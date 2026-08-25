## Large Pages and Huge Pages


Large and huge pages reduce TLB pressure and page table memory overhead by using larger page sizes.

### Page Size Support

**Standard Page Sizes by Mode:**

**32-bit Paging:**

- 4 KB (standard)
- 4 MB (large pages with PSE)

**PAE Paging:**

- 4 KB (standard)
- 2 MB (large pages)

**Long Mode (x86-64):**

- 4 KB (standard)
- 2 MB (large pages)
- 1 GB (huge pages with PDPE1GB)

### 4 MB Large Pages (32-bit, PSE)

**Enabling PSE (Page Size Extension):**

```nasm
mov eax, cr4
or eax, 0x10                ; Set PSE bit (bit 4)
mov cr4, eax
```

**4 MB Page Directory Entry:**

```
31                           12 11  9 8 7 6 5 4 3 2 1 0
+------------------------------+-----+-+-+-+-+-+-+-+-+-+
| Page Frame Address (22 bits) |Avail|G|1|D|A|C|W|U|R|P|
| (bits 31-22, maps to         |     | | | | |D|T|/|/|/|
|  bits 31-22 of phys addr)    |     | | | | | | |S|W|P|
+------------------------------+-----+-+-+-+-+-+-+-+-+-+
```

**Note:** PS bit (bit 7) must be 1 to indicate 4 MB page.

**Virtual Address with 4 MB Page:**

```
31                 22 21                                    0
+--------------------+---------------------------------------+
| Directory Index    | Page Offset (22 bits = 4 MB)         |
| (10 bits)          |                                       |
+--------------------+---------------------------------------+
```

**4 MB Page Mapping Example:**

```nasm
page_directory:
    ; Identity map first 4 MB with single large page
    dd 0x00000000 + 0x083       ; Base=0, Present, R/W, PS=1
    
    ; Map another 4 MB at virtual 4MB -> physical 4MB
    dd 0x00400000 + 0x083       ; Base=4MB, Present, R/W, PS=1
    
    times 1022 dd 0             ; Rest of directory
```

### 2 MB Large Pages (PAE and Long Mode)

**2 MB Page Directory Entry (PAE):**

```
63    52 51      36 35     21 20    12 11   9 8 7 6 5 4 3 2 1 0
+--------+-----------+--------+--------+------+-+-+-+-+-+-+-+-+-+
|Reserved| Page Base | Page   |Reserved|Avail |G|1|D|A|C|W|U|R|P|
|  (0)   |(bits 51-36)|Base    |  (0)   |      | | | | |D|T|/|/|/|
|        |           |(35-21) |        |      | | | | | | |S|W|P|
+--------+-----------+--------+--------+------+-+-+-+-+-+-+-+-+-+
```

**2 MB Page Directory Entry (Long Mode):**

```
63    52 51         21 20    12 11   9 8 7 6 5 4 3 2 1 0
+--------+-------------+--------+------+-+-+-+-+-+-+-+-+-+
|Reserved| Page Base   |Reserved|Avail |G|1|D|A|C|W|U|R|P|
|  (0)   | (bits 51-21)|  (0)   |      | | | | |D|T|/|/|/|
|        |             |        |      | | | | | | |S|W|P|
+--------+-------------+--------+------+-+-+-+-+-+-+-+-+-+
```

**Note:** PS bit (bit 7) must be 1.

**Virtual Address with 2 MB Page:**

```
47        39 38        30 29        21 20                     0
+------------+------------+------------+------------------------+
| PML4 Index | PDPT Index | PD Index   | Page Offset (21 bits) |
| (9 bits)   | (9 bits)   | (9 bits)   | (2 MB)                |
+------------+------------+------------+------------------------+
```

**2 MB Page Mapping Example:**

```nasm
align 4096
pd_table:
    ; Identity map first 1 GB using 512 × 2 MB pages
    %assign i 0
    %rep 512
        dq (i * 0x200000) + 0x083   ; 2MB aligned address + Present + R/W + PS
        %assign i i+1
    %endrep
```

