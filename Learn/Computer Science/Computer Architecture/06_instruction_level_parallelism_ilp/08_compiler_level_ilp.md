## Compiler-Level ILP


Instruction-Level Parallelism extracted at compile time is the set of techniques by which a compiler statically reorganizes, replicates, or restructures code so that a processor can issue multiple independent operations per cycle — without requiring out-of-order hardware. These techniques are the primary mechanism for exploiting ILP on **in-order** processors (embedded cores, DSPs, VLIW machines) and remain relevant on out-of-order cores as a complement to dynamic scheduling.

---

### Why Static ILP Extraction Matters

An out-of-order processor discovers parallelism dynamically by examining an instruction window at runtime. A compiler has a wider view — the entire loop body, multiple basic blocks, and inter-procedural information — but operates without knowledge of runtime values. The two approaches are complementary:

|Property|Dynamic (OOO Hardware)|Static (Compiler)|
|---|---|---|
|Scope|Instruction window (tens–hundreds of instructions)|Entire procedure / loop nest|
|Runtime value knowledge|Yes|No|
|Hardware cost|High (ROB, RS, rename)|None|
|Works on in-order hardware|No|Yes|
|Interacts with memory aliasing|Conservative (at runtime)|Alias analysis (conservative)|
|Branch handling|Speculative execution|Predication, unrolling|

---

### Foundational Concept: Dependence Analysis

Before any transformation, the compiler must determine which instructions depend on which. There are three types relevant to ILP:

**RAW (True dependence):** Instruction B reads a value written by A. Cannot be violated — must be preserved or latency hidden.

**WAR (Anti-dependence):** B writes a register/location that A reads. An artifact of name reuse, not a true data dependence. Eliminable by **renaming**.

**WAW (Output dependence):** Both A and B write the same register/location. Also an artifact of name reuse. Eliminable by renaming.

Only RAW dependences constrain execution order. WAR and WAW are broken by **register renaming** during scheduling — the compiler allocates fresh virtual registers to remove the false dependences before applying ILP transformations.

---

### Loop Dependence: Distance and Direction Vectors

For loop transformations, the compiler characterizes dependences with a **distance vector** _d_ and **direction vector** _(< , =, >)_ per loop dimension.

For a loop with induction variable _i_:

```
A[i] = ...        ; write at iteration i
... = A[i - 1]    ; read at iteration i, referencing write from iteration i-1
```

This is a **loop-carried dependence** with distance 1 (the read at iteration _i_ depends on the write from iteration _i−1_). It constrains how many iterations can be overlapped.

A **loop-independent dependence** exists entirely within one iteration and does not constrain inter-iteration parallelism.

---

### Technique 1: Loop Unrolling

Loop unrolling replicates the loop body _k_ times, reducing the loop overhead (branch, induction variable update) and — more importantly — **exposing independent operations across what were formerly iteration boundaries**, giving the scheduler a larger window of instructions with which to hide latency.

#### Basic Unrolling

**Original loop (factor 1):**

```asm
loop:
    LW   R1, 0(R2)       ; load A[i]
    FADD F0, F1, R1      ; A[i] + scalar   (3-cycle latency)
    SW   F0, 0(R3)       ; store result
    ADDI R2, R2, 4       ; advance pointer
    ADDI R3, R3, 4
    BNE  R2, R4, loop    ; branch
```

Assuming FADD has a 3-cycle latency and the processor is in-order, cycles 2–3 after FADD are stalls — the SW must wait for F0. Effective IPC is poor.

**Unrolled ×4 (before scheduling):**

```asm
loop:
    LW   R1,  0(R2)
    FADD F0,  F1, R1
    SW   F0,  0(R3)

    LW   R5,  4(R2)
    FADD F2,  F1, R5
    SW   F2,  4(R3)

    LW   R6,  8(R2)
    FADD F3,  F1, R6
    SW   F3,  8(R3)

    LW   R7,  12(R2)
    FADD F4,  F1, R7
    SW   F4,  12(R3)

    ADDI R2, R2, 16
    ADDI R3, R3, 16
    BNE  R2, R4, loop
```

