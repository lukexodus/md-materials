## Segmentation vs Paging


Both segmentation and paging are memory management techniques, but they serve different purposes and operate differently.

### Segmentation

Segmentation divides memory into logical units called segments, each representing a distinct region with specific attributes. Segments correspond to logical program components like code, data, and stack.

**Segment Structure**:

Each segment is defined by a segment descriptor stored in either the Global Descriptor Table (GDT) or Local Descriptor Table (LDT). A segment descriptor (8 bytes) contains:

- **Base Address** (32 bits): Starting linear address of the segment
- **Limit** (20 bits): Size of the segment (in bytes or 4KB pages)
- **Type** (4 bits): Segment type (code, data, stack) and access rights (read, write, execute)
- **Descriptor Privilege Level (DPL)** (2 bits): Privilege level required to access segment (0-3)
- **Present Bit (P)**: Whether segment is present in memory
- **Granularity (G)**: If 0, limit in bytes; if 1, limit in 4KB pages
- **Default Operation Size (D/B)**: 16-bit vs 32-bit operations
- **Long Mode (L)**: 64-bit code segment indicator

**Segment Selector**:

Programs reference segments using 16-bit segment selectors loaded into segment registers (CS, DS, SS, ES, FS, GS):

```
Bits 15-3: Index into GDT or LDT (8192 possible descriptors)
Bit 2 (TI): Table Indicator (0 = GDT, 1 = LDT)
Bits 1-0 (RPL): Requested Privilege Level
```

**Example**: Setting up a segment descriptor

```assembly
; GDT entry structure
struc GDT_ENTRY
    .limit_low:     resw 1      ; Limit bits 0-15
    .base_low:      resw 1      ; Base bits 0-15
    .base_mid:      resb 1      ; Base bits 16-23
    .access:        resb 1      ; Access byte
    .granularity:   resb 1      ; Flags and limit bits 16-19
    .base_high:     resb 1      ; Base bits 24-31
endstruc

; Access byte format:
; Bit 7: Present (1 = valid descriptor)
; Bits 6-5: DPL (privilege level 0-3)
; Bit 4: Descriptor type (0 = system, 1 = code/data)
; Bit 3: Executable (1 = code, 0 = data)
; Bit 2: Direction/Conforming
; Bit 1: Read/Write permission
; Bit 0: Accessed (set by CPU)

; Create a flat code segment (base=0, limit=4GB)
setup_code_segment:
    mov edi, gdt_start + 8      ; Skip null descriptor
    
    ; Limit = 0xFFFFF (4GB with granularity)
    mov word [edi + GDT_ENTRY.limit_low], 0xFFFF
    
    ; Base = 0x00000000
    mov word [edi + GDT_ENTRY.base_low], 0
    mov byte [edi + GDT_ENTRY.base_mid], 0
    mov byte [edi + GDT_ENTRY.base_high], 0
    
    ; Access: Present=1, DPL=0, Code=1, Readable=1
    ; 10011010b = 0x9A
    mov byte [edi + GDT_ENTRY.access], 0x9A
    
    ; Granularity: 4KB pages, 32-bit, limit high=0xF
    ; 11001111b = 0xCF
    mov byte [edi + GDT_ENTRY.granularity], 0xCF
    
    ret

; Load segment selector
load_code_segment:
    ; Selector: index=1 (8 bytes offset), TI=0 (GDT), RPL=0
    ; 0x08 = 0000000000001000b
    mov ax, 0x08
    mov cs, ax              ; Cannot directly mov to CS
    ; Must use far jump instead:
    jmp 0x08:.set_cs
.set_cs:
    ret
```

**Segmentation Translation**:

When accessing memory with a segment:offset address:

1. Processor extracts segment selector from segment register
2. Loads segment descriptor from GDT/LDT using selector index
3. Verifies access permissions and segment presence
4. Adds segment base to offset to produce linear address
5. Checks that offset doesn't exceed segment limit

