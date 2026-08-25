## Branch Prediction


Branch prediction is the mechanism by which a processor speculatively determines the outcome of a branch instruction before it is resolved, allowing instruction fetch and execution to continue without stalling. In a deep pipeline, an unresolved branch creates a bubble for every stage between fetch and the point at which the branch outcome is known — on a modern out-of-order processor, this penalty can exceed 15–20 cycles. Accurate prediction eliminates this penalty for the common case.

---

### The Branch Problem

In a classic 5-stage RISC pipeline (IF → ID → EX → MEM → WB), a conditional branch resolves at the end of the EX stage. By that time, two instructions have already been fetched:

```
Cycle:     1      2      3      4      5      6
BEQ:      [IF]  [ID]   [EX]  [MEM]  [WB]
+1:              [IF]  [ID]  ← must squash if branch taken
+2:                    [IF]  ← must squash if branch taken
```

The **branch penalty** is 2 cycles if the branch is taken and the fetched instructions must be squashed. For a program where 20% of instructions are branches and 60% of those are taken, the naive penalty is:

$$\text{CPI}_\text{branch} = 1 + 0.20 \times 0.60 \times 2 = 1.24$$

A predictor that achieves 95% accuracy reduces this dramatically. Branch misprediction is the primary source of control hazards in high-performance pipelines.

---

### Branch Types

Not all branches are equivalent. A complete prediction scheme must handle all types:

|Type|Example (x86 / RISC-V)|Target Known At|Outcome Known At|
|---|---|---|---|
|Conditional direct|`BEQ`, `JNE`|Decode (PC-relative)|Execute|
|Unconditional direct|`J`, `JAL`|Decode|Always taken|
|Indirect|`JR $ra`, `JALR`|Execute (register value)|Always taken|
|Call|`CALL`, `JAL ra, offset`|Decode|Always taken|
|Return|`RET`, `JR $ra`|Execute (stack value)|Always taken|

Indirect branches and returns require additional mechanisms (indirect branch predictors, return address stacks) beyond the basic prediction schemes.

---

### Static Prediction

Static prediction makes a fixed prediction that does not change based on runtime behavior. The prediction is encoded into the ISA, the compiler, or a simple hardware rule.

#### Fixed Prediction

The simplest static scheme: always predict **not taken**. The processor continues fetching sequentially. If the branch is taken, the fetched instructions are squashed.

Alternatively: always predict **taken**. The processor fetches from the predicted target, requiring knowledge of the target address at fetch time (only feasible for PC-relative branches whose offset is encoded in the instruction).

#### BTFNT — Backward Taken, Forward Not Taken

The most effective pure static scheme exploits a structural property of code:

- **Backward branches** (target address < PC) are almost always **loop back-edges** → predict **taken**
- **Forward branches** (target address > PC) are almost always **if-then** exits → predict **not taken**

```
loop:
  ...
  BNE  $t0, $zero, loop   ← backward, predict TAKEN (correct ~90% of iterations)

  BEQ  $a0, $a1, exit     ← forward, predict NOT TAKEN (often correct)
  ...
exit:
```

BTFNT achieves roughly 65–75% accuracy across typical workloads without any runtime state.

#### Compiler-Directed Hints

Some ISAs allow the compiler to embed prediction hints in the branch instruction encoding:

- **PA-RISC** and **IA-64 (Itanium)**: explicit taken/not-taken hint bits in the branch opcode
- **x86**: `HINT_NOP` prefix (deprecated); branch hints in early Pentium 4 (`0x2E` = predict not taken, `0x3E` = predict taken)
- **RISC-V**: the C extension encodes a hint: `C.BEQZ`/`C.BNEZ` with negative offset → backward → predict taken

Static prediction is used in simple embedded processors, or as the fallback for branches not yet seen by a dynamic predictor.

---

### Dynamic Prediction

Dynamic prediction uses runtime history to make predictions. The hardware maintains state tables that track how branches have behaved in the past and extrapolates that behavior into the future.