The four FADD operations are now **independent of each other** (no RAW between them). The scheduler can now interleave the independent chains to fill stall slots.

**After scheduling (latency hidden):**

```asm
loop:
    LW   R1,  0(R2)
    LW   R5,  4(R2)
    LW   R6,  8(R2)
    LW   R7,  12(R2)      ; all 4 loads issued; FADD latency hides here
    FADD F0,  F1, R1
    FADD F2,  F1, R5
    FADD F3,  F1, R6
    FADD F4,  F1, R7
    SW   F0,  0(R3)
    SW   F2,  4(R3)
    SW   F3,  8(R3)
    SW   F4,  12(R3)
    ADDI R2, R2, 16
    ADDI R3, R3, 16
    BNE  R2, R4, loop
```

Branch overhead is reduced from 6 instructions per iteration to 17 instructions per 4 iterations (≈4.25 instructions overhead per element vs. 6). More critically, stall cycles are eliminated — the four independent FADD chains overlap each other's latency.

#### Unrolling Trade-offs

|Benefit|Cost|
|---|---|
|Exposes independent operations|Increased code size (I-cache pressure)|
|Reduces branch / loop overhead|More registers required|
|Enables better scheduling window|Worse performance if loop count not divisible by _k_ (requires **epilogue** code)|
|Hides memory and FP latency|Register pressure may spill → defeats purpose|

The compiler must generate a **prologue/epilogue** or **peeled iterations** to handle the case where the trip count is not a multiple of the unroll factor _k_.

---

### Unrolling with Loop-Carried Dependences

When a loop carries a true dependence of distance 1, unrolling alone does not remove the dependence — but it can still improve throughput by **chaining** independent copies.

```c
// Recurrence: s depends on previous iteration
for (i = 0; i < N; i++)
    s = s * A[i];
```

The multiply has a recurrence with distance 1 — each iteration's result feeds the next. Unrolling ×2 produces:

```c
for (i = 0; i < N; i += 2) {
    s = s * A[i];
    s = s * A[i+1];    // still depends on previous line
}
```

This does not expose parallelism. However, if the operation is associative (floating-point associativity must be explicitly enabled — it is not the default), the compiler can use **tree reduction**:

```c
s0 = 1.0; s1 = 1.0;
for (i = 0; i < N; i += 2) {
    s0 = s0 * A[i];
    s1 = s1 * A[i+1];   // s0 and s1 are independent
}
s = s0 * s1;
```

Now two independent multiply chains proceed in parallel, halving the recurrence latency. GCC `-ffast-math` and Clang `-ffast-math` permit this transformation.

---

### Technique 2: Software Pipelining

Software pipelining (also called **symbolic loop unrolling** or **modulo scheduling**) is a fundamentally different approach. Rather than replicating the loop body and scheduling within the replicated block, it **overlaps the execution of successive iterations** — issuing operations from iteration _i+1_ while iteration _i_ is still in flight through the pipeline.

The result is a **kernel** (steady-state loop body) that contains operations from multiple iterations simultaneously, achieving a throughput that loop unrolling approximates only with large unroll factors.

#### Conceptual Illustration

<svg viewBox="0 0 620 310" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <defs> <marker id="sp-arr" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#94a3b8"/> </marker> </defs> <!-- Title -->

<text x="310" y="20" text-anchor="middle" font-size="13" font-weight="bold" fill="#e2e8f0">Software Pipelining — Overlapping Iterations</text>

<!-- Column headers -->

<text x="80" y="42" text-anchor="middle" fill="#64748b">Cycle</text> <text x="160" y="42" text-anchor="middle" fill="#64748b">Slot A</text> <text x="270" y="42" text-anchor="middle" fill="#64748b">Slot B</text> <text x="380" y="42" text-anchor="middle" fill="#64748b">Slot C</text> <text x="490" y="42" text-anchor="middle" fill="#64748b">Slot D</text>

