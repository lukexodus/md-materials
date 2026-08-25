## Thumb-2 Mixed 16/32-bit Instructions


Thumb-2, introduced with ARMv6T2 and refined in ARMv7, extends the Thumb instruction set with 32-bit encodings to eliminate most performance gaps between Thumb and ARM states. This hybrid approach combines the code density benefits of 16-bit instructions with the functionality of 32-bit instructions.

**Architecture:** Thumb-2 is not a separate processor state. It operates in Thumb state but supports both 16-bit and 32-bit instruction encodings intermixed freely within the instruction stream.

**32-bit Thumb Instructions:** Encoded as two consecutive 16-bit halfwords. The first halfword (bits 15-11 = 11101, 11110, or 11111) indicates a 32-bit instruction follows. The processor fetches both halfwords before decoding.

**32-bit instruction format:**

```
First halfword (15-0):  |1 1 1|op1|op2|...
Second halfword (15-0): |op3|...
```

**Capability Restoration:** Thumb-2 32-bit instructions restore capabilities absent in 16-bit Thumb:

**Full Register Access:** All 32-bit instructions can access all registers R0-R15 without restrictions.

**IT Block (If-Then):** Replaces ARM's conditional execution. The IT instruction creates a conditional execution block for up to four following instructions:

```assembly
IT EQ           ; If equal
ADDEQ R0, R1, R2   ; Execute if Z flag set
```

The IT instruction specifies a condition and pattern for subsequent instructions:

```assembly
ITTTE NE        ; If-Then-Then-Else, Not Equal
ADDNE R0, R1, R2   ; Execute if NE
SUBNE R3, R4, R5   ; Execute if NE  
MOVNE R6, R7       ; Execute if NE
MOVEQ R8, R9       ; Execute if EQ (inverse)
```

**Complex Addressing Modes:** 32-bit loads/stores support pre-indexed, post-indexed, and offset addressing with larger offsets (±4095 bytes for LDR/STR).

**Modified Immediate Constants:** Thumb-2 uses a 12-bit encoding for immediate values that can generate a wider range of constants through rotation and replication patterns.

**Additional Instructions:** Includes DSP extensions (SIMD operations), saturating arithmetic, bit field manipulation (BFI, UBFX), divide instructions (SDIV, UDIV), and multiply-accumulate operations.

**Example** of Thumb-2 capability:

16-bit Thumb (limited):

```assembly
MOV  R0, #100       ; 16-bit: Limited immediate
ADD  R0, R0, R1     ; 16-bit: Simple add
LDR  R2, [R3, #32]  ; 16-bit: Small offset
```

Thumb-2 (enhanced):

```assembly
MOVW R0, #45000     ; 32-bit: Move 16-bit immediate
MLA  R0, R1, R2, R3 ; 32-bit: Multiply-accumulate
LDR  R2, [R3, #2048]!  ; 32-bit: Pre-indexed, large offset
UDIV R4, R5, R6     ; 32-bit: Unsigned divide
```

**Code Density Analysis:** [Inference based on architectural design] Thumb-2 typically achieves 95-98% of ARM code performance while maintaining code density close to original Thumb (approximately 70-75% of ARM code size). The processor dynamically uses 16-bit encodings where possible and 32-bit encodings where necessary.

