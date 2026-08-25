## Hazard Detection and Resolution


A hazard is any condition in a pipelined processor that prevents the next instruction from executing in its expected cycle. Hazards are consequences of instruction-level dependencies colliding with the rigid timing of pipeline stages — the pipeline assumes each instruction is independent; hazards arise when that assumption fails. Detection and resolution mechanisms exist to preserve correct execution semantics while minimizing performance loss.

---

### Pipeline Timing Baseline

For a canonical 5-stage pipeline (IF → ID → EX → MEM → WB), each stage takes one cycle and every instruction occupies each stage exactly once.

<svg viewBox="0 0 680 160" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <defs> <marker id="a" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#78909c"/> </marker> </defs> <!-- Stage boxes --> <rect x="20" y="40" width="100" height="36" rx="4" fill="#1a237e" stroke="#5c6bc0" stroke-width="1.2"/> <text x="70" y="63" text-anchor="middle" fill="#9fa8da">IF</text> <line x1="120" y1="58" x2="138" y2="58" stroke="#78909c" stroke-width="1.2" marker-end="url(#a)"/> <rect x="140" y="40" width="100" height="36" rx="4" fill="#1b5e20" stroke="#66bb6a" stroke-width="1.2"/> <text x="190" y="63" text-anchor="middle" fill="#a5d6a7">ID</text> <line x1="240" y1="58" x2="258" y2="58" stroke="#78909c" stroke-width="1.2" marker-end="url(#a)"/> <rect x="260" y="40" width="100" height="36" rx="4" fill="#4a148c" stroke="#ab47bc" stroke-width="1.2"/> <text x="310" y="63" text-anchor="middle" fill="#ce93d8">EX</text> <line x1="360" y1="58" x2="378" y2="58" stroke="#78909c" stroke-width="1.2" marker-end="url(#a)"/> <rect x="380" y="40" width="100" height="36" rx="4" fill="#b71c1c" stroke="#ef5350" stroke-width="1.2"/> <text x="430" y="63" text-anchor="middle" fill="#ffcdd2">MEM</text> <line x1="480" y1="58" x2="498" y2="58" stroke="#78909c" stroke-width="1.2" marker-end="url(#a)"/> <rect x="500" y="40" width="100" height="36" rx="4" fill="#e65100" stroke="#ffa726" stroke-width="1.2"/> <text x="550" y="63" text-anchor="middle" fill="#ffe0b2">WB</text> <!-- Labels -->

<text x="70" y="100" text-anchor="middle" fill="#888" font-size="11">Fetch</text> <text x="190" y="100" text-anchor="middle" fill="#888" font-size="11">Decode / Reg Read</text> <text x="310" y="100" text-anchor="middle" fill="#888" font-size="11">Execute / ALU</text> <text x="430" y="100" text-anchor="middle" fill="#888" font-size="11">Memory Access</text> <text x="550" y="100" text-anchor="middle" fill="#888" font-size="11">Reg Write</text>

<text x="340" y="140" text-anchor="middle" fill="#555" font-size="11">Ideal: one instruction completes per cycle after fill</text> </svg>

A hazard disrupts this ideal. Resolution mechanisms either **stall** the pipeline (insert bubbles), **forward** data through bypass paths, or **reorder** instructions to avoid the conflict entirely.

---

### Structural Hazards

#### Definition

A structural hazard occurs when two instructions simultaneously require the same hardware resource and the resource is not replicated or time-shared.

#### Common Sources

|Resource|Conflict|
|---|---|
|Single unified memory|IF (instruction fetch) and MEM (data access) compete simultaneously|
|Single-ported register file|ID reads and WB writes to the same register in the same cycle|
|Non-pipelined functional unit|A multi-cycle divider occupied by one instruction blocks another|

#### Detection

Structural hazard detection is a static property of the hardware design. The control unit tracks which resources are in use each cycle via a **resource reservation table** or equivalent scheduling logic. If two instructions are scheduled to use the same resource in the same cycle, a hazard is flagged.

#### Resolution

**Stalling** is the standard resolution. The pipeline inserts a **bubble** (NOP) — a cycle in which the conflicting instruction is held in its current stage while the resource becomes free.

The canonical solution to the memory conflict is the **Harvard architecture**: separate instruction and data memories (or separate L1 caches), eliminating the structural hazard entirely. Most modern processors use split L1 I-cache and D-cache for this reason.

