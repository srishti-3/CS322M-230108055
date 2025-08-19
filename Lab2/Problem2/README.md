# Problem 2: Two-Road Traffic Light (Moore FSM)

**Goal:**  
Control North-South (NS) and East-West (EW) traffic lights using a shared 1 Hz tick. The sequence ensures safe alternation of green and yellow lights on both roads.

---

## Timing Requirements

| Phase       | Duration (ticks) |
|------------|----------------|
| NS Green   | 5              |
| NS Yellow  | 2              |
| EW Green   | 5              |
| EW Yellow  | 2              |

- Each tick corresponds to one clock cycle in the testbench simulation.  
- Only one of `{g, y, r}` outputs is high per road at any time.

---

## FSM Details

**Type:** Moore FSM  
**Reset:** Synchronous, active-high  

**States:**
1. `NS_GREEN` – NS has green, EW red  
2. `NS_YELLOW` – NS yellow, EW red  
3. `EW_GREEN` – EW green, NS red  
4. `EW_YELLOW` – EW yellow, NS red  

**Transitions:**  
- Each state waits for the specified number of tick pulses before transitioning to the next state in the cycle.

---

## Outputs

- `ns_g, ns_y, ns_r` – North-South traffic lights  
- `ew_g, ew_y, ew_r` – East-West traffic lights  

---

## Testbench

- Clock generated at 100 MHz in simulation (`#5 clk = ~clk;`)  
- Tick generated in testbench every 100 ns to simulate 1 Hz timing.  
- Simulation runs long enough to observe multiple cycles.

---

## Simulation Instructions

```bash
iverilog -o simv traffic_light.v tb_traffic_light.v
vvp simv
gtkwave traffic.vcd
