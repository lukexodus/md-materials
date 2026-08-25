## New Instruction Encodings


AArch64 uses fixed 32-bit instruction encoding with a more regular and orthogonal design compared to AArch32.

### Instruction Format

**All Instructions 32-bit:**

```assembly
; No 16-bit Thumb encoding
; Every instruction is exactly 4 bytes
; More regular encoding simplifies decode

ADD X0, X1, X2                  ; 4 bytes
MOV X0, #1                      ; 4 bytes
NOP                             ; 4 bytes
```

**Instruction Categories:**

- Data processing (immediate)
- Data processing (register)
- Load/store
- Branch, exception, system
- SIMD/floating-point

### Load/Store Instructions

**Basic Load/Store:**

```assembly
; Load register
LDR X0, [X1]                    ; Load from [X1] to X0
LDR X0, [X1, #8]                ; Load from [X1 + 8]
LDR W0, [X1]                    ; Load 32-bit word

; Store register
STR X0, [X1]                    ; Store X0 to [X1]
STR X0, [X1, #16]               ; Store to [X1 + 16]
STR W0, [X1]                    ; Store 32-bit word
```

**Addressing Modes:**

```assembly
; Base + offset (unsigned immediate, scaled by size)
LDR X0, [X1, #8]                ; Offset 0-32760, multiple of 8
LDR W0, [X1, #4]                ; Offset 0-16380, multiple of 4
LDRB W0, [X1, #1]               ; Offset 0-4095, byte-aligned

; Base + register offset
LDR X0, [X1, X2]                ; Address = X1 + X2
LDR X0, [X1, X2, LSL #3]        ; Address = X1 + (X2 << 3)
LDR X0, [X1, W2, SXTW #3]       ; Address = X1 + sign_extend(W2) << 3

; Pre-indexed (update base before access)
LDR X0, [X1, #8]!               ; X0 = [X1 + 8], then X1 = X1 + 8

; Post-indexed (update base after access)
LDR X0, [X1], #8                ; X0 = [X1], then X1 = X1 + 8

; PC-relative
LDR X0, label                   ; Load from PC-relative address (±1MB)
ADRP X0, label                  ; Load page address (4KB page)
```

**Example** - Different addressing modes:

```assembly
; Iterate through array
array_loop:
    LDR X0, [X1], #8            ; Post-index: load then increment
    ; Process X0
    SUBS X2, X2, #1
    B.NE array_loop

; Build stack frame
function:
    STP X29, X30, [SP, #-16]!   ; Pre-index: decrement then store
    ; Function body
    LDP X29, X30, [SP], #16     ; Post-index: load then increment
    RET
```

**Load/Store Pair:**

```assembly
; Load/store two registers
LDP X0, X1, [X2]                ; X0 = [X2], X1 = [X2 + 8]
STP X0, X1, [X2]                ; [X2] = X0, [X2 + 8] = X1

; With offset
LDP X0, X1, [X2, #16]           ; Load from X2 + 16, X2 + 24

; Pre/post-indexed
LDP X0, X1, [X2, #16]!          ; Pre-index
LDP X0, X1, [X2], #16           ; Post-index

; Signed offset (can be negative)
LDP X0, X1, [X2, #-16]          ; Load from X2 - 16, X2 - 8
```

**Example** - Efficient structure copy:

```assembly
; Copy structure using pairs
copy_struct:
    ; X0 = dest, X1 = src, X2 = size (multiple of 16)
loop:
    LDP X3, X4, [X1], #16       ; Load 16 bytes, increment src
    STP X3, X4, [X0], #16       ; Store 16 bytes, increment dest
    SUBS X2, X2, #16
    B.GT loop
    RET
```

**Load/Store Exclusive:**

```assembly
; Atomic operations
LDXR X0, [X1]                   ; Load exclusive
; Modify X0
STXR W2, X0, [X1]               ; Store exclusive, W2 = 0 if success

; Pair exclusive
LDXP X0, X1, [X2]               ; Load exclusive pair
STXP W3, X0, X1, [X2]           ; Store exclusive pair

; Acquire/Release variants
LDAXR X0, [X1]                  ; Load-acquire exclusive
STLXR W2, X0, [X1]              ; Store-release exclusive
```

### Data Processing Instructions

**Arithmetic:**

