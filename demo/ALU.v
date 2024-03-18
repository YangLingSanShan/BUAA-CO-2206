module ALU(
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [2:0] op,
    output [31:0] ALUresult,
    output equal
);
    parameter sll = 3'd0;
    parameter sub = 3'd1;
    parameter ori = 3'd2;
    parameter add = 3'd3;
    parameter lui = 3'd4;
    reg [31:0] rst;
    assign equal = (SrcA == SrcB);
    assign ALUresult = rst;
    always @(*) begin
        case (op)
            sll:
                rst = SrcA << SrcB[4:0];
            sub:
                rst = SrcA - SrcB;
            ori:
                rst = SrcA | {16'h0000,SrcB[15:0]};
            add:
                rst = SrcA + SrcB;
            lui: 
                rst = SrcB << 16;
            default: 
                rst = 32'd0;
        endcase
    end
	
endmodule