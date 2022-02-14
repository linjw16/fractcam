#
# Created on Tue Jan 18 2022
#
# Copyright (c) 2022 IOA UCAS
#
# @Filename:	 testbench.py
# @Author:		 Jiawei Lin
# @Last edit:	 11:16:42
#

import itertools
import logging
import random
import sys
import os

import warnings
# warnings.filterwarnings("ignore")

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory
from cocotb.result import TestFailure, TestSuccess
from cocotb_bus.drivers import BitDriver


class FracTCAM8x5_TB(object):
	def __init__(self, dut, debug=True):
		level = logging.DEBUG if debug else logging.WARNING
		self.log = logging.getLogger("fractcamTB")
		self.log.setLevel(level)

		self.dut = dut
		self.expected_output = []
		self.TCAM_DEPTH = self.dut.TCAM_DEPTH.value
		self.TCAM_WIDTH = self.dut.TCAM_WIDTH.value
		self.log.debug("TCAM_WIDTH = %s", repr(self.TCAM_WIDTH))
		self.log.debug("TCAM_DEPTH = %s", repr(self.TCAM_DEPTH))

		cocotb.start_soon(Clock(dut.clk, 4, 'ns').start())

	def model(self, din): 	# TODO: 
		"""Model of FracTCAM"""
		addr = 0
		self.expected_output.append(addr)

	async def reset(self):
		self.dut.search_key.value = 0
		self.dut.wr_enable.value = 0
		self.dut.rules.value = 0
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
	tb = FracTCAM8x5_TB(dut)
	await tb.reset()
	# if config_coroutine is not None:	# TODO: config match rules
	# cocotb.fork(config_coroutine(tb.csr))

	tb.dut.search_key.value = 0x0
	tb.dut.rules.value = 0xFF
	tb.dut.wr_enable.value = 1
	await RisingEdge(tb.dut.clk)
	tb.dut.wr_enable.value = 0
	await RisingEdge(tb.dut.clk)
	tb.dut.search_key.value = 0x1F % (1 << tb.TCAM_WIDTH)
	await RisingEdge(tb.dut.clk)

	for din in data_in(0x21, 1, 0x0, 0x1F):
		tb.dut.search_key.value = din % (1 << tb.TCAM_WIDTH)
		await RisingEdge(tb.dut.clk)
		tb.log.debug("match = %s", repr(1))
		tb.log.debug(tb.dut.match)
	
	await RisingEdge(tb.dut.clk)



def incrementing_payload(times=4, length=8, min=1, max=255):
	data_set = bytes(itertools.islice(itertools.cycle(range(min, max+1)), times*length))
	for i in range(times):
		yield data_set[i] 


def random_payload(length=8, min=0, max=0x100):
	set = range(min, max)
	rand_set = random.sample(set, length)
	return bytes(itertools.islice(itertools.cycle(rand_set), length))


if cocotb.SIM_NAME:
	factory = TestFactory(run_test)
	# factory.add_option("data_in", [random_payload, incrementing_payload])
	factory.add_option("data_in", [incrementing_payload])
	factory.add_option("config_coroutine", [None])
	factory.generate_tests()
