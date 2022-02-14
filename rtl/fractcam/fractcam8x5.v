`timescale 1ns / 1ps

/*
 * FracTCAM with depth of 8 and width of 5. Implemented in a SLICEM. 
 */
module fractcam8x5 #(
	parameter TCAM_WIDTH = 5,
	parameter TCAM_DEPTH = 8
) (
	input  wire clk,
	input  wire rst,
	input  wire [4:0] search_key,
	input  wire wr_enable,
	input  wire [7:0] rules,
	output wire [7:0] match
);

initial begin
	if(TCAM_DEPTH != 8) begin
		$error("Error: TCAM_DEPTH is not 8. (instance %m)");
		$finish;
	end
	if(TCAM_WIDTH != 5) begin
		$error("Error: TCAM_WIDTH is not 5. (instance %m)");
		$finish;
	end
end

wire [3:0] o5,o6;

/*
 * RAM32M 		: In order to incorporate this function into the design,
 * Verilog 		: the following instance declaration needs to be placed
 * instance 	: in the body of the design code.  The instance name
 * declaration 	: (RAM32M_inst) and/or the port declarations within the
 * code 		: parenthesis may be changed to properly reference and
 * 				: connect this function to the design.  All inputs
 * 				: and outputs must be connected.
 */
 
/*
 * RAM32M: 32-deep by 8-wide Multi Port LUT RAM (Mapped to four SliceM LUT6s)
 * Virtex-7
 * Xilinx HDL Language Template, version 2016.3
 */
(* H_SET = "uset0", RLOC = "X0Y0" *) (* dont_touch = "true" *)
RAM32M #(
	.INIT_A	(64'h8000_0000_8000_0000),
	.INIT_B	(64'h8000_0000_8000_0000),
	.INIT_C	(64'h8000_0000_8000_0000),
	.INIT_D	(64'h8000_0000_8000_0000)
) RAM32M_inst (
	.DOA	({o6[0],o5[0]}),
	.DOB	({o6[1],o5[1]}),
	.DOC	({o6[2],o5[2]}),
	.DOD	({o6[3],o5[3]}),
	.ADDRA	(search_key),
	.ADDRB	(search_key),
	.ADDRC	(search_key),
	.ADDRD	(search_key),
	.DIA	(rules[1:0]),
	.DIB	(rules[3:2]),
	.DIC	(rules[5:4]),
	.DID	(rules[7:6]),
	.WCLK	(clk),
	.WE		(wr_enable)
);

genvar i;
generate
	for (i=0; i<4; i=i+1) begin: o5_o6_DFF
		(* H_SET = "uset0", RLOC = "X0Y0" *) (* dont_touch = "true" *) (*BEL ="SLICE_X0Y0/BFF"*)
		FDRE #(
			.INIT(1'b0)
		) FDRE_inst1 (
			.Q	(match[i*2]),
			.C	(clk),
			.CE	(1'b1),
			.R	(rst),
			.D	(o5[i])
		);

		(* H_SET = "uset0", RLOC = "X0Y0" *) (* dont_touch = "true" *) (*BEL ="SLICE_X0Y0/BFF"*)
		FDRE #(
			.INIT(1'b0)
		) FDRE_inst (
			.Q	(match[(i*2)+1]),
			.C	(clk),
			.CE	(1'b1),
			.R	(rst),
			.D	(o6[i])
		);
	end
endgenerate

endmodule
