## TLB Design and Operation


The Translation Lookaside Buffer is a dedicated hardware cache for virtual-to-physical address translations. Every memory reference in a system using virtual memory requires an address translation — without the TLB, each reference would require multiple DRAM accesses to walk the page table, multiplying effective memory latency by the number of page table levels. The TLB exists to make address translation essentially free in the common case.

---

### The Translation Problem

In a system with a 4-level page table (x86-64), translating a single virtual address requires four sequential memory accesses before the actual data access:

```
Virtual Address
      │
      ▼
  PGD lookup  → DRAM access 1  (page global directory)
      │
      ▼
  PUD lookup  → DRAM access 2  (page upper directory)
      │
      ▼
  PMD lookup  → DRAM access 3  (page middle directory)
      │
      ▼
  PTE lookup  → DRAM access 4  (page table entry)
      │
      ▼
Physical Address → DRAM access 5  (actual data)
```

At ~60–100 ns per DRAM access, a five-access sequence makes every load or store cost 300–500 ns. The TLB short-circuits this entirely — a TLB hit converts a virtual address to a physical address in 1–3 ns, with no page table traversal.

---

### TLB Entry Structure

Each TLB entry caches the translation for one virtual page. The entry stores the virtual page number (VPN) as a tag and the physical page number (PPN) plus protection metadata as the payload:

```
┌──────────┬──────────┬───┬───┬───┬───┬───┬──────┐
│  VPN tag │   PPN    │ V │ D │ R │ U │ G │ ASID │
└──────────┴──────────┴───┴───┴───┴───┴───┴──────┘
  virtual    physical
  page num   page num
```

|Field|Width|Meaning|
|---|---|---|
|VPN|VA bits − page offset bits|Virtual page number; forms the lookup tag|
|PPN|PA bits − page offset bits|Physical page number; output of translation|
|V (Valid)|1 bit|Entry is currently valid|
|D (Dirty)|1 bit|Page has been written; must be written back before eviction|
|R (Referenced)|1 bit|Page has been accessed; used by OS page replacement|
|U (User)|1 bit|Page is accessible in user mode|
|W (Write)|1 bit|Page is writable|
|X (Execute)|1 bit|Page is executable (NX/XD bit for W^X enforcement)|
|G (Global)|1 bit|Translation is global — not flushed on ASID change|
|ASID|8–16 bits|Address Space ID; identifies which process owns this entry|

The page offset bits (12 bits for 4 KB pages) are **never translated** — they pass directly from the virtual address to the physical address, since the page offset is the same in both address spaces.

---

### Address Translation with the TLB

For a 48-bit virtual address with 4 KB pages (x86-64 canonical form):

```
Virtual Address (48 bits):
┌──────────────────────────────────┬────────────────┐
│         VPN (36 bits)            │  Offset (12b)  │
└──────────────────────────────────┴────────────────┘
         ↓ TLB lookup
┌──────────────────────────────────┐
│         PPN (36 bits)            │ ← from TLB hit
└──────────────────────────────────┘
         ↓ concatenate
┌──────────────────────────────────┬────────────────┐
│         PPN (36 bits)            │  Offset (12b)  │
└──────────────────────────────────┴────────────────┘
         Physical Address (48 bits)
```

The TLB lookup and the cache index computation can proceed **in parallel** when the cache is indexed by the page offset (virtually indexed, physically tagged — VIPT), eliminating the TLB from the critical path for L1 hits.

---

### TLB Organization

#### Fully Associative TLB

Most L1 TLBs are **fully associative**: any VPN can be stored in any entry. All entries are compared simultaneously with the incoming VPN using parallel comparators:

<svg viewBox="0 0 660 340" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="660" height="340" fill="#0d1117"/> <text x="210" y="26" fill="#f0f6fc" font-size="13" font-weight="bold">Fully Associative TLB Lookup</text> <!-- Incoming VPN --> <rect x="240" y="42" width="160" height="28" fill="#1c2d40" stroke="#58a6ff" stroke-width="1.5" rx="3"/> <text x="284" y="60" fill="#58a6ff" font-weight="bold">VPN (tag)</text> <line x1="320" y1="70" x2="320" y2="88" stroke="#58a6ff" stroke-width="1.5"/> <!-- Distribution line --> <line x1="100" y1="88" x2="560" y2="88" stroke="#58a6ff" stroke-width="1.5"/> <!-- Comparators and entries --> <!-- Entry 0 --> <line x1="140" y1="88" x2="140" y2="108" stroke="#8b949e" stroke-width="1"/> <rect x="80" y="108" width="80" height="24" fill="#21262d" stroke="#8b949e" stroke-width="1" rx="2"/> <text x="95" y="124" fill="#8b949e">VPN₀</text> <rect x="168" y="108" width="70" height="24" fill="#1c2d40" stroke="#3fb950" stroke-width="1" rx="2"/> <text x="180" y="124" fill="#3fb950">PPN₀</text> <rect x="246" y="108" width="30" height="24" fill="#21262d" stroke="#8b949e" stroke-width="1" rx="2"/> <text x="251" y="124" fill="#8b949e">prot</text> <!-- Comparator symbol --> <polygon points="140,140 108,156 172,156" fill="#1c2d40" stroke="#e3b341" stroke-width="1.2"/> <text x="126" y="153" fill="#e3b341" font-size="10">=?</text> <line x1="140" y1="132" x2="140" y2="140" stroke="#8b949e" stroke-width="1"/> <line x1="140" y1="156" x2="140" y2="172" stroke="#e3b341" stroke-width="1"/> <!-- Entry 1 --> <line x1="240" y1="88" x2="240" y2="108" stroke="#8b949e" stroke-width="1"/> <rect x="180" y="108" width="0" height="0"/> <rect x="285" y="108" width="80" height="24" fill="#21262d" stroke="#8b949e" stroke-width="1" rx="2"/> <text x="300" y="124" fill="#8b949e">VPN₁</text> <rect x="373" y="108" width="70" height="24" fill="#1c2d40" stroke="#3fb950" stroke-width="1" rx="2"/> <text x="385" y="124" fill="#3fb950">PPN₁</text> <rect x="451" y="108" width="30" height="24" fill="#21262d" stroke="#8b949e" stroke-width="1" rx="2"/> <text x="456" y="124" fill="#8b949e">prot</text> <polygon points="340,140 308,156 372,156" fill="#1c2d40" stroke="#e3b341" stroke-width="1.2"/> <text x="326" y="153" fill="#e3b341" font-size="10">=?</text> <line x1="340" y1="132" x2="340" y2="140" stroke="#8b949e" stroke-width="1"/> <line x1="340" y1="156" x2="340" y2="172" stroke="#e3b341" stroke-width="1"/> <!-- Entry N (ellipsis) -->

<text x="486" y="136" fill="#8b949e" font-size="16">···</text> <line x1="520" y1="88" x2="520" y2="108" stroke="#8b949e" stroke-width="1"/> <polygon points="520,140 488,156 552,156" fill="#1c2d40" stroke="#e3b341" stroke-width="1.2"/> <text x="506" y="153" fill="#e3b341" font-size="10">=?</text> <line x1="520" y1="156" x2="520" y2="172" stroke="#e3b341" stroke-width="1"/>

