## Virtual Address Translation


Virtual address translation converts logical addresses used by programs into physical addresses in RAM. x86 processors support multiple paging modes with different address widths and translation mechanisms.

### Paging Modes Overview

**32-bit Paging (Legacy)**:

- 32-bit virtual addresses → 32-bit physical addresses (4 GB addressable)
- Two-level page table hierarchy
- 4 KB page size (with 4 MB large page extension)

**PAE (Physical Address Extension)**:

- 32-bit virtual addresses → 36-bit physical addresses (64 GB addressable)
- Three-level page table hierarchy
- 4 KB and 2 MB page sizes
- Introduced with Pentium Pro

**Long Mode Paging (x86-64)**:

- 48-bit virtual addresses → 52-bit physical addresses [Inference] (4 PB addressable theoretical)
- Four-level page table hierarchy (PML4)
- 4 KB, 2 MB, and 1 GB page sizes
- Standard for 64-bit operating systems

### Enabling Paging

**Basic 32-bit Paging:**

```nasm
; Set up page directory
mov eax, page_directory
mov cr3, eax                ; Load page directory base

; Enable paging
mov eax, cr0
or eax, 0x80000000          ; Set PG bit (bit 31)
mov cr0, eax                ; Paging now active
```

**PAE Paging:**

```nasm
; Enable PAE first
mov eax, cr4
or eax, 0x20                ; Set PAE bit (bit 5)
mov cr4, eax

; Load page directory pointer table
mov eax, pdpt
mov cr3, eax

; Enable paging
mov eax, cr0
or eax, 0x80000000          ; Set PG bit
mov cr0, eax
```

**Long Mode Paging:**

```nasm
; Enable PAE
mov eax, cr4
or eax, 0x20                ; PAE bit
mov cr4, eax

; Load PML4 table
mov eax, pml4_table
mov cr3, eax

; Enable long mode (in IA32_EFER MSR)
mov ecx, 0xC0000080         ; IA32_EFER MSR
rdmsr
or eax, 0x100               ; Set LME bit
wrmsr

; Enable paging (activates long mode)
mov eax, cr0
or eax, 0x80000000          ; Set PG bit
mov cr0, eax
```

### 32-bit Paging Translation

**Virtual Address Structure (4 KB pages):**

```
31                 22 21                 12 11                  0
+--------------------+---------------------+---------------------+
| Directory Index    | Table Index         | Page Offset         |
| (10 bits)          | (10 bits)           | (12 bits)           |
+--------------------+---------------------+---------------------+
```

**Translation Process:**

1. **CR3** contains physical address of Page Directory (aligned to 4 KB)
2. **Directory Index** (bits 31-22) selects one of 1024 Page Directory Entries (PDEs)
3. PDE contains physical address of Page Table (aligned to 4 KB)
4. **Table Index** (bits 21-12) selects one of 1024 Page Table Entries (PTEs)
5. PTE contains physical address of 4 KB page frame (aligned to 4 KB)
6. **Page Offset** (bits 11-0) is added to page frame address to get physical address

**Page Directory Entry (PDE) Format:**

```
31                           12 11  9 8 7 6 5 4 3 2 1 0
+------------------------------+-----+-+-+-+-+-+-+-+-+-+
| Page Table Base Address      |Avail|G|S|0|A|D|W|U|R|P|
| (bits 31-12)                 |     | | | | | | | | | |
+------------------------------+-----+-+-+-+-+-+-+-+-+-+
```

**Page Table Entry (PTE) Format:**

```
31                           12 11  9 8 7 6 5 4 3 2 1 0
+------------------------------+-----+-+-+-+-+-+-+-+-+-+
| Page Frame Address           |Avail|G|T|D|A|C|W|U|R|P|
| (bits 31-12)                 |     | | | | | | | | | |
+------------------------------+-----+-+-+-+-+-+-+-+-+-+
```

**Common Flags:**

