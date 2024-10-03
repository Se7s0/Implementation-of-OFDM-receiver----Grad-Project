// v0
//v1: samples from an external reg on input strobe
module cordic_vPhaseCorrect(
	input CLK,s_RST,
	input Input_strobe,//Should be connected with AND Gate with the control signal from FSM with sync short output strobe
	//This is first time, second time it should be connected with strobe of total system
	//Adjust This in FSM
	
	input signed [15:0] I_in,
	input signed [15:0] Q_in,
	input signed [31:0] Input_Phase,
	//input Out_sample_values, //Make it sample from a reg
	
	output reg Out_VALID, //strobe
	
	//output  reg signed [1:-15] x_n,y_n
	output reg signed [15:0] I_out,
	output reg signed [15:0] Q_out
	);

//State Encoding	
`define state_WIDTH 1	
`define state_IDLE 1'b0
`define state_CALC 1'b1

//`define pi 32'b00110010010000111111011010101000

wire signed [31:0] pi_Val = 32'b00110010010000111111011010101000;
//`define pi 32'h6487_ED52

localparam Counter_Final_Val=20; //29 (28 in LUT table is max)(29 in counter will include a_tan_lut[28] as last point)

	//Regs for Sampling
	reg signed [16:0] I_reg;
	reg signed [16:0] Q_reg;
	reg up_half;
	reg right_half;
	reg signed [31:0] Phase_reg;
	//reg signed [31:0] Phase_Accumulator;
	
	//State Regs
	reg [`state_WIDTH-1:0] current_state;
	reg [`state_WIDTH-1:0] next_state;
	
	//Internal Control Signals
	
	reg sample_values; //Adjusted in this version to be controlled from outside
	reg enable_counter;
	reg Run_Alg;
	//reg [31:0] Phase_SAMPLED;
	reg Cond_1;
	
	//Signals after ajustement of Quadrants
	
	//wire signed [17:0] I_in;
	//wire signed [17:0] Q_in;
	
	//assign I_in = I_in[15]==0 ? I_in : ~I_in+1'b1;
	//assign Q_in = I_in[15]==0 ? Q_in : ~Q_in+1'b1;
	//assign I_in = I_in;
	//assign Q_in = Q_in;
	
	//define counter
	reg [4:0] Counter;
	
	//Lut definition
	//reg signed [31:0] atan_lut [0:Counter_Final_Val-1]; //used in initial block
	wire signed [31:0] atan_lut [0:28];
	
	//Change it to I_out and Q_out and so on
	//Phase_before_Map to Out World
	always@(*)
		begin
			/*
			if(up_half & ~right_half)
				begin
					//Phase=Phase_before_Map+ pi_Val;
					I_out= ~I_reg + 1'b1;
					Q_out = ~Q_reg + 1'b1;
				end
			else if(~up_half & ~right_half)
				begin
					I_out= ~I_reg + 1'b1;
					Q_out = ~Q_reg + 1'b1;
				end
				
			else */
				if(Cond_1)
				begin
					I_out= -I_reg[16:1];
					Q_out = -Q_reg[16:1];
				end
				else
				begin
					I_out= I_reg[16:1];
					Q_out = Q_reg[16:1];
				end
		end
		
