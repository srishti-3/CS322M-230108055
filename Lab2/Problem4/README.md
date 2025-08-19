# Problem 4: Two FSMs – Master/Slave Handshake

**Goal:**  
Implement two FSMs (Master and Slave) that communicate via a 4-phase req/ack handshake with an 8-bit data bus. The Master sends a 4-byte burst (A0–A3) and asserts `done` after completion.

---

## System Description

**Master FSM Behavior:**
1. Drives data onto bus and raises `req`.  
2. Waits for `ack` from Slave.  
3. Drops `req` after ack is observed.  
4. Moves to next byte until all 4 bytes are sent.  
5. Asserts `done` for 1 cycle after last byte.

**Slave FSM Behavior:**
1. Waits for `req` from Master.  
2. Latches incoming data on `req`.  
3. Asserts `ack` for 2 cycles (HOLD).  
4. Drops `ack` after Master drops `req`.  
5. `last_byte` observable for verification.

---

## FSM States

**Master FSM States:**
- `IDLE` → `SEND` → `WAIT_ACK` → `DROP` → `NEXT` → `FINISH`  

**Slave FSM States:**
- `WAITREQ` → `ASSERT` → `HOLD` → `DROP`  

**Data Sequence:** A0, A1, A2, A3  

---

## Inputs and Outputs

| Module | Input/Output | Description |
|--------|--------------|-------------|
| Master | `clk`, `rst`, `ack` | ack from Slave |
|        | `req`, `data`, `done` | outputs to Slave / top |
| Slave  | `clk`, `rst`, `req`, `data_in` | inputs from Master |
|        | `ack`, `last_byte` | outputs back to Master / observation |

---

## Simulation Instructions

```bash
iverilog -o simv master_fsm.v slave_fsm.v link_top.v tb_link_top.v
vvp simv
gtkwave handshake.vcd
