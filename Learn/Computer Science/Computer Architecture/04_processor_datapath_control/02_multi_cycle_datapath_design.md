## Multi-cycle Datapath Design


The multi-cycle datapath partitions instruction execution across multiple clock cycles, with each cycle performing one discrete step. This contrasts with the single-cycle design where every instruction — regardless of complexity — completes in one clock period sized to the slowest instruction. The multi-cycle approach allows each functional unit to be reused across cycles and permits different instructions to consume only as many cycles as they require.

---

### Motivation and Contrast with Single-Cycle

In a single-cycle datapath, the clock period is determined by the longest instruction path — typically a load word, which traverses the PC, instruction memory, register file, ALU, data memory, and register file write port in sequence. All simpler instructions are artificially stretched to this same period, wasting time.

|Property|Single-Cycle|Multi-Cycle|
|---|---|---|
|Clock period|Worst-case instruction|Single functional unit delay|
|Functional units|Duplicated (separate memories)|Shared and reused|
|CPI|Always 1|3–5 depending on instruction|
|Control complexity|Simple combinational|Sequenced FSM|
|Hardware cost|Higher (duplication)|Lower (sharing)|

The multi-cycle design trades a CPI greater than 1 for a shorter clock period and reduced hardware. Whether this yields better overall performance depends on the instruction mix.

---

### Key Architectural Decisions

#### Shared Memory

A single unified memory serves both instruction fetch and data access. Since these occur in different cycles, there is no structural conflict. A **Memory Address Register (MAR)** holds the address, and a **Memory Data Register (MDR)** holds the value read from or written to memory.

#### Shared ALU

One ALU handles all arithmetic, address calculation, and PC increment operations. Intermediate values are stored in temporary registers between cycles.

#### Intermediate Registers

Results computed in one cycle must be preserved for use in subsequent cycles. Several non-programmer-visible registers are introduced:

|Register|Holds|
|---|---|
|**IR** (Instruction Register)|Fetched instruction bits|
|**MDR** (Memory Data Register)|Value read from memory|
|**A**|Register file read port 1 output|
|**B**|Register file read port 2 output|
|**ALUOut**|ALU result from previous cycle|

---

### Datapath Structure

<svg viewBox="0 0 740 520" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- Memory --> <rect x="20" y="60" width="100" height="70" rx="4" fill="none" stroke="#888" stroke-width="1.5"/> <text x="70" y="91" text-anchor="middle" fill="#ccc">Memory</text> <text x="70" y="108" text-anchor="middle" fill="#aaa">(unified)</text> <!-- IR --> <rect x="160" y="60" width="70" height="35" rx="4" fill="none" stroke="#888" stroke-width="1.5"/> <text x="195" y="83" text-anchor="middle" fill="#ccc">IR</text> <!-- MDR --> <rect x="160" y="110" width="70" height="35" rx="4" fill="none" stroke="#888" stroke-width="1.5"/> <text x="195" y="133" text-anchor="middle" fill="#ccc">MDR</text> <!-- Register File --> <rect x="290" y="60" width="100" height="70" rx="4" fill="none" stroke="#888" stroke-width="1.5"/> <text x="340" y="88" text-anchor="middle" fill="#ccc">Register</text> <text x="340" y="104" text-anchor="middle" fill="#ccc">File</text> <text x="340" y="120" text-anchor="middle" fill="#aaa">32 × 32</text> <!-- A register --> <rect x="430" y="60" width="50" height="30" rx="4" fill="none" stroke="#888" stroke-width="1.5"/> <text x="455" y="80" text-anchor="middle" fill="#ccc">A</text> <!-- B register --> <rect x="430" y="100" width="50" height="30" rx="4" fill="none" stroke="#888" stroke-width="1.5"/> <text x="455" y="120" text-anchor="middle" fill="#ccc">B</text> <!-- ALU --> <rect x="520" y="70" width="80" height="60" rx="4" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="560" y="105" text-anchor="middle" fill="#7af">ALU</text> <!-- ALUOut --> <rect x="630" y="70" width="70" height="35" rx="4" fill="none" stroke="#888" stroke-width="1.5"/> <text x="665" y="93" text-anchor="middle" fill="#ccc">ALUOut</text> <!-- PC --> <rect x="20" y="200" width="70" height="35" rx="4" fill="none" stroke="#fa7" stroke-width="1.5"/> <text x="55" y="223" text-anchor="middle" fill="#fa7">PC</text> <!-- Sign Extend --> <rect x="290" y="175" width="100" height="35" rx="4" fill="none" stroke="#888" stroke-width="1.5"/> <text x="340" y="197" text-anchor="middle" fill="#aaa">Sign Extend</text> <!-- Shift Left 2 --> <rect x="430" y="175" width="80" height="35" rx="4" fill="none" stroke="#888" stroke-width="1.5"/> <text x="470" y="192" text-anchor="middle" fill="#aaa">SL2</text> <!-- MUX labels -->

