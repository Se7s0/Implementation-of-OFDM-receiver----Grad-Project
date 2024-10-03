module a_delay_sample 
#(parameter
		delay_LENGTH = 16,
		I_Q_Width=16,
		Init_Strobe_Vector=0,
		delay_STROBE_WIDTH=delay_LENGTH
	)
		
	(	input CLK,s_RST,
	input signed [I_Q_Width-1:0] a_i,a_q, //i: in-phase, q:quadratue 
	
	input enable,		//enable is being used as a reset when Low !!!!!!!!!!!!!!!!!!
	input input_strobe,

	output  signed [I_Q_Width-1:0] a_i_de,a_q_de, 
	
	//output reg output_strobe,
	output output_Valid
	);
	
	reg [delay_STROBE_WIDTH-1:0] Valid_Sig_Barrel;
	reg [I_Q_Width-1:0] a_i_Barrel [delay_LENGTH-1:0];
	reg	[I_Q_Width-1:0]	a_q_Barrel [delay_LENGTH-1:0];
	
	
	//Barrel ends
	assign output_Valid = input_strobe&Valid_Sig_Barrel[0];
	assign a_i_de = a_i_Barrel[0];
	assign a_q_de = a_q_Barrel[0];
	
	
	integer i;
	
	always@(posedge CLK)
		begin
			if(s_RST)
				begin
					Valid_Sig_Barrel<=Init_Strobe_Vector;
					
					for(i=0;i<delay_LENGTH;i=i+1)
						begin
							a_i_Barrel [i] <= 0;
							a_q_Barrel [i] <= 0;
							
						 
							end
							
				end
			else if(enable)
				begin
					if(input_strobe)
						begin
						
						Valid_Sig_Barrel<={input_strobe,Valid_Sig_Barrel[delay_STROBE_WIDTH-1:1]};
					
						for(i=0;i<delay_LENGTH-1;i=i+1)
							begin
							
								a_i_Barrel [i] <= a_i_Barrel[i+1];
								a_q_Barrel [i] <= a_q_Barrel[i+1];
								 
							end
								a_i_Barrel [delay_LENGTH-1] <= a_i;
								a_q_Barrel [delay_LENGTH-1] <= a_q;
						end
						
						else
							begin //strobe is low
							//Valid_Sig_Barrel<={1'b0,Valid_Sig_Barrel[delay_LENGTH-1:1]};
							end
				end
				
			else
			
				begin
				
				Valid_Sig_Barrel<=Init_Strobe_Vector;
				for(i=0;i<delay_LENGTH;i=i+1)
							begin
							
								a_i_Barrel [i] <= 0;
								a_q_Barrel [i] <= 0;
								 
							end
					
					
				end
		end

endmodule
		
		