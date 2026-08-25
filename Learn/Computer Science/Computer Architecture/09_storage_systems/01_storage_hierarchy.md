## Storage Hierarchy


The storage hierarchy is the organization of all data-holding components in a computer system into levels ordered by **access latency**, **bandwidth**, **capacity**, and **cost per bit**. No single technology simultaneously optimizes all four — faster storage is more expensive and smaller; cheaper storage is slower and larger. The hierarchy exploits this by placing the most frequently accessed data at the fastest levels, allowing the system to approximate the speed of the fastest technology at the cost of the cheapest.

---

### The Four Governing Properties

Every storage technology occupies a position on four axes simultaneously:

<svg viewBox="0 0 640 220" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <defs> <marker id="sh-arr" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#94a3b8"/> </marker> <marker id="sh-arr-up" markerWidth="7" markerHeight="7" refX="3" refY="1" orient="auto"> <path d="M0,6 L3,0 L6,6 z" fill="#34d399"/> </marker> <marker id="sh-arr-dn" markerWidth="7" markerHeight="7" refX="3" refY="6" orient="auto"> <path d="M0,0 L3,6 L6,0 z" fill="#f87171"/> </marker> </defs>

<text x="320" y="20" text-anchor="middle" font-size="13" font-weight="bold" fill="#e2e8f0">Storage Hierarchy — Property Gradients</text>

<!-- Left axis: top = CPU registers, bottom = tape --> <line x1="60" y1="40" x2="60" y2="195" stroke="#475569" stroke-width="1.5"/> <text x="55" y="40" text-anchor="end" fill="#93c5fd" font-size="10">registers</text> <text x="55" y="80" text-anchor="end" fill="#93c5fd" font-size="10">L1 cache</text> <text x="55" y="105" text-anchor="end" fill="#93c5fd" font-size="10">L2 cache</text> <text x="55" y="125" text-anchor="end" fill="#93c5fd" font-size="10">L3 cache</text> <text x="55" y="145" text-anchor="end" fill="#93c5fd" font-size="10">DRAM</text> <text x="55" y="165" text-anchor="end" fill="#93c5fd" font-size="10">NVMe SSD</text> <text x="55" y="183" text-anchor="end" fill="#93c5fd" font-size="10">HDD</text> <text x="55" y="198" text-anchor="end" fill="#93c5fd" font-size="10">Tape</text> <!-- Horizontal tick marks --> <line x1="57" y1="40" x2="63" y2="40" stroke="#475569"/> <line x1="57" y1="80" x2="63" y2="80" stroke="#475569"/> <line x1="57" y1="105" x2="63" y2="105" stroke="#475569"/> <line x1="57" y1="125" x2="63" y2="125" stroke="#475569"/> <line x1="57" y1="145" x2="63" y2="145" stroke="#475569"/> <line x1="57" y1="165" x2="63" y2="165" stroke="#475569"/> <line x1="57" y1="183" x2="63" y2="183" stroke="#475569"/> <line x1="57" y1="198" x2="63" y2="198" stroke="#475569"/> <!-- Bar: Latency (lower = better, so bigger bar = worse) -->

<text x="90" y="32" fill="#f87171" font-size="10">Latency (lower is faster →)</text> <rect x="65" y="34" width="2" height="10" rx="1" fill="#34d399"/> <rect x="65" y="74" width="5" height="10" rx="1" fill="#86efac"/> <rect x="65" y="99" width="12" height="10" rx="1" fill="#86efac"/> <rect x="65" y="119" width="30" height="10" rx="1" fill="#fde68a"/> <rect x="65" y="139" width="80" height="10" rx="1" fill="#fde68a"/> <rect x="65" y="159" width="160" height="10" rx="1" fill="#fb923c"/> <rect x="65" y="177" width="280" height="10" rx="1" fill="#f87171"/> <rect x="65" y="192" width="400" height="10" rx="1" fill="#f87171"/>

<!-- Bar: Capacity -->

