## Locality of Reference


Locality of reference is the empirical tendency of programs to access a small, non-random subset of their address space over any given time interval. It is the foundational behavioral property that makes hierarchical memory systems effective. Without locality, a cache would offer no advantage over direct DRAM access.

---

### Why Locality Exists

Locality is not an architectural assumption imposed on programs — it emerges from the structure of computation itself:

```
Loops        → same instructions and variables accessed repeatedly
Arrays       → sequential element access traverses contiguous memory
Functions    → local variables and stack frames occupy compact regions
Data structs → struct fields, linked list nodes cluster in memory
Code         → instruction fetch proceeds sequentially; branches are local
```

A program that accessed memory purely at random would exhibit no locality. Real programs do not behave this way.

---

### The Two Fundamental Types

#### Temporal Locality

A memory location that has been accessed recently is likely to be accessed again in the near future.

```
Source:   Loop variables, counters, accumulators
          Function-local variables within a call frame
          Frequently called code paths (hot loops)
          Instruction fetch of loop bodies
```

**Example:**

```c
int sum = 0;                  // sum: accessed on every iteration
for (int i = 0; i < N; i++) {
    sum += a[i];              // sum written and read each iteration
}                             // loop counter i: temporal locality
```

`sum` and `i` are accessed on every loop iteration. Both exhibit strong temporal locality — the same addresses are re-read and re-written $N$ times. A cache that holds these variables eliminates $N - 1$ main memory accesses for each.

#### Spatial Locality

If a memory location is accessed, nearby addresses are likely to be accessed soon.

```
Source:   Array traversal (sequential element access)
          Struct field access (fields are contiguous)
          Sequential instruction fetch
          Stack frame access (local variables are adjacent)
```

**Example:**

```c
for (int i = 0; i < N; i++) {
    sum += a[i];              // a[0], a[1], a[2], ... accessed in order
}
```

`a[i]` and `a[i+1]` are 4 bytes apart (int). Accessing `a[0]` predicts with high probability that `a[1]`, `a[2]`, ..., `a[cache_line_size/4 - 1]` will follow. A cache line fetch brings all of them into cache simultaneously, converting future accesses to hits.

---

### Formal Characterization

Let $r(t)$ denote the memory address accessed at time $t$.

**Temporal locality** implies:

$$P(r(t+\delta) = r(t)) \gg \frac{1}{|AddressSpace|}$$

for small $\delta$ — the probability of re-accessing the same address within a short time window is much higher than chance.

**Spatial locality** implies:

$$P(|r(t+\delta) - r(t)| < \epsilon) \gg \frac{\epsilon}{|AddressSpace|}$$

for small $\delta$ and $\epsilon$ — nearby addresses are accessed with probability far exceeding what a uniform random distribution would produce.

---

### Locality in the Memory Hierarchy

Each level of the memory hierarchy is designed to exploit a specific type of locality:

<svg viewBox="0 0 680 420" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="680" height="420" fill="#0d1117" rx="8"/> <text x="340" y="26" text-anchor="middle" fill="#c9d1d9" font-size="13" font-weight="bold">Memory Hierarchy and Locality Exploitation</text> <!-- Registers --> <rect x="240" y="45" width="200" height="44" rx="5" fill="#1a2d3a" stroke="#58a6ff" stroke-width="1.8"/> <text x="340" y="63" text-anchor="middle" fill="#58a6ff" font-size="11" font-weight="bold">Registers</text> <text x="340" y="79" text-anchor="middle" fill="#8b949e" font-size="9">~1 cycle | ~1 KB | Temporal (compiler)</text> <!-- L1 Cache --> <rect x="195" y="108" width="290" height="44" rx="5" fill="#1a2d3a" stroke="#3b6ea5" stroke-width="1.5"/> <text x="340" y="126" text-anchor="middle" fill="#79b8ff" font-size="11" font-weight="bold">L1 Cache</text> <text x="340" y="142" text-anchor="middle" fill="#8b949e" font-size="9">~4 cycles | 32–64 KB | Temporal + Spatial (cache lines)</text> <!-- L2 Cache --> <rect x="150" y="171" width="380" height="44" rx="5" fill="#1a2d3a" stroke="#3b6ea5" stroke-width="1.3"/> <text x="340" y="189" text-anchor="middle" fill="#79b8ff" font-size="11" font-weight="bold">L2 Cache</text> <text x="340" y="205" text-anchor="middle" fill="#8b949e" font-size="9">~12 cycles | 256 KB–1 MB | Spatial (larger line fetch)</text> <!-- L3 Cache --> <rect x="100" y="234" width="480" height="44" rx="5" fill="#1a2d3a" stroke="#3b6ea5" stroke-width="1.2"/> <text x="340" y="252" text-anchor="middle" fill="#79b8ff" font-size="11" font-weight="bold">L3 Cache (LLC)</text> <text x="340" y="268" text-anchor="middle" fill="#8b949e" font-size="9">~40 cycles | 8–64 MB | Spatial (shared; large working sets)</text> <!-- DRAM --> <rect x="50" y="297" width="580" height="44" rx="5" fill="#1a2332" stroke="#30363d" stroke-width="1.2"/> <text x="340" y="315" text-anchor="middle" fill="#8b949e" font-size="11" font-weight="bold">Main Memory (DRAM)</text> <text x="340" y="331" text-anchor="middle" fill="#6e7681" font-size="9">~100 cycles | GBs | Row buffer locality (spatial within DRAM row)</text> <!-- Disk/SSD --> <rect x="20" y="360" width="640" height="44" rx="5" fill="#1a1a1a" stroke="#30363d" stroke-width="1.0"/> <text x="340" y="378" text-anchor="middle" fill="#6e7681" font-size="11" font-weight="bold">Storage (SSD / HDD)</text> <text x="340" y="394" text-anchor="middle" fill="#555" font-size="9">~100 µs–10 ms | TBs | Sequential access (spatial on disk)</text> <!-- Vertical connecting lines --> <line x1="340" y1="89" x2="340" y2="108" stroke="#30363d" stroke-width="1.2"/> <line x1="340" y1="152" x2="340" y2="171" stroke="#30363d" stroke-width="1.2"/> <line x1="340" y1="215" x2="340" y2="234" stroke="#30363d" stroke-width="1.2"/> <line x1="340" y1="278" x2="340" y2="297" stroke="#30363d" stroke-width="1.2"/> <line x1="340" y1="341" x2="340" y2="360" stroke="#30363d" stroke-width="1.2"/> <!-- Temporal label -->

<text x="12" y="135" fill="#3fb950" font-size="9" transform="rotate(-90,12,160)">◄ Temporal</text>

<!-- Spatial label -->

<text x="660" y="200" fill="#e6c07b" font-size="9" transform="rotate(90,660,220)">Spatial ►</text> </svg>

**Temporal locality** is exploited by keeping recently used data in fast storage (registers, L1). If the same address is re-accessed, it is found at the top of the hierarchy.

**Spatial locality** is exploited by fetching data in contiguous blocks (cache lines, typically 64 bytes). When one address is accessed, the surrounding 63 bytes are fetched simultaneously, anticipating nearby accesses.

---

### Cache Line Mechanics and Spatial Locality

A cache line is the unit of transfer between memory levels. On a miss, the entire cache line containing the requested address is fetched:

```
Cache line size: 64 bytes (typical)
int array:       4 bytes per element → 16 integers per cache line

Access a[0]:  MISS → fetch a[0]..a[15] into cache (1 memory transaction)
Access a[1]:  HIT  (already in cache)
Access a[2]:  HIT
...
Access a[15]: HIT
Access a[16]: MISS → fetch a[16]..a[31]
```

Spatial locality converts 16 memory accesses into 1 memory transaction + 15 cache hits. The hit rate for sequential traversal approaches $1 - \frac{1}{\text{cache_line_elements}}$.

---

### Working Set Model

The **working set** $W(t, \Delta)$ is the set of distinct memory pages accessed in the time window $[t - \Delta, t]$:

$$W(t, \Delta) = {r(\tau) : t - \Delta \leq \tau \leq t}$$

If $|W(t, \Delta)|$ fits within the cache, temporal locality keeps most accesses as hits. When the working set exceeds cache capacity, the miss rate rises sharply — a phenomenon called **capacity miss pressure** or **working set thrashing**.

<svg viewBox="0 0 660 220" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="660" height="220" fill="#0d1117" rx="8"/> <text x="330" y="24" text-anchor="middle" fill="#c9d1d9" font-size="13" font-weight="bold">Miss Rate vs. Working Set Size</text> <!-- Axes --> <line x1="70" y1="170" x2="620" y2="170" stroke="#30363d" stroke-width="1.2"/> <line x1="70" y1="40" x2="70" y2="170" stroke="#30363d" stroke-width="1.2"/> <!-- Axis labels -->

<text x="345" y="195" text-anchor="middle" fill="#8b949e" font-size="10">Working Set Size</text> <text x="18" y="110" fill="#8b949e" font-size="10" transform="rotate(-90,18,110)">Miss Rate</text>