<text x="155" y="230" fill="#8f8" font-size="10">MuxA</text> <rect x="148" y="235" width="18" height="50" rx="2" fill="none" stroke="#8f8" stroke-width="1.2"/> <text x="157" y="250" text-anchor="middle" fill="#8f8" font-size="9">PC</text> <text x="157" y="265" text-anchor="middle" fill="#8f8" font-size="9">A</text> <text x="157" y="278" text-anchor="middle" fill="#8f8" font-size="9">—</text>

<text x="500" y="230" fill="#8f8" font-size="10">MuxB</text> <rect x="493" y="235" width="18" height="65" rx="2" fill="none" stroke="#8f8" stroke-width="1.2"/> <text x="502" y="250" text-anchor="middle" fill="#8f8" font-size="9">B</text> <text x="502" y="263" text-anchor="middle" fill="#8f8" font-size="9">4</text> <text x="502" y="276" text-anchor="middle" fill="#8f8" font-size="9">SE</text> <text x="502" y="289" text-anchor="middle" fill="#8f8" font-size="9">SL2</text>

<!-- PC Mux -->

<text x="620" y="230" fill="#8f8" font-size="10">MuxPC</text> <rect x="618" y="235" width="18" height="50" rx="2" fill="none" stroke="#8f8" stroke-width="1.2"/> <text x="627" y="250" text-anchor="middle" fill="#8f8" font-size="9">ALU</text> <text x="627" y="263" text-anchor="middle" fill="#8f8" font-size="9">Out</text> <text x="627" y="276" text-anchor="middle" fill="#8f8" font-size="9">Jmp</text>

<!-- Write-back Mux -->

<text x="340" y="310" fill="#8f8" font-size="10">MuxWB</text> <rect x="333" y="315" width="18" height="40" rx="2" fill="none" stroke="#8f8" stroke-width="1.2"/> <text x="342" y="330" text-anchor="middle" fill="#8f8" font-size="9">ALU</text> <text x="342" y="343" text-anchor="middle" fill="#8f8" font-size="9">MDR</text>

