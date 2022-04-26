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
 * FracTCAM AND gate. Three levels 6AND support at most 6^3 = 216 SLICEM columns, i.e. 216 × 5 = 1080 TCAM width.  
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
localparam IN_WIDTH_RSD1 = WIDTH+6-IN_WIDTH_PAD1;	/* residue width */
localparam IN_WIDTH_RSD2 = OUT_WIDTH1+6-IN_WIDTH_PAD2;
localparam IN_WIDTH_RSD3 = OUT_WIDTH2+6-IN_WIDTH_PAD3;

/*
 * IN_WIDTH:		1	7	11	16	21	26
 * OUT_WIDTH1:		1	2	2	3	4	5
 * OUT_WIDTH2:		1	1	1	1	1	1
 * OUT_WIDTH3:		1	1	1	1	1	1
 * IN_WIDTH_PAD1:	6	12	12	18	24	30
 * IN_WIDTH_PAD2:	6	6	6	6	6	6
 * IN_WIDTH_PAD3:	6	6	6	6	6	6
 * IN_WIDTH_RSD1:	1	1	5	4	3	2
 * IN_WIDTH_RSD2:	1	2	2	3	4	5
 * IN_WIDTH_RSD3:	1	1	1	1	1	1
 */

initial begin
	if (OUT_WIDTH3 != 1) begin
		$error("Error: and0.v's levels is not enough. (instance %m)");
		$finish;
	end
end 

wire [OUT_WIDTH1*DEPTH-1:0] and_l1;
wire [OUT_WIDTH2*DEPTH-1:0] and_l2;
wire [OUT_WIDTH3*DEPTH-1:0] and_l3;
wire [IN_WIDTH_PAD1*DEPTH-1:0] in_1_pad = {{((IN_WIDTH_PAD1-WIDTH)*DEPTH){1'b1}}, in_1};
wire [IN_WIDTH_PAD2*DEPTH-1:0] in_2_pad = {{((IN_WIDTH_PAD2-OUT_WIDTH1)*DEPTH){1'b1}}, and_l1};
wire [IN_WIDTH_PAD3*DEPTH-1:0] in_3_pad = {{((IN_WIDTH_PAD3-OUT_WIDTH2)*DEPTH){1'b1}}, and_l2};


assign out_1 = OUT_WIDTH3 ? and_l3 : OUT_WIDTH2 ? and_l2 : and_l1;

genvar i;
generate
	for (i = 0; i < OUT_WIDTH1-1; i = i+1) begin: gen_l1
		/* (* dont_touch = "true" *) */
		and6 #(
			.DEPTH(DEPTH),
			.WIDTH(6)
		) and6_inst(
			.in (in_1_pad[(i+1)*6*DEPTH-1 : i*6*DEPTH]),
			.out(and_l1[(i+1)*DEPTH-1 : i*DEPTH])
		);
	end
	for (i = 0; i < OUT_WIDTH2-1; i = i+1) begin: gen_l2
		/* (* dont_touch = "true" *) */
		and6 #(
			.DEPTH(DEPTH),
			.WIDTH(6)
		) and6_inst(
			.in (in_2_pad[(i+1)*6*DEPTH-1 : i*6*DEPTH]),
			.out(and_l2[(i+1)*DEPTH-1 : i*DEPTH])
		);
	end
	for (i = 0; i < OUT_WIDTH3-1; i = i+1) begin: gen_l3
		/* (* dont_touch = "true" *) */
		and6 #(
			.DEPTH(DEPTH),
			.WIDTH(6)
		) and6_inst(
			.in (in_3_pad[(i+1)*6*DEPTH-1 : i*6*DEPTH]),
			.out(and_l3[(i+1)*DEPTH-1 : i*DEPTH])
		);
	end

	and6 #(
		.DEPTH(DEPTH),
		.WIDTH(IN_WIDTH_RSD1)
	) and6_l1_rsd (
		.in (in_1_pad[(OUT_WIDTH1-1)*6*DEPTH +: IN_WIDTH_RSD1*DEPTH]),
		.out(and_l1[(OUT_WIDTH1-1)*DEPTH +: DEPTH])
	);

	and6 #(
		.DEPTH(DEPTH),
		.WIDTH(IN_WIDTH_RSD2)
	) and6_l2_rsd (
		.in (in_2_pad[(OUT_WIDTH2-1)*6*DEPTH +: IN_WIDTH_RSD2*DEPTH]),
		.out(and_l2[(OUT_WIDTH2-1)*DEPTH +: DEPTH])
	);

	and6 #(
		.DEPTH(DEPTH),
		.WIDTH(IN_WIDTH_RSD3)
	) and6_l3_rsd (
		.in (in_3_pad[(OUT_WIDTH3-1)*6*DEPTH +: IN_WIDTH_RSD3*DEPTH]),
		.out(and_l3[(OUT_WIDTH3-1)*DEPTH +: DEPTH])
	);
endgenerate

endmodule

`resetall