## SIMD and Vector Processing


SIMD (Single Instruction, Multiple Data) is a hardware parallelism model where a single instruction operates on multiple data elements simultaneously by treating wide registers as arrays of smaller lanes. It is the primary mechanism for data-level parallelism within a single core and underpins the performance of multimedia codecs, scientific computation, machine learning kernels, and cryptographic algorithms.

---

### Scalar vs. Vector Execution

The essential contrast is between one operation per clock cycle on one datum versus one operation per clock cycle on _N_ data elements packed into a wide register.The speedup is purely spatial — the register is partitioned into _lanes_, and the execution unit operates all lanes in parallel. No additional clock cycles are spent; the latency of a vector add equals the latency of a scalar add on the same microarchitecture.

---

### Register Width and Lane Arithmetic

A vector register of width _W_ bits holding elements of type _T_ bits supports _W/T_ lanes:

|ISA extension|Register width|float32 lanes|float64 lanes|int8 lanes|
|---|---|---|---|---|
|SSE (x86)|128-bit|4|2|16|
|AVX (x86)|256-bit|8|4|32|
|AVX-512 (x86)|512-bit|16|8|64|
|NEON (AArch64)|128-bit|4|2|16|
|SVE (AArch64)|128–2048-bit|variable|variable|variable|
|RVV (RISC-V)|variable (VLEN)|variable|variable|variable|

**Peak theoretical throughput** from SIMD alone: a processor issuing one 512-bit FMA (fused multiply-add) per cycle at 4 GHz with float32 achieves 16 × 2 × 4 × 10⁹ = 128 GFLOPS per core (the ×2 comes from FMA counting as two floating-point operations). This is the theoretical ceiling before memory bandwidth, instruction mix, or execution port limits become the binding constraint.

---

### ISA Families in Depth

#### x86 SSE / AVX / AVX-512

Intel introduced MMX (1996), then SSE (1999) with 128-bit XMM registers, then AVX (2011) expanding to 256-bit YMM registers while keeping the lower 128 bits aliased to XMM. AVX-512 (2017) added 512-bit ZMM registers, 32 register file slots (up from 16), and mask registers (`k0`–`k7`) for predicated (masked) execution.

A critical microarchitectural detail: transitioning between SSE and AVX code without `VZEROUPPER` leaves the upper 128 bits of YMM registers in an undefined state and forces the processor to merge partial register updates, triggering a severe penalty. Compilers insert `VZEROUPPER` at function boundaries to avoid this; hand-written intrinsic code must do the same.

AVX-512 introduced **opmask registers** — a 64-bit mask selects which lanes participate in an operation. Inactive lanes either retain their old value (merge masking) or write zero (zero masking). This eliminates scalar cleanup loops for non-multiple-of-vector-width array tails.

```c
// AVX-512 masked add — only lanes where mask bit is 1 are written
__m512 result = _mm512_mask_add_ps(passthrough, k_mask, a, b);
```

#### ARM NEON / SVE

NEON is fixed at 128 bits, present on all AArch64 cores. SVE (Scalable Vector Extension) introduces an architecture-defined but implementation-variable register width (VLEN). Programs compiled once run on any SVE-capable core regardless of VLEN; the programmer or compiler uses vector-length-agnostic (VLA) idioms:

```c
// SVE VLA loop — adapts at runtime to any VLEN
svbool_t pg;
for (uint64_t i = 0; i < n; i += svcntw()) {
    pg = svwhilelt_b32_u64(i, n);           // predicate for remaining lanes
    svfloat32_t va = svld1(pg, a + i);
    svfloat32_t vb = svld1(pg, b + i);
    svst1(pg, c + i, svadd_z(pg, va, vb));
}
```

SVE2 extends SVE with support for string processing, cryptography, and digital signal processing operations.

#### RISC-V V Extension (RVV)

RVV uses a register-length-agnostic model analogous to SVE. The implementation defines `VLEN` (physical register width). Programs use `vsetvli` to configure the element width (`SEW`) and grouping factor (`LMUL`), which multiplies effective register width by allowing multiple physical registers to be treated as one logical wider register:

