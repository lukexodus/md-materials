## Basic FP Instructions


### FADD - Floating-Point Addition

**Instruction variants:**

```nasm
fadd                                    ; ST(0) = ST(0) + ST(1)
fadd st(i)                              ; ST(0) = ST(0) + ST(i)
fadd st(i), st(0)                       ; ST(i) = ST(i) + ST(0)
faddp                                   ; ST(1) = ST(1) + ST(0), pop
faddp st(i), st(0)                      ; ST(i) = ST(i) + ST(0), pop
fadd dword [mem]                        ; ST(0) = ST(0) + mem32
fadd qword [mem]                        ; ST(0) = ST(0) + mem64
fiadd dword [mem]                       ; ST(0) = ST(0) + int32
fiadd word [mem]                        ; ST(0) = ST(0) + int16
```

**Basic addition examples:**

```nasm
section .data
    num1 dd 10.5
    num2 dd 20.3
    int_val dd 15

section .bss
    result resd 1

section .text
    ; Simple addition
    fld dword [num1]                    ; ST(0) = 10.5
    fadd dword [num2]                   ; ST(0) = 10.5 + 20.3 = 30.8
    fstp dword [result]                 ; Store and pop
    
    ; Stack-based addition
    fld dword [num1]                    ; ST(0) = 10.5
    fld dword [num2]                    ; ST(0) = 20.3, ST(1) = 10.5
    faddp st(1), st(0)                  ; ST(0) = 30.8, pop
    fstp dword [result]
    
    ; Add integer
    fld dword [num1]                    ; ST(0) = 10.5
    fiadd dword [int_val]               ; ST(0) = 10.5 + 15 = 25.5
    fstp dword [result]
    
    ; Add constant
    fld dword [num1]                    ; ST(0) = 10.5
    fld1                                ; ST(0) = 1.0, ST(1) = 10.5
    faddp st(1), st(0)                  ; ST(0) = 11.5
```

**Sum of array:**

```nasm
section .data
    array dd 1.1, 2.2, 3.3, 4.4, 5.5
    array_size equ 5

section .text
    ; Sum all elements
    fldz                                ; ST(0) = 0.0 (accumulator)
    xor ecx, ecx                        ; Index = 0
    
sum_loop:
    fadd dword [array + ecx*4]          ; Add array[ecx]
    inc ecx
    cmp ecx, array_size
    jl sum_loop
    ; ST(0) contains sum
    fstp dword [result]
```

### FSUB - Floating-Point Subtraction

**Instruction variants:**

```nasm
fsub                                    ; ST(0) = ST(0) - ST(1)
fsub st(i)                              ; ST(0) = ST(0) - ST(i)
fsub st(i), st(0)                       ; ST(i) = ST(i) - ST(0)
fsubp                                   ; ST(1) = ST(1) - ST(0), pop
fsubp st(i), st(0)                      ; ST(i) = ST(i) - ST(0), pop
fsub dword [mem]                        ; ST(0) = ST(0) - mem32
fsub qword [mem]                        ; ST(0) = ST(0) - mem64

; Reverse subtract (operands swapped)
fsubr                                   ; ST(0) = ST(1) - ST(0)
fsubr st(i)                             ; ST(0) = ST(i) - ST(0)
fsubr st(i), st(0)                      ; ST(i) = ST(0) - ST(i)
fsubrp                                  ; ST(1) = ST(0) - ST(1), pop
fsubrp st(i), st(0)                     ; ST(i) = ST(0) - ST(i), pop
fsubr dword [mem]                       ; ST(0) = mem32 - ST(0)
fsubr qword [mem]                       ; ST(0) = mem64 - ST(0)

fisub dword [mem]                       ; ST(0) = ST(0) - int32
fisub word [mem]                        ; ST(0) = ST(0) - int16
fisubr dword [mem]                      ; ST(0) = int32 - ST(0)
fisubr word [mem]                       ; ST(0) = int16 - ST(0)
```

**Basic subtraction examples:**

