module ALU(
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [2:0] op,
    output [31:0] ALUresult
);
    parameter sll = 3'd0;
    parameter sub = 3'd1;
    parameter ori = 3'd2;
    parameter add = 3'd3;
    parameter lui = 3'd4;
    parameter new_= 3'd5;
    reg [31:0] rst;
    reg [31:0] temp;
    integer i;
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
            new_:begin
                temp = SrcB;
                for (i = 0;i < 32;i = i + 1) begin
                    if (SrcA[i] == 1) 
                        rst[i] = 1;
                    else begin
                        if (temp > 0) begin
                            temp = temp - 1;
                            rst[i] = 1;
                        end
                        else begin
                            rst[i] = 0;
                        end
                    end
                end
            end
            default: 
                rst = 32'd0;
        endcase
    end
	
endmodule


//`ALU_srl: C = B >> shamt;
//`ALU_sra: C = $signed($signed(B) >> shamt);