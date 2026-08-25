## Thumb-2 Exclusive Instructions


Thumb-2 introduces instructions not available in standard ARM or original Thumb, optimized for specific operations.

### Bit Field Instructions

**BFI - Bit Field Insert:**

```assembly
; BFI Rd, Rn, #lsb, #width
; Insert bits from Rn into Rd at position lsb, width bits

; Example: Insert bits [7:0] of r1 into bits [15:8] of r0
BFI r0, r1, #8, #8

; Before: r0 = 0xXXXXYYYY, r1 = 0xZZZZWWAA
; After:  r0 = 0xXXXXAAYY (AA inserted at bit 8)
```

**BFC - Bit Field Clear:**

```assembly
; BFC Rd, #lsb, #width
; Clear width bits starting at lsb position

; Example: Clear bits [11:4]
BFC r0, #4, #8

; Before: r0 = 0xABCDEF12
; After:  r0 = 0xABCD0002 (bits [11:4] cleared)
```

**UBFX - Unsigned Bit Field Extract:**

```assembly
; UBFX Rd, Rn, #lsb, #width
; Extract width bits from Rn starting at lsb, zero-extended

; Example: Extract bits [19:12] from r0 to r1
UBFX r1, r0, #12, #8

; Before: r0 = 0xABCDEF12
; After:  r1 = 0x000000DE (extracted and zero-extended)
```

**SBFX - Signed Bit Field Extract:**

```assembly
; SBFX Rd, Rn, #lsb, #width  
; Extract width bits from Rn starting at lsb, sign-extended

; Example: Extract signed 8-bit value from bits [15:8]
SBFX r1, r0, #8, #8

; Before: r0 = 0x0000FF00
; After:  r1 = 0xFFFFFFFF (extracted 0xFF, sign-extended)
```

**Example** - Practical bit field usage:

```assembly
; Pack RGB values into single 32-bit word
; r0 = red (8-bit), r1 = green (8-bit), r2 = blue (8-bit)
; Result: [31:24]=alpha, [23:16]=red, [15:8]=green, [7:0]=blue

MOV r3, #0xFF           ; Alpha = 255
BFI r3, r0, #16, #8     ; Insert red at bit 16
BFI r3, r1, #8, #8      ; Insert green at bit 8  
BFI r3, r2, #0, #8      ; Insert blue at bit 0
; r3 now contains 0xFFRRGGBB

; Unpack RGB
UBFX r0, r3, #16, #8    ; Extract red
UBFX r1, r3, #8, #8     ; Extract green
UBFX r2, r3, #0, #8     ; Extract blue
```

### Divide Instructions

Thumb-2 includes hardware divide instructions (on cores with divide support):

**UDIV - Unsigned Divide:**

```assembly
; UDIV Rd, Rn, Rm
; Rd = Rn / Rm (unsigned)

UDIV r0, r1, r2         ; r0 = r1 / r2 (unsigned)

; Example: Divide 100 by 3
MOV r1, #100
MOV r2, #3
UDIV r0, r1, r2         ; r0 = 33
```

**SDIV - Signed Divide:**

```assembly
; SDIV Rd, Rn, Rm
; Rd = Rn / Rm (signed)

SDIV r0, r1, r2         ; r0 = r1 / r2 (signed)

; Example: Divide -100 by 3
MOV r1, #-100
MOV r2, #3
SDIV r0, r1, r2         ; r0 = -33
```

**Computing Remainder:**

```assembly
; Hardware doesn't provide remainder directly
; Compute manually: remainder = dividend - (quotient * divisor)

; r0 = r1 % r2 (unsigned modulo)
UDIV r3, r1, r2         ; r3 = r1 / r2
MLS r0, r3, r2, r1      ; r0 = r1 - (r3 * r2)

; Example: 17 % 5 = 2
MOV r1, #17
MOV r2, #5
UDIV r3, r1, r2         ; r3 = 3
MLS r0, r3, r2, r1      ; r0 = 17 - (3 * 5) = 2
```

**Example** - Division with error checking:

```assembly
; Safe divide with zero check
CMP r2, #0
ITE NE
UDIVNE r0, r1, r2       ; Divide if denominator != 0
MOVNE r0, #0            ; Return 0 if divide by zero
```