#### 1-Bit Predictor

Each branch is associated with a single bit that records the last outcome (T = taken, N = not taken). The prediction for the next occurrence is simply the last outcome.

```
State:   T → predict Taken
         N → predict Not Taken

Transition: if prediction is wrong → flip the bit
```

**Problem:** For a loop that executes N times and then exits, the 1-bit predictor mispredicts twice per loop invocation — once when the loop is entered (if the predictor is in state N), and once when the loop exits:

```
Iteration:  1   2   3   4   5  EXIT
Actual:     T   T   T   T   T   N
Predict:    N   T   T   T   T   T   ← wrong on entry and exit
```

For loops with large N, the 2/N misprediction rate is acceptable. For short loops, it is catastrophic.

#### 2-Bit Saturating Counter

The canonical improvement: use a 2-bit counter with four states. A single misprediction does not flip the prediction — the counter must mispredict twice in a row before changing its prediction.

```
States:
  00 — Strongly Not Taken  (SNT)
  01 — Weakly Not Taken    (WNT)
  10 — Weakly Taken        (WT)
  11 — Strongly Taken      (ST)

Prediction: MSB == 1 → Taken, MSB == 0 → Not Taken
```

State machine:

<svg viewBox="0 0 660 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="660" height="200" fill="#0d1117"/> <!-- States --> <circle cx="100" cy="100" r="38" fill="#1c2d40" stroke="#ff7b72" stroke-width="2"/> <text x="78" y="97" fill="#ff7b72" font-size="10">Strongly</text> <text x="75" y="110" fill="#ff7b72" font-size="10">Not Taken</text> <text x="90" y="123" fill="#ff7b72" font-size="9">SNT (00)</text> <circle cx="260" cy="100" r="38" fill="#1c2d40" stroke="#e3b341" stroke-width="2"/> <text x="242" y="97" fill="#e3b341" font-size="10">Weakly</text> <text x="237" y="110" fill="#e3b341" font-size="10">Not Taken</text> <text x="248" y="123" fill="#e3b341" font-size="9">WNT (01)</text> <circle cx="400" cy="100" r="38" fill="#1c2d40" stroke="#e3b341" stroke-width="2"/> <text x="385" y="97" fill="#e3b341" font-size="10">Weakly</text> <text x="388" y="110" fill="#e3b341" font-size="10">Taken</text> <text x="392" y="123" fill="#e3b341" font-size="9">WT (10)</text> <circle cx="560" cy="100" r="38" fill="#21362d" stroke="#3fb950" stroke-width="2"/> <text x="540" y="97" fill="#3fb950" font-size="10">Strongly</text> <text x="545" y="110" fill="#3fb950" font-size="10">Taken</text> <text x="548" y="123" fill="#3fb950" font-size="9">ST (11)</text> <!-- SNT → WNT (Taken) --> <line x1="138" y1="90" x2="222" y2="90" stroke="#56d364" stroke-width="1.5" marker-end="url(#arr)"/> <text x="160" y="84" fill="#56d364" font-size="10">T</text> <!-- WNT → SNT (Not Taken) --> <line x1="222" y1="110" x2="138" y2="110" stroke="#ff7b72" stroke-width="1.5" marker-end="url(#arr)"/> <text x="160" y="124" fill="#ff7b72" font-size="10">N</text> <!-- WNT → WT (Taken) --> <line x1="298" y1="90" x2="362" y2="90" stroke="#56d364" stroke-width="1.5" marker-end="url(#arr)"/> <text x="322" y="84" fill="#56d364" font-size="10">T</text> <!-- WT → WNT (Not Taken) --> <line x1="362" y1="110" x2="298" y2="110" stroke="#ff7b72" stroke-width="1.5" marker-end="url(#arr)"/> <text x="322" y="124" fill="#ff7b72" font-size="10">N</text> <!-- WT → ST (Taken) --> <line x1="438" y1="90" x2="522" y2="90" stroke="#56d364" stroke-width="1.5" marker-end="url(#arr)"/> <text x="462" y="84" fill="#56d364" font-size="10">T</text> <!-- ST → WT (Not Taken) --> <line x1="522" y1="110" x2="438" y2="110" stroke="#ff7b72" stroke-width="1.5" marker-end="url(#arr)"/> <text x="462" y="124" fill="#ff7b72" font-size="10">N</text> <!-- SNT self-loop --> <path d="M 68 68 Q 50 30 80 62" fill="none" stroke="#ff7b72" stroke-width="1.5" marker-end="url(#arr)"/> <text x="38" y="42" fill="#ff7b72" font-size="10">N</text> <!-- ST self-loop --> <path d="M 580 68 Q 610 30 592 64" fill="none" stroke="#56d364" stroke-width="1.5" marker-end="url(#arr)"/> <text x="614" y="42" fill="#56d364" font-size="10">T</text> <!-- Prediction labels -->

