## Cache Fundamentals


A cache is a small, fast memory placed between the processor and main memory to reduce the average time required to access data. It exploits the statistical regularity of memory reference patterns to keep frequently and recently used data close to the processor. Without a cache, every memory access would incur the full latency of DRAM — typically hundreds of cycles — stalling the processor on nearly every load and store.

---

### The Memory Latency Problem

Modern processors execute instructions in 1–4 cycles. DRAM access latency is 100–300 cycles. Without intervention, memory-bound programs would spend the majority of their execution time waiting for data. The cache hierarchy bridges this gap by serving most accesses from fast SRAM at 1–10 cycle latency.

```
Register file       :  0 cycles   (within processor)
L1 cache            :  4 cycles   ~32–64 KB
L2 cache            : 12 cycles   ~256 KB – 1 MB
L3 cache            : 40 cycles   ~4 MB – 64 MB
DRAM                : 200+ cycles
```

[Inference: cycle counts are representative of modern desktop-class processors; exact values vary by microarchitecture and are not guaranteed.]

---

### Locality of Reference

Cache effectiveness rests entirely on two empirically observed properties of real programs:

#### Temporal Locality

A memory location accessed now is likely to be accessed again soon. Loop variables, frequently called functions, and hot data structures all exhibit temporal locality.

```c
// sum is accessed in every iteration — high temporal locality
for (int i = 0; i < N; i++)
    sum += a[i];
```

#### Spatial Locality

If a memory location is accessed, nearby locations are likely to be accessed soon. Array traversal, sequential instruction execution, and struct field access all exhibit spatial locality.

```c
// a[0], a[1], a[2], ... accessed sequentially — high spatial locality
for (int i = 0; i < N; i++)
    sum += a[i];
```

The cache exploits both: temporal locality justifies keeping recently used data in cache; spatial locality justifies fetching data in **blocks** (cache lines) rather than individual bytes.

---

### Cache Line (Block)

The unit of transfer between cache and memory is a **cache line** (also called a cache block), not a byte. A cache line is typically 64 bytes in modern processors.

When a requested address is not in cache (a **miss**), the entire 64-byte block containing that address is fetched from memory and placed into a cache line. Subsequent accesses to other addresses within that block hit in the cache — this is spatial locality being exploited.

<svg viewBox="0 0 640 160" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <defs> <marker id="arr" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#888"/> </marker> </defs> <!-- Memory row --> <text x="20" y="38" fill="#aaa">Memory:</text> <rect x="80" y="20" width="40" height="28" rx="2" fill="none" stroke="#555" stroke-width="1"/> <rect x="120" y="20" width="40" height="28" rx="2" fill="none" stroke="#555" stroke-width="1"/> <rect x="160" y="20" width="40" height="28" rx="2" fill="none" stroke="#fa7" stroke-width="1.5"/> <rect x="200" y="20" width="40" height="28" rx="2" fill="none" stroke="#fa7" stroke-width="1.5"/> <rect x="240" y="20" width="40" height="28" rx="2" fill="none" stroke="#fa7" stroke-width="1.5"/> <rect x="280" y="20" width="40" height="28" rx="2" fill="none" stroke="#fa7" stroke-width="1.5"/> <rect x="320" y="20" width="40" height="28" rx="2" fill="none" stroke="#555" stroke-width="1"/> <rect x="360" y="20" width="40" height="28" rx="2" fill="none" stroke="#555" stroke-width="1"/> <!-- Byte addresses --> <text x="100" y="39" text-anchor="middle" fill="#555">...</text> <text x="140" y="39" text-anchor="middle" fill="#555">...</text> <text x="180" y="39" text-anchor="middle" fill="#fa7">B0</text> <text x="220" y="39" text-anchor="middle" fill="#fa7">B1</text> <text x="260" y="39" text-anchor="middle" fill="#fa7">B2</text> <text x="300" y="39" text-anchor="middle" fill="#fa7">B3</text> <text x="340" y="39" text-anchor="middle" fill="#555">...</text> <text x="380" y="39" text-anchor="middle" fill="#555">...</text> <!-- Cache line brace --> <line x1="160" y1="54" x2="320" y2="54" stroke="#fa7" stroke-width="1.2"/> <line x1="160" y1="50" x2="160" y2="58" stroke="#fa7" stroke-width="1.2"/> <line x1="320" y1="50" x2="320" y2="58" stroke="#fa7" stroke-width="1.2"/> <text x="240" y="68" text-anchor="middle" fill="#fa7">one cache line (e.g., 64 bytes)</text> <!-- Cache line in cache -->

