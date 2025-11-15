# 🧠 Custom RISC-V Core

This project implements a **Single-Cycle RISC-V Core** built completely from scratch using **SystemVerilog**.
The core consists of all fundamental CPU components — Instruction Memory, Decode Unit, Register File, Execute Unit, Data Memory, Control Unit, Branch Control Unit, and a Program Counter Register.

---

## 🏗️ Core Architecture Diagram

Below is the complete architectural block diagram of the RISC-V processor, including the Instruction Cache, Data Cache, and Core Pipeline structure:

![RISC-V Core Architecture](RISC-V Core(1).png)

> *Replace `RISC-V_Architecture.png` with your actual architecture diagram PNG filename.*

---

## 🚀 Overview

The RISC-V Core follows a **single-cycle** architecture where each instruction is executed in one clock cycle.
The design aims to maintain modularity and clarity, making it easier to extend into a pipelined version later.

### **Core Components**

* **Instruction Memory** – stores program instructions in HEX format.
* **Decode Unit** – decodes the fetched instruction and identifies the operation type.
* **Register File** – holds 32 general-purpose registers with read/write access.
* **ALU / Execute Unit** – performs arithmetic and logical operations.
* **Data Memory** – handles load/store instructions.
* **Control Unit** – generates control signals based on instruction type.
* **Branch Control Unit** – evaluates branch conditions and updates PC.
* **Program Counter (PC) Register** – keeps track of the current instruction address.

---

## ✅ Current Progress

* ✔️ **Baseline Core Ready**
  Designed and verified a complete single-cycle RISC-V processor.

* ✔️ **Functional Verification**
  Verified the design using real RISC-V assembly instructions converted to HEX format using the **RISC-V toolchain**.
  Waveforms were analyzed in **Xilinx Vivado** to confirm correct instruction execution.

* ✔️ **Synthesis & Timing Analysis**

  * Wrote a custom **TCL script** to automate synthesis and check for unintended latches — none detected.
  * Timing results:

    * **Slowest path:** 4.5 ns
    * **Fastest path:** 0.5 ns
    * **Note:** The synthesis tool reported *Unconstrained Timing Paths*, expected for a single-cycle CPU.

---

## 🧩 Next Steps

* 🔄 **Pipeline Extension**
  Extend the core into a **5-stage pipelined CPU**, introducing:

  * Hazard Detection Unit
  * Branch Prediction algorithms
  * Timing and throughput improvements

* 🧱 **Mini-SoC Integration**
  Once the pipelined CPU is functional, integrate it into a **mini System-on-Chip (SoC)** featuring:

  * AXI-Lite peripheral interface
  * Basic memory-mapped I/O blocks
  * Top-level SoC interconnect design

---

## 📊 Output Waveform

Below is the simulation waveform showing correct execution of RISC-V instructions:

![RISC-V Core Output Waveform](Yarp_RISC-V_Waveform.png)

---

## 🧰 Tools & Technologies

| Category         | Tools Used                       |
| ---------------- | -------------------------------- |
| **HDL**          | SystemVerilog                    |
| **Simulation**   | Xilinx Vivado                    |
| **Synthesis**    | Synopsys DC                      |
| **ISA**          | RISC-V (RV32I)                   |
| **Verification** | RISC-V Assembly → HEX conversion |
