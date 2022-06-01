## FracTCAM

This is an implementation of FracTCAM. Source file includes verilog example implementations of FracTCAM, exact table, longest prefix match table, and masked match table, along with some infrastructure and library modules. Testbench includes cocotb of most of the modules. 

I recommend to use fractcam.v as basic TCAM module. Comparing with the initial implementation, it provide backpressure mechanism for both search/match interfaces. The read/write logic for match rules are led out as conventional AXIL interface, the response delay are 32+1 and 32×2+1 cycles separately. The buffer registers are moved from RAM32M output to and0 output to alleviate route delay. Nevertheless, there are still some timing performance defect and it would be modifying for a while. 

```
./rtl/
	fractcam/		# // Basic dependent module and example implementation.
		and0.v			# Bitwise AND logic for arbitrary width and depth. 
		and6.v			# Bitwise AND logic for arbitrary depth with a width of 6. 
		and6x4.v		# Bitwise AND logic for with a width of 6 and a depth of 4. Utilized 4 LUT6. 
		fractcam8x5.v	# FracTCAM unit of width 5 depth 8. 
		fractcam_top.v	# Top module of FracTCAM that modified from initial implementation provided by inventor
		fractcam.v		# Parametrized fractcam with seach/match interface and refined read/write logic. 
	sim/			# Library module implementation for cocotb verification. (Ref: UG974)
		FDRE.v			# Register as D flip-flop. 
		LUT6.v			# Lookup Table as 32 bits large memory. 
		RAM32M.v		# SliceM (or CLB) that consist of four LUTs. 
		SRLC32E.v		# 32 bits wide shift-right-logic register. 
./tb/
	and0/			# All testbench has the same file structual. 
		Makefile
		testbench.py
		temp.gtkw
	em/
	fractcam/
	fractcam_top/
	fractcam8x5/
	RAM32M/
```

