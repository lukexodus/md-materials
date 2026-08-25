## Flynn's Taxonomy


Flynn's taxonomy is a classification scheme for computer architectures proposed by Michael J. Flynn in 1966 and extended in 1972. It categorizes parallel and sequential computing systems along two independent dimensions: the number of concurrent **instruction streams** and the number of concurrent **data streams** a system processes at any given time. Despite its age, the taxonomy remains the standard vocabulary for describing parallelism at the architectural level.

---

### Dimensions of Classification

**Instruction stream** refers to the sequence of instructions executed by the processor. **Data stream** refers to the sequence of data items (operands) operated upon. Each dimension is either _single_ or _multiple_, yielding four combinations.

||Single Data|Multiple Data|
|---|---|---|
|**Single Instruction**|SISD|SIMD|
|**Multiple Instruction**|MISD|MIMD|

---

### SISD — Single Instruction, Single Data

#### Conceptual Model

A single control unit fetches and issues one instruction at a time, and that instruction operates on a single data element. This is the canonical von Neumann machine.

<svg viewBox="0 0 520 160" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13"> <!-- Instruction Stream --> <text x="30" y="30" fill="#aaa" font-size="12">Instruction Stream</text> <rect x="30" y="40" width="60" height="30" rx="4" fill="#2a2a3e" stroke="#7c6fcd" stroke-width="1.5"/> <text x="60" y="60" fill="#e0e0e0" text-anchor="middle">I₁</text> <rect x="100" y="40" width="60" height="30" rx="4" fill="#2a2a3e" stroke="#7c6fcd" stroke-width="1.5"/> <text x="130" y="60" fill="#e0e0e0" text-anchor="middle">I₂</text> <rect x="170" y="40" width="60" height="30" rx="4" fill="#2a2a3e" stroke="#7c6fcd" stroke-width="1.5"/> <text x="200" y="60" fill="#e0e0e0" text-anchor="middle">I₃</text> <text x="245" y="60" fill="#666">···</text> <!-- Arrow to PU --> <line x1="270" y1="55" x2="310" y2="55" stroke="#7c6fcd" stroke-width="1.5" marker-end="url(#arr)"/> <!-- PU --> <rect x="310" y="35" width="80" height="40" rx="6" fill="#1e3a2f" stroke="#4caf88" stroke-width="2"/> <text x="350" y="60" fill="#4caf88" text-anchor="middle" font-weight="bold">PU</text> <!-- Data Stream -->

<text x="30" y="110" fill="#aaa" font-size="12">Data Stream</text> <rect x="30" y="118" width="60" height="30" rx="4" fill="#2a2a3e" stroke="#e07b54" stroke-width="1.5"/> <text x="60" y="138" fill="#e0e0e0" text-anchor="middle">D₁</text> <rect x="100" y="118" width="60" height="30" rx="4" fill="#2a2a3e" stroke="#e07b54" stroke-width="1.5"/> <text x="130" y="138" fill="#e0e0e0" text-anchor="middle">D₂</text> <rect x="170" y="118" width="60" height="30" rx="4" fill="#2a2a3e" stroke="#e07b54" stroke-width="1.5"/> <text x="200" y="138" fill="#e0e0e0" text-anchor="middle">D₃</text> <text x="245" y="138" fill="#666">···</text> <line x1="270" y1="133" x2="310" y2="75" stroke="#e07b54" stroke-width="1.5" marker-end="url(#arr2)"/>

<defs> <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#7c6fcd"/> </marker> <marker id="arr2" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#e07b54"/> </marker> </defs> </svg>

#### Characteristics

- One processing unit (PU) executes one instruction per cycle on one datum.
- Instruction-level parallelism (pipelining, superscalar) is _architectural optimization within_ SISD, not a departure from it — the abstract stream model remains single.
- All classical uniprocessors (pre-parallel era) are SISD: Intel 8086, early MIPS R2000.

#### Performance Bound

