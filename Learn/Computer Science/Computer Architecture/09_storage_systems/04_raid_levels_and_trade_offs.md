## RAID Levels and Trade-offs


RAID (Redundant Array of Independent Disks) distributes data across multiple physical drives to achieve some combination of increased throughput, increased capacity utilization, and fault tolerance. No single RAID level optimizes all three simultaneously — every level represents a specific trade-off point.

---

### Foundational Concepts

**Striping:** Data is split into chunks (stripe units) distributed across multiple drives. Enables parallel I/O — a single logical read or write is serviced by multiple drives simultaneously, increasing throughput proportionally to drive count (ideally).

**Mirroring:** Identical data is written to two or more drives. Reads can be serviced by either copy; writes must update all copies. Provides redundancy at the cost of 50% capacity efficiency.

**Parity:** An XOR-derived check value stored separately from data. Given N data blocks D₁…Dₙ, parity P = D₁ ⊕ D₂ ⊕ … ⊕ Dₙ. Any one lost block can be reconstructed by XORing the remaining blocks with P. Parity provides redundancy at lower capacity cost than mirroring but with write overhead.

**XOR reconstruction:** If drive k fails, its content is recovered as:

```
Dk = D1 ⊕ D2 ⊕ ... ⊕ D(k-1) ⊕ D(k+1) ⊕ ... ⊕ Dn ⊕ P
```

This requires reading all surviving drives — reconstruction I/O load is proportional to array size.

**Stripe unit size:** The granularity of data distribution per drive per stripe. Small stripe units increase parallelism for large sequential I/O but increase seek overhead for random small I/O (more drives involved per request). Large stripe units reduce cross-drive parallelism but keep small random I/O local to one drive.

---

### RAID 0 — Striping, No Redundancy

Data is striped across all N drives with no redundancy information.

<svg viewBox="0 0 460 160" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="10"> <text x="230" y="16" text-anchor="middle" fill="#cdd6f4" font-size="11" font-weight="bold">RAID 0 — 4 drives</text> <rect x="20" y="25" width="80" height="120" rx="3" fill="#1e1e2e" stroke="#89b4fa" stroke-width="1.3"/> <text x="60" y="42" text-anchor="middle" fill="#89b4fa">Drive 0</text> <rect x="25" y="50" width="70" height="22" rx="2" fill="#313244" stroke="#a6e3a1" stroke-width="0.9"/> <text x="60" y="65" text-anchor="middle" fill="#a6e3a1">A0</text> <rect x="25" y="76" width="70" height="22" rx="2" fill="#313244" stroke="#a6e3a1" stroke-width="0.9"/> <text x="60" y="91" text-anchor="middle" fill="#a6e3a1">A4</text> <rect x="25" y="102" width="70" height="22" rx="2" fill="#313244" stroke="#a6e3a1" stroke-width="0.9"/> <text x="60" y="117" text-anchor="middle" fill="#a6e3a1">A8</text> <rect x="130" y="25" width="80" height="120" rx="3" fill="#1e1e2e" stroke="#89b4fa" stroke-width="1.3"/> <text x="170" y="42" text-anchor="middle" fill="#89b4fa">Drive 1</text> <rect x="135" y="50" width="70" height="22" rx="2" fill="#313244" stroke="#cba6f7" stroke-width="0.9"/> <text x="170" y="65" text-anchor="middle" fill="#cba6f7">A1</text> <rect x="135" y="76" width="70" height="22" rx="2" fill="#313244" stroke="#cba6f7" stroke-width="0.9"/> <text x="170" y="91" text-anchor="middle" fill="#cba6f7">A5</text> <rect x="135" y="102" width="70" height="22" rx="2" fill="#313244" stroke="#cba6f7" stroke-width="0.9"/> <text x="170" y="117" text-anchor="middle" fill="#cba6f7">A9</text> <rect x="240" y="25" width="80" height="120" rx="3" fill="#1e1e2e" stroke="#89b4fa" stroke-width="1.3"/> <text x="280" y="42" text-anchor="middle" fill="#89b4fa">Drive 2</text> <rect x="245" y="50" width="70" height="22" rx="2" fill="#313244" stroke="#fab387" stroke-width="0.9"/> <text x="280" y="65" text-anchor="middle" fill="#fab387">A2</text> <rect x="245" y="76" width="70" height="22" rx="2" fill="#313244" stroke="#fab387" stroke-width="0.9"/> <text x="280" y="91" text-anchor="middle" fill="#fab387">A6</text> <rect x="245" y="102" width="70" height="22" rx="2" fill="#313244" stroke="#fab387" stroke-width="0.9"/> <text x="280" y="117" text-anchor="middle" fill="#fab387">A10</text> <rect x="350" y="25" width="80" height="120" rx="3" fill="#1e1e2e" stroke="#89b4fa" stroke-width="1.3"/> <text x="390" y="42" text-anchor="middle" fill="#89b4fa">Drive 3</text> <rect x="355" y="50" width="70" height="22" rx="2" fill="#313244" stroke="#f38ba8" stroke-width="0.9"/> <text x="390" y="65" text-anchor="middle" fill="#f38ba8">A3</text> <rect x="355" y="76" width="70" height="22" rx="2" fill="#313244" stroke="#f38ba8" stroke-width="0.9"/> <text x="390" y="91" text-anchor="middle" fill="#f38ba8">A7</text> <rect x="355" y="102" width="70" height="22" rx="2" fill="#313244" stroke="#f38ba8" stroke-width="0.9"/> <text x="390" y="117" text-anchor="middle" fill="#f38ba8">A11</text> </svg>

