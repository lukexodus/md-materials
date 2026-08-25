## Thumb-2 Unified Assembly Language


Thumb-2 introduced Unified Assembly Language (UAL) syntax that works across ARM and Thumb modes:

### UAL Syntax Features

**Width Specifiers:**

```assembly
; Explicit width control
ADD r0, r1, r2          ; Assembler chooses (16-bit if possible)
ADD.N r0, r1, r2        ; Force narrow (16-bit) encoding
ADD.W r0, r1, r2        ; Force wide (32-bit) encoding

; Narrow encoding fails if requirements not met
ADD.N r8, r9, r10       ; Error: high registers need wide encoding
ADD.W r8, r9, r10       ; OK: explicit wide
```

**Conditional Suffix Consistency:**

```assembly
; UAL uses same syntax for ARM and Thumb-2
; In Thumb-2, needs IT block

.arm
ADDGT r0, r1, r2        ; Predicated in ARM

.thumb
CMP r3, #0
IT GT
ADDGT r0, r1, r2        ; Predicated via IT block in Thumb-2
```

**Example** - Code that assembles for both modes:**

```assembly
; UAL code works in both ARM and Thumb-2
function:
    PUSH {r4-r7, lr}
    MOV r4, r0
    ADD r5, r4, #100
    CMP r5, #1000
    IT LT
    MOVLT r0, r5
    POP {r4-r7, pc}

; Assembler generates appropriate encoding for target mode
```

