## Prefetching Strategies


### Motivation and Fundamental Trade-off

Prefetching is the act of retrieving data into a closer level of the memory hierarchy before an explicit request is issued, with the goal of hiding memory latency. The processor or software predicts what will be needed and initiates the fetch during cycles that would otherwise be idle.

The fundamental trade-off:

- **Prefetch too early** — data evicted from cache before use (cache pollution).
- **Prefetch too late** — data arrives after the demand access stalls anyway (timeliness failure).
- **Prefetch wrong address** — cache line evicted uselessly, bandwidth wasted (accuracy failure).

Effectiveness is measured by three quantities:

```
Coverage   = Misses_eliminated / Total_misses
Accuracy   = Useful_prefetches / Total_prefetches_issued
Timeliness = fraction of prefetches arriving before demand access
```

High coverage with low accuracy wastes bandwidth and pollutes caches. High accuracy with low coverage leaves most misses unaddressed.

---

### Hardware Prefetching

Hardware prefetchers operate transparently at the microarchitectural level, requiring no program modification. They observe the stream of cache miss addresses and infer future access patterns.

#### Sequential / Stream Prefetcher

The simplest class. Detects a sequence of cache misses at monotonically increasing (or decreasing) addresses and prefetches ahead by a fixed number of lines.

```
Observed misses:  A, A+1, A+2, A+3 …
Prefetch issued:  A+4, A+5, A+6 …    (degree = 3 here)
```

**Prefetch degree** (how many lines ahead) is often adaptive: increased when misses continue to occur (stream is ongoing), decreased when hits dominate (stream has ended or slowed).

**Key Points:**

- Effective for sequential array traversal, memcpy, and streaming media.
- Fails entirely on pointer-chasing or irregular access patterns.
- Most modern processors implement multiple independent stream detectors (e.g., Intel uses up to 32 streams per core).

#### Stride Prefetcher

Generalizes the stream prefetcher to constant but non-unit strides. A **Reference Prediction Table (RPT)** or **Stride Prefetch Table** records, per instruction PC:

- Last address accessed
- Detected stride (delta between consecutive accesses)
- Confidence state (initial → transient → steady → no-pred)

```
PC 0x4010 accesses: 0x1000, 0x1040, 0x1080 …
Stride = 0x40 (64 bytes)
Prefetch: 0x10C0, 0x1100 …
```

<svg viewBox="0 0 660 180" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <rect width="660" height="180" fill="none"/> <!-- RPT table --> <text x="20" y="20" fill="#aaa" font-size="13">Stride Prefetch Table (RPT)</text> <!-- Header --> <rect x="20" y="30" width="120" height="22" fill="#2a2a2a" stroke="#555"/> <rect x="140" y="30" width="120" height="22" fill="#2a2a2a" stroke="#555"/> <rect x="260" y="30" width="100" height="22" fill="#2a2a2a" stroke="#555"/> <rect x="360" y="30" width="120" height="22" fill="#2a2a2a" stroke="#555"/> <text x="30" y="45" fill="#7ec8e3">PC</text> <text x="150" y="45" fill="#7ec8e3">Last Address</text> <text x="270" y="45" fill="#7ec8e3">Stride</text> <text x="370" y="45" fill="#7ec8e3">State</text> <!-- Row 1 --> <rect x="20" y="52" width="120" height="22" fill="#1a1a1a" stroke="#444"/> <rect x="140" y="52" width="120" height="22" fill="#1a1a1a" stroke="#444"/> <rect x="260" y="52" width="100" height="22" fill="#1a1a1a" stroke="#444"/> <rect x="360" y="52" width="120" height="22" fill="#1a1a1a" stroke="#444"/> <text x="30" y="67" fill="#ccc">0x4010</text> <text x="150" y="67" fill="#ccc">0x1080</text> <text x="270" y="67" fill="#ccc">+0x40</text> <text x="370" y="67" fill="#e3a87e">steady</text> <!-- Row 2 --> <rect x="20" y="74" width="120" height="22" fill="#1a1a1a" stroke="#444"/> <rect x="140" y="74" width="120" height="22" fill="#1a1a1a" stroke="#444"/> <rect x="260" y="74" width="100" height="22" fill="#1a1a1a" stroke="#444"/> <rect x="360" y="74" width="120" height="22" fill="#1a1a1a" stroke="#444"/> <text x="30" y="89" fill="#ccc">0x5020</text> <text x="150" y="89" fill="#ccc">0x2400</text> <text x="270" y="89" fill="#ccc">+0x200</text> <text x="370" y="89" fill="#aaa">transient</text> <!-- Row 3 --> <rect x="20" y="96" width="120" height="22" fill="#1a1a1a" stroke="#444"/> <rect x="140" y="96" width="120" height="22" fill="#1a1a1a" stroke="#444"/> <rect x="260" y="96" width="100" height="22" fill="#1a1a1a" stroke="#444"/> <rect x="360" y="96" width="120" height="22" fill="#1a1a1a" stroke="#444"/> <text x="30" y="111" fill="#ccc">0x6044</text> <text x="150" y="111" fill="#ccc">0x3100</text> <text x="270" y="111" fill="#ccc">—</text> <text x="370" y="111" fill="#666">initial</text> <!-- Prefetch arrow --> <text x="500" y="60" fill="#7ec8e3" font-size="11">→ prefetch 0x10C0</text> <text x="500" y="75" fill="#7ec8e3" font-size="11">→ prefetch 0x1100</text> <line x1="490" y1="67" x2="500" y2="67" stroke="#7ec8e3" stroke-width="1"/> </svg>

