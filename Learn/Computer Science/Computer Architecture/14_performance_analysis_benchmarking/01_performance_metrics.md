## Performance Metrics


### Framing: What Performance Metrics Measure

No single metric captures processor performance completely. Each metric isolates one dimension — instruction throughput, floating-point capacity, time — and is meaningful only within the context of a specific workload, ISA, and microarchitecture. Comparing metrics across these boundaries produces figures that are [Inference] suggestive at best and [Speculation] misleading at worst.

---

### Cycles Per Instruction (CPI)

CPI measures the average number of clock cycles consumed per instruction retired.

```
CPI = Total_Cycles / Instructions_Retired
```

It is the primary microarchitectural efficiency metric. A processor executing the same program with lower CPI is doing more work per cycle.

#### CPI Decomposition

CPI is not a monolithic quantity. It decomposes into a base component and a set of stall penalty terms:

```
CPI = CPI_base + CPI_stall

CPI_stall = Σ (Miss_Rate_i × Miss_Penalty_i)   for each memory hierarchy level i
           + Branch_misprediction_rate × Branch_penalty
           + Structural_hazard_stalls / Instructions
```

**Key Points:**

- `CPI_base` for an ideal in-order pipeline is 1.0 (one instruction retired per cycle).
- Out-of-order processors can achieve `CPI_base` below 1.0 by retiring multiple instructions per cycle — which transitions the natural metric to IPC.
- L1 miss rate, branch misprediction rate, and structural hazards are the dominant contributors to `CPI_stall` in modern cores.

#### CPI Across Microarchitectures

|Pipeline Type|Theoretical CPI Floor|
|---|---|
|Single-issue in-order|1.0|
|N-issue superscalar (ideal)|1/N|
|Out-of-order superscalar|< 1.0 (expressed as IPC > 1)|

---

### Instructions Per Cycle (IPC)

IPC is the reciprocal of CPI:

```
IPC = 1 / CPI = Instructions_Retired / Total_Cycles
```

It is the preferred metric for out-of-order and superscalar processors, where the design goal is to exceed 1 instruction per cycle. CPI below 1 is awkward to reason about; IPC above 1 is natural.

```
IPC = 2.4  →  CPI = 0.417
IPC = 0.8  →  CPI = 1.25   (pipeline frequently stalled)
```

#### IPC vs. Frequency: The Decoupling Problem

Two processors can have identical IPC but different performance if they run at different clock frequencies. Conversely, two processors at the same frequency can have radically different performance if IPC differs.

```
Execution_Time = Instruction_Count × CPI × (1 / Clock_Frequency)
               = Instruction_Count / (IPC × Frequency)
```

This is the **CPU performance equation**, which decomposes performance into three independently variable terms:

|Term|Controlled By|
|---|---|
|Instruction count|ISA, compiler, algorithm|
|CPI / IPC|Microarchitecture, memory system, branch predictor|
|Clock frequency|Process node, circuit design, voltage|

**Key Points:**

- A CISC processor executing one complex instruction may do the same work as three RISC instructions — lower instruction count, but potentially higher CPI per instruction. Comparing IPC across ISAs is [Inference] not straightforward and requires workload normalization.
- IPC is measured against instructions as counted by the ISA, not micro-ops. On x86, micro-op fusion and macro-op fusion affect how hardware IPC relates to ISA-level IPC.

#### Measuring IPC in Practice

Hardware performance counters expose:

```
INST_RETIRED.ANY    → instructions retired
CPU_CLK_UNHALTED    → cycles elapsed
IPC = INST_RETIRED / CPU_CLK_UNHALTED
```

Tools: `perf stat` (Linux), VTune, ARM Streamline. IPC measured this way is the **effective IPC** inclusive of all stalls — the ground truth for a given workload.

---

### MIPS (Millions of Instructions Per Second)

```
MIPS = (Instruction_Count / Execution_Time) / 10^6
     = (IPC × Clock_Frequency) / 10^6
```

MIPS collapses IPC and frequency into a single throughput figure. It was historically used when comparing processors of similar ISAs at similar frequency ranges, where instruction counts were comparable across programs.

#### Why MIPS Is an Unreliable Cross-Platform Metric

MIPS is instruction-count dependent, and instruction count is ISA-dependent. The same computation on x86 and RISC-V produces different instruction counts — MIPS figures are therefore not directly comparable.

Furthermore, within the same processor, MIPS varies by workload:

```
MIPS_integer_loop  ≠  MIPS_FP_intensive  ≠  MIPS_memory_bound
```

A memory-bound workload with many cache misses has low IPC and therefore low MIPS, even if the processor is capable of higher MIPS on other workloads. The number misrepresents the processor's capability.

**Key Points:**

- MIPS has been described as "Meaningless Indicator of Processor Speed" in the architecture literature — a colloquial acknowledgment of its limitations.
- It remains useful within a fixed ISA and workload class, e.g., comparing two ARM Cortex implementations running the same embedded control loop.
- Native MIPS (non-normalized) is not suitable for cross-ISA comparison.

#### Relative MIPS

A normalized variant: define 1 MIPS as the throughput of a reference machine (historically the VAX 11/780, rated at 1 MIPS). Other processors are then rated relative to that baseline. This was a precursor to modern SPECratio benchmarking but shares the same ISA-sensitivity problem.

