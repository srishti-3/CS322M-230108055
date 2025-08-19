# Problem 1: Sequence Detector (Mealy)

**Goal:**  
Detect the serial bit pattern `1101` on input `din` (overlapping sequences allowed). Output `y` is a 1-cycle pulse when the last bit arrives.

**Type:** Mealy FSM, synchronous active-high reset.

**States:**  
- `S0` – initial state  
- `S1` – detected first '1'  
- `S2` – detected '11'  
- `S3` – detected '110'  

**Output Logic:**  
- `y = 1` only when pattern `1101` is completed.

**Tested Input Streams:**  
- `11011011101` → Expected pulse indices: 3, 6, 10 (0-based)

**Simulation Instructions:**
```bash
iverilog -o simv seq_detect_mealy.v tb_seq_detect_mealy.v
vvp simv
gtkwave dump.vcd
