## Pipeline Performance Metrics


Pipeline performance metrics provide the quantitative framework for evaluating how effectively a pipeline overlaps instruction execution. They connect hardware design decisions — stage count, hazard frequency, branch behavior — to measurable throughput and efficiency values.

---

### Foundational Definitions

#### Clock Cycle Time

The clock period is set by the slowest pipeline stage (the critical path across any single stage):

$$T_{clock} = \max(t_{stage_1},\ t_{stage_2},\ \ldots,\ t_{stage_k}) + t_{overhead}$$

Where $t_{overhead}$ accounts for pipeline register setup time, clock skew, and hold time margins. Unlike the single-cycle design, only the slowest _stage_ — not the slowest _instruction_ — determines the clock period.

#### Cycles Per Instruction (CPI)

$$\text{CPI} = \text{CPI}_{ideal} + \text{CPI}_{stall}$$

For a classical 5-stage pipeline:

$$\text{CPI}_{ideal} = 1$$

Stall cycles arise from structural, data, and control hazards:

$$\text{CPI}_{stall} = \text{CPI}_{data} + \text{CPI}_{control} + \text{CPI}_{structural}$$

#### Instructions Per Cycle (IPC)

$$\text{IPC} = \frac{1}{\text{CPI}}$$

IPC is the reciprocal of CPI. It is the preferred metric when comparing processors that may have different ideal CPIs (e.g., superscalar processors with IPC > 1).

#### CPU Execution Time

$$T_{exec} = \text{IC} \times \text{CPI} \times T_{clock}$$

Where IC = instruction count. This is the fundamental performance equation. All optimizations reduce one or more of these three terms.

---

### Pipeline Speedup Over Single-Cycle

#### Ideal Speedup

For a $k$-stage pipeline executing $n$ instructions:

$$\text{Time}_{single} = n \times T_{single}$$

$$\text{Time}_{pipeline} = (k + n - 1) \times T_{stage}$$

The $(k - 1)$ term is the **pipeline fill latency** — cycles to fill the pipeline before the first instruction completes. For large $n$:

$$\text{Speedup}_{ideal} = \frac{n \times k \times T_{stage}}{(k + n - 1) \times T_{stage}} \xrightarrow{n \gg k} k$$

An ideal $k$-stage pipeline asymptotically approaches a speedup of $k$ over the single-cycle design, assuming equal stage delays.

#### Realistic Speedup (With Stalls)

$$\text{Speedup} = \frac{T_{single}}{T_{pipeline}} = \frac{\text{CPI}_{single} \times T_{single}}{\text{CPI}_{pipeline} \times T_{stage}}$$

Since $T_{single} = k \times T_{stage}$ (assuming balanced stages):

$$\text{Speedup} = \frac{k}{\text{CPI}_{pipeline}}$$

Every stall cycle directly reduces speedup. A 5-stage pipeline with CPI = 1.4 achieves speedup = 5/1.4 ≈ 3.57, not 5.

---

### Stall Cycle Contributions

#### Data Hazard Stalls

A load-use hazard on a 5-stage pipeline (without forwarding resolution) inserts one stall cycle:

$$\text{CPI}_{data} = f_{load\text{-}use} \times \text{stalls_per_hazard}$$

With full forwarding, most RAW hazards are resolved with 0 stall cycles. Load-use remains at 1 stall cycle.

**Example:**

```
Assume:
  20% of instructions are loads
  40% of loads are followed immediately by a dependent instruction
  (load-use hazard rate = 0.20 × 0.40 = 0.08 per instruction)
  Each load-use = 1 stall cycle

CPI_data = 0.08 × 1 = 0.08
```

#### Control Hazard Stalls

$$\text{CPI}_{control} = f_{branch} \times \text{penalty} \times (1 - \text{prediction_accuracy})$$

For a static predict-not-taken scheme with a 1-cycle branch penalty:

```
Assume:
  20% of instructions are branches
  Branch penalty = 1 cycle (branch resolved in EX stage)
  Prediction accuracy = 0% (always wrong — worst case)

CPI_control = 0.20 × 1 × 1.0 = 0.20
```

With a dynamic predictor at 95% accuracy:

```
CPI_control = 0.20 × 1 × 0.05 = 0.01
```

