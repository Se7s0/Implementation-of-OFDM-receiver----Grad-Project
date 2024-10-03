module delay_n #(

	parameter D = 136 + 16

)(

	input clk,
	input rst_n,
	input d,


	output out_bit
);

	reg [D-1 : 0] out;
	
always @(posedge clk or posedge rst_n) begin

	if (rst_n) out <= 0;
	
	else out <= {out[D-2 : 0], d};
	
end

assign out_bit = out[D-1];

endmodule

