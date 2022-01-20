`timescale 1ns / 1ps

module andD6 #(
	parameter D = 64
)(
	input  wire [D-1:0] a,
	input  wire [D-1:0] b,
	input  wire [D-1:0] c,
	input  wire [D-1:0] d,
	input  wire [D-1:0] e,
	input  wire [D-1:0] f,
	output wire [D-1:0] o
);

initial begin
	if(D/4*4 != D) begin
		$error("Error: Depth is not multiple of 4. (instance %m)");
		$finish;
	end
end

localparam n_andD6slice = D/4; // number of andD6 slices
genvar i;
generate
	for (i=0; i< n_andD6slice;i=i+1) begin: andD6slice
		(* dont_touch = "true" *) 
		andD6slice andD6slice_init(
			a[i*4+3:i*4],
			b[i*4+3:i*4],
			c[i*4+3:i*4],
			d[i*4+3:i*4],
			e[i*4+3:i*4],
			f[i*4+3:i*4],
			o[i*4+3:i*4]
		);
	end
endgenerate

endmodule
