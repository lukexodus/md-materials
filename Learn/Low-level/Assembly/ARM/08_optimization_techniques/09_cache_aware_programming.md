## Cache-Aware Programming


Cache optimization focuses on maximizing data locality and minimizing cache misses to improve memory access performance.

**Cache hierarchy understanding:**

- L1 cache: 16-64KB, 1-4 cycle latency
- L2 cache: 256KB-2MB, 10-20 cycle latency
- L3 cache: 2-32MB, 30-50 cycle latency (if present)
- Main memory: 100-300+ cycle latency
- Cache line size: typically 64 bytes on ARM

**Spatial locality optimization:**

**Structure of arrays (SoA) vs Array of structures (AoS):**

```asm
; Array of Structures - poor cache utilization
; struct { int x, y, z, padding; } points[N];
; Processing only x coordinates loads unnecessary data
loop:
    LDR r0, [r4]        ; Load x (also brings y, z into cache)
    ADD r0, r0, #1
    STR r0, [r4], #16   ; Skip to next structure (wastes cache line)
    SUBS r1, r1, #1
    BNE loop

; Structure of Arrays - better cache utilization
; int x[N], y[N], z[N];
; Processing x coordinates uses cache efficiently
loop:
    LDR r0, [r4]        ; Load x (next elements in same cache line)
    ADD r0, r0, #1
    STR r0, [r4], #4    ; Sequential access
    SUBS r1, r1, #1
    BNE loop
```

**Sequential memory access patterns:**

```asm
; Good - sequential access (cache-friendly)
MOV r2, #0
loop:
    LDR r0, [r4, r2]    ; Sequential loads
    ; process r0
    ADD r2, r2, #4
    CMP r2, #1024
    BLT loop

; Poor - strided access with large stride
MOV r2, #0
loop:
    LDR r0, [r4, r2]    ; Stride of 256 bytes may cross cache lines
    ; process r0
    ADD r2, r2, #256
    CMP r2, #4096
    BLT loop
```

**Temporal locality optimization:**

**Data reuse within registers:**

```asm
; Poor - repeated loads from memory
loop:
    LDR r0, [r4]
    ADD r0, r0, #1
    STR r0, [r4]
    LDR r0, [r4]        ; Redundant load
    MUL r0, r0, r1
    STR r0, [r4]
    SUBS r2, r2, #1
    BNE loop

; Good - keep data in registers
loop:
    LDR r0, [r4]
    ADD r0, r0, #1
    MUL r0, r0, r1      ; Reuse r0 from register
    STR r0, [r4]
    SUBS r2, r2, #1
    BNE loop
```

**Cache line alignment:**

```asm
; Align frequently accessed data to cache line boundaries
.align 6                ; 64-byte alignment (2^6)
hot_data:
    .word 0, 0, 0, 0    ; Ensure critical data starts on cache line
    ; ...

; Align loop entry points
.align 4                ; 16-byte alignment for code
hot_loop:
    ; frequently executed loop body
    SUBS r0, r0, #1
    BNE hot_loop
```

**Prefetching (explicit):**

```asm
; ARM has PLD (Preload Data) instruction
; [Inference] PLD effectiveness depends on processor implementation
loop:
    PLD [r4, #64]       ; Prefetch data 64 bytes ahead
    LDR r0, [r4]
    ; process r0
    STR r0, [r5], #4
    ADD r4, r4, #4
    SUBS r1, r1, #1
    BNE loop
```

**Loop blocking/tiling for cache:**

```asm
; Matrix multiplication with blocking
; Instead of processing entire rows/columns,
; process small blocks that fit in cache

; Outer loops over blocks
outer_i:
    ; ...
outer_j:
    ; Inner loops process block elements
    ; Block size chosen to fit in L1 cache
    MOV r8, #0          ; block_i
block_loop_i:
    MOV r9, #0          ; block_j
block_loop_j:
        ; Actual computation on cache-resident data
        LDR r0, [r4]
        LDR r1, [r5]
        MLA r2, r0, r1, r2
        ; ...
        ADD r9, r9, #1
        CMP r9, #BLOCK_SIZE
        BLT block_loop_j
    ADD r8, r8, #1
    CMP r8, #BLOCK_SIZE
    BLT block_loop_i
```

**Avoid cache thrashing:**

```asm
; Problem: Multiple arrays with same cache set mapping
; If array_a[i] and array_b[i] map to same cache sets,
; they evict each other (conflict misses)

; Solution: Pad arrays or use different access patterns
.align 6
array_a:
    .space 4096
    .space 64           ; Padding to change cache mapping
array_b:
    .space 4096
```

**Write combining and memory barriers:**

```asm
; Buffered writes improve performance
STR r0, [r4]            ; May be buffered
STR r1, [r4, #4]
STR r2, [r4, #8]
DMB                     ; Memory barrier when ordering required

; Use appropriate barriers
DMB SY                  ; Full system barrier
DMB ISH                 ; Inner shareable domain
DSB                     ; Data synchronization barrier
ISB                     ; Instruction synchronization barrier
```

**Key Points:**

- Strength reduction saves cycles by replacing expensive operations with cheaper equivalents
- Common subexpression elimination reduces redundant calculations
- Branch prediction optimization minimizes pipeline stalls through predictable patterns and branchless code
- Cache-aware programming maximizes data locality and minimizes memory latency through sequential access, blocking, and alignment

**Important considerations:** For specific performance characteristics, actual measurements on target hardware are necessary as cache behavior, branch prediction accuracy, and instruction timing vary significantly across ARM processor implementations [Inference - based on documented architectural differences between ARM Cortex-A series, Cortex-M series, and custom implementations].

---