<text x="20" y="115" fill="#aaa">Cache:</text> <rect x="80" y="98" width="160" height="28" rx="2" fill="none" stroke="#8f8" stroke-width="1.5"/> <text x="160" y="117" text-anchor="middle" fill="#8f8">fetched line: B0 B1 B2 B3 ...</text>

<!-- Arrow from memory to cache --> <line x1="240" y1="70" x2="160" y2="96" stroke="#888" stroke-width="1.2" marker-end="url(#arr)"/> <text x="225" y="88" fill="#aaa" font-size="10">on miss</text> </svg>

---

### Cache Lookup Mechanism

Every cache access requires answering: _is the requested address currently in the cache, and if so, where?_

A memory address is divided into three fields:

```
| Tag | Index | Block Offset |
```

|Field|Width|Purpose|
|---|---|---|
|**Block Offset**|log₂(line_size) bits|Byte position within the cache line|
|**Index**|log₂(sets) bits|Selects which cache set to examine|
|**Tag**|remaining bits|Compared against stored tags to confirm identity|

**Example:** 32-bit address, 64-byte lines, 256 sets (direct-mapped)

```
Block offset : log₂(64) = 6 bits   [5:0]
Index        : log₂(256) = 8 bits  [13:6]
Tag          : 32 − 6 − 8 = 18 bits [31:14]
```

---

### Cache Hit and Miss

**Hit:** The addressed line is in the cache. The tag stored in the indexed set matches the tag from the address, and the valid bit is set. Data is returned from the cache.

**Miss:** Either no valid line occupies the index, or the stored tag does not match. The line must be fetched from the next level of the hierarchy.

**Hit rate and Miss rate:**

```
Hit rate  = hits / total accesses
Miss rate = misses / total accesses = 1 − hit rate
```

**Average Memory Access Time (AMAT):**

```
AMAT = Hit_time + Miss_rate × Miss_penalty
```

For a two-level hierarchy:

```
AMAT = L1_hit_time + L1_miss_rate × (L2_hit_time + L2_miss_rate × Mem_latency)
```

This formula is central to evaluating cache design choices.

---

### Cache Organization

#### Direct-Mapped Cache

Each memory address maps to exactly one cache line slot (one set with one way). The index field selects the slot; the tag field confirms the identity.

<svg viewBox="0 0 580 240" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <defs> <marker id="arr2" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#888"/> </marker> </defs> <!-- Address breakdown --> <rect x="20" y="20" width="120" height="28" rx="2" fill="none" stroke="#fa7" stroke-width="1.5"/> <text x="80" y="39" text-anchor="middle" fill="#fa7">Tag</text> <rect x="140" y="20" width="80" height="28" rx="2" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="180" y="39" text-anchor="middle" fill="#7af">Index</text> <rect x="220" y="20" width="80" height="28" rx="2" fill="none" stroke="#8f8" stroke-width="1.5"/> <text x="260" y="39" text-anchor="middle" fill="#8f8">Offset</text> <!-- Cache array -->

<text x="380" y="18" text-anchor="middle" fill="#aaa">Cache (direct-mapped)</text>

<!-- Rows --> <rect x="300" y="25" width="60" height="22" rx="2" fill="none" stroke="#555" stroke-width="1"/> <rect x="360" y="25" width="120" height="22" rx="2" fill="none" stroke="#555" stroke-width="1"/> <text x="330" y="40" text-anchor="middle" fill="#aaa">V Tag</text> <text x="420" y="40" text-anchor="middle" fill="#aaa">Data (line)</text> <rect x="300" y="47" width="60" height="22" rx="2" fill="none" stroke="#888" stroke-width="1"/> <rect x="360" y="47" width="120" height="22" rx="2" fill="none" stroke="#888" stroke-width="1"/> <text x="330" y="62" text-anchor="middle" fill="#ccc">1 0x2A</text> <text x="420" y="62" text-anchor="middle" fill="#ccc">data...</text> <rect x="300" y="69" width="60" height="22" rx="2" fill="none" stroke="#888" stroke-width="1"/> <rect x="360" y="69" width="120" height="22" rx="2" fill="none" stroke="#888" stroke-width="1"/> <text x="330" y="84" text-anchor="middle" fill="#ccc">0 ----</text> <text x="420" y="84" text-anchor="middle" fill="#555">invalid</text> <rect x="300" y="91" width="60" height="22" rx="2" fill="none" stroke="#888" stroke-width="1"/> <rect x="360" y="91" width="120" height="22" rx="2" fill="none" stroke="#888" stroke-width="1"/> <text x="330" y="106" text-anchor="middle" fill="#ccc">1 0x11</text> <text x="420" y="106" text-anchor="middle" fill="#ccc">data...</text>

