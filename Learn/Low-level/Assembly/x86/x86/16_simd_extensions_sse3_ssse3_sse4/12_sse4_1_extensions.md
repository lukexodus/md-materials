## SSE4.1 Extensions


SSE4.1 introduces 47 new instructions, adding substantial functionality for blending, extraction/insertion, dot products, rounding, and packed integer operations. These instructions significantly enhance multimedia processing, 3D graphics, and general computation.

### Blending Operations

Blending operations selectively combine elements from two sources based on masks, enabling conditional element selection without branches.

**BLENDPS - Blend Packed Single-Precision Floating-Point Values**

`BLENDPS xmm1, xmm2/m128, imm8`

Selectively blends four single-precision values based on a 4-bit immediate mask. Each bit corresponds to one element.

Operation:

```
For i = 0 to 3:
    if (imm8[i] == 0)
        xmm1[i*32+31:i*32] = xmm1[i*32+31:i*32]
    else
        xmm1[i*32+31:i*32] = xmm2[i*32+31:i*32]
```

**BLENDPD - Blend Packed Double-Precision Floating-Point Values**

`BLENDPD xmm1, xmm2/m128, imm8`

Blends two double-precision values based on a 2-bit immediate mask.

**BLENDVPS - Variable Blend Packed Single-Precision**

`BLENDVPS xmm1, xmm2/m128, xmm0`

Blends based on the sign bits of corresponding elements in XMM0 (implicit operand). If XMM0's sign bit is set (negative), the element from xmm2 is selected; otherwise, the element from xmm1.

Operation:

```
For i = 0 to 3:
    if (xmm0[i*32+31] == 1)
        xmm1[i*32+31:i*32] = xmm2[i*32+31:i*32]
    else
        xmm1[i*32+31:i*32] = xmm1[i*32+31:i*32]
```

**BLENDVPD - Variable Blend Packed Double-Precision**

`BLENDVPD xmm1, xmm2/m128, xmm0`

Double-precision equivalent using XMM0 sign bits.

**PBLENDW - Blend Packed Words**

`PBLENDW xmm1, xmm2/m128, imm8`

Blends eight 16-bit integers based on an 8-bit immediate mask.

**PBLENDVB - Variable Blend Packed Bytes**

`PBLENDVB xmm1, xmm2/m128, xmm0`

Blends sixteen bytes based on the sign bits of corresponding bytes in XMM0.

Operation:

```
For i = 0 to 15:
    if (xmm0[i*8+7] == 1)
        xmm1[i*8+7:i*8] = xmm2[i*8+7:i*8]
    else
        xmm1[i*8+7:i*8] = xmm1[i*8+7:i*8]
```

### Dot Product Operations

Dot product instructions compute the sum of products of vector elements, essential for 3D graphics, physics simulations, and linear algebra.

**DPPS - Dot Product of Packed Single-Precision**

`DPPS xmm1, xmm2/m128, imm8`

Computes dot product of four single-precision pairs, with control over which elements participate in multiplication and which elements of the result are written.

Immediate byte encoding:

- Bits 7-4: Source mask (which elements to multiply)
- Bits 3-0: Destination mask (which elements to write result to)

Operation:

```
temp = 0
if (imm8[7]) temp += xmm1[31:0] * xmm2[31:0]
if (imm8[6]) temp += xmm1[63:32] * xmm2[63:32]
if (imm8[5]) temp += xmm1[95:64] * xmm2[95:64]
if (imm8[4]) temp += xmm1[127:96] * xmm2[127:96]

For i = 0 to 3:
    if (imm8[i]) xmm1[i*32+31:i*32] = temp
    else xmm1[i*32+31:i*32] = 0
```

**DPPD - Dot Product of Packed Double-Precision**

`DPPD xmm1, xmm2/m128, imm8`

Computes dot product of two double-precision pairs.

Immediate byte encoding:

- Bits 5-4: Source mask (which elements to multiply)
- Bits 1-0: Destination mask (which elements to write result to)

### Rounding Operations

