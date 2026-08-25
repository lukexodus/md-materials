## Amdahl's Law


Amdahl's Law is a mathematical bound on the speedup achievable by parallelizing a fixed workload. It does not describe how hardware works — it describes an inescapable arithmetic constraint that hardware and software designers must work within. The central insight is that the sequential fraction of any workload sets a hard ceiling on parallel speedup, independent of how many processors are added.

---

### Derivation from first principles

Let a workload have total sequential execution time $T$. Define $p$ as the fraction of that workload that can be parallelized, so $(1 - p)$ is the fraction that must remain sequential. With $N$ parallel processors, the parallel portion takes $T \cdot p / N$, and the sequential portion takes $T \cdot (1-p)$ unchanged.

Total execution time with $N$ processors:

$$T(N) = T(1-p) + T \cdot \frac{p}{N}$$

Speedup $S(N)$ is the ratio of original time to new time:

$$S(N) = \frac{T}{T(1-p) + T \cdot \frac{p}{N}} = \frac{1}{(1-p) + \frac{p}{N}}$$

As $N \to \infty$, the parallel term vanishes:

$$S(\infty) = \frac{1}{1-p}$$

This is the hard ceiling. It depends only on the sequential fraction. The number of processors is irrelevant once $N$ is large enough to make $p/N$ negligible.

---

### The ceiling in numbers

The sequential fraction dominates the limit far more aggressively than intuition suggests:

|Sequential fraction $(1-p)$|Maximum speedup $S(\infty)$|
|---|---|
|50%|2×|
|25%|4×|
|10%|10×|
|5%|20×|
|1%|100×|
|0.1%|1000×|

A program that is 95% parallel and 5% sequential cannot exceed 20× speedup regardless of processor count. Adding the 1001st processor to a problem with 1% sequential overhead yields essentially zero marginal gain.---

### Efficiency and diminishing returns

Speedup alone does not capture resource utilization. **Parallel efficiency** $E(N)$ is the fraction of theoretical linear speedup that is actually realized:

$$E(N) = \frac{S(N)}{N} = \frac{1}{N(1-p) + p}$$

At $N=1$, $E=1$ always. As $N$ grows, $E$ falls monotonically. For $p=0.95$ and $N=20$, $S \approx 11.1$, so $E = 11.1/20 = 55.5%$ — nearly half the processors are wasted due to the sequential bottleneck. This is the direct economic argument against naïve scaling: doubling the processor count on a real workload does not double throughput, and the marginal processor contributes progressively less than its predecessors.

---

### Decomposing the sequential fraction

Understanding what actually constitutes the sequential fraction is necessary to reason about whether it can be reduced.

**Algorithm-intrinsic serialization:** Some computations have true data dependencies that enforce a serial order. A recurrence relation $x_i = f(x_{i-1})$ cannot begin iteration $i$ until iteration $i-1$ is complete, regardless of hardware. Fibonacci, SHA hash chains, and many numerical integrators have this property.

**Synchronization overhead:** Barrier operations, mutex acquisition, and collective communications in distributed memory systems all force processors to wait for the slowest participant. Even if the work between barriers is perfectly parallel, the barriers themselves serialize. In an MPI program with $k$ barriers per time unit, the time spent in barrier synchronization contributes directly to $(1-p)$.

**Critical sections:** Code protected by a lock serializes all threads that try to acquire it. Amdahl's Law applies per critical section: a single lock protecting a shared counter accessed by 64 threads means up to 64 threads queued serially, regardless of how parallel the rest of the application is.

**I/O and memory bandwidth bottlenecks:** When multiple cores compete for the same DRAM bandwidth or storage interface, the effective parallelism is capped by the bandwidth, not the core count. This is not captured in the standard Amdahl model but behaves analogously — it appears as an artificial increase in the sequential fraction.

**Sequential setup and teardown:** Program initialization, result aggregation, and file I/O framing code that runs on a single thread before and after the parallel region adds directly to $(1-p)$.

---

### Visualizing time decomposition

The most direct way to see Amdahl's Law is to examine where time is actually spent as $N$ increases:The serial floor is the irreducible bar of red. No matter how many processors are added, total execution time cannot fall below it.

---

### The strong scaling assumption and its implications

Amdahl's Law applies to **strong scaling**: the total problem size is fixed, and more processors are used to solve it faster. This is the regime where Amdahl's bound is most punishing because the sequential fraction is a fixed absolute amount of work, and as $N$ grows, the parallel work per processor shrinks toward zero while the sequential work remains constant.

