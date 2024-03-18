module CMP(
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [2:0] op,
    output allow
);
    parameter beq = 3'b001;
    parameter condition_sign = 3'b010;

    wire equal = (SrcA == SrcB);
    wire condition = ($signed(SrcA) < 0);
    assign allow = (op == beq && equal) ? 1'b1 :
                   (op == condition_sign && condition) ? 1'b1 : 
                                                         1'b0;
endmodule
//$signed(rt) < 0