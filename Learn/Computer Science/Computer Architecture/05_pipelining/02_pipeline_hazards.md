## Pipeline Hazards


A pipeline hazard is any condition that prevents the next instruction in the instruction stream from executing in its designated clock cycle. Hazards are the primary source of deviation from ideal pipeline throughput and must be detected and resolved to maintain correct execution.

---

### Pipeline Baseline

Assume a canonical 5-stage RISC pipeline throughout:

|Stage|Name|Function|
|---|---|---|
|IF|Instruction Fetch|Read instruction from memory using PC|
|ID|Instruction Decode / Register Read|Decode opcode; read source registers|
|EX|Execute|ALU operation or address computation|
|MEM|Memory Access|Load or store to data memory|
|WB|Write Back|Write result to register file|

Under ideal conditions, one instruction completes per cycle (CPI = 1). Hazards increase CPI by forcing **stalls** (pipeline bubbles) or requiring other resolution mechanisms.

---

### Structural Hazards

A structural hazard occurs when two instructions simultaneously require the same hardware resource, and the hardware cannot service both in the same cycle.

#### Cause

The pipeline was designed assuming resource sharing that breaks down under certain instruction sequences.

#### Classic Example — Single Memory Port

If instruction fetch (IF) and a load/store (MEM) both need to access memory in the same cycle, and only one memory port exists, one must stall.

<svg viewBox="0 0 700 230" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="700" height="230" fill="#1e1e2e"/> <!-- Column headers -->

<text x="160" y="18" fill="#585b70" text-anchor="middle">CC1</text> <text x="220" y="18" fill="#585b70" text-anchor="middle">CC2</text> <text x="280" y="18" fill="#585b70" text-anchor="middle">CC3</text> <text x="340" y="18" fill="#585b70" text-anchor="middle">CC4</text> <text x="400" y="18" fill="#585b70" text-anchor="middle">CC5</text> <text x="460" y="18" fill="#585b70" text-anchor="middle">CC6</text> <text x="520" y="18" fill="#585b70" text-anchor="middle">CC7</text> <text x="580" y="18" fill="#585b70" text-anchor="middle">CC8</text> <text x="640" y="18" fill="#585b70" text-anchor="middle">CC9</text>

<!-- I1: LW -->

<text x="10" y="48" fill="#cdd6f4">I1: LW</text> <rect x="130" y="28" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="155" y="44" fill="#89b4fa" text-anchor="middle">IF</text> <rect x="190" y="28" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="215" y="44" fill="#89b4fa" text-anchor="middle">ID</text> <rect x="250" y="28" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="275" y="44" fill="#89b4fa" text-anchor="middle">EX</text> <rect x="310" y="28" width="50" height="24" rx="3" fill="#3a1e1e" stroke="#f38ba8" stroke-width="2"/><text x="335" y="44" fill="#f38ba8" text-anchor="middle">MEM</text> <rect x="370" y="28" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="395" y="44" fill="#89b4fa" text-anchor="middle">WB</text>

<!-- I2 -->

<text x="10" y="88" fill="#cdd6f4">I2: ADD</text> <rect x="190" y="68" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="215" y="84" fill="#89b4fa" text-anchor="middle">IF</text> <rect x="250" y="68" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="275" y="84" fill="#89b4fa" text-anchor="middle">ID</text> <rect x="310" y="68" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="335" y="84" fill="#89b4fa" text-anchor="middle">EX</text> <rect x="370" y="68" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="395" y="84" fill="#89b4fa" text-anchor="middle">MEM</text> <rect x="430" y="68" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="455" y="84" fill="#89b4fa" text-anchor="middle">WB</text>

<!-- I3: needs IF at CC4, conflict with I1 MEM -->

<text x="10" y="128" fill="#cdd6f4">I3: LW</text> <rect x="310" y="108" width="50" height="24" rx="3" fill="#3a3a1e" stroke="#f38ba8" stroke-width="2" stroke-dasharray="4,2"/> <text x="335" y="124" fill="#f38ba8" text-anchor="middle">IF?</text>

