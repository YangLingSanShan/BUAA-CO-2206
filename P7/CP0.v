module CP0(
    input clk,                      //时钟信号。
    input reset,                    //复位信号。

    input [4:0] Addr,           //寄存器地址。
    input [31:0] CP0In,	            //CP0 写入数据。    
    input [31:0] VPC,               //受害 PC。
    input [4:0] ExcCodeIn,          //记录异常类型。
    input BDIn,                     //是否是延迟槽指令。
    input [5:0] HWInt,              //输入中断信号。
    input en,                       //写使能信号。
    input EXLClr,                   //用来复位 EXL。

    output [31:0] EPCOut,           //EPC 的值。
    output [31:0] CP0Out,           //CP0 读出数据。
    output Req,                     //进入处理程序请求。
    output TestIntResponse
);
    reg [31:0] SR;
    reg [31:0] Cause;
    reg [31:0] EPC;

    wire Exception = !SR[1] && (|ExcCodeIn);
    wire Interrupt = SR[0] && !SR[1] && (| (HWInt & SR[15:10]));
    assign Req = Exception | Interrupt;
    wire [31:0] tmp_EPC = (Req) ? (BDIn ? (VPC - 32'd4) : VPC) : EPC;
    assign EPCOut = tmp_EPC;
    assign TestIntResponse = !SR[1] && SR[0] && (HWInt[2] & SR[12]);
    assign CP0Out = (Addr == 12) ? SR :
                    (Addr == 13) ? Cause :
                    (Addr == 14) ? EPCOut : 0;
    always @(posedge clk) begin
        if (reset) begin
            SR <= 0;
			Cause <= 0;
            EPC <= 0;
        end
        else begin
            Cause[15:10] <= HWInt;
            if(EXLClr) 
                SR[1] <= 1'b0;
            if(Req) begin
                    Cause[6:2] <= Interrupt ? 5'd0 : ExcCodeIn;
                    SR[1] <= 1'b1;
                    EPC <= tmp_EPC;
                    Cause[31] <= BDIn;
            end 
            else if(en) begin
                case (Addr)
                    12:SR <= CP0In;
                    14:EPC <= CP0In; 
                endcase                   
            end
        end
    end
    
   
endmodule
/*
SR（State Register）	IM（Interrupt Mask）	15:10	分别对应六个外部中断，相应位置 1 表示允许中断，置 0 表示禁止中断。这是一个被动的功能，只能通过 mtc0 这个指令修改，通过修改这个功能域，我们可以屏蔽一些中断。
SR（State Register）	EXL（Exception Level）	1	    任何异常发生时置位，这会强制进入核心态（也就是进入异常处理程序）并禁止中断。
SR（State Register）	IE（Interrupt Enable）	0	    全局中断使能，该位置 1 表示允许中断，置 0 表示禁止中断。
Cause	                BD（Branch Delay）	    31	    当该位置 1 的时候，EPC 指向当前指令的前一条指令（一定为跳转），否则指向当前指令。
Cause	                IP（Interrupt Pending）	15:10	为 6 位待决的中断位，分别对应 6 个外部中断，相应位置 1 表示有中断，置 0 表示无中断，将会每个周期被修改一次，修改的内容来自计时器和外部中断。
Cause	                ExcCode	                6:2	    异常编码，记录当前发生的是什么异常。
EPC                   	-	                    -   	记录异常处理结束后需要返回的 PC。
*/
// 0 000 0000 0000 0000 0000 00000 01010 00 10  get
// 0 000 0000 0000 0000 0000 00000 01000 00 8   expect