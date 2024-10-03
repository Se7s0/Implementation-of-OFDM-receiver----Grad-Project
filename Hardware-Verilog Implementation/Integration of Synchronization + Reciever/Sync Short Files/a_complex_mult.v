module a_complex_mult 
#(parameter
    I_Q_Width           = 16
  )
  
  (	input CLK,s_RST,
	input signed [I_Q_Width-1:0] a_i,a_q,b_i,b_q, //i: in-phase, q:quadratue 
	input input_strobe,
	
	output signed [2*I_Q_Width-1:0] p_i,p_q, //there is no carry bit guard here
	
	output reg output_strobe
	);
  

  
  
  reg signed [2*I_Q_Width:0] res_1,res_2;
  
  wire signed [2*I_Q_Width:0] common_term;
  wire signed [2*I_Q_Width:0] term_i_2;
  wire signed [2*I_Q_Width:0] term_q_2;
  
  assign common_term = a_i*(b_i+b_q);
  assign term_i_2 = -b_q*(a_i+a_q);
  assign term_q_2 = b_i*(a_q - a_i);
  
  //Takes the MSB of Carry
  //For now assume not looking at overflow
  assign p_i=res_1[2*I_Q_Width-1:0];
  assign p_q=res_2[2*I_Q_Width-1:0];
	
  always@(posedge CLK)
  begin
	if(s_RST)
		begin
			//no need to reset the p_i and p_q
			output_strobe<=0;
		end
		
	else
		begin
			if(input_strobe)
				begin
					res_1 <= common_term + term_i_2;
					res_2 <=	common_term + term_q_2;
					
					//No overflow
					//p_i <= common_term - b_q*(a_i+a_q);
					//p_q <=	common_term + b_i*(a_q - a_i);
					output_strobe <=1;
				end
			else
				begin
					output_strobe<=0;
				end
		end
		
	end
	
	
endmodule