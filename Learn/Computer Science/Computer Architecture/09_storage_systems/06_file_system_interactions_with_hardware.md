## File System Interactions with Hardware


A file system is software, but its performance and correctness are tightly coupled to the hardware beneath it — storage devices, memory buses, I/O controllers, and CPU caches. Understanding this interface means tracing every read and write from the application layer down to the physical medium and back.

---

### The Layered I/O Stack

Before examining individual mechanisms, establish the full path a file operation travels.

<svg viewBox="0 0 680 480" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13"> <!-- Background --> <rect width="680" height="480" fill="#0f1117" rx="10"/> <!-- Layer boxes --> <!-- Application --> <rect x="60" y="30" width="560" height="52" fill="#1e3a5f" rx="6" stroke="#3b82f6" stroke-width="1.5"/> <text x="340" y="52" fill="#93c5fd" text-anchor="middle" font-size="14" font-weight="bold">Application (User Space)</text> <text x="340" y="70" fill="#64748b" text-anchor="middle" font-size="11">open(), read(), write(), close()</text> <!-- VFS --> <rect x="60" y="102" width="560" height="52" fill="#1e3a2f" rx="6" stroke="#22c55e" stroke-width="1.5"/> <text x="340" y="124" fill="#86efac" text-anchor="middle" font-size="14" font-weight="bold">Virtual File System (VFS)</text> <text x="340" y="142" fill="#64748b" text-anchor="middle" font-size="11">Uniform interface: inode, dentry, file, superblock objects</text> <!-- Concrete FS --> <rect x="60" y="174" width="560" height="52" fill="#2a1f3d" rx="6" stroke="#a855f7" stroke-width="1.5"/> <text x="340" y="196" fill="#d8b4fe" text-anchor="middle" font-size="14" font-weight="bold">Concrete File System (ext4 / NTFS / XFS / ZFS …)</text> <text x="340" y="214" fill="#64748b" text-anchor="middle" font-size="11">Metadata management, journaling, extent trees, allocation bitmaps</text> <!-- Page Cache / Buffer Cache --> <rect x="60" y="246" width="560" height="52" fill="#2a2a1a" rx="6" stroke="#eab308" stroke-width="1.5"/> <text x="340" y="268" fill="#fde047" text-anchor="middle" font-size="14" font-weight="bold">Page Cache / Buffer Cache (Kernel RAM)</text> <text x="340" y="286" fill="#64748b" text-anchor="middle" font-size="11">4 KiB pages · dirty tracking · writeback threads · readahead</text> <!-- Block Layer --> <rect x="60" y="318" width="560" height="52" fill="#1f2a2a" rx="6" stroke="#06b6d4" stroke-width="1.5"/> <text x="340" y="340" fill="#67e8f9" text-anchor="middle" font-size="14" font-weight="bold">Block Layer (I/O Scheduler + BIO)</text> <text x="340" y="358" fill="#64748b" text-anchor="middle" font-size="11">Request merging, reordering (CFQ / deadline / mq-deadline / none)</text> <!-- Device Driver / Controller --> <rect x="60" y="390" width="560" height="52" fill="#2a1a1a" rx="6" stroke="#f87171" stroke-width="1.5"/> <text x="340" y="412" fill="#fca5a5" text-anchor="middle" font-size="14" font-weight="bold">Device Driver → Storage Controller → Physical Medium</text> <text x="340" y="430" fill="#64748b" text-anchor="middle" font-size="11">SATA / NVMe / PCIe · DMA · IRQ · NAND flash / magnetic platters</text> <!-- Arrows --> <line x1="340" y1="82" x2="340" y2="102" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/> <line x1="340" y1="154" x2="340" y2="174" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/> <line x1="340" y1="226" x2="340" y2="246" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/> <line x1="340" y1="298" x2="340" y2="318" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/> <line x1="340" y1="370" x2="340" y2="390" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/> <defs> <marker id="arr" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto"> <path d="M0,0 L0,8 L8,4 z" fill="#475569"/> </marker> </defs> </svg>

