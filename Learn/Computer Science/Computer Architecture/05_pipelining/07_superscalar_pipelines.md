## Superscalar Pipelines


A superscalar processor issues and executes **more than one instruction per clock cycle** by replicating functional units and widening the fetch, decode, and issue stages. Where a scalar pipeline achieves a theoretical maximum IPC of 1, a superscalar pipeline raises that ceiling to _w_ — the issue width. Achieving IPC close to _w_ in practice is the central challenge of superscalar design.

---

### Scalar Pipeline Limitation

A classic 5-stage scalar pipeline processes one instruction per cycle through a single pipeline lane. Even with perfect branch prediction and no hazards, IPC is bounded at 1. Superscalar design removes this bound by operating multiple lanes simultaneously.

<svg viewBox="0 0 680 180" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <text x="20" y="25" fill="#aaa">Scalar (IPC = 1):</text> <!-- Scalar pipeline: one instruction per row --> <rect x="20" y="35" width="60" height="28" rx="3" fill="none" stroke="#7af" stroke-width="1.2"/> <text x="50" y="54" text-anchor="middle" fill="#7af">IF</text> <rect x="90" y="35" width="60" height="28" rx="3" fill="none" stroke="#7af" stroke-width="1.2"/> <text x="120" y="54" text-anchor="middle" fill="#7af">ID</text> <rect x="160" y="35" width="60" height="28" rx="3" fill="none" stroke="#7af" stroke-width="1.2"/> <text x="190" y="54" text-anchor="middle" fill="#7af">EX</text> <rect x="230" y="35" width="60" height="28" rx="3" fill="none" stroke="#7af" stroke-width="1.2"/> <text x="260" y="54" text-anchor="middle" fill="#7af">MEM</text> <rect x="300" y="35" width="60" height="28" rx="3" fill="none" stroke="#7af" stroke-width="1.2"/> <text x="330" y="54" text-anchor="middle" fill="#7af">WB</text>

<text x="20" y="105" fill="#aaa">Superscalar (IPC = 2, 2-wide):</text>

<!-- Lane 1 --> <rect x="20" y="115" width="60" height="28" rx="3" fill="none" stroke="#fa7" stroke-width="1.2"/> <text x="50" y="134" text-anchor="middle" fill="#fa7">IF</text> <rect x="90" y="115" width="60" height="28" rx="3" fill="none" stroke="#fa7" stroke-width="1.2"/> <text x="120" y="134" text-anchor="middle" fill="#fa7">ID</text> <rect x="160" y="115" width="60" height="28" rx="3" fill="none" stroke="#fa7" stroke-width="1.2"/> <text x="190" y="134" text-anchor="middle" fill="#fa7">EX</text> <rect x="230" y="115" width="60" height="28" rx="3" fill="none" stroke="#fa7" stroke-width="1.2"/> <text x="260" y="134" text-anchor="middle" fill="#fa7">MEM</text> <rect x="300" y="115" width="60" height="28" rx="3" fill="none" stroke="#fa7" stroke-width="1.2"/> <text x="330" y="134" text-anchor="middle" fill="#fa7">WB</text> <!-- Lane 2 --> <rect x="20" y="148" width="60" height="28" rx="3" fill="none" stroke="#fa7" stroke-width="1.2"/> <text x="50" y="167" text-anchor="middle" fill="#fa7">IF</text> <rect x="90" y="148" width="60" height="28" rx="3" fill="none" stroke="#fa7" stroke-width="1.2"/> <text x="120" y="167" text-anchor="middle" fill="#fa7">ID</text> <rect x="160" y="148" width="60" height="28" rx="3" fill="none" stroke="#fa7" stroke-width="1.2"/> <text x="190" y="167" text-anchor="middle" fill="#fa7">EX</text> <rect x="230" y="148" width="60" height="28" rx="3" fill="none" stroke="#fa7" stroke-width="1.2"/> <text x="260" y="167" text-anchor="middle" fill="#fa7">MEM</text> <rect x="300" y="148" width="60" height="28" rx="3" fill="none" stroke="#fa7" stroke-width="1.2"/> <text x="330" y="167" text-anchor="middle" fill="#fa7">WB</text> <!-- annotations --> <text x="420" y="54" fill="#aaa">1 instr / cycle</text> <text x="420" y="141" fill="#aaa">2 instr / cycle</text> </svg>

