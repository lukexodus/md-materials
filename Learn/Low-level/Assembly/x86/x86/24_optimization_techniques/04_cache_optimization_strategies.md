## Cache Optimization Strategies


Cache performance is critical for modern processors. Memory access can be 100-300x slower than L1 cache access, making cache optimization essential.

### Cache Hierarchy

Modern x86 processors have multiple cache levels:

**Typical Cache Structure:**

- **L1 Cache**: 32-64 KB per core, ~4 cycles latency, split instruction/data
- **L2 Cache**: 256 KB - 1 MB per core, ~12 cycles latency, unified
- **L3 Cache**: 2-32 MB shared, ~40 cycles latency, unified
- **Main Memory**: GB-TB capacity, ~200 cycles latency

**Cache Line Size**: 64 bytes on modern x86 processors

### Spatial Locality

Accessing nearby memory addresses improves cache utilization by exploiting spatial locality.

```assembly
; Poor spatial locality - strided access
mov ecx, 1000
xor esi, esi
.loop:
    mov eax, [array + esi*16]   ; Access every 16th element
    add eax, 10
    mov [result + esi*4], eax
    inc esi
    loop .loop
; Wastes 3/4 of each cache line loaded

; Good spatial locality - sequential access
mov ecx, 1000
xor esi, esi
.loop:
    mov eax, [array + esi*4]    ; Sequential access
    add eax, 10
    mov [result + esi*4], eax
    inc esi
    loop .loop
; Uses entire cache line efficiently
```

### Temporal Locality

Reusing recently accessed data keeps it in cache.

```assembly
; Poor temporal locality - data used once then not again
mov ecx, count
.outer:
    mov esi, array1
    ; Process array1
    ; ... many instructions ...
    
    mov esi, array2
    ; Process array2
    ; ... many instructions ...
    
    ; By now, array1 might be evicted from cache
    dec ecx
    jnz .outer

; Better temporal locality - keep working set small
mov ecx, count
.outer:
    mov eax, [array1 + esi]
    mov ebx, [array2 + esi]
    ; Process both together
    add eax, ebx
    mov [result + esi], eax
    add esi, 4
    dec ecx
    jnz .outer
```

### Cache Blocking (Tiling)

Large data structures that don't fit in cache can be processed in blocks that do fit.

```assembly
; Matrix multiplication without blocking - poor cache behavior
; C[i][j] = sum(A[i][k] * B[k][j])

; Naive implementation:
.outer_i:
    .outer_j:
        xor eax, eax            ; Sum = 0
        .inner_k:
            ; A[i][k] accessed sequentially (good)
            ; B[k][j] accessed with stride (poor)
            mov ebx, [A + i*N*4 + k*4]
            imul ebx, [B + k*N*4 + j*4]
            add eax, ebx
            inc k
            cmp k, N
            jl .inner_k
        mov [C + i*N*4 + j*4], eax
        inc j
        cmp j, N
        jl .outer_j
    inc i
    cmp i, N
    jl .outer_i

; Cache-blocked implementation:
BLOCK_SIZE equ 32               ; Fits in L1 cache

.outer_i:                       ; i in steps of BLOCK_SIZE
    .outer_j:                   ; j in steps of BLOCK_SIZE
        .outer_k:               ; k in steps of BLOCK_SIZE
            ; Process BLOCK_SIZE x BLOCK_SIZE blocks
            mov bi, 0
            .block_i:
                mov bj, 0
                .block_j:
                    ; Compute C[i+bi][j+bj]
                    xor eax, eax
                    mov bk, 0
                    .block_k:
                        ; A[i+bi][k+bk] and B[k+bk][j+bj]
                        ; All accesses within small blocks - better cache reuse
                        inc bk
                        cmp bk, BLOCK_SIZE
                        jl .block_k
                    inc bj
                    cmp bj, BLOCK_SIZE
                    jl .block_j
                inc bi
                cmp bi, BLOCK_SIZE
                jl .block_i
            add k, BLOCK_SIZE
            cmp k, N
            jl .outer_k
        add j, BLOCK_SIZE
        cmp j, N
        jl .outer_j
    add i, BLOCK_SIZE
    cmp i, N
    jl .outer_i
```

