/*
 * Created on Tue Jan 18 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	 dut.v
 * @Author:		 Jiawei Lin
 * @Last edit:	 10:15:35
 */
`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * FracTCAM with match table and output and gate. 
 */
module dut #(
	parameter WIDTH = 5,
	parameter DEPTH = 64
) (
	input  wire clk,
	input  wire rst,
	input  wire [WIDTH*DEPTH-1:0] in_1,
	output wire [DEPTH-1:0] out_1
);

and0 #(
	.WIDTH(WIDTH),
	.DEPTH(DEPTH)
) and0_inst (
	.in_1(in_1),
	.out_1(out_1)
);

endmodule

`resetall