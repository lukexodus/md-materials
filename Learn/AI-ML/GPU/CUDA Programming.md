# Syllabus

## Module 1: CUDA Fundamentals

- GPU architecture overview (SM, cores, memory hierarchy)
- CUDA programming model introduction
- CUDA installation and development environment
- NVCC compiler basics
- First CUDA program (Hello World)
- CPU vs GPU execution comparison

## Module 2: CUDA Programming Model

- Host and device code separation
- Kernel functions and launch configuration
- Thread hierarchy (grids, blocks, threads)
- Thread indexing and ID calculation
- CUDA runtime API basics
- Error handling and debugging basics

## Module 3: Memory Management

- Device memory allocation and deallocation
- Host-device memory transfers
- Unified memory introduction
- Memory management best practices
- Memory alignment considerations
- Memory bandwidth optimization

## Module 4: Thread Organization and Execution

- CUDA execution model details
- Warp-level execution
- Thread divergence and branching
- Occupancy calculation and optimization
- Block size selection strategies
- Grid size considerations

## Module 5: CUDA Memory Hierarchy

- Global memory access patterns
- Shared memory architecture
- Local memory and registers
- Constant memory usage
- Texture memory applications
- Memory coalescing principles

## Module 6: Shared Memory Programming

- Shared memory declaration and usage
- Bank conflicts and avoidance
- Synchronization with __syncthreads()
- Shared memory optimization techniques
- Dynamic shared memory allocation
- Memory padding strategies

## Module 7: Memory Access Optimization

- Coalesced memory access patterns
- Memory access alignment
- Stride patterns and performance
- Cache utilization strategies
- Memory throughput optimization
- Bandwidth-bound vs compute-bound analysis

## Module 8: Synchronization and Communication

- Thread synchronization primitives
- Block-level synchronization
- Atomic operations and their usage
- Memory ordering and consistency
- Inter-block communication patterns
- Cooperative groups introduction

## Module 9: CUDA Libraries Integration

- cuBLAS for linear algebra
- cuFFT for fast Fourier transforms
- cuDNN for deep learning
- Thrust parallel algorithms
- cuSPARSE for sparse matrices
- NPP for image processing

## Module 10: Advanced Kernel Optimization

- Instruction-level parallelism
- Loop unrolling techniques
- Register usage optimization
- Instruction throughput analysis
- Latency hiding strategies
- Computational intensity improvement

## Module 11: Multi-GPU Programming

- Multi-GPU system architecture
- Device enumeration and selection
- Peer-to-peer communication
- Data distribution strategies
- Load balancing across GPUs
- Multi-GPU synchronization

## Module 12: Streams and Concurrency

- CUDA streams creation and usage
- Asynchronous memory transfers
- Kernel execution overlapping
- Stream synchronization methods
- Concurrent kernel execution
- Pipeline optimization techniques

## Module 13: Advanced Memory Techniques

- Memory pooling strategies
- Custom memory allocators
- Memory access pattern analysis
- Prefetching techniques
- Memory hierarchy optimization
- Large dataset handling

## Module 14: Profiling and Performance Analysis

- NVIDIA Nsight profiler usage
- Performance metrics interpretation
- Bottleneck identification techniques
- Memory bandwidth analysis
- Instruction throughput profiling
- Occupancy analysis tools

## Module 15: CUDA Dynamic Parallelism

- Dynamic kernel launches
- Nested parallelism concepts
- Parent-child kernel relationships
- Memory management in dynamic parallelism
- Performance considerations
- Use case scenarios

## Module 16: Cooperative Groups

- Cooperative groups programming model
- Grid-wide synchronization
- Multi-block cooperation
- Flexible thread grouping
- Advanced synchronization patterns
- Performance implications

## Module 17: Unified Memory and Advanced Features

- Unified memory deep dive
- Memory migration and hints
- Prefetching strategies
- Memory usage tracking
- CUDA-aware MPI integration
- Virtual memory management

## Module 18: Graphics Interoperability

- OpenGL interoperability
- DirectX resource sharing
- Compute-graphics pipeline integration
- Rendering acceleration techniques
- Image processing applications
- Real-time graphics computing

## Module 19: Machine Learning Applications

- Neural network implementation
- Matrix multiplication optimization
- Convolution operation acceleration
- Gradient computation techniques
- Memory-efficient training strategies
- Inference optimization

## Module 20: Scientific Computing Applications

- Numerical method implementations
- Sparse matrix operations
- Monte Carlo simulations
- Finite difference methods
- Molecular dynamics simulations
- Computational fluid dynamics

## Module 21: Advanced CUDA Features

- CUDA graphs for workflow optimization
- Memory pools and virtual memory
- Multi-process service (MPS)
- CUDA context management
- Driver API programming
- Runtime compilation techniques

## Module 22: Debugging and Testing

- CUDA debugging tools (cuda-gdb, Nsight)
- Memory error detection
- Race condition identification
- Unit testing strategies
- Continuous integration setup
- Validation techniques

## Module 23: Performance Optimization Strategies

- Roofline model analysis
- Algorithm redesign for GPUs
- Data structure optimization
- Communication-computation overlap
- Scalability analysis
- Performance portability

## Module 24: Production Deployment

- CUDA application containerization
- Cloud GPU deployment
- Performance monitoring in production
- Resource management strategies
- Fault tolerance implementations
- Maintenance and updates

---

I'll check what's already filed about Luke's learning approach and technical background before building this out.Good context — Luke works in TypeScript (batac-dms), has an OR background, and has a track record of building deep, structured "SyllaBot"-format curricula for tools and platforms rather than casual overviews. No prior CUDA-specific work is filed, so this is a new domain for him. I'll build a genuinely comprehensive, structured curriculum in that spirit — not a superficial primer.

I'm not creating a file per your preference — everything goes directly in this response, and I'm not folding any of my reasoning, so you'll see my full thinking about scope and structure below before the material itself.

## My reasoning on how to structure this

Before writing the material, let me think through what "comprehensive... for learning and mastering CUDA programming" actually requires, given what I know about Luke.

**Who is this for?** Luke has a strong OR/ILP background (applied to public health resource allocation), works professionally in TypeScript on a document management system, and has demonstrated — through the batac-dms epistemic labeling system and the SyllaBot curricula for TanStack/tRPC/Fastify/Elasticsearch — that he wants precise, structured, no-fluff technical material with explicit scaffolding. He's not a beginner programmer. He's a beginner at *GPU programming specifically*, likely coming from a CPU-only mental model.

This changes what "mastering CUDA" should emphasize. The single biggest failure mode for programmers picking up CUDA is that they already know how to write correct sequential (or even multi-threaded CPU) code, and they try to port that mental model onto the GPU. CUDA is not "C with more threads" — it's a fundamentally different execution and memory model (SIMT, warp-level execution, memory coalescing, occupancy) and most tutorials teach syntax first and mental model second, which produces people who can compile kernels but can't reason about why one kernel is 40x slower than another that does the same math.

Given Luke's OR background, I should lean into that: OR people are comfortable with combinatorial reasoning, resource allocation under constraints, and formal problem structure. GPU occupancy planning, memory hierarchy tradeoffs, and thread block sizing are *literally* resource allocation problems with constraints — registers, shared memory, and threads per SM are a knapsack problem. I can use that framing explicitly because it will make the hardware constraints click faster for him than they would for someone without that background.

**What does "comprehensive" mean here, concretely?**

A comprehensive CUDA curriculum needs to cover, at minimum:
1. The execution model (why GPUs are structured the way they are — SIMT, warps, thread hierarchy)
2. The memory hierarchy (registers, shared memory, L1/L2, global memory, constant memory, texture memory) and why it dominates performance more than compute does in most real kernels
3. The actual CUDA C/C++ programming model — kernel launches, indexing, synchronization primitives
4. Performance analysis and profiling — because writing a *correct* kernel is maybe 20% of the skill; writing a *fast* one is the other 80%, and you cannot get there without profiling tools
5. Common algorithmic patterns (reduction, scan, stencil, matrix multiply, histogram) because these patterns recur constantly and each teaches a specific hazard (bank conflicts, divergence, atomics contention)
6. Advanced memory optimization (coalescing, shared memory bank conflicts, occupancy tuning)
7. Streams and concurrency (overlapping compute and data transfer — this is where a lot of real-world speedup comes from that beginners miss entirely)
8. Modern CUDA features (unified memory, cooperative groups, tensor cores if relevant) since a "mastering" curriculum shouldn't stop at CUDA 6-era material
9. Multi-GPU programming, since real systems increasingly need this
10. Debugging methodology specific to GPU code (which is genuinely different from CPU debugging — races, uninitialized memory, and silent numerical corruption behave differently)
11. A capstone-style integration project or projects, because isolated exercises don't teach you how these concepts compose in a real kernel

I should NOT make this just a list of CUDA API calls. That's what most tutorials do and it's exactly the shallow-syntax trap I want to avoid. Every module needs: the conceptual "why," the mechanical "how," a worked example with actual reasoning shown (not just code dropped in), a common pitfall specific to that topic, and a way to self-verify understanding.

