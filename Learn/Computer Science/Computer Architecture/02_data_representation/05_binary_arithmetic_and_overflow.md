## Binary Arithmetic and Overflow


Binary arithmetic extends familiar arithmetic operations to base-2 representations. Overflow is the condition that arises when a result exceeds the range representable by a fixed number of bits — a fundamental concern in hardware design, compiler construction, and systems programming.

---

### Addition

#### Unsigned Addition

Addition proceeds identically to decimal addition, carrying when the column sum reaches 2.

```
  0 1 1 0 1   (13)
+ 0 1 0 1 1   (11)
-----------
  1 1 0 0 0   (24)
```

Each bit position computes a **sum bit** and a **carry bit**:

|A|B|Cᵢₙ|Sum|Cₒᵤₜ|
|---|---|---|---|---|
|0|0|0|0|0|
|0|1|0|1|0|
|1|1|0|0|1|
|1|1|1|1|1|

```
Sum   = A ⊕ B ⊕ Cᵢₙ
Cₒᵤₜ = A·B + Cᵢₙ·(A ⊕ B)
```

#### Signed Addition (Two's Complement)

Two's complement addition uses the same hardware as unsigned addition. The representation encodes negative numbers such that:

```
-X = ~X + 1     (bitwise NOT, then add 1)
```

For an _n_-bit two's complement number:

- Range: −2^(n−1) to 2^(n−1) − 1
- Addition wraps modulo 2ⁿ

```
  1 1 1 1 1 0   (−2, 6-bit)
+ 1 1 1 1 0 1   (−3, 6-bit)
-----------
1 1 1 1 0 1 1   → discard carry-out → 1 1 1 0 1 1 = −5 ✓
```

---

### Subtraction

Subtraction is performed by adding the two's complement of the subtrahend — no separate subtraction circuit is required.

```
A − B = A + (−B) = A + (~B + 1)
```

**Example:** 9 − 3 in 5-bit two's complement

```
  3 = 0 0 0 1 1
 ~3 = 1 1 1 0 0
 −3 = 1 1 1 0 1

  0 1 0 0 1   (+9)
+ 1 1 1 0 1   (−3)
-----------
1 0 0 1 1 0   → discard carry-out → 0 0 1 1 0 = +6 ✓
```

---

### Multiplication

#### Unsigned Multiplication

Binary multiplication reduces to shift-and-add operations. For each bit of the multiplier, if the bit is 1, the multiplicand is shifted left by the bit position and added to a running partial product sum.

```
    0 1 1 0 1   (13)
  × 0 0 1 0 1   (5)
  ---------
    0 1 1 0 1   ← bit 0 = 1: shift 0
    0 0 0 0 0   ← bit 1 = 0
  0 1 1 0 1 0 0 ← bit 2 = 1: shift 2
  ---------
  1 0 0 0 0 0 1 = 65 ✓
```

An _n_ × _n_ multiplication produces a result up to **2n bits wide**. Hardware must allocate double the width to hold the full product.

#### Signed Multiplication — Booth's Algorithm

Booth's algorithm handles signed two's complement multiplication efficiently by recoding the multiplier to reduce the number of partial product additions.

**Radix-2 Booth recoding** examines pairs of consecutive multiplier bits:

|Bits (bᵢ₊₁, bᵢ)|Operation|
|---|---|
|0 0|No operation (shift)|
|0 1|Add multiplicand|
|1 0|Subtract multiplicand|
|1 1|No operation (shift)|

This works because a run of 1s such as `0 1 1 1 0` is equivalent to `1 0 0 0 −1` — replacing a sequence of additions with one addition and one subtraction.

---

### Division

Binary division mirrors long division. Hardware implementations use either:

- **Restoring division**: if the partial remainder goes negative, restore it by adding the divisor back before shifting
- **Non-restoring division**: allow negative partial remainders and correct at the end — fewer operations per step

Both produce a quotient and a remainder. Division by zero must be detected explicitly in hardware or trapped as an exception.

---

### Arithmetic Circuits