For register file write-read conflicts, the register file is designed with **write-then-read** ordering within the same cycle (the write occurs in the first half of the cycle, the read in the second half), or the WB stage is given priority.

---

### Data Hazards

#### Definition

A data hazard occurs when an instruction depends on the result of a prior instruction that has not yet completed its write-back.

#### Classification

Three sub-types exist, named from the perspective of two instructions $I_1$ (earlier) and $I_2$ (later):

|Type|Full Name|Description|
|---|---|---|
|RAW|Read After Write|$I_2$ reads a register before $I_1$ writes it — the true dependency|
|WAR|Write After Read|$I_2$ writes a register before $I_1$ reads it — antidependency|
|WAW|Write After Write|$I_2$ writes a register before $I_1$ writes it — output dependency|

In a simple in-order 5-stage pipeline, **RAW is the only hazard that occurs naturally**. WAR and WAW cannot arise because instructions proceed in order — $I_1$ always reads before $I_2$ writes, and $I_1$ always writes before $I_2$ writes. WAR and WAW become relevant in out-of-order processors.

#### RAW Detection

The hazard detection unit compares the **destination register of instructions in EX and MEM** against the **source registers of the instruction in ID**.

```
RAW hazard if:
  (ID.rs1 == EX.rd  OR  ID.rs2 == EX.rd)   AND  EX.RegWrite
  (ID.rs1 == MEM.rd OR  ID.rs2 == MEM.rd)  AND  MEM.RegWrite
```

This check runs every cycle. When a match is detected, the instruction in ID must wait.

#### RAW Without Forwarding — Stall Cycles Required

```
I1: add  x1, x2, x3    ; WB writes x1 at end of cycle 5
I2: sub  x4, x1, x5    ; ID reads x1 at cycle 3 — value not yet written
```

|Cycle|1|2|3|4|5|6|7|
|---|---|---|---|---|---|---|---|
|I1|IF|ID|EX|MEM|**WB**|||
|I2||IF|**ID**|stall|stall|ID|EX|

Without forwarding, two stall cycles are required before ID can safely read the register.

---

### Data Forwarding (Bypassing)

Forwarding eliminates or reduces stalls by routing a computed result directly from the pipeline register where it first appears to the stage that needs it, without waiting for WB.

#### Forwarding Paths

<svg viewBox="0 0 680 260" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <defs> <marker id="f1" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#66bb6a"/> </marker> <marker id="f2" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#ffa726"/> </marker> <marker id="fa" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#78909c"/> </marker> </defs> <!-- Pipeline stages --> <rect x="20" y="40" width="90" height="34" rx="3" fill="#1a237e" stroke="#5c6bc0" stroke-width="1.2"/> <text x="65" y="62" text-anchor="middle" fill="#9fa8da">IF</text> <rect x="130" y="40" width="90" height="34" rx="3" fill="#1b5e20" stroke="#66bb6a" stroke-width="1.2"/> <text x="175" y="62" text-anchor="middle" fill="#a5d6a7">ID</text> <rect x="240" y="40" width="90" height="34" rx="3" fill="#4a148c" stroke="#ab47bc" stroke-width="1.2"/> <text x="285" y="62" text-anchor="middle" fill="#ce93d8">EX</text> <rect x="350" y="40" width="90" height="34" rx="3" fill="#b71c1c" stroke="#ef5350" stroke-width="1.2"/> <text x="395" y="62" text-anchor="middle" fill="#ffcdd2">MEM</text> <rect x="460" y="40" width="90" height="34" rx="3" fill="#e65100" stroke="#ffa726" stroke-width="1.2"/> <text x="505" y="62" text-anchor="middle" fill="#ffe0b2">WB</text> <!-- Normal flow arrows --> <line x1="110" y1="57" x2="128" y2="57" stroke="#78909c" stroke-width="1.2" marker-end="url(#fa)"/> <line x1="220" y1="57" x2="238" y2="57" stroke="#78909c" stroke-width="1.2" marker-end="url(#fa)"/> <line x1="330" y1="57" x2="348" y2="57" stroke="#78909c" stroke-width="1.2" marker-end="url(#fa)"/> <line x1="440" y1="57" x2="458" y2="57" stroke="#78909c" stroke-width="1.2" marker-end="url(#fa)"/> <!-- EX→EX forward path (EX/MEM register → ALU input) --> <path d="M 395 74 L 395 140 L 260 140 L 260 74" fill="none" stroke="#66bb6a" stroke-width="1.5" stroke-dasharray="5,3" marker-end="url(#f1)"/> <text x="327" y="158" text-anchor="middle" fill="#66bb6a" font-size="11">EX→EX forward</text> <text x="327" y="170" text-anchor="middle" fill="#66bb6a" font-size="11">(EX/MEM → ALU)</text> <!-- MEM→EX forward path (MEM/WB register → ALU input) --> <path d="M 505 74 L 505 195 L 260 195 L 260 74" fill="none" stroke="#ffa726" stroke-width="1.5" stroke-dasharray="5,3" marker-end="url(#f2)"/> <text x="382" y="213" text-anchor="middle" fill="#ffa726" font-size="11">MEM→EX forward</text> <text x="382" y="225" text-anchor="middle" fill="#ffa726" font-size="11">(MEM/WB → ALU)</text> <!-- ALU label -->