SSE4.1 introduces explicit rounding control for floating-point operations, independent of MXCSR rounding mode.

**ROUNDPS - Round Packed Single-Precision**

`ROUNDPS xmm1, xmm2/m128, imm8`

Rounds four single-precision values according to the immediate control byte.

Rounding modes (bits 1-0 of imm8):

- 0x00: Round to nearest (even)
- 0x01: Round down (toward -∞)
- 0x02: Round up (toward +∞)
- 0x03: Round toward zero (truncate)

Bit 2: If set, suppress precision exceptions.

**ROUNDPD - Round Packed Double-Precision**

`ROUNDPD xmm1, xmm2/m128, imm8`

Rounds two double-precision values.

**ROUNDSS - Round Scalar Single-Precision**

`ROUNDSS xmm1, xmm2/m32, imm8`

Rounds the lowest single-precision value, preserving upper bits of destination.

**ROUNDSD - Round Scalar Double-Precision**

`ROUNDSD xmm1, xmm2/m64, imm8`

Rounds the lowest double-precision value.

### Extraction and Insertion

Enhanced operations for moving data between XMM registers, general-purpose registers, and memory.

**EXTRACTPS - Extract Packed Single-Precision**

`EXTRACTPS r/m32, xmm1, imm8`

Extracts a single 32-bit single-precision value from an XMM register to a general-purpose register or memory. The immediate value (bits 1-0) specifies which of the four elements to extract.

**INSERTPS - Insert Packed Single-Precision**

`INSERTPS xmm1, xmm2/m32, imm8`

Inserts a single-precision value into a specified position and optionally zeroes other elements.

Immediate byte encoding:

- Bits 7-6: Source element selector (from xmm2)
- Bits 5-4: Destination element selector (in xmm1)
- Bits 3-0: Zero mask (which elements in xmm1 to zero)

**PEXTRB/PEXTRW/PEXTRD/PEXTRQ - Extract Integer**

`PEXTRB r/m8, xmm1, imm8` - Extract byte `PEXTRW r/m16, xmm1, imm8` - Extract word `PEXTRD r/m32, xmm1, imm8` - Extract doubleword `PEXTRQ r/m64, xmm1, imm8` - Extract quadword (64-bit mode only)

Extract integer values at specified positions to general-purpose registers or memory.

**PINSRB/PINSRD/PINSRQ - Insert Integer**

`PINSRB xmm1, r/m8, imm8` - Insert byte `PINSRD xmm1, r/m32, imm8` - Insert doubleword `PINSRQ xmm1, r/m64, imm8` - Insert quadword (64-bit mode only)

Insert integer values from general-purpose registers or memory into specified positions in XMM registers. Note: PINSRW was already available in SSE2.

### Packed Integer MIN/MAX

SSE4.1 extends minimum and maximum operations to support various integer data types with both signed and unsigned variants.

**PMINUW/PMINUD - Minimum Unsigned Integers**

`PMINUW xmm1, xmm2/m128` - Minimum of packed unsigned 16-bit integers `PMINUD xmm1, xmm2/m128` - Minimum of packed unsigned 32-bit integers

**PMAXUW/PMAXUD - Maximum Unsigned Integers**

`PMAXUW xmm1, xmm2/m128` - Maximum of packed unsigned 16-bit integers `PMAXUD xmm1, xmm2/m128` - Maximum of packed unsigned 32-bit integers

**PMINSB/PMINSD - Minimum Signed Integers**

`PMINSB xmm1, xmm2/m128` - Minimum of packed signed 8-bit integers `PMINSD xmm1, xmm2/m128` - Minimum of packed signed 32-bit integers

**PMAXSB/PMAXSD - Maximum Signed Integers**

`PMAXSB xmm1, xmm2/m128` - Maximum of packed signed 8-bit integers `PMAXSD xmm1, xmm2/m128` - Maximum of packed signed 32-bit integers

These complement SSE2's PMINSW/PMAXSW (signed 16-bit) and PMINUB/PMAXUB (unsigned 8-bit).

### Packed Integer Comparison

