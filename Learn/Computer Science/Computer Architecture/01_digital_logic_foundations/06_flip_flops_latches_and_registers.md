## Flip-Flops, Latches, and Registers


---

### Latches

A **latch** is a level-sensitive bistable storage element — it responds to its inputs continuously while its enable/control signal is in the active state.

---

#### SR Latch (Set-Reset)

The most fundamental latch, built from cross-coupled NOR or NAND gates.

**NOR-based SR Latch truth table:**

|S|R|Q (next)|Q̄ (next)|State|
|---|---|---|---|---|
|0|0|Q|Q̄|Hold|
|1|0|1|0|Set|
|0|1|0|1|Reset|
|1|1|—|—|Forbidden|

The forbidden state arises because both outputs are forced to the same logic level, violating the complementary invariant Q ≠ Q̄. When S and R return to 00 simultaneously from 11, the final state is metastable and nondeterministic.

**NAND-based SR Latch** uses active-low inputs (S̄, R̄); the forbidden condition is S̄ = R̄ = 0.

```
NOR-based SR Latch

  S ──┬──[NOR]── Q
      │     ↑
      │     └────────┐
      │              │
  R ──┴──[NOR]── Q̄  │
            ↑        │
            └────────┘
```

---

#### D Latch (Data/Transparent Latch)

Eliminates the forbidden state by coupling S and R through a single data input D and its complement.

|Enable (E)|D|Q (next)|
|---|---|---|
|1|0|0|
|1|1|1|
|0|×|Q (hold)|

When E = 1, the latch is **transparent**: Q tracks D in real time. When E = 0, Q latches the last value of D at the moment E fell.

**Problem — transparency:** During the active enable window, any glitch or transient on D propagates directly to Q. This is why level-sensitive latches are generally avoided in synchronous pipelines in favor of edge-triggered flip-flops.

---

#### JK Latch

Extends the SR latch by defining behavior for the previously forbidden J = K = 1 condition as **toggle**.

|J|K|Q (next)|
|---|---|---|
|0|0|Q|
|1|0|1|
|0|1|0|
|1|1|Q̄|

Still level-sensitive; the toggle condition causes a **race condition** (output oscillates while J = K = 1 and enable is active), which is resolved by making it edge-triggered — giving rise to the JK flip-flop.

---

### Flip-Flops

A **flip-flop** is an edge-triggered bistable element. It samples its input only at the active edge of the clock (rising or falling) and ignores input changes at all other times. This eliminates the transparency problem of latches and makes flip-flops the preferred storage element in synchronous design.

---

#### D Flip-Flop

The most widely used flip-flop in digital systems.

**Characteristic equation:** Q(t+1) = D

|CLK Edge|D|Q (next)|
|---|---|---|
|↑|0|0|
|↑|1|1|
|No edge|×|Q|

**Implementation:** A master-slave configuration of two D latches — the master is transparent when CLK = 0, the slave when CLK = 1. Only the rising edge causes data to transfer from master to slave output.

```
Master-Slave D Flip-Flop

        CLK=0 transparent    CLK=1 transparent
D ──► [Master D Latch] ──► [Slave D Latch] ──► Q
            ↑                      ↑
           CLK̄                    CLK
```

---

#### JK Flip-Flop

**Characteristic equation:** Q(t+1) = J·Q̄ + K̄·Q

|J|K|Q (next)|
|---|---|---|
|0|0|Q (hold)|
|1|0|1 (set)|
|0|1|0 (reset)|
|1|1|Q̄ (toggle)|

Edge-triggering resolves the race condition: toggle occurs exactly once per active clock edge, regardless of how long J = K = 1 persists.

---

#### T Flip-Flop (Toggle)

A JK flip-flop with J and K tied together.

**Characteristic equation:** Q(t+1) = T ⊕ Q

|T|Q (next)|
|---|---|
|0|Q (hold)|
|1|Q̄ (toggle)|

Primary application: **binary counters**, where each bit position is a T flip-flop driven by the carry output of the stage below it.

---

#### SR Flip-Flop

**Characteristic equation:** Q(t+1) = S + R̄·Q, with constraint S·R = 0

