## Integer Representation


Integer representation defines how whole numbers are encoded as fixed-width binary strings in hardware. The choice of representation determines the range of expressible values, the behavior of arithmetic operations, and how overflow is detected and handled.

---

### Unsigned Integers

An unsigned integer treats all $n$ bits as magnitude. There is no sign bit.

**Encoding rule:**

$$ V = \sum_{i=0}^{n-1} b_i \cdot 2^i $$

where $b_i$ is the $i$-th bit (0 = LSB, $n-1$ = MSB).

**Range:** $0$ to $2^n - 1$

For $n = 8$: range is $0$ to $255$.

|Bit pattern|Value|
|---|---|
|`0000 0000`|0|
|`0000 0001`|1|
|`0111 1111`|127|
|`1000 0000`|128|
|`1111 1111`|255|

Unsigned arithmetic wraps modulo $2^n$. There is no concept of negative values — the MSB contributes $2^{n-1}$, not $-2^{n-1}$.

---

### Signed Magnitude

The oldest and most intuitive method. The MSB encodes the sign ($0$ = positive, $1$ = negative); the remaining $n-1$ bits encode the magnitude.

**Range:** $-(2^{n-1} - 1)$ to $+(2^{n-1} - 1)$

For $n = 8$: $-127$ to $+127$.

**Problems:**

- Two representations of zero: `0000 0000` (+0) and `1000 0000` (−0).
- Addition requires inspecting the sign bit and choosing between addition or subtraction, complicating ALU design.
- Not used in modern general-purpose hardware for integers.

---

### One's Complement

Negate a value by flipping all bits.

$$ -V = \overline{V} \pmod{2^n - 1} $$

**Range:** $-(2^{n-1} - 1)$ to $+(2^{n-1} - 1)$

For $n = 8$: $-127$ to $+127$.

|Value|Bit pattern|
|---|---|
|+5|`0000 0101`|
|−5|`1111 1010`|
|+0|`0000 0000`|
|−0|`1111 1111`|

**Problems:**

- Still has two representations of zero.
- Addition requires an _end-around carry_: any carry out of the MSB must be added back to the LSB.
- Not used in modern integer hardware (historically used in some early machines and still appears in IPv4/TCP checksums).

---

### Two's Complement

The standard representation for signed integers in virtually all modern architectures. Negation is performed by inverting all bits and adding 1.

$$ -V = \overline{V} + 1 \pmod{2^n} $$

**Value formula:**

$$ V = -b_{n-1} \cdot 2^{n-1} + \sum_{i=0}^{n-2} b_i \cdot 2^i $$

The MSB carries weight $-2^{n-1}$ instead of $+2^{n-1}$.

**Range:** $-2^{n-1}$ to $+2^{n-1} - 1$

For $n = 8$: $-128$ to $+127$.

---

#### Two's Complement Table (8-bit)