---

### Structural Overview

A superscalar pipeline widens every stage. Each stage must process _w_ instructions per cycle, where _w_ is the issue width.

<svg viewBox="0 0 720 300" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <defs> <marker id="arr" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#888"/> </marker> </defs> <!-- Stage boxes --> <!-- Fetch --> <rect x="20" y="80" width="90" height="120" rx="4" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="65" y="70" text-anchor="middle" fill="#7af" font-size="12">Fetch</text> <text x="65" y="108" text-anchor="middle" fill="#aaa">I-Cache</text> <text x="65" y="124" text-anchor="middle" fill="#aaa">w words</text> <text x="65" y="140" text-anchor="middle" fill="#aaa">per cycle</text> <text x="65" y="160" text-anchor="middle" fill="#aaa">Branch</text> <text x="65" y="174" text-anchor="middle" fill="#aaa">Predict</text> <!-- Decode --> <rect x="140" y="80" width="90" height="120" rx="4" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="185" y="70" text-anchor="middle" fill="#7af" font-size="12">Decode</text> <text x="185" y="108" text-anchor="middle" fill="#aaa">w decode</text> <text x="185" y="124" text-anchor="middle" fill="#aaa">units</text> <text x="185" y="144" text-anchor="middle" fill="#aaa">Dep.</text> <text x="185" y="160" text-anchor="middle" fill="#aaa">check</text> <!-- Issue / Dispatch --> <rect x="260" y="80" width="90" height="120" rx="4" fill="none" stroke="#fa7" stroke-width="1.5"/> <text x="305" y="70" text-anchor="middle" fill="#fa7" font-size="12">Issue</text> <text x="305" y="108" text-anchor="middle" fill="#aaa">Issue</text> <text x="305" y="124" text-anchor="middle" fill="#aaa">queue /</text> <text x="305" y="140" text-anchor="middle" fill="#aaa">Sched.</text> <text x="305" y="160" text-anchor="middle" fill="#aaa">Reg read</text> <!-- Execute --> <rect x="380" y="50" width="110" height="180" rx="4" fill="none" stroke="#fa7" stroke-width="1.5"/> <text x="435" y="40" text-anchor="middle" fill="#fa7" font-size="12">Execute</text> <text x="435" y="78" text-anchor="middle" fill="#aaa">ALU₀</text> <text x="435" y="96" text-anchor="middle" fill="#aaa">ALU₁</text> <text x="435" y="114" text-anchor="middle" fill="#aaa">FPU</text> <text x="435" y="132" text-anchor="middle" fill="#aaa">Load/</text> <text x="435" y="148" text-anchor="middle" fill="#aaa">Store</text> <text x="435" y="166" text-anchor="middle" fill="#aaa">Branch</text> <text x="435" y="184" text-anchor="middle" fill="#aaa">Unit</text> <text x="435" y="202" text-anchor="middle" fill="#aaa">Mult</text> <!-- Writeback --> <rect x="520" y="80" width="90" height="120" rx="4" fill="none" stroke="#8f8" stroke-width="1.5"/> <text x="565" y="70" text-anchor="middle" fill="#8f8" font-size="12">Commit</text> <text x="565" y="108" text-anchor="middle" fill="#aaa">ROB /</text> <text x="565" y="124" text-anchor="middle" fill="#aaa">In-order</text> <text x="565" y="140" text-anchor="middle" fill="#aaa">retire</text> <text x="565" y="160" text-anchor="middle" fill="#aaa">RegFile</text> <text x="565" y="176" text-anchor="middle" fill="#aaa">write</text> <!-- Arrows --> <line x1="110" y1="140" x2="138" y2="140" stroke="#888" stroke-width="1.2" marker-end="url(#arr)"/> <line x1="230" y1="140" x2="258" y2="140" stroke="#888" stroke-width="1.2" marker-end="url(#arr)"/> <line x1="350" y1="140" x2="378" y2="140" stroke="#888" stroke-width="1.2" marker-end="url(#arr)"/> <line x1="490" y1="140" x2="518" y2="140" stroke="#888" stroke-width="1.2" marker-end="url(#arr)"/> <!-- IPC ceiling annotation -->

