module top
(
	input 				clock,
	input 				reset,
	input 				di_en,
	input signed [15:0]	di_re,
	input signed [15:0]	di_im,
	input 				lts_in,

	output wire		[15:0]	out_r_eq,
	output wire		[15:0]	out_i_eq,
	output wire 			data_en_dd,

	output wire 			valid_final,
	output wire     [1:0] 	sym


	);


	wire		do_en;
	wire[5:0]	addr, addr_deall;
	wire		data_en, w_en;
	wire 		mem1_we;
	wire		mem2_we;
	wire[15:0]	out_r, c_r, pout_r, pilot_avg_r;
	wire[15:0]	out_i, c_i, pout_i, pilot_avg_i;
	wire		lts_out;
	wire 		ref_sym;
	wire[15:0]  plts_r, plts_i, pdata_r, pdata_i;

	FFT FFT (
	.clock	(clock	),	//	i
	.reset	(reset	),	//	i
	.di_en	(di_en	),	//	i
	.di_re	(di_re	),	//	i
	.di_im	(di_im	),	//	i
	.lts_in (lts_in),
	.do_en	(do_en	),	//	o
	.lts_out(lts_out),
	.counter 	(addr   ),
	.out_r	(out_r	),	//	o
	.out_i	(out_i	),	//	o
	.mem1_we(mem1_we),
	.mem2_we(mem2_we)
	);

	pilot_null_detector pilot_null_detector(

	.clk       (clock),
	.rst_n     (reset),
	.data_valid (do_en),
	.lts_in    (lts_out),
	.out_i     (out_i),
	.out_r     (out_r),
	.data_en   (data_en),
	.w_en      (w_en),
	.addr      (addr_deall),
	.data_en_p_d (data_en_p),
	.plts_r    (plts_r),
	.plts_i    (plts_i),
	.pdata_r   (pdata_r),
	.pdata_i   (pdata_i)

	);

	cmult_p pilot_complex_mult(

		.clk    (clock),
		.rst_n  (reset),
		.data_en(data_en_p),
		.ar     (plts_r),
		.ai     (plts_i),
		.br     (pdata_r),
		.bi     (pdata_i),
		.pr     (pout_r),
		.pi     (pout_i),
		.data_en_dd(data_en_pil)

	);

	pilot_avg pilot_avg(

		.clk      (clock),
		.rst_n    (reset),
		.data_en  (data_en_pil),
		.pilot_r    (pout_r),
		.pilot_i    (pout_i),
		.pilot_avg_r(pilot_avg_r),
		.pilot_avg_i(pilot_avg_i)

	);

	mem1 #(.N(48)) memory_lts(

	.clk       (clock),
	.rst_n     (reset),
	.addra 	   (addr_deall),
	.addrb 	   (addr_deall),
	.we 	   (w_en),
	.data_r    (out_r),
	.data_i    (out_i),
	.tmp_data_r (c_r),
	.tmp_data_i (c_i)

	);

	ROM_ref ref_symbols_lut(clock, reset, addr_deall, 1'b0, ref_sym);

	cmult channel_equalizer(clock, reset, data_en, ref_sym, c_r, c_i, out_r, out_i, out_r_eq, out_i_eq, data_en_dd, pilot_avg_r, pilot_avg_i); //remove pilots

	demod demodulator(

	clock, reset, out_r_eq, out_i_eq, data_en_dd, sym, valid_final
	
	);



endmodule
