## SSSE3 Packed Operations


### Shuffle Operations

**PSHUFB** (Packed Shuffle Bytes) provides flexible byte-level permutation within 128-bit registers. Each byte in the control operand specifies the source position for the corresponding destination byte, or forces the destination byte to zero if the high bit is set.

```nasm
movdqa xmm0, [data]         ; Source data
movdqa xmm1, [shuffle_mask] ; Control mask
pshufb xmm0, xmm1           ; Shuffle bytes according to mask
```

The control byte format allows each destination byte to select any of the 16 source bytes or zero:

- Bits 0-3: source byte index (0-15)
- Bit 7: if set, destination byte becomes 0
- Bits 4-6: ignored

**Example**: Reversing byte order

```nasm
; Control mask to reverse 16 bytes
section .data
align 16
reverse_mask: db 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0

section .text
movdqa xmm0, [input]
movdqa xmm1, [reverse_mask]
pshufb xmm0, xmm1           ; Bytes now reversed
```

### Packed Absolute Value

**PABSB**, **PABSW**, and **PABSD** compute absolute values of packed 8-bit, 16-bit, or 32-bit signed integers respectively. These instructions replace multi-instruction sequences previously required for absolute value computation.

The operation converts negative values to their positive magnitude while leaving positive values unchanged. For the minimum representable negative value (e.g., -128 for signed bytes), the result is the same value since the positive equivalent cannot be represented.

### Horizontal Addition with Saturation

**PHADDW** and **PHADDD** perform horizontal addition on packed 16-bit or 32-bit signed integers. Unlike SSE3's floating-point horizontal operations, these work with integer data.

```
destination: [A7, A6, A5, A4, A3, A2, A1, A0]  (16-bit words)
source:      [B7, B6, B5, B4, B3, B2, B1, B0]
result:      [B7+B6, B5+B4, B3+B2, B1+B0, A7+A6, A5+A4, A3+A2, A1+A0]
```

**PHADDSW** performs horizontal addition of signed 16-bit integers with signed saturation, clamping results to the range [-32768, 32767].

**PHSUBW**, **PHSUBD**, and **PHSUBSW** provide corresponding horizontal subtraction variants.

### Sign-Based Operations

**PSIGNB**, **PSIGNW**, and **PSIGND** negate, zero, or preserve packed integer elements based on the sign of corresponding control elements. If the control element is negative, the result element is negated; if zero, the result is zero; if positive, the result is preserved.

This operation efficiently implements conditional negation patterns common in certain algorithms without requiring comparison and branching.

### Multiply and Add Packed Signed

**PMADDUBSW** multiplies packed unsigned 8-bit integers from one operand with packed signed 8-bit integers from another operand, producing intermediate 16-bit signed results. Horizontally adjacent pairs of these intermediate results are then added together with saturation, yielding packed 16-bit signed integers.

This instruction efficiently implements certain filtering and transform operations where unsigned data is multiplied by signed coefficients.

### Packed Align

**PALIGNR** extracts a 128-bit result from a concatenated 256-bit intermediate value formed by the source and destination operands, with a byte-granularity offset specified by an immediate operand.

```nasm
movdqa xmm0, [data1]        ; Low 128 bits
movdqa xmm1, [data2]        ; High 128 bits
palignr xmm1, xmm0, 8       ; Extract 16 bytes starting at byte 8
```

The immediate byte offset (0-255) determines the starting position in the concatenated 256-bit space. Values beyond 32 result in zeroing the destination. This instruction efficiently implements sliding window operations and data realignment across register boundaries.

