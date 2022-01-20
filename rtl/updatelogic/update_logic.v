`timescale 1ns / 1ps

module update_logic #(parameter D=512,W=40,SN=2 )(
	input  wire [W-1:0] sk,
	input  wire wclk,
	input  wire reset,
	input  wire wr,
	input  wire [SN-1:0] we_sel,
	output [W*8/5-1:0] DI,
	output [W-1:0] addr,
	output [D/8-1:0] we
);

wire[7:0] srl_ce, ce_demux;

wire comparison;
wire [4:0] count;
wire [2:0] sel_demux;
wire flag;
wire we_block;

(* dont_touch = "true" *) counter_srl counter_srl_inst(wr,reset,wclk,sel_demux,flag);

// THE MODULE SELECTS CE_DEMUX ACCORDING TO SEL LINE FROM PREVIOUS MODULE
(* dont_touch = "true" *) demux #(1,3,8) demux_inst(wr,sel_demux,ce_demux);

//
(* dont_touch = "true" *) cont_signal contrl_inst (ce_demux,flag,wr,srl_ce,we_block );

// COUNTER
(* dont_touch = "true" *) counter #(5) counter_inst(wr,wclk,reset,count);

  genvar i;
  generate
	for (i=0;i<(W/5);i=i+1)
	begin : block_comparator
		(* dont_touch = "true" *) compare compare_inst (sk[5*(i+1)-1:5*i], count, srl_ce, wclk , wr, DI[8*(i+1)-1:8*i], addr[5*(i+1)-1:5*i]);
	end
  endgenerate

  // THIS IS WE_MUX, GENERATES WE FOR THE SLICE TO BE UPDATED
  (* dont_touch = "true" *) demux #(1,SN,D/8) demux_inst2(we_block,we_sel,we);

// // // // ======================================================== // // // //

endmodule
