## Finite State Machines


A finite state machine (FSM) is a computational model consisting of a finite number of states, transitions between those states, and actions — used extensively in digital logic to design sequential circuits whose outputs depend not only on current inputs but also on past history encoded as state.

---

### Formal Definition

An FSM is defined by a 5-tuple:

$$M = (Q, \Sigma, \delta, q_0, F)$$

|Symbol|Meaning|
|---|---|
|$Q$|Finite, non-empty set of states|
|$\Sigma$|Input alphabet (set of input symbols)|
|$\delta$|Transition function: $Q \times \Sigma \rightarrow Q$|
|$q_0$|Initial state, $q_0 \in Q$|
|$F$|Set of accepting/final states, $F \subseteq Q$|

In hardware design, $F$ is less emphasized — outputs are the primary concern, not acceptance.

---

### Moore vs. Mealy Machines

These are the two fundamental FSM output models used in digital design.

#### Moore Machine

Output depends **only on the current state**.

$$\lambda : Q \rightarrow O$$

- Output is associated with states
- Output changes are synchronous with state transitions
- Generally requires more states than Mealy for equivalent behavior

#### Mealy Machine

Output depends on **both current state and current input**.

$$\lambda : Q \times \Sigma \rightarrow O$$

- Output is associated with transitions
- Output can change asynchronously with input (without a clock edge)
- Typically fewer states than an equivalent Moore machine

```
Moore:   State → Output
Mealy:   (State × Input) → Output
```

---

### State Diagram and State Table

#### State Diagram

A directed graph where:

- Nodes represent states
- Edges represent transitions, labeled with input (Mealy: input/output)
- Moore outputs are labeled inside the node

```svg
<svg viewBox="0 0 520 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">

  <!-- State S0 -->
  <circle cx="100" cy="100" r="35" fill="none" stroke="#ccc" stroke-width="2"/>
  <text x="100" y="95" text-anchor="middle" fill="#ccc">S0</text>
  <text x="100" y="112" text-anchor="middle" fill="#aaa" font-size="11">out=0</text>

  <!-- State S1 -->
  <circle cx="260" cy="100" r="35" fill="none" stroke="#ccc" stroke-width="2"/>
  <text x="260" y="95" text-anchor="middle" fill="#ccc">S1</text>
  <text x="260" y="112" text-anchor="middle" fill="#aaa" font-size="11">out=0</text>

  <!-- State S2 (accepting / output=1) -->
  <circle cx="420" cy="100" r="35" fill="none" stroke="#ccc" stroke-width="2"/>
  <circle cx="420" cy="100" r="29" fill="none" stroke="#ccc" stroke-width="1.2"/>
  <text x="420" y="95" text-anchor="middle" fill="#ccc">S2</text>
  <text x="420" y="112" text-anchor="middle" fill="#aaa" font-size="11">out=1</text>

  <!-- Initial arrow -->
  <line x1="30" y1="100" x2="62" y2="100" stroke="#aaa" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- S0 -> S1 on input 1 -->
  <path d="M133,85 Q180,50 225,85" fill="none" stroke="#aaa" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="180" y="55" text-anchor="middle" fill="#7af">1</text>

  <!-- S1 -> S0 on input 0 -->
  <path d="M225,115 Q180,150 133,115" fill="none" stroke="#aaa" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="180" y="148" text-anchor="middle" fill="#7af">0</text>

  <!-- S1 -> S2 on input 1 -->
  <path d="M293,85 Q340,50 385,85" fill="none" stroke="#aaa" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="340" y="55" text-anchor="middle" fill="#7af">1</text>

  <!-- S2 -> S0 on input 0 -->
  <path d="M390,125 Q260,195 130,125" fill="none" stroke="#aaa" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="260" y="192" text-anchor="middle" fill="#7af">0</text>

  <!-- S0 self-loop on input 0 -->
  <path d="M75,68 Q60,20 100,65" fill="none" stroke="#aaa" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="62" y="30" text-anchor="middle" fill="#7af">0</text>

  <!-- S2 self-loop on input 1 -->
  <path d="M445,68 Q480,20 448,68" fill="none" stroke="#aaa" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="490" y="38" text-anchor="middle" fill="#7af">1</text>

  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#aaa"/>
    </marker>
  </defs>
</svg>
```

_Example: Moore FSM detecting two consecutive 1s. S2 is the detecting state (out=1)._

#### State Table

