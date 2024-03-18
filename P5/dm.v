module DM(
   input [31:0] PC,
   input [31:0] Addr,
   input [31:0] WD,
   input clk,
   input reset,
   input MemWrite,
   output [31:0] RD
);
    reg [31:0]RAM [3071 : 0];
    integer i;

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0;i < 3072;i = i + 1) begin
                RAM[i] = 32'b0;
            end
        end
        else if(MemWrite) begin
            RAM[Addr[13:2]] <= WD;
            $display("%d@%h: *%h <= %h", $time, PC, Addr, WD);
        end
    end
    
    assign RD = RAM[Addr[13:2]];
endmodule