**Format decision.** Luke's past materials are described as "SyllaBot-format" — structured curriculum content. I don't have the literal template in memory (it's not stored, just referenced as a pattern), so I'll build something in that spirit: numbered modules, clear learning objectives per module, prerequisite chains made explicit, a mix of conceptual explanation and worked code, checkpoints/self-assessment, and a realistic time/effort framing. I will NOT invent things I don't actually know a "SyllaBot format" contains beyond what's stated (structured, curriculum-style) — I don't have the exact template stored, so I'll build a defensible structured curriculum rather than claim to be reproducing an exact prior format I can't verify.

**Length and depth tradeoff.** Given the explicit ask is "comprehensive" and "mastering" (not "introductory" or "quick"), and given the user preference to output everything directly rather than as a file, I need to actually write substantial material inline — not just an outline with placeholders. I'll build out real explanatory content, real code examples with correct CUDA semantics, and real worked reasoning for at least the foundational and high-leverage modules, while being honest that a *complete* mastery curriculum (this could genuinely be a 200+ hour course) can't be exhaustively written to production-course depth in one response without becoming unusable. My approach: build the full structural skeleton with all modules properly scoped, and go genuinely deep (not just headers) on the modules that carry the most conceptual weight and are most likely to be the ones a self-learner gets wrong — execution model, memory hierarchy, coalescing, occupancy, reduction pattern, and profiling methodology — while still giving working code and concrete guidance in every other module so nothing is a stub.

**Technical accuracy check I need to run in my head before writing code:** I should verify my understanding of a few CUDA specifics is current, since architecture details (warp size, shared memory sizes per SM, max threads per block, tensor core generations) have shifted across GPU generations (Kepler → Maxwell → Pascal → Volta → Turing → Ampere → Hopper → Blackwell), and I don't want to state generation-specific numbers as universal facts. Warp size (32 threads) has been constant across all NVIDIA GPU generations to date, so that's safe to state as a fixed architectural fact. But things like max shared memory per SM, max registers per thread, and max threads per SM vary by compute capability. I'll be explicit about this being generation-dependent and tell Luke to check `cudaGetDeviceProperties` rather than hardcode numbers, which is also just correct practice.

Let me also sanity-check: is there anything post-cutoff I should verify, like current CUDA toolkit version or newest architecture naming? Given this is foundational programming-model material (the SIMT execution model, memory hierarchy, warp mechanics) that has been stable for over a decade, I don't need to search — these aren't the kind of facts that go stale. What *could* have changed is the current CUDA toolkit version number and the newest GPU architecture name, which I should flag as "check current" rather than assert confidently, rather than making the reader search for a stable concept they don't need to verify.

**Structural plan I've settled on:**

- Phase 0: Prerequisites & mental model reset (the "unlearn CPU thinking" module — I think this is the single highest-leverage module in the whole curriculum for someone with Luke's background, so it goes first and gets real depth)
- Phase 1: Foundations (hardware architecture, execution model, first kernels, error handling)
- Phase 2: Memory hierarchy (this is the module that separates people who can write correct kernels from people who can write fast ones — deep treatment)
- Phase 3: Core programming patterns (reduction, scan, stencil, transpose, matmul — each teaches a specific hazard)
- Phase 4: Performance engineering (profiling tools, occupancy, coalescing, divergence, bank conflicts — this is where "mastery" actually lives)
- Phase 5: Concurrency & multi-stream programming (overlap, async, multi-GPU)
- Phase 6: Modern CUDA & libraries (cuBLAS/cuDNN/Thrust, unified memory, cooperative groups, tensor cores)
- Phase 7: Capstone projects (2-3 project specs that force integration of everything above)
- Appendices: debugging methodology, a glossary, a "mistakes I will definitely make" pre-mortem, and a resource list

I'm going to write this now, in full, in my response body, with real code and real depth on the highest-leverage modules.

---

# Quick-Guide

**Format note:** Each module states its objective, its prerequisite modules, core content, a worked example, a common failure mode specific to that topic, and a self-check. Modules build strictly on prior ones — don't skip Phase 0 even if you're tempted to jump to "real" kernels.

**Time framing (honest, not aspirational):** Genuine fluency — being able to look at a kernel and predict roughly where its time is going before profiling it — is closer to 150–250 hours of combined study and hands-on work than a weekend. Phase 0–2 alone, done properly with exercises, is 25–35 hours. Don't let the density of this document create false urgency; depth here compounds, it doesn't need to be rushed.

---

## Phase 0 — Prerequisites & The Mental Model Reset

### Module 0.1 — Why CPU Intuition Actively Hurts You Here

**Objective:** Replace "more threads = more parallel work getting done independently" with the actual GPU execution model, before you write a single line of kernel code.

**Prerequisites:** Comfort with C/C++ pointers and basic memory concepts (stack vs heap, pass-by-reference). You don't need prior parallel programming experience — in fact if you have CPU multithreading experience (pthreads, OpenMP), some of it will actively mislead you, and I'll flag exactly where.

**Core content:**

On a CPU, when you spin up threads, you're generally imagining independent workers, each with roughly its own program counter, that can branch differently, stall independently, and get scheduled by the OS more or less arbitrarily. That model is *wrong* for the GPU's actual execution unit, and almost every beginner CUDA bug and performance disaster traces back to still thinking in that model.

The GPU's real execution model is **SIMT** — Single Instruction, Multiple Thread. Here's the mechanism, stated precisely:

Threads on a GPU are grouped into fixed-size groups of **32** called **warps**. This number, 32, has been architecturally constant across every NVIDIA GPU generation to date (Kepler through the current generation) — it's safe to treat as a hardware constant, unlike other limits which vary by generation. All 32 threads in a warp execute the *same instruction* at the *same time*, in lockstep, on the GPU's SIMD execution units. They don't run "in parallel" in the sense that thread 0 might be on `add` while thread 5 is on `multiply` — the hardware physically issues one instruction per cycle *for the whole warp*.

This has an immediate, non-obvious consequence: **if threads in the same warp take different branches of an `if` statement, the warp does not run those branches in parallel — it runs them sequentially, one after another, masking out the threads that don't belong to the current branch.** This is called **warp divergence**, and it means a naive `if (threadIdx.x % 2 == 0) { doA(); } else { doB(); }` inside a kernel doesn't get you 2x parallelism on the branch — it gets you the *sum* of both branches' cost, because for half the cycles, half your ALUs are sitting idle masked out. This is the single most common reason a first CUDA kernel is slower than expected, and it is *invisible in the source code* — nothing about `if (cond) {...} else {...}` looks dangerous if you're thinking like a CPU programmer.

Above warps, threads are organized by *you*, the programmer, into **thread blocks** (also just called "blocks"), and blocks are organized into a **grid**. This is a three-level hierarchy:
- **Grid** → contains many **blocks**
- **Block** → contains many **threads**, and internally, the hardware silently groups those threads into warps of 32
- **Warp** → the actual SIMT execution unit — not something you declare, but something that exists as a consequence of how you size your blocks

Blocks are assigned to **Streaming Multiprocessors (SMs)** — the actual physical compute units on the GPU die. A GPU might have anywhere from a few dozen to well over a hundred SMs depending on the chip. Multiple blocks can be **resident** on one SM simultaneously (subject to resource limits — more on this in Phase 4), and the SM's warp scheduler interleaves the execution of warps from potentially several different resident blocks to hide latency. This interleaving is *why* GPUs achieve high throughput despite each individual thread being slow and simple: while warp A is stalled waiting on a memory load, the scheduler switches to warp B and does useful work instead of idling. This is **latency hiding via massive oversubscription**, and it's the actual reason GPUs are fast for the right kind of workload — not because each thread is fast (it isn't; a CPU core is dramatically faster per-thread), but because there are enough threads in flight that the hardware essentially never has to wait.

**Here is the framing that should click for you specifically, given your OR background:** how many warps can be resident on an SM at once is a *constrained resource allocation problem*, not a free choice. Each SM has a fixed pool of registers and a fixed pool of shared memory. Every thread you launch consumes some number of registers; every block you launch (if it uses shared memory) consumes some fixed amount of shared memory. The SM can only host as many concurrently-resident warps as its register file and shared memory pool allow, up to an architectural cap on the number of resident warps/threads per SM. This is *exactly* a knapsack problem — you are packing register-consuming, shared-memory-consuming blocks into a capacity-constrained SM, and how well you pack determines your **occupancy** (the ratio of active warps to the maximum possible), which in turn determines how well the hardware can hide latency. A kernel that uses too many registers per thread might get *fewer* warps resident, which means *less* latency hiding, which means the SM sits idle more often waiting on memory — even though the kernel's actual math is fine. This is why "just add more `__shared__` variables to make it faster" can *backfire*: more shared memory per block often means fewer blocks resident, means lower occupancy, means worse latency hiding. Phase 4 will make this quantitative; for now, internalize that GPU performance tuning is resource-constrained packing, not just algorithmic efficiency.

**The mental model reset, stated as a table, CPU thread vs GPU thread:**

| Property | CPU thread (what you're used to) | GPU thread (CUDA) |
|---|---|---|
| Independent instruction stream? | Yes | No — locked in step with 31 siblings in its warp |
| Cost of a branch misprediction/divergence | Pipeline stall, recovers | Serializes the whole warp for the divergent region |
| Typical count you'd launch | Tens to low hundreds | Thousands to millions |
| Per-thread speed | Fast, deeply pipelined, out-of-order | Slow, simple, in-order |
| Why it's fast in aggregate | Fewer, faster threads | Massive oversubscription hides memory latency |
| Scheduling granularity you control | The thread | The block (warps are automatic) |

**Common failure mode:** Writing a kernel where thread behavior depends heavily on `threadIdx` in a way that causes different threads in the *same warp* to diverge (e.g., `if (threadIdx.x < someDataDependentValue)`), then being confused why the kernel is 3-5x slower than a back-of-envelope FLOP count predicts. The fix is almost never "avoid all branches" (that's overcorrection) — it's "know when a branch will diverge *within a warp* vs. *across warps*." A branch where the condition is uniform across an entire warp (e.g., `if (blockIdx.x == 0)`, since all threads in a block share `blockIdx`) costs nothing extra — the whole warp takes the same path. A branch where the condition varies thread-by-thread within a warp (e.g., `if (threadIdx.x % 2 == 0)`) is expensive. Same-looking code, wildly different cost, and you have to reason about *which threads share a warp* to know which case you're in.

**Self-check before moving on:** Can you explain, without looking back at this text, why a kernel with `if (data[idx] > threshold) { expensive_path(); } else { cheap_path(); }` where `threshold` causes roughly half the values in any given warp to go each way, will cost approximately `cost(expensive_path) + cost(cheap_path)` per warp rather than `max(cost(expensive_path), cost(cheap_path))`? If you can explain the masking mechanism in your own words, you've internalized this module. If not, re-read the warp divergence paragraph before continuing — everything downstream assumes this.

---

### Module 0.2 — Environment Setup & The Toolchain

**Objective:** A working, verified CUDA development environment, and understanding of the compilation model (this matters more than it sounds — `nvcc` doing a two-target compile is a frequent source of confusing errors for beginners).

**Prerequisites:** Module 0.1.

**Core content:**

You need: an NVIDIA GPU (physical machine, or a cloud instance — AWS, GCP, and others all offer GPU instances; if you don't have local hardware, this is a completely legitimate path and won't handicap your learning), the CUDA Toolkit (which bundles `nvcc`, the compiler driver; runtime and driver libraries; profiling tools; and headers), and a compatible host compiler (GCC on Linux is standard).

*I'm intentionally not stating "the current CUDA Toolkit version is X" here — toolkit versions ship frequently and stating a specific number risks being stale by the time you read this. Run `nvcc --version` after install to check what you have, and check NVIDIA's developer site for the current release when you install.*

**The compilation model — the part beginners find confusing:** `nvcc` is not a single-target compiler. Your `.cu` file typically contains both **host code** (regular C++ that runs on the CPU — memory allocation, kernel launch calls, orchestration logic) and **device code** (the actual `__global__` kernel functions that run on the GPU). `nvcc` splits these apart, compiles host code with your system's C++ compiler, compiles device code into GPU assembly (PTX, an intermediate representation, then further to SASS, the actual GPU machine code) for the target architecture(s) you specify, and then stitches everything back together into one binary with an embedded GPU payload. This matters practically because:

1. Compile errors in "device code" and "host code" sections can look identical in your terminal but mean very different things — a syntax error might be a normal C++ error, but a "this function is not callable from device code" error is a *architecture model* violation, not a syntax problem (e.g., calling `malloc()` naively inside a kernel behaves differently than you'd expect, or calling a host-only library function from device code fails outright).
2. You must tell `nvcc` which GPU architecture(s) to compile for, via `-arch=sm_XX` (or the more flexible `-gencode` flag for multi-architecture binaries). If you compile for the wrong compute capability, your code might not run at all on your actual hardware, or it'll run in a slow JIT-compiled fallback mode. Check your GPU's compute capability (a small version number specific to each GPU generation) before your first compile — this trips up nearly everyone once.

**Worked example — minimal verification kernel:**

```cuda
// hello_gpu.cu
#include <cstdio>

__global__ void helloFromGPU() {
    printf("Hello from block %d, thread %d (global thread id %d)\n",
           blockIdx.x, threadIdx.x, blockIdx.x * blockDim.x + threadIdx.x);
}

int main() {
    // Launch config: <<<numBlocks, threadsPerBlock>>>
    helloFromGPU<<<2, 4>>>();

    // Kernel launches are ASYNCHRONOUS w.r.t. the host — the CPU moves on
    // immediately after the launch call returns. Without an explicit sync,
    // your program could exit before the GPU has even started, let alone
    // printed anything. This is a foreshadow of a whole category of bugs
    // in Phase 1.
    cudaDeviceSynchronize();

    return 0;
}
```

Compile with something like `nvcc -arch=sm_XX hello_gpu.cu -o hello_gpu` (substitute your actual compute capability for `sm_XX`), then run `./hello_gpu`.

**What to notice in the output when you run this:** the print order across threads will almost certainly *not* be sequential (block 0 thread 0, block 0 thread 1, ...) — you'll see interleaving. This is your first direct, empirical evidence that thread execution order across blocks (and often across warps) is not guaranteed and not something you should ever rely on. Internalize this now, empirically, rather than taking my word for it.

**Common failure mode:** Forgetting `cudaDeviceSynchronize()` (or another synchronization point) after a kernel launch, then being confused why nothing prints, or why results look wrong. Kernel launches are fire-and-forget from the host's perspective — the CPU thread continues executing your `main()` immediately. This asynchronous-by-default behavior is a core design feature (it's *why* CUDA can overlap CPU and GPU work), but it means every beginner hits "my kernel didn't run" bugs that are actually "my kernel hadn't finished running yet when I checked" bugs.

**Self-check:** Explain in your own words why removing `cudaDeviceSynchronize()` from the example above could cause the program to print nothing at all, some of the time, depending on system load — not just print things in a different order, but potentially not print anything.

---

## Phase 1 — Foundations: Kernels, Memory, and Correctness

### Module 1.1 — Thread Indexing & The Grid-Stride Pattern

**Objective:** Correctly map GPU threads to data elements for arbitrary-sized problems, including problems larger than what one grid launch can directly index.

**Prerequisites:** Module 0.1, 0.2.

**Core content:**

Every kernel needs to answer "which piece of data does *this* thread work on?" The built-in variables available inside a kernel are:
- `threadIdx` — this thread's index *within its block* (has `.x`, `.y`, `.z` components — blocks can be 1D, 2D, or 3D)
- `blockIdx` — this thread's block's index *within the grid*
- `blockDim` — the size of each block (how many threads per block, in each dimension)
- `gridDim` — the size of the grid (how many blocks, in each dimension)

The standard 1D global index formula, which you will write approximately ten thousand times over your CUDA career:

```cuda
int idx = blockIdx.x * blockDim.x + threadIdx.x;
```

Read this as: "skip past all the threads in the blocks before mine (`blockIdx.x * blockDim.x`), then add my position within my own block (`threadIdx.x`)." This gives every thread across the *entire grid* a unique global index, analogous to flattening a 2D array index.

**The problem this doesn't solve:** grids have a maximum size, and even below that maximum, you often don't want to hardcode your launch configuration to exactly match your data size (what if the data size changes at runtime? What if you want to reuse this kernel for different-sized inputs without recompiling?). The fix is the **grid-stride loop** pattern:

```cuda
__global__ void gridStrideExample(float *data, int n, float scalar) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;  // total number of threads launched

    for (int i = idx; i < n; i += stride) {
        data[i] *= scalar;
    }
}
```

This decouples "how many threads I launch" from "how much data I have to process." Each thread processes potentially *multiple* elements, striding forward by the total thread count each time, until it walks off the end of the array. This is the idiomatic, production pattern — you'll see this far more often in real code than a naive "one thread, one element, hope it fits" kernel. It also has a nice side effect: it makes your kernel robust to under-launching (fewer threads than data elements) without any correctness change, only a throughput change.

**Worked example — vector addition, done properly:**

```cuda
#include <cstdio>
#include <cuda_runtime.h>

__global__ void vectorAdd(const float *a, const float *b, float *c, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;
    for (int i = idx; i < n; i += stride) {
        c[i] = a[i] + b[i];
    }
}

int main() {
    const int N = 1 << 20;  // ~1M elements
    size_t bytes = N * sizeof(float);

    // Host allocations
    float *h_a = new float[N];
    float *h_b = new float[N];
    float *h_c = new float[N];
    for (int i = 0; i < N; i++) { h_a[i] = 1.0f; h_b[i] = 2.0f; }

    // Device allocations
    float *d_a, *d_b, *d_c;
    cudaMalloc(&d_a, bytes);
    cudaMalloc(&d_b, bytes);
    cudaMalloc(&d_c, bytes);

    // Host -> device transfer
    cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice);

    // Launch: a common, reasonable default is 256 threads/block.
    // Why 256 specifically? It's usually a good balance for occupancy on
    // most architectures (multiple of the 32-thread warp size, and small
    // enough to allow multiple blocks resident per SM). Phase 4 covers
    // how to actually tune this rather than guess.
    int threadsPerBlock = 256;
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;
    vectorAdd<<<blocksPerGrid, threadsPerBlock>>>(d_a, d_b, d_c, N);

    cudaMemcpy(h_c, d_c, bytes, cudaMemcpyDeviceToHost);

    // Verify
    bool correct = true;
    for (int i = 0; i < N; i++) {
        if (h_c[i] != 3.0f) { correct = false; break; }
    }
    printf(correct ? "PASSED\n" : "FAILED\n");

    cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);
    delete[] h_a; delete[] h_b; delete[] h_c;
    return 0;
}
```

Notice the ceiling-division idiom `(N + threadsPerBlock - 1) / threadsPerBlock` — this is how you compute "enough blocks to cover N elements, rounding up" in integer arithmetic. You'll also write this constantly.

**Common failure mode:** Off-by-one and out-of-bounds errors from forgetting the `i < n` bounds check inside the loop (or, in a naive non-grid-stride kernel, forgetting `if (idx < n)` before accessing `data[idx]`). Because you virtually always launch *at least* enough threads to cover your data (often slightly more, due to the ceiling division), threads at the tail end of the last block will have indices that run past the end of your array if you don't guard for it. This doesn't always crash — sometimes it silently reads/writes adjacent device memory, corrupting other data or producing wrong-but-plausible-looking results, which is far more dangerous than a crash because it doesn't announce itself.

**Self-check:** Given `N = 1000` and `threadsPerBlock = 256`, compute `blocksPerGrid` by hand using the ceiling-division formula, then state which global thread indices in the *last* block would be out-of-bounds if there were no bounds check.

---

### Module 1.2 — Memory Transfer, Error Handling, and Why Silent Failures Are the Default

**Objective:** Understand host-device memory transfer costs, and build the habit of rigorous CUDA error checking — because CUDA fails silently by default, and this is the single most impactful habit for avoiding hours of confused debugging.

**Prerequisites:** Module 1.1.

**Core content:**

**On error handling first, because it's foundational to everything after this point:** almost every CUDA runtime API call returns a `cudaError_t`. Kernel launches themselves don't return an error code directly (the `<<<...>>>` syntax doesn't have a return value slot), but they set an internal error state you can query. **The critical, non-obvious fact: if you don't check these return values, a failing kernel launch or a failing `cudaMemcpy` will often not crash your program — it'll just silently not do what you wanted, and your program will continue running with wrong or stale data.** This is the opposite of how most host-side C++ errors behave (where a segfault at least tells you something's wrong), and it's why disciplined CUDA developers wrap every single API call.

The standard idiom is a macro:

```cuda
#define CUDA_CHECK(call)                                                     \
    do {                                                                     \
        cudaError_t err = call;                                              \
        if (err != cudaSuccess) {                                            \
            fprintf(stderr, "CUDA error at %s:%d — %s\n",                    \
                    __FILE__, __LINE__, cudaGetErrorString(err));            \
            exit(EXIT_FAILURE);                                              \
        }                                                                    \
    } while (0)
```

And you use it around *every* CUDA call: `CUDA_CHECK(cudaMalloc(&d_a, bytes));`, `CUDA_CHECK(cudaMemcpy(...));`, and critically, after a kernel launch, you should check for launch errors *and* execution errors separately, because a launch can fail immediately (bad configuration — e.g., requesting more threads per block than the hardware supports) or fail *during* execution (e.g., an out-of-bounds memory access inside the kernel, which surfaces later):

```cuda
myKernel<<<blocks, threads>>>(args...);
CUDA_CHECK(cudaGetLastError());       // catches launch configuration errors
CUDA_CHECK(cudaDeviceSynchronize());  // catches errors that occur during execution
```

Adopt this from your very first real program, not after you've been burned once. It will save you disproportionate time relative to its triviality to write.

**On memory transfer costs:** the PCIe (or NVLink, on systems that have it) bus connecting host and device memory is *orders of magnitude* slower than either host RAM bandwidth or device (GPU) memory bandwidth. A rough mental anchor (architecture-dependent, don't treat as a hard number, but useful for intuition): device memory bandwidth is commonly in the hundreds of GB/s to low TB/s range on modern datacenter GPUs, while PCIe transfer bandwidth is typically one to two orders of magnitude lower. This means: **the cost of moving data to/from the GPU can easily dominate the cost of the computation itself**, especially for kernels that do relatively little math per byte of data (a category with a name you'll meet formally in Phase 4: "memory-bound" kernels, characterized by low **arithmetic intensity**).

The practical consequence: naive CUDA code that transfers data to the GPU, does a small amount of work, transfers back, and repeats this pattern in a loop is often *slower* than just doing the equivalent work on the CPU, because you're paying the (large, fixed) transfer cost repeatedly instead of amortizing it. The right pattern is almost always: transfer once, do as much work as possible on the device before transferring back, and if you have a pipeline of multiple kernels, keep intermediate results on the device between kernel calls rather than round-tripping to host memory between each step.

**Worked example — the anti-pattern vs. the fix, made concrete:**

```cuda
// ANTI-PATTERN: transfer-per-iteration inside a loop
for (int iter = 0; iter < 1000; iter++) {
    cudaMemcpy(d_data, h_data, bytes, cudaMemcpyHostToDevice); // slow, repeated
    someKernel<<<blocks, threads>>>(d_data, n);
    cudaMemcpy(h_data, d_data, bytes, cudaMemcpyDeviceToHost); // slow, repeated
    // ... some host-side logic that modifies h_data before next iteration ...
}

// FIX (when the host-side logic can be eliminated or moved to device):
// transfer once, iterate entirely on-device
cudaMemcpy(d_data, h_data, bytes, cudaMemcpyHostToDevice);
for (int iter = 0; iter < 1000; iter++) {
    someKernel<<<blocks, threads>>>(d_data, n);
    // if the "host-side logic" can be a second kernel, do it on-device instead
}
cudaMemcpy(h_data, d_data, bytes, cudaMemcpyDeviceToHost);
```

The fix isn't always this clean in practice — sometimes you genuinely need host-side logic between iterations. But the *default assumption* should be "can this stay on the device," not "I'll just transfer it back because that's easier to reason about," because the transfer cost compounds fast.

**Common failure mode:** Benchmarking a kernel's execution time without accounting for transfer time, concluding "CUDA made this 50x faster," then being confused in production when the end-to-end pipeline (which includes transfer) is only modestly faster than the CPU baseline, or not faster at all. Always benchmark the *whole* pipeline you care about, not just the kernel in isolation, unless you have a specific, justified reason to isolate kernel time (e.g., you're optimizing a kernel that will be called many times per transfer in the real pipeline, so transfer cost genuinely amortizes away).

**Self-check:** Given a kernel that processes 100MB of data with roughly 2 floating point operations per byte, and knowing that PCIe transfer is the likely bottleneck for low-arithmetic-intensity workloads, explain qualitatively (no need for exact numbers) why this kernel is a poor candidate for GPU acceleration *unless* it's called repeatedly on data that's already resident on the device.

---

## Phase 2 — The Memory Hierarchy (This Is Where Performance Actually Lives)

### Module 2.1 — The Full Hierarchy, Top to Bottom

**Objective:** Know every level of the CUDA memory hierarchy, its rough latency/bandwidth characteristics, its scope (which threads can see it), and its lifetime — because *choosing the right memory space for the right data* is the single highest-leverage optimization decision in CUDA, more impactful than almost any algorithmic cleverness.

**Prerequisites:** Phase 1 complete.

**Core content:**

This is the module I want you to genuinely internalize, not skim, because I'd estimate it's responsible for a larger fraction of the gap between "CUDA code that works" and "CUDA code that's actually fast" than any other single topic in this curriculum.

| Memory type | Scope | Lifetime | Rough speed | Size |
|---|---|---|---|---|
| **Registers** | Per-thread | Thread's lifetime | Fastest | Very small (thousands per SM, shared) |
| **Local memory** | Per-thread | Thread's lifetime | Slow (physically lives in global memory!) | Large but slow |
| **Shared memory** | Per-block | Block's lifetime | Very fast (on-chip) | Small (tens of KB per SM, generation-dependent) |
| **Global memory** | All threads, host | Application/allocation lifetime | Slow relative to on-chip, but high aggregate bandwidth | Large (GBs) |
| **Constant memory** | All threads (read-only) | Application lifetime | Fast *if* all threads read the same address (broadcast) | Small (tens of KB) |
| **Texture/read-only memory** | All threads (read-only) | Application lifetime | Cached, good for spatially-local access patterns | Backed by global memory |

Let me unpack the non-obvious entries, because the table alone undersells the traps here:

**Registers** are the fastest memory by a wide margin — reading a register costs essentially nothing extra beyond the instruction itself. But they're a *shared, limited pool per SM*, allocated statically per-thread based on how many the compiler decides your kernel needs. This directly feeds into the occupancy/knapsack framing from Module 0.1: a kernel with a lot of local variables and complex expressions might use many registers per thread, which limits how many threads/warps can be resident simultaneously on an SM, which limits occupancy, which limits latency hiding. You can inspect register usage per kernel with `nvcc --ptxas-options=-v`, and you can *cap* register usage with the `-maxrregcount` compiler flag or the `__launch_bounds__` kernel annotation — though capping too aggressively can force the compiler to "spill" excess variables into local memory, which brings me to the next entry, and which is usually a worse tradeoff than the register pressure you were trying to avoid.

**Local memory is the most misleadingly-named concept in CUDA, and I want to be very explicit about this because the name actively lies to you.** "Local" sounds like it should mean "close, fast, on-chip" — like registers. It does not. Local memory is per-thread *private* memory, but it is physically backed by the *same DRAM as global memory*, just with a per-thread addressing scheme and typically routed through the same cache hierarchy as global memory accesses. It exists for data that doesn't fit in registers — large local arrays, or register-spilled variables when the compiler runs out of register budget for a thread. **Local memory is slow.** If you declare a sizable local array inside a kernel (`float buffer[64];`) and the compiler can't keep it entirely in registers (which is common — register-resident arrays require the compiler to prove all accesses are at compile-time-known indices, so anything indexed by a runtime-computed value very often spills), you're silently paying global-memory-tier latency for something that *looks* like a fast local variable in your source code. This is a genuine trap: the syntax gives no visual signal that you've fallen into it. Check compiler output (`-ptxas-options=-v` again, look for "spill" in the output) if you suspect this.

**Shared memory** is on-chip, fast, and — critically — *explicitly programmer-managed and shared across all threads in a block*. This is your primary tool for two things: (1) inter-thread communication and cooperation within a block (threads can write to a shared memory location and other threads in the same block can read it, after a synchronization point), and (2) manually caching frequently-reused global memory data to avoid redundant slow global memory reads. The canonical use case, which you'll implement properly in Module 3.4 (matrix multiplication), is: load a tile of data from global memory into shared memory once, cooperatively, with all threads in the block participating in the load, then have every thread in the block reuse that shared-memory-resident tile many times, instead of every thread independently re-reading the same global memory addresses. This turns an access pattern with massive redundant global memory traffic into one slow global read per element (per tile) instead of one slow global read *per use* of that element.

Shared memory has its own hazard, **bank conflicts**, which I'll cover in depth in Module 4.3 because it deserves real space rather than a summary here — briefly: shared memory is physically divided into banks, and if multiple threads in the same warp access different addresses that happen to map to the *same bank* simultaneously, those accesses get serialized instead of running in parallel, silently degrading your shared-memory speedup.

**Global memory** is what `cudaMalloc` gives you, and it's what host `cudaMemcpy` targets. It's large, but slow relative to on-chip memory (though its *aggregate bandwidth*, when accessed well by many threads simultaneously, is genuinely high — this is a bandwidth-vs-latency distinction that matters: a single global memory access is slow, but the GPU is designed to have enough concurrent accesses in flight to still achieve high aggregate throughput, *if you access it well*). "Accessing it well" means **coalescing**, which gets its own full module (2.2) because it's that important.

**Constant memory** is small, cached, and read-only from the kernel's perspective (you set it up from host code before launch). It shines specifically when *every thread in a warp reads the exact same address* — the hardware can broadcast that single read to all 32 threads for close to the cost of one read. If threads in a warp read *different* addresses from constant memory, you lose the broadcast benefit and it degrades toward the cost of separate serialized reads. Good use cases: lookup tables, kernel parameters/coefficients that are identical for every thread — e.g., a convolution filter's fixed weights.

**Common failure mode:** Treating global memory as "the" memory space and never reaching for shared memory at all, because a kernel that only uses global memory is *correct* — it'll produce the right answer — so there's no correctness-driven pressure to learn shared memory. The performance cost of this is invisible unless you profile, which is exactly why Phase 4 exists and why I keep pointing forward to it: a huge fraction of "my CUDA code doesn't seem much faster than CPU" reports trace back to a kernel that's algorithmically fine but never uses shared memory to avoid redundant global memory traffic.

**Self-check:** For a kernel that reads the same 16 values from global memory in a fixed pattern used by *every thread in a block* (e.g., filter coefficients in a convolution), name two memory spaces from the table above that would be strong candidates for holding those 16 values instead of leaving them in global memory, and explain the mechanism (not just "it's faster") for why each would help.

---

### Module 2.2 — Coalescing: The Access Pattern That Determines Global Memory Throughput

**Objective:** Understand *precisely* what makes a global memory access pattern fast vs. slow, because "coalescing" is thrown around as jargon constantly in CUDA material without the mechanism being explained, and the mechanism is what actually lets you predict performance from reading code.

**Prerequisites:** Module 2.1.

**Core content:**

Here's the mechanism, stated plainly: when a warp (32 threads, executing in lockstep, remember) issues a global memory load or store instruction, the hardware doesn't service 32 individual, independent memory transactions. Instead, it examines the addresses all 32 threads are requesting *simultaneously*, and tries to service them with as *few* memory transactions as possible, by grouping addresses that fall within the same aligned memory segment into a single wide transaction.

**Coalesced access** — the fast case — is when the 32 threads in a warp access 32 *consecutive* memory addresses (thread 0 reads element 0, thread 1 reads element 1, ..., thread 31 reads element 31). This pattern maps naturally onto a small number of wide, aligned memory transactions, and the hardware services the entire warp's request about as efficiently as physically possible.

**Uncoalesced (strided or scattered) access** — the slow case — is when the 32 threads access addresses that are far apart, or in an irregular/scattered pattern (e.g., thread `i` accesses `data[i * stride]` for some large `stride`, or accesses driven by an indirection like `data[index_array[i]]` where `index_array` values are effectively random). Because the addresses don't fall into shared, small memory segments, the hardware has to issue many more, narrower transactions to service the same warp — you might pay the bandwidth cost of transferring far more data than you actually need, or issue many more transaction cycles than the coalesced case, for the exact same *amount* of useful data requested.

**Worked example that makes this concrete — the classic row-major vs. column-major access trap:**

```cuda
// Assume a row-major 2D array flattened to 1D: element (row, col) is at
// data[row * numCols + col]

// COALESCED (fast): consecutive threadIdx.x maps to consecutive columns,
// which are consecutive in memory for a row-major layout
__global__ void coalescedAccess(float *data, int numRows, int numCols) {
    int row = blockIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    if (col < numCols) {
        data[row * numCols + col] *= 2.0f;  // consecutive threads -> consecutive addresses
    }
}

// UNCOALESCED (slow): consecutive threadIdx.x maps to consecutive ROWS,
// which are numCols elements apart in memory — a large stride
__global__ void uncoalescedAccess(float *data, int numRows, int numCols) {
    int col = blockIdx.y;
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    if (row < numRows) {
        data[row * numCols + col] *= 2.0f;  // consecutive threads -> addresses numCols apart
    }
}
```

Both kernels are algorithmically identical — same amount of work, same data, same math. The *only* difference is which axis maps to `threadIdx.x`, and therefore which axis is contiguous in memory versus which axis strides by `numCols`. Depending on `numCols`, the second version can be dramatically slower — easily several times slower, sometimes an order of magnitude, purely from the access pattern — with *zero* difference in the arithmetic being performed. This is, I'd argue, the single clearest demonstration in all of CUDA that "the same math, expressed differently, can have wildly different performance," and it's why profiling (Phase 4) rather than reading code and guessing is how professionals actually validate performance.

**The row-major/column-major trap generalizes**: whenever you're indexing a multi-dimensional array, always ask "does consecutive `threadIdx.x` correspond to consecutive memory addresses, given this array's actual memory layout?" This single question catches a large fraction of coalescing bugs before you even run the code.

**Common failure mode:** Writing "natural-looking" code that maps `threadIdx.x` to the mathematically-natural axis of a problem (e.g., "thread x handles row x" because that's how you'd think about it on paper or in a math notation) without checking whether that axis is memory-contiguous, and then not understanding why performance is poor even though the code is correct and looks reasonable. There's no compiler warning for this — it compiles clean and runs correct, just slow.

**Self-check:** For a column-major (Fortran-style) 2D array instead of row-major, would the "coalesced" and "uncoalesced" kernels above swap roles? Reason through why or why not from the memory-layout mechanism, not from memorizing "rows are fast" as a rule (which is layout-dependent, not universal).

---

## Phase 3 — Core Algorithmic Patterns

*Each pattern below is chosen because it teaches a specific hazard you'll encounter constantly in real kernels, not because these are the only useful patterns. Work through them in order — reduction teaches synchronization and the "half the threads idle" problem; scan teaches a genuinely non-obvious parallel algorithm; stencil teaches shared-memory tiling with halo regions; histogram teaches atomics and contention; matrix multiply integrates everything from Phase 2.*

### Module 3.1 — Parallel Reduction

**Objective:** Learn to parallelize an inherently sequential-looking operation (sum/max/min over an array) correctly and efficiently, and understand `__syncthreads()` deeply — not just as "a barrier," but as a correctness requirement with sharp edges.

**Prerequisites:** Phase 2 complete.

**Core content:**

Reduction (summing an array, finding its max, etc.) looks sequential on paper: `total = a[0] + a[1] + a[2] + ... `. The parallel version restructures this as a tree: pairs of elements are combined, then pairs of *those* results are combined, halving the active element count at each step, until one value remains.

**The naive-but-instructive first attempt**, entirely within shared memory for one block:

```cuda
__global__ void reduceSum(const float *input, float *output, int n) {
    extern __shared__ float sdata[];  // dynamically-sized shared memory
    int tid = threadIdx.x;
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    // Load this block's chunk into shared memory
    sdata[tid] = (idx < n) ? input[idx] : 0.0f;
    __syncthreads();  // ensure ALL threads finish loading before any thread reads

    // Tree-based reduction within shared memory
    for (int s = blockDim.x / 2; s > 0; s >>= 1) {
        if (tid < s) {
            sdata[tid] += sdata[tid + s];
        }
        __syncthreads();  // ensure this step's writes are visible before next step's reads
    }

    // Thread 0 of each block writes this block's partial sum
    if (tid == 0) {
        output[blockIdx.x] = sdata[0];
    }
}
```

(For a full reduction across an array larger than one block, you'd launch this kernel, get one partial sum per block into `output`, then either launch the same kernel again on the (now much smaller) `output` array, recursively, or finish the final combination on the host if the number of blocks is small.)

**Why `__syncthreads()` is not optional and not just "a barrier" in the loose sense:** it's a hard synchronization point for *every thread in the block* — every thread must reach it before any thread proceeds past it. In the loop above, without the `__syncthreads()` inside the loop body, a fast thread could race ahead to the *next* iteration's read of `sdata[tid + s]` before a slower thread has finished *this* iteration's write to that same location — a genuine data race, producing silently wrong (not crashed, just numerically incorrect) results, and the wrongness will often not be consistent across runs, because it depends on the actual scheduling/timing of warps, which can vary.

**A subtlety that trips people up: `__syncthreads()` must be reached by *all* threads in the block, unconditionally, or you get undefined behavior — including potential deadlock.** This means you cannot put a `__syncthreads()` call inside a divergent branch that only *some* threads in the block will take:

```cuda
// DANGEROUS — undefined behavior / potential deadlock
if (tid < s) {
    sdata[tid] += sdata[tid + s];
    __syncthreads();  // only threads with tid < s reach this — BAD
}
```

versus the correct version shown in the worked example above, where the `if` guards only the *work*, and `__syncthreads()` sits *outside* the conditional so every thread in the block reaches it every iteration, regardless of whether that particular thread did work that iteration. This is a genuinely easy mistake to make when you're focused on "which threads need to do the add" and reflexively wrap the sync call along with the work in the same conditional.

**Why "half the threads idle" is a known, accepted limitation of this simple version, and what the fix looks like conceptually:** notice that in the first iteration of the loop, only `blockDim.x / 2` threads do any actual addition — the rest just sit there (their `if` condition is false) until the *next* iteration where the active count is halved again. This means at every step, half of the currently-active threads are idle. This is a real inefficiency, and production-quality reduction kernels address it with techniques like having each thread load *and add* two elements before the tree reduction even starts (halving the required tree depth up front), unrolling the last warp's iterations to avoid `__syncthreads()` overhead once you're down to a single warp (since a single warp is already synchronized by the SIMT execution model itself — no explicit sync needed within one warp for a plain reduction like this), and using warp-level shuffle intrinsics (`__shfl_down_sync` and similar) to do the final stages of reduction *without touching shared memory at all*, since warp-level lockstep execution means threads within one warp can exchange values directly through registers. I'm deliberately not writing out every one of these optimizations in full here — this module's job is to get the *correctness and synchronization* model right, which is the harder conceptual hurdle; once that's solid, the optimized versions are a natural next step and abundant NVIDIA documentation covers the warp-shuffle-based versions in detail once you're ready for them.

**Common failure mode:** The divergent-`__syncthreads()`-inside-a-conditional bug shown above, which sometimes produces wrong results and sometimes produces a hang (deadlock), depending on exact conditions — non-deterministic-*looking* bugs are especially demoralizing to debug because "run it again" sometimes just... works, which is the worst possible signal for actually finding the bug.

**Self-check:** Trace through the reduction loop by hand for `blockDim.x = 8`, writing out which thread indices are active (satisfy `tid < s`) at each value of `s` (4, 2, 1), and confirm that after the `s = 1` iteration, `sdata[0]` holds the sum of all 8 original elements.

---

### Module 3.2 — Parallel Scan (Prefix Sum)

**Objective:** Understand a genuinely non-obvious parallel algorithm — one where the parallel version isn't just "the sequential version, but simultaneous," but a structurally different algorithm — because this is a useful category of thinking you'll need again for other problems that don't parallelize "naturally."

**Prerequisites:** Module 3.1.

**Core content:**

A prefix sum (scan) computes, for an array `[a0, a1, a2, a3, ...]`, the running totals `[a0, a0+a1, a0+a1+a2, a0+a1+a2+a3, ...]` (inclusive scan) or the same shifted by one (exclusive scan, `[0, a0, a0+a1, a0+a1+a2, ...]`). This *looks* inherently sequential — element `i`'s result depends on element `i-1`'s result — which is exactly why it's instructive: the parallel algorithm (the Hillis-Steele or Blelloch approaches) restructures the computation entirely rather than trying to parallelize the sequential dependency chain directly.

**Hillis-Steele scan** (simpler to understand, though not the most work-efficient version — I'm choosing it for teaching clarity over raw efficiency, and noting that tradeoff explicitly rather than pretending there's one "right" version):

```cuda
__global__ void inclusiveScanHillisSteele(float *data, int n) {
    extern __shared__ float temp[];
    int tid = threadIdx.x;

    temp[tid] = (tid < n) ? data[tid] : 0.0f;
    __syncthreads();

    for (int offset = 1; offset < blockDim.x; offset *= 2) {
        float val = 0.0f;
        if (tid >= offset) {
            val = temp[tid - offset];
        }
        __syncthreads();  // all threads must finish READING before any thread WRITES this step
        if (tid >= offset) {
            temp[tid] += val;
        }
        __syncthreads();  // all threads must finish WRITING before next iteration's reads
    }

    if (tid < n) {
        data[tid] = temp[tid];
    }
}
```

Notice the *two* `__syncthreads()` calls per loop iteration, and notice the pattern of reading into a temporary (`val`) *before* the first sync, then writing *after* the first sync. This is a **read-before-write hazard avoidance pattern**: if you wrote directly to `temp[tid]` without first capturing `temp[tid - offset]` into a local variable and synchronizing, you could read a value that a neighboring thread has *already updated this iteration* rather than the value from the *previous* iteration — corrupting the algorithm's correctness, because scan's correctness at each step depends on reading pre-this-step values, not partially-updated ones. This is a more subtle version of the same underlying issue as Module 3.1's synchronization requirement, but here it bites even with a naively-"correct-looking" single-sync version, which is why I want you to see it explicitly rather than discover it as a bug.

**Why I'm showing you this specific algorithm rather than just telling you "scan exists, here's a library call":** the *thinking pattern* — "this looks sequential, so let's restructure it as a different, genuinely parallel algorithm with a different work distribution across iterations, rather than trying to force-parallelize the sequential recurrence" — recurs for other classically-sequential-looking problems (parallel sorting networks, certain graph algorithms, parts of parallel string processing). Scan is the cleanest, most teachable instance of this pattern, so it's worth understanding structurally, not just as "a thing CUDA can do."

**Common failure mode:** Trying to write scan "the obvious way" — literally translating the sequential recurrence `data[i] += data[i-1]` into a kernel where each thread reads its left neighbor — without understanding *why* this doesn't work in parallel (every thread would need every other thread to have already finished, creating a dependency chain that's not actually parallel at all, just sequential execution disguised as a kernel), and getting stuck rather than recognizing this calls for a structurally different algorithm.

**Self-check:** For `n = 8` and input `[3, 1, 4, 1, 5, 9, 2, 6]`, trace the Hillis-Steele algorithm by hand for at least the first two iterations (`offset = 1`, then `offset = 2`), and verify your intermediate `temp` array values match what you'd expect from the "each element becomes the sum of itself and its neighbor `offset` positions back" description.

---

### Module 3.3 — Stencil Computation & Shared Memory Tiling with Halo Regions

**Objective:** Learn the shared-memory tiling pattern for kernels where each output element depends on a *neighborhood* of input elements (not just one), and understand "halo" regions — a concept specific to this pattern that trips people up because block boundaries don't align with data-dependency boundaries.

**Prerequisites:** Phase 2, Module 3.1.

**Core content:**

A stencil computation is one where each output element depends on a small, fixed neighborhood of input elements — the classic example is a discrete 1D or 2D convolution/smoothing filter, where `output[i]` depends on `input[i-1], input[i], input[i+1]` (for a simple 3-point stencil) or a larger neighborhood.

The naive approach — every thread independently reads its neighborhood directly from global memory — works correctly but wastes bandwidth: for a 3-point stencil, `input[i]` gets read by *three different threads* (the ones computing `output[i-1]`, `output[i]`, and `output[i+1]`), each pulling it straight from slow global memory redundantly, when it could be read once and reused.

The fix is the tiling pattern: each block cooperatively loads its assigned chunk of input data into shared memory *once*, **plus a small extra border of neighboring elements ("halo" cells) that this block's threads need but that technically "belong" to the neighboring block's data range**, then every thread computes its output by reading exclusively from the fast shared-memory tile, including the halo cells.

**Worked example — 1D 3-point stencil with halo:**

```cuda
#define RADIUS 1  // 3-point stencil = 1 neighbor on each side
#define BLOCK_SIZE 256

__global__ void stencil1D(const float *input, float *output, int n) {
    __shared__ float tile[BLOCK_SIZE + 2 * RADIUS];  // extra space for halo

    int gindex = blockIdx.x * blockDim.x + threadIdx.x;  // global index
    int lindex = threadIdx.x + RADIUS;  // local index within the tile, shifted past the halo

    // Each thread loads its own element into the "core" of the tile
    if (gindex < n) {
        tile[lindex] = input[gindex];
    }

    // The threads at the EDGES of the block additionally load the halo cells
    // — this is the part that's easy to get wrong, because it's extra work
    // done by only SOME threads, based on their position in the block, not
    // based on the data itself
    if (threadIdx.x < RADIUS) {
        // Left halo: this block's leftmost RADIUS threads load the RADIUS
        // elements immediately to the left of this block's range
        int leftGlobalIdx = gindex - RADIUS;
        tile[lindex - RADIUS] = (leftGlobalIdx >= 0) ? input[leftGlobalIdx] : 0.0f;

        // Right halo: same threads (reusing the "first RADIUS threads" slots)
        // load the RADIUS elements immediately to the right of this block's range
        int rightGlobalIdx = gindex + BLOCK_SIZE;
        tile[lindex + BLOCK_SIZE] = (rightGlobalIdx < n) ? input[rightGlobalIdx] : 0.0f;
    }

    // CRITICAL: every thread must wait here until ALL loads (core AND halo)
    // are complete, because computing this thread's output requires reading
    // neighbor cells that may have been loaded by a DIFFERENT thread
    __syncthreads();

    if (gindex < n) {
        float result = 0.0f;
        for (int offset = -RADIUS; offset <= RADIUS; offset++) {
            result += tile[lindex + offset];
        }
        output[gindex] = result / (2 * RADIUS + 1);  // simple averaging stencil
    }
}
```

**Why the halo-loading logic looks asymmetric and threadIdx-dependent rather than clean and uniform:** because it fundamentally is asymmetric — only the threads at a block's boundary have a responsibility that "interior" threads don't have, and that responsibility (loading a neighbor cell from a range that's actually outside "this block's own" data assignment) doesn't map onto every thread the way the "core" load does. This is different in character from every kernel you've written so far in this curriculum, where every thread did essentially symmetric work. Get comfortable with this shape — cooperative loading where different threads within one block have genuinely different jobs — because it recurs in more advanced tiling patterns (2D stencils, and especially in Module 3.4's tiled matrix multiply, where the "which data does this thread load into shared memory" question and "what does this thread compute" question become properly decoupled from each other).

**Common failure mode:** Off-by-one errors in the halo indexing (getting `lindex - RADIUS` vs `lindex + RADIUS` swapped, or miscounting the tile's total required size — forgetting the `2 * RADIUS` extra space in the `__shared__` array declaration), and boundary condition bugs at the very edges of the *global* array (index `0` has no valid left neighbor; index `n-1` has no valid right neighbor) which are easy to conflate with the *block* boundary halo logic but are a separate concern requiring separate bounds checks (note the `leftGlobalIdx >= 0` and `rightGlobalIdx < n` guards in the example, which are about global array bounds, distinct from the block-local halo loading logic itself).

**Self-check:** Extend the reasoning (you don't need to write the full kernel) to a 2D stencil — describe in words which threads in a 2D thread block would be responsible for loading which halo cells (think about the four edges and four corners of a 2D tile separately), and note why the corners are a special case distinct from the edges.

---

### Module 3.4 — Tiled Matrix Multiplication (The Integration Capstone of Phase 3)

**Objective:** Combine everything from Phase 2 and Modules 3.1–3.3 into one kernel — this is the pattern most CUDA tutorials treat as "the" canonical example, and for good reason: it genuinely exercises the memory hierarchy, coalescing, shared memory tiling, and synchronization all at once.

**Prerequisites:** Modules 2.1, 2.2, 3.3.

**Core content:**

Naive matrix multiply — every output thread independently computes its dot product by reading directly from global memory — has terrible arithmetic intensity relative to memory traffic: for an `N x N` matrix multiply, each element of matrix A gets re-read from global memory `N` times (once for every output element in its row), and similarly for B. The tiled approach: divide both matrices into square tiles, load one tile of A and one tile of B into shared memory cooperatively (analogous to the stencil pattern's cooperative load, but here every thread loads exactly one element rather than having asymmetric boundary-thread responsibilities), have every thread in the block reuse both tiles to accumulate a partial dot product, then slide to the next pair of tiles and repeat, accumulating across all tile-pairs needed to complete the full dot product.

```cuda
#define TILE_SIZE 16

__global__ void tiledMatMul(const float *A, const float *B, float *C, int N) {
    __shared__ float tileA[TILE_SIZE][TILE_SIZE];
    __shared__ float tileB[TILE_SIZE][TILE_SIZE];

    int row = blockIdx.y * TILE_SIZE + threadIdx.y;
    int col = blockIdx.x * TILE_SIZE + threadIdx.x;

    float acc = 0.0f;

    // Slide across tiles along the shared dimension
    for (int t = 0; t < (N + TILE_SIZE - 1) / TILE_SIZE; t++) {
        // Cooperative load: EVERY thread loads exactly one element of each
        // tile — unlike the stencil's asymmetric halo loading, this load is
        // uniform across all threads in the block
        int aCol = t * TILE_SIZE + threadIdx.x;
        int bRow = t * TILE_SIZE + threadIdx.y;

        tileA[threadIdx.y][threadIdx.x] = (row < N && aCol < N) ? A[row * N + aCol] : 0.0f;
        tileB[threadIdx.y][threadIdx.x] = (bRow < N && col < N) ? B[bRow * N + col] : 0.0f;

        __syncthreads();  // wait for the WHOLE tile to be loaded before any thread computes with it

        for (int k = 0; k < TILE_SIZE; k++) {
            acc += tileA[threadIdx.y][k] * tileB[k][threadIdx.x];
        }

        __syncthreads();  // wait for EVERY thread to finish using this tile before overwriting it next iteration
    }

    if (row < N && col < N) {
        C[row * N + col] = acc;
    }
}
```

**Trace through why this reduces global memory traffic, concretely:** in the naive version, computing one output element `C[row][col]` requires reading an entire row of A (`N` elements) and an entire column of B (`N` elements) — and crucially, `A`'s row `row` gets independently re-read by every thread computing any element of `C`'s row `row` (there are `N` such threads), so that row of `A` gets read from global memory `N` times total, redundantly. In the tiled version, each tile of `A` and `B` is read from global memory exactly *once* per block that uses it (cooperatively, by `TILE_SIZE * TILE_SIZE` threads jointly loading `TILE_SIZE * TILE_SIZE` elements — one each), then reused `TILE_SIZE` times from fast shared memory by that block's threads during the inner accumulation loop. The redundancy factor drops from "re-read by every thread that needs it" to "re-read `TILE_SIZE` times instead of `N` times" — and since `TILE_SIZE` is a small constant (16 in this example) while `N` can be arbitrarily large, this is a substantial, scaling-dependent reduction in global memory traffic as problem size grows.

**Notice both `__syncthreads()` calls are doing genuinely different jobs**, and both are required: the first ensures the *entire* tile is loaded before *any* thread starts computing with it (a thread that finished its own single-element load early must not race ahead into the accumulation loop while a slower thread in the same block hasn't finished loading its element yet — the accumulation loop reads from *every* position in the tile, not just the position this thread personally loaded). The second ensures every thread has *finished using* the current tile before the *next* loop iteration starts overwriting `tileA`/`tileB` with the next pair of tiles — without this, a fast thread could start the next iteration's load, clobbering shared memory data a slower thread in the same block is still reading during *this* iteration's accumulation.

**Common failure mode:** Omitting the second `__syncthreads()` (the one after the accumulation loop, before the next tile-load iteration) because it's easy to reflexively think "I only need to sync after loading, not after computing" — this produces a genuine, hard-to-reproduce race condition specifically because it only manifests when thread scheduling causes a fast thread's next-iteration load to actually race ahead of a slow thread's current-iteration read, which won't happen on every run or every input size, making it a classic "works on my machine, fails intermittently in production" bug.

**Self-check:** For `N = 1000` and `TILE_SIZE = 16`, how many tile-iterations does the outer loop run (use the ceiling-division formula from Module 1.1), and what happens on the *last* iteration when `N` isn't an exact multiple of `TILE_SIZE` — walk through how the boundary checks (`row < N && aCol < N`, etc.) handle threads whose tile position would otherwise read past the matrix boundary, and confirm they correctly zero-pad rather than reading garbage or crashing.

*(Note: production code should use NVIDIA's cuBLAS library for matrix multiply rather than hand-rolling this — cuBLAS is extensively hardware-tuned in ways a hand-written kernel like this generally won't match. This module exists to teach you the tiling/memory-hierarchy pattern through the clearest possible example, not to suggest you should hand-roll matmul in production. Module 6.1 covers when and how to reach for libraries instead.)*

---

### Module 3.5 — Histogram & Atomic Operations

**Objective:** Understand atomic operations — what they guarantee, what they cost, and how contention (many threads hitting the same memory address) degrades performance even though the *correctness* guarantee holds regardless of contention level.

**Prerequisites:** Module 3.1.

**Core content:**

A histogram — counting how many data elements fall into each of several "bins" — has a data-dependent access pattern: which memory location a given thread needs to increment depends on the *value* of the data it's looking at, not on its `threadIdx`. This means two different threads (even from different blocks, running at genuinely arbitrary real-world times, not just conceptually "the same instant") might need to increment the *same* bin's counter, and a naive `bin[value]++`-style read-modify-write is a textbook data race: thread A reads the current count, thread B reads the *same* current count before A has written its incremented value back, both compute "count + 1," both write back the same new value — and you've lost one of the two increments, silently.

**Atomic operations** solve this: `atomicAdd(&bin[value], 1)` guarantees the read-modify-write sequence happens as one indivisible unit, hardware-serialized against any other atomic operation targeting the *same address*, regardless of which threads or blocks issue them or when. Correctness is not in question — atomics are correct by construction, always, for this kind of access. **What atomics do not guarantee is performance under contention**, and this is the part that's easy to construe as a solved problem once you've slapped `atomicAdd` on your race condition and confirmed the output is now numerically correct:

```cuda
__global__ void histogramNaive(const int *data, int *bins, int n, int numBins) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;
    for (int i = idx; i < n; i += stride) {
        int bin = data[i] % numBins;  // some binning logic
        atomicAdd(&bins[bin], 1);     // correct, but contended if data is skewed
    }
}
```

If your input data is such that many threads across the grid concurrently land on the *same few bins* (e.g., a heavily skewed distribution — imagine most of your data falling into just 2 or 3 of many possible bins), those few bins' memory addresses become **hot**, and every atomic operation targeting a hot address has to wait for every other pending atomic operation on that exact address to complete first — the hardware serializes them by necessity, since that's the whole point of the guarantee. With thousands of threads potentially converging on a small number of addresses, this serialization can become the dominant cost of the entire kernel, even though the *total amount of work* (number of increments) hasn't changed at all — only its *concentration* has.

**The standard fix — privatized/shared-memory histograms:** rather than every thread directly hitting the global `bins` array, each *block* first builds its own private, block-local histogram in shared memory (still using atomics, but now contention is only among the (typically much smaller number of) threads within one block, and shared memory atomics are typically faster than global memory atomics regardless), and then, once each block's local histogram is complete, one final pass merges every block's private histogram into the global result — this final merge step still needs atomics (different blocks' partial histograms still need to combine into one shared global result), but now there are far fewer atomic operations happening against the global array overall (one merge per block per bin, rather than one atomic per *data element*):

```cuda
__global__ void histogramPrivatized(const int *data, int *globalBins, int n, int numBins) {
    extern __shared__ int localBins[];  // one block-private histogram

    // Initialize this block's local histogram to zero
    for (int i = threadIdx.x; i < numBins; i += blockDim.x) {
        localBins[i] = 0;
    }
    __syncthreads();

    // Accumulate into the LOCAL histogram — contention is now bounded by
    // this block's thread count, not the whole grid's
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;
    for (int i = idx; i < n; i += stride) {
        int bin = data[i] % numBins;
        atomicAdd(&localBins[bin], 1);
    }
    __syncthreads();

    // Merge this block's local histogram into the global result — far
    // fewer atomic operations here than one-per-data-element
    for (int i = threadIdx.x; i < numBins; i += blockDim.x) {
        if (localBins[i] > 0) {
            atomicAdd(&globalBins[i], localBins[i]);
        }
    }
}
```

**Common failure mode:** Confirming correctness (the histogram totals are numerically right) and stopping there, without profiling for contention — which is invisible from correctness testing alone, since atomics are *always* correct regardless of contention. You need Phase 4's profiling tools to actually see that a kernel is atomic-contention-bound rather than assuming it based on "well, the numbers are right, so I'm done."

**Self-check:** Explain why the privatized version's *shared-memory* atomics being contended among only, say, 256 threads (one block) is meaningfully better than the naive version's *global-memory* atomics being contended among potentially hundreds of thousands of threads (the whole grid) — specifically, why does reducing the *number of concurrent contenders on any single address*, not just moving the memory space, matter here?

---

## Phase 4 — Performance Engineering (Where "Mastery" Actually Lives)

*Everything before this phase taught you to write correct kernels using the right conceptual tools. This phase teaches you to make measured, evidence-based performance decisions instead of guessing — and I want to be direct that this phase, done properly with real profiling on real hardware, is not optional if "mastering CUDA" is the actual goal. A huge fraction of self-taught CUDA programmers stop before this phase and plateau at "I can write correct kernels" without ever developing "I can predict and fix why a kernel is slow."*

### Module 4.1 — Profiling Methodology: Nsight Compute & Nsight Systems

**Objective:** Learn to use NVIDIA's actual profiling tools rather than guessing at performance from reading source code (which, as Module 2.2's coalescing example showed, can be genuinely misleading — two algorithmically identical kernels can have wildly different real performance for reasons invisible in the code itself).

**Prerequisites:** Phase 1–3 complete, at least a few kernels of your own written and running.

**Core content:**

NVIDIA provides two complementary profiling tools that serve different purposes, and conflating them is a common early mistake:

**Nsight Systems** gives you a *timeline* view of your whole application — CPU activity, GPU kernel execution, memory transfers, all laid out on a shared timeline. Its job is answering "where does my *overall program* spend its time, and how well is CPU/GPU work overlapping?" This is your first stop when you suspect the problem is *system-level* — e.g., "am I transfer-bound," "are my kernels running serially when they could overlap," "is there a big gap where neither CPU nor GPU seems to be doing anything" (often a synchronization or dependency issue).

**Nsight Compute** gives you a *deep, per-kernel* view — it profiles one kernel launch in isolation and reports detailed hardware performance counters: achieved occupancy vs. theoretical maximum, memory throughput vs. peak, whether you're compute-bound or memory-bound, warp execution efficiency (a direct, measured signal of how much warp divergence is actually costing you), and much more. This is your tool once Nsight Systems (or just intuition) has told you *which kernel* is the bottleneck, and you need to understand *why* that specific kernel is slow.

**The workflow that ties this together, stated as a decision process:**
1. Run Nsight Systems on the whole application first. Identify which kernel(s) actually dominate total runtime — don't assume; measure. (A common surprise for beginners: the kernel you spent the most engineering effort optimizing is sometimes *not* the one actually dominating runtime — a "boring" kernel called many times, or the memory transfers themselves, often turn out to matter more.)
2. For the dominant kernel(s), run Nsight Compute to get the detailed breakdown.
3. Nsight Compute will generally tell you, in its summary, whether you're **memory-bound** or **compute-bound** for this specific kernel — this single classification should drive your entire next set of optimization decisions, because optimizing compute when you're memory-bound (or vice versa) wastes effort on the wrong lever entirely.
4. If memory-bound: check achieved memory throughput against the device's theoretical peak. A large gap usually points to a coalescing problem (Module 2.2) or insufficient occupancy to hide memory latency (Module 4.2).
5. If compute-bound: check for warp divergence (Module 0.1) via warp execution efficiency metrics, and check whether you're using the most efficient available instructions for your operation (Phase 6 touches on intrinsics/fast-math tradeoffs).
6. Fix the identified issue, re-profile, and confirm the fix actually moved the metric you targeted — not just "the wall-clock time went down," which can be misleading if you changed multiple things at once or if system noise affected your timing.

**Why "just time it with a stopwatch and eyeball whether it got faster" is insufficient for real mastery, even though it's tempting because it's fast to do:** wall-clock timing tells you *whether* something got faster, but not *why*, and not whether you fixed the actual bottleneck or just got lucky / made an unrelated change that happened to help. Two kernels can have identical wall-clock time for entirely different underlying reasons (one might be memory-bound and near its bandwidth ceiling already — nothing further to gain without an algorithmic change; another might be compute-bound with room to spare — meaning a *different* kind of optimization, like increasing occupancy, would actually help). Without the profiler telling you *which* situation you're in, you're optimizing blind, and "mastery" specifically means not doing that.

**Common failure mode:** Profiling a debug build (compiled without optimization flags, or with device-side debug symbols that disable certain compiler optimizations) and drawing performance conclusions from it — debug builds can be dramatically slower than release builds for reasons entirely unrelated to your actual algorithmic or memory-access choices, and "optimizing" based on debug-build profiling can lead you to fix problems that don't exist in the real, optimized build, while missing the ones that do.

**Self-check:** If Nsight Compute reports that your kernel achieves 85% of theoretical peak memory bandwidth, what does that tell you about whether further optimizing your kernel's *arithmetic* (e.g., using faster math intrinsics) is likely to meaningfully improve wall-clock performance, and why?

---

### Module 4.2 — Occupancy: Making the Knapsack Problem Quantitative

**Objective:** Return to Module 0.1's resource-allocation framing and make it concrete and calculable, rather than just conceptual — this is where your OR background gives you a genuine head start over someone approaching this material without that framing.

**Prerequisites:** Modules 0.1, 2.1, 4.1.

**Core content:**

**Occupancy** is formally defined as the ratio of active warps per SM to the maximum possible active warps per SM (an architecture-specific hard limit). High occupancy isn't a goal in itself — it's a *means* to latency hiding: more resident warps means the scheduler has more options to switch to when the currently-executing warp stalls (typically on a memory access), which means the SM is less likely to sit idle waiting.

The constraint structure, stated as you'd state a resource allocation problem: each SM has a fixed budget of **registers** and a fixed budget of **shared memory**. Every thread block you launch consumes some amount of *both* — registers per thread (times threads per block) and shared memory per block (a single, block-wide allocation, not per-thread). The number of blocks that can be simultaneously resident on one SM is bounded by *whichever resource runs out first* — you might be register-limited (each thread uses so many registers that only a few blocks' worth fit in the register file) or shared-memory-limited (each block requests so much shared memory that only a couple of blocks fit) or limited by an architectural cap on the raw number of resident threads/blocks/warps regardless of register or shared memory usage. **This is a binding-constraint problem — improving the resource you're not actually constrained by does nothing, and you have to identify which constraint binds *for your specific kernel* before you know what to optimize.**

NVIDIA provides an **Occupancy Calculator** (both as a spreadsheet tool historically and integrated into Nsight Compute's reporting, and also programmatically via the `cudaOccupancyMaxActiveBlocksPerMultiprocessor` API, which you can call *from your own host code* to have the runtime tell you, for your actual compiled kernel and actual launch configuration, how many blocks can be resident) — use it rather than hand-calculating, because the exact register/shared-memory limits are architecture-generation-specific and you don't want to be hand-tracking generation-specific numbers when a tool will just tell you.

**The practical tuning loop:**
1. Check your kernel's register usage per thread and shared memory usage per block (via `nvcc --ptxas-options=-v` at compile time, or via Nsight Compute's per-kernel report).
2. Use the occupancy calculator (or the runtime API) to see your *achieved* occupancy given those resource requirements and your chosen block size.
3. If occupancy is low and you've confirmed (via Nsight Compute, Module 4.1) that your kernel is memory-bound and *not* already near peak bandwidth, try reducing register pressure (simplify per-thread state, or use `__launch_bounds__` to hint the compiler toward a register budget — though remember Module 2.1's warning that over-constraining registers can cause spilling into slow local memory, which can *hurt* more than the occupancy gain helps) or reducing shared memory usage per block (e.g., a smaller tile size in a tiled kernel), and re-measure.
4. **Critically: higher occupancy is not always better, and 100% occupancy is not always the goal.** Some kernels achieve near-peak performance at well below 100% theoretical occupancy, because they're already sufficiently latency-hidden, or because they're compute-bound rather than memory-bound (in which case more resident warps competing for the same limited compute units doesn't help — there's nothing to "hide" latency behind if the bottleneck is raw arithmetic throughput, not waiting). This is why Module 4.1's memory-bound-vs-compute-bound classification has to come *before* you chase occupancy numbers — occupancy tuning is the right lever specifically for latency-hiding problems in memory-bound kernels, not a universal knob to max out regardless of what's actually limiting your kernel.

**Common failure mode:** Treating "increase occupancy" as a universally correct optimization goal and spending effort chasing it for a kernel that's actually compute-bound (where it won't help) or already achieving good performance despite modest occupancy (where the "problem" the metric seems to flag isn't actually costing you anything). This is the occupancy-tuning equivalent of optimizing a resource that isn't your binding constraint — exactly the OR-framing mistake of solving the wrong constraint.

**Self-check:** If your kernel's shared memory usage per block is the binding constraint limiting resident blocks per SM (not registers, not the architectural thread/warp cap), name two distinct approaches to relaxing that specific constraint, and explain why simply reducing `threadsPerBlock` (block size) without touching shared-memory-per-block usage would or wouldn't help, given that shared memory is allocated *per block*, not *per thread*.

---

### Module 4.3 — Shared Memory Bank Conflicts

**Objective:** Understand the specific mechanism by which shared memory — which Module 2.1 described as "fast" — can silently become slow, in a way that's structurally analogous to Module 2.2's coalescing lesson but operating at a different level of the memory hierarchy.

**Prerequisites:** Modules 2.1, 3.4.

**Core content:**

Shared memory is physically organized into a fixed number of equal-sized **banks** (a number that, like many hardware specifics, is architecture-generation-dependent, though it has commonly been 32 banks on many recent generations — matching the warp size, which is not a coincidence, since the whole design intent is that a warp's 32 simultaneous shared-memory accesses can, in the best case, each hit a different bank and all proceed in parallel). Consecutive 4-byte words in shared memory are typically distributed round-robin across the banks (word 0 → bank 0, word 1 → bank 1, ..., word 31 → bank 31, word 32 → bank 0 again, wrapping around).

**A bank conflict occurs when multiple threads within the same warp access different addresses that happen to map to the *same* bank, in the same instruction.** When this happens, the hardware cannot service those accesses simultaneously — it serializes them, turning what should have been a single-cycle (or near-single-cycle) parallel access into multiple sequential accesses, directly costing you the speed advantage shared memory was supposed to provide.

**The classic example — column access into a 2D shared memory array with a "bad" stride:**

```cuda
__shared__ float tile[32][32];

// ... assume tile is populated ...

// ACCESSING BY COLUMN: thread `tid` reads tile[tid][someFixedColumn]
// If the array's row size is exactly 32 (matching the bank count), then
// consecutive tid values access addresses that are 32 words apart —
// tile[0][c], tile[1][c], tile[2][c], ... are all 32*4 bytes apart in
// memory, and with 32 banks, a 32-word stride means EVERY thread in the
// warp lands on the SAME bank. This is a worst-case, 32-way bank conflict.
float val = tile[threadIdx.x][someFixedColumn];
```

**The standard, almost eerily simple fix: pad the array's declared row size by one extra element**, so the row size no longer evenly divides the bank count:

```cuda
__shared__ float tile[32][33];  // 33, not 32 — the padding breaks the alignment

float val = tile[threadIdx.x][someFixedColumn];  // now stride-33, not stride-32
```

With a row stride of 33 instead of 32, consecutive `threadIdx.x` values no longer land on the same bank (33 doesn't share the problematic common-factor relationship with the 32-bank count that 32 itself does), and the conflict disappears — for the cost of one wasted `float` of shared memory per row, which is a trivial price for eliminating a full 32-way serialization. This is a genuinely counterintuitive fix on first encounter — "add unused padding to make it faster" feels backwards relative to most performance intuitions (which usually push toward *less* memory used, not more) — but it's a completely standard, well-known technique specifically because the bank-conflict mechanism is about *address-to-bank mapping arithmetic*, not about total memory consumed.

**Connecting this back to Module 3.4's tiled matrix multiply:** look again at that kernel's access pattern — `tileA[threadIdx.y][k]` and `tileB[k][threadIdx.x]` inside the inner accumulation loop. Depending on the exact tile dimensions and which index varies fastest, one or both of these access patterns could be conflict-prone in the same way as the example above, and a serious optimization pass on that kernel would specifically check (via Nsight Compute's bank conflict metrics — this is directly measurable, not something you should have to guess about) whether padding the tile arrays' declared dimensions helps. I'm flagging this explicitly rather than leaving it implicit, because it's a great example of Phase 4 material feeding back into and refining a Phase 3 kernel you already believed was "done."

**Common failure mode:** Assuming "I'm using shared memory, so I'm fast" as a blanket conclusion once you've gotten past Module 2.1's lesson that shared memory beats global memory — without checking whether your *specific access pattern within* shared memory is conflict-free. Shared memory being architecturally fast doesn't protect you from a bad access pattern degrading that speed advantage, in direct structural parallel to how global memory's high aggregate bandwidth doesn't protect you from a bad (uncoalesced) access pattern in Module 2.2.

**Self-check:** For the padded `tile[32][33]` example, explain in your own words why the padding specifically breaks the *modular arithmetic* relationship that caused every thread's column access to land on bank 0 in the unpadded version — you don't need to compute exact bank numbers for every thread, just explain why a stride of 33 distributes accesses across banks differently than a stride of 32 does, given 32 total banks.

---

## Phase 5 — Concurrency: Streams, Overlap, and Multi-GPU

### Module 5.1 — CUDA Streams & Overlapping Compute with Data Transfer

**Objective:** Learn to overlap host-device transfer with kernel execution — a technique that can meaningfully speed up real pipelines beyond anything achievable by kernel-level optimization alone, because it attacks the transfer-cost problem from Module 1.2 structurally rather than just minimizing it.

**Prerequisites:** Module 1.2, Module 4.1 (to actually verify overlap is happening rather than assuming it).

**Core content:**

By default, all CUDA operations you issue (kernel launches, memory copies) go into a single implicit stream, and — critically — operations within *one* stream execute in the order you issued them, each waiting for the previous one to complete (with some exceptions for certain operations, but treat this as the baseline mental model). This means a sequence like "copy data to device, run kernel, copy result back" happens as three sequential phases even though, in principle, transfer and computation use *different* hardware resources (the copy engine(s) vs. the SMs) and could, in principle, happen simultaneously *if* there were independent work available for each to do concurrently.

**CUDA streams** let you create multiple independent command queues. Operations within one stream still execute in order relative to each other, but operations in *different* streams can execute concurrently, as hardware resources allow. The classic use case: split your data into chunks, and for each chunk, issue "transfer chunk to device," "process chunk," "transfer result back" into a *different* stream per chunk (or a small rotating pool of streams). Because chunk 2's *transfer* doesn't depend on chunk 1's *kernel execution* (they're independent data), the hardware can overlap chunk 2's host-to-device copy with chunk 1's kernel still computing, effectively hiding transfer time behind compute time (or vice versa) instead of paying for both sequentially.

**Worked example — chunked, streamed processing:**

```cuda
const int numStreams = 4;
cudaStream_t streams[numStreams];
for (int i = 0; i < numStreams; i++) {
    cudaStreamCreate(&streams[i]);
}

int chunkSize = N / numStreams;
size_t chunkBytes = chunkSize * sizeof(float);

for (int i = 0; i < numStreams; i++) {
    int offset = i * chunkSize;
    // All three of these go into the SAME stream (in order relative to
    // each other), but DIFFERENT streams' operations can overlap with
    // EACH OTHER — stream 0's kernel can run concurrently with stream 1's
    // host-to-device copy, for instance
    cudaMemcpyAsync(d_data + offset, h_data + offset, chunkBytes,
                     cudaMemcpyHostToDevice, streams[i]);
    processKernel<<<blocks, threads, 0, streams[i]>>>(d_data + offset, chunkSize);
    cudaMemcpyAsync(h_result + offset, d_data + offset, chunkBytes,
                     cudaMemcpyDeviceToHost, streams[i]);
}

for (int i = 0; i < numStreams; i++) {
    cudaStreamSynchronize(streams[i]);
    cudaStreamDestroy(streams[i]);
}
```

**A non-obvious prerequisite this example glosses over but which matters in practice: `cudaMemcpyAsync` genuinely overlaps with other stream activity only if the host memory involved (`h_data`, `h_result` here) is *pinned* (page-locked) memory, allocated via `cudaMallocHost` (or `cudaHostAlloc`) rather than ordinary `malloc`/`new`.** Regular, pageable host memory *can* be used with `cudaMemcpyAsync`, but the CUDA driver has to first internally stage it through a pinned buffer before the actual DMA transfer can proceed, which reintroduces a synchronous bottleneck and defeats much of the overlap benefit you were trying to achieve. This is a genuinely easy detail to miss — the code compiles and runs correctly with pageable memory, it just quietly doesn't get you the overlap you designed for, and you'd only catch this by actually profiling (Nsight Systems' timeline view, Module 4.1) and noticing the transfers and kernels *aren't* actually overlapping in the visualization the way your streams code implies they should.

**Common failure mode:** Writing streams-based code, confirming it's *correct* (produces the right output), and assuming overlap is happening because the code "looks like" it should overlap — without verifying via Nsight Systems that the timeline actually shows concurrent execution. Non-pinned host memory (as above), insufficient independent work per stream, or hardware limitations on the number of genuinely concurrent copy engines can all silently prevent the overlap you're expecting, and only a timeline profiler view will actually show you the truth rather than your code's apparent intent.

**Self-check:** Explain why splitting work across streams only helps if the *total* problem can be decomposed into genuinely *independent* chunks — what would go wrong (in terms of correctness, not just missed performance) if you tried to stream-parallelize a problem where chunk `i+1`'s computation actually depended on chunk `i`'s *output*, and you didn't add any explicit synchronization to enforce that dependency across streams?

---

### Module 5.2 — Multi-GPU Programming (Overview & On-Ramp)

**Objective:** Understand the conceptual landscape of multi-GPU programming well enough to know which approach fits a given problem and where to go deeper, rather than full implementation-level depth (this module is intentionally more of a map than a deep-dive, given the scope of a single curriculum — multi-GPU programming is genuinely a specialization within CUDA mastery, not a single technique).

**Prerequisites:** Module 5.1.

**Core content:**

Multi-GPU CUDA programming generally falls into a few structurally distinct approaches, and picking the right one for your problem matters more than technique-level skill in any single one:

**Single-process, multi-device:** one host process manages multiple GPUs directly, using `cudaSetDevice()` to select which GPU subsequent CUDA calls target. This works well when the coordination logic is simple enough to fit in one process and you don't need each GPU to be driven by fully independent CPU resources. Peer-to-peer memory access (`cudaDeviceEnablePeerAccess`, on systems where the GPUs and interconnect support it — commonly via NVLink on systems that have it, though PCIe peer-to-peer is also possible on some configurations) lets one GPU directly read/write another GPU's memory without staging through host memory, which can be substantially faster than the alternative of always routing inter-GPU data through the host.

**Multi-process (often via MPI):** each GPU is driven by its own CPU process, and inter-GPU communication happens through a message-passing layer (commonly MPI in HPC contexts) with CUDA-aware MPI implementations able to directly move data GPU-to-GPU without an explicit host staging step in your own code (the MPI library handles that internally). This scales more naturally to many GPUs across multiple physical machines, which single-process multi-device generally doesn't (a single process can't span physical machines).

**NCCL (NVIDIA Collective Communications Library):** purpose-built for exactly the kind of collective operations (all-reduce, broadcast, scatter, gather) that dominate multi-GPU deep learning training workloads specifically, and it's worth knowing this exists and is the standard tool for that use case specifically, rather than hand-rolling collective communication patterns yourself.

**Where to go deeper from here:** if your actual use case is multi-GPU deep learning training, the practical path is learning NCCL's collective operations and how frameworks like PyTorch/TensorFlow use it under the hood, rather than hand-rolling raw CUDA multi-GPU code — frameworks have already solved this well. If your use case is a custom HPC-style application, CUDA-aware MPI is the more direct path. Given this curriculum's scope, I'm deliberately not expanding this into full worked multi-GPU code examples — this is a genuine specialization, and the honest, useful thing to do here is orient you clearly rather than give you a shallow code sample that wouldn't actually prepare you for the real complexity (topology-aware communication scheduling, load balancing across heterogeneous GPUs, fault tolerance across processes) that real multi-GPU systems have to handle.

**Self-check:** Given a hypothetical task — training a large model across 8 GPUs on one physical machine with NVLink between them — which of the three approaches above would you start investigating first, and why does the "single machine, high-speed interconnect, deep-learning-shaped workload" combination point toward that specific answer rather than the others?

---

## Phase 6 — Modern CUDA: Libraries, Unified Memory, and Beyond Hand-Rolled Kernels

### Module 6.1 — When to Use a Library Instead of Hand-Rolling

**Objective:** Develop the judgment to know when hand-writing a kernel is the right call versus when it's wasted effort relative to a mature, hardware-tuned library — because "mastery" includes knowing when *not* to hand-roll, not just being able to.

**Prerequisites:** Phase 3 complete (so you have direct, personal experience of how much engineering effort goes into a well-tuned hand-written kernel, which is what makes the "use the library instead" judgment land with real weight rather than being an abstract rule).

**Core content:**

NVIDIA maintains a set of extensively hardware-tuned libraries for common operation categories: **cuBLAS** (dense linear algebra — matrix multiply, and the operations you hand-rolled in Module 3.4 in a form NVIDIA's own engineers have tuned per-architecture, often achieving performance a hand-written kernel won't match without similarly deep, architecture-specific tuning effort), **cuFFT** (fast Fourier transforms), **cuDNN** (deep learning primitives — convolutions, pooling, activation functions, tuned specifically for the access patterns and tensor shapes common in neural network workloads), **Thrust** (a C++ STL-like library of parallel algorithms — sort, reduce, scan, transform — built on top of CUDA, giving you Module 3.1 and 3.2's reduction and scan patterns, properly optimized, without writing the kernel yourself), and **cuSPARSE** (sparse matrix operations).

**The judgment call, stated as a decision framework rather than a blanket rule:** reach for a library when your operation is a well-known, general-purpose primitive that the library covers (matrix multiply, FFT, standard neural network layers, sort/reduce/scan on generic data) — you are extremely unlikely to out-tune NVIDIA's own architecture-specific engineering effort with a general hand-written kernel, and the time you'd spend trying is much better spent on the parts of your problem that *are* genuinely custom. Hand-roll when your operation is *not* a standard primitive — a domain-specific computation particular to your problem, a fused sequence of operations where combining several steps into one custom kernel avoids materializing intermediate results to global memory (a technique called **kernel fusion**, which libraries generally can't do for you automatically because it requires knowing your specific pipeline), or a case where you've profiled a library call and found it genuinely doesn't fit your exact data shape or access pattern well (this does happen — libraries are general-purpose and occasionally a very specific, unusual shape falls into a slow path).

**Why Phase 3's hand-rolled versions weren't wasted effort even given this module's conclusion:** understanding *why* cuBLAS's matmul is fast — tiling, shared memory reuse, coalescing, occupancy — is exactly what Module 3.4 taught you, and that understanding is what lets you (a) recognize when a *custom* kernel you write for a non-standard operation needs the same techniques, (b) reason about *why* a library call is or isn't hitting the performance you'd expect when you profile it, and (c) know when kernel fusion of several library calls into one custom kernel is worth the effort, because you understand the memory-traffic cost of *not* fusing them. Library usage without this underlying understanding produces someone who can call `cublasSgemm` but can't diagnose why their end-to-end pipeline is slow when the bottleneck turns out to be the *gaps between* library calls rather than the calls themselves.

**Common failure mode (in both directions):** hand-rolling a standard operation that a library already covers extremely well, burning significant engineering time to land somewhere below the library's out-of-the-box performance; or, conversely, over-relying on library calls even when the actual bottleneck is the *orchestration* around them (unnecessary intermediate global memory round-trips between separate library calls that could have been fused into fewer, custom kernels) — both directions stem from not having done the profiling-driven diagnosis from Phase 4 before deciding where to invest effort.

**Self-check:** You have a pipeline that does: a matrix multiply, followed immediately by an elementwise activation function, followed by another matrix multiply. Using library calls for each step independently would materialize the full intermediate result to global memory twice (once after each matmul) before the next step reads it back. Explain, using Module 1.2 and 2.1's cost framing, why a custom *fused* kernel combining the activation function directly into the matmul's output-writing step (rather than three separate library calls with full round-trips between them) could be worth the hand-rolling effort here, specifically for this use case, even given this module's general "prefer libraries" guidance.

---

### Module 6.2 — Unified Memory: What It Actually Buys You (and What It Costs)

**Objective:** Understand Unified Memory as a genuine tool with real tradeoffs, not as "a way to skip learning explicit memory management" — because treating it that way produces code that works but leaves real performance on the table, exactly the trap this curriculum has been warning against throughout.

**Prerequisites:** Phase 2 complete (you need to understand what explicit memory management actually costs and buys you before "here's a way to avoid some of it" means anything).

**Core content:**

**Unified Memory** (`cudaMallocManaged`) gives you a single pointer that's valid from both host and device code — no explicit `cudaMemcpy` calls; the CUDA runtime and driver automatically migrate pages of data between host and device memory on demand, as they're accessed from each side. This genuinely reduces code complexity and eliminates a whole category of "did I remember to copy the updated result back" bugs.

**What it doesn't do: it doesn't eliminate the underlying transfer cost** — data still has to physically move across the same PCIe/NVLink bus, at the same underlying bandwidth constraints Module 1.2 described. What changes is *when and how* that movement happens (automatically, in response to a page fault, rather than at an explicit `cudaMemcpy` call you wrote), and this automatic, on-demand migration can, in some access patterns, actually be *slower* than a well-planned explicit transfer, because page-fault-driven migration can happen in smaller, less efficient chunks than a single large explicit copy would, and because the first-touch access pattern can trigger migration at a less optimal time than you'd have chosen explicitly.

**The honest, current guidance:** Unified Memory is genuinely excellent for rapid prototyping (get a correct, working version fast, without wrestling with explicit `cudaMemcpy` calls while you're still figuring out your kernel's logic), for irregular or hard-to-predict access patterns where explicit prefetching logic would be complex to write correctly by hand, and for simplifying code in genuinely memory-transfer-light applications where the difference doesn't matter much either way. It is *not* automatically the right choice for a performance-critical, already-well-understood access pattern where explicit, hand-planned transfers (potentially combined with Module 5.1's streaming/overlap techniques) can outperform the automatic on-demand migration — and you can also explicitly hint the migration system via `cudaMemPrefetchAsync` (essentially "I know I'm about to need this data on this device, start moving it now rather than waiting for a page fault") to recover much of the performance gap while keeping the simpler unified-pointer programming model, which is often a genuinely good middle ground once you've moved past initial prototyping.

**Common failure mode:** Adopting Unified Memory specifically *because* it lets you avoid learning explicit `cudaMemcpy`/host-device memory management (rather than adopting it as a deliberate choice after understanding the alternative), and then hitting a performance ceiling you can't diagnose, because you don't have the Phase 1–2 mental model of what's actually happening to the data underneath the convenient single-pointer abstraction. This is precisely why this module sits in Phase 6, requiring Phase 2 as a prerequisite, rather than being introduced early as "the easy way to avoid `cudaMemcpy`" — which is how a lot of tutorials frame it, and which I think does readers a disservice by letting them skip the mental model that later performance work depends on.

**Self-check:** Explain why "Unified Memory eliminates the need to think about data placement" is a misleading way to describe what it does, given that the *underlying* transfer cost and bandwidth constraints from Module 1.2 haven't gone anywhere — what has actually changed, precisely, versus what you might naively assume has changed if you only read marketing-style descriptions of the feature?

---

### Module 6.3 — Cooperative Groups & A Note on Tensor Cores

**Objective:** Be aware of two more recent (relative to the "classical" CUDA model taught in Phases 0–5) capabilities, understand what each is *for*, and know when they're relevant to your work rather than needing full mastery of both immediately.

**Prerequisites:** Phase 3 complete, Module 4.2.

**Core content:**

**Cooperative Groups** is a programming model extension that generalizes the synchronization primitives you learned in Phase 3. Where `__syncthreads()` (Module 3.1) synchronizes an entire thread block and is the *only* granularity classical CUDA gives you out of the box, Cooperative Groups lets you explicitly define and synchronize *arbitrary subsets* of threads — a subset smaller than a warp, an entire warp (with more explicit control than the implicit warp-lockstep behavior you've been relying on), multiple blocks within a grid (grid-wide synchronization, which classical CUDA has no built-in primitive for at all — you'd previously have needed to end the kernel and launch a new one to get a grid-wide sync point), or even, on supported multi-GPU configurations, synchronization spanning multiple devices. The practical value: algorithms that need synchronization at a granularity other than "exactly one block" (a common example: some iterative algorithms that need a barrier across the *entire grid* between iterations, which used to force you to structure your code as a sequence of separate kernel launches specifically because there was no other way to get a full-grid sync point) become expressible more directly and, in the grid-wide case specifically, sometimes more efficiently, since avoiding repeated kernel launch overhead when you can synchronize within one persistent kernel launch instead is a genuine performance win for algorithms shaped that way.

**Tensor Cores** are specialized hardware execution units (present on GPU architectures from Volta onward) built specifically for mixed-precision matrix-multiply-accumulate operations at high throughput — dramatically higher throughput than the general-purpose CUDA cores achieve for the same operation, but *only* for operations that fit the specific shapes and precision modes Tensor Cores are built for (this has evolved across generations — different generations support different precision combinations, and I'm deliberately not asserting specific precision-mode support as a fixed fact here, since this is exactly the kind of hardware-generation-specific detail that changes and that you should verify against current NVIDIA documentation for whatever GPU you're actually targeting, rather than trust a fixed list I state now). You generally access Tensor Cores either through cuBLAS/cuDNN (which will use them automatically for eligible operations without you writing anything Tensor-Core-specific yourself — this is the path most people should take) or, for custom kernels that need direct control, through the WMMA (Warp Matrix Multiply-Accumulate) API or newer `cute`/CUTLASS-based approaches for hand-written Tensor Core kernels — which is a genuinely deep specialization in its own right, comparable in scope to Module 5.2's multi-GPU material, and not something this curriculum will expand into full depth given its already broad scope. If your work is deep-learning-adjacent and performance-critical, knowing Tensor Cores exist and knowing to check whether your operations are hitting them (Nsight Compute reports this directly) is the practically important takeaway; full hand-written Tensor Core kernel authorship is a further specialization to pursue once the rest of this curriculum is solid.

**Common failure mode:** Assuming that because your GPU *has* Tensor Cores, your matrix operations are automatically using them — this depends on precision mode, operation shape, and which code path (library call vs. hand-written kernel) you're actually running, and Nsight Compute's utilization metrics will directly tell you whether Tensor Core utilization is actually happening for a given kernel, rather than you having to guess or assume based on hardware presence alone.

**Self-check:** Given this module's guidance, if you're building a deep-learning-adjacent application and want to benefit from Tensor Cores with the least engineering effort, which access path (cuBLAS/cuDNN vs. hand-written WMMA/CUTLASS kernels) should you reach for first, and under what specific circumstance would you actually need to escalate to the hand-written path instead?

---

## Phase 7 — Capstone Projects (Integration)

*These are deliberately scoped to force you to combine techniques across multiple phases rather than exercise one isolated concept — this is where you find out what you actually internalized versus what you could follow along with in a worked example but haven't yet made your own.*

### Capstone A — N-Body Simulation (Compute-Bound Profile)

**What it forces you to integrate:** thread indexing (1.1), shared memory tiling for reuse of per-body data across many pairwise force calculations (2.1, 3.3's tiling pattern generalized), occupancy tuning specifically for a compute-heavy rather than memory-heavy kernel (4.2), and profiling to confirm you've actually landed in the compute-bound regime you'd expect for this problem (4.1).

**The core problem:** simulate gravitational (or similar pairwise-force) interaction among N bodies — every body's next-step position depends on the summed force from every *other* body, an O(N²) all-pairs computation. This is naturally compute-heavy (a lot of arithmetic per byte of input data, unlike, say, vector addition), which makes it a good vehicle for practicing compute-bound optimization specifically, as distinct from the memory-bound-focused work most of Phases 2–3 emphasized.

**What "done well" looks like, concretely:** a tiled implementation where each block cooperatively loads a chunk of body positions into shared memory (directly reusing the pattern from Module 3.3/3.4, generalized to N-body's specific data shape), profiled confirmation via Nsight Compute that you're genuinely compute-bound (not accidentally memory-bound due to a coalescing mistake), and an occupancy analysis explaining *why* your chosen block size and per-thread resource usage is or isn't leaving performance on the table for this specific, compute-heavy profile — remembering Module 4.2's warning that occupancy tuning matters differently for compute-bound vs. memory-bound kernels.

### Capstone B — Image Convolution Pipeline (Memory-Bound Profile, Multi-Kernel)

**What it forces you to integrate:** stencil/halo tiling (3.3) generalized to 2D, coalescing-aware memory layout decisions for image data specifically (2.2), a multi-kernel pipeline (e.g., separate horizontal and vertical passes for a separable filter, or multiple sequential filter stages) where Module 1.2 and 6.1's "keep intermediate results on-device between kernels" guidance is directly load-bearing, and streams (5.1) if you extend it to process a batch of images with transfer/compute overlap.

**The core problem:** apply one or more convolution filters (blur, edge detection, sharpen — any standard image kernel) to a large image or batch of images, entirely on-device, with the multi-stage pipeline structured to avoid unnecessary host round-trips between stages.

**What "done well" looks like, concretely:** a working 2D stencil with correct halo handling (directly extending Module 3.3's 1D version, per that module's self-check prompt), profiled confirmation that you're memory-bound (as expected for this problem class, given relatively low arithmetic intensity per byte of image data) and specifically that you're near your device's achievable memory bandwidth for this access pattern (not leaving coalescing performance on the table), and — as an extension — a batched version using streams to overlap one image's compute with the next image's transfer, with Nsight Systems timeline evidence that the overlap is actually occurring (directly testing whether you internalized Module 5.1's warning that "code that should overlap" and "code that measurably does overlap" aren't automatically the same thing).

### Capstone C (Optional, Higher Difficulty) — A Small Sparse Linear System Solver

**What it forces you to integrate:** atomics and contention management (3.5) adapted to sparse data structures, a judgment call on library use vs. hand-rolling (6.1) specifically because cuSPARSE exists and a mature engineer's first instinct here should be to seriously consider it before hand-rolling, and — if you choose to hand-roll for the learning value specifically — real engagement with irregular, data-dependent memory access patterns that don't coalesce as cleanly as the dense-matrix case from Module 3.4, forcing you to reckon with Module 2.2's lessons in a genuinely harder setting than that module's clean row/column example.

**Why this one is optional and flagged higher-difficulty:** sparse data structures (compressed sparse row, for instance) inherently produce irregular access patterns that resist the clean tiling techniques Phase 3 taught on dense data, and doing this well is a genuine step up in difficulty from the other two capstones — appropriate once you're confident in everything through Phase 6, not as a first capstone attempt.

---

## Appendix A — CUDA-Specific Debugging Methodology

This is worth its own space because GPU debugging genuinely differs from CPU debugging in ways that catch people off guard, even people who are strong C++ debuggers on the CPU side.

**Why "just use a debugger and step through it" is harder here than on CPU:** thousands of threads executing in lockstep groups don't map cleanly onto the single-stepping, one-thread-at-a-time mental model most debuggers (and most programmers' debugging instincts) are built around. NVIDIA's `cuda-gdb` and Nsight's debugging tools *do* let you inspect specific threads/warps/blocks, set conditional breakpoints scoped to particular thread indices, and step through device code — but you have to actively decide *which* thread(s) you're inspecting, because "step through the kernel" doesn't have a single well-defined meaning the way it does for a single CPU thread.

**`cuda-memcheck` (or its modern successor, integrated into `compute-sanitizer`)** is not optional tooling for serious CUDA debugging — it catches out-of-bounds memory accesses, race conditions (including exactly the kind of missing/misplaced `__syncthreads()` bugs from Modules 3.1, 3.2, and 3.4), uninitialized memory reads, and misaligned accesses, many of which produce *silently wrong numerical results* rather than crashes when run without this tooling — recall Module 1.1's warning that out-of-bounds access often doesn't crash, it corrupts adjacent memory silently. Run your kernels under this tool routinely during development, not just when you already suspect a specific bug — many of these bug classes give zero visible symptom without it until they cause a much more confusing downstream failure.

**A specific, common category worth naming explicitly: silent numerical corruption from race conditions is *nondeterministic*, and this specifically undermines "just re-run it and see if the bug still happens" as a debugging strategy** — a race condition might produce wrong results on 1 run in 20, or only under specific system load conditions that affect thread scheduling timing, which means "I ran it again and it worked" is *not* evidence the bug is fixed, and "I can't reproduce it reliably" is not evidence there's no bug — it's often the *signature* of exactly this class of bug. Treat any inconsistent-across-runs behavior as a race condition until proven otherwise (via `compute-sanitizer`'s race detection specifically, which checks the actual synchronization structure rather than relying on catching the race "in the act" during one unlucky run), not as noise to shrug off.

**Debugging strategy when you suspect a specific kernel is wrong (not just slow):** isolate it — write a minimal standalone test harness that launches just that kernel with small, hand-verifiable input (small enough that you can compute the expected output by hand or with a trivial CPU reference implementation), rather than debugging it embedded in your full application where other sources of complexity can obscure which component is actually at fault. Compare GPU output against a CPU reference implementation of the same algorithm on identical small input — if they diverge, you've confirmed the bug is real and isolated it to this specific kernel, which is most of the actual debugging work; if they match on small input but the full-scale run still looks wrong, the bug is more likely to be a boundary condition, an out-of-bounds issue that doesn't manifest until dataset size exceeds some threshold, or a race condition that doesn't manifest reliably at small scale (small thread counts sometimes mask races that only show up with enough concurrent threads to create real scheduling variability).

---

## Appendix B — A Pre-Mortem: Mistakes You Will Almost Certainly Make

Stated directly, because I think a pre-mortem is more useful than false reassurance that a careful learner won't hit these:

1. **You will forget a `__syncthreads()` somewhere in your first few shared-memory kernels**, and it will produce either wrong-but-plausible numbers or an intermittent hang, and it will take longer to find than you expect precisely because it often doesn't fail every single run.
2. **You will write an uncoalesced access pattern without noticing**, because the code will look completely reasonable and will compile and run correctly — you'll only catch it by profiling (Module 2.2, Module 4.1), not by code review alone, and you should expect to need the profiler for this, not treat needing it as a sign you're doing something wrong.
3. **You will underestimate how much time host-device transfer costs relative to your kernel's compute time**, at least once, and be surprised when an end-to-end benchmark doesn't match your kernel-only benchmark's speedup (Module 1.2).
4. **You will, at some point, "optimize" something that wasn't actually your bottleneck**, because you optimized based on intuition or code-reading rather than profiler evidence (Module 4.1) — this is genuinely common even among experienced people, not just beginners, and the fix is procedural (profile before optimizing, always) rather than "just be smarter about guessing."
5. **You will hit a bug that only reproduces on larger data sizes**, and initially suspect an algorithmic error, when it's actually a boundary condition or a race condition that only manifests with enough scale/concurrency to expose it (Appendix A).
6. **You will, at least once, spend real effort hand-optimizing something a library already does better** (Module 6.1) — this isn't wasted time in the sense of "you shouldn't have done it," since the understanding you build from hand-rolling is genuinely valuable per Module 6.1's own reasoning, but recognize when to stop hand-tuning and switch to the library once you've extracted the learning value you were after.

None of these are signs you're doing this wrong. They're the standard, well-worn path essentially everyone walks learning this material — including, almost certainly, whoever wrote the CUDA code in any large production system you might look at.

---

## Appendix C — How to Use This Curriculum Going Forward

- Work phases in order at least once. Phase 4's profiling material specifically depends on having written enough kernels (Phases 1–3) to have something worth profiling and enough intuition to interpret what the profiler tells you.
- Don't treat the self-checks as optional — they're specifically designed to catch "I followed along with the worked example" without "I could reproduce the reasoning myself," which is a real and common gap, and the whole point of this format (given your demonstrated preference for structured, checkpoint-style curricula) is closing that gap before it compounds into later phases.
- For anything hardware-generation-specific I've flagged as "check current" rather than asserting a fixed number (exact shared memory sizes, exact register counts, current CUDA Toolkit version, current Tensor Core precision support per generation) — treat that flagging as intentional, not as a gap in this material. These numbers genuinely change across GPU generations and toolkit releases, and NVIDIA's official documentation for your specific target hardware and toolkit version is the correct source of truth, not a number frozen into a curriculum document.
- The two NVIDIA resources worth bookmarking directly, since they're the primary sources this curriculum's conceptual explanations are ultimately grounded in and the natural next step for depth beyond any single module here: the *CUDA C++ Programming Guide* (the canonical, comprehensive reference for everything in Phases 0–6) and the *CUDA C++ Best Practices Guide* (more performance-and-profiling-workflow focused, closely aligned with Phase 4's material specifically).