## Extended Precision Arithmetic


Extended precision arithmetic allows operations on numbers larger than the native register size by treating multiple registers as a single multi-word value.

### Multi-Precision Addition

```assembly
; Add two 64-bit numbers on 32-bit system
; number1 = high1:low1, number2 = high2:low2

section .data
    num1_low  dd 0xFFFFFFFF
    num1_high dd 0x00000005     ; num1 = 0x5FFFFFFFF
    num2_low  dd 0x00000002
    num2_high dd 0x00000003     ; num2 = 0x300000002

section .bss
    result_low  resd 1
    result_high resd 1

section .text
    ; Add low parts
    mov eax, [num1_low]
    add eax, [num2_low]         ; Add low dwords, sets CF if overflow
    mov [result_low], eax
    
    ; Add high parts with carry
    mov eax, [num1_high]
    adc eax, [num2_high]        ; Add high dwords + carry flag
    mov [result_high], eax
    
    ; result = 0x900000001
```

### Multi-Precision Subtraction

```assembly
; Subtract 64-bit numbers: result = num1 - num2

section .text
    ; Subtract low parts
    mov eax, [num1_low]
    sub eax, [num2_low]         ; Subtract low dwords, sets CF if borrow
    mov [result_low], eax
    
    ; Subtract high parts with borrow
    mov eax, [num1_high]
    sbb eax, [num2_high]        ; Subtract high dwords - borrow flag
    mov [result_high], eax
```

### Multi-Precision Multiplication

**64-bit × 64-bit = 128-bit Multiplication (32-bit system):**

```assembly
; Multiply two 64-bit numbers
; num1 = A:B (A=high, B=low)
; num2 = C:D (C=high, D=low)
; result = (A:B) × (C:D)
;        = (A×C)×2⁶⁴ + (A×D)×2³² + (B×C)×2³² + (B×D)
; Result needs 128 bits (4 dwords)

multiply_64x64:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    ; Load operands
    ; [ebp+8]  = num1_low (B)
    ; [ebp+12] = num1_high (A)
    ; [ebp+16] = num2_low (D)
    ; [ebp+20] = num2_high (C)
    ; [ebp+24] = result pointer (4 dwords)
    
    mov edi, [ebp+24]       ; Result pointer
    
    ; B × D (lowest 64 bits)
    mov eax, [ebp+8]        ; B
    mul dword [ebp+16]      ; B × D
    mov [edi], eax          ; Store bits 0-31
    mov ebx, edx            ; Save bits 32-63 in EBX
    
    ; A × D (middle bits)
    mov eax, [ebp+12]       ; A
    mul dword [ebp+16]      ; A × D
    add ebx, eax            ; Add to middle
    adc edx, 0              ; Propagate carry
    mov esi, edx            ; Save high part
    
    ; B × C (middle bits)
    mov eax, [ebp+8]        ; B
    mul dword [ebp+20]      ; B × C
    add ebx, eax            ; Add to middle
    adc esi, edx            ; Add high part with carry
    adc dword [edi+12], 0   ; Propagate carry to highest dword
    
    mov [edi+4], ebx        ; Store bits 32-63
    
    ; A × C (highest 64 bits)
    mov eax, [ebp+12]       ; A
    mul dword [ebp+20]      ; A × C
    add eax, esi            ; Add accumulated middle high
    adc edx, 0
    mov [edi+8], eax        ; Store bits 64-95
    mov [edi+12], edx       ; Store bits 96-127
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
```

**Example - Simplified 64×32→96 bit:**

```assembly
; Multiply 64-bit by 32-bit: (A:B) × C
; Result fits in 96 bits (3 dwords)

section .data
    num64_low  dd 0x12345678
    num64_high dd 0x00000002    ; num64 = 0x212345678
    num32      dd 100

section .bss
    result resd 3               ; 96-bit result

section .text
multiply_64_32:
    ; B × C
    mov eax, [num64_low]
    mul dword [num32]
    mov [result], eax           ; Low 32 bits
    mov ebx, edx                ; Save high 32 bits
    
    ; A × C
    mov eax, [num64_high]
    mul dword [num32]
    add eax, ebx                ; Add previous high part
    adc edx, 0                  ; Propagate carry
    mov [result+4], eax         ; Middle 32 bits
    mov [result+8], edx         ; High 32 bits
```

