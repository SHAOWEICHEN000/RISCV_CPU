🧠 RISC-V Single-Issue CPU (RV32I)
This project implements a 5-stage pipelined RISC-V RV32I single-issue CPU using Verilog. The CPU includes the classic pipeline stages: Instruction Fetch (IF), Decode (ID), Execute (EX), Memory Access (MEM), and Write-Back (WB).

📦 Features
Implements core RV32I base integer instruction set

Modular and well-structured Verilog design

Supports key instructions:
addi, lw, sw, beq, jal, jalr, lui, auipc, sub, add

Single-cycle register write-back

Hex-based program loading

Simulation-ready with $display and GTKWave

📁 Module Overview
Module	Description
fetch.v	Handles PC update logic (+4 or jump target)
decode.v	Decodes instruction fields & generates control signals
alu.v	Performs arithmetic/logic operations based on function code
imm_gen.v	Extracts and sign-extends immediate values
regfile.v	32 × 32-bit general-purpose register file
data_memory.v	Read/write memory module for lw and sw
instruction_memory.v	Loads .hex file (compiled from C) as program memory
CPU_top.v	Top-level integration of all modules
mux.v	Selects ALU operands and write-back data

🛠️ Build & Simulate
Hex Program
Instructions are loaded into instruction_memory.v using a HEX file, typically compiled from a C test file (e.g., my_test.c).

Example instructions:

Branching: beq, jal, jalr

Arithmetic: add, sub, addi

Memory: lw, sw

Run with Icarus Verilog + GTKWave
bash
複製
編輯
# Compile
iverilog -o cpu_tb CPU_top.v regfile.v alu.v decode.v fetch.v data_memory.v instruction_memory.v imm_gen.v testbench.v

# Simulate
vvp cpu_tb

# View waveform (optional)
gtkwave dump.vcd
📊 Simulation Output
Simulation prints are handled via $display. You can inspect waveforms with GTKWave for debugging and timing analysis.

🔗 Reference
Inspired by:
https://github.com/sean-brandenburg/Verilog-Processor-RISC-V/blob/master/top.v