**Performance:** [Inference] Hardware divide typically takes 2-12 cycles depending on core, vastly faster than software division routines which can take 50+ cycles.

### Multiply and Accumulate Enhancements

**MLS - Multiply and Subtract:**

```assembly
; MLS Rd, Rn, Rm, Ra
; Rd = Ra - (Rn * Rm)

MLS r0, r1, r2, r3      ; r0 = r3 - (r1 * r2)

; Example: Compute remainder in single instruction
; remainder = dividend - (quotient * divisor)
MOV r1, #17             ; dividend
MOV r2, #5              ; divisor
UDIV r3, r1, r2         ; quotient = 3
MLS r0, r3, r2, r1      ; r0 = 17 - (3 * 5) = 2
```

**SMMUL/SMMLA/SMMLS - Signed Most Significant Word Multiply:**

```assembly
; SMMUL Rd, Rn, Rm
; Rd = (Rn * Rm) >> 32 (top 32 bits of 64-bit signed product)

SMMUL r0, r1, r2        ; High 32 bits of r1 * r2

; Useful for fixed-point arithmetic
; Example: Multiply two Q31 fixed-point numbers
; Result in Q31 format (1 sign bit, 31 fraction bits)
SMMUL r0, r1, r2        ; High word = Q31 * Q31 result
```

**SMMLA - Signed Most Significant Word Multiply Accumulate:**

```assembly
; SMMLA Rd, Rn, Rm, Ra
; Rd = Ra + ((Rn * Rm) >> 32)

SMMLA r0, r1, r2, r3    ; r0 = r3 + high32(r1 * r2)
```

### Compare and Branch Instructions

**CBZ/CBNZ - Compare and Branch on Zero/Non-Zero:**

```assembly
; CBZ Rn, label
; Branch to label if Rn == 0 (does not affect flags)

CBZ r0, target          ; Branch if r0 == 0
; ... code if r0 != 0 ...
target:

; CBNZ Rn, label  
; Branch to label if Rn != 0

CBNZ r1, loop           ; Branch if r1 != 0
```

**Benefits:**

- Single instruction (compare + branch combined)
- Doesn't modify condition flags
- Smaller code size than CMP + Bcc
- Limited range (±126 bytes forward/backward)

**Example** - Loop countdown:

```assembly
; Traditional
loop:
    ; ... loop body ...
    SUBS r0, r0, #1
    BNE loop

; With CBNZ (doesn't affect flags if needed elsewhere)
loop:
    ; ... loop body ...
    SUB r0, r0, #1      ; Don't update flags
    CBNZ r0, loop       ; Branch if non-zero
```

**Example** - Null pointer check:

```assembly
; Traditional
CMP r0, #0
BEQ handle_null
; ... process pointer in r0 ...
handle_null:

; With CBZ (more compact)
CBZ r0, handle_null
; ... process pointer in r0 ...
handle_null:
```

### Table Branch Instructions

**TBB/TBH - Table Branch Byte/Halfword:**

```assembly
; TBB [Rn, Rm]
; Branch forward by byte offset in table at [Rn + Rm]

; TBH [Rn, Rm, LSL #1]
; Branch forward by halfword offset in table

; Example: Jump table for switch statement
; r0 = case value (0-3)

    TBB [pc, r0]            ; Branch using byte table
branch_table:
    .byte (case0 - branch_table) / 2
    .byte (case1 - branch_table) / 2
    .byte (case2 - branch_table) / 2
    .byte (case3 - branch_table) / 2

case0:
    ; Handle case 0
    B end_switch
case1:
    ; Handle case 1
    B end_switch
case2:
    ; Handle case 2
    B end_switch
case3:
    ; Handle case 3
end_switch:
```

**Example** - Halfword table for larger ranges:

```assembly
; TBH for switch with distant targets
    CMP r0, #4
    BHS default_case        ; Bounds check
    TBH [pc, r0, LSL #1]    ; r0 * 2 for halfword indexing

branch_table:
    .hword (case0 - branch_table) / 2
    .hword (case1 - branch_table) / 2
    .hword (case2 - branch_table) / 2
    .hword (case3 - branch_table) / 2

; Cases can be up to 128KB away with TBH
```

**Benefits:**

- Compact jump table representation
- Single cycle dispatch (table already in cache)
- Efficient for dense switch statements