```nasm
section .data
    num1 dd 50.0
    num2 dd 30.0

section .text
    ; Simple subtraction
    fld dword [num1]                    ; ST(0) = 50.0
    fsub dword [num2]                   ; ST(0) = 50.0 - 30.0 = 20.0
    
    ; Reverse subtraction
    fld dword [num1]                    ; ST(0) = 50.0
    fsubr dword [num2]                  ; ST(0) = 30.0 - 50.0 = -20.0
    
    ; Stack-based subtraction
    fld dword [num1]                    ; ST(0) = 50.0
    fld dword [num2]                    ; ST(0) = 30.0, ST(1) = 50.0
    fsubrp st(1), st(0)                 ; ST(0) = 50.0 - 30.0 = 20.0
    
    ; Subtract from constant
    fld1                                ; ST(0) = 1.0
    fsub dword [num2]                   ; ST(0) = 1.0 - 30.0 = -29.0
```

**Computing differences:**

```nasm
    ; Absolute difference |a - b|
    fld dword [a]                       ; ST(0) = a
    fld dword [b]                       ; ST(0) = b, ST(1) = a
    fsubp st(1), st(0)                  ; ST(0) = a - b
    fabs                                ; ST(0) = |a - b|
    
    ; Distance between points: sqrt((x2-x1)² + (y2-y1)²)
    fld dword [x2]                      ; ST(0) = x2
    fsub dword [x1]                     ; ST(0) = dx = x2 - x1
    fmul st(0), st(0)                   ; ST(0) = dx²
    
    fld dword [y2]                      ; ST(0) = y2, ST(1) = dx²
    fsub dword [y1]                     ; ST(0) = dy = y2 - y1
    fmul st(0), st(0)                   ; ST(0) = dy², ST(1) = dx²
    
    faddp st(1), st(0)                  ; ST(0) = dx² + dy²
    fsqrt                               ; ST(0) = distance
```

### FMUL - Floating-Point Multiplication

**Instruction variants:**

```nasm
fmul                                    ; ST(0) = ST(0) × ST(1)
fmul st(i)                              ; ST(0) = ST(0) × ST(i)
fmul st(i), st(0)                       ; ST(i) = ST(i) × ST(0)
fmulp                                   ; ST(1) = ST(1) × ST(0), pop
fmulp st(i), st(0)                      ; ST(i) = ST(i) × ST(0), pop
fmul dword [mem]                        ; ST(0) = ST(0) × mem32
fmul qword [mem]                        ; ST(0) = ST(0) × mem64
fimul dword [mem]                       ; ST(0) = ST(0) × int32
fimul word [mem]                        ; ST(0) = ST(0) × int16
```

**Basic multiplication examples:**

```nasm
section .data
    num1 dd 5.0
    num2 dd 3.0
    scale dd 2.5

section .text
    ; Simple multiplication
    fld dword [num1]                    ; ST(0) = 5.0
    fmul dword [num2]                   ; ST(0) = 5.0 × 3.0 = 15.0
    
    ; Stack-based multiplication
    fld dword [num1]                    ; ST(0) = 5.0
    fld dword [num2]                    ; ST(0) = 3.0, ST(1) = 5.0
    fmulp st(1), st(0)                  ; ST(0) = 15.0
    
    ; Square a number
    fld dword [num1]                    ; ST(0) = 5.0
    fmul st(0), st(0)                   ; ST(0) = 25.0
    
    ; Scale by constant
    fld dword [num1]                    ; ST(0) = 5.0
    fmul dword [scale]                  ; ST(0) = 5.0 × 2.5 = 12.5
```

**Product of array:**

```nasm
section .data
    array dd 2.0, 3.0, 4.0, 5.0
    array_size equ 4

section .text
    ; Multiply all elements
    fld1                                ; ST(0) = 1.0 (accumulator)
    xor ecx, ecx
    
product_loop:
    fmul dword [array + ecx*4]          ; Multiply by array[ecx]
    inc ecx
    cmp ecx, array_size
    jl product_loop
    ; ST(0) = 2 × 3 × 4 × 5 = 120.0
```

**Dot product (vector multiplication):**