<!-- stall --> <rect x="370" y="108" width="50" height="24" rx="3" fill="#2a2a2a" stroke="#585b70" stroke-width="1" stroke-dasharray="3,3"/> <text x="395" y="124" fill="#585b70" text-anchor="middle">stall</text> <rect x="430" y="108" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="455" y="124" fill="#89b4fa" text-anchor="middle">IF</text> <rect x="490" y="108" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="515" y="124" fill="#89b4fa" text-anchor="middle">ID</text> <rect x="550" y="108" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="575" y="124" fill="#89b4fa" text-anchor="middle">EX</text> <rect x="610" y="108" width="50" height="24" rx="3" fill="#3a1e1e" stroke="#f38ba8" stroke-width="1.5"/><text x="635" y="124" fill="#f38ba8" text-anchor="middle">MEM</text> <!-- Conflict annotation --> <line x1="335" y1="52" x2="335" y2="108" stroke="#f38ba8" stroke-width="1" stroke-dasharray="3,2"/> <text x="350" y="100" fill="#f38ba8" font-size="10">conflict</text>

<text x="350" y="195" fill="#fab387" text-anchor="middle" font-size="11">Single memory port conflict: I1 MEM and I3 IF both need memory at CC4 → 1-cycle stall</text> </svg>

#### Resolution

- **Separate instruction and data memories** (Harvard architecture) — the most common solution in pipelined processors; eliminates this specific structural hazard entirely.
- **Multi-ported register files** — resolves register port conflicts when multiple instructions need simultaneous reads/writes.
- **Resource duplication** — adding functional units (e.g., multiple ALUs) so that two instructions can each use one.

Structural hazards are **design-time** decisions. A sufficiently resourced pipeline can eliminate all of them, which is why modern processors rarely stall due to structural causes alone.

---

### Data Hazards

A data hazard occurs when an instruction depends on the result of a previous instruction that has not yet completed and written back to the register file.

#### The Three Types

|Type|Also Called|Condition|
|---|---|---|
|RAW|Read After Write / True dependency|Instruction J reads a register that instruction I has not yet written|
|WAR|Write After Read / Anti-dependency|Instruction J writes a register that instruction I has not yet read|
|WAW|Write After Write / Output dependency|Instruction J writes a register that instruction I also writes|

In a simple in-order pipeline, **RAW is the only hazard that causes stalls**. WAR and WAW only matter in out-of-order execution.

#### RAW Example

```asm
ADD R1, R2, R3    ; I1: R1 ← R2 + R3  (WB at end of CC5)
SUB R4, R1, R5    ; I2: R4 ← R1 − R5  (reads R1 at ID = CC3 ← WRONG)
```

I2 reads R1 at ID (CC3), but I1 does not write R1 until WB (CC5). Without intervention, I2 reads a stale value.

<svg viewBox="0 0 700 240" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="700" height="240" fill="#1e1e2e"/>

<text x="160" y="18" fill="#585b70" text-anchor="middle">CC1</text> <text x="220" y="18" fill="#585b70" text-anchor="middle">CC2</text> <text x="280" y="18" fill="#585b70" text-anchor="middle">CC3</text> <text x="340" y="18" fill="#585b70" text-anchor="middle">CC4</text> <text x="400" y="18" fill="#585b70" text-anchor="middle">CC5</text> <text x="460" y="18" fill="#585b70" text-anchor="middle">CC6</text> <text x="520" y="18" fill="#585b70" text-anchor="middle">CC7</text>

<!-- I1: ADD -->

<text x="10" y="48" fill="#cdd6f4">I1: ADD R1,R2,R3</text> <rect x="130" y="28" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="155" y="44" fill="#89b4fa" text-anchor="middle">IF</text> <rect x="190" y="28" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="215" y="44" fill="#89b4fa" text-anchor="middle">ID</text> <rect x="250" y="28" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="275" y="44" fill="#89b4fa" text-anchor="middle">EX</text> <rect x="310" y="28" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="335" y="44" fill="#89b4fa" text-anchor="middle">MEM</text> <rect x="370" y="28" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#a6e3a1" stroke-width="2"/><text x="395" y="44" fill="#a6e3a1" text-anchor="middle">WB</text>

