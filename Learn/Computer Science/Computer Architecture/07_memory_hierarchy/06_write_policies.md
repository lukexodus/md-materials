## Write Policies


---

### The Write Problem

Every store instruction raises a fundamental question: when a processor writes data, where does the write go, and what happens to other levels of the memory hierarchy that hold copies of the same address?

A cache write involves two independent decisions:

- **On a write hit** — the address being written is present in the cache — does the write update only the cache, or does it propagate immediately to the next level?
- **On a write miss** — the address being written is absent from the cache — does the cache allocate a line for the written data, or does the write bypass the cache entirely?

These two decisions are orthogonal and combine into the policies examined here. They interact with cache coherence, memory bandwidth, and the complexity of the memory controller.

---

### Write-Through

On every write hit, the data is written simultaneously to the cache line **and** to the next level of the hierarchy (the next cache level or main memory). The cache and the backing store are always consistent — at any moment, the value in memory reflects the most recently written value.

<svg viewBox="0 0 640 260" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <!-- CPU --> <rect x="0" y="100" width="80" height="50" rx="4" fill="#d0e8ff" stroke="#336" stroke-width="1.5"/> <text x="40" y="130" text-anchor="middle" fill="#222">CPU</text> <!-- Cache --> <rect x="160" y="80" width="120" height="90" rx="4" fill="#d0ffd6" stroke="#336" stroke-width="1.5"/> <text x="220" y="105" text-anchor="middle" fill="#222" font-weight="bold">Cache</text> <text x="220" y="122" text-anchor="middle" fill="#555" font-size="10">addr 0x100:</text> <text x="220" y="137" text-anchor="middle" fill="#c60" font-size="10">0xABCD ← write</text> <text x="220" y="152" text-anchor="middle" fill="#555" font-size="10">clean (always)</text> <!-- Memory --> <rect x="420" y="80" width="120" height="90" rx="4" fill="#ffd6d6" stroke="#336" stroke-width="1.5"/> <text x="480" y="105" text-anchor="middle" fill="#222" font-weight="bold">Memory</text> <text x="480" y="122" text-anchor="middle" fill="#555" font-size="10">addr 0x100:</text> <text x="480" y="137" text-anchor="middle" fill="#c60" font-size="10">0xABCD ← also written</text> <text x="480" y="152" text-anchor="middle" fill="#555" font-size="10">always consistent</text> <!-- CPU to cache --> <line x1="80" y1="125" x2="160" y2="125" stroke="#336" stroke-width="2" marker-end="url(#wa)"/> <text x="120" y="118" text-anchor="middle" fill="#336" font-size="10">write</text> <!-- Cache to memory: write-through --> <line x1="280" y1="115" x2="420" y2="115" stroke="#c60" stroke-width="2" marker-end="url(#wb)"/> <text x="350" y="108" text-anchor="middle" fill="#c60" font-size="10">write-through</text> <text x="350" y="120" text-anchor="middle" fill="#c60" font-size="10">(every hit)</text> <!-- Write buffer --> <rect x="160" y="200" width="380" height="36" rx="4" fill="#fff5cc" stroke="#c60" stroke-width="1.5" stroke-dasharray="5,2"/> <text x="350" y="222" text-anchor="middle" fill="#c60">Write Buffer (optional): absorbs write-through traffic</text> <defs> <marker id="wa" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#336"/> </marker> <marker id="wb" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#c60"/> </marker> </defs> </svg>

**Properties:**

- Cache lines are always **clean** — there is no distinction between a modified and unmodified line in the cache; every line's content matches memory
- On a cache **eviction**, the line can be silently discarded — no writeback is needed because memory is already up to date
- Every write generates a memory bus transaction, regardless of how frequently the same address is written — write-heavy workloads produce high memory bandwidth consumption
- Memory always holds the authoritative value — a direct memory access (DMA) or another processor reading from memory sees consistent data without cache intervention

**Write buffer:** To decouple the CPU from the latency of each write-through transaction, a **write buffer** (a small FIFO queue, typically 4–16 entries) sits between the cache and memory. The CPU writes into the write buffer and continues; the write buffer drains to memory independently. This hides write latency as long as the buffer does not fill faster than it drains. If it fills, the CPU stalls waiting for a buffer slot — a **write buffer stall**.