#### Structural Hazard Stalls

In classical 5-stage pipelines with separate instruction and data memories, structural hazards are largely eliminated by design. In pipelines sharing resources (e.g., a unified cache or a single multiply unit), structural hazard CPI contribution is:

$$\text{CPI}_{structural} = f_{conflicting} \times \text{stalls_per_conflict}$$

---

### Complete CPI Calculation

<svg viewBox="0 0 680 320" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <rect width="680" height="320" fill="#0d1117" rx="8"/> <!-- Title -->

<text x="340" y="28" text-anchor="middle" fill="#c9d1d9" font-size="13" font-weight="bold">CPI Decomposition</text>

<!-- Base bar --> <rect x="60" y="60" width="100" height="200" fill="#1f6feb" rx="3"/> <text x="110" y="275" text-anchor="middle" fill="#8b949e" font-size="10">Ideal</text> <text x="110" y="287" text-anchor="middle" fill="#8b949e" font-size="10">CPI = 1.0</text> <text x="110" y="160" text-anchor="middle" fill="#ffffff" font-size="11" font-weight="bold">1.0</text> <!-- Data hazard stall bar --> <rect x="220" y="60" width="100" height="200" fill="#1f6feb" rx="3"/> <rect x="220" y="44" width="100" height="16" fill="#f78166" rx="3"/> <text x="270" y="275" text-anchor="middle" fill="#8b949e" font-size="10">+ Data</text> <text x="270" y="287" text-anchor="middle" fill="#8b949e" font-size="10">Hazards</text> <text x="270" y="55" text-anchor="middle" fill="#ffffff" font-size="10">+0.08</text> <text x="270" y="160" text-anchor="middle" fill="#ffffff" font-size="11" font-weight="bold">1.08</text> <!-- Control hazard stall bar --> <rect x="380" y="60" width="100" height="200" fill="#1f6feb" rx="3"/> <rect x="380" y="44" width="100" height="16" fill="#f78166" rx="3"/> <rect x="380" y="24" width="100" height="20" fill="#e6c07b" rx="3"/> <text x="430" y="275" text-anchor="middle" fill="#8b949e" font-size="10">+ Control</text> <text x="430" y="287" text-anchor="middle" fill="#8b949e" font-size="10">Hazards</text> <text x="430" y="36" text-anchor="middle" fill="#0d1117" font-size="10">+0.20</text> <text x="430" y="55" text-anchor="middle" fill="#ffffff" font-size="10">+0.08</text> <text x="430" y="160" text-anchor="middle" fill="#ffffff" font-size="11" font-weight="bold">1.28</text> <!-- Final CPI bar --> <rect x="540" y="60" width="100" height="200" fill="#1f6feb" rx="3"/> <rect x="540" y="44" width="100" height="16" fill="#f78166" rx="3"/> <rect x="540" y="24" width="100" height="20" fill="#e6c07b" rx="3"/> <text x="590" y="275" text-anchor="middle" fill="#8b949e" font-size="10">Final CPI</text> <text x="590" y="287" text-anchor="middle" fill="#8b949e" font-size="10">(no struct.)</text> <text x="590" y="36" text-anchor="middle" fill="#0d1117" font-size="10">+0.20</text> <text x="590" y="55" text-anchor="middle" fill="#ffffff" font-size="10">+0.08</text> <text x="590" y="160" text-anchor="middle" fill="#ffffff" font-size="11" font-weight="bold">1.28</text> <!-- Legend --> <rect x="60" y="303" width="12" height="10" fill="#1f6feb"/> <text x="76" y="312" fill="#8b949e" font-size="10">Ideal CPI (1.0)</text> <rect x="200" y="303" width="12" height="10" fill="#f78166"/> <text x="216" y="312" fill="#8b949e" font-size="10">Data stalls</text> <rect x="310" y="303" width="12" height="10" fill="#e6c07b"/> <text x="326" y="312" fill="#8b949e" font-size="10">Control stalls</text> </svg>

**Example: Full CPI calculation**

