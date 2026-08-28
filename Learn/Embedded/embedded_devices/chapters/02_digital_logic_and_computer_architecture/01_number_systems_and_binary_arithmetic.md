## Number Systems and Binary Arithmetic

### Overview

Number systems and binary arithmetic form the mathematical foundation of all digital electronics and embedded computing. Because microcontrollers and processors operate exclusively on electrical signals with two distinguishable states (high/low voltage), every value a system stores, transmits, or computes is ultimately represented in binary. Understanding how numbers are represented and manipulated at this level is essential for embedded engineers, since bugs involving overflow, sign extension, rounding, and bit manipulation trace directly back to these fundamentals.

### Positional Number Systems

**The General Concept**

A positional number system represents a value as a sum of digits multiplied by increasing powers of a base (radix). For a number with digits $d_n d_{n-1} \ldots d_1 d_0$ in base $b$, the value is:

$$N = \sum_{i=0}^{n} d_i \cdot b^i$$

The base determines both how many unique digit symbols exist and what each position's place value represents.

**Decimal (Base 10)**

The number system used in everyday human arithmetic, using digits 0–9. For example, $present in decimal as 473$ means $4 \cdot 10^2 + 7 \cdot 10^1 + 3 \cdot 10^0$.

**Binary (Base 2)**

The native number system of digital electronics, using only digits 0 and 1 (called **bits**). Each position represents a power of 2. For example, $1011_2 = 1 \cdot 2^3 + 0 \cdot 2^2 + 1 \cdot 2^1 + 1 \cdot 2^0 = 8 + 0 + 2 + 1 = 11_{10}$.

**Hexadecimal (Base 16)**

Widely used in embedded programming as a compact, human-readable representation of binary data, since each hexadecimal digit corresponds exactly to 4 bits (a nibble). Digits run 0–9 followed by A–F (representing 10–15). For example, $2F_{16} = 2 \cdot 16^1 + 15 \cdot 16^0 = 32 + 15 = 47_{10}$, and in binary this is $00101111_2$ — note how the two hex digits map directly onto the two nibbles.

**Octal (Base 8)**

Less common in modern embedded work but historically significant, using digits 0–7, with each digit representing 3 bits. Octal still appears in some contexts such as Unix file permission notation.

### Conversion Between Number Systems

**Binary to Decimal**

Sum the value of each bit position where a 1 appears, as shown in the binary example above.

**Decimal to Binary**

Repeatedly divide the decimal number by 2, recording the remainder at each step; the binary representation is the sequence of remainders read in reverse order. For example, converting $13_{10}$: $13 \div 2 = 6$ remainder $1$; $6 \div 2 = 3$ remainder $0$; $3 \div 2 = 1$ remainder $1$; $1 \div 2 = 0$ remainder $1$. Reading remainders bottom-to-top gives $1101_2$.

**Binary to Hexadecimal**

Group binary digits into sets of 4 (nibbles), starting from the least significant bit, padding with leading zeros if needed, then convert each nibble independently to its hex digit. For example, $10110101_2$ splits into $1011$ and $0101$, giving $B5_{16}$.

**Hexadecimal to Binary**

The reverse process: expand each hex digit into its 4-bit binary equivalent and concatenate.

### Illustration: Base Conversion Reference

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 260" font-family="sans-serif">
  <text x="400" y="28" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Decimal, Binary, Hex Reference (svg_diagram)</text>

  <text x="80" y="60" font-size="13" font-weight="bold" fill="#1a1a1a">Decimal</text>
  <text x="280" y="60" font-size="13" font-weight="bold" fill="#1a1a1a">Binary</text>
  <text x="480" y="60" font-size="13" font-weight="bold" fill="#1a1a1a">Hex</text>

  <text x="80" y="90" font-size="12" fill="#2b6cb0">0</text>
  <text x="280" y="90" font-size="12" fill="#2b6cb0">0000</text>
  <text x="480" y="90" font-size="12" fill="#2b6cb0">0</text>

  <text x="80" y="115" font-size="12" fill="#2b6cb0">5</text>
  <text x="280" y="115" font-size="12" fill="#2b6cb0">0101</text>
  <text x="480" y="115" font-size="12" fill="#2b6cb0">5</text>

  <text x="80" y="140" font-size="12" fill="#2b6cb0">10</text>
  <text x="280" y="140" font-size="12" fill="#2b6cb0">1010</text>
  <text x="480" y="140" font-size="12" fill="#2b6cb0">A</text>

  <text x="80" y="165" font-size="12" fill="#2b6cb0">15</text>
  <text x="280" y="165" font-size="12" fill="#2b6cb0">1111</text>
  <text x="480" y="165" font-size="12" fill="#2b6cb0">F</text>

  <text x="80" y="190" font-size="12" fill="#2b6cb0">255</text>
  <text x="280" y="190" font-size="12" fill="#2b6cb0">1111 1111</text>
  <text x="480" y="190" font-size="12" fill="#2b6cb0">FF</text>

  <text x="80" y="215" font-size="12" fill="#2b6cb0">4095</text>
  <text x="280" y="215" font-size="12" fill="#2b6cb0">1111 1111 1111</text>
  <text x="480" y="215" font-size="12" fill="#2b6cb0">FFF</text>
</svg>

### Signed Number Representation

**The Problem**

Binary as described so far only represents non-negative integers. Embedded systems must also represent negative numbers using a fixed number of bits, which requires a defined encoding convention.

**Sign-Magnitude**

