module Twiddle #(
    parameter   TW_FF = 1   //  Use Output Register
)(
    input           clock,  //  Master Clock
    input   [5.0:0]   addr,   //  Twiddle Factor Number
    output  [10:0]  tw_re,  //  Twiddle Factor (Real)
    output  [10:0]  tw_im   //  Twiddle Factor (Imag)
);

wire[10:0]  wn_re[0:63];   //  Twiddle Table (Real)
wire[10:0]  wn_im[0:63];   //  Twiddle Table (Imag)
wire[10:0]  mx_re;          //  Multiplexer output (Real)
wire[10:0]  mx_im;          //  Multiplexer output (Imag)
reg [10:0]  ff_re;          //  Register output (Real)
reg [10:0]  ff_im;          //  Register output (Imag)

assign  mx_re = wn_re[addr];
assign  mx_im = wn_im[addr];

always @(posedge clock) begin
    ff_re <= mx_re;
    ff_im <= mx_im;
end

assign  tw_re = TW_FF ? ff_re : mx_re;
assign  tw_im = TW_FF ? ff_im : mx_im;assign wn_re[0] = 10'b01111111111; assign wn_im[0] = 10'b00000000000; 
assign wn_re[1] = 10'b01111111111; assign wn_im[1] = 10'b11110011010; 
assign wn_re[2] = 10'b01111111111; assign wn_im[2] = 10'b11100110100; 
assign wn_re[3] = 10'b01111001100; assign wn_im[3] = 10'b11011001101; 
assign wn_re[4] = 10'b01110011001; assign wn_im[4] = 10'b11001100111; 
assign wn_re[5] = 10'b01110011001; assign wn_im[5] = 10'b11000110100; 
assign wn_re[6] = 10'b01101100110; assign wn_im[6] = 10'b10111001101; 
assign wn_re[7] = 10'b01100000000; assign wn_im[7] = 10'b10101100111; 
assign wn_re[8] = 10'b01011001100; assign wn_im[8] = 10'b10100110100; 
assign wn_re[9] = 10'b01010011001; assign wn_im[9] = 10'b10100000000; 
assign wn_re[10] = 10'b01000110011; assign wn_im[10] = 10'b10010011010; 
assign wn_re[11] = 10'b00111001100; assign wn_im[11] = 10'b10001100111; 
assign wn_re[12] = 10'b00110011001; assign wn_im[12] = 10'b10001100111; 
assign wn_re[13] = 10'b00100110011; assign wn_im[13] = 10'b10000110100; 
assign wn_re[14] = 10'b00011001100; assign wn_im[14] = 10'b10000000000; 
assign wn_re[15] = 10'b00001100110; assign wn_im[15] = 10'b10000000000; 
assign wn_re[16] = 10'b00000000000; assign wn_im[16] = 10'b10000000000; 
assign wn_re[17] = 10'b11110011010; assign wn_im[17] = 10'b10000000000; 
assign wn_re[18] = 10'b11100110100; assign wn_im[18] = 10'b10000000000; 
assign wn_re[19] = 10'b11011001101; assign wn_im[19] = 10'b10000110100; 
assign wn_re[20] = 10'b11001100111; assign wn_im[20] = 10'b10001100111; 
assign wn_re[21] = 10'b11000110100; assign wn_im[21] = 10'b10001100111; 
assign wn_re[22] = 10'b10111001101; assign wn_im[22] = 10'b10010011010; 
assign wn_re[23] = 10'b10101100111; assign wn_im[23] = 10'b10100000000; 
assign wn_re[24] = 10'b10100110100; assign wn_im[24] = 10'b10100110100; 
assign wn_re[25] = 10'b10100000000; assign wn_im[25] = 10'b10101100111; 
assign wn_re[26] = 10'b10010011010; assign wn_im[26] = 10'b10111001101; 
assign wn_re[27] = 10'b10001100111; assign wn_im[27] = 10'b11000110100; 
assign wn_re[28] = 10'b10001100111; assign wn_im[28] = 10'b11001100111; 
assign wn_re[29] = 10'b10000110100; assign wn_im[29] = 10'b11011001101; 
assign wn_re[30] = 10'b10000000000; assign wn_im[30] = 10'b11100110100; 
assign wn_re[31] = 10'b10000000000; assign wn_im[31] = 10'b11110011010; 
assign wn_re[32] = 10'b10000000000; assign wn_im[32] = 10'b00000000000; 
assign wn_re[33] = 10'b10000000000; assign wn_im[33] = 10'b00001100110; 
assign wn_re[34] = 10'b10000000000; assign wn_im[34] = 10'b00011001100; 
assign wn_re[35] = 10'b10000110100; assign wn_im[35] = 10'b00100110011; 
assign wn_re[36] = 10'b10001100111; assign wn_im[36] = 10'b00110011001; 
assign wn_re[37] = 10'b10001100111; assign wn_im[37] = 10'b00111001100; 
assign wn_re[38] = 10'b10010011010; assign wn_im[38] = 10'b01000110011; 
assign wn_re[39] = 10'b10100000000; assign wn_im[39] = 10'b01010011001; 
assign wn_re[40] = 10'b10100110100; assign wn_im[40] = 10'b01011001100; 
assign wn_re[41] = 10'b10101100111; assign wn_im[41] = 10'b01100000000; 
assign wn_re[42] = 10'b10111001101; assign wn_im[42] = 10'b01101100110; 
assign wn_re[43] = 10'b11000110100; assign wn_im[43] = 10'b01110011001; 
assign wn_re[44] = 10'b11001100111; assign wn_im[44] = 10'b01110011001; 
assign wn_re[45] = 10'b11011001101; assign wn_im[45] = 10'b01111001100; 
assign wn_re[46] = 10'b11100110100; assign wn_im[46] = 10'b01111111111; 
assign wn_re[47] = 10'b11110011010; assign wn_im[47] = 10'b01111111111; 
assign wn_re[48] = 10'b00000000000; assign wn_im[48] = 10'b01111111111; 
assign wn_re[49] = 10'b00001100110; assign wn_im[49] = 10'b01111111111; 
assign wn_re[50] = 10'b00011001100; assign wn_im[50] = 10'b01111111111; 
assign wn_re[51] = 10'b00100110011; assign wn_im[51] = 10'b01111001100; 
assign wn_re[52] = 10'b00110011001; assign wn_im[52] = 10'b01110011001; 
assign wn_re[53] = 10'b00111001100; assign wn_im[53] = 10'b01110011001; 
assign wn_re[54] = 10'b01000110011; assign wn_im[54] = 10'b01101100110; 
assign wn_re[55] = 10'b01010011001; assign wn_im[55] = 10'b01100000000; 
assign wn_re[56] = 10'b01011001100; assign wn_im[56] = 10'b01011001100; 
assign wn_re[57] = 10'b01100000000; assign wn_im[57] = 10'b01010011001; 
assign wn_re[58] = 10'b01101100110; assign wn_im[58] = 10'b01000110011; 
assign wn_re[59] = 10'b01110011001; assign wn_im[59] = 10'b00111001100; 
assign wn_re[60] = 10'b01110011001; assign wn_im[60] = 10'b00110011001; 
assign wn_re[61] = 10'b01111001100; assign wn_im[61] = 10'b00100110011; 
assign wn_re[62] = 10'b01111111111; assign wn_im[62] = 10'b00011001100; 
assign wn_re[63] = 10'b01111111111; assign wn_im[63] = 10'b00001100110; 
endmodule
