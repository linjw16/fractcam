`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/31/2020 10:12:08 AM
// Design Name: 
// Module Name: cont_signal
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


module cont_signal(
    input [7:0] ce_demux,
    input flag,
    input wr_in,
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