```asm
vsetvli t0, a0, e32, m4, ta, ma   # SEW=32-bit, LMUL=4 (4 regs grouped), tail/mask agnostic
vle32.v  v0, (a1)                  # load 4-register group of float32
vle32.v  v4, (a2)
vfadd.vv v8, v0, v4                # vector float add
vse32.v  v8, (a3)                  # store result
```

---

### Execution Unit Architecture

A SIMD-capable core contains dedicated vector execution units distinct from the scalar integer and floating-point units. On a modern out-of-order superscalar core (e.g., Intel Golden Cove), AVX-512 operations are dispatched through specific execution ports. Widening the register does not automatically widen all pipelines equally — some operations (e.g., 512-bit integer multiply) may have higher latency or lower throughput than their 256-bit equivalents due to physical execution unit width or power constraints.

**Key execution parameters per instruction:**

- **Latency**: cycles from issue to result availability (e.g., `VADDPS` ymm: 4 cycles on Skylake)
- **Throughput** (reciprocal): minimum cycles between successive issues of the same instruction (e.g., 0.5 means 2 per cycle if enough execution ports)
- **Port assignment**: which execution ports can dispatch the instruction (port 0 / port 1 / etc.)

Throughput — not latency — is the limiting factor for independent operations in a tight loop. When a loop has no cross-iteration dependency, the issue rate equals the reciprocal throughput times the number of back-to-back instructions, constrained by port bandwidth.

---

### Memory Access: Alignment, Gather, Scatter

#### Alignment

Early SIMD ISAs required natural alignment (a 128-bit load must start at a 16-byte boundary). Misaligned loads triggered exceptions or incurred significant penalties due to crossing cache-line boundaries. Modern microarchitectures handle misaligned SIMD loads in hardware, but crossing a 64-byte cache line boundary still costs an additional cache access.

|Load type|Semantics|Hardware behavior|
|---|---|---|
|Aligned|Address % (width/8) == 0|Single cache-line access (if ≤ 64B)|
|Unaligned|Any address|May split into two cache-line accesses|
|Non-temporal|`_mm_stream_ps` / `VMOVNTPS`|Bypasses cache (write-combine buffer); avoids polluting L1/L2 on streaming writes|

#### Gather and Scatter

Gather loads a vector from non-contiguous memory addresses:

```c
// Gather: load float at addresses base[index[i]] for each lane i
__m256 v = _mm256_i32gather_ps(base_ptr, index_vec, 4);  // scale=4 bytes
```

Scatter is the converse: write each lane to an independently computed address. Both operations have significantly higher latency than contiguous vector loads (~10–20 cycles vs. ~4–5 cycles for a hit in L1) and may serialize internally on hardware that cannot issue multiple cache probes simultaneously. They are most useful when the alternative is a scalar loop with even higher overhead.

---

### Fundamental Operation Categories

#### Arithmetic and Logic

Lane-wise add, subtract, multiply, divide, FMA, bitwise AND/OR/XOR/NOT, and shifts. These are the common case and achieve near-peak throughput.

#### Horizontal Operations

Reduce across lanes within a register. `VHADDPS` adds adjacent pairs; a full horizontal sum over N lanes requires log₂(N) reduction steps. Horizontal operations are inherently more expensive than vertical (lane-wise) operations — they require permutation network activity.

```c
// Horizontal sum of 8-lane AVX float vector (requires 3 hadd + extract)
float hsum_avx(__m256 v) {
    __m128 lo = _mm256_castps256_ps128(v);
    __m128 hi = _mm256_extractf128_ps(v, 1);
    __m128 sum = _mm_add_ps(lo, hi);
    sum = _mm_hadd_ps(sum, sum);
    sum = _mm_hadd_ps(sum, sum);
    return _mm_cvtss_f32(sum);
}
```

#### Shuffle and Permute

Rearrange lanes within or across registers. `VPERMPS`, `VSHUFPS`, `VPUNPCKLBW`, `VTBL` (ARM), `vrgather` (RISC-V). Essential for AoS↔SoA conversion, matrix transposition, and FFT butterfly stages. Shuffle throughput is typically limited compared to arithmetic — planners should minimize cross-lane data movement.

#### Comparison and Masking

Lane-wise comparison producing a mask. In AVX/SSE, comparisons produce a vector of all-ones or all-zeros per lane. In AVX-512 and SVE, comparisons write directly into dedicated mask/predicate registers, enabling predicated execution without consuming data register bandwidth.