### Data Structure Layout

How data is organized in memory affects cache performance.

**Structure of Arrays (SoA) vs Array of Structures (AoS):**

```assembly
; Array of Structures - poor for processing single fields
struc Particle
    .x      resd 1
    .y      resd 1
    .z      resd 1
    .vx     resd 1
    .vy     resd 1
    .vz     resd 1
endstruc

; Update only X coordinates - wastes cache lines
mov ecx, num_particles
xor esi, esi
.loop_aos:
    mov eax, [particles + esi + Particle.x]
    add eax, [particles + esi + Particle.vx]
    mov [particles + esi + Particle.x], eax
    add esi, Particle_size
    loop .loop_aos
; Loads full structure (24 bytes) but uses only 8 bytes

; Structure of Arrays - better cache utilization
; x_coords: array of all X coordinates
; y_coords: array of all Y coordinates
; etc.

mov ecx, num_particles
xor esi, esi
.loop_soa:
    mov eax, [x_coords + esi]
    add eax, [vx_coords + esi]
    mov [x_coords + esi], eax
    add esi, 4
    loop .loop_soa
; Loads only needed data, uses cache lines efficiently
```

**Data Alignment:**

```assembly
; Misaligned data - crosses cache line boundaries
data1 db 1, 2, 3          ; Starts at odd address
dd 0x12345678             ; May span two cache lines

; Aligned data - fits in single cache line
align 4
data2 dd 0x12345678       ; Aligned to 4-byte boundary

align 64                  ; Align to cache line boundary
cache_line_data:
    times 16 dd 0         ; Entire structure in one cache line

; Align frequently accessed variables
align 64
hot_variable dd 0
align 64
another_hot_variable dd 0
; Each gets its own cache line - no false sharing
```

### Cache Line Prefetching

Modern processors have hardware prefetchers, but software prefetching can help in some cases.

```assembly
; Manual prefetching
mov ecx, count
xor esi, esi
.loop:
    prefetchnta [array + esi + 256]  ; Prefetch ahead
    
    mov eax, [array + esi]
    add eax, 10
    mov [result + esi], eax
    
    add esi, 4
    dec ecx
    jnz .loop

; Prefetch variants:
; prefetchnta - non-temporal (won't pollute cache)
; prefetcht0  - temporal, all cache levels
; prefetcht1  - temporal, L2 and L3
; prefetcht2  - temporal, L3 only
```

**When to Use Prefetching:**

- Sequential access patterns hardware prefetcher can't detect
- Large strides in memory access
- Pointer chasing (linked lists, trees)
- When prefetch distance can cover memory latency

```assembly
; Pointer chasing - hardware prefetcher doesn't help
; Linked list traversal
mov esi, list_head
mov ecx, N
.loop:
    prefetchnta [esi + Node.next]   ; Prefetch next node
    
    ; Process current node
    mov eax, [esi + Node.data]
    ; ... process data ...
    
    mov esi, [esi + Node.next]
    loop .loop
```

### False Sharing

False sharing occurs when multiple threads access different variables on the same cache line, causing unnecessary cache coherence traffic.

