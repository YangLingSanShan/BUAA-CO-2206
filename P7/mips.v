//最顶层模块
`include "mips_CPU.v"
`include "Bridge.v"
`include "Timer.v"
module mips(
    input clk,                    // 时钟信号
    input reset,                  // 同步复位信号
    input interrupt,              // 外部中断信号
    output [31:0] macroscopic_pc, // 宏观 PC

    output [31:0] i_inst_addr,    // IM 读取地址（取指 PC）
    input  [31:0] i_inst_rdata,   // IM 读取数据

    output [31:0] m_data_addr,    // DM 读写地址
    input  [31:0] m_data_rdata,   // DM 读取数据
    output [31:0] m_data_wdata,   // DM 待写入数据
    output [3 :0] m_data_byteen,  // DM 字节使能信号

    output [31:0] m_int_addr,     // 中断发生器待写入地址
    output [3 :0] m_int_byteen,   // 中断发生器字节使能信号

    output [31:0] m_inst_addr,    // M 级 PC

    output w_grf_we,              // GRF 写使能信号
    output [4 :0] w_grf_addr,     // GRF 待写入寄存器编号
    output [31:0] w_grf_wdata,    // GRF 待写入数据

    output [31:0] w_inst_addr     // W 级 PC
);
    wire [31:0] temp_toBridge_m_data_addr;
    wire [3:0] temp_toBridge_m_data_byteen;
    wire [31:0] toBridge_m_data_addr;
    wire [31:0] toBridge_m_data_wdata;
    wire [3:0] toBridge_m_data_byteen;
    wire [31:0] tocpu_m_data_rdata;
    wire TestIntResponse;
    wire T0_IRQ,T1_IRQ;
    mips_CPU _CPU(
        .clk(clk),
        .reset(reset),

        .HWInt({3'b000,interrupt,T1_IRQ,T0_IRQ}),

        .i_inst_addr(i_inst_addr),
        .i_inst_rdata(i_inst_rdata),

        .m_data_addr(temp_toBridge_m_data_addr),
        .m_data_wdata(toBridge_m_data_wdata),
        .m_data_byteen(temp_toBridge_m_data_byteen),
        .m_data_rdata(tocpu_m_data_rdata),

        .m_inst_addr(m_inst_addr),

        .w_grf_we(w_grf_we),
        .w_grf_addr(w_grf_addr),
        .w_grf_wdata(w_grf_wdata),

        .w_inst_addr(w_inst_addr),

        .macroscopic_pc(macroscopic_pc),
        .TestIntResponse(TestIntResponse)
    );
    assign toBridge_m_data_addr  = (TestIntResponse && interrupt) ? 32'h0000_7f20 : temp_toBridge_m_data_addr;
    assign toBridge_m_data_byteen= (TestIntResponse && interrupt) ? 4'b1111 : temp_toBridge_m_data_byteen; //?
    wire [31:0] T0_Addr,T0_Din,T0_Dout,T1_Addr,T1_Din,T1_Dout;
    wire T0_WE,T1_WE;
    Bridge bridge(
    //来自cpu
    .cpu_m_data_rdata(tocpu_m_data_rdata),   // cpu DM 读取数据
    .cpu_m_data_addr(toBridge_m_data_addr),    // cpu DM 读写地址
    .cpu_m_data_wdata(toBridge_m_data_wdata),   // cpu DM 待写入数据
    .cpu_m_data_byteen(toBridge_m_data_byteen),  // cpu DM 字节使能信号
    //给Time0
    .T0_Addr(T0_Addr),
    .T0_WE(T0_WE),
    .T0_Din(T0_Din),
    .T0_Dout(T0_Dout),
    //给Timer1
    .T1_Addr(T1_Addr),
    .T1_WE(T1_WE),
    .T1_Din(T1_Din),
    .T1_Dout(T1_Dout),
    //给dm
    .m_data_rdata(m_data_rdata),   // DM 读取数据
    .m_data_addr(m_data_addr),    // DM 读写地址
    .m_data_wdata(m_data_wdata),   // DM 待写入数据
    .m_data_byteen(m_data_byteen),  // DM 字节使能信号
    //给Interrupt Generator
    .m_int_addr(m_int_addr),     // 中断发生器待写入地址
    .m_int_byteen(m_int_byteen)    // 中断发生器字节使能信号
);   
    TC Timer0(
    .clk(clk),
    .reset(reset),
    .Addr(T0_Addr[31:2]),
    .WE(T0_WE),
    .Din(T0_Din),
    .Dout(T0_Dout),
    .IRQ(T0_IRQ)
);
    TC Timer1(
    .clk(clk),
    .reset(reset),
    .Addr(T1_Addr[31:2]),
    .WE(T1_WE),
    .Din(T1_Din),
    .Dout(T1_Dout),
    .IRQ(T1_IRQ)
);
endmodule