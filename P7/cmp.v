module CMP(
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [2:0] op,
    output allow
);
    parameter beq = 3'b001;
    parameter bne = 3'b010;

    wire equal = (SrcA == SrcB);
    wire not_equal = (SrcA != SrcB);
    assign allow = (op == beq && equal) ? 1'b1 :
                   (op == bne && not_equal) ? 1'b1 : 
                                                        1'b0;
endmodule
//$signed(rt) < 0