module NPC(
    input [31:0] D_pc,
    input [31:0] F_pc,
    input [2:0] op,
    input [15:0] Imm16,
    input [25:0] Imm26,
    input [31:0] rs,
    input jump_allow,

    output reg [31:0] PC
);

    parameter b = 3'b001;
    parameter j = 3'b010;
    parameter r = 3'b100;
    parameter c = 3'b011;
    always @(*) begin
        case (op)
            b: begin
                if(jump_allow)
                    PC = D_pc + 32'd4 + {{14{Imm16[15]}}, Imm16, 2'b00};
                else 
                    PC = F_pc + 32'd4;
            end
            j:
                PC = {D_pc[31:28], Imm26, 2'b00};
            r:
                PC = rs;
            c: begin
                if(jump_allow)
                    PC = D_pc + 32'd4 + {{14{Imm16[15]}}, Imm16, 2'b00};        //According to request
                else 
                    PC = F_pc + 32'd4;
            end
            default:
                PC = F_pc + 32'd4;
        endcase
    end
endmodule