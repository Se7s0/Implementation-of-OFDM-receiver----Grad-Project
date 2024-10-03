module SYN_RESETTER #(parameter NO_OF_FRAME_IN_PAK=4,parameter COUNT_WIDTH=3)
	(input CLK,s_RST,
	input Providing_Stream,
	input input_strobe,
	
	output s_RST_RESETTER_OUT
	);
	
	
	reg Cnt_Reset;
	reg [COUNT_WIDTH-1:0] Counter;
	
	assign s_RST_RESETTER_OUT = Cnt_Reset | s_RST;
	
	reg current_state;
	reg next_state;
	
	reg Raise_Count;
	
	`define state_WAIT 0
	`define state_ALT 1
	
	always@(posedge CLK)
		begin
			if(s_RST)
				begin
					current_state<=`state_WAIT;
				end
			else
				begin
					current_state<=next_state;
				end
		end
		
	always@(*)
		begin
			case(current_state)
			
			`state_WAIT: begin
							if(input_strobe & Providing_Stream)
								begin
									next_state=`state_ALT;
									Raise_Count=0;
								end
							else
								begin
									next_state=`state_WAIT;
									Raise_Count=0;
								end
						end
						
			`state_ALT: begin
							if(!Providing_Stream)
								begin
									next_state=`state_WAIT;
									Raise_Count=1;
								end
							else
								begin
									next_state=`state_ALT;
									Raise_Count=0;
								end
						end
			default: begin
					next_state=`state_WAIT;
					Raise_Count=0;
					end
			endcase
		end
			
			
	//Count and Reset controller together		
	always@(posedge CLK)
	begin
		if(s_RST)
			begin
				Counter<=0;
				Cnt_Reset<=0;
			end
		
		else if(Counter==NO_OF_FRAME_IN_PAK )
			begin
				Cnt_Reset<=1;
				Counter<=0;
			end
			
		else if(Raise_Count)
			begin
				Counter<=Counter+1;
				Cnt_Reset<=0;
			end
			
		else
			begin
				Cnt_Reset<=0;
				
			end
	end
			
			
endmodule
				