Throughput is limited to one operation per cycle (ignoring microarchitectural tricks). Scaling requires moving to a different taxonomy class.

---

### SIMD — Single Instruction, Multiple Data

#### Conceptual Model

A single control unit broadcasts one instruction to multiple processing elements (PEs), each of which applies it simultaneously to its own data element. All PEs are _lock-step_ — they execute the same operation at the same time.

<svg viewBox="0 0 560 220" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13"> <defs> <marker id="s1" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#7c6fcd"/> </marker> <marker id="s2" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#e07b54"/> </marker> </defs> <!-- Single Instruction --> <rect x="20" y="80" width="90" height="36" rx="5" fill="#2a2a3e" stroke="#7c6fcd" stroke-width="1.5"/> <text x="65" y="103" fill="#c0b4f0" text-anchor="middle">Instruction</text> <!-- Broadcast lines to PEs --> <line x1="110" y1="98" x2="170" y2="60" stroke="#7c6fcd" stroke-width="1.2" marker-end="url(#s1)"/> <line x1="110" y1="98" x2="170" y2="98" stroke="#7c6fcd" stroke-width="1.2" marker-end="url(#s1)"/> <line x1="110" y1="98" x2="170" y2="136" stroke="#7c6fcd" stroke-width="1.2" marker-end="url(#s1)"/> <line x1="110" y1="98" x2="170" y2="174" stroke="#7c6fcd" stroke-width="1.2" marker-end="url(#s1)"/> <!-- PE boxes and data --> <!-- PE0 --> <rect x="170" y="40" width="50" height="36" rx="5" fill="#1e3a2f" stroke="#4caf88" stroke-width="1.5"/> <text x="195" y="63" fill="#4caf88" text-anchor="middle">PE₀</text> <rect x="240" y="40" width="50" height="36" rx="4" fill="#2a2a3e" stroke="#e07b54" stroke-width="1.2"/> <text x="265" y="63" fill="#e07b54" text-anchor="middle">D₀</text> <line x1="220" y1="58" x2="240" y2="58" stroke="#e07b54" stroke-width="1.2" marker-end="url(#s2)"/> <!-- PE1 --> <rect x="170" y="80" width="50" height="36" rx="5" fill="#1e3a2f" stroke="#4caf88" stroke-width="1.5"/> <text x="195" y="103" fill="#4caf88" text-anchor="middle">PE₁</text> <rect x="240" y="80" width="50" height="36" rx="4" fill="#2a2a3e" stroke="#e07b54" stroke-width="1.2"/> <text x="265" y="103" fill="#e07b54" text-anchor="middle">D₁</text> <line x1="220" y1="98" x2="240" y2="98" stroke="#e07b54" stroke-width="1.2" marker-end="url(#s2)"/> <!-- PE2 --> <rect x="170" y="120" width="50" height="36" rx="5" fill="#1e3a2f" stroke="#4caf88" stroke-width="1.5"/> <text x="195" y="143" fill="#4caf88" text-anchor="middle">PE₂</text> <rect x="240" y="120" width="50" height="36" rx="4" fill="#2a2a3e" stroke="#e07b54" stroke-width="1.2"/> <text x="265" y="143" fill="#e07b54" text-anchor="middle">D₂</text> <line x1="220" y1="138" x2="240" y2="138" stroke="#e07b54" stroke-width="1.2" marker-end="url(#s2)"/> <!-- PE3 --> <rect x="170" y="160" width="50" height="36" rx="5" fill="#1e3a2f" stroke="#4caf88" stroke-width="1.5"/> <text x="195" y="183" fill="#4caf88" text-anchor="middle">PE₃</text> <rect x="240" y="160" width="50" height="36" rx="4" fill="#2a2a3e" stroke="#e07b54" stroke-width="1.2"/> <text x="265" y="183" fill="#e07b54" text-anchor="middle">D₃</text> <line x1="220" y1="178" x2="240" y2="178" stroke="#e07b54" stroke-width="1.2" marker-end="url(#s2)"/> <!-- Results -->

