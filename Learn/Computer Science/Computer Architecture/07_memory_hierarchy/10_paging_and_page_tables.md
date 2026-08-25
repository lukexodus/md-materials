## Paging and Page Tables


Paging is the dominant virtual memory mechanism in modern processors. It decouples the **virtual address space** presented to each process from the **physical address space** of installed DRAM, allowing the OS to place, relocate, and swap memory at page granularity without exposing physical layout to software. The hardware component that performs the translation at runtime is the **Memory Management Unit (MMU)**, guided by data structures — **page tables** — maintained by the OS in physical memory.

---

### Address Space Division

A virtual address is divided into two fields by the hardware:

```
Virtual Address (e.g., 32-bit, 4 KB pages):

 31                    12  11              0
 ┌────────────────────────┬────────────────┐
 │    Virtual Page Number │  Page Offset   │
 │         (VPN)          │                │
 │        20 bits         │    12 bits     │
 └────────────────────────┴────────────────┘
```

The **page offset** (log₂(page size) bits) is copied unchanged into the physical address — it identifies the byte within a page. The **VPN** is the index used to look up the physical frame number in the page table.

The physical address is assembled as:

```
Physical Address = PFN ∥ Page Offset
```

where PFN (Physical Frame Number) is retrieved from the page table entry.

---

### The Page Table Entry (PTE)

Each entry in a page table describes one virtual page. The exact layout is architecture-defined, but the canonical fields are:

<svg viewBox="0 0 660 130" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <text x="330" y="20" text-anchor="middle" font-size="13" font-weight="bold" fill="#e2e8f0">Page Table Entry — x86-64 (64-bit)</text> <!-- Bit fields --> <!-- PFN: bits 51:12 --> <rect x="20" y="35" width="260" height="40" rx="3" fill="#0f2027" stroke="#3b82f6"/> <text x="150" y="52" text-anchor="middle" fill="#93c5fd">Physical Frame Number</text> <text x="150" y="67" text-anchor="middle" fill="#64748b" font-size="10">bits 51:12 (40 bits)</text> <!-- NX: bit 63 --> <rect x="590" y="35" width="50" height="40" rx="3" fill="#292524" stroke="#78716c"/> <text x="615" y="52" text-anchor="middle" fill="#fde68a">NX</text> <text x="615" y="67" text-anchor="middle" fill="#64748b" font-size="10">bit 63</text> <!-- Flags: bits 11:0 --> <!-- G --> <rect x="280" y="35" width="32" height="40" rx="2" fill="#1e293b" stroke="#475569"/> <text x="296" y="52" text-anchor="middle" fill="#e2e8f0">G</text> <text x="296" y="67" text-anchor="middle" fill="#64748b" font-size="10">8</text> <!-- PAT --> <rect x="312" y="35" width="32" height="40" rx="2" fill="#1e293b" stroke="#475569"/> <text x="328" y="52" text-anchor="middle" fill="#e2e8f0">PAT</text> <text x="328" y="67" text-anchor="middle" fill="#64748b" font-size="10">7</text> <!-- D --> <rect x="344" y="35" width="32" height="40" rx="2" fill="#1e293b" stroke="#475569"/> <text x="360" y="52" text-anchor="middle" fill="#e2e8f0">D</text> <text x="360" y="67" text-anchor="middle" fill="#64748b" font-size="10">6</text> <!-- A --> <rect x="376" y="35" width="32" height="40" rx="2" fill="#1e293b" stroke="#475569"/> <text x="392" y="52" text-anchor="middle" fill="#e2e8f0">A</text> <text x="392" y="67" text-anchor="middle" fill="#64748b" font-size="10">5</text> <!-- PCD --> <rect x="408" y="35" width="32" height="40" rx="2" fill="#1e293b" stroke="#475569"/> <text x="424" y="52" text-anchor="middle" fill="#e2e8f0">PCD</text> <text x="424" y="67" text-anchor="middle" fill="#64748b" font-size="10">4</text> <!-- PWT --> <rect x="440" y="35" width="32" height="40" rx="2" fill="#1e293b" stroke="#475569"/> <text x="456" y="52" text-anchor="middle" fill="#e2e8f0">PWT</text> <text x="456" y="67" text-anchor="middle" fill="#64748b" font-size="10">3</text> <!-- U/S --> <rect x="472" y="35" width="32" height="40" rx="2" fill="#1e293b" stroke="#475569"/> <text x="488" y="52" text-anchor="middle" fill="#e2e8f0">U/S</text> <text x="488" y="67" text-anchor="middle" fill="#64748b" font-size="10">2</text> <!-- R/W --> <rect x="504" y="35" width="32" height="40" rx="2" fill="#1e293b" stroke="#475569"/> <text x="520" y="52" text-anchor="middle" fill="#e2e8f0">R/W</text> <text x="520" y="67" text-anchor="middle" fill="#64748b" font-size="10">1</text> <!-- P --> <rect x="536" y="35" width="32" height="40" rx="2" fill="#0f2027" stroke="#34d399"/> <text x="552" y="52" text-anchor="middle" fill="#86efac">P</text> <text x="552" y="67" text-anchor="middle" fill="#64748b" font-size="10">0</text> <!-- Field key -->

