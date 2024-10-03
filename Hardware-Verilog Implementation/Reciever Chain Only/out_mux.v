module out_mux #(

	parameter Q = 16

)(

	input clk,    
	input reset,
	input sel,

	input [Q-1 : 0] mem1_r, mem2_r, mem1_i, mem2_i,
	output reg [Q-1 : 0] out_r, out_i
	
);

	delay d0(clk, rst_n, sel, sel_delay);

always @(*) begin

	if (!sel_delay) begin

		out_r = mem1_r;
		out_i = mem1_i;
	
	end

	else begin

		out_r = mem2_r;
		out_i = mem2_i;

	end

end

endmodule
