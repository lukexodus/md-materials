## Embedded Rounding


One of AVX-512's most significant features is embedded rounding control, allowing instructions to override the MXCSR rounding mode without modifying the control register. This eliminates expensive rounding mode changes and enables different rounding behaviors within the same code sequence.

### Rounding Modes

AVX-512 supports four rounding modes that can be embedded in instruction encoding:

**Rounding Mode Encodings:**

- `{rn-sae}` or `{rne-sae}`: Round to Nearest Even (ties to even)
- `{rd-sae}`: Round Down (toward -∞, floor)
- `{ru-sae}`: Round Up (toward +∞, ceiling)
- `{rz-sae}`: Round toward Zero (truncate)

The suffix `sae` stands for "Suppress All Exceptions," which disables floating-point exception reporting for the operation.

### Register-to-Register Operations with Embedded Rounding

Embedded rounding is available only for register-to-register operations (not memory operands) and only for 512-bit operations.

**Syntax:**

```asm
vaddps zmm1 {k1}, zmm2, zmm3, {rn-sae}    ; Round to nearest
vaddps zmm1 {k1}, zmm2, zmm3, {rd-sae}    ; Round down
vaddps zmm1 {k1}, zmm2, zmm3, {ru-sae}    ; Round up
vaddps zmm1 {k1}, zmm2, zmm3, {rz-sae}    ; Round toward zero
```

### Supported Operations

Embedded rounding is available for floating-point arithmetic operations:

**Single-Precision Operations:**

- `VADDPS` - Add packed single-precision
- `VSUBPS` - Subtract packed single-precision
- `VMULPS` - Multiply packed single-precision
- `VDIVPS` - Divide packed single-precision
- `VSQRTPS` - Square root packed single-precision
- `VFMADD132PS/VFMADD213PS/VFMADD231PS` - Fused multiply-add variants
- `VFMSUB*PS, VFNMADD*PS, VFNMSUB*PS` - Other FMA variants
- `VGETEXPPS` - Extract exponent
- `VGETMANTPS` - Extract mantissa
- `VRCP14PS/VRCP28PS` - Reciprocal approximation
- `VRSQRT14PS/VRSQRT28PS` - Reciprocal square root approximation
- `VSCALEFPS` - Scale by power of 2

**Double-Precision Operations:** Corresponding `*PD` variants for all operations listed above (e.g., `VADDPD`, `VMULPD`, etc.)

**Scalar Operations:** Scalar variants (`*SS` for single, `*SD` for double) also support embedded rounding.

**Conversion Operations:**

- `VCVTPS2PD` - Convert single to double precision
- `VCVTPD2PS` - Convert double to single precision
- `VCVTSI2SS/VCVTSI2SD` - Convert integer to float
- `VCVTSS2SI/VCVTSD2SI` - Convert float to integer
- `VCVTTSS2SI/VCVTTSD2SI` - Convert with truncation
- `VCVTPS2DQ/VCVTPD2DQ` - Convert float to integer (packed)
- `VCVTPS2UDQ/VCVTPD2UDQ` - Convert float to unsigned integer

### Performance Benefits

**Eliminates Mode Switching:** Traditional rounding mode changes require modifying MXCSR, which can cause pipeline stalls. Embedded rounding provides per-instruction control without state changes.

**Enables Mixed-Precision Code:** Different operations in the same function can use different rounding modes without overhead.

**Improves Numerical Accuracy:** Algorithms requiring specific rounding behavior (interval arithmetic, correctly rounded operations) benefit from fine-grained control.

**Reduces Instruction Count:** No need for LDMXCSR/STMXCSR instruction pairs around operations requiring special rounding.

### Code Examples with Embedded Rounding

**Example 1: Basic Embedded Rounding**