<!-- Row data: cycle, slot A, slot B, slot C --> <!-- Prologue --> <rect x="20" y="50" width="580" height="18" rx="2" fill="#1a1a2e" opacity="0.5"/> <text x="80" y="63" text-anchor="middle" fill="#64748b">1</text> <text x="160" y="63" text-anchor="middle" fill="#93c5fd">LW i=0</text> <rect x="20" y="68" width="580" height="18" rx="2" fill="#1a1a2e" opacity="0.3"/> <text x="80" y="81" text-anchor="middle" fill="#64748b">2</text> <text x="160" y="81" text-anchor="middle" fill="#93c5fd">LW i=1</text> <rect x="20" y="86" width="580" height="18" rx="2" fill="#1a1a2e" opacity="0.5"/> <text x="80" y="99" text-anchor="middle" fill="#64748b">3</text> <text x="160" y="99" text-anchor="middle" fill="#93c5fd">LW i=2</text> <text x="270" y="99" text-anchor="middle" fill="#86efac">ADD i=0</text> <!-- Prologue label -->

<text x="580" y="75" fill="#475569" font-size="10">prologue</text> <line x1="570" y1="50" x2="570" y2="104" stroke="#475569" stroke-width="1"/>

<!-- Kernel --> <rect x="20" y="108" width="580" height="18" rx="2" fill="#0f2027" stroke="#334155"/> <text x="80" y="121" text-anchor="middle" fill="#64748b">4</text> <text x="160" y="121" text-anchor="middle" fill="#93c5fd">LW i=3</text> <text x="270" y="121" text-anchor="middle" fill="#86efac">ADD i=1</text> <text x="380" y="121" text-anchor="middle" fill="#fde68a">MUL i=0</text> <rect x="20" y="126" width="580" height="18" rx="2" fill="#0f2027" stroke="#334155"/> <text x="80" y="139" text-anchor="middle" fill="#64748b">5</text> <text x="160" y="139" text-anchor="middle" fill="#93c5fd">LW i=4</text> <text x="270" y="139" text-anchor="middle" fill="#86efac">ADD i=2</text> <text x="380" y="139" text-anchor="middle" fill="#fde68a">MUL i=1</text> <text x="490" y="139" text-anchor="middle" fill="#f87171">SW i=0</text> <rect x="20" y="144" width="580" height="18" rx="2" fill="#0f2027" stroke="#334155"/> <text x="80" y="157" text-anchor="middle" fill="#64748b">6</text> <text x="160" y="157" text-anchor="middle" fill="#93c5fd">LW i=5</text> <text x="270" y="157" text-anchor="middle" fill="#86efac">ADD i=3</text> <text x="380" y="157" text-anchor="middle" fill="#fde68a">MUL i=2</text> <text x="490" y="157" text-anchor="middle" fill="#f87171">SW i=1</text> <rect x="20" y="162" width="580" height="18" rx="2" fill="#0f2027" stroke="#334155"/> <text x="80" y="175" text-anchor="middle" fill="#64748b">7</text> <text x="160" y="175" text-anchor="middle" fill="#93c5fd">LW i=6</text> <text x="270" y="175" text-anchor="middle" fill="#86efac">ADD i=4</text> <text x="380" y="175" text-anchor="middle" fill="#fde68a">MUL i=3</text> <text x="490" y="175" text-anchor="middle" fill="#f87171">SW i=2</text> <!-- Kernel label -->

<text x="580" y="150" fill="#3b82f6" font-size="10">kernel</text> <line x1="570" y1="108" x2="570" y2="180" stroke="#3b82f6" stroke-width="1"/>

