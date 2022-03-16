`timescale 1ns / 1ps

/*
 * AND gate with input width at most 6, implemented in a SLICEM with four 6-LUT. 
 */
module andD6slice #(
	parameter INIT = 64'h8000_0000_0000_0000
)(
	input  wire [3:0] a,
	input  wire [3:0] b,
	input  wire [3:0] c,
	input  wire [3:0] d,
	input  wire [3:0] e,
	input  wire [3:0] f,
	output wire [3:0] o
);

(* H_SET = "uset0", RLOC = "X0Y0" *) /* (* dont_touch = "true" *) */
LUT6 #(
	.INIT(INIT)
) LUT6_inst (
	.O(o[0]),
	.I0(a[0]),
	.I1(b[0]),
	.I2(c[0]),
	.I3(d[0]),
	.I4(e[0]),
	.I5(f[0])
);

(* H_SET = "uset0", RLOC = "X0Y0" *) /* (* dont_touch = "true" *) */
LUT6 #(
	.INIT(INIT)
) LUT6_inst1 (
	.O(o[1]),
	.I0(a[1]),
	.I1(b[1]),
	.I2(c[1]),
	.I3(d[1]),
	.I4(e[1]),
	.I5(f[1])
);

(* H_SET = "uset0", RLOC = "X0Y0" *) /* (* dont_touch = "true" *) */
LUT6 #(
	.INIT(INIT)
) LUT6_inst2 (
	.O(o[2]),
	.I0(a[2]),
	.I1(b[2]),
	.I2(c[2]),
	.I3(d[2]),
	.I4(e[2]),
	.I5(f[2])
);

(* H_SET = "uset0", RLOC = "X0Y0" *) /* (* dont_touch = "true" *) */
LUT6 #(
	.INIT(INIT)
) LUT6_inst3 (
	.O(o[3]),
	.I0(a[3]),
	.I1(b[3]),
	.I2(c[3]),
	.I3(d[3]),
	.I4(e[3]),
	.I5(f[3])
);

endmodule
