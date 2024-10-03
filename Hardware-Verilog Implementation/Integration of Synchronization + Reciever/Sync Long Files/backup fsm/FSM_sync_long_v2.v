module FSM_sync_long
#(parameter
		GP_COUNTER_WIDTH = 8
	)
	(

	input CLK,s_RST,
	input short_preamble_found,
	input in_phase_strobe, //this is coming from sync short
	input in_corrected_ph_strobe,
	
	//outputs Singals to outer world
	output reg Out_Strobe,
	output reg Providing_Long,
	output reg Providing_Stream,
	
	//Counter (29-4-2024)
	input GP_Done,
	output reg GP_Load,
	output reg GP_Cup,
	output reg GP_Count_Active,
	output reg [GP_COUNTER_WIDTH-1:0] GP_Counter_Initial,
	output reg [GP_COUNTER_WIDTH-1:0] GP_Counter_Final,
	//Max search (29-4-2024)
	input [GP_COUNTER_WIDTH-1:0] Max_Found_Index,
	
	//output controls
	output reg Active_Phase_Sample,
	output reg Activate_Phase_Calc, //should be and gated with input strobe at input of phase calculator
	output reg Activate_Quantizer
	);
	//A Melee Machine
	//Creating A general Purpose Counter
	
/********************************************************************/
/************************Local Params*****************************/
/*******************************************************************/

	

//localparam REST_COUNTS_VALUE = 110;

//All comment are made from The following Assumption
//COnsidering the optimal fall from Rest is at first point of CP of Long
//Considering 1 indexing of the shape of the frame (first point in CP of Long is 1)
//Also an important assumption that data seen by the Find Max is synced with the GP Counter, meaning that the ends before (or with) a new sample being entered

localparam REST_COUNTS_VALUE = 112; //put rest counts zero now because we are starting from begining of 
//Put Rest Counts equal zero if u actually need not to Rest

localparam CORRELATION_PERIOD = 64+1+1; //slide the window N points
// 64+1+1: 64 is the sweep length, +2 by trial it is proved that it sweeps the 64th point sucessfully

localparam POSITION_OF_SECOND_LONG = 96;
//The start position of second Long Training (if starts at 97(if 1 indexing):Therefore u put the position (97) -1)
localparam POSTION_OF_TARGETTED_CORRELATION_WINDOW = 65;
//COnsidering 1 indexing The postion of second 16 after CP is 49, Put above it number 16 (which is the delay length of the correlator)
// U find that it starts at 65