|Property|Value|
|---|---|
|Minimum drives|2|
|Usable capacity|N × drive size (100%)|
|Fault tolerance|None — any single drive failure loses all data|
|Read throughput|Up to N× single drive|
|Write throughput|Up to N× single drive|
|Read IOPS|Up to N× (large I/O); single drive (small random I/O to one drive)|

**Write penalty:** None — no parity computation required.

**Failure risk:** RAID 0 increases total failure probability. With N drives each having independent failure probability p, the array fails if any drive fails: P(failure) = 1 − (1−p)^N. A 4-drive RAID 0 array is approximately 4× more likely to suffer data loss than a single drive.

**Use case:** Scratch space, caches, video editing scratch disks — workloads requiring maximum throughput with externally managed data protection (backups).

---

### RAID 1 — Mirroring

Every drive has an exact mirror. The minimum configuration is 2 drives. All writes go to all copies; reads can be distributed across mirrors.

|Property|Value|
|---|---|
|Minimum drives|2|
|Usable capacity|1/N × total raw (50% for 2-drive)|
|Fault tolerance|N−1 drive failures (all but one copy can fail)|
|Read throughput|Up to N× (reads distributed across mirrors)|
|Write throughput|Single drive (all mirrors must be written)|
|Write IOPS|Same as single drive|

**Write behavior:** Both drives must complete the write before the operation is acknowledged (in synchronous mode). Write throughput is bounded by the slowest mirror.

**Read behavior:** The controller can service reads from any mirror. For a 2-drive RAID 1, read IOPS can approach 2×. For sequential throughput, most controllers read from one drive only — distributing reads requires splitting the logical address space across mirrors or using per-request round-robin, which some implementations support.

**Rebuild:** On failure and replacement, the surviving mirror is copied entirely to the new drive. Rebuild time is proportional to drive capacity and sequential read/write speed — for multi-TB HDDs this can exceed 24 hours, during which the array has no redundancy.

**Use case:** OS volumes, databases requiring simple redundancy with fast rebuild, situations where capacity cost is acceptable.

---

### RAID 5 — Distributed Parity

