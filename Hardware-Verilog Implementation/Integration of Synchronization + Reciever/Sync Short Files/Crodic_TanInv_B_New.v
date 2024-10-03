module Cordic_TanInv_B_New(
input CLK,s_RST,
	input Input_strobe,
	
	input signed [31:0] I_in,
	input signed [31:0] Q_in,
	
	output reg Out_VALID, //strobe
	
	output reg signed [31:0] Phase
	);
	
//Lut definition
	//reg signed [31:0] atan_lut [0:28]; //used in intial block
	wire signed [31:0] atan_lut [0:28];
	
//Definition of pi_Val
wire signed [31:0] pi_Val;
assign pi_Val = 32'd843314856;
	
//Sample and work regs
reg signed [32:0] I_reg;
reg signed [32:0] Q_reg;


//Current state and Next State	
reg [1:0] current_state;
reg [1:0] next_state;

`define state_IDLE 0
`define state_SAMPLE_VAL 1
`define state_RUN 2

//define counter
	reg [4:0] Counter;
	
	//By observation, do not put less than 4
	localparam Final_Val = 20; //63.76 dB for 10 //39.64 dB for 6 //33.85 dB for 5 //28.31 for 4 //22.69 for 3  //16.08 dB for 2
	
//COntrol signals of FSM
reg sample_in_Val;
reg enable_counter;
reg Run;

//FSM Next STate and OUtput Calculation
always@(*)
	begin
		sample_in_Val=0;
		enable_counter=0;
		Run=0;
		Out_VALID=0;
		
		case(current_state)
			`state_IDLE: begin
							if(Input_strobe)
								begin
									next_state=`state_SAMPLE_VAL;
									sample_in_Val=1;
								end
							else
								begin	
									next_state=`state_IDLE;
								end
						end
						
			`state_SAMPLE_VAL: begin
								next_state=`state_RUN;
								enable_counter=1;
								sample_in_Val=0;
								Run=1;
								end
								
			`state_RUN:			begin
									if(Counter==Final_Val)
										begin
										enable_counter=0;
										Out_VALID=1;
											if(Input_strobe)
												begin
													next_state=`state_SAMPLE_VAL;
													sample_in_Val=1;
													enable_counter=0;
												end
											else
												begin
													next_state=`state_IDLE;
												end
										end
									else
										begin
											next_state=`state_RUN;
											enable_counter=1;
											Run=1;
										end
								end
				default: 
							begin
								next_state=`state_IDLE;
							end
		endcase
	end
	
	//Run Block
	always@(posedge CLK)
		begin
			if(s_RST)
				begin
					I_reg<=0;
					Q_reg<=0;
					Phase<=0;
				end
			else if(sample_in_Val)
				begin
				if(I_in[31]==1) //it is negative
					begin
						if(Q_in[31]==1)
							begin
								Phase<= -pi_Val;
							end
						else
							begin
								Phase<=pi_Val;
							end
						I_reg<=-I_in;
						Q_reg<=-Q_in;
						
					end
				else
					begin
						I_reg<=I_in;
						Q_reg<=Q_in;
						Phase<=0;
					end
				end
				
			else if(Run)
				begin
					if(Q_reg==0)
						begin
							//Do nothing
						end
						
					else if(Q_reg[31]==1) //vector is below xaxis, put it Up
						begin
							Phase<=Phase - atan_lut[Counter];
							I_reg<= I_reg-(Q_reg>>>Counter); //Shift >>> is VERY IMPORTANT
							Q_reg<=Q_reg+(I_reg>>>Counter);
						end
					else
						begin
							Phase<=Phase + atan_lut[Counter];
							I_reg<= I_reg+(Q_reg>>>Counter); //Shift >>> is VERY IMPORTANT
							Q_reg<=Q_reg-(I_reg>>>Counter);
						end
				end
		end
		
		
		
//counter block	
	always@(posedge CLK)
	begin
		if(s_RST)
			begin
				Counter<=0;
			end
		else if(enable_counter)
			begin
				Counter<=Counter+1;
			end
		else
			Counter<=0;
	end
	
 //Next State Transition
always@(posedge CLK)
	if(s_RST)
		begin
			current_state<=`state_IDLE;
		end
	else
		begin
			current_state<=next_state;
		end
		
		
		
		
//initial
///	begin
assign atan_lut[0] = 210828714;
assign atan_lut[1] = 124459457;
assign atan_lut[2] = 65760959;
assign atan_lut[3] = 33381289;
assign atan_lut[4] = 16755421;
assign atan_lut[5] = 8385878;
assign atan_lut[6] = 4193962;
assign atan_lut[7] = 2097109;
assign atan_lut[8] = 1048570;
assign atan_lut[9] = 524287;
assign atan_lut[10] = 262143;
assign atan_lut[11] = 131071;
assign atan_lut[12] = 65535;
assign atan_lut[13] = 32767;
assign atan_lut[14] = 16383;
assign atan_lut[15] = 8191;
assign atan_lut[16] = 4095;
assign atan_lut[17] = 2047;
assign atan_lut[18] = 1023;
assign atan_lut[19] = 511;
assign atan_lut[20] = 255;
assign atan_lut[21] = 127;
assign atan_lut[22] = 63;
assign atan_lut[23] = 31;
assign atan_lut[24] = 15;
assign atan_lut[25] = 7;
assign atan_lut[26] = 3;
assign atan_lut[27] = 2;
assign atan_lut[28] = 1;

	//end
	
endmodule