```assembly
; False sharing - poor performance
section .data
    align 64
shared_data:
    thread1_counter dd 0        ; Byte 0-3
    thread2_counter dd 0        ; Byte 4-7
    ; Both in same cache line!

; Thread 1:
.thread1_loop:
    inc dword [thread1_counter]
    ; Cache line invalidated for Thread 2

; Thread 2:
.thread2_loop:
    inc dword [thread2_counter]
    ; Cache line invalidated for Thread 1

; Ping-pong effect: cache line bounces between cores

; Solution: Pad to separate cache lines
section .data
    align 64
thread1_counter dd 0
    times 15 dd 0               ; Padding (64 bytes total)

    align 64
thread2_counter dd 0
    times 15 dd 0               ; Padding (64 bytes total)

; Now each counter in separate cache line - no false sharing

; Alternative: Use cache line-sized structures
struc ThreadData
    .counter resd 1
    .padding resb 60            ; Pad to 64 bytes
endstruc

thread_data:
    istruc ThreadData
        at ThreadData.counter, dd 0
    iend

    istruc ThreadData
        at ThreadData.counter, dd 0
    iend
````

### Write Combining and Non-Temporal Stores

Write combining buffers can batch writes to memory, improving throughput for sequential write patterns.

```assembly
; Standard temporal stores - written to cache
mov ecx, 1024
xor esi, esi
.loop_temporal:
    mov [buffer + esi], eax
    add esi, 4
    loop .loop_temporal
; Data goes through cache hierarchy

; Non-temporal stores - bypass cache
mov ecx, 1024
xor esi, esi
.loop_nontemporal:
    movnti [buffer + esi], eax  ; Non-temporal integer store
    add esi, 4
    loop .loop_nontemporal
sfence                          ; Ensure stores complete

; SSE non-temporal stores - 16 bytes at a time
movaps xmm0, [source]
movntps [dest], xmm0            ; Non-temporal packed single
; Or movntdq for integer data

; Use cases for non-temporal stores:
; - Large sequential writes that won't be read soon
; - Streaming data that exceeds cache capacity
; - Avoiding cache pollution with write-only data
````

**Write Combining Buffers:**

Modern processors have write combining (WC) buffers that can combine multiple writes to adjacent addresses.

```assembly
; Write combining - efficient
mov esi, framebuffer
mov ecx, 1024

.loop:
    mov dword [esi + 0], 0xFF000000
    mov dword [esi + 4], 0x00FF0000
    mov dword [esi + 8], 0x0000FF00
    mov dword [esi + 12], 0x000000FF
    ; These 4 writes combined into single memory transaction
    
    add esi, 16
    dec ecx
    jnz .loop

; For write combining to work:
; - Writes must be to WC memory region
; - Addresses should be sequential within cache line
; - Use aligned writes when possible
```

### Loop Interchange for Cache Optimization

Changing loop nesting order can dramatically improve cache behavior.

```assembly
; Poor cache behavior - column-major access on row-major data
; sum += array[j][i] for row-major storage
mov sum, 0
mov i, 0
.outer_i:
    mov j, 0
    .inner_j:
        ; Calculate offset: j * WIDTH + i
        mov eax, j
        imul eax, WIDTH
        add eax, i
        shl eax, 2              ; * 4 for dword
        mov ebx, [array + eax]
        add sum, ebx
        inc j
        cmp j, HEIGHT
        jl .inner_j
    inc i
    cmp i, WIDTH
    jl .outer_i
; Accesses memory with large strides - poor spatial locality

; Good cache behavior - row-major access on row-major data
mov sum, 0
mov j, 0
.outer_j:
    mov i, 0
    .inner_i:
        ; Calculate offset: j * WIDTH + i
        mov eax, j
        imul eax, WIDTH
        add eax, i
        shl eax, 2
        mov ebx, [array + eax]
        add sum, ebx
        inc i
        cmp i, WIDTH
        jl .inner_i
    inc j
    cmp j, HEIGHT
    jl .outer_j
; Sequential access - excellent spatial locality
```

### Cache-Aware Data Padding

Strategic padding prevents critical data from sharing cache lines with less frequently accessed data.

