## Number Systems and Base Conversions


A number system defines a structured method for representing quantities using a fixed set of symbols (digits) and a base (radix). The base determines how many unique digits are available and the positional weight of each digit.

---

### Positional Notation

Every number in a positional system follows the general form:

$$N = d_{n-1} \cdot r^{n-1} + d_{n-2} \cdot r^{n-2} + \cdots + d_1 \cdot r^1 + d_0 \cdot r^0$$

Where:

- $r$ = radix (base)
- $d_i$ = digit at position $i$
- Positions extend rightward into fractional parts using negative exponents

---

### The Four Primary Bases in Computing

|Base|Name|Digits Used|Prefix / Suffix Convention|
|---|---|---|---|
|2|Binary|0, 1|`0b` or subscript ₂|
|8|Octal|0–7|`0o` or subscript ₈|
|10|Decimal|0–9|none (default)|
|16|Hexadecimal|0–9, A–F|`0x` or subscript ₁₆|

---

### Why These Bases?

```
Binary     → Direct mapping to voltage levels (low/high = 0/1)
Octal      → Groups of 3 bits; used in Unix permissions, early systems
Hexadecimal→ Groups of 4 bits; compact representation of binary data
Decimal    → Human interface layer; I/O conversion required
```

---

### Conversion Methods

#### Decimal → Any Base (Repeated Division)

Divide the integer part repeatedly by the target base. Collect remainders in reverse order.

**Example:** Convert 156₁₀ to binary

```
156 ÷ 2 = 78  remainder 0
 78 ÷ 2 = 39  remainder 0
 39 ÷ 2 = 19  remainder 1
 19 ÷ 2 =  9  remainder 1
  9 ÷ 2 =  4  remainder 1
  4 ÷ 2 =  2  remainder 0
  2 ÷ 2 =  1  remainder 0
  1 ÷ 2 =  0  remainder 1
```

Read remainders bottom to top:

**Output:** 156₁₀ = `1001 1100`₂

---

#### Decimal Fraction → Any Base (Repeated Multiplication)

Multiply the fractional part by the base. Extract the integer part at each step. Read top to bottom.

**Example:** Convert 0.375₁₀ to binary

```
0.375 × 2 = 0.750 → integer part: 0
0.750 × 2 = 1.500 → integer part: 1
0.500 × 2 = 1.000 → integer part: 1
```

**Output:** 0.375₁₀ = `0.011`₂

> Some fractions that terminate in decimal do not terminate in binary (e.g., 0.1₁₀), producing infinitely repeating binary expansions. This is a root cause of floating-point rounding errors.

---

#### Any Base → Decimal (Expand by Positional Weights)

Multiply each digit by its positional weight and sum.

**Example:** Convert `1001 1100`₂ to decimal

```
1×2⁷ + 0×2⁶ + 0×2⁵ + 1×2⁴ + 1×2³ + 1×2² + 0×2¹ + 0×2⁰
= 128 + 0 + 0 + 16 + 8 + 4 + 0 + 0
= 156
```

**Output:** `1001 1100`₂ = 156₁₀

---

#### Binary ↔ Hexadecimal (Grouping Shortcut)

Because 16 = 2⁴, each hex digit maps exactly to a 4-bit group. No arithmetic required.

```
Binary:  1001  1100
Hex:       9     C
```

**Output:** `1001 1100`₂ = `9C`₁₆

Hex-to-binary is simply the reverse: expand each hex digit to 4 bits.

---

#### Binary ↔ Octal (Grouping Shortcut)

Because 8 = 2³, each octal digit maps exactly to a 3-bit group.

```
Binary:  001  001  110  000
Octal:     1    1    6    0
```

**Output:** `001 001 110 000`₂ = `1160`₈

---

### Conversion Diagram

