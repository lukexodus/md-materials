## Virtual Memory


Virtual memory is a memory management abstraction that decouples the address space a program uses from the physical memory installed in the system. Each process operates on a private **virtual address space** — a contiguous, uniform range of addresses — while the operating system and hardware cooperate to map those addresses to physical memory locations transparently. The mechanism enables isolation, sharing, demand-loaded execution, and the use of secondary storage as an extension of physical memory.

---

### Motivation

|Problem Without Virtual Memory|Virtual Memory Solution|
|---|---|
|Programs must be loaded entirely into physical memory|Pages loaded on demand; only working set need be resident|
|Programs must know their physical load address|Each process sees a fixed, private address space starting at 0|
|One process can read or corrupt another's memory|Page tables enforce per-process isolation in hardware|
|Physical memory limits program size|Address space can exceed physical memory; disk backs overflow|
|Sharing code between processes wastes memory|Physical pages can be mapped into multiple address spaces simultaneously|

---

### Address Space Layout

A typical virtual address space (64-bit Linux, user space) is divided into regions by convention, enforced partly by the OS and partly by hardware protection bits:

<svg viewBox="0 0 500 420" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <defs> <marker id="vm1" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#78909c"/> </marker> </defs> <!-- Address bar --> <rect x="140" y="10" width="180" height="30" rx="2" fill="#263238" stroke="#546e7a" stroke-width="1"/> <text x="230" y="30" text-anchor="middle" fill="#90a4ae" font-size="11">High address (kernel)</text> <!-- Kernel --> <rect x="140" y="42" width="180" height="36" rx="2" fill="#37474f" stroke="#546e7a" stroke-width="1"/> <text x="230" y="60" text-anchor="middle" fill="#b0bec5">Kernel space</text> <text x="230" y="73" text-anchor="middle" fill="#78909c" font-size="10">(not accessible in user mode)</text> <!-- Stack --> <rect x="140" y="80" width="180" height="42" rx="2" fill="#1a237e" stroke="#3949ab" stroke-width="1"/> <text x="230" y="97" text-anchor="middle" fill="#9fa8da">Stack</text> <text x="230" y="111" text-anchor="middle" fill="#7986cb" font-size="10">grows downward ↓</text> <!-- Gap --> <rect x="140" y="124" width="180" height="30" rx="2" fill="#121212" stroke="#2a2a2a" stroke-width="1" stroke-dasharray="4,3"/> <text x="230" y="143" text-anchor="middle" fill="#424242" font-size="10">unmapped / guard region</text> <!-- Memory-mapped --> <rect x="140" y="156" width="180" height="36" rx="2" fill="#1b5e20" stroke="#388e3c" stroke-width="1"/> <text x="230" y="173" text-anchor="middle" fill="#a5d6a7">Memory-mapped files</text> <text x="230" y="187" text-anchor="middle" fill="#81c784" font-size="10">mmap(), shared libs</text> <!-- Heap --> <rect x="140" y="194" width="180" height="42" rx="2" fill="#4a148c" stroke="#7b1fa2" stroke-width="1"/> <text x="230" y="211" text-anchor="middle" fill="#ce93d8">Heap</text> <text x="230" y="225" text-anchor="middle" fill="#ba68c8" font-size="10">grows upward ↑</text> <!-- BSS --> <rect x="140" y="238" width="180" height="30" rx="2" fill="#b71c1c" stroke="#c62828" stroke-width="1"/> <text x="230" y="258" text-anchor="middle" fill="#ffcdd2">BSS (uninit. data)</text> <!-- Data --> <rect x="140" y="270" width="180" height="30" rx="2" fill="#e65100" stroke="#ef6c00" stroke-width="1"/> <text x="230" y="290" text-anchor="middle" fill="#ffe0b2">Data (init. globals)</text> <!-- Text --> <rect x="140" y="302" width="180" height="36" rx="2" fill="#827717" stroke="#f9a825" stroke-width="1"/> <text x="230" y="319" text-anchor="middle" fill="#fff59d">Text (code)</text> <text x="230" y="333" text-anchor="middle" fill="#fff176" font-size="10">read-only, executable</text> <!-- Low address --> <rect x="140" y="340" width="180" height="30" rx="2" fill="#263238" stroke="#546e7a" stroke-width="1"/> <text x="230" y="360" text-anchor="middle" fill="#90a4ae" font-size="11">Low address (0x0 reserved)</text> <!-- Address annotations -->

