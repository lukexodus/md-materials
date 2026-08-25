## Storage Interfaces


Storage interfaces define the electrical, mechanical, and logical protocols through which a host system communicates with storage devices. The evolution from SATA to NVMe over PCIe reflects a fundamental shift in storage performance characteristics — from spinning magnetic media to NAND flash — and the interface bottlenecks that emerged as a result.

---

### SATA — Serial ATA

#### Origin and Purpose

SATA (Serial Advanced Technology Attachment) was introduced in 2003 as a replacement for Parallel ATA (PATA). It was designed around the performance envelope of mechanical hard drives, where rotational latency and seek time — not interface bandwidth — were the dominant bottlenecks.

#### Physical Layer

SATA uses a thin, 7-pin differential serial data cable and a 15-pin power connector. The differential signaling (two wires per direction) reduces electromagnetic interference compared to the wide parallel buses of PATA.

```
Host Controller                         Device
─────────────────                       ──────────────
  TX+ / TX−  ──────────────────────►  RX+ / RX−
  RX+ / RX−  ◄──────────────────────  TX+ / TX−
  GND
```

#### Generations and Bandwidth

|Revision|Line Rate|Throughput (effective)|
|---|---|---|
|SATA I|1.5 Gb/s|~150 MB/s|
|SATA II|3.0 Gb/s|~300 MB/s|
|SATA III|6.0 Gb/s|~600 MB/s|

SATA uses **8b/10b encoding**, meaning 20% of raw bandwidth is consumed by encoding overhead. A 6 Gb/s link yields a practical ceiling of ~600 MB/s.

#### Protocol — AHCI

SATA is controlled through the **Advanced Host Controller Interface (AHCI)**, a register-level interface standardized by Intel. AHCI exposes:

- A **command list** of up to 32 entries per port
- **Native Command Queuing (NCQ)** — allows the drive to reorder up to 32 outstanding commands to optimize seek paths on HDDs
- Port Multiplier support for up to 15 devices on one port

AHCI was architected with HDD latency assumptions baked in. Its command overhead, single command queue, and CPU interrupt model all impose latency that becomes visible when the underlying device (an SSD) can respond in microseconds rather than milliseconds.

#### Form Factors

- **3.5-inch** — desktop HDDs
- **2.5-inch** — laptop HDDs and SSDs
- **mSATA** — miniaturized SATA for embedded use (largely superseded by M.2)
- **M.2 (SATA mode)** — M.2 slot wired to carry SATA signals instead of PCIe

**Key Points**

- SATA III's ~600 MB/s ceiling is sufficient for HDDs but is a hard bottleneck for NAND-based SSDs.
- AHCI's 32-command queue depth is adequate for HDDs but underutilizes flash parallelism.
- A SATA SSD's latency floor is still bounded by AHCI command processing overhead, not flash access time alone.

---

### PCIe — Peripheral Component Interconnect Express

PCIe is not a storage interface per se — it is a general-purpose, high-bandwidth serial interconnect used as the **physical and electrical substrate** over which storage protocols such as NVMe operate. Understanding PCIe is prerequisite to understanding NVMe.

#### Topology

PCIe uses a **point-to-point switched topology**, replacing the shared PCI bus. Each device connects directly to the root complex (CPU or chipset) or through PCIe switches.

```
          ┌─────────────┐
          │ Root Complex │  (CPU-side)
          └──────┬───────┘
                 │ x16
          ┌──────┴───────┐
          │  PCIe Switch  │
          └──┬──────┬────┘
             │ x4   │ x4
         [NVMe]   [GPU]
```

#### Lanes and Bandwidth

A PCIe **lane** is one differential pair in each direction (full-duplex). Devices use x1, x4, x8, or x16 lane configurations.

|Generation|Encoding|Per-lane BW|x4 BW|x16 BW|
|---|---|---|---|---|
|PCIe 3.0|128b/130b|~1 GB/s|~4 GB/s|~16 GB/s|
|PCIe 4.0|128b/130b|~2 GB/s|~8 GB/s|~32 GB/s|
|PCIe 5.0|128b/130b|~4 GB/s|~16 GB/s|~64 GB/s|
|PCIe 6.0|PAM4 + FLIT|~8 GB/s|~32 GB/s|~128 GB/s|

