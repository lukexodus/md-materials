## x87 FPU Architecture Overview


The x87 FPU uses a register stack architecture with eight 80-bit registers (ST(0) through ST(7)), where ST(0) is the top of the stack. Operations typically use ST(0) and one other register, with results placed in ST(0).

### Register Stack Model

```nasm
section .data
    value1: dq 3.14159265358979323846    ; 64-bit double
    value2: dq 2.71828182845904523536

section .text
    ; Load values onto FPU stack
    fld qword [value1]         ; ST(0) = π
    fld qword [value2]         ; ST(0) = e, ST(1) = π
    
    ; Basic arithmetic
    faddp st1, st0             ; ST(0) = ST(1) + ST(0), pop stack
                               ; Result: ST(0) = π + e
    
    ; Stack manipulation
    fld qword [value1]         ; ST(0) = π, ST(1) = π + e
    fxch st1                   ; Exchange ST(0) and ST(1)
    fstp qword [result]        ; Store and pop
```

### Data Types and Precision

```nasm
section .data
    float_val: dd 3.14         ; 32-bit single precision
    double_val: dq 3.14159     ; 64-bit double precision
    extended_val: dt 3.141592653589793  ; 80-bit extended precision
    int16_val: dw 42           ; 16-bit integer
    int32_val: dd 100          ; 32-bit integer
    int64_val: dq 1000         ; 64-bit integer

section .text
    ; Load different data types
    fld dword [float_val]      ; Load 32-bit float
    fld qword [double_val]     ; Load 64-bit double
    fld tword [extended_val]   ; Load 80-bit extended
    
    ; Load integers (converted to float)
    fild word [int16_val]      ; Load 16-bit integer
    fild dword [int32_val]     ; Load 32-bit integer
    fild qword [int64_val]     ; Load 64-bit integer
    
    ; Store with type conversion
    fst dword [float_val]      ; Store as float (keep on stack)
    fstp qword [double_val]    ; Store as double and pop
    fistp dword [int32_val]    ; Convert to integer and pop
```

