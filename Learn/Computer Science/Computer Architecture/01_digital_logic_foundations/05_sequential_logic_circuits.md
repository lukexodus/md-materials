## Sequential Logic Circuits


Sequential logic circuits are circuits whose outputs depend not only on current inputs but also on past inputs — that is, on stored state. Unlike combinational logic, sequential circuits have memory.

---

### Fundamental Model

A sequential circuit consists of:

- A **combinational logic block** computing next state and outputs
- **State registers** (memory elements) storing the current state
- A **feedback path** from state registers back into combinational logic

Two dominant output models exist:

**Moore machine** — outputs depend only on current state. **Mealy machine** — outputs depend on current state and current inputs.

```
         ┌─────────────────────────────────┐
Inputs ──►│                                 │──► Outputs (Mealy: inputs+state)
         │     Combinational Logic          │
         │                                 │
         └──────────────┬──────────────────┘
                        │ Next State
                   ┌────▼────┐
                   │ State   │ (Registers / Flip-flops)
                   │ Memory  │
                   └────┬────┘
                        │ Current State
                        └──────────────────► (back to combinational logic)
                                             (also to output logic in Moore)
```

---

### Clocked vs. Asynchronous

**Synchronous (clocked):** State transitions occur only on a clock edge. The dominant design paradigm in digital systems. Easier to analyze, verify, and synthesize.

**Asynchronous:** Transitions triggered by input changes, not a clock. Faster in principle but subject to hazards, races, and difficult timing analysis.

---

### Memory Elements

#### SR Latch

The most primitive storage element. Built from two cross-coupled NOR (or NAND) gates.

|S|R|Q (next)|Q̄ (next)|
|---|---|---|---|
|0|0|Q (hold)|Q̄ (hold)|
|1|0|1|0|
|0|1|0|1|
|1|1|**Invalid**|**Invalid**|

The S=1, R=1 condition produces an undefined state and must be avoided.

#### D Latch

Eliminates the invalid state by tying S and R̄ together through a single data input D.

- When Enable=1: Q follows D (transparent)
- When Enable=0: Q holds last value

The **level-sensitive** nature of latches makes them difficult to use safely in synchronous pipelines — they can produce **timing races** if data propagates through multiple latches within a single enable window.

#### D Flip-Flop

Samples D only on the active clock edge (rising or falling). Between edges, output Q is stable regardless of D changes.

```
       D ──┤>──── Q
      CLK ─┘      Q̄
```

This is the standard building block of synchronous sequential design.

#### JK Flip-Flop

Extends the SR with a toggle function.

|J|K|Q (next)|
|---|---|---|
|0|0|Q (hold)|
|1|0|1 (set)|
|0|1|0 (reset)|
|1|1|Q̄ (toggle)|

#### T Flip-Flop

A degenerate JK with J=K tied together. When T=1, output toggles on each clock edge. Commonly used in counters.

---

### Timing Parameters

These parameters govern correct operation and must be satisfied by design.

**Setup time (t_su):** Minimum time D must be stable _before_ the active clock edge for reliable capture.

**Hold time (t_h):** Minimum time D must remain stable _after_ the active clock edge.

**Clock-to-Q propagation delay (t_cq):** Time from active clock edge until Q reaches its new stable value.

**Maximum clock frequency** is bounded by the longest combinational path between registers:

```
f_max = 1 / (t_cq + t_comb_max + t_su)
```

**Setup violation:** Data arrives too late → metastability risk. **Hold violation:** Data changes too early → incorrect capture. Cannot be fixed by slowing the clock — requires adding delay on the data path.

---

### Registers

A register is an array of D flip-flops sharing a common clock (and often a common enable or reset).

**Parallel load register:** All bits loaded simultaneously on one clock edge.

**Shift register:** Output of each flip-flop feeds input of the next. Supports serial-in/serial-out, serial-in/parallel-out, parallel-in/serial-out, and parallel-in/parallel-out configurations. Used in serial communication interfaces (SPI, UART) and pseudo-random sequence generation.

