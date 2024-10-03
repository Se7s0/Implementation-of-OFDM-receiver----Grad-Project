module ClkDiv (
		input i_ref_clk,i_rst_n,
		input i_clk_en,
		input [5:0] i_div_ratio, //was 3
		
		output reg o_div_clk
		);
		
	
	wire CLK_DIV_EN;
	wire [4:0] counter_ceil;
	reg [4:0] counter_value;
	reg delay_cycle;
	reg o_div_clk_internal;
	reg pass_same_clk_seq;
	
	assign CLK_DIV_EN = i_clk_en && (i_div_ratio != 0) && ( i_div_ratio != 1);
	
	assign counter_ceil=i_div_ratio[5:1] -1;
	
	assign number_is_odd = i_div_ratio[0] ;
	
	//assign pass_same_clk_comb = i_clk_en && !CLK_DIV_EN; //it will output same clk when div is 1 or 0
	
	assign pass_same_clk_comb = (i_clk_en) && (i_div_ratio == 1); //it will output zero when input is zero
	
	always@(posedge i_ref_clk,negedge i_rst_n)
		begin
			if(!i_rst_n)
				pass_same_clk_seq<=0;
			else
			pass_same_clk_seq<=pass_same_clk_comb;
		end
		
	//2x1 mux on output
	always@(*)
		begin
			if(pass_same_clk_seq) //output the same input clock if div is zero or one
				begin
					o_div_clk=i_ref_clk;
				end
			else
				begin
					o_div_clk=o_div_clk_internal;
				end
		end
	
	always@(posedge i_ref_clk,negedge i_rst_n)
		begin
			if(!i_rst_n)
				begin
					counter_value<=0;
				end
				
			else if (CLK_DIV_EN)
				begin
					if(counter_value==0 && o_div_clk_internal==0 && delay_cycle==1 && number_is_odd)
						begin
							counter_value<=counter_value;
						end
					else if(counter_value==counter_ceil)
						begin
							counter_value<=0;
						end
					else
						begin
							counter_value<=counter_value+1;
						end
				end
				
			else //Not enabled
				begin
					counter_value<=0;
				end
		end
		
		
	always@(posedge i_ref_clk,negedge i_rst_n)
		begin
			if(!i_rst_n)
				begin
					o_div_clk_internal<=0;
				end
		
			else if (CLK_DIV_EN)
				begin
					/*
					if(o_div_clk_internal==0 && delay_cycle==0 && number_is_odd)
						begin
							o_div_clk_internal<=!o_div_clk_internal;
							delay_cycle<=1;
						end
						*/
					if(counter_value==0)
						begin
							if(o_div_clk_internal==0 && delay_cycle==1 && number_is_odd)
								begin
									o_div_clk_internal<= 0;
									delay_cycle<=0;
								end
							else if(o_div_clk_internal==1 && number_is_odd)
								begin
									o_div_clk_internal<=!o_div_clk_internal;
									delay_cycle<=1;
								end
							else
								begin
									o_div_clk_internal<=!o_div_clk_internal;
									//Stick to delay
								end
									
							end
						end
				
			
			else // !CLK_DIV_EN ==0
				begin
					o_div_clk_internal<= 0;
					delay_cycle<=0;
				end
		end
	
endmodule
			
					
					
				