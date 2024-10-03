module top_dec(
input CLK,
input s_RST,
input signed [15:0] I_main,Q_main,
input In_main_Strobe,
input enable,

output Pack_det, //rises and falls with strobes only
output pak_strobe,
output Final_Det, //(After Counts)
output Final_Out_Strobe, //(SHould be same as pak_source if connected to same source
output Phase_Strobe,
output signed [31:0] Phase
);

parameter High_Mov_Avg_c2 = 33; //opt 33 
parameter High_Mov_Avg_c6 = 33;

wire [15:0] i_c0_c1,q_c0_c1;
wire strobe_c0_c1;

//Block c0
a_delay_sample #(.delay_LENGTH(16),.I_Q_Width(16)) delay_sample_inst_c0
		
	(	.CLK(CLK),.s_RST(s_RST),
	.a_i(I_main),.a_q(Q_main), //i: in-phase, q:quadratue 
	
	.enable(enable),		//enable is being used as a reset when Low !!!!!!!!!!!!!!!!!!
	.input_strobe(In_main_Strobe),

	.a_i_de(i_c0_c1),.a_q_de(q_c0_c1), 
	
	//output reg output_strobe,
	.output_Valid(strobe_c0_c1)
	);
	

wire [31:0] i_c1_c2,q_c1_c2;
wire [15:0] neg_q_c0_c1;
wire strobe_c1_c2;
assign neg_q_c0_c1 = ~q_c0_c1 + 1'b1;

//Block c1
a_complex_mult #(.I_Q_Width(16)) complex_mult_inst_c1
 (	.CLK(CLK),.s_RST(s_RST),
	.a_i(i_c0_c1),.a_q(neg_q_c0_c1),
	.b_i(I_main),.b_q(Q_main), //i: in-phase, q:quadratue 
	.input_strobe(strobe_c0_c1),
	
	.p_i(i_c1_c2),.p_q(q_c1_c2), //there is no carry bit guard here
	
	.output_strobe(strobe_c1_c2)
	);
	

wire [31:0] i_c2_c3,q_c2_c3;
wire strobe_c2_c3;	
//Block c2 (needs to be tested)
a_moving_avg
#(.delay_LENGTH(16),
		.I_Q_Width(32),
		.PRE_CALCULATED_SUM_WIDTH(36), //37 or 36?	(IMPPOOOORTAAANT) /////////////////
		.High_Index(High_Mov_Avg_c2),
		.Init_Strobe_Vector(16'b0000_0000_0000_0000)
	)
			moving_avg_inst_c2
	(	.CLK(CLK),.s_RST(s_RST),
	.a_i(i_c1_c2),.a_q(q_c1_c2), //i: in-phase, q:quadratue 
	
	.enable(enable),	//enable is used here as a reset when low !!!!!!!!!!!!!!!!!!	
	.input_strobe(strobe_c1_c2),
	.a_i_avg(i_c2_c3),.a_q_avg(q_c2_c3), 
	
	//output reg output_strobe,
	.output_Valid(strobe_c2_c3)
	);
	

wire strobe_c3_c4;
wire [31:0] mag_c3_c4;
//Block 3
a_complex_to_mag complex_to_mag_inst_c3(

.CLK(CLK),.s_RST(s_RST),
.input_strobe(strobe_c2_c3),
.i(i_c2_c3),.q(q_c2_c3),

.mag_stb(strobe_c3_c4),
.mag(mag_c3_c4)
);
	
	
wire [15:0] neg_Q_main;
wire [31:0] mag_sq_c5_c6;
wire strobe_c5_c6;
assign neg_Q_main = ~Q_main +1'b1;	

