module cmult #(

	parameter radix = 4,
	parameter N = 64,     			//number of inputs
	parameter stage = 0,        	//stage number

	parameter Q_int = 7, //s+6	  			//input size
	parameter Q_dec = 9,				//decimal binary size
	parameter Q = Q_dec + Q_int,
	parameter W = Q				//twiddle size

)(

	input clk, rst_n, data_en, reff,
	input signed [Q-1 : 0] ar, ai,
	input signed [Q-1 : 0] br, bi,
	output signed [Q-1 : 0] pr, pi,
	output data_en_dd,

	input signed [Q-1 : 0] pi_r, pi_i   //remove


);
	reg ref_sig;
	
	reg signed [Q-1 : 0] ai_d, ai_dd, ai_ddd, ai_dddd ;
	reg signed [Q-1 : 0] ar_d, ar_dd, ar_ddd, ar_dddd ;
	reg signed [Q-1 : 0] bi_d, bi_dd, bi_ddd, br_d, br_dd, br_ddd ;
	reg signed [Q : 0] addcommon ;
	reg signed [Q : 0] addr, addi ;
	reg signed [Q+Q : 0] mult0, multr, multi, pr_int, pi_int ;
	reg signed [Q+Q : 0] common, commonr1, commonr2 ;

	wire signed [Q-1 : 0] br_del, bi_del;
	wire data_en_d;

	delay_n #(.D(7))  u0(clk, rst_n, data_en, data_en_dd);
	delay 			  u1(clk, rst_n, data_en, data_en_d);
	delay_w #(.D(16)) u2(clk, rst_n, br, br_del);
	delay_w #(.D(16)) u3(clk, rst_n, bi, bi_del);


always @(posedge clk) begin

	if (data_en_d) begin

		ar_d <= ar;
		ar_dd <= ar_d;
		ai_d <= -ai;  //conjugate
		ai_dd <= ai_d;
		br_d <= br_del;
		br_dd <= br_d;
		br_ddd <= br_dd;
		bi_d <= bi_del;
		bi_dd <= bi_d;
		bi_ddd <= bi_dd;
		
		if (reff) begin
			
			br_d <= br_del;
			bi_d <= bi_del;

		end

		else begin
			
			br_d <= -br_del;
			bi_d <= -bi_del;

		end

	end

	else begin
		
		ar_dd <= ar_d;
		ai_dd <= ai_d;
		br_dd <= br_d;
		br_ddd <= br_dd;
		bi_dd <= bi_d;
		bi_ddd <= bi_dd;

	end

end

// Common factor (ar ai) x bi, shared for the calculations of the real and imaginary final products
//
always @(posedge clk) begin


		addcommon <= ar_d - ai_d;
		mult0 <= addcommon * bi_dd;
		common <= mult0;

end

// Real product
//
always @(posedge clk) begin


		ar_ddd <= ar_dd;
		ar_dddd <= ar_ddd;
		addr <= br_ddd - bi_ddd;
		multr <= addr * ar_dddd;
		commonr1 <= common;
		pr_int <= multr + commonr1;


end

// Imaginary product
//
always @(posedge clk) begin


		ai_ddd <= ai_dd;
		ai_dddd <= ai_ddd;
		addi <= br_ddd + bi_ddd;
		multi <= addi * ai_dddd;
		commonr2 <= common;
		pi_int <= multi + commonr2;


end

assign pr = pr_int >> Q_dec;
assign pi = pi_int >> Q_dec;

endmodule // cmult