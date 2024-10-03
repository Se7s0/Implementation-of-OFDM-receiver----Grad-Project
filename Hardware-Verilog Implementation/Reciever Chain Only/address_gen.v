module address_gen (

	input clk,    
	input rst_n,
	input en,

	output mem1_we,
	output mem2_we,
	output [5:0] addr,
	output reg [5:0] counter
	
);

	reg mem2we, mem1we;
	wire start;

	delay del0 (clk, rst_n, start, start_del);
	delay_n #(.D(80))  u0(clk, rst_n, en, en_d);
	delay_n #(.D(64))  u1(clk, rst_n, start, start_dd);

	assign diff = (start && !start_dd)	?	1'b1 : 1'b0; 


	assign start = rst_n? 1'b0 : en?	1'b1 : ((counter == 6'h3f) && !en)?	1'b0 : start;
	assign mem2_we = mem2we && start;
	assign mem1_we = mem1we && start;

	always @(posedge clk or posedge rst_n) begin
		
		if (rst_n) begin
			
			counter <= 0;

		end

		else if (start && (en || en_d)) begin
			
			counter <= counter + 1;

		end

		else if (counter == 6'h3f || en == 0)  counter <= 0;


	end

	always @(posedge clk or posedge rst_n) begin
		
		if (rst_n) begin

			mem2we <= 0;
			mem1we <= 1;
		
		end

		else if (start_del && (counter==6'h3f)) begin
			
			mem1we <= !mem1we;
			mem2we <= !mem2we;

		end

	end

	assign addr = {counter[0], counter[1], counter[2], counter[3], counter[4], counter[5]};

endmodule
