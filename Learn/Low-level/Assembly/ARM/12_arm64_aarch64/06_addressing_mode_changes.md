## Addressing Mode Changes


AArch64 introduces a simplified and more consistent addressing mode system compared to AArch32, removing some complex modes while adding new capabilities.

**Register changes:**

```asm
; AArch64 has 31 general-purpose registers (64-bit)
; X0-X30: 64-bit registers
; W0-W30: 32-bit access to lower half of X registers
; XZR/WZR: Zero register (reads as 0, writes discarded)
; SP: Stack pointer (no longer a general-purpose register)
; PC: Not directly accessible (no longer R15)

; Example register usage
MOV X0, #42                 ; 64-bit operation
MOV W0, #42                 ; 32-bit operation (upper 32 bits zeroed)
ADD X1, X2, X3              ; X1 = X2 + X3
ADD W1, W2, W3              ; W1 = W2 + W3 (32-bit)

; Zero register usage
MOV X0, XZR                 ; X0 = 0
CMP X1, XZR                 ; Compare with zero
STR XZR, [X0]               ; Store zero to memory
```

**Base addressing modes:**

**Offset addressing (base + offset):**

```asm
; Immediate offset (scaled or unscaled)
LDR X0, [X1]                ; Load from [X1]
LDR X0, [X1, #8]            ; Load from [X1 + 8]
LDR X0, [X1, #-16]          ; Load from [X1 - 16]
STR X0, [X1, #24]           ; Store to [X1 + 24]

; Scaled immediate (multiplied by operand size)
LDR X0, [X1, #8]            ; Offset 8 bytes (scaled for 64-bit)
LDR W0, [X1, #4]            ; Offset 4 bytes (scaled for 32-bit)
LDRH W0, [X1, #2]           ; Offset 2 bytes (scaled for 16-bit)
LDRB W0, [X1, #1]           ; Offset 1 byte

; Unscaled immediate offset
LDUR X0, [X1, #-5]          ; Unscaled offset (any value -256 to 255)
STUR X0, [X1, #-5]          ; Store with unscaled offset

; Register offset (extended or shifted)
LDR X0, [X1, X2]            ; Load from [X1 + X2]
LDR X0, [X1, X2, LSL #3]    ; Load from [X1 + (X2 << 3)]
LDR X0, [X1, W2, UXTW]      ; Load from [X1 + zero_extend(W2)]
LDR X0, [X1, W2, SXTW #3]   ; Load from [X1 + sign_extend(W2) << 3]
```

**Pre-indexed addressing (update base before access):**

```asm
; Pre-indexed with writeback
LDR X0, [X1, #16]!          ; X0 = *[X1 + 16], then X1 += 16
STR X0, [X1, #-8]!          ; X1 -= 8, then *[X1] = X0

; Useful for stack operations
STR X0, [SP, #-16]!         ; Push: SP -= 16, then store
LDR X0, [SP, #16]!          ; Pop: load, then SP += 16
```

**Post-indexed addressing (update base after access):**

```asm
; Post-indexed with writeback
LDR X0, [X1], #8            ; X0 = *[X1], then X1 += 8
STR X0, [X1], #16           ; *[X1] = X0, then X1 += 16

; Useful for array traversal
loop:
    LDR X0, [X1], #8        ; Load and advance pointer
    ; Process X0
    SUBS X2, X2, #1
    B.NE loop
```

**PC-relative addressing:**

```asm
; ADR: Calculate address relative to PC
ADR X0, label               ; X0 = address of label (±1MB range)
ADR X0, data_table          ; X0 = address of data_table

; ADRP: Calculate page address relative to PC
ADRP X0, label              ; X0 = page address of label (±4GB range)
ADD X0, X0, :lo12:label     ; Add low 12 bits for full address

; Load from PC-relative address
ADRP X0, my_data
LDR X1, [X0, :lo12:my_data]

; Example: Access global variable
ADRP X0, global_var
LDR W1, [X0, :lo12:global_var]
ADD W1, W1, #1
STR W1, [X0, :lo12:global_var]

label:
    .quad 0x123456789ABCDEF0
my_data:
    .word 42
global_var:
    .word 0
```

**Literal pool addressing (removed explicit literal pools):**

