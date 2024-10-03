//----------------------------------------------------------------------
//  FFT: 64-Point FFT Using Radix-2^2 Single-Path Delay Feedback
//----------------------------------------------------------------------
module FFT #(
    parameter   WIDTH = 16
)(
    input               clock,  //  Master Clock
    input               reset,  //  Active High Asynchronous Reset
    input               di_en,  //  Input Data Enable
    input   [WIDTH-1:0] di_re,  //  Input Data (Real)
    input   [WIDTH-1:0] di_im,  //  Input Data (Imag)
    input               lts_in,
    output              do_en, //high if we output a frame
    output              lts_out,
    output  [5:0]       counter,  //  Output Data Enable
    output              mem1_we,
    output              mem2_we,
    output  [WIDTH-1:0] out_r,  //  Output Data (Real)
    output  [WIDTH-1:0] out_i   //  Output Data (Imag)
);
//----------------------------------------------------------------------
//  Data must be input consecutively in natural order.
//  The result is scaled to 1/N and output in bit-reversed order.
//  The output latency is 71 clock cycles.
//----------------------------------------------------------------------

wire            su1_do_en;
wire[WIDTH-1:0] su1_do_re;
wire[WIDTH-1:0] su1_do_im;
wire            su2_do_en;
wire[WIDTH-1:0] su2_do_re;
wire[WIDTH-1:0] su2_do_im;
wire[5:0]       addr;

wire[WIDTH-1:0] data_r_mem1, data_r_mem2, data_i_mem1, data_i_mem2, do_re, do_im;


delay_n dn0(
    .clk    (clock),
    .rst_n  (reset),
    .d      (lts_in),
    .out_bit(lts_out)
);

SdfUnit #(.N(64),.M(64),.WIDTH(WIDTH)) SU1 (
    .clock  (clock      ),  //  i
    .reset  (reset      ),  //  i
    .di_en  (di_en      ),  //  i
    .di_re  (di_re      ),  //  i
    .di_im  (di_im      ),  //  i
    .do_en  (su1_do_en  ),  //  o
    .do_re  (su1_do_re  ),  //  o
    .do_im  (su1_do_im  )   //  o
);

SdfUnit #(.N(64),.M(16),.WIDTH(WIDTH)) SU2 (
    .clock  (clock      ),  //  i
    .reset  (reset      ),  //  i
    .di_en  (su1_do_en  ),  //  i
    .di_re  (su1_do_re  ),  //  i
    .di_im  (su1_do_im  ),  //  i
    .do_en  (su2_do_en  ),  //  o
    .do_re  (su2_do_re  ),  //  o
    .do_im  (su2_do_im  )   //  o
);

SdfUnit #(.N(64),.M(4),.WIDTH(WIDTH)) SU3 (
    .clock  (clock      ),  //  i
    .reset  (reset      ),  //  i
    .di_en  (su2_do_en  ),  //  i
    .di_re  (su2_do_re  ),  //  i
    .di_im  (su2_do_im  ),  //  i
    .do_en  (do_en      ),  //  o
    .do_re  (do_re      ),  //  o
    .do_im  (do_im      )   //  o
);

address_gen address_gen(
    .clk  (clock),
    .rst_n(reset),
    .en   (do_en),
    .addr (addr),
    .mem1_we(mem1_we),
    .mem2_we(mem2_we),
    .counter(counter)
); 

mem1 memory_1(
    .clk   (clock),
    .rst_n (reset),
    .we    (mem1_we),
    .addra  (addr),
    .addrb  (counter),
    .data_r(do_re),
    .data_i(do_im),
    .tmp_data_r(data_r_mem1),
    .tmp_data_i(data_i_mem1)
);

mem2 memory_2(
    .clk   (clock),
    .rst_n (reset),
    .we    (mem2_we),
    .addra  (addr),
    .addrb  (counter),
    .data_r(do_re),
    .data_i(do_im),
    .tmp_data_r(data_r_mem2),
    .tmp_data_i(data_i_mem2)
);

out_mux mux0(

    .reset(reset),
    .clk  (clock),
    .sel  (mem1_we),
    .mem1_r(data_r_mem1),
    .mem1_i(data_i_mem1),
    .mem2_r(data_r_mem2),
    .mem2_i(data_i_mem2),
    .out_r (out_r),
    .out_i (out_i)

);


endmodule