|Bit pattern|Unsigned value|Signed (two's complement) value|
|---|---|---|
|`0000 0000`|0|0|
|`0000 0001`|1|+1|
|`0111 1111`|127|+127|
|`1000 0000`|128|−128|
|`1000 0001`|129|−127|
|`1111 1110`|254|−2|
|`1111 1111`|255|−1|

---

#### Why Two's Complement Is Preferred

1. **Unique zero.** Only one bit pattern represents zero: `000...0`.
2. **Uniform addition.** The same binary adder circuit handles both signed and unsigned addition without modification. No end-around carry is needed.
3. **Subtraction reduces to addition.** $A - B = A + (-B) = A + \overline{B} + 1$, which is implementable with an adder and an inverter.
4. **Hardware simplicity.** No sign inspection logic is required for addition or subtraction.

---

#### Negation Examples (8-bit)

**Negate +5:**

```
+5  = 0000 0101
      1111 1010   (invert)
    + 0000 0001   (add 1)
    -----------
-5  = 1111 1011
```

**Negate −128 (special case):**

```
-128 = 1000 0000
       0111 1111   (invert)
     + 0000 0001   (add 1)
     -----------
       1000 0000   (wraps back to -128)
```

$-128$ has no positive counterpart in 8-bit two's complement. This is the _asymmetry_ of the range.

---

### Overflow

Overflow occurs when the result of an arithmetic operation cannot be represented in the available $n$ bits.

#### Unsigned Overflow

Occurs when the true result $\geq 2^n$ (carry out of the MSB) or $< 0$ (borrow). The result wraps modulo $2^n$.

#### Signed (Two's Complement) Overflow

Overflow occurs if and only if the two operands have the **same sign** and the result has the **opposite sign**.

**Detection condition:**

$$ \text{Overflow} = C_{n-1} \oplus C_{n-2} $$

where $C_{n-1}$ is the carry into the sign bit position and $C_{n-2}$ is the carry out of the sign bit position (i.e., carry out of the MSB). Overflow occurs when these two carries differ.

**Example — 8-bit signed overflow:**

```
  0111 1111  (+127)
+ 0000 0001  (+1)
-----------
  1000 0000  (reads as -128 — incorrect)
```

Both operands are positive; result appears negative. Overflow has occurred.

```
  1000 0000  (-128)
+ 1111 1111  (-1)
-----------
  0111 1111  (reads as +127 — incorrect)
```

Both operands are negative; result appears positive. Overflow has occurred.

---

### Sign Extension

When promoting a value from a narrower to a wider type (e.g., 8-bit to 16-bit), the value must be preserved.

- **Unsigned:** zero-extend — fill upper bits with `0`.
- **Signed (two's complement):** sign-extend — replicate the MSB into all upper bits.

**Example — sign-extend 8-bit −5 (`1111 1011`) to 16-bit:**

```
1111 1011  (8-bit, -5)
→ 1111 1111 1111 1011  (16-bit, still -5)
```

**Example — sign-extend 8-bit +5 (`0000 0101`) to 16-bit:**

```
0000 0101  (8-bit, +5)
→ 0000 0000 0000 0101  (16-bit, still +5)
```

Replicating the MSB preserves the value because the two's complement formula extends naturally: each new bit contributes $-2^k$ or $+2^k$ in a way that cancels and preserves the original value.

---

### Comparison of Representations

|Property|Signed Magnitude|One's Complement|Two's Complement|
|---|---|---|---|
|Range ($n$ bits)|$-(2^{n-1}-1)$ to $+(2^{n-1}-1)$|$-(2^{n-1}-1)$ to $+(2^{n-1}-1)$|$-2^{n-1}$ to $+(2^{n-1}-1)$|
|Unique zero|No|No|Yes|
|Addition circuit|Complex|Requires end-around carry|Simple (standard adder)|
|Negation|Flip MSB|Invert all bits|Invert all bits + 1|
|Hardware use|Rare (FP sign bit only)|Rare (checksums)|Universal|

---

### Diagram — Number Line Mapping (4-bit)

```svg
<svg viewBox="0 0 700 160" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">

  <!-- Axis -->
  <line x1="40" y1="80" x2="660" y2="80" stroke="#aaa" stroke-width="1.5"/>

  <!-- Tick marks and unsigned labels -->
  <!-- 16 values: 0000 to 1111, spaced 40px apart starting at x=40 -->

  <!-- 0000 -->
  <line x1="40" y1="74" x2="40" y2="86" stroke="#aaa" stroke-width="1"/>
  <text x="40" y="100" text-anchor="middle" fill="#888" font-size="11">0000</text>
  <text x="40" y="114" text-anchor="middle" fill="#4fc3f7" font-size="11">0</text>
  <text x="40" y="128" text-anchor="middle" fill="#a5d6a7" font-size="11">0</text>

  <!-- 0001 -->
  <line x1="80" y1="74" x2="80" y2="86" stroke="#aaa" stroke-width="1"/>
  <text x="80" y="100" text-anchor="middle" fill="#888" font-size="11">0001</text>
  <text x="80" y="114" text-anchor="middle" fill="#4fc3f7" font-size="11">1</text>
  <text x="80" y="128" text-anchor="middle" fill="#a5d6a7" font-size="11">1</text>

  <!-- 0010 -->
  <line x1="120" y1="74" x2="120" y2="86" stroke="#aaa" stroke-width="1"/>
  <text x="120" y="100" text-anchor="middle" fill="#888" font-size="11">0010</text>
  <text x="120" y="114" text-anchor="middle" fill="#4fc3f7" font-size="11">2</text>
  <text x="120" y="128" text-anchor="middle" fill="#a5d6a7" font-size="11">2</text>

  <!-- 0011 -->
  <line x1="160" y1="74" x2="160" y2="86" stroke="#aaa" stroke-width="1"/>
  <text x="160" y="100" text-anchor="middle" fill="#888" font-size="11">0011</text>
  <text x="160" y="114" text-anchor="middle" fill="#4fc3f7" font-size="11">3</text>
  <text x="160" y="128" text-anchor="middle" fill="#a5d6a7" font-size="11">3</text>

  <!-- 0100 -->
  <line x1="200" y1="74" x2="200" y2="86" stroke="#aaa" stroke-width="1"/>
  <text x="200" y="100" text-anchor="middle" fill="#888" font-size="11">0100</text>
  <text x="200" y="114" text-anchor="middle" fill="#4fc3f7" font-size="11">4</text>
  <text x="200" y="128" text-anchor="middle" fill="#a5d6a7" font-size="11">4</text>

  <!-- 0101 -->
  <line x1="240" y1="74" x2="240" y2="86" stroke="#aaa" stroke-width="1"/>
  <text x="240" y="100" text-anchor="middle" fill="#888" font-size="11">0101</text>
  <text x="240" y="114" text-anchor="middle" fill="#4fc3f7" font-size="11">5</text>
  <text x="240" y="128" text-anchor="middle" fill="#a5d6a7" font-size="11">5</text>

  <!-- 0110 -->
  <line x1="280" y1="74" x2="280" y2="86" stroke="#aaa" stroke-width="1"/>
  <text x="280" y="100" text-anchor="middle" fill="#888" font-size="11">0110</text>
  <text x="280" y="114" text-anchor="middle" fill="#4fc3f7" font-size="11">6</text>
  <text x="280" y="128" text-anchor="middle" fill="#a5d6a7" font-size="11">6</text>

  <!-- 0111 -->
  <line x1="320" y1="74" x2="320" y2="86" stroke="#aaa" stroke-width="1"/>
  <text x="320" y="100" text-anchor="middle" fill="#888" font-size="11">0111</text>
  <text x="320" y="114" text-anchor="middle" fill="#4fc3f7" font-size="11">7</text>
  <text x="320" y="128" text-anchor="middle" fill="#a5d6a7" font-size="11">7</text>

  <!-- Divider: MSB flips here -->
  <line x1="360" y1="55" x2="360" y2="86" stroke="#ef9a9a" stroke-width="1.5" stroke-dasharray="4,3"/>
  <text x="360" y="50" text-anchor="middle" fill="#ef9a9a" font-size="11">MSB=1</text>

  <!-- 1000 -->
  <line x1="360" y1="74" x2="360" y2="86" stroke="#aaa" stroke-width="1"/>
  <text x="360" y="100" text-anchor="middle" fill="#888" font-size="11">1000</text>
  <text x="360" y="114" text-anchor="middle" fill="#4fc3f7" font-size="11">8</text>
  <text x="360" y="128" text-anchor="middle" fill="#ef9a9a" font-size="11">−8</text>

  <!-- 1001 -->
  <line x1="400" y1="74" x2="400" y2="86" stroke="#aaa" stroke-width="1"/>
  <text x="400" y="100" text-anchor="middle" fill="#888" font-size="11">1001</text>
  <text x="400" y="114" text-anchor="middle" fill="#4fc3f7" font-size="11">9</text>
  <text x="400" y="128" text-anchor="middle" fill="#ef9a9a" font-size="11">−7</text>

  <!-- 1010 -->
  <line x1="440" y1="74" x2="440" y2="86" stroke="#aaa" stroke-width="1"/>
  <text x="440" y="100" text-anchor="middle" fill="#888" font-size="11">1010</text>
  <text x="440" y="114" text-anchor="middle" fill="#4fc3f7" font-size="11">10</text>
  <text x="440" y="128" text-anchor="middle" fill="#ef9a9a" font-size="11">−6</text>

  <!-- 1011 -->
  <line x1="480" y1="74" x2="480" y2="86" stroke="#aaa" stroke-width="1"/>
  <text x="480" y="100" text-anchor="middle" fill="#888" font-size="11">1011</text>
  <text x="480" y="114" text-anchor="middle" fill="#4fc3f7" font-size="11">11</text>
  <text x="480" y="128" text-anchor="middle" fill="#ef9a9a" font-size="11">−5</text>

  <!-- 1100 -->
  <line x1="520" y1="74" x2="520" y2="86" stroke="#aaa" stroke-width="1"/>
  <text x="520" y="100" text-anchor="middle" fill="#888" font-size="11">1100</text>
  <text x="520" y="114" text-anchor="middle" fill="#4fc3f7" font-size="11">12</text>
  <text x="520" y="128" text-anchor="middle" fill="#ef9a9a" font-size="11">−4</text>

  <!-- 1101 -->
  <line x1="560" y1="74" x2="560" y2="86" stroke="#aaa" stroke-width="1"/>
  <text x="560" y="100" text-anchor="middle" fill="#888" font-size="11">1101</text>
  <text x="560" y="114" text-anchor="middle" fill="#4fc3f7" font-size="11">13</text>
  <text x="560" y="128" text-anchor="middle" fill="#ef9a9a" font-size="11">−3</text>

  <!-- 1110 -->
  <line x1="600" y1="74" x2="600" y2="86" stroke="#aaa" stroke-width="1"/>
  <text x="600" y="100" text-anchor="middle" fill="#888" font-size="11">1110</text>
  <text x="600" y="114" text-anchor="middle" fill="#4fc3f7" font-size="11">14</text>
  <text x="600" y="128" text-anchor="middle" fill="#ef9a9a" font-size="11">−2</text>

  <!-- 1111 -->
  <line x1="640" y1="74" x2="640" y2="86" stroke="#aaa" stroke-width="1"/>
  <text x="640" y="100" text-anchor="middle" fill="#888" font-size="11">1111</text>
  <text x="640" y="114" text-anchor="middle" fill="#4fc3f7" font-size="11">15</text>
  <text x="640" y="128" text-anchor="middle" fill="#ef9a9a" font-size="11">−1</text>

  <!-- Legend -->
  <text x="40" y="20" fill="#888" font-size="11">Bit pattern</text>
  <text x="40" y="34" fill="#4fc3f7" font-size="11">Unsigned value</text>
  <text x="40" y="48" fill="#a5d6a7" font-size="11">Signed value (MSB=0 region)</text>
  <text x="370" y="34" fill="#ef9a9a" font-size="11">Signed value (MSB=1 region)</text>

</svg>
```

The bit patterns are identical across unsigned and two's complement. Interpretation diverges only at the MSB boundary.

---

### Key Arithmetic Properties of Two's Complement

**Subtraction via addition:**

$$A - B = A + \overline{B} + 1$$

This is directly implemented in an ALU: invert $B$, set carry-in to 1, and use the same adder path as addition.

**Multiplication sign:** The sign of a product follows from the MSBs of both operands and the standard two's complement formula. Hardware multipliers (e.g., Booth's algorithm) exploit the encoding structure for efficiency.

**Right shift behavior:**

- Unsigned right shift: logical shift — fills with `0` (divides by $2^k$, truncating toward zero).
- Signed right shift: arithmetic shift — fills with the sign bit (divides by $2^k$, truncating toward negative infinity). Most architectures provide separate shift instructions (`SHR` vs `SAR` on x86; `LSR` vs `ASR` on ARM).

---

**Conclusion**

Two's complement is the dominant encoding for signed integers because it admits a single, consistent adder circuit for both addition and subtraction, eliminates the dual-zero problem of earlier schemes, and integrates naturally with the modular arithmetic of fixed-width binary registers. The key properties to internalize are the asymmetric range, the negation procedure, overflow detection via carry disagreement, and sign extension rules — each of which has direct consequences in ALU design, compiler code generation, and low-level programming.

**Next Steps**

- Fixed-point representation — how the binary point is positioned within a two's complement word, and the trade-offs between range and precision.
- Floating-point representation (IEEE 754) — sign-magnitude encoding for the significand combined with a biased exponent, and special values (NaN, infinity, denormals).
- Binary arithmetic and overflow — carry-lookahead adders, ripple-carry chains, and hardware overflow flags (CF, OF on x86).

---

