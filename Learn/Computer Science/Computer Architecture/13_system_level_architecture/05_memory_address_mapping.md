## Memory Address Mapping


Memory address mapping is the set of mechanisms by which a processor's address space — the range of addresses an instruction can generate — is translated into locations in physical memory, memory-mapped devices, or firmware regions. It encompasses both static assignment of address ranges to hardware resources and the dynamic translation of virtual addresses to physical addresses at runtime.

---

### Address Space Concepts

A processor generates **logical (virtual) addresses** during instruction execution. These are transformed through one or more layers before reaching a physical memory cell.

|Term|Definition|
|---|---|
|**Physical address space**|The range of addresses the memory bus can carry; bounded by address line count|
|**Virtual address space**|The range of addresses a process can generate; bounded by pointer width and page table depth|
|**Address space size**|$2^n$ where $n$ is the number of address bits|
|**Physical address extension (PAE)**|Mechanism to access more physical memory than the virtual address width would otherwise permit|

A 32-bit processor generates 32-bit virtual addresses ($2^{32}$ = 4 GiB addressable), but may interface with a memory controller that uses 36 physical address bits ($2^{36}$ = 64 GiB), requiring PAE or equivalent extension.

---

### Physical Address Map

Before virtual memory is considered, the physical address space is statically partitioned between DRAM, ROM/firmware, and memory-mapped I/O regions. This partition is established by the hardware platform — chipset, SoC design, or BIOS/UEFI firmware — and is not under operating system control.

#### Typical x86 Physical Address Map (Legacy 32-bit)

<svg viewBox="0 0 480 520" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <defs> <marker id="arn" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#777"/> </marker> </defs> <!-- Address bar --> <rect x="160" y="20" width="140" height="460" rx="3" fill="#111" stroke="#444" stroke-width="1"/> <!-- Regions bottom to top (low address at bottom) --> <!-- DRAM: 0x00000000 – 0x0009FFFF conventional memory --> <rect x="160" y="400" width="140" height="60" fill="#1a3a2a" stroke="#66bb6a" stroke-width="1"/> <text x="230" y="422" fill="#66bb6a" text-anchor="middle">Conventional</text> <text x="230" y="436" fill="#66bb6a" text-anchor="middle">RAM</text> <text x="230" y="450" fill="#888" text-anchor="middle" font-size="9">640 KiB usable</text> <!-- Legacy region 0x000A0000 – 0x000FFFFF --> <rect x="160" y="350" width="140" height="50" fill="#2a2a1a" stroke="#f9a825" stroke-width="1"/> <text x="230" y="368" fill="#f9a825" text-anchor="middle">Legacy Region</text> <text x="230" y="382" fill="#f9a825" text-anchor="middle">VGA / ROM</text> <text x="230" y="393" fill="#888" text-anchor="middle" font-size="9">384 KiB</text> <!-- Extended RAM --> <rect x="160" y="190" width="140" height="160" fill="#1a2a3a" stroke="#4fc3f7" stroke-width="1"/> <text x="230" y="262" fill="#4fc3f7" text-anchor="middle">Extended RAM</text> <text x="230" y="278" fill="#888" text-anchor="middle" font-size="9">1 MiB – ~3 GiB</text> <!-- PCI Hole / MMIO --> <rect x="160" y="120" width="140" height="70" fill="#2a1a2a" stroke="#ce93d8" stroke-width="1"/> <text x="230" y="148" fill="#ce93d8" text-anchor="middle">PCI Hole /</text> <text x="230" y="163" fill="#ce93d8" text-anchor="middle">MMIO Region</text> <text x="230" y="178" fill="#888" text-anchor="middle" font-size="9">~3 GiB – 4 GiB</text> <!-- BIOS / Firmware ROM --> <rect x="160" y="20" width="140" height="100" fill="#3a1a1a" stroke="#ef9a9a" stroke-width="1"/> <text x="230" y="55" fill="#ef9a9a" text-anchor="middle">Firmware ROM</text> <text x="230" y="70" fill="#ef9a9a" text-anchor="middle">BIOS / UEFI</text> <text x="230" y="85" fill="#888" text-anchor="middle" font-size="9">Reset vector:</text> <text x="230" y="98" fill="#888" text-anchor="middle" font-size="9">0xFFFFFFF0</text> <!-- Address labels left side -->