- **P (Present, bit 0)**: 1 = page is in memory, 0 = page fault on access
- **R/W (Read/Write, bit 1)**: 0 = read-only, 1 = read/write
- **U/S (User/Supervisor, bit 2)**: 0 = supervisor only (CPL 0-2), 1 = user accessible (CPL 3)
- **PWT (Page Write-Through, bit 3)**: Cache write policy
- **PCD (Page Cache Disable, bit 4)**: 1 = disable caching for this page
- **A (Accessed, bit 5)**: Set by CPU when page is accessed
- **D (Dirty, bit 6)**: Set by CPU when page is written to (PTEs only)
- **PS (Page Size, bit 7)**: 1 = large page (PDEs only)
- **G (Global, bit 8)**: 1 = TLB entry not invalidated on CR3 reload (requires CR4.PGE)
- **Avail (bits 9-11)**: Available for OS use

**Identity Mapping Example:**

```nasm
; Create identity-mapped first 4 MB (0x00000000 - 0x003FFFFF)
align 4096
page_directory:
    ; First entry: maps 0x00000000 - 0x003FFFFF
    dd page_table_0 + 0x003      ; Present, R/W
    times 1023 dd 0              ; Rest of directory empty

align 4096
page_table_0:
    ; Map 1024 pages (1024 * 4KB = 4MB)
    %assign pg 0
    %rep 1024
        dd (pg * 0x1000) + 0x003 ; Physical address + Present + R/W
        %assign pg pg+1
    %endrep
```

**Kernel/User Space Split Example:**

```nasm
; Typical 3GB/1GB split (0x00000000-0xBFFFFFFF user, 0xC0000000-0xFFFFFFFF kernel)
page_directory:
    ; First 768 entries (0x00000000 - 0xBFFFFFFF) for user space
    %assign i 0
    %rep 768
        dd user_page_table_0 + (i * 4096) + 0x007  ; Present, R/W, User
        %assign i i+1
    %endrep
    
    ; Last 256 entries (0xC0000000 - 0xFFFFFFFF) for kernel space
    %assign i 0
    %rep 256
        dd kernel_page_table_0 + (i * 4096) + 0x003  ; Present, R/W, Supervisor
        %assign i i+1
    %endrep
```

### PAE Paging Translation

Physical Address Extension allows 32-bit systems to access more than 4 GB of physical memory by extending physical addresses to 36 bits.

**Virtual Address Structure (4 KB pages):**

```
31       30 29                 21 20                 12 11                  0
+-----------+---------------------+---------------------+---------------------+
| PDPT Index| Directory Index     | Table Index         | Page Offset         |
| (2 bits)  | (9 bits)            | (9 bits)            | (12 bits)           |
+-----------+---------------------+---------------------+---------------------+
```

**Translation Process:**

1. **CR3** contains physical address of Page Directory Pointer Table (PDPT) - only 4 entries used
2. **PDPT Index** (bits 31-30) selects one of 4 PDPT entries
3. PDPT entry contains physical address of Page Directory
4. **Directory Index** (bits 29-21) selects one of 512 Page Directory Entries
5. PDE contains physical address of Page Table
6. **Table Index** (bits 20-12) selects one of 512 Page Table Entries
7. PTE contains 36-bit physical address of page frame
8. **Page Offset** (bits 11-0) added to page frame address

**PDPT Entry Format (8 bytes):**

```
63           52 51      36 35           12 11        0
+--------------+-----------+--------------+-----------+
| Reserved (0) | Reserved  | PD Base      | Reserved  |P|
|              | (must be 0)| (bits 35-12) | Avail   |W|C|W|
|              |           |              |         |T|D|T|P|
+--------------+-----------+--------------+-----------+
```

**Page Directory Entry (PAE, 8 bytes):**

```
63           52 51      36 35           12 11   9 8 7 6 5 4 3 2 1 0
+--------------+-----------+--------------+------+-+-+-+-+-+-+-+-+-+
| Reserved (0) | PT Base   | PT Base      |Avail |G|S|0|A|C|W|U|R|P|
|              |(bits 51-36)| (bits 35-12)|      | | | | |D|T|/|/|/| 
|              |           |              |      | | | | | | |S|W|P|
+--------------+-----------+--------------+------+-+-+-+-+-+-+-+-+-+
```

**Page Table Entry (PAE, 8 bytes):**

