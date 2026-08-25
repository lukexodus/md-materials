## Reorder Buffer


The Reorder Buffer (ROB) is the central hardware structure that enables **out-of-order execution with in-order commitment**. It decouples the order in which instructions execute from the order in which their results are permanently written to architectural state, allowing speculative and out-of-order execution while preserving the precise exception model and sequential consistency guarantees of the ISA.

---

### The Problem ROB Solves

Out-of-order execution allows instructions to execute as soon as their operands are ready, regardless of program order. Without a mechanism to control commitment, this creates two critical problems:

**Problem 1 — Imprecise Exceptions:** If instruction $I_5$ causes a fault but $I_7$ has already written its result to the register file, the architectural state is corrupt — it reflects partial execution beyond the faulting instruction. Recovery is impossible.

**Problem 2 — Mis-speculation Exposure:** If a branch is predicted taken and subsequent instructions execute and write results, a misprediction has no clean rollback point.

The ROB solves both by acting as a **staging buffer**: instructions write results into the ROB first; results migrate to permanent architectural state only when the instruction is the oldest in-flight and known to be correct.

---

### Position in the Out-of-Order Pipeline

<svg viewBox="0 0 640 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- In-order front end --> <rect x="10" y="70" width="80" height="60" rx="3" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="50" y="96" text-anchor="middle" fill="#7af">Fetch /</text> <text x="50" y="110" text-anchor="middle" fill="#7af">Decode</text> <text x="50" y="123" text-anchor="middle" fill="#aaa" font-size="9">In-order</text> <line x1="90" y1="100" x2="115" y2="100" stroke="#aaa" stroke-width="1.2" marker-end="url(#rb)"/> <!-- Rename --> <rect x="115" y="70" width="80" height="60" rx="3" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="155" y="96" text-anchor="middle" fill="#7af">Rename /</text> <text x="155" y="110" text-anchor="middle" fill="#7af">Dispatch</text> <text x="155" y="123" text-anchor="middle" fill="#aaa" font-size="9">In-order</text> <line x1="195" y1="100" x2="220" y2="100" stroke="#aaa" stroke-width="1.2" marker-end="url(#rb)"/> <!-- ROB --> <rect x="220" y="30" width="180" height="150" rx="4" fill="none" stroke="#fa7" stroke-width="2"/> <text x="310" y="55" text-anchor="middle" fill="#fa7" font-size="13">ROB</text> <text x="310" y="73" text-anchor="middle" fill="#aaa" font-size="9">Circular buffer</text> <text x="310" y="87" text-anchor="middle" fill="#aaa" font-size="9">entries allocated in-order</text> <text x="310" y="101" text-anchor="middle" fill="#aaa" font-size="9">retired in-order</text> <text x="310" y="115" text-anchor="middle" fill="#aaa" font-size="9">executed out-of-order</text> <!-- RS / OOO --> <rect x="430" y="55" width="95" height="45" rx="3" fill="none" stroke="#5cf" stroke-width="1.5"/> <text x="477" y="74" text-anchor="middle" fill="#5cf">Reservation</text> <text x="477" y="87" text-anchor="middle" fill="#5cf">Stations</text> <rect x="430" y="120" width="95" height="45" rx="3" fill="none" stroke="#5cf" stroke-width="1.5"/> <text x="477" y="139" text-anchor="middle" fill="#5cf">Execution</text> <text x="477" y="152" text-anchor="middle" fill="#5cf">Units</text> <!-- Commit --> <rect x="550" y="70" width="80" height="60" rx="3" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="590" y="96" text-anchor="middle" fill="#7af">Commit /</text> <text x="590" y="110" text-anchor="middle" fill="#7af">Retire</text> <text x="590" y="123" text-anchor="middle" fill="#aaa" font-size="9">In-order</text> <!-- Arrows --> <line x1="400" y1="78" x2="430" y2="78" stroke="#aaa" stroke-width="1.2" marker-end="url(#rb)"/> <line x1="400" y1="142" x2="430" y2="142" stroke="#aaa" stroke-width="1.2" marker-end="url(#rb)"/> <line x1="525" y1="142" x2="400" y2="115" stroke="#aaa" stroke-width="1" stroke-dasharray="4,3" marker-end="url(#rb)"/> <line x1="540" y1="100" x2="550" y2="100" stroke="#aaa" stroke-width="1.2" marker-end="url(#rb)"/> <!-- Label OOO zone -->