**Write-through is used when:**

- Cache coherence is needed without a coherence protocol — memory is always authoritative, so external agents can always read from memory
- The cache is small and simple (L1 I-cache in many designs, embedded system caches)
- Write traffic is low relative to read traffic

---

### Write-Back

On a write hit, the data is written **only to the cache line**. The line is marked **dirty** — a flag bit (the dirty bit, also called the modified bit) stored with the cache tag indicates that the cache holds a value newer than memory. The write to the next level is **deferred** until the dirty line must be evicted to make room for a new allocation.

<svg viewBox="0 0 680 300" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <!-- CPU --> <rect x="0" y="110" width="80" height="50" rx="4" fill="#d0e8ff" stroke="#336" stroke-width="1.5"/> <text x="40" y="140" text-anchor="middle" fill="#222">CPU</text> <!-- Cache with dirty bit --> <rect x="150" y="80" width="150" height="120" rx="4" fill="#d0ffd6" stroke="#336" stroke-width="1.5"/> <text x="225" y="105" text-anchor="middle" fill="#222" font-weight="bold">Cache</text> <rect x="162" y="112" width="16" height="16" rx="2" fill="#c60" stroke="#900" stroke-width="1.2"/> <text x="170" y="124" text-anchor="middle" fill="#fff" font-size="9">D</text> <text x="235" y="124" text-anchor="middle" fill="#555" font-size="10">addr 0x100</text> <text x="225" y="140" text-anchor="middle" fill="#c60" font-size="10">0xABCD dirty=1</text> <text x="225" y="158" text-anchor="middle" fill="#555" font-size="10">write stays here</text> <text x="225" y="175" text-anchor="middle" fill="#555" font-size="10">until eviction</text> <!-- Memory --> <rect x="440" y="80" width="150" height="120" rx="4" fill="#ffd6d6" stroke="#336" stroke-width="1.5"/> <text x="515" y="105" text-anchor="middle" fill="#222" font-weight="bold">Memory</text> <text x="515" y="130" text-anchor="middle" fill="#555" font-size="10">addr 0x100:</text> <text x="515" y="147" text-anchor="middle" fill="#900" font-size="10">0x1234 ← stale</text> <text x="515" y="164" text-anchor="middle" fill="#555" font-size="10">(not yet updated)</text> <!-- CPU to cache write --> <line x1="80" y1="135" x2="150" y2="135" stroke="#336" stroke-width="2" marker-end="url(#wba)"/> <text x="115" y="128" text-anchor="middle" fill="#336" font-size="10">write</text> <!-- No immediate write to memory (blocked arrow) --> <line x1="300" y1="130" x2="420" y2="130" stroke="#aaa" stroke-width="1.5" stroke-dasharray="5,3"/> <text x="360" y="122" text-anchor="middle" fill="#aaa" font-size="10">no write now</text> <!-- Eviction writeback arrow --> <line x1="300" y1="160" x2="440" y2="160" stroke="#c60" stroke-width="2" marker-end="url(#wbb)"/> <text x="370" y="152" text-anchor="middle" fill="#c60" font-size="10">writeback on eviction</text> <!-- Dirty bit legend --> <rect x="150" y="230" width="16" height="16" rx="2" fill="#c60" stroke="#900" stroke-width="1.2"/> <text x="158" y="242" text-anchor="middle" fill="#fff" font-size="9">D</text> <text x="200" y="242" fill="#555" font-size="11">= dirty bit: line modified, not yet in memory</text> <defs> <marker id="wba" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#336"/> </marker> <marker id="wbb" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#c60"/> </marker> </defs> </svg>

**Eviction of a dirty line:**

When the cache must evict a dirty line (to allocate space for a new line), it must first write the dirty line's data back to memory before overwriting it. This is a **writeback** transaction — it uses memory bandwidth only when the line is actually dirty and actually evicted. If a line is written many times between allocations, all those writes are absorbed by the cache and only one memory transaction occurs.

**Properties:**

- Cache lines carry a **dirty bit** per line (sometimes per word in sub-blocking schemes)
- Write-back absorbs repeated writes to the same line — the memory bandwidth consumed is proportional to the number of dirty evictions, not the number of writes
- Memory may hold **stale data** — external agents (DMA, other processors) cannot read from memory and expect a current value without cache intervention
- Eviction latency is non-uniform: clean evictions are free; dirty evictions require a writeback before the new line can be loaded, potentially stalling the pipeline
- Cache coherence protocols are required in multiprocessor systems — the dirty state must be tracked and communicated

