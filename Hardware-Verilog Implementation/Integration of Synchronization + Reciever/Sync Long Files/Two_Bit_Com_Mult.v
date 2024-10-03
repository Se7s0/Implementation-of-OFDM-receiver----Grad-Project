module Two_Bit_Com_Mult(
input signed [1:0] I_in_A,
input signed [1:0] Q_in_A,

input signed [1:0] I_in_B,
input signed [1:0] Q_in_B,

//output signed [4:0] I_Out,
//output signed [4:0] Q_Out

output signed [2:0] I_Out,
output signed [2:0] Q_Out
);

//4 bits + 1 = 5 bits
assign I_Out =  (I_in_A*I_in_B) - (Q_in_A*Q_in_B);
assign Q_Out = (I_in_A*Q_in_B) + (I_in_B*Q_in_A); 

endmodule