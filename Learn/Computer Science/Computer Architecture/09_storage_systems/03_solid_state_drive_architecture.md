## Solid-State Drive Architecture


An SSD stores data in arrays of NAND flash memory cells and presents a block-storage interface to the host. The translation layer between the host's logical block address (LBA) space and the physical NAND array — and the management of NAND's fundamental constraints (erase-before-write, limited endurance, read disturb) — constitutes the majority of SSD design complexity. The flash translation layer (FTL) is the central intellectual content of SSD architecture.

---

### NAND Flash Cell Physics

A NAND flash cell is a floating-gate (or charge-trap) transistor. Charge stored on the electrically isolated floating gate shifts the transistor's threshold voltage Vt. The cell is read by applying a reference voltage and sensing whether the transistor conducts.

**SLC (Single-Level Cell):** 1 bit per cell. Two Vt levels (erased = high Vt → logical 1; programmed = low Vt → logical 0 by convention). Highest endurance (~100k P/E cycles), fastest program/read, lowest density.

**MLC (Multi-Level Cell):** 2 bits per cell. Four Vt levels. The Vt distribution of each level must remain narrow enough to be reliably distinguished; tighter manufacturing tolerances and slower programming (iterative verify-program loops, known as incremental step pulse programming — ISPP).

**TLC (Triple-Level Cell):** 3 bits per cell. Eight Vt levels. Dominant in consumer and enterprise SSDs since ~2017. Endurance ~1k–3k P/E cycles. Slower programming; wider Vt distributions require stronger ECC.

**QLC (Quad-Level Cell):** 4 bits per cell. Sixteen Vt levels. Very narrow margins between levels; requires powerful LDPC codes and aggressive read-retry. Endurance ~100–500 P/E cycles. Used in read-intensive and high-capacity applications.

The fundamental NAND constraint: **erase is performed on a block** (64–512 pages), not a page. Programming (write) is performed on a **page** (typically 4–16 KB). A page cannot be reprogrammed without first erasing its entire block. This asymmetry — page-granularity write, block-granularity erase — is the root cause of write amplification and the need for an FTL.

---

### Physical Organization

```
Die
└── Plane (2–4 per die)
    └── Block (thousands per plane; erase unit)
        └── Page (64–512 per block; program/read unit, 4–16 KB)
            └── Cell (1–4 bits)
```

**Die:** one silicon chip. Multiple dies are stacked in a package (3D NAND) or on a PCB.

**Plane:** an independent array with its own page register and sense amplifiers. Operations can be executed across planes simultaneously — a **multi-plane operation** reads or programs one page per plane concurrently, multiplying bandwidth. A constraint: multi-plane operations must target pages at the same offset within their respective blocks.

**Block:** the erase unit, typically 4–32 MB for TLC/QLC NAND. Block erase takes 2–5 ms — orders of magnitude slower than a page read (~50–100 µs) or program (~200–2000 µs depending on cell type).

**3D NAND (V-NAND):** cells are stacked vertically in layers (64–232 layers as of 2024). Each layer is a wordline; bitlines run vertically through all layers via cylindrical charge-trap structures. 3D stacking achieves higher density without shrinking cell dimensions, preserving endurance and reliability relative to planar scaling.

---

### SSD Internal Architecture---

### Flash Translation Layer

The FTL is firmware running on the SSD controller's embedded processor(s). It presents a logical block interface to the host while managing the physical NAND array. Its responsibilities decompose into four subsystems.

#### Logical-to-Physical Mapping (L2P)

Every host LBA maps to a **physical page address (PPA)**: a tuple (channel, die, plane, block, page). The FTL maintains a mapping table — typically one entry per 4 KB logical page — stored in DRAM and persisted to a reserved NAND region.

For a 1 TB SSD with 4 KB pages: 256 million entries × 4 bytes per entry = 1 GB of mapping table. This is why high-capacity SSDs require ≥1 GB of DRAM. DRAM-less SSDs use host memory buffer (HMB) — a portion of system DRAM accessed over PCIe — or a hierarchical mapping scheme (page-level mapping in a hot cache, block-level elsewhere).

**Mapping granularity variants:**