<text x="150" y="478" fill="#555" text-anchor="end" font-size="9">0x00000000</text> <text x="150" y="402" fill="#555" text-anchor="end" font-size="9">0x000A0000</text> <text x="150" y="352" fill="#555" text-anchor="end" font-size="9">0x00100000</text> <text x="150" y="192" fill="#555" text-anchor="end" font-size="9">~0xC0000000</text> <text x="150" y="122" fill="#555" text-anchor="end" font-size="9">~0xFFFFFFFF</text> <text x="150" y="22" fill="#555" text-anchor="end" font-size="9">0xFFFFFFF0</text>

<!-- Tick marks --> <line x1="155" y1="477" x2="160" y2="477" stroke="#555" stroke-width="1"/> <line x1="155" y1="401" x2="160" y2="401" stroke="#555" stroke-width="1"/> <line x1="155" y1="351" x2="160" y2="351" stroke="#555" stroke-width="1"/> <line x1="155" y1="191" x2="160" y2="191" stroke="#555" stroke-width="1"/> <line x1="155" y1="121" x2="160" y2="121" stroke="#555" stroke-width="1"/> <!-- Annotations right side -->

<text x="315" y="432" fill="#66bb6a" font-size="10">DOS era "640K barrier"</text> <text x="315" y="375" fill="#f9a825" font-size="10">VGA framebuffer,</text> <text x="315" y="387" fill="#f9a825" font-size="10">option ROMs</text> <text x="315" y="265" fill="#4fc3f7" font-size="10">OS and user</text> <text x="315" y="278" fill="#4fc3f7" font-size="10">process RAM</text> <text x="315" y="155" fill="#ce93d8" font-size="10">PCIe BARs,</text> <text x="315" y="168" fill="#ce93d8" font-size="10">APIC, HPET</text> <text x="315" y="65" fill="#ef9a9a" font-size="10">Mapped at reset;</text> <text x="315" y="78" fill="#ef9a9a" font-size="10">CPU starts here</text>

<!-- Low/High labels -->

<text x="230" y="510" fill="#555" text-anchor="middle" font-size="10">Low address</text> <text x="230" y="14" fill="#555" text-anchor="middle" font-size="10">High address</text> </svg>

The **PCI hole** (also called MMIO hole) is the region where physical RAM cannot be placed because those addresses are reserved for device registers and PCI/PCIe Base Address Registers (BARs). On 32-bit systems this consumed roughly 256 MiB–1 GiB of the top of the physical address space, making some installed RAM unreachable without PAE.

---

### Memory-Mapped I/O

Memory-mapped I/O (MMIO) assigns device registers to physical addresses rather than using a separate I/O address space (port-mapped I/O). The processor accesses a device by issuing a load or store to the assigned physical address range; the memory controller routes the transaction to the device instead of DRAM.

|Characteristic|MMIO|Port-mapped I/O (PMIO)|
|---|---|---|
|Address space|Shared with RAM|Separate I/O space|
|Access instruction|Normal load/store|`IN`/`OUT` (x86 only)|
|Address width|Full pointer width|16-bit port number (x86)|
|Cacheability|Marked uncacheable in page tables|Always uncached|
|Prevalence|Universal (ARM, RISC-V, all modern)|x86 legacy only|

MMIO regions must be marked **uncacheable** and **non-speculative** in the page table attributes (PAT / MAIR on ARM). A cached read of a device register would return a stale value from cache; a cached write would not reach the device. The processor must issue the transaction to the bus immediately and in order.