<!-- Epilogue --> <rect x="20" y="184" width="580" height="18" rx="2" fill="#1a1a2e" opacity="0.5"/> <text x="80" y="197" text-anchor="middle" fill="#64748b">N</text> <text x="270" y="197" text-anchor="middle" fill="#86efac">ADD i=N-1</text> <text x="380" y="197" text-anchor="middle" fill="#fde68a">MUL i=N-2</text> <text x="490" y="197" text-anchor="middle" fill="#f87171">SW i=N-3</text> <rect x="20" y="202" width="580" height="18" rx="2" fill="#1a1a2e" opacity="0.3"/> <text x="80" y="215" text-anchor="middle" fill="#64748b">N+1</text> <text x="380" y="215" text-anchor="middle" fill="#fde68a">MUL i=N-1</text> <text x="490" y="215" text-anchor="middle" fill="#f87171">SW i=N-2</text> <rect x="20" y="220" width="580" height="18" rx="2" fill="#1a1a2e" opacity="0.5"/> <text x="80" y="233" text-anchor="middle" fill="#64748b">N+2</text> <text x="490" y="233" text-anchor="middle" fill="#f87171">SW i=N-1</text> <!-- Epilogue label -->

<text x="580" y="215" fill="#475569" font-size="10">epilogue</text> <line x1="570" y1="184" x2="570" y2="238" stroke="#475569" stroke-width="1"/>

<!-- Legend --> <rect x="30" y="260" width="12" height="12" fill="#93c5fd" opacity="0.7"/> <text x="46" y="271" fill="#93c5fd">Load</text> <rect x="110" y="260" width="12" height="12" fill="#86efac" opacity="0.7"/> <text x="126" y="271" fill="#86efac">Add</text> <rect x="190" y="260" width="12" height="12" fill="#fde68a" opacity="0.7"/> <text x="206" y="271" fill="#fde68a">Multiply</text> <rect x="290" y="260" width="12" height="12" fill="#f87171" opacity="0.7"/> <text x="306" y="271" fill="#f87171">Store</text> <text x="30" y="295" fill="#64748b" font-size="10">Each cycle, the kernel issues one operation from four different iterations simultaneously.</text> </svg>

In the steady-state kernel, every cycle issues operations from four different iterations. The processor sees a fully occupied issue slot in each cycle — no stalls despite multi-cycle latencies — because the latency of one iteration's LW is filled by another iteration's ADD, MUL, and SW.

---

### Modulo Scheduling

Modulo scheduling is the standard algorithm for computing a software-pipelined schedule. It finds the minimum **Initiation Interval (II)** — the number of cycles between the start of successive iterations in the kernel.

#### Initiation Interval Bounds

II is bounded from below by two independent constraints:

**Resource bound (ResMII):**

$$\text{ResMII} = \max_r \left\lceil \frac{\text{uses}(r)}{\text{capacity}(r)} \right\rceil$$

where _uses(r)_ is the number of loop-body operations using resource _r_ and _capacity(r)_ is how many operations resource _r_ can accept per cycle.

**Recurrence bound (RecMII):**

$$\text{RecMII} = \max_c \left\lceil \frac{\sum_{e \in c} \text{latency}(e)}{\sum_{e \in c} \text{distance}(e)} \right\rceil$$

taken over all **recurrence cycles** _c_ in the dependence graph. A recurrence cycle is a cycle of true dependences that form a loop in the dependence graph (e.g., `s = s + A[i]`).

The theoretical minimum is:

$$\text{MII} = \max(\text{ResMII},\ \text{RecMII})$$

The compiler attempts to find a valid schedule with II = MII, incrementing II if no valid schedule exists.

**Example:**

A loop body with: 1× FMUL (latency 4), 1× FADD (latency 3), 1× LW (latency 2), 1× SW (latency 1), on a machine with 1 FP unit and 1 memory port:

$$\text{ResMII}_\text{FP} = \lceil 2/1 \rceil = 2 \text{ cycles}$$ $$\text{ResMII}_\text{mem} = \lceil 2/1 \rceil = 2 \text{ cycles}$$ $$\text{MII} \geq 2$$

If there is a recurrence through FADD with total latency 3 and distance 1:

$$\text{RecMII} = \lceil 3/1 \rceil = 3$$ $$\text{MII} = \max(2, 3) = 3$$

The compiler targets II = 3: one new iteration begins every 3 cycles in steady state.

---

### Kernel Construction and Modulo Constraint

In a modulo schedule with II = _k_, each operation is assigned a **schedule slot** _s_ such that:

$$s \bmod k = \text{stage}$$

Operations from different iterations that map to the same slot modulo _k_ must use **different registers** — because they execute simultaneously in different stages of the software pipeline. The compiler allocates a **rotating register file** or generates _k_ copies of each live variable (one per stage of overlap), then maps them to physical registers.

This register expansion is called **kernel register allocation** and is a significant constraint: if the number of live values exceeds the physical register count, the schedule is infeasible at that II and the compiler must increase II or reduce unrolling.

---

### Technique 3: Trace Scheduling

Trace scheduling extends ILP extraction across **basic block boundaries** — enabling the scheduler to move instructions across conditional branches.

A **trace** is the most frequently executed path through a region of code, selected by profiling or heuristic (typically the path where all branches are taken or fall-through). The compiler schedules the trace as a single extended basic block, then inserts **compensation code** on the off-trace paths to restore correctness when a branch exits the trace.

<svg viewBox="0 0 500 280" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <text x="250" y="20" text-anchor="middle" font-size="13" font-weight="bold" fill="#e2e8f0">Trace Scheduling</text> <!-- BB0 --> <rect x="180" y="35" width="140" height="40" rx="4" fill="#1e293b" stroke="#3b82f6"/> <text x="250" y="60" text-anchor="middle" fill="#93c5fd">BB0 (entry)</text> <!-- Branch arrow main trace --> <line x1="250" y1="75" x2="250" y2="100" stroke="#34d399" stroke-width="2" marker-end="url(#sp-arr)"/> <text x="262" y="92" fill="#34d399" font-size="10">hot path</text> <!-- Branch arrow off-trace --> <line x1="320" y1="55" x2="420" y2="55" stroke="#64748b" stroke-width="1.5" stroke-dasharray="4,2" marker-end="url(#sp-arr)"/> <text x="370" y="48" fill="#64748b" font-size="10">cold branch</text> <!-- Off-trace BB --> <rect x="380" y="65" width="110" height="35" rx="4" fill="#1e293b" stroke="#475569" stroke-dasharray="3,2"/> <text x="435" y="87" text-anchor="middle" fill="#64748b">off-trace BB</text> <text x="435" y="100" text-anchor="middle" fill="#475569" font-size="10">+ compensation</text> <!-- BB1 (main trace) --> <rect x="180" y="100" width="140" height="40" rx="4" fill="#0f2027" stroke="#3b82f6"/> <text x="250" y="125" text-anchor="middle" fill="#93c5fd">BB1 (trace)</text> <line x1="250" y1="140" x2="250" y2="165" stroke="#34d399" stroke-width="2" marker-end="url(#sp-arr)"/> <!-- Branch off-trace 2 --> <line x1="320" y1="120" x2="420" y2="120" stroke="#64748b" stroke-width="1.5" stroke-dasharray="4,2" marker-end="url(#sp-arr)"/> <rect x="380" y="130" width="110" height="35" rx="4" fill="#1e293b" stroke="#475569" stroke-dasharray="3,2"/> <text x="435" y="152" text-anchor="middle" fill="#64748b">off-trace BB</text> <text x="435" y="165" text-anchor="middle" fill="#475569" font-size="10">+ compensation</text> <!-- BB2 --> <rect x="180" y="165" width="140" height="40" rx="4" fill="#0f2027" stroke="#3b82f6"/> <text x="250" y="190" text-anchor="middle" fill="#93c5fd">BB2 (trace)</text> <line x1="250" y1="205" x2="250" y2="230" stroke="#34d399" stroke-width="2" marker-end="url(#sp-arr)"/> <!-- Scheduled trace box --> <rect x="50" y="100" width="110" height="105" rx="4" fill="#1e3a5f" stroke="#3b82f6" stroke-dasharray="4,2"/> <text x="105" y="118" text-anchor="middle" fill="#93c5fd" font-size="10">scheduled</text> <text x="105" y="130" text-anchor="middle" fill="#93c5fd" font-size="10">trace block</text> <text x="105" y="148" text-anchor="middle" fill="#64748b" font-size="10">BB0 + BB1 + BB2</text> <text x="105" y="162" text-anchor="middle" fill="#64748b" font-size="10">treated as one</text> <text x="105" y="176" text-anchor="middle" fill="#64748b" font-size="10">scheduling region</text> <text x="105" y="195" text-anchor="middle" fill="#86efac" font-size="10">ops moved across</text> <text x="105" y="207" text-anchor="middle" fill="#86efac" font-size="10">branch boundaries</text> <line x1="160" y1="152" x2="180" y2="152" stroke="#3b82f6" stroke-width="1.5" stroke-dasharray="3,2" marker-end="url(#sp-arr)"/> <!-- Exit --> <rect x="180" y="230" width="140" height="35" rx="4" fill="#1e293b" stroke="#475569"/> <text x="250" y="252" text-anchor="middle" fill="#e2e8f0">exit / next block</text> </svg>

