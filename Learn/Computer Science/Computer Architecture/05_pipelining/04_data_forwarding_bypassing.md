## Data Forwarding / Bypassing


Data forwarding (also called bypassing) is a hardware technique that resolves **RAW (Read After Write) data hazards** in a pipeline by routing a computed result directly from the stage that produced it to the stage that needs it, without waiting for the value to be written back to the register file and re-read in a later cycle.

---

### The Problem: RAW Hazards Without Forwarding

In a classic 5-stage pipeline (IF → ID → EX → MEM → WB), an instruction writes its result only at the WB stage. A dependent instruction that reads the same register at the ID stage will read a **stale value** unless the pipeline stalls.

```
Without forwarding:

Cycle:        1     2     3     4     5     6     7
ADD R1,R2,R3  IF    ID    EX    MEM   WB
SUB R4,R1,R5        IF    ID    EX↯   ...        ← reads R1 at ID (cycle 3), but WB is cycle 5
```

R1 is not written until cycle 5. SUB reads R1 at cycle 3 (during ID) — two cycles too early. Without intervention, it reads the old value of R1.

The naive fix is to **stall** (insert bubbles) until the value is available:

```
With stalls only:

Cycle:        1     2     3     4     5     6     7     8     9
ADD R1,R2,R3  IF    ID    EX    MEM   WB
SUB R4,R1,R5        IF    ID    --    --    EX    MEM   WB
                               ↑     ↑
                           bubbles (2 stall cycles)
```

This is correct but wastes two cycles per dependent instruction — unacceptable for a high-throughput pipeline.

---

### The Solution: Forwarding Paths

Instead of waiting for WB, the pipeline forwards the result from the **pipeline register** that holds it to the **input of the stage** that needs it. The result exists in a pipeline register well before WB commits it to the register file.

<svg viewBox="0 0 660 340" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <defs> <marker id="fwd-arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#f59e0b"/> </marker> <marker id="norm-arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#94a3b8"/> </marker> <marker id="stall-arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#f87171"/> </marker> </defs> <!-- Stage boxes --> <rect x="20" y="60" width="90" height="40" rx="4" fill="#1e293b" stroke="#475569"/> <text x="65" y="85" text-anchor="middle" fill="#e2e8f0">IF</text> <rect x="140" y="60" width="90" height="40" rx="4" fill="#1e293b" stroke="#475569"/> <text x="185" y="85" text-anchor="middle" fill="#e2e8f0">ID / RF</text> <rect x="260" y="60" width="90" height="40" rx="4" fill="#0f2027" stroke="#3b82f6"/> <text x="305" y="85" text-anchor="middle" fill="#93c5fd">EX / ALU</text> <rect x="380" y="60" width="90" height="40" rx="4" fill="#1e293b" stroke="#475569"/> <text x="425" y="85" text-anchor="middle" fill="#e2e8f0">MEM</text> <rect x="500" y="60" width="90" height="40" rx="4" fill="#1e293b" stroke="#475569"/> <text x="545" y="85" text-anchor="middle" fill="#e2e8f0">WB</text> <!-- Normal flow arrows --> <line x1="110" y1="80" x2="140" y2="80" stroke="#94a3b8" stroke-width="1.5" marker-end="url(#norm-arr)"/> <line x1="230" y1="80" x2="260" y2="80" stroke="#94a3b8" stroke-width="1.5" marker-end="url(#norm-arr)"/> <line x1="350" y1="80" x2="380" y2="80" stroke="#94a3b8" stroke-width="1.5" marker-end="url(#norm-arr)"/> <line x1="470" y1="80" x2="500" y2="80" stroke="#94a3b8" stroke-width="1.5" marker-end="url(#norm-arr)"/> <!-- Pipeline registers labels -->

<text x="127" y="55" text-anchor="middle" fill="#64748b" font-size="10">IF/ID</text> <text x="247" y="55" text-anchor="middle" fill="#64748b" font-size="10">ID/EX</text> <text x="367" y="55" text-anchor="middle" fill="#64748b" font-size="10">EX/MEM</text> <text x="487" y="55" text-anchor="middle" fill="#64748b" font-size="10">MEM/WB</text>