---

### Virtual to Physical Address Translation

The operating system and hardware jointly implement a multi-level translation from virtual addresses to physical addresses. The hardware component is the **Memory Management Unit (MMU)**; the data structure maintained in memory is the **page table**.

#### Translation Granularity

|Page size|Offset bits|Index bits available|
|---|---|---|
|4 KiB|12|52 (in 64-bit)|
|2 MiB|21|43|
|1 GiB|30|34|

Larger pages (**huge pages**, **superpages**) reduce TLB pressure at the cost of internal fragmentation.

---

### Page Table Structures

#### Single-Level Page Table

The simplest structure: an array indexed by the virtual page number (VPN), each entry holding the physical frame number (PFN) plus attributes.

```
Virtual Address:  [ VPN (20 bits) | Page Offset (12 bits) ]
                         |
                    Page Table
                   (2^20 entries × 4 bytes = 4 MiB per process)
                         |
                        PFN
                         |
Physical Address: [ PFN | Page Offset ]
```

A single-level table for a 32-bit address space with 4 KiB pages requires $2^{20}$ entries = 4 MiB per process. For thousands of processes this is prohibitive. Multi-level tables solve this by only allocating subtables for virtual regions actually in use.

---

#### Two-Level Page Table (x86 32-bit)

<svg viewBox="0 0 680 260" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <defs> <marker id="a2" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#4fc3f7"/> </marker> </defs> <!-- Virtual address decomposition -->

<text x="10" y="18" fill="#aaa">Virtual Address (32-bit)</text> <rect x="10" y="25" width="100" height="28" rx="2" fill="#1a2a3a" stroke="#4fc3f7" stroke-width="1.5"/> <text x="60" y="44" fill="#4fc3f7" text-anchor="middle">Dir [31:22]</text> <rect x="110" y="25" width="100" height="28" rx="2" fill="#1a3a1a" stroke="#66bb6a" stroke-width="1.5"/> <text x="160" y="44" fill="#66bb6a" text-anchor="middle">Table [21:12]</text> <rect x="210" y="25" width="100" height="28" rx="2" fill="#2a1a2a" stroke="#ce93d8" stroke-width="1.5"/> <text x="260" y="44" fill="#ce93d8" text-anchor="middle">Offset [11:0]</text>

<!-- CR3 --> <rect x="10" y="110" width="80" height="28" rx="2" fill="#2a1a1a" stroke="#ef9a9a" stroke-width="1.5"/> <text x="50" y="129" fill="#ef9a9a" text-anchor="middle">CR3</text> <!-- Page Directory --> <rect x="150" y="90" width="110" height="68" rx="2" fill="#1a2a3a" stroke="#4fc3f7" stroke-width="1.5"/> <text x="205" y="108" fill="#4fc3f7" text-anchor="middle">Page Directory</text> <line x1="150" y1="115" x2="260" y2="115" stroke="#4fc3f7" stroke-width="0.5"/> <rect x="155" y="118" width="100" height="14" rx="1" fill="#4fc3f7" fill-opacity="0.2"/> <text x="205" y="129" fill="#aaa" text-anchor="middle" font-size="9">entry[Dir] → PTE base</text> <line x1="150" y1="133" x2="260" y2="133" stroke="#4fc3f7" stroke-width="0.5"/> <text x="205" y="150" fill="#555" text-anchor="middle" font-size="9">1024 entries</text> <!-- Page Table --> <rect x="380" y="90" width="110" height="68" rx="2" fill="#1a3a1a" stroke="#66bb6a" stroke-width="1.5"/> <text x="435" y="108" fill="#66bb6a" text-anchor="middle">Page Table</text> <line x1="380" y1="115" x2="490" y2="115" stroke="#66bb6a" stroke-width="0.5"/> <rect x="385" y="118" width="100" height="14" rx="1" fill="#66bb6a" fill-opacity="0.2"/> <text x="435" y="129" fill="#aaa" text-anchor="middle" font-size="9">entry[Table] → PFN</text> <line x1="380" y1="133" x2="490" y2="133" stroke="#66bb6a" stroke-width="0.5"/> <text x="435" y="150" fill="#555" text-anchor="middle" font-size="9">1024 entries</text> <!-- Physical address --> <rect x="565" y="100" width="105" height="48" rx="2" fill="#2a2a1a" stroke="#f9a825" stroke-width="1.5"/> <text x="617" y="118" fill="#f9a825" text-anchor="middle">Physical</text> <text x="617" y="133" fill="#f9a825" text-anchor="middle">Address</text> <text x="617" y="145" fill="#888" text-anchor="middle" font-size="9">PFN + Offset</text> <!-- Arrows --> <line x1="90" y1="124" x2="150" y2="124" stroke="#4fc3f7" stroke-width="1.5" marker-end="url(#a2)"/> <line x1="260" y1="124" x2="380" y2="124" stroke="#66bb6a" stroke-width="1.5" marker-end="url(#a2)"/> <line x1="490" y1="124" x2="565" y2="124" stroke="#f9a825" stroke-width="1.5" marker-end="url(#a2)"/> <!-- Bit labels -->