<text x="285" y="30" text-anchor="middle" fill="#ce93d8" font-size="11">ALU inputs</text> <line x1="285" y1="33" x2="285" y2="40" stroke="#ce93d8" stroke-width="1"/> </svg>

**EX-to-EX forwarding** (also called EX/MEM forwarding): the ALU result is forwarded from the EX/MEM pipeline register to the ALU input of the next instruction. Covers a 1-instruction gap.

**MEM-to-EX forwarding** (MEM/WB forwarding): the value is forwarded from the MEM/WB register to the ALU input. Covers a 2-instruction gap.

#### Forwarding Unit Logic

The forwarding unit selects the correct ALU input operand each cycle:

```
// Forward A (for rs1 of instruction in EX)
if (EX/MEM.RegWrite AND EX/MEM.rd ≠ 0
    AND EX/MEM.rd == ID/EX.rs1)
    ForwardA = EX/MEM_result        // EX→EX

else if (MEM/WB.RegWrite AND MEM/WB.rd ≠ 0
    AND MEM/WB.rd == ID/EX.rs1)
    ForwardA = MEM/WB_result        // MEM→EX

else
    ForwardA = ID/EX_RegisterA      // no forward, use register file
```

The same logic applies symmetrically to `rs2` (ForwardB). The condition `rd ≠ 0` guards against forwarding from writes to the zero register (x0 on RISC-V), which is hardwired to zero.

**EX/MEM forwarding takes priority over MEM/WB forwarding** when both match — this handles WAW-like cases where both an older and a more recent instruction write the same register.

#### The Load-Use Hazard — One Unavoidable Stall

Forwarding cannot fully resolve a RAW hazard when the producing instruction is a **load**. A load produces its result after the MEM stage, but the consuming instruction needs it at the start of EX — one cycle earlier than forwarding can deliver.

```
I1: lw   x1, 0(x2)     ; result available after MEM (cycle 4)
I2: add  x3, x1, x4    ; needs x1 at start of EX (cycle 4) — impossible
```

|Cycle|1|2|3|4|5|6|7|8|
|---|---|---|---|---|---|---|---|---|
|lw|IF|ID|EX|**MEM**|WB||||
|add||IF|ID|**stall**|EX|MEM|WB||

The hazard detection unit identifies this condition specifically:

```
load-use hazard if:
  ID/EX.MemRead == 1
  AND (ID/EX.rd == IF/ID.rs1 OR ID/EX.rd == IF/ID.rs2)
```

**Resolution:** stall for exactly one cycle, then forward from MEM/WB to EX. The stall is implemented by:

1. Holding the PC and IF/ID register at their current values (preventing new fetch and decode).
2. Inserting a bubble into the ID/EX register (zeroing control signals so the stalled instruction has no effect in EX).

The compiler can resolve this in software by **load-use scheduling**: placing an independent instruction between the load and its consumer, filling the slot productively rather than with a hardware bubble.

---

### Control Hazards

#### Definition

A control hazard (branch hazard) occurs when the pipeline fetches instructions after a branch before it knows whether the branch is taken and what the branch target is.

In a 5-stage pipeline, the branch outcome is determined at the end of the **EX** stage (or ID if early branch resolution hardware is present). By that point, 1–2 instructions have already been fetched.

#### Detection

