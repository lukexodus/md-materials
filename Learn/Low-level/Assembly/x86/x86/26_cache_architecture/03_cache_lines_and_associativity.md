## Cache Lines and Associativity


Caches are organized into fixed-size blocks called cache lines, with associativity determining how flexibly memory addresses map to cache locations.

### Cache Line Fundamentals

**Cache Line Size**: Modern x86 processors use 64-byte cache lines. This is the minimum unit of cache storage and transfer.

```assembly
; Cache line structure (64 bytes)
; Byte 0-63: Data
; Plus metadata: tag bits, valid bit, dirty bit, coherency state

; Example: Loading a single byte loads entire 64-byte line
cache_line_load:
    mov al, [data_array]        ; Loads bytes 0-63 into cache
    mov bl, [data_array + 1]    ; Cache hit (same line)
    mov cl, [data_array + 32]   ; Cache hit (same line)
    mov dl, [data_array + 63]   ; Cache hit (same line)
    mov dh, [data_array + 64]   ; New cache line, possible miss
    ret
```

**Why 64 Bytes**: This size balances:

- Spatial locality exploitation (larger lines capture more nearby data)
- Memory bandwidth efficiency (fewer transfers needed)
- Cache pollution (smaller lines waste less space on unused data)
- Bus width constraints

**Cache Line Alignment**: Data structures should be aligned to cache line boundaries for optimal performance.

```assembly
; Unaligned structure spans two cache lines
align 1
unaligned_struct:
    db 60 dup(0)            ; 60 bytes
    dd 0                    ; 4 bytes - SPLITS across cache line boundary
    
; Accessing the dword requires loading 2 cache lines

; Aligned structure stays within one cache line
align 64                    ; Force cache line alignment
aligned_struct:
    db 60 dup(0)
    dd 0                    ; Stays within single cache line

; Accessing aligned structure requires only 1 cache line
```

**False Sharing**: Multiple threads accessing different variables in the same cache line causes performance degradation.

```assembly
; False sharing example
section .data
align 64
thread_data:
    counter1: dd 0          ; Thread 1 updates this
    counter2: dd 0          ; Thread 2 updates this (SAME CACHE LINE!)
    ; Problem: Both in same 64-byte line causes constant invalidations

; Thread 1
thread1_update:
.loop:
    lock inc dword [counter1]   ; Invalidates entire cache line
    ; Forces thread 2 to reload cache line
    jmp .loop

; Thread 2  
thread2_update:
.loop:
    lock inc dword [counter2]   ; Invalidates entire cache line
    ; Forces thread 1 to reload cache line
    jmp .loop

; Both threads constantly invalidate each other's cache line
; Despite working on "independent" variables
```

**Fixing False Sharing**:

```assembly
; Separate cache lines with padding
section .data
align 64
thread1_data:
    counter1: dd 0
    times 60 db 0           ; Padding to fill cache line

align 64
thread2_data:
    counter2: dd 0
    times 60 db 0           ; Separate cache line

; Now threads have independent cache lines
; No false sharing, much better performance
```

### Cache Associativity

Associativity determines how flexibly a memory address can be placed in the cache.

**Direct-Mapped Cache** (1-way associative):

Each memory address maps to exactly one cache line location.

```
Memory Address: [Tag | Index | Offset]
- Offset: Byte within cache line (6 bits for 64-byte lines)
- Index: Which cache set (determines cache line)
- Tag: Stored in cache to verify correct data

Address 0x0000 maps to set 0
Address 0x0040 maps to set 1
Address 0x0080 maps to set 2
...
Address 0x1000 maps to set 0 (CONFLICT with 0x0000)
```

**Conflict Misses with Direct-Mapped**:

```assembly
; Direct-mapped cache with 64 sets (4 KB cache)
; Addresses 0x0000 and 0x1000 map to same set

direct_mapped_conflict:
    mov eax, [0x0000]       ; Load into set 0
    mov ebx, [0x1000]       ; Evicts previous line, loads into set 0
    mov ecx, [0x0000]       ; Cache miss! Evicts 0x1000, reloads 0x0000
    mov edx, [0x1000]       ; Cache miss! Evicts 0x0000, reloads 0x1000
    ret
; Constant thrashing despite cache having room
```

**Set-Associative Cache** (N-way associative):

Each memory address can be placed in N different cache line locations within a set.