<!-- OR gate / hit line --> <line x1="140" y1="172" x2="140" y2="192" stroke="#e3b341" stroke-width="1"/> <line x1="340" y1="172" x2="340" y2="192" stroke="#e3b341" stroke-width="1"/> <line x1="520" y1="172" x2="520" y2="192" stroke="#e3b341" stroke-width="1"/> <line x1="140" y1="192" x2="520" y2="192" stroke="#e3b341" stroke-width="1.5"/> <line x1="330" y1="192" x2="330" y2="212" stroke="#e3b341" stroke-width="1.5"/> <!-- Mux --> <polygon points="280,212 380,212 360,240 300,240" fill="#1c2d40" stroke="#56d364" stroke-width="1.5"/> <text x="302" y="231" fill="#56d364">Select PPN</text> <line x1="330" y1="240" x2="330" y2="262" stroke="#56d364" stroke-width="1.5"/> <!-- Hit/Miss --> <rect x="240" y="262" width="180" height="28" fill="#21362d" stroke="#3fb950" stroke-width="1.5" rx="3"/> <text x="274" y="280" fill="#3fb950">TLB Hit → PPN output</text> <!-- Miss path annotation -->

<text x="440" y="278" fill="#ff7b72" font-size="10">No match →</text> <text x="440" y="292" fill="#ff7b72" font-size="10">TLB Miss</text> </svg>

Fully associative designs use **CAM** (Content-Addressable Memory) — hardware that performs all tag comparisons in a single clock cycle. CAM cells are large (10–12 transistors each vs. 6T for SRAM), so fully associative TLBs are kept small: 32–128 entries for L1.

#### Set-Associative TLB

Larger TLBs (L2, unified) use **set-associative** organization to reduce CAM area while retaining reasonable hit rates. The VPN is split into index and tag portions:

```
VPN:
┌──────────────────┬───────────┬────────────┐
│    Tag bits      │ Set index │ (page offs)│
└──────────────────┴───────────┴────────────┘
         ↓                ↓
    compare with      select set
    ways in set       (4–8 entries)
```

A 1024-entry, 4-way set-associative TLB uses 256 sets × 4 ways. Each set requires only 4-way comparators rather than 1024-way CAM — dramatically reducing circuit complexity and power.

#### Multi-Level TLB Hierarchy

Modern processors mirror the cache hierarchy with a TLB hierarchy:

|Level|Organization|Entries|Latency|Typical hit rate|
|---|---|---|---|---|
|L1 ITLB|Fully associative|32–64|1 cycle|~98–99%|
|L1 DTLB|Fully associative|32–64|1 cycle|~98–99%|
|L2 Unified TLB (STLB)|4–12 way set-assoc|512–4096|8–12 cycles|~99.5–99.9%|
|Page walk (miss)|Hardware PTW|—|50–200+ cycles|—|

The x86-64 Intel Skylake TLB hierarchy:

```
L1 ITLB: 128 entries, 8-way, for 4KB pages
          8 entries for 2MB/4GB pages
L1 DTLB: 64 entries, 4-way, for 4KB pages
          32 entries for 2MB/4GB pages
L2 STLB: 1536 entries, 12-way, unified, 4KB + 2MB
```

---

### TLB Miss Handling

When no TLB entry matches the incoming VPN, a **TLB miss** occurs. The translation must be retrieved by walking the page table. Two fundamentally different designs exist for who performs the walk.

#### Hardware Page Table Walker

In x86, ARM, and most modern RISC architectures, a dedicated **Page Table Walker (PTW)** hardware unit handles TLB misses automatically and transparently to software. The hardware knows the page table format (defined by the ISA) and walks the structure using the current CR3 (x86) or TTBR (ARM) base register:

```
TLB Miss detected
      │
      ▼
Hardware PTW activates
      │
      ├─→ Read PGD entry  [CR3 + PGD_index × 8]
      ├─→ Read PUD entry  [PGD_entry.base + PUD_index × 8]
      ├─→ Read PMD entry  [PUD_entry.base + PMD_index × 8]
      └─→ Read PTE entry  [PMD_entry.base + PTE_index × 8]
              │
              ▼
         Valid PTE?
          Yes → install translation into TLB, retry instruction
          No  → raise Page Fault exception → OS page fault handler
```

Each step in the walk is itself a memory access and may itself miss in the cache (though page table pages are kept hot). The PTW can access the data cache to avoid DRAM latency on page table entries — when page table pages reside in L1/L2, the full 4-level walk may complete in 20–40 cycles rather than 200+.

