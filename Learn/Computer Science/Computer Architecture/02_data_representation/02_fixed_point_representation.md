## Fixed-Point Representation


Fixed-point representation is a method of encoding real numbers in binary by implicitly placing a radix point at a fixed position within a fixed-width binary word. Unlike floating-point, the position of the radix point does not move — it is a compile-time or design-time convention, not stored in the number itself.

---

### Format Notation

The most common notation is **Q format**, written as **Q_m_._n_** (or sometimes **Q_n_**), where:

- **m** = number of integer bits (sometimes excluding the sign bit)
- **n** = number of fractional bits
- Total word width = m + n (+ 1 if signed)

The radix point is implicitly located between bit position _n_ and _n+1_ from the LSB.

```
  Signed Q7.8 (16-bit total: 1 sign + 7 integer + 8 fractional)

  Bit index:  15  14  13  12  11  10   9   8 | 7   6   5   4   3   2   1   0
              [S]  [  integer part          ] | [      fractional part       ]
                                              ^
                                         implicit radix point
```

---

### Value Interpretation

For a **signed Q_m_._n_** number stored as a two's complement integer _k_, the real value is:

$$V = k \times 2^{-n}$$

For **unsigned Q_m_._n_**, the same formula applies with _k_ treated as unsigned.

**Key Points**

- The binary pattern is just an integer; fixed-point is purely an _interpretation_.
- The hardware performing addition and subtraction is identical to integer hardware — no special unit is needed.
- The programmer or compiler must track radix point alignment manually.

---

### Range and Resolution

For a **signed Q_m_._n_** value in a word of width _W = m + n + 1_:

|Property|Formula|
|---|---|
|Maximum value|$+(2^m - 2^{-n})$|
|Minimum value|$-2^m$|
|Resolution (LSB weight)|$2^{-n}$|
|Total representable values|$2^W$|

For **unsigned Q_m_._n_** (_W = m + n_):

|Property|Formula|
|---|---|
|Maximum value|$2^m - 2^{-n}$|
|Minimum value|$0$|
|Resolution|$2^{-n}$|

**Example**

Signed Q3.4 (8-bit: 1 sign + 3 integer + 4 fractional):

- Resolution = $2^{-4}$ = 0.0625
- Max = $+(2^3 - 2^{-4})$ = +7.9375
- Min = $-2^3$ = −8.0

---

### Encoding Examples