<text x="128" y="58" text-anchor="end" fill="#546e7a" font-size="10">0xFFFF...</text> <text x="128" y="100" text-anchor="end" fill="#546e7a" font-size="10">~0x7FFF...</text> <text x="128" y="315" text-anchor="end" fill="#546e7a" font-size="10">0x0040...</text> <text x="128" y="355" text-anchor="end" fill="#546e7a" font-size="10">0x0000...</text>

<!-- Direction arrows -->

<text x="340" y="100" fill="#3949ab" font-size="18">↓</text> <text x="340" y="220" fill="#7b1fa2" font-size="18">↑</text> </svg>

Each region has associated **protection bits**: read, write, execute permissions enforced by the hardware on every memory access. An access violating these bits raises a protection fault (segmentation fault on Linux).

---

### The Address Translation Problem

Every memory reference a program makes uses a **virtual address (VA)**. Before the memory system can act on it, hardware must translate it to a **physical address (PA)**. This translation must be:

- Fast — it occurs on every instruction fetch and every load/store.
- Correct — the mapping is defined by the OS and must not be circumventable by user code.
- Transparent — the program is unaware that translation is occurring.

The hardware unit that performs translation is the **Memory Management Unit (MMU)**, which operates using data structures (page tables) maintained by the OS in physical memory.

---

### Paging

Paging is the dominant virtual memory implementation. Both the virtual address space and physical memory are divided into fixed-size units:

- **Page** — a fixed-size block of virtual address space (typically 4 KiB).
- **Frame** (physical page frame) — a fixed-size block of physical memory, same size as a page.

Any page can be mapped to any frame. Pages not currently needed can be **evicted** to disk (the swap space or page file); their frame is then reclaimed for other use.

**Page size trade-offs:**

|Smaller pages (4 KiB)|Larger pages (2 MiB, 1 GiB — huge pages)|
|---|---|
|Fine-grained allocation, less internal fragmentation|Fewer page table entries|
|Larger page tables|Fewer TLB entries needed to cover same memory|
|More TLB entries needed|Better for large contiguous allocations (databases, JVM heaps)|

---

### Page Table Structure

A **page table** is an array indexed by the **virtual page number (VPN)**. Each entry is a **page table entry (PTE)**.

#### Address Decomposition (4 KiB pages, 32-bit VA)

```
 31          12 11        0
 ┌─────────────┬───────────┐
 │  VPN (20b)  │ Offset    │
 └─────────────┴───────────┘
```

- **VPN** indexes into the page table to find the PTE.
- **Page offset** is appended directly to the physical frame number (PFN) to form the physical address.

#### Page Table Entry Fields

|Field|Purpose|
|---|---|
|PFN|Physical frame number — where in physical memory this page resides|
|Valid (V)|1 = page is present in physical memory; 0 = not resident (triggers page fault)|
|Dirty (D)|1 = page has been written since last loaded; must be written to disk on eviction|
|Accessed (A) / Reference (R)|Set by hardware on any access; used by replacement algorithms|
|Read / Write / Execute|Protection bits; enforced by MMU on every access|
|User / Supervisor|Controls whether user-mode code can access this page|
|Cache disable / Write-through|Cache policy override for memory-mapped I/O regions|

---

### Multi-Level Page Tables

A flat page table for a 32-bit address space with 4 KiB pages requires $2^{20}$ entries × 4 bytes = **4 MiB per process**. For 64-bit address spaces this becomes impractical. Multi-level page tables solve this by making the page table itself sparse.

#### Two-Level Example (32-bit, x86)

