## Roofline Model


The Roofline model is a visually intuitive, bounds-based performance model that characterizes the achievable performance of a computational kernel on a given hardware platform as a function of the kernel's arithmetic intensity. It identifies whether a kernel is limited by compute throughput or memory bandwidth, and quantifies how far actual performance lies from the relevant hardware ceiling. It was formalized by Williams, Waterman, and Patterson in 2009, though the underlying concepts of compute-bound versus memory-bound analysis predate that publication.

---

### Motivation

Raw peak FLOPS and peak memory bandwidth are both necessary but individually insufficient characterizations of achievable performance. A kernel that performs little arithmetic per byte of data moved will saturate memory bandwidth long before approaching peak FLOPS. A kernel that reuses data extensively will be limited by compute throughput. The Roofline model makes this relationship explicit and operational.

---

### Arithmetic Intensity

**Arithmetic intensity (AI)** is the ratio of floating-point operations performed to bytes of data transferred between the processor and a specified level of the memory hierarchy — typically main memory (DRAM).

$$AI = \frac{\text{FLOPs}}{\text{Bytes transferred}}$$

Units are **FLOP/byte**. AI is a property of the algorithm and data reuse pattern, not the hardware. Two implementations of the same algorithm may have different effective AI if one caches data and reuses it while the other streams without reuse.

**Example computations of AI:**

|Kernel|FLOPs|Bytes (double precision)|AI|
|---|---|---|---|
|STREAM Triad (`A[i] = B[i] + s*C[i]`)|2N|24N|~0.083|
|Sparse matrix-vector (SpMV)|~2 nnz|~(8 nnz + 8N)|~0.17–0.25|
|Dense matrix-vector (GEMV)|2N²|8N² + 16N|~0.25|
|Dense matrix-matrix (GEMM, large N)|2N³|24N²|~N/12|
|N-body (all-pairs)|~20N²|24N|~N/1.2|

Dense matrix-matrix multiplication (GEMM) has AI that grows with N — for large matrices, data reuse in cache means bytes transferred to DRAM grow as N² while FLOPs grow as N³. This is why GEMM is the canonical compute-bound kernel at scale.

---

### The Roofline Bound

For a given hardware platform, define:

- $\pi$ — peak floating-point throughput (FLOP/s), e.g., 10 TFLOP/s
- $\beta$ — peak memory bandwidth (byte/s), e.g., 900 GB/s
- $I$ — arithmetic intensity of the kernel (FLOP/byte)

The achievable performance $P$ (FLOP/s) is bounded by:

$$P \leq \min(\pi,\ \beta \times I)$$

This produces two bounding lines when plotted on a log-log axis with AI on the x-axis and performance on the y-axis:

- A **horizontal ceiling** at $\pi$ — the compute roof
- A **diagonal ridge line** with slope 1 (on log-log scale) equal to $\beta \times I$ — the memory bandwidth roof

The intersection of these two lines occurs at the **ridge point**:

$$I_{ridge} = \frac{\pi}{\beta}$$

A kernel with $I < I_{ridge}$ is **memory-bound**; a kernel with $I > I_{ridge}$ is **compute-bound**.

