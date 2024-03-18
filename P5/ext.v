module EXT(
    input [15:0] Imm16,
    input EXTop,
    output [31:0] extend
);
    //0 是 0 扩展
    //1 是 符号扩展
    parameter EXT_unsign = 1'b0;
    parameter EXT_sign   = 1'b1;
    assign extend = (EXTop == EXT_sign) ? {{16{Imm16[15]}},Imm16} : {16'b0,Imm16};
endmodule