module GRP(
    input [31:0] PC,
    input [31:0] WD,
    input clk,
    input reset,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    output [31:0] RD1,
    output [31:0] RD2
);
	reg [31:0] register [31:0];
    reg [31:0] WData;
    integer i;

    always @(posedge clk) begin
        if(reset) begin
            for(i = 0; i < 32;i = i + 1) 
                register[i] <= 32'b0;
        end 
        else begin
            WData = (A3 == 5'd0) ? 32'd0 : WD;
            register[A3] <= WData;
            $display("%d@%h: $%d <= %h", $time, PC, A3, WData);
        end
    end

    assign RD1 = register[A1];
    assign RD2 = register[A2];

endmodule