The critical hardware optimization: **page walk caches**. These are small caches inside the PTW that store partial walk results:

```
PGD cache   — caches PGD base → PUD base mappings
PUD cache   — caches PUD base → PMD base mappings
PMD cache   — caches PMD base → PTE base mappings
```

A 4-level walk with all three intermediate levels cached reduces to a single PTE fetch — from 4 DRAM accesses to 1.

#### Software-Managed TLB (MIPS / RISC-V sv32)

Early MIPS and some embedded RISC-V configurations use **software-managed TLBs**: the hardware simply raises a **TLB Miss exception** on every miss, and the OS handles refill entirely in software.

```
TLB Miss → exception raised
              │
              ▼
         OS TLB miss handler
              │
         Walk page table (in software)
              │
         Found PTE → write entry to TLB via privileged instruction (TLBWR)
              │
         Return from exception → retry faulting instruction
```

Advantages: the hardware is simpler and the OS can define any page table format. Disadvantages: every miss costs a full exception — context save, handler execution, TLBWR, context restore — adding dozens to hundreds of cycles. Software TLB management is viable only when the TLB miss rate is very low (large TLBs, large pages, or working sets that fit in the TLB).

MIPS provides four privileged instructions for TLB management:

|Instruction|Operation|
|---|---|
|`TLBR`|Read TLB entry at index in TLB Index register into EntryHi/EntryLo|
|`TLBWI`|Write EntryHi/EntryLo into TLB entry at index|
|`TLBWR`|Write EntryHi/EntryLo into random TLB entry|
|`TLBP`|Probe TLB for entry matching EntryHi; set Index register|

---

### Address Space Identifiers (ASIDs)

Without ASIDs, every context switch (process switch) requires flushing the entire TLB — all cached translations belong to the previous process and are invalid for the new one. On a system with 1 µs context switch rate and a TLB warmup cost of 50–100 cycles per miss across hundreds of entries, TLB flush overhead becomes significant.

**ASIDs** solve this by tagging each TLB entry with an identifier for its owning address space. Entries from different processes coexist in the TLB simultaneously:

```
TLB entry:  [ VPN | ASID | PPN | protection bits ]

Lookup match condition:
  (entry.VPN == incoming VPN) AND
  (entry.ASID == current_ASID OR entry.Global == 1)
```

On a context switch, the hardware loads the new process's ASID into the current ASID register (x86-64: bits 11:0 of CR3 in PCID mode; ARM: TTBR0.ASID). No TLB flush is needed — old entries simply fail the ASID comparison.

#### ASID Exhaustion

ASIDs are finite (8 bits → 256 ASIDs in ARMv7; 16 bits → 65536 in ARMv8). When the OS exhausts the ASID space, it must:

1. Assign a new ASID to a process, possibly reusing an old one
2. Flush all TLB entries bearing the reused ASID
3. Increment a **generation counter** in software to track ASID validity

x86-64 implements a related mechanism called **PCID** (Process Context Identifier), a 12-bit field in CR3. The `INVPCID` instruction selectively invalidates TLB entries for a specific PCID, enabling the OS to perform fine-grained TLB management rather than full flushes.

---

### TLB Shootdown

In a multiprocessor system, a virtual-to-physical mapping may be cached in the TLBs of **multiple cores simultaneously**. When the OS modifies or removes a page table entry (e.g., on `munmap`, copy-on-write fork, page reclaim), it must ensure that stale translations are removed from all TLBs that may hold them.

This operation is called a **TLB shootdown**:

```
Core 0 (initiator)                 Core 1, 2, ... N (targets)
──────────────────                 ──────────────────────────
1. Modify PTE in page table
2. Flush own TLB entry (INVLPG)
3. Send IPI to all other cores  →  4. Receive IPI
                                   5. Execute INVLPG / flush TLB
                                   6. Send acknowledgment
4. Receive all ACKs
5. Continue (PTE change safe)
```

