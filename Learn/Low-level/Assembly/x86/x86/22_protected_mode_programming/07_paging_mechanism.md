## Paging Mechanism


Paging is a memory management technique that divides physical memory into fixed-size blocks called page frames and virtual memory into pages of the same size. The paging mechanism provides virtual-to-physical address translation, enabling virtual memory, memory protection, and efficient memory allocation.

### Enabling Paging

Paging is enabled by setting bit 31 (PG bit) of the CR0 control register. Before enabling paging, the CR3 register must be loaded with the physical address of the page directory.

```assembly
; Enable paging
setup_paging:
    ; Load page directory address into CR3
    mov eax, page_directory
    mov cr3, eax
    
    ; Enable paging by setting bit 31 of CR0
    mov eax, cr0
    or eax, 0x80000000      ; Set PG bit
    mov cr0, eax
    
    ret
```

### 32-bit Paging (4 KB Pages)

The standard 32-bit paging mechanism uses a two-level page table hierarchy with 4 KB pages.

**Address Translation:**

A 32-bit linear address is divided into three components:

- Bits 31-22: Page Directory Index (10 bits, 1024 entries)
- Bits 21-12: Page Table Index (10 bits, 1024 entries)
- Bits 11-0: Offset within Page (12 bits, 4096 bytes)

**Translation Process:**

1. CR3 register points to page directory base
2. Bits 31-22 of linear address index into page directory
3. Page directory entry (PDE) points to page table
4. Bits 21-12 of linear address index into page table
5. Page table entry (PTE) points to physical page frame
6. Bits 11-0 provide offset within the page frame
7. Final physical address = page frame base + offset

### Page Directory Structure

The page directory contains 1024 entries, each 4 bytes (32 bits), for a total size of 4 KB. Each entry describes one page table.

```assembly
; Page directory entry format (32-bit)
; Bit 0:    Present (P)
; Bit 1:    Read/Write (R/W)
; Bit 2:    User/Supervisor (U/S)
; Bit 3:    Page-level Write-Through (PWT)
; Bit 4:    Page-level Cache Disable (PCD)
; Bit 5:    Accessed (A)
; Bit 6:    Reserved (must be 0)
; Bit 7:    Page Size (PS) - 0 for 4KB pages
; Bits 8-11: Available for OS use
; Bits 12-31: Page table base address (aligned to 4KB)

create_page_directory:
    ; Allocate 4KB aligned memory for page directory
    mov edi, page_directory
    xor eax, eax
    mov ecx, 1024
    rep stosd               ; Zero out page directory
    
    ; Map first page table (covers 0-4MB)
    mov eax, page_table_0
    or eax, 0x03           ; Present + Read/Write
    mov [page_directory], eax
    
    ret
```

### Page Table Structure

Each page table contains 1024 entries, each 4 bytes, mapping 4 MB of virtual address space (1024 pages × 4 KB per page).

```assembly
; Page table entry format (32-bit)
; Bit 0:    Present (P)
; Bit 1:    Read/Write (R/W)
; Bit 2:    User/Supervisor (U/S)
; Bit 3:    Page-level Write-Through (PWT)
; Bit 4:    Page-level Cache Disable (PCD)
; Bit 5:    Accessed (A)
; Bit 6:    Dirty (D)
; Bit 7:    Page Attribute Table (PAT)
; Bit 8:    Global (G)
; Bits 9-11: Available for OS use
; Bits 12-31: Physical page frame address (aligned to 4KB)

create_page_table:
    ; Identity map first 4MB (1024 pages)
    mov edi, page_table_0
    mov eax, 0x03          ; Present + Read/Write
    mov ecx, 1024
    
.loop:
    stosd                  ; Store PTE
    add eax, 0x1000        ; Next 4KB page
    loop .loop
    
    ret
```

### Page Table Entry Flags

**Present (P) - Bit 0:**

- 0: Page not present in physical memory (causes page fault)
- 1: Page is present

**Read/Write (R/W) - Bit 1:**

- 0: Read-only access
- 1: Read/write access

**User/Supervisor (U/S) - Bit 2:**

