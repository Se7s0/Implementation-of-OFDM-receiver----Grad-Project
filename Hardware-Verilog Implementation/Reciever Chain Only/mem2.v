module mem2 #(
	
	parameter log2N = 6,
	parameter Q = 16,
	parameter N = 64

)( 

	input clk, rst_n,
	input [log2N-1 : 0] addra, addrb,
	input we,

	input [Q-1 : 0] data_r,
	input [Q-1 : 0] data_i,

	output reg [Q-1 : 0] tmp_data_r,
	output reg [Q-1 : 0] tmp_data_i

);

reg [Q-1 : 0] mem_r [N-1 : 0];
reg [Q-1 : 0] mem_i [N-1 : 0];

always @(posedge clk or posedge rst_n) begin

	if (rst_n) begin
		
		tmp_data_r <= 0;
		tmp_data_i <= 0;

	end

	else if(we) begin
		
		mem_r[addra] <= data_r;
		mem_i[addra] <= data_i;
	
	end

	else begin
		
		tmp_data_r <= mem_r[addrb];
		tmp_data_i <= mem_i[addrb];

	end
end

// assign data_r_o = !we ? tmp_data_r : 'hz;
// assign data_i_o = !we ? tmp_data_i : 'hz;

endmodule