```
 31      22 21      12 11        0
 ┌─────────┬──────────┬───────────┐
 │  L1 idx │  L2 idx  │  Offset   │
 │  (10b)  │  (10b)   │  (12b)    │
 └─────────┴──────────┴───────────┘
```

1. L1 index selects a **page directory entry** → points to a page table (L2).
2. L2 index selects a **PTE** within that page table → gives PFN.
3. PFN concatenated with offset → physical address.

Only page tables for regions actually in use need be allocated. A process using only a few hundred MiB of a 4 GiB space allocates only the L2 tables covering those regions.

#### x86-64 Four-Level Paging (48-bit VA)

```
 47    39 38    30 29    21 20    12 11       0
 ┌───────┬────────┬────────┬────────┬──────────┐
 │ PML4  │  PDPT  │   PD   │   PT   │  Offset  │
 │  (9b) │  (9b)  │  (9b)  │  (9b)  │  (12b)   │
 └───────┴────────┴────────┴────────┴──────────┘
```

Each level is a 512-entry table (9 bits); the base address of the PML4 table is held in the **CR3 register**, which the OS updates on every context switch.

A full translation traverses four levels — four memory reads — before the physical address is known. The TLB exists to cache the result of this traversal.

---

### Page Fault Handling

A **page fault** is a hardware exception raised by the MMU when a virtual address cannot be translated — either because the PTE has the valid bit clear (page not resident) or because a protection violation occurred.

<svg viewBox="0 0 580 380" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <defs> <marker id="pf1" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#78909c"/> </marker> <marker id="pf2" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#ef9a9a"/> </marker> <marker id="pf3" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#a5d6a7"/> </marker> </defs> <!-- Start --> <rect x="200" y="10" width="160" height="32" rx="4" fill="#263238" stroke="#546e7a" stroke-width="1.2"/> <text x="280" y="31" text-anchor="middle" fill="#cfd8dc">Memory access (VA)</text> <line x1="280" y1="42" x2="280" y2="60" stroke="#78909c" stroke-width="1.2" marker-end="url(#pf1)"/> <!-- MMU --> <rect x="200" y="62" width="160" height="32" rx="4" fill="#1a237e" stroke="#3949ab" stroke-width="1.2"/> <text x="280" y="83" text-anchor="middle" fill="#9fa8da">MMU translates VA</text> <line x1="280" y1="94" x2="280" y2="112" stroke="#78909c" stroke-width="1.2" marker-end="url(#pf1)"/> <!-- Valid? --> <polygon points="280,114 370,145 280,176 190,145" fill="#37474f" stroke="#78909c" stroke-width="1.2"/> <text x="280" y="149" text-anchor="middle" fill="#cfd8dc">PTE valid?</text> <!-- Yes path --> <line x1="370" y1="145" x2="450" y2="145" stroke="#a5d6a7" stroke-width="1.2" marker-end="url(#pf3)"/> <text x="410" y="138" fill="#a5d6a7" font-size="10">yes</text> <rect x="452" y="128" width="110" height="34" rx="4" fill="#1b5e20" stroke="#388e3c" stroke-width="1.2"/> <text x="507" y="150" text-anchor="middle" fill="#a5d6a7">Access physical</text> <!-- No path --> <line x1="280" y1="176" x2="280" y2="194" stroke="#ef9a9a" stroke-width="1.2" marker-end="url(#pf2)"/> <text x="290" y="190" fill="#ef9a9a" font-size="10">no</text> <!-- Page fault --> <rect x="200" y="196" width="160" height="32" rx="4" fill="#b71c1c" stroke="#c62828" stroke-width="1.2"/> <text x="280" y="217" text-anchor="middle" fill="#ffcdd2">Page fault exception</text> <line x1="280" y1="228" x2="280" y2="246" stroke="#78909c" stroke-width="1.2" marker-end="url(#pf1)"/> <!-- Protection? --> <polygon points="280,248 380,275 280,302 180,275" fill="#37474f" stroke="#78909c" stroke-width="1.2"/> <text x="280" y="272" text-anchor="middle" fill="#cfd8dc">Protection</text> <text x="280" y="285" text-anchor="middle" fill="#cfd8dc">violation?</text> <!-- Yes = SIGSEGV --> <line x1="380" y1="275" x2="460" y2="275" stroke="#ef9a9a" stroke-width="1.2" marker-end="url(#pf2)"/> <text x="420" y="268" fill="#ef9a9a" font-size="10">yes</text> <rect x="462" y="258" width="100" height="34" rx="4" fill="#4a148c" stroke="#7b1fa2" stroke-width="1.2"/> <text x="512" y="275" text-anchor="middle" fill="#ce93d8">SIGSEGV /</text> <text x="512" y="288" text-anchor="middle" fill="#ce93d8">terminate</text> <!-- No = load page --> <line x1="280" y1="302" x2="280" y2="320" stroke="#a5d6a7" stroke-width="1.2" marker-end="url(#pf3)"/> <text x="290" y="316" fill="#a5d6a7" font-size="10">no</text> <!-- OS loads page --> <rect x="185" y="322" width="190" height="32" rx="4" fill="#e65100" stroke="#ef6c00" stroke-width="1.2"/> <text x="280" y="338" text-anchor="middle" fill="#ffe0b2">OS: find free frame,</text> <text x="280" y="350" text-anchor="middle" fill="#ffe0b2">load page from disk, update PTE</text> <!-- Restart --> <path d="M 185 338 Q 120 338 120 78 Q 120 78 200 78" fill="none" stroke="#a5d6a7" stroke-width="1.2" stroke-dasharray="5,3" marker-end="url(#pf3)"/> <text x="100" y="220" fill="#a5d6a7" font-size="10" transform="rotate(-90,100,220)">restart instruction</text> </svg>

