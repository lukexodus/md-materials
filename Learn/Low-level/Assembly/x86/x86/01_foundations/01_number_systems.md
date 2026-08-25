## Number Systems


### Binary (Base-2)

Binary uses only two digits: 0 and 1. Each digit position represents a power of 2, starting from 2^0 on the right.

**Example:**

- Binary: 1011₂
- Calculation: (1 × 2³) + (0 × 2²) + (1 × 2¹) + (1 × 2⁰) = 8 + 0 + 2 + 1 = 11₁₀

Converting decimal to binary involves repeatedly dividing by 2 and recording remainders in reverse order.

**Example:**

- Decimal 13 to binary:
    - 13 ÷ 2 = 6 remainder 1
    - 6 ÷ 2 = 3 remainder 0
    - 3 ÷ 2 = 1 remainder 1
    - 1 ÷ 2 = 0 remainder 1
    - Result: 1101₂

### Hexadecimal (Base-16)

Hexadecimal uses 16 digits: 0-9 and A-F (where A=10, B=11, C=12, D=13, E=14, F=15). Each hex digit represents 4 binary bits, making it compact for representing binary data.

**Example:**

- Hex: 2A₁₆
- Calculation: (2 × 16¹) + (10 × 16⁰) = 32 + 10 = 42₁₀
- Binary equivalent: 0010 1010₂

Converting between binary and hexadecimal is straightforward by grouping bits into sets of 4.

**Example:**

- Binary: 11010111₂
- Group into 4-bit chunks: 1101 0111
- Convert each group: D (13) and 7
- Result: D7₁₆

### Octal (Base-8)

Octal uses digits 0-7. Each octal digit represents 3 binary bits. While less common in modern systems, octal was historically used in some computing contexts.

**Example:**

- Octal: 17₈
- Calculation: (1 × 8¹) + (7 × 8⁰) = 8 + 7 = 15₁₀
- Binary equivalent: 001 111₂

### Conversion Summary Table

|Decimal|Binary|Hexadecimal|Octal|
|---|---|---|---|
|0|0000|0|0|
|1|0001|1|1|
|8|1000|8|10|
|15|1111|F|17|
|16|10000|10|20|
|255|11111111|FF|377|

