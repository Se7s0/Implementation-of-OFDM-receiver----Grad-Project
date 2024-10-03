module Phase_Adder_and_Reg(
input CLK,s_RST,

input sample,

input signed [31:0] Phase_t_sample,
input Input_Strobe,

output reg signed [31:0] Phase_Out
);

//`define pi 32'b00110010010000111111011010101000

reg signed [31:0] Store_Reg;

//Defining value of pi
wire signed [31:0] pi_valu;

assign pi_valu= 32'b00110010010000111111011010101000;

wire signed [31:0] Angle_To_Be;

assign Angle_To_Be=Phase_Out-Store_Reg;

always@(posedge CLK)
	begin
	
	if(s_RST)
		begin
			Store_Reg<=0;
			Phase_Out<=0;
		end
		
	else if(sample)
		begin
			Store_Reg<=(Phase_t_sample>>>4); //divide by 16 because this is shortpreamble
		end
		
	else if(Input_Strobe)
		begin
		/*
			if(Store_Reg[31]==0) //angle is positive, accumlation of it in negative
			begin
				if(Phase_Out < (~(pi_valu) + 1'b1))
					begin
						Phase_Out<= Phase_Out + (pi_valu<<<1); //2 *pi
					end
				else
					begin
						Phase_Out<=Phase_Out-Store_Reg;
					end
					
			else //angle is negative
				begin
					if(Phase_Out> pi_valu)
					begin
						Phase_Out<= Phase_Out - (pi_valu<<<1); //2 *pi
					end
				else
					begin
						Phase_Out<=Phase_Out - Store_Reg;
					end
					*/
					if(Angle_To_Be < -pi_valu) //is phase out less than negative pi?
						begin
							Phase_Out<= Angle_To_Be + (pi_valu<<<1); //2 *pi
						end
					else if (Angle_To_Be> pi_valu)
						begin
							Phase_Out<= Angle_To_Be - (pi_valu<<<1); //2 *pi
						end
					else
						begin
							Phase_Out<=Angle_To_Be;
						end
		end
	end
	
	
	endmodule