module E_reg(
    input clk,
    input reset,
    input freeze,
    input enable,
    input Req,
    
    input [31:0] D_RD1,
    input [31:0] D_RD2,
    input [31:0] D_instruction,
    input [31:0] D_PC,
    input [31:0] D_EXT,
    input D_BD,
    input [4:0] D_EXCCode,

    output reg [31:0] E_RD1,
    output reg [31:0] E_RD2,
    output reg [31:0] E_instruction,
    output reg [31:0] E_PC,
    output reg [31:0] E_EXT,
    output reg E_BD,
    output reg [4:0] E_temp_EXCCode
);

    always @(posedge clk) begin
        if (reset || freeze || Req) begin
            E_PC <= freeze ? D_PC : (Req ? 32'h0000_4180: 32'd0);
            E_instruction <= 32'd0;
            E_EXT <= 32'd0;
            E_RD1 <= 32'd0;
            E_RD2 <= 32'd0;
            E_BD <= freeze ? D_BD : 0;
            E_temp_EXCCode <= freeze ? D_EXCCode : 0;  
        end
        else if (enable) begin
            E_PC <= D_PC;
            E_instruction <= D_instruction; 
            E_EXT <= D_EXT;
            E_RD1 <= D_RD1;
            E_RD2 <= D_RD2;
            E_BD <= D_BD;
            E_temp_EXCCode <= D_EXCCode;
        end    
    end
endmodule