Each layer introduces latency, buffering, or transformation. The hardware interaction occurs primarily at the bottom two layers, but upper layers determine how often and in what form hardware is actually reached.

---

### The Virtual File System (VFS)

The VFS is a kernel abstraction that presents a single interface to all concrete file systems. It defines four key kernel objects:

|Object|Represents|Hardware relevance|
|---|---|---|
|**superblock**|Mounted volume metadata|Read from first sectors on mount|
|**inode**|File metadata (permissions, block map)|Cached from disk; determines which blocks to fetch|
|**dentry**|Directory entry (name → inode mapping)|Cached in dentry cache; reduces metadata I/O|
|**file**|Open file instance per process|Holds current offset; no direct hardware state|

VFS reduces raw I/O by maintaining in-memory caches of these objects. A path lookup that hits the dentry cache never issues a storage read. A miss triggers block reads to reconstruct inode and directory data from disk.

---

### Page Cache and Buffer Cache

The page cache is the dominant hardware-shielding layer. All file reads and writes go through it on general-purpose operating systems.

#### Read path

```
read(fd, buf, n)
  └─ VFS → file system → check page cache
       ├─ HIT:  copy page to user buffer (no I/O)
       └─ MISS: allocate page, issue block read via BIO, wait for DMA completion,
                copy to user buffer, mark page clean
```

#### Write path (two modes)

**Write-back (default):** Data is written to the page cache immediately; the page is marked _dirty_. Kernel writeback threads (e.g., `pdflush`, `kworker`) flush dirty pages to storage asynchronously based on age (`dirty_expire_centisecs`) and pressure (`dirty_ratio`).

**Write-through / `O_SYNC` / `fsync()`:** The write does not return until the hardware acknowledges persistence. This forces a synchronous flush through the block layer to the device's write cache, and may issue a `FLUSH CACHE` or `FORCE UNIT ACCESS (FUA)` command to the storage controller.

#### Readahead

When sequential access is detected, the kernel speculatively prefetches additional pages before they are requested. Readahead depth is adaptive — it grows on confirmed sequential patterns and resets on random access. This amortizes the latency of individual I/O requests across many pages.

---

### Block Layer and I/O Scheduling

Below the page cache, file system requests are converted into _block I/O requests_ (BIOs) describing logical block addresses (LBAs) and transfer lengths. The block layer:

1. **Merges** adjacent or overlapping requests into a single larger I/O.
2. **Reorders** requests to minimize seek latency (for HDDs) or respect device queues (for SSDs/NVMe).
3. **Submits** requests to the device driver queue.

#### Schedulers by device class

|Scheduler|Suited for|Mechanism|
|---|---|---|
|`mq-deadline`|HDDs, mixed|Hard deadline per request; batches reads vs. writes|
|`kyber`|Low-latency SSDs|Token-bucket per request type; targets latency percentile|
|`none` (passthrough)|NVMe SSDs|No reordering; device handles queue natively|
|`bfq`|Desktop/interactive|Proportional bandwidth per process|

NVMe devices expose multiple hardware submission queues (up to 65535), so software reordering adds overhead rather than benefit — `none` is the standard choice.

---

### DMA and Interrupt Handling

Once the block layer submits a request to the driver, the CPU is largely uninvolved in the data transfer itself.

