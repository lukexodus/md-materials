## Data Representation


### Integer Representation

Integers in computers are stored in fixed-width formats. The size determines the range of values that can be represented.

Common sizes in x86:

- Byte: 8 bits
- Word: 16 bits
- Double word (DWORD): 32 bits
- Quad word (QWORD): 64 bits

### Unsigned Integers

Unsigned integers represent only non-negative values. All bits contribute to the magnitude.

**Example:**

- 8-bit unsigned range: 0 to 255 (2⁸ - 1)
- Binary 11111111₂ = 255₁₀
- Binary 00000000₂ = 0₁₀

For n bits, unsigned range is 0 to (2ⁿ - 1).

### Signed Integers: Two's Complement

Two's complement is the standard method for representing signed integers in modern computers. The most significant bit (MSB) serves as the sign bit: 0 for positive, 1 for negative.

**Why Two's Complement:** Two's complement simplifies arithmetic operations. Addition and subtraction use the same hardware circuitry regardless of sign, and there's only one representation for zero.

**Finding Two's Complement:**

To negate a number in two's complement:

1. Invert all bits (one's complement)
2. Add 1 to the result

**Example:**

- Positive 5 in 8-bit: 00000101₂
- Invert bits: 11111010₂
- Add 1: 11111011₂ = -5 in two's complement

**Range for Two's Complement:** For n bits: -2^(n-1) to 2^(n-1) - 1

- 8-bit signed: -128 to +127
- 16-bit signed: -32,768 to +32,767
- 32-bit signed: -2,147,483,648 to +2,147,483,647

**Interpreting Two's Complement Values:**

To convert a negative two's complement number to its magnitude:

1. Check MSB (if 1, number is negative)
2. Invert all bits
3. Add 1
4. The result is the magnitude (attach negative sign)

**Example:**

- Binary: 11111100₂
- MSB is 1 (negative number)
- Invert: 00000011₂
- Add 1: 00000100₂ = 4
- Result: -4₁₀

### Sign Extension

Sign extension preserves a number's value when increasing bit width. The sign bit is copied into the new higher-order bits.

**Example:**

- 8-bit: 11111100₂ (-4)
- Extended to 16-bit: 11111111 11111100₂ (still -4)
- 8-bit: 00000101₂ (+5)
- Extended to 16-bit: 00000000 00000101₂ (still +5)

### Overflow and Underflow

Overflow occurs when an arithmetic operation produces a result outside the representable range.

**Unsigned overflow example:**

- 8-bit: 255 + 1 = 256, but max is 255
- Result wraps to: 0 (with carry flag set)

**Signed overflow example:**

- 8-bit: 127 + 1 = 128, but max is +127
- Binary: 01111111 + 00000001 = 10000000 = -128 in two's complement
- This is incorrect; overflow flag is set

