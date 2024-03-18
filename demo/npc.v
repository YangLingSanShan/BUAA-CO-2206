module NPC(
    input clk,
    input reset,
    input [2:0] op,
    input [15:0] b_imm,
    input [25:0] j_imm,
    input [31:0] rs,
    output [31:0] PC
);
	reg [31:0] pc_value;

    parameter b = 3'b001;
    parameter j = 3'b010;
    parameter r = 3'b100;

    assign PC = pc_value;
    always @(posedge clk) begin
        if (reset) begin
            pc_value <= 32'h00003000;
        end
        else begin
            case (op)
                b:
                    pc_value <= {{14{b_imm[15]}}, b_imm, 2'b00} + pc_value + 32'd4;// 11111111111111111111111111111100 
                j:
                    pc_value <= {pc_value[31:28],j_imm,2'b00};
                r:
                    pc_value <= rs;
                default:
                    pc_value <= pc_value + 32'd4;
            endcase
        end
    end
endmodule