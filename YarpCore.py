# -*- coding: utf-8 -*-
# gem5 v25.1 Python Blueprint — YARP RISC-V Core (Full-System mode)
# File: src/cpu/riscv_cached/YarpCore.py

from m5.params import *
from m5.proxy  import *
from m5.SimObject import SimObject

class YarpCore(SimObject):
    """
    Verilated YARP RISC-V core SimObject for Full-System simulation.

    Two RequestPorts connect directly to gem5's memory bus:
      icache_port  →  instruction fetch (128-bit / 16-byte cache lines)
      dcache_port  →  data read/write

    Wire these in your run script:
        core = YarpCore()
        core.icache_port = system.membus.cpu_side_ports
        core.dcache_port = system.membus.cpu_side_ports
    """

    type       = 'YarpCore'
    cxx_class  = 'gem5::YarpCore'
    cxx_header = 'cpu/riscv_cached/yarp_core_wrapper.hh'

    # ------------------------------------------------------------------ #
    # Memory ports (connect to gem5 memory bus in run script)             #
    # ------------------------------------------------------------------ #
    icache_port = RequestPort("Instruction memory port — connects to membus")
    dcache_port = RequestPort("Data memory port — connects to membus")

    # ------------------------------------------------------------------ #
    # System back-reference (required to get RequestorID)                 #
    # ------------------------------------------------------------------ #
    system = Param.System(Parent.any, "The system this CPU belongs to")

    # ------------------------------------------------------------------ #
    # Clock / reset                                                        #
    # ------------------------------------------------------------------ #
    # How many RTL cycles to hold reset_n LOW at start of simulation.
    reset_cycles = Param.Unsigned(8, "Cycles reset_n is asserted low")

    # Ticks per RTL clock cycle (1 tick = 1 ps in gem5).
    # Default: 1000 ticks = 1 ns = 1 GHz
    clock_period_ticks = Param.Unsigned(1000,
        "RTL clock period in gem5 ticks (1 tick = 1 ps)")

    # ------------------------------------------------------------------ #
    # Stats / debug                                                        #
    # ------------------------------------------------------------------ #
    dump_retire_stats = Param.Bool(True,
        "Print retire_count and IPC summary at end of simulation")
