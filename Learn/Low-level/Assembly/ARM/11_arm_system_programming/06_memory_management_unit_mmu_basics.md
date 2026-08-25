## Memory Management Unit (MMU) Basics


The Memory Management Unit provides virtual-to-physical address translation, memory protection, and cache control. The MMU enables features essential to modern operating systems: process isolation, demand paging, memory-mapped I/O, and efficient memory utilization.

**Virtual vs Physical Addressing:**

**Physical Address:** Actual hardware address on the memory bus. Physical memory is limited by installed RAM.

**Virtual Address:** Address space presented to software. Each process has its own virtual address space (typically 4GB on 32-bit ARM), isolated from other processes.

The MMU translates virtual addresses to physical addresses transparently during every memory access.

**Translation Process Overview:**

1. CPU generates virtual address during load/store/fetch
2. MMU consults translation tables (page tables) to map virtual → physical
3. MMU checks access permissions (read/write/execute, privilege level)
4. If translation succeeds, physical address sent to memory/cache
5. If translation fails, MMU raises abort exception (page fault)

**ARM MMU Architecture Components:**

**Translation Table Base Registers (TTBR0, TTBR1):** Hold physical addresses of page table base addresses. TTBR0 typically maps user space (0x00000000-0x7FFFFFFF), TTBR1 maps kernel space (0x80000000-0xFFFFFFFF).

**Translation Table Base Control Register (TTBCR):** Configures the split between TTBR0 and TTBR1 address spaces.

**Domain Access Control Register (DACR):** Provides coarse-grained access control through 16 domains. Each 2-bit field specifies domain access (no access, client, manager).

**System Control Register (SCCR):** Controls MMU enable/disable, cache enable, alignment checking, and other system features.

**Translation Lookaside Buffer (TLB):** Caches recent virtual-to-physical translations to avoid walking page tables on every access. TLB is transparent hardware but requires software maintenance (invalidation) when page tables change.

**Page Table Structure:**

ARM uses a two-level page table hierarchy (ARMv7 and earlier with Short-descriptor format):

**Level 1 (First-level descriptor table):** 4096 entries, each 4 bytes, covering 1MB sections of virtual address space. Total size = 16KB per process.

**Level 2 (Second-level page table):** 256 entries per table, each 4 bytes, covering 4KB pages. Multiple L2 tables exist, one for each 1MB section that uses fine-grained mapping.

**Virtual Address Breakdown (4KB pages):**

```
31           20 19        12 11          0
|   L1 Index   | L2 Index  | Page Offset |
|   (12 bits)  | (8 bits)  |  (12 bits)  |
```

**Translation Walk Example:**

```
Virtual Address: 0x12345678

Step 1: Extract L1 index
  L1_index = VA[31:20] = 0x123
  L1_descriptor = TTBR0 + (L1_index * 4)
  
Step 2: Read L1 descriptor
  If section (1MB page): descriptor contains physical base, done
  If page table: descriptor contains L2 table base address
  
Step 3: Extract L2 index (if L2 table)
  L2_index = VA[19:12] = 0x45
  L2_descriptor = L2_base + (L2_index * 4)
  
Step 4: Read L2 descriptor
  Physical_base = L2_descriptor[31:12]
  Page_offset = VA[11:0] = 0x678
  
Physical Address = Physical_base | Page_offset
```

**Descriptor Formats:**

**L1 Section Descriptor (1MB mapping):**

```
31          20 19 18 17 16 15 14 12 11 10 9 8  5 4 3 2 1 0
| Section Base |NS| 0|nG| S|AP2| TEX |AP1|  Domain  |XN|C|B|1|0|
```

**L1 Page Table Descriptor:**

```
31          10 9 8  5 4 3 2 1 0
| PT Base Addr | | Dom |NS| |0|1|
```

**L2 Small Page Descriptor (4KB mapping):**

```
31          12 11 10 9 8  6 5 4 3 2 1 0
| Page Base   |nG|S|AP2|TEX|AP1|C|B|1|
```

**Descriptor Field Meanings:**

- **Section/Page Base:** Physical address bits (4KB-aligned for pages, 1MB-aligned for sections)
- **AP (Access Permission):** Controls read/write access for privileged/unprivileged modes
- **Domain:** Security domain (0-15)
- **C (Cacheable), B (Bufferable):** Cache/buffer policy bits
- **TEX (Type Extension):** Extended memory type attributes
- **XN (Execute Never):** Prevents instruction execution
- **S (Shareable):** Memory shareable between cores
- **nG (not Global):** Process-specific translation (TLB management)
- **NS (Non-Secure):** TrustZone security attribute

