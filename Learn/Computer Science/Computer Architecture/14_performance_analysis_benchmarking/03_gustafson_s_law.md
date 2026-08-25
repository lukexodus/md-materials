## Gustafson's Law


Gustafson's Law, formulated by John L. Gustafson in 1988, challenges the pessimistic scaling bound established by Amdahl's Law by reframing the question of parallel speedup. Where Amdahl fixes the problem size and asks how much faster it can be solved with more processors, Gustafson observes that practitioners scaling up hardware characteristically also scale up the problem — and that under this model, the parallelizable fraction dominates increasingly as processor count grows, making near-linear speedup achievable in practice.

---

### Motivation: The Amdahl Ceiling

Amdahl's Law defines speedup for a fixed workload of size W:

$$S_{Amdahl}(p) = \frac{1}{s + \dfrac{1-s}{p}}$$

where s is the serial fraction and p is the number of processors. As p → ∞:

$$S_{Amdahl} \to \frac{1}{s}$$

A program that is 5% serial is bounded to 20× speedup regardless of processor count. This ceiling arises directly from the fixed-size assumption: the serial portion consumes a fixed amount of time, and adding processors cannot compress it.

Gustafson's insight was that this assumption is empirically wrong for most large-scale computations. Scientists and engineers given more processors do not solve the same problem faster — they solve **larger problems** in the same amount of time.

---

### Derivation

#### Setup

Let the total execution time on p processors be normalized to 1. Partition that time into:

- **s′** — the serial fraction of time (measured on the parallel system)
- **(1 − s′)** — the parallel fraction of time

On p processors, the parallel portion represents p times more work than one processor could contribute in that time slot. The equivalent sequential time to perform the same total work is:

$$T_{sequential} = s' + p \cdot (1 - s')$$

Speedup is the ratio of sequential time to parallel time:

$$S_{Gustafson}(p) = \frac{s' + p(1-s')}{1} = s' + p(1-s')$$

Rearranging:

$$\boxed{S(p) = p - s'(p - 1)}$$

This is Gustafson's Law. Speedup is **linear in p**, modulated only by the serial fraction s′.

---

### Amdahl vs. Gustafson: A Structural Comparison

The two laws differ in which quantity is held constant:

||Amdahl's Law|Gustafson's Law|
|---|---|---|
|Fixed quantity|Problem size (work W)|Execution time (wall clock)|
|Variable quantity|Time|Problem size|
|Serial fraction basis|Of total sequential work|Of parallel runtime|
|Speedup form|1 / (s + (1−s)/p)|p − s′(p−1)|
|Speedup as p → ∞|1/s (hard ceiling)|Unbounded (linear growth)|
|Implicit assumption|Strong scaling|Weak scaling|

<svg viewBox="0 0 560 320" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <defs> <marker id="ga" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#888"/> </marker> </defs> <!-- Axes --> <line x1="60" y1="270" x2="510" y2="270" stroke="#888" stroke-width="1.5" marker-end="url(#ga)"/> <line x1="60" y1="270" x2="60" y2="25" stroke="#888" stroke-width="1.5" marker-end="url(#ga)"/> <text x="515" y="274" fill="#aaa" font-size="11">p (processors)</text> <text x="30" y="22" fill="#aaa" font-size="10">Speedup</text> <!-- Grid lines and x-axis labels --> <line x1="60" y1="270" x2="60" y2="268" stroke="#666" stroke-width="1"/> <line x1="149" y1="270" x2="149" y2="268" stroke="#666" stroke-width="1"/> <line x1="238" y1="270" x2="238" y2="268" stroke="#666" stroke-width="1"/> <line x1="327" y1="270" x2="327" y2="268" stroke="#666" stroke-width="1"/> <line x1="416" y1="270" x2="416" y2="268" stroke="#666" stroke-width="1"/> <text x="56" y="284" fill="#888" font-size="10">1</text> <text x="143" y="284" fill="#888" font-size="10">4</text> <text x="232" y="284" fill="#888" font-size="10">7</text> <text x="321" y="284" fill="#888" font-size="10">10</text> <text x="410" y="284" fill="#888" font-size="10">13</text> <!-- Y-axis labels -->

<text x="38" y="274" fill="#888" font-size="10">0</text> <text x="38" y="224" fill="#888" font-size="10">3</text> <text x="38" y="174" fill="#888" font-size="10">6</text> <text x="38" y="124" fill="#888" font-size="10">9</text> <text x="32" y="74" fill="#888" font-size="10">12</text>

<!-- Ideal linear speedup --> <line x1="60" y1="270" x2="497" y2="31" stroke="#444" stroke-width="1.2" stroke-dasharray="4,3"/> <text x="480" y="28" fill="#666" font-size="10">Ideal</text> <!-- Amdahl s=0.05: ceiling at 20, but clipped to chart --> <!-- f(p) = 1/(0.05 + 0.95/p), x in [1..14], map p→x: x = 60 + (p-1)*29.67, y: y=270 - S*16.67 --> <!-- p=1:S=1, p=4:S=3.48, p=7:S=5.29, p=10:S=6.90, p=13:S=8.19 -->

<polyline points="60,253.3 149,212.0 238,182.2 327,155.0 416,133.5 497,117.2" fill="none" stroke="#e07b54" stroke-width="2"/> <text x="455" y="113" fill="#e07b54" font-size="10">Amdahl (s=0.05)</text>

<!-- Gustafson s'=0.05: S = p - 0.05*(p-1), linear --> <!-- p=1:1, p=4:3.85, p=7:6.70, p=10:9.55, p=13:12.4 -->

<polyline points="60,253.3 149,206.8 238,158.3 327,111.7 416,63.3 497,20.0" fill="none" stroke="#7c6fcd" stroke-width="2"/> <text x="460" y="20" fill="#7c6fcd" font-size="10">Gustafson (s′=0.05)</text>

<!-- Amdahl s=0.20 --> <!-- p=1:1, p=4:2.50, p=7:3.23, p=10:3.57, p=13:3.77 -->

<polyline points="60,253.3 149,228.3 238,216.1 327,210.5 416,207.2 497,205.3" fill="none" stroke="#e07b54" stroke-width="2" stroke-dasharray="5,3" opacity="0.7"/> <text x="455" y="203" fill="#e07b54" font-size="10" opacity="0.8">Amdahl (s=0.20)</text>

<!-- Gustafson s'=0.20 --> <!-- p=1:1, p=4:3.4, p=7:5.8, p=10:8.2, p=13:10.6 -->

<polyline points="60,253.3 149,213.3 238,173.3 327,133.3 416,93.3 497,55.3" fill="none" stroke="#7c6fcd" stroke-width="2" stroke-dasharray="5,3" opacity="0.7"/> <text x="455" y="53" fill="#7c6fcd" font-size="10" opacity="0.8">Gustafson (s′=0.20)</text>

<!-- Legend --> <rect x="62" y="30" width="180" height="55" rx="4" fill="#1a1a2e" stroke="#444" stroke-width="1"/> <line x1="72" y1="47" x2="100" y2="47" stroke="#e07b54" stroke-width="2"/> <text x="105" y="51" fill="#e07b54" font-size="10">Amdahl (fixed size)</text> <line x1="72" y1="65" x2="100" y2="65" stroke="#7c6fcd" stroke-width="2"/> <text x="105" y="69" fill="#7c6fcd" font-size="10">Gustafson (scaled size)</text> <line x1="72" y1="77" x2="100" y2="77" stroke="#888" stroke-width="1.2" stroke-dasharray="4,3"/> <text x="105" y="81" fill="#888" font-size="10">Ideal linear</text> </svg>

---

### The Scaled Speedup Interpretation

Gustafson's reformulation can be expressed as **scaled speedup**: the speedup achieved when problem size grows proportionally with processor count, keeping wall-clock time constant.

Define the work done in parallel time T_p = 1 as:

$$W(p) = s' \cdot W_0 + p \cdot (1 - s') \cdot W_0$$