<text x="490" y="32" fill="#93c5fd" font-size="10">Capacity (more →)</text> <rect x="470" y="34" width="2" height="10" rx="1" fill="#f87171"/> <rect x="470" y="74" width="4" height="10" rx="1" fill="#f87171"/> <rect x="470" y="99" width="10" height="10" rx="1" fill="#fb923c"/> <rect x="470" y="119" width="25" height="10" rx="1" fill="#fde68a"/> <rect x="470" y="139" width="70" height="10" rx="1" fill="#86efac"/> <rect x="470" y="159" width="110" height="10" rx="1" fill="#86efac"/> <rect x="470" y="177" width="140" height="10" rx="1" fill="#34d399"/> <rect x="470" y="192" width="160" height="10" rx="1" fill="#34d399"/> </svg>

The governing properties and their direction of change moving down the hierarchy:

| Property       | Direction going down            | Implication                               |
| -------------- | ------------------------------- | ----------------------------------------- |
| Access latency | Increases (×10–×1000 per level) | Lower levels rarely accessed directly     |
| Bandwidth      | Decreases                       | Higher levels feed data to CPU            |
| Capacity       | Increases                       | Lower levels hold the full dataset        |
| Cost per bit   | Decreases                       | Lower levels economically viable at scale |
| Volatility     | Decreases                       | Lower levels retain data without power    |

---

### Full Hierarchy: Typical Values (2024-era server)

|Level|Technology|Latency|Bandwidth|Capacity|Cost/GB|
|---|---|---|---|---|---|
|Registers|SRAM flip-flops|< 1 ns|> 10 TB/s|256 B – 8 KB|—|
|L1 cache|SRAM (6T cell)|1–4 cycles (~0.5 ns)|1–4 TB/s|32–64 KB|—|
|L2 cache|SRAM|4–15 cycles (~2 ns)|500 GB/s–1 TB/s|256 KB–2 MB|—|
|L3 cache|SRAM (often eDRAM or large SRAM arrays)|20–50 cycles (~10 ns)|200–500 GB/s|4–64 MB|—|
|L4 / HBM cache|HBM or eDRAM|50–100 cycles|400 GB/s–3.2 TB/s|16–128 GB|~$10|
|Main memory|DDR5 DRAM|60–100 ns|50–150 GB/s|16 GB–12 TB|~$4|
|Persistent memory|3D XPoint / CXL DRAM|300–500 ns|20–50 GB/s|128 GB–6 TB|~$8|
|NVMe SSD|NAND Flash|50–100 µs|5–14 GB/s|1–100 TB|~$0.10|
|SATA SSD|NAND Flash|100–500 µs|500 MB/s–1 GB/s|1–16 TB|~$0.06|
|HDD|Magnetic disk|5–15 ms|100–300 MB/s|1–30 TB|~$0.02|
|Tape|Magnetic tape|seconds–minutes|300 MB/s (streaming)|10 TB–1 PB/cartridge|~$0.002|

[Unverified] Prices and capacities are representative of 2024 market conditions and will change. They are provided for order-of-magnitude comparison.

---

### Why the Hierarchy Works: Locality

The hierarchy is effective because real programs exhibit **locality of reference** — a property that means the set of addresses accessed in the near future is strongly predictable from the set accessed in the recent past.

**Temporal locality:** A recently accessed address is likely to be accessed again soon. Caches exploit this by retaining recently used data.

**Spatial locality:** Addresses near a recently accessed address are likely to be accessed soon. Caches exploit this by fetching entire **cache lines** (typically 64 bytes) on each miss, not individual bytes.

**Sequential locality** (a strong form of spatial): Instruction streams and array traversals proceed through consecutive addresses. Hardware prefetchers detect and exploit this pattern.

Without locality, the hierarchy would not help — every access would miss every level and fall through to DRAM or disk.

---

### Level 0: Registers

Registers are the only storage directly accessible to ALU operations. They are not addressable by load/store in the memory system sense — they are named operands in the instruction encoding. On x86-64, 16 general-purpose 64-bit registers (RAX–R15) and 16 SIMD registers (XMM0–XMM15 / ZMM0–ZMM15 with AVX-512). ARM64 has 31 general-purpose 64-bit registers and 32 SIMD registers.

Register files are implemented as multi-ported SRAM arrays: a 4-read-2-write register file supports two ALU operations per cycle, each reading two source operands and one writing a result. Port count dominates area and power cost, which is why register counts are bounded.