<text x="60" y="80" fill="#4fc3f7" text-anchor="middle" font-size="9">10 bits → 1024 dirs</text> <text x="160" y="80" fill="#66bb6a" text-anchor="middle" font-size="9">10 bits → 1024 PTEs</text> <text x="260" y="80" fill="#ce93d8" text-anchor="middle" font-size="9">12 bits → 4 KiB page</text>

<!-- Offset join --> <line x1="260" y1="53" x2="617" y2="53" stroke="#ce93d8" stroke-width="1" stroke-dasharray="4,3"/> <line x1="617" y1="53" x2="617" y2="100" stroke="#ce93d8" stroke-width="1" stroke-dasharray="4,3"/>

<text x="340" y="220" fill="#555" text-anchor="middle" font-size="10">Each page table: 4 KiB (1024 × 4-byte entries). Only allocated subtables consume memory.</text> </svg>

---

#### Four-Level Page Table (x86-64, IA-32e)

64-bit x86 uses 48-bit virtual addresses (with 57-bit extension in 5-level paging). The translation uses four levels:

```
Virtual Address (48-bit canonical):
 [ PML4 index | PDPT index | PD index | PT index | Offset ]
   [47:39]      [38:30]      [29:21]    [20:12]    [11:0]
   9 bits        9 bits       9 bits     9 bits     12 bits

CR3 → PML4 table (512 entries)
          ↓ entry[PML4]
       PDPT table (512 entries)
          ↓ entry[PDPT]   ← 1 GiB superpage possible here
       Page Directory (512 entries)
          ↓ entry[PD]     ← 2 MiB superpage possible here
       Page Table (512 entries)
          ↓ entry[PT]     ← 4 KiB page
       Physical Frame + Offset
```

Each table occupies exactly one 4 KiB page (512 × 8-byte entries). The OS allocates a table only when a virtual address range within its coverage is mapped — making the structure sparse and memory-efficient.

**5-level paging (PML5):** Extends to 57-bit virtual addresses and 52-bit physical addresses by adding a fifth level (PML5 table above PML4). Supported in recent Intel and AMD processors; required for address spaces larger than 128 TiB per process.

---

### Page Table Entry Format (x86-64)

Each 8-byte PTE carries:

|Bits|Field|Meaning|
|---|---|---|
|0|**P** (Present)|Entry valid; page is in physical memory|
|1|**R/W**|0 = read-only, 1 = read/write|
|2|**U/S**|0 = supervisor only, 1 = user accessible|
|3|**PWT**|Page-level write-through|
|4|**PCD**|Page-level cache disable|
|5|**A** (Accessed)|Set by MMU on any access|
|6|**D** (Dirty)|Set by MMU on write|
|7|**PS**|Page size (superpage at PD/PDPT level)|
|11:8|Available|OS use|
|51:12|**PFN**|Physical frame number (40 bits → 52-bit PA)|
|62:52|Available|OS use (e.g., swap offset hint)|
|63|**NX/XD**|No-execute; prevents instruction fetch|

The **Accessed** and **Dirty** bits are set automatically by the MMU during normal memory operations. The OS reads and clears them to implement page replacement and copy-on-write decisions without intercepting every memory access.

---

### TLB — Translation Lookaside Buffer

Walking the page table for every memory access would require 4 additional memory reads on x86-64 (one per level). The TLB caches recent virtual-to-physical translations.

#### TLB Organization

<svg viewBox="0 0 640 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <defs> <marker id="at" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#aaa"/> </marker> </defs> <!-- CPU --> <rect x="10" y="75" width="80" height="50" rx="3" fill="#1a2a3a" stroke="#4fc3f7" stroke-width="1.5"/> <text x="50" y="104" fill="#4fc3f7" text-anchor="middle">CPU</text> <text x="50" y="116" fill="#888" text-anchor="middle" font-size="9">VA generated</text> <!-- TLB --> <rect x="140" y="40" width="180" height="120" rx="3" fill="#1a1a2a" stroke="#ce93d8" stroke-width="1.5"/> <text x="230" y="60" fill="#ce93d8" text-anchor="middle">TLB</text> <line x1="140" y1="68" x2="320" y2="68" stroke="#444" stroke-width="0.5"/> <text x="175" y="82" fill="#888" font-size="9">VPN</text> <text x="245" y="82" fill="#888" font-size="9">ASID</text> <text x="295" y="82" fill="#888" font-size="9">PFN+flags</text> <line x1="140" y1="88" x2="320" y2="88" stroke="#444" stroke-width="0.5"/> <rect x="145" y="92" width="170" height="14" rx="1" fill="#ce93d8" fill-opacity="0.15"/> <text x="175" y="102" fill="#aaa" font-size="9">0x7fff1</text> <text x="245" y="102" fill="#aaa" font-size="9">0x04</text> <text x="295" y="102" fill="#aaa" font-size="9">0x3a200 RW</text>

<text x="175" y="118" fill="#555" font-size="9">0x7fff2</text> <text x="245" y="118" fill="#555" font-size="9">0x04</text> <text x="295" y="118" fill="#555" font-size="9">0x3a201 RW</text>

<text x="175" y="134" fill="#555" font-size="9">...</text> <text x="230" y="150" fill="#666" text-anchor="middle" font-size="9">Typically 64–2048 entries, set-associative</text>

<!-- Page table walker --> <rect x="400" y="60" width="130" height="80" rx="3" fill="#1a3a1a" stroke="#66bb6a" stroke-width="1.5"/> <text x="465" y="85" fill="#66bb6a" text-anchor="middle">Page Table</text> <text x="465" y="100" fill="#66bb6a" text-anchor="middle">Walker</text> <text x="465" y="118" fill="#888" text-anchor="middle" font-size="9">Hardware (x86)</text> <text x="465" y="130" fill="#888" text-anchor="middle" font-size="9">Software (MIPS,RISC-V)</text> <!-- Physical memory --> <rect x="580" y="75" width="50" height="50" rx="3" fill="#2a2a1a" stroke="#f9a825" stroke-width="1.5"/> <text x="605" y="101" fill="#f9a825" text-anchor="middle" font-size="10">DRAM</text> <!-- Arrows --> <line x1="90" y1="100" x2="140" y2="100" stroke="#aaa" stroke-width="1.5" marker-end="url(#at)"/> <!-- Hit path --> <line x1="320" y1="85" x2="580" y2="90" stroke="#66bb6a" stroke-width="1.5" stroke-dasharray="1,0" marker-end="url(#at)"/> <text x="440" y="78" fill="#66bb6a" font-size="9">TLB hit → PA direct</text> <!-- Miss path --> <line x1="320" y1="115" x2="400" y2="105" stroke="#f9a825" stroke-width="1.5" marker-end="url(#at)"/> <text x="340" y="138" fill="#f9a825" font-size="9">TLB miss → walk</text> <line x1="530" y1="100" x2="580" y2="100" stroke="#aaa" stroke-width="1.5" marker-end="url(#at)"/> </svg>