**Dirty bit overhead:** A 32-byte cache line with a 1-bit dirty flag adds 1/256 = 0.4% storage overhead. With sub-blocking (tracking dirty state at finer granularity, e.g., per 8-byte word), partial writes can be tracked more precisely — useful when only one word in a line is written and the rest need not be fetched on a miss.

**Write-back is used when:**

- Write bandwidth reduction is important — the common case in L2, L3, and LLC in virtually all modern processors
- Write-intensive workloads dominate — databases, streaming writes, memcpy-class operations
- The complexity of tracking dirty state and maintaining coherence is acceptable

---

### Write-Through vs. Write-Back: Quantitative Comparison

Let W be the write rate (writes per cycle), H be the write hit rate, and B be the memory bus bandwidth:

**Write-through bandwidth consumption:**

```
BW_write_through = W × line_size   (every write, hit or miss, goes to memory)
```

**Write-back bandwidth consumption:**

```
BW_write_back = eviction_rate × dirty_fraction × line_size
```

For a workload with high temporal locality on writes — the same cache line written many times before eviction — the dirty fraction approaches 1 but the eviction rate is far lower than the write rate. Write-back can reduce memory write bandwidth by an order of magnitude or more relative to write-through for such workloads.

**Example:**

Suppose a loop writes to the same 64-byte cache line 1000 times before the line is evicted. Write-through generates 1000 × 64 = 64,000 bytes of memory traffic. Write-back generates 1 × 64 = 64 bytes of memory traffic (one writeback on eviction). The ratio is 1000:1.

---

### Write-Allocate (Fetch on Write)

Write-allocate is the policy governing **write misses** — what happens when a store targets an address not currently in the cache.

Under **write-allocate**, a write miss triggers a **line fetch**: the full cache line containing the target address is loaded from the next memory level into the cache. The write is then applied to the cached copy. Subsequent writes or reads to the same line hit in the cache.

<svg viewBox="0 0 680 230" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <!-- Miss detection --> <rect x="0" y="80" width="110" height="50" rx="4" fill="#ffd6d6" stroke="#c60" stroke-width="1.5"/> <text x="55" y="101" text-anchor="middle" fill="#222">Write Miss</text> <text x="55" y="116" text-anchor="middle" fill="#555" font-size="10">addr not in cache</text> <!-- Fetch line from memory --> <rect x="200" y="60" width="130" height="90" rx="4" fill="#d0e8ff" stroke="#336" stroke-width="1.5"/> <text x="265" y="85" text-anchor="middle" fill="#222" font-weight="bold">Fetch Line</text> <text x="265" y="102" text-anchor="middle" fill="#555" font-size="10">load full cache line</text> <text x="265" y="116" text-anchor="middle" fill="#555" font-size="10">from next level</text> <text x="265" y="130" text-anchor="middle" fill="#555" font-size="10">into cache</text> <!-- Apply write --> <rect x="420" y="60" width="130" height="90" rx="4" fill="#d0ffd6" stroke="#336" stroke-width="1.5"/> <text x="485" y="85" text-anchor="middle" fill="#222" font-weight="bold">Apply Write</text> <text x="485" y="102" text-anchor="middle" fill="#555" font-size="10">modify cached copy</text> <text x="485" y="116" text-anchor="middle" fill="#c60" font-size="10">dirty=1 (write-back)</text> <text x="485" y="130" text-anchor="middle" fill="#555" font-size="10">or write-through</text> <!-- Future hits --> <rect x="200" y="180" width="350" height="30" rx="4" fill="#fff5cc" stroke="#c60" stroke-width="1.2" stroke-dasharray="4,2"/> <text x="375" y="200" text-anchor="middle" fill="#c60" font-size="10">subsequent reads/writes to same line → cache hit</text> <!-- Arrows --> <line x1="110" y1="105" x2="200" y2="105" stroke="#c60" stroke-width="2" marker-end="url(#wca)"/> <line x1="330" y1="105" x2="420" y2="105" stroke="#336" stroke-width="2" marker-end="url(#wcb)"/> <line x1="485" y1="150" x2="375" y2="180" stroke="#c60" stroke-width="1.2" stroke-dasharray="4,2" marker-end="url(#wca)"/> <defs> <marker id="wca" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#c60"/> </marker> <marker id="wcb" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#336"/> </marker> </defs> </svg>