<text x="60" y="170" fill="#ff7b72" font-size="10">← Predict: Not Taken</text> <text x="440" y="170" fill="#3fb950" font-size="10">Predict: Taken →</text>

<defs> <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#8b949e"/> </marker> </defs> </svg>

For the loop misprediction problem, the 2-bit predictor handles exit gracefully: the counter must be decremented twice before switching prediction, so a single taken-to-not-taken transition (loop exit) only moves from ST → WT, still predicting taken. The next iteration (new loop entry) immediately restores the counter.

---

### Branch Target Buffer (BTB)

The branch direction predictor (taken/not-taken) alone is insufficient — the processor also needs the **target address** before the branch is even decoded, so it can fetch from the correct location.

The **Branch Target Buffer** is a cache keyed on the branch instruction's PC. Each entry stores:

```
Tag (partial PC)  |  Predicted Target Address  |  [Prediction State]
```

On instruction fetch, the current PC is looked up in the BTB simultaneously with the instruction cache:

```
Fetch PC → [BTB lookup]
              ↓
         Hit?  YES → use stored target for next fetch (speculative)
               NO  → fetch sequentially, update BTB when branch resolved
```

A BTB hit on a branch that is predicted taken redirects the fetch unit to the stored target in the same cycle as the fetch itself — zero additional latency.

#### BTB Organization

```
BTB (direct-mapped, 1024 entries):

Index: PC[11:2]  (10 bits, selects BTB row)
Tag:   PC[31:12] (upper bits, verifies the entry belongs to this branch)

Entry:
  [ Valid | Tag | Target[31:0] | 2-bit counter ]
    1 bit   20b    32 bits         2 bits
```

A **BTB miss** means the processor does not know this is a branch yet (or has never seen it), so it fetches sequentially. When the branch is eventually decoded and resolved, its target and outcome are written into the BTB.

#### BTB for Unconditional Branches

Unconditional direct branches (e.g., `J target`, `B offset`) are always taken, and their target is fixed. A BTB entry for such a branch predicts taken always and provides the target — effectively converting a fixed-cost branch into a zero-cost prediction after the first execution.

---

### Branch History Table (BHT) — Two-Level Prediction

A 2-bit saturating counter per branch captures only local behavior — how _this_ branch behaves in isolation. But branch outcomes are often correlated with the outcomes of _other_ branches (global correlation) or with the recent history of the _same_ branch (local correlation).

#### Local History: Per-Branch Shift Registers

Each branch maintains a **Branch History Register (BHR)** — a shift register recording the last N outcomes:

```
BHR for branch X after sequence T, T, N, T:
  BHR = 1101  (MSB = most recent)
```

This BHR indexes into a **Pattern History Table (PHT)** of 2-bit saturating counters. The entry selected by the history pattern gives the prediction:

```
BHR[n-1:0]  →  PHT index  →  2-bit counter  →  Taken/Not Taken
```

