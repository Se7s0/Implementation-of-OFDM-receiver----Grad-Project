module ROM_ref #(
	
	parameter log2N = 6,
	parameter Q = 1,
	parameter N = 48

)( 

	input clk, rst_n,
	input [log2N-1 : 0] addr,
	input we,

	output [Q-1 : 0] data_r

);

reg [Q-1 : 0] tmp_data_r;
reg [Q-1 : 0] mem_r [N-1 : 0];

always @(posedge clk or posedge rst_n) begin

	if (rst_n) begin
		
		mem_r[ 0] <= 1'b1;
		mem_r[ 1] <= 1'b0;
		mem_r[ 2] <= 1'b0;
		mem_r[ 3] <= 1'b1;
		mem_r[ 4] <= 1'b1;
		mem_r[ 5] <= 1'b0;
		mem_r[ 6] <= 1'b0;
		mem_r[ 7] <= 1'b1;
		mem_r[ 8] <= 1'b0;
		mem_r[ 9] <= 1'b0;
		mem_r[10] <= 1'b0;
		mem_r[11] <= 1'b0;
		mem_r[12] <= 1'b0;
		mem_r[13] <= 1'b1;
		mem_r[14] <= 1'b1;
		mem_r[15] <= 1'b0;
		mem_r[16] <= 1'b0;
		mem_r[17] <= 1'b1;
		mem_r[18] <= 1'b0;
		mem_r[19] <= 1'b0;
		mem_r[20] <= 1'b1;
		mem_r[21] <= 1'b1;
		mem_r[22] <= 1'b1;
		mem_r[23] <= 1'b1;
		mem_r[24] <= 1'b1;
		mem_r[25] <= 1'b1;
		mem_r[26] <= 1'b0;
		mem_r[27] <= 1'b0;
		mem_r[28] <= 1'b1;
		mem_r[29] <= 1'b0;
		mem_r[30] <= 1'b1;
		mem_r[31] <= 1'b0;
		mem_r[32] <= 1'b1;
		mem_r[33] <= 1'b1;
		mem_r[34] <= 1'b1;
		mem_r[35] <= 1'b1;
		mem_r[36] <= 1'b1;
		mem_r[37] <= 1'b1;
		mem_r[38] <= 1'b0;
		mem_r[39] <= 1'b0;
		mem_r[40] <= 1'b1;
		mem_r[41] <= 1'b1;
		mem_r[42] <= 1'b1;
		mem_r[43] <= 1'b0;
		mem_r[44] <= 1'b1;
		mem_r[45] <= 1'b1;
		mem_r[46] <= 1'b1;
		mem_r[47] <= 1'b1;


		tmp_data_r <= 0;

	end

	else if(we) begin
		
		mem_r[addr] <= data_r;
	
	end

	else begin
		
		tmp_data_r <= mem_r[addr];

	end
end

assign data_r = !we ? tmp_data_r : 'hz;

endmodule