- **Page-level mapping:** full flexibility; any LBA update writes to any free page. Maximum write distribution. Table size = one entry per logical page. Standard in performance SSDs.
- **Block-level mapping:** one entry per logical block. Table is 512× smaller but updates require full-block copy-on-write (read entire block, modify page, write new block). High write amplification.
- **Hybrid mapping (FAST, DFTL):** a small log area uses page-level mapping; the bulk uses block-level mapping. Log entries are periodically merged into the block map. Balances table size against write amplification.

#### Garbage Collection

NAND's erase-before-write constraint means that an overwritten page is not freed immediately — the old physical location is marked **stale** (invalid) in the mapping table, but the page's storage cannot be reclaimed until the entire block is erased. GC is the process of reclaiming stale pages.

**GC procedure:**

1. Select a **victim block** from those with the highest proportion of stale pages
2. Copy all valid pages from the victim block to free pages elsewhere
3. Erase the victim block, returning it to the free pool
4. Update the L2P mapping table for relocated pages

Every valid page copy in step 2 is a write not requested by the host — this is **write amplification**. The write amplification factor (WAF) is:

$$\text{WAF} = \frac{\text{total NAND writes}}{\text{host writes}}$$

WAF = 1 is ideal (no amplification). Under worst-case random 4 KB writes with a full drive, WAF for TLC NAND can reach 10–30×, consuming endurance rapidly.

**Victim selection policies:**

- **Greedy:** select the block with the most invalid pages. Minimizes pages to copy but can concentrate writes on recently written blocks.
- **Cost-benefit (CB):** weighs invalid page count against block age. Avoids repeatedly selecting recently written blocks, reducing WAF and improving wear distribution.
- **DGWO / CAT variants:** incorporate temperature (hot/cold data separation) into selection.

**Over-provisioning (OP):** the SSD reserves a fraction of raw NAND capacity (typically 7–28%) not visible to the host. OP provides free blocks for GC without stalling host I/O and directly reduces WAF — more free space means GC can be more selective about victim choice.

$$
\text{OP%} = \frac{\text{raw capacity} - \text{user capacity}}{\text{user capacity}} \times 100
$$

#### Wear Leveling

NAND blocks have a finite erase cycle limit (P/E cycles). GC naturally concentrates writes on blocks containing hot (frequently overwritten) data, leaving cold (rarely written) blocks nearly unworn. Without intervention, hot-block P/E counts exhaust endurance while cold blocks remain underused.

**Dynamic wear leveling:** directs new writes to the least-worn free block. Addresses hot data but does not move cold data.

**Static wear leveling:** periodically relocates cold data from low-wear blocks to high-wear blocks, freeing the fresh blocks for write traffic. Forces a write amplification cost (copying cold data) but equalizes wear across the entire NAND array. Essential for approaching rated endurance on drives with mixed hot/cold workloads.

Wear leveling effectiveness is measured by the P/E count variance across all blocks — ideal leveling minimizes variance.

#### ECC Engine

Raw NAND bit error rate (RBER) increases with P/E cycle count, retention time, and read disturb. The ECC engine corrects errors before data is returned to the host.

**BCH codes:** used in earlier SSDs (SLC/MLC era). Relatively simple hardware; correction capability of t bits per codeword, with code length and redundancy scaling with t.

**LDPC codes:** standard in TLC/QLC SSDs. Near-Shannon-limit correction capability; iterative belief-propagation decoding. Correction capability of 40–120+ bits per kilobit codeword, sufficient for QLC NAND's wide Vt distributions. Decoding latency increases with iteration count — a tradeoff managed by early-termination heuristics.

**Read retry:** when LDPC decoding fails, the controller initiates read retry — re-sensing the page at multiple shifted reference voltages to find one that reduces errors below the ECC correction threshold. Each retry adds ~50–100 µs latency. Exhausting all retry levels produces an uncorrectable error (UBER).

**RAID-like protection across dies:** enterprise SSDs implement intra-drive data protection — XOR parity across multiple dies (analogous to RAID-5 within the drive). A complete die failure is recoverable. Consumer SSDs generally do not implement this.

---

### Parallelism Architecture

SSD performance depends on exploiting multiple levels of parallelism within the NAND array simultaneously:

| Level             | Unit            | Mechanism                                                       |
| ----------------- | --------------- | --------------------------------------------------------------- |
| Channel           | Independent bus | Multiple channels transfer data concurrently                    |
| Die (chip-enable) | Independent die | Multiple dies on one channel accessed in interleave             |
| Plane             | Within a die    | Multi-plane operations: simultaneous program/read across planes |
| Bank              | Within a plane  | Some NAND supports internal bank interleaving                   |

