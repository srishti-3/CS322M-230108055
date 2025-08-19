# Problem 3: Vending Machine with Change (Mealy FSM)

**Goal:**  
Implement a vending machine that accepts coins of value 5 or 10, with a total price of 20.  

**Behavior:**  
- When total ≥ 20: `dispense = 1` (1-cycle pulse).  
- If total = 25: also `chg5 = 1` (1-cycle pulse to return 5).  
- Reset total after vending.

---

## Inputs and Outputs

| Signal   | Description                                  |
|----------|----------------------------------------------|
| `clk`    | System clock                                 |
| `rst`    | Synchronous active-high reset                |
| `coin`   | 2-bit input: `01 = 5`, `10 = 10`, `00 = idle` |
| `dispense` | 1-cycle pulse when product is vended      |
| `chg5`   | 1-cycle pulse when 5 is returned as change  |

**Note:** Only one coin per cycle is considered. Ignore `coin = 11`.

---

## FSM Design

**Type:** Mealy FSM (output depends on state and input)  
**States (total inserted):**
1. `S0` – total 0  
2. `S5` – total 5  
3. `S10` – total 10  
4. `S15` – total 15  

**Transitions:**  
- On `coin=5` or `10`, state updates according to the total.  
- Outputs `dispense` and `chg5` asserted in Mealy style when threshold reached.

---

## Tested Input Sequences

| Sequence                | Expected Output         |
|-------------------------|-----------------------|
| `10 + 10`               | `dispense = 1`        |
| `5 + 5 + 10`            | `dispense = 1`        |
| `10 + 10 + 5`           | `dispense = 1, chg5=1` |

---

## Simulation Instructions

```bash
iverilog -o simv vending_mealy.v tb_vending_mealy.v
vvp simv
gtkwave vending.vcd
