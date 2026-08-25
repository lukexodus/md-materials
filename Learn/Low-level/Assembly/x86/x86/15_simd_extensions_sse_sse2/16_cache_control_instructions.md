## Cache Control Instructions


SSE introduced explicit cache control instructions for optimizing memory access patterns, improving performance for streaming data and reducing cache pollution.

### Prefetch Instructions

Prefetch instructions initiate data transfer from memory to cache before the data is actually needed, hiding memory latency.

**PREFETCHNTA** - Prefetch Data to Non-Temporal Cache (Minimize Cache Pollution)

```nasm
prefetchnta [mem]         ; Prefetch to L1 cache with non-temporal hint
```

Intended for data that will be used once and should not evict cached data. Typically fetches to L1 cache but with low priority.

**PREFETCHT0** - Prefetch Data to All Cache Levels

```nasm
prefetcht0 [mem]          ; Prefetch to all cache levels (temporal locality)
```

For data expected to be reused soon. Brings data into all cache levels (L1, L2, L3).

**PREFETCHT1** - Prefetch Data Leaving L1 Cache Intact

```nasm
prefetcht1 [mem]          ; Prefetch to L2 cache and higher
```

For data with moderate temporal locality. Typically fetches to L2 and L3, may skip L1.

**PREFETCHT2** - Prefetch Data to L2 Cache and Higher

```nasm
prefetcht2 [mem]          ; Prefetch to L2/L3 cache
```

For data with lower temporal locality. Typically fetches to L3 and L2, avoids L1.

**Example** of prefetch usage in array processing:

```nasm
; Process array with prefetching ahead
mov esi, array_ptr
mov ecx, element_count

process_loop:
    prefetchnta [esi + 128]   ; Prefetch 2 cache lines ahead
    
    movaps xmm0, [esi]        ; Process current data
    ; ... arithmetic operations ...
    movaps [esi], xmm0
    
    add esi, 16
    dec ecx
    jnz process_loop
```

#### Prefetch Effectiveness Considerations

[Inference] Prefetch instructions provide performance benefits when:

- Memory latency is significant relative to computation time
- Access patterns are predictable and sequential or strided
- Prefetch distance is calibrated to memory latency (typically 64-256 bytes ahead)
- Memory bandwidth is not already saturated

[Inference] Prefetch may degrade performance if:

- Access patterns are unpredictable (random)
- Prefetch distance is incorrect (too close: no time to fetch; too far: evicted before use)
- Memory bandwidth is limited and prefetches compete with demand loads

### Non-Temporal Store Instructions

Non-temporal stores bypass the cache hierarchy, writing directly to memory without allocating cache lines. This reduces cache pollution when writing data that will not be immediately reread.

**MOVNTPS** - Store Packed Single-Precision Using Non-Temporal Hint

```nasm
movntps [mem], xmm0       ; Store 16 bytes, bypass cache
```

**MOVNTPD** - Store Packed Double-Precision Using Non-Temporal Hint

```nasm
movntpd [mem], xmm0       ; Store 16 bytes, bypass cache
```

**MOVNTDQ** - Store Doubleword Integer Using Non-Temporal Hint

```nasm
movntdq [mem], xmm0       ; Store 16 bytes, bypass cache
```

**MOVNTI** - Store Doubleword Using Non-Temporal Hint (General Purpose Register)

```nasm
movnti [mem], eax         ; Store 4 bytes, bypass cache
```

**MOVNTQ** - Store Quadword Using Non-Temporal Hint (MMX)

```nasm
movntq [mem], mm0         ; Store 8 bytes, bypass cache
```

#### Memory Alignment Requirements

