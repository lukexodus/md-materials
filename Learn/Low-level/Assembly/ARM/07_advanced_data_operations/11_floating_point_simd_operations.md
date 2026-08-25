## Floating-Point SIMD Operations


NEON supports single-precision (32-bit) floating-point SIMD operations. ARMv8-A adds double-precision support.

### Basic Floating-Point Operations

**VADD.F32/VSUB.F32 - Vector Floating-Point Add/Subtract**

**Example:**

```assembly
@ Add four single-precision floats in parallel
VLD1.32 {Q0}, [r0]          @ Load 4 floats
VLD1.32 {Q1}, [r1]          @ Load 4 floats
VADD.F32 Q2, Q0, Q1         @ Q2 = Q0 + Q1 (four additions)

@ Subtract
VSUB.F32 Q3, Q0, Q1         @ Q3 = Q0 - Q1
```

**VMUL.F32/VDIV.F32 - Vector Floating-Point Multiply/Divide**

**Example:**

```assembly
@ Multiply four floats
VMUL.F32 Q0, Q1, Q2         @ Q0 = Q1 * Q2

@ Divide (available in ARMv7-A with VFPv4 and later)
VDIV.F32 S0, S1, S2         @ Scalar divide: S0 = S1 / S2
                            @ [Inference: Full vector divide may require
                            @ per-lane scalar operations depending on architecture]
```

**VMLA/VMLS - Vector Multiply-Accumulate/Subtract**

Fused multiply-accumulate operations improve precision and performance.

**Example:**

```assembly
@ Multiply-accumulate: Q0 = Q0 + (Q1 * Q2)
VMLA.F32 Q0, Q1, Q2         @ Four FMA operations

@ Multiply-subtract: Q0 = Q0 - (Q1 * Q2)
VMLS.F32 Q0, Q1, Q2         @ Four FMS operations
```

### Floating-Point Comparisons

**VCGE.F32/VCGT.F32 - Vector Floating-Point Compare**

Floating-point comparisons produce masks like integer comparisons.

**Example:**

```assembly
@ Compare greater than
VCGT.F32 Q0, Q1, Q2         @ Q0[i] = all 1s if Q1[i] > Q2[i]

@ Use for conditional selection
VCGE.F32 Q3, Q4, Q5         @ Q3 = mask where Q4 >= Q5
VBSL Q3, Q6, Q7             @ Select from Q6 or Q7 based on mask
```

**VCEQ.F32 - Vector Floating-Point Equal**

[Inference: Floating-point equality comparison should be used cautiously due to precision issues; consider tolerance-based comparisons for robust code].

**Example:**

```assembly
VCEQ.F32 Q0, Q1, Q2         @ Q0[i] = all 1s if Q1[i] == Q2[i]
```

### Floating-Point Math Functions

**VABS.F32/VNEG.F32 - Absolute Value/Negate**

**Example:**

```assembly
@ Absolute value of four floats
VABS.F32 Q0, Q1             @ Q0[i] = |Q1[i]|

@ Negate
VNEG.F32 Q0, Q1             @ Q0[i] = -Q1[i]
```

**VSQRT.F32 - Square Root**

**Example:**

```assembly
@ Square root (scalar in most implementations)
VSQRT.F32 S0, S1            @ S0 = sqrt(S1)

@ For vector, may require per-lane scalar operations
VSQRT.F32 S0, S4            @ sqrt lane 0
VSQRT.F32 S1, S5            @ sqrt lane 1
VSQRT.F32 S2, S6            @ sqrt lane 2
VSQRT.F32 S3, S7            @ sqrt lane 3
```

**VRECPE/VRSQRTE - Reciprocal/Reciprocal Square Root Estimate**

Fast approximations for reciprocal and reciprocal square root with Newton-Raphson refinement steps for full precision.

**Example:**

```assembly
@ Fast reciprocal estimate: Q0 ≈ 1/Q1
VRECPE.F32 Q0, Q1           @ Initial estimate (about 8-9 bits accuracy)

@ Newton-Raphson refinement: x_new = x * (2 - x * input)
VMUL.F32 Q2, Q0, Q1         @ Q2 = estimate * input
VRECPS.F32 Q2, Q2, #2.0     @ Q2 = 2 - (estimate * input)
VMUL.F32 Q0, Q0, Q2         @ Q0 = refined estimate

@ Reciprocal sqrt estimate: Q0 ≈ 1/sqrt(Q1)
VRSQRTE.F32 Q0, Q1          @ Initial estimate

@ Refinement
VMUL.F32 Q2, Q0, Q1         @ Q2 = estimate * input
VRSQRTS.F32 Q2, Q2, Q0      @ Refinement step
VMUL.F32 Q0, Q0, Q2         @ Refined estimate
```

**VMAX.F32/VMIN.F32 - Vector Floating-Point Max/Min**

**Example:**

```assembly
@ Maximum of corresponding elements
VMAX.F32 Q0, Q1, Q2         @ Q0[i] = max(Q1[i], Q2[i])

@ Minimum
VMIN.F32 Q0, Q1, Q2         @ Q0[i] = min(Q1[i], Q2[i])
```

### Floating-Point Conversions

**VCVT - Vector Convert**

Conversions between integer and floating-point, and between precisions.

**Example:**

```assembly
@ Convert signed 32-bit integer to float
VCVT.F32.S32 Q0, Q1         @ Q0 (float) = Q1 (signed int)

@ Convert unsigned integer to float
VCVT.F32.U32 Q0, Q1         @ Q0 (float) = Q1 (unsigned int)

@ Convert float to signed integer (round toward zero)
VCVT.S32.F32 Q0, Q1         @ Q0 (signed int) = Q1 (float)

@ Convert float to unsigned integer
VCVT.U32.F32 Q0, Q1         @ Q0 (unsigned int) = Q1 (float)

@ Fixed-point conversions with fractional bits
VCVT.F32.S32 Q0, Q1, #8     @ Convert with 8 fractional bits
                            @ float = int / 256
VCVT.S32.F32 Q0, Q1, #8     @ Convert to fixed-point
                            @ int = float * 256
```

### Rounding Modes

**VRINT - Vector Round Floating-Point**

Various rounding modes for floating-point to integer conversion.

**Example:**

```assembly
@ Round to nearest (ties to even)
VRINTN.F32 Q0, Q1           @ Q0 = round(Q1)

@ Round toward zero (truncate)
VRINTZ.F32 Q0, Q1           @ Q0 = trunc(Q1)

@ Round toward positive infinity (ceil)
VRINTP.F32 Q0, Q1           @ Q0 = ceil(Q1)

@ Round toward negative infinity (floor)
VRINTM.F32 Q0, Q1           @ Q0 = floor(Q1)

@ Round to nearest away from zero
VRINTA.F32 Q0, Q1           @ Q0 = round(Q1), ties away from zero
```