Data and parity are striped across all N drives, with parity distributed so no single drive holds all parity blocks. Requires minimum 3 drives. Tolerates exactly one drive failure.

<svg viewBox="0 0 460 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="10"> <text x="230" y="16" text-anchor="middle" fill="#cdd6f4" font-size="11" font-weight="bold">RAID 5 — 4 drives, distributed parity</text> <rect x="20" y="25" width="80" height="165" rx="3" fill="#1e1e2e" stroke="#89b4fa" stroke-width="1.3"/> <text x="60" y="42" text-anchor="middle" fill="#89b4fa">Drive 0</text> <rect x="25" y="50" width="70" height="22" rx="2" fill="#313244" stroke="#a6e3a1" stroke-width="0.9"/> <text x="60" y="65" text-anchor="middle" fill="#a6e3a1">A0</text> <rect x="25" y="76" width="70" height="22" rx="2" fill="#313244" stroke="#a6e3a1" stroke-width="0.9"/> <text x="60" y="91" text-anchor="middle" fill="#a6e3a1">B0</text> <rect x="25" y="102" width="70" height="22" rx="2" fill="#313244" stroke="#f38ba8" stroke-width="0.9"/> <text x="60" y="117" text-anchor="middle" fill="#f38ba8">Pc</text> <rect x="25" y="128" width="70" height="22" rx="2" fill="#313244" stroke="#a6e3a1" stroke-width="0.9"/> <text x="60" y="143" text-anchor="middle" fill="#a6e3a1">D0</text> <rect x="25" y="154" width="70" height="22" rx="2" fill="#313244" stroke="#a6e3a1" stroke-width="0.9"/> <text x="60" y="169" text-anchor="middle" fill="#a6e3a1">E0</text> <rect x="130" y="25" width="80" height="165" rx="3" fill="#1e1e2e" stroke="#89b4fa" stroke-width="1.3"/> <text x="170" y="42" text-anchor="middle" fill="#89b4fa">Drive 1</text> <rect x="135" y="50" width="70" height="22" rx="2" fill="#313244" stroke="#cba6f7" stroke-width="0.9"/> <text x="170" y="65" text-anchor="middle" fill="#cba6f7">A1</text> <rect x="135" y="76" width="70" height="22" rx="2" fill="#313244" stroke="#f38ba8" stroke-width="0.9"/> <text x="170" y="91" text-anchor="middle" fill="#f38ba8">Pb</text> <rect x="135" y="102" width="70" height="22" rx="2" fill="#313244" stroke="#cba6f7" stroke-width="0.9"/> <text x="170" y="117" text-anchor="middle" fill="#cba6f7">C0</text> <rect x="135" y="128" width="70" height="22" rx="2" fill="#313244" stroke="#cba6f7" stroke-width="0.9"/> <text x="170" y="143" text-anchor="middle" fill="#cba6f7">D1</text> <rect x="135" y="154" width="70" height="22" rx="2" fill="#313244" stroke="#f38ba8" stroke-width="0.9"/> <text x="170" y="169" text-anchor="middle" fill="#f38ba8">Pe</text> <rect x="240" y="25" width="80" height="165" rx="3" fill="#1e1e2e" stroke="#89b4fa" stroke-width="1.3"/> <text x="280" y="42" text-anchor="middle" fill="#89b4fa">Drive 2</text> <rect x="245" y="50" width="70" height="22" rx="2" fill="#313244" stroke="#f38ba8" stroke-width="0.9"/> <text x="280" y="65" text-anchor="middle" fill="#f38ba8">Pa</text> <rect x="245" y="76" width="70" height="22" rx="2" fill="#313244" stroke="#fab387" stroke-width="0.9"/> <text x="280" y="91" text-anchor="middle" fill="#fab387">B1</text> <rect x="245" y="102" width="70" height="22" rx="2" fill="#313244" stroke="#fab387" stroke-width="0.9"/> <text x="280" y="117" text-anchor="middle" fill="#fab387">C1</text> <rect x="245" y="128" width="70" height="22" rx="2" fill="#313244" stroke="#f38ba8" stroke-width="0.9"/> <text x="280" y="143" text-anchor="middle" fill="#f38ba8">Pd</text> <rect x="245" y="154" width="70" height="22" rx="2" fill="#313244" stroke="#fab387" stroke-width="0.9"/> <text x="280" y="169" text-anchor="middle" fill="#fab387">E1</text> <rect x="350" y="25" width="80" height="165" rx="3" fill="#1e1e2e" stroke="#89b4fa" stroke-width="1.3"/> <text x="390" y="42" text-anchor="middle" fill="#89b4fa">Drive 3</text> <rect x="355" y="50" width="70" height="22" rx="2" fill="#313244" stroke="#fab387" stroke-width="0.9"/> <text x="390" y="65" text-anchor="middle" fill="#fab387">A2</text> <rect x="355" y="76" width="70" height="22" rx="2" fill="#313244" stroke="#fab387" stroke-width="0.9"/> <text x="390" y="91" text-anchor="middle" fill="#fab387">B2</text> <rect x="355" y="102" width="70" height="22" rx="2" fill="#313244" stroke="#fab387" stroke-width="0.9"/> <text x="390" y="117" text-anchor="middle" fill="#fab387">C2</text> <rect x="355" y="128" width="70" height="22" rx="2" fill="#313244" stroke="#fab387" stroke-width="0.9"/> <text x="390" y="143" text-anchor="middle" fill="#fab387">D2</text> <rect x="355" y="154" width="70" height="22" rx="2" fill="#313244" stroke="#fab387" stroke-width="0.9"/> <text x="390" y="169" text-anchor="middle" fill="#fab387">E2</text> </svg>

