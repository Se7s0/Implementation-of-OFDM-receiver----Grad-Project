//----------------------------------------------------------------------
//  Butterfly: Add/Sub and Scaling
//----------------------------------------------------------------------
module Butterfly #(
    parameter   WIDTH = 16,
    parameter   RH = 0  //  Round Half Up
)(
    input   signed  [WIDTH-1:0] x0_re,  //  Input Data #0 (Real)
    input   signed  [WIDTH-1:0] x0_im,  //  Input Data #0 (Imag)
    input   signed  [WIDTH-1:0] x1_re,  //  Input Data #1 (Real)
    input   signed  [WIDTH-1:0] x1_im,  //  Input Data #1 (Imag)
    output  signed  [WIDTH-1:0] y0_re,  //  Output Data #0 (Real)
    output  signed  [WIDTH-1:0] y0_im,  //  Output Data #0 (Imag)
    output  signed  [WIDTH-1:0] y1_re,  //  Output Data #1 (Real)
    output  signed  [WIDTH-1:0] y1_im   //  Output Data #1 (Imag)
);

//  Add/Sub
assign  y0_re = x0_re + x1_re;
assign  y0_im = x0_im + x1_im;
assign  y1_re = x0_re - x1_re;
assign  y1_im = x0_im - x1_im;



endmodule