```svg
<svg viewBox="0 0 680 420" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11">

  <!-- Background -->
  <rect x="80" y="30" width="550" height="330" fill="#f9f9f9" stroke="#ccc"/>

  <!-- Grid lines (log scale: x positions for AI = 0.0625, 0.125, 0.25, 0.5, 1, 2, 4, 8, 16, 32) -->
  <!-- x-axis spans AI: 0.0625 to 64, log2 scale mapped to 80..630 = 550px / 10 decades -->
  <!-- Each log2 step = 550/10 = 55px -->
  <!-- x(AI) = 80 + (log2(AI) - log2(0.0625)) * 55 = 80 + (log2(AI)+4)*55 -->
  <!-- y-axis spans perf: 0.25 to 32 TFLOP/s, log2 scale mapped to 360..30 = 330px / 7 decades -->
  <!-- y(P) = 360 - (log2(P) - log2(0.25)) * (330/7) = 360 - (log2(P)+2)*47.14 -->

  <!-- Vertical grid -->
  <line x1="135" y1="30" x2="135" y2="360" stroke="#ddd" stroke-width="1"/>
  <line x1="190" y1="30" x2="190" y2="360" stroke="#ddd" stroke-width="1"/>
  <line x1="245" y1="30" x2="245" y2="360" stroke="#ddd" stroke-width="1"/>
  <line x1="300" y1="30" x2="300" y2="360" stroke="#ddd" stroke-width="1"/>
  <line x1="355" y1="30" x2="355" y2="360" stroke="#ddd" stroke-width="1"/>
  <line x1="410" y1="30" x2="410" y2="360" stroke="#ddd" stroke-width="1"/>
  <line x1="465" y1="30" x2="465" y2="360" stroke="#ddd" stroke-width="1"/>
  <line x1="520" y1="30" x2="520" y2="360" stroke="#ddd" stroke-width="1"/>
  <line x1="575" y1="30" x2="575" y2="360" stroke="#ddd" stroke-width="1"/>
  <line x1="630" y1="30" x2="630" y2="360" stroke="#ddd" stroke-width="1"/>

  <!-- Horizontal grid -->
  <line x1="80" y1="313" x2="630" y2="313" stroke="#ddd" stroke-width="1"/>
  <line x1="80" y1="266" x2="630" y2="266" stroke="#ddd" stroke-width="1"/>
  <line x1="80" y1="219" x2="630" y2="219" stroke="#ddd" stroke-width="1"/>
  <line x1="80" y1="172" x2="630" y2="172" stroke="#ddd" stroke-width="1"/>
  <line x1="80" y1="125" x2="630" y2="125" stroke="#ddd" stroke-width="1"/>
  <line x1="80" y1="78" x2="630" y2="78" stroke="#ddd" stroke-width="1"/>

  <!-- Compute roof at pi=16 TFLOP/s => y = 360-(log2(16)+2)*47.14 = 360-(4+2)*47.14 = 360-282.84 = 77 -->
  <!-- Ridge point at I=16/0.9 ~17.8, x=80+(log2(17.8)+4)*55=80+(4.15+4)*55=80+448=528 -->

  <!-- Memory bandwidth roof (diagonal): slope=beta=0.9 TB/s -->
  <!-- Line: P = beta * I, both in log scale -->
  <!-- At I=0.0625: P=0.9*0.0625=0.05625 TFLOP/s => y=360-(log2(0.05625)+2)*47.14=360-(-4.15+2)*47.14=360+101=461 (off chart) -->
  <!-- At I=0.125: P=0.1125 => y=360-(-3.15+2)*47.14=360+54=414 (off chart) -->
  <!-- At I=0.25: P=0.225 => y=360-(-2.15+2)*47.14=360+7=367 (just off) -->
  <!-- At I=0.5: P=0.45 => y=360-(-1.15+2)*47.14=360-40=320 -->
  <!-- At I=1: P=0.9 => y=360-(0+2)*47.14=360-94=266 -->
  <!-- At I=2: P=1.8 => y=360-(1+2)*47.14=360-141=219 -->
  <!-- At I=4: P=3.6 => y=360-(2+2)*47.14=360-188=172 -->
  <!-- At I=8: P=7.2 => y=360-(3+2)*47.14=360-235=125 -->
  <!-- At I=16: P=14.4 => y=360-(4+2)*47.14... wait, ridge at ~17.8 -->
  <!-- At I=17.8: P=16 => meets roof at y=77 -->
  <!-- x(17.8)=80+(log2(17.8)+4)*55=80+(4.15+4)*55=80+448.25=528 -->
  <!-- x(8)=80+(3+4)*55=80+385=465 -->

  <!-- Draw bandwidth diagonal from (x=245,y=367) clipped to (x=528,y=77) -->
  <line x1="246" y1="360" x2="528" y2="77" stroke="#1976d2" stroke-width="2.5"/>

  <!-- Compute roof horizontal from ridge to right -->
  <line x1="528" y1="77" x2="630" y2="77" stroke="#c62828" stroke-width="2.5"/>

  <!-- Roof labels -->
  <text x="585" y="70" fill="#c62828" font-weight="bold">Peak Compute</text>
  <text x="585" y="82" fill="#c62828">16 TFLOP/s</text>

  <text x="155" y="195" fill="#1976d2" font-weight="bold" transform="rotate(-78,155,195)">Memory BW Roof</text>
  <text x="175" y="215" fill="#1976d2" transform="rotate(-78,175,215)">0.9 TB/s</text>

  <!-- Ridge point marker -->
  <circle cx="528" cy="77" r="5" fill="#7b1fa2" stroke="#4a148c"/>
  <text x="532" y="68" fill="#7b1fa2" font-weight="bold">Ridge ≈ 17.8 FLOP/byte</text>

  <!-- Kernel data points -->
  <!-- STREAM: AI~0.083, P~0.18 TFLOP/s => x=80+(log2(0.083)+4)*55=80+(-3.59+4)*55=80+22.5=102, y=360-(-2.47+2)*47.14=360+22=382 off, clip to 358 -->
  <!-- SpMV: AI~0.2, P~0.18 TFLOP/s => x=80+(log2(0.2)+4)*55=80+(-2.32+4)*55=80+92=172, y=360-(-2.47+2)*47.14≈358 -->
  <!-- GEMV: AI~0.25, P~0.22 TFLOP/s => x=245, y≈365 -->
  <!-- Stencil: AI~0.5, P~0.4 TFLOP/s => x=300, y=320 -->
  <!-- FFT: AI~1.5, P~1.2 TFLOP/s => x=80+(0.585+4)*55=80+252=332, y=360-(0.263+2)*47.14=360-106=254 -->
  <!-- GEMM: AI~8, P~12 TFLOP/s => x=465, y=360-(3.58+2)*47.14=360-263=97 -->

  <circle cx="172" cy="340" r="6" fill="#e65100" stroke="#bf360c"/>
  <text x="118" y="337" fill="#e65100" font-weight="bold">SpMV</text>

  <circle cx="300" cy="318" r="6" fill="#e65100" stroke="#bf360c"/>
  <text x="256" y="315" fill="#e65100" font-weight="bold">Stencil</text>

  <circle cx="332" cy="254" r="6" fill="#388e3c" stroke="#1b5e20"/>
  <text x="338" y="251" fill="#388e3c" font-weight="bold">FFT</text>

  <circle cx="465" cy="97" r="6" fill="#388e3c" stroke="#1b5e20"/>
  <text x="471" y="94" fill="#388e3c" font-weight="bold">GEMM</text>

  <!-- Memory-bound region shading -->
  <polygon points="80,360 528,77 80,77" fill="#e3f2fd" fill-opacity="0.3"/>
  <text x="130" y="250" fill="#1565c0" font-size="10">memory-bound</text>

  <!-- Compute-bound region shading -->
  <polygon points="528,77 630,77 630,360 528,360" fill="#ffebee" fill-opacity="0.4"/>
  <text x="545" y="220" fill="#c62828" font-size="10">compute</text>
  <text x="548" y="232" fill="#c62828" font-size="10">-bound</text>

  <!-- Axes -->
  <line x1="80" y1="360" x2="630" y2="360" stroke="#333" stroke-width="2"/>
  <line x1="80" y1="30" x2="80" y2="360" stroke="#333" stroke-width="2"/>

  <!-- X axis labels -->
  <text x="135" y="377" text-anchor="middle" fill="#333">⅛</text>
  <text x="190" y="377" text-anchor="middle" fill="#333">¼</text>
  <text x="245" y="377" text-anchor="middle" fill="#333">½</text>
  <text x="300" y="377" text-anchor="middle" fill="#333">1</text>
  <text x="355" y="377" text-anchor="middle" fill="#333">2</text>
  <text x="410" y="377" text-anchor="middle" fill="#333">4</text>
  <text x="465" y="377" text-anchor="middle" fill="#333">8</text>
  <text x="520" y="377" text-anchor="middle" fill="#333">16</text>
  <text x="575" y="377" text-anchor="middle" fill="#333">32</text>
  <text x="630" y="377" text-anchor="middle" fill="#333">64</text>
  <text x="355" y="395" text-anchor="middle" fill="#333" font-weight="bold">Arithmetic Intensity (FLOP/byte)</text>

  <!-- Y axis labels -->
  <text x="75" y="364" text-anchor="end" fill="#333">¼</text>
  <text x="75" y="317" text-anchor="end" fill="#333">½</text>
  <text x="75" y="270" text-anchor="end" fill="#333">1</text>
  <text x="75" y="223" text-anchor="end" fill="#333">2</text>
  <text x="75" y="176" text-anchor="end" fill="#333">4</text>
  <text x="75" y="129" text-anchor="end" fill="#333">8</text>
  <text x="75" y="82" text-anchor="end" fill="#333">16</text>

  <text x="20" y="200" text-anchor="middle" font-weight="bold" fill="#333" transform="rotate(-90,20,200)">Performance (TFLOP/s)</text>

  <!-- Title -->
  <text x="355" y="20" text-anchor="middle" font-weight="bold" font-size="13" fill="#111">Roofline Model — Example Platform</text>
</svg>
```