<!-- Data path connections --> <!-- Memory to IR --> <line x1="120" y1="78" x2="160" y2="78" stroke="#ccc" stroke-width="1.2"/> <!-- Memory to MDR --> <line x1="120" y1="118" x2="160" y2="118" stroke="#ccc" stroke-width="1.2"/> <!-- IR to Reg File (rs, rt, rd) --> <line x1="230" y1="78" x2="290" y2="88" stroke="#ccc" stroke-width="1.2"/> <!-- IR to Sign Extend --> <line x1="230" y1="90" x2="290" y2="185" stroke="#ccc" stroke-width="1.2" stroke-dasharray="4,2"/> <!-- Reg File to A --> <line x1="390" y1="78" x2="430" y2="75" stroke="#ccc" stroke-width="1.2"/> <!-- Reg File to B --> <line x1="390" y1="100" x2="430" y2="115" stroke="#ccc" stroke-width="1.2"/> <!-- A to ALU --> <line x1="480" y1="75" x2="520" y2="85" stroke="#ccc" stroke-width="1.2"/> <!-- B to ALU --> <line x1="480" y1="115" x2="520" y2="115" stroke="#ccc" stroke-width="1.2"/> <!-- ALU to ALUOut --> <line x1="600" y1="100" x2="630" y2="88" stroke="#7af" stroke-width="1.2"/> <!-- ALUOut to PC (feedback) --> <line x1="665" y1="105" x2="665" y2="380" stroke="#fa7" stroke-width="1.2" stroke-dasharray="3,2"/> <line x1="665" y1="380" x2="55" y2="380" stroke="#fa7" stroke-width="1.2" stroke-dasharray="3,2"/> <line x1="55" y1="380" x2="55" y2="235" stroke="#fa7" stroke-width="1.2" stroke-dasharray="3,2"/> <!-- PC to MuxA --> <line x1="90" y1="218" x2="148" y2="253" stroke="#fa7" stroke-width="1.2"/> <!-- Sign Extend to SL2 --> <line x1="390" y1="192" x2="430" y2="192" stroke="#aaa" stroke-width="1.2"/> <!-- Control label --> <text x="370" y="430" text-anchor="middle" fill="#f88" font-size="12">Control signals omitted for clarity — governed by FSM</text> </svg>

---

### Execution Phases

Instruction execution is divided into at most five steps. Not every instruction uses all five — this is the source of variable CPI.

#### Step 1 — Instruction Fetch (IF)

```
IR  ← Memory[PC]
MDR ← Memory[PC]    (MDR loaded simultaneously for possible use)
PC  ← PC + 4
```

- The PC is used to address unified memory.
- The fetched instruction is latched into IR.
- PC is incremented through the ALU: ALU computes PC + 4, result written back to PC.
- This step is **identical for all instructions**.

#### Step 2 — Instruction Decode / Register Read (ID)

```
A      ← Reg[IR[25:21]]     (rs field)
B      ← Reg[IR[20:16]]     (rt field)
ALUOut ← PC + (sign_extend(IR[15:0]) << 2)
```

- Register file is read regardless of instruction type — fields are always in the same position (a property of MIPS-like fixed-format ISAs).
- The branch target address is computed speculatively in ALUOut. This costs nothing since the ALU is otherwise idle.
- No control decisions are required yet; all instructions pass through this step identically.

#### Step 3 — Execute / Address Calculation (EX)

Behavior diverges here based on instruction type:

**Memory-reference (lw, sw):**

```
ALUOut ← A + sign_extend(IR[15:0])
```

**R-type:**

```
ALUOut ← A op B         (op determined by funct field)
```

**Branch (beq):**

```
if (A == B) PC ← ALUOut     (ALUOut already holds branch target from step 2)
```

**Jump:**

```
PC ← {PC[31:28], IR[25:0], 2'b00}
```

Branch and jump instructions complete here — they require only 3 cycles.

#### Step 4 — Memory Access / R-type Completion (MEM)

**Load:**

```
MDR ← Memory[ALUOut]
```

**Store:**

```
Memory[ALUOut] ← B
```

**R-type:**

```
Reg[IR[15:11]] ← ALUOut     (rd ← result; R-type completes in 4 cycles)
```

#### Step 5 — Write-Back (WB)

This step applies only to load instructions:

```
Reg[IR[20:16]] ← MDR        (rt ← data loaded from memory)
```

Load is the only instruction requiring all 5 cycles.

---

### CPI by Instruction Class

|Instruction Type|Cycles|Steps Used|
|---|---|---|
|R-type (add, sub, and…)|4|IF, ID, EX, WB|
|Load (lw)|5|IF, ID, EX, MEM, WB|
|Store (sw)|4|IF, ID, EX, MEM|
|Branch (beq)|3|IF, ID, EX|
|Jump (j)|3|IF, ID, EX|

**Average CPI** depends on instruction mix. For a typical MIPS program:

```
CPI_avg = Σ (fraction_i × CPI_i)
```

If 25% loads, 10% stores, 45% R-type, 15% branch, 5% jump:

```
CPI_avg = 0.25×5 + 0.10×4 + 0.45×4 + 0.15×3 + 0.05×3
        = 1.25 + 0.40 + 1.80 + 0.45 + 0.15
        = 4.05
```

This is meaningfully compared against single-cycle only when the multi-cycle clock period is sufficiently shorter — typically 3–5× shorter, since the single-cycle period is bounded by the full load path.

---

### Control Unit Design

The multi-cycle control unit is a **finite state machine (FSM)** — each state corresponds to one execution step, and the state transitions determine control signal values for each cycle.

#### State Diagram (MIPS Subset)

<svg viewBox="0 0 660 480" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- State S0: IF --> <circle cx="330" cy="50" r="32" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="330" y="46" text-anchor="middle" fill="#7af">S0</text> <text x="330" y="60" text-anchor="middle" fill="#aaa">IF</text> <!-- State S1: ID --> <circle cx="330" cy="160" r="32" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="330" y="156" text-anchor="middle" fill="#7af">S1</text> <text x="330" y="170" text-anchor="middle" fill="#aaa">ID</text> <!-- State S2: EX mem --> <circle cx="130" cy="280" r="32" fill="none" stroke="#fa7" stroke-width="1.5"/> <text x="130" y="276" text-anchor="middle" fill="#fa7">S2</text> <text x="130" y="290" text-anchor="middle" fill="#aaa">EX-Mem</text> <!-- State S3: EX R-type --> <circle cx="330" cy="280" r="32" fill="none" stroke="#fa7" stroke-width="1.5"/> <text x="330" y="276" text-anchor="middle" fill="#fa7">S3</text> <text x="330" y="290" text-anchor="middle" fill="#aaa">EX-R</text> <!-- State S4: Branch --> <circle cx="490" cy="280" r="32" fill="none" stroke="#fa7" stroke-width="1.5"/> <text x="490" y="276" text-anchor="middle" fill="#fa7">S4</text> <text x="490" y="290" text-anchor="middle" fill="#aaa">Branch</text> <!-- State S5: MEM load --> <circle cx="60" cy="400" r="32" fill="none" stroke="#8f8" stroke-width="1.5"/> <text x="60" y="396" text-anchor="middle" fill="#8f8">S5</text> <text x="60" y="410" text-anchor="middle" fill="#aaa">MEM-LD</text> <!-- State S6: MEM store --> <circle cx="200" cy="400" r="32" fill="none" stroke="#8f8" stroke-width="1.5"/> <text x="200" y="396" text-anchor="middle" fill="#8f8">S6</text> <text x="200" y="410" text-anchor="middle" fill="#aaa">MEM-ST</text> <!-- State S7: WB R-type --> <circle cx="330" cy="400" r="32" fill="none" stroke="#8f8" stroke-width="1.5"/> <text x="330" y="396" text-anchor="middle" fill="#8f8">S7</text> <text x="330" y="410" text-anchor="middle" fill="#aaa">WB-R</text> <!-- State S8: WB load --> <circle cx="60" cy="460" r="32" fill="none" stroke="#8f8" stroke-width="1.5"/> <text x="60" y="456" text-anchor="middle" fill="#8f8">S8</text> <text x="60" y="470" text-anchor="middle" fill="#aaa">WB-LD</text> <!-- Arrows S0 -> S1 --> <line x1="330" y1="82" x2="330" y2="128" stroke="#ccc" stroke-width="1.2" marker-end="url(#arrow)"/> <!-- S1 -> S2 (lw/sw) --> <line x1="305" y1="183" x2="155" y2="258" stroke="#ccc" stroke-width="1.2" marker-end="url(#arrow)"/> <text x="210" y="218" fill="#aaa" font-size="10">lw/sw</text> <!-- S1 -> S3 (R-type) --> <line x1="330" y1="192" x2="330" y2="248" stroke="#ccc" stroke-width="1.2" marker-end="url(#arrow)"/> <text x="336" y="225" fill="#aaa" font-size="10">R-type</text> <!-- S1 -> S4 (beq) --> <line x1="355" y1="183" x2="465" y2="258" stroke="#ccc" stroke-width="1.2" marker-end="url(#arrow)"/> <text x="435" y="218" fill="#aaa" font-size="10">beq</text> <!-- S2 -> S5 (lw) --> <line x1="108" y1="308" x2="78" y2="368" stroke="#ccc" stroke-width="1.2" marker-end="url(#arrow)"/> <text x="58" y="342" fill="#aaa" font-size="10">lw</text> <!-- S2 -> S6 (sw) --> <line x1="152" y1="308" x2="182" y2="368" stroke="#ccc" stroke-width="1.2" marker-end="url(#arrow)"/> <text x="180" y="342" fill="#aaa" font-size="10">sw</text> <!-- S3 -> S7 --> <line x1="330" y1="312" x2="330" y2="368" stroke="#ccc" stroke-width="1.2" marker-end="url(#arrow)"/> <!-- S5 -> S8 --> <line x1="60" y1="432" x2="60" y2="428" stroke="#ccc" stroke-width="1.2" marker-end="url(#arrow)"/> <!-- S4, S6, S7, S8 -> S0 (loop back, implied) -->