### Load/Store Dual

**LDRD/STRD - Load/Store Register Dual:**

```assembly
; LDRD Rt, Rt2, [Rn, #imm]
; Load two consecutive registers from memory

LDRD r0, r1, [r2]       ; r0 = [r2], r1 = [r2+4]
LDRD r0, r1, [r2, #16]  ; r0 = [r2+16], r1 = [r2+20]

; STRD Rt, Rt2, [Rn, #imm]
; Store two consecutive registers to memory

STRD r0, r1, [r2]       ; [r2] = r0, [r2+4] = r1
STRD r0, r1, [r2, #16]  ; [r2+16] = r0, [r2+20] = r1
```

**Example** - 64-bit value handling:

```assembly
; Load 64-bit timestamp
LDR r0, =timestamp_addr
LDRD r2, r3, [r0]       ; r2 = lower 32 bits, r3 = upper 32 bits

; Manipulate 64-bit value
ADDS r2, r2, #1000      ; Add to lower word
ADC r3, r3, #0          ; Add carry to upper word

; Store back
STRD r2, r3, [r0]
```

**Benefits:**

- Single instruction for two word transfers
- [Inference] May complete in single memory cycle on 64-bit buses
- Useful for structure copying and 64-bit operations

### Move Wide Instructions

**MOVW - Move 16-bit immediate:**

```assembly
; MOVW Rd, #imm16
; Move 16-bit immediate to register, zero upper bits

MOVW r0, #0x1234        ; r0 = 0x00001234
MOVW r1, #0xABCD        ; r1 = 0x0000ABCD
```

**MOVT - Move Top:**

```assembly
; MOVT Rd, #imm16
; Move 16-bit immediate to upper half of register, preserve lower bits

MOVW r0, #0x1234        ; r0 = 0x00001234
MOVT r0, #0x5678        ; r0 = 0x56781234
```

### Push/Pop Enhancements

Thumb-2 extends push/pop with more flexible register lists:

**Example** - Extended register lists:

```assembly
; Original Thumb - limited register ranges
PUSH {r0-r3}            ; Low registers only
PUSH {lr}               ; Can include LR

; Thumb-2 - flexible combinations
PUSH {r0, r2, r4, r6}   ; Non-contiguous registers
PUSH {r4-r11, lr}       ; Large range with LR
POP {r4-r11, pc}        ; Pop and return

; Save/restore scratch and preserved registers
function:
    PUSH {r0-r3, r4-r7, lr}     ; Save arguments and locals
    ; ... function body ...
    POP {r0-r3, r4-r7, pc}      ; Restore and return
```

**Example** - Preserving specific registers:

```assembly
; Only save registers that will be modified
function_efficient:
    PUSH {r4, r6, lr}       ; Only save what's needed
    ; Use r4, r6 in function
    ; r5, r7-r11 not used, don't save
    POP {r4, r6, pc}
```

### Reverse Byte Order Instructions

**REV - Reverse Byte Order (32-bit):**

```assembly
; REV Rd, Rn
; Reverse byte order in 32-bit word

MOV r0, #0x12345678
REV r1, r0              ; r1 = 0x78563412

; Endianness conversion
LDR r0, [r1]            ; Load big-endian value
REV r0, r0              ; Convert to little-endian
```

**REV16 - Reverse Bytes in Halfwords:**

```assembly
; REV16 Rd, Rn
; Reverse bytes within each halfword independently

MOV r0, #0x12345678
REV16 r1, r0            ; r1 = 0x34127856
; [31:24] ↔ [23:16], [15:8] ↔ [7:0]
```

**REVSH - Reverse Bytes in Signed Halfword:**

```assembly
; REVSH Rd, Rn
; Reverse bytes in lower halfword, sign-extend to 32 bits

MOV r0, #0x0000FF80
REVSH r1, r0            ; r1 = 0xFFFF80FF (reversed and sign-extended)
```

**Example** - Network byte order conversion:

```assembly
; Convert network (big-endian) to host (little-endian)
LDR r0, [r1]            ; Load 32-bit network order
REV r0, r0              ; Convert to host order

; Convert 16-bit port number
LDRH r0, [r1]           ; Load 16-bit value
REV16 r0, r0            ; Swap bytes
UXTH r0, r0             ; Zero-extend to 32 bits
```

