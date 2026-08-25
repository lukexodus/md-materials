## SSSE3 Extensions


SSSE3 (Supplemental SSE3) introduces 16 new instructions primarily focused on byte manipulation, shuffling, and packed integer operations, particularly beneficial for video codecs, image processing, and data reorganization.

### Packed Absolute Value

**PABSB/PABSW/PABSD - Packed Absolute Value**

`PABSB xmm1, xmm2/m128` - Absolute value of packed signed bytes `PABSW xmm1, xmm2/m128` - Absolute value of packed signed words `PABSD xmm1, xmm2/m128` - Absolute value of packed signed doublewords

Computes absolute values of packed signed integers. Each element is independently converted to its absolute value, with the special case that the absolute value of the most negative integer (e.g., -128 for bytes) remains unchanged due to two's complement representation.

### Horizontal Addition and Subtraction (Integer)

**PHADDD - Packed Horizontal Add Doublewords**

`PHADDD xmm1, xmm2/m128`

Adds adjacent pairs of 32-bit signed integers.

Operation:

```
xmm1[31:0]   = xmm1[31:0] + xmm1[63:32]
xmm1[63:32]  = xmm1[95:64] + xmm1[127:96]
xmm1[95:64]  = xmm2[31:0] + xmm2[63:32]
xmm1[127:96] = xmm2[95:64] + xmm2[127:96]
```

**PHADDW - Packed Horizontal Add Words**

`PHADDW xmm1, xmm2/m128`

Adds adjacent pairs of 16-bit signed integers.

**PHADDSW - Packed Horizontal Add with Saturation**

`PHADDSW xmm1, xmm2/m128`

Adds adjacent pairs of 16-bit signed integers with signed saturation (clamping results to [-32768, 32767]).

**PHSUBD/PHSUBW/PHSUBSW - Packed Horizontal Subtract**

`PHSUBD xmm1, xmm2/m128` - Subtract doublewords `PHSUBW xmm1, xmm2/m128` - Subtract words `PHSUBSW xmm1, xmm2/m128` - Subtract words with saturation

Subtract adjacent pairs of integers (left minus right within each pair).

### Multiply and Add

**PMADDUBSW - Multiply and Add Packed Unsigned and Signed Bytes**

`PMADDUBSW xmm1, xmm2/m128`

Multiplies unsigned bytes from the destination by signed bytes from the source, producing intermediate signed 16-bit results. Adjacent pairs of these results are then added together.

Operation:

```
For i = 0 to 7:
    tmp1 = xmm1[i*16+7:i*16] * xmm2[i*16+7:i*16]      ; unsigned × signed
    tmp2 = xmm1[i*16+15:i*16+8] * xmm2[i*16+15:i*16+8]
    xmm1[i*16+15:i*16] = SATURATE_INT16(tmp1 + tmp2)
```

Useful for video codecs where unsigned pixel values are multiplied by signed filter coefficients.

**PMULHRSW - Packed Multiply High with Round and Scale**

`PMULHRSW xmm1, xmm2/m128`

Multiplies packed 16-bit signed integers, producing 32-bit intermediate results. The upper 18 bits are extracted, rounded, and scaled to produce 16-bit results.

Operation:

```
For each word:
    tmp[31:0] = xmm1[15:0] * xmm2[15:0]
    result = (tmp[31:14] + 1) >> 1
```

Provides rounding behavior useful for fixed-point arithmetic.

### Packed Sign Operations

**PSIGNB/PSIGNW/PSIGND - Packed Sign**

`PSIGNB xmm1, xmm2/m128` - Operate on bytes `PSIGNW xmm1, xmm2/m128` - Operate on words `PSIGND xmm1, xmm2/m128` - Operate on doublewords

Negates, zeroes, or preserves elements based on the sign of corresponding elements in the source operand.

Operation for each element:

```
if (xmm2[element] < 0)
    xmm1[element] = -xmm1[element]
else if (xmm2[element] == 0)
    xmm1[element] = 0
else
    xmm1[element] = xmm1[element]
```

### Shuffle Operations

**PSHUFB - Packed Shuffle Bytes**

`PSHUFB xmm1, xmm2/m128`

Performs arbitrary byte permutation within a 128-bit register. Each byte in xmm2 acts as an index selecting a byte from xmm1. If the high bit of the index is set, the result byte is zeroed.

Operation:

```
For i = 0 to 15:
    if (xmm2[i*8+7] == 1)
        xmm1[i*8+7:i*8] = 0
    else
        index = xmm2[i*8+3:i*8]
        xmm1[i*8+7:i*8] = xmm1[index*8+7:index*8]
```

This is the most flexible shuffle operation in SSSE3, enabling arbitrary byte-level rearrangement in a single instruction.

**PALIGNR - Packed Align Right**

`PALIGNR xmm1, xmm2/m128, imm8`

Concatenates the destination and source operands (256 bits total), shifts right by the immediate value (in bytes), and stores the lower 128 bits in the destination.

Operation:

```
temp[255:0] = {xmm1, xmm2}
temp[255:0] = temp[255:0] >> (imm8 * 8)
xmm1[127:0] = temp[127:0]
```

Extremely useful for extracting misaligned data, implementing sliding window operations, and efficiently shifting data across register boundaries.

