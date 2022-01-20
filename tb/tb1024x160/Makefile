#
# Created on Wed Jan 05 2022
#
# Copyright (c) 2022 IOA UCAS
#
# @Filename:	Makefile
# @Author:		Jiawei Lin
# @Last edit:	10:24:40
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
VERILOG_SOURCES += ../../rtl/$(TOPLEVEL).v
VERILOG_SOURCES += ../../rtl/cont_signal.v
VERILOG_SOURCES += ../../rtl/counter_srl.v
VERILOG_SOURCES += ../../rtl/updatelogic/update_logic.v
VERILOG_SOURCES += ../../rtl/updatelogic/comparator.v
VERILOG_SOURCES += ../../rtl/updatelogic/counter.v
VERILOG_SOURCES += ../../rtl/updatelogic/mux5bit.v
VERILOG_SOURCES += ../../rtl/updatelogic/compare.v
VERILOG_SOURCES += ../../rtl/updatelogic/Demux.v
VERILOG_SOURCES += ../../rtl/updatelogic/srl_rf.v
VERILOG_SOURCES += ../../rtl/fractcam/andD2.v
VERILOG_SOURCES += ../../rtl/fractcam/andD2slice.v
VERILOG_SOURCES += ../../rtl/fractcam/andD6.v
VERILOG_SOURCES += ../../rtl/fractcam/and6.v
VERILOG_SOURCES += ../../rtl/fractcam/andD6slice.v
VERILOG_SOURCES += ../../rtl/fractcam/DBLOCK32X5.v
VERILOG_SOURCES += ../../rtl/fractcam/DBLOCK64x5.v
VERILOG_SOURCES += ../../rtl/fractcam/frac_tcam.v
VERILOG_SOURCES += ../../rtl/fractcam/fractcam1x6.v
# FracTCAM sim
VERILOG_SOURCES += ../../rtl/sim/FDRE.v
VERILOG_SOURCES += ../../rtl/sim/LUT6.v
VERILOG_SOURCES += ../../rtl/sim/RAM32M.v
VERILOG_SOURCES += ../../rtl/sim/SRLC32E.v

# module parameters
export PARAM_TCAM_DEPTH ?= 1024
export PARAM_TCAM_WIDTH ?= 160

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