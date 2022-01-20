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

module SRLC32E # (
	parameter INIT = 32'h0000_0000
) (
	output wire Q,					// SRL data output
	output wire Q31,				// SRL cascade output pin
	input  wire [4:0] A,			// 5-bit shift depth select input
	input  wire CE,					// Clock enable input
	input  wire CLK,				// Clock input
	input  wire D					// SRL data input
);

reg [31:0] Q_reg = INIT, Q_next;
assign Q = Q_reg[A];
assign Q31 = Q_reg[31];

always @(*) begin
	Q_next = {Q_reg[30:0], D};
end

always @(CLK) begin
	if (CE) begin
		Q_reg <= Q_next;
	end
end

endmodule

`resetall