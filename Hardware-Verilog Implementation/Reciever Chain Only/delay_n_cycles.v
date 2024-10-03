module delay_n_cycles #(

  parameter D = 16,
  parameter N = 64

)(

  input clk,
  input rst,
  input [D-1 : 0] d,

  output reg [D-1 : 0] out
);
  
  delay_n #(.D(N))  u0(clk, rst_n, d[0], out[0]);
  delay_n #(.D(N))  u1(clk, rst_n, d[1], out[1]);
  delay_n #(.D(N))  u2(clk, rst_n, d[2], out[2]);
  delay_n #(.D(N))  u3(clk, rst_n, d[3], out[3]);
  delay_n #(.D(N))  u4(clk, rst_n, d[4], out[4]);
  delay_n #(.D(N))  u5(clk, rst_n, d[5], out[5]);
  delay_n #(.D(N))  u6(clk, rst_n, d[6], out[6]);
  delay_n #(.D(N))  u7(clk, rst_n, d[7], out[7]);
  delay_n #(.D(N))  u8(clk, rst_n, d[8], out[8]);
  delay_n #(.D(N))  u9(clk, rst_n, d[9], out[9]);
  delay_n #(.D(N))  u10(clk, rst_n, d[10], out[10]);
  delay_n #(.D(N))  u11(clk, rst_n, d[11], out[11]);
  delay_n #(.D(N))  u12(clk, rst_n, d[12], out[12]);
  delay_n #(.D(N))  u13(clk, rst_n, d[13], out[13]);
  delay_n #(.D(N))  u14(clk, rst_n, d[14], out[14]);
  delay_n #(.D(N))  u15(clk, rst_n, d[15], out[15]);


endmodule
