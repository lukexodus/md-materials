## Instruction-Level Parallelism — Concepts and Limits


Instruction-level parallelism (ILP) is the property of an instruction stream that permits multiple instructions to execute simultaneously without affecting the result. Exploiting ILP is the primary mechanism by which single-threaded performance has been extracted from sequential programs beyond what clock frequency alone provides.

---

### Definitions

**ILP** of a program (for a given execution window) is the maximum number of instructions that can execute in parallel under ideal conditions. It is a property of the instruction stream and its dependences, not of any particular machine.

Formally: given a dependence graph G = (V, E) where nodes are instructions and edges are dependences, ILP = |V| / critical_path_length(G). The critical path is the longest chain of dependent instructions — the theoretical lower bound on execution time regardless of resources.

A processor **exploits** ILP to the degree that its hardware detects and schedules independent instructions concurrently. The gap between available ILP and extracted ILP is determined by both true program structure and microarchitectural constraints.

---

### Dependence Classes

Three classes of dependence constrain ILP. Only one — **true dependence** — is fundamental. The other two are artifacts of a finite register file.

#### True Dependence (RAW — Read After Write)

Instruction j reads a value produced by instruction i. j cannot begin until i completes. This is a genuine data dependence; no renaming or reordering eliminates it.

```
ADD R1, R2, R3     ; writes R1
MUL R4, R1, R5    ; reads R1 — must wait
```

#### Anti-Dependence (WAR — Write After Read)

Instruction j writes a register that instruction i reads. If j were allowed to execute before i completed its read, i would see the wrong value. This is not a true dependence — it arises only because both instructions reuse the same register name.

```
ADD R4, R1, R2    ; reads R1
SUB R1, R3, R5    ; writes R1 — WAR on R1
```

#### Output Dependence (WAW — Write After Write)

Two instructions write the same register. The second write must be the final one visible to subsequent instructions. Again an artifact of register reuse.

All WAR and WAW dependences are eliminated by **register renaming** — mapping architectural register names to a larger physical register file. After renaming, each write targets a fresh physical register, and no two live values share a register.

#### Memory Dependences

RAW, WAR, and WAW dependences exist on memory locations as well as registers. These are harder to resolve statically: the processor (or compiler) must determine whether two memory addresses alias before reordering memory operations. Conservative alias analysis limits memory-level ILP extraction.

---

### The Dependence Graph and Critical Path

The instruction dependence graph for a basic block determines the theoretical maximum ILP. Each node carries an execution latency; edge weights represent the minimum number of cycles between producer and consumer.

The **critical path length** (longest weighted path through the graph) establishes the minimum execution time for that block on a machine with unlimited resources and perfect scheduling. ILP = instructions / critical_path_cycles.

For a loop body with a loop-carried dependence of length L cycles and body size N instructions, the maximum achievable IPC is min(N/L, issue_width).

---

### Dependence Graph — IllustratedSix instructions, critical path depth = 10 cycles. With unlimited issue width, ILP = 6/10 < 1 — the multiply latency dominates. Only by unrolling or software pipelining to expose more independent work does ILP improve.

---

### Theoretical Limits on ILP

#### Wall's Study (1991)

David Wall's simulation study on RISC workloads under increasingly ideal machine models remains a foundational reference. With an oracle machine (perfect branch prediction, unlimited issue, unlimited registers, perfect memory), integer programs exhibited ILP of roughly 7–58 and FP programs up to 75. These numbers represent a ceiling under the BSC/RAW-only constraint — the true dependence structure of real programs.

The conclusion: even ideal hardware cannot extract unbounded ILP from real programs because true dependences (particularly loop-carried ones and pointer chains) impose irreducible sequential structure.

#### The ILP Wall

Empirical and analytical studies converged on what became known as the **ILP wall** — the observation that real programs have limited exploitable ILP that practical microarchitectures can capture, typically 3–6 IPC for integer workloads. Beyond that, returns from wider issue diminish rapidly:

- **Control dependences**: branches occur every 5–10 instructions on average in integer code. Each misprediction flushes the pipeline and resets the instruction window. Branch prediction accuracy directly bounds the effective window of visible instructions.
- **Memory latency**: cache misses stall execution for tens to hundreds of cycles. Dependent loads create long critical paths that no amount of issue width can hide without prefetching or memory-level parallelism.
- **True data dependences**: pointer-chasing (linked lists, trees) produces dependence chains of depth proportional to data structure depth — each load depends on the previous load's result. Irreducible with renaming.
- **Finite instruction window**: an out-of-order machine can only find independent instructions within its reorder buffer (ROB) window. Beyond ~300–500 instructions, window size yields diminishing returns for typical code.

---

### Limits in Detail

#### Branch Prediction and the Effective Window

An out-of-order machine speculatively executes past branches. The number of in-flight instructions is bounded by the ROB size. For an IPC of 4 and a 200-entry ROB, the look-ahead window is ~50 cycles. If a branch misprediction occurs within that window, all speculative work is discarded.

With a branch every B instructions and prediction accuracy p, the expected number of correctly predicted branches before a mispredict is 1/(1−p). At p=0.95 and B=7, mispredictions occur every ~140 instructions — limiting the effective exploit window to roughly that range.

#### Memory-Level Parallelism vs. ILP

Memory-level parallelism (MLP) is the ability to have multiple cache misses in flight simultaneously. Out-of-order execution with a non-blocking cache can overlap independent misses. However, dependent loads (pointer chains) cannot overlap — each must complete before the next address is known. This creates long RAW chains that bottleneck ILP regardless of window size.

#### Amdahl's Law at the Instruction Level

If a fraction f of a program consists of instructions on the critical path (irreducibly sequential), the maximum speedup from ILP is:

$$\text{Speedup} \leq \frac{1}{f}$$

For integer workloads where roughly 30–50% of dynamic instructions are on some critical dependence chain, maximum speedup from ILP alone is bounded at 2–3×, regardless of issue width.

---

### Techniques for Exposing More ILP

These are addressed in detail in subsequent modules; listed here structurally:

|Technique|Mechanism|Scope|
|---|---|---|
|Out-of-order execution|Dynamic scheduling within ROB window|Hardware, runtime|
|Register renaming|Eliminates WAR and WAW dependences|Hardware|
|Speculative execution|Executes past unresolved branches|Hardware|
|Tomasulo's algorithm|Reservation stations + dynamic scheduling|Hardware|
|Loop unrolling|Replicates loop body to expose independent iterations|Compiler|
|Software pipelining (modulo scheduling)|Interleaves iterations of a loop|Compiler|
|Trace scheduling|Schedules across basic block boundaries along likely path|Compiler|
|VLIW|Compiler exposes ILP statically; hardware executes in parallel|Compiler + ISA|
|Prefetching|Hides memory latency to reduce critical path length|Hardware + Compiler|

---

### Flynn's Bottleneck and the Transition to Explicit Parallelism

By the mid-2000s, clock frequency scaling had reached its thermal limit (the **power wall**), and ILP exploitation through wider out-of-order machines was yielding diminishing returns (the **ILP wall**). The industry response was the shift to **thread-level parallelism** (multicore) and **data-level parallelism** (SIMD, GPU), which require explicit programmer or compiler exposure of parallelism rather than relying on hardware to discover it in a sequential instruction stream.

The ILP wall is thus not a fundamental physical barrier but a practical one: the amount of ILP in typical sequential programs is limited, and the hardware cost of extracting more (wider ROBs, more execution units, more complex schedulers) grows super-linearly with diminishing performance returns.

---

**Next Steps:** Out-of-order execution microarchitecture · Tomasulo's algorithm and reservation stations · Reorder buffer design · Register renaming implementation · Speculative execution and recovery · VLIW and compiler-driven ILP.

---