```
63           52 51      36 35           12 11   9 8 7 6 5 4 3 2 1 0
+--------------+-----------+--------------+------+-+-+-+-+-+-+-+-+-+
| Reserved (0) | Page Base | Page Base    |Avail |G|T|D|A|C|W|U|R|P|
|              |(bits 51-36)| (bits 35-12)|      | | | | |D|T|/|/|/|
|              |           |              |      | | | | | | |S|W|P|
+--------------+-----------+--------------+------+-+-+-+-+-+-+-+-+-+
```

**PAE Setup Example:**

```nasm
align 32
pdpt:
    ; Four PDPT entries, each pointing to a page directory
    dq page_dir_0 + 0x001       ; Present
    dq page_dir_1 + 0x001       ; Present
    dq page_dir_2 + 0x001       ; Present
    dq page_dir_3 + 0x001       ; Present

align 4096
page_dir_0:
    ; Map first GB (512 directories × 2 MB each)
    %assign i 0
    %rep 512
        dq page_table_0 + (i * 4096) + 0x003  ; Present, R/W
        %assign i i+1
    %endrep

align 4096
page_table_0:
    ; Map first 2 MB (512 pages × 4 KB each)
    %assign i 0
    %rep 512
        dq (i * 0x1000) + 0x003   ; Physical address + Present + R/W
        %assign i i+1
    %endrep
```

### Long Mode (x86-64) Paging Translation

**Virtual Address Structure (4 KB pages):**

```
63     48 47        39 38        30 29        21 20        12 11         0
+--------+------------+------------+------------+------------+------------+
|Sign Ext| PML4 Index | PDPT Index | PD Index   | PT Index   | Offset     |
|(16 bit)| (9 bits)   | (9 bits)   | (9 bits)   | (9 bits)   | (12 bits)  |
+--------+------------+------------+------------+------------+------------+
```

**Note:** Bits 63-48 must be sign-extension of bit 47. This creates two valid address ranges:

- **0x0000000000000000 - 0x00007FFFFFFFFFFF** (canonical lower half, typically user space)
- **0xFFFF800000000000 - 0xFFFFFFFFFFFFFFFF** (canonical upper half, typically kernel space)

**Translation Process (4-level):**

1. **CR3** contains physical address of PML4 (Page Map Level 4) table
2. **PML4 Index** (bits 47-39) selects one of 512 PML4 entries
3. PML4E contains physical address of PDPT (Page Directory Pointer Table)
4. **PDPT Index** (bits 38-30) selects one of 512 PDPT entries
5. PDPTE contains physical address of PD (Page Directory)
6. **PD Index** (bits 29-21) selects one of 512 PD entries
7. PDE contains physical address of PT (Page Table)
8. **PT Index** (bits 20-12) selects one of 512 PT entries
9. PTE contains 52-bit physical address of page frame [Inference]
10. **Offset** (bits 11-0) added to page frame address

**PML4 Entry Format (8 bytes):**

```
63    52 51         12 11   9 8 7 6 5 4 3 2 1 0
+--------+-------------+------+-+-+-+-+-+-+-+-+-+
|Reserved| PDPT Base   |Avail |0|0|0|A|C|W|U|R|P|
|  (0)   | (bits 51-12)|      | | | | |D|T|/|/|/|
|        |             |      | | | | | | |S|W|P|
+--------+-------------+------+-+-+-+-+-+-+-+-+-+
```

**PDPT Entry Format (8 bytes):**

```
63    52 51         12 11   9 8 7 6 5 4 3 2 1 0
+--------+-------------+------+-+-+-+-+-+-+-+-+-+
|Reserved| PD Base     |Avail |0|S|0|A|C|W|U|R|P|
|  (0)   | (bits 51-12)|      | | | | |D|T|/|/|/|
|        |             |      | | | | | | |S|W|P|
+--------+-------------+------+-+-+-+-+-+-+-+-+-+
```

**S (bit 7)**: If 1, this entry maps a 1 GB huge page directly (no PD/PT)

**Page Directory Entry Format (8 bytes):**

```
63    52 51         12 11   9 8 7 6 5 4 3 2 1 0
+--------+-------------+------+-+-+-+-+-+-+-+-+-+
|Reserved| PT Base     |Avail |G|S|0|A|C|W|U|R|P|
|  (0)   | (bits 51-12)|      | | | | |D|T|/|/|/|
|        |             |      | | | | | | |S|W|P|
+--------+-------------+------+-+-+-+-+-+-+-+-+-+
```

