## Multi-Level Caches


A single cache level cannot simultaneously satisfy the conflicting demands of low latency (requiring small size and proximity to the processor) and high hit rate (requiring large capacity). Multi-level cache hierarchies resolve this tension by interposing progressively larger, slower, and cheaper caches between the processor and main memory — each level catching the misses that escape the level above it.

---

### Motivation: The Latency-Capacity Conflict

|Memory Type|Latency|Capacity|Cost/bit|
|---|---|---|---|
|Register|~0 cycles|256–512 B|Very high|
|L1 Cache|3–5 cycles|32–64 KB|High|
|L2 Cache|10–20 cycles|256 KB – 4 MB|Medium|
|L3 Cache|30–50 cycles|4 – 64 MB|Lower|
|DRAM|100–300 cycles|8–128 GB|Low|
|NVMe SSD|~100,000 cycles|TBs|Very low|

A single large cache would have the latency of L3; a single small cache would have the hit rate of L1. The hierarchy exploits **temporal and spatial locality** — most accesses hit L1, the majority of misses hit L2, and so on — so the average memory access time approaches L1 latency while capacity approaches DRAM size.

---

### Hierarchy Structure

<svg viewBox="0 0 580 300" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- CPU cores --> <rect x="60" y="10" width="100" height="40" rx="3" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="110" y="35" text-anchor="middle" fill="#7af">Core 0</text> <rect x="190" y="10" width="100" height="40" rx="3" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="240" y="35" text-anchor="middle" fill="#7af">Core 1</text> <rect x="320" y="10" width="100" height="40" rx="3" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="370" y="35" text-anchor="middle" fill="#7af">Core 2</text> <rect x="450" y="10" width="100" height="40" rx="3" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="500" y="35" text-anchor="middle" fill="#7af">Core 3</text> <!-- L1 caches (private per core) --> <rect x="60" y="70" width="100" height="40" rx="3" fill="none" stroke="#5cf" stroke-width="1.5"/> <text x="110" y="87" text-anchor="middle" fill="#5cf">L1-I/D</text> <text x="110" y="101" text-anchor="middle" fill="#aaa" font-size="9">32KB, 3–5cy</text> <rect x="190" y="70" width="100" height="40" rx="3" fill="none" stroke="#5cf" stroke-width="1.5"/> <text x="240" y="87" text-anchor="middle" fill="#5cf">L1-I/D</text> <text x="240" y="101" text-anchor="middle" fill="#aaa" font-size="9">32KB, 3–5cy</text> <rect x="320" y="70" width="100" height="40" rx="3" fill="none" stroke="#5cf" stroke-width="1.5"/> <text x="370" y="87" text-anchor="middle" fill="#5cf">L1-I/D</text> <text x="370" y="101" text-anchor="middle" fill="#aaa" font-size="9">32KB, 3–5cy</text> <rect x="450" y="70" width="100" height="40" rx="3" fill="none" stroke="#5cf" stroke-width="1.5"/> <text x="500" y="87" text-anchor="middle" fill="#5cf">L1-I/D</text> <text x="500" y="101" text-anchor="middle" fill="#aaa" font-size="9">32KB, 3–5cy</text> <!-- L2 caches (private per core) --> <rect x="60" y="135" width="100" height="40" rx="3" fill="none" stroke="#fa7" stroke-width="1.5"/> <text x="110" y="152" text-anchor="middle" fill="#fa7">L2</text> <text x="110" y="166" text-anchor="middle" fill="#aaa" font-size="9">512KB, 12cy</text> <rect x="190" y="135" width="100" height="40" rx="3" fill="none" stroke="#fa7" stroke-width="1.5"/> <text x="240" y="152" text-anchor="middle" fill="#fa7">L2</text> <text x="240" y="166" text-anchor="middle" fill="#aaa" font-size="9">512KB, 12cy</text> <rect x="320" y="135" width="100" height="40" rx="3" fill="none" stroke="#fa7" stroke-width="1.5"/> <text x="370" y="152" text-anchor="middle" fill="#fa7">L2</text> <text x="370" y="166" text-anchor="middle" fill="#aaa" font-size="9">512KB, 12cy</text> <rect x="450" y="135" width="100" height="40" rx="3" fill="none" stroke="#fa7" stroke-width="1.5"/> <text x="500" y="152" text-anchor="middle" fill="#fa7">L2</text> <text x="500" y="166" text-anchor="middle" fill="#aaa" font-size="9">512KB, 12cy</text> <!-- L3 cache (shared) --> <rect x="60" y="200" width="490" height="45" rx="3" fill="none" stroke="#f77" stroke-width="1.8"/> <text x="305" y="220" text-anchor="middle" fill="#f77">L3 (Shared LLC)</text> <text x="305" y="237" text-anchor="middle" fill="#aaa" font-size="9">16–64 MB, 35–50 cycles</text> <!-- DRAM --> <rect x="60" y="265" width="490" height="28" rx="3" fill="none" stroke="#aaa" stroke-width="1.2"/> <text x="305" y="284" text-anchor="middle" fill="#aaa">Main Memory (DRAM) — 100–300 cycles</text> <!-- Vertical connections --> <line x1="110" y1="50" x2="110" y2="70" stroke="#555" stroke-width="1.2"/> <line x1="240" y1="50" x2="240" y2="70" stroke="#555" stroke-width="1.2"/> <line x1="370" y1="50" x2="370" y2="70" stroke="#555" stroke-width="1.2"/> <line x1="500" y1="50" x2="500" y2="70" stroke="#555" stroke-width="1.2"/> <line x1="110" y1="110" x2="110" y2="135" stroke="#555" stroke-width="1.2"/> <line x1="240" y1="110" x2="240" y2="135" stroke="#555" stroke-width="1.2"/> <line x1="370" y1="110" x2="370" y2="135" stroke="#555" stroke-width="1.2"/> <line x1="500" y1="110" x2="500" y2="135" stroke="#555" stroke-width="1.2"/> <line x1="110" y1="175" x2="110" y2="200" stroke="#555" stroke-width="1.2"/> <line x1="240" y1="175" x2="240" y2="200" stroke="#555" stroke-width="1.2"/> <line x1="370" y1="175" x2="370" y2="200" stroke="#555" stroke-width="1.2"/> <line x1="500" y1="175" x2="500" y2="200" stroke="#555" stroke-width="1.2"/> <line x1="305" y1="245" x2="305" y2="265" stroke="#555" stroke-width="1.2"/> </svg>

