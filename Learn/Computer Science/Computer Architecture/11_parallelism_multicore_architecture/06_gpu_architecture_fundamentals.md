## GPU Architecture Fundamentals


The GPU's architectural philosophy is the inverse of the CPU's. A CPU devotes most of its transistor budget to control logic, branch prediction, and out-of-order execution machinery — mechanisms that minimize latency for a small number of sequential threads. A GPU invests that same budget in arithmetic units and registers, tolerating high latency by running thousands of threads simultaneously, hiding memory stalls behind other threads' work. The result is a processor optimized for throughput over latency.

---

### The Latency-Hiding Execution Model

The central insight of GPU architecture is **latency hiding through massive multithreading**. When a thread issues a memory load and the data has not yet arrived (a stall of hundreds of cycles on a cache miss), the GPU does not wait. It switches to another ready warp — another group of threads — and begins executing that instead. By the time control cycles back, the original memory request has likely returned.

This works only because the GPU keeps thousands of threads in flight simultaneously. Each thread's register state is stored on-chip in a large register file (not pushed to memory as in a CPU context switch), so switching costs a single cycle. The trade-off: each individual thread has no latency-hiding mechanisms of its own. It relies entirely on parallelism at the thread level to keep functional units busy.

---

### SIMT Execution

GPUs execute threads under the **Single Instruction, Multiple Thread (SIMT)** model. Threads are grouped into _warps_ (NVIDIA) or _wavefronts_ (AMD), typically 32 or 64 threads wide. All threads in a warp execute the same instruction at the same time on different data — similar to SIMD, but threads are individually addressable and can diverge.

**Warp divergence** occurs when threads within the same warp take different branches. The hardware serializes both paths: first the taken branch, with inactive lanes masked off, then the not-taken branch, with the other set masked. Throughput falls proportionally to the number of distinct paths. A warp split into two equal groups runs at half peak throughput across those branches. Rejoining after a conditional restores full throughput. This is the primary reason GPU code avoids data-dependent branching in inner loops.

---

### The Streaming Multiprocessor

The fundamental execution unit is the **Streaming Multiprocessor** (SM) on NVIDIA hardware, or Compute Unit (CU) on AMD. A modern GPU contains tens to hundreds of SMs. Each SM is itself a small parallel processor with its own scheduler, register file, ALUs, and on-chip memory.

The diagram below shows the structural organization of a GPU from the chip level down to a single SM.Within a single SM, the key components are:

**Warp schedulers** — Each SM contains two to four warp schedulers. Each scheduler manages a pool of resident warps and selects one ready warp per cycle to issue instructions from. "Ready" means no outstanding data dependencies and no memory stall. Multiple schedulers can issue simultaneously — a dual-issue SM can dispatch two warp instructions per clock.

**Register file** — Physically large (256 KB or more per SM), the register file holds the live registers of every resident warp simultaneously. This is what makes zero-cost context switching between warps possible: no state is swapped to memory. Register file size is a hard constraint on occupancy — a kernel using many registers per thread leaves room for fewer warps per SM.

**CUDA cores / ALUs** — Integer and floating-point execution units. Modern SMs have separate FP32, FP64, INT, and tensor core pipelines. Each pipeline is pipelined and accepts a new instruction every cycle.

**Tensor cores** — Introduced in the Volta architecture, tensor cores perform matrix multiply-accumulate (MMA) operations on small tiles (e.g., 4×4 or 16×16) in a single instruction. They are specifically designed for the dense matrix operations in neural network training and inference, operating on FP16, BF16, INT8, and other reduced-precision formats.

**Special function units (SFUs)** — Handle transcendentals (`sin`, `cos`, `rcp`, `sqrt`). There are far fewer SFUs than CUDA cores; issuing transcendentals to a warp when all SFUs are busy stalls the warp.

**Load/store units (LD/ST)** — Mediate memory transactions between registers and the cache/memory hierarchy. They coalesce per-thread addresses into burst transactions against global memory when possible.