This is the **local two-level predictor** (Yeh & Patt, 1991). It captures periodic patterns in individual branches, such as a branch that follows the pattern TTNTTN…

#### Global History: Shared Shift Register

Rather than one BHR per branch, a single **Global History Register (GHR)** tracks the last N outcomes across _all_ branches:

```
GHR (shift register, 12 bits):
  After branches B1=T, B2=N, B3=T:  GHR = ...101
```

The prediction for branch X is obtained by XOR-indexing the PHT with both the branch PC and the GHR:

```
Index = PC[k:0] XOR GHR[n-1:0]  →  PHT entry  →  2-bit counter
```

This is the **gshare predictor** (McFarling, 1993). XOR-hashing reduces aliasing between different branches that share PHT entries. Gshare captures correlations between different branches — for example, an inner `if` whose outcome is determined by an outer `if`.

---

### Tournament Predictor (Hybrid)

No single prediction scheme dominates all workloads. Some branches are highly predictable with local history; others require global history. A **tournament predictor** (also called a **hybrid predictor**) maintains multiple sub-predictors and a **selector** that tracks which sub-predictor has been more accurate for each branch.

The classic design (used in the Alpha 21264):

```
┌─────────────────────┐
│   Local Predictor   │─────┐
│  (per-branch BHR +  │     ├──→ [ Selector (2-bit counter) ] ──→ Final Prediction
│   local PHT)        │     │
└─────────────────────┘  compare
┌─────────────────────┐     │
│  Global Predictor   │─────┘
│  (GHR + global PHT) │
└─────────────────────┘
```

The **selector** is itself a table of 2-bit saturating counters indexed by the branch PC (or history):

- If the global predictor was correct and the local was wrong → increment selector toward "global"
- If the local predictor was correct and the global was wrong → increment selector toward "local"
- If both were correct or both wrong → no change

The selector learns, over time, which sub-predictor is more reliable for each particular branch.

#### Alpha 21264 Tournament Predictor

|Component|Size|Details|
|---|---|---|
|Local history table|1024 entries × 10-bit BHR|Per-branch 10-bit history|
|Local PHT|1024 entries × 3-bit counter|Indexed by local BHR|
|Global PHT|4096 entries × 2-bit counter|Indexed by 12-bit GHR|
|Choice (selector)|4096 entries × 2-bit counter|Indexed by 12-bit GHR|
|Total state|~29 Kbits||

This predictor achieved ~98.5% accuracy on SPECint95, a significant improvement over either component alone.

---

### Return Address Stack (RAS)

Function returns (`RET`, `JR $ra`) are indirect branches whose target changes with every call site. Neither the BTB nor the PHT helps here because the target is the caller's return address — different every time.

The **Return Address Stack** is a small hardware LIFO stack (typically 8–32 entries) that mirrors the software call stack:

```
On CALL instruction:  push (PC + 4) onto RAS
On RET instruction:   pop RAS → use as predicted target (bypass BTB lookup)
```

```
main:
  CALL foo     → push 0x1004 onto RAS
  0x1004: ...

foo:
  CALL bar     → push 0x2008 onto RAS
  ...
  RET          → pop 0x2008, predict target = 0x2008  ✓

  RET          → pop 0x1004, predict target = 0x1004  ✓
```

RAS prediction is nearly perfect for well-behaved call/return pairs. Overflow (deeply recursive functions) causes entries to be dropped, degrading to BTB prediction for those frames.

---

### Indirect Branch Predictor

For indirect branches other than returns (virtual function calls, switch-case jump tables, function pointers), the target varies in ways the BTB cannot capture because a single BTB entry stores only the _last_ target.

The **Indirect Branch Predictor** (IBP) associates a branch PC with a history of recent targets, selecting the predicted target based on the global or local history:

```
Index = PC XOR GHR  →  table of target addresses (not just taken/not-taken)
```