Non-temporal stores require 16-byte alignment for XMM operands. Misaligned addresses cause general protection faults (#GP).

**Example** of non-temporal store usage:

```nasm
; Write computed results to large output buffer
; Data will not be reread, so avoid cache pollution

compute_and_store:
    ; ... compute results in XMM0 ...
    
    movntps [edi], xmm0       ; Non-temporal store (16-byte aligned)
    add edi, 16
    
    ; ... continue processing ...
```

#### Write Combining Behavior

[Inference] Non-temporal stores typically use write-combining buffers, which aggregate multiple stores before committing to memory. This improves memory bandwidth utilization by reducing bus transactions.

**Write combining characteristics**:

- Stores accumulate in processor buffers (typically 4-10 write-combining buffers)
- Buffers flush when full, when SFENCE is executed, or when buffer resources are needed
- Sequential stores to the same cache line are merged
- Improves bandwidth for streaming writes

### Memory Fence Instructions

**SFENCE** - Store Fence

```nasm
sfence                    ; Serialize store operations
```

SFENCE ensures all store operations (including non-temporal stores) issued before SFENCE complete before any stores issued after SFENCE become globally visible. This is critical for ensuring memory ordering with non-temporal stores.

**Example** of SFENCE usage:

```nasm
; Write multiple cache lines with non-temporal stores
movntps [buffer + 0], xmm0
movntps [buffer + 16], xmm1
movntps [buffer + 32], xmm2
movntps [buffer + 48], xmm3

; Ensure all writes complete before signaling completion
sfence

; Signal that data is ready (flag visible to other threads/cores)
mov dword [completion_flag], 1
```

**LFENCE** - Load Fence

```nasm
lfence                    ; Serialize load operations
```

LFENCE ensures all load operations issued before LFENCE complete before any loads issued after LFENCE execute. Useful for preventing speculative execution from reordering loads.

**MFENCE** - Memory Fence

```nasm
mfence                    ; Serialize all memory operations
```

MFENCE ensures all memory operations (loads and stores) issued before MFENCE complete before any memory operations issued after MFENCE execute. Provides the strongest memory ordering guarantee.

**Example** of memory fence ordering:

```nasm
; Thread 1: Producer
mov [data], eax           ; Write data
sfence                    ; Ensure write completes
mov [flag], 1             ; Signal data ready

; Thread 2: Consumer
spin_wait:
    mov eax, [flag]       ; Check flag
    test eax, eax
    jz spin_wait
    
lfence                    ; Ensure flag read completes
mov ebx, [data]           ; Read data (guaranteed to see updated value)
```

### Streaming Load Instructions (SSE4.1)

While SSE/SSE2 do not include streaming loads, later extensions added complementary functionality:

**MOVNTDQA** (SSE4.1) - Load Double Quadword Non-Temporal Aligned Hint

```nasm
movntdqa xmm0, [mem]      ; Load 16 bytes with non-temporal hint
```

This instruction provides a hint that data is streaming (read once) and should not pollute caches. Note: This is SSE4.1, not SSE/SSE2.

### Cache Line Flush

**CLFLUSH** (SSE2) - Flush Cache Line

```nasm
clflush [mem]             ; Invalidate and write back cache line containing address
```

CLFLUSH flushes the cache line containing the specified memory address from all levels of the cache hierarchy. If the line is modified, it is written back to memory first.

**Use cases**:

- Ensuring data visibility across non-coherent memory systems
- Implementing persistent memory operations
- Forcing cache eviction for testing/debugging

**Example** of cache line flush:

```nasm
; Modify data
mov dword [buffer], eax

; Ensure data is written to memory (not just in cache)
clflush [buffer]

; Optionally ensure flush completes
mfence
```

### Practical Cache Control Example

**Example** of optimized memory copy with cache control:

```nasm
; Fast memory copy for large buffers (non-temporal)
; ESI = source, EDI = destination, ECX = size in bytes
; Assumes 16-byte alignment and size multiple of 64

aligned_memcpy:
    shr ecx, 6                ; Divide by 64 (process 64 bytes per iteration)
    
copy_loop:
    prefetchnta [esi + 256]   ; Prefetch source ahead
    
    ; Load 64 bytes (4 x 16-byte loads)
    movaps xmm0, [esi]
    movaps xmm1, [esi + 16]
    movaps xmm2, [esi + 32]
    movaps xmm3, [esi + 48]
    
    ; Store 64 bytes (non-temporal to avoid cache pollution)
    movntps [edi], xmm0
    movntps [edi + 16], xmm1
    movntps [edi + 32], xmm2
    movntps [edi + 48], xmm3
    
    add esi, 64
    add edi, 64
    dec ecx
    jnz copy_loop
    
    sfence                    ; Ensure all stores complete
    ret
```

### Cache Control Performance Considerations

[Inference] Cache control instruction effectiveness depends on:

**Prefetch timing**: Prefetch distance should match memory latency (typically 100-300 cycles). Too close provides insufficient time; too far may cause premature eviction.

**Non-temporal store threshold**: [Inference] Non-temporal stores are most beneficial for datasets larger than the last-level cache (typically > 1-4 MB). For smaller datasets, normal stores may perform better due to hardware prefetchers and cache reuse.

**Memory bandwidth**: When memory bandwidth is saturated, additional prefetches or non-temporal stores may not improve performance and could increase latency.

**Hardware prefetchers**: Modern processors have automatic hardware prefetchers. [Inference] Explicit software prefetching provides additional benefit primarily for irregular access patterns or when hardware prefetchers cannot detect the pattern.

**Write-combining buffer limits**: [Inference] Processors typically have 4-10 write-combining buffers. Excessive non-temporal stores to scattered addresses may cause buffer thrashing, reducing effectiveness.

### Cache Control Best Practices

**Prefetch guidelines**:

- Use for sequential or strided access patterns with predictable addresses
- Prefetch 64-256 bytes ahead for typical memory latencies
- Avoid prefetching in tight loops with high computational intensity
- Test with and without prefetching to measure actual benefit

**Non-temporal store guidelines**:

- Use for write-only streaming data (no subsequent reads)
- Ensure 16-byte alignment to avoid faults
- Use for datasets larger than cache size
- Always follow with SFENCE before synchronization points
- Process data in cache-line-sized chunks (64 bytes) for optimal write combining

**Memory fence guidelines**:

- Use SFENCE after non-temporal stores before signaling completion
- Use LFENCE/MFENCE for multi-threaded synchronization
- Minimize fence usage as they prevent instruction reordering and affect performance
- MFENCE is strongest but most expensive; use SFENCE/LFENCE when possible

