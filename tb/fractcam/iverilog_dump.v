module iverilog_dump();
initial begin
	$dumpfile("fractcam_top.fst");
	$dumpvars(0, fractcam_top);
end
endmodule