**Q3.4, signed (8-bit two's complement)**

|Binary|Integer interpretation|Fixed-point value|
|---|---|---|
|`0000 0000`|0|0.0000|
|`0001 0000`|16|1.0000|
|`0000 1000`|8|0.5000|
|`0000 0001`|1|0.0625|
|`0111 1111`|127|+7.9375|
|`1000 0000`|−128|−8.0000|
|`1111 1111`|−1|−0.0625|

**Converting a real value to Q3.4:**

To encode $V = 3.75$: $$k = V \times 2^n = 3.75 \times 16 = 60 = \texttt{0011\ 1100}_2$$

To decode `0010 1100` (= 44 decimal): $$V = 44 \times 2^{-4} = 44 / 16 = 2.75$$

---

### Arithmetic Operations

#### Addition and Subtraction

Operands must share the same Q format. If they do, integer addition hardware is used directly — no adjustment needed.

```
  Q3.4 + Q3.4:

    0001 1000   (1.5)
  + 0000 1100   (0.75)
  -----------
    0010 0100   (2.25)  ← radix point stays at position 4
```

If operands have different Q formats, one must be **shifted** to align radix points before the operation.

#### Multiplication

Multiplying Q_m₁_._n₁_ × Q_m₂_._n₂_ produces a result in Q(_m₁_+_m₂_).(_n₁_+_n₂_) format. The word width doubles. A right-shift by _n₁_ or _n₂_ (depending on convention) is required to return to the original format, discarding fractional LSBs.

```
  Q3.4 × Q3.4 → Q6.8 (16-bit intermediate result)

  To return to Q3.4: right-shift the 16-bit result by 4, take lower 8 bits.
  This discards 4 fractional bits → introduces truncation error.
```

**Key Points**

- Multiplication requires a wider accumulator to avoid immediate overflow.
- DSP hardware (e.g., MACs in signal processors) typically provides a double-wide accumulator for this reason.
- Right-shifting after multiplication is equivalent to re-quantization.

#### Division

Division in fixed-point is performed by left-shifting the dividend by _n_ bits before integer division, restoring the implied radix point in the quotient. Division is comparatively rare in fixed-point code because it is costly and can be replaced by multiplication with a reciprocal.

---

### Overflow and Saturation

Fixed-point arithmetic overflows when a result exceeds the representable range. Two common handling strategies:

```
              ┌─────────────────────────────────────────────────┐
              │             Overflow Handling                   │
              ├─────────────────┬───────────────────────────────┤
              │   Wraparound    │        Saturation             │
              ├─────────────────┼───────────────────────────────┤
              │ Default integer │ Clamp to MAX or MIN on        │
              │ two's complement│ overflow                      │
              │ behavior        │                               │
              │                 │ Required in audio, control,   │
              │ Can produce     │ image processing              │
              │ sign flips      │                               │
              └─────────────────┴───────────────────────────────┘
```

Saturation arithmetic is available as a hardware instruction on many DSP cores and ARM (using the `QADD`, `QSUB` family of instructions).

---

### Quantization Error

When converting a real value to fixed-point, the error introduced is called **quantization error**. For truncation (round toward −∞):

$$e = V_{\text{real}} - V_{\text{fixed}} \in [-2^{-n},\ 0)$$

For rounding (round to nearest):

$$e \in \left[-\frac{2^{-n}}{2},\ \frac{2^{-n}}{2}\right]$$

Increasing _n_ (more fractional bits) reduces quantization error but reduces the integer range for a fixed word width.

---

### Radix Point Alignment Diagram

```svg
<svg viewBox="0 0 640 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">

  <!-- Title -->
  <text x="320" y="22" text-anchor="middle" font-size="14" font-weight="bold" fill="#e2e8f0">Q3.4 Addition — Radix Point Alignment</text>

  <!-- Operand A row -->
  <text x="30" y="60" fill="#94a3b8">A (1.5):</text>
  <!-- Bits -->
  <rect x="140" y="44" width="30" height="24" fill="#1e293b" stroke="#475569"/>
  <text x="155" y="61" text-anchor="middle" fill="#f8fafc">0</text>
  <rect x="170" y="44" width="30" height="24" fill="#1e293b" stroke="#475569"/>
  <text x="185" y="61" text-anchor="middle" fill="#f8fafc">0</text>
  <rect x="200" y="44" width="30" height="24" fill="#1e293b" stroke="#475569"/>
  <text x="215" y="61" text-anchor="middle" fill="#f8fafc">0</text>
  <rect x="230" y="44" width="30" height="24" fill="#1e293b" stroke="#475569"/>
  <text x="245" y="61" text-anchor="middle" fill="#f8fafc">1</text>

  <!-- radix marker A -->
  <line x1="260" y1="40" x2="260" y2="72" stroke="#f59e0b" stroke-width="2" stroke-dasharray="4,2"/>

  <rect x="260" y="44" width="30" height="24" fill="#0f172a" stroke="#475569"/>
  <text x="275" y="61" text-anchor="middle" fill="#86efac">1</text>
  <rect x="290" y="44" width="30" height="24" fill="#0f172a" stroke="#475569"/>
  <text x="305" y="61" text-anchor="middle" fill="#86efac">0</text>
  <rect x="320" y="44" width="30" height="24" fill="#0f172a" stroke="#475569"/>
  <text x="335" y="61" text-anchor="middle" fill="#86efac">0</text>
  <rect x="350" y="44" width="30" height="24" fill="#0f172a" stroke="#475569"/>
  <text x="365" y="61" text-anchor="middle" fill="#86efac">0</text>

  <!-- Operand B row -->
  <text x="30" y="110" fill="#94a3b8">B (0.75):</text>
  <rect x="140" y="94" width="30" height="24" fill="#1e293b" stroke="#475569"/>
  <text x="155" y="111" text-anchor="middle" fill="#f8fafc">0</text>
  <rect x="170" y="94" width="30" height="24" fill="#1e293b" stroke="#475569"/>
  <text x="185" y="111" text-anchor="middle" fill="#f8fafc">0</text>
  <rect x="200" y="94" width="30" height="24" fill="#1e293b" stroke="#475569"/>
  <text x="215" y="111" text-anchor="middle" fill="#f8fafc">0</text>
  <rect x="230" y="94" width="30" height="24" fill="#1e293b" stroke="#475569"/>
  <text x="245" y="111" text-anchor="middle" fill="#f8fafc">0</text>

  <!-- radix marker B -->
  <line x1="260" y1="90" x2="260" y2="122" stroke="#f59e0b" stroke-width="2" stroke-dasharray="4,2"/>

  <rect x="260" y="94" width="30" height="24" fill="#0f172a" stroke="#475569"/>
  <text x="275" y="111" text-anchor="middle" fill="#86efac">1</text>
  <rect x="290" y="94" width="30" height="24" fill="#0f172a" stroke="#475569"/>
  <text x="305" y="111" text-anchor="middle" fill="#86efac">1</text>
  <rect x="320" y="94" width="30" height="24" fill="#0f172a" stroke="#475569"/>
  <text x="335" y="111" text-anchor="middle" fill="#86efac">0</text>
  <rect x="350" y="94" width="30" height="24" fill="#0f172a" stroke="#475569"/>
  <text x="365" y="111" text-anchor="middle" fill="#86efac">0</text>

  <!-- Divider line -->
  <line x1="140" y1="128" x2="385" y2="128" stroke="#64748b" stroke-width="1.5"/>
  <text x="120" y="151" fill="#94a3b8">= (2.25):</text>

  <!-- Result row -->
  <rect x="140" y="135" width="30" height="24" fill="#1e293b" stroke="#475569"/>
  <text x="155" y="152" text-anchor="middle" fill="#f8fafc">0</text>
  <rect x="170" y="135" width="30" height="24" fill="#1e293b" stroke="#475569"/>
  <text x="185" y="152" text-anchor="middle" fill="#f8fafc">0</text>
  <rect x="200" y="135" width="30" height="24" fill="#1e293b" stroke="#475569"/>
  <text x="215" y="152" text-anchor="middle" fill="#f8fafc">0</text>
  <rect x="230" y="135" width="30" height="24" fill="#1e293b" stroke="#475569"/>
  <text x="245" y="152" text-anchor="middle" fill="#f8fafc">0</text>

  <!-- radix marker result -->
  <line x1="260" y1="131" x2="260" y2="163" stroke="#f59e0b" stroke-width="2" stroke-dasharray="4,2"/>

  <rect x="260" y="135" width="30" height="24" fill="#0f172a" stroke="#475569"/>
  <text x="275" y="152" text-anchor="middle" fill="#86efac">1</text>
  <rect x="290" y="135" width="30" height="24" fill="#0f172a" stroke="#475569"/>
  <text x="305" y="152" text-anchor="middle" fill="#86efac">0</text>
  <rect x="320" y="135" width="30" height="24" fill="#0f172a" stroke="#475569"/>
  <text x="335" y="152" text-anchor="middle" fill="#86efac">0</text>
  <rect x="350" y="135" width="30" height="24" fill="#0f172a" stroke="#475569"/>
  <text x="365" y="152" text-anchor="middle" fill="#86efac">0</text>

  <!-- missing bit carry -->
  <rect x="110" y="135" width="30" height="24" fill="#1e293b" stroke="#f59e0b" stroke-width="1.5"/>
  <text x="125" y="152" text-anchor="middle" fill="#fbbf24">1</text>

  <!-- Radix label -->
  <text x="258" y="185" text-anchor="middle" fill="#f59e0b" font-size="11">radix point</text>

  <!-- Legend -->
  <rect x="430" y="55" width="14" height="14" fill="#1e293b" stroke="#475569"/>
  <text x="450" y="66" fill="#94a3b8" font-size="11">integer bits</text>
  <rect x="430" y="78" width="14" height="14" fill="#0f172a" stroke="#475569"/>
  <text x="450" y="89" fill="#94a3b8" font-size="11">fractional bits</text>
  <rect x="430" y="101" width="14" height="14" fill="#1e293b" stroke="#f59e0b" stroke-width="1.5"/>
  <text x="450" y="112" fill="#94a3b8" font-size="11">carry out</text>
</svg>
```

---

### Fixed-Point vs. Floating-Point

|Property|Fixed-Point|Floating-Point (IEEE 754)|
|---|---|---|
|Radix point position|Static, implicit|Dynamic, stored in exponent|
|Hardware cost|Low — integer ALU|High — dedicated FPU|
|Range|Narrow, fixed|Wide, dynamic|
|Precision|Uniform across range|Non-uniform (higher near zero)|
|Overflow handling|Programmer responsibility|Inf / NaN signals|
|Determinism|Fully deterministic|Platform-dependent rounding modes|
|Typical use|DSPs, embedded, control|General scientific, graphics|

---

### Practical Use Cases

**Digital Signal Processing (DSP):** Audio codecs, filters, and transforms are implemented in fixed-point on dedicated DSP chips (e.g., TI C6000 series, Qualcomm Hexagon) to achieve low power and predictable latency.

**Embedded and Real-Time Control:** Microcontrollers without hardware FPUs (many ARM Cortex-M0/M0+ cores) use fixed-point arithmetic in motor control, PID loops, and sensor fusion.

**Neural Network Inference:** Quantized models use Q8.0 or Q4.0 formats to reduce model size and accelerate inference on integer-only hardware (e.g., Google Edge TPU, ARM Ethos NPUs). This is an active area of hardware-software co-design.

**Finance:** Fixed-point (not floating-point) is standard for currency arithmetic to avoid floating-point rounding anomalies.

---

### Compiler and Language Support

- **C/C++:** No native fixed-point type in standard C (before C23 Annex). Programmers use `int16_t`, `int32_t` with manual shift discipline, or libraries like `libfixmath`.
- **C23 (`_Fract`, `_Accum`):** The Embedded C extension (ISO/IEC TR 18037) defines `_Fract` and `_Accum` types with compiler-managed radix tracking.
- **MATLAB/Simulink:** First-class `fi` (fixed-point) objects with automatic overflow and rounding mode configuration, used extensively in DSP algorithm development before HDL export.
- **VHDL/Verilog:** Hardware description languages require explicit management of bit widths; fixed-point is represented as `std_logic_vector` with documented conventions.

---

**Conclusion**

Fixed-point representation trades dynamic range for simplicity, determinism, and low hardware cost. The radix point is a compile-time convention that imposes strict alignment discipline on all arithmetic. Addition is free in hardware cost; multiplication requires width management and rescaling. Overflow and quantization error are the two primary sources of numerical failure and must be analyzed as part of any fixed-point system design.

**Next Steps**

Proceed to **Floating-Point Representation (IEEE 754)** to examine how a stored exponent field solves the range limitations of fixed-point at the cost of hardware complexity and non-uniform precision.

---