<text x="477" y="185" text-anchor="middle" fill="#555" font-size="9">Out-of-order zone</text>

<defs> <marker id="rb" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#aaa"/> </marker> </defs> </svg>

The front end (fetch, decode, rename, dispatch) and back end (commit/retire) operate strictly **in program order**. Only the middle zone — issue, execute, writeback — is out of order.

---

### ROB Structure

The ROB is implemented as a **circular FIFO buffer** with a head pointer (oldest instruction, next to commit) and a tail pointer (newest instruction, most recently allocated).

Each ROB entry contains:

|Field|Width (typical)|Purpose|
|---|---|---|
|Instruction type|3–4 bits|ALU / Load / Store / Branch|
|Destination register|5–6 bits|Architectural register to write|
|Value|64 bits|Computed result (valid when done)|
|Done bit|1 bit|Set when execution completes|
|Exception|1 bit|Instruction caused a fault|
|Exception code|4–8 bits|Fault type (page fault, div-zero…)|
|PC|48–64 bits|For precise exception reporting|
|Speculative|1 bit|Instruction is past an unresolved branch|
|Store address|64 bits|For store instructions|

A 192-entry ROB (e.g., Intel Skylake class) requires substantial area but enables hiding long-latency operation stalls.

<svg viewBox="0 0 580 180" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- ROB circular buffer visualization --> <text x="290" y="20" text-anchor="middle" fill="#ccc" font-size="12">ROB — Circular Buffer</text> <!-- Draw entries as a ring of rectangles --> <!-- Top row (entries 0-5) --> <rect x="30" y="40" width="80" height="36" rx="2" fill="#1a2a1a" stroke="#5cf" stroke-width="1.5"/> <text x="70" y="55" text-anchor="middle" fill="#5cf" font-size="9">Entry 0</text> <text x="70" y="68" text-anchor="middle" fill="#aaa" font-size="8">DONE ✓</text> <rect x="115" y="40" width="80" height="36" rx="2" fill="#1a2a1a" stroke="#5cf" stroke-width="1.5"/> <text x="155" y="55" text-anchor="middle" fill="#5cf" font-size="9">Entry 1</text> <text x="155" y="68" text-anchor="middle" fill="#aaa" font-size="8">DONE ✓</text> <rect x="200" y="40" width="80" height="36" rx="2" fill="#1a2a1a" stroke="#fa7" stroke-width="1.5"/> <text x="240" y="55" text-anchor="middle" fill="#fa7" font-size="9">Entry 2</text> <text x="240" y="68" text-anchor="middle" fill="#aaa" font-size="8">executing</text> <rect x="285" y="40" width="80" height="36" rx="2" fill="#1a2a1a" stroke="#fa7" stroke-width="1.5"/> <text x="325" y="55" text-anchor="middle" fill="#fa7" font-size="9">Entry 3</text> <text x="325" y="68" text-anchor="middle" fill="#aaa" font-size="8">executing</text> <rect x="370" y="40" width="80" height="36" rx="2" fill="#1a1a1a" stroke="#555" stroke-width="1.5"/> <text x="410" y="55" text-anchor="middle" fill="#555" font-size="9">Entry 4</text> <text x="410" y="68" text-anchor="middle" fill="#555" font-size="8">waiting</text> <rect x="455" y="40" width="80" height="36" rx="2" fill="#1a1a1a" stroke="#555" stroke-width="1.5"/> <text x="495" y="55" text-anchor="middle" fill="#555" font-size="9">Entry 5</text> <text x="495" y="68" text-anchor="middle" fill="#555" font-size="8">waiting</text> <!-- Bottom row (entries 6-11, free) --> <rect x="30" y="115" width="80" height="36" rx="2" fill="#111" stroke="#333" stroke-width="1"/> <text x="70" y="135" text-anchor="middle" fill="#333" font-size="9">Entry 11</text> <text x="70" y="147" text-anchor="middle" fill="#333" font-size="8">free</text> <rect x="455" y="115" width="80" height="36" rx="2" fill="#111" stroke="#333" stroke-width="1"/> <text x="495" y="135" text-anchor="middle" fill="#333" font-size="9">Entry 6</text> <text x="495" y="147" text-anchor="middle" fill="#333" font-size="8">free</text> <!-- Dots for other free entries -->

