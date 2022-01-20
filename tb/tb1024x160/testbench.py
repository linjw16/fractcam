#
# Created on Sun Jan 16 2022
#
# Copyright (c) 2022 IOA UCAS
#
# @Filename:	testbench.py
# @Author:		Jiawei Lin
# @Last edit:	15:11:00
#

import itertools
import logging

import warnings
# warnings.filterwarnings("ignore")

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory
from cocotb.result import TestFailure, TestSuccess
from cocotb_bus.drivers import BitDriver

class FracTCAM_TB(object):
	def __init__(self, dut, debug=True):
		self.dut = dut
		self.expected_output = []

		level = logging.DEBUG if debug else logging.WARNING
		self.log = logging.getLogger("fractcamTB")
		self.log.setLevel(level)

		cocotb.start_soon(Clock(dut.clk, 4, 'ns').start())

	def model(self, din):
		"""Model of FracTCAM"""
		addr = 0
		self.expected_output.append(addr)

	async def reset(self):
		self.dut.search_key.value = 0
		self.dut.wr_en_sel.value = 0
		self.dut.wr_en.value = 0
		self.log.info("Reset begin...")
		self.dut.rst.setimmediatevalue(0)
		await RisingEdge(self.dut.clk)
		await RisingEdge(self.dut.clk)
		self.dut.rst <= 1
		await RisingEdge(self.dut.clk)
		await RisingEdge(self.dut.clk)
		self.dut.rst.value = 0
		await RisingEdge(self.dut.clk)
		await RisingEdge(self.dut.clk)
		self.log.info("reset end")

async def run_test(dut, data_in=None, config_coroutine=None):
	tb = FracTCAM_TB(dut)
	await tb.reset()
	# if config_coroutine is not None:	# TODO: config match rules
		# cocotb.fork(config_coroutine(tb.csr))

	for din in [data_in() for x in range(4)]:
		tb.dut.search_key.value = int.from_bytes(din, byteorder='big')
		await RisingEdge(tb.dut.clk)
		tb.log.debug("match = %s", repr(1))
		tb.log.debug(tb.dut.match_line)

def incrementing_payload(length=4):
	return bytes(itertools.islice(itertools.cycle(range(1, 256)), length))

if cocotb.SIM_NAME:
	factory = TestFactory(run_test)
	factory.add_option("data_in", [incrementing_payload])
	factory.add_option("config_coroutine", [None])
	factory.generate_tests()