### Select Bytes Instruction

**SEL - Select Bytes:**

```assembly
; SEL Rd, Rn, Rm
; Select bytes from Rn or Rm based on GE flags

; GE flags set by SIMD instructions or explicitly:
; If GE[3] set: Rd[31:24] = Rn[31:24], else Rm[31:24]
; If GE[2] set: Rd[23:16] = Rn[23:16], else Rm[23:16]
; If GE[1] set: Rd[15:8] = Rn[15:8], else Rm[15:8]
; If GE[0] set: Rd[7:0] = Rn[7:0], else Rm[7:0]

; Set GE flags
SADD8 r4, r0, r1        ; Parallel add, sets GE flags

; Select bytes based on GE flags
SEL r5, r2, r3          ; Select from r2 or r3 per byte
```

**Example** - Byte-wise max operation:

```assembly
; Compute max of each byte independently
; r0 = {a3, a2, a1, a0}, r1 = {b3, b2, b1, b0}

USUB8 r2, r0, r1        ; Sets GE where r0[i] >= r1[i]
SEL r3, r0, r1          ; r3[i] = max(r0[i], r1[i])
```

### Saturating Instructions

**SSAT/USAT - Signed/Unsigned Saturate:**

```assembly
; SSAT Rd, #imm, Rn {,shift}
; Saturate Rn to signed range [-(2^(imm-1)), 2^(imm-1)-1]

MOV r0, #1000
SSAT r1, #8, r0         ; Saturate to 8-bit signed [-128, 127]
                        ; r1 = 127 (clamped)

MOV r0, #-200
SSAT r1, #8, r0         ; r1 = -128 (clamped)

; USAT Rd, #imm, Rn {,shift}
; Saturate Rn to unsigned range [0, 2^imm-1]

MOV r0, #1000
USAT r1, #8, r0         ; Saturate to 8-bit unsigned [0, 255]
                        ; r1 = 255 (clamped)

MOV r0, #-10
USAT r1, #8, r0         ; r1 = 0 (negative clamped to 0)
```

**Example** - Audio sample clamping:

```assembly
; Clamp audio sample to 16-bit signed range
; r0 = processed sample (may overflow)

SSAT r0, #16, r0        ; Clamp to [-32768, 32767]
```

**Example** - RGB color clamping:

```assembly
; Clamp color component to [0, 255]
ADD r0, r0, r1          ; May exceed 255
USAT r0, #8, r0         ; Clamp to unsigned 8-bit
```

### Parallel Add/Subtract Instructions

**SADD8/USADD8 - Parallel Byte Add:**

```assembly
; SADD8 Rd, Rn, Rm
; Add four bytes in parallel (signed, sets GE flags)

; r0 = {10, 20, 30, 40}
; r1 = { 5, 10, 15, 20}
SADD8 r2, r0, r1        ; r2 = {15, 30, 45, 60}
                        ; GE flags set for each byte

; USADD8 Rd, Rn, Rm  
; Add four bytes in parallel (unsigned, saturating)

MOV r0, #0xFFFFFFFF     ; All bytes = 255
MOV r1, #0x01010101     ; All bytes = 1
USADD8 r2, r0, r1       ; r2 = 0xFFFFFFFF (saturated)
```

**SADD16/USADD16 - Parallel Halfword Add:**

```assembly
; SADD16 Rd, Rn, Rm
; Add two halfwords in parallel

; r0 = {1000, 2000} (16-bit values)
; r1 = { 500, 1500}
SADD16 r2, r0, r1       ; r2 = {1500, 3500}
```

**SSUB8/USUB8 - Parallel Byte Subtract:**

```assembly
; SSUB8 Rd, Rn, Rm
; Subtract four bytes in parallel (sets GE flags)

SSUB8 r2, r0, r1        ; r2[i] = r0[i] - r1[i] for each byte
                        ; GE[i] set if r0[i] >= r1[i]
```

**Example** - SIMD-style operations without NEON:

```assembly
; Process 4 pixels simultaneously (8-bit grayscale)
; Add brightness to each pixel

LDR r0, [r1]            ; Load 4 pixels: {p3, p2, p1, p0}
MOV r2, #0x10101010     ; Brightness delta: {16, 16, 16, 16}
UQADD8 r0, r0, r2       ; Saturating add to each pixel
STR r0, [r1]            ; Store back
```