```nasm
section .data
    vec1_x dd 1.0
    vec1_y dd 2.0
    vec1_z dd 3.0
    
    vec2_x dd 4.0
    vec2_y dd 5.0
    vec2_z dd 6.0

section .text
    ; Compute dot product: (x1×x2) + (y1×y2) + (z1×z2)
    fld dword [vec1_x]
    fmul dword [vec2_x]                 ; ST(0) = x1 × x2
    
    fld dword [vec1_y]                  ; ST(0) = y1, ST(1) = x1×x2
    fmul dword [vec2_y]                 ; ST(0) = y1 × y2, ST(1) = x1×x2
    faddp st(1), st(0)                  ; ST(0) = x1×x2 + y1×y2
    
    fld dword [vec1_z]                  ; ST(0) = z1, ST(1) = sum
    fmul dword [vec2_z]                 ; ST(0) = z1 × z2, ST(1) = sum
    faddp st(1), st(0)                  ; ST(0) = dot product
    
    fstp dword [result]                 ; Store result
```

### FDIV - Floating-Point Division

**Instruction variants:**

```nasm
fdiv                                    ; ST(0) = ST(0) / ST(1)
fdiv st(i)                              ; ST(0) = ST(0) / ST(i)
fdiv st(i), st(0)                       ; ST(i) = ST(i) / ST(0)
fdivp                                   ; ST(1) = ST(1) / ST(0), pop
fdivp st(i), st(0)                      ; ST(i) = ST(i) / ST(0), pop
fdiv dword [mem]                        ; ST(0) = ST(0) / mem32
fdiv qword [mem]                        ; ST(0) = ST(0) / mem64

; Reverse divide (operands swapped)
fdivr                                   ; ST(0) = ST(1) / ST(0)
fdivr st(i)                             ; ST(0) = ST(i) / ST(0)
fdivr st(i), st(0)                      ; ST(i) = ST(0) / ST(i)
fdivrp                                  ; ST(1) = ST(0) / ST(1), pop
fdivrp st(i), st(0)                     ; ST(i) = ST(0) / ST(i), pop
fdivr dword [mem]                       ; ST(0) = mem32 / ST(0)
fdivr qword [mem]                       ; ST(0) = mem64 / ST(0)

fidiv dword [mem]                       ; ST(0) = ST(0) / int32
fidiv word [mem]                        ; ST(0) = ST(0) / int16
fidivr dword [mem]                      ; ST(0) = int32 / ST(0)
fidivr word [mem]                       ; ST(0) = int16 / ST(0)
```

**Basic division examples:**

```nasm
section .data
    numerator dd 100.0
    denominator dd 4.0
    dividend dd 50.0

section .text
    ; Simple division
    fld dword [numerator]               ; ST(0) = 100.0
    fdiv dword [denominator]            ; ST(0) = 100.0 / 4.0 = 25.0
    
    ; Reverse division
    fld dword [numerator]               ; ST(0) = 100.0
    fdivr dword [denominator]           ; ST(0) = 4.0 / 100.0 = 0.04
    
    ; Stack-based division
    fld dword [numerator]               ; ST(0) = 100.0
    fld dword [denominator]             ; ST(0) = 4.0, ST(1) = 100.0
    fdivrp st(1), st(0)                 ; ST(0) = 100.0 / 4.0 = 25.0
    
    ; Reciprocal (1/x)
    fld1                                ; ST(0) = 1.0
    fdiv dword [denominator]            ; ST(0) = 1.0 / 4.0 = 0.25
    
    ; Or using reverse divide
    fld dword [denominator]             ; ST(0) = 4.0
    fld1                                ; ST(0) = 1.0, ST(1) = 4.0
    fdivrp st(1), st(0)                 ; ST(0) = 1.0 / 4.0 = 0.25
```

**Division by zero handling:**

```nasm
section .text
    ; Division with zero check
    fld dword [numerator]               ; ST(0) = numerator
    fldz                                ; ST(0) = 0.0, ST(1) = numerator
    fcomp dword [denominator]           ; Compare denominator with 0.0
    fstsw ax
    sahf
    je division_by_zero                 ; If equal, handle error
    
    fdiv dword [denominator]            ; Safe division
    jmp division_done
    
division_by_zero:
    fstp st(0)                          ; Clean up stack
    ; Handle error (set to infinity, NaN, or error code)
    fldz
    fld1
    fdivp st(1), st(0)                  ; Result = +Infinity
    
division_done:
    fstp dword [result]
```

