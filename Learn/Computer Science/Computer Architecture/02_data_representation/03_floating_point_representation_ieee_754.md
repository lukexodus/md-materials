## Floating-Point Representation (IEEE 754)


Floating-point representation provides a mechanism for encoding real numbers in binary with a fixed number of bits, balancing range and precision through a standardized format. IEEE 754, established in 1985 and revised in 2008, is the dominant standard governing floating-point arithmetic in virtually all modern hardware and software systems.

---

### The General Structure

A floating-point number is expressed as:

$$(-1)^S \times M \times 2^E$$

where:

- **S** — sign bit (0 = positive, 1 = negative)
- **M** — mantissa (also called significand or fraction)
- **E** — exponent (biased integer)

The three fields are packed into a fixed-width binary word. IEEE 754 defines several precision formats; the two most common are **single precision (32-bit)** and **double precision (64-bit)**.

---

### Standard Formats

|Format|Total bits|Sign|Exponent|Fraction|Bias|
|---|---|---|---|---|---|
|Half (binary16)|16|1|5|10|15|
|Single (binary32)|32|1|8|23|127|
|Double (binary64)|64|1|11|52|1023|
|Extended (x87)|80|1|15|64|16383|

The bit layout for **single precision**:

```
Bit 31       30–23          22–0
  [S]  [Exponent: 8 bits]  [Fraction: 23 bits]
```

---

### Normalization and the Hidden Bit

In a **normalized** number, the significand is always adjusted so that its leading binary digit is 1:

$$M = 1.f_1 f_2 f_3 \ldots f_{23}$$

Because this leading 1 is always present in normalized form, it is **not stored** — it is implicit. This is the **hidden bit** convention, which effectively gives 24 bits of precision using only 23 stored fraction bits (53 bits for double).

The stored fraction field contains only the fractional part $f_1 f_2 \ldots f_{23}$ after the binary point.

---

### Biased Exponent Encoding

The exponent is stored as an **unsigned integer with a bias** subtracted to recover the true exponent:

$$E_\text{true} = E_\text{stored} - \text{Bias}$$

For single precision, Bias = 127. This means:

- Stored value `00000001` → true exponent = 1 − 127 = **−126**
- Stored value `01111111` → true exponent = 127 − 127 = **0**
- Stored value `11111110` → true exponent = 254 − 127 = **127**