### Packing and Unpacking Instructions

**PKHBT - Pack Halfword Bottom Top:**

```assembly
; PKHBT Rd, Rn, Rm {,LSL #imm}
; Rd[15:0] = Rn[15:0], Rd[31:16] = Rm[31:16] << imm

MOV r0, #0x12345678     ; r0 = 0x12345678
MOV r1, #0xABCDEF00     ; r1 = 0xABCDEF00
PKHBT r2, r0, r1        ; r2 = 0xABCD5678
                        ; Takes bottom of r0, top of r1
```

**PKHTB - Pack Halfword Top Bottom:**

```assembly
; PKHTB Rd, Rn, Rm {,ASR #imm}
; Rd[31:16] = Rn[31:16], Rd[15:0] = (Rm >> imm)[15:0]

MOV r0, #0x12345678     ; r0 = 0x12345678
MOV r1, #0xABCDEF00     ; r1 = 0xABCDEF00
PKHTB r2, r0, r1        ; r2 = 0x1234EF00
                        ; Takes top of r0, bottom of r1
```

**Example** - Combine two 16-bit values:

```assembly
; r0 = x coordinate (16-bit)
; r1 = y coordinate (16-bit)
; Combine into single 32-bit value

PKHBT r2, r0, r1, LSL #16   ; r2 = (y << 16) | x
```

**Example** - Extract and combine color components:

```assembly
; Extract green/blue, combine with new red/alpha
UBFX r0, r3, #0, #16    ; Extract GB (bits 15:0)
PKHBT r4, r0, r1, LSL #16   ; Combine with new RA
```

### Saturating Add/Subtract Instructions

**QADD/QSUB - Saturating Add/Subtract (32-bit):**

```assembly
; QADD Rd, Rn, Rm
; Rd = saturate(Rn + Rm) to 32-bit signed range

MOV r0, #0x7FFFFFFF     ; Max positive 32-bit
MOV r1, #100
QADD r2, r0, r1         ; r2 = 0x7FFFFFFF (saturated)
                        ; Sets Q flag in CPSR if saturated

; QSUB Rd, Rn, Rm
; Rd = saturate(Rn - Rm)

MOV r0, #0x80000000     ; Max negative 32-bit
MOV r1, #100
QSUB r2, r0, r1         ; r2 = 0x80000000 (saturated)
```

**QDADD/QDSUB - Saturating Double and Add/Subtract:**

```assembly
; QDADD Rd, Rn, Rm
; Rd = saturate(Rn + saturate(Rm * 2))

; QDSUB Rd, Rn, Rm
; Rd = saturate(Rn - saturate(Rm * 2))

; Useful for DSP algorithms
```

**QADD16/QSUB16 - Saturating Parallel Halfword Operations:**

```assembly
; QADD16 Rd, Rn, Rm
; Saturating add of two packed halfwords

; r0 = {32000, 10000}
; r1 = { 1000, 30000}
QADD16 r2, r0, r1       ; r2 = {32767, 32767} (both saturated)
```

**QADD8/QSUB8 - Saturating Parallel Byte Operations:**

```assembly
; QADD8 Rd, Rn, Rm
; Saturating add of four packed bytes

MOV r0, #0x7F7F7F7F     ; All bytes = 127
MOV r1, #0x01010101     ; All bytes = 1
QADD8 r2, r0, r1        ; r2 = 0x7F7F7F7F (all saturated at 127)
```

### Leading Zero Count

**CLZ - Count Leading Zeros:**

```assembly
; CLZ Rd, Rn
; Count number of leading zero bits in Rn

MOV r0, #0x00001000     ; Binary: 0000...0001000000000000
CLZ r1, r0              ; r1 = 19 (19 leading zeros)

MOV r0, #0x80000000     ; Binary: 1000...0000
CLZ r1, r0              ; r1 = 0 (no leading zeros)

MOV r0, #0
CLZ r1, r0              ; r1 = 32 (all zeros)
```

**Example** - Computing log2 (integer):**

