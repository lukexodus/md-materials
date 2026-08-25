## Tomasulo's Algorithm


Tomasulo's algorithm is a hardware-based dynamic scheduling scheme that achieves out-of-order execution while preserving correct dataflow semantics. It was introduced in 1967 in the IBM System/360 Model 91 floating-point unit. Its core contribution is the combination of **reservation stations**, **common data bus (CDB) broadcasting**, and **implicit register renaming** — eliminating WAR and WAW hazards without compiler intervention.

---

### Problem Being Solved

A naive in-order pipeline stalls whenever an instruction's source operand is not yet available (RAW hazard). Independent instructions behind the stall are blocked even though they could execute immediately.

Three hazard types exist in register name space:

|Hazard|Type|Cause|
|---|---|---|
|RAW (Read After Write)|True dependence|Consumer reads before producer writes|
|WAR (Write After Read)|Anti-dependence|Writer overwrites before prior reader finishes|
|WAW (Write After Write)|Output dependence|Two writers to same register, wrong one commits last|

RAW hazards are true data dependencies — they cannot be eliminated, only tolerated by waiting or forwarding. WAR and WAW hazards are **name dependencies** — artifacts of insufficient register names, not true data relationships. Tomasulo eliminates WAR and WAW through implicit renaming.

---

### Structural Components

<svg viewBox="0 0 580 320" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="10"> <!-- Instruction Queue --> <rect x="10" y="130" width="90" height="50" rx="3" fill="#1e1e2e" stroke="#89b4fa" stroke-width="1.3"/> <text x="55" y="150" text-anchor="middle" fill="#89b4fa">Instruction</text> <text x="55" y="164" text-anchor="middle" fill="#89b4fa">Queue</text> <!-- Arrow IQ to RS --> <line x1="100" y1="155" x2="140" y2="155" stroke="#89b4fa" stroke-width="1.2"/> <polygon points="136,151 141,155 136,159" fill="#89b4fa"/> <!-- Reservation Stations --> <rect x="140" y="60" width="130" height="190" rx="3" fill="#1e1e2e" stroke="#fab387" stroke-width="1.3"/> <text x="205" y="80" text-anchor="middle" fill="#fab387" font-weight="bold">Reservation</text> <text x="205" y="93" text-anchor="middle" fill="#fab387" font-weight="bold">Stations</text> <rect x="150" y="102" width="110" height="28" rx="2" fill="#313244" stroke="#6c7086" stroke-width="0.8"/> <text x="205" y="114" text-anchor="middle" fill="#cdd6f4">RS1: ADD p3←p1+p2</text> <text x="205" y="126" text-anchor="middle" fill="#a6e3a1">ready</text> <rect x="150" y="135" width="110" height="28" rx="2" fill="#313244" stroke="#6c7086" stroke-width="0.8"/> <text x="205" y="147" text-anchor="middle" fill="#cdd6f4">RS2: MUL p6←?+p4</text> <text x="205" y="159" text-anchor="middle" fill="#f38ba8">waiting RS3</text> <rect x="150" y="168" width="110" height="28" rx="2" fill="#313244" stroke="#6c7086" stroke-width="0.8"/> <text x="205" y="180" text-anchor="middle" fill="#cdd6f4">RS3: ADD p5←p1+p2</text> <text x="205" y="192" text-anchor="middle" fill="#a6e3a1">ready</text> <rect x="150" y="201" width="110" height="28" rx="2" fill="#313244" stroke="#6c7086" stroke-width="0.8"/> <text x="205" y="213" text-anchor="middle" fill="#cdd6f4">RS4: empty</text> <text x="205" y="225" text-anchor="middle" fill="#6c7086">—</text> <!-- Arrow RS to FUs --> <line x1="270" y1="120" x2="320" y2="90" stroke="#a6e3a1" stroke-width="1.2"/> <polygon points="315,87 321,91 316,95" fill="#a6e3a1"/> <line x1="270" y1="180" x2="320" y2="210" stroke="#a6e3a1" stroke-width="1.2"/> <polygon points="315,207 321,211 316,215" fill="#a6e3a1"/> <!-- Functional Units --> <rect x="320" y="60" width="90" height="50" rx="3" fill="#1e1e2e" stroke="#a6e3a1" stroke-width="1.3"/> <text x="365" y="82" text-anchor="middle" fill="#a6e3a1">Integer</text> <text x="365" y="96" text-anchor="middle" fill="#a6e3a1">ALU</text> <rect x="320" y="185" width="90" height="50" rx="3" fill="#1e1e2e" stroke="#a6e3a1" stroke-width="1.3"/> <text x="365" y="207" text-anchor="middle" fill="#a6e3a1">FP / MUL</text> <text x="365" y="221" text-anchor="middle" fill="#a6e3a1">Unit</text> <!-- CDB --> <rect x="310" y="275" width="220" height="28" rx="3" fill="#1e1e2e" stroke="#cba6f7" stroke-width="1.4"/> <text x="420" y="294" text-anchor="middle" fill="#cba6f7" font-weight="bold">Common Data Bus (CDB)</text> <!-- FU to CDB --> <line x1="365" y1="110" x2="365" y2="275" stroke="#cba6f7" stroke-width="1.2" stroke-dasharray="4,2"/> <line x1="365" y1="235" x2="365" y2="275" stroke="#cba6f7" stroke-width="1.2"/> <!-- CDB to RS (broadcast back) --> <line x1="310" y1="289" x2="205" y2="289" stroke="#cba6f7" stroke-width="1.2"/> <line x1="205" y1="289" x2="205" y2="250" stroke="#cba6f7" stroke-width="1.2"/> <polygon points="201,254 205,249 209,254" fill="#cba6f7"/> <!-- CDB to Register File --> <rect x="430" y="110" width="110" height="50" rx="3" fill="#1e1e2e" stroke="#f38ba8" stroke-width="1.3"/> <text x="485" y="132" text-anchor="middle" fill="#f38ba8">Register</text> <text x="485" y="146" text-anchor="middle" fill="#f38ba8">File / RAT</text> <line x1="480" y1="275" x2="480" y2="160" stroke="#cba6f7" stroke-width="1.2"/> <polygon points="476,164 480,159 484,164" fill="#cba6f7"/> <!-- Register File to RS --> <line x1="430" y1="135" x2="270" y2="135" stroke="#f38ba8" stroke-width="1.2" stroke-dasharray="3,2"/> </svg>

