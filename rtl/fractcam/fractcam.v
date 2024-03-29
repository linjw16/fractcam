/*
 * Created on Sun May 01 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	 fractcam.v
 * @Author:		 Jiawei Lin
 * @Last edit:	 23:45:55
 */

`resetall
`timescale 1ns / 1ps
`default_nettype none

module fractcam #(
	parameter ADDR_WIDTH = 10,
	parameter DATA_WIDTH = 8,
	parameter DATA_DEPTH = 10,
	parameter TCAM_DEPTH = (DATA_DEPTH+7)/8*8,
	parameter TCAM_WIDTH = (DATA_WIDTH+4)/5*5
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
	output wire [DATA_WIDTH-1:0]	rd_rsp_data,
	output wire [DATA_WIDTH-1:0]	rd_rsp_keep,
	output wire						rd_rsp_valid,
	input  wire						rd_rsp_ready,

	input  wire [TCAM_WIDTH-1:0]	search_key,
	input  wire						search_valid,
	output wire						search_ready,
	output wire [TCAM_DEPTH-1:0] 	match_line,
	output wire						match_valid,
	input  wire						match_ready
);

localparam CL_DEPTH = $clog2(TCAM_DEPTH);

initial begin
	if (TCAM_DEPTH/8*8 != TCAM_DEPTH) begin
		$error("Error: TCAM_DEPTH is not multiple of 8. (instance %m)");
		$finish;
	end
	if (TCAM_WIDTH/5*5 != TCAM_WIDTH) begin
		$error("Error: TCAM_WIDTH is not multiple of 5. (instance %m)");
		$finish;
	end
	if (ADDR_WIDTH < CL_DEPTH) begin
		$error("Error: ADDR_WIDTH < CL_DEPTH (instance %m)");
		$finish;
	end
end

localparam CNT_WIDTH = 6;

reg [ADDR_WIDTH-1:0] wr_addr_reg = {ADDR_WIDTH{1'b0}}, wr_addr_next;
reg [TCAM_WIDTH*8-1:0] wr_data_reg = {TCAM_WIDTH{1'b0}}, wr_data_next;
reg [TCAM_WIDTH*8-1:0] wr_keep_reg = {TCAM_WIDTH{1'b1}}, wr_keep_next;
reg [ADDR_WIDTH-1:0] rd_addr_reg = {ADDR_WIDTH{1'b0}}, rd_addr_next;
reg [TCAM_WIDTH-1:0] rd_data_reg = {TCAM_WIDTH{1'b0}}, rd_data_next;
reg [TCAM_WIDTH-1:0] rd_keep_reg = {TCAM_WIDTH{1'b1}}, rd_keep_next;
reg [CNT_WIDTH-1:0] cnt_wr_reg = {CNT_WIDTH{1'b0}}, cnt_wr_next;
reg [CNT_WIDTH-1:0] cnt_rd_reg = {CNT_WIDTH{1'b0}}, cnt_rd_next;
reg [SLICEM_COLS-1:0] rd_mask_reg = {SLICEM_COLS{1'b0}}, rd_mask_next;
reg wr_flag_reg = 1'b0, wr_flag_next;
reg rd_flag_reg = 1'b0, rd_flag_next;
reg wr_en_reg = 1'b0, wr_en_next;
// reg [TCAM_DEPTH-1:0] rd_en_reg = {TCAM_DEPTH{1'b0}}, rd_en_next;

wire [TCAM_DEPTH-1:0] rd_en;
wire [TCAM_DEPTH/8-1:0] wr_en_pad, wr_enable_oh;
wire [TCAM_DEPTH-1:0] match_line_int;
wire clk_en;

reg rd_rsp_valid_reg = 1'b0, rd_rsp_valid_next;
reg search_ready_reg = 1'b1, search_ready_next;	// TODO: rm 
reg [TCAM_DEPTH-1:0] match_line_reg = {TCAM_DEPTH{1'b0}}, match_line_next;
reg match_valid_reg = 1'b0, match_valid_next;

assign clk_en = wr_flag_reg || wr_en_reg;
assign wr_en_pad = {{TCAM_DEPTH/8-1{1'b0}}, wr_en_reg};
assign wr_enable_oh = wr_en_pad << wr_addr_reg[ADDR_WIDTH-1:3];
assign wr_ready = !wr_flag_reg;
assign rd_en = 1 << rd_addr_reg;
assign rd_cmd_ready = !clk_en && !rd_flag_reg;
assign rd_rsp_valid = rd_rsp_valid_reg;
assign rd_rsp_data = rd_data_reg[DATA_WIDTH-1:0];
assign rd_rsp_keep = rd_keep_reg[DATA_WIDTH-1:0];
// TODO: Can it be decoupled by a skid buffer. 
assign search_ready = search_ready_reg && !rd_flag_reg && (!match_valid_reg || match_ready);
assign match_valid = match_valid_reg;
assign match_line = match_line_reg;

integer k;

always @(*) begin
	search_ready_next = 1'b1;
	match_line_next = match_line_reg;
	match_valid_next = match_valid_reg;

	if (match_valid && match_ready) begin
		// match_line_next = {TCAM_DEPTH{1'b0}};
		match_valid_next = 1'b0;
	end

	if (search_valid && search_ready) begin
		match_line_next = match_line_int;
		match_valid_next = 1'b1;
	end

	/* 2.1 write logic */
	wr_addr_next = wr_addr_reg;
	wr_data_next = wr_data_reg;
	wr_keep_next = wr_keep_reg;
	wr_flag_next = wr_flag_reg;
	wr_en_next = wr_en_reg;

	if (wr_valid && wr_ready) begin
		wr_addr_next = wr_addr;
		for (k=0; k<8; k=k+1) begin
			wr_data_next[k*TCAM_WIDTH +: TCAM_WIDTH] = {
				{TCAM_WIDTH-DATA_WIDTH{1'b0}}, 
				wr_data[k*DATA_WIDTH +: DATA_WIDTH]
			};
			wr_keep_next[k*TCAM_WIDTH +: TCAM_WIDTH] = {
				{TCAM_WIDTH-DATA_WIDTH{1'b0}}, 
				wr_keep[k*DATA_WIDTH +: DATA_WIDTH]
			};
		end
		wr_flag_next = 1'b1;
	end

	if (clk_en) begin
		if (cnt_wr_reg == 5'h1F) begin
			wr_en_next = wr_flag_reg;
			wr_flag_next = 1'b0;
			cnt_wr_next = {CNT_WIDTH{1'b0}};
			search_ready_next = !wr_flag_reg;
		end else begin
			cnt_wr_next = cnt_wr_reg + 5'b1;
			search_ready_next = !wr_en_reg;
		end
	end else begin
		cnt_wr_next = {CNT_WIDTH{1'b0}};
		search_ready_next = 1'b1;
	end

	/* 2.2 read logic */
	rd_addr_next = rd_addr_reg;
	rd_data_next = rd_data_reg;
	rd_keep_next = rd_keep_reg;
	rd_flag_next = rd_flag_reg;
	rd_mask_next = rd_mask_reg;
	// rd_en_next = rd_en_reg;
	rd_rsp_valid_next = rd_rsp_valid_reg;
	
	for (k=0;k<(TCAM_WIDTH/5);k=k+1) begin
		if (match_mtx[k*TCAM_DEPTH +: TCAM_DEPTH] & rd_en) begin
			rd_data_next[k*5+:5] = cnt_rd_reg;
			if (rd_mask_reg[k]) begin
				rd_keep_next[k*5+:5] = rd_keep_reg[k*5+:5] & ~(cnt_rd_reg ^ rd_data_reg[k*5+:5]);
			end else begin
				rd_mask_next[k] = 1'b1;
			end
		end
	end

	if (rd_rsp_valid && rd_rsp_ready) begin
		rd_rsp_valid_next = 1'b0;
	end

	if (rd_flag_reg) begin
		if (cnt_rd_reg == 6'h20) begin
			cnt_rd_next = {CNT_WIDTH{1'b0}};
			rd_flag_next = 1'b0;
			// rd_en_next = {TCAM_DEPTH{1'b0}};
			rd_rsp_valid_next = 1'b1;
		end else begin
			cnt_rd_next = cnt_rd_reg + 5'b1;
		end
		if (cnt_rd_reg == 6'h00) begin
		end
	end else begin
		cnt_rd_next = {CNT_WIDTH{1'b0}};
	end

	if (rd_cmd_valid && rd_cmd_ready) begin
		rd_flag_next = 1'b1;
		// rd_en_next = 1 << rd_addr_reg;
		rd_addr_next = rd_cmd_addr;
		rd_data_next = {TCAM_WIDTH{1'b0}};
		rd_keep_next = {TCAM_WIDTH{1'b1}};
		rd_mask_next = {SLICEM_COLS{1'b0}};
	end

end

always @(posedge clk) begin
	if (rst) begin
		wr_addr_reg <= {ADDR_WIDTH{1'b0}};
		wr_data_reg <= {TCAM_WIDTH{1'b0}};
		wr_keep_reg <= {TCAM_WIDTH{1'b1}};
		rd_addr_reg <= {ADDR_WIDTH{1'b0}};
		rd_data_reg <= {TCAM_WIDTH{1'b0}};
		rd_keep_reg <= {TCAM_WIDTH{1'b1}};
		cnt_wr_reg <= {CNT_WIDTH{1'b0}};
		cnt_rd_reg <= {CNT_WIDTH{1'b0}};
		wr_flag_reg <= 1'b0;
		rd_flag_reg <= 1'b0;
		wr_en_reg <= 1'b0;
		// rd_en_reg <= {SLICEM_COLS{1'b0}};
		rd_mask_reg <= {SLICEM_COLS{1'b0}};

		rd_rsp_valid_reg <= 1'b0;
		search_ready_reg <= 1'b1;
		match_line_reg <= {TCAM_DEPTH{1'b0}};
		match_valid_reg <= 1'b0;
	end else begin
		rd_addr_reg <= rd_addr_next;
		rd_data_reg <= rd_data_next;
		rd_keep_reg <= rd_keep_next;
		wr_addr_reg <= wr_addr_next;
		wr_data_reg <= wr_data_next;
		wr_keep_reg <= wr_keep_next;
		cnt_wr_reg <= cnt_wr_next;
		cnt_rd_reg <= cnt_rd_next;
		wr_flag_reg <= wr_flag_next;
		rd_flag_reg <= rd_flag_next;
		wr_en_reg <= wr_en_next;
		// rd_en_reg <= rd_en_next;
		rd_mask_reg <= rd_mask_next;

		rd_rsp_valid_reg <= rd_rsp_valid_next;
		search_ready_reg <= search_ready_next;
		match_line_reg <= match_line_next;
		match_valid_reg <= match_valid_next;
	end
end

wire [TCAM_WIDTH-1:0] search_key_int;
wire [TCAM_WIDTH*8/5-1:0] rules_int;

genvar i, j;
generate
for (i=0;i<(TCAM_WIDTH/5);i=i+1) begin: W_ctl
	assign search_key_int[5*i+:5] = wr_en_reg ? cnt_wr_reg : (rd_flag_reg ? cnt_rd_reg : search_key[5*i+:5]);

	for (j=0; j<8; j=j+1) begin: D_ctl
		wire rule_32;
		wire [4:0] keep, data, xor_5;
		assign keep = wr_keep_reg[j*TCAM_WIDTH+5*i+:5];
		assign data = wr_data_reg[j*TCAM_WIDTH+5*i+:5];
		assign xor_5 = keep & (data ^ cnt_wr_reg);
		assign rule_32 = !(|xor_5);
		SRLC32E #(
			.INIT(32'h00000000) 
		) SRLC32E_inst (
			.Q(),	
			.Q31(rules_int[8*i+j]), 
			.A(),	
			.CE(clk_en),	
			.CLK(clk), 
			.D(rule_32)	
		);
	end
end endgenerate

/*
 * 2. FracTCAM inplementation
 */
localparam INIT = 32'b0;
localparam SLICEM_COLS = TCAM_WIDTH/5;	// SLICEMs' column size
localparam SLICEM_ROWS = TCAM_DEPTH/8;	// SLICEMs' row size

wire [SLICEM_COLS*TCAM_DEPTH-1:0] match_mtx;

generate
	for (i=0; i<SLICEM_COLS; i=i+1) begin: W_ext	// Width_extension
		for (j=0; j<SLICEM_ROWS; j=j+1) begin: D_ext	// Depth_extension
			RAM32M #(
				.INIT_A	(INIT),
				.INIT_B	(INIT),
				.INIT_C	(INIT),
				.INIT_D	(INIT)
			) RAM32M_inst (
				.DOA	(match_mtx[i*TCAM_DEPTH+j*8+0+:2]),
				.DOB	(match_mtx[i*TCAM_DEPTH+j*8+2+:2]),
				.DOC	(match_mtx[i*TCAM_DEPTH+j*8+4+:2]),
				.DOD	(match_mtx[i*TCAM_DEPTH+j*8+6+:2]),
				.ADDRA	(search_key_int[5*i+:5]),
				.ADDRB	(search_key_int[5*i+:5]),
				.ADDRC	(search_key_int[5*i+:5]),
				.ADDRD	(search_key_int[5*i+:5]),
				.DIA	(rules_int[8*i+0+:2]),
				.DIB	(rules_int[8*i+2+:2]),
				.DIC	(rules_int[8*i+4+:2]),
				.DID	(rules_int[8*i+6+:2]),
				.WCLK	(clk),
				.WE		(wr_enable_oh[j])
			);
		end
	end
endgenerate

and0 #(
	.WIDTH(SLICEM_COLS),
	.DEPTH(TCAM_DEPTH)
) and0_inst (
	.in_1(match_mtx),
	.out_1(match_line_int)
);

endmodule

`resetall