**Shared memory / L1 cache** — A fast, on-chip SRAM block physically unified between shared memory (programmer-visible scratchpad) and L1 cache. The split between scratchpad and cache is often configurable per kernel. Shared memory has very high bandwidth (nearly register file bandwidth) and is visible only to threads within the same thread block — the primary mechanism for inter-thread communication and data reuse within a block.

---

### The Memory Hierarchy

The GPU memory hierarchy has sharply different characteristics from a CPU's.

```
Registers         ~1 cycle     per thread, fastest
Shared memory     ~5 cycles    per thread block (SM-local scratchpad)
L1 cache          ~30 cycles   per SM, backed by L2
L2 cache          ~200 cycles  on-chip, shared across all SMs
GDDR6 / HBM       ~500+ cycles off-chip VRAM, terabytes/sec bandwidth
System RAM         much slower  via PCIe (~16 GB/s)
```

**Global memory** (VRAM) is accessible by all threads but is high-latency. The memory access pattern critically determines throughput. When threads in a warp access consecutive memory addresses, the LD/ST units coalesce those accesses into a single wide transaction — this is _coalesced access_. If threads access scattered addresses, each requires a separate transaction, multiplying bandwidth consumption and stalling the warp for many cycles. Writing GPU kernels to achieve coalesced access is one of the primary optimization concerns.

**Shared memory bank conflicts** arise within shared memory. The SRAM is divided into banks (typically 32), and simultaneous accesses to the same bank by different threads in a warp serialize. Careful data layout or padding avoids conflicts and preserves the scratchpad's full bandwidth.

**Texture and constant memory** are specialized read-only caches. The texture cache is optimized for 2D spatial locality (hardware interpolation, boundary clamping) and is essential for graphics workloads. Constant memory (64 KB, read-only) is broadcast-cached: a single access shared by all threads in a warp costs one cache access, not 32.

---

### Occupancy

_Occupancy_ is the ratio of active warps to the maximum warps an SM can support. High occupancy maximizes the warp scheduler's ability to hide latency. It is constrained by three SM resources shared among all resident warps:

- **Registers per thread** — if a kernel uses many registers, fewer threads fit.
- **Shared memory per block** — large allocations limit how many blocks can reside simultaneously.
- **Thread block size** — blocks that are too small leave warps under-subscribed.

Occupancy is not a free metric to maximize regardless of cost. A kernel that reduces register use by spilling to local memory (in VRAM) may achieve higher occupancy but lower throughput due to the extra memory traffic. The CUDA occupancy calculator and profilers expose the binding constraint for a given kernel.

---

### Thread Hierarchy

GPU programs are organized into a three-level hierarchy that maps directly onto hardware.

```
Grid
└── Thread blocks (CTAs)
    └── Warps (32 threads, hardware scheduling unit)
        └── Threads
```

A **thread** is the unit of sequential execution — it has its own registers, program counter, and call stack.

A **thread block** (or Cooperative Thread Array, CTA) is a group of threads assigned to a single SM for its lifetime. Threads within a block can synchronize via `__syncthreads()` (a barrier) and communicate through shared memory. The hardware guarantees a block runs on exactly one SM, which is what makes shared memory communication safe and fast.

A **grid** is the collection of all thread blocks launched by a kernel call. Blocks are distributed across SMs by the hardware thread block scheduler — the programmer does not control assignment. Blocks within a grid have no shared fast memory and cannot synchronize in general (though newer architectures support cooperative groups with grid-level synchronization).

This maps directly to hardware as follows: the GPU's global thread block scheduler dispatches blocks to SMs with available resources. The SM's warp schedulers then manage all warps from all resident blocks.

---

### The Graphics Pipeline

A GPU's compute capability is built on top of, and originally derived from, a fixed-function graphics pipeline. Understanding the pipeline explains why certain hardware features exist.

