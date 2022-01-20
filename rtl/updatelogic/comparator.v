`timescale 1ns / 1ps

// COMPARES THE RULE WITH KEY
module comparator #(parameter size=5)(input[size-1:0] rule,input[size-1:0] count,output comparison);
assign comparison = (rule == count);
endmodule
