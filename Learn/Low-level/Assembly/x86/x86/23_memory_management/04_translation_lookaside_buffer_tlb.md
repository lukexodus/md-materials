## Translation Lookaside Buffer (TLB)


The TLB is a specialized CPU cache that stores recent virtual-to-physical address translations to accelerate memory access.

**TLB Purpose and Operation**:

Page table walks require multiple memory accesses (2-5 depending on paging mode), creating significant performance overhead. The TLB caches successful translations, allowing single-cycle address translation for cached entries.

**TLB Structure**:

TLBs are organized as associative caches with entries containing:

- **Virtual Page Number**: Linear address bits identifying the page
- **Physical Page Frame Number**: Corresponding physical address
- **Attributes**: Page protection bits (R/W, U/S, XD, etc.)
- **ASID/PCID**: Address Space Identifier to distinguish processes
- **Valid Bit**: Indicates if entry is valid

**TLB Types**:

Modern processors typically have split TLBs:

**Instruction TLB (ITLB)**: Caches translations for instruction fetches **Data TLB (DTLB)**: Caches translations for data accesses

Each may have multiple levels:

- **L1 TLB**: Small (16-64 entries), very fast, fully associative
- **L2 TLB**: Larger (512-1536 entries), slower, set-associative

**TLB Entries for Different Page Sizes**:

Separate TLB entries may exist for different page sizes:

- 4KB page entries
- 2MB page entries (large pages)
- 1GB page entries (huge pages)

Larger pages reduce TLB pressure since each entry covers more memory.

**TLB Lookup Process**:

```
Memory Access Request (Linear Address)
         |
         v
    TLB Lookup
    /         \
TLB Hit      TLB Miss
   |            |
Physical     Page Table
Address      Walk (multiple
Available    memory accesses)
   |            |
   |        Cache result
   |        in TLB
   |            |
   +------------+
         |
    Continue memory access
```

**TLB Hit**: Translation found in TLB, immediate physical address available **TLB Miss**: Translation not in TLB, requires page table walk, result cached in TLB

**Global Pages**:

The Global (G) bit in PTEs marks pages that should not be flushed from the TLB on context switches (CR3 reload). Useful for kernel pages shared across all processes.

Enabled via CR4.PGE (Page Global Enable):

```assembly
enable_global_pages:
    mov eax, cr4
    or eax, 0x80            ; Set PGE bit (bit 7)
    mov cr4, eax
    ret

; Mark kernel page as global
    mov eax, kernel_page_pte
    or eax, 0x100           ; Set Global bit (bit 8)
    mov [page_table + offset], eax
```

**Process Context Identifier (PCID)**:

In modern x86-64 processors, PCID (CR3 bits 11-0 when CR4.PCIDE=1) tags TLB entries with a process identifier, allowing TLB entries from multiple processes to coexist. This reduces TLB flushes on context switches.

```assembly
; Enable PCID (64-bit mode only)
enable_pcid:
    mov eax, cr4
    or eax, 0x20000         ; Set PCIDE bit (bit 17)
    mov cr4, eax
    ret

; Load CR3 with PCID
load_cr3_with_pcid:
    mov rax, page_table_base
    or rax, 5               ; PCID = 5
    mov cr3, rax
    ret
```

**TLB Invalidation**:

TLB entries must be invalidated when page table mappings change to maintain coherency.

**Full TLB Flush**:

```assembly
; Method 1: Reload CR3 (flushes all non-global entries)
flush_tlb_full:
    mov eax, cr3
    mov cr3, eax            ; Reloading CR3 flushes TLB
    ret
```

**Single Page Invalidation**:

```assembly
; INVLPG instruction - invalidates single page
flush_tlb_page:
    ; Invalidate TLB entry for page at linear address in EAX
    invlpg [eax]
    ret

; Example: Invalidate page at 0x00401000
    mov eax, 0x00401000
    invlpg [eax]
```

**Global Page Flush**:

```assembly
; Flush global pages (requires toggling CR4.PGE)
flush_tlb_global:
    mov eax, cr4
    mov ebx, eax
    and eax, ~0x80          ; Clear PGE
    mov cr4, eax            ; Disable global pages (flushes all)
    mov cr4, ebx            ; Re-enable global pages
    ret
```