<text x="20" y="100" fill="#64748b" font-size="10">P=Present R/W=Writable U/S=User/Supervisor PWT=Write-through PCD=Cache-disable</text> <text x="20" y="115" fill="#64748b" font-size="10">A=Accessed D=Dirty PAT=Page Attr Table G=Global NX=No-Execute (XD bit)</text> </svg>

|Bit|Name|Meaning|
|---|---|---|
|P|Present|Page is in physical memory; if 0, MMU raises page fault|
|R/W|Read/Write|0 = read-only; 1 = writable|
|U/S|User/Supervisor|0 = kernel only; 1 = user accessible|
|A|Accessed|Set by MMU on any read or write; used by OS for LRU approximation|
|D|Dirty|Set by MMU on write; indicates page must be written to disk before reclaim|
|G|Global|TLB entry survives CR3 reload (used for kernel pages)|
|NX|No-Execute|Page cannot be executed (requires EFER.NXE); defeats code injection|
|PFN|—|Physical frame number of the mapped page|

The OS clears A and D bits periodically to track working sets. The hardware sets them; only the OS clears them.

---

### Single-Level Page Table

The simplest structure: one flat array of PTEs indexed directly by VPN.

```
Virtual address → VPN → page_table[VPN] → PFN → Physical address
```

For a 32-bit address space with 4 KB pages:

- VPN = 20 bits → 2²⁰ = 1,048,576 entries
- At 4 bytes per PTE → **4 MB per process**, resident in physical memory at all times

For 64-bit address spaces this becomes completely impractical (2⁵² PTEs). Single-level tables are used only in minimal embedded MMUs.

---

### Multi-Level Page Tables

The solution is to **page the page table itself** — use a tree of tables where only the portions covering mapped virtual addresses need to exist in physical memory. Unmapped regions consume no memory because the intermediate table entries are simply marked not present.

#### Two-Level (32-bit x86, MIPS)

```
 31          22  21          12  11              0
 ┌────────────┬───────────────┬──────────────────┐
 │  PD Index  │   PT Index    │   Page Offset    │
 │  (10 bits) │   (10 bits)   │    (12 bits)     │
 └────────────┴───────────────┴──────────────────┘
      │                │
      │                └─── indexes into Page Table (1024 entries × 4B = 4KB)
      └────────────────────── indexes into Page Directory (1024 entries × 4B = 4KB)
```

CR3 holds the physical address of the Page Directory. A page directory entry (PDE) holds the physical address of a page table; the PTE holds the PFN.

Only allocated page tables need to exist — a process using 1 MB of virtual space requires at most 1 page directory + a small number of page tables rather than 4 MB.

---

#### Four-Level (x86-64, Linux)

x86-64 uses a 48-bit virtual address space (bits 47:0 used; bits 63:48 must be sign extensions of bit 47 — **canonical addresses**). The 36 VPN bits are split across four levels:

<svg viewBox="0 0 660 360" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <defs> <marker id="pt-arr" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#94a3b8"/> </marker> <marker id="pt-arr-y" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#f59e0b"/> </marker> </defs> <!-- Virtual address breakdown -->

<text x="330" y="20" text-anchor="middle" font-size="13" font-weight="bold" fill="#e2e8f0">x86-64 Four-Level Page Table Walk</text>

<!-- VA fields --> <rect x="20" y="35" width="70" height="28" rx="2" fill="#334155" stroke="#64748b"/> <text x="55" y="54" text-anchor="middle" fill="#64748b">sign ext</text> <rect x="90" y="35" width="65" height="28" rx="2" fill="#1e3a5f" stroke="#3b82f6"/> <text x="122" y="54" text-anchor="middle" fill="#93c5fd">L4 [8]</text> <rect x="155" y="35" width="65" height="28" rx="2" fill="#1e3a5f" stroke="#3b82f6"/> <text x="187" y="54" text-anchor="middle" fill="#93c5fd">L3 [9]</text> <rect x="220" y="35" width="65" height="28" rx="2" fill="#1e3a5f" stroke="#3b82f6"/> <text x="252" y="54" text-anchor="middle" fill="#93c5fd">L2 [9]</text> <rect x="285" y="35" width="65" height="28" rx="2" fill="#1e3a5f" stroke="#3b82f6"/> <text x="317" y="54" text-anchor="middle" fill="#93c5fd">L1 [9]</text> <rect x="350" y="35" width="100" height="28" rx="2" fill="#0f2027" stroke="#34d399"/> <text x="400" y="54" text-anchor="middle" fill="#86efac">offset [12]</text> <!-- bit labels -->

<text x="55" y="76" text-anchor="middle" fill="#475569" font-size="9">63:48</text> <text x="122" y="76" text-anchor="middle" fill="#475569" font-size="9">47:39</text> <text x="187" y="76" text-anchor="middle" fill="#475569" font-size="9">38:30</text> <text x="252" y="76" text-anchor="middle" fill="#475569" font-size="9">29:21</text> <text x="317" y="76" text-anchor="middle" fill="#475569" font-size="9">20:12</text> <text x="400" y="76" text-anchor="middle" fill="#475569" font-size="9">11:0</text>