This captures patterns such as a virtual dispatch that alternates between two target functions. Modern processors (Intel's IBRS post-Spectre, ARM's CSV2 mitigation) have significantly modified indirect branch predictor designs due to security considerations — the predictor's state became an attack surface for cross-process speculation.

---

### Prediction in a Modern Frontend

A modern superscalar processor integrates all these mechanisms into a unified **fetch/predict** pipeline:

<svg viewBox="0 0 700 420" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="700" height="420" fill="#0d1117"/> <!-- Title -->

<text x="200" y="26" fill="#f0f6fc" font-size="13" font-weight="bold">Modern Branch Prediction Pipeline</text>

<!-- Cycle 1: Fetch --> <rect x="30" y="50" width="160" height="60" fill="#1c2d40" stroke="#58a6ff" stroke-width="1.5" rx="4"/> <text x="70" y="74" fill="#58a6ff" font-weight="bold">Instruction Fetch</text> <text x="45" y="92" fill="#8b949e">PC → I-Cache lookup</text> <text x="45" y="106" fill="#8b949e">PC → BTB lookup</text> <!-- BTB --> <rect x="30" y="150" width="160" height="50" fill="#21262d" stroke="#e3b341" stroke-width="1.5" rx="4"/> <text x="82" y="172" fill="#e3b341" font-weight="bold">BTB</text> <text x="38" y="188" fill="#8b949e">tag match → target addr</text> <!-- BHT/PHT --> <rect x="220" y="150" width="160" height="50" fill="#21262d" stroke="#3fb950" stroke-width="1.5" rx="4"/> <text x="258" y="172" fill="#3fb950" font-weight="bold">BHT / PHT</text> <text x="228" y="188" fill="#8b949e">GHR XOR PC → taken?</text> <!-- RAS --> <rect x="410" y="150" width="130" height="50" fill="#21262d" stroke="#d2a8ff" stroke-width="1.5" rx="4"/> <text x="452" y="172" fill="#d2a8ff" font-weight="bold">RAS</text> <text x="418" y="188" fill="#8b949e">return addr stack</text> <!-- Selector --> <rect x="220" y="50" width="160" height="60" fill="#1c2d40" stroke="#ff7b72" stroke-width="1.5" rx="4"/> <text x="258" y="74" fill="#ff7b72" font-weight="bold">Selector / Chooser</text> <text x="228" y="92" fill="#8b949e">tournament meta-predictor</text> <text x="228" y="106" fill="#8b949e">local vs global choice</text> <!-- Mux --> <rect x="410" y="50" width="130" height="60" fill="#21262d" stroke="#58a6ff" stroke-width="1.5" rx="4"/> <text x="440" y="74" fill="#58a6ff" font-weight="bold">Next-PC Mux</text> <text x="418" y="92" fill="#8b949e">PC+4 / BTB target</text> <text x="418" y="106" fill="#8b949e">/ RAS top</text> <!-- Decode --> <rect x="570" y="50" width="110" height="60" fill="#1c2d40" stroke="#79c0ff" stroke-width="1.5" rx="4"/> <text x="590" y="80" fill="#79c0ff" font-weight="bold">Decode</text> <text x="578" y="95" fill="#8b949e">confirm branch</text> <text x="578" y="109" fill="#8b949e">type detected</text> <!-- Execute / Resolve --> <rect x="570" y="200" width="110" height="60" fill="#1c2d40" stroke="#56d364" stroke-width="1.5" rx="4"/> <text x="578" y="225" fill="#56d364" font-weight="bold">Execute</text> <text x="578" y="240" fill="#8b949e">branch resolved</text> <text x="578" y="254" fill="#8b949e">actual outcome</text> <!-- Update --> <rect x="300" y="290" width="200" height="60" fill="#21262d" stroke="#ff7b72" stroke-width="1.5" rx="4"/> <text x="340" y="315" fill="#ff7b72" font-weight="bold">Predictor Update</text> <text x="308" y="333" fill="#8b949e">update BTB, BHT, GHR</text> <text x="308" y="347" fill="#8b949e">selector on misprediction</text> <!-- Squash --> <rect x="100" y="290" width="160" height="60" fill="#2d1a1a" stroke="#ff7b72" stroke-width="1.5" rx="4" stroke-dasharray="5,3"/> <text x="128" y="315" fill="#ff7b72" font-weight="bold">Pipeline Flush</text> <text x="110" y="333" fill="#8b949e">squash wrong-path</text> <text x="110" y="347" fill="#8b949e">instructions</text> <!-- Arrows --> <!-- Fetch → BTB --> <line x1="110" y1="110" x2="110" y2="150" stroke="#8b949e" stroke-width="1.2" marker-end="url(#a2)"/> <!-- Fetch → Selector --> <line x1="190" y1="80" x2="220" y2="80" stroke="#8b949e" stroke-width="1.2" marker-end="url(#a2)"/> <!-- Selector → Mux --> <line x1="380" y1="80" x2="410" y2="80" stroke="#8b949e" stroke-width="1.2" marker-end="url(#a2)"/> <!-- Mux → Decode --> <line x1="540" y1="80" x2="570" y2="80" stroke="#8b949e" stroke-width="1.2" marker-end="url(#a2)"/> <!-- Decode → Execute --> <line x1="625" y1="110" x2="625" y2="200" stroke="#8b949e" stroke-width="1.2" marker-end="url(#a2)"/> <!-- Execute → Update --> <line x1="580" y1="260" x2="500" y2="290" stroke="#ff7b72" stroke-width="1.2" marker-end="url(#a2)"/> <!-- Execute → Squash --> <line x1="570" y1="250" x2="260" y2="310" stroke="#ff7b72" stroke-width="1.2" stroke-dasharray="4,3" marker-end="url(#a2)"/> <!-- BTB → Mux --> <line x1="190" y1="172" x2="474" y2="110" stroke="#e3b341" stroke-width="1" stroke-dasharray="4,3" marker-end="url(#a2)"/> <!-- BHT → Selector --> <line x1="300" y1="150" x2="300" y2="110" stroke="#3fb950" stroke-width="1" marker-end="url(#a2)"/> <!-- RAS → Mux --> <line x1="475" y1="150" x2="475" y2="110" stroke="#d2a8ff" stroke-width="1" marker-end="url(#a2)"/> <!-- Update → GHR label -->

