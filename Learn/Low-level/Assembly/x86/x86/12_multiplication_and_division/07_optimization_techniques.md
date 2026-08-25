## Optimization Techniques


### Strength Reduction

Replacing expensive operations with cheaper equivalents.

**Example (multiply by constant using LEA):**

```nasm
section .text
; Multiply by 3 using LEA
multiply_by_3:
    mov eax, [value]
    lea eax, [eax + eax*2]   ; EAX = EAX + EAX×2 = 3×EAX
    ret

; Multiply by 5
multiply_by_5:
    mov eax, [value]
    lea eax, [eax + eax*4]   ; EAX = EAX + EAX×4 = 5×EAX
    ret

; Multiply by 9
multiply_by_9:
    mov eax, [value]
    lea eax, [eax + eax*8]   ; EAX = EAX + EAX×8 = 9×EAX
    ret
```

**Example (multiply by composite constants):**

```nasm
section .text
; Multiply by 10: x×10 = (x×2)×5 = (x + x×4)×2
multiply_by_10:
    mov eax, [value]
    lea eax, [eax + eax*4]   ; EAX × 5
    shl eax, 1               ; (EAX×5) × 2 = EAX×10
    ret

; Multiply by 12: x×12 = (x×3)×4
multiply_by_12:
    mov eax, [value]
    lea eax, [eax + eax*2]   ; EAX × 3
    shl eax, 2               ; (EAX×3) × 4 = EAX×12
    ret

; Multiply by 15: x×15 = x×16 - x
multiply_by_15:
    mov eax, [value]
    mov ebx, eax
    shl eax, 4               ; EAX × 16
    sub eax, ebx             ; EAX×16 - EAX = EAX×15
    ret
```

**Example (multiply by 7 using shifts and adds):**

```nasm
section .text
multiply_by_7:
    mov eax, [value]
    mov ebx, eax
    shl eax, 3               ; EAX × 8
    sub eax, ebx             ; EAX×8 - EAX = EAX×7
    ret
```

**Example (divide by constant using multiplication):**

```nasm
section .text
; Divide by 3 using multiplication by magic number
; For unsigned 32-bit: x/3 ≈ (x × 0xAAAAAAAB) >> 33
divide_by_3:
    mov eax, [value]
    mov edx, 0xAAAAAAAB      ; Magic number for division by 3
    mul edx                  ; EDX:EAX = value × magic
    shr edx, 1               ; Quotient in EDX after shift
    mov eax, edx
    ret

; Divide by 5
; x/5 ≈ (x × 0xCCCCCCCD) >> 34
divide_by_5:
    mov eax, [value]
    mov edx, 0xCCCCCCCD
    mul edx
    shr edx, 2               ; Quotient
    mov eax, edx
    ret
```

**Example (divide by 10 using magic multiplication):**

```nasm
section .text
; Divide by 10 using multiplication
; x/10 ≈ (x × 0xCCCCCCCD) >> 35
divide_by_10:
    mov eax, [value]
    mov edx, 0xCCCCCCCD      ; Magic number
    mul edx                   ; EDX:EAX = value × 0xCCCCCCCD
    shr edx, 3                ; Shift right 35 bits = shift EDX right 3
    mov eax, edx              ; Quotient in EAX
    ret
```

### Loop Unrolling for Multiplication