The pipeline stages are: application → vertex fetch → vertex shader → tessellation → geometry shader → rasterization → fragment shader → raster operations (ROP) → framebuffer.

**Programmable stages** (vertex, geometry, fragment/pixel shaders) execute general-purpose code on SM hardware — these are what general-purpose GPU (GPGPU) compute borrows. **Fixed-function stages** (rasterization, texture sampling, ROP blending) are implemented in dedicated hardware units outside the SMs, optimized for throughput on narrow tasks like scan conversion or alpha blending.

Modern GPU APIs (Vulkan, DirectX 12, Metal) expose this pipeline explicitly, allowing programmers to control synchronization, resource barriers, and pipeline state objects at a low level.

---

### GPGPU: The CUDA/OpenCL Abstraction

GPGPU computing layers a compute abstraction over the graphics pipeline hardware. In CUDA's model:

- The _host_ (CPU) allocates GPU memory, copies data to VRAM, and launches kernels.
- A _kernel_ is a C function annotated with `__global__`, executed by thousands of threads simultaneously.
- The programmer expresses parallelism by specifying a grid/block configuration.
- Memory management is explicit: `cudaMalloc`, `cudaMemcpy`. Unified Memory (introduced later) provides a virtual address space accessible from both CPU and GPU, with hardware-managed migrations.

The compiler (NVCC) compiles kernel code to PTX (an intermediate virtual ISA) and then to SASS (native machine code). PTX is architecture-independent; SASS is microarchitecture-specific. This layering means PTX code compiled once can be JIT-compiled to newer architectures.

---

### Comparison: CPU vs GPU

|Characteristic|CPU|GPU|
|---|---|---|
|Cores|8–128 (large, complex)|Thousands (small, simple)|
|Clock speed|3–5 GHz|1.5–2.5 GHz|
|Threads in flight|1–2 per core|32–64 per SM (hundreds total)|
|Latency tolerance|Hardware (OOO, branch prediction)|Software (thread-level parallelism)|
|Memory bandwidth|~100 GB/s (DDR5)|~1–4 TB/s (HBM3)|
|Cache per core|Large (MB-range L3)|Small (KB-range L1/shared)|
|Suited for|Sequential, branch-heavy, low-latency|Data-parallel, regular, high-throughput|

---

**Key Points**

- The GPU trades per-thread latency tolerance for aggregate throughput by running thousands of threads and hiding stalls behind other warps' work.
- SIMT execution runs all threads in a warp on the same instruction; divergent branches serialize and reduce throughput — a fundamental constraint on GPU code structure.
- The SM is the autonomous execution unit: it holds its own warp schedulers, register file, ALUs, tensor cores, SFUs, LD/ST units, and shared memory.
- Occupancy — the fraction of maximum resident warps — determines how effectively the scheduler can hide latency, but is constrained by register use, shared memory use, and block size.
- Memory access patterns must be coalesced to achieve near-peak VRAM bandwidth; scattered access multiplies transaction count and stalls LD/ST pipelines.
- The thread block is the unit of SM assignment and the boundary within which fast shared memory and `__syncthreads()` operate; blocks cannot communicate via shared memory.
- Tensor cores accelerate dense matrix multiply-accumulate and are the primary compute substrate for neural network workloads.

**Conclusion**

GPU architecture is a study in specialization: every design choice — from the massive register file to the absence of branch prediction hardware, from shared memory banked SRAM to the SIMT execution model — is a consequence of optimizing for throughput on data-parallel workloads. Understanding this architecture is prerequisite to understanding why neural network training, scientific simulation, and graphics rendering scale as they do on modern hardware.

**Next Steps**

From the syllabus: **SIMD and vector processing** provides the CPU-side parallel counterpart to SIMT and explains the architectural lineage that influenced GPU design. **Memory consistency models** addresses how multi-core/multi-SM systems order memory operations — essential for understanding GPU synchronization primitives and their performance implications.

---