Physical register files in out-of-order processors are larger than the architectural register count — register renaming maps architectural registers to a larger pool of physical registers (e.g., 256 physical integer registers on Intel Skylake vs. 16 architectural).

---

### Levels 1–3: Cache Hierarchy

Cache is treated in depth in **Cache Fundamentals** and **Multi-Level Caches**. In the context of the full storage hierarchy, the key properties are:

The cache hierarchy operates entirely in **physical addresses** (virtually-indexed physically-tagged caches are an exception for L1). The TLB translates virtual to physical before cache lookup for L2 and L3. Cache lines are the unit of transfer between all levels.

**Inclusion policies** govern whether data present in L1 must also be present in L2 and L3:

- **Inclusive:** L2 and L3 contain a superset of L1. Cache invalidation is simple (invalidate at L3, guaranteed to propagate). Wastes capacity — a 256 KB L2 containing all of a 32 KB L1 gains only 224 KB of unique capacity.
- **Exclusive:** Each level holds disjoint data. Full capacity utilization. AMD Zen architecture uses exclusive L2/L3.
- **Non-inclusive non-exclusive (NINE):** No guarantee either way. Intel uses this for L3 in recent microarchitectures — L3 acts as a victim cache for L2 misses.

---

### Level 4: High Bandwidth Memory and DRAM Caches

**HBM (High Bandwidth Memory)** stacks multiple DRAM dies vertically using through-silicon vias (TSVs) and connects them to the processor via an interposer or in-package connection, delivering bandwidth of 400 GB/s–3.2 TB/s — 10–20× that of conventional DDR5.

HBM is used in three distinct roles depending on the system:

|Role|Description|Example|
|---|---|---|
|Only memory|No DDR5; entire memory capacity is HBM|AMD Instinct MI300X|
|DRAM cache|Transparent cache for larger DDR5 pool|Intel Sapphire Rapids HBM mode|
|Complementary pool|HBM and DDR5 both exposed, OS allocates explicitly|NVIDIA H100|

When used as a DRAM cache (L4 cache), the HBM acts analogously to how L3 acts relative to DRAM — a large, fast buffer that absorbs accesses that would otherwise reach the slower DDR5 pool.

---

### Main Memory: DRAM

DRAM is the primary working memory of the system. Each bit is stored as a charge on a capacitor — a single transistor plus a capacitor per bit (1T1C cell), achieving far higher density than SRAM (6 transistors per bit) at the cost of requiring periodic **refresh** (charge leaks and must be restored every 32–64 ms) and a more complex access protocol.

DRAM is organized into banks, rows, and columns. Access proceeds in three phases:

- **Activate (RAS):** Opens a row, transferring its contents to a sense amplifier row buffer
- **Read/Write (CAS):** Accesses a column within the open row — fast if the row is already open
- **Precharge:** Closes the row, preparing the bank for the next activation

Row buffer hits (the requested address is in an already-open row) are fast (~15 ns). Row buffer misses (must precharge and activate a new row) incur the full latency (~60–100 ns). The memory controller schedules DRAM commands to maximize row buffer hits — this is called **open-page policy**.

DDR5 (Double Data Rate 5) transfers data on both edges of the clock, doubles the burst length to 16 beats, operates at 4800–8400 MT/s per channel, and increases bank group count to improve parallelism. A dual-channel DDR5-6400 configuration delivers ~100 GB/s.

---

### Persistent Memory

**Persistent memory** (also called **storage-class memory**) is a technology that occupies the latency/bandwidth position between DRAM and NVMe SSD while retaining data without power.

Intel Optane (3D XPoint) was the most fully realized commercial product — installed in DIMM slots, accessible via load/store instructions, with ~300–500 ns read latency and byte-addressability. It was discontinued in 2022.

The CXL (Compute Express Link) standard now enables DRAM expansion and persistent memory attached via PCIe lanes, with latencies of 200–500 ns depending on hop count. CXL.mem allows processors to access remote memory pools as if they were local DRAM, enabling **memory disaggregation** — a rack-level memory pool shared across multiple compute nodes.

---

### NVMe SSD

NVMe (Non-Volatile Memory Express) SSDs connect via PCIe lanes and use NAND flash as the storage medium. The NVMe protocol was designed specifically for flash — it supports up to 65,535 parallel I/O queues with 65,535 entries each, eliminating the queue depth bottleneck of SATA (32 entries, one queue).