<text x="430" y="128" fill="#555">... (N sets total)</text>

<!-- Index arrow --> <line x1="180" y1="48" x2="300" y2="70" stroke="#7af" stroke-width="1.2" marker-end="url(#arr2)"/> <text x="230" y="68" fill="#7af" font-size="10">selects row</text> <!-- Tag compare --> <line x1="80" y1="48" x2="310" y2="70" stroke="#fa7" stroke-width="1.2" stroke-dasharray="4,2"/> <text x="160" y="92" fill="#fa7" font-size="10">tag compare</text> </svg>

**Advantage:** Simple, fast — one tag comparison per access. **Disadvantage:** **Conflict misses** — two addresses that map to the same index evict each other repeatedly, even if the cache has many free slots.

**Example of conflict miss:**

```
Cache: 4 sets, line size 4 bytes
Address A = 0x00   → index 0
Address B = 0x10   → index 0  (same set)

Access: A, B, A, B, A, B ...
Every access misses — cache is 0% effective despite having 3 unused sets.
```

#### Set-Associative Cache

Each index maps to a **set** containing _k_ ways (slots). Any of the _k_ ways within the selected set can hold the line. Tag comparison is performed against all _k_ ways simultaneously.

<svg viewBox="0 0 600 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <defs> <marker id="arr3" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#888"/> </marker> </defs> <!-- Set label --> <text x="20" y="55" fill="#7af">Set 0</text> <text x="20" y="95" fill="#7af">Set 1</text> <text x="20" y="135" fill="#7af">Set 2</text> <text x="20" y="175" fill="#7af">...</text> <!-- Way headers -->

<text x="130" y="25" text-anchor="middle" fill="#aaa">Way 0</text> <text x="250" y="25" text-anchor="middle" fill="#aaa">Way 1</text> <text x="370" y="25" text-anchor="middle" fill="#aaa">Way 2</text> <text x="490" y="25" text-anchor="middle" fill="#aaa">Way 3</text>

<!-- Set 0 --> <rect x="70" y="35" width="120" height="28" rx="2" fill="none" stroke="#888" stroke-width="1"/> <text x="130" y="54" text-anchor="middle" fill="#ccc">V=1 Tag=0x3F data</text> <rect x="195" y="35" width="120" height="28" rx="2" fill="none" stroke="#888" stroke-width="1"/> <text x="255" y="54" text-anchor="middle" fill="#ccc">V=1 Tag=0x12 data</text> <rect x="320" y="35" width="120" height="28" rx="2" fill="none" stroke="#888" stroke-width="1"/> <text x="380" y="54" text-anchor="middle" fill="#ccc">V=0 --- ---</text> <rect x="445" y="35" width="120" height="28" rx="2" fill="none" stroke="#888" stroke-width="1"/> <text x="505" y="54" text-anchor="middle" fill="#ccc">V=1 Tag=0x7A data</text> <!-- Set 1 --> <rect x="70" y="75" width="120" height="28" rx="2" fill="none" stroke="#888" stroke-width="1"/> <text x="130" y="94" text-anchor="middle" fill="#ccc">V=1 Tag=0x01 data</text> <rect x="195" y="75" width="120" height="28" rx="2" fill="none" stroke="#888" stroke-width="1"/> <text x="255" y="94" text-anchor="middle" fill="#ccc">V=0 --- ---</text> <rect x="320" y="75" width="120" height="28" rx="2" fill="none" stroke="#888" stroke-width="1"/> <text x="380" y="94" text-anchor="middle" fill="#ccc">V=1 Tag=0x55 data</text> <rect x="445" y="75" width="120" height="28" rx="2" fill="none" stroke="#888" stroke-width="1"/> <text x="505" y="94" text-anchor="middle" fill="#ccc">V=1 Tag=0x22 data</text> <!-- Set 2 --> <rect x="70" y="115" width="120" height="28" rx="2" fill="none" stroke="#888" stroke-width="1"/> <text x="130" y="134" text-anchor="middle" fill="#555">...</text> <rect x="195" y="115" width="120" height="28" rx="2" fill="none" stroke="#888" stroke-width="1"/> <text x="255" y="134" text-anchor="middle" fill="#555">...</text> <rect x="320" y="115" width="120" height="28" rx="2" fill="none" stroke="#888" stroke-width="1"/> <text x="380" y="134" text-anchor="middle" fill="#555">...</text> <rect x="445" y="115" width="120" height="28" rx="2" fill="none" stroke="#888" stroke-width="1"/> <text x="505" y="134" text-anchor="middle" fill="#555">...</text>