### Multi-Precision Division

**64-bit ÷ 32-bit = 32-bit Quotient:**

```assembly
; Divide 64-bit dividend by 32-bit divisor
; dividend = high:low (EDX:EAX)
; divisor in EBX
; Returns: EAX = quotient, EDX = remainder

divide_64_32:
    ; dividend already in EDX:EAX
    div ebx                     ; EAX = quotient, EDX = remainder
    ret

; Usage:
mov eax, 0x00000000         ; Low 32 bits of dividend
mov edx, 0x00000001         ; High 32 bits (dividend = 0x100000000)
mov ebx, 0x10000            ; Divisor = 65536
call divide_64_32
; EAX = 0x10000 (quotient = 65536)
; EDX = 0 (remainder = 0)
```

**128-bit ÷ 64-bit = 64-bit Quotient (32-bit system):**

This is complex and requires iterative algorithms or specialized routines:

```assembly
; divide_128_64(dividend_ptr, divisor_ptr, quotient_ptr)
; dividend: d3:d2:d1:d0 (dword offsets 0,4,8,12) — high dwords at +8,+12
; divisor:  v1:v0 (dword offsets 0,4) — low dword at +0, high dword at +4
; quotient: 64-bit result at [quotient_ptr] (low dword at +0, high dword at +4)
; On divide-by-zero: quotient = 0xFFFFFFFFFFFFFFFF

divide_128_64:
    push    ebp
    mov     ebp, esp
    push    ebx
    push    esi
    push    edi

    ; Get pointers to operands
    mov     esi, [ebp+8]     ; esi = dividend pointer
    mov     edi, [ebp+12]    ; edi = divisor pointer
    mov     ebx, [ebp+16]    ; ebx = quotient pointer

    ; Initialize quotient to 0
    mov     dword [ebx], 0
    mov     dword [ebx+4], 0

    ; Check for division by zero: OR low and high dwords of divisor into eax
    mov     eax, [edi]       ; eax = v0
    or      eax, [edi+4]     ; eax |= v1
    jz      .div_by_zero

    ; Iterative division algorithm (bit-by-bit)
    mov     ecx, 128         ; iterate 128 times (for 128 dividend bits)

.divide_loop:
    ; Shift dividend left by 1: d0,d1,d2,d3 << 1 (d0 is lowest)
    shl     dword [esi], 1
    rcl     dword [esi+4], 1
    rcl     dword [esi+8], 1
    rcl     dword [esi+12], 1

    ; Shift quotient left by 1 (maintain 64-bit quotient at [ebx]+[ebx+4])
    shl     dword [ebx], 1
    rcl     dword [ebx+4], 1

    ; Compare high 64 bits of dividend (d2:d3 at esi+8,esi+12) with divisor (v0:v1 at edi,edi+4)
    mov     eax, [esi+8]     ; low dword of high-64
    mov     edx, [esi+12]    ; high dword of high-64
    cmp     edx, [edi+4]
    ja      .subtract
    jb      .next_bit
    cmp     eax, [edi]
    jb      .next_bit

.subtract:
    ; Subtract divisor from high 64 bits of dividend
    mov     eax, [esi+8]
    sub     eax, [edi]
    mov     [esi+8], eax

    mov     eax, [esi+12]
    sbb     eax, [edi+4]
    mov     [esi+12], eax

    ; Set low bit of quotient
    or      dword [ebx], 1

.next_bit:
    dec     ecx
    jnz     .divide_loop

    ; Remainder ends up in high 64 bits of dividend (esi+8, esi+12)
    jmp     .done

.div_by_zero:
    ; Indicate division-by-zero error by setting quotient to all 1s
    mov     dword [ebx], 0xFFFFFFFF
    mov     dword [ebx+4], 0xFFFFFFFF

.done:
    pop     edi
    pop     esi
    pop     ebx
    pop     ebp
    ret

````

**Practical Example - 96-bit ÷ 32-bit:**

```assembly
; Divide 96-bit number by 32-bit divisor
; More practical than 128-bit division

