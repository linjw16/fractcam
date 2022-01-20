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

import warnings
# warnings.filterwarnings("ignore")

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory
from cocotb.result import TestFailure, TestSuccess
from cocotb_bus.drivers import BitDriver


class and0_TB(object):
	def __init__(self, dut, debug=True):
		self.dut = dut
		self.expected_output = []

		level = logging.DEBUG if debug else logging.WARNING
		self.log = logging.getLogger("TB")
		self.log.setLevel(level)

		cocotb.start_soon(Clock(dut.clk, 4, 'ns').start())

	def model(self, din):
		"""Model of FracTCAM"""
		WIDTH = self.dut.WIDTH
		DEPTH = self.dut.DEPTH
		self.log.debug("WIDTH = %s", repr(WIDTH))
		self.log.debug("DEPTH = %s", repr(DEPTH))
		out_1 = 0xFFFF
		for i in range(len(din)):
			din_i[i] = din >> (i*DEPTH)
			out_1 = out_1 & din_i[i]
		self.expected_output.append(out_1)
		return out_1

	async def reset(self):
		self.dut.in_1.value = 0
		self.log.info("Reset begin...")
		self.dut.rst.setimmediatevalue(0)
		# await RisingEdge(self.dut.clk)
		# await RisingEdge(self.dut.clk)
		# self.dut.rst <= 1
		# await RisingEdge(self.dut.clk)
		# await RisingEdge(self.dut.clk)
		# self.dut.rst.value = 0
		await RisingEdge(self.dut.clk)
		await RisingEdge(self.dut.clk)
		self.log.info("reset end")


async def run_test(dut, data_in=None, config_coroutine=None):
	tb = and0_TB(dut)
	await tb.reset()
	# if config_coroutine is not None:	# TODO: config match rules
	# cocotb.fork(config_coroutine(tb.csr))

	tb.dut.in_1.value = 0xFFFFFF
	await RisingEdge(tb.dut.clk)

	for din in [data_in(3) for x in range(0, 0xFF, 0xF)]:
		tb.dut.in_1.value = int.from_bytes(din, byteorder='big')
		await RisingEdge(tb.dut.clk)
		out_1 = tb.dut.out_1.value
		assert out_1 == tb.model(din)
		tb.log.debug("AND = %s", repr(out_1))


def incrementing_payload(length=8, min=1, max=255):
	return bytes(itertools.islice(itertools.cycle(range(min, max+1)), length))


def random_payload(length=8, min=0, max=0x100):
	set = range(min, max)
	rand_set = random.sample(set, length)
	return bytes(itertools.islice(itertools.cycle(rand_set), length))


if cocotb.SIM_NAME:
	factory = TestFactory(run_test)
	# factory.add_option("data_in", [random_payload, incrementing_payload])
	factory.add_option("data_in", [random_payload])
	factory.add_option("config_coroutine", [None])
	factory.generate_tests()
