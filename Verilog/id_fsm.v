`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:18:38 08/30/2023 
// Design Name: 
// Module Name:    id_fsm 
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
`define S0 2'b00
`define S1 2'b01
`define S2 2'b10
module id_fsm(
    input [7:0] char,
    input clk,
    output out
    );
reg [1:0] state = `S0;
always @(posedge clk) begin
    case (state)
        `S0:begin
            if((char >= 8'd65 && char <= 8'd90) || (char >= 8'd97 && char <= 8'd122))begin
                state <= `S1;
            end
            else begin
                state <= `S0;
            end
        end 
        `S1:begin
            if((char >= 8'd65 && char <= 8'd90) || (char >= 8'd97 && char <= 8'd122))begin
                state <= `S1;
            end
            else if(char >= 8'd48 && char <= 8'd57) begin
                state <= `S2;
            end
            else begin
                state <= `S0;
            end
        end
        `S2:begin
            if(char >= 8'd48 && char <= 8'd57) begin
                state <= `S2;
            end
            else if ((char >= 8'd65 && char <= 8'd90) || (char >= 8'd97 && char <= 8'd122)) begin
                state <= `S1;
            end
            else begin
                state <= `S0;
            end
        end 
    endcase
end                 
assign out = (state == `S2) ? 1'b1 : 1'b0;
endmodule
