`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2019 03:47:21 PM
// Design Name: 
// Module Name: frac_tcam
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


module frac_tcam #(parameter W=5,D=64,N=1) (sk,reset,we,rules,clk,match);

parameter n=W/5;      // number of slices
parameter kw_size=5;    // DBLOCK64x5 key width size
parameter b_depth = 64;     // block depth

input [W-1:0] sk;
input reset;
input [D/8-1:0] we;
input [W*8/5-1:0] rules;
input clk;
output [D-1:0] match;

wire [n*D-1:0] match_l;
wire [6*D-1:0] match_and;


genvar i;

generate 
    for (i=0; i<n; i=i+1)
    begin:Width_extension
        (* dont_touch = "true" *) DBLOCK64x5 #(kw_size,D) DBLOCK64x5_inst (sk[i*5+4:i*5],reset,we,rules[i*8+7:i*8],clk,match_l[i*D+D-1:i*D]);
    end
endgenerate

(* dont_touch = "true" *) andD6 #(D) andD6_init(match_l[6*D-1:5*D],match_l[5*D-1:4*D],match_l[4*D-1:3*D],match_l[3*D-1:2*D],match_l[2*D-1:D],match_l[D-1:0],match_and[D-1:0]);
(* dont_touch = "true" *) andD6 #(D) andD6_init1(match_l[12*D-1:11*D],match_l[11*D-1:10*D],match_l[10*D-1:9*D],match_l[9*D-1:8*D],match_l[8*D-1:7*D],match_l[7*D-1:6*D],match_and[2*D-1:D]);
(* dont_touch = "true" *) andD6 #(D) andD6_init2(match_l[18*D-1:17*D],match_l[17*D-1:16*D],match_l[16*D-1:15*D],match_l[15*D-1:14*D],match_l[14*D-1:13*D],match_l[13*D-1:12*D],match_and[3*D-1:2*D]);
(* dont_touch = "true" *) andD6 #(D) andD6_init3(match_l[24*D-1:23*D],match_l[23*D-1:22*D],match_l[22*D-1:21*D],match_l[21*D-1:20*D],match_l[20*D-1:19*D],match_l[19*D-1:18*D],match_and[4*D-1:3*D]);
(* dont_touch = "true" *) andD6 #(D) andD6_init4(match_l[30*D-1:29*D],match_l[29*D-1:28*D],match_l[28*D-1:27*D],match_l[27*D-1:26*D],match_l[26*D-1:25*D],match_l[25*D-1:24*D],match_and[5*D-1:4*D]);
(* dont_touch = "true" *) andD2 #(D) andD2_init1(match_l[32*D-1:31*D],match_l[31*D-1:30*D],match_and[6*D-1:5*D]);
(* dont_touch = "true" *) andD6 #(D) andD6_init5(match_and[6*D-1:5*D],match_and[5*D-1:4*D],match_and[4*D-1:3*D],match_and[3*D-1:2*D],match_and[2*D-1:D],match_and[D-1:0],match);



endmodule