<!-- WB writes R1 annotation -->

<text x="395" y="22" fill="#a6e3a1" text-anchor="middle" font-size="10">R1 written</text>

<!-- I2: SUB reads R1 at ID = CC3 -->

<text x="10" y="88" fill="#cdd6f4">I2: SUB R4,R1,R5</text> <rect x="190" y="68" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="215" y="84" fill="#89b4fa" text-anchor="middle">IF</text> <rect x="250" y="68" width="50" height="24" rx="3" fill="#3a1e1e" stroke="#f38ba8" stroke-width="2"/><text x="275" y="84" fill="#f38ba8" text-anchor="middle">ID</text> <rect x="310" y="68" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="335" y="84" fill="#89b4fa" text-anchor="middle">EX</text> <rect x="370" y="68" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="395" y="84" fill="#89b4fa" text-anchor="middle">MEM</text> <rect x="430" y="68" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="455" y="84" fill="#89b4fa" text-anchor="middle">WB</text>

<!-- ID reads R1 annotation -->

<text x="275" y="62" fill="#f38ba8" text-anchor="middle" font-size="10">R1 read (stale!)</text>

<!-- RAW arrow --> <path d="M395,52 Q395,100 275,92" fill="none" stroke="#fab387" stroke-width="1.5" stroke-dasharray="4,2" marker-end="url(#raw)"/> <text x="370" y="78" fill="#fab387" font-size="10">RAW</text> <!-- Gap annotation -->

<text x="350" y="140" fill="#585b70" text-anchor="middle">WB is at CC5 — ID reads at CC3 — gap of 2 cycles</text>

<!-- With stalls -->

<text x="10" y="178" fill="#585b70" font-size="10">With stalls:</text> <text x="10" y="198" fill="#cdd6f4" font-size="10">I2: SUB</text> <rect x="130" y="182" width="40" height="20" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1"/><text x="150" y="196" fill="#89b4fa" text-anchor="middle" font-size="10">IF</text> <rect x="175" y="182" width="40" height="20" rx="3" fill="#2a2a2a" stroke="#585b70" stroke-width="1" stroke-dasharray="3,2"/><text x="195" y="196" fill="#585b70" text-anchor="middle" font-size="10">stall</text> <rect x="220" y="182" width="40" height="20" rx="3" fill="#2a2a2a" stroke="#585b70" stroke-width="1" stroke-dasharray="3,2"/><text x="240" y="196" fill="#585b70" text-anchor="middle" font-size="10">stall</text> <rect x="265" y="182" width="40" height="20" rx="3" fill="#3a1e1e" stroke="#a6e3a1" stroke-width="1.5"/><text x="285" y="196" fill="#a6e3a1" text-anchor="middle" font-size="10">ID</text> <text x="295" y="196" fill="#a6e3a1" font-size="9">✓</text>

<text x="350" y="218" fill="#fab387" text-anchor="middle" font-size="10">2 stall cycles inserted → R1 now valid at ID</text>

<defs> <marker id="raw" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#fab387"/> </marker> </defs> </svg>

#### Resolution 1 — Data Forwarding (Bypassing)

Instead of waiting for WB to commit the result to the register file, the result is routed directly from the pipeline register where it sits to the stage that needs it.

|Forward from|Forward to|Resolves|
|---|---|---|
|EX/MEM register|EX stage input|EX–EX hazard (1-cycle gap)|
|MEM/WB register|EX stage input|MEM–EX hazard (2-cycle gap)|
|MEM/WB register|MEM stage input|Load–use with intervening instruction|

