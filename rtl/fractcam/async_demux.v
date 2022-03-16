/*
 * Created on Mon Feb 14 2022
 *
 * Copyright (c) 2022 IOA UCAS
 *
 * @Filename:	 async_demux.v
 * @Author:		 Jiawei Lin
 * @Last edit:	 15:54:19
 */

module async_demux #(
	parameter DATA_WIDTH = 8,
	parameter ADDR_WIDTH = $clog2(COUNT),
	parameter COUNT  = 16
) (
  input  wire [DATA_WIDTH-1:0] data_in,
  input  wire [ADDR_WIDTH-1:0] select,
  output wire [COUNT*DATA_WIDTH-1:0] data_out
);

reg [COUNT*DATA_WIDTH-1:0] data_cur = {COUNT*DATA_WIDTH{1'b0}};

assign data_out = data_cur << ( select*DATA_WIDTH);

always @(*) begin 
	data_cur = {{(COUNT-1)*DATA_WIDTH{1'b0}}, data_in};
end

endmodule