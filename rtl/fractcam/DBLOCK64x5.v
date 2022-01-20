`timescale 1ns / 1ps

module DBLOCK64x5 #(parameter kw_size=5,D=64)(sk,clr,we,rules,clk,match);

parameter m=D/32;
parameter rd_size=32;	// DBLOCK rule depth size
parameter we_size=4;

input  wire [kw_size-1:0] sk;
input  wire clr;
input  wire [D/8-1:0] we;
input  wire [7:0] rules;
input  wire clk;
output [D-1:0] match;

//genvar i;
//generate
//	for (i=0;i<n;i=i+1)
//		begin: depth_extension
//		DBLOCK #(kw_size,rd_size) DBLOCK_inst(sk[i*5+4:i*5],we,ce,clr,rule,clk,match);
//	end
//endgenerate
genvar i;
generate
for (i=0;i<m;i=i+1)
begin:depth_extension
DBLOCK32X5 #(kw_size,rd_size,we_size) DBLOCK32x5_inst0(sk,clr,we[i*4+3:i*4],rules,clk,match[i*32+31:i*32]);
end
endgenerate

endmodule