#### Type Conversion

`VCVTPS2PD` (float32 → float64), `VCVTDQ2PS` (int32 → float32), saturation-narrowing pack operations. Conversion throughput and latency vary; converting half-precision (`float16`) to `float32` is hardware-accelerated on modern cores (Intel Sapphire Rapids, AMD Zen 4, all modern ARM cores).

---

### Auto-Vectorization vs. Intrinsics vs. Vector Libraries

**Auto-vectorization** is the compiler's ability to detect that a scalar loop is vectorizable and emit vector instructions without programmer intervention. GCC and Clang both perform this with `-O2`/`-O3` and target flags (`-march=native`, `-mfpu=neon`).

Conditions that allow auto-vectorization:

- No loop-carried data dependencies between iterations
- No aliasing between pointers (use `restrict` to assert)
- Predictable, constant stride access pattern
- No function calls that the compiler cannot inline or vectorize

Conditions that typically block it:

- Conditional writes with data-dependent indices (gather/scatter patterns)
- Reductions with non-associative operations (e.g., floating-point summation order matters without `-ffast-math`)
- Loop-carried dependencies (e.g., `a[i] = a[i-1] + x`)

**Compiler intrinsics** expose individual SIMD instructions as C functions, giving the programmer full control at the cost of portability and maintainability.

**Vendor/open-source libraries** (Intel MKL, OpenBLAS, FFTW, Highway, xsimd, HighwayHash) provide hand-tuned kernels that dispatch to the best ISA extension at runtime.

---

### Data Layout: AoS vs. SoA

The performance of SIMD operations is heavily influenced by how data is arranged in memory.

**Array of Structures (AoS):** Common in object-oriented code. Loading a single component (e.g., all `x` values) requires gathering from non-contiguous addresses.

**Structure of Arrays (SoA):** Separate arrays per field. Loading all `x` values is a single contiguous vector load.

```
AoS: [x0,y0,z0, x1,y1,z1, x2,y2,z2, x3,y3,z3]
      ^─────────────────────load 4 x values──────^  (stride-3 gather needed)

SoA: [x0,x1,x2,x3], [y0,y1,y2,y3], [z0,z1,z2,z3]
      ^──load──^
```

The transformation from AoS to SoA is called _transposition_ and requires shuffle/unpack operations. A common intermediate layout is _AoSoA_ (Array of Structures of Arrays), which groups _N_ elements into blocks matching the vector width, balancing cache locality with load efficiency.

---

### Predication and Masked Execution

Conditional computation in scalar code uses branches. Branching in SIMD code is expensive because lanes within a register cannot independently branch. The SIMD idiom is to compute both outcomes and select:

```c
// Scalar: if (a[i] > 0) c[i] = a[i] + b[i]; else c[i] = 0;

// AVX: compute both sides, blend using comparison mask
__m256 mask   = _mm256_cmp_ps(a, _mm256_setzero_ps(), _CMP_GT_OS);
__m256 add    = _mm256_add_ps(a, b);
__m256 result = _mm256_and_ps(add, mask);   // zero where mask=0
```

AVX-512 and SVE/RVV natively support masked operations where inactive lanes do no work and generate no faults — critical for safe predicated memory accesses (e.g., loading near the end of a buffer without reading past it).

---

### Performance Bottlenecks and Limiting Factors

#### Vectorization efficiency

The fraction of execution time actually spent in vectorized code. Auto-vectorization failures in hot loops leave scalar throughput on the table.

#### Memory bandwidth

Wide vector loads consume memory bandwidth proportionally. A 512-bit load per cycle at 4 GHz requires 256 GB/s — exceeding DRAM bandwidth for most systems. Effective SIMD use requires data to reside in L1 or L2 cache.

#### Port contention

On out-of-order cores with multiple execution ports, issuing too many instructions requiring the same port causes stalls even when latency is hidden. On Intel Skylake/Ice Lake, most 256-bit floating-point operations share ports 0 and 1 — a loop with three FMAs per iteration cannot sustain more than 2 FMAs/cycle regardless of latency.

#### Register pressure