<text x="260" y="140" text-anchor="middle" fill="#333" font-size="16">· · · · free entries · · · ·</text>

<!-- Head/Tail arrows -->

<text x="70" y="30" text-anchor="middle" fill="#5cf" font-size="9">← HEAD (commit)</text> <text x="495" y="108" text-anchor="middle" fill="#fa7" font-size="9">TAIL (allocate) →</text>

<!-- Arrow wrapping --> <path d="M535,133 Q575,133 575,58 Q575,40 535,40" fill="none" stroke="#333" stroke-width="1" stroke-dasharray="3,3"/> <path d="M30,133 Q10,133 10,58 Q10,40 30,40" fill="none" stroke="#333" stroke-width="1" stroke-dasharray="3,3"/> </svg>

---

### Lifecycle of an Instruction Through the ROB

```
1. ALLOCATE  (Rename/Dispatch stage, in program order)
     ├─ Tail pointer selects next free ROB entry
     ├─ ROB entry initialized: done=0, destination reg recorded
     └─ ROB entry number becomes the instruction's "tag"
             ↓
2. ISSUE
     └─ Instruction issued to reservation station with ROB tag
             ↓
3. EXECUTE  (Out of order — any order operands are ready)
     └─ Execution unit computes result
             ↓
4. WRITEBACK (to ROB, not register file)
     ├─ Result written to ROB entry's Value field
     ├─ Done bit set to 1
     └─ Result broadcast on Common Data Bus (CDB) for forwarding
             ↓
5. COMMIT  (In program order — only when entry is at HEAD)
     ├─ Check: done=1 AND no exception AND not mis-speculated
     ├─ Write Value from ROB entry to architectural register file
     ├─ Advance HEAD pointer
     └─ Free ROB entry
```

Commit happens **one or more entries per cycle** (superscalar processors can retire multiple instructions per cycle), but always strictly oldest-first.

---

### ROB and Register Renaming

The ROB works in conjunction with register renaming to eliminate false dependences (WAR and WAW hazards). There are two primary renaming schemes:

#### Scheme 1: ROB as Physical Register File

The ROB entry itself holds the value. The register alias table (RAT) maps each architectural register to either:

- A **ROB entry tag** (result is in-flight or in ROB), or
- A **committed value** (result is in the architectural register file)

```
Architectural RF:   R3 = 42        (last committed value)
RAT entry for R3:  → ROB#17        (in-flight result in ROB slot 17)

If ROB#17 done=1:  forward Value from ROB#17
If ROB#17 done=0:  stall or wait for CDB broadcast
```

#### Scheme 2: Separate Physical Register File

A larger **physical register file (PRF)** holds all values — both committed and in-flight. The ROB stores only tags (pointers into the PRF) and control information, not the values themselves. Used in high-performance designs to decouple the ROB size from the value storage requirement.

|Scheme|ROB stores|Value access|Used in|
|---|---|---|---|
|ROB-as-PRF|Values directly|From ROB entry|Simpler designs, textbook Tomasulo|
|Separate PRF|Tags only|From physical register|Intel P6 / Core, AMD Zen|

---

### Precise Exceptions via ROB

