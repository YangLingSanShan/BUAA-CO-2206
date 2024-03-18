module CTRL(
    input [31:0] instruction,
    output reg [2:0] alu_op,    //b,j,r
    output reg [2:0] npc_op,
    
    output reg RegWrite,
    output reg RegDst,
    output reg MemWrite,
    output reg MemtoReg,
    output reg sll_sign,
    output reg AlUsrc,
    output reg link,
    output reg condition_link
);
	//add, sub, ori, lw, sw, beq, lui, jal, jr, nop
    wire [5:0] Opcode = instruction[31:26];
    wire [5:0] func = instruction[5:0];
    parameter R = 6'b000000;
    parameter add_fun = 6'b100000;
    parameter sub_fun = 6'b100010;
    parameter sll_fun = 6'b000000;
    parameter jr_fun  = 6'b001000;

    parameter ori_opc = 6'b001101;
    parameter lw_opc  = 6'b100011;
    parameter sw_opc  = 6'b101011;
    parameter beq_opc = 6'b000100;
    parameter lui_opc = 6'b001111;
    parameter jal_opc = 6'b000011;
    always @(*) begin
        case (Opcode)
            R:begin
                case (func)
                    add_fun:begin
                        alu_op   = 3'b011;
                        npc_op   = 3'b000;
                        RegWrite = 1'b1;
                        RegDst   = 1'b1;
                        MemWrite = 1'b0;
                        MemtoReg = 1'b0;
                        sll_sign = 1'b0;
                        AlUsrc   = 1'b0;
                        link     = 1'b0;
                        condition_link = 1'b0;
                    end 
                    sub_fun:begin
                        alu_op   = 3'b001;
                        npc_op   = 3'b000;
                        RegWrite = 1'b1;
                        RegDst   = 1'b1;
                        MemWrite = 1'b0;
                        MemtoReg = 1'b0;
                        sll_sign = 1'b0;
                        AlUsrc   = 1'b0;
                        link     = 1'b0;
                        condition_link = 1'b0;
                    end 
                    sll_fun:begin
                        alu_op   = 3'b000;
                        npc_op   = 3'b000;
                        RegWrite = 1'b1;
                        RegDst   = 1'b1;
                        MemWrite = 1'b0;
                        MemtoReg = 1'b0;
                        sll_sign = 1'b1;
                        AlUsrc   = 1'b0;
                        link     = 1'b0;
                        condition_link = 1'b0;
                    end
                    jr_fun:begin
                        alu_op   = 3'b111;
                        npc_op   = 3'b100;
                        RegWrite = 1'b0;
                        RegDst   = 1'b0;
                        MemWrite = 1'b0;
                        MemtoReg = 1'b0;
                        sll_sign = 1'b0;
                        AlUsrc   = 1'b0;
                        link     = 1'b0;
                        condition_link = 1'b0;
                    end
                    /* R-type
                    new_opc:begin
                        alu_op   = 3'b101;
                        npc_op   = 3'b000;
                        RegWrite = 1'b1;
                        RegDst   = 1'b1;
                        MemWrite = 1'b0;
                        MemtoReg = 1'b0;
                        sll_sign = 1'b0;
                        AlUsrc   = 1'b0;
                        link     = 1'b0;
                        condition_link = 1'b0;
                    end
                    */
                endcase
            end 
            ori_opc:begin
                alu_op   = 3'b010;
                npc_op   = 3'b000;
                RegWrite = 1'b1;
                RegDst   = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;
                sll_sign = 1'b0;
                AlUsrc   = 1'b1;
                link     = 1'b0;
                condition_link = 1'b0;
            end
            lw_opc:begin
                alu_op   = 3'b011;
                npc_op   = 3'b000;
                RegWrite = 1'b1;
                RegDst   = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b1;
                sll_sign = 1'b0;
                AlUsrc   = 1'b1;
                link     = 1'b0;
                condition_link = 1'b0;
            end
            sw_opc:begin
                alu_op   = 3'b011;
                npc_op   = 3'b000;
                RegWrite = 1'b0;
                RegDst   = 1'b0;
                MemWrite = 1'b1;
                MemtoReg = 1'b0;
                sll_sign = 1'b0;
                AlUsrc   = 1'b1;
                link     = 1'b0;
                condition_link = 1'b0;
            end
            beq_opc:begin
                alu_op   = 3'b111;
                npc_op   = 3'b001;
                RegWrite = 1'b0;
                RegDst   = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;
                sll_sign = 1'b0;
                AlUsrc   = 1'b0;
                link     = 1'b0;
                condition_link = 1'b0;
            end
            lui_opc:begin
                alu_op   = 3'b100;
                npc_op   = 3'b000;
                RegWrite = 1'b1;
                RegDst   = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;
                sll_sign = 1'b0;
                AlUsrc   = 1'b1;
                link     = 1'b0;
                condition_link = 1'b0;
            end
            jal_opc:begin
                alu_op   = 3'b111;
                npc_op   = 3'b010;
                RegWrite = 1'b1;
                RegDst   = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;
                sll_sign = 1'b0;
                AlUsrc   = 1'b0;
                link     = 1'b1;
                condition_link = 1'b0;
            end
            /* I-type
            new_opc:begin
                alu_op   = 3'b101;       //!!!
                npc_op   = 3'b000;
                RegWrite = 1'b1;
                RegDst   = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;
                sll_sign = 1'b0;
                AlUsrc   = 1'b1;
                link     = 1'b0;
                condition_link = 1'b0;
            end
            
            If function(rs,rt) == const, then (branch Imm and link)
            new_opc:begin
                alu_op   = 3'b111;
                npc_op   = 3'b101;      //!!!! according to request
                RegWrite = 1'b1;
                RegDst   = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;
                sll_sign = 1'b0;
                AlUsrc   = 1'b0;
                link     = 1'b0;
                condition_link = 1'b1;
            end

            If function(rs,rt) == const, then branch Imm
            new_opc:begin
                alu_op   = 3'b111;
                npc_op   = 3'b101;      //!!!! according to request
                RegWrite = 1'b0;
                RegDst   = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;
                sll_sign = 1'b0;
                AlUsrc   = 1'b0;
                link     = 1'b0;
                condition_link = 1'b0;
            end
            */
        endcase
    end
    
endmodule