```assembly
; Compute floor(log2(x)) for x > 0
; log2(x) = 31 - CLZ(x)

MOV r0, #1000           ; Input value
CLZ r1, r0              ; Count leading zeros
RSB r2, r1, #31         ; r2 = 31 - r1 = floor(log2(1000)) = 9
                        ; 2^9 = 512, 2^10 = 1024
```

**Example** - Normalizing values:**

```assembly
; Normalize 32-bit value (shift left until MSB is 1)
CLZ r1, r0              ; Count leading zeros
LSL r0, r0, r1          ; Shift to normalize
; r1 contains normalization shift amount
```

**Example** - Priority encoder:**

```assembly
; Find highest set bit position
; bit_position = 31 - CLZ(value)

MOV r0, #0x00040000     ; Bit 18 set
CLZ r1, r0              ; r1 = 13
RSB r2, r1, #31         ; r2 = 18 (position of highest bit)
```

### Sum of Absolute Differences

**USAD8 - Unsigned Sum of Absolute Differences:**

```assembly
; USAD8 Rd, Rn, Rm
; Rd = |Rn[31:24] - Rm[31:24]| + |Rn[23:16] - Rm[23:16]| +
;      |Rn[15:8] - Rm[15:8]| + |Rn[7:0] - Rm[7:0]|

; Example: Compare pixel similarity (4 bytes)
LDR r0, [r1]            ; Load 4 pixels from image A
LDR r2, [r3]            ; Load 4 pixels from image B
USAD8 r4, r0, r2        ; Sum of absolute differences
                        ; Lower value = more similar
```

**USADA8 - Unsigned Sum of Absolute Differences and Accumulate:**

```assembly
; USADA8 Rd, Rn, Rm, Ra
; Rd = Ra + USAD8(Rn, Rm)

MOV r5, #0              ; Accumulator
USADA8 r5, r0, r2, r5   ; Accumulate differences
```

**Example** - Block matching in video encoding:**

```assembly
; Compare 4x4 block (4 pixels per iteration)
MOV r4, #0              ; Total SAD
MOV r5, #4              ; Row counter

block_loop:
    LDR r0, [r1], #4    ; Load 4 pixels from reference
    LDR r2, [r3], #4    ; Load 4 pixels from candidate
    USADA8 r4, r0, r2, r4   ; Accumulate SAD
    SUBS r5, r5, #1
    BNE block_loop
    
; r4 now contains total SAD for 4x4 block (16 pixels)
```

### DSP-Oriented Multiply Instructions

**SMMUL/SMMLA/SMMLS** (covered earlier but expanded):

**Example** - Fixed-point Q15 multiplication:**

```assembly
; Q15 format: 1 sign bit, 15 fraction bits
; Range: [-1.0, 0.999969482421875]

; Multiply two Q15 numbers
; Result needs to be in Q15 format

SMULBB r0, r1, r2       ; r0 = (r1[15:0] * r2[15:0])
SSAT r0, #16, r0, ASR #15   ; Shift and saturate to Q15

; Or using SMMUL for Q31 (higher precision)
; Q31: 1 sign bit, 31 fraction bits

SMMUL r0, r1, r2        ; High 32 bits of 64-bit product
LSL r0, r0, #1          ; Adjust for Q31 format
```

**SMUL/SMLA - Signed Multiply with halfword operands:**

```assembly
; SMULBB - Multiply bottom halfwords
SMULBB r0, r1, r2       ; r0 = r1[15:0] * r2[15:0]

; SMULBT - Multiply bottom of first, top of second
SMULBT r0, r1, r2       ; r0 = r1[15:0] * r2[31:16]

; SMULTB - Multiply top of first, bottom of second  
SMULTB r0, r1, r2       ; r0 = r1[31:16] * r2[15:0]

; SMULTT - Multiply top halfwords
SMULTT r0, r1, r2       ; r0 = r1[31:16] * r2[31:16]
```

**Example** - Complex number multiplication (DSP):**

```assembly
; Complex multiply: (a + bi) * (c + di) = (ac - bd) + (ad + bc)i
; r0 = {a[31:16], b[15:0]} (real, imag)
; r1 = {c[31:16], d[15:0]} (real, imag)

SMULBB r2, r0, r1       ; r2 = b * d
SMULTT r3, r0, r1       ; r3 = a * c
SMLABB r4, r0, r1, r0   ; r4 = temp (for imaginary part)
SMLABT r5, r0, r1, r0   ; r5 = temp (for imaginary part)

SUB r6, r3, r2          ; Real part: ac - bd
ADD r7, r4, r5          ; Imaginary part: ad + bc (simplified)
PKHBT r8, r7, r6, LSL #16   ; Pack result
```