NAND flash stores data as charge trapped in a floating gate or charge trap layer. Charge level encodes bits:

|Type|Bits/cell|Endurance (P/E cycles)|Density|Speed|
|---|---|---|---|---|
|SLC|1|100,000|Low|Fastest|
|MLC|2|10,000|Medium|Fast|
|TLC|3|3,000|High|Moderate|
|QLC|4|1,000|Highest|Slowest|
|PLC|5|~300|Emerging|Slowest|

NAND flash cannot be overwritten in place — it must be **erased** (entire erase block, typically 4–16 MB) before rewriting. This requires a **Flash Translation Layer (FTL)** that implements:

- **Logical-to-physical mapping:** Remaps logical block addresses to physical NAND locations
- **Wear leveling:** Distributes writes evenly across all blocks to prevent premature cell exhaustion
- **Garbage collection:** Reclaims erased blocks from invalidated data
- **Write amplification:** The ratio of physical writes to logical writes, always ≥ 1, typically 3–10× for mixed workloads under a naive FTL

NVMe Gen 4 (PCIe 4.0 ×4) delivers up to ~7 GB/s sequential read; Gen 5 (PCIe 5.0 ×4) up to ~14 GB/s.

---

### HDD: Magnetic Disk

A hard disk drive stores data as magnetic domains on a spinning platter coated with a ferromagnetic film. One or more read/write heads mounted on an actuator arm access concentric tracks.

Access time has three components:

$$t_{\text{access}} = t_{\text{seek}} + t_{\text{rotation}} + t_{\text{transfer}}$$

- **Seek time:** Time to move the head to the correct track. Average ~3–9 ms for modern drives.
- **Rotational latency:** Time for the target sector to rotate under the head. Average = half a rotation. At 7200 RPM: 60/7200/2 = 4.17 ms average.
- **Transfer time:** Time to read the sector as it passes under the head. At 200 MB/s sequential, a 4 KB sector takes ~20 µs.

The dominant cost is seek + rotation (~8–14 ms average), making random I/O on HDDs 100–1000× slower than sequential I/O. SSDs eliminate both — there is no mechanical movement.

HDDs retain strong economic advantages for **sequential, bulk storage**: price per gigabyte (~$0.02) is 5–10× lower than SATA SSD and 50× lower than NVMe SSD. Archival, backup, and cold storage workloads remain HDD-dominated.

---

### Tape

Magnetic tape is the lowest-cost, highest-latency storage medium in active use. A modern LTO-9 tape cartridge holds 18 TB native (45 TB compressed) and streams at 400 MB/s — competitive with HDDs when streaming. The latency to reach a random position is dominated by mechanical rewinding and seeking, measured in **seconds to minutes**.

Tape is exclusively used for:

- **Archival and backup** (cold data that is written once and rarely read)
- **Compliance retention** (regulatory requirements for multi-year data preservation)
- **Hyperscaler cold storage** (Facebook/Meta, Google, AWS Glacier all use tape at exabyte scale)

The cost per gigabyte (~$0.002) is 10× lower than HDD and effectively irreplaceable for exabyte-scale cold storage.

**LTFS (Linear Tape File System)** standardizes a filesystem layout on tape, allowing tape cartridges to be mounted and accessed with standard file operations, removing the need for proprietary backup software.

---

### The Hierarchy as a Whole

<svg viewBox="0 0 580 420" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <defs> <marker id="tri-dn" markerWidth="10" markerHeight="10" refX="5" refY="10" orient="auto"> <path d="M0,0 L10,0 L5,10 z" fill="#475569"/> </marker> </defs>

<text x="290" y="22" text-anchor="middle" font-size="13" font-weight="bold" fill="#e2e8f0">Storage Hierarchy Triangle</text>

