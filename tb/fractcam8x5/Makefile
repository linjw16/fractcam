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

DUT	= fractcam8x5
TOPLEVEL = $(DUT)
MODULE	= testbench

# FracTCAM
VERILOG_SOURCES += ../../rtl/fractcam/fractcam8x5.v
# FracTCAM sim
VERILOG_SOURCES += ../../rtl/sim/FDRE.v
VERILOG_SOURCES += ../../rtl/sim/LUT6.v
VERILOG_SOURCES += ../../rtl/sim/RAM32M.v
VERILOG_SOURCES += ../../rtl/sim/SRLC32E.v

# module parameters
export PARAM_TCAM_DEPTH ?= 8
export PARAM_TCAM_WIDTH ?= 5

ifeq ($(SIM), icarus)
	PLUSARGS += -fst

	COMPILE_ARGS += -P $(TOPLEVEL).TCAM_DEPTH=$(PARAM_TCAM_DEPTH)
	COMPILE_ARGS += -P $(TOPLEVEL).TCAM_WIDTH=$(PARAM_TCAM_WIDTH)

	ifeq ($(WAVES), 1)
		VERILOG_SOURCES += iverilog_dump.v
		COMPILE_ARGS += -s iverilog_dump
	endif

else ifeq ($(SIM), verilator)
	COMPILE_ARGS += -Wno-SELRANGE -Wno-WIDTH

	COMPILE_ARGS += -GTCAM_DEPTH=$(PARAM_TCAM_DEPTH)
	COMPILE_ARGS += -GTCAM_WIDTH=$(PARAM_TCAM_WIDTH)

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