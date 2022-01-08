module mux5bit(count,sk,s,addr);
input [4:0] count;
input [4:0] sk;
input s;
output [4:0] addr;

assign addr=(s)?count:sk;
endmodule