<text x="320" y="25" fill="#aaa" font-size="11">Results</text> <line x1="290" y1="58" x2="340" y2="58" stroke="#a0c4a0" stroke-width="1" stroke-dasharray="4,3"/> <line x1="290" y1="98" x2="340" y2="98" stroke="#a0c4a0" stroke-width="1" stroke-dasharray="4,3"/> <line x1="290" y1="138" x2="340" y2="138" stroke="#a0c4a0" stroke-width="1" stroke-dasharray="4,3"/> <line x1="290" y1="178" x2="340" y2="178" stroke="#a0c4a0" stroke-width="1" stroke-dasharray="4,3"/> <rect x="340" y="40" width="40" height="30" rx="3" fill="#1a2a1a" stroke="#a0c4a0" stroke-width="1"/> <text x="360" y="60" fill="#a0c4a0" text-anchor="middle" font-size="11">R₀</text> <rect x="340" y="80" width="40" height="30" rx="3" fill="#1a2a1a" stroke="#a0c4a0" stroke-width="1"/> <text x="360" y="100" fill="#a0c4a0" text-anchor="middle" font-size="11">R₁</text> <rect x="340" y="120" width="40" height="30" rx="3" fill="#1a2a1a" stroke="#a0c4a0" stroke-width="1"/> <text x="360" y="140" fill="#a0c4a0" text-anchor="middle" font-size="11">R₂</text> <rect x="340" y="160" width="40" height="30" rx="3" fill="#1a2a1a" stroke="#a0c4a0" stroke-width="1"/> <text x="360" y="180" fill="#a0c4a0" text-anchor="middle" font-size="11">R₃</text> </svg>

#### Characteristics

- The instruction decoder/controller is shared; only the data paths are replicated.
- Ideal for **data-parallel** workloads: the same transformation applied uniformly to large arrays (vector addition, matrix multiply, image convolution, neural network layer activations).
- Masking/predication is used to handle conditional execution — inactive PEs are masked out rather than branching independently.
- Memory access pattern matters: strided or gathered data causes lane stalls or gather penalties.

#### Hardware Realizations

|Realization|Examples|Width|
|---|---|---|
|x86 vector extensions|MMX → SSE → AVX-512|64 → 128 → 512 bit|
|ARM NEON / SVE|Cortex-A, Apple M-series|128 bit / scalable|
|GPU warp execution|NVIDIA CUDA warps (32 threads)|32 lanes|
|Classic array processors|ILLIAC IV, Connection Machine|64–65,536 PEs|

**Key Points:**

- SIMD efficiency degrades when data paths diverge (branch divergence in GPU warps causes serialization).
- Vectorization is the compiler's task of converting scalar loops into SIMD instructions automatically.
- Register width and lane count are the primary capacity parameters.

**Example** — vectorized addition of two 8-element integer arrays using AVX2 (256-bit, 8 × 32-bit lanes):

```asm
vmovdqu  ymm0, [rsi]       ; load A[0..7] into ymm0
vmovdqu  ymm1, [rdx]       ; load B[0..7] into ymm1
vpaddd   ymm2, ymm0, ymm1  ; ymm2[i] = A[i] + B[i], all 8 lanes simultaneously
vmovdqu  [rdi], ymm2       ; store result
```

**Output:** Eight additions complete in one instruction cycle instead of eight scalar cycles.

---

### MISD — Multiple Instruction, Single Data

#### Conceptual Model

Multiple processing units each execute a _different_ instruction, but all operate on the **same** data stream simultaneously. Each unit's output may feed the next (pipeline interpretation) or the results may be cross-checked (fault-tolerance interpretation).

