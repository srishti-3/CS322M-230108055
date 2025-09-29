# RVX10 Instruction Encodings

This document lists **32-bit hexadecimal encodings** for the RVX10 test program used with `riscvsingle.sv`.

| Addr  | Assembly            | Encoding (Hex) |
|-------|-------------------|----------------|
| 0x00  | addi x5, x0, -252  | F04FF093       |
| 0x04  | ori  x5, x5, 0x5A5 | 05AFF113       |
| 0x08  | addi x6, x0, 240   | 00F00313       |
| 0x0C  | ori  x6, x6, 0xFFF | 0FFF0313       |
| 0x10  | andn x12, x5, x6   | 0062860B       |
| 0x14  | addi x7, x0, -2    | FFE00393       |
| 0x18  | addi x8, x0, 1     | 00100413       |
| 0x1C  | minu x12, x7, x8   | 0183A60B       |
| 0x20  | addi x9, x0, -2048 | 80000493       |
| 0x24  | ori  x9, x9, 1     | 0014E493       |
| 0x28  | addi x10, x0, 3    | 00300513       |
| 0x2C  | rol x12, x9, x10   | 02A4860B       |
| 0x30  | addi x11, x0, -128 | F8000593       |
| 0x34  | abs x12, x11, x0   | 0605860B       |
| 0x38  | addi x29, x0, 25   | 01900E93       |
| 0x3C  | addi x30, x0, 100  | 06400F13       |
| 0x40  | sw x29, 0(x30)     | 01DE2023       |
