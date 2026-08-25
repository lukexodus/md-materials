## Fixed-Point Arithmetic


Fixed-point arithmetic represents fractional numbers using integers by scaling values by a fixed power of 2. This is useful when floating-point operations are unavailable or too slow.

### Fixed-Point Representation

In fixed-point notation, a number is stored as an integer where some bits represent the fractional part. Common formats:

- Q16.16: 16 bits integer, 16 bits fraction
- Q8.24: 8 bits integer, 24 bits fraction
- Q0.32: 32 bits fraction (values between 0 and 1)

**Example (fixed-point representation concepts):**

```nasm
section .data
    ; Q16.16 format: value = integer_part × 2^16 + fractional_part
    fp_value dd 0x00028000   ; 2.5 in Q16.16 (2 × 65536 + 0.5 × 65536)
    fp_pi dd 0x0003243F      ; Approximately 3.14159 in Q16.16
    
section .text
; Convert integer to Q16.16 fixed-point
int_to_fixed:
    mov eax, [integer_val]
    shl eax, 16              ; Multiply by 2^16
    mov [fixed_result], eax
    ret

; Convert Q16.16 fixed-point to integer
fixed_to_int:
    mov eax, [fixed_val]
    sar eax, 16              ; Divide by 2^16 (signed)
    mov [integer_result], eax
    ret
```

### Fixed-Point Addition and Subtraction

Addition and subtraction work directly with fixed-point numbers if they have the same format.

**Example (fixed-point addition):**

```nasm
section .data
    ; Q16.16 format
    fp_a dd 0x00028000       ; 2.5
    fp_b dd 0x00018000       ; 1.5
    
section .bss
    fp_sum resd 1
    
section .text
fixed_add:
    mov eax, [fp_a]
    add eax, [fp_b]          ; Direct addition
    mov [fp_sum], eax        ; Result: 4.0 (0x00040000)
    ret
```

**Example (fixed-point subtraction):**

```nasm
section .text
fixed_subtract:
    mov eax, [fp_a]
    sub eax, [fp_b]          ; Direct subtraction
    mov [fp_difference], eax
    ret
```

**Example (overflow checking in fixed-point addition):**

```nasm
section .text
fixed_add_checked:
    mov eax, [fp_a]
    add eax, [fp_b]
    jo fixed_overflow        ; Check overflow flag
    
    mov [fp_sum], eax
    xor eax, eax             ; Success
    ret
    
fixed_overflow:
    mov eax, 1               ; Error
    ret
```

### Fixed-Point Multiplication

Multiplying two fixed-point numbers requires scaling the result to maintain the correct format.

**Example (Q16.16 multiplication):**

```nasm
section .data
    ; Q16.16 format
    fp_x dd 0x00028000       ; 2.5
    fp_y dd 0x00030000       ; 3.0
    
section .bss
    fp_product resd 1
    
section .text
fixed_multiply:
    ; x × y in Q16.16
    mov eax, [fp_x]          ; EAX = 2.5 in Q16.16
    imul dword [fp_y]        ; EDX:EAX = 2.5 × 3.0 in Q32.32
    
    ; Result is in Q32.32, need to convert to Q16.16
    ; Shift right 16 bits to get Q16.16
    shrd eax, edx, 16        ; Shift right 16, taking bits from EDX
    sar edx, 16
    
    ; EAX now contains 7.5 in Q16.16 (0x00078000)
    mov [fp_product], eax
    ret
```

**Example (Q16.16 multiplication with rounding):**

```nasm
section .text
fixed_multiply_round:
    mov eax, [fp_x]
    imul dword [fp_y]        ; EDX:EAX = product in Q32.32
    
    ; Add 0.5 in Q32.32 format (0x00008000) for rounding
    add eax, 0x8000
    adc edx, 0
    
    ; Shift right 16 bits
    shrd eax, edx, 16
    sar edx, 16
    
    mov [fp_product], eax
    ret
```

**Example (signed Q16.16 multiplication with overflow check):**

```nasm
section .text
fixed_multiply_checked:
    mov eax, [fp_x]
    imul dword [fp_y]        ; EDX:EAX = result
    
    ; Check if result fits in Q16.16
    ; After shift, EDX should be sign extension of EAX's bit 31
    shrd eax, edx, 16
    sar edx, 16
    
    ; Check if EDX is proper sign extension
    mov ebx, eax
    sar ebx, 31              ; EBX = sign extension of EAX
    cmp edx, ebx
    jne overflow_detected
    
    mov [fp_product], eax
    xor eax, eax             ; Success
    ret
    
overflow_detected:
    mov eax, 1               ; Error
    ret
```