<svg viewBox="0 0 540 180" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13"> <defs> <marker id="m1" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#e07b54"/> </marker> <marker id="m2" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#7c6fcd"/> </marker> <marker id="m3" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#4caf88"/> </marker> </defs> <!-- Data stream fan-out --> <rect x="20" y="75" width="70" height="36" rx="5" fill="#2a2a3e" stroke="#e07b54" stroke-width="1.5"/> <text x="55" y="98" fill="#e07b54" text-anchor="middle">Data D</text> <!-- Lines to PUs --> <line x1="90" y1="85" x2="150" y2="50" stroke="#e07b54" stroke-width="1.2" marker-end="url(#m1)"/> <line x1="90" y1="93" x2="150" y2="93" stroke="#e07b54" stroke-width="1.2" marker-end="url(#m1)"/> <line x1="90" y1="93" x2="150" y2="136" stroke="#e07b54" stroke-width="1.2" marker-end="url(#m1)"/> <!-- PU0 with I0 --> <rect x="100" y="20" width="60" height="28" rx="4" fill="#2a2a3e" stroke="#7c6fcd" stroke-width="1.2"/> <text x="130" y="38" fill="#c0b4f0" text-anchor="middle">I₀</text> <rect x="150" y="35" width="60" height="34" rx="5" fill="#1e3a2f" stroke="#4caf88" stroke-width="1.5"/> <text x="180" y="57" fill="#4caf88" text-anchor="middle">PU₀</text> <!-- PU1 with I1 --> <rect x="100" y="78" width="60" height="28" rx="4" fill="#2a2a3e" stroke="#7c6fcd" stroke-width="1.2"/> <text x="130" y="96" fill="#c0b4f0" text-anchor="middle">I₁</text> <rect x="150" y="78" width="60" height="34" rx="5" fill="#1e3a2f" stroke="#4caf88" stroke-width="1.5"/> <text x="180" y="100" fill="#4caf88" text-anchor="middle">PU₁</text> <!-- PU2 with I2 --> <rect x="100" y="120" width="60" height="28" rx="4" fill="#2a2a3e" stroke="#7c6fcd" stroke-width="1.2"/> <text x="130" y="138" fill="#c0b4f0" text-anchor="middle">I₂</text> <rect x="150" y="120" width="60" height="34" rx="5" fill="#1e3a2f" stroke="#4caf88" stroke-width="1.5"/> <text x="180" y="142" fill="#4caf88" text-anchor="middle">PU₂</text> <!-- Results to voter/comparator --> <line x1="210" y1="52" x2="330" y2="88" stroke="#4caf88" stroke-width="1.2" stroke-dasharray="5,3" marker-end="url(#m3)"/> <line x1="210" y1="95" x2="330" y2="92" stroke="#4caf88" stroke-width="1.2" stroke-dasharray="5,3" marker-end="url(#m3)"/> <line x1="210" y1="137" x2="330" y2="96" stroke="#4caf88" stroke-width="1.2" stroke-dasharray="5,3" marker-end="url(#m3)"/> <rect x="330" y="72" width="80" height="40" rx="6" fill="#3a2a1e" stroke="#e0a854" stroke-width="1.5"/> <text x="370" y="87" fill="#e0a854" text-anchor="middle" font-size="11">Voter /</text> <text x="370" y="103" fill="#e0a854" text-anchor="middle" font-size="11">Comparator</text> <!-- Instruction streams descending -->

<text x="30" y="18" fill="#aaa" font-size="11">Instruction streams: I₀ I₁ I₂ (distinct)</text> </svg>

#### Characteristics

- Theoretically the most constrained and least common class; many consider it largely hypothetical in pure form.
    
- Two interpretations dominate the literature:
    
    1. **Pipeline interpretation**: The stages of an instruction pipeline can be viewed as MISD — each stage applies a different micro-operation to the same instruction token flowing through. This is a stretch of the taxonomy but illustrates the conceptual edge case.
        
    2. **Fault-tolerant / TMR interpretation**: Triple Modular Redundancy (TMR) runs identical or diverse programs on the same inputs and a voter circuit selects the majority result. _Diverse redundancy_ (different algorithms yielding the same result) is the cleaner MISD fit.
        
