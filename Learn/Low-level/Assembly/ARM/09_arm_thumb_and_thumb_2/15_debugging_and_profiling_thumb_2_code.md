## Debugging and Profiling Thumb-2 Code


### Instruction Size Analysis

**Example** - Analyzing code size:

```assembly
.thumb
.global function_start
function_start:
    PUSH {r4-r7, lr}        ; 2 bytes
    MOV r4, r0              ; 2 bytes
    ADD r5, r4, #100        ; 2 bytes
    CMP r5, #1000           ; 2 bytes
    IT LT                   ; 2 bytes
    MOVLT r0, r5            ; 2 bytes
    POP {r4-r7, pc}         ; 2 bytes
function_end:

; Total: 14 bytes (7 instructions × 2 bytes each)

; To get size in assembly:
.set function_size, function_end - function_start
```

### Mixed Encoding Example

**Example** - Identifying wide instructions:

```assembly
.thumb
mixed_function:
    PUSH {r4-r7, lr}        ; 16-bit
    MOVW r4, #0x1234        ; 32-bit (wide immediate)
    MOVT r4, #0x5678        ; 32-bit
    ADD.W r5, r8, r9        ; 32-bit (high registers)
    LDR r6, [r4, #200]      ; 32-bit (large offset)
    BFI r6, r5, #8, #8      ; 32-bit (bit field operation)
    ADD r0, r4, r6          ; 16-bit (result)
    POP {r4-r7, pc}         ; 16-bit

; 6 instructions: 3×16-bit + 3×32-bit = 18 bytes
```