<!-- EX/MEM forward path --> <path d="M 425 100 L 425 160 L 305 160 L 305 100" stroke="#f59e0b" stroke-width="2" fill="none" marker-end="url(#fwd-arr)" stroke-dasharray="none"/> <text x="365" y="178" text-anchor="middle" fill="#f59e0b" font-size="11">EX→EX forward</text> <text x="365" y="190" text-anchor="middle" fill="#64748b" font-size="10">(EX/MEM → ALU input)</text> <!-- MEM/WB forward path --> <path d="M 545 100 L 545 220 L 305 220 L 305 165" stroke="#34d399" stroke-width="2" fill="none" marker-end="url(#fwd-arr)"/> <text x="430" y="238" text-anchor="middle" fill="#34d399" font-size="11">MEM→EX forward</text> <text x="430" y="250" text-anchor="middle" fill="#64748b" font-size="10">(MEM/WB → ALU input)</text> <!-- WB → ID path (register file forwarding) --> <path d="M 545 100 L 545 290 L 185 290 L 185 100" stroke="#a78bfa" stroke-width="1.5" fill="none" marker-end="url(#fwd-arr)" stroke-dasharray="5,3"/> <text x="365" y="308" text-anchor="middle" fill="#a78bfa" font-size="11">WB→ID (register file write-then-read)</text> <!-- ALU mux indicator --> <rect x="290" y="95" width="30" height="14" rx="3" fill="#1e3a5f" stroke="#3b82f6"/> <text x="305" y="107" text-anchor="middle" fill="#93c5fd" font-size="9">MUX</text> <!-- Legend --> <line x1="30" y1="315" x2="60" y2="315" stroke="#f59e0b" stroke-width="2"/> <text x="65" y="319" fill="#f59e0b" font-size="11">EX/MEM forward (1-cycle distance)</text> <line x1="30" y1="330" x2="60" y2="330" stroke="#34d399" stroke-width="2"/> <text x="65" y="334" fill="#34d399" font-size="11">MEM/WB forward (2-cycle distance)</text> <line x1="330" y1="315" x2="360" y2="315" stroke="#a78bfa" stroke-width="1.5" stroke-dasharray="5,3"/> <text x="365" y="319" fill="#a78bfa" font-size="11">WB→ID (register file)</text> </svg>

---

### Forwarding Sources and Destinations

There are two primary forwarding paths in a 5-stage pipeline:

#### EX/MEM → EX (1-cycle distance)

The instruction one cycle ahead has just completed EX. Its result sits in the EX/MEM pipeline register. It can be forwarded directly to the ALU input of the current instruction's EX stage.

```
Cycle:        1     2     3     4     5
ADD R1,R2,R3  IF    ID    EX    MEM   WB
                          ↓  (EX/MEM.rd = R1, forward to next EX)
SUB R4,R1,R5        IF    ID    EX    MEM   WB
                                ↑ receives forwarded R1
```

No stall required.

#### MEM/WB → EX (2-cycle distance)

The instruction two cycles ahead has completed MEM. Its result sits in the MEM/WB pipeline register. It is forwarded to the ALU input of the current instruction.

```
Cycle:        1     2     3     4     5     6
ADD R1,R2,R3  IF    ID    EX    MEM   WB
                          ↓↓ (MEM/WB.rd = R1 at cycle 5, forward back to EX at cycle 4)
NOP                 IF    ID    EX    MEM   WB
SUB R4,R1,R5              IF    ID    EX    MEM   WB
                                      ↑ receives forwarded R1 from MEM/WB
```

**Key Points**

- By cycle 5 (WB of ADD), the MEM/WB register holds R1's value. SUB is in its EX stage at cycle 5 — it can receive the forwarded value just in time.
- Instructions 3+ cycles ahead have already written back; the register file holds the correct value and a normal read suffices.

---

### Forwarding Unit Logic

The forwarding unit is a combinational block that examines pipeline register fields and drives MUX select signals at the ALU inputs.