/********************************************************************/
/************************Defining Macros*****************************/
/*******************************************************************/	
`define STATE_WIDTH 4
`define state_IDLE 0
`define state_SAMPLE_PHASE 1
`define state_RESTING 2
`define state_CORRELATING 3
`define state_WAIT_FOR_SECOND_TRAIN 4
`define state_PROVIDING_LONG 5
`define state_WAITING_CP 6
`define state_PROVIDING_STREAM 7

/********************************************************************/
/************************Internal Regs Declarement*******************/
/*******************************************************************/
//current and next
reg [`STATE_WIDTH-1:0] current_state;
reg [`STATE_WIDTH-1:0] next_state;



/********************************************************************/
/************************FSM Next State Transition*******************/
/*******************************************************************/
always@(posedge CLK)
	begin
		if(s_RST)
			begin
				current_state<=`state_IDLE;
			end
		else
			begin
				current_state<=next_state;
			end
	end
	






 	
/********************************************************************/
/**********FSM Output and Next state Calculation (melee machine)***********/
/*******************************************************************/
always@(*)
	begin	
		
		//Newly made
		//GP counter signals
		GP_Load=0;
		GP_Cup=0;
		GP_Count_Active=0;
		
		GP_Counter_Initial=0;
		GP_Counter_Final=REST_COUNTS_VALUE;
		//Quantizer
		Activate_Quantizer=0;
		Activate_Phase_Calc=0;
		
				
		
		Active_Phase_Sample=0;
	
		
		Out_Strobe=0;
		Providing_Long=0;
		Providing_Stream=0;
		
		case(current_state)
			`state_IDLE: begin
							if(short_preamble_found)
								begin
								//Controlling GP Counter
									GP_Load=1;
									GP_Counter_Initial=0;
									GP_Counter_Final=REST_COUNTS_VALUE;
									
									next_state=`state_SAMPLE_PHASE;
								end
							else
								begin
									next_state=`state_IDLE;
								end
						end
			
			`state_SAMPLE_PHASE: begin
								//Used now as the resting counter
								GP_Count_Active=1;
								GP_Cup=1;
								
								
								
								if(in_phase_strobe)
									begin
										next_state=`state_RESTING;
										
										Active_Phase_Sample=1;
									end
								else
									begin
										next_state=`state_SAMPLE_PHASE;
										
									end
								end
								
									
			`state_RESTING: begin
							if(GP_Done) //GP Counter is Free Now after Resting, See what are u going to use it again
								begin
									Activate_Quantizer=1; //Pass the Quantizer input strobe signal to the correlator
									Activate_Phase_Calc=1;
									next_state=`state_CORRELATING;
									
									//All Controls of GP Counter
									GP_Load=1;
									GP_Cup=0;
									GP_Count_Active=0;
		
									GP_Counter_Initial=0;
									GP_Counter_Final=CORRELATION_PERIOD;
								end
							else
								begin
									GP_Count_Active=1;
									GP_Cup=1;
									
									next_state=`state_RESTING;
								end
						end
						
			`state_CORRELATING: begin
									Activate_Quantizer=1;
									Activate_Phase_Calc=1;
									GP_Cup=1;
									GP_Count_Active=1;
									
									if(GP_Done) //GP Counter is now Done(After Counting the sweep window), Look what to do with it
										begin
											//using GP here to calculate the remaining samples to output the Long 
											//Opt Value Depends manily on where u are considereing to fall
											//GP_Counter_Initial=(128-Max_Found_Index); //128 is 64*2, where 64 is the shift length,Assuming fall at begining of CP of Long
											GP_Counter_Initial=(POSTION_OF_TARGETTED_CORRELATION_WINDOW<<1)-Max_Found_Index +1'b1; 											
											GP_Counter_Final=POSITION_OF_SECOND_LONG; //The start position of second Long Training (it starts at 97(if 1 indexing):Therefore u put the position (indexed by 1) -1
											GP_Load=1;
											GP_Count_Active=0;
											
											//next_state = `state_POS_DECISION; I DIDNOT DEFINE THIS STATE, WHYYYYYYY
											next_state = `state_WAIT_FOR_SECOND_TRAIN;
										end
										
									else
										begin
											
											next_state=`state_CORRELATING;
										end
								end		
			`state_WAIT_FOR_SECOND_TRAIN: begin
										//added 12:16am , 03/05/2024
										Activate_Phase_Calc=1;
										
										if(GP_Done) //GP is Done
											begin
												next_state=`state_PROVIDING_LONG;
												
												Out_Strobe=in_corrected_ph_strobe;
												
												//Used now to determine if we are outputting the long
												GP_Counter_Initial=0;  
												GP_Counter_Final=64; 
												GP_Load=1;
												GP_Count_Active=0;
											end
										else
											begin
												next_state=`state_WAIT_FOR_SECOND_TRAIN;
												GP_Count_Active=1;
												GP_Cup=1;
											end
										end
			`state_PROVIDING_LONG: begin
									Activate_Phase_Calc=1;
									Out_Strobe=in_corrected_ph_strobe;
									
									GP_Count_Active=1;
									GP_Cup=1;
									
									if(GP_Done)
										begin
											next_state=`state_WAITING_CP;
											
											//Added for CP
											GP_Count_Active=0;
											GP_Counter_Initial=0;
											GP_Counter_Final=16;
											GP_Cup=0;
											GP_Load=1;
										end
									else
										begin
											Providing_Long=1;
											next_state=`state_PROVIDING_LONG;
										end
									end
						
						
			`state_WAITING_CP: 	
								begin
									Activate_Phase_Calc=1;
									
									
									if(GP_Done)
										begin
											
											next_state=`state_PROVIDING_STREAM;
											
											GP_Count_Active=0;
											GP_Counter_Initial=0;
											GP_Counter_Final=64;
											GP_Cup=0;
											GP_Load=1;
										end
										
									else
										begin
											GP_Cup=1;
											GP_Count_Active=1;
											
											next_state=`state_WAITING_CP;
										end
									end
									
			`state_PROVIDING_STREAM: begin
									Activate_Phase_Calc=1;
									
									if(GP_Done)
										begin
											next_state=`state_WAITING_CP;
											
											GP_Count_Active=0;
											GP_Counter_Initial=0;
											GP_Counter_Final=16;
											GP_Cup=0;
											GP_Load=1;
										end
									else
										begin
									//Old
									Activate_Phase_Calc=1;
									Out_Strobe=in_corrected_ph_strobe;
									Providing_Stream=1;
									
									GP_Cup=1;
									GP_Count_Active=1;
										end
									end
			default: begin
						next_state=`state_IDLE;
					end
					
		endcase
			
	end
		
	endmodule
				