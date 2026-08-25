## Write Policies (Write-Through, Write-Back)


Write policies determine how cache handles writes to memory, balancing performance, complexity, and data consistency.

### Write-Back Policy

Write-back (also called copy-back) delays writing to memory until the cache line is evicted.

**Write-Back Characteristics**:

- **Write to cache only initially**
- **Memory not updated until eviction**
- **Dirty bit tracks modified lines**
- **Reduces memory bandwidth**
- **Better performance for frequent writes**

**Write-Back Operation**:

```
1. CPU writes to address in cache
2. Cache line marked dirty (Modified state)
3. Memory remains unchanged (stale)
4. On eviction: Write dirty line back to memory
```

```assembly
; Write-back in action
section .data
align 64
cached_data: dd 0

write_back_example:
    ; First write - cache miss, load line
    mov dword [cached_data], 10     ; Load line, mark dirty
    
    ; Subsequent writes - cache hits
    mov dword [cached_data], 20     ; Hits cache, mark dirty
    mov dword [cached_data], 30     ; Hits cache, still dirty
    mov dword [cached_data], 40     ; Hits cache, still dirty
    
    ; Memory still has value 0
    ; Only cache has value 40
    
    ; Eventually line evicted (due to cache pressure)
    ; Writeback occurs: Memory updated to 40
    
    ret

; Only 1 memory write despite 4 stores
; Memory bandwidth saved: 75% reduction
```

**Dirty Bit Management**:

```
Cache Line Metadata:
[Tag | Valid | Dirty | Coherency State | LRU bits | Data (64 bytes)]

Dirty = 0: Clean (matches memory)
Dirty = 1: Dirty (modified, memory stale)

On read miss:
- If evicting clean line: Simply overwrite
- If evicting dirty line: Write back to memory first

On write hit:
- Set dirty bit
- Update data

On write miss (write-allocate):
- Allocate cache line
- Set dirty bit
- Write data
```

**Write-Back with Cache Coherency**:

```assembly
; Multi-core write-back scenario
section .data
align 64
shared_data: dd 100

; Core 0
core0_write_back:
    ; Load into cache (Exclusive state)
    mov eax, [shared_data]
    
    ; Write - stays in cache (Modified state, dirty)
    mov dword [shared_data], 200
    ; Memory still has 100
    
    ; Core 1 reads shared_data...
    ; Cache coherency forces writeback
    ; Core 0: M → S (writeback to memory)
    ; Memory now has 200
    ret

; Writeback happens due to coherency, not eviction
```

**Write-Back Advantages**:

**Reduced Memory Traffic**: Multiple writes to same location coalesced

```assembly
array_update_write_back:
    mov ecx, 100
    mov esi, array
.loop:
    mov dword [esi], eax        ; Write to cache
    add esi, 4
    dec ecx
    jnz .loop
    ; If array fits in cache: 100 writes to cache, 0-2 writebacks
    ret
```

**Better Performance**: Writes complete at cache speed, not memory speed

```assembly
; Write-back timing
    mov [cached_var], eax       ; ~4-5 cycles (L1 cache latency)
    ; vs ~200 cycles if had to wait for memory
```

**Write Combining**: Multiple dirty lines can be written back in burst

**Write-Back Disadvantages**:

**Complexity**: Requires dirty bit tracking, writeback logic **Data Loss Risk**: Dirty data only in cache (vulnerable to power loss) **Coherency Overhead**: Dirty lines must be written back on sharing

### Write-Through Policy

Write-through immediately writes to both cache and memory on every store.

**Write-Through Characteristics**:

- **Write to cache and memory simultaneously**
- **No dirty bit needed**
- **Memory always consistent with cache**
- **Simpler coherency**
- **Higher memory bandwidth usage**

**Write-Through Operation**:

```
1. CPU writes to address
2. Update cache line
3. Simultaneously write to memory
4. Cache line always clean
```

```assembly
; Write-through example
write_through_example:
    ; Each write goes to both cache and memory
    mov dword [cached_data], 10     ; Cache: 10, Memory: 10
    mov dword [cached_data], 20     ; Cache: 20, Memory: 20
    mov dword [cached_data], 30     ; Cache: 30, Memory: 30
    mov dword [cached_data], 40     ; Cache: 40, Memory: 40
    
    ret

; 4 writes to cache, 4 writes to memory
; Memory bandwidth: 4x higher than write-back
```

**Write-Through with Write Buffer**:

To hide write latency, write-through caches use write buffers:

```
CPU Write → Cache → Write Buffer → Memory

Write buffer:
- Holds pending writes to memory
- Write completes from CPU perspective
- Buffer drains to memory asynchronously
- Typically 4-8 entries deep
```

```assembly
; Write-through with buffering
buffered_write_through:
    mov dword [data1], 10       ; Cache + write buffer
    mov dword [data2], 20       ; Cache + write buffer
    mov dword [data3], 30       ; Cache + write buffer
    mov dword [data4], 40       ; Cache + write buffer
    ; CPU continues immediately
    ; Write buffer drains to memory in background
    
    mov eax, [data1]            ; Read from cache (hit)
    ; Read sees write despite memory not updated yet
    ret
```