#### TLB Miss Handling

|Architecture|Miss handling|Page table format|
|---|---|---|
|x86, ARM (v8+)|Hardware walker (CR3/TTBR points to table)|Fixed format required|
|MIPS, older SPARC|Software TLB handler (OS trap)|OS-defined format|
|RISC-V (Sv39/Sv48)|Hardware walker|Fixed Sv39/Sv48 format|

#### ASID — Address Space Identifier

Without ASIDs, every context switch must flush the entire TLB (invalidating all cached translations) because different processes use the same virtual addresses mapped to different physical frames. ASIDs tag each TLB entry with the process identifier, allowing entries from multiple processes to coexist. On context switch, the processor updates only the ASID register rather than flushing.

|Architecture|ASID width|Notes|
|---|---|---|
|ARM (v8)|8 or 16 bits|Configurable in TCR_EL1|
|RISC-V|16 bits (Sv39/48)|In SATP register|
|x86-64|PCID (12 bits)|Optional; CR3 PCID field; requires explicit OS support|

---

### Address Translation for Kernel and User Space

The OS partitions the virtual address space between kernel and user code:

#### x86-64 Canonical Split

```
0x0000000000000000 – 0x00007FFFFFFFFFFF  : User space   (128 TiB)
                    [non-canonical gap]
0xFFFF800000000000 – 0xFFFFFFFFFFFFFFFF  : Kernel space (128 TiB)
```

The non-canonical gap (bits 63:48 must equal bit 47) causes an immediate fault on any access, providing a hard boundary that requires no permission check.

Linux further divides kernel space into:

|Region|Purpose|
|---|---|
|Direct map|All physical RAM mapped at a fixed offset; kernel accesses physical memory via this region|
|vmalloc|Non-contiguous virtual allocations|
|vmemmap|Struct page array for memory management|
|Modules|Loaded kernel modules|
|KASAN / KASLR|Shadow memory and randomized base|

#### Page Table Sharing

On x86-64, all processes share the kernel PML4 entries (upper half). Only user-space PML4 entries differ per process. A context switch updates CR3 to point to the new process's PML4; the kernel half mappings remain identical. (Meltdown mitigations introduced KPTI which separates kernel and user page tables more aggressively.)

---

### Superpages / Huge Pages

Standard 4 KiB pages require a full 4-level walk plus a TLB entry per 4 KiB. For large contiguous allocations (databases, ML model weights, video buffers), this creates TLB thrashing.

Superpages terminate the walk early:

|Level terminated|Page size|PTE flag|
|---|---|---|
|Page Directory (PD)|2 MiB|PS bit set in PDE|
|Page Directory Pointer Table (PDPT)|1 GiB|PS bit set in PDPTE|

A single 2 MiB TLB entry covers 512× more virtual space than a 4 KiB entry. The trade-off is internal fragmentation and the requirement that the physical backing be physically contiguous at that alignment.

Linux exposes huge pages via `mmap(MAP_HUGETLB)`, transparent huge pages (THP), and `/sys/kernel/mm/hugepages/`.

---

### Nested / Extended Page Tables (Virtualization)

In a virtualized environment, a guest OS manages its own page tables translating guest-virtual to guest-physical addresses. The hypervisor must additionally translate guest-physical to host-physical (true physical) addresses.