---

### Reservation Station Fields

Each reservation station entry holds:

|Field|Description|
|---|---|
|`Op`|Operation to perform (ADD, MUL, LOAD, …)|
|`Qj`|Tag of RS producing the first source operand (0 if available)|
|`Qk`|Tag of RS producing the second source operand (0 if available)|
|`Vj`|Value of first source operand (valid when Qj = 0)|
|`Vk`|Value of second source operand (valid when Qk = 0)|
|`A`|Memory address (load/store only; holds immediate, then effective address after calculation)|
|`Busy`|Whether this entry is occupied|

The register file (or RAT) additionally maintains, per architectural register:

|Field|Description|
|---|---|
|`Qi`|Tag of the RS that will produce this register's next value (0 = register holds a valid value)|
|`Value`|Current committed value|

---

### Three Phases

#### Phase 1 — Issue (Dispatch)

An instruction is taken from the head of the instruction queue and issued into a free reservation station.

1. A free RS entry is allocated. If none is free, the instruction stalls (structural hazard on RS).
2. For each source register r:
    - If `Qi[r] = 0`: the register holds a valid value → copy `Value[r]` into `Vj` or `Vk`; set corresponding `Qj` or `Qk` to 0
    - If `Qi[r] ≠ 0`: the register is waiting on RS tag `Qi[r]` → copy that tag into `Qj` or `Qk`
3. Update the RAT: set `Qi[rd]` to the tag of the newly allocated RS entry. This is the implicit register renaming step.

WAR and WAW hazards are eliminated here. Once the RAT entry is overwritten with the new RS tag, the old mapping is discarded — any subsequent instruction reading that register will wait on the new producer, not the old one.

#### Phase 2 — Execute

An RS entry becomes eligible for execution when **both** `Qj = 0` and `Qk = 0` — meaning both source values are available in `Vj` and `Vk`.

When a functional unit is free and an RS entry is ready, the instruction is dispatched to the functional unit. If multiple RS entries are ready for the same functional unit, the selection policy is implementation-defined (often FIFO or oldest-first).

For **load/store instructions**, execution is two-step:

1. Compute effective address: `A = base + offset` (using Vj once available)
2. Access memory

Loads may not bypass earlier stores to the same address — the load/store unit must check the store buffer for address conflicts before issuing the memory read.

#### Phase 3 — Write Result (CDB Broadcast)

When a functional unit completes:

1. The result value and the producing RS tag are placed on the **Common Data Bus**.
2. Every reservation station monitors the CDB simultaneously. Any RS with `Qj` or `Qk` matching the broadcast tag captures the value into `Vj` or `Vk` and clears the tag to 0.
3. The register file updates any register whose `Qi` matches the broadcast tag, writing the value and clearing `Qi` to 0.
4. The RS entry that produced the result is freed.

This broadcast mechanism is what makes Tomasulo's algorithm distributed — no central scoreboard arbitrates which instruction may write; any completing instruction broadcasts to all consumers simultaneously.

---

### Worked Example

Consider the following sequence with an FP multiplier latency of 3 cycles and FP adder latency of 2 cycles:

```
I1: FMUL F6, F2, F4      ; F6 ← F2 × F4
I2: FADD F8, F6, F2      ; F8 ← F6 + F2   (RAW on F6 from I1)
I3: FADD F2, F4, F10     ; F2 ← F4 + F10  (WAR: I2 reads F2, I3 writes F2)
I4: FMUL F6, F10, F8     ; F6 ← F10 × F8  (WAW: I1 writes F6, I4 writes F6)
```

After issue of all four instructions, the RAT state:

|Register|Qi (producing RS)|
|---|---|
|F2|RS_FADD2 (I3)|
|F6|RS_FMUL2 (I4)|
|F8|RS_FADD1 (I2)|

