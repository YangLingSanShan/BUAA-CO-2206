module IM(
   input [31:0] PC,
   output [31:0] instruction
);
    reg [31:0] ROM[0:4095];

    initial begin
        $readmemh("code.txt", ROM);
    end
    wire [11:0] addr = PC[13:2] - 12'b1100_0000_0000;         //32'h00003000;
    reg [31:0] rst;
	always @(*) begin
        rst = ROM[addr];
    end
    assign instruction = rst;
endmodule