When the OS handles a valid page fault (not a protection violation):

1. The faulting process is **suspended**; the OS takes control.
2. The OS selects a **victim frame** using a replacement policy if no free frames exist.
3. If the victim frame is **dirty**, its contents are written to disk (swap).
4. The required page is **read from disk** into the victim frame.
5. The **PTE is updated**: valid bit set, PFN filled in, dirty bit cleared.
6. The **TLB entry** for the old mapping (if any) is invalidated.
7. The faulting instruction is **restarted** from the beginning — the access now succeeds.

This is the mechanism behind **demand paging**: pages are loaded only when first accessed rather than at program load time.

---

### Page Replacement Policies

When all physical frames are occupied and a new page must be brought in, a victim must be chosen.

#### Optimal (OPT / Bélády's Algorithm)

Evict the page whose next use is furthest in the future. Provably optimal — minimizes page fault rate. Not implementable in practice (requires future knowledge); used as a benchmark.

#### FIFO

Evict the page that has been in memory the longest. Simple but exhibits **Bélády's anomaly**: adding more frames can increase the page fault rate for some reference strings. Poor practical performance.

#### Least Recently Used (LRU)

Evict the page not used for the longest time. Strong approximation of OPT under temporal locality. Exact LRU is expensive — requires timestamping every memory access. Hardware typically provides only approximate information (the **accessed bit**).

#### Clock Algorithm (Second Chance)

An efficient LRU approximation. Pages are arranged in a circular list. A clock hand advances; if the accessed bit of the current page is 1, it is cleared and the hand moves on (the page gets a second chance). If the bit is 0, the page is evicted. The accessed bit is set by hardware on any reference to the page.

#### Working Set Model

The **working set** $W(t, \Delta)$ is the set of pages referenced in the time window $[,t - \Delta,, t,]$. The OS tracks each process's working set and aims to keep it resident. If the total working set size across all processes exceeds physical memory, **thrashing** occurs — the system spends more time handling page faults than executing instructions. The OS response to thrashing is to **suspend** one or more processes entirely, freeing their frames for the remaining processes.

---

### Translation Lookaside Buffer (TLB)

Without a TLB, every memory access requires multiple physical memory reads (one per page table level) before the actual access — a 4× or 5× slowdown for a 4-level table. The TLB is a small, fully associative (or set-associative) cache inside the MMU that stores recently used VPN→PFN translations.