<svg viewBox="0 0 700 180" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="700" height="180" fill="#1e1e2e"/> <!-- Pipeline stages --> <rect x="30" y="40" width="80" height="36" rx="4" fill="#313244" stroke="#89b4fa" stroke-width="1.5"/> <text x="70" y="63" fill="#89b4fa" text-anchor="middle">IF</text> <rect x="150" y="40" width="80" height="36" rx="4" fill="#313244" stroke="#89b4fa" stroke-width="1.5"/> <text x="190" y="63" fill="#89b4fa" text-anchor="middle">ID</text> <rect x="270" y="40" width="80" height="36" rx="4" fill="#313244" stroke="#a6e3a1" stroke-width="2"/> <text x="310" y="57" fill="#a6e3a1" text-anchor="middle">EX</text> <text x="310" y="70" fill="#585b70" text-anchor="middle" font-size="9">result here</text> <rect x="390" y="40" width="80" height="36" rx="4" fill="#313244" stroke="#a6e3a1" stroke-width="2"/> <text x="430" y="57" fill="#a6e3a1" text-anchor="middle">MEM</text> <text x="430" y="70" fill="#585b70" text-anchor="middle" font-size="9">result here</text> <rect x="510" y="40" width="80" height="36" rx="4" fill="#313244" stroke="#89b4fa" stroke-width="1.5"/> <text x="550" y="63" fill="#89b4fa" text-anchor="middle">WB</text> <!-- Normal flow arrows --> <line x1="110" y1="58" x2="150" y2="58" stroke="#585b70" stroke-width="1.5" marker-end="url(#af)"/> <line x1="230" y1="58" x2="270" y2="58" stroke="#585b70" stroke-width="1.5" marker-end="url(#af)"/> <line x1="350" y1="58" x2="390" y2="58" stroke="#585b70" stroke-width="1.5" marker-end="url(#af)"/> <line x1="470" y1="58" x2="510" y2="58" stroke="#585b70" stroke-width="1.5" marker-end="url(#af)"/> <!-- Forwarding paths --> <!-- EX → EX (one stage back) --> <path d="M350,76 Q350,120 310,120 Q270,120 270,76" fill="none" stroke="#a6e3a1" stroke-width="2" marker-end="url(#afwd)"/> <text x="310" y="140" fill="#a6e3a1" text-anchor="middle" font-size="10">EX→EX forward</text> <!-- MEM → EX (two stages back) --> <path d="M470,76 Q470,150 310,150 Q270,150 270,76" fill="none" stroke="#fab387" stroke-width="2" marker-end="url(#afwd2)"/> <text x="420" y="165" fill="#fab387" text-anchor="middle" font-size="10">MEM→EX forward</text> <defs> <marker id="af" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#585b70"/> </marker> <marker id="afwd" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#a6e3a1"/> </marker> <marker id="afwd2" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#fab387"/> </marker> </defs> </svg>

#### Resolution 2 — Load-Use Hazard (Unavoidable Stall)

Forwarding cannot fully resolve a **load-use hazard**: a load instruction followed immediately by an instruction that uses the loaded value. The load result is not available until the end of MEM, but the consumer needs it at the start of EX — one cycle too early even with forwarding.

```asm
LW  R1, 0(R2)    ; result available after MEM
ADD R3, R1, R4   ; needs R1 at EX — one cycle before LW MEM completes
```

The only resolution without reordering is a **1-cycle stall** (bubble inserted between LW and ADD), after which forwarding from MEM/WB can supply the value. Compilers mitigate this by scheduling an independent instruction between the load and its use — **load delay slot scheduling**.

---

### Control Hazards

A control hazard occurs when the pipeline fetches instructions after a branch before it is known whether the branch is taken and what the target address is.

#### The Problem

In the 5-stage pipeline, the branch outcome (taken/not-taken) and target address are not determined until the end of EX (CC3 for a branch fetched at CC1). By that time, two instructions have already been fetched speculatively.

```asm
BEQ R1, R2, TARGET   ; fetched CC1; outcome known end of CC3
ADD R3, R4, R5        ; fetched CC1+1 = CC2 — may be wrong
SUB R6, R7, R8        ; fetched CC1+2 = CC3 — may be wrong
```

If the branch is taken, the two instructions in IF and ID must be squashed (turned into NOPs), costing 2 cycles — the **branch penalty**.

<svg viewBox="0 0 700 220" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="700" height="220" fill="#1e1e2e"/>