<text x="650" y="130" fill="#aaa">Theoretical</text> <text x="650" y="145" fill="#aaa">IPC ceiling</text> <text x="650" y="162" fill="#fa7" font-size="13">= w</text> </svg>

---

### Fetch Stage

The fetch stage must supply _w_ instructions per cycle to keep the pipeline full. This imposes several requirements not present in scalar designs.

#### Wide Instruction Fetch

The instruction cache must deliver _w_ instructions per cycle. For a 4-wide machine fetching 32-bit instructions, this is 128 bits per cycle. The cache is typically designed with a wide read port or banked to deliver this bandwidth.

**Alignment problem:** Instructions fetched from an arbitrary PC may straddle a cache line boundary. The fetch unit must handle partial fetch groups — cycles where fewer than _w_ instructions are available because of a branch target in the middle of a fetch block.

#### Fetch Buffer / Instruction Queue

Fetched instructions are placed into an instruction queue (also called a fetch buffer or instruction window) to decouple the fetch rate from the decode rate. This absorbs short-term fetch bandwidth fluctuations caused by branch mispredictions and cache misses.

#### Branch Prediction at Fetch Width

A scalar machine predicts one branch per cycle. A superscalar fetch unit may encounter **multiple branches within a single fetch group**. The fetch unit must:

- Identify all branches in the fetch group
- Predict each branch
- Redirect the fetch stream from the predicted target of the first taken branch

This requires a **multi-branch predictor** capable of resolving several branches simultaneously, adding significant complexity to the branch prediction logic.

---

### Decode Stage

_w_ decode units operate in parallel. Each unit resolves the instruction type, source and destination registers, immediate values, and functional unit requirements.

**Dependency detection** begins here. The decode stage identifies:

- **RAW (Read After Write):** instruction _j_ reads a register written by instruction _i_, where _i_ precedes _j_ in program order
- **WAR (Write After Read):** instruction _j_ writes a register read by instruction _i_ — a false dependency eliminated by register renaming
- **WAW (Write After Write):** two instructions write the same register — also a false dependency eliminated by renaming

In an in-order superscalar, the decode stage enforces these dependencies directly. In an out-of-order superscalar, detection results are passed to the issue stage and register renaming logic.

---

### Issue Policies

The issue stage determines which instructions from the instruction window are dispatched to functional units in a given cycle. Two broad policies exist:

#### In-Order Issue

Instructions are issued in program order. An instruction cannot issue until all preceding instructions have issued. A single stalled instruction blocks all instructions behind it — this is called a **structural stall** or **issue stall**.

- Simple hardware
- Low IPC — a single long-latency instruction (e.g., cache miss) stalls the entire pipeline
- Used in early superscalars and some embedded processors

#### Out-of-Order Issue

Instructions are issued as soon as their operands are ready and a functional unit is available, regardless of program order. An instruction window (issue queue or reservation stations) holds instructions waiting for operands. The scheduler scans the window each cycle and selects eligible instructions.

- Complex hardware — requires Tomasulo-style scheduling, register renaming, and a reorder buffer
- Higher IPC — long-latency instructions do not block independent instructions
- Used in all modern high-performance processors (Intel Core, AMD Zen, ARM Cortex-A)

---

### Static vs. Dynamic Superscalar

|Property|Static (In-Order)|Dynamic (Out-of-Order)|
|---|---|---|
|Issue order|Program order|Dataflow order|
|Scheduling|Compiler|Hardware at runtime|
|Dependency handling|Stall or compiler NOP insertion|Tomasulo + ROB|
|Hardware complexity|Moderate|High|
|IPC potential|Limited|Higher|
|Examples|Early SPARC, ARM Cortex-A53|Intel Core, AMD Zen, Apple M-series|

---

### Functional Unit Composition

