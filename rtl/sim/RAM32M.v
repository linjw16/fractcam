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

module RAM32M # (
	parameter INIT_A = 64'h0000_0000_0000_0000,
	parameter INIT_B = 64'h0000_0000_0000_0000,
	parameter INIT_C = 64'h0000_0000_0000_0000,
	parameter INIT_D = 64'h0000_0000_0000_0000
) (
	output wire [1:0] DOA,
	output wire [1:0] DOB,
	output wire [1:0] DOC,
	output wire [1:0] DOD,
	input  wire [4:0] ADDRA,
	input  wire [4:0] ADDRB,
	input  wire [4:0] ADDRC,
	input  wire [4:0] ADDRD,
	input  wire [1:0] DIA,
	input  wire [1:0] DIB,
	input  wire [1:0] DIC,
	input  wire [1:0] DID,
	input  wire WCLK,
	input  wire WE
);

reg [31:0] LUT5_A_H_reg = INIT_A >> 32, LUT5_A_H_next;
reg [31:0] LUT5_A_L_reg = INIT_A, LUT5_A_L_next;
reg [31:0] LUT5_B_H_reg = INIT_B >> 32, LUT5_B_H_next;
reg [31:0] LUT5_B_L_reg = INIT_B, LUT5_B_L_next;
reg [31:0] LUT5_C_H_reg = INIT_C >> 32, LUT5_C_H_next;
reg [31:0] LUT5_C_L_reg = INIT_C, LUT5_C_L_next;
reg [31:0] LUT5_D_H_reg = INIT_D >> 32, LUT5_D_H_next;
reg [31:0] LUT5_D_L_reg = INIT_D, LUT5_D_L_next;

assign DOA = {LUT5_A_H_reg[ADDRA],LUT5_A_L_reg[ADDRA]};
assign DOB = {LUT5_B_H_reg[ADDRB],LUT5_B_L_reg[ADDRB]};
assign DOC = {LUT5_C_H_reg[ADDRC],LUT5_C_L_reg[ADDRC]};
assign DOD = {LUT5_D_H_reg[ADDRD],LUT5_D_L_reg[ADDRD]};

always @(*) begin
	LUT5_A_H_next = LUT5_A_H_reg;
	LUT5_A_L_next = LUT5_A_L_reg;
	LUT5_B_H_next = LUT5_B_H_reg;
	LUT5_B_L_next = LUT5_B_L_reg;
	LUT5_C_H_next = LUT5_C_H_reg;
	LUT5_C_L_next = LUT5_C_L_reg;
	LUT5_D_H_next = LUT5_D_H_reg;
	LUT5_D_L_next = LUT5_D_L_reg;
	if (WE) begin
		LUT5_A_H_next[ADDRD] = DIA[1];
		LUT5_A_L_next[ADDRD] = DIA[0];
		LUT5_B_H_next[ADDRD] = DIB[1];
		LUT5_B_L_next[ADDRD] = DIB[0];
		LUT5_C_H_next[ADDRD] = DIC[1];
		LUT5_C_L_next[ADDRD] = DIC[0];
		LUT5_D_H_next[ADDRD] = DID[1];
		LUT5_D_L_next[ADDRD] = DID[0];
	end
end

always @(posedge(WCLK)) begin	
	LUT5_A_H_reg <= LUT5_A_H_next;
	LUT5_A_L_reg <= LUT5_A_L_next;
	LUT5_B_H_reg <= LUT5_B_H_next;
	LUT5_B_L_reg <= LUT5_B_L_next;
	LUT5_C_H_reg <= LUT5_C_H_next;
	LUT5_C_L_reg <= LUT5_C_L_next;
	LUT5_D_H_reg <= LUT5_D_H_next;
	LUT5_D_L_reg <= LUT5_D_L_next;
end

endmodule

`resetall