**PCID-aware Invalidation** (64-bit only):

```assembly
; INVPCID instruction - flexible TLB invalidation
; Types: 0=individual address, 1=single context, 2=all contexts (non-global), 3=all contexts
invpcid_single:
    ; Descriptor: [linear address (8 bytes), PCID (8 bytes)]
    mov rax, descriptor_addr
    mov ecx, 0              ; Type 0: individual address
    invpcid rax, rcx
    ret
```

**TLB Shootdown**:

In multi-processor systems, when one CPU modifies page tables, other CPUs' TLBs must be invalidated. This process is called TLB shootdown:

1. CPU modifying page tables sends inter-processor interrupt (IPI) to other CPUs
2. Other CPUs execute their TLB invalidation handlers
3. Acknowledge completion back to initiating CPU

[Inference: This is typically handled by OS kernel memory management subsystems]

**TLB Performance Considerations**:

**TLB Reach**: Total memory covered by all TLB entries. Formula: TLB_reach = Number_of_entries × Page_size

**Example**:

- 64-entry TLB with 4KB pages: 64 × 4KB = 256KB reach
- 64-entry TLB with 2MB pages: 64 × 2MB = 128MB reach

**TLB Miss Penalty**:

Page table walks on TLB misses can take 10-200 CPU cycles depending on:

- Number of page table levels (2-5 levels)
- Cache hits/misses during page table walk
- Memory latency
- Hardware page table walker efficiency

Modern processors have hardware page table walkers that operate concurrently with other CPU operations, reducing effective miss penalty.

**Optimizing TLB Usage**:

**Large Pages**: Using 2MB or 1GB pages dramatically increases TLB reach

```assembly
; Map 1GB of kernel memory with 2MB pages
setup_kernel_large_pages:
    mov edi, kernel_page_directory
    mov eax, 0x00000000     ; Start at physical 0
    or eax, 0x83            ; Present + R/W + PS (2MB pages)
    mov ecx, 512            ; 512 entries × 2MB = 1GB
.loop:
    stosd                   ; Store low 32 bits
    xor ebx, ebx
    mov [edi], ebx          ; Clear high 32 bits (PAE mode)
    add edi, 4
    add eax, 0x00200000     ; Next 2MB
    loop .loop
    ret
```

**TLB Prefetching**: [Inference: Some modern processors support TLB prefetch hints]

- Sequential access patterns may trigger hardware TLB prefetch
- Software prefetch instructions (PREFETCH*) don't typically affect TLB

**Memory Alignment**: Aligning frequently-accessed data structures to page boundaries can improve TLB efficiency by reducing entries needed.

**Superpages in Operating Systems**: [Inference: Linux transparent huge pages, Windows large page support]

- Automatically promote contiguous small pages to large pages
- Application requests large pages explicitly via APIs
- Balancing memory fragmentation vs TLB efficiency

**TLB Statistics and Profiling**:

Performance counters track TLB behavior:

```assembly
; Read performance counter (example for TLB misses)
; Counter MSR addresses are processor-specific
read_tlb_miss_counter:
    mov ecx, 0x186          ; Example MSR address (varies by CPU)
    rdpmc                   ; Read performance counter
    ; Result in EDX:EAX
    ret
```

[Inference: Actual counter addresses and availability depend on specific CPU model]

**Key Points**:

- TLB is transparent to software but critical for performance
- TLB misses can degrade performance by 10-100x compared to hits
- Large pages significantly improve TLB reach, especially for large working sets
- Global pages reduce TLB flush overhead for kernel mappings
- PCID support reduces context switch overhead by avoiding full TLB flushes
- TLB invalidation must be performed after page table modifications
- Multi-processor systems require TLB shootdown protocols
- INVLPG is faster than full CR3 reload for single-page invalidation
- Hardware page walkers reduce TLB miss penalty on modern processors
- TLB is typically first-level cache for address translation
- Application working set should ideally fit within TLB reach for optimal performance

