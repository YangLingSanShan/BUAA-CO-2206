`include "alu.v"
`include "cmp.v"
`include "E_reg.v"
`include "stall.v"
`include "dm.v"
`include "M_reg.v"
`include "ext.v"
`include "D_reg.v"
`include "grp.v"
`include "im.v"
`include "W_reg.v"
`include "npc.v"
//`include "ctrl.v"
//F D E M W
//E,M,W -> D
//M,W   -> E
//W     -> M

//如果是有条件跳转，但是无条件链接的，把下面(E_GRFSel == 3'b011 && E_allow) ? E_PC + 8 : 32'dz; 类似所有的&&alow删掉
//并且将controller里面的 (link | (condition_branch_condition_link && allow))          ? 5'd31 : 5'd0;的&&allow删掉
module mips(
    input clk,
    input reset
);
    wire [31:0] F_instr,F_instruction,D_instruction,E_instruction,M_instruction,W_instruction;
    wire [31:0] F_PC,D_PC,E_PC,M_PC,W_PC;
    wire [4:0]  E_GRFAddr,M_GRFAddr,W_GRFAddr;  //转发时候要写到哪里
    wire [2:0]  E_GRFWDSel ,M_GRFWDSel ,W_GRFWDSel;   //找到转发数据的控制信号
    wire [31:0] E_GRFData,M_GRFData,W_GRFData;  //转发时候要写什么
    wire D_allow,E_allow,M_allow,W_allow;
    wire D_condition_branch_condition_link,E_condition_branch_condition_link,M_condition_branch_condition_link,W_condition_branch_condition_link;
    wire freeze;
    STALL _stall(
        .D_instruction(D_instruction),
        .E_instruction(E_instruction),
        .M_instruction(M_instruction),

        .stall(freeze)
    );
    /*********************************************************F级****************************************************************/
    //F级 取指 Fetch
    IM _im(
        .clk(clk),
        .reset(reset),
        .enable(!freeze),
        .NPC(npc),

        .instruction(F_instr),
        .PC(F_PC)
    );
    assign F_instruction = (!D_allow && D_condition_branch_condition_link) ? 32'b0 : F_instr;
    /*********************************************************D级****************************************************************/
    //D级
    wire D_EXTop;                           //EXT的选择信号,来自CTRL
    wire [31:0] npc;                        //计算出的下一条指令的地址
    wire [15:0] D_Imm16;                    //这个是需要扩展的16位立即数，EXT/NPC的输入,来自于CTRL
    wire [25:0] D_Imm26;                    //jal指令的跳转地址,NPC的输入，来自于CTRL
    wire [2:0] D_CMPop;                     //CMP的选择信号,来自CTRL
    wire [2:0] D_NPCop;                     //NPC的选择信号,来自CTRL
    wire [31:0] D_EXTresult;                //16位立即数在进行位扩展之后的结果,来自EXT
    wire [4:0] D_rs;                        //指令对应的rs地址,来自CTRL,传入GRP
    wire [4:0] D_rt;                        //指令对应的rt地址,来自CTRL,传入GRP
    wire [31:0] D_rd1_beforeforward;        //直接读出来的rd1,来自GRP
    wire [31:0] D_rd2_beforeforward;        //直接读出来的rd2,来自GRP
    wire [31:0] D_rd1_afterforward;         //转发处理后的rd1
    wire [31:0] D_rd2_afterforward;         //转发处理后的rd2 
    /**这里需要处理来自E,M的转发**/
    assign D_rd1_afterforward = (D_rs == 5'b0)      ? 32'b0     :
                                (D_rs == E_GRFAddr) ? E_GRFData : 
                                (D_rs == M_GRFAddr) ? M_GRFData :
                                (D_rs == W_GRFAddr) ? W_GRFData : D_rd1_beforeforward;
     
    assign D_rd2_afterforward = (D_rt == 5'b0)      ? 32'b0     :
                                (D_rt == E_GRFAddr) ? E_GRFData : 
                                (D_rt == M_GRFAddr) ? M_GRFData : 
                                (D_rt == W_GRFAddr) ? W_GRFData : D_rd2_beforeforward;                                                  
    /**转发处理结束**/
    D_reg _D(
        .clk(clk),
        .reset(reset),
        .enable(!freeze),
        .F_PC(F_PC),
        .F_instruction(F_instruction),

        .D_PC(D_PC),
        .D_instruction(D_instruction)
    );
    //D级 译码 Decode   :  D_ctrl / GRP / NPC / CMP / EXT
    
    Control D_control(
        .instruction(D_instruction),  
        .allow(D_allow),

        .rs(D_rs),
        .rt(D_rt),
        .Imm16(D_Imm16),
        .Imm26(D_Imm26),

        .CMPop(D_CMPop),
        .NPCop(D_NPCop),
        .EXTop(D_EXTop),
        .condition_branch_condition_link(D_condition_branch_condition_link)
    );
    
    GRP _grp( 
        .clk(clk),
        .reset(reset),
        .PC(W_PC),               //回写W
        .WD(W_GRFData),          //回写W
        
        .A1(D_rs),
        .A2(D_rt),
        .A3(W_GRFAddr),          //回写地址
        .RD1(D_rd1_beforeforward),
        .RD2(D_rd2_beforeforward)
    );

    CMP _cmp(
        .SrcA(D_rd1_afterforward),        
        .SrcB(D_rd2_afterforward),
        .op(D_CMPop),
        
        .allow(D_allow)
    );

    NPC _npc(
        .D_pc(D_PC),
        .F_pc(F_PC),
        .op(D_NPCop),
        .Imm16(D_Imm16),
        .Imm26(D_Imm26),
        .rs(D_rd1_afterforward),
        .jump_allow(D_allow),

        .PC(npc)
    );

    EXT _ext(
        .Imm16(D_Imm16),
        .EXTop(D_EXTop),
        
        .extend(D_EXTresult)
    );

    /*********************************************************E级****************************************************************/
    //E级
    wire [4:0] E_rs;                 //指令对应的rs地址,来自CTRL,传入
    wire [4:0] E_rt;                 //指令对应的rt地址,来自CTRL,传入GRP
    wire [2:0] E_ALUop;              //ALU的控制信号,来自CTRL,传入ALU
    wire [31:0] E_rd1_beforeforward; //未转发前的rd1数据，来自于E级寄存器
    wire [31:0] E_rd2_beforeforward; //未转发前的rd2数据，来自于E级寄存器
    wire [31:0] E_rd1_afterforward;  //转发后的rd1数据
    wire [31:0] E_rd2_afterforward;  //转发后的rd2数据
    wire [31:0] E_SrcA;              //SrcA真正输入数据
    wire [31:0] E_SrcB;              //SrcB真正输入数据
    wire [1:0] E_SrcA_Selop;         //ALU对于端口SRCA的控制选择信号
    wire [1:0] E_SrcB_Selop;         //ALU对于端口SRCB的控制选择信号
    wire [31:0] E_EXTresult;         //从E级寄存器取得的拓展器数据
    wire [4:0] E_sllBits;            //左移的位数,来自STRL
    wire [31:0] E_ALUresult;         //ALU计算结果,来自ALU
    /*
    A的来源主要取决于sll,sll的第一个操作数是rt
    parameter A_rs = 2'b00;
    parameter A_rt = 2'b01;
    B的来源主要取决于指令形式,一般来说R型指令为rt,sll为sll位数,I指令为16位立即数拓展
    parameter B_rt  = 2'b00;
    parameter B_sll = 2'b01;
    parameter B_Imm = 2'b10;
    */
    /**这里需要处理来自M,W的转发**/
    assign E_rd1_afterforward =  (E_rs == 5'b0)      ? 32'b0     :
                                 (E_rs == M_GRFAddr) ? M_GRFData :
                                 (E_rs == W_GRFAddr) ? W_GRFData : E_rd1_beforeforward;
    assign E_rd2_afterforward =  (E_rt == 5'b0)      ? 32'b0     :
                                 (E_rt == M_GRFAddr) ? M_GRFData :
                                 (E_rt == W_GRFAddr) ? W_GRFData : E_rd2_beforeforward;        
    /**转发处理结束**/
    /**这里需要处理SrcA和SrcB的数据来源**/
    assign E_SrcA = (E_SrcA_Selop == 2'b00) ? E_rd1_afterforward :
                    (E_SrcA_Selop == 2'b01) ? E_rd2_afterforward : 32'b0;

    assign E_SrcB = (E_SrcB_Selop == 2'b00) ? E_rd2_afterforward :
                    (E_SrcB_Selop == 2'b01) ? {27'b0,E_sllBits}  :
                    (E_SrcB_Selop == 2'b10) ? E_EXTresult        : 32'b0; 
    /**数据来源处理结束**/
    assign E_GRFData = (E_GRFWDSel == 3'b000) ? E_ALUresult : 
                       (E_GRFWDSel == 3'b001) ? E_PC + 8    :
                       (E_GRFWDSel == 3'b011 && E_allow) ? E_PC + 8 : 32'dz;          
    E_reg _E(
    .clk(clk),
    .reset(reset | freeze),
    .enable(1'b1),
    
    .D_RD1(D_rd1_afterforward),
    .D_RD2(D_rd2_afterforward),
    .D_instruction(D_instruction),
    .D_PC(D_PC),        //这玩意要给31号寄存器留着
    .D_EXT(D_EXTresult),
    .D_allow(D_allow),

    .E_RD1(E_rd1_beforeforward),
    .E_RD2(E_rd2_beforeforward),
    .E_instruction(E_instruction),
    .E_PC(E_PC),
    .E_EXT(E_EXTresult),
    .E_allow(E_allow)
    );
    
    //E级 执行 execute E_ctrl / ALU
    Control E_control(
        .instruction(E_instruction),  
        .allow(E_allow),

        .rs(E_rs),
        .rt(E_rt),
        .sll_bits(E_sllBits),
        .ALUop(E_ALUop),
        .GRFaddr(E_GRFAddr),
        .GRFWDSel(E_GRFWDSel),
        .ALU_SrcA_Sel(E_SrcA_Selop),
        .ALU_SrcB_Sel(E_SrcB_Selop),
        .condition_branch_condition_link(E_condition_branch_condition_link)
    );
    
    ALU _alu(
        .SrcA(E_SrcA),
        .SrcB(E_SrcB),
        .op(E_ALUop),
        .ALUresult(E_ALUresult)
    );
    /*********************************************************M级****************************************************************/
    //M级
    wire [31:0] M_rd2_beforeforward; //未转发前的rd2数据,来自于M级寄存器
    wire [31:0] M_rd2_afterforward;  //转发后的rd2数据
    wire [31:0] M_ALUresult;         //传来的ALU计算结果,来自于M级寄存器
    wire MemWrite;                   //DM写使能信号,来自于CTRL,传入DM
    wire [4:0] M_rt;                 //指令对应的rt地址,来自CTRL,传入GRP
    wire [31:0] M_DM_RD;             //读出来的DM数据
    assign M_GRFData = (M_GRFWDSel == 3'b000) ? M_ALUresult : 
                       (M_GRFWDSel == 3'b001) ? M_PC+ 8     :  
                       (M_GRFWDSel == 3'b010) ? M_DM_RD     :
                       (M_GRFWDSel == 3'b011 && M_allow) ? M_PC + 8 : 32'dz; 
    /**这里需要处理来自W的转发**/
    assign M_rd2_afterforward = (M_rt == 5'b0)             ? 32'b0     :
                                (M_rt == W_GRFAddr)        ? W_GRFData : M_rd2_beforeforward;
    /**转发处理结束**/
    M_reg _M(   
        .clk(clk),
        .reset(reset),
        .enable(1'b1),
        .E_PC(E_PC),
        .E_instruction(E_instruction),
        .E_RD2(E_rd2_afterforward),
        .E_ALUresult(E_ALUresult),
        .E_allow(E_allow),

        .M_PC(M_PC),
        .M_instruction(M_instruction),
        .M_RD2(M_rd2_beforeforward),
        .M_ALUresult(M_ALUresult),
        .M_allow(M_allow)
    );
    //M级 memory 访存 M_ctrl / DM
    
    Control M_control(
        .instruction(M_instruction),  
        .allow(M_allow),

        .rt(M_rt),
        .GRFaddr(M_GRFAddr),
        .GRFWDSel(M_GRFWDSel),
        .MemWrite(MemWrite),
        .condition_branch_condition_link(M_condition_branch_condition_link)
    );
    
    DM _dm(
        .clk(clk),
        .reset(reset),
        .PC(M_PC),
        .Addr(M_ALUresult),
        .WD(M_rd2_afterforward),
        .MemWrite(MemWrite), 
        
        .RD(M_DM_RD)
    );
    /*********************************************************W级****************************************************************/
    //W级
    assign W_GRFData = (W_GRFWDSel == 3'b000) ? W_ALUresult : 
                       (W_GRFWDSel == 3'b001) ? W_PC + 8    : 
                       (W_GRFWDSel == 3'b010) ? W_DM_RD     : 
                       (W_GRFWDSel == 3'b011 && W_allow) ?  W_PC + 8 : 32'dz; 
    wire [31:0] W_ALUresult;         //传来的ALU计算结果,来自于M级寄存器
    wire [31:0] W_DM_RD;             //读出来的DM数据
    W_reg _W(
        .clk(clk),
        .reset(reset),
        .enable(1'b1),

        .M_PC(M_PC),
        .M_instruction(M_instruction),
        .M_ALUresult(M_ALUresult),
        .M_RD(M_DM_RD),
        .M_allow(M_allow),

        .W_PC(W_PC),
        .W_instruction(W_instruction),
        .W_ALUresult(W_ALUresult),
        .W_RD(W_DM_RD),
        .W_allow(W_allow)
    );
    
    //W级 writeback 回写
    Control W_control(
        .instruction(W_instruction),
        .allow(W_allow),

        .GRFaddr(W_GRFAddr),
        .GRFWDSel(W_GRFWDSel),
        .condition_branch_condition_link(W_condition_branch_condition_link)
    );
    
    

                        
endmodule