```
Given:
  Branch frequency:        20%
  Branch penalty:          2 cycles (resolved at end of EX)
  Branch prediction acc.:  90%
  Load frequency:          25%
  Load-use hazard rate:    35% of loads followed by dependent use
  Load-use stall:          1 cycle

CPI_ideal    = 1.00
CPI_control  = 0.20 × 2 × (1 - 0.90) = 0.04
CPI_data     = 0.25 × 0.35 × 1       = 0.0875

CPI_total    = 1.00 + 0.04 + 0.0875  = 1.1275
IPC          = 1 / 1.1275            ≈ 0.887
```

---

### Throughput and Latency

These are distinct concepts that are frequently conflated:

|Metric|Definition|Unit|
|---|---|---|
|**Latency**|Time for one instruction to complete|seconds / cycles|
|**Throughput**|Instructions completed per unit time|instructions/second|

In a pipeline, latency _increases_ relative to a single-cycle design (an instruction traverses $k$ stages), while throughput _increases_ due to overlap.

$$\text{Latency}_{pipeline} = k \times T_{clock}$$ $$\text{Latency}_{single} = T_{single} = k \times T_{stage} \approx \text{Latency}_{pipeline}$$

For a perfectly balanced pipeline with no overhead, latency is approximately unchanged. In practice, pipeline register overhead makes $T_{clock} > T_{stage}$, so pipeline latency slightly _exceeds_ single-cycle latency per instruction.

$$\text{Throughput}_{ideal} = \frac{1}{T_{clock}} \quad \text{(instructions/second)}$$

---

### Pipeline Efficiency

$$\text{Efficiency} = \frac{\text{Useful work cycles}}{\text{Total cycles}} = \frac{\text{IC}}{\text{IC} + \text{Total stall cycles}}$$

Equivalently:

$$\text{Efficiency} = \frac{\text{CPI}_{ideal}}{\text{CPI}_{actual}} = \frac{1}{\text{CPI}_{actual}}$$

For CPI = 1.28: Efficiency = 1/1.28 ≈ 78.1%. The remaining 21.9% of cycles are stall cycles — the pipeline is partially idle.

---

### Branch Penalty and Its Impact

The branch penalty is the number of pipeline stages between the fetch of a branch instruction and the stage where the branch outcome is known.

<svg viewBox="0 0 700 260" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="700" height="260" fill="#0d1117" rx="8"/> <text x="350" y="24" text-anchor="middle" fill="#c9d1d9" font-size="13" font-weight="bold">2-Cycle Branch Penalty — Timing Diagram</text> <!-- Cycle headers -->

<text x="165" y="45" text-anchor="middle" fill="#8b949e" font-size="10">Cycle 1</text> <text x="235" y="45" text-anchor="middle" fill="#8b949e" font-size="10">Cycle 2</text> <text x="305" y="45" text-anchor="middle" fill="#8b949e" font-size="10">Cycle 3</text> <text x="375" y="45" text-anchor="middle" fill="#8b949e" font-size="10">Cycle 4</text> <text x="445" y="45" text-anchor="middle" fill="#8b949e" font-size="10">Cycle 5</text> <text x="515" y="45" text-anchor="middle" fill="#8b949e" font-size="10">Cycle 6</text> <text x="585" y="45" text-anchor="middle" fill="#8b949e" font-size="10">Cycle 7</text> <text x="655" y="45" text-anchor="middle" fill="#8b949e" font-size="10">Cycle 8</text>

<!-- Instruction labels -->

<text x="80" y="78" fill="#c9d1d9" font-size="10">beq (branch)</text> <text x="80" y="118" fill="#f78166" font-size="10">I+1 (squashed)</text> <text x="80" y="158" fill="#f78166" font-size="10">I+2 (squashed)</text> <text x="80" y="198" fill="#3fb950" font-size="10">Target instr.</text>