---

### L1 Cache

The L1 cache is **physically closest to the execution units** and is always split into separate instruction and data caches (Harvard-style at L1, unified at L2 and below).

#### Why Split I and D at L1?

- Instructions and data have distinct access patterns — prefetch behavior, stride, and write frequency differ fundamentally
- A split cache allows **simultaneous** instruction fetch and data load/store in the same cycle — critical for pipelined execution
- Each sub-cache can be independently tuned (I-cache: read-only, high spatial locality; D-cache: read/write, variable locality)

#### Design Parameters

|Parameter|Typical L1 Values|Rationale|
|---|---|---|
|Size|32–64 KB|Fits in 3–5 cycle access time budget|
|Associativity|4–8 way|Balance conflict misses vs. hit time|
|Block size|64 bytes|Matches cache line to DRAM burst|
|Write policy|Write-through or write-back|Write-through simplifies coherence|
|Access time|3–5 cycles|Must not exceed pipeline stage budget|
|Hit rate|~90–95%|For typical workloads|

The L1 access time must fit within the pipeline's load-use latency budget. If a load result is needed two cycles after issue, the L1 must respond in two cycles — this hard constraint bounds L1 size more than any other factor.

---

### L2 Cache

The L2 cache is **private to each core** in most modern designs and serves as the primary victim/backup for L1 misses. It is unified (instructions and data together).

#### Role

```
L1 miss
   ↓
Check L2
   ├── L2 hit  → supply data to L1 and core (10–20 cycles)
   └── L2 miss → escalate to L3
```