```asm
; AArch32 style (not available in AArch64)
; LDR R0, =0x12345678        ; Load from literal pool

; AArch64 alternatives:

; Method 1: MOV with immediate (for values that fit)
MOV X0, #0x1234             ; 16-bit immediate
MOVK X0, #0x5678, LSL #16   ; Insert 16 bits at position

; Method 2: Load from nearby memory
ADRP X0, constant_pool
LDR X1, [X0, :lo12:constant_value]

; Method 3: Build with multiple instructions
MOV X0, #0x5678
MOVK X0, #0x1234, LSL #16
MOVK X0, #0xABCD, LSL #32
MOVK X0, #0xEF00, LSL #48

constant_pool:
constant_value:
    .quad 0x123456789ABCDEF0
```

**Load/Store pair operations:**

```asm
; Load/store two registers simultaneously
LDP X0, X1, [X2]            ; X0 = [X2], X1 = [X2 + 8]
STP X0, X1, [X2]            ; [X2] = X0, [X2 + 8] = X1

; With offset
LDP X0, X1, [X2, #16]       ; Load from [X2 + 16] and [X2 + 24]
STP X0, X1, [X2, #32]       ; Store to [X2 + 32] and [X2 + 40]

; With pre-index
LDP X0, X1, [X2, #16]!      ; X2 += 16, then load
STP X0, X1, [X2, #-16]!     ; X2 -= 16, then store

; With post-index
LDP X0, X1, [X2], #16       ; Load, then X2 += 16
STP X0, X1, [X2], #16       ; Store, then X2 += 16

; Stack operations using pairs
STP X29, X30, [SP, #-16]!   ; Push frame pointer and link register
LDP X29, X30, [SP], #16     ; Pop frame pointer and link register

; Function prologue/epilogue
function_entry:
    STP X29, X30, [SP, #-32]!   ; Save FP, LR
    STP X19, X20, [SP, #16]     ; Save callee-saved registers
    MOV X29, SP                  ; Setup frame pointer
    ; Function body
    LDP X19, X20, [SP, #16]     ; Restore registers
    LDP X29, X30, [SP], #32     ; Restore FP, LR
    RET
```

**Exclusive load/store (atomic operations):**

```asm
; Load exclusive
LDXR X0, [X1]               ; Load exclusive (64-bit)
LDXR W0, [X1]               ; Load exclusive (32-bit)
LDXRH W0, [X1]              ; Load exclusive (16-bit)
LDXRB W0, [X1]              ; Load exclusive (8-bit)

; Store exclusive (returns 0 on success, 1 on failure)
STXR W2, X0, [X1]           ; Store exclusive (64-bit)
STXR W2, W0, [X1]           ; Store exclusive (32-bit)
STXRH W2, W0, [X1]          ; Store exclusive (16-bit)
STXRB W2, W0, [X1]          ; Store exclusive (8-bit)

; Atomic increment example
atomic_inc:
retry:
    LDXR X0, [X1]           ; Load exclusive
    ADD X0, X0, #1          ; Increment
    STXR W2, X0, [X1]       ; Store exclusive
    CBNZ W2, retry          ; Retry if failed
    RET

; Load/store acquire/release exclusive
LDAXR X0, [X1]              ; Load acquire exclusive
STLXR W2, X0, [X1]          ; Store release exclusive
```

**Comparison with AArch32:**

```asm
; AArch32: Complex flexible second operand
ADD R0, R1, R2, LSL #3      ; R0 = R1 + (R2 << 3)
ADD R0, R1, R2, ROR #8      ; R0 = R1 + rotate_right(R2, 8)

; AArch64: Simpler, separate shift instructions
LSL X2, X2, #3              ; X2 = X2 << 3
ADD X0, X1, X2              ; X0 = X1 + X2

; But register offset in memory access still supported
LDR X0, [X1, X2, LSL #3]    ; Load from [X1 + (X2 << 3)]

; AArch32: Auto-increment addressing with multiple registers
LDMIA R0!, {R1-R5}          ; Load R1-R5, increment R0

; AArch64: Must use pairs or individual loads
LDP X1, X2, [X0], #16       ; Load pair and increment
LDP X3, X4, [X0], #16
LDR X5, [X0], #8

; AArch32: Conditional execution
ADDNE R0, R1, R2            ; Execute if not equal

; AArch64: Conditional select instead
CSEL X0, X1, X2, NE         ; X0 = (NE) ? X1 : X2
```