|Current State|Input|Next State|Output (Moore)|
|---|---|---|---|
|S0|0|S0|0|
|S0|1|S1|0|
|S1|0|S0|0|
|S1|1|S2|0|
|S2|0|S0|1|
|S2|1|S2|1|

---

### FSM Design Procedure

The systematic path from specification to gate-level implementation follows these stages:

```
1. Specification
        ↓
2. State Diagram
        ↓
3. State Table
        ↓
4. State Encoding
        ↓
5. Next-State Logic (Karnaugh map / Boolean minimization)
        ↓
6. Output Logic
        ↓
7. Flip-flop Selection & Circuit Implementation
```

---

### State Encoding

State encoding assigns binary codes to abstract states. The choice directly affects logic complexity and timing.

|Encoding Scheme|Description|Trade-off|
|---|---|---|
|Binary|Minimal bits: $\lceil \log_2 n \rceil$|Complex next-state logic|
|One-hot|One flip-flop per state|Simple logic, many flip-flops|
|Gray code|Adjacent states differ by 1 bit|Reduces glitches in async designs|
|Output-encoded|State bits are the output bits|Eliminates separate output logic|

For the 3-state example above using binary encoding:

|State|$Q_1$|$Q_0$|
|---|---|---|
|S0|0|0|
|S1|0|1|
|S2|1|0|

---

### Next-State and Output Logic Derivation

Using D flip-flops (since $D = Q_{\text{next}}$), derive Boolean expressions from the state table.

**Next-state equations** (derived via Karnaugh map):

$$D_1 = Q_0 \cdot X$$

$$D_0 = \overline{Q_1} \cdot X$$

**Output equation** (Moore — depends only on state):

$$Z = Q_1$$

These expressions are then implemented with combinational gates feeding the D inputs of the flip-flops.

---

### Synchronous vs. Asynchronous FSMs

|Property|Synchronous|Asynchronous|
|---|---|---|
|State changes|On clock edge only|Immediately on input change|
|Hazard risk|Low (clock masks glitches)|High (race conditions, glitches)|
|Design complexity|Lower|Higher|
|Speed|Clock-limited|Potentially faster|
|Predominant use|Digital logic, CPUs|Handshake protocols, some interfaces|

Synchronous FSMs are standard in VLSI and CPU design. Asynchronous FSMs require hazard-free logic and are used in specialized low-power or delay-insensitive designs.

---

### Hazards in Asynchronous FSMs

When multiple state bits change simultaneously, intermediate invalid states may be briefly visited — this is a **race condition**.

- **Non-critical race**: Machine reaches correct final state regardless of transition order
- **Critical race**: Different transition orders lead to different final states — a design error

**Example:**

```
Transition: 00 → 11
If Q0 changes first: 00 → 01 → 11  ✓
If Q1 changes first: 00 → 10 → 11  ✓  (non-critical)

Transition: 01 → 10
If Q0 changes first: 01 → 00 → 10  ✗ (may latch at 00)
If Q1 changes first: 01 → 11 → 10  ✗ (may latch at 11)  (critical)
```

Gray code encoding eliminates critical races by ensuring only one bit changes per transition.

---

### FSM Minimization (State Reduction)

Equivalent states can be merged to reduce flip-flop count and logic complexity.

Two states $s_i$ and $s_j$ are **equivalent** if:

1. They produce identical outputs for all inputs
2. Their next states are equivalent for all inputs (recursively)

**Algorithm — Implication Table Method:**

1. List all state pairs
2. Mark pairs with different outputs as distinguishable
3. Propagate: if next-state pair of $(s_i, s_j)$ on input $x$ is already marked, mark $(s_i, s_j)$
4. Repeat until no new marks are added
5. Unmarked pairs are equivalent — merge them

---

### FSM in Hardware: Flip-Flop Types

Any edge-triggered flip-flop can store state. The choice affects next-state logic complexity.

|Flip-Flop|Excitation Equation|Notes|
|---|---|---|
|D|$D = Q_{\text{next}}$|Simplest — directly maps next-state table|
|JK|$J = Q_{\text{next}} \cdot \overline{Q}$, $K = \overline{Q_{\text{next}}} \cdot Q$|Can minimize logic in some cases|
|T|$T = Q_{\text{next}} \oplus Q$|Useful when toggling behavior is frequent|
|SR|$S = Q_{\text{next}} \cdot \overline{Q}$, $R = \overline{Q_{\text{next}}} \cdot Q$|Forbidden state must be avoided|