Because L2 handles only the ~5–10% of accesses that miss L1, it can afford higher latency and larger capacity without impacting average performance proportionally.

#### Design Parameters

|Parameter|Typical L2 Values|
|---|---|
|Size|256 KB – 4 MB|
|Associativity|8–16 way|
|Block size|64 bytes (matches L1)|
|Write policy|Write-back|
|Access time|10–20 cycles|
|Hit rate (of L1 misses)|~80–95%|

L2 is typically implemented in **low-leakage SRAM** with longer bit lines than L1, trading access time for density.

---

### L3 Cache (Last-Level Cache, LLC)

The L3 is **shared across all cores** on the die, acting as the last line of defense before main memory. It is the most architecturally complex level due to sharing and coherence requirements.

#### Role

```
L2 miss
   ↓
Check L3 (shared, all cores)
   ├── L3 hit  → supply data to requesting L2 and core (30–50 cycles)
   │             also: check if another core's L1/L2 has a modified copy
   └── L3 miss → DRAM access (100–300 cycles)
```

#### Design Parameters

|Parameter|Typical L3 Values|
|---|---|
|Size|4 MB – 64 MB (and growing)|
|Associativity|12–24 way|
|Block size|64 bytes|
|Write policy|Write-back|
|Access time|30–50 cycles|
|Organization|Sliced / banked (one slice per core)|

#### Sliced LLC

Large L3 caches are divided into **slices** — one per core — connected by a ring bus or mesh interconnect. A hash of the physical address determines which slice holds a given line. This prevents the entire LLC from being a single centralized structure with unacceptable wire delay.

<svg viewBox="0 0 540 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="10"> <!-- Ring bus with 4 cores and 4 LLC slices --> <!-- Cores top --> <rect x="80" y="10" width="70" height="30" rx="3" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="115" y="30" text-anchor="middle" fill="#7af">Core 0</text> <rect x="370" y="10" width="70" height="30" rx="3" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="405" y="30" text-anchor="middle" fill="#7af">Core 1</text> <!-- Cores bottom --> <rect x="80" y="160" width="70" height="30" rx="3" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="115" y="180" text-anchor="middle" fill="#7af">Core 3</text> <rect x="370" y="160" width="70" height="30" rx="3" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="405" y="180" text-anchor="middle" fill="#7af">Core 2</text> <!-- LLC slices --> <rect x="70" y="82" width="90" height="36" rx="3" fill="none" stroke="#f77" stroke-width="1.5"/> <text x="115" y="99" text-anchor="middle" fill="#f77">LLC Slice 0</text> <text x="115" y="111" text-anchor="middle" fill="#aaa" font-size="8">addr hash %4 = 0</text> <rect x="360" y="82" width="90" height="36" rx="3" fill="none" stroke="#f77" stroke-width="1.5"/> <text x="405" y="99" text-anchor="middle" fill="#f77">LLC Slice 1</text> <text x="405" y="111" text-anchor="middle" fill="#aaa" font-size="8">addr hash %4 = 1</text> <rect x="190" y="50" width="90" height="36" rx="3" fill="none" stroke="#f77" stroke-width="1.5"/> <text x="235" y="67" text-anchor="middle" fill="#f77">LLC Slice 3</text> <text x="235" y="79" text-anchor="middle" fill="#aaa" font-size="8">addr hash %4 = 3</text> <rect x="255" y="120" width="90" height="36" rx="3" fill="none" stroke="#f77" stroke-width="1.5"/> <text x="300" y="137" text-anchor="middle" fill="#f77">LLC Slice 2</text> <text x="300" y="149" text-anchor="middle" fill="#aaa" font-size="8">addr hash %4 = 2</text> <!-- Ring bus --> <ellipse cx="270" cy="100" rx="165" ry="60" fill="none" stroke="#555" stroke-width="1.5" stroke-dasharray="6,4"/> <text x="270" y="104" text-anchor="middle" fill="#444" font-size="9">Ring / Mesh Interconnect</text> <!-- Core-to-slice connections --> <line x1="115" y1="40" x2="115" y2="82" stroke="#555" stroke-width="1"/> <line x1="115" y1="118" x2="115" y2="160" stroke="#555" stroke-width="1"/> <line x1="405" y1="40" x2="405" y2="82" stroke="#555" stroke-width="1"/> <line x1="405" y1="118" x2="405" y2="160" stroke="#555" stroke-width="1"/> </svg>

