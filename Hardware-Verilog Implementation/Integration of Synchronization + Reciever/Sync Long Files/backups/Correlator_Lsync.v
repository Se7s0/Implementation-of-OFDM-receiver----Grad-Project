module Correlator_Lsync(
input CLK,s_RST,

input signed [1:0] I_in_Quant,
input signed [1:0] Q_in_Quant,
input enable,

input input_strobe,
output output_strobe,
//use straighforward implementation for n<10 of complex multipliers

//If pipelining, adjust the output strobe to be synced with the pipeline 
output reg signed [6:0] I_corr_Out, //max I is 32 , -18
output reg signed [6:0] Q_corr_Out //Max Q is 16, -12

);
wire [31:0] I_W;
wire [31:0] Q_W;

Mults_Weights_Drive  Mults_Weights_Drive_Inst(.I_W(I_W),.Q_W(Q_W));

parameter delay_LENGTH=16; //some lines that need it are readjusted, fix them to reuse this parameter correctly and control the block behavoiur 

	reg [16-1:0] Valid_Sig_Barrel;
	reg signed [1:0] I_Barrel [delay_LENGTH-1:0];
	reg	signed [1:0]	Q_Barrel [delay_LENGTH-1:0];

	assign output_strobe = input_strobe&Valid_Sig_Barrel[0];
	
	//Array variables
	wire signed [2:0] I_Mult_Out [15:0]; //on matlab, it appeared that max is 2 and min is -2 (f3lan)
	wire signed [2:0] Q_Mult_Out [15:0];
	
	//used for Barrel
	integer i;
	
	always@(posedge CLK)
		begin
			if(s_RST)
				begin
					Valid_Sig_Barrel<=0;
					
					for(i=0;i<delay_LENGTH;i=i+1)
						begin
							I_Barrel [i] <= 0;
							Q_Barrel [i] <= 0;
							
						 
							end
							
				end
				
			else if(input_strobe)
						begin
						
						Valid_Sig_Barrel<={input_strobe,Valid_Sig_Barrel[16-1:1]};
					
						for(i=0;i<16-1;i=i+1)
							begin
							
								I_Barrel [i] <= I_Barrel[i+1];
								Q_Barrel [i] <= Q_Barrel[i+1];
								 
							end
								I_Barrel [16-1] <= I_in_Quant;
								Q_Barrel [16-1] <= Q_in_Quant;
						end
						
			else
				begin //strobe is low
					//Valid_Sig_Barrel<={1'b0,Valid_Sig_Barrel[delay_LENGTH-1:1]};
				end	
		end
		
		genvar j;
		
		generate 
			for(j=0;j<16;j=j+1)
				begin
					Two_Bit_Com_Mult Gen_0 (.I_in_A(I_Barrel[j]),
					.Q_in_A(-Q_Barrel[j]),
					.I_in_B({I_W[2*j+1],I_W[2*j]}),// needs to be filled by matlab
					//.I_in_B(2'b01),
					.Q_in_B(Q_W[2*j+1:2*j]),
					.I_Out(I_Mult_Out[j]),
					.Q_Out(Q_Mult_Out[j])
					);
			end
			endgenerate
			
	always@(*)
		begin
			I_corr_Out = I_Mult_Out[0] + I_Mult_Out[1] + I_Mult_Out[2] + I_Mult_Out[3] +
             I_Mult_Out[4] + I_Mult_Out[5] + I_Mult_Out[6] + I_Mult_Out[7] +
             I_Mult_Out[8] + I_Mult_Out[9] + I_Mult_Out[10] + I_Mult_Out[11] +
             I_Mult_Out[12] + I_Mult_Out[13] + I_Mult_Out[14] + I_Mult_Out[15];

			Q_corr_Out = Q_Mult_Out[0] + Q_Mult_Out[1] + Q_Mult_Out[2] + Q_Mult_Out[3] +
             Q_Mult_Out[4] + Q_Mult_Out[5] + Q_Mult_Out[6] + Q_Mult_Out[7] +
             Q_Mult_Out[8] + Q_Mult_Out[9] + Q_Mult_Out[10] + Q_Mult_Out[11] +
             Q_Mult_Out[12] + Q_Mult_Out[13] + Q_Mult_Out[14] + Q_Mult_Out[15];
		
		end
		
endmodule