When an instruction raises an exception:

- The exception flag and code are written into its ROB entry at writeback
- The instruction is **not** retired when it reaches the head — instead:
    1. All younger instructions in the ROB are **flushed** (squashed)
    2. ROB is drained of all entries after the faulting instruction
    3. Architectural state reflects exactly the state before the faulting instruction
    4. The exception handler is invoked with a precise PC

This guarantees the **precise exception model** required by most ISAs: the machine state at the point of exception exactly corresponds to sequential execution up to and not including the faulting instruction.

<svg viewBox="0 0 580 120" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- ROB entries before exception handling --> <text x="290" y="18" text-anchor="middle" fill="#aaa" font-size="10">ROB state when exception at Entry 3 reaches HEAD</text> <rect x="20" y="30" width="75" height="50" rx="2" fill="#1a2a1a" stroke="#5cf" stroke-width="1.5"/> <text x="57" y="50" text-anchor="middle" fill="#5cf" font-size="9">Entry 0</text> <text x="57" y="63" text-anchor="middle" fill="#5cf" font-size="8">committed</text> <text x="57" y="73" text-anchor="middle" fill="#5cf" font-size="8">✓</text> <rect x="100" y="30" width="75" height="50" rx="2" fill="#1a2a1a" stroke="#5cf" stroke-width="1.5"/> <text x="137" y="50" text-anchor="middle" fill="#5cf" font-size="9">Entry 1</text> <text x="137" y="63" text-anchor="middle" fill="#5cf" font-size="8">committed</text> <text x="137" y="73" text-anchor="middle" fill="#5cf" font-size="8">✓</text> <rect x="180" y="30" width="75" height="50" rx="2" fill="#1a2a1a" stroke="#5cf" stroke-width="1.5"/> <text x="217" y="50" text-anchor="middle" fill="#5cf" font-size="9">Entry 2</text> <text x="217" y="63" text-anchor="middle" fill="#5cf" font-size="8">committed</text> <text x="217" y="73" text-anchor="middle" fill="#5cf" font-size="8">✓</text> <rect x="260" y="30" width="75" height="50" rx="2" fill="#3a1a1a" stroke="#f77" stroke-width="2"/> <text x="297" y="50" text-anchor="middle" fill="#f77" font-size="9">Entry 3</text> <text x="297" y="63" text-anchor="middle" fill="#f77" font-size="8">EXCEPTION</text> <text x="297" y="73" text-anchor="middle" fill="#f77" font-size="8">page fault</text> <rect x="340" y="30" width="75" height="50" rx="2" fill="#1a1a2a" stroke="#555" stroke-width="1.5" stroke-dasharray="4,3"/> <text x="377" y="50" text-anchor="middle" fill="#555" font-size="9">Entry 4</text> <text x="377" y="63" text-anchor="middle" fill="#555" font-size="8">SQUASH</text> <rect x="420" y="30" width="75" height="50" rx="2" fill="#1a1a2a" stroke="#555" stroke-width="1.5" stroke-dasharray="4,3"/> <text x="457" y="50" text-anchor="middle" fill="#555" font-size="9">Entry 5</text> <text x="457" y="63" text-anchor="middle" fill="#555" font-size="8">SQUASH</text> <rect x="500" y="30" width="70" height="50" rx="2" fill="#1a1a2a" stroke="#555" stroke-width="1.5" stroke-dasharray="4,3"/> <text x="535" y="50" text-anchor="middle" fill="#555" font-size="9">Entry 6</text> <text x="535" y="63" text-anchor="middle" fill="#555" font-size="8">SQUASH</text> <!-- Arrow showing squash direction --> <line x1="500" y1="105" x2="345" y2="105" stroke="#f77" stroke-width="1.5" marker-end="url(#rs)"/> <text x="430" y="118" text-anchor="middle" fill="#f77" font-size="9">flush all younger entries</text> <defs> <marker id="rs" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#f77"/> </marker> </defs> </svg>

---