TLB shootdown uses **Inter-Processor Interrupts (IPIs)**, which are expensive: each IPI involves the APIC, an interrupt handler on the remote core, cache coherence traffic, and acknowledgment. On a 128-core system, a single shootdown may trigger 127 IPIs.

Shootdown cost is a significant source of overhead in:

- **fork/exec** — copy-on-write page promotion
- **mmap/munmap** — large virtual address range changes
- **page migration** — NUMA rebalancing
- **KSM** (Kernel Samepage Merging) — transparent huge page collapsing

Mitigation strategies include:

- **Lazy shootdown** — defer invalidation, detect stale access on fault
- **Batching** — accumulate multiple invalidations and issue a single shootdown
- **Large pages** — fewer TLB entries → fewer shootdown targets

---

### Huge Page Support

Standard 4 KB pages cover 4 KB per TLB entry. A 256 MB working set requires 65,536 TLB entries — far exceeding any TLB. **Huge pages** allow a single TLB entry to cover a much larger region:

|Page size|x86-64 name|ARM name|TLB coverage per entry|
|---|---|---|---|
|4 KB|Page|Page|4 KB|
|2 MB|Large page|Section (ARMv7)|2 MB|
|1 GB|Huge page|—|1 GB|
|512 GB|(5-level paging)|—|512 GB|

The page table walker detects huge pages by examining flags in intermediate page table entries (the Present bit in a PDE/PUD set with the PS bit in x86 signals a 2 MB or 1 GB leaf rather than a pointer to a deeper table level).

One TLB entry covering 2 MB vs. 4 KB means 512× fewer TLB entries for the same coverage. For workloads with large, contiguous working sets (databases, HPC, JVM heap), huge pages reduce TLB miss rate dramatically and eliminate most page walk overhead.

Linux implements **Transparent Huge Pages (THP)**: the kernel automatically promotes aligned, contiguous 4 KB pages into 2 MB huge pages when possible, without application modification.

---

### TLB and Cache Interaction

The relationship between TLB and cache indexing determines the critical path for memory accesses. Three organizations exist:

#### PIPT — Physically Indexed, Physically Tagged

The cache is indexed and tagged with physical addresses. The TLB must complete before the cache can be accessed — they are **sequential**:

```
VA → [TLB] → PA → [Cache lookup] → Data
              ↑
         serialized
```

Highest correctness, no aliasing issues. Slowest — TLB latency adds directly to cache latency on the critical path.

#### VIVT — Virtually Indexed, Virtually Tagged

The cache uses virtual addresses for both index and tag. The TLB is not needed for a cache hit:

```
VA → [Cache lookup (VA tag)] → Hit → Data  (TLB not needed)
                             → Miss → [TLB] → PA → fill cache
```

Fastest — TLB latency hidden entirely. Problem: **aliasing**. Two different virtual addresses mapping to the same physical address create two cache entries that must be kept coherent. Also, cache must be flushed on every context switch (different process may use same VA for different PA). Only viable with full OS cooperation or hardware aliasing detection. Rare in modern designs.

#### VIPT — Virtually Indexed, Physically Tagged

The dominant design for L1 caches. The cache index is derived from the virtual address (available immediately), while the tag is the physical address (from TLB). Both lookups proceed **in parallel**:

```
VA ─────┬──────────────────────→ [Cache: index with VA bits]
        │                                    ↓
        └──→ [TLB] → PA (tag) ──→ [Compare PA tag with cache tags]
                                             ↓
                              Match? → Hit, return data
                              No match? → Miss
```

The key constraint: the cache index bits must lie entirely within the **page offset** (bits below bit 12 for 4 KB pages), so that the index is the same regardless of which physical page the virtual page maps to. This limits cache size for a given associativity:

$$\text{Cache size} \leq \text{Associativity} \times \text{Page size}$$

For 4 KB pages and 8-way associativity: maximum alias-free VIPT L1 = 8 × 4 KB = 32 KB. Intel's 32 KB 8-way L1 sits exactly at this limit. A 64 KB 8-way L1 would require either aliasing management or 8 KB pages.

