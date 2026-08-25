## Benchmarking Methodologies


A benchmark is a workload with a defined measurement protocol whose purpose is to produce a reproducible, comparable performance number. The validity of any benchmark result depends entirely on whether the workload represents the application domain of interest, whether the measurement methodology controls for confounding factors, and whether the reported metric means what it is claimed to mean. This section treats three canonical benchmarks — SPEC CPU, STREAM, and Linpack — as case studies in methodology, not merely as numbers to memorize.

---

### What Benchmarks Measure and What They Do Not

Every benchmark measures performance on a specific workload under specific conditions. No benchmark measures "performance" as an absolute. The gap between benchmark score and application performance in production is determined by:

- **Workload representativeness**: how closely the benchmark's access patterns, instruction mix, and data sizes match the target application.
- **Measurement validity**: whether the timed interval captures steady-state behavior or includes initialization, I/O, or JIT warm-up.
- **Reproducibility**: whether the same hardware and software configuration reliably produces the same result.
- **Comparability**: whether two results produced under different conditions (compiler flags, OS, firmware) are meaningfully comparable.

These concerns motivate the formal run rules that accompany each major benchmark suite.

---

### SPEC CPU

#### Purpose and Scope

The **Standard Performance Evaluation Corporation (SPEC) CPU** suite is the industry-standard benchmark for measuring **compute-bound, single-node CPU performance**. It targets integer and floating-point throughput and is dominated by real application kernels drawn from scientific computing, compilation, compression, and simulation workloads.

The current suite is **SPEC CPU 2017**, which superseded SPEC CPU 2006. It contains two benchmark families:

|Family|Focus|Metric|
|---|---|---|
|**SPECspeed**|Single-instance latency|SPECspeed2017_int, SPECspeed2017_fp|
|**SPECrate**|Throughput (N copies in parallel)|SPECrate2017_int, SPECrate2017_fp|

SPECspeed measures how fast one workload completes. SPECrate runs N simultaneous copies (typically N = core count) and measures aggregate throughput. The two metrics are not interchangeable and answer different questions.

#### Workloads

**Integer benchmarks (SPECint)** include workloads such as compiler front-ends, XML processing, chess engines, and data compression. These stress branch prediction, cache behavior, and integer throughput.

**Floating-point benchmarks (SPECfp)** include weather modeling, finite element analysis, molecular dynamics, and ray tracing. These stress FPU throughput, vectorization, and memory bandwidth at working-set sizes that vary from cache-resident to memory-bound.

Each individual benchmark is run, timed, and normalized against a reference machine (a Sun Ultra 5 workstation for SPEC CPU 2006; a specific dual-socket Intel Xeon system for SPEC CPU 2017). The **geometric mean** of normalized ratios across all benchmarks in a family produces the reported score.

#### Geometric Mean Rationale

The geometric mean is used rather than arithmetic mean because the individual benchmark ratios span orders of magnitude. The geometric mean gives each benchmark equal multiplicative weight regardless of its absolute ratio, preventing a single high-ratio benchmark from dominating. If machine A is 2× faster on every benchmark than machine B, then A's score is exactly 2× B's score — a consistency property the arithmetic mean does not have for ratio data.

```
SPECscore = (∏ ratio_i)^(1/n)
           i=1 to n
```

#### Run Rules and Reporting

SPEC imposes detailed run rules governing:

- **Compiler and flags**: any compiler and optimization flags are permitted, but must be disclosed. Results are categorized as **"base"** (restricted, more conservative flags) and **"peak"** (unrestricted). Base results must use the same flags across all benchmarks in a family; peak allows per-benchmark tuning.
- **Operating system and libraries**: must be disclosed.
- **No algorithm changes**: the source code of the benchmarks may not be modified in ways that change the algorithm or output.
- **Result verification**: output must match reference checksums within tolerance.
- **Publication**: results must be submitted to SPEC and reviewed before public disclosure as "official."

Unofficial results (run without full compliance) exist but are not comparable to official submissions. The distinction matters for procurement decisions.

#### What SPEC CPU Does Not Measure

SPEC CPU explicitly excludes:

- **I/O performance**: benchmarks run from memory after initial load.
- **OS or system call overhead**: workloads are predominantly compute.
- **Multithreaded parallelism within a single benchmark**: SPECspeed runs one copy, single-threaded (except benchmarks that are inherently parallel, which are a minority).
- **Java or managed runtime performance**: SPEC has separate suites (SPECjvm, SPECjbb) for this.
- **GPU or accelerator performance**.