Wide vector registers are expensive in terms of register file area and power. AVX-512 has 32 ZMM registers, which is generous, but complex kernels with unrolled loops may spill to memory if register demand exceeds supply.

#### Frequency throttling

On Intel processors, sustained AVX-512 workloads trigger frequency downclocking (AVX-512 license level) because the power density of the execution units exceeds the thermal budget at base frequency. AMD Zen 4 and ARM SVE do not exhibit this behavior. This makes AVX-512 throughput gains context-dependent — shorter burst workloads see the full width benefit; sustained workloads may see reduced gains due to lower clock frequency.

---

### SIMD in the Context of Flynn's Taxonomy

SIMD fits directly into Flynn's taxonomy as the SIMD class: one instruction stream, multiple data streams. Within a single core, the vector execution unit _is_ a SIMD processor. This is distinct from MIMD (multiple independent instruction streams, as in multicore), SISD (scalar single-core), and MISD (multiple instruction streams, single data — rare in practice, used in fault-tolerant systems).

Modern cores are simultaneously:

- **SISD** for control flow and scalar computation
- **SIMD** for vector arithmetic
- **MIMD** at the chip level across cores

GPU architectures are a form of SIMT (Single Instruction, Multiple Threads) — a software-visible version of SIMD where each thread executes the same instruction on its own data, with hardware handling divergence via masking.

---

### Worked Example: SAXPY Kernel

SAXPY (Single-precision A·X Plus Y) computes `y[i] += a * x[i]` for all `i`. It exercises load, FMA, and store in a memory-bandwidth-bound loop.

```c
// Scalar baseline
void saxpy_scalar(float a, float *x, float *y, int n) {
    for (int i = 0; i < n; i++)
        y[i] += a * x[i];
}

// AVX-512 intrinsic (handles 16 floats per iteration)
void saxpy_avx512(float a, float *x, float *y, int n) {
    __m512 va = _mm512_set1_ps(a);          // broadcast scalar to all 16 lanes
    int i = 0;
    for (; i <= n - 16; i += 16) {
        __m512 vx = _mm512_loadu_ps(x + i);
        __m512 vy = _mm512_loadu_ps(y + i);
        vy = _mm512_fmadd_ps(va, vx, vy);   // vy = va*vx + vy (FMA)
        _mm512_storeu_ps(y + i, vy);
    }
    for (; i < n; i++)                       // scalar tail
        y[i] += a * x[i];
}
```

The loop body issues: 2 loads, 1 FMA, 1 store — each operating on 16 floats. The FMA has throughput of 0.5 cycles on a two-port machine, meaning the arithmetic ceiling is 32 floats/cycle. In practice, this kernel is memory-bandwidth-bound for large arrays: two 64-byte cache-line reads plus one write per 16 iterations saturates DRAM bandwidth well before the FMA unit becomes the bottleneck.

---

### Relationship to the Roofline Model

The Roofline model (covered in Module 14) quantifies whether a kernel is compute-bound or memory-bandwidth-bound using _arithmetic intensity_ (FLOPS per byte of memory traffic). SIMD raises the compute ceiling by multiplying per-cycle FLOPS by the vector width. It does _not_ raise the memory bandwidth ceiling. Kernels with low arithmetic intensity (like SAXPY, intensity ≈ 1 FLOP/byte) remain bandwidth-bound regardless of how wide the vector unit is.

Kernels like dense matrix multiply have high arithmetic intensity (~N/2 for N×N multiply with blocking) and are compute-bound — these benefit directly from wider SIMD because the execution unit, not memory, is the limiting resource.

---

**Conclusion:** SIMD and vector processing are the mechanism by which a single core extracts data-level parallelism without increasing clock frequency or replicating full execution pipelines. The architecture spans register file design, dedicated execution units, memory alignment and gather/scatter hardware, masking logic, and compiler vectorization infrastructure. The practical performance of SIMD code is jointly determined by vector width, memory bandwidth, execution port availability, and data layout — understanding all four is necessary to reason about observed vs. theoretical throughput.

**Next Steps:** The natural continuation is **GPU Architecture Fundamentals** (also in Module 11), which extends SIMD to the SIMT execution model across thousands of threads, and **ILP concepts and limits** (Module 6), which addresses how out-of-order execution and superscalar dispatch interact with vector instruction scheduling.

---