<!-- Cache capacity markers --> <line x1="200" y1="40" x2="200" y2="172" stroke="#58a6ff" stroke-width="1" stroke-dasharray="4,3"/> <text x="200" y="35" text-anchor="middle" fill="#58a6ff" font-size="9">L1</text> <line x1="310" y1="40" x2="310" y2="172" stroke="#3b6ea5" stroke-width="1" stroke-dasharray="4,3"/> <text x="310" y="35" text-anchor="middle" fill="#3b6ea5" font-size="9">L2</text> <line x1="440" y1="40" x2="440" y2="172" stroke="#1f4a7a" stroke-width="1" stroke-dasharray="4,3"/> <text x="440" y="35" text-anchor="middle" fill="#1f4a7a" font-size="9">L3</text> <!-- Miss rate curve: low → step up at each cache boundary -->

<polyline points="70,162 200,160 205,148 310,145 318,118 440,113 450,75 620,72" fill="none" stroke="#f78166" stroke-width="2.2"/>

<!-- Region labels -->

<text x="135" y="155" text-anchor="middle" fill="#3fb950" font-size="9">fits L1</text> <text x="255" y="140" text-anchor="middle" fill="#e6c07b" font-size="9">fits L2</text> <text x="375" y="110" text-anchor="middle" fill="#e6c07b" font-size="9">fits L3</text> <text x="535" y="70" text-anchor="middle" fill="#f78166" font-size="9">DRAM-bound</text>

<!-- Y axis ticks -->

<text x="62" y="163" text-anchor="end" fill="#8b949e" font-size="9">low</text> <text x="62" y="80" text-anchor="end" fill="#8b949e" font-size="9">high</text> </svg>

Each step in the miss rate corresponds to the working set outgrowing a cache level. The working set model guides loop tiling and blocking optimizations.

---

### Locality Violations and Their Cost

#### Stride Access Pattern

A stride-$s$ access pattern touches every $s$-th byte:

```
Stride 1   (sequential):  a[0], a[1], a[2], ...        → full spatial locality
Stride 4   (skip 3):      a[0], a[4], a[8], ...        → partial (every 4th element)
Stride 64  (cache line):  a[0], a[64], a[128], ...     → every access is a new cache line
Stride >>  (random):      a[0], a[1003], a[47], ...    → no spatial locality
```

For a 64-byte cache line holding 16 integers, stride-1 gives 1 miss per 16 accesses (6.25% miss rate). Stride-16 gives 1 miss per access (100% miss rate). Stride access is the most common locality violation in numerical code.

#### Column-Major vs. Row-Major Array Traversal

A 2D array stored in row-major order (C default):

```
int A[1024][1024];   // A[row][col], row-major in memory

Row-major traversal (good):
  for (i = 0; i < N; i++)
    for (j = 0; j < N; j++)
      sum += A[i][j];    // A[i][0], A[i][1], ... sequential → spatial locality

Column-major traversal (bad):
  for (j = 0; j < N; j++)
    for (i = 0; i < N; i++)
      sum += A[i][j];    // A[0][j], A[1][j], ... stride = 1024 ints = 4096 bytes
                         // Each access is a new cache line → no spatial locality
```

For a 1024×1024 int matrix, the column-major traversal generates 1,048,576 cache misses; the row-major traversal generates 65,536 (16× fewer for a 64-byte line).

---

### Loop Tiling (Blocking): Exploiting Both Locality Types

Loop tiling restructures nested loops to operate on sub-blocks that fit in cache, recovering temporal locality for data that would otherwise be evicted before reuse:

```c
// Original matrix multiply — poor temporal locality for B
for (i = 0; i < N; i++)
  for (j = 0; j < N; j++)
    for (k = 0; k < N; k++)
      C[i][j] += A[i][k] * B[k][j];   // B traversed column-major

// Tiled matrix multiply — B tile fits in L1/L2
int T = 64;  // tile size tuned to cache
for (ii = 0; ii < N; ii += T)
  for (jj = 0; jj < N; jj += T)
    for (kk = 0; kk < N; kk += T)
      for (i = ii; i < ii+T; i++)
        for (j = jj; j < jj+T; j++)
          for (k = kk; k < kk+T; k++)
            C[i][j] += A[i][k] * B[k][j];
```

The tile of `B` (T×T elements) remains in cache across the inner loops, converting cold misses to hits for repeated accesses.

---

### Prefetching and Spatial Locality

Hardware prefetchers detect regular stride patterns in cache miss addresses and issue early fetch requests to hide DRAM latency:

```
Observed miss pattern:  addr 0x1000, 0x1040, 0x1080, 0x10C0 ...
                        (stride = 64 bytes = 1 cache line)
Prefetcher prediction:  fetch 0x1100 before it is requested
```

Prefetching is effective precisely because spatial locality makes access patterns predictable. Random access patterns defeat hardware prefetchers entirely.

Software prefetch instructions (`__builtin_prefetch` in GCC, `PREFETCHT0` in x86) allow compilers and programmers to issue explicit prefetch hints when the hardware prefetcher cannot detect the pattern.

---

### Temporal Locality in the Instruction Stream

Locality applies equally to code as to data:

```
Sequential fetch:    PC advances by 4 each cycle → spatial locality in instruction cache
Loops:               same instructions re-fetched on every iteration → temporal locality
Function hot paths:  frequently called functions stay resident in L1-I cache
```

This is why the instruction cache (I-cache) and data cache (D-cache) are split at L1 — their access patterns differ. Code exhibits strong spatial locality (sequential fetch) and strong temporal locality (loops). Data exhibits variable locality depending on the algorithm.

---

### Quantifying Locality: Reuse Distance

**Reuse distance** (also called LRU stack distance) for an access to address $a$ is the number of distinct addresses accessed since the last access to $a$:

```
Access sequence:  A  B  C  A  D  B
Reuse distances:  ∞  ∞  ∞  2  ∞  3

A at position 4: since last access to A (position 1), saw B and C → distance = 2
B at position 6: since last access to B (position 2), saw C, A, D → distance = 3
```

A reuse distance of $d$ means the address would be a cache hit in any fully-associative LRU cache with capacity $> d$ cache lines. The reuse distance distribution of a program is a complete characterization of its temporal locality and can be used to predict miss rates for any cache size.

---

### Locality and Memory Consistency

In multicore systems, locality interacts with cache coherence:

```
Core 0 writes X  →  X in Core 0's L1 (temporal locality — future reads are fast)
Core 1 reads X   →  Core 0's copy must be invalidated or shared (coherence traffic)
```

False sharing occurs when two cores access different variables that happen to reside on the same cache line. The cache coherence protocol treats the entire line as shared, generating invalidation traffic even though no logical sharing exists. This is a spatial locality pathology: the cache line is too large relative to the granularity of independent data.

```
struct {
    int counter_a;   // used by Core 0
    int counter_b;   // used by Core 1
} shared;            // both fields on same 64-byte cache line → false sharing
```

---

### Locality Summary Table

|Property|Temporal Locality|Spatial Locality|
|---|---|---|
|Definition|Same address reaccessed soon|Nearby addresses accessed soon|
|Exploited by|Cache retention (LRU policy keeps recent data)|Cache line fetch (64-byte blocks)|
|Violated by|Large working sets, random access, pointer chasing|Stride > cache line, column-major on row-major arrays|
|Prefetch benefit|Low (address must have been seen before)|High (stream/stride prefetchers exploit it)|
|Relevant code pattern|Loops, counters, local variables|Array traversal, struct access, sequential code|
|Failure consequence|Capacity misses, thrashing|Spatial miss on every access, wasted bandwidth|

---

**Key Points**

- Temporal locality: recently accessed addresses are likely to be accessed again. Exploited by cache retention policies.
- Spatial locality: nearby addresses are likely to be accessed. Exploited by fetching 64-byte cache lines on every miss.
- Both types emerge naturally from loop structure, array layout, and sequential instruction fetch — they are properties of programs, not hardware.
- The working set model connects temporal locality to cache sizing: when the working set fits in a cache level, most accesses hit.
- Stride access patterns, column-major traversal of row-major arrays, and pointer chasing are the primary causes of locality degradation.
- Loop tiling restructures computation to keep active data within cache bounds, restoring temporal locality for reused operands.
- False sharing in multicore systems is a spatial locality artifact at the cache coherence layer.

**Conclusion** Locality of reference is the behavioral contract between programs and memory hierarchy design. Every cache sizing decision, cache line width, replacement policy, and prefetcher design is premised on its existence. When programs violate locality — through irregular access patterns, excessive working sets, or cache-hostile data layouts — the full latency penalty of lower memory hierarchy levels is exposed, and no amount of cache hierarchy depth compensates.

**Next Steps** Proceed to _Cache Fundamentals_ to see how temporal and spatial locality are mechanically exploited through cache organization, or to _Cache Mapping_ to examine how direct-mapped, set-associative, and fully associative structures trade capacity miss rate against conflict miss rate.

---