```assembly
; Critical hot path data structure
struc HotData
    .critical1      resd 1      ; Frequently accessed
    .critical2      resd 1      ; Frequently accessed
    .critical3      resd 1      ; Frequently accessed
    .critical4      resd 1      ; Frequently accessed
    ; Total: 16 bytes - fits in single cache line with room for more
    
    ; Separate rarely-used fields
    .padding        resb 48     ; Pad to cache line boundary
    
    .rarely_used1   resd 1      ; In different cache line
    .rarely_used2   resd 1
endstruc

; Group frequently accessed fields together
align 64
critical_section:
    dd variable1    ; Hot
    dd variable2    ; Hot
    dd variable3    ; Hot
    dd variable4    ; Hot
    ; All in same cache line

align 64
cold_section:
    dd variable5    ; Cold
    dd variable6    ; Cold
    ; Separate cache line
```

### SIMD and Cache Optimization

SIMD instructions process multiple data elements simultaneously and work best with cache-friendly access patterns.

```assembly
; Scalar processing - 4 operations per loop
mov ecx, 1000
xor esi, esi
.scalar_loop:
    mov eax, [array + esi]
    add eax, 10
    mov [result + esi], eax
    add esi, 4
    dec ecx
    jnz .scalar_loop

; SSE processing - 4 operations per iteration (4x throughput)
mov ecx, 250            ; 1000 / 4
xor esi, esi
movaps xmm1, [const_10] ; XMM1 = {10, 10, 10, 10}

.sse_loop:
    movaps xmm0, [array + esi]  ; Load 4 floats
    addps xmm0, xmm1            ; Add 10 to all 4
    movaps [result + esi], xmm0 ; Store 4 results
    add esi, 16                 ; 16 bytes = 4 floats
    dec ecx
    jnz .sse_loop

; AVX processing - 8 operations per iteration (8x throughput)
mov ecx, 125            ; 1000 / 8
xor esi, esi
vbroadcastss ymm1, [const_10]   ; Broadcast to all 8 elements

.avx_loop:
    vmovaps ymm0, [array + esi] ; Load 8 floats (32 bytes)
    vaddps ymm0, ymm0, ymm1     ; Add 10 to all 8
    vmovaps [result + esi], ymm0 ; Store 8 results
    add esi, 32                 ; 32 bytes = 8 floats
    dec ecx
    jnz .avx_loop
    vzeroupper                  ; Clear upper bits to avoid penalties
```

**Cache-Friendly SIMD Patterns:**

```assembly
; Aligned loads - faster than unaligned
section .data
align 32                        ; AVX requires 32-byte alignment
vector_data:
    times 8 dd 1.0

section .text
vmovaps ymm0, [vector_data]    ; Aligned load - fast

; Unaligned data
unaligned_data:
    db 1                        ; Misaligned
    times 32 dd 1.0

vmovups ymm0, [unaligned_data + 1]  ; Unaligned load - slower

; Stream loads for large data
prefetchnta [large_array + 512]
movntdqa xmm0, [large_array]   ; Streaming load
```

### Software Prefetch Distance

The prefetch distance (how far ahead to prefetch) depends on memory latency and processing rate.

```assembly
; Calculate optimal prefetch distance:
; distance = latency * processing_rate
; Example: 200 cycle latency, process 1 element per 4 cycles
; distance = 200 / 4 = 50 elements = 200 bytes

PREFETCH_DISTANCE equ 256       ; Bytes ahead

mov ecx, count
xor esi, esi

; Prefetch initial data
prefetchnta [array + PREFETCH_DISTANCE]

.loop:
    ; Prefetch for future iteration
    prefetchnta [array + esi + PREFETCH_DISTANCE]
    
    ; Process current data (should be in cache now)
    mov eax, [array + esi]
    add eax, 10
    mov [result + esi], eax
    
    add esi, 4
    dec ecx
    jnz .loop

; Two-level prefetching for complex patterns
.loop_2level:
    prefetchnta [array + esi + PREFETCH_DISTANCE]     ; Near prefetch
    prefetcht2 [array + esi + PREFETCH_DISTANCE*2]    ; Far prefetch
    
    ; Process data
    mov eax, [array + esi]
    add eax, ebx
    mov [result + esi], eax
    
    add esi, 4
    dec ecx
    jnz .loop_2level
```

