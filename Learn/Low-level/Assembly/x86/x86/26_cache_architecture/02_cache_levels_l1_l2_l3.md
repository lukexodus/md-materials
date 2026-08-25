## Cache Levels (L1, L2, L3)


Modern x86 processors implement three levels of cache, each with different characteristics optimized for specific access patterns.

### L1 Cache (Level 1)

L1 cache is the smallest, fastest cache closest to the CPU execution units. Modern processors split L1 into separate instruction and data caches.

**L1 Characteristics**:

- **Size**: 32-64 KB per cache (separate I-cache and D-cache)
- **Latency**: 4-5 cycles
- **Bandwidth**: Very high (multiple accesses per cycle)
- **Associativity**: 8-way set associative (typical)
- **Line Size**: 64 bytes
- **Organization**: Split into instruction cache (L1-I) and data cache (L1-D)

**L1 Split Cache Design**:

```
L1 Instruction Cache (L1-I):
- Stores decoded instructions (micro-ops on modern x86)
- Read-only from CPU perspective
- Optimized for sequential access (instruction fetch)
- Typical size: 32 KB

L1 Data Cache (L1-D):
- Stores program data
- Read/write operations
- Optimized for random access patterns
- Typical size: 32-48 KB
```

**Why Split L1**: Separate caches allow simultaneous instruction fetch and data access without contention. This is critical for superscalar execution where multiple operations occur per cycle.

```assembly
; Demonstrating L1-I vs L1-D usage
cache_split_example:
    ; Instruction fetch uses L1-I
    mov eax, [esi]          ; Fetch this instruction from L1-I
                            ; Data access [esi] uses L1-D
    add eax, ebx            ; Fetch from L1-I, operands from registers
    mov [edi], eax          ; Fetch from L1-I, data write to L1-D
    ret
; CPU can fetch instructions while simultaneously accessing data
```

**L1 Cache Performance**:

```assembly
; L1-friendly access pattern
l1_friendly:
    xor eax, eax
    mov ecx, 8              ; Process 8 integers = 32 bytes
.loop:
    add eax, [esi]          ; Sequential access, stays in L1
    add esi, 4
    dec ecx
    jnz .loop
    ret
; All accesses likely hit L1 if data fits

; L1-unfriendly pattern (cache thrashing)
l1_unfriendly:
    xor eax, eax
    mov ecx, 10000
.loop:
    add eax, [large_array + ecx*4]  ; Random access, exceeds L1 size
    dec ecx
    jnz .loop
    ret
; Constant L1 misses, falls through to L2/L3
```

### L2 Cache (Level 2)

L2 cache is larger but slower than L1, serving as a victim cache for L1 evictions.

**L2 Characteristics**:

- **Size**: 256-512 KB per core
- **Latency**: 12-15 cycles
- **Bandwidth**: Lower than L1 but still high
- **Associativity**: 8-16 way set associative
- **Line Size**: 64 bytes
- **Organization**: Unified (both instructions and data)
- **Inclusivity**: May be inclusive or exclusive of L1 (architecture dependent)

**L2 Purpose**: Captures data evicted from L1, reducing pressure on L3 and main memory. Acts as a filter between the very fast L1 and slower outer memory hierarchy.

**Inclusive vs Exclusive L2**:

**Inclusive L2** (Intel typical): L2 contains everything in L1

- Advantage: Simpler coherency (only need to snoop L2)
- Disadvantage: Effective L2 size reduced by L1 contents

**Exclusive L2** (AMD typical): L2 contains only data evicted from L1

- Advantage: Maximum effective cache capacity (L1 + L2)
- Disadvantage: More complex coherency protocol

```assembly
; Working set fits in L2 but not L1
l2_bound_loop:
    xor eax, eax
    xor ecx, ecx
    mov edx, 100            ; 100 KB working set
.loop:
    add eax, [data + ecx]   ; Exceeds L1 (32 KB) but fits L2 (256 KB)
    add ecx, 64             ; Jump by cache line
    cmp ecx, edx
    jl .loop
    ret
; L1 misses but L2 hits - ~12 cycle latency per access
```

### L3 Cache (Level 3)