```assembly
; Add/subtract (immediate)
ADD X0, X1, #100                ; X0 = X1 + 100
SUB X0, X1, #50                 ; X0 = X1 - 50
ADDS X0, X1, #10                ; Add and set flags
SUBS X0, X1, #10                ; Subtract and set flags

; Add/subtract (register)
ADD X0, X1, X2                  ; X0 = X1 + X2
SUB X0, X1, X2                  ; X0 = X1 - X2
ADD X0, X1, X2, LSL #3          ; X0 = X1 + (X2 << 3)
SUB X0, X1, X2, LSR #2          ; X0 = X1 - (X2 >> 2)

; Add/subtract with carry
ADC X0, X1, X2                  ; X0 = X1 + X2 + carry
SBC X0, X1, X2                  ; X0 = X1 - X2 - !carry

; Negate
NEG X0, X1                      ; X0 = -X1 (alias for SUB X0, XZR, X1)
NGC X0, X1                      ; X0 = -X1 - !carry
```

**Logical:**

```assembly
; Bitwise operations
AND X0, X1, X2                  ; X0 = X1 & X2
ORR X0, X1, X2                  ; X0 = X1 | X2
EOR X0, X1, X2                  ; X0 = X1 ^ X2
BIC X0, X1, X2                  ; X0 = X1 & ~X2 (bit clear)

; With immediate (complex encoding)
AND X0, X1, #0xFF               ; X0 = X1 & 0xFF
ORR X0, X1, #0xF0F0F0F0F0F0F0F0 ; X0 = X1 | pattern

; Test (logical AND, discard result)
TST X0, X1                      ; Set flags based on X0 & X1
TST X0, #0xFF                   ; Test against immediate
```

**Shift and Rotate:**

```assembly
; Logical shifts
LSL X0, X1, #5                  ; X0 = X1 << 5
LSR X0, X1, #5                  ; X0 = X1 >> 5 (logical)

; Arithmetic shift
ASR X0, X1, #5                  ; X0 = X1 >> 5 (arithmetic, sign-extend)

; Rotate
ROR X0, X1, #5                  ; X0 = rotate_right(X1, 5)

; Variable shift
LSL X0, X1, X2                  ; X0 = X1 << (X2 & 63)
LSR X0, X1, X2                  ; X0 = X1 >> (X2 & 63)
ASR X0, X1, X2                  ; Arithmetic shift by register
ROR X0, X1, X2                  ; Rotate by register
```

**Multiply and Divide:**

```assembly
; Multiply (32-bit and 64-bit)
MUL X0, X1, X2                  ; X0 = X1 * X2 (64-bit)
MUL W0, W1, W2                  ; W0 = W1 * W2 (32-bit)

; Multiply-add/subtract
MADD X0, X1, X2, X3             ; X0 = X3 + (X1 * X2)
MSUB X0, X1, X2, X3             ; X0 = X3 - (X1 * X2)

; High multiply (upper 64 bits of 64x64 -> 128)
SMULH X0, X1, X2                ; X0 = (X1 * X2)[127:64] (signed)
UMULH X0, X1, X2                ; X0 = (X1 * X2)[127:64] (unsigned)

; Divide
SDIV X0, X1, X2                 ; X0 = X1 / X2 (signed)
UDIV X0, X1, X2                 ; X0 = X1 / X2 (unsigned)

; Compute remainder (no dedicated instruction)
UDIV X3, X1, X2                 ; quotient
MSUB X0, X3, X2, X1             ; remainder = dividend - quotient * divisor
```

**Example** - 64-bit multiplication with overflow detection:

```assembly
; Multiply X1 * X2, check for overflow
MUL X0, X1, X2                  ; Lower 64 bits
SMULH X3, X1, X2                ; Upper 64 bits

; Check overflow: upper 64 bits should be all 0 or all 1
CMP X3, X0, ASR #63             ; Compare with sign extension of lower
B.NE overflow                   ; Branch if overflow
```

### Bit Manipulation

**Bit Field Operations:**

```assembly
; Extract bit field (unsigned)
UBFX X0, X1, #8, #8             ; Extract bits [15:8] from X1

; Extract bit field (signed)
SBFX X0, X1, #8, #8             ; Extract bits [15:8], sign-extend

; Insert bit field
BFI X0, X1, #8, #8              ; Insert X1[7:0] into X0[15:8]

; Clear bit field
BFC X0, #8, #8                  ; Clear bits [15:8] of X0

; Example: Pack RGB values
UBFX X3, X0, #0, #8             ; Extract red
UBFX X4, X1, #0, #8             ; Extract green
UBFX X5, X2, #0, #8             ; Extract blue

MOV X6, X3                      ; Start with red
BFI X6, X4, #8, #8              ; Insert green at bits [15:8]
BFI X6, X5, #16, #8             ; Insert blue at bits [23:16]
; X6 = 0x00BBGGRR
```

