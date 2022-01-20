module mux5bit(count,sk,s,addr);
input  wire [4:0] count;
input  wire [4:0] sk;
input  wire s;
output [4:0] addr;

assign addr=(s)?count:sk;
endmodule

