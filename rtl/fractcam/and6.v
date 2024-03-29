/*
 * Created on Mon Jan 17 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	 and6.v
 * @Author:		 Jiawei Lin
 * @Last edit:	 10:49:55
 */
`timescale 1ns / 1ps

/*
 * And gate with input width at most 6
 */
module and6 #(
	parameter DEPTH = 8,
	parameter WIDTH = 6
)(
	input  wire [WIDTH*DEPTH-1 : 0] in,
	output wire [DEPTH-1 : 0] out
);

localparam NUM_CLB = DEPTH/4; // number of andD6 slices
localparam D = DEPTH;

initial begin
	if(DEPTH/4*4 != DEPTH) begin
		$error("Error :  Depth is not multiple of 4. (instance %m)");
		$finish;
	end
	if(WIDTH>6) begin
		$error("Error :  Width should in {1,2,3,4,5,6}. (instance %m)");
		$finish;
	end
end

genvar i;
generate
	case (WIDTH)
		1: begin
			assign out[DEPTH-1:0] = in[DEPTH-1:0];
		end
		2: begin
			for (i=0; i<NUM_CLB; i=i+1) begin :  and6x4
				/* (* dont_touch = "true" *) */ 
				and6x4 #(
					.INIT(64'h8888_8888_8888_8888)
				) and6x4_inst(
					in[0*D+i*4+3 : 0*D+i*4],
					in[1*D+i*4+3 : 1*D+i*4],
					4'hF,
					4'hF,
					4'hF,
					4'hF,
					out[i*4+3 : i*4]
				);
			end
		end
		3: begin
			for (i=0; i<NUM_CLB; i=i+1) begin :  and6x4
				/* (* dont_touch = "true" *) */ 
				and6x4 #(
					.INIT(64'h8080_8080_8080_8080)
				) and6x4_inst(
					in[0*D+i*4+3 : 0*D+i*4],
					in[1*D+i*4+3 : 1*D+i*4],
					in[2*D+i*4+3 : 2*D+i*4],
					4'hF,
					4'hF,
					4'hF,
					out[i*4+3 : i*4]
				);
			end
		end
		4: begin
			for (i=0; i<NUM_CLB; i=i+1) begin :  and6x4
				/* (* dont_touch = "true" *) */ 
				and6x4 #(
					.INIT(64'h8000_8000_8000_8000)
				) and6x4_inst(
					in[0*D+i*4+3 : 0*D+i*4],
					in[1*D+i*4+3 : 1*D+i*4],
					in[2*D+i*4+3 : 2*D+i*4],
					in[3*D+i*4+3 : 3*D+i*4],
					in[4*D+i*4+3 : 4*D+i*4],
					in[5*D+i*4+3 : 5*D+i*4],
					out[i*4+3 : i*4]
				);
			end
		end
		5: begin
			for (i=0; i<NUM_CLB; i=i+1) begin :  and6x4
				/* (* dont_touch = "true" *) */ 
				and6x4 #(
					.INIT(64'h8000_0000_8000_0000)
				) and6x4_inst(
					in[0*D+i*4+3 : 0*D+i*4],
					in[1*D+i*4+3 : 1*D+i*4],
					in[2*D+i*4+3 : 2*D+i*4],
					in[3*D+i*4+3 : 3*D+i*4],
					in[4*D+i*4+3 : 4*D+i*4],
					in[5*D+i*4+3 : 5*D+i*4],
					out[i*4+3 : i*4]
				);
			end
		end
		default : begin // 6: 
			for (i=0; i<NUM_CLB; i=i+1) begin :  and6x4
				/* (* dont_touch = "true" *) */ 
				and6x4 #(
					.INIT(64'h8000_0000_0000_0000)
				) and6x4_inst(
					in[0*D+i*4+3 : 0*D+i*4],
					in[1*D+i*4+3 : 1*D+i*4],
					in[2*D+i*4+3 : 2*D+i*4],
					in[3*D+i*4+3 : 3*D+i*4],
					in[4*D+i*4+3 : 4*D+i*4],
					in[5*D+i*4+3 : 5*D+i*4],
					out[i*4+3 : i*4]
				);
			end
		end
	endcase
endgenerate

endmodule
