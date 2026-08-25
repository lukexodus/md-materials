## Code Density Benefits


Code density refers to the amount of functionality achieved per byte of instruction memory. Thumb instruction sets reduce code size significantly compared to the standard 32-bit ARM instruction set.

### Instruction Encoding Comparison

**ARM (32-bit):** Every instruction is 4 bytes

```assembly
; ARM mode - each instruction is 32 bits
ADD r0, r1, r2      ; 4 bytes
MOV r3, #100        ; 4 bytes
LDR r4, [r5]        ; 4 bytes
B target            ; 4 bytes
; Total: 16 bytes
```

**Thumb (16-bit):** Most instructions are 2 bytes

```assembly
; Thumb mode - most instructions are 16 bits
ADD r0, r1, r2      ; 2 bytes (low registers)
MOV r3, #100        ; 2 bytes
LDR r4, [r5]        ; 2 bytes
B target            ; 2 bytes (short range)
; Total: 8 bytes (50% reduction)
```

**Thumb-2 (mixed):** 16-bit and 32-bit instructions

```assembly
; Thumb-2 mode - intelligent mix
ADD r0, r1, r2      ; 2 bytes (common case)
MOVW r3, #1000      ; 4 bytes (wide immediate)
LDR r4, [r5, #128]  ; 2 bytes (offset in range)
B target            ; 2 or 4 bytes depending on distance
; Total: 10 bytes (37.5% reduction, more flexible)
```

### Code Size Statistics

[Inference] Typical code size reductions compared to ARM:

- **Thumb:** 65-70% of ARM code size (30-35% reduction)
- **Thumb-2:** 74-78% of ARM code size (22-26% reduction)
- Thumb-2 approaches Thumb density while maintaining near-ARM functionality

### Register Access Limitations in Thumb

Original Thumb (ARMv4T-ARMv6) restricts most operations to low registers (r0-r7):

```assembly
; Thumb - low register operations (16-bit)
ADD r0, r1, r2      ; Valid - all low registers
MOV r3, r4          ; Valid - low registers

; High register access requires special encoding
MOV r8, r0          ; Special encoding for high registers
ADD r0, r8, r9      ; Not available in original Thumb
```

Thumb-2 removes most register restrictions:

```assembly
; Thumb-2 - full register access
ADD r0, r1, r2      ; 16-bit encoding
ADD r8, r9, r10     ; 32-bit encoding (high registers)
ADD.W r0, r1, r2    ; 32-bit encoding (explicit wide)
```

### Memory Footprint Impact

**Example** - Function code size comparison:

```assembly
; ARM mode (32-bit instructions)
function_arm:
    PUSH {r4-r7, lr}        ; 4 bytes
    MOV r4, r0              ; 4 bytes
    MOV r5, r1              ; 4 bytes
    LDR r6, =constant       ; 4 bytes
    ADD r4, r4, r5          ; 4 bytes
    MUL r4, r4, r6          ; 4 bytes
    MOV r0, r4              ; 4 bytes
    POP {r4-r7, pc}         ; 4 bytes
; Total: 32 bytes

; Thumb-2 mode (mixed encoding)
function_thumb2:
    PUSH {r4-r7, lr}        ; 2 bytes
    MOV r4, r0              ; 2 bytes
    MOV r5, r1              ; 2 bytes
    LDR r6, =constant       ; 4 bytes (PC-relative load)
    ADD r4, r4, r5          ; 2 bytes
    MUL r4, r4, r6          ; 2 bytes
    MOV r0, r4              ; 2 bytes
    POP {r4-r7, pc}         ; 2 bytes
; Total: 18 bytes (43.75% reduction)
```

### Cache and Memory Benefits

**Instruction Cache Efficiency:**

- Smaller code fits more functions in cache
- Reduced cache misses improve performance
- [Inference] 30% code size reduction can increase effective cache capacity by ~43%

**Memory Bandwidth:**

- Fetching 16-bit instructions uses half the bus bandwidth
- Particularly beneficial for systems with narrow memory buses
- Flash memory systems benefit from reduced storage requirements

**Example** - Cache line utilization (32-byte cache line):

```
ARM mode (32-bit instructions):
- Fits 8 instructions per cache line
- Function needing 12 instructions = 2 cache lines

Thumb-2 mode (mostly 16-bit):
- Fits ~14-16 instructions per cache line  
- Same 12-instruction function = 1 cache line
- Reduced cache pollution
```

