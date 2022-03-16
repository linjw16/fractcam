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

DUT	= fractcam_top
TOPLEVEL = $(DUT)
MODULE	= testbench

# FracTCAM
VERILOG_SOURCES += ./$(TOPLEVEL).v
VERILOG_SOURCES += ../../rtl/fractcam/async_demux.v
VERILOG_SOURCES += ../../rtl/fractcam/update_logic.v
VERILOG_SOURCES += ../../rtl/fractcam/fractcam.v
VERILOG_SOURCES += ../../rtl/fractcam/fractcam8x5.v
VERILOG_SOURCES += ../../rtl/fractcam/and0.v
VERILOG_SOURCES += ../../rtl/fractcam/and6.v
VERILOG_SOURCES += ../../rtl/fractcam/andD6slice.v
# FracTCAM sim
VERILOG_SOURCES += ../../rtl/sim/FDRE.v
VERILOG_SOURCES += ../../rtl/sim/LUT6.v
VERILOG_SOURCES += ../../rtl/sim/RAM32M.v
VERILOG_SOURCES += ../../rtl/sim/SRLC32E.v

# module parameters
export PARAM_TCAM_DEPTH ?= 16
export PARAM_TCAM_WIDTH ?= 10
export PARAM_TCAM_WR_WIDTH ?= 8
export PARAM_INIT ?= 0

ifeq ($(SIM), icarus)
	PLUSARGS += -fst

	COMPILE_ARGS += -P $(TOPLEVEL).TCAM_DEPTH=$(PARAM_TCAM_DEPTH)
	COMPILE_ARGS += -P $(TOPLEVEL).TCAM_WIDTH=$(PARAM_TCAM_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).TCAM_WR_WIDTH=$(PARAM_TCAM_WR_WIDTH)
	COMPILE_ARGS += -P $(TOPLEVEL).INIT=$(PARAM_INIT)

	ifeq ($(WAVES), 1)
		VERILOG_SOURCES += iverilog_dump.v
		COMPILE_ARGS += -s iverilog_dump
	endif

else ifeq ($(SIM), verilator)
	COMPILE_ARGS += -Wno-SELRANGE -Wno-WIDTH

	COMPILE_ARGS += -GTCAM_DEPTH=$(PARAM_TCAM_DEPTH)
	COMPILE_ARGS += -GTCAM_WIDTH=$(PARAM_TCAM_WIDTH)
	COMPILE_ARGS += -GTCAM_WR_WIDTH=$(PARAM_TCAM_WR_WIDTH)
	COMPILE_ARGS += -GINIT=$(PARAM_INIT)

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