**Rationale:** If a store is issued to an address, there is a high probability (by spatial and temporal locality) that the surrounding data in the same cache line will be read or written soon. Fetching the full line on a write miss exploits this locality. Without the fetch, future reads to nearby addresses in the same line would also miss.

**Cost:** The fetch itself takes the full line load latency from the next memory level. For a write miss where only 4 bytes of a 64-byte line are written, 60 bytes of data are loaded from memory and immediately overwritten — wasted bandwidth if those 60 bytes are never read.

**Write-allocate is almost always paired with write-back.** The reasoning: if the line is fetched into the cache on a write miss, it makes sense to keep future writes in the cache (write-back) rather than sending each one through to memory (write-through), since the line is now resident.

---

### No-Write-Allocate (Write-Around)

Under **no-write-allocate** (also called **write-around**), a write miss does not fetch the line into the cache. The write goes directly to the next level of the hierarchy, bypassing the cache.

<svg viewBox="0 0 640 180" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <!-- Miss --> <rect x="0" y="70" width="110" height="50" rx="4" fill="#ffd6d6" stroke="#c60" stroke-width="1.5"/> <text x="55" y="91" text-anchor="middle" fill="#222">Write Miss</text> <text x="55" y="106" text-anchor="middle" fill="#555" font-size="10">addr not in cache</text> <!-- Bypass arrow --> <line x1="110" y1="95" x2="300" y2="95" stroke="#c60" stroke-width="2" marker-end="url(#wda)"/> <text x="205" y="85" text-anchor="middle" fill="#c60" font-size="10">write bypasses cache</text> <!-- Memory --> <rect x="300" y="55" width="140" height="80" rx="4" fill="#ffd6d6" stroke="#336" stroke-width="1.5"/> <text x="370" y="82" text-anchor="middle" fill="#222" font-weight="bold">Next Level</text> <text x="370" y="99" text-anchor="middle" fill="#555" font-size="10">(L2 / Memory)</text> <text x="370" y="116" text-anchor="middle" fill="#c60" font-size="10">write applied here</text> <!-- Cache unchanged --> <rect x="490" y="55" width="130" height="80" rx="4" fill="#e0e0e0" stroke="#aaa" stroke-width="1.5"/> <text x="555" y="82" text-anchor="middle" fill="#aaa" font-weight="bold">Cache</text> <text x="555" y="99" text-anchor="middle" fill="#aaa" font-size="10">unchanged</text> <text x="555" y="116" text-anchor="middle" fill="#aaa" font-size="10">line not allocated</text>

<text x="0" y="160" fill="#555" font-size="11">[Inference] Subsequent reads to same line will miss — used when write locality is low</text>

<defs> <marker id="wda" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#c60"/> </marker> </defs> </svg>

**When no-write-allocate is appropriate:**

- **Streaming writes:** a loop that initializes a large array once and never reads it again — allocating cache lines on every write would pollute the cache without benefit, evicting lines that are actively used by other data
- **Write-through caches:** since every write goes to memory anyway, there is less benefit to caching the written line — the combination write-through + no-write-allocate is consistent in that memory is always current and the cache is not disturbed by write misses
- **Video frame buffer writes, DMA destination buffers:** large contiguous write streams with no re-read

**Non-temporal stores in x86-64:** The `MOVNT` family of instructions (`MOVNTPS`, `MOVNTDQ`, `MOVNTI`) implements software-controlled no-write-allocate. They bypass the cache hierarchy entirely and write directly to memory using write-combining buffers. The programmer explicitly signals that the written data will not be reused soon, preventing cache pollution.

---

### Policy Combinations

The two decisions — hit policy and miss policy — combine into four combinations, two of which are practical:

|Hit policy|Miss policy|Practical?|Typical use|
|---|---|---|---|
|Write-through|No-write-allocate|✓ Common|L1 caches in simple designs, embedded|
|Write-through|Write-allocate|✗ Rare|Inconsistent — line fetched but every write still goes to memory|
|Write-back|Write-allocate|✓ Dominant|L2, L3, LLC in all modern out-of-order processors|
|Write-back|No-write-allocate|✓ Situational|Streaming write paths, non-temporal stores|

