`timescale 1ns / 1ps

module fractcam_tb;
reg clk,wr;
reg reset;
wire  match_reduced;
reg [159:0] sk; //search key
reg [6:0] we_sel=7'd0;

(* dont_touch = "true" *) top #(1024,160) top_inst (sk,clk,wr,reset,we_sel,match_reduced);

//====================================================//

initial begin
clk=0;
forever #1 clk=~clk;
end

initial begin
reset=1;
#100;
reset=0;
wr = 0;
we_sel = 7'd0;

// reading of Fractcam
 // #2 is the clock periode

		sk = 160'd00; #2;
		sk = 160'd03; #2;
		sk = 160'd20; #2;
		sk = 160'd30; #2;
		sk = 160'd17; #2;
//	end

// Writng the srl of update logic
// I want to check the functionality of the update. For that reason i kept the sk=17 for all SRLs.
//i know it may wrong for real but just want to check the functionality
// As SRLs are initiated by 00 so the location at sk=17 should be 1 for all 8 srls. and the rest contents of SRLs should be 0.

	wr = 1; #576; // 576 is equal to clock_period(2)x number of clock cycles required for update (32 x8 + 32)

// reading the FRACTCAM again
// the same location are read again. if the update logic works fine the we should get match_reduced 0 for all other location except sk=17

	wr = 0;
	sk = 160'd00; #2;
	sk = 160'd03; #2;
	sk = 160'd20; #2;
	sk = 160'd30; #2;
	sk = 160'd17; #2;

	wr = 0;
	we_sel = 7'd2;
	sk = 160'd00; #2;
	sk = 160'd03; #2;
	sk = 160'd20; #2;
	sk = 160'd30; #2;
	sk = 160'd17; #2;

end

endmodule