---

### FLOPS (Floating-Point Operations Per Second)

FLOPS measures throughput of floating-point operations specifically. It is the dominant metric in HPC, ML training, and scientific computing, where floating-point arithmetic is the primary workload.

```
FLOPS = FP_Operations / Execution_Time
```

Reported at various scales:

|Prefix|Value|Context|
|---|---|---|
|MFLOPS|10⁶|Embedded processors, legacy|
|GFLOPS|10⁹|Desktop CPUs, game consoles|
|TFLOPS|10¹²|GPUs, AI accelerators|
|PFLOPS|10¹⁵|Supercomputers|
|EFLOPS|10¹⁸|Near-future systems|

#### Peak FLOPS vs. Sustained FLOPS

**Peak (theoretical) FLOPS** is computed from hardware specification:

```
Peak_FLOPS = Clock_Frequency × FP_units × FP_ops_per_cycle × Cores
```

For a processor with 2 FMA (Fused Multiply-Add) units per core, each FMA counts as 2 FP operations (one multiply + one add), executing 8 FP values per cycle (256-bit AVX2 / 32-bit):

```
Peak = 3.0 GHz × 2 FMA_units × 2 ops/FMA × 8 floats/cycle × 1 core
     = 3.0 × 10⁹ × 32 = 96 GFLOPS/core
```

**Sustained FLOPS** is measured on a real workload. It is always less than or equal to peak, bounded by:

- Memory bandwidth (if the workload is memory-bound, FP units sit idle waiting for data)
- Instruction-level parallelism (compiler must generate FMA chains that keep all FP units busy)
- Instruction scheduling and latency hiding

The **Roofline model** (Module 14) directly expresses this: a workload's arithmetic intensity (FLOPS/byte) determines whether it is compute-bound (sustained ≈ peak FLOPS) or memory-bound (sustained FLOPS ≪ peak).

#### Precision Variants

FLOPS ratings are precision-specific. Hardware may have different throughput at different precisions:

|Precision|Bits|Typical Use|
|---|---|---|
|FP64 (double)|64|Scientific simulation, CFD|
|FP32 (single)|32|Graphics, general ML inference|
|FP16 (half)|16|ML training (with FP32 accumulation)|
|BF16|16|ML training (Google TPU origin)|
|INT8 / FP8|8|Inference acceleration|

On modern GPUs (e.g., NVIDIA H100): FP64 peak < FP32 peak < FP16 peak < INT8 peak, often by factors of 2× or more per step, because lower-precision datapaths can be wider or clocked more aggressively. Comparing FLOPS figures across precisions is [Unverified] without knowing which precision each figure refers to.

**Key Points:**

- Peak FLOPS is a marketing figure. Sustained FLOPS on a real workload requires measurement.
- FMA counts as 2 FLOPS by convention in HPC, but some vendors count it as 1. Verify the counting convention before comparing figures across vendors.

---

### Relationship Between the Metrics

```
Execution_Time = IC × CPI × t_cycle
               = IC / (IPC × f)

MIPS = IC / (Execution_Time × 10⁶)
     = f × IPC / 10⁶

FLOPS = FP_fraction × IC × FP_ops_per_FP_instruction / Execution_Time
```

Where `IC` = instruction count, `f` = clock frequency, `FP_fraction` = fraction of instructions that are floating-point.

These relationships expose the dependencies:

- MIPS and FLOPS both depend on instruction count, which depends on the ISA and compiler.
- CPI/IPC are microarchitecture metrics, independent of frequency.
- Execution time is the only metric that directly answers "how long did this take?" — and is therefore the most honest single-number performance summary for a specific workload.

---

### Metric Applicability by Context

|Metric|Best Used For|Inappropriate For|
|---|---|---|
|CPI|Diagnosing pipeline efficiency, identifying stall sources|Cross-ISA comparison|
|IPC|Superscalar and OOO processor evaluation|Comparing processors at different frequencies|
|MIPS|Fixed-ISA throughput comparison (same ISA, similar programs)|Cross-ISA, cross-workload comparison|
|FLOPS (peak)|Characterizing hardware FP capacity|Predicting real application performance|
|FLOPS (sustained)|HPC and ML workload benchmarking|General-purpose workload characterization|
|Execution time|Definitive single-workload performance comparison|Generalizing across workloads|

---

### Common Measurement Pitfalls

**Warm vs. cold cache**: IPC measured with a warm cache is higher than with a cold cache. Benchmarks must specify cache state at measurement start.

**Frequency scaling**: modern processors use DVFS. IPC measured at boost frequency ≠ IPC at base frequency if the workload duration is short enough to remain in boost. `perf stat` reports actual measured frequency alongside IPC.

**Retired vs. issued instructions**: out-of-order processors issue speculative instructions that are later squashed. Performance counters typically report **retired** instructions (those that committed). IPC based on issued instructions overstates useful work.

**Turbo / boost effects on FLOPS**: peak FLOPS figures are often quoted at maximum boost frequency, achievable only for short bursts under low thermal load. Sustained FLOPS under thermal steady-state is lower.

**Micro-op expansion on x86**: a single x86 instruction may decode into multiple micro-ops. IPC at the ISA level and IPC at the micro-op level differ. Profiling tools must specify which level they report.

---