```
ForwardA (controls ALU input A — sourced from ID/EX.rs1):

  if (EX/MEM.RegWrite AND EX/MEM.rd ≠ 0 AND EX/MEM.rd = ID/EX.rs1)
      ForwardA = EX_MEM   // use EX/MEM pipeline register value

  else if (MEM/WB.RegWrite AND MEM/WB.rd ≠ 0 AND MEM/WB.rd = ID/EX.rs1)
      ForwardA = MEM_WB   // use MEM/WB pipeline register value

  else
      ForwardA = REGISTER // use register file output (no hazard)

ForwardB (controls ALU input B — sourced from ID/EX.rs2): symmetric
```

The `rd ≠ 0` check is necessary for RISC architectures (MIPS, RISC-V) where register 0 is hardwired to zero — writing to it is a no-op and must not trigger forwarding.

**The EX/MEM path takes priority over MEM/WB** because it carries the most recent write to a given register. If both EX/MEM and MEM/WB contain a write to the same destination (two consecutive writes to the same register), the EX/MEM value is the one that will ultimately persist.

---

### The Load-Use Hazard: The One Case Forwarding Cannot Eliminate

Forwarding resolves all EX-stage RAW hazards _except_ one: a **load followed immediately by a use**.

```
LW  R1, 0(R2)    ; R1 available after MEM (end of cycle 4)
ADD R3, R1, R4   ; needs R1 at start of EX (cycle 4) ← impossible
```

<svg viewBox="0 0 660 260" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <defs> <marker id="lu-arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#f87171"/> </marker> <marker id="lu-fwd" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#34d399"/> </marker> </defs> <!-- Cycle headers -->

<text x="160" y="20" text-anchor="middle" fill="#64748b">C1</text> <text x="220" y="20" text-anchor="middle" fill="#64748b">C2</text> <text x="280" y="20" text-anchor="middle" fill="#64748b">C3</text> <text x="340" y="20" text-anchor="middle" fill="#64748b">C4</text> <text x="400" y="20" text-anchor="middle" fill="#64748b">C5</text> <text x="460" y="20" text-anchor="middle" fill="#64748b">C6</text> <text x="520" y="20" text-anchor="middle" fill="#64748b">C7</text>

<!-- LW row -->

<text x="110" y="55" text-anchor="end" fill="#e2e8f0">LW R1,0(R2)</text> <rect x="130" y="38" width="55" height="24" rx="3" fill="#1e293b" stroke="#475569"/> <text x="160" y="55" text-anchor="middle" fill="#94a3b8">IF</text> <rect x="190" y="38" width="55" height="24" rx="3" fill="#1e293b" stroke="#475569"/> <text x="220" y="55" text-anchor="middle" fill="#94a3b8">ID</text> <rect x="250" y="38" width="55" height="24" rx="3" fill="#1e293b" stroke="#475569"/> <text x="280" y="55" text-anchor="middle" fill="#94a3b8">EX</text> <rect x="310" y="38" width="55" height="24" rx="3" fill="#0f2027" stroke="#3b82f6"/> <text x="340" y="55" text-anchor="middle" fill="#93c5fd">MEM</text> <rect x="370" y="38" width="55" height="24" rx="3" fill="#1e293b" stroke="#475569"/> <text x="400" y="55" text-anchor="middle" fill="#94a3b8">WB</text>

<!-- R1 produced here -->

<text x="340" y="78" text-anchor="middle" fill="#3b82f6" font-size="10">R1 ready</text> <line x1="340" y1="62" x2="340" y2="82" stroke="#3b82f6" stroke-width="1" stroke-dasharray="3,2"/>

<!-- ADD row WITHOUT stall - show problem -->

<text x="110" y="115" text-anchor="end" fill="#f87171">ADD (no stall)</text> <rect x="190" y="98" width="55" height="24" rx="3" fill="#1e293b" stroke="#475569"/> <text x="220" y="115" text-anchor="middle" fill="#94a3b8">IF</text> <rect x="250" y="98" width="55" height="24" rx="3" fill="#1e293b" stroke="#475569"/> <text x="280" y="115" text-anchor="middle" fill="#94a3b8">ID</text> <rect x="310" y="98" width="55" height="24" rx="3" fill="#7f1d1d" stroke="#f87171"/> <text x="340" y="115" text-anchor="middle" fill="#f87171">EX↯</text>

