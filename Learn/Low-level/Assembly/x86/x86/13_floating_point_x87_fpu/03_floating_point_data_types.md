## Floating-Point Data Types


### IEEE 754 Formats

**Single Precision (32 bits):**

```
Bit 31:    Sign (S)
Bits 30-23: Exponent (E) - 8 bits, biased by 127
Bits 22-0:  Mantissa (M) - 23 bits (24 with implicit leading 1)

Value = (-1)^S × 1.M × 2^(E-127)

Range: ±1.18 × 10^-38 to ±3.40 × 10^38
Precision: ~7 decimal digits
```

```nasm
section .data
    ; Single precision examples
    single_pi dd 3.14159265             ; π (rounded to single precision)
    single_max dd 3.402823e38           ; Maximum positive value
    single_min dd 1.175494e-38          ; Minimum positive normalized value
    single_tiny dd 1.401298e-45         ; Minimum positive denormalized value
    
    ; Special values
    single_inf dd 0x7F800000            ; Positive infinity
    single_ninf dd 0xFF800000           ; Negative infinity
    single_nan dd 0x7FC00000            ; Not a Number (quiet NaN)
    single_zero dd 0x00000000           ; Positive zero
    single_nzero dd 0x80000000          ; Negative zero
```

**Double Precision (64 bits):**

```
Bit 63:     Sign (S)
Bits 62-52: Exponent (E) - 11 bits, biased by 1023
Bits 51-0:  Mantissa (M) - 52 bits (53 with implicit leading 1)

Value = (-1)^S × 1.M × 2^(E-1023)

Range: ±2.23 × 10^-308 to ±1.80 × 10^308
Precision: ~15-16 decimal digits
```

```nasm
section .data
    ; Double precision examples
    double_e dq 2.718281828459045       ; Euler's number
    double_max dq 1.797693e308          ; Maximum positive value
    double_min dq 2.225074e-308         ; Minimum positive normalized value
    
    ; Special values
    double_inf dq 0x7FF0000000000000    ; Positive infinity
    double_nan dq 0x7FF8000000000000    ; Quiet NaN
```

**Extended Precision (80 bits):**

```
Bit 79:     Sign (S)
Bits 78-64: Exponent (E) - 15 bits, biased by 16383
Bit 63:     Integer part (explicit, not implicit like single/double)
Bits 62-0:  Mantissa (M) - 63 bits

Value = (-1)^S × I.M × 2^(E-16383)

Range: ±3.37 × 10^-4932 to ±1.18 × 10^4932
Precision: ~19 decimal digits
```

```nasm
section .data
    ; Extended precision (10 bytes, often stored as 12 with padding)
    extended_val dt 1.23456789012345678 ; Full precision
    
    ; Extended precision offers highest accuracy
    ; All FPU internal calculations use 80-bit format
```

### Integer to Float Conversion

**Load integer as floating-point:**

```nasm
section .data
    int_value dd 12345
    long_value dq 9876543210

section .text
    ; Convert 32-bit integer to float
    fild dword [int_value]              ; ST(0) = 12345.0
    
    ; Convert 64-bit integer to float
    fild qword [long_value]             ; ST(0) = 9876543210.0
    
    ; Convert with scaling
    fild dword [int_value]              ; ST(0) = 12345.0
    fld1                                ; ST(0) = 1.0, ST(1) = 12345.0
    fld1                                ; ST(0) = 1.0, ST(1) = 1.0, ST(2) = 12345.0
    faddp st(1), st(0)                  ; ST(0) = 2.0, ST(1) = 12345.0
    fdivrp st(1), st(0)                 ; ST(0) = 6172.5
```

### Float to Integer Conversion

**Store as integer with rounding:**

```nasm
section .data
    float_value dd 123.456

section .bss
    int_result resd 1

section .text
    ; Convert with current rounding mode
    fld dword [float_value]             ; ST(0) = 123.456
    fistp dword [int_result]            ; int_result = 123 or 124 (depends on rounding mode)
    
    ; Round toward zero (truncate)
    fld dword [float_value]
    frndint                             ; Round to integer (stays in ST(0))
    fistp dword [int_result]            ; Store as integer
    
    ; Explicit truncation
    fld dword [float_value]
    ; Save control word
    fstcw word [old_control]
    mov ax, [old_control]
    or ax, 0x0C00                       ; Set rounding mode to truncate
    mov [new_control], ax
    fldcw word [new_control]
    fistp dword [int_result]            ; Truncate
    fldcw word [old_control]            ; Restore rounding mode
```

### BCD (Binary Coded Decimal) Format

**Packed BCD (18 digits, 10 bytes):**

```nasm
section .data
    ; Packed BCD: sign byte + 9 bytes (2 digits each)
    bcd_value dt 123456789012345678     ; 18-digit BCD number
    
section .bss
    bcd_result rest 1                   ; 10-byte BCD storage

section .text
    ; Load BCD
    fbld tword [bcd_value]              ; Load BCD → ST(0)
    
    ; Perform calculations in floating-point
    fld1
    faddp st(1), st(0)
    
    ; Store as BCD
    fbstp tword [bcd_result]            ; Convert to BCD, store, pop
```

### Special Floating-Point Values

**Testing for special values:**

```nasm
section .text
    ; Check for zero
    fld dword [value]
    ftst                                ; Compare ST(0) with 0.0
    fstsw ax
    sahf
    jz is_zero
    
    ; Check for NaN or infinity
    fld dword [value]
    fxam                                ; Examine ST(0)
    fstsw ax
    ; C3 C2 C0 indicate type:
    ; C3=0, C2=0, C0=1: +Infinity
    ; C3=0, C2=1, C0=1: -Infinity  
    ; C3=0, C2=1, C0=0: NaN
    
    ; Check sign
    fld dword [value]
    ftst
    fstsw ax
    sahf
    js is_negative                      ; Sign flag set if negative
```

**Creating special values:**

```nasm
    ; Create infinity
    fld1
    fldz
    fdivp st(1), st(0)                  ; 1.0 / 0.0 = +Infinity
    
    ; Create NaN
    fldz
    fldz
    fdivp st(1), st(0)                  ; 0.0 / 0.0 = NaN
    
    ; Create negative zero
    fld1
    fchs                                ; ST(0) = -1.0
    fldz
    fmulp st(1), st(0)                  ; -1.0 × 0.0 = -0.0
```

