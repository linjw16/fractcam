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
	input  wire [SLICEM_ADDR_WIDTH-1:0] wr_en_sel,
	input  wire 						wr_en,
	output wire [TCAM_DEPTH-1:0] 		match_line,
	output wire 						match
);

localparam SLICEM_ROWS=TCAM_DEPTH/8;
localparam SLICEM_ADDR_WIDTH = $clog2(SLICEM_ROWS);
localparam WR_DATA_WIDTH=TCAM_WIDTH*8/5;

(*max_fanout=50*) wire [WR_DATA_WIDTH-1:0] wr_data_in ;
(*max_fanout=50*) wire [TCAM_WIDTH-1:0] wr_addr;
(*max_fanout=50*) wire [SLICEM_ROWS-1:0] wr_en_oh;

(* dont_touch = "true" *)
update_logic # (
	.D(TCAM_DEPTH),
	.W(TCAM_WIDTH),
	.SN(SLICEM_ADDR_WIDTH)
) update_inst (
	.sk(search_key),
	.wclk(clk),
	.reset(rst),
	.wr(wr_en),
	.we_sel(wr_en_sel),
	.DI(wr_data_in),
	.addr(wr_addr),
	.we(wr_en_oh)
);

(* dont_touch = "true" *)
frac_tcam #(
	.TCAM_WIDTH(TCAM_WIDTH),
	.TCAM_DEPTH(TCAM_DEPTH)
) frac_tcam_inst (
	.sk(wr_addr),
	.reset(rst),
	.we(wr_en_oh),
	.rules(wr_data_in),
	.clk(clk),
	.match(match_line)
);

assign match = |match_line;

endmodule

`resetall