**Write Buffer Overflow**:

```assembly
; Write buffer full - stall
buffer_full_stall:
    mov ecx, 100
.loop:
    mov [array + ecx*4], eax    ; Fast initially
    dec ecx
    jnz .loop
    ; Eventually write buffer fills
    ; CPU stalls until buffer drains
    ret

; Performance degrades to memory write speed when buffer full
```

**Write-Through Advantages**:

**Simplicity**: No dirty bit, no writeback logic **Memory Consistency**: Memory always up-to-date **Reliability**: No data loss on power failure (data in memory) **Simpler Coherency**: No writeback complications

**Write-Through Disadvantages**:

**Higher Memory Traffic**: Every write goes to memory

```assembly
; Write-through bandwidth usage
high_bandwidth_writes:
    mov ecx, 1000
.loop:
    mov [array + ecx*4], eax    ; 1000 memory writes
    dec ecx
    jnz .loop
    ret

; Write-back would coalesce to ~16 writebacks (64 KB / 4 KB cache lines)
; Write-through: 1000 memory writes
; 62x more memory traffic
```

**Lower Write Performance**: Writes limited by memory speed **Write Buffer Stalls**: Sustained writes exhaust buffer

### Write-Allocate vs Write-No-Allocate

Independent of write-back/write-through, caches can allocate or not allocate on write misses.

**Write-Allocate** (Fetch-on-write):

On write miss, load cache line before writing.

```assembly
; Write-allocate behavior
write_allocate_example:
    ; Write to address not in cache
    mov dword [uncached_data], 42
    
    ; Operation:
    ; 1. Cache miss detected
    ; 2. Load entire 64-byte cache line from memory
    ; 3. Modify the 4-byte dword
    ; 4. Line now in cache (dirty if write-back)
    
    ; Subsequent writes hit cache
    mov dword [uncached_data + 4], 43   ; Cache hit
    ret

; Brings spatial locality - nearby accesses hit cache
```

**Write-No-Allocate** (Write-around):

On write miss, write directly to memory without loading into cache.

```assembly
; Write-no-allocate behavior
write_no_allocate_example:
    ; Write to address not in cache
    mov dword [uncached_data], 42
    
    ; Operation:
    ; 1. Cache miss detected
    ; 2. Write directly to memory
    ; 3. Cache line NOT loaded
    
    ; Subsequent writes still miss
    mov dword [uncached_data + 4], 43   ; Cache miss again
    ret

; Avoids polluting cache with write-only data
```

**Typical Combinations**:

**Write-Back + Write-Allocate**: Most common (modern x86)

- Writes coalesced in cache
- Good for temporal locality
- Reduces memory bandwidth

**Write-Through + Write-No-Allocate**: Historical (early systems)

- Simple implementation
- Avoids cache pollution from writes
- Lower bandwidth than write-through + write-allocate

```assembly
; Comparing policies for array initialization

; Write-back + write-allocate (typical)
wb_wa_init:
    mov ecx, 1024           ; Initialize 4 KB array
    xor eax, eax
    mov edi, array
    rep stosd
    ; Stores hit cache (allocated on first miss per line)
    ; Memory writes: ~64 writebacks (4 KB / 64 bytes)
    ret

; Write-through + write-no-allocate (hypothetical)
wt_wna_init:
    mov ecx, 1024
    xor eax, eax
    mov edi, array
    rep stosd
    ; Every store goes to memory (no allocation)
    ; Memory writes: 1024 writes
    ret

; Write-back much more efficient: 16x fewer memory writes
```

### Non-Temporal Stores

x86 provides non-temporal store instructions that bypass cache:

```assembly
; Temporal store - goes through cache (write-allocate)
temporal_store:
    mov [buffer], eax       ; Allocates cache line
    ; Good if data will be read soon
    ret

; Non-temporal store - bypasses cache (write-no-allocate)
non_temporal_store:
    movnti [buffer], eax    ; Directly to memory, bypass cache
    ; Good for streaming writes that won't be read soon
    ret

; Use case: Large memory copy
large_memcpy_non_temporal:
    mov ecx, 1000000        ; Copy 4 MB
    mov esi, source
    mov edi, destination
.loop:
    movdqa xmm0, [esi]      ; Load 16 bytes
    movntdq [edi], xmm0     ; Non-temporal store (bypass cache)
    add esi, 16
    add edi, 16
    sub ecx, 4
    jnz .loop
    
    sfence                  ; Ensure non-temporal stores complete
    ret

; Advantages:
; - Doesn't pollute cache with write-once data
; - Avoids write-allocate for data not read back
; - Better for streaming workloads
```

**Write Combining Buffers**:

Non-temporal stores use write combining (WC) buffers:

```
Write Combining Buffer:
- Separate from cache
- Accumulates writes to same cache line
- Flushes full cache lines to memory
- Reduces bus transactions
```

