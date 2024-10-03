//----------------------------------------------------------------------
//  Twiddle: 64-Point Twiddle Table for Radix-2^2 Butterfly
//----------------------------------------------------------------------
module Twiddle #(
    parameter   TW_FF = 1   //  Use Output Register
)(
    input           clock,  //  Master Clock
    input   [5:0]   addr,   //  Twiddle Factor Number
    output  [15:0]  tw_re,  //  Twiddle Factor (Real)
    output  [15:0]  tw_im   //  Twiddle Factor (Imag)
);

wire[15:0]  wn_re[0:63];    //  Twiddle Table (Real)
wire[15:0]  wn_im[0:63];    //  Twiddle Table (Imag)
wire[15:0]  mx_re;          //  Multiplexer output (Real)
wire[15:0]  mx_im;          //  Multiplexer output (Imag)
reg [15:0]  ff_re;          //  Register output (Real)
reg [15:0]  ff_im;          //  Register output (Imag)

assign  mx_re = wn_re[addr];
assign  mx_im = wn_im[addr];

always @(posedge clock) begin
    ff_re <= mx_re;
    ff_im <= mx_im;
end

assign  tw_re = TW_FF ? ff_re : mx_re;
assign  tw_im = TW_FF ? ff_im : mx_im;

//----------------------------------------------------------------------
//  Twiddle Factor Value
//----------------------------------------------------------------------
//  Multiplication is bypassed when twiddle address is 0.
//  Setting wn_re[0] = 0 and wn_im[0] = 0 makes it easier to check the waveform.
//  It may also reduce power consumption slightly.
//
//      wn_re = cos(-2pi*n/64)          wn_im = sin(-2pi*n/64)

assign  wn_re[ 0] = 16'b0000001000000000;
assign  wn_re[ 1] = 16'b0000000111111101;
assign  wn_re[ 2] = 16'b0000000111110110;
assign  wn_re[ 3] = 16'b0000000111101001;
assign  wn_re[ 4] = 16'b0000000111011001;
assign  wn_re[ 5] = 16'b0000000111000011;
assign  wn_re[ 6] = 16'b0000000110101001;
assign  wn_re[ 7] = 16'b0000000110001011;
assign  wn_re[ 8] = 16'b0000000101101010;
assign  wn_re[ 9] = 16'b0000000101000100;
assign  wn_re[10] = 16'b0000000100011100;
assign  wn_re[11] = 16'b0000000011110001;
assign  wn_re[12] = 16'b0000000011000011;
assign  wn_re[13] = 16'b0000000010010100;
assign  wn_re[14] = 16'b0000000001100011;
assign  wn_re[15] = 16'b0000000000110010;
assign  wn_re[16] = 16'b0000000000000000;
assign  wn_re[17] = 16'b1111111111001101;
assign  wn_re[18] = 16'b1111111110011100;
assign  wn_re[19] = 16'b1111111101101011;
assign  wn_re[20] = 16'b1111111100111100;
assign  wn_re[21] = 16'b1111111100001110;
assign  wn_re[22] = 16'b1111111011100011;
assign  wn_re[23] = 16'b1111111010111011;
assign  wn_re[24] = 16'b1111111010010101;
assign  wn_re[25] = 16'b1111111001110100;
assign  wn_re[26] = 16'b1111111001010110;
assign  wn_re[27] = 16'b1111111000111100;
assign  wn_re[28] = 16'b1111111000100110;
assign  wn_re[29] = 16'b1111111000010110;
assign  wn_re[30] = 16'b1111111000001001;
assign  wn_re[31] = 16'b1111111000000010;
assign  wn_re[32] = 16'b1111111000000000;
assign  wn_re[33] = 16'b1111111000000010;
assign  wn_re[34] = 16'b1111111000001001;
assign  wn_re[35] = 16'b1111111000010110;
assign  wn_re[36] = 16'b1111111000100110;
assign  wn_re[37] = 16'b1111111000111100;
assign  wn_re[38] = 16'b1111111001010110;
assign  wn_re[39] = 16'b1111111001110100;
assign  wn_re[40] = 16'b1111111010010101;
assign  wn_re[41] = 16'b1111111010111011;
assign  wn_re[42] = 16'b1111111011100011;
assign  wn_re[43] = 16'b1111111100001110;
assign  wn_re[44] = 16'b1111111100111100;
assign  wn_re[45] = 16'b1111111101101011;
assign  wn_re[46] = 16'b1111111110011100;
assign  wn_re[47] = 16'b1111111111001101;
assign  wn_re[48] = 16'b1111111111111111;
assign  wn_re[49] = 16'b0000000000110010;
assign  wn_re[50] = 16'b0000000001100011;
assign  wn_re[51] = 16'b0000000010010100;
assign  wn_re[52] = 16'b0000000011000011;
assign  wn_re[53] = 16'b0000000011110001;
assign  wn_re[54] = 16'b0000000100011100;
assign  wn_re[55] = 16'b0000000101000100;
assign  wn_re[56] = 16'b0000000101101010;
assign  wn_re[57] = 16'b0000000110001011;
assign  wn_re[58] = 16'b0000000110101001;
assign  wn_re[59] = 16'b0000000111000011;
assign  wn_re[60] = 16'b0000000111011001;
assign  wn_re[61] = 16'b0000000111101001;
assign  wn_re[62] = 16'b0000000111110110;
assign  wn_re[63] = 16'b0000000111111101;