Edge-triggered; the forbidden state (S = R = 1) must still be avoided by design. Less common than D or JK in practice.

---

### Timing Parameters

These parameters are critical to meeting setup/hold constraints in synchronous systems.

|Parameter|Symbol|Definition|
|---|---|---|
|Setup time|t_su|Minimum time D must be stable **before** the clock edge|
|Hold time|t_h|Minimum time D must remain stable **after** the clock edge|
|Clock-to-Q propagation|t_cq|Time from clock edge until Q reaches a valid stable value|
|Clock-to-Q contamination|t_ccq|Earliest time Q may begin to change after the clock edge|

**Setup-hold window violation** causes the flip-flop to enter a **metastable** state — an intermediate voltage between logic 0 and 1 that resolves randomly after an unbounded (but statistically characterized) time. Synchronizer circuits use this property deliberately with added resolution time.

**Maximum clock frequency:**

```
f_max = 1 / (t_cq + t_logic + t_su + t_skew)
```

Where t_logic is the combinational delay between flip-flops and t_skew is clock skew between source and destination flip-flops.

---

### Flip-Flop vs. Latch: Comparison

|Property|Latch|Flip-Flop|
|---|---|---|
|Trigger|Level (enable high/low)|Edge (rising or falling)|
|Transparency|Yes — tracks D while enabled|No — samples only at edge|
|Timing analysis|Difficult (open window)|Well-defined (single instant)|
|Gate count|~4–6 gates|~8–12 gates (master-slave)|
|Use in sync design|Occasional (carefully controlled)|Dominant|
|Hazard sensitivity|High|Low|

Latches are used deliberately in **latch-based pipelines** (common in high-performance ASIC and some CPU designs, e.g., IBM POWER-era cores) because they allow time-borrowing — a slow half-cycle can borrow time from the adjacent fast half-cycle — increasing effective throughput under variable logic depth.

---

### Registers

A **register** is a collection of flip-flops (typically D flip-flops) sharing a common clock and, usually, common control signals, storing a multi-bit word as a single unit.

---

#### Basic Register (Parallel Load)

N flip-flops with a shared clock. All bits are loaded simultaneously on the clock edge when the load-enable signal is asserted.

```
4-bit Parallel Register

D[3] ──► [DFF] ──► Q[3]
D[2] ──► [DFF] ──► Q[2]    CLK ──► (all flip-flops)
D[1] ──► [DFF] ──► Q[1]
D[0] ──► [DFF] ──► Q[0]
```

A 2-to-1 MUX per flip-flop selects between D_new (load) and Q (hold) based on the load-enable signal, allowing the register to hold its value when not being written.

---

#### Shift Register

Flip-flops connected in series — Q of each stage feeds D of the next. Data moves one position per clock cycle.

**Serial-In Serial-Out (SISO):** simplest form; used in delay lines and serial communication.

**Serial-In Parallel-Out (SIPO):** shift in bits serially, read all bits simultaneously from Q outputs. Used in deserializers (SPI receivers, UART RX path).

**Parallel-In Serial-Out (PISO):** load all bits in parallel, shift out one at a time. Used in serializers (SPI transmitters, UART TX path).

**Parallel-In Parallel-Out (PIPO):** full parallel access with optional shift — the universal shift register.

```
4-bit SISO Shift Register

Serial_In ──► [DFF0] ──► [DFF1] ──► [DFF2] ──► [DFF3] ──► Serial_Out
                  CLK (shared)
```

---

#### Universal Shift Register

Controlled by a 2-bit select (S1, S0):

|S1|S0|Operation|
|---|---|---|
|0|0|Hold|
|0|1|Shift right|
|1|0|Shift left|
|1|1|Parallel load|

Each flip-flop's input is driven by a 4-to-1 MUX selecting among: Q itself (hold), left neighbor's Q (shift right), right neighbor's Q (shift left), and parallel input D.

---

#### Counters (Register with Feedback)

A counter is a register whose next state is a function of its current state — the flip-flop outputs feed back through combinational logic (or directly) to the inputs.