**Universal shift register:** Supports both shift and parallel load modes via a mode select input.

---

### Counters

Counters are the most common application of sequential logic.

**Ripple (asynchronous) counter:** The Q output of each flip-flop clocks the next. Simple but produces glitches due to propagation skew — all bits do not change simultaneously.

**Synchronous counter:** All flip-flops share the same clock. Next-state logic computes carry enables. No ripple glitch. Preferred for all precision applications.

**Modulo-N counter:** Counts from 0 to N−1, then resets. Requires combinational decode of the terminal count to force reset or load.

**Up/down counter:** Mode input reverses the count direction. Used in address generators and PWM controllers.

**Gray code counter:** Successive values differ by exactly one bit. Eliminates multi-bit glitches during transitions. Critical in asynchronous clock-domain crossing and absolute encoders.

---

### Finite State Machine Implementation

The formal FSM model maps directly to hardware:

1. **State encoding** — assign binary codes to states
2. **Next-state logic** — combinational function of current state and inputs
3. **Output logic** — Moore: function of state only; Mealy: function of state and inputs
4. **State register** — D flip-flops holding the current state encoding

**State encoding choices:**

|Encoding|Description|Trade-off|
|---|---|---|
|Binary|Minimal bits (log₂ N)|Denser logic, deeper decode|
|One-hot|One flip-flop per state|More registers, simpler decode logic|
|Gray|Successive states differ by 1 bit|Reduces transition glitches|
|Johnson|Shift-register based|Simple hardware, limited states|

One-hot encoding is common in FPGAs where flip-flops are abundant but logic is constrained.

---

### Mealy vs. Moore Comparison

|Property|Moore|Mealy|
|---|---|---|
|Output depends on|State only|State + Inputs|
|Output timing|Synchronous with state|Can change with input (async)|
|State count|Typically more states|Typically fewer states|
|Glitch risk|Lower|Higher (input glitches propagate)|
|Common use|Clean synchronous outputs|Faster response, fewer states|

---

### Hazards in Sequential Circuits

**Static hazard:** A momentary unwanted pulse on an output that should remain constant. Arises from unequal path delays through combinational logic.

**Dynamic hazard:** Multiple output transitions when only one is expected. Occurs in multi-level logic networks.

**Critical race:** In asynchronous circuits, the outcome depends on which signal arrives first — produces nondeterministic behavior.

**Essential hazard:** Unique to asynchronous circuits. Requires minimum delays on certain paths rather than zero delay. Cannot be removed by logic simplification.

Synchronous design eliminates race conditions by subordinating all state changes to the clock edge.

---

### Metastability

When setup or hold constraints are violated, a flip-flop may enter a **metastable state** — an intermediate, unstable voltage level between logic 0 and 1. The flip-flop will eventually resolve to a valid state, but the resolution time is unbounded.

Mean time between failures (MTBF) for a synchronous synchronizer:

```
MTBF = e^(t_r / τ) / (f_clk · f_data · C)
```

Where t_r is the time available for resolution, τ is the flip-flop's metastability time constant, and C is a technology-dependent constant.

Metastability is not eliminable, only manageable — by providing more resolution time (using slower clocks or multi-stage synchronizers) and selecting flip-flops with small τ.

---

### Clock Domain Crossing

When signals cross between circuits clocked by independent (or unrelated) clocks, synchronization is required.

**Single-bit crossing:** Use a two-flop synchronizer — two D flip-flops in series in the destination domain. Reduces (not eliminates) metastability probability.

**Multi-bit crossing:** A two-flop synchronizer is insufficient — bits may be sampled in different cycles. Solutions:

- **Gray-coded counters** (e.g., FIFO pointers) — only one bit changes per transition
- **Handshake protocols** — sender asserts valid, receiver acknowledges
- **Asynchronous FIFOs** — purpose-built structures with Gray-coded pointers and independent read/write clocks

---

### SVG — D Flip-Flop and Register Chain