<!-- Conflict arrow --> <line x1="340" y1="82" x2="340" y2="98" stroke="#f87171" stroke-width="2" marker-end="url(#lu-arr)"/> <text x="355" y="95" fill="#f87171" font-size="10">too early!</text> <!-- Divider --> <line x1="20" y1="140" x2="640" y2="140" stroke="#334155" stroke-width="1" stroke-dasharray="4,2"/> <text x="330" y="155" text-anchor="middle" fill="#64748b" font-size="11">with stall + forwarding:</text> <!-- LW row again -->

<text x="110" y="195" text-anchor="end" fill="#e2e8f0">LW R1,0(R2)</text> <rect x="130" y="178" width="55" height="24" rx="3" fill="#1e293b" stroke="#475569"/> <text x="160" y="195" text-anchor="middle" fill="#94a3b8">IF</text> <rect x="190" y="178" width="55" height="24" rx="3" fill="#1e293b" stroke="#475569"/> <text x="220" y="195" text-anchor="middle" fill="#94a3b8">ID</text> <rect x="250" y="178" width="55" height="24" rx="3" fill="#1e293b" stroke="#475569"/> <text x="280" y="195" text-anchor="middle" fill="#94a3b8">EX</text> <rect x="310" y="178" width="55" height="24" rx="3" fill="#0f2027" stroke="#3b82f6"/> <text x="340" y="195" text-anchor="middle" fill="#93c5fd">MEM</text> <rect x="370" y="178" width="55" height="24" rx="3" fill="#1e293b" stroke="#475569"/> <text x="400" y="195" text-anchor="middle" fill="#94a3b8">WB</text>

<!-- Bubble --> <rect x="370" y="178" width="55" height="24" rx="3" fill="#1a1a2e" stroke="#334155"/> <text x="395" y="195" text-anchor="middle" fill="#475569">bubble</text> <!-- ADD row with stall -->

<text x="110" y="235" text-anchor="end" fill="#86efac">ADD R3,R1,R4</text> <rect x="190" y="218" width="55" height="24" rx="3" fill="#1e293b" stroke="#475569"/> <text x="220" y="235" text-anchor="middle" fill="#94a3b8">IF</text> <rect x="250" y="218" width="55" height="24" rx="3" fill="#1e293b" stroke="#475569"/> <text x="280" y="235" text-anchor="middle" fill="#94a3b8">ID</text> <rect x="310" y="218" width="55" height="24" rx="3" fill="#1e293b" stroke="#334155" stroke-dasharray="3,2"/> <text x="340" y="235" text-anchor="middle" fill="#64748b">stall</text> <rect x="370" y="218" width="55" height="24" rx="3" fill="#0f2027" stroke="#34d399"/> <text x="400" y="235" text-anchor="middle" fill="#86efac">EX ✓</text> <rect x="430" y="218" width="55" height="24" rx="3" fill="#1e293b" stroke="#475569"/> <text x="460" y="235" text-anchor="middle" fill="#94a3b8">MEM</text> <rect x="490" y="218" width="55" height="24" rx="3" fill="#1e293b" stroke="#475569"/> <text x="520" y="235" text-anchor="middle" fill="#94a3b8">WB</text>

<!-- Forward arrow from MEM to EX --> <path d="M 340 202 L 340 213 L 400 213 L 400 218" stroke="#34d399" stroke-width="1.5" fill="none" marker-end="url(#lu-fwd)"/> <text x="370" y="211" text-anchor="middle" fill="#34d399" font-size="10">forward</text> </svg>

The data is produced at the **end** of LW's MEM stage (cycle 4). ADD's EX stage needs it at the **beginning** of cycle 4. This is a temporal impossibility — even with forwarding, the data does not exist yet.

The mandatory solution is **one stall cycle** inserted by the hazard detection unit, followed by a MEM/WB → EX forward on the next cycle.

---

### Hazard Detection Unit (Load-Use)

The hazard detection unit operates in the ID stage and checks the instruction currently in EX:

```
if (ID/EX.MemRead AND
    (ID/EX.rd = IF/ID.rs1 OR ID/EX.rd = IF/ID.rs2))
then:
    stall pipeline:
        — freeze PC (do not increment)
        — freeze IF/ID register (re-fetch same instruction next cycle)
        — insert NOP/bubble into ID/EX register
```

