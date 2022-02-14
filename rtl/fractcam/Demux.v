`timescale 1ns / 1ps

//module mux #(parameter  WIDTH= 8,CHANNELS= 4) (
//	input		in_bus,
//	input		sel,
//	output					out
//	);
//genvar ig;

//wire	input_array ;
//assign  out = input_array;
//generate
//	for(ig=0; ig<CHANNELS; ig=ig+1) begin: array_assignments
//		assign  input_array = in_bus;
//	end
//endgenerate
////define the clogb2 function
//function integer clogb2;
//  input depth;
//  integer i,result;
//  begin
//	for (i = 0; 2 ** i < depth; i = i + 1)
//	result = i + 1;
//	clogb2 = result;
//	end
//endfunction
//endmodule

//module demux
//#(
//  parameter
//	WIDTH = 8, // Min 1
//	WIDTH_sel = 4, // Min 1
//	NUM_INPUTS  = 16 // Min 2
//)
//(
////  input wire [ NUM_INPUTS - 1 : 0 ] [ WIDTH - 1 : 0 ] a_i, // SystemVerilog
//  input wire [ NUM_INPUTS * WIDTH - 1 : 0 ] a_i,
//  input wire [ WIDTH_sel  - 1 : 0 ] select_i,
//  output wire [ WIDTH -1 : 0 ] y_o
//);
//assign y_o = a_i >> ( select_i * WIDTH );
//endmodule

module demux
#(
  parameter
	WIDTH = 8,
	WIDTH_sel = 4,
	NUM_OUTPUTS  = 16
)
(
  input wire [ WIDTH - 1 : 0 ] a_i,
  input wire [ WIDTH_sel - 1 : 0 ] select_i,
  output wire [NUM_OUTPUTS * WIDTH - 1 : 0] y_o
);
reg [NUM_OUTPUTS * WIDTH - 1 : 0] y;
always@* begin y = { {(NUM_OUTPUTS-1)*WIDTH{1'b0}}, a_i};end
assign y_o = y << ( select_i * WIDTH);
endmodule