```svg
<svg viewBox="0 0 520 160" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">

  <!-- FF1 -->
  <rect x="40" y="30" width="80" height="80" rx="4" fill="#1e1e2e" stroke="#89b4fa" stroke-width="1.5"/>
  <text x="80" y="72" text-anchor="middle" fill="#cdd6f4">D FF</text>
  <text x="48" y="58" fill="#a6e3a1">D</text>
  <text x="48" y="90" fill="#f38ba8">CLK</text>
  <text x="108" y="72" text-anchor="start" fill="#fab387">Q</text>

  <!-- Wire: D in -->
  <line x1="10" y1="54" x2="40" y2="54" stroke="#a6e3a1" stroke-width="1.5"/>
  <text x="5" y="58" fill="#a6e3a1">D</text>

  <!-- CLK line FF1 -->
  <line x1="40" y1="86" x2="10" y2="86" stroke="#f38ba8" stroke-width="1.5"/>
  <text x="2" y="90" fill="#f38ba8">C</text>

  <!-- Q out FF1 → D in FF2 -->
  <line x1="120" y1="68" x2="200" y2="68" stroke="#fab387" stroke-width="1.5"/>

  <!-- FF2 -->
  <rect x="200" y="30" width="80" height="80" rx="4" fill="#1e1e2e" stroke="#89b4fa" stroke-width="1.5"/>
  <text x="240" y="72" text-anchor="middle" fill="#cdd6f4">D FF</text>
  <text x="208" y="58" fill="#a6e3a1">D</text>
  <text x="208" y="90" fill="#f38ba8">CLK</text>
  <text x="268" y="72" text-anchor="start" fill="#fab387">Q</text>

  <!-- CLK line FF2 shared -->
  <line x1="200" y1="86" x2="170" y2="86" stroke="#f38ba8" stroke-width="1.5"/>
  <line x1="170" y1="86" x2="170" y2="130" stroke="#f38ba8" stroke-width="1.5"/>
  <line x1="10" y1="130" x2="170" y2="130" stroke="#f38ba8" stroke-width="1.5"/>

  <!-- Q out FF2 → D in FF3 -->
  <line x1="280" y1="68" x2="360" y2="68" stroke="#fab387" stroke-width="1.5"/>

  <!-- FF3 -->
  <rect x="360" y="30" width="80" height="80" rx="4" fill="#1e1e2e" stroke="#89b4fa" stroke-width="1.5"/>
  <text x="400" y="72" text-anchor="middle" fill="#cdd6f4">D FF</text>
  <text x="368" y="58" fill="#a6e3a1">D</text>
  <text x="368" y="90" fill="#f38ba8">CLK</text>
  <text x="428" y="72" text-anchor="start" fill="#fab387">Q</text>

  <!-- CLK line FF3 -->
  <line x1="360" y1="86" x2="330" y2="86" stroke="#f38ba8" stroke-width="1.5"/>
  <line x1="330" y1="86" x2="330" y2="130" stroke="#f38ba8" stroke-width="1.5"/>
  <line x1="170" y1="130" x2="330" y2="130" stroke="#f38ba8" stroke-width="1.5"/>

  <!-- Q out FF3 -->
  <line x1="440" y1="68" x2="510" y2="68" stroke="#fab387" stroke-width="1.5"/>
  <text x="490" y="64" fill="#fab387">Q_out</text>

  <!-- CLK label -->
  <text x="2" y="134" fill="#f38ba8">CLK</text>

  <!-- Label -->
  <text x="200" y="148" text-anchor="middle" fill="#6c7086" font-size="11">3-stage shift register (synchronous)</text>
</svg>
```

---

**Key Points**

- All synchronous sequential design reduces to: state registers + combinational next-state logic + feedback
- Latch vs. flip-flop distinction is critical — latches are level-sensitive and hazard-prone in synchronous pipelines
- Timing constraints (setup, hold, t_cq) define the maximum frequency and minimum data-path delay bounds simultaneously
- Metastability cannot be eliminated — only the probability of unresolved metastability can be reduced
- Clock domain crossing requires structural solutions, not just careful routing

---