|Property|Value|
|---|---|
|Minimum drives|3|
|Usable capacity|(N−1) × drive size|
|Fault tolerance|1 drive failure|
|Read throughput|Up to (N−1)×|
|Write throughput|Reduced — parity write penalty|
|Small write IOPS|Significantly degraded|

#### RAID 5 Write Penalty

Every small write (smaller than a full stripe) requires a **read-modify-write cycle**:

1. Read old data block
2. Read old parity block
3. Compute new parity: P_new = P_old ⊕ D_old ⊕ D_new
4. Write new data block
5. Write new parity block

This is the **RAID 5 write penalty**: each logical write generates 4 I/O operations (2 reads + 2 writes). For write-heavy random I/O workloads, this is severe — a controller capable of 10,000 write IOPS in RAID 0 may deliver 2,500 effective IOPS in RAID 5 under the same random write load.

A full-stripe write (writing all data blocks in one stripe simultaneously) avoids the read-modify-write: new parity is computed directly from new data, requiring only N writes.

#### Degraded Mode and Rebuild Risk

During rebuild after a drive failure, every read of a block on a non-failed drive triggers reconstruction reads of all other surviving drives to regenerate missing data. This saturates all remaining drives with read I/O simultaneously.

The **URE (Unrecoverable Read Error) problem:** HDDs have a typical URE rate of 1 sector error per 10¹⁴ bits read. During a full rebuild of a 4 TB drive, approximately 3.2 × 10¹³ bits are read. The probability of encountering a URE during rebuild:

```
P(URE during rebuild) ≈ 1 − (1 − 1/10^14)^(3.2×10^13) ≈ 27%
```

A URE during rebuild of a single-parity RAID 5 array means the array cannot reconstruct the failed drive's data — total data loss. This risk increases with drive capacity and is the primary reason RAID 5 is considered unsuitable for arrays using large-capacity HDDs.

---

### RAID 6 — Dual Distributed Parity

Extends RAID 5 with two independent parity blocks per stripe using two different parity schemes (typically standard XOR parity P and a Reed-Solomon derived Q parity). Tolerates any two simultaneous drive failures.

