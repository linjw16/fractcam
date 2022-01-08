`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/01/2020 11:47:29 AM
// Design Name: 
// Module Name: update_logic
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

module update_logic #(parameter D=512,W=40,SN=2 )(
    input [W-1:0] sk,//key is used to write a rule 
//    input[2:0]  rule_id, // RULE ID to identify 8 rules in slice 
    input wclk, // CLOCK 
    input reset, 
    input wr, // WRITE ENABLE FOR UPDATE OF TCAM WORD
    input [SN-1:0] we_sel, // RULE_ID 
    output [W*8/5-1:0] DI, // DATA PINS TO BE CONNECTED WITH DI PINS OF LUTRAM OF fracTCAM 
    output [W-1:0] addr,   // ADDRESS FOR FRACTCAM
    output [D/8-1:0] we    // WRITE ENABLE PIN FOR FRACTCAM
    );
// wire [7:0] q [W/5-1:0];
wire[7:0] srl_ce, ce_demux;
//wire [N/8-1:0] we;
wire comparison; 
wire [4:0] count;
wire [2:0] sel_demux;
wire flag;
wire we_block;

// THE MODULE GENERATES SEL LINE FOR SRLs AND IT ALSO GENERATES THE FLAG WHEN ALL SRLs ARE FILLED
(* dont_touch = "true" *) counter_srl counter_srl_inst(wr,reset,wclk,sel_demux,flag);

// THE MODULE SELECTS CE_DEMUX ACCORDING TO SEL LINE FROM PREVIOUS MODULE
(* dont_touch = "true" *) demux #(1,3,8) demux_inst(wr,sel_demux,ce_demux);

// THE MODULE GENERATES CE FOR SRL AND ALSO GENERATE WE LINE FOR WE_DEMUX DEPENDS ON FLAG
(* dont_touch = "true" *) cont_signal contrl_inst (ce_demux,flag,wr,srl_ce,we_block );

// COUNTER
(* dont_touch = "true" *) counter #(5) counter_inst(wr,wclk,reset,count);
  
  
// COMPARES THE RULE WITH KEY  
  genvar i;
  generate 
     for (i=0;i<(W/5);i=i+1)
     begin : block_comparator
          (* dont_touch = "true" *) compare compare_inst (sk[5*(i+1)-1:5*i], count, srl_ce, wclk , wr, DI[8*(i+1)-1:8*i], addr[5*(i+1)-1:5*i]);
     end
  endgenerate
  
  // THIS IS WE_MUX, GENERATES WE FOR THE SLICE TO BE UPDATED
  (* dont_touch = "true" *) demux #(1,SN,D/8) demux_inst2(we_block,we_sel,we);

// // // // ======================================================== // // // //


endmodule
