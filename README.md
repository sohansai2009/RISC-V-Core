# 🧠 Custom RISC-V Core

This project implements a **RISC-V Core** built completely from scratch using **SystemVerilog**.  
It began as a **Single-Cycle RV32I processor** and has now been extended into a **5-stage pipelined CPU** with an evolving memory hierarchy.  
The design includes all core components — Instruction Memory, Decode Unit, Register File, Execute Unit, Data Memory, Control Unit, Branch Control Unit, and a Program Counter Register.  
As part of the architectural improvements, a **direct-mapped instruction cache** has also been implemented to accelerate instruction fetch performance.


---

## 🏗️ Core Architecture Diagram

Below is the complete architectural block diagram of the RISC-V processor, including the Instruction Cache, Data Cache, and Core CPU structure:

![RISC-V Core Architecture](RISC-V_Core_Modified.png)

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
  Designed and verified a fully functional single-cycle RISC-V processor implementing all RV32I base instructions.

* ✔️ **Functional Verification**  
  Validated the design using real RISC-V assembly programs, converted to HEX using the **RISC-V toolchain**, and verified correct execution through **Xilinx Vivado** waveform analysis.

* ✔️ **Synthesis & Timing Analysis**  
  * Developed a custom **TCL script** to run synthesis and automatically check for unintended latches — none were found.  
  * Analyzed the timing reports for both the pipelined and non-pipelined cores.  
The pipelined CPU shows a **slowest arrival time of 3.47 ns**, while the single-cycle core reports a **slowest arrival time of 1.73 ns**.  
However, the critical path in the single-cycle design was observed **between the same register**, indicating that the reported value reflects an unconstrained or unrealistic path due to the nature of single-cycle timing rather than an actual improvement over the pipelined architecture.


* ✔️ **Extended to 5-Stage Pipelined CPU**  
  Converted the single-cycle architecture into a **5-stage pipelined CPU** (IF → ID → EX → MEM → WB), significantly reducing the critical path and enabling higher frequency scaling.

* ✔️ **Direct-Mapped Instruction Cache Implemented**  
  Added a **direct-mapped instruction cache** between the CPU and Instruction Memory to reduce fetch latency and prepare the design for future SoC-level memory hierarchies.


---

## 🧩 Next Steps

* 🔄 **Integrate the Pipeline**
  Fully integrate the already implemented **5-stage pipelined CPU** with proper handling of:
  
  * Hazard Detection Unit  
  * Forwarding/Bypass logic  
  * Pipeline stall control for load-use and cache-miss scenarios  
  * Improved timing and throughput

* 📦 **Implement Direct-Mapped Data Cache**
  Extend the memory hierarchy by designing a **direct-mapped data cache** for the MEM stage to accelerate load/store operations.

* ⏸️ **Pipeline Stall Logic for Cache Misses**
  Introduce a stall mechanism to maintain pipeline correctness during cache misses:
  
  * Freeze IF, ID, and EX stages  
  * Allow MEM/WB to complete  
  * Maintain correct ordering and forwarding

* 📈 **System Performance Analysis**
  Analyze full-system behavior after adding caches:
  
  * IPC (Instructions Per Cycle)  
  * Cache hit/miss rate  
  * Memory latency improvements  
  * Impact on maximum frequency

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
