/*
 * Created on Fri Jan 14 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	LUT6.v
 * @Author:		Jiawei Lin
 * @Last edit:	10:13:18
 */

`resetall
`timescale 1ns / 1ps
`default_nettype none

module LUT6 # (
	parameter INIT = 64'h0000_0000_0000_0000	// Specify LUT Contents
) (
	output wire O,
	input  wire I0,
	input  wire I1,
	input  wire I2,
	input  wire I3,
	input  wire I4,
	input  wire I5
);

reg [63:0] LUT6 = INIT;
// assign O = LUT6[{I0, I1, I2, I3, I4, I5}];
assign O = LUT6[{I5, I4, I3, I2, I1, I0}];

endmodule

`resetall