D flip-flops dominate modern design due to their simplicity and direct correspondence with next-state logic.

---

### Timing Constraints in Synchronous FSMs

For correct operation, all flip-flops must satisfy:

$$t_{clk} \geq t_{CQ} + t_{logic} + t_{setup}$$

|Parameter|Meaning|
|---|---|
|$t_{clk}$|Clock period|
|$t_{CQ}$|Clock-to-Q propagation delay of flip-flop|
|$t_{logic}$|Propagation delay through combinational next-state logic|
|$t_{setup}$|Setup time required at flip-flop input before clock edge|

The **critical path** — the longest combinational path — determines the maximum operating frequency:

$$f_{max} = \frac{1}{t_{CQ} + t_{logic,max} + t_{setup}}$$

Hold time must also be satisfied:

$$t_{hold} \leq t_{CQ} + t_{logic,min}$$

Violation of hold time causes **metastability**, which is not corrected by slowing the clock.

---

### FSM Categories by Application

|Category|Description|Example|
|---|---|---|
|Recognizer / Detector|Asserts output when input sequence matches a pattern|Sequence detector, parity checker|
|Controller|Generates control signals driving a datapath|CPU control unit, protocol sequencer|
|Transducer|Transforms input stream to output stream|Serial-to-parallel converter|
|Arbiter|Manages resource access among competing requestors|Bus arbiter|
|Counter|Special case FSM with regular state progression|Binary counter, Gray counter|

---

### FSM as CPU Control Unit

In processor design, the control unit is often implemented as an FSM (or a ROM-based microprogrammed variant):

```
         Instruction Register (IR)
                    |
                    ↓
         ┌─────────────────────┐
         │   Control Unit FSM  │
         │                     │
         │  State = Phase of   │
         │  instruction cycle  │
         └─────────────────────┘
                    |
         ┌──────────┴──────────┐
         ↓                     ↓
   Datapath Signals       Next State
   (RegWrite, MemRead,    (Fetch → Decode
    ALUOp, Branch…)        → Execute…)
```

Each state corresponds to a stage: Fetch, Decode, Execute, Memory Access, Write-Back. The FSM advances through these stages, asserting the appropriate control signals at each.

---

### **Key Points**

- An FSM has a finite number of states; its behavior at any time is fully determined by its current state and current inputs.
- Moore machines derive output from state alone; Mealy machines derive output from state and input simultaneously.
- D flip-flops are the standard storage element in synchronous FSM implementation due to their direct next-state correspondence.
- State encoding choice (binary, one-hot, Gray) affects both logic complexity and susceptibility to hazards.
- The critical path through combinational next-state logic sets the maximum clock frequency.
- State minimization reduces hardware cost; the implication table method is the canonical manual algorithm.
- Asynchronous FSMs are prone to critical races; Gray encoding and careful hazard analysis are required.

---

### **Example**

**Specification:** Detect the sequence `1011` on a serial input line. Assert output `Z = 1` for one clock cycle when the last four bits received match `1011` (overlapping detection allowed).

**State diagram** (Moore — output in state):

|State|Meaning|Output|
|---|---|---|
|A|No progress|0|
|B|Received `1`|0|
|C|Received `10`|0|
|D|Received `101`|0|
|E|Received `1011`|1|

**Partial state table:**

|State|Input=0|Input=1|
|---|---|---|
|A|A|B|
|B|C|B|
|C|A|D|
|D|C|E|
|E|C|B|

On entering state E, $Z = 1$. The machine then continues scanning for the next occurrence (overlapping: `1011011` yields two detections).

---

### **Conclusion**

Finite state machines provide a rigorous, implementation-ready model for sequential behavior in digital systems. The design flow — from state diagram through encoding, logic minimization, and flip-flop implementation — is methodical and directly synthesizable to hardware. Timing closure, encoding strategy, and state minimization are the principal engineering decisions that affect area, speed, and power of the resulting circuit.

---

### **Next Steps**

- **Timing and Propagation Delay** — analyze how gate and interconnect delays constrain FSM operating frequency and how static timing analysis is applied
- **Combinational Logic Circuits** — review the gate-level primitives from which next-state and output logic are built
- **Control Unit Design (Hardwired vs. Microprogrammed)** — see how FSMs scale into full CPU control units, and how microprogramming offers an alternative to hardwired FSM control

---