L3 cache is the largest, slowest on-chip cache, shared across all cores in a processor.

**L3 Characteristics**:

- **Size**: 8-32 MB (entire chip)
- **Latency**: 40-50 cycles
- **Bandwidth**: Moderate
- **Associativity**: 12-16 way set associative
- **Line Size**: 64 bytes
- **Organization**: Shared across all cores
- **Inclusivity**: Typically inclusive of L1/L2

**L3 as Shared Resource**: L3 acts as a communication medium between cores, reducing the need for memory access when cores share data.

```assembly
; Thread 1 writes data
thread1_writer:
    mov [shared_data], eax      ; Writes to cache, eventually L3
    ret

; Thread 2 reads data (on different core)
thread2_reader:
    mov ebx, [shared_data]      ; Cache miss in L1/L2, hits in L3
    ret
; L3 hit avoids expensive main memory access
```

**L3 Cache Slicing**: Modern processors partition L3 into slices, with each slice associated with specific cores for better locality.

```
Example: 8-core processor with 16 MB L3
- 8 slices of 2 MB each
- Each core has local slice with lower latency
- Can access other slices at higher latency
- Address bits determine which slice contains data
```

**NUMA Considerations**: Multi-socket systems have separate L3 caches per socket. Accessing data in another socket's L3 incurs additional latency:

```
Local L3 hit:     ~40 cycles
Remote L3 hit:    ~100 cycles (cross-socket)
Main memory:      ~200 cycles
```

```assembly
; NUMA-aware data placement (conceptual)
; Bind thread to CPU socket where data resides
numa_aware_access:
    ; Data allocated on same NUMA node as thread
    mov eax, [local_data]       ; Fast L3 access (~40 cycles)
    ret

numa_unaware_access:
    ; Data on different NUMA node
    mov eax, [remote_data]      ; Slow remote L3 (~100 cycles)
    ret
```

**Cache Hierarchy Performance Impact**:

```assembly
; Benchmark showing cache level impact
benchmark_cache_levels:
    rdtsc                       ; Read timestamp counter
    mov r8, rax
    
    ; Test 1: Fits in L1 (8 KB)
    mov ecx, 2000               ; 2000 iterations
.l1_test:
    mov eax, [l1_data]
    dec ecx
    jnz .l1_test
    
    rdtsc
    sub rax, r8                 ; ~8000 cycles (4 cycles × 2000)
    mov [l1_time], rax
    
    ; Test 2: Fits in L2 (128 KB), exceeds L1
    rdtsc
    mov r8, rax
    mov ecx, 2000
.l2_test:
    mov eax, [l2_data]
    dec ecx
    jnz .l2_test
    
    rdtsc
    sub rax, r8                 ; ~24000 cycles (12 cycles × 2000)
    mov [l2_time], rax
    
    ; Test 3: Fits in L3 (4 MB), exceeds L1/L2
    rdtsc
    mov r8, rax
    mov ecx, 2000
.l3_test:
    mov eax, [l3_data]
    dec ecx
    jnz .l3_test
    
    rdtsc
    sub rax, r8                 ; ~80000 cycles (40 cycles × 2000)
    mov [l3_time], rax
    
    ; Test 4: Exceeds all caches (100 MB)
    rdtsc
    mov r8, rax
    mov ecx, 2000
.mem_test:
    mov eax, [mem_data]
    dec ecx
    jnz .mem_test
    
    rdtsc
    sub rax, r8                 ; ~400000 cycles (200 cycles × 2000)
    mov [mem_time], rax
    
    ret
; Results show exponential increase in access time
```

**Key Points**:

- L1 is split into instruction and data caches for parallelism
- Each cache level is progressively larger but slower
- L1/L2 are typically per-core, L3 is shared across cores
- Cache hierarchy exploits temporal and spatial locality
- Working set size determines which cache level dominates performance
- Modern processors can have L1 hit rate >95% for well-optimized code
- Cache miss penalty grows dramatically at each level (L1: 4 cycles, L2: 12, L3: 40, Memory: 200)
- L3 cache facilitates inter-core communication
- NUMA systems have multiple memory hierarchies with cross-node penalties