divide_96_32:
    push ebp
    mov ebp, esp
    push ebx
    
    ; [ebp+8]  = dividend pointer (3 dwords)
    ; [ebp+12] = divisor (32-bit)
    ; [ebp+16] = quotient pointer (3 dwords)
    
    mov esi, [ebp+8]        ; Dividend
    mov ebx, [ebp+12]       ; Divisor
    mov edi, [ebp+16]       ; Quotient
    
    ; Divide high dword first
    mov eax, [esi+8]        ; Highest dword
    xor edx, edx
    div ebx                 ; EDX:EAX ÷ EBX
    mov [edi+8], eax        ; Store high quotient
    
    ; Divide middle dword (with remainder from previous)
    mov eax, [esi+4]
    ; EDX already contains remainder from previous division
    div ebx
    mov [edi+4], eax
    
    ; Divide low dword (with remainder from previous)
    mov eax, [esi]
    ; EDX already contains remainder
    div ebx
    mov [edi], eax
    
    ; EDX contains final remainder
    
    pop ebx
    pop ebp
    ret

; Example:
section .data
    dividend96 dd 0x12345678, 0xABCDEF00, 0x00000001
    divisor32 dd 0x1000

section .bss
    quotient96 resd 3

section .text
    push quotient96
    push dword [divisor32]
    push dividend96
    call divide_96_32
    add esp, 12
````

### Extended Precision Comparison

```assembly
; Compare two 64-bit numbers: compare num1 with num2
; Returns: ZF=1 if equal, CF=1 if num1 < num2

compare_64bit:
    push ebp
    mov ebp, esp
    
    ; [ebp+8]  = num1_low
    ; [ebp+12] = num1_high
    ; [ebp+16] = num2_low
    ; [ebp+20] = num2_high
    
    ; Compare high parts first
    mov eax, [ebp+12]
    cmp eax, [ebp+20]
    jne .done               ; Different high parts, flags are set
    
    ; High parts equal, compare low parts
    mov eax, [ebp+8]
    cmp eax, [ebp+16]
    
.done:
    pop ebp
    ret

; Usage:
push num2_high
push num2_low
push num1_high
push num1_low
call compare_64bit
add esp, 16

je numbers_equal
jb num1_less_than_num2
ja num1_greater_than_num2
```

### Extended Precision Shift Operations

**64-bit Left Shift:**

```assembly
; Shift 64-bit value left by count bits
; value = high:low

shift_left_64:
    push ebp
    mov ebp, esp
    push ebx
    
    mov eax, [ebp+8]        ; Low dword
    mov edx, [ebp+12]       ; High dword
    mov cl, [ebp+16]        ; Shift count
    
    cmp cl, 32
    jae .shift_32_or_more
    
    ; Shift less than 32 bits
    shld edx, eax, cl       ; Shift high, bring in bits from low
    shl eax, cl             ; Shift low
    jmp .done
    
.shift_32_or_more:
    ; Shift 32 or more bits
    sub cl, 32
    mov edx, eax            ; Low becomes high
    shl edx, cl             ; Shift remaining
    xor eax, eax            ; Low becomes 0
    
.done:
    ; Result in EDX:EAX
    pop ebx
    pop ebp
    ret

; Example: shift 0x0000000100000005 left by 4
; Result: 0x0000001000000050
```

**64-bit Right Shift (Logical):**

```assembly
; Logical right shift of 64-bit value
shift_right_64:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp+8]        ; Low dword
    mov edx, [ebp+12]       ; High dword
    mov cl, [ebp+16]        ; Shift count
    
    cmp cl, 32
    jae .shift_32_or_more
    
    ; Shift less than 32 bits
    shrd eax, edx, cl       ; Shift low, bring in bits from high
    shr edx, cl             ; Shift high
    jmp .done
    
.shift_32_or_more:
    ; Shift 32 or more bits
    sub cl, 32
    mov eax, edx            ; High becomes low
    shr eax, cl             ; Shift remaining
    xor edx, edx            ; High becomes 0
    
.done:
    pop ebp
    ret
```

**64-bit Arithmetic Right Shift:**

```assembly
; Arithmetic right shift (preserves sign)
shift_right_64_signed:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp+8]        ; Low dword
    mov edx, [ebp+12]       ; High dword
    mov cl, [ebp+16]        ; Shift count
    
    cmp cl, 32
    jae .shift_32_or_more
    
    ; Shift less than 32 bits
    shrd eax, edx, cl       ; Shift low
    sar edx, cl             ; Arithmetic shift high (sign extends)
    jmp .done
    
.shift_32_or_more:
    ; Shift 32 or more bits
    sub cl, 32
    mov eax, edx            ; High becomes low
    sar eax, cl             ; Arithmetic shift
    sar edx, 31             ; Fill high with sign bit (all 0s or all 1s)
    
.done:
    pop ebp
    ret
```

