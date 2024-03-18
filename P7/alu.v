module ALU(
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [3:0] op,
    output [31:0] ALUresult,
    output overflow
);
    parameter sll = 4'd0;
    parameter sub = 4'd1;
    parameter ori = 4'd2;
    parameter add = 4'd3;
    parameter lui = 4'd4;
    parameter and_= 4'd5;
    parameter slt = 4'd6;
    parameter sltu= 4'd7;
    reg [31:0] rst;
    assign ALUresult = rst;
    wire [32:0] temp = (op == add) ? {SrcA[31],SrcA} + {SrcB[31],SrcB} : 
                       (op == sub) ? {SrcA[31],SrcA} - {SrcB[31],SrcB} : 33'b0;
    assign overflow = (temp[32] != temp[31]);                  

    always @(*) begin
        case (op)
            sll:
                rst = SrcA << SrcB[4:0];
            sub:
                rst = SrcA - SrcB;
            ori:
                rst = SrcA | SrcB;
            add:
                rst = SrcA + SrcB;
            lui: 
                rst = SrcB << 16;
            and_:
                rst = SrcA & SrcB;
            slt:
                rst = $signed(SrcA) < $signed(SrcB) ? 32'b1 : 32'b0;
            sltu:
                rst = SrcA < SrcB ? 32'b1 : 32'b0;
            default: 
                rst = 32'd0;
        endcase
    end
	
endmodule


//`ALU_srl: C = B >> shamt;
//`ALU_sra: C = $signed($signed(B) >> shamt);