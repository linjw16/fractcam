/*
 * Created on Tue Jan 18 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	 andD2.v
 * @Author:		 Jiawei Lin
 * @Last edit:	 10:58:47
 */

// Language: Verilog 2001

`resetall
`timescale 1ns / 1ps
`default_nettype none

module andD2 #(
	parameter D=64
) (
	input  wire [D-1:0] a,
	input  wire [D-1:0] b,
	output [D-1:0] o
);

localparam n_andD2slice = D/4; // number of andD2 slices
genvar i;
generate
	for (i=0; i<n_andD2slice; i=i+1) begin: lp_andD2slice
		(* dont_touch = "true" *) 
		andD2slice andD2slice_init(
			a[i*4+3:i*4],
			b[i*4+3:i*4],
			o[i*4+3:i*4]
		);
	end
endgenerate

endmodule

`resetall