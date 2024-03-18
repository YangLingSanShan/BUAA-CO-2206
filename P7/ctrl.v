module Control(
    input [31:0] instruction,
    
    output [4:0] rs,
    output [4:0] rt,
    output [4:0] rd,
    output [4:0] sll_bits,
    output [15:0] Imm16,
    output [25:0] Imm26,

    output [3:0] ALUop,
    output [2:0] CMPop,
    output [2:0] NPCop,
    output [4:0] GRFaddr,
    output [2:0] GRFWDSel,
    output GRFWrEn,
    output [1:0] ALU_SrcA_Sel,
    output [1:0] ALU_SrcB_Sel,
    output [1:0] BE_op,
    output [2:0] DE_op,
	output [3:0] MU_op,
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
    output Start,
    output move_to,
    output move_from,
    output branch_link,
    output lui_flag,
    output eret,
    output CP0en,
    output EXT_RI,
    output Ari_Ov,
    output MFC0,
    output MTC0,
    output Syscall
);
	//add, sub, ori, lw, sw, beq, lui, jal, jr, nop
    //If wanna add contidional link, add GRFselop and correct datapath of GRFData in mips.v
    wire [5:0] Opcode = instruction[31:26];
    wire [5:0] func = instruction[5:0];
    parameter R = 6'b000000;
    parameter COP0 = 6'b010000;
    parameter add_fun = 6'b100000;
    parameter sub_fun = 6'b100010;
    parameter sll_fun = 6'b000000;
    parameter jr_fun  = 6'b001000;
    parameter and_fun = 6'b100100;
    parameter or_fun  = 6'b100101;
    parameter slt_fun = 6'b101010;
    parameter sltu_fun= 6'b101011;
	parameter mult_fun= 6'b011000;
	parameter multu_fun = 6'b011001;
	parameter div_fun = 6'b011010;
	parameter divu_fun= 6'b011011;
	parameter mfhi_fun= 6'b010000;
	parameter mflo_fun= 6'b010010;
	parameter mthi_fun= 6'b010001;
	parameter mtlo_fun= 6'b010011;
    parameter syscall_fun= 6'b001100;

    //mult, multu, div, divu, mfhi, mflo, mthi, mtlo
	parameter ori_opc = 6'b001101;
    parameter lw_opc  = 6'b100011;
    parameter sw_opc  = 6'b101011;
    parameter beq_opc = 6'b000100;
    parameter lui_opc = 6'b001111;
    parameter jal_opc = 6'b000011;
    parameter addi_opc= 6'b001000;
    parameter andi_opc= 6'b001100;
    parameter bne_opc = 6'b000101;
    parameter lh_opc  = 6'b100001;
    parameter lb_opc  = 6'b100000;
    parameter sb_opc  = 6'b101000;
    parameter sh_opc  = 6'b101001;
    parameter lhu_opc = 6'b100101;
    parameter lbu_opc = 6'b100100;
    parameter j_opc = 6'b000010;
    //alu op
    parameter sll_sign = 4'd0;
    parameter sub_sign = 4'd1;
    parameter ori_sign = 4'd2;
    parameter add_sign = 4'd3;
    parameter lui_sign = 4'd4;
    parameter and_sign = 4'd5;
    parameter slt_sign = 4'd6;
    parameter sltu_sign= 4'd7;
    //cmp op
    parameter beq_sign = 3'b001;
    parameter bne_sign = 3'b010;
    parameter not_sign = 3'b000;
    //EXT op
    parameter EXT_unsign = 1'b0;
    parameter EXT_sign   = 1'b1;
    //npc op
    parameter b = 3'b001;
    parameter j = 3'b010;
    parameter r = 3'b100;
    parameter n = 3'b000;
    //alu op
    parameter A_rs = 2'b00;
    parameter A_rt = 2'b01;
    parameter B_rt  = 2'b00;
    parameter B_sll = 2'b01;
    parameter B_Imm = 2'b10;    
    //WDsel op
    parameter PC8 = 3'b001;
    parameter DM_RD = 3'b010;
    parameter MU_RES = 3'b011;
    parameter CP0 = 3'b100;
    parameter ALU_RES = 3'b000;
    //BE op
    parameter BE_word = 2'b00;
    parameter BE_byte = 2'b01;
    parameter BE_half = 2'b10;
    parameter BE_none = 2'b11;
    //de op
    parameter DE_lw = 3'b000;
    parameter DE_lbu = 3'b001;
    parameter DE_lb = 3'b010;
    parameter DE_lhu = 3'b011;
    parameter DE_lh = 3'b100;
    //MU op
	parameter MU_mult = 4'b0000;
	parameter MU_multu= 4'b0001;
	parameter MU_div  = 4'b0010;
	parameter MU_divu = 4'b0011;
	parameter MU_mthi = 4'b0100;
	parameter MU_mtlo = 4'b0101;
	parameter MU_mfhi = 4'b0110;
	parameter MU_mflo = 4'b0111;
	parameter MU_none = 4'b1000;
	
    wire add = (Opcode == R && func == add_fun);
    wire sub = (Opcode == R && func == sub_fun);
    wire sll = (Opcode == R && func == sll_fun);
    wire jr  = (Opcode == R && func == jr_fun);
    wire and_= (Opcode == R && func == and_fun);
    wire or_ = (Opcode == R && func == or_fun);
    wire slt = (Opcode == R && func == slt_fun);
    wire sltu= (Opcode == R && func == sltu_fun);
    wire syscall = (Opcode == R && func == syscall_fun);
    wire ori = (Opcode == ori_opc);
    wire lw  = (Opcode == lw_opc);
    wire sw  = (Opcode == sw_opc);
    wire beq = (Opcode == beq_opc);
    wire lui = (Opcode == lui_opc);
    wire jal = (Opcode == jal_opc);
    wire j_  = (Opcode == j_opc);
    wire addi= (Opcode == addi_opc);
    wire andi= (Opcode == andi_opc);
    wire bne = (Opcode == bne_opc);
    wire lh  = (Opcode == lh_opc);
    wire lb  = (Opcode == lb_opc);
    wire sb  = (Opcode == sb_opc);
    wire sh  = (Opcode == sh_opc);
    wire lbu = (Opcode == lbu_opc);
    wire lhu = (Opcode == lhu_opc);
	//mult, multu, div, divu, mfhi, mflo, mthi, mtlo
	wire mult= (Opcode == R && func == mult_fun);
	wire multu= (Opcode == R && func == multu_fun);
	wire div = (Opcode == R && func == div_fun);
	wire divu= (Opcode == R && func == divu_fun);
	wire mfhi= (Opcode == R && func == mfhi_fun);
	wire mflo= (Opcode == R && func == mflo_fun);
	wire mthi= (Opcode == R && func == mthi_fun);
	wire mtlo= (Opcode == R && func == mtlo_fun);
    wire mfc0= (Opcode == COP0 && rs == 0);
    wire mtc0= (Opcode == COP0 && rs == 4);
    
    assign rs = instruction[25:21];
    assign rt = instruction[20:16];
    assign rd = instruction[15:11];
    assign Imm16 = instruction[15:0];
    assign Imm26 = instruction[25:0];
    assign sll_bits = instruction[10:6];
    /*************************************************************************************/
    
    assign ALUop = sub ? sub_sign :
                   (ori | or_)   ? ori_sign :
                   lui ? lui_sign :
                   sll ? sll_sign :
                   (and_ | andi) ? and_sign : 
                   slt ? slt_sign :
                   sltu? sltu_sign:
                   add_sign;
    //If add new branch group instructions,add it below
    assign CMPop = beq ? beq_sign :
                   bne ? bne_sign :
                   not_sign;
    //If add new branch group instructions,add it below
    assign NPCop = branch ? b :
                   j_imm  ? j :
                   j_reg  ? r :
                   n;
    assign GRFaddr = (r_cal | move_from)        ? rd    :
                     (i_cal | load | mfc0)      ? rt    :
                     link                       ? 5'd31 : 5'd0;

    assign GRFWDSel = link ? PC8   :    //pc + 8
                      load ? DM_RD :    //rd
                      move_from ? MU_RES :
                      mfc0 ? CP0 :
                      ALU_RES;        //ALUresult
    assign GRFWrEn = !(store | branch  | j | jr);
    //assign GRFWrEn = !((store) | (branch && !branch_link) | j | jr); 条件链接用这个
    assign ALU_SrcA_Sel = sll_flag ? A_rt : A_rs;
    assign ALU_SrcB_Sel = r_cal                  ? B_rt  :
                          (i_cal | load | store) ? B_Imm :
                          sll_sign               ? B_sll :
                          B_rt;
    assign BE_op = (sw) ? BE_word :
                   (sh) ? BE_half :
                   (sb) ? BE_byte : 
                   BE_none;
    assign DE_op = (lw) ? DE_lw :
                   (lh) ? DE_lh :
                   (lhu)? DE_lhu:
                   (lb) ? DE_lb :
                   (lbu)? DE_lbu: DE_lhu;
				   
	assign MU_op = (mult) ? MU_mult :
				   (multu)? MU_multu:
				   (div)  ? MU_div	:
				   (divu) ? MU_divu :
				   (mthi) ? MU_mthi :
				   (mtlo) ? MU_mtlo :
				   (mfhi) ? MU_mfhi :
				   (mflo) ? MU_mflo :
				   MU_none;
				   
    assign EXTop    = (load | store | (i_cal && !andi && !ori)) ? EXT_sign : EXT_unsign;
    assign sll_flag = (sll);
    assign branch   = (beq | bne );
    assign r_cal    = (add | sub | sll | and_ | or_ | slt | sltu | mult | multu | div | divu);
    assign i_cal    = (ori | lui | addi | andi);
    assign load     = (lw | lh | lb | lbu | lhu);
    assign store    = (sw | sh | sb);
    assign j_imm    = (jal|j_);
    assign j_reg    = (jr);
    assign move_to  = (mtlo | mthi);
    assign move_from= (mflo | mfhi);
    //assign branch_link = 0;                // uc-unconditional 无条件链接
    //If add conditonal link instructions,add a signal below
    assign link     = (jal);
    assign Start    = (mult | multu | div | divu);
    assign lui_flag = (lui);
    assign eret = (instruction == 32'h42000018);
    assign CP0en = mtc0;
    assign EXT_RI = !(add | sub | sll | jr | and_ | or_ | slt | sltu | ori | lw | sw | beq | lui | jal | j_ | addi | andi | bne | lh | lb | sb | sh | 
                      lbu | lhu | mult | multu | div | divu | mfhi | mflo | mthi | mtlo | mfc0 | mtc0 | eret | syscall);
    assign Ari_Ov = (addi | add | sub);
    assign MFC0 = mfc0;
    assign MTC0 = mtc0;
    assign Syscall = syscall;
endmodule