//~ `New testbench
`include "mips.v"
`timescale  1ns / 1ps

module tb_mips;

// mips Parameters
parameter PERIOD  = 10;


// mips Inputs
reg   clk                                  = 0 ;
reg   reset                                = 0 ;

// mips Outputs


mips  u_mips (
    .clk                     ( clk     ),
    .reset                   ( reset   )
);

initial
begin
    $dumpfile("mips_tb.vcd");
    $dumpvars;
    clk = 1;
    reset = 1;
    #2;
    reset = 0;  
    #200;
    $finish;
end

always #1 clk = ~clk;

endmodule