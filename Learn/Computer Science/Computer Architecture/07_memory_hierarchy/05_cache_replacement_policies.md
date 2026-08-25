## Cache Replacement Policies


When a cache miss occurs and the target set is full, a victim line must be selected for eviction. The replacement policy governs that selection. The choice affects hit rate, implementation cost, and worst-case behavior — and the optimal policy is workload-dependent.

---

### Theoretical Optimum — Bélády's Algorithm

Bélády's optimal policy (OPT) evicts the line whose next use is furthest in the future. It is provably optimal in hit rate for any fixed cache size and access sequence.

It is not implementable in hardware — it requires knowledge of future accesses. It serves as an upper-bound benchmark against which real policies are measured.

---

### Least Recently Used (LRU)

#### Principle

Evict the line that was least recently accessed. LRU approximates Bélády by assuming that past recency predicts future reuse — a reasonable assumption under temporal locality.

#### Exact LRU Implementation

For a set with N ways, exact LRU requires maintaining a total ordering of all N lines by recency. The standard representation is a recency stack or an N×N bit matrix.

**Bit matrix method:** For N ways, maintain an N×N upper-triangular matrix of bits. On access to way i:

- Set all bits in row i to 1
- Set all bits in column i to 0

The LRU way is the row whose sum is 0. For N=4 ways, this requires 6 bits (upper triangle only).

Storage cost for exact LRU in a set-associative cache with S sets and N ways:

```
bits = S × N×(N-1)/2
```

For a 16-way set-associative cache with 1024 sets: 1024 × 120 = 122,880 bits ≈ 15 KB of overhead. This grows as O(N²) per set — impractical beyond 4–8 ways.

#### LRU Stack Property

LRU has the **stack property**: the set of lines present in a cache of size k is always a subset of those present in a cache of size k+1, for any access sequence. This means increasing cache size under LRU never increases the miss rate — a property Bélády's algorithm also satisfies, but FIFO and random do not.

#### Bélády's Anomaly

FIFO does not have the stack property. It is possible to construct access sequences where increasing cache size under FIFO _increases_ the miss rate. LRU is immune to this anomaly.

#### LRU Weakness — Thrashing

If the working set size exceeds the cache size by even one line, LRU produces a 100% miss rate on cyclic access patterns. For a 4-way set with lines A, B, C, D, E cycled in order: each access evicts the line that will be needed next, since the working set (5 lines) exceeds capacity (4 ways) by exactly one.

This is the **LRU thrashing** problem. It is deterministic and repeatable — the same access pattern always produces the same worst-case behavior.

---

### Pseudo-LRU (PLRU)

Exact LRU is too expensive beyond 4 ways. Pseudo-LRU approximates the LRU decision with O(N) bits using a binary tree structure.

#### Tree-PLRU for N=4 ways

Maintain a binary tree with N−1 = 3 internal nodes, each holding a single pointer bit indicating which subtree was used more recently.