<svg viewBox="0 0 680 300" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <rect width="680" height="300" fill="#0f1117" rx="10"/> <!-- CPU --> <rect x="30" y="90" width="120" height="60" fill="#1e3a5f" rx="5" stroke="#3b82f6" stroke-width="1.5"/> <text x="90" y="115" fill="#93c5fd" text-anchor="middle" font-size="13" font-weight="bold">CPU</text> <text x="90" y="135" fill="#64748b" text-anchor="middle" font-size="10">issues command</text> <!-- RAM --> <rect x="270" y="30" width="140" height="60" fill="#1e3a2f" rx="5" stroke="#22c55e" stroke-width="1.5"/> <text x="340" y="55" fill="#86efac" text-anchor="middle" font-size="13" font-weight="bold">Main Memory</text> <text x="340" y="75" fill="#64748b" text-anchor="middle" font-size="10">DMA target buffer</text> <!-- DMA Controller --> <rect x="270" y="120" width="140" height="60" fill="#2a1f3d" rx="5" stroke="#a855f7" stroke-width="1.5"/> <text x="340" y="145" fill="#d8b4fe" text-anchor="middle" font-size="13" font-weight="bold">DMA Controller</text> <text x="340" y="165" fill="#64748b" text-anchor="middle" font-size="10">bus master transfer</text> <!-- Storage Controller --> <rect x="510" y="90" width="140" height="60" fill="#2a1a1a" rx="5" stroke="#f87171" stroke-width="1.5"/> <text x="580" y="115" fill="#fca5a5" text-anchor="middle" font-size="13" font-weight="bold">Storage Ctrl</text> <text x="580" y="135" fill="#64748b" text-anchor="middle" font-size="10">SATA / NVMe</text> <!-- IRQ line --> <rect x="270" y="210" width="140" height="50" fill="#2a2a1a" rx="5" stroke="#eab308" stroke-width="1.5"/> <text x="340" y="232" fill="#fde047" text-anchor="middle" font-size="13" font-weight="bold">Interrupt (IRQ)</text> <text x="340" y="250" fill="#64748b" text-anchor="middle" font-size="10">signals completion</text> <!-- Arrows --> <!-- CPU to DMA --> <line x1="150" y1="120" x2="270" y2="150" stroke="#3b82f6" stroke-width="1.5" marker-end="url(#a2)"/> <text x="200" y="128" fill="#3b82f6" font-size="10">1. program</text> <!-- DMA to Storage --> <line x1="410" y1="150" x2="510" y2="120" stroke="#a855f7" stroke-width="1.5" marker-end="url(#a2)"/> <text x="445" y="128" fill="#a855f7" font-size="10">2. read cmd</text> <!-- Storage to DMA (data) --> <line x1="510" y1="130" x2="410" y2="155" stroke="#f87171" stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#a2)"/> <text x="438" y="168" fill="#f87171" font-size="10">3. data</text> <!-- DMA to RAM --> <line x1="340" y1="120" x2="340" y2="90" stroke="#22c55e" stroke-width="1.5" marker-end="url(#a2)"/> <text x="348" y="110" fill="#22c55e" font-size="10">4. write</text> <!-- IRQ to CPU --> <line x1="270" y1="235" x2="90" y2="160" stroke="#eab308" stroke-width="1.5" marker-end="url(#a2)"/> <text x="130" y="218" fill="#eab308" font-size="10">5. IRQ → CPU wakes</text> <defs> <marker id="a2" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto"> <path d="M0,0 L0,8 L8,4 z" fill="#94a3b8"/> </marker> </defs> </svg>

**Steps:**

1. The driver programs the DMA controller with the physical address of the target kernel buffer, the LBA, and transfer length.
2. The DMA controller issues the read command to the storage controller independently.
3. The storage controller streams data back over the bus.
4. The DMA controller writes data directly into main memory without CPU involvement.
5. On completion, the storage controller asserts an interrupt line; the CPU's interrupt handler marks the BIO complete, wakes the waiting process, and the page cache page is marked clean.

This is why a large sequential read consumes minimal CPU — the processor is free to execute other work while the DMA transfer proceeds.

---

### Storage Device Hardware Interface

#### HDD (Hard Disk Drive)

The file system's logical block address must be translated into **cylinder, head, sector (CHS)** geometry by the disk firmware, though modern drives expose a flat LBA namespace and perform their own internal geometry mapping.

- **Seek time** (~3–12 ms): arm movement to the correct track. The I/O scheduler exploits this by reordering requests to reduce total seek distance.
- **Rotational latency** (~0–8 ms at 7200 RPM): waiting for the target sector to rotate under the head.
- **Transfer time**: proportional to transfer size and platter RPM.

