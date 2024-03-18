module IM(
    input clk,
    input reset,
    input enable,
    input [31:0] NPC,
    output reg [31:0] PC
);
    
    always @(posedge clk) begin
        if(reset) begin
            PC <= 32'h0000_3000;
        end 
        else if(enable) begin
            PC <= NPC;
        end
    end

endmodule