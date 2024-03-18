module DE(
    input [31:0] Addr,
    input [31:0] m_data_rdata,
    input [2:0] op,
    input Overflow,
    input load,
    output M_EXC_AdEL,
    output reg [31:0] DE_RD
);
    parameter DE_lw  = 3'b000;
    parameter DE_lbu = 3'b001;
    parameter DE_lb  = 3'b010;
    parameter DE_lhu = 3'b011;
    parameter DE_lh  = 3'b100;

    wire NotAlignWord = ((op == DE_lw) && (|Addr[1:0]));//lw取数地址未 4 字节对齐。
    wire NotAlignHalf = ((op == DE_lhu || op == DE_lh ) && (Addr[0]));   //lh 地址未 2 字节对齐。
    wire OutRange = !(((Addr >= 32'h0000_0000) && (Addr <= 32'h0000_2fff)) ||
                      ((Addr >= 32'h0000_7f00) && (Addr <= 32'h0000_7f0b)) ||
                      ((Addr >= 32'h0000_7f10) && (Addr <= 32'h0000_7f1b)) ||
                      ((Addr >= 32'h0000_7f20) && (Addr <= 32'h0000_7f23)));
    wire ErrorTimer = (op != DE_lw && Addr >= 32'h0000_7f00);
    assign M_EXC_AdEL = (load && (NotAlignWord || NotAlignHalf || ErrorTimer || OutRange || Overflow));

    always @(*) begin
        case (op)
            DE_lw:begin
                DE_RD = m_data_rdata[31:0];
            end 
            DE_lbu:begin
                case (Addr[1:0])
                    2'b00:begin
                        DE_RD = {24'b0,m_data_rdata[7:0]};
                    end
                    2'b01:begin
                        DE_RD = {24'b0,m_data_rdata[15:8]};
                    end
                    2'b10:begin
                        DE_RD = {24'b0,m_data_rdata[23:16]};
                    end
                    2'b11:begin
                        DE_RD = {24'b0,m_data_rdata[31:24]};
                    end 
                endcase
            end
            DE_lb:begin
                case (Addr[1:0])
                    2'b00:begin
                        DE_RD = {{24{m_data_rdata[7]}},m_data_rdata[7:0]};
                    end
                    2'b01:begin
                        DE_RD = {{24{m_data_rdata[15]}},m_data_rdata[15:8]};
                    end
                    2'b10:begin
                        DE_RD = {{24{m_data_rdata[23]}},m_data_rdata[23:16]};
                    end
                    2'b11:begin
                        DE_RD = {{24{m_data_rdata[31]}},m_data_rdata[31:24]};
                    end 
                endcase
            end
            DE_lhu:begin
                case (Addr[1])
                    1'b0:begin
                        DE_RD = {16'b0,m_data_rdata[15:0]};
                    end
                    1'b1:begin
                        DE_RD = {16'b0,m_data_rdata[31:16]};
                    end
                endcase
            end
            DE_lh:begin
                case (Addr[1])
                    1'b0:begin
                        DE_RD = {{16{m_data_rdata[15]}},m_data_rdata[15:0]};
                    end
                    1'b1:begin
                        DE_RD = {{16{m_data_rdata[31]}},m_data_rdata[31:16]};
                    end
                endcase
            end 
        endcase
    end
endmodule