<text x="160" y="18" fill="#585b70" text-anchor="middle">CC1</text> <text x="220" y="18" fill="#585b70" text-anchor="middle">CC2</text> <text x="280" y="18" fill="#585b70" text-anchor="middle">CC3</text> <text x="340" y="18" fill="#585b70" text-anchor="middle">CC4</text> <text x="400" y="18" fill="#585b70" text-anchor="middle">CC5</text> <text x="460" y="18" fill="#585b70" text-anchor="middle">CC6</text> <text x="520" y="18" fill="#585b70" text-anchor="middle">CC7</text>

<!-- Branch instruction -->

<text x="5" y="46" fill="#cdd6f4">BEQ</text> <rect x="130" y="28" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="155" y="44" fill="#89b4fa" text-anchor="middle">IF</text> <rect x="190" y="28" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="215" y="44" fill="#89b4fa" text-anchor="middle">ID</text> <rect x="250" y="28" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#cba6f7" stroke-width="2"/><text x="275" y="40" fill="#cba6f7" text-anchor="middle">EX</text> <text x="275" y="50" fill="#cba6f7" text-anchor="middle" font-size="9">outcome</text> <rect x="310" y="28" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="335" y="44" fill="#89b4fa" text-anchor="middle">MEM</text> <rect x="370" y="28" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="395" y="44" fill="#89b4fa" text-anchor="middle">WB</text>

<!-- Speculative I+1 — squashed -->

<text x="5" y="86" fill="#585b70">I+1</text> <rect x="190" y="68" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="215" y="84" fill="#89b4fa" text-anchor="middle">IF</text> <rect x="250" y="68" width="50" height="24" rx="3" fill="#3a1e1e" stroke="#f38ba8" stroke-width="1.5" stroke-dasharray="4,2"/><text x="275" y="84" fill="#f38ba8" text-anchor="middle">squash</text> <rect x="310" y="68" width="50" height="24" rx="3" fill="#2a2a2a" stroke="#585b70" stroke-width="1" stroke-dasharray="3,2"/><text x="335" y="84" fill="#585b70" text-anchor="middle">NOP</text> <rect x="370" y="68" width="50" height="24" rx="3" fill="#2a2a2a" stroke="#585b70" stroke-width="1" stroke-dasharray="3,2"/><text x="395" y="84" fill="#585b70" text-anchor="middle">NOP</text> <rect x="430" y="68" width="50" height="24" rx="3" fill="#2a2a2a" stroke="#585b70" stroke-width="1" stroke-dasharray="3,2"/><text x="455" y="84" fill="#585b70" text-anchor="middle">NOP</text>

<!-- Speculative I+2 — squashed -->

<text x="5" y="126" fill="#585b70">I+2</text> <rect x="250" y="108" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.2"/><text x="275" y="124" fill="#89b4fa" text-anchor="middle">IF</text> <rect x="310" y="108" width="50" height="24" rx="3" fill="#3a1e1e" stroke="#f38ba8" stroke-width="1.5" stroke-dasharray="4,2"/><text x="335" y="124" fill="#f38ba8" text-anchor="middle">squash</text> <rect x="370" y="108" width="50" height="24" rx="3" fill="#2a2a2a" stroke="#585b70" stroke-width="1" stroke-dasharray="3,2"/><text x="395" y="124" fill="#585b70" text-anchor="middle">NOP</text> <rect x="430" y="108" width="50" height="24" rx="3" fill="#2a2a2a" stroke="#585b70" stroke-width="1" stroke-dasharray="3,2"/><text x="455" y="124" fill="#585b70" text-anchor="middle">NOP</text> <rect x="490" y="108" width="50" height="24" rx="3" fill="#2a2a2a" stroke="#585b70" stroke-width="1" stroke-dasharray="3,2"/><text x="515" y="124" fill="#585b70" text-anchor="middle">NOP</text>

<!-- TARGET fetched after branch resolves -->

<text x="5" y="166" fill="#a6e3a1">TARGET</text> <rect x="310" y="148" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#a6e3a1" stroke-width="2"/><text x="335" y="164" fill="#a6e3a1" text-anchor="middle">IF</text> <rect x="370" y="148" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#a6e3a1" stroke-width="1.5"/><text x="395" y="164" fill="#a6e3a1" text-anchor="middle">ID</text> <rect x="430" y="148" width="50" height="24" rx="3" fill="#1e3a5f" stroke="#a6e3a1" stroke-width="1.5"/><text x="455" y="164" fill="#a6e3a1" text-anchor="middle">EX</text>

