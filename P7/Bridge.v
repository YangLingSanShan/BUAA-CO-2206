module Bridge (
    //来自cpu
    output [31:0] cpu_m_data_rdata,   // cpu DM 读取数据
    input  [31:0] cpu_m_data_addr,    // cpu DM 读写地址
    input  [31:0] cpu_m_data_wdata,   // cpu DM 待写入数据
    input  [3 :0] cpu_m_data_byteen,  // cpu DM 字节使能信号
    //给Time0
    output [31:0] T0_Addr,
    output        T0_WE,
    output [31:0] T0_Din,
    input  [31:0] T0_Dout,
    //给Timer1
    output [31:0] T1_Addr,
    output        T1_WE,
    output [31:0] T1_Din,
    input  [31:0] T1_Dout,
    //给dm
    input  [31:0] m_data_rdata,   // DM 读取数据
    output [31:0] m_data_addr,    // DM 读写地址
    output [31:0] m_data_wdata,   // DM 待写入数据
    output [3 :0] m_data_byteen,  // DM 字节使能信号
    //给Interrupt Generator
    output [31:0] m_int_addr,     // 中断发生器待写入地址
    output [3 :0] m_int_byteen    // 中断发生器字节使能信号
);   
    //处理输入给IO设备的数据
    assign T0_Din = cpu_m_data_wdata;
    assign T1_Din = cpu_m_data_wdata;
    assign m_data_wdata = cpu_m_data_wdata;
    //处理输入给IO设备的地址
    assign T0_Addr = cpu_m_data_addr;
    assign T1_Addr = cpu_m_data_addr;
    assign m_data_addr = cpu_m_data_addr;
    assign m_int_addr = cpu_m_data_addr;
    //处理输入给IO设备的使能信号
    wire WE = |cpu_m_data_byteen;
    assign T0_WE  = (cpu_m_data_addr >= 32'h0000_7f00 && cpu_m_data_addr <= 32'h0000_7f0b) ? WE : 1'd0;   //0x0000_7F00∼0x0000_7F0B
    assign T1_WE  = (cpu_m_data_addr >= 32'h0000_7f10 && cpu_m_data_addr <= 32'h0000_7f1b) ? WE : 1'd0;   //0x0000_7F10∼0x0000_7F1B
    assign m_data_byteen = (cpu_m_data_addr >= 32'h0000_0000 && cpu_m_data_addr <= 32'h0000_2fff) ? cpu_m_data_byteen : 4'b0000;
    assign m_int_byteen = cpu_m_data_byteen;// (cpu_m_data_addr >= 32'h0000_7f20 && cpu_m_data_addr <= 32'h0000_7f23) ? cpu_m_data_byteen : 4'b0000;//0x0000_7F20∼0x0000_7F23
    //处理输入给CPU的数据
    //cpu_m_data_rdata 可能来自 T0_Dout T1_Dout 以及 m_data_rdata
    assign cpu_m_data_rdata = ((m_data_addr >= 32'h0000_0000) && (m_data_addr <= 32'h0000_2fff)) ? m_data_rdata :
                              ((cpu_m_data_addr >= 32'h0000_7f00 && cpu_m_data_addr <= 32'h0000_7f0b)) ? T0_Dout :
                              ((cpu_m_data_addr >= 32'h0000_7f10 && cpu_m_data_addr <= 32'h0000_7f1b)) ? T1_Dout : 32'd0;
endmodule
