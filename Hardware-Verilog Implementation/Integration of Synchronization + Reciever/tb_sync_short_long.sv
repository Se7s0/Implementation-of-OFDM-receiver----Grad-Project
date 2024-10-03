module tb_sync_short_long();

    // Clock and reset signals
    reg CLK_tb=0;
    reg CLK_Slow_tb;
    reg s_RST_All_tb;
    reg enable_All_tb;

    // Input signals
    reg signed [15:0] I_main_tb, Q_main_tb;
    reg In_main_Strobe_tb;

    // Output signals
    wire output_strobe_tb;

    wire Data_valid;
    wire signed [15:0] I_out_tb;
    wire signed [15:0] Q_out_tb;

    // Clock divider inputs
    reg i_rst_n_tb;
    
	//My integers
	integer Current_Input = 0;

    // Instantiate the ClkDiv module
    ClkDiv clk_div_inst (
        .i_ref_clk(CLK_tb),
        .i_rst_n(i_rst_n_tb),
        .i_clk_en(1'b1),
        .i_div_ratio(6'd30),
        .o_div_clk(CLK_Slow_tb)
    );

    // Instantiate the SYNC_SHORT_LONG module
    SYNC_SHORT_LONG uut (
        .CLK(CLK_tb),
        .CLK_slow (CLK_Slow_tb),
        .s_RST(!s_RST_All_tb),
        .enable(enable_All_tb),
        .I_main(I_main_tb),
        .Q_main(Q_main_tb),
        .In_main_Strobe(In_main_Strobe_tb),

        .output_strobe(output_strobe_tb),

        .data_en_dd      (Data_valid),
        .I_out(I_out_tb),
        .Q_out(Q_out_tb)
    );

    // Generate the main clock
    always #10 CLK_tb = ~CLK_tb;

  

    // Input and output file handling
    integer input_file, output_file;
    integer scan_result;

    // Testbench logic
        integer i, j;

    initial begin
        // Initialize signals
        j=0;
        s_RST_All_tb = 0;
        enable_All_tb = 0;
        I_main_tb = 0;
        Q_main_tb = 0;
        In_main_Strobe_tb = 0;
        i_rst_n_tb = 0;
     

        // Open files
        input_file = $fopen("input_data_p11.txt", "r");
        output_file = $fopen("C:/Users/Moham/Downloads/Digital_comm_2/Digital_comm_2/complex.txt", "w");

        // Release reset and enable
        #(30*30);
        s_RST_All_tb = 1;
        enable_All_tb = 1;
        i_rst_n_tb = 1;
         

        // Apply inputs on positive edge of slow clock
        while (!$feof(input_file)) begin
			@(posedge CLK_Slow_tb);
			In_main_Strobe_tb=1;
            scan_result = $fscanf(input_file, "%d %d\n", I_main_tb, Q_main_tb);
			//I_main_tb=I_main_tb>>>1;
			//Q_main_tb=Q_main_tb>>>1;
			Current_Input=Current_Input+1;
			
            
			@(negedge CLK_tb);
			@(posedge CLK_tb);
			#2;
			In_main_Strobe_tb=0;
        end

        

        // End simulation after some time
        #200;
        $fclose(output_file);
        $stop;
    end

	// Capture outputs on positive edge of output_strobe
        always @(posedge output_strobe_tb) begin
            $fwrite(output_file, "%0d+%0dj\n", I_out_tb, Q_out_tb);
        end

    // reg [15:0]  memo_r[48*4-1:0];
    // reg [15:0]  memo_i[48*4-1:0];

    // reg [1:0] demod_data [48*4-1 : 0];

    // always @(posedge CLK_Slow_tb) begin
    
    //     if (Data_valid) begin
            
    //         memo_r[j] = I_out_tb;
    //         memo_i[j] = Q_out_tb;
            
    //         case ({I_out_tb[15], Q_out_tb[15]})

    //             2'd0: demod_data[j] = 2'd3;

    //             2'd1: demod_data[j] = 2'd1;
                
    //             2'd2: demod_data[j] = 2'd2;

    //             2'd3: demod_data[j] = 2'd0;

    //         endcase

    //         j=j+1;

    //         if (j == 192) begin
    //             $stop;
    //         end


    //     end

    // end


endmodule
