/*
 * Created on Sun May 01 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	 frac_ctl.v
 * @Author:		 Jiawei Lin
 * @Last edit:	 23:45:55
 */

`resetall
`timescale 1ns / 1ps
`default_nettype none

module frac_ctl #(
	parameter ADDR_WIDTH = 10,
	parameter TCAM_DEPTH = 1024,
	parameter TCAM_WIDTH = 5
) (
	input  wire clk,
	input  wire rst,

	input  wire [ADDR_WIDTH-1:0]	wr_addr,	/* align to 8 */
	input  wire [DATA_WIDTH*8-1:0]	wr_data,
	input  wire [DATA_WIDTH*8-1:0]	wr_keep,
	input  wire						wr_valid,
	output wire						wr_ready,

	input  wire [ADDR_WIDTH-1:0]	rd_cmd_addr,
	input  wire						rd_cmd_valid,
	output wire						rd_cmd_ready,

	output wire [DATA_WIDTH*8-1:0]	rd_rsp_data,
	output wire [DATA_WIDTH*8-1:0]	rd_rsp_keep,
	output wire						rd_rsp_valid,
	input  wire						rd_rsp_ready,

	output wire [TCAM_WIDTH-1:0] 		search_key,
	output wire [TCAM_WIDTH*8/5-1:0] 	rules,
	output wire [TCAM_DEPTH/8-1:0] 		wr_enable_oh	
);

localparam CNT_WR_WIDTH = 5;
localparam CNT_RD_WIDTH = 9;

reg [CNT_WR_WIDTH-1:0] cnt_wr_reg = {CNT_WR_WIDTH{1'b0}}, cnt_wr_next;
reg [CNT_RD_WIDTH-1:0] cnt_rd_reg = {CNT_RD_WIDTH{1'b0}}, cnt_rd_next;
reg ready_reg = 1'b1, ready_next;
reg wr_en_reg = 1'b0, wr_en_next;
reg wr_flag_reg = 1'b0, wr_flag_next;
reg rd_flag_reg = 1'b0, rd_flag_next;

wire rd_ready;

assign rd_ready = rd_cmd_ready && wr_ready;
assign wr_ready = ready_reg;

always @(*) begin
	ready_next = ready_reg;
	// wr_enable_sel_next = wr_enable_sel_reg;
	wr_data_next = wr_data_reg;
	wr_keep_next = wr_keep_reg;
	sel_next = sel_reg;

	if(wr_valid && wr_ready) begin
		rd_flag_next = 1'b1;
		wr_flag_next = 1'b1;
		ready_next = 1'b0;
		wr_data_next = wr_tcam_data;
		wr_keep_next = wr_tcam_keep;
		// wr_enable_sel_next = wr_enable_sel;
	end

	if (rd_cmd_valid && rd_cmd_ready) begin
		rd_flag_next = 1'b1;
	end

	if(rst | wr_ready) begin
		cnt_wr_next = 0;
	end else if (cnt_wr_reg == 31) begin
		cnt_wr_next = 0;
		sel_next = sel_reg + 1'b1;
	end else begin
		cnt_wr_next = cnt_wr_reg + 1;
	end

	if(rst | wr_ready) begin
		wr_en_next = 0;
		cnt_rd_next = 0;
	end else if (cnt_rd_reg==287) begin
		wr_en_next = 0;
		cnt_rd_next = 0;
		ready_next = 1'b1;
	end else if (cnt_rd_reg>=255) begin
		wr_en_next = 1;
		cnt_rd_next = cnt_rd_reg + 1;
	end else begin
		wr_en_next = 0;
		cnt_rd_next = cnt_rd_reg + 1;
	end
end

always @(posedge clk) begin
	if (rst) begin
		cnt_wr_reg <= 1'b0;
		cnt_rd_reg <= 1'b0;
		wr_en_reg <= 1'b0;
		wr_flag_reg <= 1'b0;
		rd_flag_reg <= 1'b0;
		sel_reg <= 1'b0;
		ready_reg <= 1'b0;
		wr_enable_sel_reg <= 1'b0;
		wr_data_reg <= 1'b0;
		wr_keep_reg <= 1'b0;
	end else begin
		cnt_wr_reg <= cnt_wr_next;
		cnt_rd_reg <= cnt_rd_next;
		wr_en_reg <= wr_en_next;
		wr_flag_reg <= wr_flag_next;
		rd_flag_reg <= rd_flag_next;
		sel_reg <= sel_next;
		ready_reg <= ready_next;
		wr_enable_sel_reg <= wr_enable_sel_next;
		wr_data_reg <= wr_data_next;
		wr_keep_reg <= wr_keep_next;
	end
end

wire[7:0] srl_ce, ce_demux, wr_flag_pad;
wire [TCAM_WIDTH-1:0] wr_data_mux, wr_keep_mux;

assign wr_flag_pad = {7'b0, wr_flag_reg};
assign ce_demux = wr_flag_pad << sel_reg;
assign srl_ce = ce_demux | {8{wr_en_reg}};
assign wr_data_mux = wr_data_reg >> sel_reg*TCAM_WIDTH;
assign wr_keep_mux = wr_keep_reg >> sel_reg*TCAM_WIDTH;

genvar j;
generate
	for (i=0;i<(TCAM_WIDTH/5);i=i+1) begin : block_comparator
		wire rule_32;
		wire [4:0] xor_5;
		assign xor_5 = wr_keep_mux[5*i+:5] & (wr_data_mux[5*i+:5] ^ count);
		assign rule_32 = !(|xor_5);
		assign search_key[5*i+:5] = wr_flag_reg ? count : search_key[5*i+:5];

		for (j=0; j<8; j=j+1) begin:SRL32
			SRLC32E #(
				.INIT(32'h00000000) 
			) SRLC32E_inst (
				.Q(),	
				.Q31(rules[8*i+j]), 
				.A(),	
				.CE(srl_ce[j]),	
				.CLK(clk), 
				.D(rule_32)	
			);
		end
	end
endgenerate

wire we_block;
assign we_block = wr_en_reg;
// THIS IS WE_MUX, GENERATES WE FOR THE SLICE TO BE UPDATED
async_demux #(
	.DATA_WIDTH		(1),
	.ADDR_WIDTH		(SLICEM_ADDR_WIDTH),
	.COUNT			(TCAM_DEPTH/8)
) async_demux_wrten (
	.data_in		(we_block),
	.select			(wr_enable_sel_reg),
	.data_out		(wr_enable_oh)
);

endmodule

`resetall
