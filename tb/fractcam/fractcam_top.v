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
	parameter TCAM_WIDTH = 130,
	parameter TCAM_WR_WIDTH = 128,
	parameter INIT = 64'b0
) (
	input  wire clk,
	input  wire rst,

	input  wire [TCAM_WIDTH-1:0] 		search_key,
	input  wire [TCAM_WR_WIDTH*8-1:0] 	wr_tcam_data,
	input  wire [TCAM_WR_WIDTH*8-1:0] 	wr_tcam_keep,
	input  wire [SLICEM_ADDR_WIDTH-1:0] wr_slicem_addr,
	input  wire 						wr_valid,
	output wire 						wr_ready,
	output wire [TCAM_DEPTH-1:0] 		match
);

localparam SLICEM_ROWS=TCAM_DEPTH/8;
localparam SLICEM_ADDR_WIDTH = SLICEM_ROWS>1 ? $clog2(SLICEM_ROWS) : 1;
localparam WR_DATA_WIDTH=TCAM_WIDTH*8/5;

initial begin
	if (TCAM_WR_WIDTH > TCAM_WIDTH) begin
		$error("Error: TCAM_WR_WIDTH should not be lager than TCAM_WIDTH (instance %m)");
		$finish;
	end
end

wire [TCAM_WIDTH*8-1:0] wr_tcam_data_pad, wr_tcam_keep_pad;

genvar i;
generate
	for (i=0; i<8; i=i+1) begin
		assign wr_tcam_data_pad[i*TCAM_WIDTH +: TCAM_WIDTH] = {
			{TCAM_WIDTH-TCAM_WR_WIDTH{1'b0}}, 
			wr_tcam_data[i*TCAM_WR_WIDTH +: TCAM_WR_WIDTH]
		};
		assign wr_tcam_keep_pad[i*TCAM_WIDTH +: TCAM_WIDTH] = {
			{TCAM_WIDTH-TCAM_WR_WIDTH{1'b1}}, 
			wr_tcam_keep[i*TCAM_WR_WIDTH +: TCAM_WR_WIDTH]
		};
	end
endgenerate

(*max_fanout=50*) wire [WR_DATA_WIDTH-1:0] wr_data_in ;
(*max_fanout=50*) wire [TCAM_WIDTH-1:0] wr_addr;
(*max_fanout=50*) wire [SLICEM_ROWS-1:0] wr_enable_oh;

/* (* dont_touch = "true" *) */
update_logic # (
	.TCAM_DEPTH			(TCAM_DEPTH),
	.TCAM_WIDTH			(TCAM_WIDTH),
	.SLICEM_ADDR_WIDTH	(SLICEM_ADDR_WIDTH)
) update_inst (
	.clk				(clk),
	.rst				(rst),
	.search_key			(search_key),
	.wr_tcam_data		(wr_tcam_data_pad),
	.wr_tcam_keep		(wr_tcam_keep_pad),
	.wr_valid			(wr_valid),
	.wr_enable_sel		(wr_slicem_addr),
	.wr_data_in			(wr_data_in),
	.wr_addr			(wr_addr),
	.wr_enable_oh		(wr_enable_oh),
	.wr_ready			(wr_ready)
);

/* (* dont_touch = "true" *) */
fractcam #(
	.TCAM_WIDTH			(TCAM_WIDTH),
	.TCAM_DEPTH			(TCAM_DEPTH),
	.INIT				(INIT)
) fractcam_inst (
	.clk				(clk),
	.rst				(rst),
	.search_key			(wr_addr),
	.wr_enable			(wr_enable_oh),
	.rules				(wr_data_in),
	.match				(match)
);

endmodule

`resetall