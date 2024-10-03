module Mults_Weights_Drive (output [31:0] I_W , output [31:0] Q_W);

assign I_W[1:0] =  	2'b01	;
assign I_W[3:2] =   2'b01   ;
assign I_W[5:4] =   2'b11   ;
assign I_W[7:6] =   2'b11   ;
assign I_W[9:8] =   2'b01   ;
assign I_W[11:10] = 2'b01   ;
assign I_W[13:12] = 2'b11   ;
assign I_W[15:14] = 2'b11   ;
assign I_W[17:16] = 2'b11   ;
assign I_W[19:18] = 2'b11   ;
assign I_W[21:20] =  2'b11   ;
assign I_W[23:22] =  2'b01   ;
assign I_W[25:24] =  2'b11   ;
assign I_W[27:26] =  2'b11   ;
assign I_W[29:28] =  2'b01   ;
assign I_W[31:30] =  2'b01   ;


assign Q_W[1:0] = 2'b11  ;
assign Q_W[3:2] = 2'b01  ;
assign Q_W[5:4] = 2'b01  ;
assign Q_W[7:6] = 2'b01  ;
assign Q_W[9:8] = 2'b01  ;
assign Q_W[11:10]=2'b01  ;
assign Q_W[13:12]=2'b01  ;
assign Q_W[15:14]=2'b11  ;
assign Q_W[17:16]=2'b11  ;
assign Q_W[19:18]=2'b11  ;
assign Q_W[21:20]=  2'b11  ;
assign Q_W[23:22]=  2'b11  ;
assign Q_W[25:24]=  2'b01  ;
assign Q_W[27:26]=  2'b01  ;
assign Q_W[29:28]=  2'b01  ;
assign Q_W[31:30]=  2'b01  ;


endmodule