Two approaches:

|Approach|Description|Cost|
|---|---|---|
|**Shadow page tables**|Hypervisor maintains a shadow PT that maps guest-virtual directly to host-physical; trap on every guest PT modification|High overhead|
|**Extended Page Tables (EPT / NPT)**|Hardware performs two-dimensional walk: guest PT + EPT in hardware|One hardware walk per guest access; modern approach|

EPT (Intel) and NPT (AMD Nested Paging) add a second set of page tables walked entirely in hardware. A TLB miss in a VM now requires up to $4 \times 4 = 16$ memory accesses (4 guest-level walks, each requiring 4 host-level walks) in the worst case, motivating careful huge page use in hypervisors.

---

### Memory-Mapped Files

The same translation mechanism used for anonymous memory is used to map files into virtual address space (`mmap`). The OS populates PTE entries to point to page cache frames holding file data. Accessing an unmapped-but-reserved page faults; the fault handler reads the corresponding file block into a page cache frame and installs the PTE.

|Property|Anonymous mapping|File-backed mapping|
|---|---|---|
|Backing store|Swap space|File on disk|
|Initial PTE|Not present; zero-on-demand|Not present; read-from-file on fault|
|Shared between processes|No (CoW on fork)|Yes (same page cache frame)|
|Dirty page fate|Written to swap|Written back to file (msync / writeback)|

---

### Address Space Layout Randomization (ASLR)

ASLR randomizes the virtual base addresses of stack, heap, shared libraries, and executable (PIE) at load time. It does not change the translation mechanism — page tables still map virtual to physical correctly — but it makes it harder for an attacker to predict the address of a target function or buffer.

|Region|Typical entropy (x86-64 Linux)|
|---|---|
|Stack|28 bits|
|Heap (mmap base)|28 bits|
|Shared libraries|28 bits|
|Executable (PIE)|28 bits|

ASLR interacts with huge pages: aligning to 2 MiB boundaries reduces effective entropy, creating a security–performance tension that OS designers must manage explicitly.

---

### Summary of Translation Steps (x86-64, 4-level, no TLB hit)

```
1. CPU generates 64-bit virtual address
2. MMU checks: is address canonical? → fault if not
3. MMU reads CR3 → physical address of PML4 table
4. MMU indexes PML4[VA[47:39]] → PDPT base address
   Check: P=1, permission bits
5. MMU indexes PDPT[VA[38:30]] → PD base address (or 1 GiB superpage)
6. MMU indexes PD[VA[29:21]]   → PT base address  (or 2 MiB superpage)
7. MMU indexes PT[VA[20:12]]   → PFN + attributes
8. Physical address = PFN << 12 | VA[11:0]
9. MMU installs translation in TLB
10. Memory access proceeds to cache hierarchy
```

---

**Key Points**

- The physical address map partitions physical address space between DRAM, MMIO, and firmware regions — established by hardware, not the OS.
- MMIO maps device registers into the physical address space; accesses must be marked uncacheable in page table attributes.
- Multi-level page tables (2-level for 32-bit, 4-level for 64-bit x86) provide sparse coverage: only virtual regions in use require allocated subtables.
- Each PTE carries the physical frame number plus Present, R/W, U/S, Accessed, Dirty, NX, and cache attribute bits.
- The TLB caches recent translations; ASIDs and PCIDs allow multi-process TLB coexistence without full flush on context switch.
- Superpages (2 MiB, 1 GiB) terminate the walk early, reducing TLB pressure for large contiguous allocations.
- Virtualization adds a second translation layer (EPT/NPT); worst-case hardware walk requires up to 16 memory accesses.
- ASLR randomizes virtual base addresses without modifying the translation mechanism itself.

**Next Steps** Proceed to TLB design in depth (fully associative structure, global vs local entries, large-page TLBs) or advance to virtual memory management (demand paging, page replacement algorithms, working set model, thrashing).

---