- 0: Supervisor only (CPL 0-2)
- 1: User accessible (CPL 3)

**Accessed (A) - Bit 5:**

- Set by processor when page is accessed
- OS can use for page replacement algorithms

**Dirty (D) - Bit 6:**

- Set by processor when page is written to
- OS can use to optimize page-out operations

**Global (G) - Bit 8:**

- Prevents TLB flush for this page when CR3 changes
- Requires CR4.PGE = 1

```assembly
; Example: Mapping a page with specific attributes
map_page:
    ; Parameters:
    ; EAX = virtual address
    ; EBX = physical address
    ; ECX = flags (Present, R/W, U/S, etc.)
    
    push edi
    push eax
    
    ; Extract page directory index (bits 31-22)
    mov edi, eax
    shr edi, 22
    shl edi, 2              ; Multiply by 4 for byte offset
    add edi, page_directory
    
    ; Check if page table exists
    mov edx, [edi]
    test edx, 1             ; Test present bit
    jnz .table_exists
    
    ; Allocate new page table
    call allocate_page_table
    or eax, 0x07            ; Present + R/W + User
    mov [edi], eax
    mov edx, eax
    
.table_exists:
    ; Get page table address
    and edx, 0xFFFFF000     ; Clear flags, keep address
    
    ; Extract page table index (bits 21-12)
    pop eax
    push eax
    shr eax, 12
    and eax, 0x3FF          ; Isolate 10 bits
    shl eax, 2              ; Multiply by 4
    add edx, eax
    
    ; Set page table entry
    mov eax, ebx            ; Physical address
    and eax, 0xFFFFF000     ; Align to 4KB
    or eax, ecx             ; Add flags
    mov [edx], eax
    
    ; Invalidate TLB entry
    pop eax
    invlpg [eax]
    
    pop edi
    ret
```

### Page Fault Handling

When the processor attempts to access a page that is not present or violates protection rules, it generates a page fault exception (vector 14) and pushes an error code onto the stack.

**Error Code Format:**

- Bit 0: P (0 = not present, 1 = protection violation)
- Bit 1: W/R (0 = read, 1 = write)
- Bit 2: U/S (0 = supervisor, 1 = user mode)
- Bit 3: RSVD (1 = reserved bit violation)
- Bit 4: I/D (1 = instruction fetch)

```assembly
; Page fault handler
page_fault_handler:
    ; Save registers
    push eax
    push ebx
    push ecx
    push edx
    
    ; Get faulting address from CR2
    mov eax, cr2
    
    ; Get error code from stack
    mov ebx, [esp + 20]     ; Skip saved registers + return address
    
    ; Analyze error code
    test ebx, 1
    jz .not_present
    
    ; Protection violation
    test ebx, 2
    jnz .write_violation
    
.read_violation:
    ; Handle read protection violation
    jmp .handle_protection
    
.write_violation:
    ; Handle write protection violation (e.g., copy-on-write)
    call handle_copy_on_write
    jmp .done
    
.not_present:
    ; Page not present - load from disk or allocate
    call handle_page_not_present
    jmp .done
    
.handle_protection:
    ; Terminate offending process or handle error
    call terminate_faulting_process
    
.done:
    ; Restore registers
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    ; Remove error code
    add esp, 4
    
    iret
```

### Physical Address Extension (PAE)

PAE extends physical addressing from 32 bits to 36 bits, allowing access to up to 64 GB of physical memory on 32-bit systems. It introduces a three-level page table hierarchy.

**Enabling PAE:**

```assembly
; Enable PAE paging
enable_pae:
    ; Set PAE bit (bit 5) in CR4
    mov eax, cr4
    or eax, 0x20
    mov cr4, eax
    
    ; Load page directory pointer table
    mov eax, pdpt
    mov cr3, eax
    
    ; Enable paging
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax
    
    ret
```

**PAE Structure:**

1. **Page Directory Pointer Table (PDPT)**: 4 entries (32 bytes), pointed to by CR3
2. **Page Directory**: 512 entries per PDPT entry
3. **Page Table**: 512 entries per PD entry
4. **Page**: 4 KB