### Exclusive Load/Store (for synchronization)

**LDREX/STREX - Exclusive Load/Store:**

```assembly
; LDREX Rt, [Rn]
; Load exclusive - marks memory for exclusive access

; STREX Rd, Rt, [Rn]  
; Store exclusive - stores only if exclusive access maintained
; Rd = 0 if successful, 1 if failed

; Atomic increment example
retry:
    LDREX r1, [r0]          ; Load value with exclusive monitor
    ADD r1, r1, #1          ; Increment
    STREX r2, r1, [r0]      ; Attempt exclusive store
    CMP r2, #0              ; Check if succeeded
    BNE retry               ; Retry if failed

; Alternative with IT block
retry:
    LDREX r1, [r0]
    ADD r1, r1, #1
    STREX r2, r1, [r0]
    CBNZ r2, retry          ; Retry if failed (r2 != 0)
```

**LDREXB/STREXB - Byte exclusive:**

```assembly
; Atomic byte operations
retry:
    LDREXB r1, [r0]
    ADD r1, r1, #1
    STREXB r2, r1, [r0]
    CBNZ r2, retry
```

**LDREXH/STREXH - Halfword exclusive:**

```assembly
; Atomic halfword operations
retry:
    LDREXH r1, [r0]
    ADD r1, r1, #1
    STREXH r2, r1, [r0]
    CBNZ r2, retry
```

**Example** - Compare-and-swap (CAS):**

```assembly
; Atomic compare and swap
; r0 = address, r1 = expected value, r2 = new value
; Returns: r0 = 1 if successful, 0 if failed

cas:
    LDREX r3, [r0]          ; Load current value
    CMP r3, r1              ; Compare with expected
    ITT EQ
    STREXEQ r4, r2, [r0]    ; Store new value if match
    RSBEQ r0, r4, #1        ; Return success (1) or fail (0)
    
    IT NE
    MOVNE r0, #0            ; Return 0 if comparison failed
    
    BX lr
```

**Example** - Spinlock implementation:**

```assembly
; Acquire spinlock (value at [r0])
acquire_lock:
    MOV r1, #1              ; Lock value
try_lock:
    LDREX r2, [r0]          ; Load lock status
    CMP r2, #0              ; Check if unlocked
    ITT EQ
    STREXEQ r3, r1, [r0]    ; Try to acquire
    CMPEQ r3, #0            ; Check if succeeded
    BNE try_lock            ; Retry if failed
    DMB                     ; Data memory barrier
    BX lr

; Release spinlock
release_lock:
    DMB                     ; Data memory barrier
    MOV r1, #0
    STR r1, [r0]            ; Release lock
    BX lr
```

### Memory Barrier Instructions

**DMB - Data Memory Barrier:**

```assembly
; DMB {option}
; Ensures memory operations before DMB complete before operations after

DMB                     ; Full system DMB
DMB SY                  ; Full system (explicit)
DMB ISH                 ; Inner shareable domain
DMB OSH                 ; Outer shareable domain
DMB NSH                 ; Non-shareable
```

**DSB - Data Synchronization Barrier:**

```assembly
; DSB {option}
; Stronger than DMB - waits for all operations to complete

DSB                     ; Full system DSB
DSB SY                  ; Full system (explicit)
```

**ISB - Instruction Synchronization Barrier:**

```assembly
; ISB
; Flushes pipeline, ensures subsequent instructions see memory/context changes

ISB                     ; Flush instruction pipeline
```

**Example** - Proper synchronization usage:**

```assembly
; Producer-consumer with memory barriers
producer:
    STR r0, [r1]            ; Write data
    DMB                     ; Ensure write completes
    MOV r2, #1
    STR r2, [r3]            ; Set flag
    BX lr

consumer:
wait_flag:
    LDR r0, [r3]            ; Read flag
    CMP r0, #1
    BNE wait_flag
    DMB                     ; Ensure flag read before data read
    LDR r1, [r1]            ; Read data
    ; Process data
```

