# RVX10 Single-Cycle RISC-V Processor

## Overview
This project implements a **single-cycle RISC-V processor** with a **RVX10 custom instruction set**.  

Custom instructions include: **ANDN, ORN, XNOR, MIN, MAX, MINU, MAXU, ROL, ROR, ABS**.

The testbench writes results to **memory address 100** and prints `Simulation succeeded` when correct.

## Files
- `riscvsingle.sv` - main RTL for processor, ALU, datapath, and memories  
- `rvx10.hex` - instruction memory containing RV32I + RVX10 instructions  
- Testbench is included in `riscvsingle.sv`  

## How to Run
1. Place `rvx10.hex` in the same folder as `riscvsingle.sv`.  
2. Compile with Icarus Verilog:
```bash
iverilog -g2012 -o simv riscvsingle.sv
```


4. Run the simulation:
```bash
vvp simv
```

 5. Check output. If correct, you should see:
 Simulation succeeded
