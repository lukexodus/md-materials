## Transcendental Functions


The x87 FPU provides hardware support for various transcendental functions through specialized instructions.

### Trigonometric Functions

**FSIN - Sine:**

```nasm
section .data
    angle: dq 1.5707963267948966  ; π/2 radians
    result: dq 0.0

section .text
    ; Calculate sin(angle)
    fld qword [angle]          ; ST(0) = angle
    fsin                       ; ST(0) = sin(angle)
    fstp qword [result]        ; Store result
    
    ; Check for valid range: |angle| < 2^63
    fld qword [angle]
    fsin
    fstsw ax                   ; Load FPU status word
    test ah, 0x04              ; Check C2 flag (range error)
    jnz .range_reduction_needed
```

**FCOS - Cosine:**

```nasm
section .text
    ; Calculate cos(angle)
    fld qword [angle]          ; ST(0) = angle
    fcos                       ; ST(0) = cos(angle)
    fstp qword [result]
```

**FSINCOS - Simultaneous Sine and Cosine:**

```nasm
section .data
    angle: dq 0.785398163      ; π/4 radians
    sin_result: dq 0.0
    cos_result: dq 0.0

section .text
    ; More efficient than separate FSIN and FCOS
    fld qword [angle]          ; ST(0) = angle
    fsincos                    ; ST(0) = cos, ST(1) = sin
    fstp qword [cos_result]    ; Store cosine
    fstp qword [sin_result]    ; Store sine
```

**FPTAN - Partial Tangent:**

```nasm
section .text
    ; Calculate tan(angle)
    ; FPTAN computes ST(1)/ST(0) and pushes 1.0
    fld qword [angle]          ; ST(0) = angle
    fptan                      ; ST(0) = 1.0, ST(1) = tan(angle)
    fstp st0                   ; Pop the 1.0
    fstp qword [result]        ; Store tangent
```

**FPATAN - Partial Arctangent:**

```nasm
section .data
    y_val: dq 3.0
    x_val: dq 4.0
    atan_result: dq 0.0

section .text
    ; Calculate atan2(y, x)
    fld qword [y_val]          ; ST(0) = y
    fld qword [x_val]          ; ST(0) = x, ST(1) = y
    fpatan                     ; ST(0) = atan(y/x)
    fstp qword [atan_result]
    
    ; For simple arctan(x):
    fld qword [x_val]          ; ST(0) = x
    fld1                       ; ST(0) = 1.0, ST(1) = x
    fpatan                     ; ST(0) = atan(x)
```

### Angle Range Reduction

**FSINCOS requires |angle| < 2^63, for larger angles:**

```nasm
section .text
reduce_angle:
    ; Input: ST(0) = angle in radians
    ; Reduce angle to valid range using FPREM1
    
.reduce_loop:
    fprem1                     ; Partial remainder with respect to π/2
    fstsw ax                   ; Load status word
    test ah, 0x04              ; Check C2 (reduction incomplete)
    jnz .reduce_loop           ; Continue if not complete
    
    ; Now angle is in range [-π/4, π/4]
    ret

; Complete sine with range reduction:
sine_full_range:
    fld qword [angle]
    call reduce_angle
    fsin
    fstp qword [result]
    ret
```

### Exponential and Logarithmic Functions

**F2XM1 - 2^x - 1 (for -1 ≤ x ≤ 1):**

```nasm
section .text
    ; Calculate 2^x - 1 for small x
    fld qword [exponent]       ; ST(0) = x, where -1 ≤ x ≤ 1
    f2xm1                      ; ST(0) = 2^x - 1
    fstp qword [result]
```

**Computing 2^x for any x:**

```nasm
section .data
    exponent: dq 3.7
    result: dq 0.0

section .text
    ; Calculate 2^x = 2^(integer_part) * 2^(fractional_part)
    fld qword [exponent]       ; ST(0) = x
    
    ; Split into integer and fractional parts
    fld st0                    ; ST(0) = x, ST(1) = x
    frndint                    ; ST(0) = integer part
    fxch st1                   ; ST(0) = x, ST(1) = integer part
    fsub st0, st1              ; ST(0) = fractional part
    
    ; Compute 2^(fractional)
    f2xm1                      ; ST(0) = 2^frac - 1
    fld1
    faddp st1, st0             ; ST(0) = 2^frac, ST(1) = integer part
    
    ; Scale by 2^(integer)
    fscale                     ; ST(0) = 2^frac * 2^integer = 2^x
    fstp st1                   ; Pop integer part
    fstp qword [result]
```