### Extended Precision Increment/Decrement

```assembly
; Increment 64-bit value
increment_64:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp+8]        ; Address of low dword
    add dword [eax], 1      ; Increment low part
    adc dword [eax+4], 0    ; Add carry to high part
    
    pop ebp
    ret

; Decrement 64-bit value
decrement_64:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp+8]        ; Address of low dword
    sub dword [eax], 1      ; Decrement low part
    sbb dword [eax+4], 0    ; Subtract borrow from high part
    
    pop ebp
    ret
```

### Extended Precision Negation

```assembly
; Negate 64-bit value (two's complement)
; -value = ~value + 1

negate_64:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp+8]        ; Low dword
    mov edx, [ebp+12]       ; High dword
    
    ; Invert bits
    not eax
    not edx
    
    ; Add 1
    add eax, 1
    adc edx, 0
    
    ; Result in EDX:EAX
    pop ebp
    ret
```

### Complete Example - 128-bit Addition

```assembly
; Add two 128-bit numbers (4 dwords each)

section .data
    num1 dd 0xFFFFFFFF, 0xFFFFFFFF, 0x00000000, 0x00000005
    num2 dd 0x00000001, 0x00000000, 0x00000000, 0x00000003

section .bss
    result resd 4

section .text
add_128bit:
    ; Add dword 0 (lowest)
    mov eax, [num1]
    add eax, [num2]
    mov [result], eax
    
    ; Add dword 1 with carry
    mov eax, [num1+4]
    adc eax, [num2+4]
    mov [result+4], eax
    
    ; Add dword 2 with carry
    mov eax, [num1+8]
    adc eax, [num2+8]
    mov [result+8], eax
    
    ; Add dword 3 with carry
    mov eax, [num1+12]
    adc eax, [num2+12]
    mov [result+12], eax
    
    ; CF set if overflow beyond 128 bits
    jc overflow_occurred

; Result: 0x0000000900000000FFFFFFFF00000000
```

### Complete Example - Arbitrary Precision Addition

```assembly
; Add two numbers of arbitrary length (in dwords)
; Generic function for any size

add_multi_precision:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx
    
    ; [ebp+8]  = pointer to num1
    ; [ebp+12] = pointer to num2
    ; [ebp+16] = pointer to result
    ; [ebp+20] = length in dwords
    
    mov esi, [ebp+8]        ; num1
    mov edi, [ebp+12]       ; num2
    mov ebx, [ebp+16]       ; result
    mov ecx, [ebp+20]       ; length
    
    clc                     ; Clear carry flag
    
.add_loop:
    mov eax, [esi]
    adc eax, [edi]          ; Add with carry
    mov [ebx], eax
    
    add esi, 4
    add edi, 4
    add ebx, 4
    
    loop .add_loop
    
    ; Return carry flag state in EAX
    setc al
    movzx eax, al
    
    pop ebx
    pop edi
    pop esi
    pop ebp
    ret
```

### Performance Optimization Examples

**Fast Multiply by 10:**

```assembly
; Multiply by 10 without MUL instruction
; result = value × 10 = value × (8 + 2) = (value << 3) + (value << 1)

multiply_by_10:
    mov eax, [value]
    mov ebx, eax
    shl eax, 3              ; EAX = value × 8
    shl ebx, 1              ; EBX = value × 2
    add eax, ebx            ; EAX = value × 10

; Or using LEA (fastest):
    mov eax, [value]
    lea eax, [eax + eax*4]  ; EAX = value × 5
    shl eax, 1              ; EAX = value × 10

; Or single LEA (even faster):
    mov ebx, [value]
    lea eax, [ebx + ebx*4]  ; EAX = value + value×4 = value×5
    add eax, eax            ; EAX = value×10
```

**Fast Division by Power of 2:**

```assembly
; Unsigned division by power of 2
mov eax, 100
shr eax, 3              ; Divide by 8 (2³)

; Signed division by power of 2 (requires rounding adjustment)
mov eax, -100
cdq                     ; Sign extend
and edx, 7              ; EDX = (value < 0) ? 7 : 0
add eax, edx            ; Adjust for negative rounding
sar eax, 3              ; Arithmetic shift (divide by 8)
```