---

### Inclusive, Exclusive, and Non-Inclusive Hierarchies

The relationship between what data is stored at each level is a fundamental design choice.

#### Inclusive

Every line present in L1 or L2 is **also present in L3**.

```
L3 ⊇ L2 ⊇ L1
```

- L3 can act as a **snoop filter** — to check coherence, only L3 needs to be consulted, not all L1/L2 caches
- A line evicted from L3 **must also be invalidated** from all L1/L2 caches (inclusion property enforcement)
- Wastes L3 capacity: data in L1 occupies both L1 and L3 simultaneously
- Used in: Intel Sandy Bridge through Broadwell

#### Exclusive

A line exists in **exactly one level** of the hierarchy at any time.

```
L1 ∩ L2 = ∅ ;  L2 ∩ L3 = ∅
```

- On an L1 miss that hits L2: the line is **swapped** — moved to L1, evicted from L2
- Total capacity = L1 + L2 + L3 (no duplication waste)
- Coherence is more complex — the snoop filter must track all levels independently
- Used in: AMD Opteron, some embedded designs

#### Non-Inclusive / Non-Exclusive (NINE)

Lines may or may not be present in multiple levels — no invariant is enforced.

- L2 and L3 act as **victim caches** — they hold recently evicted lines from the level above
- Most flexible; most common in modern high-performance designs
- Requires a separate **snoop filter / directory** to track line locations
- Used in: Intel Skylake and later (L3 became NINE with a separate snoop filter)

|Property|Inclusive|Exclusive|NINE|
|---|---|---|---|
|Capacity efficiency|Low|High|Medium–High|
|Snoop filter needed|No (L3 is filter)|Yes|Yes|
|Eviction on L3 evict|Must invalidate L1/L2|Only in one place|Best-effort|
|Coherence complexity|Lower|Higher|Medium|

---

### Average Memory Access Time (AMAT)

AMAT is the primary metric for evaluating a cache hierarchy:

$$\text{AMAT} = t_{L1} + m_{L1} \cdot (t_{L2} + m_{L2} \cdot (t_{L3} + m_{L3} \cdot t_{DRAM}))$$

where $t_X$ is the hit time at level $X$ and $m_X$ is the miss rate at level $X$.

**Example:**

|Parameter|Value|
|---|---|
|$t_{L1}$|4 cycles|
|$m_{L1}$|5%|
|$t_{L2}$|12 cycles|
|$m_{L2}$|10%|
|$t_{L3}$|40 cycles|
|$m_{L3}$|20%|
|$t_{DRAM}$|200 cycles|

$$\text{AMAT} = 4 + 0.05 \cdot (12 + 0.10 \cdot (40 + 0.20 \cdot 200))$$

$$= 4 + 0.05 \cdot (12 + 0.10 \cdot 80)$$

$$= 4 + 0.05 \cdot (12 + 8)$$

$$= 4 + 0.05 \cdot 20 = 4 + 1.0 = \mathbf{5.0 \text{ cycles}}$$

Without L2 and L3 (direct DRAM on L1 miss): $$\text{AMAT} = 4 + 0.05 \cdot 200 = 4 + 10 = 14 \text{ cycles}$$

The hierarchy reduces AMAT from 14 to 5 cycles in this example — a $2.8\times$ improvement.

---

### Miss Classification: The Three Cs

All cache misses at any level fall into one of three categories:

|Class|Cause|Reducible By|
|---|---|---|
|**Compulsory** (cold)|First access to a line — never been in cache|Prefetching; larger blocks|
|**Capacity**|Working set exceeds cache size|Larger cache|
|**Conflict**|Multiple lines map to same set, evict each other|Higher associativity; better placement|