#### TLB Operation

```
On every memory access:
  1. Check TLB for VPN
  2. TLB hit  → use cached PFN directly (1–2 cycle latency)
  3. TLB miss → walk page table (hardware or software)
             → load translation into TLB
             → evict old TLB entry if full (LRU or random)
             → retry access
```

#### TLB Miss Handling

|Approach|Mechanism|Used by|
|---|---|---|
|Hardware page table walk|MMU walks the page table autonomously; OS is not involved|x86, ARM (most)|
|Software-managed TLB|TLB miss raises an exception; OS fills the TLB via a miss handler|MIPS, SPARC, some RISC-V configs|

Software-managed TLBs give the OS freedom to use any page table format but add OS overhead on every miss. Hardware-managed TLBs require the page table format to be defined by the ISA.

#### TLB Reach and Coverage

$$\text{TLB reach} = \text{TLB entries} \times \text{page size}$$

A 64-entry TLB with 4 KiB pages covers 256 KiB. A working set larger than the TLB reach causes frequent misses (**TLB thrashing**). Huge pages (2 MiB, 1 GiB) dramatically increase TLB reach without increasing entry count, which is a primary motivation for their use in databases and scientific workloads.

#### TLB and Context Switches

On a context switch, virtual address mappings change (each process has its own page table). The TLB must either be:

- **Flushed entirely** — simple but expensive; every post-switch access is a TLB miss.
- **Tagged with an Address Space Identifier (ASID)** — each TLB entry carries the ASID of its process. Entries from other processes remain valid; the TLB checks both VPN and ASID. x86-64 supports PCIDs for this purpose; ARM uses ASIDs. This eliminates flush overhead on context switches.

---

### Virtual Memory and Sharing

Because the page table maps virtual to physical, multiple processes can have PTEs pointing to the **same physical frame**. This enables:

- **Shared libraries**: a single physical copy of `libc.so` mapped into every process's address space — read-only and executable.
- **Copy-on-write (CoW)**: after `fork()`, parent and child share all physical frames. Both PTEs are marked read-only. On the first write by either process, a protection fault is raised; the OS copies the frame, remaps the writing process's PTE to the new copy, and marks it writable. Shared pages are duplicated lazily, only when modified.
- **IPC shared memory**: two processes explicitly share a physical region (`mmap()` with `MAP_SHARED`), with writes by one immediately visible to the other.

---

### Address Space Identifiers and Tagged TLBs

<svg viewBox="0 0 580 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- TLB table --> <rect x="10" y="10" width="560" height="28" rx="3" fill="#263238" stroke="#455a64" stroke-width="1"/> <text x="60" y="29" text-anchor="middle" fill="#90a4ae">ASID</text> <text x="180" y="29" text-anchor="middle" fill="#90a4ae">VPN</text> <text x="330" y="29" text-anchor="middle" fill="#90a4ae">PFN</text> <text x="460" y="29" text-anchor="middle" fill="#90a4ae">Prot / Flags</text> <!-- Row: process A --> <rect x="10" y="40" width="560" height="30" rx="1" fill="#1a237e" stroke="#3949ab" stroke-width="0.8"/> <text x="60" y="59" text-anchor="middle" fill="#9fa8da">0x01 (A)</text> <text x="180" y="59" text-anchor="middle" fill="#9fa8da">0x0040 1</text> <text x="330" y="59" text-anchor="middle" fill="#9fa8da">0x00A3 F</text> <text x="460" y="59" text-anchor="middle" fill="#9fa8da">R-X user</text> <!-- Row: process B --> <rect x="10" y="72" width="560" height="30" rx="1" fill="#1b5e20" stroke="#388e3c" stroke-width="0.8"/> <text x="60" y="91" text-anchor="middle" fill="#a5d6a7">0x02 (B)</text> <text x="180" y="91" text-anchor="middle" fill="#a5d6a7">0x0040 1</text> <text x="330" y="91" text-anchor="middle" fill="#a5d6a7">0x00B1 2</text> <text x="460" y="91" text-anchor="middle" fill="#a5d6a7">R-X user</text> <!-- Row: shared lib --> <rect x="10" y="104" width="560" height="30" rx="1" fill="#4a148c" stroke="#7b1fa2" stroke-width="0.8"/> <text x="60" y="123" text-anchor="middle" fill="#ce93d8">0x01 (A)</text> <text x="180" y="123" text-anchor="middle" fill="#ce93d8">0x7FFF 0</text> <text x="330" y="123" text-anchor="middle" fill="#ce93d8">0x00C4 4</text> <text x="460" y="123" text-anchor="middle" fill="#ce93d8">R-X user (shared lib)</text> <rect x="10" y="136" width="560" height="30" rx="1" fill="#4a148c" stroke="#7b1fa2" stroke-width="0.8"/> <text x="60" y="155" text-anchor="middle" fill="#ce93d8">0x02 (B)</text> <text x="180" y="155" text-anchor="middle" fill="#ce93d8">0x7FFF 0</text> <text x="330" y="155" text-anchor="middle" fill="#ce93d8">0x00C4 4</text> <text x="460" y="155" text-anchor="middle" fill="#ce93d8">R-X user (shared lib)</text>