---

### The Ridge Point

The ridge point $I_{ridge} = \pi / \beta$ is the most important single parameter derived from the Roofline model. It represents the minimum arithmetic intensity a kernel must achieve to be compute-bound on this platform.

|Platform (approximate)|Peak FLOP/s|Peak BW|Ridge Point|
|---|---|---|---|
|Intel Core i9 (single core, AVX-512 FP64)|~100 GFLOP/s|~50 GB/s|~2 FLOP/byte|
|AMD EPYC 9654 (FP64)|~6 TFLOP/s|~460 GB/s|~13 FLOP/byte|
|NVIDIA A100 (FP64)|~9.7 TFLOP/s|~2 TB/s (HBM2e)|~4.8 FLOP/byte|
|NVIDIA H100 (FP64)|~34 TFLOP/s|~3.35 TB/s|~10 FLOP/byte|

[Unverified: figures are representative of published specifications and may not reflect sustained throughput under real workloads. Behavior is not guaranteed.]

GPUs have very high memory bandwidth (HBM) which shifts the ridge point leftward — a smaller AI suffices to be compute-bound. CPUs with narrower memory buses have lower bandwidth relative to peak compute, pushing the ridge point rightward.

---

### Multiple Roofs

The basic Roofline model uses one compute roof and one bandwidth roof. In practice, multiple ceilings exist simultaneously, each constraining a different class of kernel:

#### Compute Ceilings

Not all instructions achieve peak throughput. Hardware limitations impose lower effective ceilings for specific operation types:

|Ceiling|Cause|
|---|---|
|Peak FP64 (vector, FMA)|Full AVX-512 FMA pipeline utilization|
|Peak FP32|Separate FP32 units; often 2× FP64 throughput|
|No FMA|If FMA is not used, throughput is halved|
|No SIMD|Scalar-only code; 4–16× below vector peak (width-dependent)|
|No ILP|Dependent instruction chains limit execution unit utilization|

Each ceiling is a horizontal line below the peak roof. A kernel's actual performance is bounded by the lowest applicable ceiling.

#### Bandwidth Ceilings

Different levels of the memory hierarchy offer different bandwidth:

|Level|Typical BW (server CPU)|
|---|---|
|L1 cache|~1–4 TB/s|
|L2 cache|~500 GB/s – 2 TB/s|
|L3 (LLC)|~200–500 GB/s|
|DRAM|~50–460 GB/s|
|NVMe SSD|~10–14 GB/s|

A kernel whose working set fits in L2 cache operates against the L2 bandwidth roof, not the DRAM roof — its effective AI relative to DRAM is much higher because bytes are not fetched from DRAM.

```svg
<svg viewBox="0 0 680 360" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11">
  <text x="340" y="20" text-anchor="middle" font-weight="bold" font-size="13">Extended Roofline — Multiple Ceilings</text>

  <rect x="60" y="30" width="580" height="300" fill="#f9f9f9" stroke="#ccc"/>

  <!-- Peak compute roof -->
  <line x1="430" y1="50" x2="640" y2="50" stroke="#c62828" stroke-width="2.5"/>
  <text x="645" y="54" fill="#c62828" font-weight="bold">Peak (FMA+SIMD)</text>

  <!-- No FMA ceiling -->
  <line x1="430" y1="90" x2="640" y2="90" stroke="#c62828" stroke-width="1.5" stroke-dasharray="8,4"/>
  <text x="645" y="94" fill="#c62828">No FMA</text>

  <!-- Scalar ceiling -->
  <line x1="430" y1="150" x2="640" y2="150" stroke="#c62828" stroke-width="1.5" stroke-dasharray="4,4"/>
  <text x="645" y="154" fill="#c62828">Scalar only</text>

  <!-- L1 BW diagonal (steepest) -->
  <line x1="60" y1="200" x2="200" y2="50" stroke="#2e7d32" stroke-width="1.5" stroke-dasharray="5,3"/>
  <text x="62" y="210" fill="#2e7d32">L1 BW</text>

  <!-- L2 BW diagonal -->
  <line x1="60" y1="260" x2="310" y2="50" stroke="#388e3c" stroke-width="1.5" stroke-dasharray="5,3"/>
  <text x="62" y="272" fill="#388e3c">L2 BW</text>

  <!-- L3 BW diagonal -->
  <line x1="60" y1="310" x2="410" y2="50" stroke="#66bb6a" stroke-width="2"/>
  <text x="62" y="322" fill="#66bb6a">LLC BW</text>

  <!-- DRAM BW diagonal (shallowest) -->
  <line x1="60" y1="330" x2="640" y2="50" stroke="#1976d2" stroke-width="2.5"/>
  <text x="62" y="342" fill="#1976d2" font-weight="bold">DRAM BW</text>

  <!-- Kernel A: memory-bound at DRAM level -->
  <circle cx="130" cy="290" r="6" fill="#e65100"/>
  <text x="110" y="280" fill="#e65100">A</text>

  <!-- Kernel B: fits in L3, compute-bound vs scalar -->
  <circle cx="330" cy="148" r="6" fill="#7b1fa2"/>
  <text x="338" y="145" fill="#7b1fa2">B</text>

  <!-- Kernel C: fits in L1, near peak compute -->
  <circle cx="480" cy="58" r="6" fill="#388e3c"/>
  <text x="488" y="55" fill="#388e3c">C</text>

  <!-- Axes -->
  <line x1="60" y1="330" x2="640" y2="330" stroke="#333" stroke-width="1.5"/>
  <line x1="60" y1="30" x2="60" y2="330" stroke="#333" stroke-width="1.5"/>
  <text x="350" y="350" text-anchor="middle" fill="#333" font-weight="bold">Arithmetic Intensity →</text>
  <text x="20" y="190" text-anchor="middle" fill="#333" font-weight="bold" transform="rotate(-90,20,190)">Performance →</text>
</svg>
```