PCIe 3.0 and later use **128b/130b encoding**, reducing encoding overhead to ~1.5% compared to SATA's 20%.

#### Transaction Layer

PCIe operates through **Transaction Layer Packets (TLPs)**:

- **Memory Read / Write** — primary mechanism for NVMe register access and DMA transfers
- **Completion** — response to a read request
- **Message** — signaling (e.g., interrupts via MSI/MSI-X)

The transaction layer sits above the data link layer (which handles ACK/NAK and error detection via CRC) and the physical layer.

```
┌─────────────────────────────┐
│     Transaction Layer        │  TLPs: read, write, completion
├─────────────────────────────┤
│      Data Link Layer         │  ACK/NAK, LCRC, sequence numbers
├─────────────────────────────┤
│       Physical Layer         │  Differential signaling, 8b/10b or 128b/130b
└─────────────────────────────┘
```

#### Flow Control

PCIe uses a **credit-based flow control** mechanism. The receiver advertises credits (buffer space) to the transmitter. The transmitter can only send if it holds sufficient credits. This is performed per traffic class and type (posted, non-posted, completion).

**Key Points**

- PCIe lanes are full-duplex and point-to-point; there is no shared bus arbitration.
- 128b/130b encoding is far more efficient than SATA's 8b/10b.
- PCIe bandwidth scales linearly with lane count and doubles with each generation.
- PCIe itself defines only the transport — the protocol riding over it determines semantics.

---

### NVMe — Non-Volatile Memory Express

#### Motivation

AHCI/SATA was a legacy bottleneck for NAND flash. NVMe was developed by a consortium of industry vendors and published in 2011 specifically to exploit the low latency and internal parallelism of solid-state storage over a PCIe substrate.

The fundamental problems NVMe solves:

|Problem with AHCI|NVMe's solution|
|---|---|
|1 command queue, 32 entries|65,535 queues × 65,536 entries each|
|High per-command CPU overhead|Streamlined 13-DWORD submission / completion queue model|
|Polling and interrupt inefficiency|MSI-X with per-queue interrupt vectors; optional polling mode|
|Register-heavy interface|Memory-mapped queue model, minimal register interaction|

#### Queue Model

NVMe uses memory-mapped **Submission Queues (SQ)** and **Completion Queues (CQ)** residing in host DRAM. The host writes commands to the SQ and rings a **doorbell register** on the NVMe controller. The controller fetches commands via DMA, executes them, and posts completions to the CQ.

```
Host DRAM                              NVMe Controller
─────────────────────────────          ──────────────────────────
 Submission Queue (SQ)                  DMA fetch commands
 ┌───┬───┬───┬───┬───┐                 ◄─────────────────────────
 │CMD│CMD│CMD│   │   │ ── doorbell ──►  Execute on NAND
 └───┴───┴───┴───┴───┘

 Completion Queue (CQ)
 ┌───┬───┬───┬───┬───┐
 │CQE│CQE│   │   │   │ ◄── MSI-X ────  Post completion
 └───┴───┴───┴───┴───┘
```

Multiple SQs can be mapped to a single CQ, or each SQ can have a dedicated CQ. Per-core queue pairs allow lock-free submission from multi-threaded workloads.

#### Command Set

The NVMe base command set includes:

- **Admin commands** — identify controller/namespace, get/set features, firmware management, format NVM
- **I/O commands** — Read, Write, Flush, Dataset Management (TRIM/Deallocate), Write Zeroes, Compare, Verify

The **NVMe-oF (over Fabrics)** extension extends the queue model across network fabrics (RDMA, Fibre Channel, TCP), allowing remote NVMe targets to be accessed with near-local latency.

#### Namespaces