A superscalar processor contains multiple heterogeneous functional units. Not every unit can execute every instruction — the set of units determines which combinations of instructions can be issued simultaneously.

|Unit|Instructions Handled|
|---|---|
|Integer ALU|Add, sub, logical, shift, compare|
|Load/Store Unit (LSU)|Memory reads and writes|
|Branch Unit|Conditional and unconditional branches|
|Floating Point Unit (FPU)|FP add, multiply, divide|
|Multiply/Divide Unit|Integer multiply, divide|
|SIMD Unit|Vector operations|

A 4-wide machine might have: 2 integer ALUs, 1 LSU, 1 branch unit, 1 FPU. Instructions can only issue to their compatible unit. An instruction mix with many floating-point operations saturates the FPU while leaving integer units idle — this is a **structural hazard** at the issue level.

---

### Hazards in Superscalar Pipelines

Superscalar execution introduces all scalar hazards at increased frequency, plus new forms specific to wide issue.

#### Structural Hazards

Arise when more instructions of a given type are ready to issue than there are functional units to handle them. The scheduler must stall or hold back excess instructions.

#### Data Hazards — RAW at Issue Width

In a 2-wide in-order machine, instructions _i_ and _i+1_ may be issued in the same cycle. If _i+1_ reads a register written by _i_, the result of _i_ is not yet available. Options:

1. Stall _i+1_ by one cycle
2. Detect the dependency and issue _i+1_ alone (issue one instead of two)
3. Use forwarding if the latency allows

For out-of-order machines, Tomasulo scheduling handles this: _i+1_ waits in its reservation station until the result of _i_ is broadcast on the common data bus.

#### WAR and WAW — False Dependencies

These do not reflect true dataflow but arise from register name reuse:

```
I1: ADD R3 ← R1 + R2     (writes R3)
I2: SUB R3 ← R4 + R5     (WAW: both write R3)
I3: MUL R6 ← R3 + R7     (RAW on R3 — which R3?)
```

**Register renaming** resolves this by mapping architectural registers to a larger physical register file. Each write to an architectural register allocates a new physical register, eliminating WAR and WAW hazards entirely.

---

### Register Renaming in Superscalar Context

For a _w_-wide machine, the rename stage must allocate _w_ new physical registers per cycle and update _w_ rename table entries atomically. The rename table (also called the Register Alias Table, RAT) maps architectural register names to physical register names.

<svg viewBox="0 0 620 230" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <defs> <marker id="arr2" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#888"/> </marker> </defs> <!-- Arch register file --> <rect x="20" y="50" width="110" height="140" rx="4" fill="none" stroke="#888" stroke-width="1.5"/> <text x="75" y="40" text-anchor="middle" fill="#aaa">Arch. Registers</text> <text x="75" y="78" text-anchor="middle" fill="#ccc">R0</text> <text x="75" y="96" text-anchor="middle" fill="#ccc">R1</text> <text x="75" y="114" text-anchor="middle" fill="#ccc">R2</text> <text x="75" y="132" text-anchor="middle" fill="#ccc">R3</text> <text x="75" y="150" text-anchor="middle" fill="#ccc">...</text> <text x="75" y="168" text-anchor="middle" fill="#ccc">R31</text> <!-- RAT --> <rect x="200" y="50" width="130" height="140" rx="4" fill="none" stroke="#fa7" stroke-width="1.5"/> <text x="265" y="40" text-anchor="middle" fill="#fa7">RAT</text> <text x="265" y="75" text-anchor="middle" fill="#ccc">R0 → P14</text> <text x="265" y="93" text-anchor="middle" fill="#ccc">R1 → P07</text> <text x="265" y="111" text-anchor="middle" fill="#ccc">R2 → P31</text> <text x="265" y="129" text-anchor="middle" fill="#ccc">R3 → P52</text> <text x="265" y="147" text-anchor="middle" fill="#ccc">...</text> <text x="265" y="165" text-anchor="middle" fill="#ccc">R31 → P19</text> <!-- Physical register file --> <rect x="410" y="30" width="120" height="170" rx="4" fill="none" stroke="#8f8" stroke-width="1.5"/> <text x="470" y="22" text-anchor="middle" fill="#8f8">Physical Registers</text> <text x="470" y="58" text-anchor="middle" fill="#ccc">P00..P07</text> <text x="470" y="80" text-anchor="middle" fill="#ccc">P08..P15</text> <text x="470" y="102" text-anchor="middle" fill="#ccc">P16..P23</text> <text x="470" y="124" text-anchor="middle" fill="#ccc">P24..P31</text> <text x="470" y="146" text-anchor="middle" fill="#ccc">...</text> <text x="470" y="168" text-anchor="middle" fill="#ccc">P56..P63</text> <text x="470" y="190" text-anchor="middle" fill="#aaa" font-size="10">(64 or more entries)</text> <!-- Arrows --> <line x1="130" y1="120" x2="198" y2="120" stroke="#888" stroke-width="1.2" marker-end="url(#arr2)"/> <line x1="330" y1="120" x2="408" y2="120" stroke="#888" stroke-width="1.2" marker-end="url(#arr2)"/> </svg>

