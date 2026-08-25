## x87 FPU Architecture


### Overview

The x87 Floating-Point Unit (FPU) is a coprocessor integrated into x86 processors since the Intel 80486. It provides hardware support for floating-point arithmetic using an IEEE 754-compatible format.

**Key architectural features:**

- Separate register stack (8 registers, each 80 bits)
- Independent instruction set with FP prefix
- Stack-based operation model
- Support for transcendental functions (sine, cosine, logarithm, etc.)
- Multiple precision modes and rounding modes
- Exception handling for floating-point errors

**FPU Data Path:**

```
Memory ←→ FPU Registers (ST(0)-ST(7)) ←→ ALU
              ↓
         Control/Status Registers
```

### FPU Control Word

The FPU Control Word configures FPU operation modes:

**16-bit Control Word format:**

```
Bit 15-12: Reserved
Bit 11-10: Rounding Control (RC)
           00 = Round to nearest (even)
           01 = Round down (toward -∞)
           10 = Round up (toward +∞)
           11 = Round toward zero (truncate)
Bit 9-8:   Precision Control (PC)
           00 = Single precision (24 bits)
           01 = Reserved
           10 = Double precision (53 bits)
           11 = Extended precision (64 bits)
Bit 7-6:   Reserved
Bit 5:     Precision exception mask (PM)
Bit 4:     Underflow exception mask (UM)
Bit 3:     Overflow exception mask (OM)
Bit 2:     Zero divide exception mask (ZM)
Bit 1:     Denormalized operand exception mask (DM)
Bit 0:     Invalid operation exception mask (IM)
```

**Loading and storing control word:**

```nasm
section .data
    fpu_control dw 0x037F               ; Default: all exceptions masked, round to nearest, extended precision

section .text
    fldcw word [fpu_control]            ; Load control word
    fstcw word [fpu_control]            ; Store control word
    
    ; Modify rounding mode to round down
    fstcw word [fpu_control]
    or word [fpu_control], 0x0400       ; Set RC bits to 01
    fldcw word [fpu_control]
```

### FPU Status Word

The FPU Status Word reports current FPU state:

**16-bit Status Word format:**

```
Bit 15:    Busy (B)
Bit 14:    Condition Code C3
Bit 13-11: Stack Top Pointer (TOP) - points to ST(0)
Bit 10:    Condition Code C2
Bit 9:     Condition Code C1
Bit 8:     Condition Code C0
Bit 7:     Exception Summary (ES)
Bit 6:     Stack Fault (SF)
Bit 5:     Precision exception (PE)
Bit 4:     Underflow exception (UE)
Bit 3:     Overflow exception (OE)
Bit 2:     Zero divide exception (ZE)
Bit 1:     Denormalized operand exception (DE)
Bit 0:     Invalid operation exception (IE)
```

**Reading status word:**

```nasm
section .bss
    fpu_status resw 1

section .text
    fstsw word [fpu_status]             ; Store status word to memory
    fstsw ax                            ; Store status word to AX (faster)
    
    ; Check for exceptions
    fstsw ax
    test ax, 0x3F                       ; Test exception bits
    jnz fpu_exception_occurred
    
    ; Check condition codes
    fstsw ax
    sahf                                ; Transfer C0, C2, C3 to CPU flags
    je equal                            ; Use CPU conditional jumps
```

### FPU Tag Word

The Tag Word tracks the content type of each FPU register:

**16-bit Tag Word format:**

```
Bits 15-14: Tag for ST(7)
Bits 13-12: Tag for ST(6)
...
Bits 1-0:   Tag for ST(0)

Tag values:
00 = Valid (normal floating-point value)
01 = Zero
10 = Special (NaN, infinity, denormal)
11 = Empty
```

**Accessing tag word:**

```nasm
section .bss
    fpu_tag resw 1

section .text
    ; Store environment (control, status, tag words)
    fstenv [fpu_env]                    ; Store 14-byte environment
    
    ; Save complete FPU state
    fsave [fpu_state]                   ; Save 108-byte state (deprecated)
    fxsave [fpu_state]                  ; Save 512-byte extended state (modern)
```

### FPU Initialization

**Initialize FPU to known state:**

```nasm
    finit                               ; Initialize FPU (wait for completion)
    fninit                              ; Initialize FPU (no wait)
    
    ; After FINIT:
    ; - Control Word = 0x037F (all exceptions masked, round to nearest, extended precision)
    ; - Status Word = 0x0000 (stack empty, TOP = 0)
    ; - Tag Word = 0xFFFF (all registers empty)
    ; - All registers marked as empty
```

**Check FPU presence:**

```nasm
    ; Set control word to known value
    fninit
    mov word [test_value], 0x5A5A
    fnstsw word [test_value]
    cmp word [test_value], 0x0000       ; FINIT sets status to 0
    jne no_fpu_present
```

