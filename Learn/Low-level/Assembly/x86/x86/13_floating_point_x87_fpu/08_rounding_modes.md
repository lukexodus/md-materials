## Rounding Modes


The FPU supports four rounding modes controlled by the RC field in the control word.

### Setting Rounding Modes

```nasm
section .bss
    ctrl_word: resw 1

section .text
    ; Round to nearest (even) - default
set_round_nearest:
    fstcw word [ctrl_word]
    and word [ctrl_word], 0xF3FF  ; Clear RC bits
    or word [ctrl_word], 0x0000   ; Set RC = 00
    fldcw word [ctrl_word]
    ret
    
    ; Round down (toward -∞)
set_round_down:
    fstcw word [ctrl_word]
    and word [ctrl_word], 0xF3FF
    or word [ctrl_word], 0x0400   ; Set RC = 01
    fldcw word [ctrl_word]
    ret
    
    ; Round up (toward +∞)
set_round_up:
    fstcw word [ctrl_word]
    and word [ctrl_word], 0xF3FF
    or word [ctrl_word], 0x0800   ; Set RC = 10
    fldcw word [ctrl_word]
    ret
    
    ; Round toward zero (truncate)
set_round_zero:
    fstcw word [ctrl_word]
    and word [ctrl_word], 0xF3FF
    or word [ctrl_word], 0x0C00   ; Set RC = 11
    fldcw word [ctrl_word]
    ret
```

### Rounding Mode Examples

**Round to Nearest (Even):**

```nasm
section .data
    test_val1: dq 2.5          ; Exactly halfway
    test_val2: dq 3.5          ; Exactly halfway
    test_val3: dq 2.3
    test_val4: dq 2.7

section .text
    call set_round_nearest
    
    fld qword [test_val1]
    frndint                    ; Result: 2.0 (rounds to even)
    
    fld qword [test_val2]
    frndint                    ; Result: 4.0 (rounds to even)
    
    fld qword [test_val3]
    frndint                    ; Result: 2.0 (closer to 2)
    
    fld qword [test_val4]
    frndint                    ; Result: 3.0 (closer to 3)
```

**Round Down (Floor):**

```nasm
section .data
    pos_val: dq 2.7
    neg_val: dq -2.3

section .text
    call set_round_down
    
    fld qword [pos_val]
    frndint                    ; Result: 2.0 (toward -∞)
    
    fld qword [neg_val]
    frndint                    ; Result: -3.0 (toward -∞)
```

**Round Up (Ceiling):**

```nasm
section .text
    call set_round_up
    
    fld qword [pos_val]
    frndint                    ; Result: 3.0 (toward +∞)
    
    fld qword [neg_val]
    frndint                    ; Result: -2.0 (toward +∞)
```

**Round Toward Zero (Truncate):**

```nasm
section .text
    call set_round_zero
    
    fld qword [pos_val]
    frndint                    ; Result: 2.0 (toward zero)
    
    fld qword [neg_val]
    frndint                    ; Result: -2.0 (toward zero)
```

### Directed Rounding for Interval Arithmetic

```nasm
section .data
    val_a: dq 1.0
    val_b: dq 3.0
    lower_bound: dq 0.0
    upper_bound: dq 0.0

section .text
    ; Compute interval [a/b, a/b] with guaranteed bounds
    
    ; Lower bound: round down
    call set_round_down
    fld qword [val_a]
    fdiv qword [val_b]
    fstp qword [lower_bound]   ; Lower = floor(a/b)
    
    ; Upper bound: round up
    call set_round_up
    fld qword [val_a]
    fdiv qword [val_b]
    fstp qword [upper_bound]   ; Upper = ceil(a/b)
    
    ; Restore default rounding
    call set_round_nearest
```

### Converting to Integer with Rounding

**FIST/FISTP - Store Integer (uses current rounding mode):**

```nasm
section .data
    float_val: dq 2.7
    int_result: dd 0

section .text
    ; Using current rounding mode
    fld qword [float_val]
    fistp dword [int_result]   ; Convert and store
    
    ; Result depends on rounding mode:
    ; Nearest: 3
    ; Down: 2
    ; Up: 3
    ; Zero: 2
```

**FISTTP - Store Integer with Truncation (SSE3):**

