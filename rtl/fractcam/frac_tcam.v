`timescale 1ns / 1ps
/*
 * Created on Mon Jan 17 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	 frac_tcam.v
 * @Author:		 Jiawei Lin
 * @Last edit:	 14:43:28
 */

/*
 * FracTCAM with match table and output and gate. 
 */
module frac_tcam #(
	parameter TCAM_WIDTH = 5,
	parameter TCAM_DEPTH = 64
) (
	input  wire clk,
	input  wire reset,
	input  wire [TCAM_WIDTH-1:0] sk,
	input  wire [TCAM_DEPTH/8-1:0] we,
	input  wire [TCAM_WIDTH*8/5-1:0] rules,
	output wire [TCAM_DEPTH-1:0] match
);

localparam SLICEM_COLS = TCAM_WIDTH/5;	// number of slices
localparam SLICEM_WIDTH = 5;			// DBLOCK64x5 key width size

wire [SLICEM_COLS*TCAM_DEPTH-1:0] match_l;

genvar i;
generate
	for (i=0; i<SLICEM_COLS; i=i+1)
	begin:Width_extension
		(* dont_touch = "true" *) 
		DBLOCK64x5 #(
			SLICEM_WIDTH,
			TCAM_DEPTH
		) DBLOCK64x5_inst (
			sk[i*5+4:i*5],
			reset,
			we,
			rules[i*8+7:i*8],
			clk,
			match_l[i*TCAM_DEPTH+TCAM_DEPTH-1:i*TCAM_DEPTH]
		);
	end
endgenerate

and0 #(
	.WIDTH(SLICEM_COLS),
	.DEPTH(TCAM_DEPTH)
) and0_inst (
	.in_1(match_l),
	.out_1(match)
);

endmodule
