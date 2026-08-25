## Cache Control


ARM processors implement separate instruction and data caches (Harvard architecture) with various sizes and associativities depending on the implementation. Cache management is critical for correctness (maintaining coherency) and performance (optimizing hit rates).

**Cache Architecture:**

**L1 Cache:** Typically 16KB-64KB per cache (I-cache and D-cache), 2-way or 4-way set-associative, integrated into CPU core.

**L2 Cache:** Optional unified cache, 256KB-2MB, 8-way or 16-way set-associative, shared between cores or per-core.

**L3 Cache:** Present in high-end systems, several MB, shared across all cores.

**Cache Line Size:** Typically 32 or 64 bytes (8 or 16 words). Entire cache line is loaded/evicted as a unit.

**Cache Organization - Set Associative:**

```
Virtual Address (example: 32-bit, 32-byte lines, 4-way set-associative, 16KB cache):

31              10  9     5  4        0
|      Tag        | Index | Byte Offset |
|    (22 bits)    |(5 bits)|  (5 bits)  |

Number of sets = Cache size / (Ways × Line size)
               = 16384 / (4 × 32) = 128 sets (7 bits, but using 5 shown)

Each set contains 4 cache lines (ways)
```

**Cache Operations:** ARM provides coprocessor instructions for cache maintenance. These operations are essential when:

- DMA devices access memory (bypassing cache)
- Code is modified (self-modifying code, JIT compilation)
- Memory-mapped I/O requires uncached access
- Cache coherency must be maintained in multi-core systems

**Cache Maintenance Operations:**

**Clean:** Write dirty cache lines to memory, marking them clean but keeping them in cache.

**Invalidate:** Discard cache line contents without writing back. Use when external entity modified memory.

**Clean and Invalidate:** Write dirty lines to memory, then discard. Ensures memory is current and future reads fetch from memory.

**Cache Operation by Set/Way:**

```assembly
; Clean entire D-cache by set/way
    ; Determine cache geometry (omitted for brevity)
    ; Loop through all sets and ways
    
    MOV     R0, #0                   ; Set index
set_loop:
    MOV     R1, #0                   ; Way index
way_loop:
    ; Create set/way value
    ORR     R2, R0, R1, LSL #30      ; Combine set and way
    MCR     p15, 0, R2, c7, c10, 2   ; DCCSW (clean by set/way)
    ADD     R1, R1, #1
    CMP     R1, #4                   ; 4 ways
    BLT     way_loop
    ADD     R0, R0, #1
    CMP     R0, #128                 ; 128 sets
    BLT     set_loop
```

**Cache Operation by Virtual Address (MVA):**

```assembly
; Clean and invalidate D-cache line containing address in R0
MCR     p15, 0, R0, c7, c14, 1       ; DCCIMVAC

; Invalidate I-cache line containing address in R0
MCR     p15, 0, R0, c7, c5, 1        ; ICIMVAU
```

**Common Cache Maintenance Operations:**

```assembly
; Clean entire D-cache
MOV     R0, #0
MCR     p15, 0, R0, c7, c10, 0       ; DCCSW (implementation-specific)

; Invalidate entire I-cache
MOV     R0, #0
MCR     p15, 0, R0, c7, c5, 0        ; ICIALLU

; Invalidate entire D-cache
MOV     R0, #0
MCR     p15, 0, R0, c7, c6, 0        ; DCISW (use with caution)

; Clean D-cache range by MVA
; R0 = start address, R1 = end address, R2 = line size
clean_range:
    MCR     p15, 0, R0, c7, c10, 1   ; DCCMVAC
    ADD     R0, R0, R2               ; Next cache line
    CMP     R0, R1
    BLT     clean_range
    DSB                              ; Ensure completion
```

**Cache Maintenance Sequence for DMA:**

**Before DMA read (device → memory):**

```assembly
; Invalidate D-cache for buffer to discard stale data
; R0 = buffer address, R1 = buffer size, R2 = cache line size

    ADD     R1, R0, R1               ; End address
    BIC     R0, R0, #31              ; Align to cache line boundary
invalidate_loop:
    MCR     p15, 0, R0, c7, c6, 1    ; DCIMVAC
    ADD     R0, R0, R2
    CMP     R0, R1
    BLT     invalidate_loop
    DSB                              ; Wait for completion
    
    ; Now start DMA operation
```

**After DMA write (memory → device):**

```assembly
; Clean D-cache to ensure data is in memory
; R0 = buffer address, R1 = buffer size, R2 = cache line size

    ADD     R1, R0, R1               ; End address
clean_loop:
    MCR     p15, 0, R0, c7, c10, 1   ; DCCMVAC
    ADD     R0, R0, R2
    CMP     R0, R1
    BLT     clean_loop
    DSB                              ; Wait for completion
    
    ; Now start DMA operation
```

**Self-Modifying Code / JIT Compilation:**

```assembly
; After writing new code to memory
; R0 = code start, R1 = code end, R2 = cache line size

    ; Clean D-cache (write code to memory)
clean_code:
    MCR     p15, 0, R0, c7, c10, 1   ; DCCMVAC
    ADD     R0, R0, R2
    CMP     R0, R1
    BLT     clean_code
    DSB
    
    ; Invalidate I-cache (discard old instructions)
    LDR     R0, =code_start
invalidate_icache:
    MCR     p15, 0, R0, c7, c5, 1    ; ICIMVAU
    ADD     R0, R0, R2
    CMP     R0, R1
    BLT     invalidate_icache
    DSB
    ISB                              ; Synchronize pipeline
    
    ; Now safe to execute new code
```

**Cache Locking:** Some ARM implementations allow locking cache lines to guarantee they remain resident. Useful for deterministic real-time code:

```assembly
; Lock I-cache line (implementation-specific)
MCR     p15, 0, R0, c9, c0, 1        ; Lock I-cache line containing R0

; Lock D-cache line
MCR     p15, 0, R0, c9, c0, 0        ; Lock D-cache line containing R0
```

**Cache Performance Monitoring:** ARM Performance Monitor Unit (PMU) provides counters for cache events:

```assembly
; Enable PMU
MRC     p15, 0, R0, c9, c12, 0       ; Read PMCR
ORR     R0, R0, #1                   ; Enable all counters
MCR     p15, 0, R0, c9, c12, 0       ; Write PMCR

; Configure counter 0 for D-cache misses
MOV     R0, #0x03                    ; Event 0x03 = D-cache refill
MCR     p15, 0, R0, c9, c12, 5       ; Select counter 0
MCR     p15, 0, R0, c9, c13, 1       ; Set event type

; Read counter
MRC     p15, 0, R0, c9, c13, 2       ; Read counter 0 value
```

**Multi-core Cache Coherency:** Modern ARM implementations with multiple cores use hardware cache coherency protocols (MESI, MOESI) through interconnects like CoreLink. Software must still use appropriate barriers:

```assembly
; Ensure visibility across cores
DMB     ; Data Memory Barrier - ensures memory access ordering
DSB     ; Data Synchronization Barrier - waits for completion
ISB     ; Instruction Synchronization Barrier - flushes pipeline
```

**Barrier Variants:**

```assembly
DMB SY   ; System-wide barrier (all domains, all access types)
DMB ST   ; Store barrier only
DMB ISH  ; Inner Shareable domain
DMB OSH  ; Outer Shareable domain
```

**Cache Prefetching:** Explicit prefetch instructions help hide memory latency:

```assembly
PLD     [R0]           ; Prefetch for data load
PLDW    [R0]           ; Prefetch for data write (ARMv7)
PLI     [R0]           ; Prefetch for instruction fetch
```

