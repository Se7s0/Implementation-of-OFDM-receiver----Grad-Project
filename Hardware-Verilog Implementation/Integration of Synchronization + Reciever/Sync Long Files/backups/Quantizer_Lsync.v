module Quantizer_Lsync(
input signed  I_in_MSB, //Connect the MSB only
input signed  Q_in_MSB,
input input_strobe,
input Active_Quant,

output signed [1:0] I_Quant,
output signed [1:0] Q_Quant,
output output_strobe
);

assign I_Quant = (I_in_MSB==0) ? 2'b01 : 2'b11; //(1 for +ve, -ve -1 for -ve)
assign Q_Quant = (Q_in_MSB==0) ? 2'b01 : 2'b11;

assign output_strobe = Active_Quant ? input_strobe: 1'b0;

endmodule