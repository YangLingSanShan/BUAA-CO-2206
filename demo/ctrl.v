module CTRL(
    input [31:0] instruction,
    output [2:0] alu_op,    //b,j,r
    output [2:0] npc_op,
    
    output RegWrite,
    output RegDst,
    output MemWrite,
    output MemtoReg,
    output sll_sign,
    output AlUsrc,
    output link
);
	//add, sub, ori, lw, sw, beq, lui, jal, jr, nop
    wire [5:0] Opcode = instruction[31:26];
    wire [5:0] func = instruction[5:0];
    parameter R = 6'b000000;
    parameter add_fun = 6'b100000;
    parameter sub_fun = 6'b100010;
    parameter sll_fun = 6'b000000;
    parameter jr_fun  = 6'b001000;

    parameter ori_opc = 6'b001101;
    parameter lw_opc  = 6'b100011;
    parameter sw_opc  = 6'b101011;
    parameter beq_opc = 6'b000100;
    parameter lui_opc = 6'b001111;
    parameter jal_opc = 6'b000011;

    wire add = (Opcode == R && func == add_fun);
    wire sub = (Opcode == R && func == sub_fun);
    wire sll = (Opcode == R && func == sll_fun);
    wire jr  = (Opcode == R && func == jr_fun);
    wire ori = (Opcode == ori_opc);
    wire lw  = (Opcode == lw_opc);
    wire sw  = (Opcode == sw_opc);
    wire beq = (Opcode == beq_opc);
    wire lui = (Opcode == lui_opc);
    wire jal = (Opcode == jal_opc);
    
    assign RegWrite = (add | sub | sll | ori | lw  | jal | lui) ? 1'b1 : 1'b0;
    assign RegDst   = (add | sub | sll) ? 1'b1 : 1'b0;
    assign AlUsrc   = (ori | lw  | sw  | lui) ? 1'b1 : 1'b0;
    assign sll_sign = sll ? 1'b1 : 1'b0;
    assign MemtoReg = lw  ? 1'b1 : 1'b0;
    assign MemWrite = sw  ? 1'b1 : 1'b0;
    assign link     = jal ? 1'b1 : 1'b0;
    assign npc_op   = beq ? 3'b001 : 
                      jal ? 3'b010 : 
                      jr  ? 3'b100 : 3'b000;
    assign alu_op   = sll ? 3'b000 : 
                      sub ? 3'b001 : 
                      ori ? 3'b010 : 
                      (add | lw | sw ) ? 3'b011 : 
                      lui ? 3'b100 : 3'b101;
endmodule