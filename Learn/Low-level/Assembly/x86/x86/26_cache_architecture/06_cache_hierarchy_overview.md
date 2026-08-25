## Cache Hierarchy Overview


### Typical Cache Organization

**Modern x86 Cache Hierarchy:**

```
CPU Core
  ├─ L1 Instruction Cache (32-64 KB, ~4 cycle latency)
  ├─ L1 Data Cache (32-64 KB, ~4 cycle latency)
  ├─ L2 Unified Cache (256-512 KB, ~12 cycle latency)
  └─ L3 Unified Cache (shared, 8-32+ MB, ~40 cycle latency)
       └─ Main Memory (GB scale, ~200+ cycle latency)
```

**Cache Line Characteristics:**

- **Cache line size**: Typically 64 bytes on modern x86
- **Alignment**: Cache lines are 64-byte aligned
- **Associativity**: N-way set associative (commonly 8-way or 16-way)
- **Write policy**: Usually write-back with write-allocate

### Cache Line States (MESI Protocol)

```nasm
; MESI states affect performance based on cache coherency operations
; M (Modified): 00 - Dirty, exclusive to this cache
; E (Exclusive): 01 - Clean, exclusive to this cache
; S (Shared):    10 - Clean, may exist in other caches
; I (Invalid):   11 - Not present or invalid
```

### Cache Organization

**Set-Associative Cache Structure:**

```
Virtual/Physical Address:
+------------------+------------------+------------------+
|       Tag        |      Index       |     Offset       |
+------------------+------------------+------------------+
      (varies)        (log2(sets))        (6 bits)

Example for 32 KB, 8-way set-associative, 64-byte line:
- 64 sets = 32768 / (8 ways × 64 bytes)
- Index: 6 bits (log2(64))
- Offset: 6 bits (log2(64))
- Tag: remaining bits
```

**Detecting Cache Parameters:**

```nasm
; CPUID provides cache information
detect_cache_info:
    ; Intel: Use CPUID leaf 0x04
    mov eax, 0x04
    mov ecx, 0                  ; Cache level index (0, 1, 2...)
    cpuid
    
    ; EAX bits 4-0: Cache type
    ;   0 = null, 1 = data, 2 = instruction, 3 = unified
    ; EAX bits 7-5: Cache level (1, 2, 3)
    ; EAX bits 25-14: Maximum cores sharing this cache
    ; EBX bits 11-0: Line size - 1
    ; EBX bits 21-12: Partitions - 1
    ; EBX bits 31-22: Associativity - 1
    ; ECX: Number of sets - 1
    
    ; Calculate cache size
    mov esi, ebx
    and esi, 0xFFF
    inc esi                     ; Line size
    
    mov edi, ebx
    shr edi, 12
    and edi, 0x3FF
    inc edi                     ; Partitions
    
    mov edx, ebx
    shr edx, 22
    inc edx                     ; Ways (associativity)
    
    inc ecx                     ; Sets
    
    ; Cache size = line_size × ways × sets × partitions
    imul esi, edi
    imul esi, edx
    imul esi, ecx
    ; ESI = cache size in bytes
    
    ret

; AMD: Use CPUID leaf 0x80000005 (L1) and 0x80000006 (L2/L3)
detect_amd_cache:
    mov eax, 0x80000005
    cpuid
    ; ECX: L1 data cache info
    ; EDX: L1 instruction cache info
    
    mov eax, 0x80000006
    cpuid
    ; ECX: L2 cache info
    ; EDX: L3 cache info
    
    ret
```

### Cache Line Addressing

```nasm
; Calculate which cache set an address maps to
get_cache_set:
    ; Input: EAX = address
    ; Assume: 64-byte lines, 64 sets (6-bit index)
    
    shr eax, 6                  ; Remove offset (6 bits)
    and eax, 0x3F               ; Mask to get 6-bit index
    ; EAX = cache set index (0-63)
    
    ret

; Check if two addresses are on same cache line
same_cache_line:
    ; Input: EAX = address1, EBX = address2
    ; Output: ZF set if same line
    
    shr eax, 6
    shr ebx, 6
    cmp eax, ebx
    ret

; Align address to cache line boundary
align_to_cache_line:
    ; Input: EAX = address
    ; Output: EAX = aligned address
    
    and eax, ~0x3F              ; Clear lower 6 bits
    ret
```

