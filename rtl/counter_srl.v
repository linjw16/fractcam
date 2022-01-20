`timescale 1ns / 1ps

/*
 * THE MODULE GENERATES SEL LINE FOR SRLs AND IT ALSO GENERATES THE FLAG WHEN ALL SRLs ARE FILLED
 */
module counter_srl (
	input wire wr,
	input wire reset,
	input wire clk,
	output [2:0] sel,
	output reg flag
	);

  reg [5:0] count={6{1'b0}};
  reg [8:0] count2={9{1'b0}};
  reg [2:0] sel = {3{1'b0}};

// SEL IS INCREMENTED AFTER 32 CLOCK CYCLES
	always @(posedge clk)
	begin
			if(reset | ~wr)
				count <= 0;
			else if (count==31)
				begin
				count <= 0;
				sel <= sel + 1'b1;
				end
			else begin
			count <= count + 1;
			end
	end

// GENERATES FLAG
	always @(posedge clk)
		begin
				if(reset | ~wr)
					begin
					flag <= 0;
					count2 <= 0;
					end
				else if (count2==287)
					begin
					count2 <= 0;
					flag <= 0;
					end
				else if (count2>=255)
					begin
					flag <= 1;
					count2 <= count2+1;
					end
				else begin
					flag <= 0;
					count2 <= count2 + 1;
				end
		end
endmodule
