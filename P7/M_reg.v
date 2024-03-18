module M_reg(
    input clk,
    input reset,
    input enable,
    input Req,

    input [31:0] E_PC,
    input [31:0] E_instruction,
    input [31:0] E_RD2,
    input [31:0] E_ALUresult,
    input [31:0] E_MUresult,
    input E_BD,
    input [4:0] E_EXCCode,
    input E_Overflow,

    output reg [31:0] M_PC,
    output reg [31:0] M_instruction,
    output reg [31:0] M_RD2,
    output reg [31:0] M_ALUresult,
    output reg [31:0] M_MUresult,
    output reg M_BD,
    output reg [4:0] M_temp_EXCCode,
    output reg  M_Overflow
);

    always @(posedge clk) begin
        if (reset || Req) begin
            M_PC <= (Req) ? 32'h0000_4180 : 32'd0;
            M_instruction <= 32'd0;
            M_RD2 <= 32'd0;
            M_ALUresult <= 32'd0;
            M_MUresult <= 32'd0;
            M_BD <= 1'b0;
            M_temp_EXCCode <= 4'b0;
            M_Overflow <= 1'b0;
        end
        else if (enable) begin
            M_PC <= E_PC;
            M_instruction <= E_instruction;
            M_RD2 <= E_RD2;
            M_ALUresult <= E_ALUresult;
            M_MUresult <= E_MUresult;
            M_BD <= E_BD;
            M_temp_EXCCode <= E_EXCCode;
            M_Overflow <= E_Overflow;
        end    
    end
endmodule