NVMe introduces the concept of **namespaces** — independent logical storage units within a single physical device. Each namespace has its own 64-bit Namespace ID (NSID) and LBA space. One controller can expose up to 2³²−1 namespaces. This enables:

- Multi-tenant isolation on NVMe SSDs
- Namespace sharing across multiple controllers (shared storage)
- Per-namespace formatting and protection information settings

#### Latency Profile

|Interface|Typical 4K Random Read Latency|
|---|---|
|HDD over SATA|5–10 ms|
|SATA SSD (AHCI)|50–100 µs|
|NVMe SSD (PCIe 3.0 x4)|20–50 µs|
|NVMe SSD (PCIe 4.0 x4)|15–40 µs|
|Optane (3D XPoint) over NVMe|~10 µs|

[Unverified: exact latency values vary by drive model, workload, and queue depth. These figures are representative order-of-magnitude estimates from published datasheets and are not guaranteed to apply universally.]

#### Throughput Comparison

|Interface|Sequential Read|Random 4K IOPS|
|---|---|---|
|SATA III (AHCI)|~550 MB/s|~100K|
|NVMe PCIe 3.0 x4|~3,500 MB/s|~700K|
|NVMe PCIe 4.0 x4|~7,000 MB/s|~1,000K|
|NVMe PCIe 5.0 x4|~14,000 MB/s|~1,500K+|

[Unverified: peak figures from manufacturer specifications; actual sustained throughput is workload-dependent.]

**Key Points**

- NVMe's massive queue depth eliminates the command queue as a bottleneck for parallelism-heavy NAND.
- Per-core queue pairs allow OS schedulers to submit I/O without locking.
- MSI-X allows each queue to interrupt a specific CPU core, improving cache locality for completions.
- NVMe is protocol-agnostic at the physical layer — it runs over PCIe, RDMA, TCP, and Fibre Channel.

---

### Form Factors Carrying NVMe

NVMe rides over PCIe, and that PCIe connectivity is exposed through several physical form factors:

|Form Factor|Lanes|Common Use|
|---|---|---|
|M.2 (NVMe)|x4 PCIe|Consumer laptops, desktops|
|U.2 (SFF-8639)|x4 PCIe|Enterprise 2.5" drives|
|U.3|x4 PCIe|Enterprise, tri-mode (SATA/SAS/NVMe)|
|EDSFF (E1.S, E3.S)|x4 or x8 PCIe|Datacenter density|
|AIC (Add-In Card)|x4/x8/x16|High-end desktop or server|
|CXL (future)|PCIe 5.0+|Memory-semantic storage|

M.2 slots are particularly important to distinguish: an M.2 slot can carry either SATA signals or PCIe signals depending on how the motherboard wires it, and the drive keying (B-key, M-key, B+M-key) determines compatibility.

---

### Interface Stack Comparison

