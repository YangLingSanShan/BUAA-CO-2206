module NPC(
    input [31:0] D_pc,
    input [31:0] F_pc,
    input [31:0] EPC,
    input [2:0] op,
    input eret,
    input Req,
    input [15:0] Imm16,
    input [25:0] Imm26,
    input [31:0] rs,
    input jump_allow,


    output [31:0] PC
);

    parameter b = 3'b001;
    parameter j = 3'b010;
    parameter r = 3'b100;

    assign PC = (eret)                  ?  EPC + 4                                        :
                (Req)                   ?  32'h0000_4180                                  :
                (op == b && jump_allow) ?  D_pc + 32'd4 + {{14{Imm16[15]}}, Imm16, 2'b00} :
                (op == j)               ?  {D_pc[31:28], Imm26, 2'b00}                    :
                (op == r)               ?  rs                                             :
                F_pc + 32'd4;
endmodule