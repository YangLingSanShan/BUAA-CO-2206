
module mips(
    input clk,
    input reset
);
	wire [31:0] instruction;
    wire [31:0] pc;
    wire [2:0] alu_op;    //b,j,r
    wire [2:0] npc_op;  
    wire RegWrite;
    wire RegDst;
    wire MemWrite;
    wire MemtoReg;
    wire sll_sign;
    wire AlUsrc;
    wire link;
    wire equal;
    wire [4:0] rs = instruction[25:21];
    wire [4:0] rt = instruction[20:16];
    wire [4:0] rd = instruction[15:11];
    wire [15:0] Imm16 = instruction[15:0];
    wire [25:0] Imm26 = instruction[25:0];
    wire [4:0] sllBits = instruction[10:6];
    wire [31:0] ALUresult;
    wire [31:0] rd1;
    wire [31:0] rd2;
    wire [31:0] romData;

    CTRL _ctrl(
        .instruction(instruction),
        .alu_op(alu_op),
        .npc_op(npc_op),
        .RegWrite(RegWrite),
        .RegDst(RegDst),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .sll_sign(sll_sign),
        .AlUsrc(AlUsrc),
        .link(link)
    );
  
    NPC _npc(
        .clk(clk),
        .reset(reset),
        .op(npc_op == 3'b001 ? (equal ? npc_op : 3'b000) : npc_op),
        .b_imm(Imm16),
        .j_imm(Imm26),
        .rs(rd1),
        .PC(pc)
    );

    IM _im(
        .PC(pc),
        .instruction(instruction)
    );

    GRF _grf(
        .PC(pc),
        .WD(link ? (pc + 32'd4) : (MemtoReg ? romData : ALUresult)),
        .reset(reset),
        .clk(clk),
        .A1(rs),
        .A2(rt),
        .A3(link ? 5'd31 : (RegDst ? rd : rt)),
        .RegWrite(RegWrite),
        .RD1(rd1),
        .RD2(rd2)
    );

    DM _dm(
        .PC(pc),
        .Addr(ALUresult),
        .WD(rd2),
        .clk(clk),
        .reset(reset),
        .MemWrite(MemWrite),
        .RD(romData)
    );

    ALU _alu(
        .SrcA(rd1),
        .SrcB(AlUsrc ? {{16{Imm16[15]}},Imm16} : (sll_sign ? {{27{sllBits[4]}},sllBits} : rd2)),
        .op(alu_op),    
        .ALUresult(ALUresult),
        .equal(equal)
    );
endmodule