When a _w_-wide rename stage processes _w_ instructions simultaneously, it must handle the case where two instructions in the same rename group write the same architectural register — the second write's physical register mapping must shadow the first within the same cycle.

---

### Commit and the Reorder Buffer

Out-of-order execution produces results in dataflow order, but **exceptions and precise state** require that architectural state be updated in program order. The **Reorder Buffer (ROB)** is a circular queue that holds instructions from dispatch until they retire in order.

```
Dispatch:  instruction enters tail of ROB
Complete:  instruction marks itself done (out of order)
Commit:    instruction at head of ROB, if done, updates arch. state and leaves
```

For a _w_-wide machine, up to _w_ instructions commit per cycle (in-order from the ROB head) and up to _w_ instructions enter the ROB tail per cycle.

**ROB sizing:** A larger ROB increases the instruction window — the number of in-flight instructions — enabling more ILP to be found. Modern processors use ROBs of 200–600 entries. [Inference: larger ROBs generally improve IPC on memory-latency-bound workloads, but returns diminish; exact behavior depends on workload characteristics and is not guaranteed.]

---

### Commit Width and Retirement

The commit stage retires up to _w_ instructions per cycle from the head of the ROB. Retirement:

1. Copies the physical register value to the architectural register file (or marks the mapping permanent)
2. Frees the old physical register that previously held this architectural register's value
3. Handles exceptions or flushes speculatively executed instructions if misprediction or fault is detected at commit

If a mispredicted branch reaches the head of the ROB, all instructions after it are squashed, the ROB is flushed from that point, and the fetch unit redirects to the correct path.

---

### Superscalar Pipeline Timing Diagram

A 2-wide in-order superscalar processing 6 instructions (no hazards):

```
Cycle:      1    2    3    4    5    6    7
I0:        IF   ID   EX  MEM   WB
I1:        IF   ID   EX  MEM   WB
I2:             IF   ID   EX  MEM   WB
I3:             IF   ID   EX  MEM   WB
I4:                  IF   ID   EX  MEM   WB
I5:                  IF   ID   EX  MEM   WB
```

I0 and I1 are fetched together; I2 and I3 together; I4 and I5 together. All 6 instructions complete by cycle 7. A scalar pipeline would require cycle 10.

With a RAW hazard between I1 and I2 in an in-order machine:

```
Cycle:      1    2    3    4    5    6    7    8
I0:        IF   ID   EX  MEM   WB
I1:        IF   ID   EX  MEM   WB
I2:             IF   ID  ---   EX  MEM   WB        (stalled 1 cycle)
I3:             IF  ---   ID   EX  MEM   WB
```

The stall propagates through the entire fetch group behind it.

---

### IPC Limiting Factors

Theoretical peak IPC equals the issue width _w_. Measured IPC falls below this due to:

|Factor|Effect|
|---|---|
|RAW data hazards|Stalls or partial issue groups|
|Branch mispredictions|Pipeline flush, refill latency|
|Cache misses|Long-latency stalls block commit|
|Structural hazards|Functional unit contention|
|False dependencies (without renaming)|WAR/WAW stalls|
|Instruction alignment|Fetch group cannot always fill to width _w_|
|Control flow divergence|Taken branches terminate fetch group early|