The most significant bit (MSB) indicates sign (0 = positive, 1 = negative), and the remaining bits represent magnitude. This approach is conceptually simple but creates two representations of zero (+0 and −0) and complicates arithmetic circuit design, which is why it is rarely used in modern processors.

**Two's Complement**

The dominant representation in virtually all modern processors and microcontrollers. To negate a number in two's complement: invert all bits, then add 1. For example, to represent $-5$ in 8 bits: $5_{10} = 00000101_2$; inverting gives $11111010$; adding 1 gives $11111011_2$, which represents $-5$.

**Why Two's Complement Dominates**

- It has a single representation of zero.
- Addition and subtraction can use the same hardware circuitry regardless of sign, since subtraction is implemented as adding the two's complement of the subtrahend.
- The MSB still conveniently indicates sign (0 = positive/zero, 1 = negative), matching intuition.

For an $n$-bit two's complement number, the representable range is:

$$-2^{n-1} \text{ to } 2^{n-1} - 1$$

For example, an 8-bit signed integer ranges from $-128$ to $127$.

### Binary Arithmetic Operations

**Binary Addition**

Follows the same positional carry logic as decimal addition, but with only two digit values. The basic rules: $0+0=0$, $0+1=1$, $1+0=1$, $1+1=10$ (write 0, carry 1). For example:

```
  0110  (6)
+ 0101  (5)
------
  1011  (11)
```

**Overflow in Addition**

When adding two signed numbers of the same sign produces a result whose sign bit differs from both operands, an overflow has occurred — the result cannot be correctly represented in the available bit width. Embedded engineers must account for this explicitly, since silent overflow can produce a plausible-looking but incorrect result rather than an obvious error. [Inference] Whether overflow is trapped as an error, wraps silently, or is detected via a status flag depends on the specific processor architecture and how the compiler/language handles the operation, so behavior should be verified against the target platform's documentation rather than assumed universally.

**Binary Subtraction via Two's Complement**

Rather than implementing separate subtraction logic, most processors compute $A - B$ as $A + (\text{two's complement of } B)$, allowing the same adder circuit to handle both addition and subtraction.

**Bitwise Operations**

Distinct from arithmetic operations, bitwise operations act independently on each bit position:
- **AND (&)**: result bit is 1 only if both input bits are 1 — commonly used for masking specific bits.
- **OR (|)**: result bit is 1 if either input bit is 1 — commonly used for setting specific bits.
- **XOR (^)**: result bit is 1 if the input bits differ — commonly used for toggling bits or simple checksums.
- **NOT (~)**: inverts every bit.
- **Shift left (\<\<) / Shift right (\>\>)**: moves bits by a specified number of positions, commonly used for efficient multiplication/division by powers of two and for extracting specific bit fields from a register value.

These operations are used pervasively in embedded firmware for tasks such as setting or clearing individual bits in a hardware register without disturbing other bits.

### Fixed-Point and Floating-Point Representation

**Fixed-Point Representation**

Represents fractional values by treating a fixed number of the integer's bits as representing a fractional component, with an implied (not stored) binary point position. Fixed-point arithmetic is common on small microcontrollers lacking a hardware floating-point unit (FPU), since it can be implemented using ordinary integer arithmetic instructions, offering predictable performance and lower resource usage.

**Floating-Point Representation**

Represents a wide dynamic range of values (including very large and very small magnitudes) using a sign bit, an exponent field, and a mantissa (significand) field, most commonly following the **IEEE 754** standard. Many mid-range and larger microcontrollers include a hardware FPU to accelerate these operations; smaller microcontrollers without an FPU must emulate floating-point arithmetic in software, which is significantly slower.

[Inference] Whether a given embedded design should use fixed-point or floating-point arithmetic depends on the specific processor's capabilities, the required precision, and performance/power constraints — this is a design decision rather than a strictly "better/worse" choice between the two approaches.

### Comparative Summary

| Concept | Purpose | Common Embedded Use |
|---|---|---|
| Binary | Native digital representation | All internal data representation |
| Hexadecimal | Compact, human-readable binary | Memory addresses, register values, debugging |
| Two's complement | Signed integer representation | Standard signed arithmetic on virtually all processors |
| Bitwise operations | Direct bit-level manipulation | Register configuration, flag manipulation, masking |
| Fixed-point | Fractional values without FPU | Small MCUs, deterministic real-time math |
| Floating-point | Wide dynamic range fractional values | MCUs/MPUs with FPU, sensor scaling, DSP algorithms |

### Practical Example: Configuring a Hardware Register

A common embedded task is enabling a specific peripheral feature by setting a single bit in a hardware control register without disturbing other bits, illustrating bitwise operations in practice:

```c
#define ENABLE_BIT (1 << 3)  // Binary: 00001000, Hex: 0x08

// Set the bit (enable the feature) without affecting other bits
CONTROL_REGISTER |= ENABLE_BIT;

// Clear the bit (disable the feature) without affecting other bits
CONTROL_REGISTER &= ~ENABLE_BIT;

// Check whether the bit is currently set
if (CONTROL_REGISTER & ENABLE_BIT) {
    // Feature is enabled
}
```

This pattern — using shift, OR, AND, and NOT operations together — appears constantly in embedded firmware, since most hardware peripherals are controlled through individual bits or bit fields within memory-mapped registers rather than through higher-level function calls.

### Related Topics

- What defines an embedded system
- Microcontroller architecture and memory-mapped registers
- Fixed-point vs. floating-point arithmetic in embedded systems
- Digital logic gates and Boolean algebra
- Data types and memory representation in embedded C
- Bit manipulation techniques for register configuration
- Analog-to-digital conversion and quantization