Kernel A is bound by DRAM bandwidth. Kernel B fits in LLC and hits the scalar compute ceiling — it needs vectorization, not more memory bandwidth. Kernel C is near peak compute. Each diagnosis implies a different optimization strategy.

---

### Operational Intensity vs Arithmetic Intensity

A subtle but important distinction:

**Arithmetic intensity** is the algorithmic ratio — computed from the algorithm assuming perfect cache behavior (i.e., each data element is loaded from memory only once, ever).

**Operational intensity** is the measured or modeled ratio accounting for actual cache misses and memory traffic — it reflects what the hardware actually transfers to and from DRAM during execution.

A kernel with high algorithmic AI but poor cache behavior may have low operational intensity if its working set does not fit in cache, repeatedly evicting and reloading data. The gap between algorithmic and operational AI quantifies cache inefficiency.

---

### Placing a Kernel on the Roofline

To position a kernel, two quantities must be measured or modeled:

**Measured performance (FLOP/s):** Use hardware performance counters to count floating-point operations executed per second. On x86: `INST_RETIRED.256B_PACKED_DOUBLE`, `INST_RETIRED.512B_PACKED_DOUBLE`, etc.

**Measured memory traffic (bytes):** Count DRAM read and write transactions. On Intel: `UNC_M_CAS_COUNT.RD` and `UNC_M_CAS_COUNT.WR` from the uncore memory controller PMU, multiplied by cache line size (64 bytes).

