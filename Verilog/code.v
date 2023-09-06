`timescale 1ns / 1ps
`define one 1'b1
`define zero 1'b0
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:27:38 08/30/2023 
// Design Name: 
// Module Name:    code 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module code(
    input Clk,
    input Reset,
    input Slt,
    input En,
    output reg [63:0] Output0,
    output reg [63:0] Output1
    );
    reg [1:0] count4 = 2'b01;

always @(posedge Clk) begin
    if(Reset == 1'b1)begin      //reset == 1
        Output0 <= 64'd0;
        Output1 <= 64'd0;
    end
    else begin                  //reset == 0
        if(En == 1'b1)begin     //en == 1
            case (Slt)
                `zero:begin      //Slt == 0
                    Output0 <= Output0 + 64'd1;
                    Output1 <= Output1;
                end 
                `one:begin       //Slt == 1
                    count4 <= count4 + 2'b01;
                    if(count4 == 2'b00) begin
                        Output0 <= Output0;
                        Output1 <= Output1 + 64'd1;
                    end
                    else begin
                        Output0 <= Output0;
                        Output1 <= Output1;
                    end
                end 
            endcase
        end
        else begin              //en == 0   ->stay
            Output0 <= Output0;
            Output1 <= Output1;
        end
    end
end
endmodule