- No mainstream general-purpose architecture is MISD; the category exists primarily to make the taxonomy complete.
    

**Key Points:**

- Space Shuttle flight computers (IBM AP-101) used a form of redundant execution on the same sensor data streams — the closest real-world approximation.
- Cryptographic pipelines (multiple hash/cipher functions on the same input) are sometimes cited but are better classified as special-purpose rather than canonical MISD.

---

### MIMD — Multiple Instruction, Multiple Data

#### Conceptual Model

Multiple independent processing units each fetch their own instruction stream and operate on their own data stream. This is the most general and most prevalent class of parallel architecture.

<svg viewBox="0 0 540 230" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <defs> <marker id="d1" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#7c6fcd"/> </marker> <marker id="d2" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#e07b54"/> </marker> </defs> <!-- Row labels -->

<text x="10" y="60" fill="#aaa" font-size="11">I₀,D₀</text> <text x="10" y="110" fill="#aaa" font-size="11">I₁,D₁</text> <text x="10" y="160" fill="#aaa" font-size="11">I₂,D₂</text> <text x="10" y="210" fill="#aaa" font-size="11">I₃,D₃</text>

<!-- PE0 --> <rect x="55" y="38" width="55" height="30" rx="4" fill="#2a2a3e" stroke="#7c6fcd" stroke-width="1.2"/> <text x="82" y="58" fill="#c0b4f0" text-anchor="middle">I₀</text> <rect x="55" y="72" width="55" height="30" rx="4" fill="#2a2a3e" stroke="#e07b54" stroke-width="1.2"/> <text x="82" y="92" fill="#e07b54" text-anchor="middle">D₀</text> <line x1="110" y1="53" x2="140" y2="68" stroke="#7c6fcd" stroke-width="1.1" marker-end="url(#d1)"/> <line x1="110" y1="87" x2="140" y2="75" stroke="#e07b54" stroke-width="1.1" marker-end="url(#d2)"/> <rect x="140" y="55" width="65" height="38" rx="6" fill="#1e3a2f" stroke="#4caf88" stroke-width="1.8"/> <text x="172" y="79" fill="#4caf88" text-anchor="middle" font-weight="bold">PU₀</text> <!-- PE1 --> <rect x="55" y="88" width="55" height="30" rx="4" fill="#2a2a3e" stroke="#7c6fcd" stroke-width="1.2"/> <text x="82" y="108" fill="#c0b4f0" text-anchor="middle">I₁</text> <rect x="55" y="122" width="55" height="30" rx="4" fill="#2a2a3e" stroke="#e07b54" stroke-width="1.2"/> <text x="82" y="142" fill="#e07b54" text-anchor="middle">D₁</text> <line x1="110" y1="103" x2="140" y2="115" stroke="#7c6fcd" stroke-width="1.1" marker-end="url(#d1)"/> <line x1="110" y1="137" x2="140" y2="125" stroke="#e07b54" stroke-width="1.1" marker-end="url(#d2)"/> <rect x="140" y="103" width="65" height="38" rx="6" fill="#1e3a2f" stroke="#4caf88" stroke-width="1.8"/> <text x="172" y="127" fill="#4caf88" text-anchor="middle" font-weight="bold">PU₁</text> <!-- PE2 --> <rect x="55" y="138" width="55" height="30" rx="4" fill="#2a2a3e" stroke="#7c6fcd" stroke-width="1.2"/> <text x="82" y="158" fill="#c0b4f0" text-anchor="middle">I₂</text> <rect x="55" y="172" width="55" height="30" rx="4" fill="#2a2a3e" stroke="#e07b54" stroke-width="1.2"/> <text x="82" y="192" fill="#e07b54" text-anchor="middle">D₂</text> <line x1="110" y1="153" x2="140" y2="162" stroke="#7c6fcd" stroke-width="1.1" marker-end="url(#d1)"/> <line x1="110" y1="187" x2="140" y2="173" stroke="#e07b54" stroke-width="1.1" marker-end="url(#d2)"/> <rect x="140" y="150" width="65" height="38" rx="6" fill="#1e3a2f" stroke="#4caf88" stroke-width="1.8"/> <text x="172" y="174" fill="#4caf88" text-anchor="middle" font-weight="bold">PU₂</text> <!-- PE3 --> <rect x="55" y="188" width="55" height="30" rx="4" fill="#2a2a3e" stroke="#7c6fcd" stroke-width="1.2"/> <text x="82" y="208" fill="#c0b4f0" text-anchor="middle">I₃</text> <rect x="55" y="200" width="55" height="30" rx="4" fill="#2a2a3e" stroke="#e07b54" stroke-width="1.2"/> <text x="82" y="220" fill="#e0e0e0" text-anchor="middle">D₃</text> <line x1="110" y1="203" x2="140" y2="206" stroke="#7c6fcd" stroke-width="1.1" marker-end="url(#d1)"/> <line x1="110" y1="215" x2="140" y2="212" stroke="#e07b54" stroke-width="1.1" marker-end="url(#d2)"/> <rect x="140" y="197" width="65" height="38" rx="6" fill="#1e3a2f" stroke="#4caf88" stroke-width="1.8"/> <text x="172" y="221" fill="#4caf88" text-anchor="middle" font-weight="bold">PU₃</text> <!-- Shared memory --> <rect x="240" y="100" width="90" height="60" rx="6" fill="#2a1e3a" stroke="#a070d0" stroke-width="1.5" stroke-dasharray="5,3"/> <text x="285" y="127" fill="#a070d0" text-anchor="middle" font-size="11">Shared</text> <text x="285" y="143" fill="#a070d0" text-anchor="middle" font-size="11">Memory /</text> <text x="285" y="159" fill="#888" text-anchor="middle" font-size="10">Interconnect</text> <line x1="205" y1="74" x2="240" y2="118" stroke="#a070d0" stroke-width="1" stroke-dasharray="3,3"/> <line x1="205" y1="122" x2="240" y2="128" stroke="#a070d0" stroke-width="1" stroke-dasharray="3,3"/> <line x1="205" y1="169" x2="240" y2="140" stroke="#a070d0" stroke-width="1" stroke-dasharray="3,3"/> <line x1="205" y1="216" x2="240" y2="152" stroke="#a070d0" stroke-width="1" stroke-dasharray="3,3"/> </svg>

