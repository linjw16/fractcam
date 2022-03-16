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
from cocotb.triggers import RisingEdge, FallingEdge
from cocotb.regression import TestFactory
from cocotb.result import TestFailure, TestSuccess


class FracTCAM_TB(object):
	def __init__(self, dut, debug=True):
		level = logging.DEBUG if debug else logging.WARNING
		self.log = logging.getLogger("fractcamTB")
		self.log.setLevel(level)

		self.dut = dut
		self.TCAM_DEPTH = self.dut.TCAM_DEPTH.value
		self.TCAM_WIDTH = self.dut.TCAM_WIDTH.value
		self.TCAM_WR_WIDTH = self.dut.TCAM_WR_WIDTH.value
		self.SLICEM_ROWS = self.dut.SLICEM_ROWS.value
		self.SLICEM_ADDR_WIDTH = self.dut.SLICEM_ADDR_WIDTH.value
		self.log.debug("TCAM_DEPTH = %s", repr(self.TCAM_DEPTH))
		self.log.debug("TCAM_WIDTH = %s", repr(self.TCAM_WIDTH))
		self.log.debug("TCAM_WR_WIDTH = %s", repr(self.TCAM_WR_WIDTH))
		self.log.debug("SLICEM_ROWS = %s", repr(self.SLICEM_ROWS))
		self.log.debug("SLICEM_ADDR_WIDTH = %s", repr(self.SLICEM_ADDR_WIDTH))
		self.log.debug("INIT = %s", repr(self.dut.INIT))
		self.wr_addr_ptr = 0
		self.tcam_dict = {}
		self.tcam_list = [set()]*self.TCAM_DEPTH

		cocotb.start_soon(Clock(dut.clk, 4, 'ns').start())

	async def reset(self):
		await RisingEdge(self.dut.clk)
		await RisingEdge(self.dut.clk)
		self.dut.search_key.value = 0
		self.dut.wr_slicem_addr.value = 0
		self.dut.wr_valid.value = 0
		self.dut.wr_tcam_data.value = 0
		self.dut.wr_tcam_keep.value = 0
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

	def model_wr(self, wr_data=0, wr_keep=0, idx=0):
		while(wr_keep & (1 << idx)):
			idx = idx+1
		if(idx == self.TCAM_WR_WIDTH):
			set_1 = self.tcam_dict.get(wr_data, set())
			set_1.add(self.wr_addr_ptr)
			self.tcam_dict[wr_data] = set_1
			set_2 = self.tcam_list[self.wr_addr_ptr]
			set_2.add(wr_data)
			self.tcam_list[self.wr_addr_ptr] = set_2
		else:
			self.model_wr(wr_data, wr_keep, idx+1)
			self.model_wr(wr_data ^ (1 << idx), wr_keep, idx+1)

	async def write(self, wr_data=range(8), wr_keep=range(8)):
		wr_data_1 = 0
		wr_keep_1 = 0
		for i in range(8):
			wr_data_1 += wr_data[i] << (i*self.TCAM_WR_WIDTH)
			wr_keep_1 += wr_keep[i] << (i*self.TCAM_WR_WIDTH)

			# self.tcam_dict[wr_data[i]] = (self.wr_addr_ptr // 0x1000)*8+i
			set_2 = self.tcam_list[self.wr_addr_ptr]
			for sk in set_2:
				set_1 = self.tcam_dict[sk].discard(self.wr_addr_ptr)
			self.tcam_list[self.wr_addr_ptr] = set()
			self.model_wr(wr_data[i], wr_keep[i])
			self.wr_addr_ptr = (self.wr_addr_ptr+1) % (int(self.TCAM_DEPTH/8) << 3)

		# self.wr_addr_ptr = self.wr_addr_ptr + 0x1000
		self.dut.wr_slicem_addr.value = (
			self.wr_addr_ptr-1) // 0x1000 % int(self.TCAM_DEPTH/8)
		self.dut.wr_valid.value = 1
		self.dut.wr_tcam_data.value = wr_data_1
		self.dut.wr_tcam_keep.value = wr_keep_1
		await RisingEdge(self.dut.clk)
		self.dut.wr_valid.value = 0
		for _ in range(32*9):
			await RisingEdge(self.dut.clk)
	# async def write(self, wr_data=range(8)):
	# 	self.dut.wr_slicem_addr.value = self.wr_addr_ptr // 0x8
	# 	self.wr_addr_ptr = self.wr_addr_ptr + 1
	# 	self.dut.wr_valid.value = 1
	# 	for i in range(8):
	# 		self.tcam_dict[wr_data[i]] = i
	# 		self.dut.search_key.value = wr_data[i]
	# 		for _ in range(32):
	# 			await RisingEdge(self.dut.clk)
	# 	for _ in range(32):
	# 		await RisingEdge(self.dut.clk)
	# 	self.dut.wr_valid.value = 0


async def run_test(dut, search_key=None, data_in=None, config_coroutine=None):
	tb = FracTCAM_TB(dut)
	await tb.reset()
	# if config_coroutine is not None:	# TODO: config match rules
	# cocotb.fork(config_coroutine(tb.csr))

	for wr_data in data_in(int(tb.TCAM_DEPTH/8), 8, 0x0, 1 << tb.TCAM_WR_WIDTH):
		wr_keep = [(1<<tb.TCAM_WR_WIDTH)-1]*8
		await tb.write(wr_data, wr_keep)
		await RisingEdge(tb.dut.clk)
		tb.log.debug(str(tb.tcam_dict))
		tb.log.debug(str(tb.tcam_list))

	wr_data = [0b00001, 0b00010, 0b00100, 0b01000,
            0b10000, 0b00011, 0b00111, 0b01111]
	wr_keep = [(1 << tb.TCAM_WR_WIDTH)-1]*8
	wr_keep[-1] = 0b00100
	await tb.write(wr_data, wr_keep)
	tb.log.debug(str(tb.tcam_dict))
	
	for din in range(1<<tb.TCAM_WR_WIDTH):
		key_1 = din % (1 << tb.TCAM_WR_WIDTH)
		tb.dut.search_key.value = key_1
		await RisingEdge(tb.dut.clk)
		await FallingEdge(tb.dut.clk)
		match = tb.dut.match.value
		expected_addr = tb.tcam_dict.get(key_1, {tb.TCAM_DEPTH+1})
		expected_match = 0
		for i in expected_addr:
			expected_match = expected_match + (1 << i) % (1 << tb.TCAM_DEPTH)
		if(match):
			tb.log.debug("search_key = %s\t match = %s\t expected_match = %s", bin(key_1)[2:], repr(match), bin(expected_match)[2:])
		try:
			assert (match & expected_match) if (
			match and expected_match) else not (match or expected_match)
		except AssertionError:
			tb.log.debug("Error\nsearch_key = %s\t match = %s\t expected_match = %s",
			             bin(key_1)[2:], repr(match), bin(expected_match)[2:])
			return
	await RisingEdge(tb.dut.clk)


def incrementing_payload(times=4, length=8, min=1, max=255):
	data_set = bytes(itertools.islice(itertools.cycle(range(min, max+1)), times*length))
	for i in range(times):
		yield data_set[i] 


def random_payload(times=4, length=8, min=0, max=0x100):
	set = range(min, max)
	for i in range(times):
		yield random.sample(set, length)


if cocotb.SIM_NAME:
	factory = TestFactory(run_test)
	factory.add_option("data_in", [random_payload])
	factory.add_option("search_key", [incrementing_payload])
	factory.add_option("config_coroutine", [None])
	factory.generate_tests()
