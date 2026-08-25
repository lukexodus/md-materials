## Multithreading


### Overview

A single-threaded processor wastes the majority of its execution cycles waiting — on cache misses, branch mispredictions, and long-latency instructions. Multithreading is the architectural strategy of keeping execution resources occupied during those stalls by maintaining the state of more than one thread on the same processor core, interleaving their execution to fill the gaps.

Three distinct forms exist, differentiated by the granularity at which threads are switched and the degree of hardware duplication required: coarse-grained, fine-grained, and simultaneous multithreading (SMT). Each trades different quantities of hardware complexity, single-thread performance, and throughput.

---

### The Stall Problem and the Case for Multithreading

A superscalar out-of-order processor has a pipeline of 10–20+ stages and an issue width of 4–8 instructions per cycle. Despite out-of-order execution and speculative execution drawing from a reorder buffer of 100–300+ entries, execution resources go idle when:

- An L2 or L3 cache miss stalls the load/store pipeline for 10–300 cycles.
- A branch misprediction flushes the pipeline and requires a refill of 15–20 cycles.
- Long-latency floating-point or division operations occupy functional units.
- Structural hazards exhaust a particular functional unit class.

The IPC of a memory-bound workload on a single-threaded core can collapse to 0.1–0.3 from a theoretical peak of 4–8. Multithreading is the response: while one thread stalls, another thread's instructions are ready to fill the vacant issue slots.

The key insight is that multithreading trades **latency** for **throughput**. It does not accelerate any single thread — it amortizes idle resources across threads. This trade-off is central to all three forms.

---

### Hardware State Per Thread

Every thread context requires its own copy of:

- **Program counter (PC):** Points to the thread's next instruction.
- **General-purpose register file:** A full set of architectural registers (32 × 64-bit for RISC-V or ARM64; 16 × 64-bit for x86-64).
- **Condition codes / status flags**
- **Control and status registers (CSRs):** Privilege level, floating-point rounding mode, exception vectors, etc.

Shared between threads on the same core:

- Instruction cache and data cache
- TLB (usually, with ASID tagging to distinguish address spaces)
- Execution units (ALUs, FPUs, load/store units)
- Branch predictor (partially — SMT complicates this)
- Reorder buffer and reservation stations (in SMT)

The amount of hardware that must be replicated per thread defines the silicon area cost of supporting N hardware threads.

---

### Coarse-Grained Multithreading

#### Mechanism

In coarse-grained multithreading (CGMT), the processor executes instructions from a single thread until a **long-latency event** occurs — almost exclusively an L2/L3 cache miss or an explicit trap. At that point, the processor performs a **full pipeline flush**, switches thread context (swapping the PC and register file pointer to a different hardware thread), and resumes execution from the new thread. When the original thread's miss returns from memory, it becomes eligible to resume.

The switch threshold is typically tens of cycles. Context switch overhead is several cycles for the pipeline flush and register state reload.

#### Why Coarse-Grained Is Rarely Sufficient

The fundamental limitation is that CGMT is reactive and coarse. The pipeline flush incurred on every context switch is itself a performance penalty, and the switch only fires on long events. Shorter stalls — branch mispredictions, structural hazards — do not trigger a switch, so those cycles remain wasted. The processor still sees large windows of idleness between the stall detection and the point at which the new thread fills the pipe.

CGMT was used in early multithreaded designs such as the **IBM AS/400** processor and the **MIPS MT** extension. It is now largely superseded by fine-grained or SMT in high-performance designs, though it remains relevant in deeply embedded contexts where hardware simplicity matters more than throughput.

---

### Fine-Grained Multithreading

#### Mechanism

In fine-grained multithreading (FGMT), the processor switches thread context on **every single clock cycle** in a round-robin (or priority-weighted) schedule, regardless of whether the current thread is stalled. Each thread gets one cycle in rotation; the pipeline stages are occupied by instructions from different threads at every cycle.

Because thread N+1 is ready the moment thread N's cycle ends, the switch overhead approaches zero — there is no flush, because instructions from different threads never interact in the pipeline. The pipeline can be kept continuously full as long as enough threads are available and at least one thread has a ready instruction.

#### Pipeline Behavior

Consider a 4-thread FGMT design. In steady state:

```
Cycle:    1      2      3      4      5      6      7      8
Stage:   T0     T1     T2     T3     T0     T1     T2     T3
Fetch    I0     I0     I0     I0     I1     I1     I1     I1
Decode   —      I0     I0     I0     I0     I1     I1     I1
Issue    —      —      I0     I0     I0     I0     I1     I1
```