$$I_{measured} = \frac{\text{FP ops counted}}{\text{bytes counted by memory controller}}$$

The measured point $(I_{measured}, P_{measured})$ is plotted on the Roofline. Its distance below the applicable roof quantifies attained efficiency:

$$\eta = \frac{P_{measured}}{\min(\pi, \beta \times I_{measured})}$$

$\eta = 1$ means the kernel is exactly at its roof (roofline-optimal for its intensity). $\eta \ll 1$ implies unexploited optimization headroom.

---

### Optimization Strategies Implied by the Model

The Roofline model prescribes different optimization directions depending on where a kernel falls:

#### Memory-Bound Kernels ($I < I_{ridge}$)

The goal is to increase operational intensity — reduce bytes transferred per FLOP — or move data closer to the processor:

|Strategy|Mechanism|
|---|---|
|**Loop tiling / blocking**|Restructure iteration to keep working set in L1/L2, increasing data reuse|
|**Data layout transformation**|AoS → SoA (Array of Structures to Structure of Arrays) for better vectorization and cache line utilization|
|**Compression**|Use FP16 or BF16 where precision permits; halves bytes transferred|
|**Fusion**|Merge multiple passes over the same data into one, reducing total memory traffic|
|**Prefetching**|Hide memory latency (does not change AI but improves bandwidth utilization)|

#### Compute-Bound Kernels ($I > I_{ridge}$)

The goal is to approach peak FLOP/s:

|Strategy|Mechanism|
|---|---|
|**Vectorization**|Use SIMD intrinsics or compiler auto-vectorization to process multiple elements per instruction|
|**FMA utilization**|Fused multiply-add doubles effective throughput on supported hardware|
|**Instruction-level parallelism**|Unroll loops to expose independent operations to the out-of-order scheduler|
|**Mixed precision**|Use FP16/BF16 for eligible operations; modern hardware (e.g., Tensor Cores) achieves much higher throughput at lower precision|

#### Below the Bandwidth Roof (Poor Bandwidth Utilization)

Even for memory-bound kernels, if measured performance is far below $\beta \times I$, bandwidth is not being fully utilized:

- Cache line utilization: only a fraction of each fetched cache line may be used (spatial locality problem)
- Irregular access patterns (scatter/gather) prevent coalescing on GPUs or full cache line use on CPUs
- TLB misses adding overhead beyond DRAM latency

---

### Roofline on GPUs

GPUs have fundamentally different roofline characteristics from CPUs:

- Very high peak compute ($\pi$): Tensor Cores for FP16/BF16 offer dramatically higher throughput than FP64
- Very high peak bandwidth ($\beta$): HBM provides TB/s bandwidth
- Ridge point may be at moderate AI (e.g., ~5–10 FLOP/byte for FP64)
- **Occupancy** affects how well the hardware is utilized — if too few warps are active, memory latency is not hidden even if bandwidth is available

On GPUs, the Roofline is often extended with a **latency roof** — a bound on performance from insufficient parallelism (too few active warps to cover memory latency), independent of bandwidth.

|GPU Roof Type|Cause|Mitigation|
|---|---|---|
|Compute roof|FP throughput saturated|Mixed precision, algorithmic reduction|
|Bandwidth roof|HBM saturated|Data reuse, tiling, compression|
|Latency/occupancy bound|Insufficient parallelism|Increase thread count, reduce register pressure, tune block size|