This logic fires only for load instructions (`MemRead` is set). ALU instruction hazards are fully resolved by forwarding alone.

---

### Double Data Hazard

When two consecutive instructions both write the same register, and a third reads it, the forwarding unit must supply the **most recent** value.

```
ADD R1, R2, R3      ; write 1 to R1
ADD R1, R4, R5      ; write 2 to R1  ← most recent
SUB R6, R1, R7      ; must read write 2, not write 1
```

The EX/MEM priority rule in the forwarding logic handles this correctly: when SUB is in EX, the first ADD is in WB (MEM/WB holds its value) and the second ADD is in MEM (EX/MEM holds its value). The EX/MEM check fires first and delivers the second ADD's result.

---

### Forwarding in the Context of Memory Operations

#### Store Forwarding (MEM → MEM)

A store instruction writes a value to memory. The value to be stored may itself be a hazard target. The forwarding unit must also cover the **MEM stage data input** (the value being written), not only the ALU inputs.

```
ADD R1, R2, R3
SW  R1, 0(R4)    ; the value of R1 being stored must be forwarded
```

This requires an additional forwarding path: EX/MEM or MEM/WB → the data input of the MEM stage.

#### Load-Store Forwarding

On some architectures, a store followed by a load to the **same address** can be resolved in the memory system before the store reaches the cache — this is **store-to-load forwarding** in the memory subsystem, distinct from register forwarding but conceptually parallel.

---

### Forwarding in Deeper and Superscalar Pipelines

In pipelines deeper than 5 stages, more forwarding paths are needed. If the EX stage is split into EX1, EX2, EX3 (e.g., for a multi-cycle FPU), results must be forwarded from each intermediate pipeline register.

In **superscalar processors**, forwarding becomes a crossbar: every functional unit's output must potentially be forwardable to every functional unit's input in the same cycle. For an N-issue superscalar with M functional units, the forwarding network is an N×M MUX structure, contributing non-trivial area and wire delay.

<svg viewBox="0 0 500 240" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <text x="250" y="20" text-anchor="middle" font-size="13" font-weight="bold" fill="#e2e8f0">2-Issue Superscalar Forwarding Network</text> <!-- Slot 0 output --> <rect x="40" y="50" width="100" height="35" rx="4" fill="#0f2027" stroke="#3b82f6"/> <text x="90" y="73" text-anchor="middle" fill="#93c5fd">ALU 0 output</text> <!-- Slot 1 output --> <rect x="40" y="130" width="100" height="35" rx="4" fill="#0f2027" stroke="#3b82f6"/> <text x="90" y="153" text-anchor="middle" fill="#93c5fd">ALU 1 output</text> <!-- MUX 0 --> <rect x="230" y="45" width="50" height="45" rx="3" fill="#1e3a5f" stroke="#475569"/> <text x="255" y="73" text-anchor="middle" fill="#e2e8f0">MUX</text> <text x="255" y="84" text-anchor="middle" fill="#64748b" font-size="9">4-to-1</text> <!-- MUX 1 --> <rect x="230" y="130" width="50" height="45" rx="3" fill="#1e3a5f" stroke="#475569"/> <text x="255" y="158" text-anchor="middle" fill="#e2e8f0">MUX</text> <text x="255" y="169" text-anchor="middle" fill="#64748b" font-size="9">4-to-1</text> <!-- ALU 0 next --> <rect x="360" y="50" width="100" height="35" rx="4" fill="#1e293b" stroke="#475569"/> <text x="410" y="73" text-anchor="middle" fill="#e2e8f0">ALU 0 input</text> <!-- ALU 1 next --> <rect x="360" y="130" width="100" height="35" rx="4" fill="#1e293b" stroke="#475569"/> <text x="410" y="153" text-anchor="middle" fill="#e2e8f0">ALU 1 input</text> <!-- Forward paths --> <!-- ALU0 → MUX0 --> <line x1="140" y1="67" x2="230" y2="67" stroke="#f59e0b" stroke-width="1.5" marker-end="url(#fwd-arr)"/> <!-- ALU0 → MUX1 --> <path d="M 160 75 L 200 75 L 200 152 L 230 152" stroke="#f59e0b" stroke-width="1.5" fill="none" marker-end="url(#fwd-arr)"/> <!-- ALU1 → MUX1 --> <line x1="140" y1="152" x2="230" y2="152" stroke="#34d399" stroke-width="1.5" marker-end="url(#fwd-arr)"/> <!-- ALU1 → MUX0 --> <path d="M 160 140 L 200 140 L 200 75 L 230 75" stroke="#34d399" stroke-width="1.5" fill="none" marker-end="url(#fwd-arr)"/> <!-- MUX to ALU --> <line x1="280" y1="67" x2="360" y2="67" stroke="#94a3b8" stroke-width="1.5" marker-end="url(#norm-arr)"/> <line x1="280" y1="152" x2="360" y2="152" stroke="#94a3b8" stroke-width="1.5" marker-end="url(#norm-arr)"/> <!-- Reg file inputs --> <rect x="140" y="195" width="110" height="25" rx="3" fill="#1e293b" stroke="#475569"/> <text x="195" y="212" text-anchor="middle" fill="#94a3b8">register file</text> <line x1="195" y1="195" x2="245" y2="90" stroke="#475569" stroke-width="1" stroke-dasharray="3,2"/> <line x1="195" y1="195" x2="245" y2="175" stroke="#475569" stroke-width="1" stroke-dasharray="3,2"/> <!-- Labels -->

