# RVX10 Instruction Encodings

This document lists the **32-bit hexadecimal encodings** for the RVX10 test program used with `riscvsingle.sv`.

| Addr  | Hex Code   | Assembly (Approx)      | Description / Notes                       |
|-------|-----------|-----------------------|------------------------------------------|
| 0x00  | 00500113  | addi x2, x0, 5        | I-type: add immediate                     |
| 0x04  | 00C00193  | addi x3, x0, 12       | I-type                                     |
| 0x08  | FF718393  | addi x7, x3, -9       | I-type                                     |
| 0x0C  | 0023E233  | RVX10 custom           | R-type / RVX10 instruction               |
| 0x10  | 0041F2B3  | RVX10 custom           | R-type                                    |
| 0x14  | 004282B3  | add x5, x5, x4        | Standard RV32I R-type                     |
| 0x18  | 02728863  | beq x5, x7, offset    | Branch instruction (B-type)               |
| 0x1C  | 0041A233  | RVX10 custom           | R-type                                    |
| 0x20  | 00020463  | beq x0, x0, offset    | Branch instruction (B-type)               |
| 0x24  | 00000293  | addi x5, x0, 0        | I-type                                     |
| 0x28  | 0023A233  | RVX10 custom           | R-type                                    |
| 0x2C  | 005203B3  | RVX10 custom           | R-type                                    |
| 0x30  | 402383B3  | RVX10 custom           | R-type                                    |
| 0x34  | 0471AA23  | sw x7, offset(x3)     | S-type store                               |
| 0x38  | 06002103  | RVX10 custom           | I/R-type                                  |
| 0x3C  | 005104B3  | RVX10 custom           | R-type                                    |
| 0x40  | 008001EF  | jal x3, offset        | J-type jump                                |
| 0x44  | 00100113  | addi x2, x0, 1        | I-type                                     |
| 0x48  | 00910133  | add x2, x2, x9        | R-type                                     |
| 0x4C  | 0221A023  | sw x2, offset(x3)     | S-type store                               |
| 0x50  | 00210063  | beq x2, x0, offset    | B-type branch                              |

## Notes

1. **RVX10 Instructions:**  
   Instructions labeled **RVX10 custom** correspond to your custom extension instructions as implemented in the `aludec` and `alu` modules. They extend the standard RV32I without changing the memory or pipeline structure.

2. **Standard Instructions:**  
   Instructions like `addi`, `add`, `beq`, `sw`, and `jal` follow standard RV32I encoding and are compatible with the base RISC-V single-cycle implementation.

3. **Memory Mapping:**  
   - `0x34` (sw) stores data to memory at address 100 in your testbench.
   - The simulation is designed to succeed when **WriteData = 25** at **DataAdr = 100**.