```svg
<svg viewBox="0 0 720 420" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">

  <!-- SATA Stack -->
  <text x="110" y="30" text-anchor="middle" font-weight="bold" font-size="14">SATA / AHCI</text>
  <rect x="30" y="40" width="160" height="40" rx="4" fill="#c8e6c9" stroke="#388e3c"/>
  <text x="110" y="65" text-anchor="middle">Application / OS</text>
  <rect x="30" y="88" width="160" height="40" rx="4" fill="#a5d6a7" stroke="#388e3c"/>
  <text x="110" y="113" text-anchor="middle">Block I/O Layer</text>
  <rect x="30" y="136" width="160" height="40" rx="4" fill="#81c784" stroke="#388e3c"/>
  <text x="110" y="161" text-anchor="middle">AHCI Driver</text>
  <rect x="30" y="184" width="160" height="40" rx="4" fill="#66bb6a" stroke="#388e3c"/>
  <text x="110" y="209" text-anchor="middle">AHCI Controller</text>
  <rect x="30" y="232" width="160" height="40" rx="4" fill="#4caf50" stroke="#2e7d32"/>
  <text x="110" y="257" text-anchor="middle" fill="white">SATA Physical</text>
  <rect x="30" y="280" width="160" height="40" rx="4" fill="#388e3c" stroke="#1b5e20"/>
  <text x="110" y="305" text-anchor="middle" fill="white">HDD / SATA SSD</text>

  <!-- NVMe Stack -->
  <text x="400" y="30" text-anchor="middle" font-weight="bold" font-size="14">NVMe / PCIe</text>
  <rect x="320" y="40" width="160" height="40" rx="4" fill="#bbdefb" stroke="#1976d2"/>
  <text x="400" y="65" text-anchor="middle">Application / OS</text>
  <rect x="320" y="88" width="160" height="40" rx="4" fill="#90caf9" stroke="#1976d2"/>
  <text x="400" y="113" text-anchor="middle">Block I/O Layer</text>
  <rect x="320" y="136" width="160" height="40" rx="4" fill="#64b5f6" stroke="#1976d2"/>
  <text x="400" y="161" text-anchor="middle">NVMe Driver</text>
  <rect x="320" y="184" width="160" height="40" rx="4" fill="#42a5f5" stroke="#1565c0"/>
  <text x="400" y="209" text-anchor="middle">NVMe Controller</text>
  <rect x="320" y="232" width="160" height="40" rx="4" fill="#2196f3" stroke="#0d47a1"/>
  <text x="400" y="257" text-anchor="middle" fill="white">PCIe Transaction</text>
  <rect x="320" y="280" width="160" height="40" rx="4" fill="#1976d2" stroke="#0d47a1"/>
  <text x="400" y="305" text-anchor="middle" fill="white">PCIe Physical</text>
  <rect x="320" y="328" width="160" height="40" rx="4" fill="#0d47a1" stroke="#01579b"/>
  <text x="400" y="353" text-anchor="middle" fill="white">NVMe SSD</text>

  <!-- Labels -->
  <text x="110" y="345" text-anchor="middle" font-size="11" fill="#555">Queue depth: 32</text>
  <text x="400" y="385" text-anchor="middle" font-size="11" fill="#555">Queue depth: 65535 × 65536</text>
</svg>
```

---

### Choosing an Interface — Design Considerations

|Consideration|SATA|NVMe (PCIe)|
|---|---|---|
|Cost|Lower|Higher|
|Power|~2–4W active|~4–8W active (higher ceiling)|
|Latency|~70–100 µs (SSD)|~20–50 µs|
|Peak throughput|~550 MB/s|~3.5–14 GB/s|
|CPU overhead|Higher (AHCI)|Lower (streamlined queues)|
|Legacy compatibility|Broad|Requires PCIe lanes in host|
|Enterprise features|Limited|Namespaces, end-to-end protection, atomic writes|

**Example**

A database server executing thousands of 4K random reads per second saturates SATA's AHCI queue at 32 commands, causing queuing latency even when the SSD hardware is capable of more. Migrating to NVMe with per-core queue pairs allows the OS to submit I/O from each CPU core without lock contention, and the controller can process hundreds of thousands of IOPS without queue saturation.

---

**Conclusion**

SATA remains a cost-effective interface for HDD-class workloads and entry-level SSDs where ~550 MB/s throughput is acceptable. PCIe provides the electrical and logical transport layer that enables modern high-bandwidth communication between host and device. NVMe is the purpose-built protocol that exploits PCIe's bandwidth and latency characteristics, eliminating the AHCI command model's bottlenecks through deep multi-queue architecture, low per-command overhead, and MSI-X interrupt routing. The progression from SATA → PCIe/AHCI (early PCIe SSDs) → NVMe reflects each layer of bottleneck being identified and removed as NAND flash performance advanced.

**Next Steps**

- RAID levels and trade-offs — how multiple storage devices are combined for performance and redundancy, and how the interface choice affects RAID controller design
- File system interactions with hardware — how the VFS layer, journaling, and writeback caching interact with the command sets and flush semantics exposed by SATA and NVMe
- Memory-mapped I/O — how NVMe's doorbell registers and queue structures relate to the broader MMIO model used across PCIe devices

---

