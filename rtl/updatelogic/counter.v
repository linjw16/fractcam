`timescale 1ns / 1ps

module counter #(parameter size=5)(input wr, input clk,input reset,output reg [size-1:0] counter);
 always@(posedge clk)
 begin
 if(reset | ~wr)
			counter <= 0;
 else
			counter <= counter + 1;
 end
endmodule