```
4-way set-associative cache:
- Each set has 4 cache lines
- Address can map to any of the 4 lines in its set
- Reduces conflict misses dramatically

Set 0: [Line A] [Line B] [Line C] [Line D]
Set 1: [Line A] [Line B] [Line C] [Line D]
...
```

**Set-Associative Example**:

```assembly
; 4-way set-associative, 32 KB L1 cache
; 512 sets × 4 ways × 64 bytes = 32 KB

set_assoc_example:
    mov eax, [0x0000]       ; Maps to set 0, way 0
    mov ebx, [0x2000]       ; Maps to set 0, way 1
    mov ecx, [0x4000]       ; Maps to set 0, way 2
    mov edx, [0x6000]       ; Maps to set 0, way 3
    ; All 4 addresses fit simultaneously in set 0
    
    mov esi, [0x0000]       ; Cache hit! (way 0)
    mov edi, [0x2000]       ; Cache hit! (way 1)
    ret
; No conflict misses - all fit in different ways
```

**Fully-Associative Cache**:

Any memory address can map to any cache line. No conflict misses possible, but expensive to implement (requires comparing tag with all cache lines).

```
Fully associative:
- Entire cache is one set with all lines
- Maximum flexibility
- Expensive hardware (parallel tag comparison)
- Used only for small caches (TLB, etc.)
```

**Typical Associativities**:

- L1 Data: 8-way set associative
- L1 Instruction: 8-way set associative
- L2: 8-16 way set associative
- L3: 12-16 way set associative

**Replacement Policies**:

When all ways in a set are full, a replacement policy determines which line to evict:

**Least Recently Used (LRU)**:

- Evict the line accessed longest ago
- Good performance, moderate hardware cost
- Most common in modern x86 processors

**Pseudo-LRU**: Approximation of LRU with less hardware **Random**: Evict random line - simple but less effective **FIFO**: Evict oldest line - simple but can evict hot data

```assembly
; Demonstrating LRU replacement
lru_example:
    ; Assume 4-way set-associative cache, set 0
    mov eax, [addr_a]       ; Way 0, LRU order: [A, -, -, -]
    mov ebx, [addr_b]       ; Way 1, LRU order: [B, A, -, -]
    mov ecx, [addr_c]       ; Way 2, LRU order: [C, B, A, -]
    mov edx, [addr_d]       ; Way 3, LRU order: [D, C, B, A]
    
    mov eax, [addr_a]       ; Hit way 0, LRU order: [A, D, C, B]
    ; A moves to most recently used position
    
    mov esi, [addr_e]       ; Miss! Evicts B (least recently used)
                            ; LRU order: [E, A, D, C]
    ret
```

**Cache Coloring**: Operating systems can use page coloring to reduce cache conflicts.

```assembly
; Without cache coloring
; Two arrays allocated contiguously might conflict
array1: times 8192 dd 0     ; 32 KB
array2: times 8192 dd 0     ; 32 KB
; If accessed together, may cause conflicts

; With cache coloring
; OS allocates arrays to different cache colors (sets)
; array1 uses even sets, array2 uses odd sets
; Reduces conflicts when both accessed
```

**Measuring Cache Associativity**:

```assembly
; Benchmark to detect associativity
measure_associativity:
    ; Create array with stride = cache size / N
    ; Increase N until performance degrades
    ; Degradation point reveals associativity
    
    mov ecx, 8              ; Test 8-way
    mov eax, 32768          ; L1 cache size
    xor edx, edx
    div ecx                 ; stride = 4096
    
    ; Access N addresses all mapping to same set
    mov ebx, 0
.loop:
    mov esi, [array + ebx]
    add ebx, eax            ; Jump by stride
    cmp ebx, stride * 8
    jl .loop
    
    ; If performance drops, associativity < 8
    ret
```

**Key Points**:

- Cache line is 64 bytes on modern x86 processors
- All cache operations work on entire cache lines, not individual bytes
- Alignment to cache line boundaries improves performance
- False sharing occurs when threads write different variables in the same cache line
- Associativity determines placement flexibility in cache
- Higher associativity reduces conflict misses but increases hardware cost
- LRU is the most common replacement policy
- Set-associative caches balance performance and cost
- Cache conflicts can devastate performance despite sufficient cache capacity
- Understanding address mapping to cache sets helps avoid conflict patterns

