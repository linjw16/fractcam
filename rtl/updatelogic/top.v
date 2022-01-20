`timescale 1ns / 1ps

//In dure rule_size is equaivalent to D and key to W

module top #(parameter D=64,W=160)(sk,clk,wr,reset,we_sel,match_reduced);
input  wire [W-1:0] sk; //search key
input  wire clk,wr;
input  wire reset;
input  wire [SN-1:0] we_sel;
output match_reduced;

parameter N=D/8;
parameter SN = clog2(D/8);
parameter rb=W*8/5;

(*max_fanout=50*) wire[D-1:0] match; // match lines
(*max_fanout=50*) wire[W*8/5-1:0] DI ;
(*max_fanout=50*) wire[W-1:0] addr;
(*max_fanout=50*) wire[D/8-1:0] we;
 //key =40, rules = 64 for unprotected version

(* dont_touch = "true" *) update_logic #(D,W,SN)update_inst (sk,clk,reset,wr,we_sel,DI,addr,we);
(* dont_touch = "true" *)frac_tcam #(W,D,rb) frac_tcam_inst(addr,reset,we,DI,clk,match);
//(* dont_touch = "true" *)register #(D) match_register(match,clk2,reset,match_reg);
(* dont_touch = "true" *)match_reduction #(D) match_reduction_inst(match,match_reduced);

// // // // ======================================================== // // // //

function integer clog2 (input integer n);
integer j;
begin
	n = n - 1;
	for (j = 0; n > 0; j = j + 1)
		n = n >> 1;
	clog2 = j;
end
endfunction

endmodule