|Property|Value|
|---|---|
|Minimum drives|4|
|Usable capacity|(N−2) × drive size|
|Fault tolerance|2 simultaneous drive failures|
|Read throughput|Up to (N−2)×|
|Write throughput|Worse than RAID 5 — 6 I/Os per small write (2 reads + 4 writes)|

**Q parity computation** uses Galois Field arithmetic (GF(2⁸)) rather than simple XOR, making RAID 6 parity computation more CPU-intensive than RAID 5. Modern RAID controllers and software implementations use hardware acceleration (SIMD instructions) for GF multiplication.

**Write penalty:** 6 I/O operations per small random write (read old data, read old P, read old Q, write new data, write new P, write new Q). RAID 6 write IOPS under random small write load is approximately 1/6 of the raw drive IOPS — worse than RAID 5's 1/4.

**Use case:** High-capacity HDD arrays where rebuild URE risk makes RAID 5 unacceptable. Standard recommendation for enterprise HDD arrays with drive capacities ≥ 2–4 TB.

---

### RAID 10 — Striped Mirrors

RAID 10 (also written RAID 1+0) stripes data across mirrored pairs. Each mirror pair is a RAID 1; the pairs are combined with RAID 0 striping.

<svg viewBox="0 0 460 180" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="10"> <text x="230" y="16" text-anchor="middle" fill="#cdd6f4" font-size="11" font-weight="bold">RAID 10 — 4 drives (2 mirror pairs, striped)</text> <!-- Mirror pair 0 -->

<text x="115" y="38" text-anchor="middle" fill="#fab387" font-size="10">Mirror pair 0</text> <rect x="20" y="45" width="80" height="120" rx="3" fill="#1e1e2e" stroke="#a6e3a1" stroke-width="1.3"/> <text x="60" y="62" text-anchor="middle" fill="#a6e3a1">Drive 0</text> <rect x="25" y="70" width="70" height="22" rx="2" fill="#313244" stroke="#a6e3a1" stroke-width="0.9"/> <text x="60" y="85" text-anchor="middle" fill="#a6e3a1">A0</text> <rect x="25" y="96" width="70" height="22" rx="2" fill="#313244" stroke="#a6e3a1" stroke-width="0.9"/> <text x="60" y="111" text-anchor="middle" fill="#a6e3a1">A2</text> <rect x="25" y="122" width="70" height="22" rx="2" fill="#313244" stroke="#a6e3a1" stroke-width="0.9"/> <text x="60" y="137" text-anchor="middle" fill="#a6e3a1">A4</text>

<rect x="130" y="45" width="80" height="120" rx="3" fill="#1e1e2e" stroke="#a6e3a1" stroke-width="1.3"/> <text x="170" y="62" text-anchor="middle" fill="#a6e3a1">Drive 1</text> <rect x="135" y="70" width="70" height="22" rx="2" fill="#313244" stroke="#a6e3a1" stroke-width="0.9"/> <text x="170" y="85" text-anchor="middle" fill="#a6e3a1">A0′</text> <rect x="135" y="96" width="70" height="22" rx="2" fill="#313244" stroke="#a6e3a1" stroke-width="0.9"/> <text x="170" y="111" text-anchor="middle" fill="#a6e3a1">A2′</text> <rect x="135" y="122" width="70" height="22" rx="2" fill="#313244" stroke="#a6e3a1" stroke-width="0.9"/> <text x="170" y="137" text-anchor="middle" fill="#a6e3a1">A4′</text> <!-- Mirror arrow --> <line x1="100" y1="105" x2="130" y2="105" stroke="#fab387" stroke-width="1.1" stroke-dasharray="3,2"/> <text x="115" y="100" text-anchor="middle" fill="#fab387" font-size="8">mirror</text> <!-- Mirror pair 1 -->