<text x="290" y="196" text-anchor="middle" fill="#546e7a" font-size="10">Both processes share PFN 0x00C44 (same physical page); different ASIDs keep their private mappings distinct</text>

<!-- Column dividers --> <line x1="110" y1="10" x2="110" y2="166" stroke="#37474f" stroke-width="0.6"/> <line x1="250" y1="10" x2="250" y2="166" stroke="#37474f" stroke-width="0.6"/> <line x1="400" y1="10" x2="400" y2="166" stroke="#37474f" stroke-width="0.6"/> </svg>

---

### Segmentation vs. Paging

Some architectures (notably x86 in protected mode) provide **segmentation** as a separate or complementary mechanism. Segmentation divides the address space into variable-size logical segments (code, data, stack), each with a base and limit. x86-64 largely abandons segmentation for user space (segment bases are 0); paging is the operative mechanism.

|Property|Segmentation|Paging|
|---|---|---|
|Unit size|Variable (segment size)|Fixed (page size)|
|Fragmentation type|External (gaps between segments)|Internal (last page partially used)|
|Sharing granularity|Per segment|Per page|
|Hardware complexity|Base+limit per segment|Multi-level page table walk|
|Modern usage|Rare (FS/GS for TLS on x86-64)|Universal|

---

### Summary of Virtual Memory Components

|Component|Location|Role|
|---|---|---|
|Page table|Physical memory (OS-managed)|Maps VPN → PFN for entire address space|
|CR3 / TTBR register|CPU register|Points to root of current process's page table|
|MMU|CPU hardware|Performs page table walk on TLB miss|
|TLB|On-chip cache in MMU|Caches recent VPN → PFN translations|
|Page fault handler|OS kernel|Loads missing pages, enforces protection|
|Swap space|Disk / SSD|Backing store for evicted pages|

---

**Conclusion**

Virtual memory is a cooperative abstraction maintained jointly by the OS and hardware. The OS defines the mapping through page table structures and handles fault resolution; the hardware enforces the mapping on every access through the MMU and caches translations in the TLB. The system achieves process isolation, transparent use of disk as extended memory, efficient sharing of physical pages, and a uniform address space model — all without program awareness. The performance of the abstraction rests critically on TLB hit rates, which in turn depend on working set size, page size, TLB capacity, and ASID support.

**Next Steps**

- TLB design — associativity, ASID implementation, shootdown protocols in multiprocessor systems, and the interaction between TLB reach and huge page support.
- Paging and page tables — inverted page tables, hashed page tables, and the specific page table formats of x86-64 (PML4/PML5) and ARMv8.
- Cache coherence — how virtual memory sharing interacts with physically tagged caches, and the aliasing problems that arise when multiple virtual addresses map to the same physical cache line.

---