---

### TLB Miss Rate and Performance Impact

The **effective memory access time (EMAT)** with TLB:

$$\text{EMAT} = h_\text{TLB} \times t_\text{cache} + (1 - h_\text{TLB}) \times (t_\text{walk} + t_\text{cache})$$

where $h_\text{TLB}$ is the TLB hit rate, $t_\text{cache}$ is the cache hit time (assuming data is cached), and $t_\text{walk}$ is the page table walk time.

For $h_\text{TLB}$ = 0.99, $t_\text{cache}$ = 4 ns, $t_\text{walk}$ = 200 ns:

$$\text{EMAT} = 0.99 \times 4 + 0.01 \times 204 = 3.96 + 2.04 = 6.0 \text{ ns}$$

If $h_\text{TLB}$ drops to 0.90:

$$\text{EMAT} = 0.90 \times 4 + 0.10 \times 204 = 3.6 + 20.4 = 24.0 \text{ ns}$$

A 9-percentage-point drop in TLB hit rate produces a 4× increase in effective memory latency — demonstrating why TLB miss rate is a first-order performance concern for memory-intensive workloads.

#### TLB Coverage

The working set that fits within the TLB without misses is the **TLB coverage**:

$$\text{Coverage} = \text{TLB entries} \times \text{page size}$$

|TLB entries|4 KB pages|2 MB pages|
|---|---|---|
|64 (L1)|256 KB|128 MB|
|1536 (L2)|6 MB|3 GB|

A database with a 10 GB buffer pool will thrash a 4 KB-page TLB but fit comfortably within a 2 MB-page TLB with 5000+ entries. This is the primary motivation for huge page adoption in database systems.

---

### TLB in the Context of Security

#### Spectre Variant 2 and the BTB/iTLB Interaction

Spectre variant 2 (branch target injection) demonstrated that the BTB and iTLB can be manipulated across privilege boundaries to redirect speculative execution. Mitigations (IBPB, Retpoline) interact with TLB management because flushing translation state and prediction state must both occur on certain privilege transitions.

#### Meltdown and TLB Flushing (KPTI)

Meltdown exploited the fact that kernel page table entries were resident in the TLB during user-mode execution, enabling speculative reads of kernel memory. The mitigation — **KPTI (Kernel Page Table Isolation)** — maintains two entirely separate sets of page tables:

```
User-mode CR3:   maps only user pages + minimal kernel trampoline
Kernel-mode CR3: maps full kernel + user pages
```

Every user↔kernel transition requires a CR3 switch, which invalidates all non-global TLB entries unless PCID is used to tag user and kernel translations separately. PCID-aware KPTI retains user translations across kernel entry/exit with a PCID tag, recovering most of the shootdown overhead. Without PCID (older CPUs), KPTI costs 10–30% throughput on syscall-heavy workloads.

#### Accessed and Dirty Bit Management

The TLB caches the A (accessed) and D (dirty) bits from PTEs. When the hardware sets these bits (on first access or first write), the update is made in the TLB entry and only propagated to the PTE on TLB eviction. This creates a window where the PTE in memory does not reflect the true dirty/accessed state — the OS page replacement algorithm must account for this by flushing TLB entries before inspecting PTE bits.

---

### ISA-Specific TLB Details

#### x86-64 TLB Management Instructions

|Instruction|Operation|
|---|---|
|`INVLPG m`|Invalidate all TLB entries (all PCIDs) for the page containing address `m`|
|`MOV CR3, reg`|Load new page table base; flushes all non-global TLB entries (unless PCID bits set)|
|`INVPCID type, m128`|Fine-grained invalidation: individual address, single PCID, all PCIDs|
|`WRMSR IA32_FLUSH_CMD`|On some CPUs: flush L1D cache (security mitigation)|