**Example (computing polynomial using Horner's method):**

```nasm
section .text
; Evaluate: result = a×x³ + b×x² + c×x + d
; Using Horner's method: ((a×x + b)×x + c)×x + d
evaluate_polynomial:
    mov eax, [coeff_a]
    imul eax, [x]            ; a×x
    add eax, [coeff_b]       ; a×x + b
    imul eax, [x]            ; (a×x + b)×x
    add eax, [coeff_c]       ; (a×x + b)×x + c
    imul eax, [x]            ; ((a×x + b)×x + c)×x
    add eax, [coeff_d]       ; Final result
    ret
```

**Example (array multiplication unrolled):**

```nasm
section .data
    array1 dd 10, 20, 30, 40, 50, 60, 70, 80
    array2 dd 2, 3, 4, 5, 6, 7, 8, 9
    
section .bss
    result resd 8
    
section .text
multiply_arrays_unrolled:
    ; Multiply 8 elements without loop
    mov eax, [array1]
    imul eax, [array2]
    mov [result], eax
    
    mov eax, [array1+4]
    imul eax, [array2+4]
    mov [result+4], eax
    
    mov eax, [array1+8]
    imul eax, [array2+8]
    mov [result+8], eax
    
    mov eax, [array1+12]
    imul eax, [array2+12]
    mov [result+12], eax
    
    mov eax, [array1+16]
    imul eax, [array2+16]
    mov [result+16], eax
    
    mov eax, [array1+20]
    imul eax, [array2+20]
    mov [result+20], eax
    
    mov eax, [array1+24]
    imul eax, [array2+24]
    mov [result+24], eax
    
    mov eax, [array1+28]
    imul eax, [array2+28]
    mov [result+28], eax
    ret
```

### Reciprocal Multiplication

**Example (division using reciprocal for repeated divisions):**

```nasm
section .data
    divisor dd 7
    reciprocal dq 0          ; Will store precomputed reciprocal
    
section .text
; Precompute reciprocal: reciprocal = 2^64 / divisor
precompute_reciprocal:
    xor edx, edx
    mov eax, 1
    shl eax, 32              ; This is conceptual; actual implementation differs
    ; [Inference: Actual reciprocal calculation is complex]
    ; For 64-bit: reciprocal ≈ 2^64 / divisor
    ret

; Use reciprocal for fast division
fast_divide_using_reciprocal:
    mov eax, [dividend]
    ; Multiply by reciprocal and shift
    ; result = (dividend × reciprocal) >> 64
    ; Simplified representation
    ret
```

### SIMD Multiplication

**Example (parallel multiplication using SSE):**

```nasm
section .data
    align 16
    vec1 dd 10, 20, 30, 40           ; Four 32-bit integers
    vec2 dd 2, 3, 4, 5
    
section .bss
    align 16
    result_vec resd 4
    
section .text
simd_multiply:
    movdqa xmm0, [vec1]      ; Load 4 integers into XMM0
    movdqa xmm1, [vec2]      ; Load 4 integers into XMM1
    
    ; SSE2 doesn't have 32-bit integer multiply directly
    ; Use SSE4.1 PMULLD or emulate
    
    ; With SSE4.1:
    pmulld xmm0, xmm1        ; Multiply four pairs in parallel
    
    movdqa [result_vec], xmm0 ; Store results
    ret
```

**Example (parallel multiplication with SSE2 emulation):**

```nasm
section .text
simd_multiply_sse2:
    movdqa xmm0, [vec1]
    movdqa xmm1, [vec2]
    
    ; SSE2: multiply low 16 bits
    movdqa xmm2, xmm0
    movdqa xmm3, xmm1
    pmuludq xmm2, xmm3       ; Multiply elements 0 and 2
    
    ; Shuffle and multiply high pairs
    psrlq xmm0, 32
    psrlq xmm1, 32
    pmuludq xmm0, xmm1       ; Multiply elements 1 and 3
    
    ; Combine results (simplified)
    ret
```

### Avoiding Division

**Example (checking divisibility without division):**

```nasm
section .text
; Check if number is divisible by 3 using sum of digits
is_divisible_by_3:
    mov eax, [number]
    xor ebx, ebx             ; Sum of digits
    
sum_digits:
    test eax, eax
    jz check_sum
    
    xor edx, edx
    mov ecx, 10
    div ecx                  ; EDX = digit, EAX = remaining
    add ebx, edx             ; Add digit to sum
    jmp sum_digits
    
check_sum:
    ; A number is divisible by 3 if sum of digits is divisible by 3
    mov eax, ebx
    xor edx, edx
    mov ecx, 3
    div ecx
    
    test edx, edx            ; Check remainder
    jz divisible
    
    xor eax, eax             ; Not divisible
    ret
    
divisible:
    mov eax, 1
    ret
```

**Example (checking divisibility by 2^n using bitwise AND):**

```nasm
section .text
; Check if divisible by 8 (2^3)
is_divisible_by_8:
    mov eax, [number]
    and eax, 7               ; Check last 3 bits
    test eax, eax
    jz divisible_by_8
    
    xor eax, eax
    ret
    
divisible_by_8:
    mov eax, 1
    ret
```

### Karatsuba Multiplication

**Example (64-bit multiplication using 32-bit operations - Karatsuba concept):**

```nasm
section .text
; Multiply two 64-bit numbers using Karatsuba algorithm
; x = x1*2^32 + x0, y = y1*2^32 + y0
; x*y = (x1*y1)*2^64 + ((x1+x0)*(y1+y0) - x1*y1 - x0*y0)*2^32 + x0*y0
karatsuba_64bit:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    ; Load 64-bit operands (low and high dwords)
    mov eax, [ebp+8]         ; x0 (low)
    mov edx, [ebp+12]        ; x1 (high)
    mov ebx, [ebp+16]        ; y0 (low)
    mov ecx, [ebp+20]        ; y1 (high)
    
    ; Compute x0 * y0
    push eax
    mul ebx                  ; EDX:EAX = x0 * y0
    mov esi, eax             ; Save low part
    mov edi, edx             ; Save high part
    pop eax
    
    ; Compute x1 * y1
    push edx
    mov eax, [ebp+12]        ; x1
    mul ecx                  ; EDX:EAX = x1 * y1
    mov [ebp-16], eax        ; Store z2_low
    mov [ebp-20], edx        ; Store z2_high
    pop edx
    
    ; Compute (x1 + x0) * (y1 + y0)
    mov eax, [ebp+8]         ; x0
    add eax, [ebp+12]        ; x0 + x1
    mov ebx, [ebp+16]        ; y0
    add ebx, [ebp+20]        ; y0 + y1
    mul ebx                  ; EDX:EAX = (x0+x1)*(y0+y1)
    
    ; Subtract x0*y0 and x1*y1 (middle term)
    sub eax, esi
    sbb edx, edi
    sub eax, [ebp-16]
    sbb edx, [ebp-20]
    
    ; Combine results (simplified - full implementation more complex)
    ; Result would be in multiple registers
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
```

### Conditional Multiplication

**Example (multiply only if condition met, avoiding branch):**

```nasm
section .text
conditional_multiply_branchless:
    mov eax, [value]
    mov ebx, [multiplier]
    mov ecx, [condition]     ; 0 or 1
    
    ; Branchless: result = condition ? (value × multiplier) : value
    imul ebx, eax            ; EBX = value × multiplier
    dec ecx                  ; ECX = -1 if condition was 1, -1 if 0
    
    ; Create mask: 0xFFFFFFFF if condition, 0 if not
    and ebx, ecx             ; Zero out EBX if condition was 0
    not ecx
    and eax, ecx             ; Zero out EAX if condition was 1
    
    or eax, ebx              ; Combine results
    ret
```