**Bit Reverse and Count:**

```assembly
; Reverse bits
RBIT    X0, X1                      ; Reverse all 64 bits

; Reverse bytes
REV     X0, X1                      ; Reverse byte order (64-bit)
REV     W0, W1                      ; Reverse byte order (32-bit)
REV16   X0, X1                      ; Reverse bytes within halfwords
REV32   X0, X1                      ; Reverse bytes within words

; Count leading zeros
CLZ     X0, X1                      ; Count leading zeros (64-bit)
CLZ     W0, W1                      ; Count leading zeros (32-bit)

; Count leading sign bits
CLS     X0, X1                      ; Count leading sign bits

; Example: Find highest set bit
CLZ     X0, X1                      ; Count leading zeros
MOV     X2, #63
SUB     X0, X2, X0                  ; Position = 63 - CLZ
````

**Example** - Bit manipulation utilities:

```assembly
; Set bit N
set_bit:
    ; X0 = value, X1 = bit position
    MOV X2, #1
    LSL X2, X2, X1              ; Create mask
    ORR X0, X0, X2              ; Set bit
    RET

; Clear bit N
clear_bit:
    MOV X2, #1
    LSL X2, X2, X1
    BIC X0, X0, X2              ; Clear bit
    RET

; Toggle bit N
toggle_bit:
    MOV X2, #1
    LSL X2, X2, X1
    EOR X0, X0, X2              ; Toggle bit
    RET

; Test bit N (returns 0 or 1)
test_bit:
    LSR X0, X0, X1              ; Shift bit to position 0
    AND X0, X0, #1              ; Mask to single bit
    RET
````

### Move and Select Instructions

**Move Instructions:**

```assembly
; Move immediate (16-bit)
MOV X0, #0x1234                 ; X0 = 0x1234

; Move wide (16-bit immediate to any position)
MOVZ X0, #0x1234, LSL #0        ; X0 = 0x0000000000001234
MOVZ X0, #0x1234, LSL #16       ; X0 = 0x0000000012340000
MOVZ X0, #0x1234, LSL #32       ; X0 = 0x0000123400000000
MOVZ X0, #0x1234, LSL #48       ; X0 = 0x1234000000000000

; Move with keep (insert 16-bit immediate, keep other bits)
MOVK X0, #0x5678, LSL #16       ; Insert 0x5678 at bits [31:16]

; Move with NOT
MOVN X0, #0x1234, LSL #0        ; X0 = ~0x1234 = 0xFFFFFFFFFFFFEDCB

; Building 64-bit constant
MOVZ X0, #0x1234, LSL #0        ; X0 = 0x0000000000001234
MOVK X0, #0x5678, LSL #16       ; X0 = 0x0000000056781234
MOVK X0, #0x9ABC, LSL #32       ; X0 = 0x00009ABC56781234
MOVK X0, #0xDEF0, LSL #48       ; X0 = 0xDEF09ABC56781234
```

**Conditional Select:**

```assembly
; Select based on condition
CSEL X0, X1, X2, EQ             ; X0 = (condition == EQ) ? X1 : X2

; Example conditions:
CSEL X0, X1, X2, EQ             ; Equal
CSEL X0, X1, X2, NE             ; Not equal
CSEL X0, X1, X2, GT             ; Greater than (signed)
CSEL X0, X1, X2, LT             ; Less than (signed)
CSEL X0, X1, X2, GE             ; Greater or equal
CSEL X0, X1, X2, LE             ; Less or equal
CSEL X0, X1, X2, HI             ; Higher (unsigned)
CSEL X0, X1, X2, LS             ; Lower or same (unsigned)

; Conditional select increment
CSINC X0, X1, X2, EQ            ; X0 = (EQ) ? X1 : X2 + 1

; Conditional select invert
CSINV X0, X1, X2, EQ            ; X0 = (EQ) ? X1 : ~X2

; Conditional select negate
CSNEG X0, X1, X2, EQ            ; X0 = (EQ) ? X1 : -X2
```

**Example** - Branchless min/max:

```assembly
; Compute max(X0, X1) without branching
CMP X0, X1
CSEL X0, X0, X1, GT             ; X0 = (X0 > X1) ? X0 : X1

; Compute min(X0, X1)
CMP X0, X1
CSEL X0, X0, X1, LT             ; X0 = (X0 < X1) ? X0 : X1

; Absolute value
CMP X0, XZR                     ; Compare with zero
CSNEG X0, X0, X0, GE            ; X0 = (X0 >= 0) ? X0 : -X0

; Clamp to range [X1, X2]
CMP X0, X1
CSEL X0, X0, X1, GE             ; X0 = max(X0, X1)
CMP X0, X2
CSEL X0, X0, X2, LE             ; X0 = min(X0, X2)
```

**Conditional Compare:**

```assembly
; Conditional compare (register)
CCMP X0, X1, #0, EQ             ; If EQ: compare X0 with X1, else set flags to #0

; Conditional compare (immediate)
CCMP X0, #10, #0, NE            ; If NE: compare X0 with 10, else flags = 0

; Example: Complex condition without branches
; if (a == 10 && b < 20) ...
CMP X0, #10                     ; Compare a with 10
CCMP X1, #20, #0, EQ            ; If EQ, compare b with 20
B.LT then_block                 ; Branch if both conditions true
```

**Example** - Conditional operations in practice:

```assembly
; Traditional branching approach
compute_value:
    CMP X0, #100
    B.LT less_than
    MOV X0, #100                ; Clamp to 100
    B done
less_than:
    CMP X0, #0
    B.GE done
    MOV X0, #0                  ; Clamp to 0
done:
    RET

; Branchless approach with CSEL
compute_value_branchless:
    CMP X0, #100
    MOV X1, #100
    CSEL X0, X1, X0, GT         ; X0 = (X0 > 100) ? 100 : X0
    CMP X0, #0
    CSEL X0, XZR, X0, LT        ; X0 = (X0 < 0) ? 0 : X0
    RET
```

### Branch Instructions

**Unconditional Branch:**

```assembly
; Branch (±128MB range)
B label                         ; Branch to label

; Branch with link (function call)
BL function                     ; LR = PC + 4, PC = function

; Branch to register
BR X0                           ; PC = X0

; Branch with link to register
BLR X0                          ; LR = PC + 4, PC = X0

; Return
RET                             ; PC = LR (alias for BR X30)
RET X0                          ; PC = X0 (return to specific register)
```

**Conditional Branch:**

```assembly
; Branch on condition (±1MB range)
B.EQ label                      ; Branch if equal
B.NE label                      ; Branch if not equal
B.GT label                      ; Branch if greater (signed)
B.LT label                      ; Branch if less (signed)
B.GE label                      ; Branch if greater or equal
B.LE label                      ; Branch if less or equal
B.HI label                      ; Branch if higher (unsigned)
B.LS label                      ; Branch if lower or same
B.CS label                      ; Branch if carry set
B.CC label                      ; Branch if carry clear
B.MI label                      ; Branch if minus (negative)
B.PL label                      ; Branch if plus (positive)
B.VS label                      ; Branch if overflow set
B.VC label                      ; Branch if overflow clear

; Example: Multi-way branch
CMP X0, #10
B.LT case_less
B.EQ case_equal
B.GT case_greater
```

**Compare and Branch:**

```assembly
; Compare and branch on zero
CBZ X0, label                   ; Branch if X0 == 0 (±1MB range)
CBNZ X0, label                  ; Branch if X0 != 0

; Example: Loop with CBZ
loop:
    ; ... loop body ...
    SUBS X0, X0, #1             ; Decrement counter
    B.NE loop                   ; Traditional branch

; Alternative with CBZ (doesn't use flags)
loop2:
    ; ... loop body ...
    SUB X0, X0, #1              ; Decrement (no flags)
    CBNZ X0, loop2              ; Branch if non-zero
```

**Test Bit and Branch:**

```assembly
; Test bit and branch
TBZ X0, #5, label               ; Branch if bit 5 is zero (±32KB range)
TBNZ X0, #5, label              ; Branch if bit 5 is one

; Example: Check flag bit
TBZ X0, #31, not_set            ; Branch if bit 31 clear
    ; Bit is set
not_set:
    ; Bit is clear

; Example: Power-of-two check
; Check if X0 is power of 2 (only one bit set)
SUB X1, X0, #1
TST X0, X1                      ; Power of 2 if result is zero
B.EQ is_power_of_two
```

**Example** - Branch optimization:

```assembly
; Poor: Multiple conditional branches
check_range_poor:
    CMP X0, #0
    B.LT out_of_range
    CMP X0, #100
    B.GT out_of_range
    ; In range
    MOV X0, #1
    RET
out_of_range:
    MOV X0, #0
    RET

; Better: Minimize branches
check_range_better:
    CMP X0, #100
    CCMP X0, #0, #0, LS         ; If X0 <= 100, compare with 0
    CSINC X0, XZR, XZR, GE      ; X0 = (X0 >= 0) ? 1 : 0
    RET
```

### PC-Relative Addressing

**Address Loading:**

```assembly
; Load address of label (±1MB)
ADR X0, label                   ; X0 = address of label

; Load page address (±4GB)
ADRP X0, label                  ; X0 = page address (4KB aligned)
ADD X0, X0, :lo12:label         ; Add page offset (low 12 bits)

; Example: Load from data section
data_section:
    .quad 0x123456789ABCDEF0

code_section:
    ADRP X0, data_section       ; Load page address
    LDR X1, [X0, :lo12:data_section]    ; Load from page + offset
    
; Position-independent code
    ADRP X0, global_var
    ADD X0, X0, :lo12:global_var
    LDR X1, [X0]                ; Access global variable
```

**Example** - Position-independent function:

```assembly
.global pic_function
pic_function:
    ; Access global offset table
    ADRP X0, :got:external_symbol
    LDR X0, [X0, :got_lo12:external_symbol]
    
    ; Call through PLT
    ADRP X1, external_function
    ADD X1, X1, :lo12:external_function
    BLR X1
    
    RET
```

### System Instructions

**Memory Barriers:**

```assembly
; Data memory barrier
DMB SY                          ; Full system DMB
DMB ISH                         ; Inner shareable
DMB ISHST                       ; Inner shareable, stores only
DMB LD                          ; Load barrier
DMB ST                          ; Store barrier

; Data synchronization barrier
DSB SY                          ; Full system DSB
DSB ISH                         ; Inner shareable

; Instruction synchronization barrier
ISB                             ; Flush pipeline

; Example: Proper synchronization
    STR X0, [X1]                ; Write data
    DMB ISH                     ; Ensure write visible
    MOV X2, #1
    STR X2, [X3]                ; Write flag
```

**Cache Operations:**

```assembly
; Data cache operations
DC CIVAC, X0                    ; Clean and invalidate by VA to PoC
DC CVAC, X0                     ; Clean by VA to PoC
DC IVAC, X0                     ; Invalidate by VA to PoC
DC ZVA, X0                      ; Zero cache line

; Instruction cache operations
IC IVAU, X0                     ; Invalidate by VA to PoU
IC IALLU                        ; Invalidate all to PoU

; Example: Self-modifying code
    ; Write new instructions
    STR X0, [X1]
    DC CVAU, X1                 ; Clean data cache
    DSB ISH                     ; Ensure completion
    IC IVAU, X1                 ; Invalidate instruction cache
    DSB ISH
    ISB                         ; Synchronize pipeline
```

**System Register Access:**

```assembly
; Read system register
MRS X0, MPIDR_EL1               ; Read multiprocessor affinity register
MRS X0, CNTFRQ_EL0              ; Read counter frequency
MRS X0, CNTVCT_EL0              ; Read virtual counter

; Write system register
MSR TTBR0_EL1, X0               ; Write translation table base
MSR VBAR_EL1, X0                ; Write vector base address

; Example: Read CPU ID
MRS X0, MIDR_EL1                ; Main ID register
UBFX X1, X0, #4, #12            ; Extract part number
UBFX X2, X0, #16, #4            ; Extract variant
UBFX X3, X0, #20, #4            ; Extract architecture
```

**Hint Instructions:**

```assembly
; No operation
NOP                             ; No operation

; Yield (in spin-loops)
YIELD                           ; Hint to scheduler

; Wait for event/interrupt
WFE                             ; Wait for event
WFI                             ; Wait for interrupt
SEV                             ; Send event
SEVL                            ; Send event local

; Example: Spinlock with yield
spin_lock:
    LDAXR W1, [X0]              ; Load-acquire exclusive
    CBNZ W1, spin_lock_retry    ; If locked, retry
    MOV W1, #1
    STXR W2, W1, [X0]           ; Try to acquire
    CBNZ W2, spin_lock          ; Retry if failed
    RET

spin_lock_retry:
    YIELD                       ; Hint to other threads
    B spin_lock
```

