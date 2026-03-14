import m5
from m5.objects import *

# --- 1. The Virtual Motherboard ---
system = System()

# --- 2. The Clock Generator ---
system.clk_domain = SrcClockDomain()
system.clk_domain.clock = '1GHz'
system.clk_domain.voltage_domain = VoltageDomain()

# --- 3. The Physical Memory Setup ---
system.mem_mode = 'timing'
system.mem_ranges = [AddrRange('512MB')]

# --- 4. The CPU ---
system.cpu = YarpCore()

# --- 5. The System Bus ---
system.membus = SystemXBar()

# --- 6. Wiring it up ---
system.cpu.icache_port = system.membus.cpu_side_ports
system.cpu.dcache_port = system.membus.cpu_side_ports
system.system_port     = system.membus.cpu_side_ports

# --- 7. The RAM ---
system.mem_ctrl = MemCtrl()
system.mem_ctrl.dram = DDR3_1600_8x8()
system.mem_ctrl.dram.range = system.mem_ranges[0]
system.mem_ctrl.port = system.membus.mem_side_ports

# --- 8. Bare Metal Workload ---
# RiscvBareMetal loads the ELF into simulated memory and
# sets the CPU start address to the ELF entry point (0x000)
# auto_reset_vect=True means it automatically uses the ELF
# entry point, so reset_vect parameter is ignored
system.workload = RiscvBareMetal()
system.workload.bootloader = "/home/dalab/gem5/program_0.elf"
system.workload.auto_reset_vect = True

# --- 9. Booting up! ---
root = Root(full_system=True, system=system)
m5.instantiate()

print("Powering on — bare metal program loaded!")
print("Entry point: 0x00 (matches RTL RESET_PC)")
print("Starting simulation...")

exit_event = m5.simulate(10000000)  # enough ticks for loop to complete

print(f"\nSimulation stopped at tick {m5.curTick()}")
print(f"Reason: {exit_event.getCause()}")