**Ripple (Asynchronous) Counter:** Each flip-flop's clock input is driven by the Q output of the previous stage. Simple but introduces cumulative propagation delay — glitches appear at intermediate states during counting. Timing analysis is non-trivial.

```
2-bit Ripple Counter

CLK ──► [TFF0 T=1] ──Q0──► [TFF1 T=1] ──Q1
                 Q0 feeds CLK of TFF1
```

**Synchronous Counter:** All flip-flops share the same clock. Carry logic (AND of all lower-order Q outputs) enables the T input of each stage. Glitch-free; timing is predictable.

**Modulo-N Counter:** counts 0 to N−1, then resets. Implemented by decoding the terminal count and synchronously loading 0, or using synchronous clear.

**Up/Down Counter:** a control input selects between incrementing and decrementing by choosing between carry and borrow propagation logic.

---

#### Register File

A register file is an array of registers with a read/write port interface, fundamental to processor datapath design.

**Structure:**

- N registers, each W bits wide
- Read ports: address input → data output (typically combinational / asynchronous read)
- Write port: address input + data input + write-enable, clocked

**2-read-port, 1-write-port register file (typical of MIPS/RISC-V):**

```
         ┌─────────────────────────┐
 RS1 ──► │                         │──► Read Data 1
 RS2 ──► │    Register Array       │──► Read Data 2
  RD ──► │    (32 × 32-bit regs)   │
  WD ──► │                         │
  WE ──► │                         │
 CLK ──► └─────────────────────────┘
```

Read is typically implemented with a decoder driving multiplexers; write is implemented with a decoder enabling the write-enable of the addressed flip-flop bank.

**Note:** Register 0 in MIPS and RISC-V is hardwired to zero — writes to it are discarded, reads always return 0. This is enforced by simply not connecting write-enable to that register bank.

---

### Characteristic Equations Summary

|Flip-Flop|Characteristic Equation|Excitation for Q→1|
|---|---|---|
|SR|Q* = S + R̄·Q (S·R = 0)|S=1 or hold|
|D|Q* = D|D=1|
|JK|Q* = J·Q̄ + K̄·Q|J=1 or K=0 hold|
|T|Q* = T ⊕ Q|T=1 (toggle)|

---

### Excitation Tables

Used when designing sequential circuits from a desired state transition: given the current state Q and desired next state Q*, what input is required?

**D Flip-Flop:**

|Q|Q*|D|
|---|---|---|
|0|0|0|
|0|1|1|
|1|0|0|
|1|1|1|

D always equals Q* — the simplest excitation, which is why D flip-flops dominate sequential circuit synthesis.

**T Flip-Flop:**

|Q|Q*|T|
|---|---|---|
|0|0|0|
|0|1|1|
|1|0|1|
|1|1|0|

T = Q ⊕ Q* — T is 1 only when a change is needed.

**JK Flip-Flop:**

|Q|Q*|J|K|
|---|---|---|---|
|0|0|0|×|
|0|1|1|×|
|1|0|×|1|
|1|1|×|0|

Don't-cares in the excitation table allow Karnaugh map minimization to produce simpler logic than D-based designs in some cases — historically a reason JK flip-flops were preferred before gate density made D dominant.

---

**Key Points**

- Latches are level-sensitive; flip-flops are edge-triggered. The distinction determines whether a storage element responds continuously (during an enable window) or discretely (at a single clock instant).
- The master-slave D flip-flop is the canonical synchronous storage primitive because its characteristic equation Q* = D makes sequential circuit synthesis direct.
- Setup time, hold time, and clock-to-Q delay collectively constrain maximum operating frequency and must be satisfied at every flip-flop in a synchronous path.
- Registers are structured arrays of flip-flops sharing control signals; their variants (parallel, shift, universal, counter, register file) serve distinct architectural roles.
- Metastability is an irreducible physical phenomenon at every synchronous boundary; it is managed statistically through synchronizer design, never eliminated.

**Next Steps**

Proceed to **Finite State Machines**, which build directly on flip-flop and register foundations — state registers hold encoded states, and excitation equations derived here determine next-state logic. From there, **Timing and Propagation Delay** formalizes the constraints introduced in the timing parameters section above.

---