<text x="350" y="200" fill="#fab387" text-anchor="middle">2-cycle branch penalty: I+1 and I+2 fetched speculatively, then squashed</text> </svg>

#### Resolution 1 — Flush and Stall (Freeze)

The simplest approach: when a branch is detected at ID, stall the pipeline until the outcome is known at EX, inserting bubbles. This incurs the full branch penalty with no speculation.

#### Resolution 2 — Predict Not Taken

Assume the branch is never taken. Continue fetching sequentially. If the branch turns out not taken — no penalty. If taken — flush the 2 speculative instructions.

#### Resolution 3 — Predict Taken

Assume the branch is always taken. Begin fetching from the branch target immediately. Requires knowing the target early (often from a **Branch Target Buffer**). If correct — no penalty. If not taken — flush.

#### Resolution 4 — Delayed Branch

The architecture defines one or more **branch delay slots**: instructions immediately following the branch that always execute regardless of the branch outcome. The compiler fills delay slots with useful independent instructions.

```asm
BEQ R1, R2, TARGET
ADD R5, R6, R7      ; delay slot — always executes
; branch takes effect here
TARGET: ...
```

Used in MIPS. If no useful instruction can fill the slot, a NOP is inserted — recovering no performance.

#### Resolution 5 — Dynamic Branch Prediction

Hardware maintains a history of each branch's behavior and predicts future outcomes based on past behavior. Detailed coverage appears in the Branch Prediction topic; the key mechanisms are:

|Mechanism|Description|
|---|---|
|1-bit predictor|Predicts the last outcome|
|2-bit saturating counter|Requires two consecutive mispredictions to change prediction|
|Branch History Table (BHT)|Table of 2-bit counters indexed by PC|
|Branch Target Buffer (BTB)|Caches branch targets so the fetched address is known before decode|
|Tournament predictor|Chooses between local and global history predictors per branch|

---

### Hazard Comparison

|Property|Structural|Data (RAW)|Control|
|---|---|---|---|
|Cause|Resource conflict|Instruction dependency|Branch outcome unknown|
|Detected at|Issue / decode|Decode / hazard unit|Decode / execute|
|Resolution (stall)|Yes — 1+ cycles|Yes — 1–2 cycles|Yes — branch penalty|
|Resolution (forwarding)|Not applicable|Yes — eliminates most stalls|Not applicable|
|Resolution (prediction)|Not applicable|Not applicable|Yes — reduces penalty|
|Eliminating at design time|Yes (resource duplication)|Partially (forwarding + compiler)|Partially (delay slots)|

---

### CPI Impact

$$\text{CPI}_\text{actual} = \text{CPI}_\text{ideal} + \text{stalls}_\text{structural} + \text{stalls}_\text{data} + \text{stalls}_\text{control}$$

**Example:** A pipeline with CPI_ideal = 1, 5% load-use hazards (1 stall each), 20% branches with 2-cycle penalty and 10% misprediction rate:

```
CPI = 1 + (0.05 × 1) + (0.20 × 0.10 × 2)
    = 1 + 0.05 + 0.04
    = 1.09
```

[Inference] This is a simplified illustrative calculation. Actual CPI depends on the specific workload, hazard rates, and microarchitectural details — behavior is not guaranteed to match any real processor.

---

**Conclusion:** Structural, data, and control hazards each attack pipeline efficiency through different mechanisms. Structural hazards are resolved primarily by hardware design. Data hazards are addressed by forwarding and stall insertion, with compiler scheduling as a complementary tool. Control hazards — driven by the fundamental uncertainty of branch outcomes — require prediction and speculative execution, and represent the largest remaining source of pipeline inefficiency in deeply pipelined designs.

**Next Steps:** Proceed to Data Forwarding / Bypassing for a detailed treatment of forwarding unit logic and edge cases, or to Branch Prediction for a full account of static and dynamic prediction mechanisms and their performance implications.

---