assign  wn_im[ 0] = 16'b0000000000000000;
assign  wn_im[ 1] = 16'b1111111111001101;
assign  wn_im[ 2] = 16'b1111111110011100;
assign  wn_im[ 3] = 16'b1111111101101011;
assign  wn_im[ 4] = 16'b1111111100111100;
assign  wn_im[ 5] = 16'b1111111100001110;
assign  wn_im[ 6] = 16'b1111111011100011;
assign  wn_im[ 7] = 16'b1111111010111011;
assign  wn_im[ 8] = 16'b1111111010010101;
assign  wn_im[ 9] = 16'b1111111001110100;
assign  wn_im[10] = 16'b1111111001010110;
assign  wn_im[11] = 16'b1111111000111100;
assign  wn_im[12] = 16'b1111111000100110;
assign  wn_im[13] = 16'b1111111000010110;
assign  wn_im[14] = 16'b1111111000001001;
assign  wn_im[15] = 16'b1111111000000010;
assign  wn_im[16] = 16'b1111111000000000;
assign  wn_im[17] = 16'b1111111000000010;
assign  wn_im[18] = 16'b1111111000001001;
assign  wn_im[19] = 16'b1111111000010110;
assign  wn_im[20] = 16'b1111111000100110;
assign  wn_im[21] = 16'b1111111000111100;
assign  wn_im[22] = 16'b1111111001010110;
assign  wn_im[23] = 16'b1111111001110100;
assign  wn_im[24] = 16'b1111111010010101;
assign  wn_im[25] = 16'b1111111010111011;
assign  wn_im[26] = 16'b1111111011100011;
assign  wn_im[27] = 16'b1111111100001110;
assign  wn_im[28] = 16'b1111111100111100;
assign  wn_im[29] = 16'b1111111101101011;
assign  wn_im[30] = 16'b1111111110011100;
assign  wn_im[31] = 16'b1111111111001101;
assign  wn_im[32] = 16'b1111111111111111;
assign  wn_im[33] = 16'b0000000000110010;
assign  wn_im[34] = 16'b0000000001100011;
assign  wn_im[35] = 16'b0000000010010100;
assign  wn_im[36] = 16'b0000000011000011;
assign  wn_im[37] = 16'b0000000011110001;
assign  wn_im[38] = 16'b0000000100011100;
assign  wn_im[39] = 16'b0000000101000100;
assign  wn_im[40] = 16'b0000000101101010;
assign  wn_im[41] = 16'b0000000110001011;
assign  wn_im[42] = 16'b0000000110101001;
assign  wn_im[43] = 16'b0000000111000011;
assign  wn_im[44] = 16'b0000000111011001;
assign  wn_im[45] = 16'b0000000111101001;
assign  wn_im[46] = 16'b0000000111110110;
assign  wn_im[47] = 16'b0000000111111101;
assign  wn_im[48] = 16'b0000001000000000;
assign  wn_im[49] = 16'b0000000111111101;
assign  wn_im[50] = 16'b0000000111110110;
assign  wn_im[51] = 16'b0000000111101001;
assign  wn_im[52] = 16'b0000000111011001;
assign  wn_im[53] = 16'b0000000111000011;
assign  wn_im[54] = 16'b0000000110101001;
assign  wn_im[55] = 16'b0000000110001011;
assign  wn_im[56] = 16'b0000000101101010;
assign  wn_im[57] = 16'b0000000101000100;
assign  wn_im[58] = 16'b0000000100011100;
assign  wn_im[59] = 16'b0000000011110001;
assign  wn_im[60] = 16'b0000000011000011;
assign  wn_im[61] = 16'b0000000010010100;
assign  wn_im[62] = 16'b0000000001100011;
assign  wn_im[63] = 16'b0000000000110010;

endmodule
