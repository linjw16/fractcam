`timescale 1ns / 1ps

/*
 * THE MODULE GENERATES CE FOR SRL AND ALSO GENERATE WE LINE FOR WE_DEMUX DEPENDS ON FLAG
 */
module cont_signal(
	input wire [7:0] ce_demux,
	input wire flag,
	input wire wr_in,
	output [7:0] ce,
	output we_block
	);

// GENERATES VALID CE AND WE LINE FOR SRLs AND WE_DEMUX
	genvar i;
	generate
			for (i=0; i<8; i=i+1)
		begin: CE_demux
		or(ce[i], ce_demux[i] , flag);
		end
	endgenerate
	assign we_block = wr_in & flag;

endmodule