Trace scheduling is complex to implement correctly because compensation code on off-trace paths can grow large, and the profiling data must be representative. It is the scheduling foundation used in **Itanium (IA-64)** compilation and in aggressive VLIW compilers.

---

### Technique 4: Predication

Predicated execution eliminates branches by converting them into **conditional operations** — both paths are computed, but only the result of the correct path is committed. This widens the scheduling region without requiring compensation code.

```asm
; Original (branch-based):
    CMP  R1, R2
    BNE  else_branch
    ADD  R3, R4, R5      ; if-path
    B    end
else_branch:
    SUB  R3, R4, R5      ; else-path
end:

; Predicated (ARM-style):
    CMP  R1, R2
    ADDEQ R3, R4, R5     ; executes only if EQ
    SUBNE R3, R4, R5     ; executes only if NE
```

Both ADD and SUB are issued; the processor discards the wrong result. The branch is eliminated entirely, making both operations visible to the scheduler in the same basic block. ARM (Thumb-2 and AArch32 IT blocks), IA-64 (full predication), and AVX-512 (mask registers) all support this.

Predication is most beneficial when branches are hard to predict and the two paths are short. For long paths, the wasted execution of the wrong path exceeds the branch-misprediction penalty.

---

### Technique 5: Loop Transformations for Memory Hierarchy

These are compiler transformations that restructure loop nests primarily for **cache behavior**, but they also affect ILP by changing the dependence structure.

#### Loop Interchange

Swaps the order of nested loop indices to achieve **stride-1 memory access** in the innermost loop, maximizing spatial locality.

```c
// Poor locality (column-major access of row-major array):
for (j = 0; j < N; j++)
    for (i = 0; i < N; i++)
        A[i][j] = B[i][j] + 1;   // stride N access

// After interchange (row-major, stride-1):
for (i = 0; i < N; i++)
    for (j = 0; j < N; j++)
        A[i][j] = B[i][j] + 1;   // stride 1 access
```

Legal only when no dependence prevents it (distance vector must not have a `<` component in the interchanged dimension that would be violated).

#### Loop Tiling (Blocking)

Divides an iteration space into **tiles** that fit in cache, improving temporal locality for operations that reuse data across iterations.

```c
// Untiled matrix multiply (poor L1 reuse):
for (i = 0; i < N; i++)
    for (j = 0; j < N; j++)
        for (k = 0; k < N; k++)
            C[i][j] += A[i][k] * B[k][j];

// Tiled (tile size T chosen to fit three T×T submatrices in L1):
for (ii = 0; ii < N; ii += T)
  for (jj = 0; jj < N; jj += T)
    for (kk = 0; kk < N; kk += T)
      for (i = ii; i < min(ii+T, N); i++)
        for (j = jj; j < min(jj+T, N); j++)
          for (k = kk; k < min(kk+T, N); k++)
            C[i][j] += A[i][k] * B[k][j];
```