<!-- Triangle levels, widening downward --> <!-- Registers --> <polygon points="290,40 250,70 330,70" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1.5"/> <text x="290" y="62" text-anchor="middle" fill="#93c5fd" font-size="10">Regs</text> <!-- L1 --> <polygon points="250,72 210,102 370,102 330,72" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1.5"/> <text x="290" y="92" text-anchor="middle" fill="#93c5fd">L1 Cache — 32–64 KB</text> <!-- L2 --> <polygon points="210,104 165,134 415,134 370,104" fill="#1e293b" stroke="#3b82f6" stroke-width="1.5"/> <text x="290" y="124" text-anchor="middle" fill="#93c5fd">L2 Cache — 256 KB–2 MB</text> <!-- L3 --> <polygon points="165,136 115,166 465,166 415,136" fill="#1e293b" stroke="#475569" stroke-width="1.5"/> <text x="290" y="156" text-anchor="middle" fill="#e2e8f0">L3 Cache — 4–64 MB</text> <!-- DRAM --> <polygon points="115,168 60,198 520,198 465,168" fill="#0f2027" stroke="#475569" stroke-width="1.5"/> <text x="290" y="188" text-anchor="middle" fill="#e2e8f0">Main Memory (DRAM) — 16 GB–12 TB</text> <!-- Persistent / NVMe --> <polygon points="60,200 20,230 560,230 520,200" fill="#1a1a2e" stroke="#334155" stroke-width="1.5"/> <text x="290" y="220" text-anchor="middle" fill="#94a3b8">NVMe SSD — 1–100 TB</text> <!-- HDD --> <rect x="20" y="232" width="540" height="32" fill="#1a1a2e" stroke="#334155" stroke-width="1.5"/> <text x="290" y="252" text-anchor="middle" fill="#94a3b8">HDD — 1–30 TB</text> <!-- Tape --> <rect x="20" y="266" width="540" height="32" fill="#0f0f1a" stroke="#334155" stroke-width="1.5"/> <text x="290" y="286" text-anchor="middle" fill="#64748b">Tape — 10 TB–1 PB/cartridge</text> <!-- Left labels -->

<text x="12" y="55" text-anchor="end" fill="#34d399" font-size="10">fast</text> <text x="12" y="282" text-anchor="end" fill="#f87171" font-size="10">slow</text> <line x1="15" y1="58" x2="15" y2="278" stroke="#475569" stroke-width="1"/> <polygon points="15,275 11,262 19,262" fill="#f87171"/> <polygon points="15,62 11,75 19,75" fill="#34d399"/>

<!-- Right labels -->

<text x="570" y="55" fill="#f87171" font-size="10">small</text> <text x="570" y="282" fill="#34d399" font-size="10">large</text> <line x1="568" y1="58" x2="568" y2="278" stroke="#475569" stroke-width="1"/> <polygon points="568,62 564,75 572,75" fill="#f87171"/> <polygon points="568,275 564,262 572,262" fill="#34d399"/>

<!-- Transfer arrows and labels at bottom -->

<text x="290" y="325" text-anchor="middle" fill="#64748b" font-size="10">Data movement between levels:</text> <text x="290" y="342" text-anchor="middle" fill="#94a3b8" font-size="10">Registers ↔ Cache: words/cycles via load-store unit</text> <text x="290" y="357" text-anchor="middle" fill="#94a3b8" font-size="10">Cache ↔ DRAM: cache lines (64B) on miss</text> <text x="290" y="372" text-anchor="middle" fill="#94a3b8" font-size="10">DRAM ↔ SSD: pages (4KB) via OS/DMA on page fault</text> <text x="290" y="387" text-anchor="middle" fill="#94a3b8" font-size="10">SSD/HDD ↔ Tape: files/blocks via backup software</text> <text x="290" y="410" text-anchor="middle" fill="#64748b" font-size="10">Unit of transfer grows larger at each lower boundary.</text> </svg>

---

### Data Movement Between Levels

Each boundary between levels transfers data at a different **granularity**:

|Boundary|Transfer unit|Mechanism|
|---|---|---|
|Register ↔ L1 cache|1–64 bytes (load/store width)|Load-store unit, every cycle|
|L1 ↔ L2 cache|64-byte cache line|On L1 miss|
|L2 ↔ L3 cache|64-byte cache line|On L2 miss|
|L3 ↔ DRAM|64-byte cache line (burst of ~8 transfers)|On L3 miss, via memory controller|
|DRAM ↔ SSD|4 KB page|OS demand paging, via DMA|
|SSD ↔ HDD|Files / blocks (application-defined)|Tiered storage software|
|HDD ↔ Tape|Files / tape blocks|Backup software / HSM|