A fourth category relevant to multi-level caches:

|Class|Cause|Reducible By|
|---|---|---|
|**Coherence**|A line is invalidated by another core's write|Coherence protocol optimization; sharing reduction|

---

### Write Policies Across Levels

|Level|Typical Write Policy|Rationale|
|---|---|---|
|L1|Write-through + write buffer, or write-back|Write-through simplifies coherence; write-back reduces traffic|
|L2|Write-back|Reduces L3 bandwidth pressure|
|L3|Write-back|Reduces DRAM bandwidth pressure|

With write-back at every level, a **dirty line** may exist only in L1 — all other levels hold stale data. This dirty state must be tracked (dirty bit per cache line) and the line must be written back to the next level on eviction.

---

### Cache Line State Through the Hierarchy

A 64-byte cache line travels through the hierarchy with associated metadata at each level:

```
Per-line metadata at each cache level:
  ┌──────────┬───────┬───────┬──────────┬──────────┐
  │  Tag     │ Valid │ Dirty │  State   │  Data    │
  │ (addr)   │  bit  │  bit  │ (MESI…)  │ (64 B)   │
  └──────────┴───────┴───────┴──────────┴──────────┘

State field per MESI protocol:
  M — Modified: dirty, only copy
  E — Exclusive: clean, only copy
  S — Shared: clean, may exist in other caches
  I — Invalid: not present / not usable
```

The MESI state transitions are coordinated across all levels by the **cache coherence protocol** — handled at the L3/LLC level in most designs via a directory or snoop-filter.

---

### Critical Path of a Multi-Level Miss

<svg viewBox="0 0 600 180" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="10"> <!-- Timeline bar --> <line x1="20" y1="90" x2="580" y2="90" stroke="#333" stroke-width="1"/> <!-- L1 access --> <rect x="20" y="65" width="55" height="30" rx="2" fill="#1a2a3a" stroke="#5cf" stroke-width="1.5"/> <text x="47" y="84" text-anchor="middle" fill="#5cf">L1</text> <text x="47" y="107" text-anchor="middle" fill="#aaa" font-size="9">4 cy</text> <!-- L1 miss marker --> <line x1="75" y1="55" x2="75" y2="115" stroke="#f77" stroke-width="1" stroke-dasharray="3,2"/> <text x="75" y="50" text-anchor="middle" fill="#f77" font-size="8">miss</text> <!-- L2 access --> <rect x="75" y="65" width="100" height="30" rx="2" fill="#1a2a3a" stroke="#fa7" stroke-width="1.5"/> <text x="125" y="84" text-anchor="middle" fill="#fa7">L2</text> <text x="125" y="107" text-anchor="middle" fill="#aaa" font-size="9">12 cy</text> <!-- L2 miss marker --> <line x1="175" y1="55" x2="175" y2="115" stroke="#f77" stroke-width="1" stroke-dasharray="3,2"/> <text x="175" y="50" text-anchor="middle" fill="#f77" font-size="8">miss</text> <!-- L3 access --> <rect x="175" y="65" width="140" height="30" rx="2" fill="#1a2a3a" stroke="#f77" stroke-width="1.5"/> <text x="245" y="84" text-anchor="middle" fill="#f77">L3</text> <text x="245" y="107" text-anchor="middle" fill="#aaa" font-size="9">40 cy</text> <!-- L3 miss marker --> <line x1="315" y1="55" x2="315" y2="115" stroke="#f55" stroke-width="1" stroke-dasharray="3,2"/> <text x="315" y="50" text-anchor="middle" fill="#f55" font-size="8">miss</text> <!-- DRAM access --> <rect x="315" y="65" width="255" height="30" rx="2" fill="#2a1a1a" stroke="#aaa" stroke-width="1.5"/> <text x="442" y="84" text-anchor="middle" fill="#aaa">DRAM</text> <text x="442" y="107" text-anchor="middle" fill="#555" font-size="9">~200 cy</text> <!-- Total label -->