File system designs historically reflected HDD geometry: cylinder groups (ext2/ext3), allocation policies that cluster related data, and large sequential writes to amortize seek cost.

#### SSD (Solid-State Drive)

SSDs expose an LBA interface identical to HDDs, but the underlying NAND flash has fundamentally different characteristics:

|Property|Implication for file system|
|---|---|
|**No seek latency**|Random I/O nearly as fast as sequential; old HDD-optimized layouts less critical|
|**Page-granular write** (4–16 KiB)|Write to a page requires the entire page to be programmed; partial page updates require read-modify-write|
|**Block-granular erase** (128–512 pages)|Erase before rewrite; necessitates Flash Translation Layer (FTL)|
|**Write endurance** (P/E cycles)|Wear leveling in FTL; file systems can help by avoiding excessive small writes|
|**Write amplification**|FTL internal garbage collection may write more data than the file system requested|

The **Flash Translation Layer (FTL)** in the SSD firmware provides the logical-to-physical mapping, wear leveling, and garbage collection. The file system sees a clean LBA device; the FTL absorbs the complexity of NAND constraints. However, FTL behavior interacts with file system patterns — a file system that issues `TRIM`/`DISCARD` commands on deletion helps the FTL reclaim erased blocks early, reducing write amplification.

#### NVMe

NVMe replaces the SATA/AHCI command interface with a protocol designed for flash:

- **PCIe direct attachment**: bypasses the SATA controller entirely; lower latency path to the CPU.
- **Multiple queues**: up to 65535 submission/completion queue pairs per namespace, one per CPU core, eliminating lock contention.
- **Doorbell registers**: submission is a memory write to a device register; no port I/O.
- **Latency**: end-to-end ~20–100 µs vs ~100–200 µs for SATA SSDs.

---

### Journaling and Hardware Ordering Guarantees

Journaling ensures file system consistency after a crash, but it depends on hardware write ordering guarantees.

**The problem:** The CPU and storage controller both maintain write caches. Without explicit ordering, the OS cannot assume that writes committed to the device's write cache are persisted to stable storage in the order issued.

**Hardware mechanisms used:**

- **`FLUSH CACHE` command (ATA) / `SYNCHRONIZE CACHE` (SCSI/NVMe):** Forces the device to commit its write cache to non-volatile storage before responding. Expensive (~1–10 ms).
- **Force Unit Access (FUA) bit (NVMe / SATA):** Tags a specific write command as requiring persistence before acknowledgment, without flushing the entire cache.

**Journaling modes and their flush usage (ext4 example):**

|Mode|What is journaled|Flush behavior|
|---|---|---|
|`writeback`|Metadata only, no ordering|One flush after metadata commit|
|`ordered` (default)|Metadata only; data written before commit|Flush after data write, flush after metadata commit|
|`journal`|Metadata + data|Flush after journal write, flush after commit|

Each mode represents a trade-off between durability, consistency, and I/O cost. `ordered` mode is the standard default: it protects against metadata inconsistency (avoiding pointing to uninitialized data) without the overhead of double-writing data.

---

### Memory-Mapped I/O for Files (`mmap`)

`mmap()` maps a file's pages directly into the process virtual address space. On first access, the MMU raises a page fault; the kernel resolves it by loading the file's page from disk (or page cache) into physical memory and updating the page table entry. Subsequent accesses to that virtual address hit RAM with no syscall overhead.

```
Process VA ──page table──► Physical page (in page cache)
                                  │
              on first fault:     └─ kernel reads from storage if not cached
              kernel fills PTE,       and installs PTE
              process continues
```

**Hardware involvement:**

- The MMU handles the virtual-to-physical translation in hardware on every access.
- A page fault is a hardware exception that traps into the kernel.
- Modified (dirty) mapped pages are tracked by the hardware dirty bit in the PTE; the kernel's writeback scans for dirty PTEs to flush.

