## Three-Operand Instruction Format


AVX introduced a fundamental change to x86 instruction encoding: non-destructive three-operand instructions using the VEX (Vector Extensions) prefix.

### VEX Encoding

VEX is a new instruction prefix that replaces traditional REX/opcode prefixes for AVX instructions, encoding operands and vector length.

**VEX prefix structure**:

- **2-byte VEX**: For simpler instructions (C5h prefix byte)
- **3-byte VEX**: For complex instructions requiring extended encoding (C4h prefix byte)
- **Encodes**: Destination register, two source registers, vector length (128/256-bit)

### Instruction Format Comparison

**Traditional SSE format** (two-operand, destructive):

```nasm
addps xmm0, xmm1          ; XMM0 = XMM0 + XMM1 (XMM0 destroyed)
```

**AVX format** (three-operand, non-destructive):

```nasm
vaddps xmm0, xmm1, xmm2   ; XMM0 = XMM1 + XMM2 (XMM1 preserved)
vaddps ymm0, ymm1, ymm2   ; YMM0 = YMM1 + YMM2 (256-bit version)
```

### Operand Notation

AVX instructions follow the syntax:

```nasm
v<operation> dest, src1, src2/mem
```

Where:

- **dest**: Destination register (written)
- **src1**: First source register (read, preserved)
- **src2/mem**: Second source register or memory operand (read)

**Example** of three-operand benefits:

```nasm
; SSE version (destructive)
movaps xmm0, xmm1         ; Copy XMM1 to XMM0
addps xmm0, xmm2          ; Add XMM2 to XMM0
                          ; Result in XMM0, XMM1 destroyed

; AVX version (non-destructive)
vaddps xmm0, xmm1, xmm2   ; Result in XMM0, both XMM1 and XMM2 preserved
                          ; No move required
```

### Register Pressure Reduction

The three-operand format significantly reduces register pressure by eliminating the need for temporary copies.

**Example** computing multiple dependent operations:

```nasm
; SSE version - requires moves to preserve inputs
movaps xmm3, xmm0
addps xmm3, xmm1          ; xmm3 = xmm0 + xmm1
movaps xmm4, xmm0
subps xmm4, xmm2          ; xmm4 = xmm0 - xmm2
movaps xmm5, xmm3
mulps xmm5, xmm4          ; xmm5 = xmm3 * xmm4

; AVX version - no moves needed
vaddps xmm3, xmm0, xmm1   ; xmm3 = xmm0 + xmm1
vsubps xmm4, xmm0, xmm2   ; xmm4 = xmm0 - xmm2
vmulps xmm5, xmm3, xmm4   ; xmm5 = xmm3 * xmm4
```

### Memory Operands

AVX instructions can use memory operands as the third operand (src2), maintaining the three-operand benefit:

```nasm
vaddps ymm0, ymm1, [mem]  ; YMM0 = YMM1 + memory[0:255]
vmulps xmm2, xmm3, [esi]  ; XMM2 = XMM3 * memory[esi]
```

Memory operands must be aligned to 32 bytes for 256-bit operations using aligned load instructions, though unaligned variants exist.

