module MD(
	input clk,
	input reset,
	input[31:0] SrcA,
	input[31:0] SrcB,
	input[3:0] MU_op,
	input Start,
	input Req,
	output reg Busy,
	output reg [31:0] HI,
	output reg [31:0] LO
    );
	
	reg [3:0] cnt;
	reg [31:0] hi;
	reg [31:0] lo;
	
	parameter MU_mult = 4'b0000;
	parameter MU_multu= 4'b0001;
	parameter MU_div  = 4'b0010;
	parameter MU_divu = 4'b0011;
	parameter MU_mthi = 4'b0100;
	parameter MU_mtlo = 4'b0101;
	parameter MU_mfhi = 4'b0110;
	parameter MU_mflo = 4'b0111;
	parameter MU_none = 4'b1000;
	
	always @(posedge clk) begin
		if (reset) begin
			cnt <= 4'b0;
			HI  <= 32'b0;
			LO  <= 32'b0;
			Busy<= 1'b0;
		end
		else if (!Req) begin
			if(cnt == 4'b0) begin
				if (Start) begin
					Busy <= 1'b1;
					
					if(MU_op == MU_mult || MU_op == MU_multu) 
						cnt <= 5'd5;
					else if (MU_op == MU_div || MU_op == MU_divu)
						cnt <= 5'd10;
						
					case (MU_op)
						MU_mult:
							{hi,lo} <= $signed(SrcA) * $signed(SrcB);
						MU_multu:
							{hi,lo} <= SrcA * SrcB;
						MU_div: begin
							if(SrcB != 32'b0) begin
								lo <= $signed(SrcA) / $signed(SrcB);
								hi <= $signed(SrcA) % $signed(SrcB);
							end
							else begin
								lo <= lo;
								hi <= hi;
							end
						end
						MU_divu:begin
							if(SrcB != 32'b0) begin
								lo <= SrcA / SrcB;
								hi <= SrcA % SrcB;
							end
							else begin
								lo <= lo;
								hi <= hi;
							end
						end
					endcase
				end
				else begin
					cnt <= 4'b0;
					if (MU_op == MU_mthi)
						HI <= SrcA;
					else if (MU_op == MU_mtlo)
						LO <= SrcA;
				end
			end
			else if (cnt == 4'b1) begin
				LO <= lo;
				HI <= hi;
				Busy <= 1'b0;
				cnt <= cnt - 4'b1;
			end
			else begin
				cnt <= cnt - 4'b1;
				hi <= hi;
				lo <= lo;
				Busy <= 1'b1;
			end
		end
	end

endmodule