```nasm
section .text
    ; Always rounds toward zero, ignoring control word
    fld qword [float_val]
    fisttp dword [int_result]  ; Always truncates
    ; Result: 2 (regardless of rounding mode)
```

### Rounding Mode Preservation

```nasm
section .text
perform_special_rounding:
    ; Save current control word
    sub rsp, 4
    fstcw word [rsp]
    
    ; Change rounding mode temporarily
    call set_round_down
    
    ; Perform calculations with round-down
    fld qword [value]
    ; ... calculations ...
    
    ; Restore original control word
    fldcw word [rsp]
    add rsp, 4
    ret
```

### Comparing with Specific Rounding

```nasm
section .text
    ; Compare two values with tolerance using rounding
    fld qword [value1]
    fsub qword [value2]        ; Difference
    fabs                       ; Absolute difference
    
    fld qword [tolerance]
    fcomip st0, st1            ; Compare and pop
    fstp st0                   ; Clean stack
    
    jbe .within_tolerance      ; If |diff| <= tolerance
```

### FPU State Management

**FINIT/FNINIT - Initialize FPU:**

```nasm
section .text
    ; Initialize FPU to default state
    finit                      ; Wait for pending operations
    ; or
    fninit                     ; No wait
    
    ; Default state:
    ; - All exception masks set (exceptions masked)
    ; - Rounding: nearest
    ; - Precision: extended (64-bit)
    ; - Stack: empty
```

**FSAVE/FNSAVE - Save FPU State:**

```nasm
section .bss
    fpu_state: resb 108        ; 108 bytes for FPU state

section .text
    ; Save complete FPU state
    fsave [fpu_state]          ; Save and initialize FPU
    ; or
    fnsave [fpu_state]         ; No wait version
    
    ; State includes:
    ; - Control word
    ; - Status word
    ; - Tag word
    ; - All 8 FPU registers
```

**FRSTOR - Restore FPU State:**

```nasm
section .text
    ; Restore previously saved state
    frstor [fpu_state]
```

**FXSAVE/FXRSTOR - Extended State (SSE):**

```nasm
section .bss
    align 16
    fpu_extended_state: resb 512  ; 512 bytes aligned

section .text
    ; Save FPU + SSE state
    fxsave [fpu_extended_state]
    
    ; Restore FPU + SSE state
    fxrstor [fpu_extended_state]
```

**FCLEX/FNCLEX - Clear Exceptions:**

```nasm
section .text
    ; Clear exception flags in status word
    fclex                      ; Wait for pending operations
    ; or
    fnclex                     ; No wait
```

### Exception Handling Example

```nasm
section .data
    dividend: dq 1.0
    divisor: dq 0.0
    result: dq 0.0

section .text
    ; Unmask divide-by-zero exception
    fstcw word [ctrl_word]
    and word [ctrl_word], 0xFFFB  ; Unmask ZE bit
    fldcw word [ctrl_word]
    
    ; Attempt division
    fld qword [dividend]
    fdiv qword [divisor]       ; This will set ZE flag
    
    ; Check for exception
    fstsw ax
    test al, 0x04              ; Test ZE bit
    jnz .division_error
    
    fstp qword [result]
    jmp .done
    
.division_error:
    fstp st0                   ; Clear stack
    ; Handle error...
    
.done:
    ; Restore exception masking
    fstcw word [ctrl_word]
    or word [ctrl_word], 0x0004
    fldcw word [ctrl_word]
```

**Key Points:**

- x87 FPU uses 80-bit extended precision internally for intermediate calculations
- Stack-based architecture requires careful management of register stack (TOP pointer)
- Transcendental functions (FSIN, FCOS, FPTAN, FPATAN, F2XM1, FYL2X) provide hardware acceleration
- Control word configures precision (24/53/64 bits), rounding mode, and exception masks
- Four rounding modes: nearest (even), down (floor), up (ceiling), toward zero (truncate)
- Status word provides condition codes for comparisons and exception flags
- **[Inference]** Modern compilers often prefer SSE2 scalar operations over x87 for better performance and predictability
- FXSAVE/FXRSTOR should be used when preserving both FPU and SSE state

**Important subtopics:**

- SSE/AVX floating-point operations as modern alternatives to x87
- Denormal numbers and their performance implications
- IEEE 754 compliance and edge cases (NaN propagation, signed zeros, infinity handling)
- Numerical stability techniques and error accumulation in iterative algorithms

---

