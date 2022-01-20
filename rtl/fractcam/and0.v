/*
 * Created on Tue Jan 18 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	 and0.v
 * @Author:		 Jiawei Lin
 * @Last edit:	 17:07:02
 */

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * FracTCAM with match table and output and gate. 
 */
module and0 #(
	parameter WIDTH = 5,
	parameter DEPTH = 64
) (
	input  wire [WIDTH*DEPTH-1:0] in_1,
	output wire [DEPTH-1:0] out_1
);

localparam OUT_WIDTH1 = (WIDTH + 5) / 6;
localparam OUT_WIDTH2 = (OUT_WIDTH1 + 5) / 6;
localparam OUT_WIDTH3 = (OUT_WIDTH2 + 5) / 6;
localparam IN_WIDTH_PAD1 = OUT_WIDTH1 * 6;
localparam IN_WIDTH_PAD2 = OUT_WIDTH2 * 6;
localparam IN_WIDTH_PAD3 = OUT_WIDTH3 * 6;

wire [OUT_WIDTH1*DEPTH-1:0] and_l1;
wire [OUT_WIDTH2*DEPTH-1:0] and_l2;
wire [OUT_WIDTH3*DEPTH-1:0] and_l3;
wire [IN_WIDTH_PAD1*DEPTH-1:0] in_1_pad = {{((IN_WIDTH_PAD1-WIDTH)*DEPTH){1'b1}}, in_1};
wire [IN_WIDTH_PAD2*DEPTH-1:0] in_2_pad = {{((IN_WIDTH_PAD2-OUT_WIDTH1)*DEPTH){1'b1}}, and_l1};
wire [IN_WIDTH_PAD3*DEPTH-1:0] in_3_pad = {{((IN_WIDTH_PAD3-OUT_WIDTH2)*DEPTH){1'b1}}, and_l2};

genvar i;
generate
	for (i = 0; i < OUT_WIDTH1; i = i+1) begin: lp_and6_l1
		(* dont_touch = "true" *)
		and6 #(
			.DEPTH(DEPTH),
			.WIDTH(6)
		) andD6_init(
			.in (in_1_pad[(i+1)*6*DEPTH-1 : i*6*DEPTH]),
			.out(and_l1[(i+1)*DEPTH-1 : i*DEPTH])
		);
	end
	for (i = 0; i < OUT_WIDTH2; i = i+1) begin: lp_and6_l2
		(* dont_touch = "true" *)
		and6 #(
			.DEPTH(DEPTH),
			.WIDTH(6)
		) andD6_init(
			.in (in_2_pad[(i+1)*6*DEPTH-1 : i*6*DEPTH]),
			.out(and_l2[(i+1)*DEPTH-1 : i*DEPTH])
		);
	end
	for (i = 0; i < OUT_WIDTH3; i = i+1) begin: lp_and6_l3
		(* dont_touch = "true" *)
		and6 #(
			.DEPTH(DEPTH),
			.WIDTH(6)
		) andD6_init(
			.in (in_3_pad[(i+1)*6*DEPTH-1 : i*6*DEPTH]),
			.out(and_l3[(i+1)*DEPTH-1 : i*DEPTH])
		);
	end
	assign out_1 = OUT_WIDTH3 ? and_l3 : OUT_WIDTH2 ? and_l2 : and_l1;
endgenerate

endmodule

`resetall