<text x="170" y="95" fill="#f59e0b" font-size="10">cross-forward</text> <text x="170" y="125" fill="#34d399" font-size="10">cross-forward</text> </svg>

---

### Compiler Role: Instruction Scheduling

The compiler can reduce or eliminate forwarding stalls by **reordering instructions** to place independent instructions between a producer and its consumer — effectively filling the delay slots naturally.

```c
// Source:
a = b + c;
d = a * 2;
e = f + g;
```

**Naive order (load-use stall if b,c,f,g are in memory):**

```asm
LW   R1, b
LW   R2, c
ADD  R3, R1, R2   ; RAW on R1, R2 — stall if not forwarded
MUL  R4, R3, 2    ; RAW on R3 — stall
LW   R5, f
LW   R6, g
ADD  R7, R5, R6
```

**Scheduled order (independent loads moved up):**

```asm
LW   R1, b
LW   R2, c
LW   R5, f        ; ← moved here: independent, fills stall slot
ADD  R3, R1, R2   ; R1, R2 now available via forwarding or ready
LW   R6, g        ; ← fills stall slot for ADD→MUL
MUL  R4, R3, 2
ADD  R7, R5, R6
```

This is **static scheduling** and is a core responsibility of the compiler backend in RISC architectures. VLIW architectures rely on this entirely, with no forwarding hardware — the compiler must guarantee hazard-free issue slots.

---

### Summary of Forwarding Paths

|Source Register|Destination|Latency|Stall Required|
|---|---|---|---|
|EX/MEM (ALU result)|ALU input (EX)|1 cycle|No|
|MEM/WB (ALU result)|ALU input (EX)|2 cycles|No|
|MEM/WB (load result)|ALU input (EX)|2 cycles|No|
|MEM (load result)|ALU input (EX)|1 cycle (load-use)|**Yes — 1 stall**|
|MEM/WB|MEM stage data input|2 cycles|No|
|WB|ID (register file)|3 cycles|No (write-then-read)|

---

**Conclusion**

Data forwarding is the primary mechanism by which a pipelined processor eliminates the performance penalty of RAW data hazards. It routes results through dedicated bypass paths directly from pipeline registers to functional unit inputs, making the register file write-back latency invisible to the programmer and compiler in almost all cases. The sole exception — the load-use hazard — requires exactly one stall cycle, which compilers routinely hide through instruction scheduling. In deeper and wider pipelines, the forwarding network grows in complexity and becomes a significant contributor to cycle time and area.

**Next Steps**

Proceed to **Branch Prediction** to examine how control hazards — the other major source of pipeline inefficiency — are mitigated through static heuristics, dynamic history tables, and speculative execution.

---

