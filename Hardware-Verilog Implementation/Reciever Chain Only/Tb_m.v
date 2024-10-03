module Tb_m;

	reg 		clock;
	reg 		reset;
	reg 		di_en;
	reg [15:0]	di_re;
	reg [15:0]	di_im;
	reg 		lts_in;


	wire[15:0]	out_r_eq;
	wire[15:0]	out_i_eq;
	wire 		data_en_dd, lts_in_d;

	reg [15:0]	mem_r[80*5-1:0];
	reg [15:0]	mem_i[80*5-1:0];

	reg [15:0]	memo_r[48*4-1:0];
	reg [15:0]	memo_i[48*4-1:0];

	integer i, j, k;

	//----------------------------------------------------------------------
	//	Clock and Reset
	//----------------------------------------------------------------------
	always begin
		clock = 1; #10;
		clock = 0; #10;
	end

	initial begin
		j=0;
		k=0;
		lts_in = 0;
		reset = 1; 
		di_en = 0;
		#60;
		reset = 0;

		//$readmemb("in_r.txt", mem_r);
		//$readmemb("in_i.txt", mem_i);

		$readmemb("fft_in_r.txt", mem_r);
		$readmemb("fft_in_i.txt", mem_i);

		#40;

		di_en = 1;

		for (i = 0; i < (80*5); i=i+1) begin
			
			di_re = mem_r[i];
			di_im = mem_i[i];

			if ( i>15 && i<80) begin
				lts_in = 1;
			end

			else lts_in=0;

			if (di_re === 16'bzz) begin
				di_en = 0;
			end

			else di_en = 1;

			@(posedge clock);

		end

		di_en = 0;

	/*	

		#(160*9)

		di_en = 1;

		for (i = 0; i < 560; i=i+1) begin
			
			di_re = mem_r[i];
			di_im = mem_i[i];

			if ( i>15 && i<80) begin
				lts_in = 1;
			end

			else lts_in=0;

			if (di_re === 16'bzz) begin
				di_en = 0;
			end

			else di_en = 1;

			@(posedge clock);

		end

		di_en = 0;

		#(160*12)

		di_en = 1;

		for (i = 0; i < 560; i=i+1) begin
			
			di_re = mem_r[i];
			di_im = mem_i[i];

			if ( i>15 && i<80) begin
				lts_in = 1;
			end

			else lts_in=0;

			if (di_re === 16'bzz) begin
				di_en = 0;
			end

			else di_en = 1;

			@(posedge clock);

		end

		di_en = 0;

		#(160*11)

		di_en = 1;

		for (i = 0; i < 560; i=i+1) begin
			
			di_re = mem_r[i];
			di_im = mem_i[i];

			if ( i>15 && i<80) begin
				lts_in = 1;
			end

			else lts_in=0;

			if (di_re === 16'bzz) begin
				di_en = 0;
			end

			else di_en = 1;

			@(posedge clock);

		end

		di_en = 0;

		#(160*50)

		di_en = 1;

		for (i = 0; i < 560; i=i+1) begin
			
			di_re = mem_r[i];
			di_im = mem_i[i];

			if ( i>15 && i<80) begin
				lts_in = 1;
			end

			else lts_in=0;

			if (di_re === 16'bzz) begin
				di_en = 0;
			end

			else di_en = 1;

			@(posedge clock);

		end

		di_en = 0;

		#(160*10)

		di_en = 1;

		for (i = 0; i < 560; i=i+1) begin
			
			di_re = mem_r[i];
			di_im = mem_i[i];

			if ( i>15 && i<80) begin
				lts_in = 1;
			end

			else lts_in=0;

			if (di_re === 16'bzz) begin
				di_en = 0;
			end

			else di_en = 1;

			@(posedge clock);

		end

		di_en = 0;

	*/	

	end

	delay_n #(.D(16))  u0(clock, reset, lts_in, lts_in_d);


	wire [1:0] sym;

	top top1 (

	.clock	(clock	),	//	i
	.reset	(reset	),	//	i
	.di_en	(di_en	),	//	i
	.di_re	(di_re	),	//	i
	.di_im	(di_im	),	//	i
	.lts_in (lts_in),
	.out_i_eq  (out_i_eq),
	.out_r_eq  (out_r_eq),
	.data_en_dd(data_en_dd),
	.valid_final(valid_final),
	.sym        (sym)

	);


	always @(posedge clock) begin
		
		if (data_en_dd) begin
			
			memo_r[j] = out_r_eq;
			memo_i[j] = out_i_eq;
			j=j+1;


			if (j == 192) begin
				//$stop;
			end


		end

	end

	reg [1:0] memo_sym [48*4-1:0];

	always @(posedge clock) begin
		
		if (valid_final) begin
			
			memo_sym[k] = sym;
			k=k+1;


			if (k == 192) begin
				$stop;
			end


		end

	end



endmodule
