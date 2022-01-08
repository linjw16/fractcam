`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/01/2020 01:00:08 PM
// Design Name: 
// Module Name: counter
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


module counter #(parameter size=5)(input wr, input clk,input reset,output reg [size-1:0] counter);
 always@(posedge clk)
 begin
 if(reset | ~wr)
            counter <= 0;
 else 
            counter <= counter + 1;
 end  
endmodule