<svg viewBox="0 0 380 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- Root node --> <circle cx="190" cy="40" r="16" fill="#1e1e2e" stroke="#89b4fa" stroke-width="1.4"/> <text x="190" y="45" text-anchor="middle" fill="#89b4fa">b0</text> <!-- Left subtree node --> <circle cx="100" cy="100" r="16" fill="#1e1e2e" stroke="#fab387" stroke-width="1.4"/> <text x="100" y="105" text-anchor="middle" fill="#fab387">b1</text> <!-- Right subtree node --> <circle cx="280" cy="100" r="16" fill="#1e1e2e" stroke="#fab387" stroke-width="1.4"/> <text x="280" y="105" text-anchor="middle" fill="#fab387">b2</text> <!-- Edges --> <line x1="178" y1="53" x2="112" y2="87" stroke="#6c7086" stroke-width="1.2"/> <line x1="202" y1="53" x2="268" y2="87" stroke="#6c7086" stroke-width="1.2"/> <line x1="88" y1="113" x2="60" y2="155" stroke="#6c7086" stroke-width="1.2"/> <line x1="112" y1="113" x2="140" y2="155" stroke="#6c7086" stroke-width="1.2"/> <line x1="268" y1="113" x2="240" y2="155" stroke="#6c7086" stroke-width="1.2"/> <line x1="292" y1="113" x2="320" y2="155" stroke="#6c7086" stroke-width="1.2"/> <!-- Leaves --> <rect x="40" y="155" width="40" height="28" rx="3" fill="#313244" stroke="#a6e3a1" stroke-width="1.2"/> <text x="60" y="174" text-anchor="middle" fill="#a6e3a1">W0</text> <rect x="120" y="155" width="40" height="28" rx="3" fill="#313244" stroke="#a6e3a1" stroke-width="1.2"/> <text x="140" y="174" text-anchor="middle" fill="#a6e3a1">W1</text> <rect x="220" y="155" width="40" height="28" rx="3" fill="#313244" stroke="#a6e3a1" stroke-width="1.2"/> <text x="240" y="174" text-anchor="middle" fill="#a6e3a1">W2</text> <rect x="300" y="155" width="40" height="28" rx="3" fill="#313244" stroke="#a6e3a1" stroke-width="1.2"/> <text x="320" y="174" text-anchor="middle" fill="#a6e3a1">W3</text> <!-- Edge labels -->

<text x="130" y="70" fill="#6c7086" font-size="9">0=left</text> <text x="220" y="70" fill="#6c7086" font-size="9">1=right</text> </svg>

**Victim selection:** Follow the tree from root to leaf. At each node, go left if the bit points right (the right subtree was recently used, so the left is the candidate), and vice versa. The leaf reached is the PLRU victim.

**Update on access to way i:** Flip each bit along the path from root to way i to point away from i.

Storage cost: N−1 bits per set regardless of N. For the same 16-way, 1024-set cache: 1024 × 15 = 15,360 bits ≈ 1.9 KB — an 8× reduction over exact LRU.

PLRU is not always consistent with exact LRU decisions but approximates it well in practice. It is the dominant implementation in L1/L2 caches of real processors.

---

### FIFO (First-In First-Out)

#### Principle

Evict the line that has been resident in the cache the longest, regardless of how recently it was accessed. Implemented with a simple pointer that cycles through ways.

#### Implementation

Maintain one pointer per set indicating the next victim way. On eviction, use the way at the pointer and advance the pointer modulo N. No update is needed on a cache hit.

Storage cost: ⌈log₂(N)⌉ bits per set — far cheaper than LRU. For 4-way: 2 bits per set.

#### FIFO Weakness

FIFO does not exploit recency — a line that has been accessed repeatedly since being loaded is evicted the same as one that was loaded and never reused. It also does not have the stack property and is susceptible to Bélády's anomaly.

**FIFO is immune to LRU thrashing** in the strict cyclic sense: it does not reset the eviction pointer on access, so a frequently accessed hot line will eventually be evicted regardless — but a different access pattern (non-cyclic with a stable working set) can cause FIFO to outperform LRU when the working set fits and access order is sequential.

---

### Random Replacement

#### Principle

Select the victim uniformly at random among all ways in the set. Requires a random or pseudo-random number source — typically a hardware linear feedback shift register (LFSR).

#### Implementation

One LFSR per cache bank (or shared), advancing each cycle. On a miss, the LFSR output modulo N selects the victim. No per-set state is required beyond the LFSR.

Storage cost: effectively zero per set — only the LFSR state, which is shared.

#### Properties

Random replacement has **no worst-case access pattern** in the deterministic sense — because the victim is nondeterministic, no adversarial access sequence can consistently force the worst possible eviction choice. This is its primary advantage over LRU.

For LRU thrashing scenarios (working set = N+1 lines, cyclic access), random replacement achieves a hit rate of approximately (N)/(N+1) on average — far better than LRU's 0%.

