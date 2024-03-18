module BE(
    input [1:0] op,
    input [1:0] Addr,
    input [31:0] WD,
    output reg [3:0] m_data_byteen,
    output reg [31:0] m_data_wdata
    );
    parameter BE_word = 2'b00;
    parameter BE_byte = 2'b01;
    parameter BE_half = 2'b10;
    parameter BE_none = 2'b11;
    
    wire[7:0]  byte0 = WD[7:0];
    wire[15:0] half0 = WD[15:0];
    wire[31:0] word0 = WD[31:0];
    always @(*) begin
        case (op)
            BE_word:begin
                m_data_byteen = 4'b1111;
                m_data_wdata  = word0;
            end
            BE_byte:begin
                case (Addr)
                    2'b00:begin
                       m_data_byteen = 4'b0001;
                       m_data_wdata  = {24'b0,byte0}; 
                    end 
                    2'b01:begin
                        m_data_byteen = 4'b0010;
                        m_data_wdata  = {16'b0,byte0,8'b0}; 
                    end
                    2'b10:begin
                        m_data_byteen = 4'b0100;
                        m_data_wdata  = {8'b0,byte0,16'b0};
                    end 
                    2'b11:begin
                        m_data_byteen = 4'b1000;
                        m_data_wdata  = {byte0,24'b0};
                    end 
                endcase
            end
            BE_half:begin
                case (Addr[1])
                    1'b0:begin
                        m_data_byteen = 4'b0011;
                        m_data_wdata  = {16'b0,word0};
                    end 
                    1'b1:begin
                        m_data_byteen = 4'b1100;
                        m_data_wdata = {word0,16'b0};
                    end
                endcase
            end
            BE_none:begin
                m_data_byteen = 4'b0000;
                m_data_wdata  = 32'b0;
            end 
        endcase
    end
    
endmodule