**Average calculation:**

```nasm
section .data
    values dd 10.0, 20.0, 30.0, 40.0, 50.0
    count dd 5

section .text
    ; Calculate average
    fldz                                ; ST(0) = 0.0 (sum)
    xor ecx, ecx
    
sum_values:
    fadd dword [values + ecx*4]
    inc ecx
    cmp ecx, [count]
    jl sum_values
    
    fidiv dword [count]                 ; Divide sum by count
    fstp dword [average]                ; Store average
```

**Percentage calculation:**

```nasm
section .data
    part dd 25.0
    total dd 200.0
    hundred dd 100.0

section .text
    ; Calculate percentage: (part / total) × 100
    fld dword [part]                    ; ST(0) = 25.0
    fdiv dword [total]                  ; ST(0) = 0.125
    fmul dword [hundred]                ; ST(0) = 12.5
    fstp dword [percentage]             ; percentage = 12.5%
```

### Combined Arithmetic Operations

**Expression evaluation: (a + b) × (c - d)**

```nasm
section .data
    a dd 10.0
    b dd 5.0
    c dd 20.0
    d dd 8.0

section .text
    ; Calculate (a + b)
    fld dword [a]                       ; ST(0) = a
    fadd dword [b]                      ; ST(0) = a + b
    
    ; Calculate (c - d)
    fld dword [c]                       ; ST(0) = c, ST(1) = a+b
    fsub dword [d]                      ; ST(0) = c - d, ST(1) = a+b
    
    ; Multiply results
    fmulp st(1), st(0)                  ; ST(0) = (a+b) × (c-d)
    fstp dword [result]
```

**Quadratic formula: x = (-b ± sqrt(b² - 4ac)) / 2a**

```nasm
section .data
    a dd 1.0                            ; Coefficient a
    b dd -5.0                           ; Coefficient b
    c dd 6.0                            ; Coefficient c
    two dd 2.0
    four dd 4.0

section .bss
    root1 resd 1
    root2 resd 1
    discriminant resd 1

section .text
    ; Calculate discriminant: b² - 4ac
    fld dword [b]                       ; ST(0) = b
    fmul st(0), st(0)                   ; ST(0) = b²
    
    fld dword [four]                    ; ST(0) = 4, ST(1) = b²
    fmul dword [a]                      ; ST(0) = 4a, ST(1) = b²
    fmul dword [c]                      ; ST(0) = 4ac, ST(1) = b²
    
    fsubp st(1), st(0)                  ; ST(0) = b² - 4ac
    fst dword [discriminant]
    
    ; Check if discriminant is negative
    ftst
    fstsw ax
    sahf
    js no_real_roots                    ; Negative discriminant
    
    ; Calculate sqrt(discriminant)
    fsqrt                               ; ST(0) = sqrt(b² - 4ac)
    
    ; Calculate root1: (-b + sqrt) / 2a
    fld dword [b]                       ; ST(0) = b, ST(1) = sqrt
    fchs                                ; ST(0) = -b, ST(1) = sqrt
    fadd st(0), st(1)                   ; ST(0) = -b + sqrt, ST(1) = sqrt
    fld dword [two]                     ; ST(0) = 2, ST(1) = -b+sqrt, ST(2) = sqrt
    fmul dword [a]                      ; ST(0) = 2a, ST(1) = -b+sqrt, ST(2) = sqrt
    fdivp st(1), st(0)                  ; ST(0) = root1, ST(1) = sqrt
    fstp dword [root1]
    
    ; Calculate root2: (-b - sqrt) / 2a
    fld dword [b]                       ; ST(0) = b, ST(1) = sqrt
    fchs                                ; ST(0) = -b, ST(1) = sqrt
    fsubp st(1), st(0)                  ; ST(0) = -b - sqrt
    fld dword [two]                     ; ST(0) = 2, ST(1) = -b-sqrt
    fmul dword [a]                      ; ST(0) = 2a, ST(1) = -b-sqrt
    fdivp st(1), st(0)                  ; ST(0) = root2
    fstp dword [root2]
    
    jmp roots_done

no_real_roots:
    fstp st(0)                          ; Clean up stack
    ; Handle complex roots case
    
roots_done:
```