<text x="300" y="135" text-anchor="middle" fill="#ccc" font-size="10">Total miss penalty: ~256 cycles (L1+L2+L3+DRAM)</text> <text x="300" y="150" text-anchor="middle" fill="#555" font-size="9">Each level's lookup is serial — the critical path is additive on a full miss</text>

<!-- Arrows to show sequential --> <line x1="75" y1="80" x2="75" y2="80" stroke="#555" stroke-width="1"/> </svg>

On a full miss to DRAM, the penalty is approximately additive through each level. This is why minimizing the L3 miss rate is critical — an L3 miss is catastrophically more expensive than an L2 miss.

---

### L1 Design: Speed-Critical Optimizations

Because L1 latency directly affects pipeline CPI, several aggressive techniques are applied:

#### Virtually Indexed, Physically Tagged (VIPT)

- The cache is indexed using virtual address bits (no TLB needed to begin the lookup)
- Tag comparison uses the physical address (from TLB, which runs in parallel)
- Correct only if the index bits lie entirely within the page offset (below the 12-bit page boundary), so that virtual and physical index bits are identical

$$\text{VIPT safe condition:} \quad \log_2(\text{sets} \times \text{block size}) \leq 12$$

For a 32 KB, 8-way, 64-byte-block L1: $\log_2(64 \times 64) = 12$ — exactly at the boundary.

#### Critical Word First

When a cache line miss occurs, the specific word the processor needs is transferred first from DRAM/LLC — execution can resume before the entire 64-byte line arrives.

#### Non-Blocking Cache with MSHRs

**Miss Status Holding Registers (MSHRs)** allow the cache to handle multiple outstanding misses simultaneously instead of stalling on the first one. Each MSHF tracks:

- The missing address
- Which instruction is waiting
- What sub-word within the line is needed

A cache with $N$ MSHRs can tolerate $N$ simultaneous outstanding misses — critical for hiding memory latency under out-of-order execution.

---

### L3 Design: Bandwidth-Critical Optimizations

The LLC is optimized for bandwidth and fair sharing rather than raw latency:

#### Way Partitioning (Intel CAT)

Intel Cache Allocation Technology allows the OS or hypervisor to assign specific LLC ways to specific cores or VMs — preventing one workload from evicting another's data (cache thrashing in shared environments).

#### Adaptive Replacement Policies

Standard LRU performs poorly for streaming access patterns (scans of large arrays thrash the cache). Modern LLCs use:

- **Pseudo-LRU (PLRU)**: approximates LRU with fewer bits per line
- **RRIP (Re-Reference Interval Prediction)**: new lines inserted with a "distant re-reference" prediction; promoted only on actual re-use — resists scan pollution

#### Prefetcher Integration

The L2 and L3 house hardware prefetchers that monitor access patterns and issue speculative fetches:

- **Stream prefetcher**: detects sequential strides
- **Stride prefetcher**: detects fixed non-unit strides
- **SMS (Spatial Memory Streaming)**: tracks spatial patterns within pages

---

### Multi-Level Cache and Out-of-Order Execution

The interaction between the ROB/OOO engine and the cache hierarchy is critical to performance:

```
Load instruction issues
   ↓
Checks L1 D-cache
   ├── Hit (4 cy):  result forwarded to ROB, dependent instructions wake
   └── Miss:        MSHR allocated; instruction stays in ROB
         ↓
   Checks L2 (12 cy)
         ├── Hit:   fills L1, wakes load in ROB
         └── Miss:
               ↓
         Checks L3 (40 cy)
               ├── Hit:   fills L2→L1, wakes load
               └── Miss: DRAM fetch (200 cy)
                         fills L3→L2→L1, wakes load
```

During the entire miss penalty, the OOO engine continues executing independent instructions from the ROB window. The ROB size determines how many independent instructions can be found to fill the gap — a 200-cycle DRAM miss requires a very large instruction window to fully hide.

---

