module pilot_null_detector #(

	parameter radix = 4,
	parameter N = 64,     			//number of inputs
	parameter stage = 0,        	//stage number
	parameter log2N = 6,

	parameter Q_int = 6, //s+5	  			//input size
	parameter Q_dec = 7,				//decimal binary size
	parameter Q = 16,
	parameter W = Q				//twiddle size

)(

	input clk, rst_n,
	input lts_in, data_valid,

	input signed [Q-1 : 0] out_r, out_i,

	output reg data_en, w_en,
	output wire data_en_p_d,
	output reg [log2N-1 : 0] addr,

	output reg signed [Q-1 : 0] plts_r, plts_i, pdata_r, pdata_i


);

	reg [log2N-1 : 0] counter;

	reg signed [Q-1 : 0] pilots_lts_r [3 : 0];
	reg signed [Q-1 : 0] pilots_lts_i [3 : 0];

	reg [1:0] lts_counter, mux_sel_p; // mux select counter

	reg w_en_p, data_en_p;

	wire [1:0] trial;

	assign trial = mux_sel_p - 1;
	
	delay_n #(.D(81)) d_64(clk, rst_n, data_valid, data_valid_d);
	delay_n #(.D(2)) d_2(clk, rst_n, data_en_p, data_en_p_d);

	always @(posedge clk or posedge rst_n) begin
		
		if(rst_n) begin
			
			data_en <= 0;
			counter <= 0;
			w_en <= 0;
		
		end 

		else if(data_valid_d) begin
		
			if (!((counter > 25) && (counter < 37))) begin //if it is not null
			 	
			 	if (counter != 63 && counter != 6 && counter != 20 && counter != 42 && counter != 56) begin //negation (-1) done in both if conditions //if it is not pilot

			 		if (lts_in) w_en <= 1;
			 		
			 		else data_en <= 1;

			 	end

			 	else begin 

			 		data_en <= 0;
			 		w_en <= 0;

			 	end

			 end

		 	else begin 

		 		data_en <= 0;
		 		w_en <= 0;

		 	end

			counter <= counter + 1; 
		
		end

		else if (counter == 6'h00) begin
			
	 		data_en <= 0;
	 		w_en <= 0;

		end

	end

	always @(posedge clk or posedge rst_n) begin
		
		if (rst_n) addr <= 0;

		else if (w_en || data_en) begin
			
			if (addr == 48 - 1)  addr <= 0;

			else addr <= addr + 1;

		end

	end

	always @(posedge clk or posedge rst_n) begin
		
		if(rst_n) begin
			
			data_en_p <= 0;
			w_en_p <= 0;
		
		end 

		else if(data_valid_d) begin
		
			if (!((counter > 25) && (counter < 37))) begin //if it is not null
			 	
			 	if (counter == 6 || counter == 20 || counter == 42 || counter == 56) begin //negation (-1) done in both if conditions //if it is not pilot

			 		if (lts_in) w_en_p <= 1;
			 		
			 		else data_en_p <= 1;

			 	end

			 	else begin 

			 		data_en_p <= 0;
			 		w_en_p <= 0;

			 	end

			end

		 	else begin 

		 		data_en_p <= 0;
		 		w_en_p <= 0;

		 	end
		
		end

		else if (counter == 6'h00) begin
			
	 		data_en_p <= 0;
	 		w_en_p <= 0;

		end

	end

	always @(posedge clk or posedge rst_n) begin
		
		if (rst_n) begin
			
			lts_counter <= 0;

			pilots_lts_r[0] <= 0;
			pilots_lts_r[1] <= 0;
			pilots_lts_r[2] <= 0;
			pilots_lts_r[3] <= 0;			

			pilots_lts_i[0] <= 0;
			pilots_lts_i[1] <= 0;
			pilots_lts_i[2] <= 0;
			pilots_lts_i[3] <= 0;

		end

		else if (w_en_p) begin
			
			pilots_lts_r[lts_counter] <= out_r;
			pilots_lts_i[lts_counter] <= out_i;

			lts_counter <= lts_counter + 1;

		end

	end

	always @(posedge clk or posedge rst_n) begin
		
		if (rst_n) begin
			
			plts_r <= 0;
			plts_i <= 0;

		end

		else case (trial)

		0: begin

			plts_i <= -pilots_lts_i[0];
			plts_r <= -pilots_lts_r[0];

		end

		1: begin

			plts_i <= pilots_lts_i[1];
			plts_r <= pilots_lts_r[1];

		end
		
		2: begin

			plts_i <= -pilots_lts_i[2];
			plts_r <= -pilots_lts_r[2];

		end
		
		3: begin

			plts_i <= -pilots_lts_i[3];
			plts_r <= -pilots_lts_r[3];

		end

		endcase

	end

	always @(posedge clk or posedge rst_n) begin
		
		if (rst_n) begin
			
			pdata_r <= 0;
			pdata_i <= 0;
			mux_sel_p <= 0;

		end

		else if (data_en_p) begin
			
			mux_sel_p <= mux_sel_p + 1;
			
			pdata_i <= out_i;
			pdata_r <= out_r;

		end

	end




endmodule