### Branch Misprediction Recovery

When the branch execution unit resolves a branch in the EX stage and determines the prediction was wrong:

1. The branch's ROB entry is at some position — not necessarily the head
2. All ROB entries **younger than the branch** are squashed (tail is rewound to branch entry + 1)
3. The RAT is restored to reflect only instructions up to and including the branch
4. The front end restarts fetch from the correct target PC

The ROB entry count between the branch and the tail determines the **misprediction penalty** in terms of wasted work — all those in-flight instructions are discarded.

$$\text{Misprediction penalty} \approx \text{(pipeline stages from fetch to branch resolution)}$$

For a 14-stage pipeline resolving branches at stage 10: penalty ≈ 10 cycles of squashed instructions.

---

### ROB and the Store Buffer

Stores require special treatment. A store instruction cannot write to memory at execution time — the memory system must only be modified at commit, since the store might be speculative.

The mechanism:

```
EXECUTE:   Store address and value computed → written to ROB entry
                                           → also written to Store Buffer
COMMIT:    Store reaches ROB head → store is "graduated"
           → Store Buffer entry marked as committed
           → Store Buffer drains to D-cache / memory when ready
```

The **Store Buffer** (also called the Store Queue) sits between the ROB and the memory system. Loads must check the store buffer for forwarding — a load to address $A$ should receive the most recent committed-or-in-flight store value to $A$ rather than reading stale memory.

---

### ROB Size and Out-of-Order Window

The ROB size determines the **instruction window** — the maximum number of instructions that can be simultaneously in-flight. A larger ROB:

- Allows more instructions to be examined for independent work
- Increases the ability to tolerate long-latency operations (cache misses, divides)
- Requires more area and power
- Increases misprediction recovery cost (more entries to squash)

|Processor|Approximate ROB Size|
|---|---|
|Intel Pentium Pro (P6)|40 entries|
|Intel Core 2|96 entries|
|Intel Skylake|224 entries|
|Intel Golden Cove (Alder Lake P-core)|512 entries|
|AMD Zen 3|256 entries|
|Apple Firestorm (M1 P-core)|~630 entries [Inference]|

[Inference] Apple does not publicly disclose microarchitectural details; the ~630 figure circulates in reverse-engineering analyses and should be treated as an estimate, not a confirmed specification.

The effective instruction window is the **minimum** of ROB size, reservation station count, and physical register count — whichever fills first stalls allocation.

---

### ROB Interaction with the Common Data Bus (CDB)

When an execution unit completes, it broadcasts its result on the **Common Data Bus**:

```
Broadcast: (ROB_tag, value)

Recipients listen simultaneously:
  ├─ ROB entry matching ROB_tag: set done=1, store value
  └─ Reservation stations: wake up waiting instructions
                           whose source operand tag matches ROB_tag
```

This single broadcast mechanism links the ROB (for in-order commitment) with the reservation stations (for out-of-order scheduling) — the two central structures of the Tomasulo-style OOO engine.