Control hazards are detected structurally whenever a branch instruction enters the pipeline. Every branch is a potential hazard — detection is unconditional on the instruction type.

#### Resolution Strategies

##### Flush (Branch Not Taken Assumption)

The simplest policy: assume the branch is not taken, continue fetching sequentially. If the branch is taken, **flush** the incorrectly fetched instructions by replacing them with bubbles.

```
Penalty = number of stages between IF and branch resolution
```

For resolution at EX: 2-cycle penalty on a taken branch. For resolution at ID (early branch): 1-cycle penalty.

##### Stall (Freeze Until Resolved)

Hold the PC and insert bubbles until the branch outcome is known. Incurs the full branch penalty on every branch, unconditionally. Not used in high-performance designs.

##### Delayed Branching

Used in MIPS and early SPARC. The instruction in the **branch delay slot** (the instruction immediately following the branch in memory) is always executed regardless of the branch outcome. The assembler is responsible for placing a useful instruction in the delay slot.

```mips
beq  $t0, $t1, target    ; branch
addi $t2, $t2, 1         ; delay slot — always executes
; execution resumes here (not taken) or at target (taken)
```

If no useful instruction can be placed in the delay slot, a NOP is inserted. This is a hardware–software co-design solution that shifts branch penalty management to the ISA and compiler. Modern ISAs (RISC-V, ARM, x86) do not use delayed branches.

##### Branch Prediction

The dominant strategy in all modern processors. The processor predicts whether the branch will be taken and from where, fetches speculatively, and flushes only on misprediction.

|Strategy|Mechanism|Misprediction penalty|
|---|---|---|
|Static: predict not taken|Always fetch sequential|Full penalty on taken|
|Static: predict taken|Always fetch target|Full penalty on not taken|
|Backward taken / forward not taken (BTFN)|Loops (backward) predicted taken|Reduced average penalty|
|Dynamic: BHT (1-bit)|Per-branch taken/not-taken bit|Mis-predicts on loop exit|
|Dynamic: BHT (2-bit saturating counter)|4-state FSM; tolerates one anomaly|Lower average misprediction rate|
|Dynamic: BTB + BHT|Branch target buffer predicts target; BHT predicts direction|Full speculative fetch|
|Tournament / hybrid|Selects between local and global history predictors|Near-optimal for mixed workloads|

On a misprediction, the pipeline must:

1. Flush all instructions fetched along the wrong path (set their control signals to NOP).
2. Restore the PC to the correct target.
3. Resume fetching from the correct address.

The cost of a misprediction is the **branch penalty** — the number of pipeline stages between fetch and resolution. In deep pipelines (Intel Pentium 4: ~20 stages), this penalty can reach 15–20 cycles, making prediction accuracy critical.

---

### Hazard Interaction and Priority

When multiple hazards occur simultaneously, resolution must be prioritized. A consistent ordering is required to avoid corrupting pipeline state:

1. **Structural hazards** are resolved first by resource arbitration.
2. **Load-use hazards** are detected before other RAW hazards because they require a stall that forwarding cannot eliminate.
3. **Control hazards** interact with data hazards: if a branch instruction itself has a data hazard (its condition register is produced by a preceding load), both a load-use stall and a branch flush may be required in the same cycle window.

The hazard detection unit and forwarding unit operate in parallel each cycle; their outputs are combined by the pipeline control logic to determine the final stall, flush, and forward signals for that cycle.

---

### Summary of Detection and Resolution

