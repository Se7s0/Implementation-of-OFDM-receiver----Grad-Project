module Correlator_Top #(parameter GP_COUNTER_WIDTH=8)(

input CLK,s_RST,

input input_strobe, //The MAin Great STrobe
input enable,


input signed [15:0] I_in,
input signed [15:0] Q_in,

output output_strobe,
output  [11:0] Mag_Sq, //unecessary, for debugging in these newer versions

output [GP_COUNTER_WIDTH-1:0] Index, //unecessary, for debugging in these newer versions

//New 
input signed [31:0] Phase_t_sample,
 
 //Fsm related 
 input short_preamble_found,
input in_phase_strobe, //coming from short sync
output Providing_Long,
output Providing_Stream,

output signed [15:0] I_out,
output signed [15:0] Q_out
);

wire signed [15:0] c0_c1_I_out;
	wire signed [15:0] c0_c1_Q_out;
	
	
assign I_out = c0_c1_I_out;
assign Q_out = c0_c1_Q_out;
 
wire signed [6:0] I_corr_Out_Inter;
 
wire signed [6:0] Q_corr_Out_Inter;
wire Corr_Sync_Out_Strobe_Inter;

wire signed [1:0] c1_c2_I_Quant;
wire signed [1:0] c1_c2_Q_Quant;


//c2
//Instintates two bit Multipliers inside it, and chain of adders
Correlator_Lsync Correlator_Sync_Inst(
.CLK(CLK),.s_RST(s_RST),

.I_in_Quant(c1_c2_I_Quant),
.Q_in_Quant(c1_c2_Q_Quant),
.enable(enable),

.input_strobe(c1_c2_output_strobe),
.output_strobe(Corr_Sync_Out_Strobe_Inter),

.I_corr_Out(I_corr_Out_Inter), //max I is 32 , -18
.Q_corr_Out(Q_corr_Out_Inter) //Max Q is 16, -12

); 

wire c3_c4_strobe;

Lsync_Mag_Sq Lsync_Mag_Sq_Inst(

.CLK(CLK),.s_RST(s_RST),
.I_in_A(I_corr_Out_Inter),
.Q_in_A(Q_corr_Out_Inter),
.input_strobe(Corr_Sync_Out_Strobe_Inter),


.I_Out(Mag_Sq), // max value is 32^2 + 16^2
.output_strobe(c3_c4_strobe)

);


wire [GP_COUNTER_WIDTH-1:0] Internal_Counter_c5;

//c4 Fina Max
Find_Max #(.GP_COUNTER_WIDTH(GP_COUNTER_WIDTH)) Find_Max_c4(
.CLK(CLK),.s_RST(s_RST),

.Mag_Val(Mag_Sq),
.input_strobe(c3_c4_strobe),
.in_Counter_Val(Internal_Counter_c5),
.enable(enable),

.Index(Index),
//.output_strobe(output_strobe) strobe of find max, maybe important for FSM
.output_strobe()
);

//c00, phase reg and adder
//Phase Register and adder
wire FSM_c00_sample;

wire signed [31:0] c00_c0_Phase_Out;

Phase_Adder_and_Reg Phase_Adder_and_Reg_c00(

.CLK(CLK),.s_RST(s_RST),

.sample(FSM_c0_sample),

.Phase_t_sample(Phase_t_sample),
.Input_Strobe(input_strobe),

.Phase_Out(c00_c0_Phase_Out)
);



//c0, Phase corrector
wire strobe_c0;
wire FSM_c0_Activate_Phase_Calc;

assign strobe_c0 = input_strobe & FSM_c0_Activate_Phase_Calc;


	wire c0_c1_Out_VALID;
	
	
cordic_vPhaseCorrect cordic_vPhaseCorrect_c0(
	.CLK(CLK),.s_RST(s_RST),
	.Input_strobe(strobe_c0),//Should be connected with AND Gate with the control signal from FSM with sync short output strobe
	//This is first time, second time it should be connected with strobe of total system
	//Adjust This in FSM
	
	.I_in(I_in),
	.Q_in(Q_in),
	.Input_Phase(c00_c0_Phase_Out),
	//input Out_sample_values, //Make it sample from a reg
	
	.Out_VALID(c0_c1_Out_VALID), //strobe
	
	//output  reg signed [1:-15] x_n,y_n
	.I_out(c0_c1_I_out),
	.Q_out(c0_c1_Q_out)
	);

	
wire FSM_c1_Activate_Quantizer;



//c1 , Quantizer
	Quantizer_Lsync Quantizer_Lsync_c1(
.I_in_MSB(c0_c1_I_out[15]), //Connect the MSB only
.Q_in_MSB(c0_c1_Q_out[15]),
.input_strobe(c0_c1_Out_VALID),
.Active_Quant(FSM_c1_Activate_Quantizer),

.I_Quant(c1_c2_I_Quant),
.Q_Quant(c1_c2_Q_Quant),
.output_strobe(c1_c2_output_strobe)
);



//c5 GP_Counter
wire [GP_COUNTER_WIDTH-1:0] Load_Inital_Value_FSM_c5;
wire [GP_COUNTER_WIDTH-1:0] Load_Final_Value_FSM_c5;
wire C_up_FSM_c5;
wire Count_FSM_c5;
wire Load_FSM_c5;
wire Done_c5_FSM;


Load_Done_Counter  #(.reg_WIDTH(GP_COUNTER_WIDTH)) Load_Done_Counter_c5

	
	(.CLK(CLK),.s_RST(s_RST),
	.Load_Inital_Value(Load_Inital_Value_FSM_c5), 
	.Load_Final_Value(Load_Final_Value_FSM_c5),
	
	.C_up(C_up_FSM_c5),	
	.Count(Count_FSM_c5 & input_strobe), //it counts on slow clock
	.Load(Load_FSM_c5),
	
	.Done(Done_c5_FSM), 
	.Internal_Counter(Internal_Counter_c5)
	);
	
	
//FSM




FSM_sync_long
#(
		.GP_COUNTER_WIDTH(GP_COUNTER_WIDTH)
	)
		FSM_Inst
	(
	.in_Counter_Val(Internal_Counter_c5),
	.CLK(CLK),.s_RST(s_RST),
	.short_preamble_found(short_preamble_found),
	.in_phase_strobe(in_phase_strobe), //this is coming from sync short
	.in_corrected_ph_strobe(c0_c1_Out_VALID),
	
	//outputs Singals to outer world
	.Out_Strobe(output_strobe),
	.Providing_Long(Providing_Long),
	.Providing_Stream(Providing_Stream),
	
	//Counter (29-4-2024)
	.GP_Done(Done_c5_FSM),
	.GP_Load(Load_FSM_c5),
	.GP_Cup(C_up_FSM_c5),
	.GP_Count_Active(Count_FSM_c5),
	.GP_Counter_Initial(Load_Inital_Value_FSM_c5),
	.GP_Counter_Final(Load_Final_Value_FSM_c5),
	//Max search (29-4-2024)
	.Max_Found_Index(Index),
	
	//output controls
	.Active_Phase_Sample(FSM_c0_sample),
	.Activate_Phase_Calc(FSM_c0_Activate_Phase_Calc), //should be and gated with input strobe at input of phase calculator
	.Activate_Quantizer(FSM_c1_Activate_Quantizer)
	);	
	
endmodule