<svg viewBox="0 0 580 160" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- CDB wire --> <line x1="30" y1="90" x2="550" y2="90" stroke="#fa7" stroke-width="2.5"/> <text x="290" y="82" text-anchor="middle" fill="#fa7" font-size="10">Common Data Bus (ROB_tag=7, value=0xFF)</text> <!-- Execution unit broadcasting --> <rect x="30" y="110" width="90" height="40" rx="3" fill="none" stroke="#5cf" stroke-width="1.5"/> <text x="75" y="127" text-anchor="middle" fill="#5cf">ALU</text> <text x="75" y="141" text-anchor="middle" fill="#aaa" font-size="9">broadcasts</text> <line x1="75" y1="110" x2="75" y2="90" stroke="#5cf" stroke-width="1.5" marker-end="url(#rc)"/> <!-- ROB receiving --> <rect x="190" y="110" width="90" height="40" rx="3" fill="none" stroke="#fa7" stroke-width="1.5"/> <text x="235" y="127" text-anchor="middle" fill="#fa7">ROB</text> <text x="235" y="141" text-anchor="middle" fill="#aaa" font-size="9">sets done=1</text> <line x1="235" y1="90" x2="235" y2="110" stroke="#fa7" stroke-width="1.5" marker-end="url(#rc)"/> <!-- RS receiving --> <rect x="360" y="110" width="110" height="40" rx="3" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="415" y="127" text-anchor="middle" fill="#7af">Reservation</text> <text x="415" y="141" text-anchor="middle" fill="#7af">Stations</text> <line x1="415" y1="90" x2="415" y2="110" stroke="#7af" stroke-width="1.5" marker-end="url(#rc)"/> <!-- RAT receiving (optional) --> <rect x="490" y="110" width="60" height="40" rx="3" fill="none" stroke="#aaa" stroke-width="1"/> <text x="520" y="127" text-anchor="middle" fill="#aaa">RAT</text> <text x="520" y="141" text-anchor="middle" fill="#555" font-size="9">update</text> <line x1="520" y1="90" x2="520" y2="110" stroke="#aaa" stroke-width="1.2" marker-end="url(#rc)"/> <defs> <marker id="rc" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#aaa"/> </marker> </defs> </svg>

---

### ROB State Machine Per Entry

Each ROB entry progresses through a well-defined set of states:

<svg viewBox="0 0 560 100" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect x="10" y="30" width="80" height="36" rx="20" fill="none" stroke="#333" stroke-width="1.5"/> <text x="50" y="52" text-anchor="middle" fill="#555">FREE</text> <rect x="130" y="30" width="80" height="36" rx="4" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="170" y="52" text-anchor="middle" fill="#7af">ALLOCATED</text> <rect x="260" y="30" width="80" height="36" rx="4" fill="none" stroke="#fa7" stroke-width="1.5"/> <text x="300" y="45" text-anchor="middle" fill="#fa7">EXECUTING</text> <text x="300" y="59" text-anchor="middle" fill="#aaa" font-size="9">(done=0)</text> <rect x="390" y="30" width="80" height="36" rx="4" fill="none" stroke="#5cf" stroke-width="1.5"/> <text x="430" y="45" text-anchor="middle" fill="#5cf">COMPLETE</text> <text x="430" y="59" text-anchor="middle" fill="#aaa" font-size="9">(done=1)</text> <!-- Commit arc --> <path d="M470,48 Q515,15 515,65 Q515,80 460,80 Q200,80 50,66" fill="none" stroke="#5cf" stroke-width="1" stroke-dasharray="4,3" marker-end="url(#rd)"/> <text x="510" y="12" fill="#5cf" font-size="9">commit</text> <text x="260" y="92" text-anchor="middle" fill="#555" font-size="9">→ FREE</text> <!-- Squash arc --> <path d="M300,30 Q300,10 180,10 Q90,10 90,30" fill="none" stroke="#f77" stroke-width="1" stroke-dasharray="4,3" marker-end="url(#rd)"/> <text x="220" y="8" fill="#f77" font-size="9">squash / flush</text> <!-- Forward arrows --> <line x1="90" y1="48" x2="130" y2="48" stroke="#aaa" stroke-width="1.5" marker-end="url(#rd)"/> <line x1="210" y1="48" x2="260" y2="48" stroke="#aaa" stroke-width="1.5" marker-end="url(#rd)"/> <line x1="340" y1="48" x2="390" y2="48" stroke="#aaa" stroke-width="1.5" marker-end="url(#rd)"/>

<text x="108" y="43" fill="#555" font-size="8">dispatch</text> <text x="220" y="43" fill="#555" font-size="8">issue</text> <text x="342" y="43" fill="#555" font-size="8">writeback</text>

<defs> <marker id="rd" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#aaa"/> </marker> </defs> </svg>

---

### Retirement Rate and Superscalar Commitment