An SSD with 8 channels × 4 dies/channel × 2 planes/die = 64-way parallelism. Effective bandwidth = single-plane bandwidth × 64, subject to scheduling overhead.

The NAND scheduler maintains a command queue per die and issues commands to keep all channels and dies busy simultaneously, hiding the latency of individual NAND operations behind parallel execution across other dies.

---

### Write Path and Caching

**Write buffer (DRAM):** incoming host writes are absorbed into a DRAM write buffer. The FTL coalesces small writes and aligns them to page boundaries before issuing NAND programs. This converts random small writes to sequential page-aligned writes, reducing WAF and improving throughput.

**Power-loss protection (PLP):** enterprise and prosumer SSDs include capacitors (supercapacitors or tantalum arrays) sufficient to flush the DRAM write buffer to NAND on power loss. Without PLP, a power failure after a host write acknowledge but before NAND program completion causes data loss. Consumer SSDs without PLP rely on host-side power-loss guarantees (UPS, orderly shutdown) or accept the risk.

**SLC cache:** many TLC/QLC SSDs program a portion of NAND in SLC mode (1 bit/cell regardless of physical cell capability) as a fast-write staging area. SLC programming is ~4–8× faster than TLC and produces lower WAF for bursty writes. Data is later **folded** (migrated from SLC to TLC/QLC) during idle periods. When the SLC cache is exhausted, write performance drops to native TLC/QLC speed — the common cause of sustained-write performance collapse in consumer SSDs.

---

### Host Interface and Queue Depth

**NVMe (Non-Volatile Memory Express):** protocol designed for flash over PCIe. Supports up to 65,535 I/O queues with up to 65,535 commands per queue, per namespace. Eliminates the serialization bottleneck of AHCI (SATA), which supports one queue of 32 commands. Queue depth matters because NAND latency is high (~100 µs) and parallelism requires many simultaneous outstanding commands to keep all dies busy.

**SATA/AHCI:** single queue, 32 commands, 600 MB/s interface bandwidth. Bottlenecks both queue depth and bandwidth for high-performance NAND. Retained for compatibility.

**NVMe-oF (over Fabrics):** extends NVMe over RDMA (RoCE, iWARP) or Fibre Channel, enabling disaggregated flash storage accessible at near-local latency. Relevant for data center architectures.

---

### Endurance, Retention, and Reliability

**Endurance** is expressed in drive writes per day (DWPD) or total bytes written (TBW) over the rated lifetime:

$$\text{TBW} = \frac{\text{raw capacity} \times \text{P/E cycles} \times \text{OP adjustment}}{\text{WAF}}$$

A 1 TB TLC SSD with 3,000 P/E cycles, 7% OP, and WAF of 3 yields roughly 1 PB TBW — a typical consumer rating.

**Retention:** data retention degrades with P/E cycle count. A fresh cell retains charge for >10 years; a worn cell (at rated P/E limit) retains for ~1 year at room temperature. Retention decreases further at elevated temperature. Enterprise SSDs rated for high DWPD sacrifice retention for endurance (intentionally running cells harder).

**Read disturb:** sensing a cell's Vt requires applying a pass voltage to neighboring cells on the same wordline. Over many reads of adjacent pages, charge leaks into the floating gates of unread cells, shifting their Vt distributions. The FTL tracks read counts per block and proactively refreshes (read-scrubbing) blocks approaching the read disturb threshold.

---

### Firmware Persistence and Power-Loss Recovery

The L2P mapping table is the SSD's most critical data structure. On clean shutdown it is flushed to a reserved NAND region. On sudden power loss, the in-DRAM mapping table is lost. Recovery requires **replay**: the FTL scans the NAND OOB (out-of-band) area — spare bytes appended to each page containing the logical address written there — to reconstruct the mapping table. This scan is O(total pages) and can take several seconds on large drives; it is the source of the "rebuilding" delay observed after unexpected power loss.

---

**Next Steps:** NVMe command set and queue pair mechanics · ZNS (Zoned Namespace) SSDs and host-managed GC · Computational storage and in-drive processing · Open-channel SSDs · RAID levels and SSD-aware RAID · PCIe 5.0 / CXL-attached flash.

---