<!-- beq stages --> <rect x="130" y="62" width="60" height="24" fill="#1f6feb" rx="2"/> <text x="160" y="78" text-anchor="middle" fill="#fff" font-size="9">IF</text> <rect x="200" y="62" width="60" height="24" fill="#1f6feb" rx="2"/> <text x="230" y="78" text-anchor="middle" fill="#fff" font-size="9">ID</text> <rect x="270" y="62" width="60" height="24" fill="#1f6feb" rx="2"/> <text x="300" y="78" text-anchor="middle" fill="#fff" font-size="9">EX✓</text> <rect x="340" y="62" width="60" height="24" fill="#1f6feb" rx="2"/> <text x="370" y="78" text-anchor="middle" fill="#fff" font-size="9">MEM</text> <rect x="410" y="62" width="60" height="24" fill="#1f6feb" rx="2"/> <text x="440" y="78" text-anchor="middle" fill="#fff" font-size="9">WB</text> <!-- I+1 squashed --> <rect x="200" y="102" width="60" height="24" fill="#3d1f1f" rx="2" stroke="#f78166" stroke-width="1" stroke-dasharray="3,2"/> <text x="230" y="118" text-anchor="middle" fill="#f78166" font-size="9">IF</text> <rect x="270" y="102" width="60" height="24" fill="#1a1a1a" rx="2"/> <text x="300" y="118" text-anchor="middle" fill="#444" font-size="9">bubble</text> <rect x="340" y="102" width="60" height="24" fill="#1a1a1a" rx="2"/> <text x="370" y="118" text-anchor="middle" fill="#444" font-size="9">bubble</text> <rect x="410" y="102" width="60" height="24" fill="#1a1a1a" rx="2"/> <text x="440" y="118" text-anchor="middle" fill="#444" font-size="9">bubble</text> <rect x="480" y="102" width="60" height="24" fill="#1a1a1a" rx="2"/> <text x="510" y="118" text-anchor="middle" fill="#444" font-size="9">bubble</text> <!-- I+2 squashed --> <rect x="270" y="142" width="60" height="24" fill="#3d1f1f" rx="2" stroke="#f78166" stroke-width="1" stroke-dasharray="3,2"/> <text x="300" y="158" text-anchor="middle" fill="#f78166" font-size="9">IF</text> <rect x="340" y="142" width="60" height="24" fill="#1a1a1a" rx="2"/> <text x="370" y="158" text-anchor="middle" fill="#444" font-size="9">bubble</text> <rect x="410" y="142" width="60" height="24" fill="#1a1a1a" rx="2"/> <text x="440" y="158" text-anchor="middle" fill="#444" font-size="9">bubble</text> <rect x="480" y="142" width="60" height="24" fill="#1a1a1a" rx="2"/> <text x="510" y="158" text-anchor="middle" fill="#444" font-size="9">bubble</text> <rect x="550" y="142" width="60" height="24" fill="#1a1a1a" rx="2"/> <text x="580" y="158" text-anchor="middle" fill="#444" font-size="9">bubble</text> <!-- Target instruction --> <rect x="340" y="182" width="60" height="24" fill="#1a3d28" rx="2" stroke="#3fb950" stroke-width="1"/> <text x="370" y="198" text-anchor="middle" fill="#3fb950" font-size="9">IF</text> <rect x="410" y="182" width="60" height="24" fill="#1a3d28" rx="2" stroke="#3fb950" stroke-width="1"/> <text x="440" y="198" text-anchor="middle" fill="#3fb950" font-size="9">ID</text> <rect x="480" y="182" width="60" height="24" fill="#1a3d28" rx="2" stroke="#3fb950" stroke-width="1"/> <text x="510" y="198" text-anchor="middle" fill="#3fb950" font-size="9">EX</text> <rect x="550" y="182" width="60" height="24" fill="#1a3d28" rx="2" stroke="#3fb950" stroke-width="1"/> <text x="580" y="198" text-anchor="middle" fill="#3fb950" font-size="9">MEM</text> <rect x="620" y="182" width="60" height="24" fill="#1a3d28" rx="2" stroke="#3fb950" stroke-width="1"/> <text x="650" y="198" text-anchor="middle" fill="#3fb950" font-size="9">WB</text> <!-- Annotation: branch resolved at EX --> <line x1="300" y1="54" x2="300" y2="230" stroke="#e6c07b" stroke-width="1" stroke-dasharray="3,2"/> <text x="302" y="243" fill="#e6c07b" font-size="9">branch resolved</text> <!-- Penalty brace --> <line x1="200" y1="225" x2="340" y2="225" stroke="#f78166" stroke-width="1"/> <line x1="200" y1="220" x2="200" y2="230" stroke="#f78166" stroke-width="1"/> <line x1="340" y1="220" x2="340" y2="230" stroke="#f78166" stroke-width="1"/> <text x="270" y="242" text-anchor="middle" fill="#f78166" font-size="9">2-cycle penalty</text> </svg>