<svg viewBox="0 0 580 260" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <!-- Full Adder block --> <rect x="200" y="80" width="180" height="100" rx="6" fill="none" stroke="#888" stroke-width="1.5"/> <text x="290" y="136" text-anchor="middle" fill="#ccc" font-size="13">Full Adder</text> <!-- Inputs --> <line x1="80" y1="100" x2="200" y2="100" stroke="#7af" stroke-width="1.5"/> <text x="70" y="104" text-anchor="end" fill="#7af">A</text> <line x1="80" y1="130" x2="200" y2="130" stroke="#7af" stroke-width="1.5"/> <text x="70" y="134" text-anchor="end" fill="#7af">B</text> <line x1="80" y1="160" x2="200" y2="160" stroke="#7af" stroke-width="1.5"/> <text x="70" y="164" text-anchor="end" fill="#7af">Cᵢₙ</text> <!-- Outputs --> <line x1="380" y1="110" x2="500" y2="110" stroke="#fa7" stroke-width="1.5"/> <text x="510" y="114" fill="#fa7">Sum</text> <line x1="380" y1="150" x2="500" y2="150" stroke="#fa7" stroke-width="1.5"/> <text x="510" y="154" fill="#fa7">Cₒᵤₜ</text> <!-- Equations below --> <text x="290" y="220" text-anchor="middle" fill="#aaa">Sum = A ⊕ B ⊕ Cᵢₙ</text> <text x="290" y="240" text-anchor="middle" fill="#aaa">Cₒᵤₜ = A·B + Cᵢₙ·(A⊕B)</text> </svg>

#### Ripple Carry Adder (RCA)

Full adders are chained such that each Cₒᵤₜ feeds the next stage's Cᵢₙ. For _n_ bits, the critical path traverses _n_ full adders.

<svg viewBox="0 0 620 130" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- FA3 --> <rect x="30" y="30" width="80" height="60" rx="4" fill="none" stroke="#888" stroke-width="1.5"/> <text x="70" y="65" text-anchor="middle" fill="#ccc">FA₃</text> <!-- FA2 --> <rect x="170" y="30" width="80" height="60" rx="4" fill="none" stroke="#888" stroke-width="1.5"/> <text x="210" y="65" text-anchor="middle" fill="#ccc">FA₂</text> <!-- FA1 --> <rect x="310" y="30" width="80" height="60" rx="4" fill="none" stroke="#888" stroke-width="1.5"/> <text x="350" y="65" text-anchor="middle" fill="#ccc">FA₁</text> <!-- FA0 --> <rect x="450" y="30" width="80" height="60" rx="4" fill="none" stroke="#888" stroke-width="1.5"/> <text x="490" y="65" text-anchor="middle" fill="#ccc">FA₀</text> <!-- Carry chain --> <line x1="110" y1="60" x2="170" y2="60" stroke="#f88" stroke-width="1.5"/> <line x1="250" y1="60" x2="310" y2="60" stroke="#f88" stroke-width="1.5"/> <line x1="390" y1="60" x2="450" y2="60" stroke="#f88" stroke-width="1.5"/> <!-- Cin far right --> <line x1="560" y1="60" x2="530" y2="60" stroke="#f88" stroke-width="1.5"/> <text x="575" y="64" text-anchor="middle" fill="#f88">C₀</text> <!-- Cout far left --> <line x1="30" y1="60" x2="10" y2="60" stroke="#f88" stroke-width="1.5"/> <text x="6" y="64" text-anchor="end" fill="#f88">Cₒᵤₜ</text> <!-- Carry labels --> <text x="140" y="52" text-anchor="middle" fill="#f88" font-size="10">C₃</text> <text x="280" y="52" text-anchor="middle" fill="#f88" font-size="10">C₂</text> <text x="420" y="52" text-anchor="middle" fill="#f88" font-size="10">C₁</text> <!-- Sum outputs --> <line x1="70" y1="90" x2="70" y2="115" stroke="#7af" stroke-width="1.2"/> <text x="70" y="125" text-anchor="middle" fill="#7af">S₃</text> <line x1="210" y1="90" x2="210" y2="115" stroke="#7af" stroke-width="1.2"/> <text x="210" y="125" text-anchor="middle" fill="#7af">S₂</text> <line x1="350" y1="90" x2="350" y2="115" stroke="#7af" stroke-width="1.2"/> <text x="350" y="125" text-anchor="middle" fill="#7af">S₁</text> <line x1="490" y1="90" x2="490" y2="115" stroke="#7af" stroke-width="1.2"/> <text x="490" y="125" text-anchor="middle" fill="#7af">S₀</text> </svg>

**Delay:** O(n) — carries propagate serially from LSB to MSB.