<text x="300" y="185" text-anchor="middle" fill="#aaa">4-way set-associative: 4 tag comparisons per access, done in parallel</text> </svg>

A _k_-way set-associative cache with _S_ sets holds _k × S_ lines total. The index selects the set; all _k_ tags are compared in parallel; the matching way (if any) provides the data.

#### Fully Associative Cache

A line can reside in any slot — no index field. The entire tag is compared against all cache entries simultaneously. This eliminates conflict misses entirely but requires _N_ comparators for an _N_-line cache — practical only for small structures like TLBs.

---

### Mapping Summary

|Organization|Sets|Ways|Conflict Misses|Hardware Cost|
|---|---|---|---|---|
|Direct-mapped|N|1|Highest|Lowest|
|_k_-way set-assoc|N/k|k|Moderate|Moderate|
|Fully associative|1|N|None|Highest|

Increasing associativity reduces conflict misses with diminishing returns beyond 8 ways for most workloads. Most L1 caches are 4- or 8-way; L2 and L3 caches are 8- to 16-way or higher.

---

### Valid and Dirty Bits

Each cache line slot stores metadata alongside the tag and data:

|Bit|Purpose|
|---|---|
|**Valid bit**|Indicates whether this slot contains meaningful data (cleared on reset)|
|**Dirty bit**|Indicates whether the line has been written since it was fetched (used only with write-back policy)|

On reset, all valid bits are cleared. The first access to any address will miss regardless of the tag stored in the slot.

---

### Miss Classification — The 3 Cs

|Miss Type|Cause|Reduction Strategy|
|---|---|---|
|**Compulsory (Cold)**|First access to a line — never been in cache|Prefetching, larger line size|
|**Capacity**|Cache too small to hold the working set|Larger cache|
|**Conflict**|Two addresses map to the same set and evict each other|Higher associativity|

A fourth category, **coherence misses**, arises in multiprocessor systems where a line is invalidated by another core's write.

---

### Replacement Policies

When a miss occurs in a set that is full (_k_ valid lines in a _k_-way set), one line must be evicted. Common policies:

#### Least Recently Used (LRU)

Evicts the line accessed least recently. Optimal for typical workloads with temporal locality. Requires tracking access order — exact LRU for _k_ ways needs log₂(k!) bits of state per set.

For a 4-way set, exact LRU requires tracking a permutation of 4 elements — 4.58 bits. In practice, **pseudo-LRU** approximations (tree-PLRU, bit-PLRU) are used.

**Tree-PLRU for 4 ways:**