**Key Points:**

- Indexed by PC, so multiple load instructions with different strides are tracked independently.
- Confidence gating suppresses prefetches until the stride is confirmed, limiting accuracy waste.

#### Spatial Prefetcher

Exploits **spatial locality** at a coarser granularity than the cache line. Observes which cache lines within a larger **spatial region** (e.g., a 2 KB or 4 KB block) are accessed together across multiple instances of that region being live in cache.

The **AMPM (Access Map Pattern Matching)** prefetcher and **SMS (Spatial Memory Streaming)** are representative designs:

1. On first access to a region, begin recording a **footprint bitmask** — one bit per cache line within the region.
2. On eviction, store the footprint in a **pattern history table** indexed by the triggering access offset.
3. On the next access to any region at the same offset, replay the stored footprint as prefetches.

This captures patterns like struct field access (fields at known offsets from a base pointer) that stride prefetchers miss.

#### Markov / Correlation Prefetcher

Records transitions between miss addresses in a **correlation table**:

```
Miss X → Miss Y observed repeatedly
→ On next miss X, prefetch Y
```

Handles irregular but repeating patterns (e.g., pointer traversal over a fixed graph topology). Storage cost is high; accuracy degrades when the access graph is large or context-dependent.

#### Best-Offset Prefetcher (BOP)

A modern, hardware-practical design. Evaluates multiple candidate offsets (Δ = 1, 2, 3 … N lines ahead) simultaneously. Scores each offset by how often a prefetch at that offset would have arrived before the demand access. The highest-scoring offset is selected as the current prefetch distance, updated periodically.

BOP won the 2nd Data Prefetching Championship (2015) and variants are deployed in production microarchitectures.

#### Prefetch Filtering: MSHR and Prefetch Queue Interaction

Prefetch requests are issued into the **Miss Status Holding Register (MSHR)** table (or a parallel prefetch queue). Mechanisms to limit pollution:

- **Throttling**: reduce prefetch aggressiveness (degree or distance) when cache miss rate rises — indicating pollution is occurring.
- **Prefetch-aware replacement**: mark prefetched lines with low priority in the replacement policy (NRU bit cleared), so they are evicted first if not touched before a demand miss occurs.
- **Confidence filtering**: suppress prefetches with below-threshold confidence scores.

---

### Software Prefetching

Software prefetchers are explicit instructions inserted by the compiler or programmer. The processor treats them as hints: they are non-faulting (a bad address does not raise an exception) and non-binding (the processor may ignore them under resource pressure).

#### ISA Prefetch Instructions

|Architecture|Instruction|Notes|
|---|---|---|
|x86|`PREFETCHT0`|Prefetch into all cache levels (L1/L2/L3)|
|x86|`PREFETCHT1`|Prefetch into L2 and L3 only|
|x86|`PREFETCHT2`|Prefetch into L3 only|
|x86|`PREFETCHNTA`|Non-temporal: bypass L2/L3, minimize pollution|
|ARM|`PRFM PLDL1KEEP`|Prefetch for load, L1, keep in cache|
|ARM|`PRFM PLDL1STRM`|Prefetch for load, L1, streaming (evict soon)|
|RISC-V|None in base ISA|Vendor extensions (e.g., T-Head) add prefetch hints|

`PREFETCHNTA` (non-temporal prefetch) is critical for streaming workloads: data is fetched into a small buffer without displacing the working set from L1/L2, avoiding pollution.

#### Compiler-Inserted Prefetching

Compilers (GCC, Clang, ICC) analyze loop structure and insert prefetch instructions automatically. The canonical transformation for a loop with stride `S` and prefetch distance `D`:

```c
// Original
for (int i = 0; i < N; i++)
    sum += A[i];

// After software prefetch insertion (distance D iterations ahead)
for (int i = 0; i < N; i++) {
    __builtin_prefetch(&A[i + D], 0, 0);  // 0=read, 0=no temporal locality
    sum += A[i];
}
```

**Choosing D**: the prefetch must be issued far enough ahead that the memory latency is hidden, but not so far that the data is evicted before use.

```
D ≈ Memory_Latency_cycles / Loop_body_cycles
```

If memory latency is 200 cycles and the loop body executes in 4 cycles, D ≈ 50 iterations.

**Key Points:**

- Compiler prefetching is reliable for regular (affine) loops but fails for pointer-chasing or data-dependent access patterns, which require runtime information.
- Over-aggressive compiler prefetch insertion can reduce performance by saturating the memory bus.

#### Programmer-Directed Prefetching

