module Control(
    input [31:0] instruction,
    input allow,

    output [4:0] rs,
    output [4:0] rt,
    output [4:0] rd,
    output [4:0] sll_bits,
    output [15:0] Imm16,
    output [25:0] Imm26,

    output [2:0] ALUop,
    output [2:0] CMPop,
    output [2:0] NPCop,
    output [4:0] GRFaddr,
    output [2:0] GRFWDSel,
    output [1:0] ALU_SrcA_Sel,
    output [1:0] ALU_SrcB_Sel,
    output EXTop,
    output MemWrite,            //DM使能信号
    //下面是stall模块需要的信号
    output sll_flag,
    output branch,
    output r_cal,
    output i_cal,
    output load,
    output store,
    output j_imm,
    output j_reg,
    output link,
    output lui_flag,
    output condition_branch_condition_link
);
	//add, sub, ori, lw, sw, beq, lui, jal, jr, nop
    //If wanna add contidional link, add GRFselop and correct datapath of GRFData in mips.v
    wire [5:0] Opcode = instruction[31:26];
    wire [5:0] func = instruction[5:0];
    parameter R = 6'b000000;
    parameter add_fun = 6'b100000;
    parameter sub_fun = 6'b100010;
    parameter sll_fun = 6'b000000;
    parameter jr_fun  = 6'b001000;
    parameter new_fun = 6'b111111;

    parameter ori_opc = 6'b001101;
    parameter lw_opc  = 6'b100011;
    parameter sw_opc  = 6'b101011;
    parameter beq_opc = 6'b000100;
    parameter lui_opc = 6'b001111;
    parameter jal_opc = 6'b000011;
    parameter j_opc   = 6'b000010;
    parameter bltzal_opc = 6'b000001;
    //alu op
    parameter sll_sign = 3'd0;
    parameter sub_sign = 3'd1;
    parameter ori_sign = 3'd2;
    parameter add_sign = 3'd3;
    parameter lui_sign = 3'd4;
    parameter new_sign = 3'd5;
    //cmp op
    parameter beq_sign = 3'b001;
    parameter condition_sign = 3'b010;
    parameter not_sign = 3'b000;
    //EXT op
    parameter EXT_unsign = 1'b0;
    parameter EXT_sign   = 1'b1;
    //npc op
    parameter b = 3'b001;
    parameter j = 3'b010;
    parameter r = 3'b100;
    parameter c = 3'b011;
    parameter n = 3'b000;
    //alu op
    parameter A_rs = 2'b00;
    parameter A_rt = 2'b01;
    parameter B_rt  = 2'b00;
    parameter B_sll = 2'b01;
    parameter B_Imm = 2'b10;    
    //WDsel op
    parameter PC8     = 3'b001;
    parameter DM_RD   = 3'b010;
    parameter ALU_RES = 3'b000;
    parameter CBCL    = 3'b011;

    wire add = (Opcode == R && func == add_fun);
    wire sub = (Opcode == R && func == sub_fun);
    wire sll = (Opcode == R && func == sll_fun);
    wire jr  = (Opcode == R && func == jr_fun);
    wire new_= (Opcode == R && func == new_fun);
    wire ori = (Opcode == ori_opc);
    wire lw  = (Opcode == lw_opc);
    wire sw  = (Opcode == sw_opc);
    wire beq = (Opcode == beq_opc);
    wire lui = (Opcode == lui_opc);
    wire jal = (Opcode == jal_opc);
    wire j_  = (Opcode == j_opc);
    wire bltzal = (Opcode == bltzal_opc);
    assign rs = instruction[25:21];
    assign rt = instruction[20:16];
    assign rd = instruction[15:11];
    assign Imm16 = instruction[15:0];
    assign Imm26 = instruction[25:0];
    assign sll_bits = instruction[10:6];
    /*************************************************************************************/
    
    assign ALUop = sub ? sub_sign :
                   ori ? ori_sign :
                   lui ? lui_sign :
                   sll ? sll_sign :
                   new_? new_sign :
                   add_sign;
    //If add new branch group instructions,add it below
    assign CMPop = beq ? beq_sign :
                   condition_branch_condition_link ? condition_sign :
                   not_sign;
    //If add new branch group instructions,add it below
    assign NPCop = branch ? b :
                   j_imm  ? j :
                   j_reg  ? r :
                   condition_branch_condition_link ? c :
                   n;

    assign GRFaddr = r_cal          ? rd    :
                     (i_cal | load) ? rt    :
                     (link | (condition_branch_condition_link && allow))          ? 5'd31 : 5'd0;
    assign GRFWDSel = (link) ? PC8   :    //pc + 8
                      load   ? DM_RD :    //rd
                      condition_branch_condition_link ? CBCL : 
                      ALU_RES;        //ALUresult
    assign ALU_SrcA_Sel = sll_flag ? A_rt : A_rs;
    assign ALU_SrcB_Sel = r_cal                  ? B_rt  :
                          (i_cal | load | store) ? B_Imm :
                          sll_sign               ? B_sll :
                          B_rt;
    assign EXTop    = (load | store) ? EXT_sign : EXT_unsign;
    assign MemWrite = store;
    assign sll_flag = (sll);
    assign branch   = (beq);
    assign r_cal    = (add | sub | sll | new_);
    assign i_cal    = (ori | lui);
    assign load     = (lw);
    assign store    = (sw);
    assign j_imm    = (jal | j_);
    assign j_reg    = (jr);

    assign link     = (jal);
    assign lui_flag = (lui);
    assign condition_branch_condition_link =  bltzal;
endmodule