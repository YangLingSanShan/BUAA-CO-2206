module M_reg(
    input clk,
    input reset,
    input enable,
    input [31:0] E_PC,
    input [31:0] E_instruction,
    input [31:0] E_RD2,
    input [31:0] E_ALUresult,
    input E_allow,

    output reg [31:0] M_PC,
    output reg [31:0] M_instruction,
    output reg [31:0] M_RD2,
    output reg [31:0] M_ALUresult,
    output reg M_allow
);

    always @(posedge clk) begin
        if (reset) begin
            M_PC <= 32'd0;
            M_instruction <= 32'd0;
            M_RD2 <= 32'd0;
            M_ALUresult <= 32'd0;
            M_allow <= 1'b0;
        end
        else if (enable) begin
            M_PC <= E_PC;
            M_instruction <= E_instruction;
            M_RD2 <= E_RD2;
            M_ALUresult <= E_ALUresult;
            M_allow <= E_allow;
        end    
    end
endmodule