**Computing e^x:**

```nasm
section .text
exp_function:
    ; Calculate e^x using e^x = 2^(x * log2(e))
    fld qword [x_value]        ; ST(0) = x
    fldl2e                     ; ST(0) = log2(e), ST(1) = x
    fmulp st1, st0             ; ST(0) = x * log2(e)
    
    ; Now compute 2^(result) using the 2^x method above
    fld st0
    frndint
    fxch st1
    fsub st0, st1
    f2xm1
    fld1
    faddp st1, st0
    fscale
    fstp st1
    fstp qword [result]
    ret
```

**FYL2X - y * log2(x):**

```nasm
section .data
    x_val: dq 8.0
    y_val: dq 3.0

section .text
    ; Calculate y * log2(x)
    fld qword [y_val]          ; ST(0) = y
    fld qword [x_val]          ; ST(0) = x, ST(1) = y
    fyl2x                      ; ST(0) = y * log2(x)
    fstp qword [result]        ; Result = 3 * log2(8) = 9
```

**FYL2XP1 - y * log2(x+1) (for |x| < 1-√2/2):**

```nasm
section .text
    ; More accurate for values near zero
    fld qword [y_val]          ; ST(0) = y
    fld qword [x_val]          ; ST(0) = x, ST(1) = y
    fyl2xp1                    ; ST(0) = y * log2(x+1)
    fstp qword [result]
```

**Computing Natural Logarithm ln(x):**

```nasm
section .text
natural_log:
    ; ln(x) = log2(x) / log2(e) = log2(x) * ln(2)
    fldln2                     ; ST(0) = ln(2)
    fld qword [x_value]        ; ST(0) = x, ST(1) = ln(2)
    fyl2x                      ; ST(0) = ln(2) * log2(x) = ln(x)
    fstp qword [result]
    ret
```

**Computing Base-10 Logarithm log10(x):**

```nasm
section .text
log10_function:
    ; log10(x) = log2(x) / log2(10)
    fldlg2                     ; ST(0) = log2(10)
    fld qword [x_value]        ; ST(0) = x, ST(1) = log2(10)
    fyl2x                      ; ST(0) = log2(10) * log2(x) = log10(x)
    fstp qword [result]
    ret
```

**Computing x^y (Power Function):**

```nasm
section .data
    base: dq 2.5
    exponent: dq 3.7
    power_result: dq 0.0

section .text
power_function:
    ; x^y = 2^(y * log2(x))
    fld qword [exponent]       ; ST(0) = y
    fld qword [base]           ; ST(0) = x, ST(1) = y
    fyl2x                      ; ST(0) = y * log2(x)
    
    ; Compute 2^(result)
    fld st0
    frndint
    fxch st1
    fsub st0, st1
    f2xm1
    fld1
    faddp st1, st0
    fscale
    fstp st1
    fstp qword [power_result]
    ret
```

### Square Root and Other Operations

**FSQRT - Square Root:**

```nasm
section .text
    fld qword [value]          ; ST(0) = value
    fsqrt                      ; ST(0) = sqrt(value)
    fstp qword [result]
```

**FXTRACT - Extract Exponent and Significand:**

```nasm
section .text
    ; Extract mantissa and exponent
    fld qword [value]          ; ST(0) = value
    fxtract                    ; ST(0) = exponent, ST(1) = significand
    fstp qword [exponent_out]
    fstp qword [mantissa_out]
```

**FSCALE - Scale by Power of 2:**

```nasm
section .text
    ; Compute x * 2^n efficiently
    fild dword [scale_factor]  ; ST(0) = n (integer)
    fld qword [value]          ; ST(0) = x, ST(1) = n
    fscale                     ; ST(0) = x * 2^n, ST(1) = n
    fstp st1                   ; Pop scale factor
    fstp qword [result]
```

### Constant Values

```nasm
section .text
    ; Load mathematical constants
    fldz                       ; ST(0) = +0.0
    fld1                       ; ST(0) = +1.0
    fldpi                      ; ST(0) = π
    fldl2e                     ; ST(0) = log2(e)
    fldl2t                     ; ST(0) = log2(10)
    fldlg2                     ; ST(0) = log10(2)
    fldln2                     ; ST(0) = ln(2)
```

