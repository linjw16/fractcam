`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/01/2020 01:07:41 PM
// Design Name: 
// Module Name: comparator
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


module comparator #(parameter size=5)(input[size-1:0] rule,input[size-1:0] count,output comparison);
assign comparison = (rule == count); 
endmodule
