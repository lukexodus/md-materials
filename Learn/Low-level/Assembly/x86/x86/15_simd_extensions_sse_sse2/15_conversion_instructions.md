## Conversion Instructions


Conversion instructions transform data between different types, enabling interoperability between integer and floating-point operations, as well as between different precisions.

### Integer to Floating-Point Conversions

#### SSE: Integer to Single-Precision

**CVTPI2PS** - Convert Packed Doubleword Integers to Packed Single-Precision

```nasm
cvtpi2ps xmm0, mm0        ; Convert 2 int32 (MMX) to 2 floats (low half of XMM0)
```

**CVTSI2SS** - Convert Doubleword Integer to Scalar Single-Precision

```nasm
cvtsi2ss xmm0, eax        ; Convert int32 to float (lowest element)
cvtsi2ss xmm0, [mem]      ; Convert int32 from memory
```

#### SSE2: Integer to Single/Double-Precision

**CVTDQ2PS** - Convert Packed Doubleword Integers to Packed Single-Precision

```nasm
cvtdq2ps xmm0, xmm1       ; Convert 4 int32 to 4 floats
```

**CVTDQ2PD** - Convert Packed Doubleword Integers to Packed Double-Precision

```nasm
cvtdq2pd xmm0, xmm1       ; Convert 2 low int32 to 2 doubles
```

**CVTSI2SD** - Convert Doubleword Integer to Scalar Double-Precision

```nasm
cvtsi2sd xmm0, eax        ; Convert int32 to double (lowest element)
```

**Example** of integer to float conversion:

```nasm
; XMM0 contains 4 signed integers: [100][-200][300][-400]
cvtdq2ps xmm0, xmm0
; XMM0 now contains 4 floats: [100.0][-200.0][300.0][-400.0]
```

### Floating-Point to Integer Conversions

Floating-point to integer conversions require handling of rounding modes and out-of-range values. SSE/SSE2 provides multiple conversion modes.

#### SSE: Single-Precision to Integer

**CVTPS2PI** - Convert Packed Single-Precision to Packed Doubleword Integers

```nasm
cvtps2pi mm0, xmm0        ; Convert 2 low floats to 2 int32 (MMX)
```

**CVTTPS2PI** - Convert with Truncation Packed Single-Precision to Packed Doubleword Integers

```nasm
cvttps2pi mm0, xmm0       ; Convert 2 low floats to 2 int32 (truncate toward zero)
```

**CVTSS2SI** - Convert Scalar Single-Precision to Doubleword Integer

```nasm
cvtss2si eax, xmm0        ; Convert lowest float to int32
```

**CVTTSS2SI** - Convert with Truncation Scalar Single-Precision to Doubleword Integer

```nasm
cvttss2si eax, xmm0       ; Convert lowest float to int32 (truncate)
```

#### SSE2: Single/Double-Precision to Integer

**CVTPS2DQ** - Convert Packed Single-Precision to Packed Doubleword Integers

```nasm
cvtps2dq xmm0, xmm1       ; Convert 4 floats to 4 int32
```

**CVTTPS2DQ** - Convert with Truncation Packed Single-Precision to Packed Doubleword Integers

```nasm
cvttps2dq xmm0, xmm1      ; Convert 4 floats to 4 int32 (truncate)
```

**CVTPD2DQ** - Convert Packed Double-Precision to Packed Doubleword Integers

```nasm
cvtpd2dq xmm0, xmm1       ; Convert 2 doubles to 2 int32 (low half)
```

**CVTTPD2DQ** - Convert with Truncation Packed Double-Precision to Packed Doubleword Integers

```nasm
cvttpd2dq xmm0, xmm1      ; Convert 2 doubles to 2 int32 (truncate)
```

**CVTSD2SI** - Convert Scalar Double-Precision to Doubleword Integer

```nasm
cvtsd2si eax, xmm0        ; Convert lowest double to int32
```

**CVTTSD2SI** - Convert with Truncation Scalar Double-Precision to Doubleword Integer

```nasm
cvttsd2si eax, xmm0       ; Convert lowest double to int32 (truncate)
```

#### Rounding Behavior

**Standard conversions** (CVT without TT prefix) use the rounding mode specified in the MXCSR register:

- **Round to nearest (even)**: Default mode
- **Round down (toward negative infinity)**
- **Round up (toward positive infinity)**
- **Round toward zero (truncate)**

**Truncating conversions** (CVTT prefix) always round toward zero regardless of MXCSR setting.

**Example** comparing rounding modes:

```nasm
; XMM0 contains: [2.7][-2.7][2.3][-2.3]

; With MXCSR set to round-to-nearest (default)
cvtps2dq xmm1, xmm0
; XMM1: [3][-3][2][-2]

; With truncation (toward zero)
cvttps2dq xmm2, xmm0
; XMM2: [2][-2][2][-2]
```

### Precision Conversions

#### Single to Double Precision

**CVTPS2PD** - Convert Packed Single-Precision to Packed Double-Precision

```nasm
cvtps2pd xmm0, xmm1       ; Convert 2 low floats to 2 doubles
```

**CVTSS2SD** - Convert Scalar Single-Precision to Scalar Double-Precision

```nasm
cvtss2sd xmm0, xmm1       ; Convert lowest float to double
```

**Example** of precision extension:

```nasm
; XMM1 contains floats: [1.5][2.5][3.5][4.5]
cvtps2pd xmm0, xmm1
; XMM0 contains doubles: [1.5][2.5] (converted from low 2 floats)
```

#### Double to Single Precision

**CVTPD2PS** - Convert Packed Double-Precision to Packed Single-Precision

```nasm
cvtpd2ps xmm0, xmm1       ; Convert 2 doubles to 2 floats (low half)
```

**CVTSD2SS** - Convert Scalar Double-Precision to Scalar Single-Precision

```nasm
cvtsd2ss xmm0, xmm1       ; Convert lowest double to float
```

Double to single conversion may lose precision or produce infinity if the value exceeds float range.

**Example** of precision reduction:

```nasm
; XMM1 contains doubles: [1.234567890123][9.876543210987]
cvtpd2ps xmm0, xmm1
; XMM0 low half contains floats: [1.234568][9.876543] (precision loss)
; XMM0 high half is cleared to zero
```

### Special Conversion Instructions

**CVTPI2PD** - Convert Packed Doubleword Integers to Packed Double-Precision (MMX to XMM)

```nasm
cvtpi2pd xmm0, mm0        ; Convert 2 int32 (MMX) to 2 doubles
```

**CVTPD2PI** - Convert Packed Double-Precision to Packed Doubleword Integers (XMM to MMX)

```nasm
cvtpd2pi mm0, xmm0        ; Convert 2 doubles to 2 int32 (MMX)
```

**CVTTPD2PI** - Convert with Truncation Packed Double-Precision to Packed Doubleword Integers

```nasm
cvttpd2pi mm0, xmm0       ; Convert 2 doubles to 2 int32 (truncate)
```