<text x="145" y="380" fill="#8b949e" font-size="10">← redirect fetch to correct PC</text>

<defs> <marker id="a2" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#8b949e"/> </marker> </defs> </svg>

---

### Performance Metrics

#### Misprediction Penalty

The cost of a misprediction depends on the pipeline depth and where the branch resolves:

$$\text{Penalty} = \text{stages between Fetch and branch resolution}$$

|Processor|Pipeline Depth|Approx. Misprediction Penalty|
|---|---|---|
|Classic MIPS 5-stage|5|1–2 cycles|
|Intel Pentium (1993)|5|3–4 cycles|
|Intel Pentium 4 (Netburst)|31|20+ cycles|
|Intel Core i7 (Skylake)|14–19|15–19 cycles|
|ARM Cortex-A77|13|~12 cycles|

#### Prediction Accuracy vs. IPC Loss

$$\text{Effective CPI} = \text{Base CPI} + f_b \times (1 - \text{accuracy}) \times \text{penalty}$$

where $f_b$ is the fraction of instructions that are branches. For $f_b = 0.20$, penalty = 15, base CPI = 1:

|Accuracy|CPI|IPC|
|---|---|---|
|80%|1 + 0.20 × 0.20 × 15 = 1.60|0.625|
|95%|1 + 0.20 × 0.05 × 15 = 1.15|0.870|
|99%|1 + 0.20 × 0.01 × 15 = 1.03|0.971|

The difference between 95% and 99% accuracy is nearly 12% IPC — a compelling reason to invest in more sophisticated predictors.

---

### Modern Predictors Beyond Tournament

