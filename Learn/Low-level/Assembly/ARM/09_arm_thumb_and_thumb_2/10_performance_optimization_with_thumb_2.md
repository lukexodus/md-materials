## Performance Optimization with Thumb-2


### When to Use Narrow vs Wide Encodings

**Prefer narrow (16-bit) for:**

- Low register operations (r0-r7)
- Small immediate values
- Simple operations without shifts
- Common instruction sequences

**Require wide (32-bit) for:**

- High register operations (r8-r15)
- Large immediate values
- Shifted operands in data processing
- Extended addressing modes
- Complex operations (divide, bit fields)

**Example** - Optimizing for code density:**

```assembly
; Good: Maximum use of narrow encodings
function_compact:
    PUSH {r4-r7, lr}        ; 16-bit
    MOV r4, r0              ; 16-bit (low registers)
    MOV r5, r1              ; 16-bit
    ADD r4, r4, r5          ; 16-bit
    MOV r0, r4              ; 16-bit
    POP {r4-r7, pc}         ; 16-bit
; Total: 12 bytes

; Poor: Unnecessary wide encodings
function_bloated:
    PUSH.W {r4-r7, lr}      ; 32-bit (unnecessary .W)
    MOV.W r4, r0            ; 32-bit (unnecessary .W)
    MOV.W r5, r1            ; 32-bit
    ADD.W r4, r4, r5        ; 32-bit
    MOV.W r0, r4            ; 32-bit
    POP.W {r4-r7, pc}       ; 32-bit
; Total: 24 bytes (100% larger!)
```

### Register Allocation for Thumb-2

**Strategy:** Prioritize low registers (r0-r7) for hot code paths:

```assembly
; Optimized: Important variables in low registers
hot_loop:
    ; r0-r3: frequently accessed variables (narrow encodings)
    LDR r0, [r4]            ; 16-bit
    ADD r1, r1, r0          ; 16-bit
    STR r1, [r4], #4        ; 16-bit
    SUBS r3, r3, #1         ; 16-bit
    BNE hot_loop            ; 16-bit

; Unoptimized: Using high registers unnecessarily
hot_loop_bad:
    ; r8-r10: force 32-bit encodings
    LDR r8, [r4]            ; 32-bit
    ADD.W r9, r9, r8        ; 32-bit
    STR r8, [r4], #4        ; 32-bit
    SUBS r10, r10, #1       ; 32-bit
    BNE hot_loop_bad        ; 16-bit
```

### Mixing IT Blocks and Branches

**Example** - When to use IT vs branches:**

```assembly
; IT block: Good for 1-4 simple instructions
CMP r0, #10
ITE GT
ADDGT r1, r1, #1
MOVLE r1, #0

; Branch: Better for longer conditional blocks
CMP r0, #10
BLE else_case
    ; Multiple instructions when > 10
    ADD r1, r1, #1
    MOV r2, #5
    MUL r3, r1, r2
    STR r3, [r4]
    B endif
else_case:
    ; Multiple instructions when <= 10
    MOV r1, #0
    MOV r2, #0
    STR r2, [r4]
endif:
```

### Literal Pool Management

Thumb-2 PC-relative loads have limited range (±4KB):

```assembly
; Close literal (within ±4KB)
LDR r0, =value          ; Assembler generates PC-relative load
; ...
value: .word 0x12345678

; Far literal (beyond range)
LDR r0, =far_value      ; May need veneer or different approach

; Better: Use MOVW/MOVT for constants
MOVW r0, #0x5678
MOVT r0, #0x1234        ; r0 = 0x12345678 (no literal pool needed)
```

**Example** - Efficient constant loading:**

```assembly
; Poor: Excessive literal pool usage
LDR r0, =0x12345678     ; Literal pool entry
LDR r1, =0x87654321     ; Another entry
LDR r2, =0xABCDEF00     ; Another entry
; 3 literal pool entries = 12 bytes + load overhead

; Better: Use MOVW/MOVT
MOVW r0, #0x5678
MOVT r0, #0x1234        ; 8 bytes, no pool access
MOVW r1, #0x4321
MOVT r1, #0x8765        ; 8 bytes
MOVW r2, #0xEF00
MOVT r2, #0xABCD        ; 8 bytes
; Total: 24 bytes but faster (no memory access), no pool
```