**PCMPEQQ - Compare Packed Qword Data for Equal**

`PCMPEQQ xmm1, xmm2/m128`

Compares two pairs of 64-bit integers for equality, setting corresponding quadwords to all ones (0xFFFFFFFFFFFFFFFF) if equal, all zeros otherwise.

### Conversion Operations

**PMOVSXBW/PMOVSXBD/PMOVSXBQ - Sign Extend Packed Bytes**

`PMOVSXBW xmm1, xmm2/m64` - Bytes to words `PMOVSXBD xmm1, xmm2/m32` - Bytes to doublewords `PMOVSXBQ xmm1, xmm2/m16` - Bytes to quadwords

Sign-extend packed signed integers from smaller to larger types.

**PMOVSXWD/PMOVSXWQ/PMOVSXDQ - Sign Extend Packed Integers**

`PMOVSXWD xmm1, xmm2/m64` - Words to doublewords `PMOVSXWQ xmm1, xmm2/m32` - Words to quadwords `PMOVSXDQ xmm1, xmm2/m64` - Doublewords to quadwords

**PMOVZXBW/PMOVZXBD/PMOVZXBQ - Zero Extend Packed Bytes**

`PMOVZXBW xmm1, xmm2/m64` - Bytes to words `PMOVZXBD xmm1, xmm2/m32` - Bytes to doublewords `PMOVZXBQ xmm1, xmm2/m16` - Bytes to quadwords

Zero-extend packed unsigned integers.

**PMOVZXWD/PMOVZXWQ/PMOVZXDQ - Zero Extend Packed Integers**

`PMOVZXWD xmm1, xmm2/m64` - Words to doublewords `PMOVZXWQ xmm1, xmm2/m32` - Words to quadwords `PMOVZXDQ xmm1, xmm2/m64` - Doublewords to quadwords

### Multiplication Operations

**PMULDQ - Multiply Packed Signed Dword Integers**

`PMULDQ xmm1, xmm2/m128`

Multiplies two pairs of signed 32-bit integers, producing two 64-bit results. Uses even-indexed elements (elements 0 and 2) from each operand.

Operation:

```
xmm1[63:0]   = xmm1[31:0] * xmm2[31:0]
xmm1[127:64] = xmm1[95:64] * xmm2[95:64]
```

**PMULLD - Multiply Packed Signed Dword Integers and Store Low Result**

`PMULLD xmm1, xmm2/m128`

Multiplies four pairs of signed 32-bit integers, producing four 32-bit results (low 32 bits of each 64-bit product).

Operation:

```
For i = 0 to 3:
    temp[63:0] = xmm1[i*32+31:i*32] * xmm2[i*32+31:i*32]
    xmm1[i*32+31:i*32] = temp[31:0]
```

### Horizontal MIN/MAX

**PHMINPOSUW - Packed Horizontal Word Minimum**

`PHMINPOSUW xmm1, xmm2/m128`

Finds the minimum unsigned 16-bit value among eight words and returns both the minimum value and its index.

Operation:

```
min_value = minimum of xmm2[7:0], xmm2[15:8], ..., xmm2[127:112]
min_index = position of minimum value (0-7)
xmm1[15:0] = min_value
xmm1[18:16] = min_index
xmm1[127:19] = 0
```

### Testing and Flags

**PTEST - Logical Compare**

`PTEST xmm1, xmm2/m128`

Performs logical AND and ANDN operations, setting flags without modifying registers.

Operation:

```
temp1 = xmm1 AND xmm2
temp2 = xmm1 ANDN xmm2
ZF = (temp1 == 0) ? 1 : 0
CF = (temp2 == 0) ? 1 : 0
OF = 0
SF = 0
PF = 0
AF = 0
```

Useful for testing whether any bits are set or whether all bits match specific patterns.

### Memory Operations

**MOVNTDQA - Load Double Quadword Non-Temporal Aligned Hint**

`MOVNTDQA xmm1, m128`

Loads 128 bits from memory with a non-temporal hint, optimized for streaming reads. Requires 16-byte alignment.