`mmap` is the mechanism behind _demand paging_ for executables, shared libraries, and database buffer pools (e.g., SQLite, PostgreSQL). It avoids `read()`/`write()` syscall overhead for large working sets but introduces hidden latency at first access.

---

### `fsync()`, `fdatasync()`, and Durability

|Call|Flushes|Hardware guarantee|
|---|---|---|
|`fsync(fd)`|Data + metadata|Device confirms persistence|
|`fdatasync(fd)`|Data only (skips metadata if unnecessary)|Device confirms data persistence|
|`sync()`|All dirty pages system-wide|Initiates writeback; does not wait by default|
|`O_DIRECT`|Bypasses page cache|Data goes directly to device; alignment required|
|`O_SYNC`|Per-write sync|Each `write()` is synchronous to hardware|

`O_DIRECT` bypasses the page cache entirely, issuing aligned DMA transfers directly between the user buffer (pinned in RAM) and the device. Databases (PostgreSQL, MySQL InnoDB) use `O_DIRECT` or `O_DSYNC` to manage their own buffer pools and avoid double-caching.

---

### RAID and Hardware Interaction

RAID distributes or replicates data across multiple physical devices. The interaction with hardware depends on implementation level:

|Level|Hardware role|File system sees|
|---|---|---|
|**Hardware RAID** (controller card)|Controller handles striping, mirroring, parity; presents single virtual LBA device|Single block device; unaware of RAID|
|**Software RAID** (mdadm / ZFS)|OS kernel manages multiple block devices; RAID logic in kernel|Multiple raw block devices|
|**Host-based** (FakeRAID)|Firmware presents metadata; driver implements RAID in OS|Hybrid; less portable|

Hardware RAID controllers include an onboard **Battery-Backed Write Cache (BBWC)** or **flash-backed write cache**. This allows the controller to acknowledge writes before committing them to disk, improving performance while maintaining durability across power loss. The file system's flush commands interact with this cache, not the individual drives.

---

### Partition Alignment and Hardware Performance

Modern storage devices have a physical sector size of 4096 bytes (4Kn or 512e emulation) despite reporting 512-byte logical sectors for compatibility. A partition or file system that begins at a misaligned LBA causes every aligned 4 KiB file system block to span two physical sectors, doubling erase/read operations on that boundary.

**Correct alignment:** partitions and file system blocks should be aligned to 4096-byte boundaries (or 1 MiB for SSDs with large erase blocks). Tools like `parted`, `gdisk`, and modern OS installers enforce this by default.

---

### Summary Table: Hardware Resource per File System Operation

|File System Operation|CPU|RAM (page cache)|DMA|IRQ|Storage I/O|
|---|---|---|---|---|---|
|Cached read|Copy only|Read|No|No|No|
|Uncached read|Minimal|Allocate + fill|Yes|Yes|Yes|
|Buffered write|Copy only|Dirty page|No|No|Deferred|
|`fsync()`|Minimal|Flush dirty pages|Yes|Yes|Yes + FLUSH cmd|
|`mmap` first access|Page fault handler|PTE install|Yes|Yes|Yes|
|Metadata update (journal)|Minimal|Journal buffer|Yes|Yes|Yes × 2 (data + commit)|

---

**Conclusion:** The file system is a software contract layered over hardware that has radically different physical properties depending on the device class. HDD geometry, NAND flash erase granularity, NVMe queue depth, DMA transfer mechanics, hardware write caches, and MMU page fault handling are all direct participants in every non-trivially cached file operation. File system design decisions — journaling mode, allocation policy, flush frequency, TRIM support — are inseparable from the characteristics of the hardware beneath them.

**Next Steps:** The logical continuation is **Main Memory Systems** (Module 8) to understand DRAM timing and memory controller behavior, which underlies the page cache performance examined here, followed by **I/O Systems & Buses** (Module 10) for DMA controller architecture and interrupt handling in depth.

---

