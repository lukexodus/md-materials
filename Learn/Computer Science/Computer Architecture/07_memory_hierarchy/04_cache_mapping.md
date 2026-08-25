## Cache Mapping


Cache mapping defines the rule by which a main memory address is assigned to a location in the cache. It determines which cache line(s) a given memory block may occupy, directly governing hit rate, hardware complexity, and the nature of conflict misses.

---

### Foundational Terminology

A **cache line** (or cache block) is the unit of transfer between cache and main memory — typically 64 bytes on contemporary processors. The cache holds C bytes total, divided into S lines of size B bytes: S = C/B.

Every main memory address is decomposed into three fields whose widths depend on the mapping scheme:

|Field|Purpose|
|---|---|
|**Tag**|Identifies which memory block occupies a cache line|
|**Index**|Selects which cache set to examine|
|**Block offset**|Selects the byte within the cache line|

Block offset width = log₂(B) bits. Index and tag widths vary by mapping scheme.

---

### Direct-Mapped Cache

#### Structure

Each memory block maps to **exactly one** cache line. The index field selects the line; the tag field distinguishes the one block from all others that share that line.

With S lines:

- Index width: log₂(S) bits
- Tag width: address_bits − log₂(S) − log₂(B)

A cache line stores: **valid bit | tag | data[B bytes]**

#### Lookup

On access to address A:

1. Extract index → select line index(A)
2. Check valid bit
3. Compare stored tag against tag(A)
4. Hit iff valid ∧ tags match; byte offset selects byte within block

#### Conflict Misses

If two frequently accessed addresses map to the same line, they evict each other on every access — **thrashing**. This is the defining pathology of direct-mapped caches. The conflict occurs regardless of how much total cache space remains unused.

**Example:** 4 KB direct-mapped cache, 64-byte lines → 64 lines. Addresses 0x0000 and 0x1000 both map to line 0. Alternating accesses to both produce a miss rate of 100%.

---

### Fully Associative Cache

#### Structure

A memory block may occupy **any** cache line. There is no index field — the entire non-offset portion of the address is the tag. On every access, the tag is compared against all S stored tags simultaneously.

- Index width: 0 bits
- Tag width: address_bits − log₂(B)

Hardware requirement: S parallel comparators operating every cycle. For large caches this is prohibitively expensive; fully associative caches are used only where S is small — TLBs, victim caches, small L1 caches in embedded systems.

#### Replacement

With full freedom of placement, a replacement policy must decide which line to evict on a miss. Common policies: LRU (optimal for many access patterns), pseudo-LRU (hardware approximation), FIFO, random. True LRU requires log₂(S) bits of state per line and an update on every hit — expensive for large S.

#### Property

Fully associative caches have **no conflict misses by definition** — any miss is either a cold miss (first access) or a capacity miss (working set exceeds cache size). This makes them the baseline for comparing miss rates: the difference between a direct-mapped miss rate and the fully associative miss rate at the same capacity is the conflict miss contribution.

---

### Set-Associative Cache

#### Structure

A compromise: the cache is divided into **2^k sets**, each holding **W lines** (W-way associative). A memory block maps to exactly one set (determined by the index field) but may occupy any of the W lines within that set.

- Number of sets: S_sets = S / W
- Index width: log₂(S_sets) bits
- Tag width: address_bits − log₂(S_sets) − log₂(B)

Each set requires W parallel tag comparators. Hardware cost scales with W, not total cache size.

W=1 is direct-mapped. W=S_sets is fully associative.

#### Lookup

1. Extract index → select set
2. Compare tag against all W tags in the set simultaneously
3. Hit if any comparator matches and valid bit is set
4. On miss, select a victim line within the set per replacement policy; fetch block from memory

---

### Address Decomposition — Visualization---

### Miss Classification (3C Model)

**Compulsory misses** (cold misses): the first access to any block. Unavoidable regardless of cache size or associativity. Reducible by prefetching or larger block size.

**Capacity misses**: the working set exceeds the cache capacity. Occur even in a fully associative cache. Reducible only by increasing cache size.

**Conflict misses**: multiple blocks compete for the same set. Zero in a fully associative cache; maximal in direct-mapped. Reducible by increasing associativity or cache size.

A fourth category sometimes added: **coherence misses** — invalidations from other processors in a multicore system. Not a property of the mapping scheme itself.

The 3C model attributes every miss to exactly one cause, making it useful for analyzing whether a design change (more associativity, larger cache, larger block) will address the dominant miss type.

---

### Hardware Cost vs. Associativity

|Associativity W|Sets S/W|Tag comparators per access|Replacement logic|
|---|---|---|---|
|1 (direct)|S|1|None|
|2|S/2|2|1 LRU bit per set|
|4|S/4|4|3 bits pseudo-LRU per set|
|8|S/8|8|6+ bits LRU state per set|
|S (fully assoc.)|1|S|Full LRU — impractical for large S|

