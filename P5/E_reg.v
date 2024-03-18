module E_reg(
    input clk,
    input reset,
    input enable,
    
    input [31:0] D_RD1,
    input [31:0] D_RD2,
    input [31:0] D_instruction,
    input [31:0] D_PC,
    input [31:0] D_EXT,
    input D_allow,

    output reg [31:0] E_RD1,
    output reg [31:0] E_RD2,
    output reg [31:0] E_instruction,
    output reg [31:0] E_PC,
    output reg [31:0] E_EXT,
    output reg E_allow
);

    always @(posedge clk) begin
        if (reset) begin
            E_PC <= 32'd0;
            E_instruction <= 32'd0;
            E_EXT <= 32'd0;
            E_RD1 <= 32'd0;
            E_RD2 <= 32'd0;
            E_allow <= 1'b0;
        end
        else if (enable) begin
            E_PC <= D_PC;
            E_instruction <= D_instruction; 
            E_EXT <= D_EXT;
            E_RD1 <= D_RD1;
            E_RD2 <= D_RD2;
            E_allow <= D_allow;
        end    
    end
endmodule