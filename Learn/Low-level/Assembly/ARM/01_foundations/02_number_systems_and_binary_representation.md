## Number Systems and Binary Representation


Assembly programming requires understanding how numbers are represented in binary at the hardware level.

### Positional Number Systems

Decimal (base-10) uses digits 0-9 with each position representing a power of 10. Binary (base-2) uses digits 0-1 with each position representing a power of 2. Hexadecimal (base-16) uses digits 0-9 and A-F, with each position representing a power of 16.

The decimal number 157 converts to binary as: 157 = 128 + 16 + 8 + 4 + 1 = 2^7 + 2^4 + 2^3 + 2^2 + 2^0 = 10011101₂

In hexadecimal: 157 = 9×16 + 13 = 0x9D

Hexadecimal provides a compact representation where each hex digit corresponds to exactly 4 binary bits, making it convenient for expressing binary patterns.

### Binary Arithmetic

Binary addition follows the same principles as decimal addition with carry propagation:

```
  1011 (11)
+ 0110 (6)
------
 10001 (17)
```

Binary subtraction can be performed directly or through addition of the negative representation. Multiplication and division follow standard algorithms but operate in base-2.

### Unsigned Integer Representation

Unsigned integers represent only non-negative values using straightforward binary encoding. An n-bit unsigned integer can represent values from 0 to 2^n - 1.

For 8-bit unsigned:

- Minimum: 00000000₂ = 0
- Maximum: 11111111₂ = 255

For 32-bit unsigned:

- Range: 0 to 4,294,967,295

### Signed Integer Representation

Signed integers must represent both positive and negative values. ARM processors use **two's complement** representation, which has several mathematical advantages.

In two's complement, the most significant bit (MSB) serves as the sign bit. Positive numbers have MSB=0 and use standard binary representation. Negative numbers have MSB=1 and are formed by inverting all bits of the absolute value and adding 1.

For 8-bit two's complement:

- Range: -128 to +127
- +5: 00000101
- -5: 11111011 (invert 00000101 → 11111010, add 1 → 11111011)

For 32-bit two's complement:

- Range: -2,147,483,648 to +2,147,483,647

Two's complement allows the same hardware adder to perform both addition and subtraction. Adding a negative number (in two's complement) produces the correct result without special circuitry.

### Sign Extension

When converting a smaller signed value to a larger representation, **sign extension** replicates the sign bit into the additional high-order bits, preserving the value.

Converting 8-bit -5 (11111011) to 16-bit: 11111011 → 11111111 11111011

Converting 8-bit +5 (00000101) to 16-bit: 00000101 → 00000000 00000101

ARM provides specific instructions (SXTB, SXTH for signed; UXTB, UXTH for unsigned) for these operations.

### Floating-Point Representation

ARM processors implement IEEE 754 floating-point standard for representing real numbers. A floating-point number consists of three components: sign bit, exponent, and mantissa (fraction).

Single-precision (32-bit) format:

- 1 sign bit
- 8 exponent bits (biased by 127)
- 23 mantissa bits (with implicit leading 1)

Double-precision (64-bit) format:

- 1 sign bit
- 11 exponent bits (biased by 1023)
- 52 mantissa bits (with implicit leading 1)

The value represented is: (-1)^sign × 1.mantissa × 2^(exponent - bias)

[Inference] This representation allows for a wide range of magnitudes but with variable precision—larger numbers have less precision in the least significant digits.

### Bitwise Operations

Binary representations enable efficient bitwise operations that manipulate individual bits. **AND** produces 1 only when both bits are 1. **OR** produces 1 when at least one bit is 1. **XOR** produces 1 when bits differ. **NOT** inverts all bits.

These operations are fundamental for:

- Masking specific bits: `value & 0x0F` extracts lower 4 bits
- Setting bits: `value | 0x80` sets bit 7
- Clearing bits: `value & ~0x80` clears bit 7
- Toggling bits: `value ^ 0x80` toggles bit 7

### Bit Shifting

**Logical shift left (LSL)** shifts bits leftward, filling vacated positions with zeros. Each left shift by one position multiplies the value by 2.

**Logical shift right (LSR)** shifts bits rightward, filling vacated positions with zeros. Each right shift by one position divides unsigned values by 2.

**Arithmetic shift right (ASR)** shifts bits rightward but preserves the sign bit by replicating it, correctly dividing signed values by 2.

**Rotate right (ROR)** shifts bits rightward with bits shifted out re-entering from the left.