**Amdahl's Law applies within a single core:** the sequential portion of an instruction stream — chains of dependent instructions — limits IPC regardless of issue width. A dependent chain of length _L_ with one instruction per cycle cannot complete in fewer than _L_ cycles regardless of how many other independent instructions are available.

---

### Performance Metrics

**IPC (Instructions Per Cycle):**

```
IPC = Instructions_completed / Cycles_elapsed
```

**Throughput** for a _w_-wide machine with average IPC observed:

```
Throughput = IPC × Clock_frequency
```

**Issue efficiency:**

```
Issue_efficiency = IPC / w
```

A 4-wide machine achieving IPC = 2.4 has an issue efficiency of 60%. Real processors typically achieve 30–70% issue efficiency on general-purpose workloads. [Inference: values are representative of published microarchitecture studies; actual efficiency depends heavily on workload.]

---

### Comparison of Superscalar Approaches

|Design Point|In-Order Superscalar|Out-of-Order Superscalar|
|---|---|---|
|Issue queue|None (or shallow)|Deep reservation stations / unified queue|
|Scheduling|Static (compiler)|Dynamic (hardware)|
|Register renaming|Optional|Required|
|ROB|Not required|Required for precise exceptions|
|Transistor budget|Moderate|High|
|Power|Lower|Higher|
|Target|Embedded, mobile|Server, desktop, high-performance mobile|
|Examples|ARM Cortex-A53, early MIPS R8000|Intel Core, AMD Zen 4, Apple M4|

---

### Real Processor Issue Widths

|Processor|Issue Width|ROB Size|Notes|
|---|---|---|---|
|Intel Core i9 (Sunny Cove)|4-wide decode|352 entries|Out-of-order|
|AMD Zen 4|4-wide decode|320 entries|Out-of-order|
|Apple M3 (Avalanche)|9-wide decode|~650 entries|Out-of-order|
|ARM Cortex-A55|2-wide|Shallow|In-order|
|IBM POWER10|8-wide|512 entries|Out-of-order, SMT-capable|

[Unverified: specific ROB sizes are based on published microarchitecture analyses and may not reflect undisclosed internal specifications. Disclaimer: these figures are commonly cited in architectural literature but are not official manufacturer disclosures.]

---

**Key Points**

- A superscalar pipeline widens every stage to _w_ slots; theoretical IPC ceiling is _w_, practical IPC is substantially lower.
- In-order superscalar is simpler but suffers from a single stalled instruction blocking the entire issue group.
- Out-of-order superscalar adds an issue queue, Tomasulo-style scheduling, register renaming, and a reorder buffer to issue instructions in dataflow order while committing in program order.
- Register renaming eliminates WAR and WAW false dependencies, which would otherwise impose unnecessary stalls in a wide issue machine.
- The ROB enforces in-order commit, enabling precise exceptions and correct recovery from branch mispredictions in an out-of-order machine.
- Fetch width, branch prediction, cache behavior, and dependent instruction chains are the primary limiters of practical IPC below the theoretical ceiling.
- Issue efficiency on general-purpose workloads is typically 30–70% of peak, depending on the instruction mix and memory behavior.

**Conclusion** Superscalar pipelines extend the pipeline model from IPC ≤ 1 to IPC ≤ _w_ by replicating and widening every pipeline stage. The mechanisms required to approach this ceiling — out-of-order scheduling, register renaming, and in-order commit via the ROB — constitute the core of modern high-performance microarchitecture. Each mechanism directly addresses a specific class of hazard or dependency that would otherwise serialize instruction execution and collapse effective IPC toward 1.

**Next Steps**

- Tomasulo's Algorithm — the scheduling mechanism underlying out-of-order issue in superscalar processors
- Reorder Buffer (ROB) — precise exception handling and speculative execution in the context of wide commit
- Branch Prediction — multi-branch fetch-group prediction, a requirement specific to superscalar fetch width
- Register Renaming — physical register file sizing, freelist management, and RAT design for _w_-wide rename

---