**Access Permission Encoding:**

```
AP[2:0]  Privileged     Unprivileged
000      No access      No access
001      Read/Write     No access
010      Read/Write     Read-only
011      Read/Write     Read/Write
100      Reserved
101      Read-only      No access
110      Read-only      Read-only
111      Read-only      Read-only (deprecated)
```

**Memory Types and Cache Policy:**

The C, B, and TEX bits combine to specify memory type:

**Strongly-ordered:** No buffering, no caching. Used for device registers requiring strict ordering.

**Device:** Bufferable but not cacheable. Used for memory-mapped I/O.

**Normal:** Cacheable and bufferable with various policies (write-through, write-back, non-cacheable).

**Example** TEX, C, B encoding for Normal memory:

```
TEX C B  Memory Type
001 0 0  Normal, write-through, no allocate on write
001 1 1  Normal, write-back, no allocate on write
001 0 1  Normal, write-through, allocate on write
001 1 0  Normal, write-back, allocate on write
```

**MMU Programming Example:**

```assembly
; Enable MMU with identity mapping (virtual = physical)

    ; Disable MMU and caches
    MRC     p15, 0, R0, c1, c0, 0    ; Read SCCR
    BIC     R0, R0, #0x1             ; Clear M bit (MMU)
    BIC     R0, R0, #0x4             ; Clear C bit (D-cache)
    BIC     R0, R0, #0x1000          ; Clear I bit (I-cache)
    MCR     p15, 0, R0, c1, c0, 0    ; Write SCCR
    
    ; Invalidate TLB
    MOV     R0, #0
    MCR     p15, 0, R0, c8, c7, 0    ; TLBIALL
    
    ; Set domain access (domain 0 = manager)
    MVN     R0, #0                    ; All bits set
    MCR     p15, 0, R0, c3, c0, 0    ; Write DACR
    
    ; Create L1 page table (simplified identity map)
    LDR     R0, =page_table_base
    LDR     R1, =0x4096              ; 4096 entries
    MOV     R2, #0                   ; Physical base = 0
    MOV     R3, #0x0C02              ; Section descriptor bits
create_section:
    ORR     R4, R2, R3               ; Combine base + attributes
    STR     R4, [R0], #4             ; Store descriptor
    ADD     R2, R2, #0x100000        ; Next 1MB section
    SUBS    R1, R1, #1
    BNE     create_section
    
    ; Set TTBR0
    LDR     R0, =page_table_base
    MCR     p15, 0, R0, c2, c0, 0    ; Write TTBR0
    
    ; Set TTBCR (use only TTBR0)
    MOV     R0, #0
    MCR     p15, 0, R0, c2, c0, 2    ; Write TTBCR
    
    ; Enable MMU
    MRC     p15, 0, R0, c1, c0, 0    ; Read SCCR
    ORR     R0, R0, #0x1             ; Set M bit
    ORR     R0, R0, #0x4             ; Set C bit
    ORR     R0, R0, #0x1000          ; Set I bit
    MCR     p15, 0, R0, c1, c0, 0    ; Write SCCR
    
    ; MMU now active

.align 14  ; 16KB alignment
page_table_base:
    .space 16384
```

**TLB Management:** Software must explicitly invalidate TLB entries when modifying page tables:

```assembly
; Invalidate entire TLB
MOV     R0, #0
MCR     p15, 0, R0, c8, c7, 0      ; TLBIALL

; Invalidate TLB entry by virtual address
MCR     p15, 0, R0, c8, c7, 1      ; TLBIMVA, R0 = virtual address

; Invalidate TLB by ASID (Address Space ID)
MCR     p15, 0, R0, c8, c7, 2      ; TLBIASID, R0 = ASID
```

**Data/Instruction Synchronization Barriers:** Required after MMU/TLB operations to ensure changes are visible:

```assembly
DSB     ; Data Synchronization Barrier
ISB     ; Instruction Synchronization Barrier
```

**Page Fault Handling:** When translation fails, the MMU raises a data abort or prefetch abort exception. The kernel's fault handler:

1. Reads Fault Address Register (FAR) to get faulting virtual address
2. Reads Fault Status Register (FSR) to determine fault type
3. Decides action: load page from disk, allocate memory, terminate process
4. Updates page tables and invalidates TLB
5. Resumes execution (retry faulting instruction)

```assembly
; Read fault information
MRC     p15, 0, R0, c6, c0, 0      ; DFAR (Data Fault Address)
MRC     p15, 0, R1, c5, c0, 0      ; DFSR (Data Fault Status)
```

