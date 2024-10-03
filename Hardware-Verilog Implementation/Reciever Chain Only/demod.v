module demod (

	input clk,    // Clock
	input rst,  // Asynchronous reset active low
	input signed [16-1 : 0] I_out, Q_out,
	input data_valid,

	output reg [1:0] sym,
	output data_valid_d

	
);

	delay u1(clk, rst, data_valid, data_valid_d);


    always @(posedge clk or posedge rst) begin

    	if (rst) sym <= 0;    	
    
        else if (data_valid) begin

            case ({I_out[15], Q_out[15]})

                2'd0: sym <= 2'd3;

                2'd1: sym <= 2'd1;
                
                2'd2: sym <= 2'd2;

                2'd3: sym <= 2'd0;

            endcase

        end

    end

endmodule : demod