### Cache-Oblivious Algorithms

[Inference] Cache-oblivious algorithms perform well across different cache sizes without tuning, using recursive divide-and-conquer approaches.

```assembly
; Recursive matrix transpose (cache-oblivious)
; transpose(matrix, n, row_start, col_start, size)

transpose:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 20]     ; size
    cmp eax, THRESHOLD      ; Base case threshold
    jle .base_case
    
    ; Recursive case: divide into quadrants
    shr eax, 1              ; size / 2
    
    ; Transpose 4 quadrants
    push eax                ; size/2
    push dword [ebp + 16]   ; col_start
    push dword [ebp + 12]   ; row_start
    call transpose
    add esp, 12
    
    ; ... 3 more recursive calls for other quadrants ...
    
    jmp .done
    
.base_case:
    ; Direct transpose for small block
    mov esi, [ebp + 12]     ; row_start
    mov edi, [ebp + 16]     ; col_start
    mov ecx, [ebp + 20]     ; size
    
    ; Transpose small block
    ; ... standard transpose code ...
    
.done:
    pop ebp
    ret
```

### Hardware Performance Counters

Modern processors provide performance counters to measure cache behavior and guide optimization.

```assembly
; Reading performance counters (simplified, requires ring 0)
; Intel: Use RDPMC instruction

mov ecx, 0              ; Counter 0 (e.g., L1 cache misses)
rdpmc                   ; Read counter into EDX:EAX

; Common counters:
; - L1/L2/L3 cache hits and misses
; - TLB hits and misses
; - Branch mispredictions
; - Instructions retired
; - Cycles

; Example: Measure cache miss rate
rdpmc                   ; Read initial counter
mov [start_count], eax

; Code to measure
; ...

rdpmc                   ; Read final counter
sub eax, [start_count]
; EAX = cache misses during code execution
```

### Memory Access Patterns Summary

**Best Practices:**

```assembly
; 1. Sequential access - best cache utilization
mov ecx, count
xor esi, esi
.seq_loop:
    mov eax, [array + esi]
    ; Process
    add esi, 4
    loop .seq_loop

; 2. Stride-1 access when possible
; Process array[i], array[i+1], array[i+2]... sequentially

; 3. Avoid large strides
; Bad: array[0], array[1000], array[2000]...
; Good: array[0], array[1], array[2]...

; 4. Keep working set small
; Try to keep active data under L1 size (32-64 KB)

; 5. Use blocking for large datasets
; Process data in cache-sized chunks

; 6. Align data structures
align 64                ; Cache line alignment
important_data:
    dd 0

; 7. Avoid false sharing in multithreaded code
; Separate thread-local data by cache line size

; 8. Use non-temporal operations for streaming
movntdq [dest], xmm0   ; Bypass cache for write-only data

; 9. Prefetch for irregular access patterns
prefetchnta [pointer_chain]

; 10. Profile and measure
; Use performance counters to validate optimizations
```

### Register Pressure and Spilling

Register pressure affects cache performance when values spill to stack/memory.

