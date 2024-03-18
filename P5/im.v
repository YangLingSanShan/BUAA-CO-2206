module IM(
    input clk,
    input reset,
    input enable,
    input [31:0] NPC,
    output [31:0] instruction,
    output reg [31:0] PC
);
    integer i;
    reg[31:0] ROM[0:4095];
    reg[31:0] npc;
    
    initial begin
        $readmemh("code.txt", ROM);
    end
    always @(posedge clk) begin
        if(reset) begin
            PC <= 32'h0000_3000;
        end 
        else if(enable) begin
            PC <= NPC;
        end
        else
            PC <= PC;
    end

    assign instruction = ROM[(PC[31:0] - 32'h0000_3000) >> 2];

endmodule