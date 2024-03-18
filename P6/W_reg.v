module W_reg(
    input clk,
    input reset,
    input enable,

    input [31:0] M_PC,
    input [31:0] M_instruction,
    input [31:0] M_ALUresult,
    input [31:0] M_RD,
    input [31:0] M_MUresult,
    input M_allow,

    output reg [31:0] W_PC,
    output reg [31:0] W_instruction,
    output reg [31:0] W_ALUresult,
    output reg [31:0] W_RD,
    output reg [31:0] W_MUresult,
    output reg W_allow
);

    always @(posedge clk) begin
        if (reset) begin
            W_PC <= 32'd0;
            W_instruction <= 32'd0;
            W_RD <= 32'd0; 
            W_ALUresult <= 32'd0;
            W_MUresult <= 32'b0;
            W_allow <= 1'b0;
        end
        else if (enable) begin
            W_PC <= M_PC;
            W_instruction <= M_instruction;
            W_ALUresult <= M_ALUresult;
            W_RD <= M_RD; 
            W_MUresult <= M_MUresult;
            W_allow <= M_allow;
        end    
    end

endmodule