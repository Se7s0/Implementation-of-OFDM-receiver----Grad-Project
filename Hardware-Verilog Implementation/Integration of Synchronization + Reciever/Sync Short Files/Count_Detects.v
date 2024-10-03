module Count_Detects
#(parameter
		Counts = 15,
		Counter_Width=4
	)
	
	(
input CLK,
input s_RST,
input In_Pak_Strobe,
input In_Pack_det,
input enable, //low Clears

output reg Out_Det, //rises and falls with strobes only
output reg Out_Strobe
);

reg [Counter_Width-1:0] Counter_Reg;

always@(posedge CLK)
	begin
		if(s_RST)
			begin
				Counter_Reg<=0;
				Out_Det<=0;
				Out_Strobe<=0;
			end
			
		else if(enable)
			begin
				if(In_Pak_Strobe) //Strobe Came
					begin
						Out_Strobe<=1; //Strobe In to Strobe Out
						
						if(Counter_Reg == Counts) //Stuck here till Cleared by Enable
							begin
								Out_Det<=1;
								
							end
						else if(In_Pack_det)
							begin
								Counter_Reg<=Counter_Reg+1;
							end
						else //No match
							begin
								Counter_Reg<=0;
							end
							
					end
				else //in pak strobe low
					begin
						Out_Strobe<=0;
					end
			end
		else //enable is low
			begin
				Counter_Reg<=0;
				Out_Det<=0;
				Out_Strobe<=0;
			end
			
	end
	
endmodule
				
					
				
					