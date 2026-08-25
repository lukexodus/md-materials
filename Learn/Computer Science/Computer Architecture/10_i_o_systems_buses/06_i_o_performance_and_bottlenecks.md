## I/O Performance and Bottlenecks


### Fundamental I/O Performance Metrics

I/O performance is characterized by three primary dimensions:

**Latency** — the time from issuing a request to receiving the first byte of the response. Measured in microseconds (μs) for NVMe SSDs, milliseconds (ms) for HDDs, and nanoseconds (ns) for DRAM.

**Throughput (Bandwidth)** — the sustained data transfer rate, measured in MB/s or GB/s. Distinct from latency; a device can have high throughput but high latency (e.g., magnetic tape).

**IOPS (I/O Operations Per Second)** — the number of discrete I/O requests serviced per second. Critical for workloads with many small, random accesses rather than large sequential transfers.

The relationship between these metrics:

```
Throughput = IOPS × Transfer_Size
Latency    = Queue_Depth / IOPS          (Little's Law approximation)
```

**Key Points:**

- Latency and throughput are not interchangeable; optimizing one does not imply the other.
- Queue depth (number of outstanding I/O requests) mediates the throughput-latency tradeoff: deeper queues raise throughput at the cost of per-request latency.

---

### I/O Stack Layers and Where Latency Accumulates

A complete I/O request traverses multiple layers, each contributing latency:

```
Application
    │  syscall overhead (read/write/fsync)
    ▼
VFS (Virtual File System)
    │  inode lookup, permission check
    ▼
File System (ext4, XFS, NTFS…)
    │  block allocation, journaling
    ▼
Block Layer (I/O scheduler, merging, reordering)
    │  queue management
    ▼
Device Driver
    │  command translation, DMA setup
    ▼
Hardware Controller (HBA, NVMe controller)
    │  internal queuing (NCQ, NVMe queues)
    ▼
Physical Medium (NAND, magnetic platter, network)
```

**Key Points:**

- For NVMe SSDs, the physical medium latency is ~100 μs; software stack overhead can exceed that if not carefully managed.
- For HDDs, the physical medium dominates: seek (3–10 ms) + rotational latency (0–8 ms) dwarfs software overhead.

---

### Bottleneck Categories

#### CPU-Bound I/O

Occurs when the processor cannot issue or process I/O requests fast enough. Causes:

- High per-interrupt overhead from many small I/O completions (interrupt storms).
- Expensive system call paths (context switching, kernel/user boundary crossing).
- Software encryption or compression applied in-line (e.g., dm-crypt on every block).

Mitigation: interrupt coalescing, polling (io_uring in Linux), hardware offload engines.

#### Bus/Interconnect Bound

The transfer rate of the system bus limits throughput before the device itself saturates.

|Interface|Peak Bandwidth|
|---|---|
|SATA III|600 MB/s|
|PCIe 3.0 ×4|~3.5 GB/s|
|PCIe 4.0 ×4|~7 GB/s|
|PCIe 5.0 ×4|~14 GB/s|

A fast NVMe SSD (PCIe 4.0 ×4) is bottlenecked if placed in a PCIe 3.0 ×2 slot. The interconnect becomes the constraint, not the device.

#### Device-Bound

The physical medium itself is the limit. For HDDs this is mechanical; for SSDs it is NAND program/erase cycle throughput and internal parallelism (channel count, die interleaving).

**Write amplification** (WA) is a key SSD-specific bottleneck:

```
WA = Data written to NAND / Data written by host
```

High WA degrades sustained write throughput, as garbage collection consumes internal bandwidth.

#### Memory/DMA Bound

DMA transfers compete with CPU and GPU for memory bandwidth. On systems without IOMMU bandwidth partitioning, heavy DMA from multiple devices can saturate the memory bus, degrading all compute performance simultaneously.

#### Queue Depth Saturation

Each device has a maximum supported queue depth (NCQ for SATA: 32; NVMe: up to 65,535 queues × 65,535 entries). If software issues fewer requests than the device can pipeline, device utilization drops below 100% — a throughput loss invisible to per-request latency measurements.