<!-- CR3 --> <rect x="530" y="90" width="110" height="30" rx="3" fill="#292524" stroke="#78716c"/> <text x="585" y="110" text-anchor="middle" fill="#fde68a">CR3 (PML4 base)</text> <!-- PML4 table --> <rect x="480" y="140" width="110" height="70" rx="3" fill="#1e293b" stroke="#3b82f6"/> <text x="535" y="158" text-anchor="middle" fill="#93c5fd">PML4</text> <rect x="490" y="165" width="90" height="14" rx="2" fill="#0f2027" stroke="#3b82f6"/> <text x="535" y="176" text-anchor="middle" fill="#93c5fd" font-size="10">entry[L4 bits]</text> <text x="535" y="200" text-anchor="middle" fill="#64748b" font-size="9">512 entries × 8B</text> <!-- PDPT --> <rect x="330" y="140" width="110" height="70" rx="3" fill="#1e293b" stroke="#3b82f6"/> <text x="385" y="158" text-anchor="middle" fill="#93c5fd">PDPT</text> <rect x="340" y="165" width="90" height="14" rx="2" fill="#0f2027" stroke="#3b82f6"/> <text x="385" y="176" text-anchor="middle" fill="#93c5fd" font-size="10">entry[L3 bits]</text> <text x="385" y="200" text-anchor="middle" fill="#64748b" font-size="9">512 entries × 8B</text> <!-- PD --> <rect x="180" y="140" width="110" height="70" rx="3" fill="#1e293b" stroke="#3b82f6"/> <text x="235" y="158" text-anchor="middle" fill="#93c5fd">PD</text> <rect x="190" y="165" width="90" height="14" rx="2" fill="#0f2027" stroke="#3b82f6"/> <text x="235" y="176" text-anchor="middle" fill="#93c5fd" font-size="10">entry[L2 bits]</text> <text x="235" y="200" text-anchor="middle" fill="#64748b" font-size="9">512 entries × 8B</text> <!-- PT --> <rect x="30" y="140" width="110" height="70" rx="3" fill="#1e293b" stroke="#3b82f6"/> <text x="85" y="158" text-anchor="middle" fill="#93c5fd">PT</text> <rect x="40" y="165" width="90" height="14" rx="2" fill="#0f2027" stroke="#3b82f6"/> <text x="85" y="176" text-anchor="middle" fill="#93c5fd" font-size="10">entry[L1 bits]</text> <text x="85" y="200" text-anchor="middle" fill="#64748b" font-size="9">512 entries × 8B</text> <!-- Physical frame --> <rect x="30" y="255" width="110" height="40" rx="3" fill="#0f2027" stroke="#34d399"/> <text x="85" y="272" text-anchor="middle" fill="#86efac">Physical Frame</text> <text x="85" y="288" text-anchor="middle" fill="#64748b" font-size="9">PFN ∥ offset</text> <!-- Arrows: CR3 → PML4 --> <line x1="585" y1="120" x2="535" y2="140" stroke="#f59e0b" stroke-width="1.5" marker-end="url(#pt-arr-y)"/> <!-- PML4 → PDPT --> <line x1="480" y1="175" x2="440" y2="175" stroke="#94a3b8" stroke-width="1.5" marker-end="url(#pt-arr)"/> <!-- PDPT → PD --> <line x1="330" y1="175" x2="290" y2="175" stroke="#94a3b8" stroke-width="1.5" marker-end="url(#pt-arr)"/> <!-- PD → PT --> <line x1="180" y1="175" x2="140" y2="175" stroke="#94a3b8" stroke-width="1.5" marker-end="url(#pt-arr)"/> <!-- PT → physical frame --> <line x1="85" y1="210" x2="85" y2="255" stroke="#34d399" stroke-width="1.5" marker-end="url(#pt-arr)"/> <!-- Offset addition -->

<text x="400" y="275" text-anchor="middle" fill="#86efac" font-size="10">+ page offset (bits 11:0)</text> <line x1="400" y1="63" x2="400" y2="265" stroke="#34d399" stroke-width="1" stroke-dasharray="3,2"/> <line x1="140" y1="272" x2="400" y2="272" stroke="#34d399" stroke-width="1" stroke-dasharray="3,2"/>

<!-- Memory access labels -->

<text x="535" y="228" text-anchor="middle" fill="#64748b" font-size="9">mem access 1</text> <text x="385" y="228" text-anchor="middle" fill="#64748b" font-size="9">mem access 2</text> <text x="235" y="228" text-anchor="middle" fill="#64748b" font-size="9">mem access 3</text> <text x="85" y="228" text-anchor="middle" fill="#64748b" font-size="9">mem access 4</text>

<!-- Walk label -->

<text x="330" y="330" text-anchor="middle" fill="#64748b" font-size="10">Each level requires one physical memory read. Without TLB: 4 memory accesses per virtual address.</text> </svg>

The five-level variant (**5-level paging**, Intel Ice Lake and later, Linux `CONFIG_X86_5LEVEL`) extends to 57-bit virtual addresses by adding a PML5 level, supporting 128 PB of virtual address space.

---

### Page Table Walk: Step by Step

For x86-64, a full walk on a TLB miss:

```
1. MMU reads CR3 → physical base address of PML4

2. physical_addr = CR3.base + (VA[47:39] × 8)
   reads PML4E → extracts PDPT base, checks P bit

3. physical_addr = PDPT.base + (VA[38:30] × 8)
   reads PDPTE → extracts PD base, checks P bit

4. physical_addr = PD.base + (VA[29:21] × 8)
   reads PDE → extracts PT base, checks P bit
   (if PDE.PS=1: this is a 2MB huge page; walk ends here)

5. physical_addr = PT.base + (VA[20:12] × 8)
   reads PTE → extracts PFN, checks P bit, sets A/D bits

6. physical_addr = (PTE.PFN << 12) | VA[11:0]
```