The multiplexer tree selecting among W hits also grows with W. In practice, the critical-path delay through the set lookup and tag comparison is a primary constraint on L1 cache cycle time.

---

### Hit Time and the Virtually Indexed Physically Tagged (VIPT) Optimization

L1 caches in out-of-order processors must return data within 4–5 cycles to avoid stalling the pipeline. The critical path is: address generation → index extraction → SRAM array read → tag compare → data mux.

**VIPT** exploits the overlap between address translation and cache access: if the index bits fall entirely within the page offset (bits below the page boundary), the index is identical in both the virtual and physical address. The cache array can be read using virtual index bits while the TLB translates the upper bits in parallel, with tag comparison using the physical tag. This hides TLB latency from the critical path.

Constraint: for a direct-mapped VIPT cache, index_bits + offset_bits ≤ page_offset_bits (typically 12 for 4 KB pages). For 64-byte lines (6 offset bits), a direct-mapped VIPT L1 can have at most 2^6 = 64 lines = 4 KB. Larger L1s require set-associativity: a 4-way 16 KB cache has 64 sets, index = 6 bits, 6+6=12 ≤ 12 — exactly fits a 4 KB page offset, and is VIPT-compatible. This is why 32 KB 8-way and 16 KB 4-way are canonical L1 sizes.

---

### Replacement Policies

Relevant only for W > 1.

**LRU (Least Recently Used):** evict the line not accessed for the longest time. Optimal for many workloads exhibiting temporal locality. Exact LRU requires tracking access order among W lines: (W−1) + (W−2) + … = W(W−1)/2 bits per set, and update logic on every hit.

**Pseudo-LRU (PLRU):** a binary tree of bits approximating LRU. For W=4, three bits suffice. Used in most real L1/L2 caches as a hardware-feasible approximation.

**Random:** select victim uniformly at random. Surprisingly competitive with LRU in practice; used in some ARM designs. Hardware cost is minimal — a small LFSR.

**FIFO:** evict the oldest-inserted line. Simple but ignores recency of use; performs poorly under access patterns with temporal locality.

**RRIP (Re-Reference Interval Prediction):** each line has a 2-bit RRPV (re-reference prediction value); scan victims with RRPV=3. Handles scan-resistant and thrash-resistant patterns better than LRU. Used in Intel's L3 caches.

---

### Write Policies

Orthogonal to mapping scheme but interacts with it.

**Write-hit policies:**

- **Write-through:** every write is propagated immediately to the next level. Simple coherence, no dirty bits needed; generates high write traffic.
- **Write-back:** writes update only the cache line (marked dirty). The modified block is written to memory only on eviction. Reduces write traffic substantially; requires a dirty bit per line.

**Write-miss policies:**

- **Write-allocate:** on a write miss, fetch the block into cache, then write. Usually paired with write-back.
- **No-write-allocate (write-around):** write directly to next level, do not bring block into cache. Usually paired with write-through. Avoids polluting cache with blocks that are written but not subsequently read.

---

### Quantitative Comparison

For a fixed total cache size and block size, increasing associativity reduces conflict misses with diminishing returns. The miss rate improvement from direct-mapped to 2-way is typically the largest step; 8-way captures most of the benefit of full associativity for most workloads.

|Associativity|Miss rate (typical integer)|Notes|
|---|---|---|
|1-way (direct)|Baseline|High conflict miss rate|
|2-way|−20 to −40% vs direct|Largest single gain|
|4-way|−5 to −15% vs 2-way|Diminishing returns begin|
|8-way|−2 to −5% vs 4-way|Near-asymptotic|
|Fully assoc.|Capacity + cold only|Conflict misses = 0|

[Unverified: specific percentages vary significantly across workloads and cache sizes. These are representative ranges from architectural simulation studies; actual values depend on application memory access patterns.]

---

### Summary

|Property|Direct-mapped|Set-associative (W-way)|Fully associative|
|---|---|---|---|
|Placement freedom|1 line per block|W lines per block|Any line|
|Index bits|log₂(S)|log₂(S/W)|0|
|Tag comparators|1|W|S|
|Conflict misses|Maximum|Reduced by W|Zero|
|Replacement logic|None|Required|Required|
|Hardware cost|Lowest|Moderate|Highest|
|Typical use|Some L1, TLBs|L1, L2, L3 (W=4–16)|TLBs, victim caches|

---

**Next Steps:** Replacement policy analysis and Belady's optimal algorithm · Write buffer design · Multi-level cache inclusion and exclusion properties · Cache coherence protocols (MSI, MESI) · Non-blocking caches and miss-status holding registers (MSHRs) · Prefetching and stream buffers.

---