#### Characteristics

- Each PU has its own program counter, register file, and operates asynchronously relative to other PUs.
- PUs may share memory (UMA/NUMA) or communicate via message passing (distributed memory).
- The broadest and most powerful category — virtually all modern parallel systems are MIMD.

#### MIMD Sub-classifications

MIMD splits along the memory organization axis:

```
MIMD
├── Shared Memory (tightly coupled)
│   ├── UMA  — Uniform Memory Access
│   │          (all processors equidistant from all memory)
│   │          e.g., symmetric multiprocessor (SMP) with bus interconnect
│   └── NUMA — Non-Uniform Memory Access
│              (memory latency depends on which node owns it)
│              e.g., AMD EPYC multi-socket, large NUMA servers
└── Distributed Memory (loosely coupled)
    ├── Clusters — commodity nodes + network (Ethernet, InfiniBand)
    └── MPP     — Massively Parallel Processors (custom interconnects)
                  e.g., Cray T3E, IBM Blue Gene, Frontier/Summit
```

#### MIMD Examples

|System|Type|Notes|
|---|---|---|
|Dual/quad-core desktop CPU|Shared-memory MIMD|Cores share LLC via ring/mesh|
|AMD EPYC server (multi-socket)|NUMA MIMD|Inter-socket via Infinity Fabric|
|Beowulf cluster|Distributed MIMD|MPI message passing|
|Intel Xeon Phi (KNL)|Shared-memory MIMD|72 cores, high-bandwidth MCDRAM|
|Frontier (Oak Ridge)|Distributed MIMD|9,408 nodes, HPE Slingshot|

