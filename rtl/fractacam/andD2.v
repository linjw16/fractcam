`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/25/2019 11:15:16 PM
// Design Name: 
// Module Name: andD2
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


module andD2 #(D=64)(
    input [D-1:0] a,
    input [D-1:0] b,
    output [D-1:0] o
    );
    parameter n_andD2slice = D/4; // number of andD2 slices
    genvar i;
    generate
    for (i=0; i< n_andD2slice;i=i+1)
    begin: andD3slice 
    (* dont_touch = "true" *) andD2slice andD2slice_init(a[i*4+3:i*4],b[i*4+3:i*4],o[i*4+3:i*4]);
    end
    endgenerate
endmodule