**S (bit 7)**: If 1, this entry maps a 2 MB large page directly (no PT)

**Page Table Entry Format (8 bytes):**

```
63    52 51         12 11   9 8 7 6 5 4 3 2 1 0
+--------+-------------+------+-+-+-+-+-+-+-+-+-+
|Reserved| Page Base   |Avail |G|T|D|A|C|W|U|R|P|
|  (0)   | (bits 51-12)|      | | | | |D|T|/|/|/|
|        |             |      | | | | | | |S|W|P|
+--------+-------------+------+-+-+-+-+-+-+-+-+-+
```

**Long Mode Page Table Setup Example:**

```nasm
align 4096
pml4_table:
    ; Map first 512 GB through one PDPT
    dq pdpt_table + 0x003           ; Present, R/W
    times 510 dq 0                  ; Rest unused
    ; Last entry for kernel (higher half)
    dq pdpt_kernel + 0x003          ; Present, R/W

align 4096
pdpt_table:
    ; Map first GB through one PD
    dq pd_table + 0x003             ; Present, R/W
    times 511 dq 0                  ; Rest unused

align 4096
pd_table:
    ; Map first 2 MB through one PT
    dq pt_table + 0x003             ; Present, R/W
    times 511 dq 0                  ; Rest unused

align 4096
pt_table:
    ; Identity map first 2 MB (512 pages × 4 KB)
    %assign i 0
    %rep 512
        dq (i * 0x1000) + 0x003     ; Physical address + Present + R/W
        %assign i i+1
    %endrep
```

### TLB (Translation Lookaside Buffer)

The TLB is a CPU cache that stores recent virtual-to-physical address translations to avoid page table walks.

**TLB Management Instructions:**

```nasm
; Invalidate single TLB entry
invlpg [virtual_address]

; Invalidate all TLB entries (except global pages if CR4.PGE=1)
mov eax, cr3
mov cr3, eax                ; Reloading CR3 flushes TLB

; Invalidate all TLB entries including global pages
mov eax, cr4
and eax, ~0x80              ; Clear PGE bit
mov cr4, eax                ; Flushes all TLB
or eax, 0x80                ; Restore PGE
mov cr4, eax
```

**Global Pages:**

Pages marked with the G (Global) flag in PTEs remain in the TLB across CR3 reloads. This is useful for kernel pages that are shared across all processes.

```nasm
; Enable global pages
mov eax, cr4
or eax, 0x80                ; Set PGE (Page Global Enable)
mov cr4, eax

; Create global page entry
; Kernel page table entry with Global flag
dq 0x123000 + 0x103         ; Present, R/W, Global
```

### Page Fault Handling

When a page fault occurs, the CPU:

1. Pushes error code onto stack
2. Pushes CS:EIP of faulting instruction
3. Jumps to page fault handler (interrupt 14)
4. Stores faulting address in CR2

**Page Fault Error Code Format:**

```
Bit 0 (P): 0 = page not present, 1 = protection violation
Bit 1 (W/R): 0 = read access, 1 = write access
Bit 2 (U/S): 0 = supervisor mode, 1 = user mode
Bit 3 (RSVD): 1 = reserved bit violation
Bit 4 (I/D): 1 = instruction fetch
```

**Page Fault Handler Example:**

```nasm
page_fault_handler:
    push eax
    push ebx
    
    ; Get faulting address
    mov eax, cr2                ; CR2 contains faulting address
    
    ; Get error code (already on stack)
    mov ebx, [esp + 12]         ; Error code pushed by CPU
    
    ; Check if present bit (bit 0) is 0
    test ebx, 1
    jz .not_present
    
.protection_violation:
    ; Handle protection violation
    ; Check U/S bit (bit 2)
    test ebx, 4
    jnz .user_violation
    ; Kernel violation
    jmp .handle_kernel_fault
    
.user_violation:
    ; User tried to access kernel page
    jmp .handle_user_fault
    
.not_present:
    ; Page not present - might need to load from disk
    ; or allocate new page
    call handle_page_not_present
    
    pop ebx
    pop eax
    add esp, 4                  ; Remove error code
    iretd                       ; Return from interrupt
```

