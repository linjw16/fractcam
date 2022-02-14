/*
 * Created on Sat Jan 08 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	fractcam_top.v
 * @Author:		Jiawei Lin
 * @Last edit:	21:12:32
 */

// Language: Verilog 2001

`resetall
`timescale 1ns / 1ps
`default_nettype none

module fractcam_top #(
	parameter TCAM_DEPTH = 1024,
	parameter TCAM_WIDTH = 160
) (
	input  wire clk,
	input  wire rst,

	input  wire [TCAM_WIDTH-1:0] 		search_key,
	input  wire [TCAM_WIDTH*8-1:0] 		wr_tcam_data,
	input  wire [TCAM_WIDTH*8-1:0] 		wr_tcam_keep,
	input  wire [SLICEM_ADDR_WIDTH-1:0] wr_enable_sel,
	input  wire 						wr_enable,
	output wire 						wr_busy,
	output wire [TCAM_DEPTH-1:0] 		match
);

localparam SLICEM_ROWS=TCAM_DEPTH/8;
localparam SLICEM_ADDR_ENABLE = $clog2(SLICEM_ROWS);
localparam SLICEM_ADDR_WIDTH = SLICEM_ADDR_ENABLE ? SLICEM_ADDR_ENABLE : 1;
localparam WR_DATA_WIDTH=TCAM_WIDTH*8/5;

(*max_fanout=50*) wire [WR_DATA_WIDTH-1:0] wr_data_in ;
(*max_fanout=50*) wire [TCAM_WIDTH-1:0] wr_addr;
(*max_fanout=50*) wire [SLICEM_ROWS-1:0] wr_enable_oh;

(* dont_touch = "true" *)
update_logic # (
	.DEBUG_WIDTH		(DEBUG_WIDTH),
	.TCAM_DEPTH			(TCAM_DEPTH),
	.TCAM_WIDTH			(TCAM_WIDTH),
	.SLICEM_ADDR_WIDTH	(SLICEM_ADDR_WIDTH)
) update_inst (
	.clk				(clk),
	.rst				(rst),
	.debug				(debug),
	.search_key			(search_key),
	.wr_tcam_data		(wr_tcam_data),
	.wr_tcam_keep		(wr_tcam_keep),
	.wr_enable			(wr_enable),
	.wr_enable_sel		(wr_enable_sel),
	.wr_data_in			(wr_data_in),
	.wr_addr			(wr_addr),
	.wr_enable_oh		(wr_enable_oh),
	.wr_busy			(wr_busy)
);

localparam DEBUG_WIDTH = 16;
wire [DEBUG_WIDTH-1:0] debug;
// reg  [DEBUG_WIDTH-1:0] debug_reg = {DEBUG_WIDTH{1'b0}}, debug_next;
// always @(*) begin
// 	debug_next <= debug;
// end
// always @(posedge(clk)) begin
// 	debug_reg <= debug_next;
// end

(* dont_touch = "true" *)
fractcam #(
	.DEBUG_WIDTH		(DEBUG_WIDTH),
	.TCAM_WIDTH			(TCAM_WIDTH),
	.TCAM_DEPTH			(TCAM_DEPTH)
) fractcam_inst (
	.clk				(clk),
	.rst				(rst),
	// .debug				(debug),
	.search_key			(wr_addr),
	.wr_enable			(wr_enable_oh),
	.rules				(wr_data_in),
	.match				(match)
);

endmodule

`resetall