The `INVPCID` instruction (introduced with Haswell) is the most flexible: it can invalidate a single address in a specific PCID, all entries in a PCID, or all entries globally.

#### ARM TLB Management (AArch64)

ARM uses a systematic **TLBI** (TLB Invalidate) instruction family with operand suffixes encoding scope and shareability:

```
TLBI ALLE1IS    — invalidate all EL1 entries, inner shareable domain
TLBI VAE1IS, Xt — invalidate by VA, EL1, inner shareable
TLBI ASIDE1, Xt — invalidate by ASID, EL1
TLBI VMALLE1    — invalidate all EL1 entries in current VMID (virtualization)
```

The `IS` suffix broadcasts the invalidation across all cores in the inner shareable domain — the hardware equivalent of the x86 IPI-based shootdown, but implemented as a single instruction that the interconnect propagates automatically.

#### RISC-V TLB Management

RISC-V uses the `SFENCE.VMA` instruction:

```
SFENCE.VMA rs1, rs2
  rs1 = 0, rs2 = 0  → flush all TLB entries
  rs1 ≠ 0, rs2 = 0  → flush entries for virtual address in rs1
  rs1 = 0, rs2 ≠ 0  → flush entries for ASID in rs2
  rs1 ≠ 0, rs2 ≠ 0  → flush entry for VA rs1 with ASID rs2
```

The instruction also acts as a memory fence, ensuring all prior page table writes are visible before the TLB is queried again. The RISC-V spec deliberately leaves the TLB organization implementation-defined — the ISA only specifies the software-visible invalidation semantics.

---

### Complete TLB Operation Summary

