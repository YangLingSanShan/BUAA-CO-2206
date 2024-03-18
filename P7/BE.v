module BE(
    input [1:0] op,
    input [31:0] Addr,
    input [31:0] WD,
    input Overflow,
    input store,
    input [4:0] EXCCode,
    output M_EXC_AdES,
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
    wire NotAlignWord = ((op == BE_word) && (|Addr[1:0]));//sw存数地址未 4 字节对齐。
    wire NotAlignHalf = ((op == BE_half) && (Addr[0]));   //sw存数地址未 2 字节对齐。
    wire OutRange = !(((Addr >= 32'h0000_0000) && (Addr <= 32'h0000_2fff)) ||
                      ((Addr >= 32'h0000_7f00) && (Addr <= 32'h0000_7f0b)) ||
                      ((Addr >= 32'h0000_7f10) && (Addr <= 32'h0000_7f1b)) ||
                      ((Addr >= 32'h0000_7f20) && (Addr <= 32'h0000_7f23)));
    wire ErrorTimer = (Addr >= 32'h0000_7f08 && Addr <= 32'h0000_7f0b) ||
                      (Addr >= 32'h0000_7f18 && Addr <= 32'h0000_7f1b) ||
                      (op != BE_word && Addr >= 32'h0000_7f00);
    assign M_EXC_AdES = (store && (NotAlignWord || NotAlignHalf || ErrorTimer || OutRange || Overflow));

    always @(*) begin
        if(!(M_EXC_AdES || |EXCCode)) begin
            case (op)
                BE_word:begin
                    m_data_byteen = 4'b1111;
                    m_data_wdata  = word0;
                end
                BE_byte:begin
                    case (Addr[1:0])
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
        else begin
            m_data_byteen = 4'b0000;
            m_data_wdata  = 32'b0;
        end
    end

endmodule