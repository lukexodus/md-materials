## Overflow Handling


Overflow in multiplication and division can cause program errors or unexpected results. Proper detection and handling are crucial.

### Multiplication Overflow Detection

**Example (detecting unsigned multiplication overflow with MUL):**

```nasm
section .text
checked_multiply_32:
    mov eax, [operand1]
    mul dword [operand2]     ; EDX:EAX = result
    
    ; Check carry flag or overflow flag
    jc multiplication_overflow
    ; Alternatively: jo multiplication_overflow
    
    ; Check if high dword is zero
    test edx, edx
    jnz multiplication_overflow
    
    ; Result fits in 32 bits
    mov [result], eax
    xor eax, eax         ; Return 0 (success)
    ret
    
multiplication_overflow:
    mov eax, 1           ; Return 1 (overflow)
    ret
```

**Example (detecting signed multiplication overflow with IMUL):**

```nasm
section .text
checked_signed_multiply:
    mov eax, [signed_op1]
    imul dword [signed_op2]  ; EDX:EAX = result
    
    jo signed_overflow   ; OF set if result doesn't fit
    
    ; No overflow, result in EAX
    mov [result], eax
    xor eax, eax
    ret
    
signed_overflow:
    mov eax, 1
    ret
```

**Example (two-operand IMUL overflow detection):**

```nasm
section .text
multiply_with_overflow_check:
    mov eax, [value1]
    imul eax, [value2]   ; Result in EAX only
    
    jo overflow_detected ; OF set if truncation occurred
    
    ; Result valid
    mov [result], eax
    clc                  ; Clear carry (success)
    ret
    
overflow_detected:
    stc                  ; Set carry (error)
    ret
```

**Example (pre-checking multiplication bounds):**

```nasm
section .text
; Check if a × b will overflow 32-bit unsigned
check_multiply_overflow:
    mov eax, [operand_a]
    mov ebx, [operand_b]
    
    ; If a == 0 or b == 0, no overflow
    test eax, eax
    jz no_overflow
    test ebx, ebx
    jz no_overflow
    
    ; Check if b > (2^32 - 1) / a
    xor edx, edx
    mov ecx, 0xFFFFFFFF  ; Maximum 32-bit value
    div ebx              ; EAX = MAX / b
    
    cmp eax, [operand_a]
    jb will_overflow     ; If MAX/b < a, overflow will occur
    
no_overflow:
    xor eax, eax         ; Return 0 (no overflow)
    ret
    
will_overflow:
    mov eax, 1           ; Return 1 (will overflow)
    ret
```

**Example (saturating multiplication):**

```nasm
section .text
; Multiply with saturation: result clamped to MAX if overflow
saturating_multiply_32:
    mov eax, [operand1]
    mul dword [operand2]
    
    jnc no_saturation    ; No carry, no overflow
    
    ; Overflow occurred, saturate to maximum
    mov eax, 0xFFFFFFFF
    jmp done
    
no_saturation:
    ; Check high dword
    test edx, edx
    jz done
    
    ; High part non-zero, saturate
    mov eax, 0xFFFFFFFF
    
done:
    mov [result], eax
    ret
```

### Division Overflow and Error Handling

**Example (division overflow - quotient too large):**

```nasm
section .text
; Division can overflow if quotient doesn't fit in destination register
check_division_overflow:
    mov edx, [high_dividend]
    mov eax, [low_dividend]
    mov ebx, [divisor]
    
    ; Check if divisor is zero
    test ebx, ebx
    jz division_error
    
    ; Check if quotient will fit in 32 bits
    ; For EDX:EAX ÷ EBX, quotient overflows if EDX >= EBX
    cmp edx, ebx
    jae quotient_overflow
    
    div ebx
    ; Success
    mov [quotient], eax
    mov [remainder], edx
    xor eax, eax         ; Return success
    ret
    
division_error:
quotient_overflow:
    mov eax, 1           ; Return error
    ret
```

**Example (safe division wrapper):**

```nasm
section .text
; Safe division that handles all error cases
safe_divide_32:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp+8]     ; Dividend
    mov ebx, [ebp+12]    ; Divisor
    
    ; Check for division by zero
    test ebx, ebx
    jz div_error
    
    ; Prepare for division
    xor edx, edx         ; Clear high dword
    
    ; Check for overflow: EDX >= divisor
    cmp edx, ebx
    jae div_error
    
    div ebx
    ; EAX = quotient, EDX = remainder
    clc                  ; Clear carry (success)
    pop ebp
    ret
    
div_error:
    xor eax, eax
    xor edx, edx
    stc                  ; Set carry (error)
    pop ebp
    ret
```

**Example (handling division exceptions with exception handlers):**

```nasm
; [Inference: Division exceptions (#DE) can be caught with exception handlers
; in protected mode, but this requires OS-level or interrupt handling setup]

section .text
; Simplified concept - actual implementation requires IDT setup
divide_with_exception_handling:
    ; In real systems, this would involve setting up exception handler
    ; For demonstration: inline check
    
    mov eax, [dividend]
    mov ebx, [divisor]
    
    ; Manual checks to avoid exception
    test ebx, ebx
    jz handle_div_by_zero
    
    ; For IDIV, check range
    cdq
    ; Check if EDX:EAX / EBX will fit in EAX
    ; This is complex, simplified here
    
    idiv ebx
    jmp success
    
handle_div_by_zero:
    ; Handle error
    mov eax, -1
    jmp done
    
success:
    ; EAX contains quotient
    
done:
    ret
```

