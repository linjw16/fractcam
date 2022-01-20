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

module FDRE # (
	parameter INIT = 1'b0	// Initial value of register (1'b0 or 1'b1)
) (
	output wire Q,			// 1-bit Data output
	input  wire C,			// 1-bit Clock input
	input  wire CE,			// 1-bit Clock enable input
	input  wire R,			// 1-bit Synchronous reset input
	input  wire D			// 1-bit Data input
);

reg Q_reg = INIT, Q_next;
assign Q = Q_reg;

always @(*) begin
	Q_next = Q_reg;
	if (CE) begin
		Q_next = D;
	end
end

always @(posedge C) begin
	if (R) begin
		Q_reg <= 1'b0;
	end
	Q_reg <= Q_next;
end

endmodule

`resetall