```assembly
; Example memory access with segmentation
mov ax, 0x10            ; Data segment selector
mov ds, ax              ; Load into DS
mov eax, [0x1000]       ; Access DS:0x1000

; Hardware performs:
; 1. Load descriptor for selector 0x10 from GDT
; 2. Extract base address from descriptor (e.g., 0x00100000)
; 3. Add offset: 0x00100000 + 0x1000 = 0x00101000 (linear address)
; 4. Verify 0x1000 < segment limit
```

**Flat Memory Model**:

Modern operating systems typically use a "flat" memory model where all segments have base=0 and limit=4GB, effectively disabling segmentation's memory isolation features. This simplifies programming and relies on paging for memory protection.

```assembly
; Typical flat model GDT
gdt_start:
    ; Null descriptor (required)
    dq 0
    
    ; Code segment: base=0, limit=4GB, ring 0, executable
    dw 0xFFFF           ; Limit low
    dw 0x0000           ; Base low
    db 0x00             ; Base mid
    db 0x9A             ; Access: present, ring 0, code, readable
    db 0xCF             ; Flags: 4KB granularity, 32-bit, limit high
    db 0x00             ; Base high
    
    ; Data segment: base=0, limit=4GB, ring 0, writable
    dw 0xFFFF           ; Limit low
    dw 0x0000           ; Base low
    db 0x00             ; Base mid
    db 0x92             ; Access: present, ring 0, data, writable
    db 0xCF             ; Flags: 4KB granularity, 32-bit, limit high
    db 0x00             ; Base high
```

### Paging

Paging divides both linear and physical memory into fixed-size blocks called pages (typically 4KB). Virtual memory addresses are translated to physical addresses through page tables.

**Paging Advantages Over Segmentation**:

- **Fixed-Size Blocks**: Eliminates external fragmentation that occurs with variable-sized segments
- **Transparent to Programs**: Applications don't need to manage segments
- **Efficient Memory Allocation**: Operating system can allocate physical memory in page-sized units
- **Demand Paging**: Pages can be loaded from disk only when accessed
- **Memory Protection**: Fine-grained per-page access control
- **Shared Memory**: Multiple processes can map same physical pages
- **Memory Overcommitment**: Linear address space can exceed physical RAM

**Page Sizes**:

x86 supports multiple page sizes:

- **4KB pages**: Standard page size, maximum flexibility
- **4MB pages (PSE)**: Large pages in 32-bit mode, reduces TLB misses
- **2MB pages (PAE/Long Mode)**: Large pages in PAE and 64-bit mode
- **1GB pages (Long Mode)**: Huge pages in 64-bit mode with PDPE1GB feature

**Enabling Paging**:

```assembly
; Enable paging in 32-bit protected mode
enable_paging:
    ; Load page directory base into CR3
    mov eax, page_directory_physical_addr
    mov cr3, eax
    
    ; Enable paging by setting CR0.PG (bit 31)
    mov eax, cr0
    or eax, 0x80000000      ; Set PG bit
    mov cr0, eax
    
    ; Paging now active
    ret
```

**Paging and Segmentation Interaction**:

In protected mode and long mode, both segmentation and paging can be active simultaneously. The translation proceeds in two stages:

1. **Segmentation**: Logical address → Linear address
2. **Paging**: Linear address → Physical address

In 64-bit long mode, segmentation is largely disabled (segment bases forced to 0 for most segments), making linear addresses equal to logical addresses in practice. Only FS and GS segment bases remain usable for special purposes like thread-local storage.

**Key Differences**:

|Aspect|Segmentation|Paging|
|---|---|---|
|Unit Size|Variable (1 byte to 4GB)|Fixed (4KB, 2MB, 4MB, 1GB)|
|Programmer Visibility|Visible (segment registers)|Transparent|
|Memory Allocation|Logical divisions|Physical page frames|
|Fragmentation|External fragmentation possible|Internal fragmentation only|
|Modern Usage|Minimal (flat model)|Primary mechanism|
|Protection Granularity|Per segment|Per page|
|Sharing|Entire segments|Individual pages|

**Real-World Usage**:

Modern operating systems (Windows, Linux, macOS) use paging as the primary memory management mechanism with a flat segmentation model. Segmentation remains mandatory due to x86 architecture requirements but provides minimal functionality in contemporary systems. 64-bit long mode further reduces segmentation's role, making paging virtually the sole memory management mechanism.