In performance-critical code (database engines, HPC kernels, game engines), programmers manually insert prefetches for irregular patterns the compiler cannot deduce:

```c
// Linked list traversal — prefetch next node while processing current
Node *cur = head;
while (cur) {
    if (cur->next)
        __builtin_prefetch(cur->next, 0, 1);
    process(cur);
    cur = cur->next;
}
```

For pointer-chasing structures, this is the only software mechanism available, since the address of `cur->next` is not known until `cur` is loaded — creating an inherent **data-dependent latency chain** that hardware prefetchers also cannot resolve without running the pointer chain speculatively.

#### Helper Threads / Runahead Execution

A more aggressive technique: a **helper thread** (or the processor in **runahead mode**) runs slightly ahead of the main execution stream, executing load instructions speculatively to prime the cache — even if computed values are not retained. This handles pointer-chasing chains where the prefetch address cannot be computed without executing code.

In **hardware runahead execution** (proposed by Mutlu et al., 2003, and variants in production): when the processor encounters a long-latency miss that stalls the ROB, it enters runahead mode, marks registers with pseudo values, and speculatively executes forward — issuing prefetches as a side effect — until the blocking miss resolves, then rewinds and re-executes correctly.

---

### Prefetching in the Memory Hierarchy: Where Each Strategy Applies

|Level|Typical Prefetcher Type|Rationale|
|---|---|---|
|L1 → L2|Stride, stream (aggressive)|Latency of L2 miss is short; must act fast|
|L2 → L3|Stream, spatial, BOP|More time to compute prefetch address|
|L3 → DRAM|Stream with large degree|DRAM latency ~100+ ns; large prefetch window needed|
|DRAM → Storage|OS readahead (software)|Managed by kernel page cache, not hardware|
|Storage → DRAM|File system prefetch, mmap readahead|Entirely software; latency in milliseconds|

---

### OS and File System Prefetching

At the storage level, hardware prefetchers do not operate. All prefetching is software-managed:

**Linux readahead**: the kernel tracks sequential read patterns on file descriptors. When a sequential pattern is detected, it issues asynchronous `read_pages()` calls beyond the current file position, populating the page cache before the application requests those pages.

```
readahead window size: starts small, doubles on continued sequential access
controlled by: /sys/block/<dev>/queue/read_ahead_kb
```

**mmap + `madvise()`**: an application can advise the kernel about its intended access pattern:

|`madvise` flag|Meaning|
|---|---|
|`MADV_SEQUENTIAL`|Aggressive readahead, discard pages after use|
|`MADV_RANDOM`|Disable readahead (random access, prefetch is wasteful)|
|`MADV_WILLNEED`|Immediately prefetch the specified range|
|`MADV_DONTNEED`|Release pages from page cache|

**`posix_fadvise()`**: equivalent advisory interface for file descriptors rather than memory-mapped regions.

**Key Points:**

- `MADV_WILLNEED` is the programmer's explicit software prefetch for file data — identical in intent to `PREFETCHT0` for cache lines.
- Databases frequently call `posix_fadvise(POSIX_FADV_DONTNEED)` after sequential scans to avoid polluting the page cache with data that will not be reused.

---

### Interaction with Cache Replacement and Bandwidth

Prefetching competes for the same resources as demand accesses:

- **Memory bandwidth**: every prefetch request consumes bus bandwidth. On bandwidth-bound workloads, excessive prefetching can reduce overall throughput by displacing demand requests in the memory controller queue.
- **Cache capacity**: prefetched lines evict existing lines. A prefetch with low accuracy that evicts a line still in active use produces a **cache pollution miss** — a demand miss caused by the prefetcher itself.
- **MSHR slots**: prefetch requests occupy MSHR entries. If the MSHR is full, demand misses cannot be issued (a structural hazard; see Module 7 coverage on MSHRs).

**Throttling mechanisms** respond to these pressures dynamically:

- **Miss rate feedback**: if the demand miss rate rises while prefetching is active, reduce prefetch aggressiveness (degree or confidence threshold).
- **Bandwidth utilization feedback**: if memory bus utilization exceeds a threshold, halt low-confidence prefetches.
- **Prefetch accuracy tracking**: count prefetch hits vs. total prefetches; reduce degree when accuracy drops below a bound.

---

### Summary of Strategy Applicability

|Access Pattern|Best Hardware Strategy|Best Software Strategy|
|---|---|---|
|Sequential array|Stream prefetcher|Compiler loop prefetch|
|Fixed stride|Stride prefetcher (RPT)|Compiler loop prefetch|
|Struct field access|Spatial prefetcher (SMS)|Manual `__builtin_prefetch`|
|Repeating irregular|Markov / correlation|Helper thread|
|Pointer chasing|Runahead execution|Manual prefetch, helper thread|
|File sequential read|OS readahead|`madvise(MADV_SEQUENTIAL)`|
|File random read|None effective|`madvise(MADV_RANDOM)` (disable)|
|Streaming (no reuse)|`PREFETCHNTA` path|`MADV_SEQUENTIAL` + `DONTNEED`|

---

