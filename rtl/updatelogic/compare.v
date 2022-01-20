module compare(
	input  wire [4:0] sk,//key is used to write a rule
	input  wire [4:0] count,
	input  wire [7:0] srl_ce,
	input  wire  wclk,
	input  wire  wr,
	output[7:0] q,
	output [4:0] addr
	);
wire comparison;

(* dont_touch = "true" *) mux5bit mux_inst (count,sk,wr,addr);
(* dont_touch = "true" *) comparator #(5) comparator_inst(sk,count,comparison);
//(* dont_touch = "true" *) demux #(1,3,8) demux_inst(1,rule_id,srl_ce);
(* dont_touch = "true" *) srl_rf srl_rf_inst(comparison,wclk,srl_ce,q);

endmodule