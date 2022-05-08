#
# Created on Tue May 03 2022
#
# Copyright (c) 2022 IOA UCAS
#
# @Filename:	 testbench.py
# @Author:		 Jiawei Lin
# @Last edit:	 01:28:09
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
		self.DATA_WIDTH = self.dut.DATA_WIDTH.value
		self.SLICEM_ROWS = self.dut.SLICEM_ROWS.value
		self.ADDR_WIDTH = self.dut.ADDR_WIDTH.value
		self.log.debug("TCAM_DEPTH = %s", repr(self.TCAM_DEPTH))
		self.log.debug("TCAM_WIDTH = %s", repr(self.TCAM_WIDTH))
		self.log.debug("DATA_WIDTH = %s", repr(self.DATA_WIDTH))
		self.log.debug("SLICEM_ROWS = %s", repr(self.SLICEM_ROWS))
		self.log.debug("ADDR_WIDTH = %s", repr(self.ADDR_WIDTH))
		self.log.debug("INIT = %s", repr(self.dut.INIT))
		self.tcam_dict = {}
		self.tcam_list = [set()]*self.TCAM_DEPTH

		cocotb.start_soon(Clock(dut.clk, 4, 'ns').start())

	async def reset(self):
		await RisingEdge(self.dut.clk)
		await RisingEdge(self.dut.clk)
		self.dut.search_key.value = 0
		self.dut.wr_addr.value = 0
		self.dut.wr_data.value = 0
		self.dut.wr_keep.value = 0
		self.dut.wr_valid.value = 0
		self.dut.rd_cmd_addr = 0
		self.dut.rd_cmd_valid = 0
		self.dut.rd_rsp_ready = 0
		self.dut.search_valid = 0
		self.dut.match_ready = 1

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

	def model_wr(self, wr_addr=0, wr_data=0, wr_keep=0, idx=0):
		while(wr_keep & (1 << idx)):
			idx = idx+1
		if(idx == self.DATA_WIDTH):
			set_1 = self.tcam_dict.get(wr_data, set())
			set_1.add(wr_addr)
			self.tcam_dict[wr_data] = set_1
			# print("tcam_dict[%03X] = %s" % (wr_data, repr(set_1)))
			set_2 = self.tcam_list[wr_addr]
			set_2.add(wr_data)
			self.tcam_list[wr_addr] = set_2
			# print("tcam_list[%03X] = %s" % (wr_addr, repr(set_2)))
		else:
			self.model_wr(wr_addr, wr_data, wr_keep, idx+1)
			self.model_wr(wr_addr, wr_data ^ (1 << idx), wr_keep, idx+1)

	async def write(self, wr_addr=0, wr_data=range(8), wr_keep=range(8)):
		wr_data_1 = 0
		wr_keep_1 = 0
		for i in range(8):
			wr_addr_i = (((wr_addr % self.TCAM_DEPTH)>>3)<<3) + i
			wr_data_1 += wr_data[i] << (i*self.DATA_WIDTH)
			wr_keep_1 += wr_keep[i] << (i*self.DATA_WIDTH)
			set_2 = self.tcam_list[wr_addr_i]
			for sk in set_2:
				set_1 = self.tcam_dict[sk].discard(wr_addr_i)
			self.tcam_list[wr_addr_i] = set()
			self.model_wr(wr_addr_i, wr_data[i], wr_keep[i])

		self.dut.wr_addr.value = wr_addr
		self.dut.wr_valid.value = 1
		self.dut.wr_data.value = wr_data_1
		self.dut.wr_keep.value = wr_keep_1
		await RisingEdge(self.dut.clk)
		self.dut.wr_valid.value = 0
		await RisingEdge(self.dut.rd_cmd_ready)
		for _ in range(2):
			await RisingEdge(self.dut.clk)

	async def read(self, rd_addr=0):
		self.dut.rd_cmd_addr.value = rd_addr
		self.dut.rd_cmd_valid.value = 1
		while not self.dut.rd_cmd_ready.value:
			await RisingEdge(self.dut.clk)
		await RisingEdge(self.dut.clk)
		self.dut.rd_cmd_valid.value = 0

		self.dut.rd_rsp_ready.value = 1
		await RisingEdge(self.dut.rd_rsp_valid)
		await RisingEdge(self.dut.clk)
		rd_data = self.dut.rd_rsp_data.value
		rd_keep = self.dut.rd_rsp_keep.value
		self.dut.rd_rsp_ready.value = 0
		return [rd_data, rd_keep]


async def run_test(dut, search_key=None, data_in=None, config_coroutine=None):
	tb = FracTCAM_TB(dut)
	await tb.reset()
	# if config_coroutine is not None:	# TODO: config match rules
	# cocotb.fork(config_coroutine(tb.csr))

	for idx,wr_data in enumerate(data_in(tb.TCAM_DEPTH//8, 8, 0x0, 1 << tb.DATA_WIDTH)):
		wr_keep = [(1<<tb.DATA_WIDTH)-1]*8
		await tb.write(idx<<3, wr_data, wr_keep)
		await RisingEdge(tb.dut.clk)
		tb.log.debug("tcam_dict:"+str(tb.tcam_dict))
		tb.log.debug("tcam_list:"+str(tb.tcam_list))

	wr_data = [0b00001, 0b00011, 0b00111, 0b01111,
            0b11111, 0b11110, 0b11100, 0b11000]
	wr_keep = [(1 << tb.DATA_WIDTH)-1]*8
	wr_keep[-1] = ((1 << tb.DATA_WIDTH)-1)-0b11000
	await tb.write(0, wr_data, wr_keep)
	tb.log.debug("tcam_dict:"+str(tb.tcam_dict))
	tb.log.debug("tcam_list:"+str(tb.tcam_list))

	for i in range(tb.TCAM_DEPTH):
		[rd_data, rd_keep] = await tb.read(i)
		try:
			assert (int(rd_data) in tb.tcam_list[i])
		except AssertionError:
			tb.log.debug("tcam[%02X] = (%s, %s)" %
		             (i, format(int(rd_data), '010b'), format(int(rd_keep), '010b')))
			input("\n\n\t Push any key...")

	for din in range(1<<tb.DATA_WIDTH):
		key_1 = din % (1 << tb.DATA_WIDTH)
		tb.dut.search_key.value = key_1
		tb.dut.search_valid.value = 1
		while not (tb.dut.search_ready.value):
			await RisingEdge(tb.dut.clk)
		await RisingEdge(tb.dut.clk)
		tb.dut.search_valid.value = 0
		await RisingEdge(tb.dut.clk)
		await FallingEdge(tb.dut.clk)
		match = tb.dut.match_line.value
		expected_addr = tb.tcam_dict.get(key_1, {tb.TCAM_DEPTH+1})
		expected_match = 0
		for i in expected_addr:
			expected_match = expected_match + (1 << i) % (1 << tb.TCAM_DEPTH)
		if(match):
			tb.log.debug("search_key = %s\t match = %s\t expected_match = %s",
		             bin(key_1)[2:], repr(match), format(expected_match, '016b'))

		try:
			assert (match & expected_match) if (
			match and expected_match) else not (match or expected_match)
		except AssertionError:
			tb.log.debug("search_key = %s\t match = %s\t expected_match = %s",
		             bin(key_1)[2:], repr(match), format(expected_match, '016b'))
			input("\n\n\t Push any key...")
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