---

### STREAM

#### Purpose and Scope

**STREAM** (written by John McCalpin) measures **sustainable main memory bandwidth**. It is not a compute benchmark. Its purpose is to determine how fast the processor-memory subsystem can move data, which is the binding constraint for memory-bound applications.

STREAM is deliberately simple: four array operations on large arrays (sized to exceed all cache levels) iterated many times.

#### The Four Kernels

|Kernel|Operation|Bytes Read|Bytes Written|
|---|---|---|---|
|**Copy**|`C[i] = A[i]`|1 array|1 array|
|**Scale**|`B[i] = scalar × C[i]`|1 array|1 array|
|**Add**|`C[i] = A[i] + B[i]`|2 arrays|1 array|
|**Triad**|`A[i] = B[i] + scalar × C[i]`|2 arrays|1 array|

The **Triad** kernel is the most commonly cited result. It performs a multiply-add with two reads and one write per element, producing a bandwidth figure in GB/s.

The reported bandwidth is computed as:

```
Bandwidth (GB/s) = (bytes_accessed per iteration × iterations) / elapsed_time
```

Where bytes_accessed counts actual memory traffic (reads + writes), not flops.

#### Array Sizing Requirement

The fundamental requirement is that the arrays must be large enough that **no array fits in any level of cache**. STREAM's documentation specifies the array size must be at least 4× the size of the last-level cache. If the arrays fit in cache, the measured bandwidth reflects cache bandwidth — an entirely different and much larger number — which would be misleading for the benchmark's stated purpose.

This sizing requirement is frequently violated in informal STREAM runs reported without disclosure, making raw results non-comparable unless array size is stated.

#### Interpretation

STREAM Triad bandwidth is a **ceiling figure** for memory-bandwidth-bound workloads, not an achieved application bandwidth. Real applications achieve less than STREAM bandwidth because:

- They have irregular access patterns (STREAM accesses are perfectly sequential and prefetchable).
- They mix compute and memory access (STREAM is pure memory traffic).
- They have synchronization overhead and non-uniform thread placement.

STREAM is most useful for: comparing memory subsystems across platforms, verifying that hardware is performing to specification, diagnosing memory configuration issues (e.g., wrong DIMM slots populated, single-channel vs. quad-channel), and bounding the expected performance of memory-bound codes.

#### Multithreaded STREAM and NUMA Effects

STREAM is typically run with OpenMP parallelism, one thread per core. On NUMA systems, results depend critically on thread and memory placement. If all threads allocate memory in one NUMA node but run on another, remote memory accesses throttle bandwidth. Correct NUMA-aware execution (first-touch allocation, thread affinity set before allocation) is required to measure peak bandwidth. Comparing STREAM results across platforms without disclosing NUMA configuration is a common source of misleading comparisons.

---

### Linpack

#### Purpose and Scope

**Linpack** measures **floating-point throughput for dense linear algebra**, specifically the solution of a dense system of linear equations Ax = b via LU factorization with partial pivoting. It is the benchmark used to rank systems on the **TOP500** list of the world's most powerful supercomputers.

The original Linpack benchmark (Dongarra, 1979) solved a fixed-size problem. The **HPL (High-Performance Linpack)** benchmark, used for TOP500, allows the problem size N to be chosen by the user — a critical methodological distinction.

#### HPL Methodology

HPL solves a dense N×N system in double precision. The operation count is:

```
FLOPs = (2/3) N³ + O(N²)
```

The dominant term is the LU factorization, which is (2/3)N³ floating-point operations. The reported metric is:

```
R_peak efficiency = R_max / R_peak

R_max = FLOPs_computed / elapsed_time   (in GFLOPS or TFLOPS or PFLOPS)
R_peak = theoretical peak FP throughput of the system
```

**R_max** is the achieved rate. **R_peak** is the theoretical maximum derived from core count, frequency, and FMA width. HPL efficiency (R_max / R_peak) for modern GPU-accelerated clusters typically ranges from 60% to 80%; CPU-only systems are often 70–90%.

#### Problem Size Selection

The user selects N to maximize R_max. Larger N:

- Increases arithmetic intensity (FLOPs per byte), making the workload more compute-bound and less memory-bandwidth-bound.
- Requires more memory: the matrix consumes approximately 8N² bytes (double precision). An N=100,000 matrix requires ~80 GB.