---

### MIPS Formula (Millions of Instructions Per Second)

$$\text{MIPS} = \frac{\text{IC}}{T_{exec} \times 10^6} = \frac{f_{clock}}{\text{CPI} \times 10^6}$$

MIPS is clock-frequency and CPI dependent. It is not a reliable cross-architecture comparison metric because instruction counts differ between ISAs for equivalent workloads. An ISA with more powerful instructions executes fewer of them; a higher MIPS rating on a simpler ISA does not imply better performance.

---

### FLOPS (Floating-Point Operations Per Second)

$$\text{FLOPS} = \frac{\text{FP operations}}{T_{exec}}$$

Useful only for floating-point-intensive workloads. Peak FLOPS is a theoretical upper bound rarely achieved in practice; sustained FLOPS is the meaningful measurement and is heavily influenced by memory bandwidth.

---

### Amdahl's Law Applied to Pipelines

Amdahl's Law quantifies the limit of improvement when only a fraction of execution is sped up:

$$\text{Speedup}_{overall} = \frac{1}{(1 - f) + \dfrac{f}{s}}$$

Where $f$ = fraction of execution time affected by the improvement, $s$ = speedup of that fraction.

**Example: Branch penalty reduction**

```
Assume branches consume 30% of execution time.
Improve branch predictor: 2-cycle penalty → 0-cycle penalty (s → ∞ for that fraction).

Speedup = 1 / ((1 - 0.30) + 0.30/∞)
        = 1 / 0.70
        ≈ 1.43×
```

Even a perfect branch predictor yields at most 1.43× speedup if branches are 30% of execution time. This bounds the value of branch prediction investment.

---

### Pipeline Depth and the Clock Frequency Trade-off

Increasing pipeline depth (more stages) reduces the per-stage work and allows a higher clock frequency, but introduces additional costs:

<svg viewBox="0 0 680 230" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="680" height="230" fill="#0d1117" rx="8"/> <text x="340" y="24" text-anchor="middle" fill="#c9d1d9" font-size="13" font-weight="bold">Pipeline Depth vs. Performance</text> <!-- Axes --> <line x1="80" y1="190" x2="640" y2="190" stroke="#30363d" stroke-width="1.2"/> <line x1="80" y1="40" x2="80" y2="190" stroke="#30363d" stroke-width="1.2"/> <text x="360" y="215" text-anchor="middle" fill="#8b949e" font-size="10">Pipeline Depth (stages)</text> <text x="20" y="115" fill="#8b949e" font-size="10" transform="rotate(-90,20,115)">Performance</text> <!-- X axis labels -->

<text x="130" y="202" text-anchor="middle" fill="#8b949e" font-size="9">5</text> <text x="210" y="202" text-anchor="middle" fill="#8b949e" font-size="9">8</text> <text x="290" y="202" text-anchor="middle" fill="#8b949e" font-size="9">12</text> <text x="380" y="202" text-anchor="middle" fill="#8b949e" font-size="9">16</text> <text x="470" y="202" text-anchor="middle" fill="#8b949e" font-size="9">20</text> <text x="560" y="202" text-anchor="middle" fill="#8b949e" font-size="9">31 (Pentium 4)</text>

<!-- Throughput curve — rises then flattens/drops --> <polyline points="80,170 130,120 210,90 290,72 380,65 470,68 560,85" fill="none" stroke="#3fb950" stroke-width="2"/> <text x="580" y="83" fill="#3fb950" font-size="9">Throughput</text> <!-- Clock freq curve — rises monotonically but slowing --> <polyline points="80,175 130,140 210,110 290,88 380,72 470,62 560,55" fill="none" stroke="#58a6ff" stroke-width="2"/> <text x="575" y="53" fill="#58a6ff" font-size="9">Clock freq</text> <!-- Penalty curve — rises steeply --> <polyline points="80,185 130,183 210,178 290,168 380,150 470,128 560,100" fill="none" stroke="#f78166" stroke-width="2"/> <text x="575" y="98" fill="#f78166" font-size="9">Stall penalty</text> <!-- Optimal region annotation --> <rect x="200" y="45" width="120" height="28" rx="3" fill="#1a2d1a" stroke="#3fb950" stroke-width="1"/> <text x="260" y="60" text-anchor="middle" fill="#3fb950" font-size="9">Practical optimum</text> <text x="260" y="70" text-anchor="middle" fill="#3fb950" font-size="9">~10–16 stages</text> </svg>

