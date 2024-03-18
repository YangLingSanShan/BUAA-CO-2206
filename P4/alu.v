module ALU(
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [2:0] op,
    output [31:0] ALUresult,
    output equal,
    output condition
);

    assign condition = 0;    //to be continued!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    integer i;

    reg [31:0] temp;
    //If want to add a beq-type instruction, add another output signal to  calculate
    parameter sll = 3'd0;
    parameter sub = 3'd1;
    parameter ori = 3'd2;
    parameter add = 3'd3;
    parameter lui = 3'd4;
    //parameter new_instr = 3'd5; 
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
            //new_instr:  
            //注意，这里传进来的是符号扩展的，如果需要，请根据内容修改
            default: 
                rst = 32'd0;
        endcase
    end


endmodule


//`ALU_srl: C = B >> shamt;
//`ALU_sra: C = $signed($signed(SrcB) >>> shamt);
/*
    SrcA[0]  + SrcA[1]  + SrcA[2]  + SrcA[3]  +
    SrcA[4]  + SrcA[5]  + SrcA[6]  + SrcA[7]  +
    SrcA[8]  + SrcA[9]  + SrcA[10] + SrcA[11] +
    SrcA[12] + SrcA[13] + SrcA[14] + SrcA[15] +
    SrcA[16] + SrcA[17] + SrcA[18] + SrcA[19] +
    SrcA[20] + SrcA[21] + SrcA[22] + SrcA[23] +
    SrcA[24] + SrcA[25] + SrcA[26] + SrcA[27] +
    SrcA[28] + SrcA[29] + SrcA[30] + SrcA[31] +

    SrcB[0]  + SrcB[1]  + SrcB[2]  + SrcB[3]  +
    SrcB[4]  + SrcB[5]  + SrcB[6]  + SrcB[7]  +
    SrcB[8]  + SrcB[9]  + SrcB[10] + SrcB[11] +
    SrcB[12] + SrcB[13] + SrcB[14] + SrcB[15] +
    SrcB[16] + SrcB[17] + SrcB[18] + SrcB[19] +
    SrcB[20] + SrcB[21] + SrcB[22] + SrcB[23] +
    SrcB[24] + SrcB[25] + SrcB[26] + SrcB[27] +
    SrcB[28] + SrcB[29] + SrcB[30] + SrcB[31] +
*/