The write-through + write-allocate combination is internally inconsistent: fetching a line into the cache on a write miss only to forward every subsequent hit to memory anyway provides the overhead of both policies with the benefit of neither. It is essentially unused in practice.

---

### Multi-Level Cache Write Policy Interactions

In a typical three-level hierarchy (L1, L2, L3/LLC):

<svg viewBox="0 0 720 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <rect x="0" y="60" width="80" height="50" rx="4" fill="#d0e8ff" stroke="#336" stroke-width="1.5"/> <text x="40" y="90" text-anchor="middle" fill="#222">CPU</text> <rect x="120" y="40" width="130" height="90" rx="4" fill="#d0ffd6" stroke="#336" stroke-width="1.5"/> <text x="185" y="65" text-anchor="middle" fill="#222" font-weight="bold">L1 Cache</text> <text x="185" y="82" text-anchor="middle" fill="#555" font-size="10">write-back</text> <text x="185" y="96" text-anchor="middle" fill="#555" font-size="10">write-allocate</text> <text x="185" y="110" text-anchor="middle" fill="#c60" font-size="10">dirty bit per line</text> <rect x="300" y="40" width="130" height="90" rx="4" fill="#fff5cc" stroke="#336" stroke-width="1.5"/> <text x="365" y="65" text-anchor="middle" fill="#222" font-weight="bold">L2 Cache</text> <text x="365" y="82" text-anchor="middle" fill="#555" font-size="10">write-back</text> <text x="365" y="96" text-anchor="middle" fill="#555" font-size="10">write-allocate</text> <text x="365" y="110" text-anchor="middle" fill="#c60" font-size="10">dirty bit per line</text> <rect x="480" y="40" width="130" height="90" rx="4" fill="#ffd6d6" stroke="#336" stroke-width="1.5"/> <text x="545" y="65" text-anchor="middle" fill="#222" font-weight="bold">L3 / LLC</text> <text x="545" y="82" text-anchor="middle" fill="#555" font-size="10">write-back</text> <text x="545" y="96" text-anchor="middle" fill="#555" font-size="10">write-allocate</text> <text x="545" y="110" text-anchor="middle" fill="#c60" font-size="10">dirty bit per line</text> <!-- DRAM --> <rect x="660" y="60" width="60" height="50" rx="4" fill="#e8d0ff" stroke="#336" stroke-width="1.5"/> <text x="690" y="90" text-anchor="middle" fill="#222">DRAM</text> <!-- Arrows --> <line x1="80" y1="85" x2="120" y2="85" stroke="#336" stroke-width="1.5" marker-end="url(#wea)"/> <line x1="250" y1="85" x2="300" y2="85" stroke="#336" stroke-width="1.5" marker-end="url(#wea)"/> <line x1="430" y1="85" x2="480" y2="85" stroke="#336" stroke-width="1.5" marker-end="url(#wea)"/> <line x1="610" y1="85" x2="660" y2="85" stroke="#336" stroke-width="1.5" marker-end="url(#wea)"/> <!-- Writeback arrows (upward) --> <line x1="185" y1="155" x2="365" y2="155" stroke="#c60" stroke-width="1.5" stroke-dasharray="4,2" marker-end="url(#web)"/> <text x="275" y="170" text-anchor="middle" fill="#c60" font-size="10">dirty eviction writebacks</text> <line x1="365" y1="165" x2="545" y2="165" stroke="#c60" stroke-width="1.5" stroke-dasharray="4,2" marker-end="url(#web)"/> <line x1="545" y1="155" x2="690" y2="155" stroke="#c60" stroke-width="1.5" stroke-dasharray="4,2" marker-end="url(#web)"/> <defs> <marker id="wea" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#336"/> </marker> <marker id="web" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#c60"/> </marker> </defs> </svg>

A dirty eviction from L1 propagates to L2, where it may hit an existing L2 line (updating it, marking it dirty) or miss and allocate a new L2 line. A dirty eviction from L2 propagates to L3. A dirty eviction from L3 goes to DRAM — this is the only point at which DRAM is written.

