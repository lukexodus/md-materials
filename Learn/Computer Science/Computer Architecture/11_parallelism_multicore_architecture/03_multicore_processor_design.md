## Multicore Processor Design


Multicore processors integrate two or more independent processing cores onto a single die, enabling thread-level parallelism at the hardware level. Each core is a fully functional processor capable of independently fetching, decoding, and executing instructions. The design discipline spans physical integration, cache hierarchy, interconnect fabric, coherence, and the interface between hardware and the software stack.

---

### Core Microarchitecture

Each core in a modern multicore processor is itself a sophisticated out-of-order, superscalar pipeline. The replication unit is not a bare ALU but a complete execution engine, including:

- A front-end: branch predictor, instruction cache (L1-I), fetch and decode logic
- A back-end: rename/dispatch, reservation stations or a unified scheduler, execution units (integer, FP, SIMD, load/store), and a reorder buffer (ROB)
- Private L1 data cache (L1-D) and typically a private L2 cache

The decision of what to replicate per core versus what to share is the central design variable of multicore architecture.

---

### Homogeneous vs. Heterogeneous Multicore

**Homogeneous (Symmetric) Multicore** All cores are identical in microarchitecture and operate at the same frequency. The OS scheduler treats them as interchangeable. This simplifies load balancing and verification but wastes die area when workloads are mixed (e.g., a latency-critical foreground thread alongside a throughput-bound background task).

**Heterogeneous (Asymmetric) Multicore** Cores differ by microarchitecture, pipeline width, clock frequency, or power envelope. The canonical contemporary implementation is ARM's **big.LITTLE** and its successor **DynamIQ**:

|Cluster|Characteristics|Target workload|
|---|---|---|
|Big cores|Wide OoO, deep pipeline, high clock|Interactive, latency-sensitive|
|Little cores|Narrow in-order, low clock, low power|Background, idle tasks|
|Medium cores (DynamIQ)|Intermediate|Sustained compute|

The OS or runtime must be aware of core asymmetry to schedule threads appropriately — a topic referred to as **task-aware scheduling**. Intel's implementation is called **Thread Director** (P-cores + E-cores in Alder Lake and later).

---

### Die Integration Strategies

**Monolithic die** All cores and shared structures are fabricated on one continuous silicon die. This minimizes latency for on-die communication but limits maximum core count by yield: a defect anywhere on a large die scraps the entire chip.