The freedom to choose N means HPL results are not directly comparable between systems with different memory capacities: a system with more memory can use a larger N, achieving higher efficiency. This is an intentional feature (maximizing reported performance) but must be understood when interpreting rankings.

#### Parallelization

HPL uses a 2D block-cyclic decomposition of the matrix across a process grid of P×Q MPI ranks. Block size NB (typically 256–1024) controls granularity. Optimal P, Q, and NB are tuned by the submitter for each system. The benchmark is explicitly an optimized, tuned run — it measures what the system can achieve when configured for this specific workload, not typical application performance.

#### What Linpack Does Not Measure

HPL is a **single-workload**, **single-precision-insensitive** (it uses only FP64), **dense linear algebra** benchmark. It does not measure:

- Sparse linear algebra performance (different memory access patterns, cache behavior).
- Mixed-precision performance (relevant for AI training, which uses FP16/BF16).
- Latency-sensitive or irregular workloads.
- Any workload other than LU factorization.

The **HPCG (High-Performance Conjugate Gradient)** benchmark was introduced as a complement to HPL specifically because HPL's dense, regular access patterns are unrepresentative of many HPC workloads. HPCG uses sparse matrix-vector products and exhibits much lower hardware efficiency — typically 2–10% of R_peak — and is considered a more representative stress test for memory bandwidth and network latency.

---

### Comparative Summary

|Property|SPEC CPU 2017|STREAM|HPL (Linpack)|
|---|---|---|---|
|**Primary metric**|Normalized ratio (geometric mean)|Memory bandwidth (GB/s)|FP64 throughput (GFLOPS/TFLOPS)|
|**Bound**|Compute + cache behavior|Memory bandwidth|Compute (dense FP64)|
|**Workload type**|Diverse real applications|Pure memory copy/add|Dense LU factorization|
|**Parallelism**|Per-benchmark; rate = N copies|OpenMP threads|MPI + OpenMP|
|**Problem size**|Fixed|Must exceed LLC|User-chosen (tuned)|
|**Primary use**|CPU procurement, compiler evaluation|Memory subsystem verification|Supercomputer ranking (TOP500)|
|**What it does not measure**|I/O, GPU, multithreaded scaling|Compute, irregular access|Sparse LA, mixed precision, latency|

---

### Methodological Pitfalls

#### Benchmark Optimization vs. General Optimization

Compiler and hardware vendors invest significantly in optimizing for published benchmarks. Techniques that improve benchmark scores but not general application performance include:

- **Profile-guided optimization (PGO) trained on the benchmark itself**: illegal under SPEC base rules, but peak runs permit it.
- **Auto-vectorization tuned to benchmark loop structures**: legitimately improves the benchmark and likely generalizes, but not always.
- **Hardware prefetchers trained on sequential access**: STREAM and HPL benefit maximally; irregular applications do not.

The result is that benchmark scores can overstate performance on real workloads if the real workload's characteristics differ from the benchmark's.

#### Turbo Boost and Frequency Scaling

Modern processors sustain higher clock frequencies for short-duration workloads than for sustained ones. A benchmark that runs for 30 seconds may execute entirely in a boosted frequency state. A production workload running continuously for hours operates at a lower sustained frequency. SPEC CPU runtimes are typically long enough to observe sustained behavior, but short microbenchmarks are not.

#### Memory Configuration Sensitivity

STREAM and HPL results are highly sensitive to memory channel count, DIMM population, and NUMA topology. Two platforms with identical processors but different memory configurations can show 2× differences in STREAM bandwidth. Benchmark reports that do not disclose memory configuration in full are not reproducible.

#### Single-Node vs. Scale-Out

SPEC CPU and STREAM are single-node benchmarks. HPL scales across nodes via MPI but measures a single monolithic problem. Neither class measures distributed application performance, inter-node network behavior, or storage I/O. The **SPEC MPI** and **NAS Parallel Benchmarks (NPB)** address parallel scaling; **IOzone** and **fio** address storage.

---

### The Roofline Model as Benchmark Interpreter

The **Roofline model** provides a framework for interpreting where a workload sits relative to the bounds measured by STREAM and Linpack:

```
Attainable performance = min(R_peak, bandwidth × arithmetic_intensity)
```

Where **arithmetic intensity** (AI) is FLOPs per byte of DRAM traffic. STREAM measures the bandwidth ceiling; HPL/R_peak measures the compute ceiling. A workload with AI below the ridge point (bandwidth × AI < R_peak) is memory-bandwidth bound — STREAM bandwidth predicts its ceiling. A workload with AI above the ridge point is compute-bound — R_peak predicts its ceiling.