### 1 GB Huge Pages (Long Mode)

**Checking for 1 GB Page Support:**

```nasm
; Check CPUID for PDPE1GB support
mov eax, 0x80000001
cpuid
test edx, (1 << 26)         ; Check bit 26
jz no_1gb_pages
```

**1 GB PDPT Entry:**

```
63    52 51         30 29    12 11   9 8 7 6 5 4 3 2 1 0
+--------+-------------+--------+------+-+-+-+-+-+-+-+-+-+
|Reserved| Page Base   |Reserved|Avail |G|1|D|A|C|W|U|R|P|
|  (0)   | (bits 51-30)|  (0)   |      | | | | |D|T|/|/|/|
|        |             |        |      | | | | | | |S|W|P|
+--------+-------------+--------+------+-+-+-+-+-+-+-+-+-+
```

**Note:** PS bit (bit 7) must be 1.

**Virtual Address with 1 GB Page:**

```
47        39 38        30 29                               0
+------------+------------+----------------------------------+
| PML4 Index | PDPT Index | Page Offset (30 bits = 1 GB)    |
| (9 bits)   | (9 bits)   |                                  |
+------------+------------+----------------------------------+
```

**1 GB Page Mapping Example:**

```nasm
align 4096
pdpt_table:
    ; Identity map first 512 GB using 512 × 1 GB pages
    %assign i 0
    %rep 512
        dq (i * 0x40000000) + 0x083 ; 1GB aligned + Present + R/W + PS
        %assign i i+1
    %endrep
```

### Large Page Benefits and Considerations

**Benefits:**

- **Reduced TLB misses**: Single TLB entry covers more memory
- **Fewer page table levels**: 2 MB pages skip PT level, 1 GB pages skip PT and PD levels
- **Lower memory overhead**: Fewer page table structures needed
- **Better performance**: [Inference] Reduced address translation overhead for workloads with large contiguous memory access patterns

**Considerations:**

- **Memory waste**: [Inference] Internal fragmentation if not fully utilized
- **Alignment requirements**: Physical memory must be aligned to page size boundary
- **Limited flexibility**: Cannot have different permissions within the large page
- **Allocation challenges**: [Inference] Finding contiguous physical memory becomes harder

**Mixed Page Size Example:**

```nasm
pd_table:
    ; First entry: 2 MB large page
    dq 0x00000000 + 0x083       ; 2 MB page, Present, R/W, PS=1
    
    ; Second entry: Standard 4 KB pages through PT
    dq pt_table + 0x003         ; Point to page table, Present, R/W, PS=0
    
    ; Rest: 2 MB pages
    %assign i 2
    %rep 510
        dq (i * 0x200000) + 0x083
        %assign i i+1
    %endrep
```

### Page Attribute Table (PAT)

PAT allows finer control over caching attributes for pages. It works with PCD, PWT, and PAT bits in page table entries.

**PAT MSR (IA32_PAT, MSR 0x277):**

```nasm
; Read PAT MSR
mov ecx, 0x277
rdmsr                       ; PAT in EDX:EAX

; Write PAT MSR (set PA0=WB, PA1=WT, PA2=UC, PA3=UC)
mov ecx, 0x277
mov eax, 0x00070106         ; Low 32 bits
mov edx, 0x00000000         ; High 32 bits (typically 0)
wrmsr
```

**PAT Entry Types:**

- 0x00 = UC (Uncacheable)
- 0x01 = WC (Write Combining)
- 0x04 = WT (Write Through)
- 0x05 = WP (Write Protected)
- 0x06 = WB (Write Back)

**Using PAT with Page Table Entries:**

```
PTE bits: PAT (bit 7), PCD (bit 4), PWT (bit 3)
These 3 bits form index into PAT MSR (0-7)
```

```nasm
; Create page with Write Combining (assuming PA1 = WC)
; PAT=0, PCD=0, PWT=1 = index 1
dq framebuffer_addr + 0x00B ; Present, R/W, PWT=1 (index 1 = WC)
```

