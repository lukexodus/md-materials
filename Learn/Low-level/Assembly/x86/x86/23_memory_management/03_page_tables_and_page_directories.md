## Page Tables and Page Directories


Paging systems use hierarchical page table structures to translate linear addresses to physical addresses. The structure varies by processor mode and enabled features.

### 32-bit Paging (Non-PAE)

Standard 32-bit paging uses a two-level page table hierarchy with 4KB page size.

**Structure**:

- **Page Directory**: 1024 entries (Page Directory Entries - PDEs), each covering 4MB of linear address space
- **Page Table**: 1024 entries (Page Table Entries - PTEs), each mapping 4KB page

**Address Translation**:

A 32-bit linear address is divided into three components:

```
Linear Address (32 bits):
Bits 31-22: Page Directory Index (10 bits) - selects PDE
Bits 21-12: Page Table Index (10 bits) - selects PTE  
Bits 11-0:  Page Offset (12 bits) - offset within 4KB page
```

**Translation Process**:

1. CR3 register holds physical address of page directory
2. Extract bits 31-22 from linear address (PD index)
3. Multiply by 4 (PDE size) and add to CR3 to get PDE address
4. Read PDE, extract page table physical address
5. Extract bits 21-12 from linear address (PT index)
6. Multiply by 4 and add to page table base to get PTE address
7. Read PTE, extract physical page frame address (bits 31-12)
8. Combine page frame address with offset (bits 11-0) to get physical address

**Example**: Address translation calculation

```
Linear Address: 0x00401234

Page Directory Index: bits 31-22 = 0x001 (entry 1)
Page Table Index: bits 21-12 = 0x001 (entry 1)
Offset: bits 11-0 = 0x234

If CR3 = 0x00100000:
1. PDE address = 0x00100000 + (1 * 4) = 0x00100004
2. Read PDE at 0x00100004, suppose it contains 0x00101007
   (page table at 0x00101000, present, writable, user)
3. PTE address = 0x00101000 + (1 * 4) = 0x00101004
4. Read PTE at 0x00101004, suppose it contains 0x00200007
   (page frame at 0x00200000, present, writable, user)
5. Physical address = 0x00200000 + 0x234 = 0x00200234
```

**Page Directory Entry (PDE) Format**:

```
Bits 31-12: Page Table Base Address (physical address >> 12)
Bits 11-9:  Available for OS use
Bit 8 (G):  Global page (if CR4.PGE=1)
Bit 7 (PS): Page Size (0=4KB, 1=4MB if CR4.PSE=1)
Bit 6 (D):  Dirty (set by CPU on write)
Bit 5 (A):  Accessed (set by CPU on any access)
Bit 4 (PCD): Page-level Cache Disable
Bit 3 (PWT): Page-level Write-Through
Bit 2 (U/S): User/Supervisor (0=supervisor, 1=user)
Bit 1 (R/W): Read/Write (0=read-only, 1=writable)
Bit 0 (P):   Present (1=page table present)
```

**Page Table Entry (PTE) Format**:

```
Bits 31-12: Physical Page Frame Address (physical address >> 12)
Bits 11-9:  Available for OS use
Bit 8 (G):  Global page (not flushed on CR3 reload if CR4.PGE=1)
Bit 7 (PAT): Page Attribute Table index
Bit 6 (D):  Dirty (set by CPU on write)
Bit 5 (A):  Accessed (set by CPU on any access)
Bit 4 (PCD): Page-level Cache Disable
Bit 3 (PWT): Page-level Write-Through
Bit 2 (U/S): User/Supervisor (0=supervisor only, 1=user accessible)
Bit 1 (R/W): Read/Write (0=read-only, 1=writable)
Bit 0 (P):   Present (1=page present in memory)
```

**Example**: Creating page tables

