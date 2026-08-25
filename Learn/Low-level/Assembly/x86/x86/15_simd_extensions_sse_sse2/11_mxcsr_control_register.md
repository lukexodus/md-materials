## MXCSR Control Register


The MXCSR (SSE Control and Status Register) is a 32-bit register controlling SSE/SSE2 floating-point operations.

**Control Fields:**

- Bits 15: Flush-to-Zero (FTZ) - Treats denormal results as zero
- Bits 14-13: Rounding Control (00=nearest, 01=down, 10=up, 11=truncate)
- Bits 12: Precision Mask
- Bits 11: Underflow Mask
- Bits 10: Overflow Mask
- Bits 9: Divide-by-Zero Mask
- Bits 8: Denormal Operation Mask
- Bits 7: Invalid Operation Mask
- Bit 6: Denormals-Are-Zero (DAZ)

**Status Fields:**

- Bits 5-0: Exception flags (Precision, Underflow, Overflow, Divide-by-Zero, Denormal, Invalid)

**Instructions:** `LDMXCSR m32` - Load MXCSR from memory `STMXCSR m32` - Store MXCSR to memory

**Example:** Setting FTZ and DAZ

```asm
section .data
    mxcsr_val: dd 0

section .text
    stmxcsr [mxcsr_val]              ; Save current MXCSR
    or dword [mxcsr_val], 0x8040     ; Set FTZ (bit 15) and DAZ (bit 6)
    ldmxcsr [mxcsr_val]              ; Load modified MXCSR
```

