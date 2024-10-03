//----------------------------------------------------------------------
//  Multiply: Complex Multiplier
//----------------------------------------------------------------------
module Multiply #(
    parameter   WIDTH = 16
)(
    input   signed  [WIDTH-1:0] a_re,
    input   signed  [WIDTH-1:0] a_im,
    input   signed  [WIDTH-1:0] b_re,
    input   signed  [WIDTH-1:0] b_im,
    output  signed  [WIDTH-1:0] sc_m_re,
    output  signed  [WIDTH-1:0] sc_m_im
);

wire signed [WIDTH*2-1:0]   arbr, arbi, aibr, aibi, m_re, m_im;

//  Signed Multiplication
assign  arbr = a_re * b_re;
assign  arbi = a_re * b_im;
assign  aibr = a_im * b_re;
assign  aibi = a_im * b_im;

//  Sub/Add
//  These sub/add may overflow if unnormalized data is input.
assign  m_re = arbr - aibi;
assign  m_im = arbi + aibr;

//  Scaling
assign  sc_m_re = m_re >> 9;
assign  sc_m_im = m_im >> 9;

endmodule