**Key Points:**

- MIMD requires explicit synchronization mechanisms (mutexes, barriers, semaphores, atomic operations) when PUs share state.
- Thread-level parallelism (TLP) and process-level parallelism both operate within the MIMD model.
- MIMD is the foundation of multicore processors, server clusters, and supercomputers.
- The MIMD model imposes coherence requirements: cache coherence protocols (MSI, MESI, MOESI) exist specifically because independent PUs may hold inconsistent copies of shared cache lines.

**Example** — two threads on a 2-core MIMD system executing different functions concurrently:

```c
// Core 0                        // Core 1
void compress(uint8_t *buf) {    void encrypt(uint8_t *buf) {
    lz4_compress(buf, ...);          aes_encrypt(buf, ...);
}                                }
// Different instructions, different data regions — pure MIMD
```

---

### Comparative Summary

||SISD|SIMD|MISD|MIMD|
|---|---|---|---|---|
|Instruction streams|1|1|N|N|
|Data streams|1|N|1|N|
|Parallelism type|None (sequential)|Data-parallel|Redundant / pipeline|Task + data parallel|
|Synchronization|None|Lock-step|Voter logic|Explicit (locks, barriers)|
|Scalability|Poor|Moderate (lane-limited)|Not applicable|High|
|Prevalence|Legacy uniprocessors|Vector units, GPUs|Fault-tolerant systems|All modern parallel HW|
|Control overhead|Minimal|Low (shared decoder)|High (diverse logic)|High (OS scheduler, coherence)|

---

### SIMD–MIMD Hybrid: The Modern Reality

Contemporary processors do not map cleanly to a single class. A modern multicore CPU is:

- **MIMD** at the core level: each core runs an independent thread with its own PC.
- **SIMD** within each core: AVX/NEON vector units apply one instruction to multiple data lanes.
- **SISD** at the scalar pipeline level within a lane.

GPUs are frequently labeled SIMD but are more precisely **SIMT (Single Instruction, Multiple Threads)**: threads within a warp execute the same instruction but have independent PCs and can diverge (with serialization penalty). SIMT is Flynn's SIMD generalized to handle divergence at a cost.

```
Modern CPU (e.g., AMD Zen 4)
└── MIMD: 16 cores, each independent
    └── Each core: scalar OOO pipeline (SISD model)
        └── Each core: 256/512-bit AVX-512 unit (SIMD model)
```

---

### Limitations of Flynn's Taxonomy

Flynn's taxonomy was formulated for 1966-era hardware and carries several acknowledged limitations:

- It does not capture **memory organization** (shared vs. distributed), which is architecturally as significant as the instruction/data stream count.
- It does not distinguish **pipeline parallelism** from **array parallelism** within SIMD.
- It does not address **dataflow** architectures, where execution is triggered by data availability rather than a program counter.
- MIMD is too broad: it encompasses systems as different as a dual-core laptop and a 10,000-node supercomputer.
- Subsequent taxonomies (Handler's μ-metric, Shore's classification, the Skillicorn taxonomy) attempt to refine these gaps but none achieved Flynn's adoption.

---

**Conclusion:** Flynn's taxonomy provides an enduring two-dimensional framework — instruction streams × data streams — for classifying computer architectures. SISD describes classical sequential machines; SIMD exploits data parallelism through replicated data paths under a single controller; MISD remains theoretically complete but practically marginal; MIMD underlies all modern parallel computing from multicore CPUs to warehouse-scale clusters. The taxonomy's value is in building a shared vocabulary and revealing the fundamental trade-off between control complexity and parallelism degree, even as real hardware increasingly blurs the boundaries between classes.

**Next Steps:** Proceed to **Symmetric Multiprocessing** to examine how MIMD shared-memory systems are physically organized — covering bus-based coherence, directory protocols, and the scalability limits of SMP — or to **SIMD and Vector Processing** for a deeper treatment of lane architecture, gather/scatter, and masked execution.

---