**Chiplet/multi-die integration** Cores are split across multiple smaller dies (chiplets) connected via a high-bandwidth, low-latency die-to-die interconnect (e.g., AMD's Infinity Fabric, Intel's EMIB, or TSMC's CoWoS). Yield improves because a defect affects only one small chiplet. This is covered in depth under Module 12, but the topology is directly relevant to multicore design because it determines the latency structure of cross-core communication.

---

### Cache Hierarchy in Multicore Systems

Cache organization is the most consequential design decision in a multicore system because it directly determines coherence complexity, bandwidth pressure, and inter-core communication latency.

#### Private vs. Shared Caches

```
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│  Core 0  │   │  Core 1  │   │  Core 2  │   │  Core 3  │
│  L1I L1D │   │  L1I L1D │   │  L1I L1D │   │  L1I L1D │
│    L2    │   │    L2    │   │    L2    │   │    L2    │
└────┬─────┘   └────┬─────┘   └────┬─────┘   └────┬─────┘
     └───────────────┴──────────────┴───────────────┘
                              │
                       Shared L3 (LLC)
                              │
                        Main Memory
```

|Level|Typical ownership|Typical size (per core)|Latency|
|---|---|---|---|
|L1-I / L1-D|Private|32–64 KB each|4–5 cycles|
|L2|Private (sometimes shared between 2 cores)|256 KB – 2 MB|10–15 cycles|
|L3 (LLC)|Shared across all cores|2–8 MB/core|30–50 cycles|

**Private caches** reduce average access latency for each core's working set and avoid bandwidth contention. Their cost is that the same cache line may exist in multiple private caches simultaneously, requiring coherence.

**Shared caches** present a single coherent view with no duplication overhead, but all cores compete for the same bandwidth and capacity. A single core with a large working set can evict lines useful to other cores (**cache thrashing**).

Most modern designs use **private L1 and L2** with a **shared, banked LLC**. The LLC is physically distributed across the die — each bank sits near a cluster of cores — but is logically unified.

#### Inclusive, Exclusive, and Non-Inclusive Caches

|Policy|Definition|Implication|
|---|---|---|
|Inclusive|Every line in L1/L2 is also present in L3|LLC acts as coherence directory; eviction from LLC requires invalidation of upper levels|
|Exclusive|A line exists in exactly one level at a time|Maximum effective capacity; complex fill/eviction logic|
|Non-inclusive (NINE)|No constraint enforced|LLC may or may not have a copy; used in AMD Zen|

---

### Interconnect Fabric

Cores, cache banks, memory controllers, and I/O must be connected. The interconnect topology determines scalability, latency, and bandwidth.

#### Bus

A single shared wire. Simple but does not scale — bandwidth is fixed and contention grows with core count. Practical only for 2–4 cores.

#### Crossbar

Full point-to-point connectivity between all nodes. Zero contention, minimum latency. Hardware cost scales as O(N²) — impractical beyond ~16 nodes.

#### Ring Bus

Nodes arranged in a ring; messages travel around the ring in one or both directions. Intel used a bidirectional ring in Sandy Bridge through Broadwell (up to ~18 cores). Latency grows linearly with ring diameter; bandwidth does not scale well past ~20 cores.

#### Mesh (2D)

Nodes arranged in a 2D grid. Each node connects to up to four neighbors. Intel adopted a 2D mesh in Skylake-SP (Xeon Scalable) and all subsequent server designs. Latency is O(√N); bandwidth scales with N.

```svg
<svg viewBox="0 0 340 340" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11">
  <!-- Grid lines horizontal -->
  <line x1="50" y1="80" x2="290" y2="80" stroke="#888" stroke-width="1.5"/>
  <line x1="50" y1="160" x2="290" y2="160" stroke="#888" stroke-width="1.5"/>
  <line x1="50" y1="240" x2="290" y2="240" stroke="#888" stroke-width="1.5"/>
  <!-- Grid lines vertical -->
  <line x1="50" y1="80" x2="50" y2="240" stroke="#888" stroke-width="1.5"/>
  <line x1="170" y1="80" x2="170" y2="240" stroke="#888" stroke-width="1.5"/>
  <line x1="290" y1="80" x2="290" y2="240" stroke="#888" stroke-width="1.5"/>
  <!-- Nodes -->
  <rect x="30" y="60" width="40" height="40" rx="5" fill="#4a90d9" stroke="#2c5f8a" stroke-width="1.5"/>
  <text x="50" y="85" text-anchor="middle" fill="white" font-size="10">C0</text>
  <rect x="150" y="60" width="40" height="40" rx="5" fill="#4a90d9" stroke="#2c5f8a" stroke-width="1.5"/>
  <text x="170" y="85" text-anchor="middle" fill="white" font-size="10">C1</text>
  <rect x="270" y="60" width="40" height="40" rx="5" fill="#4a90d9" stroke="#2c5f8a" stroke-width="1.5"/>
  <text x="290" y="85" text-anchor="middle" fill="white" font-size="10">C2</text>
  <rect x="30" y="140" width="40" height="40" rx="5" fill="#4a90d9" stroke="#2c5f8a" stroke-width="1.5"/>
  <text x="50" y="165" text-anchor="middle" fill="white" font-size="10">C3</text>
  <rect x="150" y="140" width="40" height="40" rx="5" fill="#e07b39" stroke="#a04e1a" stroke-width="1.5"/>
  <text x="170" y="165" text-anchor="middle" fill="white" font-size="10">MC</text>
  <rect x="270" y="140" width="40" height="40" rx="5" fill="#4a90d9" stroke="#2c5f8a" stroke-width="1.5"/>
  <text x="290" y="165" text-anchor="middle" fill="white" font-size="10">C4</text>
  <rect x="30" y="220" width="40" height="40" rx="5" fill="#4a90d9" stroke="#2c5f8a" stroke-width="1.5"/>
  <text x="50" y="245" text-anchor="middle" fill="white" font-size="10">C5</text>
  <rect x="150" y="220" width="40" height="40" rx="5" fill="#4a90d9" stroke="#2c5f8a" stroke-width="1.5"/>
  <text x="170" y="245" text-anchor="middle" fill="white" font-size="10">C6</text>
  <rect x="270" y="220" width="40" height="40" rx="5" fill="#4a90d9" stroke="#2c5f8a" stroke-width="1.5"/>
  <text x="290" y="245" text-anchor="middle" fill="white" font-size="10">C7</text>
  <!-- Legend -->
  <rect x="30" y="295" width="14" height="14" rx="3" fill="#4a90d9"/>
  <text x="50" y="306" fill="#ccc" font-size="10">Core + LLC bank</text>
  <rect x="160" y="295" width="14" height="14" rx="3" fill="#e07b39"/>
  <text x="180" y="306" fill="#ccc" font-size="10">Memory Controller</text>
</svg>
```

#### Hierarchical Ring / Cluster Mesh

Some designs partition cores into clusters, with a fast local ring or crossbar inside each cluster and a slower inter-cluster mesh between clusters. AMD's Zen CCX (Core Complex) uses this model.

---

### Cache Coherence

When multiple cores hold private copies of the same cache line and one core writes, all other copies must be updated or invalidated. The protocol that manages this is the **cache coherence protocol**.

#### Snooping vs. Directory

**Snooping:** Every cache controller monitors (snoops) all transactions on a shared broadcast medium. Simple and low-latency for small core counts. Does not scale — broadcast traffic grows with N.

**Directory-based:** A directory tracks, for each cache line, which cores currently hold a copy. Coherence messages are point-to-point between the requesting core and the directory (and the sharer cores). Scales to hundreds of nodes. Directory overhead is approximately 1–2 bits per cache line per core.

Most server-class multicore processors use directory-based coherence anchored at the LLC or a dedicated directory structure.

#### Protocol States

The foundational protocol is **MSI**:

|State|Meaning|
|---|---|
|**M**odified|Core has the only copy; it is dirty (differs from memory)|
|**S**hared|One or more cores have a clean read-only copy|
|**I**nvalid|Core does not have a valid copy|

**MESI** adds the **E**xclusive state: a clean copy held by exactly one core, allowing silent upgrade to M on a write without a bus transaction.

**MOESI** adds **O**wned: a core holds a dirty copy but other cores may also hold stale shared copies — the Owner is responsible for supplying the data on a miss rather than fetching from memory.

|Protocol|Extra state|Benefit|
|---|---|---|
|MSI|—|Baseline|
|MESI|Exclusive|Avoids redundant invalidation on first write|
|MOESI|Owned|Avoids memory writeback on shared-dirty transfers|

#### False Sharing

Two cores access different variables that happen to reside on the same cache line. A write by Core 0 invalidates Core 1's copy of the entire line even though Core 1's variable was not modified. This causes coherence traffic and performance degradation without any logical sharing. Mitigation requires padding data structures to cache-line boundaries.

---

### Synchronization Hardware Support

Multicore software requires atomic operations for mutual exclusion and lock-free data structures. Hardware provides:

**Test-and-Set (TAS):** Atomically reads a memory location and writes 1. Widely considered obsolete for scalable locks due to O(N²) coherence traffic under contention.

**Compare-and-Swap (CAS):** Atomically compares a memory word to an expected value and, if equal, replaces it with a new value. Returns success/failure. The foundation of most lock-free algorithms.

**Load-Linked / Store-Conditional (LL/SC):** LL reads a location and registers a reservation. SC writes only if no intervening write to that location has occurred (the reservation is still valid). Avoids the ABA problem inherent in CAS. Used on RISC architectures (ARM `LDXR`/`STXR`, RISC-V `LR`/`SC`, MIPS `LL`/`SC`).

**Fetch-and-Add:** Atomically increments a memory word and returns the old value. Efficient for ticket locks.

---

### Memory Consistency Models

Cache coherence defines the ordering of operations to a _single_ memory location. The **memory consistency model** defines the ordering of operations to _multiple_ memory locations as observed by other cores.

|Model|Description|Example ISA|
|---|---|---|
|Sequential Consistency (SC)|All cores observe all memory operations in a single global order|Theoretical baseline|
|Total Store Order (TSO)|Loads may bypass prior stores from the same core (store buffer effect)|x86|
|Release Consistency|Only acquire/release operations impose ordering; ordinary loads/stores freely reorder|ARM, RISC-V (base)|

In TSO, a store is placed in a per-core **store buffer** and may not be visible to other cores immediately. Loads from the same core can read their own store buffer (store-to-load forwarding) but the store reaches the cache — and becomes globally visible — asynchronously. This can produce results that SC would not permit.

Software must insert **memory barriers** (fences) to impose ordering where the hardware model would otherwise permit reordering.

---

### Power and Thermal Constraints

Scaling core count raises total die power. For a fixed thermal design power (TDP):

- Each additional core reduces the sustainable per-core frequency
- A **power wall** sets a hard ceiling on simultaneously active cores at full frequency
- **Dark silicon** refers to die area that must remain powered down at any given moment to stay within TDP

Multicore designs respond with:

- **Per-core power gating:** idle cores are power-gated (supply voltage removed)
- **Per-core DVFS:** active cores run at voltage/frequency determined by current workload and thermal headroom
- **Turbo/boost modes:** one or a few cores can briefly exceed base frequency when others are idle, within TDP budget

---

### Scalability Limits

**Amdahl's Law** bounds speedup from adding cores. If fraction _s_ of a program is serial:

$$\text{Speedup}(N) = \frac{1}{s + \frac{1-s}{N}}$$

As N → ∞, speedup → 1/s. A program with 5% serial fraction cannot exceed 20× speedup regardless of core count.

Beyond Amdahl's Law, practical limits include:

- **Coherence overhead:** Coherence traffic grows with sharing and core count
- **Interconnect bandwidth saturation:** Memory bandwidth is shared; bandwidth-bound workloads see diminishing returns
- **Synchronization contention:** Lock contention serializes threads
- **OS overhead:** Scheduling, IPI (inter-processor interrupts), and TLB shootdowns have fixed per-core costs

---

### OS and Software Interface

The hardware multicore design exposes topology information to the OS through:

- **ACPI MADT (Multiple APIC Description Table):** Lists logical processors and their APIC IDs
- **CPUID instruction (x86):** Reports core count, thread count, cache topology, and feature flags
- **Device tree (ARM/embedded):** Describes CPU cluster topology

The OS uses this information for:

- **Scheduler affinity:** Keeping a thread on the same core or within the same LLC domain to preserve cache warmth
- **NUMA-aware allocation:** Allocating memory from the NUMA node local to the thread running the allocation
- **Interrupt affinity:** Routing device interrupts to cores that own the relevant data structures

---

**Key Points**

- The central design variable is the partitioning of resources between private (per-core) and shared structures, most critically caches.
- Interconnect topology (ring → mesh → hierarchical) is selected based on target core count and bandwidth requirements.
- Cache coherence protocols (MSI/MESI/MOESI) impose ordering on private cache lines; the memory consistency model governs cross-core visibility of operations to different addresses.
- False sharing is a coherence artifact with no logical cause, resolved by cache-line-aligned data layout.
- Heterogeneous multicore (big.LITTLE, P+E cores) addresses workload diversity and power efficiency that homogeneous designs cannot achieve at the same TDP.
- Amdahl's Law and practical interconnect/coherence costs bound the returns from adding cores.

**Next Steps**

Proceed to **Flynn's Taxonomy and SIMD/Vector Processing** for the data-parallel complement to thread-level parallelism, or to **Cache Coherence Protocols in depth (MSI, MESI, MOESI)** under Module 7 for formal state transition analysis. **NUMA** and **Memory Consistency Models** are natural continuations within Module 11.

---

