# 
# Created on Tue Jan 18 2022
# 
# Copyright (c) 2022 IOA UCAS
# 
# @Filename:	 Makefile
# @Author:		 Jiawei Lin
# @Last edit:	 10:13:11
# 

TOPLEVEL_LANG = verilog

SIM ?= icarus
WAVES ?= 1

COCOTB_HDL_TIMEUNIT = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

DUT	= and0
TOPLEVEL = dut
MODULE	= testbench

VERILOG_SOURCES += dut.v
VERILOG_SOURCES += ../../rtl/fractcam/and0.v
VERILOG_SOURCES += ../../rtl/fractcam/and6.v
VERILOG_SOURCES += ../../rtl/fractcam/andD6slice.v
# FracTCAM sim
VERILOG_SOURCES += ../../rtl/sim/FDRE.v
VERILOG_SOURCES += ../../rtl/sim/LUT6.v
VERILOG_SOURCES += ../../rtl/sim/RAM32M.v
VERILOG_SOURCES += ../../rtl/sim/SRLC32E.v

# module parameters
export PARAM_DEPTH ?= 8
export PARAM_WIDTH ?= 12

ifeq ($(SIM), icarus)
	PLUSARGS += -fst

	COMPILE_ARGS += -P $(TOPLEVEL).DEPTH=$(PARAM_DEPTH)
	COMPILE_ARGS += -P $(TOPLEVEL).WIDTH=$(PARAM_WIDTH)

	ifeq ($(WAVES), 1)
		VERILOG_SOURCES += iverilog_dump.v
		COMPILE_ARGS += -s iverilog_dump
	endif

else ifeq ($(SIM), verilator)
	COMPILE_ARGS += -Wno-SELRANGE -Wno-WIDTH

	COMPILE_ARGS += -GDEPTH=$(PARAM_DEPTH)
	COMPILE_ARGS += -GWIDTH=$(PARAM_WIDTH)

	# COMPILE_ARGS += -I $(HEADER_FILES)

	ifeq ($(WAVES), 1)
		COMPILE_ARGS += --trace-fst
	endif

endif

include $(shell cocotb-config --makefiles)/Makefile.sim

iverilog_dump.v:
	echo 'module iverilog_dump();' > $@
	echo 'initial begin' >> $@
	echo '	$$dumpfile("$(TOPLEVEL).fst");' >> $@
	echo '	$$dumpvars(0, $(TOPLEVEL));' >> $@
	echo 'end' >> $@
	echo 'endmodule' >> $@

clean::
	@rm -rf iverilog_dump.v
	@rm -rf dump.fst $(TOPLEVEL).fst
	@rm -rf *.xml .fuse*
	@rm -rf __pycache__