<svg viewBox="0 0 700 460" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="700" height="460" fill="#0d1117"/> <text x="220" y="26" fill="#f0f6fc" font-size="13" font-weight="bold">TLB Operation Flowchart</text> <!-- Start --> <rect x="270" y="42" width="160" height="28" fill="#1c2d40" stroke="#58a6ff" stroke-width="1.5" rx="14"/> <text x="300" y="60" fill="#58a6ff">Memory access (VA)</text> <line x1="350" y1="70" x2="350" y2="90" stroke="#8b949e" stroke-width="1.3"/> <!-- L1 TLB lookup --> <rect x="255" y="90" width="190" height="28" fill="#21262d" stroke="#e3b341" stroke-width="1.5" rx="3"/> <text x="282" y="108" fill="#e3b341">L1 TLB lookup (VPN + ASID)</text> <line x1="350" y1="118" x2="350" y2="138" stroke="#8b949e" stroke-width="1.3"/> <!-- L1 Hit? --> <polygon points="350,138 440,158 350,178 260,158" fill="#1c2d40" stroke="#56d364" stroke-width="1.5"/> <text x="315" y="162" fill="#56d364">L1 TLB hit?</text> <!-- Yes from L1 --> <line x1="440" y1="158" x2="560" y2="158" stroke="#3fb950" stroke-width="1.3"/> <text x="460" y="150" fill="#3fb950" font-size="10">Yes</text> <rect x="560" y="138" width="110" height="38" fill="#21362d" stroke="#3fb950" stroke-width="1.5" rx="3"/> <text x="577" y="155" fill="#3fb950">PA = PPN +</text> <text x="568" y="169" fill="#3fb950">offset → access</text> <!-- No from L1 → L2 --> <line x1="350" y1="178" x2="350" y2="200" stroke="#ff7b72" stroke-width="1.3"/> <text x="356" y="194" fill="#ff7b72" font-size="10">No</text> <!-- L2 TLB lookup --> <rect x="255" y="200" width="190" height="28" fill="#21262d" stroke="#e3b341" stroke-width="1.2" rx="3"/> <text x="272" y="218" fill="#e3b341">L2 STLB lookup (set-assoc)</text> <line x1="350" y1="228" x2="350" y2="248" stroke="#8b949e" stroke-width="1.3"/> <!-- L2 Hit? --> <polygon points="350,248 440,268 350,288 260,268" fill="#1c2d40" stroke="#56d364" stroke-width="1.5"/> <text x="315" y="272" fill="#56d364">L2 TLB hit?</text> <!-- Yes from L2 --> <line x1="440" y1="268" x2="530" y2="268" stroke="#3fb950" stroke-width="1.3"/> <text x="450" y="260" fill="#3fb950" font-size="10">Yes</text> <rect x="530" y="250" width="120" height="38" fill="#21362d" stroke="#3fb950" stroke-width="1.2" rx="3"/> <text x="545" y="266" fill="#3fb950">Install in L1 TLB</text> <text x="548" y="280" fill="#3fb950">→ return PA</text> <!-- No from L2 → Page walk --> <line x1="350" y1="288" x2="350" y2="310" stroke="#ff7b72" stroke-width="1.3"/> <text x="356" y="304" fill="#ff7b72" font-size="10">No</text> <!-- Hardware PTW --> <rect x="240" y="310" width="220" height="28" fill="#2d1a1a" stroke="#ff7b72" stroke-width="1.5" rx="3"/> <text x="265" y="328" fill="#ff7b72">Hardware page table walk</text> <line x1="350" y1="338" x2="350" y2="358" stroke="#8b949e" stroke-width="1.3"/> <!-- Valid PTE? --> <polygon points="350,358 440,378 350,398 260,378" fill="#1c2d40" stroke="#56d364" stroke-width="1.5"/> <text x="308" y="382" fill="#56d364">Valid PTE?</text> <!-- Yes → install --> <line x1="440" y1="378" x2="520" y2="378" stroke="#3fb950" stroke-width="1.3"/> <text x="450" y="370" fill="#3fb950" font-size="10">Yes</text> <rect x="520" y="360" width="148" height="38" fill="#21362d" stroke="#3fb950" stroke-width="1.2" rx="3"/> <text x="530" y="376" fill="#3fb950">Install in L1 + L2 TLB</text> <text x="538" y="390" fill="#3fb950">retry instruction</text> <!-- No → page fault --> <line x1="260" y1="378" x2="130" y2="378" stroke="#ff7b72" stroke-width="1.3"/> <text x="180" y="370" fill="#ff7b72" font-size="10">No</text> <rect x="40" y="360" width="90" height="38" fill="#2d1a1a" stroke="#ff7b72" stroke-width="1.5" rx="3"/> <text x="50" y="376" fill="#ff7b72">Page Fault</text> <text x="48" y="390" fill="#ff7b72">→ OS handler</text> <!-- Protection check annotation --> <rect x="30" y="138" width="148" height="38" fill="#21262d" stroke="#8b949e" stroke-width="1" rx="3" stroke-dasharray="4,3"/> <text x="38" y="154" fill="#8b949e">On every hit:</text> <text x="38" y="168" fill="#8b949e">check U/W/X bits</text> <line x1="256" y1="157" x2="178" y2="157" stroke="#8b949e" stroke-width="1" stroke-dasharray="3,3"/> </svg>

---

**Conclusion** The TLB is the mechanism that makes virtual memory practical. Without it, the overhead of address translation would render virtual memory systems unusable for any performance-sensitive workload. Its design — fully associative L1 for minimum latency, set-associative L2 for capacity, hardware page table walkers to handle misses transparently, ASIDs to survive context switches, and VIPT cache interaction to parallelize translation with data fetch — represents a set of engineering decisions that collectively reduce the average cost of address translation to near zero. The failure cases — TLB shootdown in multiprocessor systems, TLB thrashing in large working sets, and the security implications exposed by Meltdown — reveal how deeply the TLB is entangled with OS design, processor microarchitecture, and the threat model of the entire system.

**Next Steps** Proceed to **Cache Coherence (MSI, MESI, MOESI)** to examine how physically addressed caches across multiple cores maintain a consistent view of memory, the protocols that govern ownership and sharing of cache lines, and the interconnect mechanisms that implement coherence efficiently.

---