```asm
section .data
    align 64
    values1: dd 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5
            dd 9.5, 10.5, 11.5, 12.5, 13.5, 14.5, 15.5, 16.5
    values2: dd 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8
            dd 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6
    
    result_nearest: times 16 dd 0
    result_down: times 16 dd 0
    result_up: times 16 dd 0
    result_zero: times 16 dd 0

section .text
    vmovaps zmm0, [values1]          ; Load first vector
    vmovaps zmm1, [values2]          ; Load second vector
    
    ; Add with different rounding modes
    vaddps zmm2, zmm0, zmm1, {rn-sae}    ; Round to nearest
    vmovaps [result_nearest], zmm2
    
    vaddps zmm3, zmm0, zmm1, {rd-sae}    ; Round down
    vmovaps [result_down], zmm3
    
    vaddps zmm4, zmm0, zmm1, {ru-sae}    ; Round up
    vmovaps [result_up], zmm4
    
    vaddps zmm5, zmm0, zmm1, {rz-sae}    ; Round toward zero
    vmovaps [result_zero], zmm5
```

**Output:** [Inference: Results will differ based on rounding mode for values where fractional parts don't represent exactly.]

**Example 2: Interval Arithmetic**

```asm
section .data
    align 64
    lower_bounds: dd 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0
                 dd 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0
    upper_bounds: dd 1.1, 2.1, 3.1, 4.1, 5.1, 6.1, 7.1, 8.1
                 dd 9.1, 10.1, 11.1, 12.1, 13.1, 14.1, 15.1, 16.1
    divisor: dd 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0
            dd 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0
    
    result_lower: times 16 dd 0
    result_upper: times 16 dd 0

section .text
    vmovaps zmm0, [lower_bounds]
    vmovaps zmm1, [upper_bounds]
    vmovaps zmm2, [divisor]
    
    ; Divide lower bounds rounding down (toward -∞)
    vdivps zmm3, zmm0, zmm2, {rd-sae}
    vmovaps [result_lower], zmm3
    
    ; Divide upper bounds rounding up (toward +∞)
    vdivps zmm4, zmm1, zmm2, {ru-sae}
    vmovaps [result_upper], zmm4
```

This ensures the computed interval contains all possible results, essential for verified numerical computing.

**Example 3: Fused Multiply-Add with Rounding**

```asm
section .data
    align 64
    a_values: dd 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0
             dd 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0
    b_values: dd 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2
             dd 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0
    c_values: dd 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0
             dd 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0
    result: times 16 dd 0

section .text
    vmovaps zmm0, [a_values]
    vmovaps zmm1, [b_values]
    vmovaps zmm2, [c_values]
    
    ; Compute a * b + c with truncation rounding
    vfmadd213ps zmm0, zmm1, zmm2, {rz-sae}
    vmovaps [result], zmm0
```

**Output:** result = a × b + c with all operations rounded toward zero

**Example 4: Convert Float to Integer with Specific Rounding**

```asm
section .data
    align 64
    floats: dd 1.4, 1.5, 1.6, 2.4, 2.5, 2.6, -1.4, -1.5
           dd -1.6, -2.4, -2.5, -2.6, 0.5, -0.5, 100.7, -100.7
    
    int_nearest: times 16 dd 0
    int_floor: times 16 dd 0
    int_ceil: times 16 dd 0
    int_trunc: times 16 dd 0

section .text
    vmovaps zmm0, [floats]
    
    ; Convert with different rounding modes
    vcvtps2dq zmm1, zmm0, {rn-sae}       ; Round to nearest
    vmovdqa32 [int_nearest], zmm1
    
    vcvtps2dq zmm2, zmm0, {rd-sae}       ; Floor
    vmovdqa32 [int_floor], zmm2
    
    vcvtps2dq zmm3, zmm0, {ru-sae}       ; Ceiling
    vmovdqa32 [int_ceil], zmm3
    
    vcvtps2dq zmm4, zmm0, {rz-sae}       ; Truncate
    vmovdqa32 [int_trunc], zmm4
```

**Output:** (for value 1.5)

- int_nearest = 2 (rounds to even)
- int_floor = 1
- int_ceil = 2
- int_trunc = 1

**Example 5: Scalar Operations with Embedded Rounding**

```asm
section .data
    val1: dd 10.7
    val2: dd 3.2
    result: dd 0.0

section .text
    vmovss xmm0, [val1]
    vmovss xmm1, [val2]
    
    ; Divide scalar with round-up
    vdivss xmm2, xmm0, xmm1, {ru-sae}
    vmovss [result], xmm2
```

**Output:** result = ceil(10.7 / 3.2) = ceil(3.34375) ≈ 3.344 (rounded up in floating-point representation)

