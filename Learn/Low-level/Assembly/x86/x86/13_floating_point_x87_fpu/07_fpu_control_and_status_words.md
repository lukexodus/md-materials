## FPU Control and Status Words


### FPU Status Word (FSW)

The FPU status word contains flags indicating the FPU's current state and condition codes.

**Status Word Bit Layout:**

```
Bit 15: B (Busy)
Bit 14: C3 (Condition Code 3)
Bit 13-11: TOP (Stack Top Pointer, 000-111)
Bit 10: C2 (Condition Code 2)
Bit 9: C1 (Condition Code 1)
Bit 8: C0 (Condition Code 0)
Bit 7: ES (Error Summary)
Bit 6: SF (Stack Fault)
Bit 5: PE (Precision Exception)
Bit 4: UE (Underflow Exception)
Bit 3: OE (Overflow Exception)
Bit 2: ZE (Zero Divide Exception)
Bit 1: DE (Denormalized Operand Exception)
Bit 0: IE (Invalid Operation Exception)
```

**Reading Status Word:**

```nasm
section .bss
    status_word: resw 1

section .text
    ; Method 1: Store to memory
    fstsw word [status_word]   ; Store status word
    mov ax, [status_word]
    
    ; Method 2: Store directly to AX (486+)
    fstsw ax                   ; Faster, directly to AX
    
    ; Check for exceptions
    test ax, 0x003F            ; Test exception bits (0-5)
    jnz .exception_occurred
    
    ; Check specific exceptions
    test ax, 0x0001            ; Invalid operation
    jnz .invalid_operation
    
    test ax, 0x0004            ; Zero divide
    jnz .zero_divide
    
    test ax, 0x0008            ; Overflow
    jnz .overflow
```

**Condition Codes (C0-C3):**

```nasm
section .text
    ; FCOM sets condition codes based on comparison
    fld qword [value1]
    fcom qword [value2]        ; Compare ST(0) with value2
    fstsw ax                   ; Get status
    sahf                       ; Store AH to CPU flags
    
    ; Now can use standard conditional jumps
    ja .value1_greater         ; ST(0) > value2
    jb .value1_less            ; ST(0) < value2
    je .values_equal           ; ST(0) == value2
    jp .unordered              ; NaN encountered
    
    ; Alternative: Check condition codes directly
    fld qword [value1]
    fcom qword [value2]
    fstsw ax
    
    ; Check C0, C2, C3 for comparison result
    ; C3 C2 C0
    ; 0  0  0  = ST(0) > value2
    ; 0  0  1  = ST(0) < value2
    ; 1  0  0  = ST(0) = value2
    ; 1  1  1  = Unordered (NaN)
    
    and ah, 0x45               ; Isolate C0, C2, C3
    cmp ah, 0x40               ; Check for equality
    je .equal
```

**TOP (Stack Top Pointer):**

```nasm
section .text
    ; Extract TOP field
    fstsw ax
    and ah, 0x38               ; Isolate bits 11-13
    shr ah, 3                  ; Shift to get TOP value (0-7)
    ; AH now contains stack top pointer
```

### FPU Control Word (FCW)

The control word configures FPU operation including precision, rounding mode, and exception masks.

**Control Word Bit Layout:**

```
Bit 15-13: Reserved
Bit 12: IC (Infinity Control) - deprecated
Bit 11-10: RC (Rounding Control)
           00 = Round to nearest (even)
           01 = Round down (toward -∞)
           10 = Round up (toward +∞)
           11 = Round toward zero (truncate)
Bit 9-8: PC (Precision Control)
         00 = Single precision (24 bits)
         01 = Reserved
         10 = Double precision (53 bits)
         11 = Extended precision (64 bits)
Bit 7-6: Reserved
Bit 5: PM (Precision Mask)
Bit 4: UM (Underflow Mask)
Bit 3: OM (Overflow Mask)
Bit 2: ZM (Zero Divide Mask)
Bit 1: DM (Denormal Operand Mask)
Bit 0: IM (Invalid Operation Mask)
```

**Reading and Modifying Control Word:**

```nasm
section .bss
    control_word: resw 1
    new_control: resw 1

section .text
    ; Read control word
    fstcw word [control_word]
    
    ; Modify control word
    mov ax, [control_word]
    or ax, 0x003F              ; Mask all exceptions
    mov [new_control], ax
    fldcw word [new_control]   ; Load new control word
```

**Exception Masking:**

```nasm
section .text
    ; Mask all exceptions (default)
    fstcw word [control_word]
    or word [control_word], 0x003F
    fldcw word [control_word]
    
    ; Unmask specific exceptions for debugging
    fstcw word [control_word]
    and word [control_word], 0xFFFE  ; Unmask invalid operation
    fldcw word [control_word]
    
    ; Now invalid operations will raise exceptions
```

### Precision Control

```nasm
section .text
    ; Set single precision (24-bit mantissa)
    fstcw word [control_word]
    and word [control_word], 0xFCFF  ; Clear PC bits
    or word [control_word], 0x0000   ; Set to 00 (single)
    fldcw word [control_word]
    
    ; Set double precision (53-bit mantissa)
    fstcw word [control_word]
    and word [control_word], 0xFCFF
    or word [control_word], 0x0200   ; Set to 10 (double)
    fldcw word [control_word]
    
    ; Set extended precision (64-bit mantissa, default)
    fstcw word [control_word]
    and word [control_word], 0xFCFF
    or word [control_word], 0x0300   ; Set to 11 (extended)
    fldcw word [control_word]
```