<svg viewBox="0 0 620 320" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- Axes --> <line x1="60" y1="260" x2="590" y2="260" stroke="#555577" stroke-width="1.5"/> <line x1="60" y1="260" x2="60" y2="30" stroke="#555577" stroke-width="1.5"/> <!-- Axis labels -->

<text x="590" y="275" fill="#888888" font-size="10">Arithmetic Intensity (FLOP/byte) →</text> <text x="10" y="150" fill="#888888" font-size="10" transform="rotate(-90,20,150)">Performance (GFLOPS) →</text>

<!-- Roofline: memory-bound slope --> <!-- Ridge point at x=240, y=100 (arbitrary units mapped to SVG) --> <line x1="60" y1="260" x2="270" y2="80" stroke="#4a9eff" stroke-width="2"/> <!-- Roofline: compute ceiling --> <line x1="270" y1="80" x2="580" y2="80" stroke="#55cc55" stroke-width="2"/> <!-- Ridge point marker --> <circle cx="270" cy="80" r="5" fill="#ffcc44" stroke="#ffcc44"/> <text x="275" y="75" fill="#ffcc44" font-size="10">Ridge point</text> <!-- Labels -->

<text x="80" y="200" fill="#4a9eff" font-size="10">Memory-bandwidth</text> <text x="80" y="212" fill="#4a9eff" font-size="10">bound (slope = BW)</text> <text x="380" y="72" fill="#55cc55" font-size="10">Compute bound (R_peak)</text>

<!-- STREAM arrow --> <line x1="80" y1="255" x2="80" y2="235" stroke="#4a9eff" stroke-width="1.2" stroke-dasharray="3,2" marker-end="url(#c1)"/> <text x="55" y="270" fill="#4a9eff" font-size="9">BW from</text> <text x="52" y="280" fill="#4a9eff" font-size="9">STREAM</text> <!-- HPL arrow --> <line x1="500" y1="255" x2="500" y2="88" stroke="#55cc55" stroke-width="1.2" stroke-dasharray="3,2" marker-end="url(#c1)"/> <text x="468" y="270" fill="#55cc55" font-size="9">R_peak from</text> <text x="472" y="280" fill="#55cc55" font-size="9">HPL / spec</text> <!-- Example workload point --> <circle cx="180" cy="155" r="5" fill="#ff8855" stroke="#ff8855"/> <text x="185" y="153" fill="#ff8855" font-size="10">memory-bound app</text> <circle cx="420" cy="120" r="5" fill="#cc88ff" stroke="#cc88ff"/> <text x="425" y="118" fill="#cc88ff" font-size="10">compute-bound app</text> <defs> <marker id="c1" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#aaaaaa"/> </marker> </defs> </svg>

This makes STREAM and Linpack complementary rather than redundant: one characterizes the memory wall, the other the compute ceiling, and together they bound what any workload can achieve on a given platform.

---

**Key Points**

- SPEC CPU 2017 measures compute-bound CPU performance using real application kernels; the geometric mean of normalized ratios is the reported score; base and peak runs have different compiler-flag constraints.
- STREAM measures sustainable DRAM bandwidth; array size must exceed LLC; NUMA-aware execution is required for valid results on multi-socket systems.
- HPL measures FP64 dense LU factorization throughput; problem size is user-tunable to maximize efficiency; it is the TOP500 ranking metric but unrepresentative of many HPC workloads.
- All three benchmarks are narrow in scope; no single benchmark characterizes overall system performance.
- The Roofline model uses STREAM bandwidth and peak FLOP rate together to bound attainable performance for any workload given its arithmetic intensity.

**Conclusion** Benchmark methodology is as important as benchmark results. A score without its run configuration, compiler flags, memory topology, and problem size parameters is not reproducible and not comparable. The three benchmarks examined here collectively characterize the two fundamental limits of a compute node — memory bandwidth and peak FP throughput — and the compute-bound behavior of real application code. Understanding their design constraints and blind spots is prerequisite to using them as decision-making tools rather than marketing figures.

**Next Steps** Proceed to **Roofline Model** for the full treatment of arithmetic intensity analysis and performance bound derivation, **Performance Counters and Profiling** for hardware-level measurement methodology, and **Amdahl's Law and Gustafson's Law** for scaling analysis that contextualizes what benchmark gains translate to in parallel workloads.

---