Each entry in PAE mode is 8 bytes (64 bits) to accommodate 36-bit physical addresses:

```assembly
; PAE page table entry (64-bit)
; Bits 0-11:   Flags (similar to 32-bit, with additional bits)
; Bits 12-35:  Physical address bits 12-35
; Bits 36-51:  Reserved (must be 0)
; Bits 52-62:  Available for OS use
; Bit 63:      Execute Disable (NX) if supported
```

### Page Size Extension (PSE)

PSE allows the use of 4 MB pages (32-bit mode) or 2 MB pages (PAE/64-bit mode) in addition to standard 4 KB pages. Large pages reduce TLB pressure and improve performance for large contiguous memory regions.

```assembly
; Enable PSE for 4MB pages
enable_pse:
    ; Set PSE bit (bit 4) in CR4
    mov eax, cr4
    or eax, 0x10
    mov cr4, eax
    
    ret

; Create page directory entry for 4MB page
create_4mb_page:
    ; Page directory entry with PS bit set
    mov eax, physical_address
    and eax, 0xFFC00000     ; Align to 4MB boundary
    or eax, 0x83            ; Present + R/W + PS bit
    mov [page_directory + index*4], eax
    
    ret
```

### 64-bit Paging (Long Mode)

64-bit long mode uses a four-level page table hierarchy (or five with LA57 extension):

1. **Page Map Level 4 (PML4)**: 512 entries, pointed to by CR3
2. **Page Directory Pointer Table (PDPT)**: 512 entries per PML4 entry
3. **Page Directory (PD)**: 512 entries per PDPT entry
4. **Page Table (PT)**: 512 entries per PD entry
5. **Page**: 4 KB

**64-bit Linear Address Format:**

- Bits 63-48: Sign extension (must match bit 47)
- Bits 47-39: PML4 index (9 bits)
- Bits 38-30: PDPT index (9 bits)
- Bits 29-21: PD index (9 bits)
- Bits 20-12: PT index (9 bits)
- Bits 11-0: Offset (12 bits)

```assembly
; 64-bit page table entry format
; Bits 0-11:   Flags
; Bits 12-51:  Physical address bits 12-51 (40 bits total)
; Bits 52-62:  Available for OS use
; Bit 63:      Execute Disable (NX)

; Example: Setting up identity mapping in 64-bit mode
setup_64bit_paging:
    ; Clear PML4
    mov rdi, pml4
    xor rax, rax
    mov rcx, 512
    rep stosq
    
    ; Set up first PML4 entry
    mov rax, pdpt
    or rax, 0x03            ; Present + R/W
    mov [pml4], rax
    
    ; Set up PDPT entry
    mov rax, pd
    or rax, 0x03
    mov [pdpt], rax
    
    ; Set up PD entries for 2MB pages
    mov rdi, pd
    mov rax, 0x83           ; Present + R/W + PS (2MB pages)
    mov rcx, 512
    
.loop:
    stosq
    add rax, 0x200000       ; Next 2MB
    loop .loop
    
    ; Load CR3
    mov rax, pml4
    mov cr3, rax
    
    ret
```

### Translation Lookaside Buffer (TLB)

The TLB is a cache that stores recent virtual-to-physical address translations to improve performance. The processor automatically manages the TLB, but software must invalidate entries when page tables change.

**TLB Invalidation Instructions:**

```assembly
; Invalidate single page
mov eax, virtual_address
invlpg [eax]            ; Invalidate TLB entry for this page

; Invalidate all TLB entries (except global pages)
mov eax, cr3
mov cr3, eax            ; Reloading CR3 flushes TLB

; Invalidate all TLB entries including global pages (if supported)
mov eax, cr4
xor eax, 0x80           ; Toggle PGE bit
mov cr4, eax
xor eax, 0x80           ; Toggle back
mov cr4, eax
```

### Memory Type Range Registers (MTRRs)

[Inference] MTRRs allow the operating system to specify memory types (write-back, write-through, uncacheable, etc.) for different physical memory ranges, controlling how the processor caches memory accesses. This mechanism is complementary to page-level caching controls.

