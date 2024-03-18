module D_reg(
    input clk,
    input reset,
    input enable,
    input [31:0] F_PC,
    input [31:0] F_instruction,
    input F_BD,
    input [4:0] F_EXCCode,
    input Req,
    
    output reg [31:0] D_PC,
    output reg [31:0] D_instruction,
    output reg D_BD,
    output reg [4:0] D_temp_EXCCode
);

    always @(posedge clk) begin
        if (reset || Req) begin
            D_PC <= (Req) ? 32'h0000_4180 : 32'd0;
            D_instruction <= 32'd0;
            D_BD <= 1'd0;
            D_temp_EXCCode <= 4'b0;
        end
        else if (enable) begin
            D_PC <= F_PC;
            D_instruction <= F_instruction; 
            D_BD <= F_BD;
            D_temp_EXCCode <= F_EXCCode;
        end    
    end


endmodule