//Next state transition
always @(posedge CLK)
 begin
  if(s_RST)
   begin
	 current_state <= `state_IDLE ;
   end
  else
   begin
	 current_state <= next_state ;
   end
 end	

 //FSM output and next state Calculation
	always@(*)
		begin
			//3arafly yabny kol el control signals hena b zero
			//Write Only Values in state, the values that are invert to this
			sample_values=0;
			enable_counter=0;
			Run_Alg=0;
			Out_VALID=0;
			
			case(current_state)
				`state_IDLE: begin
				
								//fy style el 2 , kona bn7ot hena bara el output b8ad el nazar 3an el inputs, fy el state bas
								//DYh internal control signals, 3yzynha t act bsor3a 34an el module yb2a 7etta 3ala ba3do
								if(Input_strobe)
									begin
										next_state=`state_CALC;
										sample_values=1;
										
										//ta3dyl:
											Run_Alg=1;
										enable_counter=1;
									end
								else
									begin
										next_state=`state_IDLE;
									end
								end
								
				`state_CALC: begin //lw m3rft4 eny ykml, hydy3 1 cycle 3ala m y2dr y response tany
								
								
								if(Counter==Counter_Final_Val)
										begin
											Out_VALID=1;
											//
											
											//set for next round
											if(Input_strobe)
												begin
													next_state=`state_CALC;
													sample_values=1;
												end
											else
												begin
													next_state= `state_IDLE;
													
												end
										end
								else
									begin
										next_state= `state_CALC;
										Run_Alg=1;
										enable_counter=1;
									end
							end
									
					default:	next_state=`state_IDLE;
									
				endcase
	end
				
	
	//Sampling
	always@(posedge CLK)
		begin
			if(s_RST)
				begin
				
					Cond_1<=0;
					Phase_reg<=0;
					I_reg<=0;
					Q_reg<=0;
					up_half<=0;
					right_half<=0;
				
				end
			else if(sample_values)
				begin
					//This is Assumption, test this algorithm
				//	Phase_Accumulator<=0;
					up_half<=~Q_in[15];
					right_half<=~I_in[15];
					
					if((Input_Phase> (pi_Val>>>1)) && !Input_Phase[31]) //if angle is +ve and greater than pi/2
					begin
						//Phase_reg<= Input_Phase- (pi_Val>>>1);
						Cond_1<=1;
						Phase_reg<= Input_Phase - (pi_Val);
						Q_reg<= Q_in;
						I_reg<= I_in;
						
						/*
						if(I_in[15]==0 & Q_in[15] ==0)
							begin
								I_reg<=~I_in +1'b1;
						end
						
						else if(I_in[15]==1 & Q_in[15] ==0)
							begin
								Q_reg<=~Q_in +1'b1;
						end
						
						else if(I_in[15]==1 & Q_in[15] ==1)
							begin
								I_reg<=~I_in +1'b1;
						end
						
						else if(I_in[15]==0 & Q_in[15] ==1)
							begin
								Q_reg<=~Q_in +1'b1;
						end
						*/
					end
					
					else if((Input_Phase < (-pi_Val>>>1)) && Input_Phase[31]) //less than -pi/2 and -ve
					begin
						Cond_1<=1;
						Phase_reg<= (pi_Val) + Input_Phase;
						Q_reg<= Q_in;
						I_reg<= I_in;
						/*
						if(I_in[15]==0 & Q_in[15] ==0)
							begin
								Q_reg<=~I_in +1'b1;
						end
						
						else if(I_in[15]==1 & Q_in[15] ==0)
							begin
								I_reg<=~Q_in +1'b1;
						end
						
						else if(I_in[15]==1 & Q_in[15] ==1)
							begin
								Q_reg<=~I_in +1'b1;
						end
						
						else if(I_in[15]==0 & Q_in[15] ==1)
							begin
								I_reg<=~Q_in +1'b1;
						end
						*/
					end
					
					else
					begin
						Cond_1<=0;
						Phase_reg<=Input_Phase;
						I_reg<=I_in;
						Q_reg<=Q_in;
						
					end
				end
				
			else if(Run_Alg)
				begin
				/*	
				if(Phase_Accumulator==Phase_reg) //u can delete this condition for easiness, very hard to happen
					begin
						//Do nothing,angle reached
					end */
					
					/*if(Phase_reg==0) //For debugging only, it does not give cordic gain
						begin
							//DO nothing
						end
				 else */ if(Phase_reg[31] ==0) //Old (Vector is below x_axis), rotate it towards up
					begin
					
						
						I_reg<= I_reg-(Q_reg>>>Counter); //Shift >>> is VERY IMPORTANT
						Q_reg<=Q_reg+(I_reg>>>Counter);
						
						Phase_reg<=Phase_reg-atan_lut[Counter];
						
					end
				else	//Vector is ABove x-axis
					begin
						
						I_reg<= I_reg+(Q_reg>>>Counter);
						Q_reg<=Q_reg-(I_reg>>>Counter);
						
						Phase_reg<=Phase_reg+atan_lut[Counter];
					end
				
					
			end
		end
	
	
				
	//counter block
	always@(posedge CLK)
	begin
		if(s_RST)
			begin
				Counter<={5{1'b1}};
			end
		else if(enable_counter)
			begin
				Counter<=Counter+1;
			end
		else
			Counter<={5{1'b1}};
	end
	
	
//	initial
//	begin
assign 	atan_lut[0] = 210828714;
assign 	atan_lut[1] = 124459457;
assign 	atan_lut[2] = 65760959;
assign 	atan_lut[3] = 33381289;
assign 	atan_lut[4] = 16755421;
assign 	atan_lut[5] = 8385878;
assign 	atan_lut[6] = 4193962;
assign 	atan_lut[7] = 2097109;
assign 	atan_lut[8] = 1048570;
assign 	atan_lut[9] = 524287;
assign 	atan_lut[10] = 262143;
assign 	atan_lut[11] = 131071;
assign 	atan_lut[12] = 65535;
assign 	atan_lut[13] = 32767;
assign 	atan_lut[14] = 16383;
assign 	atan_lut[15] = 8191;
assign 	atan_lut[16] = 4095;
assign 	atan_lut[17] = 2047;
assign 	atan_lut[18] = 1023;
assign 	atan_lut[19] = 511;
assign 	atan_lut[20] = 255;
assign 	atan_lut[21] = 127;
assign 	atan_lut[22] = 63;
assign 	atan_lut[23] = 31;
assign 	atan_lut[24] = 15;
assign 	atan_lut[25] = 7;
assign 	atan_lut[26] = 3;
assign 	atan_lut[27] = 2;
assign 	atan_lut[28] = 1;

//	end
	
endmodule