<text x="345" y="38" text-anchor="middle" fill="#cba6f7" font-size="10">Mirror pair 1</text> <rect x="250" y="45" width="80" height="120" rx="3" fill="#1e1e2e" stroke="#cba6f7" stroke-width="1.3"/> <text x="290" y="62" text-anchor="middle" fill="#cba6f7">Drive 2</text> <rect x="255" y="70" width="70" height="22" rx="2" fill="#313244" stroke="#cba6f7" stroke-width="0.9"/> <text x="290" y="85" text-anchor="middle" fill="#cba6f7">A1</text> <rect x="255" y="96" width="70" height="22" rx="2" fill="#313244" stroke="#cba6f7" stroke-width="0.9"/> <text x="290" y="111" text-anchor="middle" fill="#cba6f7">A3</text> <rect x="255" y="122" width="70" height="22" rx="2" fill="#313244" stroke="#cba6f7" stroke-width="0.9"/> <text x="290" y="137" text-anchor="middle" fill="#cba6f7">A5</text>

<rect x="360" y="45" width="80" height="120" rx="3" fill="#1e1e2e" stroke="#cba6f7" stroke-width="1.3"/> <text x="400" y="62" text-anchor="middle" fill="#cba6f7">Drive 3</text> <rect x="365" y="70" width="70" height="22" rx="2" fill="#313244" stroke="#cba6f7" stroke-width="0.9"/> <text x="400" y="85" text-anchor="middle" fill="#cba6f7">A1′</text> <rect x="365" y="96" width="70" height="22" rx="2" fill="#313244" stroke="#cba6f7" stroke-width="0.9"/> <text x="400" y="111" text-anchor="middle" fill="#cba6f7">A3′</text> <rect x="365" y="122" width="70" height="22" rx="2" fill="#313244" stroke="#cba6f7" stroke-width="0.9"/> <text x="400" y="137" text-anchor="middle" fill="#cba6f7">A5′</text> <line x1="330" y1="105" x2="360" y2="105" stroke="#cba6f7" stroke-width="1.1" stroke-dasharray="3,2"/> <text x="345" y="100" text-anchor="middle" fill="#cba6f7" font-size="8">mirror</text> <!-- Stripe arrows --> <line x1="170" y1="160" x2="250" y2="160" stroke="#89b4fa" stroke-width="1.2"/> <text x="210" y="175" text-anchor="middle" fill="#89b4fa" font-size="9">stripe</text> </svg>

|Property|Value|
|---|---|
|Minimum drives|4 (must be even)|
|Usable capacity|50% of total raw|
|Fault tolerance|One drive per mirror pair (worst case: 1; best case: N/2)|
|Read throughput|Up to N× (reads from any mirror)|
|Write throughput|Up to N/2× (limited by mirror pairs)|
|Write IOPS|High — no parity computation|

**Fault tolerance nuance:** RAID 10 survives the failure of one drive per mirror pair. In a 4-drive RAID 10, it can survive 2 drive failures if they are in different pairs. It fails if both drives in any single pair fail simultaneously — probability depends on drive correlation and array rebuild time.

**No write penalty:** Unlike RAID 5/6, RAID 10 has no parity computation. Each write is simply sent to both drives in the mirror pair. Write IOPS approaches that of a single drive (constrained by the slower mirror member), not a fraction of it.

**Rebuild:** Rebuilding a failed RAID 10 drive reads only the surviving mirror in that pair — not the entire array. Rebuild I/O is proportional to drive capacity, not array size. Rebuild is faster and imposes less load on the remaining drives than RAID 5/6.

**Use case:** High-performance databases, write-intensive transactional workloads, any application requiring both high IOPS and redundancy where capacity efficiency is secondary.

---

### RAID 01 vs. RAID 10 Distinction

RAID 01 (0+1) stripes first, then mirrors the stripe sets. RAID 10 (1+0) mirrors first, then stripes the mirrors.

The distinction matters for fault tolerance. In RAID 01 with 4 drives:

- One drive fails → entire stripe set it belongs to is lost → the surviving stripe set is now carrying the full load with no redundancy
- A second failure on the surviving stripe set → total array loss

In RAID 10, a second failure must be in the same mirror pair as the first to cause array loss. RAID 10 is strictly more fault-tolerant than RAID 01 for equal drive counts and is preferred in all production deployments.

---

### RAID 50 and RAID 60

Nested levels combining parity RAID with striping:

**RAID 50:** Two or more RAID 5 arrays striped together. Improves read/write throughput over a single RAID 5 group and reduces per-group rebuild time. Tolerates one failure per RAID 5 sub-group.

**RAID 60:** Two or more RAID 6 arrays striped together. Tolerates two failures per sub-group. Used in very large HDD arrays where maximum redundancy and throughput are both required.

In both cases, a second failure within the same sub-group before rebuild completes causes data loss for that sub-group.

---

### Comparative Summary

|Level|Min Drives|Usable Capacity|Fault Tolerance|Read Perf|Write Perf|Write Penalty|Rebuild Load|
|---|---|---|---|---|---|---|---|
|RAID 0|2|100%|0 drives|N×|N×|None|N/A|
|RAID 1|2|50%|N−1 drives|Up to N×|1×|None|Low (mirror only)|
|RAID 5|3|(N−1)/N|1 drive|(N−1)×|Degraded|4 I/Os/write|High (full array)|
|RAID 6|4|(N−2)/N|2 drives|(N−2)×|Severely degraded|6 I/Os/write|High (full array)|
|RAID 10|4|50%|1 per pair|N×|N/2×|None|Low (mirror only)|

---

### Software vs. Hardware RAID

**Hardware RAID:** Dedicated RAID controller with onboard processor and cache (battery-backed or flash-backed). Offloads parity computation from the host CPU. Cache absorbs write bursts and enables write coalescing (accumulating partial stripe writes to perform full-stripe writes). The cache is the primary mechanism that makes RAID 5/6 write performance acceptable in practice.

**Software RAID (mdraid, ZFS, Storage Spaces):** Parity computed by the host CPU. Modern CPUs with AVX2/AVX-512 perform XOR and GF parity computation at memory bandwidth speeds — software RAID parity overhead is minimal on current hardware. Software RAID has no hardware cache but benefits from the OS page cache.

**HBA (Host Bus Adapter) with fake RAID:** The HBA presents a RAID volume but performs all computation in a driver on the host CPU. Offers no benefit over software RAID and typically worse flexibility. Generally not recommended for production use.

---

### RAID Is Not Backup

RAID provides availability against drive failure. It does not protect against:

- Accidental deletion or overwrite (immediately reflected across all mirrors/parity)
- Ransomware or filesystem corruption (propagated to all members)
- Controller failure destroying metadata
- Simultaneous multi-drive failure exceeding fault tolerance
- Fire, flood, theft of the physical machine

RAID and backup are orthogonal mechanisms serving different failure modes.

---

**Key Points**

- The RAID 5 write penalty (4 I/Os per small write) and URE-during-rebuild risk make it unsuitable for large-capacity HDD arrays and write-intensive workloads — RAID 6 addresses the former, and neither fully addresses the latter
- RAID 10 has no write penalty and low rebuild load, making it the preferred choice for write-heavy, latency-sensitive workloads at the cost of 50% capacity efficiency
- RAID 6 is the standard for capacity-efficient redundant HDD arrays where drive capacity makes RAID 5 URE risk unacceptable
- RAID 01 and RAID 10 are not equivalent — RAID 10 provides strictly better fault tolerance for the same drive count
- Software RAID on modern CPUs with SIMD support imposes negligible CPU overhead for parity computation; hardware RAID's primary practical advantage is its write cache, not compute offload
- RAID is an availability mechanism, not a data protection mechanism — it does not substitute for backup

---

