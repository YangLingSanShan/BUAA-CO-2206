`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:10:07 08/31/2023 
// Design Name: 
// Module Name:    cpu_checker 
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
`define init_dec_counter 3'd1       //dec_counter initiation
`define init_hex_counter 4'd1       //hex_counter initiation    start from 0
`define max_dec_counter 3'd4        //dec_counter max
`define max_hex_counter 4'd8        //hex_counter max
`define cpu_type 1'b1               //type:cpu                  0
`define reg_type 1'b0               //type:reg                  1
`define S0 4'd0
`define S1 4'd1
`define S2 4'd2
`define S3 4'd3
`define S4 4'd4
`define S5 4'd5
`define S6 4'd6
`define S7 4'd7
`define S8 4'd8
`define S9 4'd9
`define S10 4'd10
`define S11 4'd11                  //different status
`define S12 4'd12
`define S13 4'd13
`define S14 4'd14                  
`define reg_dec_init 16'd0000
`define reg_hex_init 32'h0000_0000
module cpu_checker(
    input clk,
    input reset,
    input [7:0] char,
    input  [15:0] freq,
    output [1:0] format_type,
    output [3:0] error_code
    );
    //<4位十进制数time> 9999->2^14
    //<8位十六进制数pc>
    //<十进制数grf>
    //<8位十六进制数addr>
    reg [3:0] status = `S0;
    reg [3:0] hex_counter = `init_hex_counter;
    reg [2:0] dec_counter = `init_dec_counter;
    reg temp = `reg_type;
    //new code
    reg [15:0] time_ = `reg_dec_init;
    reg [31:0] pc =  `reg_hex_init;
    reg [15:0] grf = `reg_dec_init;
    reg [31:0] addr = `reg_hex_init;
    reg [3:0] state = 4'b0000;

    reg [3:0] time_state = 4'b0000;
    reg [3:0] grf_state = 4'b0000;
    reg [3:0] pc_state = 4'b0000;
    reg [3:0] addr_state = 4'b0000;
    //new code end
    wire dec_digit = (char >= "0" && char <= "9") ? 1'b1 : 1'b0;
    wire hex_digit = (dec_digit == 1'b1) ? 1'b1  : ( (char >= "a" && char <= "f") ? 1'b1 : 1'b0 );
    wire only_dec = (dec_digit == 1'b1) ? ((char >= "a" && char <= "f") ? 1'b0 : 1'b1) : 1'b0;
    wire [15:0] f = (freq >> 1) - 16'd1;
    assign format_type = (status != `S14) ? 2'b00 : ((temp == `reg_type) ? 2'b01 : 2'b10);
    assign error_code = (status != `S14) ? 4'b0000 : (time_state + pc_state + addr_state + grf_state);   
    
   
    always @(posedge clk) begin
        
        
        if (reset == 1'b1) begin    //reset enable
            status <= `S0;
            dec_counter <= `init_dec_counter;
            hex_counter <= `init_hex_counter;
            //new reg
            temp <= `cpu_type;
            time_ <= `reg_dec_init;
            grf <= `reg_dec_init;
            pc <=  `reg_hex_init;
            addr <=  `reg_hex_init;
            state <= 4'b0000;
            
            time_state <= 4'b0000;
            grf_state <= 4'b0000;
            pc_state <= 4'b0000;
            addr_state <= 4'b0000;
        end
        else begin
            case (status)
                `S0:begin
                    
                    time_state <= 4'b0000;
                    grf_state <= 4'b0000;
                    pc_state <= 4'b0000;
                    addr_state <= 4'b0000;

                    if (char == "^") 
                        status <= `S1;
                    else 
                        status <= `S0;
                end
                `S1:begin                                           //read the first time value
					temp  <= `cpu_type;
                    time_ <= `reg_dec_init;                         //??????????????????????
                    grf   <= `reg_dec_init;
                    pc    <= `reg_hex_init;
                    addr  <= `reg_hex_init;
                    state <= 4'b0000;

                    time_state <= 4'b0000;
                    grf_state <= 4'b0000;
                    pc_state <= 4'b0000;
                    addr_state <= 4'b0000;

                    if (dec_digit == 1'b1) begin
                        dec_counter <= `init_dec_counter;
                        time_ <= (char - "0" );            
                        status <= `S2;
                    end
                    else if (char == "^") 
                        status <= `S1;
                    else 
                        status <= `S0;
                end
                `S2:begin
                    if (char == "@") 
                        status <= `S3;
                    else if (dec_digit == 1'b1) begin               //read other time values
                        dec_counter <= dec_counter + 3'b1;
                        time_ <= ((time_+time_+time_+time_+time_)<<1) + (char - "0") ; //time_ mult 10  //time + dec_num(char)
                        if (dec_counter + 3'b1 <= `max_dec_counter) 
                            status <= `S2;
                        else 
                            status <= `S0;
                    end
                    else if (char == "^") 
                        status <= `S1;
                    else
                        status <= `S0;
                end
                `S3:begin
                    if (hex_digit == 1'b1) begin                    //read the first pc value
                        hex_counter <= `init_hex_counter;
                        if(only_dec == 1'b1)
                            pc <= pc + (char - "0");                 //only digit
                        else
                            pc <= pc + (char - "a" + 8'd10);         //alpha
                        status <= `S4;
                    end
                    else if (char == "^") 
                        status <= `S1;
                    else
                        status <= `S0;
                end
                `S4:begin
                    if (char == ":") begin
                        if (hex_counter == `max_hex_counter) 
                            status <= `S5;
                        else 
                            status <= `S0;
                        end
                    else if (hex_digit == 1'b1) begin               // read other pc values
                        hex_counter <= hex_counter + 4'b1;
                                                                     //pc 16
                        if(only_dec == 1'b1)
                            pc <= (pc<<4) + (char - "0");                 //only digit
                        else
                            pc <= (pc<<4) + (char - "a" + 8'd10);         //alpha

                        if (hex_counter + 4'b1 <= `max_hex_counter) 
                            status <= `S4;
                        else 
                            status <= `S0;
                    end
                    else if (char == "^") 
                        status <= `S1;
                    else
                        status <= `S0;
                end
                `S5:begin
                    case (char)
                        "$":status <= `S6;                         //reg
                        " ":status <= `S5;                         //reg
                        8'd42:status <= `S7;                      
                        "^":status <= `S1; 
                        default: status <= `S0;
                    endcase
                end
                `S6:begin                                           //reg $grf
                    temp <= `reg_type;
                    if (dec_digit == 1'b1) begin
                        dec_counter <= `init_dec_counter;           //read the first grf value
                        grf = grf + (char - "0"); 
                        status <= `S8;
                    end
                    else if (char == "^") 
                        status <= `S1;
                    else
                        status <= `S0;
                end
                `S7:begin
                    temp <= `cpu_type;
                    if (hex_digit == 1'b1) begin
                        hex_counter <= `init_hex_counter;           //read the first addr value 注意跳模�

                    if(only_dec == 1'b1)
                        addr <= addr + (char - "0");                 //only digit
                    else
                        addr <= addr + (char - "a" + 8'd10);    

                        status <= `S9;
                    end
                    else if (char == "^") 
                        status <= `S1;
                    else
                        status <= `S0;
                end
                `S8:begin
                    if (char == " ") 
                        status <= `S10;
                    else if (char == "<") 
                        status <= `S11;
                    else if (dec_digit == 1'b1) begin
                        dec_counter <= dec_counter + 3'b1;          //read other grf values

                        grf <= ((grf+grf+grf+grf+grf)<<1)+(char - "0");                   //time + dec_num(char)

                        if (dec_counter + 3'b1 <= `max_dec_counter) 
                            status <= `S8;
                        else 
                            status <= `S0;
                    end
                    else if (char == "^") 
                        status <= `S1;
                    else
                        status <= `S0;
                end
                `S9:begin
                    if (char == " ") begin
                        if (hex_counter == `max_hex_counter)begin
                            status <= `S10;
                        end
                        else 
                            status <= `S0;
                    end
                    else if (char == "<") begin
                        if (hex_counter == `max_hex_counter) 
                            status <= `S11;
                        
                        else 
                            status <= `S0;
                    end
                    else if (hex_digit == 1'b1) begin
                        hex_counter <= hex_counter + 4'b1;              //read other addr values

                                                 //mult 16
                        if(only_dec == 1'b1)
                            addr <= (addr<< 4) + (char - "0");                 //only digit
                        else
                            addr <= (addr<<4) + (char - "a" + 8'd10);    

                        if (hex_counter+ 4'b1 <= `max_hex_counter) 
                            status <= `S9;
                        else 
                            status <= `S0;
                    end
                    else if (char == "^") 
                        status <= `S1;
                    else
                        status <= `S0;
                end    
                `S10:begin
                    case (char)
                        "<":status <= `S11;
                        " ":status <= `S10;
                        "^":status <= `S1; 
                        default:status <= `S0; 
                    endcase
                end
                `S11:begin
                    case (char)
                        "=":status <=`S12;
                        "^":status <= `S1; 
                        default:status <= `S0; 
                    endcase
                end
                `S12:begin
                    if (hex_digit == 1'b1) begin
                        hex_counter <= `init_hex_counter;
                        status <= `S13;
                    end
                    else if (char == " ") 
                        status <= `S12;
                    else if (char == "^") 
                        status <= `S1;
                    else
                        status <= `S0;
                end
                `S13:begin
                        if (char == "#") begin
                            if (hex_counter == `max_hex_counter) begin
                                
                                if((time_ & f ) == 0)
                                time_state <= time_state;
                            else
                                time_state <= time_state + 4'b0001;
                            
                            if((32'h3000 <= pc && pc <= 32'h4fff) && ((pc & 3) == 32'd0))
                                pc_state <= pc_state;
                            else
                                pc_state <= pc_state + 4'b0010;

                            if(temp == `cpu_type) begin             //addr
                                if(((32'h0000 <= addr) && (addr <= 32'h2fff)) && ((addr & 3) == 32'd0)) begin
                                    addr_state <= addr_state; 
                                end
                                else begin                                
                                    addr_state <= addr_state + 4'b0100;
                                end
                            end
                            else begin                              //grf
                                if(grf>=8'd0 && grf <= 8'd31) begin
                                    grf_state <= grf_state;
                                    
                                end
                                else begin
                                   
                                    grf_state <= grf_state + 4'b1000;
                                end
                            end
                            
                            status <= `S14;
                        end
                        else 
                            status <= `S0;
                    end
                    else if (hex_digit == 1'b1) begin
                        hex_counter <= hex_counter + 4'b1;
                        if (hex_counter + 4'b1 <= `max_hex_counter) 
                            status <= `S13;
                        else 
                            status <= `S0;
                    end
                    else if (char == "^") 
                        status <= `S1;
                    else
                        status <= `S0;
                end
                `S14:begin
                        
                       
                        

                        if (char == "^") 
                            status <= `S1;
                        else
                            status <= `S0;
                        
                        
                end
                default: status <= `S0;
            endcase
        end
    end
                   
endmodule
