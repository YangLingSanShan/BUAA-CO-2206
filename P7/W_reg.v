module W_reg(
    input clk,
    input reset,
    input enable,
    input Req,

    input [31:0] M_PC,
    input [31:0] M_instruction,
    input [31:0] M_ALUresult,
    input [31:0] M_RD,
    input [31:0] M_MUresult,
    input M_condition_link,
    input M_BD,
    input [4:0] M_EXCCode,
    input [31:0] M_CP0out,


    output reg [31:0] W_PC,
    output reg [31:0] W_instruction,
    output reg [31:0] W_ALUresult,
    output reg [31:0] W_RD,
    output reg [31:0] W_MUresult,
    output reg W_condition_link,
    output reg W_BD,
    output reg [4:0] W_temp_EXCCode,
    output reg [31:0] W_CP0out
);

    always @(posedge clk) begin
        if (reset || Req) begin
            W_PC <= (Req) ? 32'h0000_4180 : 32'd0;
            W_instruction <= 32'd0;
            W_RD <= 32'd0; 
            W_ALUresult <= 32'd0;
            W_MUresult <= 32'b0;
            W_condition_link <= 1'b0;
            W_BD <= 1'b0;
            W_temp_EXCCode <= 4'b0;
            W_CP0out <= 32'd0; 
        end
        else if (enable) begin
            W_PC <= M_PC;
            W_instruction <= M_instruction;
            W_ALUresult <= M_ALUresult;
            W_RD <= M_RD; 
            W_MUresult <= M_MUresult;
            W_condition_link <= M_condition_link;
            W_BD <= M_BD;
            W_temp_EXCCode <= M_EXCCode;
            W_CP0out <= M_CP0out;
        end    
    end

endmodule