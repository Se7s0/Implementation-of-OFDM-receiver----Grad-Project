module SYNC_SHORT_LONG(

			input CLK, CLK_slow,
			//Reset of each Module
			input s_RST,
			//input s_RST_RESETTER_OUT_Short,
			//input s_RST_RESETTER_OUT_Long,
				
			//Enable of each Module
			input enable,
			//input enable_Short,
			//input enable_Long,
			
			//Main inputs
			input signed [15:0] I_main,Q_main,
			input In_main_Strobe,

			output output_strobe,
			output data_en_dd,
			output signed [15:0] I_out,
			output signed [15:0] Q_out

);
	

wire		do_en;
wire [5:0]	addr, addr_deall;
wire		data_en, w_en;
wire 		mem1_we;
wire		mem2_we;
wire signed [15:0]	out_r, c_r, out_r_eq;
wire signed [15:0]	out_i, c_i, out_i_eq;
wire		lts_out;
wire 		ref_sym;
wire		Providing_Long, Providing_Stream;
wire [1:0]	sym;

	
wire S_L_Final_Det;
wire S_L_Final_Out_Strobe;
wire S_L_Phase_Strobe;
wire signed [31:0] S_L_Phase;
	
top_dec top_dec_Inst(
		 .CLK(CLK),.s_RST(s_RST_RESETTER_OUT),.enable(enable),
		.I_main(I_main),.Q_main(Q_main),
		.In_main_Strobe(In_main_Strobe),


		.Pack_det(), //rises and falls with strobes only // 4/5/2024 maloo4 lazma dlw2ty
		.pak_strobe(), // 4/5/2024 maloo4 lazma dlw2ty

		.Final_Det(S_L_Final_Det), //(After Counts) M3ana
		.Final_Out_Strobe(S_L_Final_Out_Strobe), //(SHould be same as pak_source if connected to same source M3ana
		.Phase_Strobe(S_L_Phase_Strobe),
		.Phase(S_L_Phase)
);

Correlator_Top #(.GP_COUNTER_WIDTH(8)) Correlator_Top_Inst(

	.CLK(CLK),.s_RST(s_RST_RESETTER_OUT),.enable(enable),

	.input_strobe(In_main_Strobe), //The MAin Great STrobe



	.I_in(I_main),
	.Q_in(Q_main),

	.output_strobe(output_strobe),

	//New 
	.Phase_t_sample(S_L_Phase),
	 
	 //Fsm related 
	 .short_preamble_found(S_L_Final_Det), //no need to look at the strobe of this S_L_Final_Det
	.in_phase_strobe(S_L_Phase_Strobe), //coming from short sync
	.Providing_Long(Providing_Long),
	.Providing_Stream(Providing_Stream),

	.I_out(I_out),
	.Q_out(Q_out),


	.Mag_Sq(), //unecessary, for debugging in these newer versions

	.Index() //unecessary, for debugging in these newer versions
);

SYN_RESETTER #(.NO_OF_FRAME_IN_PAK(4),.COUNT_WIDTH(3)) SYN_RESETTER_INST
	(.CLK(CLK),.s_RST(s_RST),
	.Providing_Stream(Providing_Stream),
	.input_strobe(output_strobe),
	
	.s_RST_RESETTER_OUT(s_RST_RESETTER_OUT)
);

assign Data_valid = Providing_Stream || Providing_Long;

FFT FFT (
	.clock	(CLK_slow	),	//	i
	.reset	(s_RST	),	//	i
	.di_en	(Data_valid	),	//	i
	.di_re	(I_out >>> 6),	//	i
	.di_im	(Q_out >>> 6),	//	i
	.lts_in (Providing_Long),
	.do_en	(do_en	),	//	o
	.lts_out(lts_out),
	.counter 	(addr   ),
	.out_r	(out_r	),	//	o
	.out_i	(out_i	),	//	o
	.mem1_we(mem1_we),
	.mem2_we(mem2_we)
);

pilot_null_detector u0(

	.clk       (CLK_slow),
	.rst_n     (s_RST),
	.data_valid (do_en),
	.lts_in    (lts_out),
	.data_en   (data_en),
	.w_en      (w_en),
	.addr    (addr_deall)

);

mem1 #(.N(48)) m_lts(

	.clk       (CLK_slow),
	.rst_n     (s_RST),
	.addra 	   (addr_deall),
	.addrb 	   (addr_deall),
	.we 	   (w_en),
	.data_r    (out_r),
	.data_i    (out_i),
	.tmp_data_r (c_r),
	.tmp_data_i (c_i)

);

ROM_ref u4(

	CLK_slow, s_RST, addr_deall, 1'b0, ref_sym
);

cmult u3(

	CLK_slow, s_RST, data_en, ref_sym, c_r, c_i, out_r, out_i, out_r_eq, out_i_eq, data_en_dd

);

demod d1(

	CLK_slow, s_RST, out_r_eq, out_i_eq, data_en_dd, sym, valid_final
);

endmodule