<text x="490" y="320" text-anchor="middle" fill="#aaa" font-size="10">→ done</text> <text x="200" y="438" text-anchor="middle" fill="#aaa" font-size="10">→ done</text> <text x="330" y="438" text-anchor="middle" fill="#aaa" font-size="10">→ done</text> <text x="60" y="500" text-anchor="middle" fill="#aaa" font-size="10">→ done</text>

<!-- Arrow marker def --> <defs> <marker id="arrow" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#ccc"/> </marker> </defs> </svg>

Each state transition is unconditional (between IF and ID) or conditioned on the opcode (from ID onward). The FSM loops back to S0 after each instruction completes.

---

### Control Signals per State

The FSM outputs a set of control signals in each state. Below is a representative table for the MIPS subset:

|State|MemRead|MemWrite|IRWrite|RegWrite|ALUSrcA|ALUSrcB|PCWrite|PCSource|
|---|---|---|---|---|---|---|---|---|
|S0 (IF)|1|0|1|0|0 (PC)|01 (4)|1|00 (ALU)|
|S1 (ID)|0|0|0|0|0 (PC)|11 (SL2)|0|—|
|S2 (EX-Mem)|0|0|0|0|1 (A)|10 (SE)|0|—|
|S3 (EX-R)|0|0|0|0|1 (A)|00 (B)|0|—|
|S4 (Branch)|0|0|0|0|1 (A)|00 (B)|Branch|01 (ALUOut)|
|S5 (MEM-LD)|1|0|0|0|—|—|0|—|
|S6 (MEM-ST)|0|1|0|0|—|—|0|—|
|S7 (WB-R)|0|0|0|1|—|—|0|—|
|S8 (WB-LD)|0|0|0|1|—|—|0|—|

ALUSrcA: 0 = PC, 1 = register A ALUSrcB: 00 = B, 01 = constant 4, 10 = sign-extended immediate, 11 = sign-extended shifted

---

### Hardwired vs. Microprogrammed Control

The FSM control unit can be implemented in two ways:

#### Hardwired Control

The FSM is implemented directly as combinational logic and flip-flops. State transitions and output signals are encoded as Boolean expressions.

- Faster — no memory lookup overhead
- Harder to modify — changing instruction behavior requires redesigning logic
- Appropriate for RISC-style ISAs with small, regular instruction sets

#### Microprogrammed Control

Each FSM state corresponds to a **microinstruction** stored in a **control ROM**. A microprogram sequencer steps through microinstructions, each specifying the control word for one cycle.

```
Microinstruction format:
[ ALUSrcA | ALUSrcB | ALUOp | MemRead | MemWrite | IRWrite | RegWrite | PCWrite | PCSource | Next-State ]
```