Biased encoding is used (rather than two's complement) so that floating-point numbers can be compared as unsigned integers — a useful hardware optimization.

---

### Special Values

IEEE 754 reserves certain exponent patterns for special values:

|Exponent (stored)|Fraction|Meaning|
|---|---|---|
|`00000000` (all 0s)|`0`|±Zero|
|`00000000` (all 0s)|≠ `0`|Subnormal (denormalized)|
|`11111111` (all 1s)|`0`|±Infinity|
|`11111111` (all 1s)|≠ `0`|NaN (Not a Number)|
|anything else|any|Normalized number|

This leaves the usable normalized exponent range for single precision as stored values **1 through 254**, giving true exponents **−126 through +127**.

---

### Subnormal Numbers

When the stored exponent is all zeros, the hidden bit convention is **disabled** and the number is treated as:

$$(-1)^S \times 0.f_1 f_2 \ldots f_{23} \times 2^{-126}$$

Subnormals fill the **underflow gap** between zero and the smallest normalized number ($2^{-126}$), allowing gradual underflow. Without them, numbers smaller than $2^{-126}$ would flush abruptly to zero.

```
Number line near zero (not to scale):

  −Normalized ← −Subnormal ← −0  +0 → +Subnormal → +Normalized →
               ↑                                   ↑
          smallest normal                     smallest normal
          (negative side)                     (positive side)
           2^−126                               2^−126
```

---

### NaN Variants

IEEE 754 defines two kinds of NaN:

- **Quiet NaN (QNaN)** — propagates through operations silently; the MSB of the fraction field is **1**.
- **Signaling NaN (SNaN)** — raises a floating-point exception when used; the MSB of the fraction is **0** (with at least one other fraction bit set to avoid confusion with infinity).

NaN is **unordered** with respect to all values, including itself: `NaN == NaN` is false.

---

### Encoding a Number — Step by Step

**Example:** Encode **−12.375** in IEEE 754 single precision.

**Step 1 — Sign** Negative → S = `1`

**Step 2 — Convert to binary**

- Integer part: 12 = `1100`
- Fractional part: 0.375 = 0.011 (0.375 × 2 = 0.75 → 0; 0.75 × 2 = 1.5 → 1; 0.5 × 2 = 1.0 → 1)
- Combined: `1100.011`

**Step 3 — Normalize** `1100.011` = `1.100011 × 2³` Fraction field = `10001100000000000000000` (23 bits, trailing zeros)

**Step 4 — Biased exponent** True exponent = 3 → stored = 3 + 127 = 130 = `10000010`

**Step 5 — Assemble**

```
S        Exponent         Fraction
1   |  10000010  |  10001100000000000000000
```

Hex: `C1460000`

**Output:**

```
Binary:  1 10000010 10001100000000000000000
Hex:     0xC1460000
```

---

### Range and Precision

For single precision:

|Property|Value|
|---|---|
|Largest normalized|≈ 3.4 × 10³⁸|
|Smallest normalized|≈ 1.18 × 10⁻³⁸|
|Smallest subnormal|≈ 1.4 × 10⁻⁴⁵|
|Decimal digits of precision|≈ 7|

For double precision:

|Property|Value|
|---|---|
|Largest normalized|≈ 1.8 × 10³⁰⁸|
|Smallest normalized|≈ 2.2 × 10⁻³⁰⁸|
|Decimal digits of precision|≈ 15–16|

---

### Machine Epsilon

**Machine epsilon** (ε) is the smallest value such that `1.0 + ε ≠ 1.0`. It characterizes the relative precision of a format:

$$\varepsilon = 2^{-p+1}$$

where $p$ is the number of significand bits (including the hidden bit).

- Single: ε ≈ 1.19 × 10⁻⁷
- Double: ε ≈ 2.22 × 10⁻¹⁶

---

### Rounding Modes

IEEE 754 mandates four rounding modes:

|Mode|Description|
|---|---|
|Round to nearest, ties to even (default)|Rounds to nearest; on tie, rounds to even last bit (banker's rounding)|
|Round to nearest, ties away from zero|Rounds tie cases away from zero|
|Round toward +∞ (ceiling)|Always rounds up|
|Round toward −∞ (floor)|Always rounds down|
|Round toward zero (truncation)|Strips the extra bits|

The **round-to-nearest, ties-to-even** default minimizes cumulative bias in long computations.

---

### Arithmetic Operations and the Guard Bits

During floating-point arithmetic, intermediate results use extra bits to preserve accuracy before final rounding:

- **Guard bit** — first bit beyond the stored precision
- **Round bit** — second bit beyond precision
- **Sticky bit** — OR of all remaining bits; set if any lower bit is nonzero

These three bits together allow the hardware to apply the correct rounding mode without significant error.

---

### IEEE 754-2008 Extensions

The 2008 revision added:

- **binary16** (half precision) — for graphics, ML inference
- **decimal32 / decimal64 / decimal128** — for financial applications where decimal fractions must be exact
- **Fused Multiply-Add (FMA)** — computes $a \times b + c$ with a single rounding, improving both accuracy and performance
- Formal specification of **exception handling** (invalid operation, division by zero, overflow, underflow, inexact)

---

### Common Pitfalls

**1. Representation error** 0.1 cannot be represented exactly in binary floating-point. Its stored value is approximately `0.100000001490116119384765625` in single precision, leading to accumulation of error in repeated addition.

**2. Catastrophic cancellation** Subtracting two nearly equal numbers causes massive loss of significant bits:

```
a = 1.0000001
b = 1.0000000
a − b = 0.0000001   ← only 1 significant bit remains
```

**3. Associativity failure** Floating-point addition is **not** associative: `(a + b) + c ≠ a + (b + c)` in general due to rounding at each step.

**4. Overflow and underflow**

- Overflow → ±Infinity
- Underflow → subnormal or zero (with loss of precision)

---

### Visual Summary of the Value Space

```svg
<svg viewBox="0 0 720 260" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">

  <!-- Background -->
  <rect width="720" height="260" fill="#0d1117"/>

  <!-- Number line -->
  <line x1="40" y1="130" x2="680" y2="130" stroke="#58a6ff" stroke-width="2"/>
  <polygon points="680,125 692,130 680,135" fill="#58a6ff"/>

  <!-- Zero -->
  <line x1="360" y1="120" x2="360" y2="140" stroke="#f0f6fc" stroke-width="2"/>
  <text x="356" y="158" fill="#f0f6fc">0</text>

  <!-- Negative infinity marker -->
  <line x1="50" y1="120" x2="50" y2="140" stroke="#ff7b72" stroke-width="2"/>
  <text x="30" y="158" fill="#ff7b72">−∞</text>

  <!-- Positive infinity marker -->
  <line x1="670" y1="120" x2="670" y2="140" stroke="#ff7b72" stroke-width="2"/>
  <text x="656" y="158" fill="#ff7b72">+∞</text>

  <!-- Negative normalized region -->
  <rect x="80" y="110" width="230" height="20" fill="#388bfd" opacity="0.5" rx="3"/>
  <text x="140" y="104" fill="#79c0ff" font-size="11">Negative Normalized</text>

  <!-- Positive normalized region -->
  <rect x="410" y="110" width="230" height="20" fill="#388bfd" opacity="0.5" rx="3"/>
  <text x="460" y="104" fill="#79c0ff" font-size="11">Positive Normalized</text>

  <!-- Negative subnormal -->
  <rect x="310" y="110" width="45" height="20" fill="#3fb950" opacity="0.6" rx="3"/>
  <text x="295" y="172" fill="#56d364" font-size="10">−sub</text>

  <!-- Positive subnormal -->
  <rect x="365" y="110" width="45" height="20" fill="#3fb950" opacity="0.6" rx="3"/>
  <text x="370" y="172" fill="#56d364" font-size="10">+sub</text>

  <!-- NaN labels -->
  <rect x="50" y="110" width="28" height="20" fill="#d29922" opacity="0.7" rx="3"/>
  <text x="42" y="172" fill="#e3b341" font-size="10">NaN</text>

  <rect x="642" y="110" width="28" height="20" fill="#d29922" opacity="0.7" rx="3"/>
  <text x="634" y="172" fill="#e3b341" font-size="10">NaN</text>

  <!-- Legend -->
  <rect x="60" y="200" width="14" height="14" fill="#388bfd" opacity="0.7" rx="2"/>
  <text x="80" y="212" fill="#c9d1d9" font-size="11">Normalized</text>

  <rect x="180" y="200" width="14" height="14" fill="#3fb950" opacity="0.8" rx="2"/>
  <text x="200" y="212" fill="#c9d1d9" font-size="11">Subnormal</text>

  <rect x="300" y="200" width="14" height="14" fill="#d29922" opacity="0.8" rx="2"/>
  <text x="320" y="212" fill="#c9d1d9" font-size="11">NaN</text>

  <rect x="390" y="200" width="14" height="14" fill="#ff7b72" opacity="0.8" rx="2"/>
  <text x="410" y="212" fill="#c9d1d9" font-size="11">±Infinity</text>

  <!-- Title -->
  <text x="230" y="30" fill="#f0f6fc" font-size="14" font-weight="bold">IEEE 754 Single-Precision Value Space</text>
  <text x="220" y="50" fill="#8b949e" font-size="11">(not to scale — subnormal region greatly exaggerated)</text>

</svg>
```

---

### Conversion Quick-Reference

```
Given a 32-bit word in hex → float:

1. Extract bits [31], [30:23], [22:0]
2. E_true = E_stored − 127
3. If E_stored ∈ [1, 254]:   value = (−1)^S × 1.fraction × 2^E_true
4. If E_stored = 0, frac ≠ 0: value = (−1)^S × 0.fraction × 2^−126   (subnormal)
5. If E_stored = 0, frac = 0: value = ±0
6. If E_stored = 255, frac = 0: value = ±∞
7. If E_stored = 255, frac ≠ 0: value = NaN
```

---

**Conclusion** IEEE 754 encodes real numbers through a sign bit, a biased exponent, and a normalized significand with an implicit leading 1. Special patterns extend the system to represent zero, subnormals, infinities, and NaN, covering the full domain of numerical computation. The bias encoding, hidden bit optimization, guard/round/sticky rounding machinery, and mandated exception semantics collectively make IEEE 754 a complete and hardware-efficient standard. Mastery of its encoding rules, precision limits, and failure modes — particularly representation error, cancellation, and non-associativity — is essential for reasoning about the numerical behavior of any real system.

**Next Steps** Proceed to **Binary Arithmetic and Overflow** to examine how addition, subtraction, multiplication, and division are executed at the bit level and how overflow conditions are detected and handled for both integer and floating-point types.

---