```assembly
; Allocate and initialize page directory
setup_paging:
    ; Clear page directory (4KB = 1024 entries * 4 bytes)
    mov edi, page_directory
    mov ecx, 1024
    xor eax, eax
    rep stosd
    
    ; Create page table for first 4MB (identity mapping)
    mov edi, page_table_0
    mov eax, 0x00000007     ; Physical address 0, present+writable+user
    mov ecx, 1024
.fill_page_table:
    stosd                   ; Store PTE
    add eax, 0x1000         ; Next 4KB page
    loop .fill_page_table
    
    ; Install page table in page directory
    mov eax, page_table_0
    or eax, 0x07            ; Present + writable + user
    mov [page_directory], eax
    
    ; Load page directory into CR3
    mov eax, page_directory
    mov cr3, eax
    
    ret

; Page-aligned data structures
align 4096
page_directory:
    times 1024 dd 0

align 4096
page_table_0:
    times 1024 dd 0
```

**4MB Pages (PSE - Page Size Extension)**:

When CR4.PSE is enabled and PDE bit 7 (PS) is set, the PDE directly maps a 4MB page instead of pointing to a page table:

```
PDE with PS=1:
Bits 31-22: Physical address bits 31-22 (4MB aligned)
Bits 21-13: Reserved (must be 0)
Bits 12-0:  Same as standard PDE flags
```

Linear address format for 4MB pages:

```
Bits 31-22: Page Directory Index (10 bits)
Bits 21-0:  Page Offset (22 bits) - offset within 4MB page
```

```assembly
; Map 4MB page
create_4mb_mapping:
    ; Enable PSE
    mov eax, cr4
    or eax, 0x10            ; Set CR4.PSE (bit 4)
    mov cr4, eax
    
    ; Create 4MB page entry
    ; Map linear 0x00000000 to physical 0x00000000
    mov eax, 0x00000083     ; Physical 0, present+writable+PS bit
    mov [page_directory], eax
    
    ret
```

### PAE (Physical Address Extension) Paging

PAE extends physical addressing from 32 bits (4GB) to 36 bits (64GB) while maintaining 32-bit linear addresses. It uses a three-level page table hierarchy.

**Structure**:

- **Page Directory Pointer Table (PDPT)**: 4 entries (PDPTEs), each covering 1GB
- **Page Directory**: 512 entries (PDEs), each covering 2MB
- **Page Table**: 512 entries (PTEs), each mapping 4KB

**Entry Size**: All entries are 64 bits (8 bytes) to accommodate 36-bit physical addresses.

**Address Translation**:

Linear address format (32 bits):

```
Bits 31-30: PDPT Index (2 bits) - selects PDPTE
Bits 29-21: Page Directory Index (9 bits) - selects PDE
Bits 20-12: Page Table Index (9 bits) - selects PTE
Bits 11-0:  Page Offset (12 bits) - offset within 4KB page
```

**Enabling PAE**:

```assembly
enable_pae_paging:
    ; Load PDPT address into CR3
    mov eax, pdpt_physical_addr
    mov cr3, eax
    
    ; Enable PAE (CR4.PAE)
    mov eax, cr4
    or eax, 0x20            ; Set PAE bit (bit 5)
    mov cr4, eax
    
    ; Enable paging (CR0.PG)
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax
    
    ret
```

**PDPTE Format** (64 bits):

```
Bits 63-52: Available for OS use (when Present=0)
Bits 51-12: Page Directory Base Address (bits 35-12 of physical address)
Bits 11-9:  Available for OS use
Bits 8-5:   Reserved (must be 0)
Bit 4-1:    Reserved (must be 0)
Bit 0 (P):  Present
```

**PAE PDE and PTE Format** (64 bits):

Similar to non-PAE but extended to 64 bits:

```
Bits 63:    Execute Disable (XD/NX) - prevents instruction execution if set
Bits 62-52: Available for OS use
Bits 51-12: Physical address bits 35-12
Bits 11-0:  Same flags as non-PAE entries
```

**2MB Large Pages in PAE**:

With PS bit set in PDE, maps 2MB page directly:

```
Linear Address:
Bits 31-30: PDPT Index
Bits 29-21: Page Directory Index
Bits 20-0:  Page Offset (21 bits) - offset within 2MB
```

### Long Mode (64-bit) Paging

64-bit long mode uses 4-level or 5-level page table hierarchies to translate 48-bit or 57-bit linear addresses.

**4-Level Paging Structure**:

- **PML4 (Page Map Level 4)**: 512 entries, each covering 512GB
- **PDPT (Page Directory Pointer Table)**: 512 entries, each covering 1GB
- **Page Directory**: 512 entries, each covering 2MB
- **Page Table**: 512 entries, each mapping 4KB

**Linear Address Format** (48-bit used):

```
Bits 63-48: Sign extension (copies of bit 47)
Bits 47-39: PML4 Index (9 bits)
Bits 38-30: PDPT Index (9 bits)
Bits 29-21: PD Index (9 bits)
Bits 20-12: PT Index (9 bits)
Bits 11-0:  Page Offset (12 bits)
```

**5-Level Paging**: Adds PML5 level above PML4 for 57-bit addresses [requires CPU support, enabled via CR4.LA57].

**Example**: Setting up long mode paging

```assembly
; 64-bit paging setup (from 32-bit protected mode)
setup_long_mode_paging:
    ; Clear page tables
    mov edi, pml4_table
    mov ecx, 0x1000 / 4     ; 4KB / 4 bytes
    xor eax, eax
    rep stosd
    
    mov edi, pdpt_table
    mov ecx, 0x1000 / 4
    rep stosd
    
    mov edi, pd_table
    mov ecx, 0x1000 / 4
    rep stosd
    
    mov edi, pt_table
    mov ecx, 0x1000 / 4
    rep stosd
    
    ; PML4[0] -> PDPT
    mov eax, pdpt_table
    or eax, 0b11            ; Present + Writable
    mov [pml4_table], eax
    
    ; PDPT[0] -> PD
    mov eax, pd_table
    or eax, 0b11
    mov [pdpt_table], eax
    
    ; PD[0] -> PT
    mov eax, pt_table
    or eax, 0b11
    mov [pd_table], eax
    
    ; Identity map first 2MB
    mov edi, pt_table
    mov eax, 0x00000003     ; Physical 0, present + writable
    mov ecx, 512
.map_pages:
    stosd                   ; Low 32 bits
    xor eax, eax
    stosd                   ; High 32 bits
    add eax, 0x1000         ; Next page
    loop .map_pages
    
    ; Load PML4 into CR3
    mov eax, pml4_table
    mov cr3, eax
    
    ; Enable PAE (required for long mode)
    mov eax, cr4
    or eax, 0x20
    mov cr4, eax
    
    ; Enable long mode (EFER.LME)
    mov ecx, 0xC0000080     ; EFER MSR
    rdmsr
    or eax, 0x100           ; Set LME bit
    wrmsr
    
    ; Enable paging (activates long mode)
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax
    
    ret

align 4096
pml4_table:  times 512 dq 0
pdpt_table:  times 512 dq 0
pd_table:    times 512 dq 0
pt_table:    times 512 dq 0
```

**Large and Huge Pages in Long Mode**:

- **2MB pages**: Set PS bit in PDE
- **1GB pages**: Set PS bit in PDPTE (requires CPU support)

**Page Table Entry Attributes in Long Mode**:

```
Bit 63 (XD/NX): Execute Disable
Bits 62-52: Available
Bits 51-12: Physical address
Bit 11-9: Available
Bit 8 (G): Global
Bit 7 (PS): Page Size (for PDE/PDPTE)
Bit 6 (D): Dirty
Bit 5 (A): Accessed
Bit 4 (PCD): Cache Disable
Bit 3 (PWT): Write-Through
Bit 2 (U/S): User/Supervisor
Bit 1 (R/W): Read/Write
Bit 0 (P): Present
```

**Key Points**:

- All page table structures must be 4KB aligned (bits 11-0 of address must be zero)
- Entries are always traversed from highest level to lowest
- Each level of table contains indices extracted from the linear address
- Present bit (bit 0) must be set in all traversed entries for successful translation
- Operating systems use available bits (AVL) for their own purposes like tracking swapped pages
- Page tables themselves occupy physical memory and must be managed by the OS
- Recursive page table mapping technique allows OS to modify page tables using virtual addresses [commonly used in OS kernels]
- Page table hierarchy can be partially populated; entire address space doesn't need all page tables allocated
- Page faults occur when Present bit is 0 in any level during traversal

