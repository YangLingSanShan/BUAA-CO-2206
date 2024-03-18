module D_reg(
    input clk,
    input reset,
    input enable,
    input [31:0] F_PC,
    input [31:0] F_instruction,
    
    output reg [31:0] D_PC,
    output reg [31:0] D_instruction
);

    always @(posedge clk) begin
        if (reset) begin
            D_PC <= 32'd0;
            D_instruction <= 32'd0;
        end
        else if (enable) begin
            D_PC <= F_PC;
            D_instruction <= F_instruction; 
        end    
    end


endmodule