|Effect of deeper pipeline|Direction|
|---|---|
|Clock frequency|Increases (less work per stage)|
|Ideal throughput|Increases|
|Branch misprediction penalty (cycles)|Increases|
|Load-to-use latency (cycles)|Increases|
|Pipeline register area and power|Increases|
|Hazard stall CPI contribution|Increases|

The performance optimum is typically 10–16 stages for out-of-order superscalar processors under realistic workloads. The Pentium 4's 31-stage Prescott pipeline is the canonical example of exceeding the optimum — high clock frequency was offset by severe branch penalty and high stall rates.

---

### Speedup Worked Example

**Given:**

```
Single-cycle clock period:  800 ps
5-stage pipeline, each stage: 160 ps
Pipeline register overhead:   20 ps per stage boundary
Pipeline clock period:        160 + 20 = 180 ps

Branch frequency:       22%
Branch penalty:         2 cycles
Prediction accuracy:    93%
Load-use frequency:     8% of all instructions
```

**Step 1 — CPI:**

```
CPI_control  = 0.22 × 2 × (1 - 0.93)
             = 0.22 × 2 × 0.07
             = 0.0308

CPI_data     = 0.08 × 1
             = 0.08

CPI_total    = 1.00 + 0.0308 + 0.08
             = 1.1108
```

**Step 2 — Execution time ratio (per instruction):**

```
T_single    = 800 ps
T_pipeline  = 1.1108 × 180 ps = 199.9 ps
```

**Step 3 — Speedup:**

```
Speedup = 800 / 199.9 ≈ 4.00×
```

**Step 4 — Ideal pipeline speedup (no hazards):**

```
Speedup_ideal = 800 / 180 ≈ 4.44×
```

Hazards reduce speedup from 4.44× to 4.00×, a 10% degradation from ideal.

---

### Summary of All Pipeline Metrics

|Metric|Formula|Notes|
|---|---|---|
|Clock period|$\max(t_{stage}) + t_{overhead}$|Bottleneck stage|
|CPI|$1 + \text{CPI}_{stall}$|Ideal = 1 for scalar|
|IPC|$1 / \text{CPI}$|> 1 only for superscalar|
|Execution time|$\text{IC} \times \text{CPI} \times T_{clk}$|Fundamental equation|
|Speedup vs. single-cycle|$k / \text{CPI}_{pipeline}$|$k$ = stage count|
|Efficiency|$1 / \text{CPI}_{actual}$|Fraction of useful cycles|
|MIPS|$f_{clk} / (\text{CPI} \times 10^6)$|Not cross-ISA comparable|
|Branch stall contribution|$f_{br} \times p \times (1 - acc)$|$p$ = penalty cycles|
|Load-use stall contribution|$f_{load} \times f_{use} \times 1$|1 stall cycle per hazard|

---

**Key Points**

- CPI = 1 + stall cycles per instruction; every hazard category contributes additively.
- Pipeline speedup relative to single-cycle is $k / \text{CPI}_{pipeline}$, not simply $k$.
- Latency per instruction increases in a pipeline (due to pipeline register overhead); throughput improves because of overlap.
- Deeper pipelines raise clock frequency but amplify branch penalties and increase sensitivity to hazard rates.
- MIPS and peak FLOPS are unreliable cross-architecture performance comparisons; execution time is the only reliable absolute metric.
- Amdahl's Law sets a hard ceiling on the benefit of reducing any single hazard type.

**Conclusion** Pipeline performance metrics translate structural hardware properties — stage count, hazard rates, prediction accuracy — into measurable quantities. CPI and execution time are the primary targets for optimization. Every technique examined in subsequent topics — forwarding, branch prediction, out-of-order execution — is ultimately justified by its effect on these metrics.

**Next Steps** Proceed to _Branch Prediction_ to examine how prediction accuracy directly reduces $\text{CPI}_{control}$, or advance to _Instruction-Level Parallelism_ to see how superscalar and out-of-order designs push IPC above 1.

---

