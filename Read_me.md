# 🧠 RISC-V Single Issue CPU (RV32I)

This project is a Verilog-based implementation of a **5-stage RISC-V RV32I single-issue CPU**, including instruction fetch, decode, execute, memory access, and write-back stages.

## 📦 Features

- Implements core RV32I instructions
- Single-cycle register write-back
- Supports `addi`, `lw`, `sw`, `beq`, `jal`, `jalr`, `lui`, `auipc`, etc.
- Modular design with:
  - `fetch.v`
  - `decode.v`
  - `alu.v`
  - `imm_gen.v`
  - `regfile.v`
  - `data_memory.v`
  - `instruction_memory.v`
  - `CPU_top.v`
  - `mux`

## 🛠️ Build & Simulate
## Hex Program
simple instructions in hex file like if, jump, add, sub and load in instruction memory
## simulaion
gtkwave 
$display

### Using Icarus Verilog
```bash
iverilog -o cpu_tb CPU_top.v regfile.v alu.v decode.v fetch.v data_memory.v instruction_memory.v imm_gen.v testbench.v
vvp cpu_tb

REFERENCE:https://github.com/sean-brandenburg/Verilog-Processor-RISC-V/blob/master/top.v
