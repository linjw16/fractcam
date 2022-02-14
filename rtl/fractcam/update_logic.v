`timescale 1ns / 1ps

module update_logic #(
	parameter DEBUG_WIDTH = 32,
	parameter TCAM_DEPTH = 512,
	parameter TCAM_WIDTH = 40,
	parameter SLICEM_ADDR_WIDTH = 2 
)(
	input  wire clk,
	input  wire rst,
	output wire [DEBUG_WIDTH-1:0] 		debug,
	input  wire [TCAM_WIDTH-1:0] 		search_key,
	input  wire [TCAM_WIDTH*8-1:0] 		wr_tcam_data,
	input  wire [TCAM_WIDTH*8-1:0] 		wr_tcam_keep,
	input  wire 						wr_enable,
	input  wire [SLICEM_ADDR_WIDTH-1:0] wr_enable_sel,
	output wire [TCAM_WIDTH-1:0] 		wr_addr,
	output wire [TCAM_WIDTH*8/5-1:0] 	wr_data_in,
	output wire [TCAM_DEPTH/8-1:0] 		wr_enable_oh,
	output wire 						wr_busy
);

assign debug = {wr_enable_sel,wr_enable, we_block, flag};

// COUNTER
localparam COUNT_WIDTH = 5;
// localparam TCAM_PTR_WIDTH = 3;

reg [8:0] count2_reg = {9{1'b0}}, count2_next;
reg [COUNT_WIDTH-1:0] count_reg = {COUNT_WIDTH{1'b0}}, count_next;
reg flag_reg = 1'b0, flag_next;
reg [2:0] sel_reg = {3{1'b0}}, sel_next;
reg wr_busy_reg = 1'b0, wr_busy_next;
// reg [TCAM_PTR_WIDTH-1:0] wr_tcam_ptr_reg = {TCAM_PTR_WIDTH{1'b0}}, wr_tcam_ptr_next;

wire [4:0] count;
wire flag;

assign count = count_reg;
assign flag = flag_reg;
assign wr_busy = wr_busy_reg;

always @(*) begin
	wr_busy_next = wr_busy_reg;
	// wr_tcam_ptr_next = wr_tcam_ptr_reg;
	sel_next = sel_reg;
	if(wr_enable && ~wr_busy_reg)
		wr_busy_next = 1'b1;

	if(rst | ~wr_enable) begin
		count_next = 0;
	end else if (count_reg == 31) begin
		count_next = 0;
		sel_next = sel_next + 1'b1;
	end else begin
		count_next = count_reg + 1;
	end

	if(rst | ~wr_enable) begin
		flag_next = 0;
		count2_next = 0;
	end else if (count2_reg==287) begin	// 0x11F
		count2_next = 0;
		flag_next = 0;
		wr_busy_next = 1'b0;
	end else if (count2_reg>=255) begin
		flag_next = 1;
		count2_next = count2_reg + 1;
	end else begin
		flag_next = 0;
		count2_next = count2_reg + 1;
	end
end

always @(posedge clk) begin
	count_reg <= count_next;
	sel_reg <= sel_next;
	count2_reg <= count2_next;
	flag_reg <= flag_next;
	wr_busy_reg <= wr_busy_next;
end

wire[7:0] srl_ce, ce_demux;
// THE MODULE SELECTS CE_DEMUX ACCORDING TO SEL LINE FROM PREVIOUS MODULE
(* dont_touch = "true" *)
demux # (
	1, 
	3, 
	8
) demux_inst (
	wr_enable, 
	sel_reg, 
	ce_demux
);

wire [TCAM_WIDTH-1:0] wr_tcam_data_mux, wr_tcam_keep_mux;
assign wr_tcam_data_mux = wr_tcam_data >> sel_reg*TCAM_WIDTH;
assign wr_tcam_keep_mux = wr_tcam_keep >> sel_reg*TCAM_WIDTH;

// GENERATES VALID CE AND WE LINE FOR SRLs AND WE_DEMUX
genvar i;
generate
	for (i=0; i<8; i=i+1) begin: CE_demux
		or(srl_ce[i], ce_demux[i] , flag);
	end
endgenerate

genvar j;
generate
	for (i=0;i<(TCAM_WIDTH/5);i=i+1)
	begin : block_comparator
		wire comparison;

		// masked_match #(
		// 	.DATA_WIDTH(5)
		// ) masked_match_inst (
		// 	.data_1	(wr_tcam_data_mux[5*(i+1)-1:5*i]),
		// 	.data_2	(count),
		// 	.keep	(wr_tcam_keep_mux[5*(i+1)-1:5*i]),
		// 	.match	(comparison)
		// );

		wire [4:0] match_per_bit;
		assign match_per_bit = wr_tcam_keep_mux[5*(i+1)-1:5*i] & (wr_tcam_data_mux[5*(i+1)-1:5*i] ^ count);
		assign comparison = !(|match_per_bit);
		
		// assign comparison = (wr_tcam_data_mux[5*(i+1)-1:5*i] == count);	// TODO: 

		assign wr_addr[5*(i+1)-1:5*i] = wr_enable ? count : search_key[5*(i+1)-1:5*i];

		for (j=0; j<8; j=j+1) begin:SRL32
			SRLC32E #(
				.INIT(32'h00000000) 
			) SRLC32E_inst (
				.Q(),	
				.Q31(wr_data_in[8*i+j]), 
				.A(),	
				.CE(srl_ce[j]),	
				.CLK(clk), 
				.D(comparison)	
			);
		end
	end
endgenerate

wire we_block;
assign we_block = wr_enable & flag;
// THIS IS WE_MUX, GENERATES WE FOR THE SLICE TO BE UPDATED
(* dont_touch = "true" *)
demux #(
	1, 
	SLICEM_ADDR_WIDTH, 
	TCAM_DEPTH/8
) demux_inst2 (
	we_block, 
	wr_enable_sel, 
	wr_enable_oh
);

endmodule