The first term is the serial work (fixed); the second term is the parallel work, which grows linearly with p because each processor contributes a full unit of parallel work. The sequential time to perform W(p) on one processor is:

$$T_1(p) = W(p) = s' + p(1-s')$$

This directly recovers Gustafson's formula. The key is that W(p) is not fixed — it is a function of p. This is **weak scaling**: processor count and problem size increase together.

---

### Numeric Example

A climate simulation has a serial setup phase of 2% wall-clock time on any number of processors (s′ = 0.02). The rest is parallelizable domain decomposition.

|Processors (p)|S = p − 0.02(p−1)|Efficiency = S/p|
|---|---|---|
|1|1.00|100%|
|16|15.70|98.1%|
|64|63.51|99.2%|
|256|253.05|98.8%|
|1024|1,012.98|98.9%|

**Output:** Even at 1,024 processors, speedup remains above 1,012 — essentially linear — because the serial fraction is small and the problem grows to fill the machine.

Contrast with Amdahl at the same s = 0.02: ceiling is 1/0.02 = 50× regardless of processor count.

---

### Reinterpreting the Serial Fraction

A critical subtlety: s and s′ are not the same quantity, even when they appear numerically identical.

**Amdahl's s** — serial fraction of total sequential work. If a program takes 100 seconds sequentially and 5 seconds of that is inherently serial, s = 0.05. With p processors the parallel portion compresses but the 5 s floor remains.

**Gustafson's s′** — serial fraction of observed parallel runtime. If on 64 processors the job takes 1000 seconds and 20 seconds are serial activity, s′ = 0.02. As problem size grows, the parallel portion grows but the serial overhead may remain roughly constant, shrinking s′.

This distinction matters for measurement. When profiling:

- Amdahl's s is measured on a **uniprocessor run**.
- Gustafson's s′ is measured on the **parallel run at scale**.

If serial overhead is truly fixed (does not grow with problem size), s′ → 0 as problem size increases, and Gustafson's speedup approaches ideal linear. If serial overhead grows with problem size (e.g., O(n log n) gather step vs O(n) parallel step), s′ is not constant and the law must be applied more carefully.

---

### Conditions for Applicability

Gustafson's Law yields optimistic but accurate predictions when:

- **The problem is weak-scalable**: more work can be added that parallelizes well as more processors are added. Finite element meshes, particle simulations, and Monte Carlo methods are canonical examples.
- **The serial fraction is truly constant or shrinking**: coordination overhead, I/O, and reduction operations do not grow faster than the parallel work.
- **Communication overhead is sublinear**: the interconnect does not become the bottleneck as p grows. Nearest-neighbor stencils on mesh networks satisfy this; all-to-all reductions do not.
- **Memory capacity scales with p**: the larger problem must fit in the aggregate memory of the system. Many scientific codes are memory-bound before they are compute-bound.

The law becomes pessimistic or inapplicable when:

- Serial overhead grows with p (e.g., global synchronization barriers, centralized I/O).
- The problem has a natural maximum size that cannot be exceeded (fixed dataset, fixed physical domain).
- Communication volume grows superlinearly with problem size.

---

### Serial Overhead Categories

Not all sources of serialism behave the same way under scaling:

```
Serial Overhead Sources
│
├── Truly Fixed (best case for Gustafson)
│   ├── Program initialization, library startup
│   ├── Final output / result writing
│   └── Single global reduction (fixed-size result)
│
├── Grows as O(log p) — acceptable
│   ├── Tree-structured reductions
│   ├── Barrier synchronization with tournament trees
│   └── Parallel prefix operations
│
├── Grows as O(p) — degrades Gustafson's prediction
│   ├── All-to-all communication
│   ├── Centralized task scheduling
│   └── Sequential consistency enforcement in shared memory
│
└── Grows as O(p²) — catastrophic
    ├── Naive all-pairs communication
    └── Fully connected lock contention
```

When overhead grows as O(log p), Gustafson's Law still yields near-linear effective speedup but with a logarithmic correction. When overhead grows as O(p), the law reverts toward Amdahl-like behavior.

---

### Relation to Efficiency and Isoefficiency

