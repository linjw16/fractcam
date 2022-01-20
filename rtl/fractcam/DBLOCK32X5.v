`timescale 1ns / 1ps

module DBLOCK32X5 #(parameter kw_size=5, rd_size=32,we_size=1)(
	input wire [kw_size-1:0] sk,
	input wire clr,
	input wire [we_size-1:0] we,
	input wire [7:0] rules,
	input wire wclk,
	output [rd_size-1:0] match
	);

genvar i;
	generate
	for (i=0; i<rd_size/8; i=i+1)
	begin:fracTCAM32x5
	fractcam8x5 fractcam8x5_inst (
	.sk(sk),
	.clr(clr),
	.we(we[i]),
	.rules(rules),
	.wclk(wclk),
	.match(match[((i+1)*8-1):8*i])
	);
	end
	endgenerate
endmodule
