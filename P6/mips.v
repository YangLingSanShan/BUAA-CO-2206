`include "alu.v"
`include "cmp.v"
`include "E_reg.v"
`include "stall.v"
`include "BE.v"
`include "DE.v"
`include "MD.v"
`include "M_reg.v"
`include "ext.v"
`include "D_reg.v"
`include "grp.v"
`include "im.v"
`include "W_reg.v"
`include "npc.v"
//F D E M W
//E,M,W -> D
//M,W   -> E
//W     -> M
//如果是有条件跳转，但是无条件链接的，把下面(E_GRFSel == 3'b011 && E_allow) ? E_PC + 8 : 32'dz; 类似所有的&&alow删掉
//并且将controller里面的 (link | (condition_branch_condition_link && allow))          ? 5'd31 : 5'd0;的&&allow删掉
module mips(
    input clk,
    input reset,
    input [31:0] i_inst_rdata,
    input [31:0] m_data_rdata,
    output [31:0] i_inst_addr,
    output [31:0] m_data_addr,
    output [31:0] m_data_wdata,
    output [3:0] m_data_byteen, 
    output [31:0] m_inst_addr,
    output w_grf_we,
    output [4:0] w_grf_addr,
    output [31:0] w_grf_wdata,
    output [31:0] w_inst_addr
);
    /*
    assign w_grf_we = 1'b1;
    assign w_grf_wdata = (W_GRFData === 32'dz) ? 32'd0 : W_GRFData;
    assign w_grf_addr  = (W_GRFAddr === 5'dx) ? 5'd0 : W_GRFAddr;
    assign w_inst_addr = W_PC;
    */

    wire [31:0] F_instruction,D_instruction,E_instruction,M_instruction,W_instruction;    //F_instruction = i_inst_rdata
    wire [31:0] F_PC,D_PC,E_PC,M_PC,W_PC;
    wire [4:0]  E_GRFAddr,M_GRFAddr,W_GRFAddr;  //forward to where
    wire [2:0]  E_GRFSel ,M_GRFSel ,W_GRFSel;   //get forward what
    wire [31:0] E_GRFData,M_GRFData,W_GRFData;  //forward what is here
    wire D_cbcl,E_cbcl,M_cbcl,W_cbcl;
    wire D_allow,E_allow,M_allow,W_allow;
    wire freeze;
    wire busy;
    //assign F_instruction = (i_inst_rdata === 32'bx || (!D_allow && D_cbcl)) ? 32'b0 : i_inst_rdata;
    assign F_instruction = (i_inst_rdata === 32'bx) ? 32'b0 : i_inst_rdata;
    STALL _stall(
        .D_instruction(D_instruction),
        .E_instruction(E_instruction),
        .M_instruction(M_instruction),
        .Busy(busy),
        .stall(freeze)
    );
    /*********************************************************F***************************************************************/
    //F Fetch
    IM _im(
        .clk(clk),
        .reset(reset),
        .enable(!freeze),
        .NPC(npc),

        .PC(F_PC)
    );
	assign i_inst_addr = F_PC;
    /*********************************************************D***************************************************************/
    wire D_EXTop;                           //EXT op,from CTRL
    wire [31:0] npc;                        //next pc
    wire [15:0] D_Imm16;                    //Imm16 waiting for extend, to EXT/NPC, from ctrl
    wire [25:0] D_Imm26;                    //jal , to NPC，from ctrl
    wire [2:0] D_CMPop;                     //CMP op,from CTRL
    wire [2:0] D_NPCop;                     //NPC op,from CTRL
    wire [31:0] D_EXTresult;                //Imm16 -> 32
    wire [4:0] D_rs;                        //rs in instruction, from ctrl,to GRP
    wire [4:0] D_rt;                        //rt in instruction, from ctrl,to GRP
    wire [31:0] D_rd1_beforeforward;        //rd1 before forward 
    wire [31:0] D_rd2_beforeforward;        //rd2 before forward 
    wire [31:0] D_rd1_afterforward;         //rd1 after forward 
    wire [31:0] D_rd2_afterforward;         //rd2 after forward 
    /**BEGIN FORWARD**/
    assign D_rd1_afterforward = (D_rs == 5'b0)      ? 32'b0     :
                                (D_rs == E_GRFAddr) ? E_GRFData : 
                                (D_rs == M_GRFAddr) ? M_GRFData :
                                (D_rs == W_GRFAddr) ? W_GRFData : D_rd1_beforeforward;
     
    assign D_rd2_afterforward = (D_rt == 5'b0)      ? 32'b0     :
                                (D_rt == E_GRFAddr) ? E_GRFData : 
                                (D_rt == M_GRFAddr) ? M_GRFData : 
                                (D_rt == W_GRFAddr) ? W_GRFData : D_rd2_beforeforward;                                                  
    /**END FORWARD**/
    D_reg _D(
        .clk(clk),
        .reset(reset),
        .enable(!freeze),
        .F_PC(F_PC),
        .F_instruction(F_instruction),

        .D_PC(D_PC),
        .D_instruction(D_instruction)
    );
    //D Decode   :  D_ctrl / GRP / NPC / CMP / EXT
    
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
        .cbcl(D_cbcl)
    );
    
    GRP _grp( 
        .clk(clk),
        .reset(reset),
        .PC(W_PC),               //W
        .WD(W_GRFData),          //W
        
        .A1(D_rs),
        .A2(D_rt),
        .A3(W_GRFAddr),          //W addr
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

    /*********************************************************E***************************************************************/
    //E
    wire [4:0] E_rs;                 //rs addr,from CTRL,to GRP
    wire [4:0] E_rt;                 //rt addr,from CTRL,to GRP
    wire [3:0] E_ALUop;              //ALU op ,from CTRL,to ALU
    wire [31:0] E_rd1_beforeforward; //from D
    wire [31:0] E_rd2_beforeforward; //from D
    wire [31:0] E_rd1_afterforward;  
    wire [31:0] E_rd2_afterforward;  
    wire [31:0] E_SrcA;              //SrcA real in
    wire [31:0] E_SrcB;              //SrcB real in
    wire [1:0] E_SrcA_Selop;         //ALU -> SRCA op
    wire [1:0] E_SrcB_Selop;         //ALU -> SRCB op
    wire [31:0] E_EXTresult;         //extend
    wire [4:0] E_sllBits;            //sll bits
    wire [31:0] E_ALUresult;         //ALU result
	wire [3:0] E_MU_op;	
    wire E_Start;
    wire [31:0] E_HI;
    wire [31:0] E_LO;
    wire [31:0] E_MUresult;
    /**BEGIN FORWARD**/
    assign E_rd1_afterforward =  (E_rs == 5'b0)      ? 32'b0     :
                                 (E_rs == M_GRFAddr) ? M_GRFData :
                                 (E_rs == W_GRFAddr) ? W_GRFData : E_rd1_beforeforward;
    assign E_rd2_afterforward =  (E_rt == 5'b0)      ? 32'b0     :
                                 (E_rt == M_GRFAddr) ? M_GRFData :
                                 (E_rt == W_GRFAddr) ? W_GRFData : E_rd2_beforeforward;        
    /**END FORWARD**/
    /**SrcA and SrcB data source*/
     /*
    A (sll first opprand is rt)
    parameter A_rs = 2'b00;
    parameter A_rt = 2'b01;
    
    parameter B_rt  = 2'b00;
    parameter B_sll = 2'b01;
    parameter B_Imm = 2'b10;
    */
    assign E_SrcA = (E_SrcA_Selop == 2'b00) ? E_rd1_afterforward :
                    (E_SrcA_Selop == 2'b01) ? E_rd2_afterforward : 32'b0;

    assign E_SrcB = (E_SrcB_Selop == 2'b00) ? E_rd2_afterforward :
                    (E_SrcB_Selop == 2'b01) ? {27'b0,E_sllBits}  :
                    (E_SrcB_Selop == 2'b10) ? E_EXTresult        : 32'b0; 
    /**END**/
    //parameter MU_mflo = 4'b0111;
    //parameter MU_mfhi = 4'b0110;
    assign E_GRFData = (E_GRFSel == 3'b000) ? E_ALUresult : 
                       (E_GRFSel == 3'b001) ? E_PC + 8    :
                       (E_GRFSel == 3'b100 && E_allow) ? E_PC + 8    : 32'dz;        
    assign E_MUresult = (E_MU_op == 4'b0110) ? E_HI :
                        (E_MU_op == 4'b0111) ? E_LO : 32'bz;	
	                                    
    E_reg _E(
    .clk(clk),
    .reset(reset | freeze),
    .enable(1'b1),
    
    .D_RD1(D_rd1_afterforward),
    .D_RD2(D_rd2_afterforward),
    .D_instruction(D_instruction),
    .D_PC(D_PC),        
    .D_EXT(D_EXTresult),
    .D_allow(D_allow),

    .E_RD1(E_rd1_beforeforward),
    .E_RD2(E_rd2_beforeforward),
    .E_instruction(E_instruction),
    .E_PC(E_PC),
    .E_EXT(E_EXTresult),
    .E_allow(E_allow)
    );
    
    //E execute E_ctrl / ALU / MD
    Control E_control(
        .instruction(E_instruction),
        .allow(E_allow),
    
        .rs(E_rs),
        .rt(E_rt),
        .sll_bits(E_sllBits),
        .ALUop(E_ALUop),
        .GRFaddr(E_GRFAddr),
        .GRFWDSel(E_GRFSel),
        .ALU_SrcA_Sel(E_SrcA_Selop),
        .ALU_SrcB_Sel(E_SrcB_Selop),
		.MU_op(E_MU_op),
        .Start(E_Start),
        .cbcl(E_cbcl)
    );
    
    ALU _alu(
        .SrcA(E_SrcA),
        .SrcB(E_SrcB),
        .op(E_ALUop),
        .ALUresult(E_ALUresult)
    );
	
	MD _MD(
        .clk(clk),
        .reset(reset),
        .SrcA(E_SrcA),
        .SrcB(E_SrcB),
        .MU_op(E_MU_op),
        .Start(E_Start & !Req),
        
        .Busy(busy),
        .HI(E_HI),
        .LO(E_LO)
	);
    /*********************************************************M***************************************************************/
    wire [31:0] M_rd2_beforeforward; //not forward rd2 data ,from E
    wire [31:0] M_rd2_afterforward;  //after forward rd2 data
    wire [31:0] M_ALUresult;         //ALU result,from E
    wire [31:0] M_MUresult;          //MU result,from E
    wire [4:0] M_rt;                 //rt Address, from CTRL, to GRP
    wire [31:0] M_DE_RD;             //Read Data from DE
    wire [1:0] M_BE_op;
    wire [2:0] M_DE_op;              
    assign m_inst_addr = M_PC;
    assign m_data_addr = M_ALUresult;
    assign M_GRFData = (M_GRFSel == 3'b000) ? M_ALUresult : 
                       (M_GRFSel == 3'b001) ? M_PC + 8    :  
                       (M_GRFSel == 3'b011) ? M_MUresult  :
                       (M_GRFSel == 3'b100 && M_allow) ? M_PC + 8    :  32'dz; 
    /*BEGIN FORWARD*/
    assign M_rd2_afterforward = (M_rt == 5'b0)             ? 32'b0     :
                                (M_rt == W_GRFAddr)        ? W_GRFData : M_rd2_beforeforward;
    /**END FORWARD**/
    M_reg _M(   
        .clk(clk),
        .reset(reset),
        .enable(1'b1),
        .E_PC(E_PC),
        .E_instruction(E_instruction),
        .E_RD2(E_rd2_afterforward),
        .E_ALUresult(E_ALUresult),
        .E_MUresult(E_MUresult),
        .E_allow(E_allow),

        .M_PC(M_PC),
        .M_instruction(M_instruction),
        .M_RD2(M_rd2_beforeforward),
        .M_ALUresult(M_ALUresult),
        .M_MUresult(M_MUresult),
        .M_allow(M_allow)
    );
    //M memory  M_ctrl / BE / DE
    
    Control M_control(
        .instruction(M_instruction),  
        .allow(M_allow),

        .rt(M_rt),
        .GRFaddr(M_GRFAddr),
        .GRFWDSel(M_GRFSel),
        .DE_op(M_DE_op),
        .BE_op(M_BE_op),
        .cbcl(M_cbcl)
    );

    BE M_BE(
        .op(M_BE_op),
        .Addr(M_ALUresult[1:0]),
        .WD(M_rd2_afterforward),

        .m_data_byteen(m_data_byteen),
        .m_data_wdata(m_data_wdata)
    );
	
    DE M_DE(
        .Addr(M_ALUresult[1:0]),
        .m_data_rdata(m_data_rdata),
        .op(M_DE_op),
        .DE_RD(M_DE_RD)
    );

    /*********************************************************W***************************************************************/
    wire [31:0] W_ALUresult;         //ALUresult from M
    wire [31:0] W_DE_RD;             //DM data from M
    wire [31:0] W_MUresult;
    assign W_GRFData = (W_GRFSel == 3'b000) ? W_ALUresult : 
                       (W_GRFSel == 3'b001) ? W_PC + 8    : 
                       (W_GRFSel == 3'b010) ? W_DE_RD     :
                       (W_GRFSel == 3'b011) ? W_MUresult  :
                       (W_GRFSel == 3'b100 && W_allow) ? W_PC + 8    : 32'dz; 
    W_reg _W(
        .clk(clk),
        .reset(reset),
        .enable(1'b1),

        .M_PC(M_PC),
        .M_instruction(M_instruction),
        .M_ALUresult(M_ALUresult),
        .M_RD(M_DE_RD),
        .M_MUresult(M_MUresult),
        .M_allow(M_allow),

        .W_PC(W_PC),
        .W_instruction(W_instruction),
        .W_ALUresult(W_ALUresult),
        .W_RD(W_DE_RD),
        .W_MUresult(W_MUresult),
        .W_allow(W_allow)
    );
    
    //Writeback 
    Control W_control(
        .instruction(W_instruction),
        .allow(W_allow),
        
        .GRFaddr(W_GRFAddr),
        .GRFWDSel(W_GRFSel),
        .cbcl(W_cbcl)
    );
    
    

                        
endmodule