#### Carry Lookahead Adder (CLA)

CLA eliminates serial carry propagation by computing carries in parallel using two intermediate signals:

```
Generate:   Gᵢ = Aᵢ · Bᵢ           (this stage always produces a carry)
Propagate:  Pᵢ = Aᵢ ⊕ Bᵢ           (this stage passes a carry through)

Carry:      Cᵢ₊₁ = Gᵢ + Pᵢ · Cᵢ
```

Expanding for 4 bits:

```
C₁ = G₀ + P₀·C₀
C₂ = G₁ + P₁·G₀ + P₁·P₀·C₀
C₃ = G₂ + P₂·G₁ + P₂·P₁·G₀ + P₂·P₁·P₀·C₀
C₄ = G₃ + P₃·G₂ + P₃·P₂·G₁ + P₃·P₂·P₁·G₀ + P₃·P₂·P₁·P₀·C₀
```

All carries are computed simultaneously in O(log n) gate delays, at the cost of increased logic complexity.

---

### Overflow

Overflow occurs when an arithmetic result falls outside the representable range of the chosen format and bit width.

#### Unsigned Overflow

For _n_-bit unsigned addition, overflow occurs when the result exceeds 2ⁿ − 1. This is detected by a carry-out from the MSB.

```
n = 4, range: 0 to 15

  1 1 1 0   (14)
+ 0 0 1 1   (3)
---------
1 0 0 0 1   → carry-out = 1 → OVERFLOW (result = 17, not representable)
```

**Detection:** Cₒᵤₜ of the MSB = 1

#### Signed Overflow (Two's Complement)

For _n_-bit signed addition, overflow occurs when the result exceeds 2^(n−1) − 1 (positive overflow) or falls below −2^(n−1) (negative overflow). Carry-out alone is insufficient for detection.

**Overflow conditions:**

- Adding two positives yields a negative result
- Adding two negatives yields a positive result

(Adding operands of opposite signs can never overflow.)

**Detection rule:**

```
Overflow = Cₙ₋₁ ⊕ Cₙ

where Cₙ₋₁ = carry into MSB
      Cₙ   = carry out of MSB
```

Equivalently:

```
Overflow = (A[n-1] = B[n-1]) AND (Result[n-1] ≠ A[n-1])
```

**Positive overflow example** (4-bit, range −8 to +7):

```
  0 1 1 0   (+6)
+ 0 0 1 1   (+3)
---------
  1 0 0 1   (−7 in two's complement) ← OVERFLOW: two positives summed to negative
```

**Negative overflow example:**

```
  1 0 1 0   (−6)
+ 1 1 0 1   (−3)
---------
1 0 1 1 1   → discard carry → 0 1 1 1 = +7 ← OVERFLOW: two negatives summed to positive
```

<svg viewBox="0 0 540 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <!-- Number line --> <line x1="40" y1="100" x2="500" y2="100" stroke="#888" stroke-width="1.5"/> <!-- Zero marker --> <line x1="270" y1="90" x2="270" y2="110" stroke="#ccc" stroke-width="1.5"/> <text x="270" y="125" text-anchor="middle" fill="#ccc">0</text> <!-- Min marker --> <line x1="60" y1="90" x2="60" y2="110" stroke="#f88" stroke-width="1.5"/> <text x="60" y="125" text-anchor="middle" fill="#f88">−2^(n−1)</text> <!-- Max marker --> <line x1="480" y1="90" x2="480" y2="110" stroke="#7af" stroke-width="1.5"/> <text x="480" y="125" text-anchor="middle" fill="#7af">2^(n−1)−1</text> <!-- Valid range bracket --> <line x1="60" y1="75" x2="480" y2="75" stroke="#8f8" stroke-width="1.2"/> <line x1="60" y1="70" x2="60" y2="80" stroke="#8f8" stroke-width="1.2"/> <line x1="480" y1="70" x2="480" y2="80" stroke="#8f8" stroke-width="1.2"/> <text x="270" y="68" text-anchor="middle" fill="#8f8">valid representable range</text> <!-- Overflow arrows --> <line x1="480" y1="100" x2="520" y2="100" stroke="#f44" stroke-width="1.5" marker-end="url(#arr)"/> <text x="510" y="90" fill="#f44" font-size="11">+overflow</text> <line x1="60" y1="100" x2="20" y2="100" stroke="#f44" stroke-width="1.5"/> <text x="10" y="90" fill="#f44" font-size="11" text-anchor="middle">−overflow</text> </svg>