If **any** P bit is 0, the MMU raises a **page fault** (#PF, interrupt vector 14), saving the faulting address in CR2 and an error code on the stack. The OS page fault handler either:

- Loads the missing page from disk and sets P=1 (demand paging), or
- Kills the process (segmentation fault — access to unmapped region)

---

### Huge Pages

Every level of the page table hierarchy can terminate early by setting a **Page Size (PS)** bit in the intermediate entry, mapping a larger region with a single PTE:

|Level terminated|Page size|Name|
|---|---|---|
|L1 (PT)|4 KB|standard page|
|L2 (PD) with PS=1|2 MB|large page|
|L3 (PDPT) with PS=1|1 GB|huge page|

Huge pages reduce TLB pressure (one TLB entry covers 2 MB instead of 4 KB) at the cost of internal fragmentation. Linux supports **Transparent Huge Pages (THP)** — the kernel automatically promotes page-aligned 2 MB regions to huge pages when possible.

---

### The Translation Lookaside Buffer (TLB)

A full 4-level walk costs **4 physical memory accesses per virtual address** — a catastrophic overhead applied to every load and store. The TLB is a small, fully associative or set-associative cache of recent VPN→PFN translations, making the common case a single-cycle lookup.

<svg viewBox="0 0 620 230" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <text x="310" y="20" text-anchor="middle" font-size="13" font-weight="bold" fill="#e2e8f0">TLB Hit vs. Miss Path</text> <!-- Virtual address box --> <rect x="230" y="35" width="160" height="30" rx="4" fill="#1e293b" stroke="#475569"/> <text x="310" y="55" text-anchor="middle" fill="#e2e8f0">Virtual Address</text> <!-- TLB lookup --> <line x1="310" y1="65" x2="310" y2="90" stroke="#94a3b8" stroke-width="1.5" marker-end="url(#pt-arr)"/> <rect x="220" y="90" width="180" height="35" rx="4" fill="#1e3a5f" stroke="#3b82f6"/> <text x="310" y="113" text-anchor="middle" fill="#93c5fd">TLB Lookup (VPN)</text> <!-- Hit path --> <line x1="220" y1="107" x2="130" y2="107" stroke="#34d399" stroke-width="2" marker-end="url(#pt-arr)"/> <text x="175" y="100" fill="#34d399" font-size="10">HIT</text> <rect x="30" y="90" width="100" height="35" rx="4" fill="#0f2027" stroke="#34d399"/> <text x="80" y="108" text-anchor="middle" fill="#86efac">PFN ready</text> <text x="80" y="120" text-anchor="middle" fill="#64748b" font-size="9">~1 cycle</text> <!-- Miss path --> <line x1="400" y1="107" x2="490" y2="107" stroke="#f87171" stroke-width="2" marker-end="url(#pt-arr)"/> <text x="445" y="100" fill="#f87171" font-size="10">MISS</text> <rect x="490" y="90" width="110" height="35" rx="4" fill="#292524" stroke="#f87171"/> <text x="545" y="108" text-anchor="middle" fill="#f87171">Page Table Walk</text> <text x="545" y="120" text-anchor="middle" fill="#64748b" font-size="9">4 mem accesses</text> <!-- Walk result back to TLB --> <path d="M 545 125 L 545 170 L 310 170 L 310 125" stroke="#f59e0b" stroke-width="1.5" fill="none" marker-end="url(#pt-arr-y)"/> <text x="430" y="185" text-anchor="middle" fill="#f59e0b" font-size="10">fill TLB entry</text> <!-- Physical address --> <rect x="230" y="185" width="160" height="30" rx="4" fill="#0f2027" stroke="#34d399"/> <text x="310" y="205" text-anchor="middle" fill="#86efac">Physical Address</text> <line x1="80" y1="125" x2="80" y2="200" stroke="#34d399" stroke-width="1.5"/> <line x1="80" y1="200" x2="230" y2="200" stroke="#34d399" stroke-width="1.5" marker-end="url(#pt-arr)"/> </svg>

#### TLB Properties

A typical out-of-order processor has a **split L1 TLB** (separate ITLB for instructions and DTLB for data), each holding 32–64 entries, with a unified **L2 TLB** (second-level, ~1024–4096 entries) serving misses from both. Intel Skylake uses a 64-entry L1 DTLB and a 1536-entry L2 TLB.

**TLB reach** — the total memory addressable without a TLB miss — is:

$$\text{TLB reach} = \text{TLB entries} \times \text{page size}$$

For 64 entries × 4 KB = 256 KB. For 64 entries × 2 MB (huge pages) = 128 MB — a 512× increase in reach, which is why huge pages dramatically improve TLB performance for large working sets.

#### TLB Shootdown

When the OS modifies a PTE (e.g., unmapping a page), it must **invalidate** any cached translation in TLBs across **all CPU cores** that may have used that mapping. This is a **TLB shootdown**:

1. OS modifies PTE in page table
2. OS sends **inter-processor interrupt (IPI)** to all other cores
3. Each core executes `INVLPG addr` (invalidate specific TLB entry) or `MOV CR3, CR3` (flush entire TLB)
4. Each core signals completion
5. OS proceeds

TLB shootdowns are expensive — IPIs are serializing and interrupt normal execution. Linux batches them using **mmu_gather** structures to reduce IPI frequency during large unmapping operations (e.g., `munmap` of a large region).

#### Global Pages and PCID

The **G (Global)** bit in a PTE marks kernel pages that should survive CR3 reloads. Kernel mappings are present in every process's address space; flushing them on every context switch wastes TLB capacity.

**PCID (Process Context Identifier)** is a 12-bit tag stored in CR3 that allows multiple processes' TLB entries to coexist simultaneously — the TLB is tagged per ASID (Address Space ID), eliminating full flushes on context switch. Linux enables PCID on x86-64 (KAISER/KPTI patches, post-Meltdown). ARM64 uses **ASID** (16-bit) with equivalent semantics.

---

### Context Switch and CR3

On a context switch, the OS loads the incoming process's page table root into CR3:

```asm
MOV CR3, new_process_PML4_phys    ; flushes non-global TLB entries
```

This invalidates all non-global TLB entries. With PCID enabled, the OS sets a different PCID in CR3 instead of flushing, and the old entries remain tagged to their PCID — they will be reused when that process is scheduled again.

---

### Kernel vs. User Address Space Split

On x86-64, the canonical address space is split:

```
0x0000000000000000 – 0x00007FFFFFFFFFFF   user space   (128 TB)
0xFFFF800000000000 – 0xFFFFFFFFFFFFFFFF   kernel space (128 TB)
```

The kernel is mapped into the upper portion of every process's virtual address space. This allows the kernel to operate without a CR3 reload on system calls (at the cost of the kernel occupying virtual address space and being vulnerable to Meltdown-class attacks).

**Kernel Page Table Isolation (KPTI)**, introduced as a Meltdown mitigation, maintains **two separate page tables** per process:

- User page table: maps user space + minimal kernel trampoline (for syscall entry)
- Kernel page table: maps full kernel + user space

CR3 is swapped on every user↔kernel transition, incurring a full TLB flush (or PCID switch). The performance cost is 5–30% for syscall-heavy workloads.

---

### Inverted Page Tables

Rather than indexing by VPN (one entry per virtual page), an **inverted page table** has one entry per **physical frame**, indexed by PFN. Each entry records which (process, VPN) pair occupies that frame.

|Property|Forward Page Table|Inverted Page Table|
|---|---|---|
|Size|Proportional to virtual address space|Proportional to physical RAM|
|Lookup|O(depth) tree walk|Hash table lookup|
|Multi-process|Separate table per process|Single global table|
|TLB miss cost|Walk tree|Hash + chain traversal|
|Used by|x86, ARM, RISC-V|IBM POWER, some SPARC|

IBM POWER processors use a hashed inverted page table (HPTE). The VPN is hashed to find the anchor entry; collision chains handle conflicts. TLB misses are handled by a software TLB miss handler (a privileged routine), unlike x86's hardware page table walker.

---

### Software-Managed TLBs (MIPS, RISC-V)

Some architectures define the TLB in the ISA but leave page table format entirely to the OS. On a TLB miss, instead of a hardware page table walker, the CPU raises a **TLB miss exception** and jumps to an OS-defined handler.

**MIPS TLB miss handler (conceptual):**

```asm
tlb_miss_handler:
    MFC0  k0, BadVAddr          ; load faulting virtual address
    SRL   k0, k0, PAGE_SHIFT    ; extract VPN
    LW    k1, page_table(k0)    ; software walk — load PTE
    MTC0  k1, EntryLo           ; load PFN + flags into CP0
    TLBWR                        ; write random TLB entry
    ERET                         ; return, retry faulting instruction
```

This gives the OS complete flexibility over page table format (radix, inverted, hashed — anything). The cost is that the TLB miss handler must be extremely fast and its own code must never miss the TLB (or it enters infinite recursion — mitigated by wiring handler pages into TLB entries that are never evicted).

RISC-V also uses software-managed TLBs. The `satp` CSR holds the page table base and mode (Sv32, Sv39, Sv48, Sv57), but the hardware walks the table only in certain implementations — in others, the trap-based software model is used.

---

### Page Fault Handling

Page faults are the mechanism by which the OS implements **demand paging**, **copy-on-write**, and **memory-mapped files**.

<svg viewBox="0 0 580 320" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <text x="290" y="20" text-anchor="middle" font-size="13" font-weight="bold" fill="#e2e8f0">Page Fault Handling Flow</text> <rect x="200" y="35" width="180" height="30" rx="15" fill="#1e3a5f" stroke="#3b82f6"/> <text x="290" y="55" text-anchor="middle" fill="#93c5fd">Memory access</text> <line x1="290" y1="65" x2="290" y2="85" stroke="#94a3b8" stroke-width="1.5" marker-end="url(#pt-arr)"/> <rect x="200" y="85" width="180" height="30" rx="4" fill="#1e293b" stroke="#475569"/> <text x="290" y="105" text-anchor="middle" fill="#e2e8f0">TLB miss → walk PTE</text> <line x1="290" y1="115" x2="290" y2="135" stroke="#94a3b8" stroke-width="1.5" marker-end="url(#pt-arr)"/> <rect x="200" y="135" width="180" height="30" rx="4" fill="#1e293b" stroke="#64748b"/> <text x="290" y="155" text-anchor="middle" fill="#e2e8f0">PTE.Present = 0 ?</text> <!-- No → TLB fill --> <line x1="200" y1="150" x2="100" y2="150" stroke="#34d399" stroke-width="1.5" marker-end="url(#pt-arr)"/> <text x="150" y="143" fill="#34d399" font-size="10">No (P=1)</text> <rect x="20" y="135" width="80" height="30" rx="4" fill="#0f2027" stroke="#34d399"/> <text x="60" y="155" text-anchor="middle" fill="#86efac">TLB fill</text> <text x="60" y="165" text-anchor="middle" fill="#64748b" font-size="9">done</text> <!-- Yes → fault --> <line x1="290" y1="165" x2="290" y2="185" stroke="#f87171" stroke-width="1.5" marker-end="url(#pt-arr)"/> <text x="298" y="179" fill="#f87171" font-size="10">Yes</text> <rect x="200" y="185" width="180" height="30" rx="4" fill="#292524" stroke="#f87171"/> <text x="290" y="205" text-anchor="middle" fill="#f87171">Page Fault #PF</text> <text x="290" y="215" text-anchor="middle" fill="#64748b" font-size="9">CR2 = fault addr</text> <line x1="290" y1="215" x2="290" y2="235" stroke="#94a3b8" stroke-width="1.5" marker-end="url(#pt-arr)"/> <rect x="180" y="235" width="220" height="30" rx="4" fill="#1e293b" stroke="#64748b"/> <text x="290" y="255" text-anchor="middle" fill="#e2e8f0">In VMA? Permissions OK?</text> <!-- Invalid → SIGSEGV --> <line x1="400" y1="250" x2="480" y2="250" stroke="#f87171" stroke-width="1.5" marker-end="url(#pt-arr)"/> <text x="440" y="243" fill="#f87171" font-size="10">No</text> <rect x="480" y="235" width="80" height="30" rx="4" fill="#7f1d1d" stroke="#f87171"/> <text x="520" y="258" text-anchor="middle" fill="#f87171">SIGSEGV</text> <!-- Valid → allocate --> <line x1="290" y1="265" x2="290" y2="285" stroke="#34d399" stroke-width="1.5" marker-end="url(#pt-arr)"/> <text x="298" y="279" fill="#34d399" font-size="10">Yes</text> <rect x="180" y="285" width="220" height="28" rx="4" fill="#0f2027" stroke="#34d399"/> <text x="290" y="299" text-anchor="middle" fill="#86efac">Alloc frame, load page,</text> <text x="290" y="311" text-anchor="middle" fill="#86efac">set PTE.P=1, return</text> </svg>

#### Copy-on-Write (CoW)

`fork()` maps both parent and child to the **same physical pages**, with PTEs marked read-only in both. On the first write by either process, a page fault fires. The OS:

1. Allocates a new physical frame
2. Copies the page content
3. Updates the faulting process's PTE to point to the new frame with write permission
4. Returns — the write is retried and succeeds

This defers the cost of copying the entire address space until (and unless) pages are actually modified.

#### Memory-Mapped Files (`mmap`)

`mmap` maps a file's contents into virtual address space. PTEs are initially not present. On first access, the page fault handler reads the corresponding file block from disk into a physical frame and sets the PTE. The **page cache** (Linux) caches these frames — subsequent mappings of the same file share the same physical frames.

---

### Page Replacement and the Dirty Bit

When physical memory is exhausted, the OS must evict a page to disk (swap). The **D (Dirty)** bit determines cost:

- **Clean page (D=0):** Discarded — the page on disk or in the file cache is still valid. No write required.
- **Dirty page (D=1):** Must be written to swap or backing file before frame is reclaimed.

The **A (Accessed)** bit implements approximate LRU: the OS periodically scans PTEs, demoting pages that have not been accessed since the last scan (clearing A bits) to a cold list, and evicting from the cold list first.

Linux uses a **two-list clock algorithm** (active list + inactive list) rather than a pure LRU, since scanning all PTEs for a true LRU is impractical at scale.

---

### Summary: Address Translation Performance

|Scenario|Cost|
|---|---|
|TLB hit|1 cycle (concurrent with cache access in virtually-indexed caches)|
|TLB miss, all page tables in L1/L2 cache|10–30 cycles (4 cache hits)|
|TLB miss, page tables in DRAM|100–400 cycles (4 DRAM accesses)|
|Page fault, page in swap|Millions of cycles (disk/SSD access)|

The TLB hit rate is the single most important factor in virtual memory performance. Working set size relative to TLB reach determines whether a workload is TLB-bound.

---

**Conclusion**

Paging implements virtual memory through a hierarchical mapping from virtual page numbers to physical frame numbers, stored in page tables resident in physical memory. The MMU walks this structure on each TLB miss, with the TLB serving as the critical performance layer that makes per-access translation overhead negligible in the common case. Every significant OS mechanism — demand paging, copy-on-write, memory-mapped files, shared memory, page protection — is implemented by manipulating PTE fields and exploiting the page fault mechanism. The interaction between TLB capacity, page size, page table depth, and working set size determines the practical performance envelope of any virtual memory system.

**Next Steps**

Proceed to **TLB Design** for a detailed treatment of TLB microarchitecture — associativity, tagging, ASID/PCID management, multi-level TLB hierarchies, and hardware page table walkers — or to **Cache Coherence** to examine how physical address translation interacts with multicore cache protocols.

---

