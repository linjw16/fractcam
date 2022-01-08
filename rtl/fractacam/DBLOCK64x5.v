`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2019 08:46:34 PM
// Design Name: 
// Module Name: DBLOCK_W
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DBLOCK64x5 #(parameter kw_size=5,D=64)(sk,clr,we,rules,clk,match);

parameter m=D/32;
parameter rd_size=32;   // DBLOCK rule depth size
parameter we_size=4;

input [kw_size-1:0] sk;
input clr;
input [D/8-1:0] we;
input [7:0] rules;
input clk;
output [D-1:0] match;

//genvar i;
//generate
//    for (i=0;i<n;i=i+1)
//        begin: depth_extension
//        DBLOCK #(kw_size,rd_size) DBLOCK_inst(sk[i*5+4:i*5],we,ce,clr,rule,clk,match);
//    end
//endgenerate
genvar i;
generate
for (i=0;i<m;i=i+1)
begin:depth_extension
DBLOCK32X5 #(kw_size,rd_size,we_size) DBLOCK32x5_inst0(sk,clr,we[i*4+3:i*4],rules,clk,match[i*32+31:i*32]);
end
endgenerate

endmodule