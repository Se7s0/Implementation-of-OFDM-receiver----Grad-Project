module Load_Done_Counter 
#(parameter
		reg_WIDTH = 4
	)
	
	(	input CLK,s_RST,
	input [reg_WIDTH-1:0] Load_Inital_Value, 
	input [reg_WIDTH-1:0] Load_Final_Value,
	
	input C_up,	
	input Count,
	input Load,
	
	output Done, 
	output reg [reg_WIDTH-1:0] Internal_Counter
	);
	
	
	
	//reg [reg_WIDTH-1:0] Internal_Counter;
	reg [reg_WIDTH-1:0] Final_Value;
	
	//First implementation, i do not remember what was the intention
	//assign Done = Internal_Counter == (Final_Value-1'b1); //becuase there is a load cycle
	assign Done = Internal_Counter == Final_Value;
	
	always@(posedge CLK)
		begin
			if(s_RST)
				begin
					Internal_Counter<=0;
					Final_Value <=1;
				end
				
				
			else if(Count & !Done) //counter will stop when done
				begin
					if(C_up)
						begin
							Internal_Counter<=Internal_Counter + 1'b1;
						end
					else
						begin
							Internal_Counter<=Internal_Counter -1'b1;
						end
				end
				
			else if(Load)
				begin
					Final_Value<=Load_Final_Value;
					Internal_Counter<=Load_Inital_Value;
				end
				
			else
				begin
					//Do nothing
				end
		end
		
endmodule
			