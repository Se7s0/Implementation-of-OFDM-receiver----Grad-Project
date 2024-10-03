module Lsync_Mag_Sq(

input CLK,s_RST,
input signed [5:0] I_in_A,
input signed [5:0] Q_in_A,
input input_strobe,


output reg [10:0] I_Out, // max value is 32^2 + 16^2
output reg output_strobe
);


always@(posedge CLK)
	begin
		if(s_RST)
			begin
				I_Out<=0;
				output_strobe<=0;
			end
			
		else if(input_strobe)
				begin
					I_Out <=  (I_in_A*I_in_A) + (Q_in_A* Q_in_A);
					output_strobe<=1;
				end
		else
			begin
				output_strobe<=0;
			end
	end
			
		
endmodule