- Easier to modify — add or change instructions by updating ROM contents
- Slower — ROM access adds latency
- Appropriate for CISC ISAs where many complex, variable-length instructions must be decoded (e.g., x86 microcode)

---

### Multiplexer Requirements

The sharing of functional units requires multiplexers at every input where more than one source feeds a unit:

|Mux|Inputs|Selects|
|---|---|---|
|**MuxA** (ALU input A)|PC, register A|ALUSrcA|
|**MuxB** (ALU input B)|B, constant 4, sign-extended imm, SL2 imm|ALUSrcB (2-bit)|
|**MuxPC** (PC source)|ALU output, ALUOut register, jump target|PCSource (2-bit)|
|**MuxWB** (write-back data)|ALUOut, MDR|MemToReg|
|**MuxDst** (write register)|rt field, rd field|RegDst|

---

### Performance Analysis

Let the single-cycle clock period be T_sc, which is bounded by the load instruction path:

```
T_sc ≈ t_mem + t_rf_read + t_ALU + t_mem + t_rf_write
```

The multi-cycle clock period T_mc is bounded by the slowest single step — memory access:

```
T_mc ≈ t_mem
```

In practice T_sc ≈ 4–5 × T_mc for a simple MIPS implementation.

**Execution time comparison:**

```
Time_sc = N × 1 × T_sc         = N × T_sc
Time_mc = N × CPI_avg × T_mc   ≈ N × 4.05 × T_mc

If T_sc = 4.5 × T_mc:
  Time_sc = N × 4.5 × T_mc
  Time_mc = N × 4.05 × T_mc    ← multi-cycle is faster here
```

The multi-cycle design is faster only when the clock period reduction outweighs the CPI increase. For deeper pipelines and more complex ISAs, pipelining strictly dominates multi-cycle.

---

### Limitations and Transition to Pipelining

The multi-cycle datapath has one fundamental inefficiency: **functional units sit idle during the cycles they are not needed**. The ALU is unused in the memory access step; memory is unused during the execute step.

Pipelining resolves this by overlapping the execution of multiple instructions — while instruction _i_ is in the MEM stage, instruction _i+1_ is in EX, _i+2_ is in ID, and _i+3_ is in IF. The multi-cycle stage decomposition maps directly onto pipeline stages, making multi-cycle design a conceptually necessary precursor to understanding pipelining.

The register barriers between stages (IR, MDR, A, B, ALUOut) evolve directly into **pipeline registers** (IF/ID, ID/EX, EX/MEM, MEM/WB) in the pipelined datapath.

---

**Key Points**

- The multi-cycle datapath replaces duplicated functional units with shared units controlled by an FSM sequencer.
- Five intermediate registers (IR, MDR, A, B, ALUOut) preserve inter-cycle values across shared units.
- Instruction fetch and decode (steps 1–2) are identical for all instructions; divergence begins at the execute stage.
- Branch and jump instructions complete in 3 cycles; R-type and store in 4; load in 5.
- The branch target is computed speculatively in the decode step at no additional cost, since the ALU would otherwise be idle.
- Hardwired control is faster; microprogrammed control is more modifiable — the choice reflects ISA complexity.
- Average CPI of ~4 is offset by a clock period 4–5× shorter than single-cycle; overall speedup is design- and workload-dependent.

**Conclusion** The multi-cycle datapath is a structurally complete execution model that introduces the concepts of staged decomposition, register barriers between stages, shared resource scheduling, and FSM-based sequenced control. These concepts are the direct foundation of pipelined processor design. Understanding which resources are active per cycle, and why intermediate registers are necessary, establishes the mental model required for analyzing pipeline registers, forwarding paths, and hazard conditions in subsequent study.

**Next Steps**

- Pipelining — the multi-cycle stage decomposition maps directly onto pipeline stages; pipeline registers are the natural extension of IR, MDR, A, B, ALUOut
- Control Unit Design (hardwired vs. microprogrammed) — deeper treatment of FSM encoding and microcode sequencing
- Hazard Detection and Resolution — data and control hazards are a direct consequence of overlapping multi-cycle-style stages

---

