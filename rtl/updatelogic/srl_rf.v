`timescale 1ns / 1ps

module srl_rf(d,clk,ce,q);
input  wire  d;
input  wire  clk;
input  wire [7:0] ce;
//input[4:0] a;
output[7:0] q;
genvar i;
	generate
	for (i=0; i<8; i=i+1)
	begin:SRL32
	SRLC32E #(
	.INIT(32'h00000000) // Initial Value of Shift Register
	) SRLC32E_inst (
	.Q(),	// SRL data output
	.Q31(q[i]), // SRL cascade output pin
	.A(),	// 5-bit shift depth select input
	.CE(ce[i]),	// Clock enable input
	.CLK(clk), // Clock input
	.D(d)	// SRL data input
	);
	end
	endgenerate

endmodule
