#
# Created on Mon Jan 17 2022
#
# Copyright (c) 2022 IOA UCAS
#
# @Filename:	 testbench.py
# @Author:		 Jiawei Lin
# @Last edit:	 19:57:56
#

import itertools
import logging

import warnings
warnings.filterwarnings("ignore")

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory
# from cocotb.result import TestFailure

class RAM32M_TB(object):
	def __init__(self, dut, debug=True):
		self.dut = dut
		
		level = logging.DEBUG if debug else logging.WARNING
		self.log = logging.getLogger("RAM32M_TB")
		self.log.setLevel(level)

		cocotb.start_soon(Clock(dut.WCLK, 4, 'ns').start())

	async def reset(self):
		self.log.info("Reset begin...")
		self.dut.ADDRA.value = 0
		self.dut.ADDRB.value = 0
		self.dut.ADDRC.value = 0
		self.dut.ADDRD.value = 0
		self.dut.DIA.value = 0
		self.dut.DIB.value = 0
		self.dut.DIC.value = 0
		self.dut.DID.value = 0
		self.dut.WE.value = 0
		await RisingEdge(self.dut.WCLK)
		await RisingEdge(self.dut.WCLK)
		self.log.info("reset end")
	
	async def write(self, addrD=0x00, dinA=0x0, dinB=0x0, dinC=0x0, dinD=0x0):
		self.log.debug("Write begin...")
		self.dut.DIA.value = dinA
		self.dut.DIB.value = dinB
		self.dut.DIC.value = dinC
		self.dut.DID.value = dinD
		self.dut.ADDRD.value = addrD
		self.dut.WE.value = 1
		await RisingEdge(self.dut.WCLK)
		self.dut.WE.value = 0
		self.log.debug("Write end")


async def run_test(dut, config=None):
	tb = RAM32M_TB(dut)
	await tb.reset()
	E_DOA = 0xF0F0_E0E0_C0C0_8080
	for ADDRA in range(32):
		tb.dut.ADDRA.value = ADDRA
		await RisingEdge(tb.dut.WCLK)
		DOA = bytes(tb.dut.DOA.value)
		tb.log.debug("read_out = %s", DOA)
		tb.log.debug("read_out = %s", repr(DOA))

	await tb.write(0x10, 0b10, 0b10, 0b10)

	for ADDRB in range(32):
		tb.dut.ADDRB.value = ADDRB
		await RisingEdge(tb.dut.WCLK)
		DOB = bytes(tb.dut.DOB.value)
		tb.log.debug("read_out = %s", repr(DOB))


if cocotb.SIM_NAME:
	factory = TestFactory(run_test)
	factory.add_option("config", [None])
	factory.generate_tests()
