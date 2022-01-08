`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2019 09:27:59 PM
// Design Name: 
// Module Name: fractcam1x6
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


module fractcam8x5(
    input [4:0] sk,
    input clr,
    input we,
    input [7:0] rules,
    input wclk,
    output [7:0] match
    );
    
    wire [3:0] o5,o6;
    

       
//   RAM32M    : In order to incorporate this function into the design,
//   Verilog   : the following instance declaration needs to be placed
//  instance   : in the body of the design code.  The instance name
// declaration : (RAM32M_inst) and/or the port declarations within the
//    code     : parenthesis may be changed to properly reference and
//             : connect this function to the design.  All inputs
//             : and outputs must be connected.

//  <-----Cut code below this line---->

   // RAM32M: 32-deep by 8-wide Multi Port LUT RAM (Mapped to four SliceM LUT6s)
   //         Virtex-7
   // Xilinx HDL Language Template, version 2016.3
      
   (* H_SET = "uset0", RLOC = "X0Y0" *) (* dont_touch = "true" *)  RAM32M #(
      .INIT_A(64'h8000000800000000), // Initial contents of A Port
      .INIT_B(64'h8000000800000000), // Initial contents of B Port
      .INIT_C(64'h8000000800000000), // Initial contents of C Port
      .INIT_D(64'h8000000800000000)  // Initial contents of D Port
   ) RAM32M_inst (
      .DOA({o6[0],o5[0]}),     // Read port A 2-bit output
      .DOB({o6[1],o5[1]}),     // Read port B 2-bit output
      .DOC({o6[2],o5[2]}),     // Read port C 2-bit output
      .DOD({o6[3],o5[3]}),     // Read/write port D 2-bit output
      .ADDRA(sk), // Read port A 5-bit address input
      .ADDRB(sk), // Read port B 5-bit address input
      .ADDRC(sk), // Read port C 5-bit address input
      .ADDRD(sk), // Read/write port D 5-bit address input
      .DIA(rules[1:0]),     // RAM 2-bit data write input addressed by ADDRD, 
                     //   read addressed by ADDRA
      .DIB(rules[3:2]),     // RAM 2-bit data write input addressed by ADDRD, 
                     //   read addressed by ADDRB
      .DIC(rules[5:4]),     // RAM 2-bit data write input addressed by ADDRD, 
                     //   read addressed by ADDRC
      .DID(rules[7:6]),     // RAM 2-bit data write input addressed by ADDRD, 
                     //   read addressed by ADDRD
      .WCLK(wclk),   // Write clock input
      .WE(we)        // Write enable input
   );
   
   // End of RAM32M_inst instantiation
			
genvar i;
generate 
for (i=0; i<4; i=i+1)
begin:o5_o6_DFF
(* H_SET = "uset0", RLOC = "X0Y0" *) (* dont_touch = "true" *) (*BEL ="SLICE_X0Y0/BFF"*)FDRE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) FDRE_inst1 (
      .Q(match[i*2]),      // 1-bit Data output
      .C(wclk),      // 1-bit Clock input
      .CE(1'b1),    // 1-bit Clock enable input
      .R(clr),      // 1-bit Synchronous reset input
      .D(o5[i])       // 1-bit Data input
   );

 
   (* H_SET = "uset0", RLOC = "X0Y0" *) (* dont_touch = "true" *) (*BEL ="SLICE_X0Y0/BFF"*)FDRE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) FDRE_inst (
      .Q(match[(i*2)+1]),      // 1-bit Data output
      .C(wclk),      // 1-bit Clock input
      .CE(1'b1),    // 1-bit Clock enable input
      .R(clr),      // 1-bit Synchronous reset input
      .D(o6[i])       // 1-bit Data input
   );

   // End of FDRE_inst instantiation
end
endgenerate			
																		
endmodule