//Block c5
a_complex_mult #(.I_Q_Width(16)) complex_to_mag_sq_inst_c5
 (	.CLK(CLK),.s_RST(s_RST),
	.a_i(I_main),.a_q(Q_main),
	.b_i(I_main),.b_q(neg_Q_main), //i: in-phase, q:quadratue 
	.input_strobe(In_main_Strobe),
	
	.p_i(mag_sq_c5_c6),.p_q(), //there is no carry bit guard here
	
	.output_strobe(strobe_c5_c6)
	);


wire [31:0] i_c6_c4;
wire strobe_c6;	
//Block c6
//for optimization, make it single channel delay 
a_moving_avg
#(.delay_LENGTH(16),
		.I_Q_Width(32),
		.PRE_CALCULATED_SUM_WIDTH(36), //37 or 36? (IMPPOOOORTAAANT) the value entered is always +ve (Using matlab, it can be reduced to 34 bits)
		.High_Index(High_Mov_Avg_c6),
		.Init_Strobe_Vector(16'h0)
	)
			moving_avg_inst_c6
	(	.CLK(CLK),.s_RST(s_RST),
	.a_i(mag_sq_c5_c6),.a_q(), //i: in-phase, q:quadratue 
	
	.enable(enable),	//enable is used here as a reset when low !!!!!!!!!!!!!!!!!!	
	.input_strobe(strobe_c5_c6),
	.a_i_avg(i_c6_c4),.a_q_avg(), 
	
	//output reg output_strobe,
	.output_Valid(strobe_c6)
	);
	
//block c4	
a_pack_decision pack_decision_inst_c4(
.CLK(CLK),
.s_RST(s_RST),
.prod_avg_mag(mag_c3_c4),
.mag_sq_avg(i_c6_c4),
.prod_avg_mag_Strobe(strobe_c3_c4),

.Pack_det(Pack_det), //rises and falls with strobes only
.pak_strobe(pak_strobe)
);



//CFO Estimation

wire signed [31:0] i_c8_Cordic;
wire signed [31:0] q_c8_Cordic;
wire strobe_c8_Cordic;

//Block c8 (needs to be tested)

a_moving_avg
#(.delay_LENGTH(64),
		.I_Q_Width(32),
		.PRE_CALCULATED_SUM_WIDTH(37), //Recalculate After Correction Please //(5lyh kda 38 badal 37)
		.High_Index(35),////////////////////////MAKES OVERFLOW AT HIGH SNRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR
		.Init_Strobe_Vector(64'h0)
	)
			moving_avg_inst_c8
	(	.CLK(CLK),.s_RST(s_RST),
	.a_i(i_c1_c2),.a_q(q_c1_c2), //i: in-phase, q:quadratue 
	
	.enable(enable),	//enable is used here as a reset when low !!!!!!!!!!!!!!!!!!	
	.input_strobe(strobe_c1_c2),
	.a_i_avg(i_c8_Cordic),.a_q_avg(q_c8_Cordic), 
	
	//output reg output_strobe,
	.output_Valid(strobe_c8_Cordic)
	);
	

Cordic_TanInv_B_New Inst_Cordic_TanInv_B_New_c9(
	.CLK(CLK),.s_RST(s_RST),
	.Input_strobe(strobe_c8_Cordic),
	
	.I_in(i_c8_Cordic),.Q_in(q_c8_Cordic),
	
	
	.Out_VALID(Phase_Strobe), //strobe
	
	
	.Phase(Phase)
	);
	
//Wires of Final block (put a code when diagram is drawn)
//Defined at top	
//wire Final_Det;
//wire Final_Out_Strobe;
	
Count_Detects
#(
		.Counts(15),
		.Counter_Width(4)
	)
	Count_Detects_inst
	(
.CLK(CLK),
.s_RST(s_RST),
//.In_Pak_Strobe(pak_strobe),
.In_Pak_Strobe(strobe_c3_c4), //for faster 1 cycle
.In_Pack_det(Pack_det),
.enable(enable), //low Clears

.Out_Det(Final_Det), //rises and falls with strobes only
.Out_Strobe(Final_Out_Strobe)
);

endmodule