<svg viewBox="0 0 680 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13"> <!-- Queue depth vs throughput curve --> <rect width="680" height="200" fill="none"/> <!-- Axes --> <line x1="60" y1="160" x2="620" y2="160" stroke="#888" stroke-width="1.5"/> <line x1="60" y1="20" x2="60" y2="160" stroke="#888" stroke-width="1.5"/> <!-- Axis labels --> <text x="320" y="190" text-anchor="middle" fill="#aaa" font-size="12">Queue Depth →</text> <text x="15" y="95" text-anchor="middle" fill="#aaa" font-size="12" transform="rotate(-90,15,95)">Throughput →</text> <!-- Curve: rises steeply then plateaus --> <path d="M60,160 C100,160 130,40 200,32 S400,28 620,28" fill="none" stroke="#7ec8e3" stroke-width="2.5"/> <!-- Saturation annotation --> <line x1="200" y1="32" x2="200" y2="160" stroke="#e3a87e" stroke-width="1" stroke-dasharray="4,3"/> <text x="205" y="100" fill="#e3a87e" font-size="11">Device saturates</text> <text x="205" y="115" fill="#e3a87e" font-size="11">here; deeper queue</text> <text x="205" y="130" fill="#e3a87e" font-size="11">adds only latency</text> <!-- Under-utilization region label --> <text x="100" y="140" fill="#aaa" font-size="11">Under-utilized</text> </svg>

---

### I/O Scheduling and Its Effect on Performance

The I/O scheduler (block layer) reorders and merges requests to optimize physical media access. Trade-offs differ by workload and device type.

|Scheduler|Strategy|Best For|
|---|---|---|
|CFQ (legacy)|Fair time slices per process|Rotating HDDs, mixed workloads|
|Deadline|Prioritize reads; enforce deadlines|Databases on HDDs|
|mq-deadline|Multi-queue variant of Deadline|SSDs with multiple queues|
|None (noop)|FIFO, minimal reordering|NVMe SSDs (device does its own scheduling)|
|BFQ|Budget fair queuing|Desktop responsiveness|

**Key Points:**

- Reordering is valuable for HDDs (reduces seek distance via elevator algorithm) but counterproductive for SSDs where random access cost ≈ sequential access cost.
- Using CFQ or Deadline on NVMe adds scheduler overhead with no physical benefit.

---

### Measuring and Locating I/O Bottlenecks

**Utilization** — percentage of time the device is busy. A device at 100% utilization with growing queue depth is the bottleneck.

**Service time vs. wait time** — `iostat -x` separates `svctm` (device service time) from `await` (total wait including queue). Large `await` relative to `svctm` indicates queuing delays upstream of the device.

**Saturation indicators:**

```
await >> svctm         → queue saturation
iowait CPU %  high     → CPUs stalled waiting for I/O
write-back pressure    → page cache dirty ratio exceeded, triggering synchronous writeback
```

**Key Points:**

- High `iowait` does not always mean the I/O device is the bottleneck; it can indicate insufficient I/O depth or an oversubscribed memory bus.
- Profiling tools: `iostat`, `blktrace`, `perf`, `eBPF/bpftrace` (for stack-level attribution), `fio` (synthetic benchmarking with controllable queue depth, block size, and access pattern).

---

### Roofline Applied to I/O

The Roofline model (covered under Module 14) applies to I/O subsystems directly. The two ceilings are:

- **Bandwidth ceiling** — the maximum MB/s deliverable by the interconnect or device.
- **IOPS ceiling** — the maximum operations/s regardless of transfer size.

A workload operating below both ceilings is software-limited (scheduler, driver, syscall overhead). A workload hitting one ceiling cannot be improved by tuning the other.

---

### Structural Sources of I/O Bottleneck: Summary Table

|Bottleneck Layer|Observable Symptom|Mitigation Direction|
|---|---|---|
|Physical medium|High `svctm`, low IOPS vs. spec|Faster device, RAID striping|
|Interconnect|Throughput capped below device spec|Higher-bandwidth slot/interface|
|I/O scheduler|Unnecessary latency on SSDs|Use `none` scheduler for NVMe|
|Driver/interrupt|High CPU% on soft-IRQ|Interrupt coalescing, MSI-X, io_uring polling|
|DMA/memory bus|I/O throughput degrades under compute load|IOMMU QoS, NUMA-local DMA|
|Queue depth|Device under-utilized, throughput < spec|Increase outstanding request count|
|Write amplification (SSD)|Sustained write throughput degrades over time|Over-provisioning, workload alignment|
|Software stack overhead|Latency >> device spec under light load|io_uring, kernel bypass (SPDK, DPDK)|

---

