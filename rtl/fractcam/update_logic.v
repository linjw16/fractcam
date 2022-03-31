`timescale 1ns / 1ps

module update_logic #(
	parameter TCAM_DEPTH = 512,
	parameter TCAM_WIDTH = 40,
	parameter SLICEM_ADDR_WIDTH = 2 
)(
	input  wire clk,
	input  wire rst,
	input  wire [TCAM_WIDTH-1:0] 		search_key,
	input  wire [TCAM_WIDTH*8-1:0] 		wr_tcam_data,
	input  wire [TCAM_WIDTH*8-1:0] 		wr_tcam_keep,
	input  wire 						wr_valid,
	input  wire [SLICEM_ADDR_WIDTH-1:0] wr_enable_sel,
	output wire [TCAM_WIDTH-1:0] 		wr_addr,
	output wire [TCAM_WIDTH*8/5-1:0] 	wr_data_in,
	output wire [TCAM_DEPTH/8-1:0] 		wr_enable_oh,
	output wire 						wr_ready
);

// COUNTER
localparam COUNT_WIDTH = 5;

reg [8:0] count2_reg = {9{1'b0}}, count2_next;
reg [COUNT_WIDTH-1:0] count_reg = {COUNT_WIDTH{1'b0}}, count_next;
reg flag_reg = 1'b0, flag_next;
reg [2:0] sel_reg = {3{1'b0}}, sel_next;
reg [SLICEM_ADDR_WIDTH-1:0] wr_enable_sel_reg = {SLICEM_ADDR_WIDTH{1'b0}}, wr_enable_sel_next;
reg wr_ready_reg = 1'b1, wr_ready_next;
reg [TCAM_WIDTH*8-1:0] wr_tcam_data_reg = {TCAM_WIDTH{1'b1}}, wr_tcam_data_next;
reg [TCAM_WIDTH*8-1:0] wr_tcam_keep_reg = {TCAM_WIDTH{1'b1}}, wr_tcam_keep_next;

wire [4:0] count;
wire flag;

assign count = count_reg;
assign flag = flag_reg;
assign wr_ready = wr_ready_reg;

always @(*) begin
	wr_ready_next = wr_ready_reg;
	wr_enable_sel_next = wr_enable_sel_reg;
	wr_tcam_data_next = wr_tcam_data_reg;
	wr_tcam_keep_next = wr_tcam_keep_reg;
	sel_next = sel_reg;
	if(wr_valid && wr_ready) begin
		wr_ready_next = 1'b0;
		wr_tcam_data_next = wr_tcam_data;
		wr_tcam_keep_next = wr_tcam_keep;
		wr_enable_sel_next = wr_enable_sel;
	end

	if(rst | wr_ready) begin
		count_next = 0;
	end else if (count_reg == 31) begin
		count_next = 0;
		sel_next = sel_next + 1'b1;
	end else begin
		count_next = count_reg + 1;
	end

	if(rst | wr_ready) begin
		flag_next = 0;
		count2_next = 0;
	end else if (count2_reg==287) begin	/* (0x20)*(8+1)-1 = 287; */
		count2_next = 0;
		flag_next = 0;
		wr_ready_next = 1'b1;
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
	count2_reg <= count2_next;
	flag_reg <= flag_next;
	sel_reg <= sel_next;
	wr_ready_reg <= wr_ready_next;
	wr_enable_sel_reg <= wr_enable_sel_next;
	wr_tcam_data_reg <= wr_tcam_data_next;
	wr_tcam_keep_reg <= wr_tcam_keep_next;
end

wire[7:0] srl_ce, ce_demux;
// THE MODULE SELECTS CE_DEMUX ACCORDING TO SEL LINE FROM PREVIOUS MODULE
async_demux #(
	.DATA_WIDTH		(1),
	.ADDR_WIDTH		(3),
	.COUNT			(8)
) async_demux_clken (
  .data_in			(~wr_ready_reg),
  .select			(sel_reg),
  .data_out			(ce_demux)
);

wire [TCAM_WIDTH-1:0] wr_tcam_data_mux, wr_tcam_keep_mux;
assign wr_tcam_data_mux = wr_tcam_data_reg >> sel_reg*TCAM_WIDTH;
assign wr_tcam_keep_mux = wr_tcam_keep_reg >> sel_reg*TCAM_WIDTH;

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
		wire [4:0] match_per_bit;
		assign match_per_bit = wr_tcam_keep_mux[5*(i+1)-1:5*i] & (wr_tcam_data_mux[5*(i+1)-1:5*i] ^ count);
		assign comparison = !(|match_per_bit);
		
		// assign comparison = (wr_tcam_data_mux[5*(i+1)-1:5*i] == count);	// TODO: 

		assign wr_addr[5*(i+1)-1:5*i] = wr_ready_reg ? search_key[5*(i+1)-1:5*i] : count;

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
assign we_block = (~wr_ready_reg) & flag;
// THIS IS WE_MUX, GENERATES WE FOR THE SLICE TO BE UPDATED
async_demux #(
	.DATA_WIDTH		(1),
	.ADDR_WIDTH		(SLICEM_ADDR_WIDTH),
	.COUNT			(TCAM_DEPTH/8)
) async_demux_wrten (
  .data_in			(we_block),
  .select			(wr_enable_sel_reg),
  .data_out			(wr_enable_oh)
);

endmodule