<svg viewBox="0 0 660 310" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <defs> <marker id="ar" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#78909c"/> </marker> </defs> <!-- Header --> <rect x="10" y="10" width="640" height="28" rx="3" fill="#263238" stroke="#455a64" stroke-width="1"/> <text x="100" y="29" fill="#90a4ae" font-size="12">Hazard Type</text> <text x="270" y="29" fill="#90a4ae" font-size="12">Detection</text> <text x="460" y="29" fill="#90a4ae" font-size="12">Resolution</text> <!-- Row 1: Structural --> <rect x="10" y="40" width="640" height="44" rx="2" fill="#1a237e" stroke="#3949ab" stroke-width="0.8"/> <text x="100" y="58" text-anchor="middle" fill="#9fa8da">Structural</text> <text x="270" y="55" fill="#c5cae9" font-size="11">Resource reservation table;</text> <text x="270" y="69" fill="#c5cae9" font-size="11">static scheduling logic</text> <text x="460" y="55" fill="#c5cae9" font-size="11">Stall; replicate resource;</text> <text x="460" y="69" fill="#c5cae9" font-size="11">split caches (Harvard)</text> <!-- Row 2: RAW (general) --> <rect x="10" y="86" width="640" height="44" rx="2" fill="#1b5e20" stroke="#388e3c" stroke-width="0.8"/> <text x="100" y="104" text-anchor="middle" fill="#a5d6a7">RAW (ALU→ALU)</text> <text x="270" y="101" fill="#c8e6c9" font-size="11">Compare EX.rd / MEM.rd</text> <text x="270" y="115" fill="#c8e6c9" font-size="11">against ID.rs1 / ID.rs2</text> <text x="460" y="101" fill="#c8e6c9" font-size="11">EX→EX or MEM→EX</text> <text x="460" y="115" fill="#c8e6c9" font-size="11">forwarding; no stall needed</text> <!-- Row 3: Load-use --> <rect x="10" y="132" width="640" height="44" rx="2" fill="#4a148c" stroke="#7b1fa2" stroke-width="0.8"/> <text x="100" y="150" text-anchor="middle" fill="#ce93d8">RAW (load-use)</text> <text x="270" y="147" fill="#e1bee7" font-size="11">ID/EX.MemRead AND</text> <text x="270" y="161" fill="#e1bee7" font-size="11">rd matches IF/ID.rs1 or rs2</text> <text x="460" y="147" fill="#e1bee7" font-size="11">1-cycle stall + MEM→EX</text> <text x="460" y="161" fill="#e1bee7" font-size="11">forward; or compiler scheduling</text> <!-- Row 4: WAR / WAW --> <rect x="10" y="178" width="640" height="44" rx="2" fill="#263238" stroke="#546e7a" stroke-width="0.8"/> <text x="100" y="196" text-anchor="middle" fill="#b0bec5">WAR / WAW</text> <text x="270" y="193" fill="#cfd8dc" font-size="11">Not applicable in simple</text> <text x="270" y="207" fill="#cfd8dc" font-size="11">in-order pipeline</text> <text x="460" y="193" fill="#cfd8dc" font-size="11">Register renaming in OoO;</text> <text x="460" y="207" fill="#cfd8dc" font-size="11">in-order: structural prevention</text> <!-- Row 5: Control --> <rect x="10" y="224" width="640" height="44" rx="2" fill="#b71c1c" stroke="#c62828" stroke-width="0.8"/> <text x="100" y="242" text-anchor="middle" fill="#ffcdd2">Control (branch)</text> <text x="270" y="239" fill="#ffcdd2" font-size="11">Instruction decode identifies</text> <text x="270" y="253" fill="#ffcdd2" font-size="11">branch opcode</text> <text x="460" y="239" fill="#ffcdd2" font-size="11">Predict + flush on mispredict;</text> <text x="460" y="253" fill="#ffcdd2" font-size="11">stall; delayed branch</text> <!-- Column dividers --> <line x1="185" y1="40" x2="185" y2="268" stroke="#37474f" stroke-width="0.8"/> <line x1="400" y1="40" x2="400" y2="268" stroke="#37474f" stroke-width="0.8"/> </svg>

---

**Conclusion**

Hazard detection and resolution is the mechanism by which a pipelined processor preserves the illusion of sequential execution in the presence of structural constraints, data dependencies, and control flow. Detection logic compares in-flight instruction metadata — destination registers, memory-read signals, and branch opcodes — against the requirements of younger instructions each cycle. Resolution trades off hardware complexity against performance: forwarding eliminates most RAW stalls with added datapath multiplexers; prediction eliminates most control penalties at the cost of flush logic; stalling is always correct but always costly. The load-use hazard represents the irreducible case where neither forwarding nor prediction alone suffices, requiring at minimum one pipeline bubble.

**Next Steps**

- Data forwarding / bypassing — full forwarding network design, interaction with multi-cycle functional units, and forwarding in the presence of exceptions.
- Branch prediction — detailed treatment of 2-bit saturating counters, branch target buffers, global history registers, and tournament predictors.
- Pipeline performance metrics — CPI analysis incorporating hazard penalties, Amdahl's Law applied to branch and memory stall contributions.

---