**Inclusive vs. exclusive cache interactions:** In an inclusive hierarchy (L2 contains all lines in L1), an L1 dirty eviction always hits in L2. In an exclusive hierarchy (L1 and L2 hold disjoint sets), an L1 eviction goes to L2 as a new allocation. The write policy interacts with inclusivity — dirty tracking must be consistent across levels.

---

### Write Combining

Write combining (WC) is a mechanism used for write-through or uncached memory regions — typically memory-mapped I/O and frame buffers — where individual word-size writes would generate excessive bus transactions.

A set of **write-combining buffers** (typically 4–12 in modern processors) collect writes to the same cache-line-aligned region. While the buffer is open (subsequent writes to the same line arrive within a timing window), they accumulate. When the buffer is flushed — either because it is full, the line boundary is crossed, a serializing instruction is executed, or the buffer times out — the entire collected write is sent as a single burst transaction.

```
Without WC:  8 × 4-byte writes → 8 bus transactions (32 bytes, 8× overhead)
With WC:     8 × 4-byte writes → 1 bus transaction (32 bytes, coalesced)
```

Write combining is orthogonal to cache write policy — it applies to non-cacheable regions where neither write-through nor write-back in the normal sense applies. The memory type range registers (MTRRs) and page attribute table (PAT) in x86-64 configure per-region memory types including WC.

---

### Write Policy and Cache Coherence

In multiprocessor systems, write policy determines how difficult the coherence problem is:

**Write-through + no-write-allocate:** Memory is always authoritative. A simple snooping protocol can monitor the memory bus — any write seen on the bus causes other caches holding that line to invalidate their copy (write-invalidate). No directory state is needed if the bus is shared.

**Write-back:** Memory may be stale. Coherence requires tracking which cache holds a dirty copy. The MESI protocol adds the **Modified** (M) state specifically for write-back dirty lines — a cache in state M holds the only valid copy of the line; memory is stale. Before another processor can read the line, the M-state cache must first write back its dirty copy, transitioning to S (Shared).

The dirty bit in a write-back cache is the per-line counterpart to the M state in MESI — both indicate that the cache holds data newer than memory.

---

### Write Policy in Practice: Selected Implementations

|Processor|L1D policy|L2 policy|LLC policy|
|---|---|---|---|
|Intel Core (Nehalem onward)|Write-back, write-allocate|Write-back|Write-back|
|AMD Zen series|Write-back, write-allocate|Write-back|Write-back|
|ARM Cortex-A series|Configurable (WT or WB per page)|Write-back|Write-back|
|MIPS embedded cores|Write-through (common default)|—|—|
|GPU L1 caches (NVIDIA)|Write-through to L2 (historically)|Write-back|Write-back|

[Unverified: specific policy configurations for individual processor generations may vary by stepping or platform; the table above reflects publicly documented general tendencies, not guaranteed per-product specifications.]

---

**Key Points**

- Write-through and write-back govern write hits: write-through propagates every write immediately to the next level, keeping memory consistent at the cost of bandwidth; write-back absorbs writes in the cache and defers propagation to eviction, reducing bandwidth at the cost of dirty state complexity.
- Write-allocate and no-write-allocate govern write misses: write-allocate fetches the line on a miss and applies the write to the cached copy, exploiting spatial locality; no-write-allocate sends the write directly to the next level, avoiding cache pollution for streaming write patterns.
- Write-back and write-allocate are almost always paired; write-through and no-write-allocate are almost always paired — the combinations have internal consistency that the cross-pairs lack.
- The dirty bit is the hardware mechanism that makes write-back possible — it distinguishes lines whose cached value is newer than memory from lines that are clean.
- Write combining solves the bandwidth problem for uncached write-through regions by coalescing multiple sub-line writes into a single burst transaction.
- Write-back complicates cache coherence in multiprocessor systems because memory may be stale — coherence protocols such as MESI introduce the Modified state specifically to track and manage dirty write-back lines.

**Next Steps**

Proceed to **Multi-Level Caches** to examine how write policies compose across an L1/L2/L3 hierarchy, including the interactions between inclusive and exclusive configurations and the flow of dirty data through writeback chains. Follow with **Cache Coherence (MSI, MESI, MOESI)** for the full treatment of how write-back dirty state is managed across multiple processors sharing a memory system.

---

