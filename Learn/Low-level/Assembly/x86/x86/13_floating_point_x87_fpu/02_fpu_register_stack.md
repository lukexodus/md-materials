## FPU Register Stack


### Register Stack Architecture

The x87 FPU uses a register stack model with 8 registers, each 80 bits wide (extended precision).

**Register naming:**

```
ST(0) - Top of stack (most recently pushed)
ST(1) - Second register
ST(2) - Third register
...
ST(7) - Bottom register (least recently accessed)
```

**Physical vs. Logical registers:**

- Physical registers: R0-R7 (hardware registers)
- Logical registers: ST(0)-ST(7) (relative to TOP pointer)
- TOP pointer in status word determines which physical register is ST(0)

**Stack operation example:**

```
Initial state: TOP = 0
ST(0) = R0, ST(1) = R1, ST(2) = R2, ...

After PUSH (TOP = 7):
ST(0) = R7, ST(1) = R0, ST(2) = R1, ...

After POP (TOP = 1):
ST(0) = R1, ST(1) = R2, ST(2) = R3, ...
```

### Stack Operations

**Load (push) operations:**

```nasm
section .data
    float_val dd 3.14159                ; Single precision
    double_val dq 2.71828               ; Double precision
    extended_val dt 1.41421             ; Extended precision (10 bytes)
    integer_val dd 42                   ; 32-bit integer
    short_int dw 100                    ; 16-bit integer
    long_int dq 1000000                 ; 64-bit integer

section .text
    ; Load floating-point values (push onto stack)
    fld dword [float_val]               ; Load single precision → ST(0)
    fld qword [double_val]              ; Load double precision → ST(0), previous ST(0) → ST(1)
    fld tword [extended_val]            ; Load extended precision → ST(0)
    
    ; Load integer values (convert and push)
    fild dword [integer_val]            ; Load 32-bit integer as float → ST(0)
    fild word [short_int]               ; Load 16-bit integer as float → ST(0)
    fild qword [long_int]               ; Load 64-bit integer as float → ST(0)
    
    ; Load constants
    fldz                                ; Push +0.0 → ST(0)
    fld1                                ; Push +1.0 → ST(0)
    fldpi                               ; Push π → ST(0)
    fldl2e                              ; Push log₂(e) → ST(0)
    fldl2t                              ; Push log₂(10) → ST(0)
    fldlg2                              ; Push log₁₀(2) → ST(0)
    fldln2                              ; Push ln(2) → ST(0)
    
    ; Duplicate stack top
    fld st(0)                           ; Push copy of ST(0) → new ST(0)
    fld st(2)                           ; Push copy of ST(2) → new ST(0)
```

**Store (pop) operations:**

```nasm
section .bss
    result_float resd 1                 ; Single precision
    result_double resq 1                ; Double precision
    result_extended rest 1              ; Extended precision
    result_int resd 1                   ; 32-bit integer

section .text
    ; Store and pop
    fstp dword [result_float]           ; Store ST(0) as single, pop stack
    fstp qword [result_double]          ; Store ST(0) as double, pop stack
    fstp tword [result_extended]        ; Store ST(0) as extended, pop stack
    
    ; Store without popping
    fst dword [result_float]            ; Store ST(0) as single, keep on stack
    fst qword [result_double]           ; Store ST(0) as double, keep on stack
    fst st(1)                           ; Copy ST(0) to ST(1)
    
    ; Store integers (convert and pop)
    fistp dword [result_int]            ; Convert ST(0) to 32-bit integer, pop
    fistp word [result_int]             ; Convert ST(0) to 16-bit integer, pop
    fistp qword [result_int]            ; Convert ST(0) to 64-bit integer, pop
    
    ; Store without conversion
    fist dword [result_int]             ; Convert and store, keep on stack
    fist word [result_int]              ; Convert and store, keep on stack
```

**Stack management:**

```nasm
    ; Pop without storing
    fstp st(0)                          ; Discard ST(0), pop stack
    ffree st(0)                         ; Mark ST(0) as empty (doesn't pop)
    
    ; Exchange registers
    fxch                                ; Exchange ST(0) ↔ ST(1)
    fxch st(3)                          ; Exchange ST(0) ↔ ST(3)
    
    ; Clear exceptions and pop
    fclex                               ; Clear exception flags (wait)
    fnclex                              ; Clear exception flags (no wait)
```

### Stack Management Patterns

**Cleaning up the stack:**

```nasm
    ; Clear all 8 registers
    finit                               ; Reset FPU (empties stack)
    
    ; Or manually pop all
    ffree st(0)
    ffree st(1)
    ffree st(2)
    ffree st(3)
    ffree st(4)
    ffree st(5)
    ffree st(6)
    ffree st(7)
    finit                               ; Reset TOP pointer
```

**Managing stack depth:**

```nasm
    ; Check stack depth before operations
    fstsw ax                            ; Get status word
    shr ax, 11                          ; Shift TOP pointer to bits 2:0
    and ax, 7                           ; Isolate TOP value
    ; AX now contains number of free stack slots (0-7)
    
    ; Prevent stack overflow
    cmp ax, 1                           ; Check if nearly full
    jl stack_overflow_error
    fld dword [value]                   ; Safe to push
```

**Preserving intermediate results:**

```nasm
    ; Save ST(0) for later use
    fld st(0)                           ; Duplicate ST(0)
    ; Perform operations on ST(0)
    fadd dword [offset]
    ; Original value still in ST(1)
    
    ; Multiple intermediate values
    fld dword [x]                       ; ST(0) = x
    fld dword [y]                       ; ST(0) = y, ST(1) = x
    fld st(1)                           ; ST(0) = x, ST(1) = y, ST(2) = x
    fmul st(0), st(0)                   ; ST(0) = x², ST(1) = y, ST(2) = x
    fxch st(1)                          ; ST(0) = y, ST(1) = x², ST(2) = x
    fmul st(0), st(0)                   ; ST(0) = y², ST(1) = x², ST(2) = x
    faddp st(1), st(0)                  ; ST(0) = x² + y², ST(1) = x
```

