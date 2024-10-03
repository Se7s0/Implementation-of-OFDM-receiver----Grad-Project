module Find_Max #(parameter GP_COUNTER_WIDTH=8)(
input CLK,s_RST,

input  [11:0] Mag_Val,
input input_strobe,
input [GP_COUNTER_WIDTH-1:0] in_Counter_Val,
input enable,

output reg [GP_COUNTER_WIDTH-1:0] Index,
output reg output_strobe
);


reg [11:0] Stored_Mag;


always@(posedge CLK)
	begin
		if(s_RST)
			begin
				Index<=0;
				Stored_Mag<=0;
				output_strobe<=0;
			end
			
		else if(enable)
			if(input_strobe)
				begin
					output_strobe<=1;
					if(Mag_Val>Stored_Mag)
						begin
							Stored_Mag<=Mag_Val;
							Index<=in_Counter_Val;
						end
						
					else //Do not store the value because it is not larger than the stroed
						begin
						
						end
				end
				
			else //input_strobe is low and enable is high
				begin
					output_strobe<=0;
				end
				
		else //enable is low, here used as reset to the internal regs
			begin
				output_strobe<=0;
				Index<=0;
				Stored_Mag<=0;
			end
	end
	
endmodule