#### TAGE — Tagged Geometric History Length

TAGE (TAgged GEometric history length, Seznec 2006) is the basis of virtually all state-of-the-art predictors. It uses multiple predictor tables, each using a different history length from a **geometric series**:

$$L(i) = \alpha^{i-1} \times L(1), \quad \alpha \approx 2, \quad i = 1 \ldots M$$

For example, history lengths: 2, 4, 8, 16, 32, 64, 128 bits.

Each table entry is a **tagged entry** — a 3-bit counter plus a tag (partial history hash) plus a usefulness counter. The longest matching history length whose tag matches wins. This allows TAGE to exploit correlations over both short and long history windows simultaneously.

TAGE achieves ~99.5%+ accuracy on SPEC CPU2017 with appropriately sized tables.

#### Perceptron Predictor

The perceptron predictor (Jiménez & Lin, 2001) applies a single-layer neural network to branch prediction. A perceptron is stored per branch:

$$y = w_0 + \sum_{i=1}^{n} x_i \cdot w_i$$

where $x_i \in {-1, +1}$ encodes the global history bits and $w_i$ are learned weights. The sign of $y$ gives the prediction. Weights are updated by perceptron training when a misprediction occurs.

Perceptron predictors are particularly effective for branches with **long history dependencies** — correlations that require more than 12–15 bits of history, which overflow the PHT indexing in TAGE-like schemes.

---

### Predictor State as a Security Surface

Post-Spectre, branch predictors became a security concern. The **BTB** and **BHT** are shared microarchitectural state that can be:

- **Poisoned** (attacker pre-trains the predictor to mispredict in victim context)
- **Probed** (attacker measures timing differences to infer predictor state → infers victim control flow)

Mitigations include:

|Mitigation|Mechanism|
|---|---|
|IBRS (Indirect Branch Restricted Speculation)|Isolates predictor state between privilege levels|
|IBPB (Indirect Branch Predictor Barrier)|Flushes predictor state on context switch|
|STIBP (Single Thread Indirect Branch Predictors)|Isolates predictor between hyperthreads|
|Retpoline|Replaces indirect branches with a return trampoline that defeats BTB-based speculation|
|eIBRS (Enhanced IBRS)|Persistent IBRS without per-entry overhead|

These mitigations impose measurable performance costs — in some workloads, IBPB on every context switch degrades throughput by 10–30%.

---

### Summary of Predictor Mechanisms

|Predictor|State|Captures|Accuracy (typical)|
|---|---|---|---|
|Always not-taken|None|—|~60%|
|BTFNT|None (rule-based)|Code structure|~65–75%|
|1-bit counter|1 bit/branch|Last outcome|~75–85%|
|2-bit saturating counter|2 bits/branch|Local stability|~85–90%|
|Local two-level (BHR+PHT)|n-bit BHR + PHT|Local patterns|~90–94%|
|Gshare|GHR + shared PHT|Global correlation|~93–96%|
|Tournament (hybrid)|Local + global + selector|Both|~97–98.5%|
|TAGE|Multi-table geometric|Long-range correlation|~99–99.5%|
|Perceptron|Weight vectors|Long history linear|~98–99.5%|

---

**Conclusion** Branch prediction progresses from trivial static rules through increasingly sophisticated dynamic schemes that model correlations across branches and history lengths. The 2-bit saturating counter established the foundational insight that hysteresis prevents noise from destabilizing predictions; two-level predictors extended this to pattern recognition over history sequences; tournament predictors acknowledged that no single scheme dominates all workloads; and TAGE unified these ideas through geometric history indexing to achieve near-perfect accuracy on modern benchmarks. The misprediction penalty scales with pipeline depth, making predictor accuracy a first-order determinant of IPC in every deeply pipelined processor.

**Next Steps** Proceed to **Pipeline Performance Metrics** to formalize the relationships between CPI, branch frequency, prediction accuracy, and structural hazards into a complete analytical framework for pipeline efficiency.

---

