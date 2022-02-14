# 
# Created on Mon Jan 17 2022
# 
# Copyright (c) 2022 IOA UCAS
# 
# @Filename:	 Makefile
# @Author:		 Jiawei Lin
# @Last edit:	 19:58:03
# 

TOPLEVEL_LANG = verilog

SIM ?= icarus
WAVES ?= 1

COCOTB_HDL_TIMEUNIT = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

DUT	= RAM32M
TOPLEVEL = $(DUT)
MODULE	= testbench

# FracTCAM
VERILOG_SOURCES += ../../rtl/sim/$(TOPLEVEL).v

# module parameters
export PARAM_INIT_A ?= $(shell printf %d 0x7FFFFFFFFFFFFFFF)
export PARAM_INIT_B ?= $(shell printf %d 0x7FFFFFFFFFFFFFFF)
export PARAM_INIT_C ?= $(shell printf %d 0x7FFFFFFFFFFFFFFF)
export PARAM_INIT_D ?= $(shell printf %d 0x7FFFFFFFFFFFFFFF)

ifeq ($(SIM), icarus)
	PLUSARGS += -fst

	COMPILE_ARGS += -P $(TOPLEVEL).INIT_A=$(PARAM_INIT_A)
	COMPILE_ARGS += -P $(TOPLEVEL).INIT_B=$(PARAM_INIT_B)
	COMPILE_ARGS += -P $(TOPLEVEL).INIT_C=$(PARAM_INIT_C)
	COMPILE_ARGS += -P $(TOPLEVEL).INIT_D=$(PARAM_INIT_D)

	ifeq ($(WAVES), 1)
		VERILOG_SOURCES += iverilog_dump.v
		COMPILE_ARGS += -s iverilog_dump
	endif

else ifeq ($(SIM), verilator)
	COMPILE_ARGS += -Wno-SELRANGE -Wno-WIDTH

	COMPILE_ARGS += -GINIT_A=$(PARAM_INIT_A)
	COMPILE_ARGS += -GINIT_B=$(PARAM_INIT_B)
	COMPILE_ARGS += -GINIT_C=$(PARAM_INIT_C)
	COMPILE_ARGS += -GINIT_D=$(PARAM_INIT_D)

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