**Polynomial evaluation: ax³ + bx² + cx + d (Horner's method)**

```nasm
section .data
    x dd 2.0
    coeffs dd 3.0, 2.0, -5.0, 1.0      ; a=3, b=2, c=-5, d=1

section .text
    ; Horner's method: d + x(c + x(b + x×a))
    fld dword [coeffs]                  ; ST(0) = a
    fmul dword [x]                      ; ST(0) = ax
    fadd dword [coeffs + 4]             ; ST(0) = ax + b
    fmul dword [x]                      ; ST(0) = x(ax + b) = ax² + bx
    fadd dword [coeffs + 8]             ; ST(0) = ax² + bx + c
    fmul dword [x]                      ; ST(0) = x(ax² + bx + c)
    fadd dword [coeffs + 12]            ; ST(0) = ax³ + bx² + cx + d
    fstp dword [result]
```

### Additional FPU Operations

**Absolute value:**

```nasm
    fld dword [value]                   ; Load value
    fabs                                ; ST(0) = |ST(0)|
    fstp dword [result]
```

**Change sign:**

```nasm
    fld dword [value]                   ; Load value
    fchs                                ; ST(0) = -ST(0)
    fstp dword [result]
```

**Square root:**

```nasm
    fld dword [value]                   ; Load value
    fsqrt                               ; ST(0) = sqrt(ST(0))
    fstp dword [result]
```

**Round to integer:**

```nasm
    fld dword [value]                   ; Load value
    frndint                             ; Round to integer (stays as float)
    fstp dword [result]
```

**Scale by power of 2:**

```nasm
    ; Multiply ST(0) by 2^ST(1)
    fld dword [value]                   ; ST(0) = value
    fld dword [exponent]                ; ST(0) = exp, ST(1) = value
    fscale                              ; ST(0) = value × 2^exp (ST(1) unchanged)
    fstp st(1)                          ; Remove exponent, keep result
    fstp dword [result]
```

**Extract exponent and mantissa:**

```nasm
    fld dword [value]                   ; ST(0) = value
    fxtract                             ; ST(0) = exponent, ST(1) = mantissa
    fstp dword [exponent]               ; Store exponent
    fstp dword [mantissa]               ; Store mantissa
```

**Remainder:**

```nasm
    ; Compute ST(0) mod ST(1)
    fld dword [dividend]                ; ST(0) = dividend
    fld dword [divisor]                 ; ST(0) = divisor, ST(1) = dividend
    fprem                               ; ST(0) = remainder, ST(1) = divisor
    ; Or use fprem1 for IEEE remainder
    fstp st(1)                          ; Remove divisor
    fstp dword [remainder]
```

### Comparison Operations

**Compare floating-point values:**

```nasm
section .text
    ; Compare ST(0) with memory
    fld dword [value1]                  ; ST(0) = value1
    fcom dword [value2]                 ; Compare with value2
    fstsw ax                            ; Get status word
    sahf                                ; Transfer to CPU flags
    ja value1_greater
    jb value1_less
    je values_equal
    
    ; Compare and pop
    fld dword [value1]
    fcomp dword [value2]                ; Compare and pop
    fstsw ax
    sahf
    
    ; Compare ST(0) with ST(i)
    fld dword [value1]                  ; ST(0) = value1
    fld dword [value2]                  ; ST(0) = value2, ST(1) = value1
    fcompp                              ; Compare ST(0) with ST(1), pop both
    fstsw ax
    sahf
    
    ; Compare with zero
    fld dword [value]
    ftst                                ; Compare ST(0) with 0.0
    fstsw ax
    sahf
    jz is_zero
    js is_negative
    ; Otherwise positive
```

**Unordered comparison (handles NaN):**

```nasm
    ; FUCOM - unordered compare
    fld dword [value1]
    fucom dword [value2]                ; Compare, handles NaN properly
    fstsw ax
    sahf
    jp is_unordered                     ; Parity flag set if NaN
    ja value1_greater
    jb value1_less
    je values_equal
    
is_unordered:
    ; One or both values are NaN
```

**Find maximum/minimum:**

```nasm
    ; Maximum of two values
    fld dword [value1]                  ; ST(0) = value1
    fld dword [value2]                  ; ST(0) = value2, ST(1) = value1
    fcom st(1)                          ; Compare
    fstsw ax
    sahf
    ja val2_greater
    ; value1 >= value2
    fstp st(0)                          ; Pop value2, keep value1
    jmp max_done
val2_greater:
    fstp st(1)                          ; Pop value1, keep value2
max_done:
    fstp dword [maximum]
    
    ; Using conditional move (modern x86)
    fld dword [value1]
    fld dword [value2]
    fcomi st(0), st(1)                  ; Compare and set EFLAGS
    fcmovb st(0), st(1)                 ; Move ST(1) to ST(0) if below
    fstp dword [maximum]
    fstp st(0)                          ; Clean up
```

### Precision and Rounding Control

**Set precision mode:**

```nasm
section .bss
    control_word resw 1

section .text
    ; Get current control word
    fstcw word [control_word]
    
    ; Set to single precision (24-bit mantissa)
    mov ax, [control_word]
    and ax, 0xFCFF                      ; Clear PC bits
    or ax, 0x0000                       ; Set PC = 00 (single)
    mov [control_word], ax
    fldcw word [control_word]
    
    ; Set to double precision (53-bit mantissa)
    mov ax, [control_word]
    and ax, 0xFCFF
    or ax, 0x0200                       ; Set PC = 10 (double)
    mov [control_word], ax
    fldcw word [control_word]
    
    ; Set to extended precision (64-bit mantissa) - default
    mov ax, [control_word]
    or ax, 0x0300                       ; Set PC = 11 (extended)
    mov [control_word], ax
    fldcw word [control_word]
```

**Set rounding mode:**

```nasm
    ; Round to nearest (even) - default
    fstcw word [control_word]
    mov ax, [control_word]
    and ax, 0xF3FF                      ; Clear RC bits
    or ax, 0x0000                       ; RC = 00
    mov [control_word], ax
    fldcw word [control_word]
    
    ; Round down (toward -∞)
    mov ax, [control_word]
    and ax, 0xF3FF
    or ax, 0x0400                       ; RC = 01
    mov [control_word], ax
    fldcw word [control_word]
    
    ; Round up (toward +∞)
    mov ax, [control_word]
    and ax, 0xF3FF
    or ax, 0x0800                       ; RC = 10
    mov [control_word], ax
    fldcw word [control_word]
    
    ; Round toward zero (truncate)
    mov ax, [control_word]
    and ax, 0xF3FF
    or ax, 0x0C00                       ; RC = 11
    mov [control_word], ax
    fldcw word [control_word]
```

### Exception Handling

**Mask/unmask exceptions:**

```nasm
    ; Mask all exceptions (default)
    fstcw word [control_word]
    or word [control_word], 0x003F      ; Set all exception mask bits
    fldcw word [control_word]
    
    ; Unmask divide-by-zero exception
    fstcw word [control_word]
    and word [control_word], 0xFFFB     ; Clear ZM bit
    fldcw word [control_word]
    
    ; Check for exceptions after operation
    fld dword [value1]
    fdiv dword [value2]
    fstsw ax
    test ax, 0x3F                       ; Test exception bits
    jnz exception_occurred
```

**Key Points:**

- x87 FPU uses a stack-based architecture with 8 × 80-bit registers, accessed relative to TOP pointer
- Three floating-point formats supported: single (32-bit), double (64-bit), and extended (80-bit) precision
- All internal calculations performed in 80-bit extended precision for maximum accuracy
- FADD/FSUB/FMUL/FDIV instructions operate on stack registers or memory, with variants for different operand combinations
- Control Word configures rounding mode (nearest/down/up/zero), precision mode (24/53/64-bit), and exception masks
- Status Word reports exceptions and condition codes, transferable to CPU flags via SAHF for conditional branching
- Comparison instructions (FCOM, FUCOM, FTST) set condition codes without modifying operands
- Integer and BCD conversions available through FILD/FIST and FBLD/FBSTP instructions
- [Unverified] Stack discipline critical—mismatched push/pop operations can cause stack overflow or invalid results requiring FINIT reset
- Modern alternatives include SSE/AVX instructions for SIMD floating-point operations with register-based (non-stack) architecture

---