```assembly
; High register pressure - causes spills
function_spills:
    push ebp
    mov ebp, esp
    sub esp, 32             ; Reserve stack space for spills
    
    ; Need 10 values but only 6 GPRs available (excluding ESP, EBP)
    mov eax, [data1]
    mov ebx, [data2]
    mov ecx, [data3]
    mov edx, [data4]
    mov esi, [data5]
    mov edi, [data6]
    
    ; Must spill to use more values
    mov [ebp - 4], eax      ; Spill EAX
    mov eax, [data7]        ; Load new value
    
    ; Later need spilled value
    add ebx, [ebp - 4]      ; Load from spill - cache/memory access
    
    mov esp, ebp
    pop ebp
    ret

; Lower register pressure - avoid spills
function_optimized:
    push ebp
    mov ebp, esp
    
    ; Process in chunks that fit in registers
    mov eax, [data1]
    mov ebx, [data2]
    add eax, ebx
    mov [result], eax       ; Store intermediate result
    
    ; Next chunk
    mov ecx, [data3]
    mov edx, [data4]
    add ecx, edx
    add ecx, [result]       ; Combine with previous
    mov [result], ecx
    
    pop ebp
    ret
    
; No spills to stack - better cache behavior
```

### Loop Fusion for Cache Reuse

Fusing loops that access the same data improves temporal locality.

```assembly
; Separate loops - poor temporal locality
mov ecx, count
xor esi, esi
.loop1:
    mov eax, [array + esi]
    add eax, 10
    mov [array + esi], eax
    add esi, 4
    loop .loop1

; Array might be evicted from cache
mov ecx, count
xor esi, esi
.loop2:
    mov eax, [array + esi]
    imul eax, 2
    mov [array + esi], eax
    add esi, 4
    loop .loop2

; Fused loop - better temporal locality
mov ecx, count
xor esi, esi
.fused_loop:
    mov eax, [array + esi]
    add eax, 10             ; First operation
    imul eax, 2             ; Second operation
    mov [array + esi], eax
    add esi, 4
    loop .fused_loop
; Process each element completely before moving to next
; Better cache reuse
```

### Avoiding Cache Conflicts

[Inference] Cache conflict misses occur when multiple addresses map to the same cache set. Power-of-two strides can cause pathological behavior in set-associative caches.

```assembly
; Potential cache conflicts with power-of-2 strides
ARRAY_SIZE equ 1024     ; Power of 2
STRIDE equ 256          ; Power of 2

mov ecx, 100
xor esi, esi
.conflict_loop:
    ; Accessing array[0], array[256], array[512], array[768]
    ; These may all map to same cache sets
    mov eax, [array + esi]
    add esi, STRIDE
    and esi, (ARRAY_SIZE * 4 - 1)
    loop .conflict_loop
; Many conflict misses possible

; Solution: Use non-power-of-2 strides or array sizes
ARRAY_SIZE equ 1020     ; Not power of 2
; Or add padding to break power-of-2 patterns

; Better: Sequential access when possible
mov ecx, count
xor esi, esi
.sequential:
    mov eax, [array + esi]
    add esi, 4
    loop .sequential
```

**Key Points:**

- Instruction scheduling maximizes throughput by ordering instructions to exploit multiple execution units while minimizing dependencies and pipeline stalls
- Modern x86 processors decode instructions into micro-ops, with fusion optimizations combining certain instruction pairs into single μops for better efficiency
- Pipeline awareness requires understanding load-use latencies, store forwarding behavior, and avoiding partial register stalls that cause delays
- Branch prediction optimization involves making branches predictable, eliminating branches through predication (CMOV, SETcc), and arranging code to favor common execution paths
- Cache optimization depends on exploiting spatial locality through sequential access, temporal locality through data reuse, and cache blocking for large datasets that exceed cache capacity
- Data structure layout significantly impacts cache performance, with structure-of-arrays often outperforming array-of-structures for operations on specific fields
- False sharing between threads causes unnecessary cache coherence traffic and must be avoided by padding thread-local data to separate cache lines
- SIMD instructions combined with cache-friendly access patterns provide substantial performance improvements through parallel processing and efficient memory bandwidth utilization
- Prefetching can hide memory latency for predictable access patterns, with optimal prefetch distance calculated from memory latency and processing rate
- [Inference] Register pressure, loop fusion, cache-oblivious algorithms, and avoiding cache conflicts through non-power-of-2 strides are additional optimization considerations for complex scenarios

---

