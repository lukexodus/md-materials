## SSE4.2 Extensions


SSE4.2 adds 7 new instructions focused on string and text processing, CRC32 calculation, and enhanced comparison operations.

### String and Text Processing

SSE4.2 introduces powerful instructions for accelerating string comparisons and searches, particularly beneficial for text processing, pattern matching, and data validation.

**PCMPESTRI - Packed Compare Explicit Length Strings, Return Index**

`PCMPESTRI xmm1, xmm2/m128, imm8`

Compares two strings of explicitly specified lengths and returns the index of the first match or mismatch in ECX. String lengths are specified in EAX (for xmm1) and EDX (for xmm2).

**PCMPESTRM - Packed Compare Explicit Length Strings, Return Mask**

`PCMPESTRM xmm1, xmm2/m128, imm8`

Similar to PCMPESTRI but returns a bit mask in XMM0 indicating all match positions.

**PCMPISTRI - Packed Compare Implicit Length Strings, Return Index**

`PCMPISTRI xmm1, xmm2/m128, imm8`

Compares null-terminated strings and returns the index in ECX. String length is determined by finding null terminators.

**PCMPISTRM - Packed Compare Implicit Length Strings, Return Mask**

`PCMPISTRM xmm1, xmm2/m128, imm8`

Returns a bit mask in XMM0 for null-terminated string comparisons.

**String Comparison Control Byte (imm8):**

The immediate byte controls comparison behavior with multiple fields:

Bits 1-0: Data format

- 00b: Unsigned bytes
- 01b: Unsigned words
- 10b: Signed bytes
- 11b: Signed words

Bits 3-2: Aggregation operation

- 00b: Equal any (substring search)
- 01b: Ranges (check if characters fall within specified ranges)
- 10b: Equal each (compare corresponding elements)
- 11b: Equal ordered (substring match requiring order)

Bit 4: Polarity

- 0: Positive polarity (match)
- 1: Negative polarity (mismatch)

Bit 5: Output selection (for PCMPESTRM/PCMPISTRM)

- 0: Bit mask
- 1: Byte/word mask

Bit 6: Most significant bit vs least significant bit

**Flags Set:**

These instructions set CPU flags:

- CF: Reset if string contains null terminator
- ZF: Set if result is zero
- SF: Set for negative result
- OF: Set if valid result in ECX/XMM0

### CRC32 Calculation

**CRC32 - Accumulate CRC32 Value**

`CRC32 r32, r/m8` - Accumulate byte `CRC32 r32, r/m16` - Accumulate word `CRC32 r32, r/m32` - Accumulate doubleword `CRC32 r64, r/m64` - Accumulate quadword (64-bit mode only)

Computes CRC32C (Castagnoli) polynomial, updating an accumulator register with data from the source operand. Used for data integrity checks, network protocols, and file systems.

Operation:

```
r32 = CRC32(r32, source_data)
```

The polynomial used is 0x1EDC6F41 (reversed representation of 0x82F63B78).

### Enhanced Comparison

**PCMPGTQ - Compare Packed Qword Data for Greater Than**

`PCMPGTQ xmm1, xmm2/m128`

Compares two pairs of signed 64-bit integers for greater-than relationship, setting corresponding quadwords to all ones if true, all zeros if false.

Operation:

```
For i = 0 to 1:
    if (xmm1[i*64+63:i*64] > xmm2[i*64+63:i*64])
        xmm1[i*64+63:i*64] = 0xFFFFFFFFFFFFFFFF
    else
        xmm1[i*64+63:i*64] = 0
```

