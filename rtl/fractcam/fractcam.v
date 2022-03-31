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
module fractcam #(
	parameter TCAM_WIDTH = 5,
	parameter TCAM_DEPTH = 64,
	parameter INIT = 64'b0
) (
	input  wire clk,
	input  wire rst,
	input  wire [TCAM_WIDTH-1:0] search_key,
	input  wire [TCAM_DEPTH/8-1:0] wr_enable,
	input  wire [TCAM_WIDTH*8/5-1:0] rules,
	output wire [TCAM_DEPTH-1:0] match
);

// TODO: Padding the last SLICEM's input in order to support arbitrary width and depth. 
initial begin
	if(TCAM_DEPTH/8*8 != TCAM_DEPTH) begin
		$error("Error: TCAM_DEPTH is not multiple of 8. (instance %m)");
		$finish;
	end
	if(TCAM_WIDTH/5*5 != TCAM_WIDTH) begin
		$error("Error: TCAM_WIDTH is not multiple of 5. (instance %m)");
		$finish;
	end
end

localparam SLICEM_COLS = TCAM_WIDTH/5;	// SLICEMs' column size
localparam SLICEM_ROWS = TCAM_DEPTH/8;	// SLICEMs' row size

wire [SLICEM_COLS*TCAM_DEPTH-1:0] match_l;

genvar i, j;
generate
	for (i=0; i<SLICEM_COLS; i=i+1) begin: Width_extension
		for (j=0; j<SLICEM_ROWS; j=j+1) begin: Depth_extension
			fractcam8x5 #(
				.INIT_A		(INIT),
				.INIT_B		(INIT),
				.INIT_C		(INIT),
				.INIT_D		(INIT)
			) fractcam8x5_inst (
				.clk		(clk),
				.rst		(rst),
				.search_key	(search_key[i*5+4:i*5]),
				.wr_enable	(wr_enable[j]),
				.rules		(rules[i*8+7:i*8]),
				.match		(match_l[i*TCAM_DEPTH+(j+1)*8-1 : i*TCAM_DEPTH+j*8])
			);
		end
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