Tiling does not directly create ILP but prevents cache misses from serializing the computation — a stalled load is a hard pipeline bubble that no amount of ILP extraction can fill.

#### Loop Fusion and Fission

**Fusion** combines two loops over the same range into one, reducing loop overhead and improving producer-consumer locality:

```c
// Before fusion:
for (i = 0; i < N; i++) A[i] = B[i] + 1;
for (i = 0; i < N; i++) C[i] = A[i] * 2;

// After fusion (A[i] stays in register between the two ops):
for (i = 0; i < N; i++) {
    A[i] = B[i] + 1;
    C[i] = A[i] * 2;
}
```

**Fission** (distribution) splits a loop body into multiple loops, useful when the combined body has too many live values for the register file (reducing register pressure at the cost of loop overhead).

---

### Interaction with VLIW Architectures

VLIW (Very Long Instruction Word) processors expose multiple functional units in each instruction word and rely **entirely** on the compiler to fill them. There is no dynamic scheduling hardware, no out-of-order execution, and no interlocking — the compiler guarantees hazard-free issue slots.

```
VLIW instruction word (example — 4 slots):
┌──────────────┬──────────────┬──────────────┬──────────────┐
│  INT slot    │  FP slot     │  MEM slot    │  BR slot     │
│  ADD R1,R2   │  FMUL F0,F1  │  LW R3,0(R4) │  (nop)       │
└──────────────┴──────────────┴──────────────┴──────────────┘
```

All compiler-level ILP techniques are critical for VLIW — especially modulo scheduling, which was co-developed specifically for VLIW DSP compilers (the Trace/Lam work at Yale, and the Charlesworth work for the FPS-164). Modern descendants include TI C6000, Qualcomm Hexagon, and Intel Itanium (though IA-64 added register rotation hardware to assist software pipelining).

---

### Register Pressure: The Primary Constraint

All of these techniques increase the number of simultaneously live values, which increases **register pressure**. When live values exceed physical registers, the compiler must spill to the stack — a memory operation that can negate the latency-hiding benefit.

The tension between ILP extraction and register pressure is the central constraint in compiler scheduling:

|Transformation|ILP gain|Register pressure impact|
|---|---|---|
|Loop unrolling ×k|Exposes k-way parallelism|k× more live values|
|Software pipelining|Near-optimal throughput|High — all in-flight iterations are live simultaneously|
|Trace scheduling|Crosses branch boundaries|Moderate — compensation code may add copies|
|Predication|Eliminates branches|Low — replaces branch with parallel ops|
|Loop tiling|Improves cache behavior|Increases nesting depth live values|

The compiler must solve a joint optimization: maximize ILP while keeping live values within the register budget. This is NP-hard in general; production compilers use heuristics (list scheduling with priority functions, iterative modulo scheduling with II adjustment, integrated pressure-aware scheduling in LLVM's MachineScheduler).

---

**Conclusion**

Compiler-level ILP extraction is static parallelism discovery: the compiler restructures and replicates code to present the processor with independent operations, hiding latency and filling issue slots without dynamic hardware support. Loop unrolling achieves this by replication; software pipelining achieves it by overlapping iterations at the cost of prologue/epilogue complexity and register pressure; trace scheduling and predication extend the scheduling scope across branches. These techniques are indispensable on in-order and VLIW architectures, and remain a productive complement to out-of-order execution on superscalar processors — reducing the burden on the instruction window and reservation stations.

**Next Steps**

Proceed to **Memory Hierarchy** to examine how cache behavior interacts with ILP — specifically how memory latency, prefetching, and cache miss penalties set a floor on the throughput gains achievable by any scheduling strategy.

---