<svg viewBox="0 0 340 160" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <defs> <marker id="arr4" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#888"/> </marker> </defs> <!-- Root bit --> <circle cx="170" cy="35" r="18" fill="none" stroke="#fa7" stroke-width="1.5"/> <text x="170" y="40" text-anchor="middle" fill="#fa7">b0</text> <!-- Level 2 bits --> <circle cx="90" cy="95" r="18" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="90" y="100" text-anchor="middle" fill="#7af">b1</text> <circle cx="250" cy="95" r="18" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="250" y="100" text-anchor="middle" fill="#7af">b2</text> <!-- Ways --> <rect x="30" y="138" width="40" height="22" rx="2" fill="none" stroke="#8f8" stroke-width="1.2"/> <text x="50" y="153" text-anchor="middle" fill="#8f8">W0</text> <rect x="110" y="138" width="40" height="22" rx="2" fill="none" stroke="#8f8" stroke-width="1.2"/> <text x="130" y="153" text-anchor="middle" fill="#8f8">W1</text> <rect x="190" y="138" width="40" height="22" rx="2" fill="none" stroke="#8f8" stroke-width="1.2"/> <text x="210" y="153" text-anchor="middle" fill="#8f8">W2</text> <rect x="270" y="138" width="40" height="22" rx="2" fill="none" stroke="#8f8" stroke-width="1.2"/> <text x="290" y="153" text-anchor="middle" fill="#8f8">W3</text> <!-- Edges --> <line x1="155" y1="50" x2="105" y2="78" stroke="#888" stroke-width="1.2"/> <line x1="185" y1="50" x2="235" y2="78" stroke="#888" stroke-width="1.2"/> <line x1="75" y1="110" x2="55" y2="136" stroke="#888" stroke-width="1.2"/> <line x1="105" y1="110" x2="125" y2="136" stroke="#888" stroke-width="1.2"/> <line x1="235" y1="110" x2="215" y2="136" stroke="#888" stroke-width="1.2"/> <line x1="265" y1="110" x2="285" y2="136" stroke="#888" stroke-width="1.2"/> <!-- Edge labels --> <text x="126" y="68" fill="#aaa" font-size="10">0=left</text> <text x="196" y="68" fill="#aaa" font-size="10">1=right</text> </svg>

3 bits track the pseudo-LRU state for a 4-way set. The bit at each node points toward the MRU subtree; the victim is found by traversing toward the LRU subtree (the opposite direction at each node).

#### Random Replacement

Selects a victim randomly. Simpler hardware than LRU. Performance is comparable to LRU for large caches; worse for small caches or adversarial access patterns.

#### FIFO (First In, First Out)

Evicts the line that has been in the cache the longest. Simple to implement. Susceptible to **Bélády's anomaly** — adding more cache capacity can increase misses for certain access sequences.

#### Not Most Recently Used (NMRU)

A simplified approximation: protect the most recently used line from eviction; select randomly among the remaining ways. Cheaper than LRU, better than pure random.

---

### Write Policies

Two decisions must be made when a store instruction executes:

#### Write-Hit Policy

**Write-through:** The write updates both the cache line and main memory simultaneously. Memory is always consistent with the cache. Write traffic to memory is high — every store causes a memory write. A **write buffer** is typically added to queue memory writes and avoid stalling the processor.

**Write-back:** The write updates only the cache line. The dirty bit is set. Memory is updated only when the line is evicted. Write traffic to memory is reduced. The complexity is that at any time, memory may hold stale data — coherence protocols must account for this.

#### Write-Miss Policy

**Write-allocate (fetch-on-write):** On a write miss, the line is first fetched from memory into the cache, then the write is performed. Anticipates future reads to the same line. Typically paired with write-back.

**No-write-allocate (write-around):** On a write miss, the data is written directly to memory without bringing the line into the cache. Avoids polluting the cache with lines that may not be read again. Typically paired with write-through.

Common combinations:

|Write-Hit|Write-Miss|Typical Use|
|---|---|---|
|Write-back|Write-allocate|L1, L2, L3 in most processors|
|Write-through|No-write-allocate|Some L1 designs; I/O coherence|

---

### Cache Size, Line Size, and Associativity Trade-offs

#### Cache Size

Larger caches reduce capacity misses but increase hit latency (larger SRAMs are slower) and consume more power and area.

#### Line Size

Larger lines exploit spatial locality more aggressively but carry costs:

- **Miss penalty increases** — more data must be transferred on a miss
- **Internal fragmentation** — a large line may bring in data never accessed
- **Pollution** — spatial locality is poor for some access patterns (e.g., pointer-chasing linked lists)

Typical line sizes: 32–128 bytes. Most modern processors use 64 bytes.

#### Associativity

Higher associativity reduces conflict misses. Returns diminish beyond 8 ways for most workloads. Each added way adds a tag comparator and increases set access time.