---

### Overflow in Multiplication

An _n_-bit × _n_-bit multiplication requires up to **2n bits** for the full result. If the result is truncated to _n_ bits, the high-order bits are lost. Hardware must either:

- Use a double-width accumulator (e.g., HI/LO registers in MIPS)
- Raise an overflow exception
- Saturate the result (common in DSP and SIMD contexts)

---

### Overflow Detection Summary

|Operation|Type|Detection Method|
|---|---|---|
|Unsigned add|Overflow|Cₒᵤₜ = 1|
|Signed add|Positive overflow|Both inputs positive, result negative|
|Signed add|Negative overflow|Both inputs negative, result positive|
|Signed add|Hardware|Cₙ₋₁ ⊕ Cₙ = 1|
|Unsigned sub|Borrow|Borrow-out = 1 (result < 0)|
|Signed sub|Overflow|Same rule applied to A + (−B)|
|Multiplication|Any|High-order _n_ bits of 2n-bit result ≠ sign extension of low half|

---

### Overflow Handling in Hardware and ISAs

Different architectures handle overflow differently:

|Architecture|Behavior|
|---|---|
|x86 (add)|Sets OF (overflow flag) and CF (carry flag); no exception|
|MIPS (add)|Raises arithmetic overflow exception; `addu` silently wraps|
|ARM (ADDS)|Sets V flag (overflow) and C flag (carry); no automatic exception|
|RISC-V|No overflow exception; programmer checks flags explicitly|
|IEEE 754 FP|Sets overflow flag; returns ±∞|

The separation between **trapping** (add, MIPS) and **non-trapping** (addu, MIPS) variants is an explicit ISA design decision reflecting the trade-off between safety and performance.

---

### Saturation Arithmetic

In saturation arithmetic, overflow clamps the result to the maximum (or minimum) representable value rather than wrapping. This is used extensively in signal processing to prevent audio/video clipping artifacts.

```
n = 8, unsigned, range 0–255:

  200 + 100 = 300 → wraps to 44   (standard)
  200 + 100 = 300 → clamps to 255 (saturating)
```

SIMD instruction sets (SSE, NEON) provide dedicated saturating arithmetic instructions (e.g., `paddsb`, `vqadd`).

---

### Overflow in Floating-Point

IEEE 754 floating-point overflow occurs when the rounded result exceeds the largest finite representable value:

- Single precision: ≈ ±3.4 × 10³⁸
- Double precision: ≈ ±1.8 × 10³⁰⁸

The result is set to **±∞** (infinity), not a random bit pattern. This is a deliberate design property of IEEE 754 that enables continued computation through overflow conditions. The overflow flag in the floating-point status register is also set.

**Underflow** (distinct from overflow) occurs when the result is too small in magnitude to be represented as a normalized number — the result is either flushed to zero or represented as a subnormal (denormalized) number.

---

**Key Points**

- Binary addition and subtraction share the same hardware in two's complement systems — subtraction is addition of the negated operand.
- Unsigned overflow is detected by carry-out from the MSB; signed overflow requires comparing carry-into and carry-out-of the MSB (Cₙ₋₁ ⊕ Cₙ).
- Adding two operands of opposite sign in two's complement cannot overflow.
- Multiplication of two _n_-bit values requires 2_n_ bits; truncation is a form of overflow.
- ISAs differ in whether overflow causes a trap or merely sets a flag — this is a deliberate design choice with performance and safety implications.
- Saturation arithmetic and IEEE 754 infinity are two domain-specific overflow resolution strategies that prevent undefined behavior at the cost of precision.

**Conclusion** Binary arithmetic is structurally identical for unsigned and two's complement signed values at the hardware level, with overflow detection as the primary distinguishing concern. Correct overflow handling — whether through exception, flag-setting, saturation, or infinity — is a critical property of both hardware and the ISAs built atop it. Designs that neglect overflow detection introduce silent data corruption, a class of error that is difficult to diagnose and has caused documented failures in safety-critical systems.

**Next Steps**

- Fixed-point and floating-point representation (IEEE 754) — overflow in the context of exponent and mantissa fields
- ALU design — hardware realization of the detection logic covered here
- Error detection and correction — parity and Hamming codes as a complementary reliability concern

---

