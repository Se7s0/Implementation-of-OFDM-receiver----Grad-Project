module a_complex_to_mag(

input CLK,s_RST,
input input_strobe,
input signed [31:0] i,q,

output reg mag_stb,
output reg [31:0] mag
);

//internal register
reg [1:0] counter;

reg [31:0] abs_i,abs_q;
reg [31:0] max,min;

always@(posedge CLK)
	begin
		if(s_RST)
		begin
			counter<=2'b00;
		end
	else
		case (counter)
		
		2'b00:	if(input_strobe==1)
				counter<=counter+1;
				
		2'b10:	counter<=0;
		
		default:	counter<=counter+1;
		
		endcase
end		
		
		
always@(posedge CLK)
begin
	if(s_RST)
		begin
			// i didn't reset some regs as they will be filled with values before being valid at output
			mag_stb<=0;
		end
	else
		begin
			mag_stb<=0;
			
			if(input_strobe==1 && counter==0) //fiRST cycle
				begin
					if(i[31] ==1)
						abs_i<=~i+1'b1;
					else
						abs_i<=i;
					
					if(q[31]==1)
						abs_q<=~q+1'b1;
					else
						abs_q<=q;
				end
				
			if(counter==2'b01) //second cycle (note, we can reduce regs by writing in same place)
				begin
					if(abs_i>abs_q)
						begin
						max <= abs_i;
						min<=abs_q;
						end
					else
						begin
						max<=abs_q;
						min<=abs_i;
						end
				end
				
			if(counter==2'b10) //third cycle
				begin
					mag<= max+ (min>>2);
					mag_stb<=1;
				end	
				
		end
		
end

endmodule