---

### Limitations of the Roofline Model

The Roofline model is a bound, not a prediction. Several factors limit its precision:

|Limitation|Explanation|
|---|---|
|**Single bandwidth number**|Real memory systems have non-uniform latency and bandwidth; streaming BW ≠ random-access BW|
|**No latency modeling**|A memory-bound kernel at low queue depth may be latency-limited, not bandwidth-limited|
|**No instruction mix modeling**|The compute roof assumes all instructions are floating-point; integer, branch, and memory instructions consume issue slots|
|**Cache hierarchy collapse**|The model uses a single BW roof per level; actual behavior depends on access pattern, associativity, and prefetcher effectiveness|
|**No interconnect modeling**|In multi-socket or GPU cluster settings, NVLink/UPI/InfiniBand bandwidth adds additional roofs|
|**Compiler variability**|The same source code may achieve dramatically different effective AI depending on compiler vectorization, loop transformations, and register allocation|

[Inference] The Roofline model is most reliable as a diagnostic tool to identify the dominant bottleneck, not as a precise performance predictor. Quantitative accuracy requires careful measurement of actual memory traffic and FLOPs, not theoretical estimates. Behavior is not guaranteed.

---

### Empirical Roofline Tool (ERT)

The **Empirical Roofline Toolkit (ERT)**, developed at NERSC, automates the measurement of actual $\pi$ and $\beta$ on a given platform by running calibrated microbenchmarks rather than relying on manufacturer specifications. This accounts for:

- Sustained vs. peak bandwidth (manufacturer specs are often theoretical maxima)
- Actual FMA and SIMD throughput under realistic register pressure
- Effective L1/L2/L3/DRAM bandwidth at the working set sizes relevant to the target kernel

Using empirically measured roofline bounds produces a tighter and more actionable model than one based on specification sheets.

---

**Example**

A climate simulation stencil kernel operates on a 3D grid with a 7-point stencil. For each output point it performs 13 FLOPs (6 adds, 6 multiplies, 1 scaling) and reads 7 doubles (56 bytes) with minimal reuse beyond what fits in register. Operational intensity is approximately $13/56 \approx 0.23$ FLOP/byte. On a CPU with $\beta = 200$ GB/s and $\pi = 3$ TFLOP/s, the ridge point is $3000/200 = 15$ FLOP/byte. Since $0.23 \ll 15$, the kernel is deeply memory-bound. The Roofline ceiling is $0.23 \times 200 = 46$ GFLOP/s — regardless of how much the compute pipeline is optimized, performance cannot exceed 46 GFLOP/s without increasing data reuse. Loop tiling in the z-dimension to fit a slab in L2 cache can raise the effective operational intensity for the L2 roof, potentially achieving 5–10× throughput improvement without changing algorithmic FLOP count.

---

**Conclusion**

The Roofline model provides a principled, hardware-aware framework for understanding and diagnosing computational performance. By expressing performance as a function of arithmetic intensity against hardware ceilings for compute and memory bandwidth, it immediately identifies whether optimization effort should target data reuse and memory traffic reduction or instruction throughput and vectorization. Extended with multiple cache-level bandwidth roofs and compute ceilings for different instruction classes, it becomes a detailed diagnostic map of where a kernel stands relative to all applicable hardware limits. Its primary value is not numerical precision but architectural insight: it makes the dominant bottleneck visible and prescribes the class of optimization needed to address it.

**Next Steps**

- CPI, IPC, MIPS, FLOPS — the foundational performance metrics from which roofline quantities are derived
- Amdahl's Law and Gustafson's Law — complementary bounds-based models for parallel speedup
- Prefetching strategies — techniques that improve bandwidth utilization in memory-bound kernels without changing AI
- SIMD and vector processing — the hardware mechanism behind the gap between scalar and peak compute roofs
- Cache fundamentals and mapping — the cache behavior that determines whether algorithmic AI matches operational intensity

---