This is to be distinguished from **weak scaling** (Gustafson's model), in which the problem size grows with $N$, keeping the per-processor workload constant. In weak scaling the sequential fraction may remain a small fraction of the total work even at large $N$, because the parallel work grows proportionally. Amdahl and Gustafson are not in conflict — they describe different operational regimes. The question of which model is relevant is empirical: is the user's actual workload fixed-size or does it scale with available hardware?

---

### Extensions and refinements

**Amdahl with parallelization overhead.** Real parallel execution is not free. Spawning threads, synchronizing, and aggregating results take time $T_{overhead}(N)$, which typically grows with $N$. A refined model:

$$S(N) = \frac{1}{(1-p) + \frac{p}{N} + \kappa(N)}$$

where $\kappa(N)$ is the overhead term. For fine-grained parallelism on shared-memory machines, $\kappa$ grows slowly (barrier cost, cache coherence traffic). For distributed-memory systems with all-reduce communications, $\kappa$ can grow as $O(\log N)$ or $O(N)$, causing speedup to peak at some finite $N$ and then decline — a curve that turns over, which pure Amdahl does not predict.

**Memory bandwidth as a serial bottleneck.** On NUMA or bandwidth-limited systems, even code with no explicit serialization can be effectively serialized by the memory subsystem. The Roofline model captures this separately, but architecturally it manifests as an Amdahl-like ceiling: doubling cores does not double throughput once the memory bus is saturated.

**Heterogeneous Amdahl.** In a processor with fast cores and slow cores (big.LITTLE, or a CPU + GPU system), the sequential fraction should run on the fastest available core. If the fast core is $r$ times faster than the unit used to define $T$:

$$S(N) = \frac{1}{\frac{1-p}{r} + \frac{p}{N}}$$

This moves the ceiling upward (the sequential term shrinks by $r$), which is the architectural argument for retaining a few very fast out-of-order cores alongside many simple ones. Intel's Thread Director and ARM's DynamIQ implement exactly this policy in hardware.

---

### Amdahl's Law as an architectural design constraint

Amdahl's Law is not merely a performance analysis tool — it is a design input. Several architectural decisions are direct responses to it.

**Reducing the sequential fraction structurally.** Techniques like speculative execution, out-of-order execution, branch prediction, and prefetching all exist in part to remove artificial serialization from single-threaded code — to allow the CPU to find and execute parallel work that the program text presents as sequential. This increases the effective $p$ for instruction-level parallelism before thread-level parallelism is even considered.

**Minimizing synchronization granularity.** Lock-free data structures, read-copy-update (RCU), and transactional memory all aim to reduce the fraction of time threads spend in serialized critical sections — directly attacking $(1-p)$ at the software-hardware interface.

**Hardware support for fast barriers and atomics.** Cache coherence protocols that implement atomic read-modify-write in hardware (rather than software locking) reduce the latency of each synchronization event. This does not change the sequential fraction conceptually, but reduces $T$ for the sequential portions, which in practice often makes previously impractical parallelization practical.

**Specialization over scaling.** When the sequential fraction is algorithm-intrinsic and cannot be reduced, adding more general-purpose processors is provably wasteful past a saturation point. The architectural response is to deploy faster specialized hardware (a TPU, an FPGA, a cryptographic accelerator) on the bottleneck path, increasing $r$ in the heterogeneous model rather than increasing $N$.

---

**Key Points:** Amdahl's Law states $S(N) = 1/[(1-p) + p/N]$, giving a hard ceiling $S(\infty) = 1/(1-p)$ determined entirely by the sequential fraction. The bound is arithmetic, not physical — it cannot be bypassed by hardware design, only shifted by reducing $(1-p)$ or by heterogeneous acceleration of the sequential path. Parallel efficiency $E(N) = S(N)/N$ falls monotonically with $N$, making the marginal processor increasingly unproductive. The law assumes strong scaling (fixed problem size); Gustafson's Law addresses the weak scaling regime. Real systems experience additional overhead terms that cause speedup to peak and decline before the asymptotic ceiling is reached.

**Next Steps:** Gustafson's Law and the weak scaling perspective, the Roofline model (which introduces bandwidth as a separate architectural ceiling orthogonal to Amdahl's), or memory consistency models (which determine the hardware cost of the synchronization that enforces serialization).

---