[Inference] Random replacement's average-case hit rate approaches LRU's for large N and typical workloads, though it will be worse than LRU for access patterns with strong temporal locality, since it does not use recency information. This is not guaranteed to hold for all workloads.

---

### Quantitative Comparison

For a 4-way set, working set of 5 distinct lines accessed in cyclic order (A→B→C→D→E→A→B→…):

|Policy|Hit rate|
|---|---|
|OPT|0% (working set exceeds capacity regardless)|
|LRU|0% (thrashing — deterministic worst case)|
|FIFO|0% (same cyclic pattern, also thrashes)|
|Random|~80% on average (N/(N+1) = 4/5)|

For a 4-way set, working set of 4 lines with strong temporal locality (repeated access to same 4 lines):

|Policy|Hit rate|
|---|---|
|OPT|~100%|
|LRU|~100%|
|FIFO|~100%|
|Random|~100%|

For mixed workloads with moderate locality, LRU and PLRU typically outperform random by 2–10% in miss rate for L1/L2 caches.

---

### Implementation Cost Summary

|Policy|State per set (N ways)|Hit update required|Anomaly-free|
|---|---|---|---|
|OPT|N/A (oracle)|N/A|Yes|
|Exact LRU|N(N−1)/2 bits|Yes|Yes|
|Tree-PLRU|N−1 bits|Yes|Approximately|
|FIFO|⌈log₂ N⌉ bits|No|No|
|Random|~0 per set|No|Yes (probabilistic)|

---

### Scan Resistance and Modern Variants

A **scan** (also called a streaming access) is a sequential traversal of a large array that exceeds cache capacity. Under LRU, a scan evicts the entire working set from cache, destroying temporal locality that existed before the scan. The scan lines themselves are never reused.

This motivates several LRU variants used in real processors:

**MRU (Most Recently Used):** For known streaming patterns, evict the most recently used line rather than the least. Intel processors detect streaming patterns and switch to MRU for those addresses.

**NRU (Not Recently Used):** Each line has a reference bit. On access, set the bit. On eviction, select any line with a reference bit of 0 (resetting bits periodically). Approximates LRU with 1 bit per line.

**RRIP (Re-Reference Interval Prediction):** Each line holds a small saturating counter representing predicted re-reference interval. On insertion, lines are given an intermediate value (not highest priority). Lines with highest counter value are evicted. Scan-resistant by default since scan lines do not get promoted. Used in Intel's LLC replacement policy.

**SHIP (Signature-based Hit Interval Prediction):** Extends RRIP with a signature table indexed by PC or memory region to learn per-source re-reference behavior. Lines inserted from sources historically showing poor reuse are inserted at low priority.

---

### Set Dueling

Selecting the better policy between two candidates without offline profiling is done via **set dueling** (used in tournament predictors and cache policy selection):

- A small number of sets are permanently dedicated to Policy A
- A different small number are permanently dedicated to Policy B
- The remaining sets use the policy that is currently winning according to a saturating counter tracking which dedicated group has fewer misses
- The winning policy is applied to the follower sets dynamically

This allows hardware to adapt between, for example, LRU and RRIP without OS or compiler involvement. Intel's DRRIP (Dynamic RRIP) uses set dueling between SRRIP and BRRIP modes.

---

**Key Points**

- LRU is optimal under strong temporal locality and has the stack property, but degenerates to 0% hit rate on cyclic access patterns where working set exceeds capacity by one line
- PLRU reduces LRU's O(N²) state cost to O(N) bits per set with minimal hit rate impact — it is the dominant real implementation
- FIFO requires no hit-path update and is cheapest to implement correctly, but lacks the stack property and does not exploit recency
- Random replacement has no deterministic worst case and outperforms LRU on thrashing workloads, but cannot exploit recency — its advantage is robustness, not average-case performance
- Scan resistance is a practical requirement for LLC replacement policies; RRIP-family policies address this by inserting lines at intermediate priority rather than highest
- Set dueling enables runtime policy selection between two candidates without profiling, at the cost of dedicating a small number of sets as monitors
---

