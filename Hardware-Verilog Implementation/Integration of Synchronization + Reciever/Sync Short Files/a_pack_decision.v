module a_pack_decision(
input CLK,
input s_RST,
input unsigned [31:0] prod_avg_mag,
input unsigned [31:0] mag_sq_avg,
input prod_avg_mag_Strobe,

output reg Pack_det, //rises and falls with strobes only
output reg pak_strobe
);

//Very Accurate Impelemntation
/*
wire [33:0] seven_five_mag_sq_avg;
wire [31:0] compare_val;

assign seven_five_mag_sq_avg = (mag_sq_avg>>1) + (mag_sq_avg>>2);

assign compare_val = seven_five_mag_sq_avg[33:2];
*/

//less accurate
//this is made for comparison only
wire unsigned [31:0] compare_val;

assign compare_val = (mag_sq_avg>>1) + (mag_sq_avg>>2);



always@(posedge CLK)
begin
	if(s_RST)
		begin
			Pack_det<=0;
			pak_strobe<=0;
		end
	
	else
		begin
			if(prod_avg_mag_Strobe) //Strobe High Now
				begin
					pak_strobe<=1; //strobe in, strobe out
					if(prod_avg_mag>compare_val)
						begin
							Pack_det<=1;
						end
					else
						begin
							Pack_det<=0;
						end
				end
			else	//Strobe Down
				begin
					pak_strobe<=0;
				end
		end
		
end


endmodule
				
				
			