**Checking for Division Overflow Before DIV:**

```assembly
; Safe 32-bit division: check if quotient will fit
safe_divide:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp+8]        ; Dividend (low)
    mov edx, [ebp+12]       ; Dividend (high)
    mov ebx, [ebp+16]       ; Divisor
    
    ; Check for division by zero
    test ebx, ebx
    jz .error
    
    ; Check if quotient will overflow
    ; Quotient overflows if EDX >= EBX
    cmp edx, ebx
    jae .error
    
    ; Safe to divide
    div ebx
    jmp .done
    
.error:
    ; Set error flag or return error code
    xor eax, eax
    dec eax                 ; EAX = -1 (error indicator)
    
.done:
    pop ebp
    ret
```

**Optimized Modulo Power of 2:**

```assembly
; Fast modulo for power of 2: value mod 2ⁿ
mov eax, 100
and eax, 0x0F           ; value mod 16 (2⁴)
                        ; Mask keeps only lower 4 bits

; Equivalent to:
mov eax, 100
mov ebx, 16
xor edx, edx
div ebx
; EDX now has result, but AND is much faster
```

### Example - BigInteger Library Functions

```assembly
; Initialize big integer to zero
bigint_zero:
    push ebp
    mov ebp, esp
    push edi
    
    mov edi, [ebp+8]        ; Pointer to bigint
    mov ecx, [ebp+12]       ; Size in dwords
    xor eax, eax
    rep stosd               ; Fill with zeros
    
    pop edi
    pop ebp
    ret

; Copy big integer
bigint_copy:
    push ebp
    mov ebp, esp
    push esi
    push edi
    
    mov edi, [ebp+8]        ; Destination
    mov esi, [ebp+12]       ; Source
    mov ecx, [ebp+16]       ; Size in dwords
    rep movsd
    
    pop edi
    pop esi
    pop ebp
    ret

; Compare big integers
; Returns: 0 if equal, -1 if num1 < num2, 1 if num1 > num2
bigint_compare:
    push ebp
    mov ebp, esp
    push esi
    push edi
    
    mov esi, [ebp+8]        ; num1
    mov edi, [ebp+12]       ; num2
    mov ecx, [ebp+16]       ; Size in dwords
    
    ; Compare from high to low
    lea esi, [esi + ecx*4 - 4]
    lea edi, [edi + ecx*4 - 4]
    std                     ; Backward direction
    
.compare_loop:
    mov eax, [esi]
    cmp eax, [edi]
    ja .greater
    jb .less
    
    sub esi, 4
    sub edi, 4
    loop .compare_loop
    
    ; Equal
    xor eax, eax
    jmp .done
    
.greater:
    mov eax, 1
    jmp .done
    
.less:
    mov eax, -1
    
.done:
    cld                     ; Restore direction
    pop edi
    pop esi
    pop ebp
    ret
```

**Key Points:**

- MUL performs unsigned multiplication with result in register pair (AX, DX:AX, EDX:EAX, RDX:RAX)
- IMUL performs signed multiplication with three forms: one-operand (like MUL), two-operand (truncated), three-operand (with immediate)
- DIV performs unsigned division with quotient and remainder stored separately
- IDIV performs signed division, requires proper sign extension (CBW, CWD, CDQ, CQO)
- Upper register (AH, DX, EDX, RDX) must be initialized before division to prevent undefined behavior
- Division by zero or quotient overflow causes CPU exception (interrupt 0, divide error)
- CF and OF flags indicate if multiplication result needs extended register space
- [Inference] Signed division remainder sign matches dividend sign in x86 architecture
- Extended precision arithmetic uses ADC/SBB for multi-word addition/subtraction with carry propagation
- Multi-precision multiplication requires breaking operations into word-sized chunks and accumulating partial products
- Multi-precision division typically uses iterative algorithms or processes from high-order words downward
- LEA and shift operations provide faster alternatives to multiplication/division by specific constants

**Important subtopics:** Optimizing multiplication/division with bit shifts and LEA, Handling overflow detection and prevention, Implementing arbitrary-precision arithmetic libraries, Using SIMD instructions for parallel multiplication, Hardware performance characteristics of MUL/DIV instructions

---