A superscalar processor can **retire multiple instructions per cycle** — but only the $N$ oldest consecutive completed entries. If the oldest entry is not done, retirement stalls regardless of how many younger entries are complete.

```
ROB HEAD →  Entry 0: done=1  ✓  ← can commit
            Entry 1: done=1  ✓  ← can commit (if superscalar width ≥ 2)
            Entry 2: done=0  ✗  ← BLOCKS all further retirement
            Entry 3: done=1  ✓  ← cannot commit yet
            Entry 4: done=1  ✓  ← cannot commit yet
```

This **head-of-line blocking** is a fundamental constraint. A single long-latency instruction (e.g., an L2 cache miss taking 40 cycles) blocks retirement for all subsequent instructions regardless of whether they completed long ago.

---

### **Key Points**

- The ROB is the mechanism that allows out-of-order execution while preserving the in-order commitment required for precise exceptions and correct speculation recovery.
- Instructions are allocated into the ROB strictly in program order at dispatch; they are retired strictly in program order at commit; only execution itself is out of order.
- Each ROB entry is tagged with a unique identifier broadcast on the CDB at writeback — this tag links the ROB to the reservation station scheduling mechanism.
- Results are written to the architectural register file only at commit, never directly from execution units; the ROB entry holds values in-flight.
- Precise exceptions are implemented by flushing all entries younger than the faulting instruction and restoring the RAT to the pre-exception state.
- Branch misprediction recovery squashes all ROB entries younger than the resolved branch and restarts the front end from the correct PC.
- ROB size sets the instruction window — the maximum number of in-flight instructions — which directly determines the processor's ability to find and exploit ILP.
- Head-of-line blocking at the commit port means a single stalled instruction prevents all younger instructions from retiring, even if they completed long ago.

---

### **Example**

**Instruction sequence:**

```
I1:  ADD  R1, R2, R3     ; latency 1 cycle
I2:  LOAD R4, 0(R5)      ; latency 10 cycles (L1 miss assumed)
I3:  ADD  R6, R7, R8     ; latency 1 cycle
I4:  MUL  R9, R1, R6     ; latency 3 cycles, depends on I1 and I3
```

**ROB allocation (in order):**

|ROB#|Instr|Dest|Done at cycle|
|---|---|---|---|
|0|ADD|R1|3|
|1|LOAD|R4|13 (L1 miss)|
|2|ADD|R6|3|
|3|MUL|R9|7 (I1,I3 ready by cycle 3, MUL takes 3 more)|

**Retirement sequence:**

- Cycle 3: ROB#0 done=1 → commit R1. ROB#1 done=0 → **stall**
- Cycles 4–12: ROB#0 is gone; ROB#1 still at head, done=0 → retirement stalled despite ROB#2 (done since cycle 3) and ROB#3 (done since cycle 7) waiting
- Cycle 13: ROB#1 done=1 → commit R4. ROB#2 done=1 → commit R6. ROB#3 done=1 → commit R9. All three retire in one commit group.

The LOAD's 10-cycle latency holds up three already-complete instructions for 10 cycles at the retirement port — illustrating head-of-line blocking.

---

### **Conclusion**

The Reorder Buffer is the structural cornerstone of out-of-order processors. It provides the ordering discipline that makes speculative, out-of-order execution safe: by buffering results until they are the oldest in-flight instruction and known to be non-speculative, it reconciles the performance demands of dynamic scheduling with the ISA's requirement for precise, sequential architectural state. Every major design decision in an OOO processor — window size, retirement width, renaming scheme, branch recovery latency — is directly shaped by the ROB's properties and constraints.

---

### **Next Steps**

- **Tomasulo's Algorithm** — the full OOO scheduling mechanism of which the ROB is one component; understand how reservation stations, the CDB, and the ROB interact as a complete system
- **Register Renaming** — how the RAT eliminates WAR and WAW hazards and how it is checkpointed for misprediction recovery
- **Speculative Execution** — how the ROB's commit barrier enables control speculation and what the hardware costs of deep speculation windows are

---