The inter-thread spacing eliminates all data hazards between threads (each thread's instructions are separated by at least N−1 cycles), and structural hazards are reduced because no two threads contend for the same resource in the same cycle.

#### The Single-Thread Performance Penalty

The cost is severe for single-thread latency. A thread that has no stalls and is compute-bound receives only 1/N of the pipeline's time, running at 1/N its potential throughput. On a 4-thread FGMT core, a CPU-bound thread sees 25% of effective throughput compared to a dedicated core.

FGMT is therefore viable only when workloads are inherently parallel and memory-bound — each thread is expected to stall frequently, and the round-robin schedule is the mechanism to hide those stalls.

#### Historical Usage

The canonical implementation is the **Sun UltraSPARC T1 (Niagara)**, which ran 4 fine-grained hardware threads per core across 8 cores (32 hardware threads total) on a single chip. It was designed explicitly for throughput-oriented server workloads (web serving, database query) where every thread is memory-bound and per-thread latency is less important than aggregate throughput. The T1 had a deliberately simple in-order pipeline; the FGMT mechanism was sufficient to keep it busy.

---

### Simultaneous Multithreading (SMT)

#### Motivation

Both CGMT and FGMT use a single thread's instruction stream at any given moment. The issue slots of a wide superscalar processor are filled from one thread's window of instructions. If that thread's instruction-level parallelism (ILP) is limited — and most real programs have bounded ILP — some issue slots go unused even when the thread is not stalled.

SMT is the observation that **two orthogonal dimensions of parallelism exist**: ILP within one thread, and TLP (thread-level parallelism) across threads. An SMT processor exploits both simultaneously. In every cycle, the front end fetches and decodes instructions from multiple threads, and the out-of-order back end issues from a shared pool of ready instructions across all threads to fill all available execution slots.

#### Architecture

The structural requirements of SMT are more substantial than CGMT or FGMT:

**Replicated per logical thread:**

- Program counter
- Architectural register file (or at minimum, the register rename map — the RAT/ROB entries)
- Retirement state and exception handling
- Active list / ROB head pointer

**Shared and partitioned:**

- Reorder buffer: entries are tagged by thread ID; the ROB is partitioned (statically or dynamically) across threads.
- Reservation stations / issue queues: instructions from all threads compete for entries; the oldest-ready instruction across all threads is issued.
- Physical register file: shared pool; the rename stage pulls from it regardless of thread.
- L1 instruction cache and data cache: shared, accessed concurrently.
- Branch predictor: shared; SMT creates interference between threads' prediction histories (a known correctness and performance concern).
- Fetch bandwidth: partitioned each cycle by a fetch policy (round-robin, IPC-driven, ICOUNT).

The fundamental SMT trade-off: the ROB, issue queue, and register file — resources sized for one thread — must now accommodate instructions from N threads. Each resource is effectively shared. A thread that generates many outstanding cache misses can fill the ROB and starve the other thread of ROB entries, a well-known SMT pathology.

#### Fetch Policy

The front end must decide each cycle which thread(s) to fetch from. Common policies:

- **Round-robin:** Alternate threads in strict rotation. Simple; performs well when threads have similar IPC.
- **ICOUNT:** Prefer the thread with the fewest instructions currently in the pipeline (fewest ROB entries). Empirically effective — it implicitly prioritizes threads that are making progress over stalled threads.
- **Stall-aware / flush-on-stall:** Temporarily stop fetching from a thread that has a long-latency miss pending; redirect all fetch bandwidth to the other thread. Recovers single-thread efficiency during the other thread's stall.

#### Intel Hyper-Threading Technology (HT)

Intel's implementation of SMT, introduced in the **Pentium 4 Northwood** (2002) and present in most subsequent Intel client and server processors, exposes 2 logical processors per physical core to the operating system. Each logical processor has its own architectural state (APIC, PC, registers, flags). The physical core's resources — ROB, reservation station, execution units, caches — are shared.

Intel's published figures [Unverified — die area numbers are not independently confirmed] suggest each additional logical processor adds approximately 5% die area overhead per physical core, while offering throughput improvements of 15–30% on mixed workloads — a highly favorable area-efficiency trade-off.

HT interacts directly with the operating system scheduler: the OS must be HT-aware to avoid scheduling two threads on the same physical core when idle physical cores exist, which would sacrifice both threads' performance while leaving physical cores dormant.

#### ARM SMT

ARM introduced SMT capability in the **Cortex-X4** and related cores (Armv9 generation). Earlier ARM server designs (Neoverse N1, V1) were single-threaded per core, relying on high core counts for throughput. The architectural decision to add SMT to Arm reflects convergence with the same workload pressures that motivated Intel and IBM's SMT implementations.

IBM's **POWER** architecture has supported 2-way, 4-way, and 8-way SMT (the latter on POWER9/POWER10) for server workloads, with the ability to switch SMT mode at runtime depending on workload character.

---

### Comparative Analysis

The three strategies are best understood as a spectrum on two axes: **switch granularity** (when threads swap) and **issue-slot sharing** (how many threads contribute instructions in the same cycle).

The diagram below illustrates how each strategy occupies the pipeline over time.The key distinction the diagram makes visible: CGMT leaves large contiguous blocks of wasted slots around stall and flush events. FGMT fills every cycle but restricts each thread to 1/N of the pipeline. SMT fills the issue width across threads simultaneously — the two threads pool their ready instructions into a shared issue window, so neither a stall in one thread nor limited ILP in one thread wastes the other thread's potential.

---

### SMT Resource Contention and Interference

SMT's shared resources create contention that can degrade both threads compared to running alone. The most significant interference vectors:

**ROB pressure:** A thread with many outstanding cache misses can monopolize ROB entries. Older instructions from that thread cannot retire, blocking allocation of new entries. The other thread may be unable to allocate ROB entries for its own instructions even though its instructions are ready to execute.

**L1/L2 cache thrashing:** If both threads have large working sets, their combined footprint exceeds the cache capacity. Each thread evicts the other's data, elevating the miss rate for both beyond what either would experience alone. This is the primary cause of SMT hurting performance on workloads that are individually cache-efficient.

**Branch predictor pollution:** The branch history table and pattern history table are shared (or only lightly partitioned) between threads. Thread 1's branch outcomes write into the same predictor state that thread 0 uses. This cross-thread prediction interference increases misprediction rates. [Inference — the magnitude of this effect is workload-dependent and not universally quantified.]

**Fetch bandwidth competition:** The front end has fixed fetch bandwidth (e.g., 16 bytes/cycle). When both threads are decode-bound rather than stall-bound, they compete for this bandwidth and each receives less than a single-threaded core would.

**Mitigation mechanisms:** Modern processors include partial mitigations — logical processor tagging in branch predictors (TAGE predictors with thread bits), dynamic ROB partitioning policies that cap one thread's allocation when the other is starved, and fetch throttling policies (ICOUNT) that shift bandwidth to the thread making less progress.

---

### SMT and Security: Side-Channel Attacks

SMT's resource sharing creates a class of microarchitectural side-channel vulnerabilities that are absent in single-threaded or coarse-grained designs.

**Cache timing side channels:** Because L1D and L2 are shared, a spy thread on the co-scheduled logical processor can infer the memory access pattern of a victim thread by measuring cache evictions (Flush+Reload, Prime+Probe). This has been exploited to recover cryptographic keys from co-located threads.

**Spectre variant 4 / SMT-specific Spectre:** Speculative execution across SMT threads interacts with shared predictor state to enable cross-thread speculation attacks.

**Port contention:** Sharing of execution ports (execution units) between SMT threads allows a spy to infer which ports the victim is using by measuring its own execution latency — a covert channel requiring no shared memory.

**Mitigations:** Operating systems and hypervisors can disable SMT entirely (the strongest mitigation, at throughput cost), or implement core scheduling — a policy that never co-schedules threads from different security domains (different VMs, different users) on the same physical core. Linux's `nosmt` kernel parameter and AMD's SMT scheduling policies implement forms of this.

---

### Performance Characterization by Workload

|Workload type|SMT behavior|
|---|---|
|Memory-bound (HPC, databases)|High benefit — stall cycles from one thread filled by the other|
|Latency-sensitive (gaming, single-threaded)|Slight degradation — the other thread competes for cache and execution resources|
|Throughput server (web, JVM, scripting)|Moderate-to-high benefit — mixed ILP and memory-bound characteristics|
|Crypto / security-sensitive|Disable SMT or use core scheduling — side-channel exposure|
|SIMD-heavy (media encoding, ML inference)|Neutral to negative — SIMD instructions consume full execution unit width; no benefit from SMT|
|Compilations / make -j|Positive — many threads, all memory-bound on different source files|

---

### Summary Table

|Property|Coarse-grained|Fine-grained|SMT|
|---|---|---|---|
|Switch trigger|Long-latency stall|Every cycle|Continuous (same cycle)|
|Pipeline flush on switch|Yes|No|N/A|
|Issue slots per cycle|1 thread|1 thread (rotated)|Multiple threads|
|Single-thread performance|Full (when active)|1/N degraded|Near-full (when alone)|
|Area overhead per thread|Low|Low|Moderate (~5%)|
|Hardware complexity|Low|Moderate|High|
|Handles short stalls|No|Yes|Yes|
|Handles ILP gaps|No|No|Yes|
|Cache interference|Minimal|Minimal|Significant|
|Representative implementation|IBM AS/400, MIPS MT|Sun UltraSPARC T1|Intel HT, IBM POWER, ARM Cortex-X4|

---

**Next Steps:** The most directly connected topics are **out-of-order execution and the reorder buffer** (the shared ROB is what makes SMT architecturally possible — and constrains it), **branch prediction** (shared predictor state is both the mechanism of cross-thread speculation improvement and the source of Spectre-class vulnerabilities in SMT), and **power and thermal management / DVFS** (SMT's throughput gain interacts with dynamic voltage and frequency scaling because higher utilization of execution units raises power density per physical core).

---