### Real Processor Cache Configurations

|Processor|L1-I|L1-D|L2|L3|
|---|---|---|---|---|
|Intel Skylake|32 KB, 8-way|32 KB, 8-way|256 KB/core|8–16 MB shared|
|Intel Golden Cove (Alder Lake)|32 KB|48 KB, 12-way|1.25 MB/core|30 MB shared|
|AMD Zen 4|32 KB|32 KB|1 MB/core|32 MB/CCD|
|Apple Firestorm (M1 P-core)|192 KB|128 KB|12 MB/cluster|—|
|ARM Cortex-A78|32 KB|32 KB|256 KB–512 KB|4–8 MB|

Apple's M-series uses an unusually large L2 that functionally subsumes what other designs call L2 and L3 combined. [Inference] Exact internal configurations are based on reverse-engineering and Anandtech-level analyses; Apple does not officially publish cache specifications.

---

### **Key Points**

- The multi-level hierarchy exploits locality: most accesses hit L1, most misses hit L2, most remaining misses hit L3 — DRAM traffic is minimized.
- L1 is speed-optimized: small, low-associativity, split I/D, accessed speculatively via VIPT, with MSHRs for non-blocking operation.
- L2 is private per-core and serves as the primary backup for L1 misses; its latency must be low enough that dependent instructions do not stall the OOO window excessively.
- L3 is shared across cores, sliced for scalability, and acts as the last cache before DRAM; its miss rate is the primary determinant of memory bandwidth demand.
- Inclusive hierarchies waste capacity but simplify coherence via L3-as-snoop-filter; NINE hierarchies maximize capacity but require a separate directory.
- AMAT captures the weighted cost of the full hierarchy and is the standard metric for cache design evaluation.
- The OOO window size and MSHR count jointly determine how effectively long-latency cache misses can be tolerated without stalling execution.
- Write-back policy at every level minimizes inter-level traffic; dirty bits and coherence states track which level holds the authoritative copy.

---

### **Example**

**Workload A** (high temporal locality — matrix diagonal access):

- L1 hit rate: 96%, L2 hit rate: 99%, L3 hit rate: 99%
- $\text{AMAT} = 4 + 0.04(12 + 0.01(40 + 0.01 \times 200)) = 4 + 0.04 \times 12.42 \approx 4.50$ cycles

**Workload B** (low locality — random pointer chasing across 1 GB):

- L1 hit rate: 40%, L2 hit rate: 30%, L3 hit rate: 20%
- $\text{AMAT} = 4 + 0.60(12 + 0.70(40 + 0.80 \times 200))$
- $= 4 + 0.60(12 + 0.70 \times 200) = 4 + 0.60 \times 152 = 4 + 91.2 = \mathbf{95.2}$ cycles

The $21\times$ difference in AMAT between these workloads — with identical hardware — illustrates that the cache hierarchy's effectiveness is fundamentally determined by application memory access patterns, not just hardware parameters.

---

### **Conclusion**

Multi-level cache hierarchies are the primary mechanism by which modern processors bridge a three-order-of-magnitude latency gap between the core and DRAM. The design of each level reflects a distinct point in the latency-capacity trade-off space, and the interactions between levels — fill policies, inclusion properties, coherence protocols, and non-blocking mechanisms — determine both single-thread performance and multi-core scalability. Understanding AMAT, the Three Cs miss model, and the per-level design constraints is prerequisite to reasoning about any memory-bound workload or cache-aware algorithm.

---

### **Next Steps**

- **Cache Coherence (MSI, MESI, MOESI)** — how the shared L3 and private L1/L2 caches maintain a consistent view of memory across cores, and the protocol state machines that govern line transitions
- **Virtual Memory and TLB Design** — how virtual-to-physical address translation interacts with the VIPT L1 cache and the TLB shootdown problem in multi-core systems
- **DRAM Internals and Timing** — the timing parameters (tRCD, tCL, tRP) that determine the 100–300 cycle DRAM penalty that the cache hierarchy is designed to avoid

---

