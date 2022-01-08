`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2018 10:26:02 AM
// Design Name: 
// Module Name: match_reduction
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module match_reduction #(parameter rules_num=32)(match,match_reduced);
input[rules_num-1:0] match;
output match_reduced;
assign match_reduced = |match;
endmodule
