module DE(
    input [1:0] Addr,
    input [31:0] m_data_rdata,
    input [2:0] op,
    output reg [31:0] DE_RD
);
    parameter DE_lw  = 3'b000;
    parameter DE_lbu = 3'b001;
    parameter DE_lb  = 3'b010;
    parameter DE_lhu = 3'b011;
    parameter DE_lh  = 3'b100;

    always @(*) begin
        case (op)
            DE_lw:begin
                DE_RD = m_data_rdata[31:0];
            end 
            DE_lbu:begin
                case (Addr)
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
                case (Addr)
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