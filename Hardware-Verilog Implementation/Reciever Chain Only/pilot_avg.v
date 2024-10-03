module pilot_avg #(

	parameter Q = 16,
	parameter Q_dec = 9

)(

	input clk,
	input rst_n,
	input data_en,
	input signed [Q-1 : 0] pilot_r, pilot_i,

	output reg signed [Q-1 : 0] pilot_avg_r, pilot_avg_i
);

	reg signed [Q-1 + 3 : 0] avg_reg_r, avg_reg_i;
	reg [1 : 0] counter;

	wire [1:0] trial;
	assign trial = counter - 1;

always @(posedge clk or posedge rst_n) begin

	if (rst_n) begin 

		avg_reg_r <= 0;
		avg_reg_i <= 0;
		counter <= 0;

	end

	else if (data_en) begin

		if (counter == 0) begin
			
			avg_reg_r <= pilot_r;
			avg_reg_i <=  pilot_i;
			counter <= counter + 1;

		end
		
		else begin

			avg_reg_r <= avg_reg_r + pilot_r;
			avg_reg_i <= avg_reg_i + pilot_i;
			counter <= counter + 1;

		end

	end
	
end

always @(posedge clk or posedge rst_n) begin

	if (rst_n) begin 

		pilot_avg_r <= 0;
		pilot_avg_i <= 0;

	end

	else if (trial == 3) begin
		
		pilot_avg_r <= avg_reg_r >>> 2; //divide by 4 + quantize
		pilot_avg_i <= -avg_reg_i >>> 2; //divide by 4 + quantize

	end
	
end



endmodule

