module delay #(

	parameter D = 1

)(

	input clk,
	input rst,
	input d,

	output reg out
);
	
always @(posedge clk or posedge rst) begin

	if (rst) out <= 0;
	
	else out <= d;
	
end


endmodule