### Fixed-Point Division

Division requires pre-scaling the dividend to maintain precision.

**Example (Q16.16 division):**

```nasm
section .data
    fp_dividend dd 0x00078000    ; 7.5
    fp_divisor dd 0x00028000     ; 2.5
    
section .bss
    fp_quotient resd 1
    
section .text
fixed_divide:
    ; x ÷ y in Q16.16
    ; Need to compute (x << 16) ÷ y
    
    mov eax, [fp_dividend]   ; EAX = 7.5 in Q16.16
    cdq                      ; Sign-extend to EDX:EAX
    
    ; Shift left 16 bits: EDX:EAX << 16
    shld edx, eax, 16
    shl eax, 16
    
    ; Now EDX:EAX is dividend in Q32.32
    idiv dword [fp_divisor]  ; EAX = quotient in Q16.16
    
    ; EAX = 3.0 in Q16.16 (0x00030000)
    mov [fp_quotient], eax
    ret
```

**Example (Q16.16 division with range checking):**

```nasm
section .text
fixed_divide_safe:
    mov ebx, [fp_divisor]
    
    ; Check for division by zero
    test ebx, ebx
    jz division_error
    
    mov eax, [fp_dividend]
    cdq
    
    ; Shift left 16 bits
    shld edx, eax, 16
    shl eax, 16
    
    ; Check for overflow before division
    ; If |EDX| >= |divisor|, quotient won't fit
    mov ecx, edx
    ; Simplified check
    cmp edx, ebx
    jge division_error
    
    idiv ebx
    mov [fp_quotient], eax
    xor eax, eax             ; Success
    ret
    
division_error:
    mov eax, 1               ; Error
    ret
```

### Fixed-Point Square Root

**Example (integer square root for fixed-point):**

```nasm
section .text
; Newton-Raphson method for square root in Q16.16
fixed_sqrt:
    mov eax, [fp_value]
    
    ; Check for negative or zero
    test eax, eax
    jle sqrt_error
    
    ; Initial guess: x/2
    mov ebx, eax
    shr ebx, 1
    
    ; Iterate: x_new = (x + value/x) / 2
    mov ecx, 10              ; Iteration count
    
sqrt_loop:
    ; Compute value / x
    mov eax, [fp_value]
    cdq
    shld edx, eax, 16
    shl eax, 16
    idiv ebx                 ; EAX = value / x in Q16.16
    
    ; Compute (x + value/x) / 2
    add eax, ebx
    sar eax, 1               ; Divide by 2
    
    mov ebx, eax             ; Update guess
    loop sqrt_loop
    
    mov [fp_result], eax
    xor eax, eax
    ret
    
sqrt_error:
    mov eax, 1
    ret
```

### Fixed-Point Trigonometry

**Example (sine approximation using Taylor series in fixed-point):**

```nasm
section .data
    ; Q16.16 constants for Taylor series
    ; sin(x) ≈ x - x³/3! + x⁵/5! - x⁷/7!
    fact3_inv dd 0x00002AAB  ; 1/6 in Q16.16
    fact5_inv dd 0x000001C0  ; 1/120 in Q16.16
    fact7_inv dd 0x00000028  ; 1/5040 in Q16.16
    
section .text
fixed_sin_approx:
    push ebp
    mov ebp, esp
    sub esp, 16              ; Local variables
    
    mov eax, [ebp+8]         ; Get x in Q16.16
    mov [ebp-4], eax         ; Store x
    
    ; Compute x³
    imul eax, [ebp-4]
    shrd eax, edx, 16
    imul eax, [ebp-4]
    shrd eax, edx, 16
    mov [ebp-8], eax         ; Store x³
    
    ; Compute x³/6
    imul eax, [fact3_inv]
    shrd eax, edx, 16
    mov [ebp-12], eax        ; Store x³/6
    
    ; Result ≈ x - x³/6 (first two terms)
    mov eax, [ebp-4]
    sub eax, [ebp-12]
    
    mov esp, ebp
    pop ebp
    ret
```

### Fixed-Point Scaling Conversion

**Example (converting between different fixed-point formats):**

```nasm
section .text
; Convert Q16.16 to Q8.24
convert_q16_16_to_q8_24:
    mov eax, [q16_16_value]
    shl eax, 8               ; Shift left 8 bits
    mov [q8_24_value], eax
    ret

; Convert Q8.24 to Q16.16
convert_q8_24_to_q16_16:
    mov eax, [q8_24_value]
    
    ; Add rounding bit
    add eax, 0x80            ; Add 0.5 in lowest bit to be discarded
    
    sar eax, 8               ; Shift right 8 bits (signed)
    mov [q16_16_value], eax
    ret

; Convert Q16.16 to Q0.32 (fractional only)
convert_q16_16_to_q0_32:
    mov eax, [q16_16_value]
    shl eax, 16
    mov [q0_32_value], eax
    ret
```

