`timescale 1ns / 1ps

module andD2slice(
	input  wire [3:0] a,
	input  wire [3:0] b,
	output [3:0] o
	);

	(* H_SET = "uset0", RLOC = "X0Y0" *) (* dont_touch = "true" *)  LUT6 #(
		.INIT(64'h8888888888888888)  // Specify LUT Contents
		) LUT6_inst (
		.O(o[0]),	// LUT general output
		.I0(a[0]), // LUT input
		.I1(b[0]), // LUT input
		.I2(1'b1), // LUT input
		.I3(1'b1), // LUT input
		.I4(1'b1), // LUT input
		.I5(1'b1)  // LUT input
		);

	(* H_SET = "uset0", RLOC = "X0Y0" *) (* dont_touch = "true" *)  LUT6 #(
		.INIT(64'h8888888888888888)  // Specify LUT Contents
		) LUT6_inst1 (
		.O(o[1]),	// LUT general output
		.I0(a[1]), // LUT input
		.I1(b[1]), // LUT input
		.I2(1'b1), // LUT input
		.I3(1'b1), // LUT input
		.I4(1'b1), // LUT input
		.I5(1'b1)  // LUT input
		);

 (* H_SET = "uset0", RLOC = "X0Y0" *) (* dont_touch = "true" *)  LUT6 #(
		.INIT(64'h8888888888888888)  // Specify LUT Contents
		) LUT6_inst2 (
		.O(o[2]),	// LUT general output
		.I0(a[2]), // LUT input
		.I1(b[2]), // LUT input
		.I2(1'b1), // LUT input
		.I3(1'b1), // LUT input
		.I4(1'b1), // LUT input
		.I5(1'b1)  // LUT input
	);

 (* H_SET = "uset0", RLOC = "X0Y0" *) (* dont_touch = "true" *)  LUT6 #(
		.INIT(64'h8888888888888888)  // Specify LUT Contents
	) LUT6_inst3 (
		.O(o[3]),	// LUT general output
		.I0(a[3]), // LUT input
		.I1(b[3]), // LUT input
		.I2(1'b1), // LUT input
		.I3(1'b1), // LUT input
		.I4(1'b1), // LUT input
		.I5(1'b1)  // LUT input
	);

endmodule