The transfer unit grows at each level because the latency per operation is higher — amortizing the fixed overhead of initiating a transfer requires moving more data per operation. A DRAM access that costs 80 ns amortized over 64 bytes is 1.25 ns/byte. Initiating a tape seek that costs 30 seconds must be amortized over gigabytes to remain efficient.

---

### Hierarchical Storage Management (HSM)

Below the DRAM level, data movement is managed by software rather than hardware. **HSM (Hierarchical Storage Management)** systems automatically migrate data between storage tiers based on access frequency:

- **Hot tier:** NVMe SSD — frequently accessed data
- **Warm tier:** SATA SSD or HDD — moderately accessed data
- **Cold tier:** HDD or object storage — infrequently accessed data
- **Archive tier:** Tape or cloud cold storage — rarely accessed data

HSM policies track last-access time and data size. Files not accessed for a configurable threshold are **migrated** (copied down) to a cheaper tier and may be **stubbed** (replaced by a pointer) at the higher tier. On access, a stub triggers **recall** — the file is promoted back.

Enterprise products (IBM Spectrum Scale/GPFS, NetApp FabricPool, AWS S3 Intelligent Tiering) implement HSM at scale. At the datacenter level, HSM manages petabytes of data across tape libraries, object stores, and flash tiers.

---

### Emerging Technologies and Hierarchy Disruption

Several technologies are actively reshaping the traditional hierarchy:

**CXL (Compute Express Link):** A PCIe 5.0/6.0 based protocol that enables cache-coherent memory expansion. CXL.mem allows a processor to access DRAM attached to a CXL controller with ~200–500 ns latency — slower than local DRAM but accessible as normal memory, not block storage. CXL pools enable memory disaggregation, where a rack's total DRAM is shared across nodes.

**Storage-class memory / Persistent memory:** Byte-addressable, non-volatile memory that collapses the boundary between storage and memory. While Optane is discontinued, research continues into resistive RAM (ReRAM), magnetoresistive RAM (MRAM), and phase-change memory (PCM).

**Computational storage:** Offloading computation (compression, encryption, filtering) to storage devices themselves — NVMe SSDs with embedded ARM cores or FPGAs — reducing data movement by processing near storage.

**Near-data processing / Processing-in-memory (PIM):** Placing compute elements inside or adjacent to DRAM (Samsung HBM-PIM, SK Hynix AiM) to process data where it resides, bypassing the memory bandwidth bottleneck.

---

### Quantifying the Hierarchy: The Memory Mountain

The **memory mountain** is an empirical characterization of a system's effective memory bandwidth as a function of working set size and access stride. It reveals the bandwidth available at each level of the hierarchy:

- **Ridge at small working sets / stride 1:** L1 bandwidth (peak)
- **Plateaus:** L2, L3 bandwidths at corresponding working set sizes
- **Valley at large working sets / large strides:** DRAM bandwidth, heavily penalized by spatial locality loss

The memory mountain is the primary diagnostic tool for understanding whether a workload is compute-bound, cache-bound, or memory-bandwidth-bound — and where in the hierarchy the bottleneck lies.

---

**Conclusion**

The storage hierarchy is not a single design choice but an emergent consequence of the physics and economics of storage technologies. SRAM is fast but consumes transistors and power. DRAM is dense but slow and volatile. Flash is non-volatile and inexpensive but wears out and requires complex indirection. Magnetic media is nearly free per bit but mechanical. No single medium dominates; the hierarchy exists because all are necessary. Locality of reference makes the hierarchy effective: the vast majority of accesses are served by the small, fast upper levels, while the large, slow lower levels hold the full dataset at acceptable cost. Every architectural decision — cache line size, prefetch depth, page size, I/O queue depth — is ultimately an optimization of data movement across this hierarchy.

**Next Steps**

Proceed to **HDD Architecture** and **SSD Architecture** for detailed treatment of the lower storage levels, or to **Cache Fundamentals** for the upper levels. For the system-level view of how the OS manages the boundary between DRAM and storage, proceed to **Virtual Memory** and **Paging and Page Tables**.

---