### Fixed-Point Interpolation

**Example (linear interpolation in fixed-point):**

```nasm
section .text
; Linear interpolation: result = a + t × (b - a)
; a, b, result in Q16.16; t in Q0.16 (0.0 to 1.0)
fixed_lerp:
    mov eax, [fp_b]
    sub eax, [fp_a]          ; b - a
    
    movzx ebx, word [t]      ; t in Q0.16
    imul ebx                 ; EDX:EAX = (b-a) × t in Q16.32
    
    shrd eax, edx, 16        ; Convert to Q16.16
    
    add eax, [fp_a]          ; a + t×(b-a)
    mov [fp_result], eax
    ret
```

### Fixed-Point Saturation

**Example (clamping fixed-point values to range):**

```nasm
section .data
    fp_min dd 0x00000000     ; 0.0 in Q16.16
    fp_max dd 0x00010000     ; 1.0 in Q16.16
    
section .text
fixed_clamp:
    mov eax, [fp_value]
    
    ; Clamp to minimum
    cmp eax, [fp_min]
    jge check_max
    mov eax, [fp_min]
    jmp done
    
check_max:
    ; Clamp to maximum
    cmp eax, [fp_max]
    jle done
    mov eax, [fp_max]
    
done:
    mov [fp_result], eax
    ret
```

### Fixed-Point Matrix Operations

**Example (2x2 matrix multiplication in Q16.16):**

```nasm
section .data
    ; Matrix A
    a11 dd 0x00020000        ; 2.0
    a12 dd 0x00010000        ; 1.0
    a21 dd 0x00030000        ; 3.0
    a22 dd 0x00040000        ; 4.0
    
    ; Matrix B
    b11 dd 0x00010000        ; 1.0
    b12 dd 0x00020000        ; 2.0
    b21 dd 0x00030000        ; 3.0
    b22 dd 0x00040000        ; 4.0
    
section .bss
    ; Result matrix C
    c11 resd 1
    c12 resd 1
    c21 resd 1
    c22 resd 1
    
section .text
matrix_multiply_2x2:
    ; c11 = a11*b11 + a12*b21
    mov eax, [a11]
    imul dword [b11]
    shrd eax, edx, 16
    mov ebx, eax
    
    mov eax, [a12]
    imul dword [b21]
    shrd eax, edx, 16
    add eax, ebx
    mov [c11], eax
    
    ; c12 = a11*b12 + a12*b22
    mov eax, [a11]
    imul dword [b12]
    shrd eax, edx, 16
    mov ebx, eax
    
    mov eax, [a12]
    imul dword [b22]
    shrd eax, edx, 16
    add eax, ebx
    mov [c12], eax
    
    ; c21 = a21*b11 + a22*b21
    mov eax, [a21]
    imul dword [b11]
    shrd eax, edx, 16
    mov ebx, eax
    
    mov eax, [a22]
    imul dword [b21]
    shrd eax, edx, 16
    add eax, ebx
    mov [c21], eax
    
    ; c22 = a21*b12 + a22*b22
    mov eax, [a21]
    imul dword [b12]
    shrd eax, edx, 16
    mov ebx, eax
    
    mov eax, [a22]
    imul dword [b22]
    shrd eax, edx, 16
    add eax, ebx
    mov [c22], eax
    ret
```

### Fixed-Point Performance Considerations

**Example (comparing floating-point vs fixed-point performance concept):**

```nasm
section .text
; Fixed-point operations are typically faster than floating-point
; when FPU is not available or on embedded systems

; Floating-point addition (x87)
float_add:
    fld dword [float_a]
    fadd dword [float_b]
    fstp dword [float_result]
    ret

; Fixed-point addition (much faster)
fixed_add_fast:
    mov eax, [fp_a]
    add eax, [fp_b]
    mov [fp_result], eax
    ret
```

**Important subtopics:**

**Extended precision arithmetic** - Implementing multiplication and division for numbers larger than 64 bits using multi-word techniques.

**Booth's multiplication algorithm** - Optimized signed multiplication algorithm that reduces the number of addition operations.

**Non-restoring division** - Faster division algorithm alternative to restoring division, useful for hardware implementation and understanding.

**Floating-point emulation** - Implementing IEEE 754 floating-point operations in software using integer arithmetic when hardware FPU is unavailable.

---

