module delay_w #(

	parameter D = 16

)(

	input clk,
	input rst,
	input [D-1 : 0] d,

	output reg [D-1 : 0] out
);
	
always @(posedge clk or posedge rst) begin

	if (rst) out <= 0;
	
	else out <= d;
	
end

endmodule
