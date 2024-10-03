module a_moving_avg
#(parameter
		delay_LENGTH = 16,
		I_Q_Width=16,
		PRE_CALCULATED_SUM_WIDTH=20,
		//Low_Index=0,
		High_Index=15,
		Init_Strobe_Vector=0
	)
		
	(	input CLK,s_RST,
	input signed [I_Q_Width-1:0] a_i,a_q, //i: in-phase, q:quadratue 
	
	input enable,	//enable is used here as a reset when low !!!!!!!!!!!!!!!!!!	
	input input_strobe,
	output signed [I_Q_Width-1:0] a_i_avg,a_q_avg, 
	
	//output reg output_strobe,
	output wire output_Valid
	);
	
	localparam Repeat_Bits = PRE_CALCULATED_SUM_WIDTH-I_Q_Width;
	parameter Low_Index=High_Index+1-I_Q_Width;
	
	// local parametr of sum width of moving average
	localparam SUM_WIDTH = PRE_CALCULATED_SUM_WIDTH;
	//running sum seg
	reg signed [SUM_WIDTH-1:0] running_sum_i ,running_sum_q ;
	//output to outside world of avg filter
	//Automatic by counting from MSB
	//assign a_i_avg = running_sum_i[SUM_WIDTH-1:SUM_WIDTH-1-I_Q_Width+1];
	//assign a_q_avg = running_sum_q[SUM_WIDTH-1:SUM_WIDTH-1-I_Q_Width+1];
	//Using High and Low dedicated by user
	assign a_i_avg = running_sum_i[High_Index:Low_Index];
	assign a_q_avg = running_sum_q[High_Index:Low_Index];
	
	//Connection to barrel module
	wire signed [I_Q_Width-1:0] a_i_delayed,a_q_delayed;
	
	wire signed [PRE_CALCULATED_SUM_WIDTH-1:0] a_i_sign_extended;
	wire signed [PRE_CALCULATED_SUM_WIDTH-1:0] a_i_delayed_sign_extended;
	wire signed [PRE_CALCULATED_SUM_WIDTH-1:0] a_q_sign_extended;
	wire signed [PRE_CALCULATED_SUM_WIDTH-1:0] a_q_delayed_sign_extended;
	//Sign extensions
	assign a_i_sign_extended = {{Repeat_Bits{a_i[I_Q_Width-1]}},a_i};
	assign a_i_delayed_sign_extended = {{Repeat_Bits{a_i_delayed[I_Q_Width-1]}},a_i_delayed};
	
	assign a_q_sign_extended = {{Repeat_Bits{a_q[I_Q_Width-1]}},a_q};
	assign a_q_delayed_sign_extended = {{Repeat_Bits{a_q_delayed[I_Q_Width-1]}},a_q_delayed};
	
	always@(posedge CLK)
		begin
			if(s_RST)
				begin
					running_sum_i<=0;
					running_sum_q<=0;
				end
			
			else if(enable)
				begin
					if(input_strobe)
						begin
						//running_sum_i<=running_sum_i + a_i -a_i_delayed;
						//running_sum_i<=running_sum_i +a_q- a_q_delayed;
						running_sum_i<=running_sum_i + a_i_sign_extended -a_i_delayed_sign_extended;
						running_sum_q<=running_sum_q +a_q_sign_extended- a_q_delayed_sign_extended;
						end
					else
						begin
						end
				end
			else //enable is low
				begin
					running_sum_i<=0;
					running_sum_q<=0;
					
				end
				
		end
		
		
		
	
	a_delay_sample #(.I_Q_Width(I_Q_Width),.delay_LENGTH(delay_LENGTH),.Init_Strobe_Vector(Init_Strobe_Vector))  delay_sample_inst(
	.CLK(CLK),.s_RST(s_RST),
	.a_i(a_i),.a_q(a_q),
	
	.enable(enable),
	.input_strobe(input_strobe),
	.a_i_de(a_i_delayed),.a_q_de(a_q_delayed),
	
	.output_Valid(output_Valid)
	);
endmodule
	
	