<svg viewBox="0 0 640 340" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">

  <!-- Nodes -->
  <!-- Decimal -->
  <rect x="260" y="20" width="120" height="44" rx="8" fill="#1e3a5f" stroke="#4a9eff" stroke-width="1.5"/>
  <text x="320" y="47" text-anchor="middle" fill="#e0f0ff" font-size="14" font-weight="bold">Decimal</text>

  <!-- Binary -->
  <rect x="60" y="160" width="120" height="44" rx="8" fill="#1e3a5f" stroke="#4a9eff" stroke-width="1.5"/>
  <text x="120" y="187" text-anchor="middle" fill="#e0f0ff" font-size="14" font-weight="bold">Binary</text>

  <!-- Octal -->
  <rect x="260" y="270" width="120" height="44" rx="8" fill="#1e3a5f" stroke="#4a9eff" stroke-width="1.5"/>
  <text x="320" y="297" text-anchor="middle" fill="#e0f0ff" font-size="14" font-weight="bold">Octal</text>

  <!-- Hex -->
  <rect x="460" y="160" width="120" height="44" rx="8" fill="#1e3a5f" stroke="#4a9eff" stroke-width="1.5"/>
  <text x="520" y="187" text-anchor="middle" fill="#e0f0ff" font-size="14" font-weight="bold">Hex</text>

  <!-- Arrows: Decimal <-> Binary -->
  <line x1="220" y1="55" x2="145" y2="158" stroke="#4a9eff" stroke-width="1.2" marker-end="url(#arr)"/>
  <line x1="135" y1="158" x2="210" y2="60" stroke="#a0cfff" stroke-width="1.2" marker-end="url(#arr2)" stroke-dasharray="4,3"/>
  <text x="148" y="105" fill="#7ab8ff" font-size="11">÷2 rem</text>
  <text x="186" y="125" fill="#a0cfff" font-size="11">× weights</text>

  <!-- Arrows: Decimal <-> Hex -->
  <line x1="420" y1="55" x2="495" y2="158" stroke="#4a9eff" stroke-width="1.2" marker-end="url(#arr)"/>
  <line x1="505" y1="158" x2="430" y2="60" stroke="#a0cfff" stroke-width="1.2" marker-end="url(#arr2)" stroke-dasharray="4,3"/>
  <text x="450" y="100" fill="#7ab8ff" font-size="11">÷16 rem</text>
  <text x="428" y="125" fill="#a0cfff" font-size="11">× weights</text>

  <!-- Arrows: Binary <-> Hex (4-bit group) -->
  <line x1="180" y1="178" x2="458" y2="178" stroke="#f0a040" stroke-width="1.5" marker-end="url(#arr3)"/>
  <line x1="458" y1="190" x2="180" y2="190" stroke="#f0a040" stroke-width="1.5" marker-end="url(#arr3)" stroke-dasharray="4,3"/>
  <text x="295" y="170" fill="#f0c070" font-size="11">group 4 bits</text>
  <text x="295" y="205" fill="#f0c070" font-size="11">expand to 4 bits</text>

  <!-- Arrows: Binary <-> Octal (3-bit group) -->
  <line x1="140" y1="204" x2="275" y2="268" stroke="#60c090" stroke-width="1.5" marker-end="url(#arr4)"/>
  <line x1="280" y1="268" x2="145" y2="208" stroke="#60c090" stroke-width="1.5" marker-end="url(#arr4)" stroke-dasharray="4,3"/>
  <text x="170" y="252" fill="#80d8a8" font-size="11">group 3 bits</text>

  <!-- Arrows: Decimal <-> Octal -->
  <line x1="305" y1="64" x2="305" y2="268" stroke="#4a9eff" stroke-width="1.0" marker-end="url(#arr)" stroke-dasharray="5,3"/>
  <line x1="335" y1="268" x2="335" y2="64" stroke="#a0cfff" stroke-width="1.0" marker-end="url(#arr2)" stroke-dasharray="5,3"/>
  <text x="342" y="175" fill="#7ab8ff" font-size="11">÷8</text>

  <!-- Arrowhead markers -->
  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#4a9eff"/>
    </marker>
    <marker id="arr2" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#a0cfff"/>
    </marker>
    <marker id="arr3" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#f0a040"/>
    </marker>
    <marker id="arr4" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#60c090"/>
    </marker>
  </defs>
</svg>

---

### Hex Digit Reference Table

|Decimal|Binary|Hex|
|---|---|---|
|0|0000|0|
|1|0001|1|
|2|0010|2|
|3|0011|3|
|4|0100|4|
|5|0101|5|
|6|0110|6|
|7|0111|7|
|8|1000|8|
|9|1001|9|
|10|1010|A|
|11|1011|B|
|12|1100|C|
|13|1101|D|
|14|1110|E|
|15|1111|F|

---

### Fractional Representations

The positional notation extends symmetrically across the radix point:

```
Binary:   1  0  1  1  .  1  0  1
Weights: 2³ 2² 2¹ 2⁰   2⁻¹ 2⁻² 2⁻³
        = 8 + 0 + 2 + 1 + 0.5 + 0 + 0.125
        = 11.625₁₀
```

---

### Non-Terminating Binary Fractions

Some decimal fractions have no finite binary representation:

|Decimal|Binary (truncated)|Exact?|
|---|---|---|
|0.5|0.1|✓|
|0.25|0.01|✓|
|0.1|0.0001100110011…|✗|
|0.3|0.0100110011…|✗|

Only fractions whose denominator is a power of 2 terminate in binary. This has direct consequences for IEEE 754 floating-point representation (covered in the Data Representation module).

---

### Arithmetic Across Bases

#### Binary Addition Rules

```
0 + 0 = 0
0 + 1 = 1
1 + 0 = 1
1 + 1 = 0, carry 1
1 + 1 + 1 (carry) = 1, carry 1
```

**Example:**

```
  1001 1100   (156)
+ 0110 0011   ( 99)
-----------
  1111 1111   (255)
```

#### Hexadecimal Addition

Treat A–F as 10–15. Carry occurs when the sum ≥ 16.

```
  9C   (156)
+ 63   ( 99)
----
  FF   (255)
```

---

### Signed Representation Preview

Unsigned interpretations assume all bits represent magnitude. However, architectures must also represent negative numbers — this requires conventions such as sign-magnitude, one's complement, or two's complement, covered in detail under Integer Representation.

---

**Key Points**

- The radix determines digit count and positional weight at each column.
- Binary↔Hex and Binary↔Octal conversions are structural (grouping), not arithmetic.
- Decimal↔any-base conversions use repeated division (integers) and repeated multiplication (fractions).
- Not all decimal fractions have finite representations in binary; this is a fundamental precision constraint, not an implementation defect.

**Conclusion** Number system fluency is prerequisite to every subsequent topic in this course. Instruction encodings, memory addresses, IEEE 754 fields, and hardware datapaths all operate on bit patterns whose meaning depends entirely on the base and interpretation applied.

**Next Steps** Proceed to _Boolean Algebra and Logic Minimization_ to see how binary values are manipulated at the gate level, or jump to _Integer Representation_ to see how these bit patterns encode signed and unsigned quantities in hardware.

---