```assembly
; Write combining in action
write_combining:
    ; Fill WC buffer (64 bytes)
    movnti [buffer], eax        ; WC buffer: 4 bytes
    movnti [buffer + 4], ebx    ; WC buffer: 8 bytes
    ; ... more stores ...
    movnti [buffer + 60], esi   ; WC buffer: 64 bytes (full)
    
    ; Buffer flushes automatically when full
    ; Single 64-byte memory write instead of 16 separate writes
    
    sfence                      ; Explicit flush
    ret
```

### Memory Types and Caching Policy

x86 memory type range registers (MTRRs) and page attributes control caching policy:

**Memory Types**:

**Uncacheable (UC)**: No caching, all accesses go to memory

- Used for: Memory-mapped I/O, device registers
- Write policy: Write-through to device, no cache allocation

**Write Combining (WC)**: Writes combined in buffers, weak ordering

- Used for: Frame buffers, graphics memory
- Write policy: Bypass cache, combine in WC buffers

**Write-Through (WT)**: Write-through with write-allocate

- Used for: Rarely (legacy compatibility)
- Write policy: Writes to cache and memory simultaneously

**Write-Protected (WP)**: Reads cacheable, writes go through to memory

- Used for: Read-mostly data
- Write policy: Write-through for writes, cacheable for reads

**Write-Back (WB)**: Full caching with write-back

- Used for: Normal system memory
- Write policy: Write-back, write-allocate

**Setting Memory Types**:

```assembly
; Via page table entry (PAT - Page Attribute Table)
set_page_memory_type:
    ; Page table entry bits:
    ; PAT (bit 7), PCD (bit 4), PWT (bit 3)
    ; Combination determines memory type
    
    mov eax, [page_table_entry]
    and eax, ~0x98          ; Clear PAT, PWT, PCD
    or eax, 0x10            ; Set for write-through
    mov [page_table_entry], eax
    
    ; Flush TLB
    invlpg [virtual_address]
    ret

; Via MTRR (system-wide, privileged)
; Typically configured by BIOS/OS
```

**Mixing Write Policies**:

```assembly
; Different memory regions with different policies
section .data

; Normal data - write-back
align 64
normal_data: dd 0

; Device memory - uncacheable  
section .device_mem
align 64
device_register: dd 0

access_mixed:
    ; Write-back access
    mov dword [normal_data], 42     ; Cached, write-back
    
    ; Uncacheable access
    mov dword [device_register], 1  ; Direct to device, uncached
    ; Ensures device sees write immediately
    
    ret
```

### Cache Flushing

x86 provides instructions to explicitly flush cache:

```assembly
; CLFLUSH - Flush single cache line
flush_line:
    clflush [data_address]      ; Invalidate and writeback if dirty
    ; Line removed from all cache levels
    ; Subsequent access causes cache miss
    ret

; CLFLUSHOPT - Optimized flush (may be reordered)
flush_line_opt:
    clflushopt [data_address]
    ; Faster but requires fence for ordering
    sfence
    ret

; CLWB - Write-back without invalidate
writeback_line:
    clwb [data_address]         ; Writeback if dirty, keep in cache
    ; Line remains cached after writeback
    ; Better performance than CLFLUSH
    ret

; WBINVD - Flush entire cache (privileged)
flush_all_caches:
    wbinvd                      ; Writebacks all dirty lines, invalidates
    ; Very expensive, rarely used
    ret
```

**Use Cases for Cache Flushing**:

```assembly
; DMA buffer preparation
prepare_dma_buffer:
    ; CPU fills buffer
    mov ecx, buffer_size
    mov edi, dma_buffer
    rep stosb
    
    ; Flush to ensure DMA device sees data
    mov ecx, buffer_size
    mov esi, dma_buffer
.flush_loop:
    clflush [esi]               ; Flush each cache line
    add esi, 64
    sub ecx, 64
    jg .flush_loop
    
    mfence                      ; Ensure flushes complete
    ; Now DMA device can access coherent data
    ret
```

**Key Points**:

- Write-back delays memory writes until eviction, reducing bandwidth
- Write-through writes to memory immediately, ensuring consistency
- Modern x86 uses write-back with write-allocate for performance
- Dirty bits track modified cache lines requiring writeback
- Write buffers hide write-through latency
- Write-allocate loads cache line on write miss for spatial locality
- Non-temporal stores bypass cache for streaming workloads
- Memory types (UC, WC, WT, WP, WB) control caching policy
- CLFLUSH/CLWB explicitly manage cache contents
- Write-back provides ~10-100x better write performance than write-through
- Cache coherency protocols interact with write policies
- Write combining coalesces multiple writes to same cache line

**Related Topics for Further Study**: Memory consistency models (sequential consistency, total store ordering), Lock-free algorithms and cache considerations, NUMA-aware memory allocation, Prefetching techniques (hardware and software), Cache-oblivious algorithms, Performance monitoring counters for cache analysis, Transactional memory and cache implications

---

