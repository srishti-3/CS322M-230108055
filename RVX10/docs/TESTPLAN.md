# RVX10 Test Plan

## Goal
Verify all 10 RVX10 instructions and correct single-cycle CPU behavior. Final test is writing 25 to memory address 100 to pass the simulation.

## Registers & Memory
- x28: checksum / accumulation (optional)
- x5-x15: test registers
- Memory addresses 96-100 used for intermediate and final checks

## Test Steps
1. Load deterministic test values into registers.
2. Execute each RVX10 instruction:
   - ANDN, ORN, XNOR
   - MIN, MAX, MINU, MAXU
   - ROL, ROR
   - ABS
3. Check results by storing intermediate results to memory addresses 96+.
4. Accumulate success indicators if needed in x28.
5. End program with:
   - `sw xN, 100(x0)` → store 25 at address 100
   - Testbench prints "Simulation succeeded" if address 100 = 25.

## Example Checks
| Instruction | Inputs        | Expected Output | Memory Check |
|-------------|---------------|----------------|--------------|
| ANDN x5,x6,x7 | x6=0xF0F0A5A5, x7=0x0F0FFFFF | 0xF0F00000 | mem[96] |
| MINU x8,x9,x10 | x9=0xFFFFFFFE, x10=0x00000001 | 0x00000001 | mem[97] |
| ROL x11,x12,x13 | x12=0x80000001, x13=3 | 0x0000000B | mem[98] |
| ABS x14,x15,x0 | x15=0xFFFFFF80 | 0x00000080 | mem[99] |

> Repeat for all instructions to fully cover RVX10.

## Pass Criterion
- Final memory address 100 contains 25 → testbench prints "Simulation succeeded".
- Any deviation prints "Simulation failed".