**The 2:1 cache rule of thumb** [Inference — widely cited but workload-dependent]: a direct-mapped cache of size _2N_ has approximately the same miss rate as a 2-way set-associative cache of size _N_.

---

### AMAT Example

**Given:**

- L1 hit time: 4 cycles, miss rate: 5%
- L2 hit time: 12 cycles, miss rate: 30%
- Memory latency: 200 cycles

```
AMAT = 4 + 0.05 × (12 + 0.30 × 200)
     = 4 + 0.05 × (12 + 60)
     = 4 + 0.05 × 72
     = 4 + 3.6
     = 7.6 cycles
```

Reducing the L1 miss rate from 5% to 3% (e.g., by increasing associativity):

```
AMAT = 4 + 0.03 × 72 = 4 + 2.16 = 6.16 cycles
```

A 2% improvement in L1 miss rate yields a 19% reduction in AMAT — illustrating why L1 miss rate is disproportionately important.

---

### Instruction vs. Data Caches

Most processors use **split L1 caches** — a separate L1 instruction cache (I-cache) and L1 data cache (D-cache):

- Instructions are read-only, eliminating write complexity in the I-cache
- Instruction and data accesses can proceed simultaneously without structural conflict
- Working sets of instructions and data have different locality characteristics

The L2 and L3 caches are typically **unified** — they hold both instructions and data.

---

### Critical Word First and Early Restart

On a cache miss, the processor stalls waiting for the missed line to be fetched. Two optimizations reduce this stall:

**Critical word first:** The specific word within the line that caused the miss is transferred first, before the rest of the line. The processor can resume as soon as the critical word arrives, while the remainder of the line is fetched in the background.

**Early restart:** The processor resumes as soon as the critical word arrives, regardless of fill order. The line continues filling in the background.

Both techniques reduce the effective miss penalty without altering the cache structure.

---

### Non-Blocking Caches

A **blocking cache** stalls all subsequent accesses when a miss is in progress. A **non-blocking cache** (also called lockup-free) allows subsequent accesses to proceed while a miss is being serviced — hitting in the cache or even generating additional outstanding misses.

**Miss Status Holding Registers (MSHRs)** track outstanding misses. A cache that supports _k_ simultaneous outstanding misses is said to support **k outstanding misses** or **miss under miss** operation. This is essential for out-of-order processors, which may generate several independent load misses before the first resolves.

---

**Key Points**

- Caches exploit temporal and spatial locality to serve most memory accesses at low latency; their effectiveness is entirely dependent on program behavior.
- The cache line is the unit of transfer; its size determines how aggressively spatial locality is captured.
- Address decomposition into tag, index, and offset fields is the mechanism by which the hardware locates data and confirms identity.
- AMAT = hit time + miss rate × miss penalty; reducing miss rate at L1 has outsized effect because all misses pay the full downstream penalty.
- The 3 Cs (compulsory, capacity, conflict) classify misses by cause and point directly to the appropriate design countermeasure.
- Direct-mapped caches suffer conflict misses; full associativity eliminates them at prohibitive hardware cost; set-associativity is the practical compromise.
- Write-back with write-allocate is the dominant policy for on-chip caches; write-through is reserved for specific coherence or simplicity requirements.
- Non-blocking caches with MSHR support are necessary for out-of-order processors to tolerate memory latency without serializing independent loads.

**Conclusion** Cache design is a multi-dimensional optimization over size, associativity, line size, replacement policy, and write policy, all evaluated through the lens of AMAT and the 3 Cs miss classification. Every design choice involves a trade-off between miss rate, hit latency, hardware complexity, power, and area. These fundamentals underpin every topic in the memory hierarchy — multi-level caches, cache coherence, virtual memory, and prefetching all build directly on the mechanisms established here.

**Next Steps**

- Cache Mapping (direct, set-associative, fully associative) — deeper quantitative treatment of index/tag sizing, conflict miss analysis, and working set behavior
- Replacement Policies — formal analysis of LRU, RRIP, and adaptive policies under different access patterns
- Write Policies — write buffers, write-combining, and store queue design
- Multi-level Caches — inclusive, exclusive, and NINE (non-inclusive non-exclusive) hierarchies
- Cache Coherence (MSI, MESI, MOESI) — maintaining consistency across multiple L1 caches in a multicore system

---