**Parallel efficiency** under Gustafson's model:

$$E(p) = \frac{S(p)}{p} = \frac{p - s'(p-1)}{p} = 1 - s'\left(1 - \frac{1}{p}\right)$$

As p → ∞:

$$E \to 1 - s'$$

Efficiency is bounded away from zero — it approaches a constant (1 − s′) rather than collapsing to zero as in fixed-size scaling.

**Isoefficiency** characterizes how problem size must grow with p to maintain constant efficiency. For a system with serial fraction s′ and parallel overhead T_o(n, p):

$$W(p) \geq \frac{E}{1-E} \cdot T_o(n,p)$$

Gustafson's model is the case where this isoefficiency function is linear: W must grow as O(p) to maintain efficiency, which is satisfied naturally when the problem is uniformly partitioned across processors. Problems with superlinear isoefficiency functions require disproportionately larger inputs to maintain the same efficiency at scale.

---

### Extended Formulation: Non-Uniform Parallel Scaling

The basic law assumes all p processors contribute equally to parallel work. A refined form accounts for non-uniform workloads and communication overhead:

$$S(p) = \frac{s' + p(1-s') - T_{comm}(p)}{1}$$

where T_comm(p) is the communication overhead as a fraction of parallel runtime. For nearest-neighbor stencil codes on a d-dimensional mesh, T_comm ∝ p^(1/d) / p = p^(1/d − 1) → 0, which is negligible. For all-to-all collectives, T_comm ∝ log p / 1 = log p, which grows and must be accounted for explicitly.

In practice, empirical scaled speedup curves are fitted against the Gustafson model to extract s′ and validate whether a code's parallel efficiency is limited by serial overhead, communication, or load imbalance.

---

### Practical Implications for System Design

**Key Points:**

- Gustafson's Law justifies building massively parallel systems for workloads that are naturally weak-scalable. Petascale and exascale machines are premised on the observation that scientific problems scale — finer mesh resolution, longer simulation time, more Monte Carlo samples — to fill available parallelism.
- A code with s′ = 0.01 achieves 990× speedup on 1,000 processors under Gustafson's model but is capped at 100× under Amdahl's. The practical difference between a 10-hour job and a 36-second job on the same hardware.
- Gustafson's Law redirects optimization effort: rather than trying to eliminate the serial fraction (hard), the goal is to ensure the parallel fraction scales cleanly (often achievable by algorithmic redesign — domain decomposition, owner-computes rules, hierarchical reductions).
- For strong-scaling workloads (fixed dataset: genomics, database query, video transcode), Amdahl's Law is the correct model and Gustafson's optimism is inapplicable.

---

### Summary of Key Quantities

|Quantity|Symbol|Meaning|
|---|---|---|
|Processors|p|Number of parallel processing units|
|Serial time fraction|s′|Fraction of parallel wall-clock time spent in serial code|
|Scaled speedup|S(p)|p − s′(p − 1)|
|Parallel efficiency|E(p)|S(p)/p → 1 − s′ as p → ∞|
|Scaling model|Weak|Problem size grows with p; time fixed|
|Amdahl equivalent|s|Serial fraction of fixed sequential work|

---

**Conclusion:** Gustafson's Law establishes that the relevant question for large-scale parallel systems is not how much faster a fixed problem can be solved, but how much more work can be accomplished in fixed time as resources increase. By measuring the serial fraction against the parallel execution time rather than the sequential execution time, the law reveals that near-linear speedup is not merely theoretically possible but routinely achieved in practice for workloads that are naturally weak-scalable. Its limits lie in assumptions of constant serial overhead and linear isoefficiency — both of which must be verified empirically before the law's predictions can be trusted at scale.

**Next Steps:** Proceed to **Amdahl's Law** for the complementary strong-scaling analysis and a unified treatment of when each model applies, or to **Benchmarking Methodologies (SPEC CPU, STREAM, Linpack)** to examine how these scaling laws manifest in standardized measurement — particularly how STREAM's weak-scaling design and Linpack's strong-scaling emphasis reflect the two frameworks directly.

---