I2 holds `Qj = RS_FMUL1` (waiting for F6 from I1) and `Vk = value of F2 at issue time` — the value of F2 is captured at issue, so I3's subsequent write to F2 does not affect I2. WAR hazard is eliminated.

I4's RS_FMUL2 entry overwrites Qi[F6], so I1's eventual write to the old F6 will not corrupt I4's destination — I4 gets its own physical slot. WAW hazard is eliminated.

---

### Implicit Register Renaming

The renaming in Tomasulo is implicit in the sense that there is no explicit physical register file with a separate name map (as in a modern PRF-based OOO processor). Instead:

- **RS tags serve as physical register names** while values are in-flight
- **Values migrate** — once an operand is produced, it is captured into dependent RS entries and (when no further consumers exist in-flight) written back to the architectural register file

This is sufficient for correctness but creates a limitation: **values may be duplicated** across multiple RS entries that all consumed the same CDB broadcast. There is no single canonical storage location for an in-flight value — it is distributed across RS entries.

Modern processors replace this with an explicit **physical register file (PRF)**: RS entries hold only tags (not values), and all operand reads go to the PRF by tag. This reduces the amount of data moved and avoids value duplication.

---

### Common Data Bus Contention

The CDB is a single broadcast bus. In a single cycle, only one functional unit may write to it. If multiple units complete in the same cycle, all but one must stall for a cycle.

This is a structural hazard on the CDB itself. Solutions in practice:

- **Multiple CDBs** — one per functional unit type (separate integer and FP CDBs). Increases wiring complexity and the number of comparators in each RS entry.
- **Result queues** — completed results are buffered in a queue; the CDB arbitrates among queued results rather than directly from units. Decouples completion from broadcast.

---

### Handling Memory Operations

Memory introduces ordering constraints beyond register data dependences. Two rules must hold:

1. A **load** may not execute before all prior stores whose addresses are unknown have resolved — an earlier store might alias the load address.
2. A **store** may not write to memory until it is the oldest instruction and known to be non-speculative (i.e., past all preceding branches).

The **store buffer** (also called store queue) holds store addresses and values that have been computed but not yet committed to memory. A load checks the store buffer for address matches — if a match exists, the load takes the value from the store buffer (store-to-load forwarding) rather than from the cache hierarchy.

In the original IBM 360/91 implementation, Tomasulo did not handle speculative execution — there was no branch prediction and no mechanism to roll back state. Modern implementations add a **reorder buffer (ROB)** to handle this.

---

### Reorder Buffer Extension

The original algorithm has no mechanism to handle exceptions or mispredictions — results written to the register file are immediately visible and cannot be undone.

The ROB adds **in-order commitment** to out-of-order execution:

- Each issued instruction allocates a ROB entry
- Instructions execute out of order and write results to the PRF (or ROB entry), not directly to the ARF
- Instructions commit **in program order** from the head of the ROB
- On misprediction or exception, the ROB tail is flushed, physical registers are freed, and the RAT is restored from the retirement RAT

With the ROB, the three phases become: Issue → Execute → Write Result → Commit. The algorithm is sometimes called **Tomasulo with ROB** or described as the foundation of the modern OOO pipeline.

---

### Hazard Resolution Summary

|Hazard|Tomasulo Mechanism|
|---|---|
|RAW|RS entry waits on Qj/Qk tags; CDB broadcast delivers value when ready|
|WAR|Source value captured into RS at issue time; subsequent writes to same register do not affect captured value|
|WAW|RAT overwritten with newest producer's tag; older producer's result goes to RS entries that subscribed, not to ARF if superseded|
|Structural (RS full)|Issue stalls until an RS entry is freed|
|Structural (CDB)|Completing units queue; arbitration determines broadcast order|

---

### Limitations

- **RS tag comparators** — every RS entry must compare its Qj and Qk against every CDB broadcast tag every cycle. For W reservation stations and B CDBs, this requires W × B comparators, all operating in parallel each cycle. This is the primary cycle-time cost of Tomasulo.
- **Value duplication** — in the original scheme, a value broadcast on the CDB is copied into every waiting RS entry simultaneously. A value produced early may live in multiple RS entries simultaneously, increasing register file area.
- **No speculative execution** in the original form — the ROB is a necessary addition for branch prediction and precise exceptions.
- **Memory ordering** — the original design's handling of memory hazards is conservative; aggressive load speculation requires additional microarchitectural support (load queue, memory dependence prediction).

---

**Key Points**

- Tomasulo eliminates WAR and WAW hazards by capturing source values (or tags) at issue time — subsequent writes to the same architectural register name do not affect already-issued instructions
- The CDB broadcast is the mechanism that makes the algorithm distributed: no central controller arbitrates dataflow; every RS simultaneously monitors every broadcast
- RS tags function as implicit physical register names while values are in-flight — modern processors make this explicit with a separate physical register file
- The ROB is not part of the original algorithm but is a necessary extension for speculative execution and precise exceptions
- The comparator array (one per RS entry per CDB) is the primary cycle-time and area cost that limits RS count in real implementations

---

