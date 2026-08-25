## Division Instructions


x86 provides DIV for unsigned division and IDIV for signed division. Division operations are more complex than multiplication and can generate exceptions.

### DIV (Unsigned Division)

DIV performs unsigned division with implicit operands. The dividend is in AX, DX:AX, EDX:EAX, or RDX:RAX depending on divisor size.

**Syntax and Operation:**

```nasm
DIV r/m8     ; AL = AX ÷ r/m8, AH = remainder
DIV r/m16    ; AX = DX:AX ÷ r/m16, DX = remainder
DIV r/m32    ; EAX = EDX:EAX ÷ r/m32, EDX = remainder
DIV r/m64    ; RAX = RDX:RAX ÷ r/m64, RDX = remainder (64-bit mode)
```

**Flags Affected:** All flags (CF, OF, SF, ZF, AF, PF) are undefined after DIV.

**Example (8-bit division):**

```nasm
section .data
    dividend db 100
    divisor db 7
    
section .bss
    quotient resb 1
    remainder resb 1
    
section .text
divide_8bit:
    xor ah, ah           ; Clear AH (high byte of dividend)
    mov al, [dividend]   ; AX = 0x0064 (100)
    div byte [divisor]   ; AL = 100 ÷ 7 = 14, AH = 100 mod 7 = 2
    
    mov [quotient], al   ; Store quotient (14)
    mov [remainder], ah  ; Store remainder (2)
    ret
```

**Example (16-bit division):**

```nasm
section .data
    dividend dw 50000
    divisor dw 300
    
section .bss
    quotient resw 1
    remainder resw 1
    
section .text
divide_16bit:
    xor dx, dx           ; Clear DX (high word of dividend)
    mov ax, [dividend]   ; DX:AX = 0x0000C350 (50000)
    div word [divisor]   ; AX = 50000 ÷ 300 = 166, DX = 50000 mod 300 = 200
    
    mov [quotient], ax
    mov [remainder], dx
    ret
```

**Example (32-bit division):**

```nasm
section .data
    large_dividend dd 1000000000
    large_divisor dd 7
    
section .bss
    result_quotient resd 1
    result_remainder resd 1
    
section .text
divide_32bit:
    xor edx, edx             ; Clear EDX (high dword)
    mov eax, [large_dividend] ; EDX:EAX = 1000000000
    div dword [large_divisor] ; EAX = quotient, EDX = remainder
    
    ; EAX = 142857142, EDX = 6
    mov [result_quotient], eax
    mov [result_remainder], edx
    ret
```

**Example (64-bit division with large dividend):**

```nasm
section .data
    ; Represent large number as 64-bit value
    high_dword dd 5          ; High 32 bits
    low_dword dd 0           ; Low 32 bits
    divisor32 dd 1000
    
section .text
divide_64_by_32:
    mov edx, [high_dword]    ; EDX = high part
    mov eax, [low_dword]     ; EAX = low part
    ; EDX:EAX = 5 × 2^32 = 21474836480
    
    div dword [divisor32]    ; EAX = quotient, EDX = remainder
    ; EAX = 21474836, EDX = 480
    ret
```

**Example (division by zero handling):**

```nasm
section .text
safe_divide:
    mov eax, [dividend]
    mov ebx, [divisor]
    
    ; Check for division by zero
    test ebx, ebx
    jz division_by_zero
    
    xor edx, edx
    div ebx
    clc                  ; Clear carry flag (success)
    ret
    
division_by_zero:
    xor eax, eax         ; Return 0
    xor edx, edx
    stc                  ; Set carry flag (error)
    ret
```

### IDIV (Signed Division)

IDIV performs signed division with the same operand structure as DIV.

**Syntax and Operation:**

```nasm
IDIV r/m8     ; AL = AX ÷ r/m8 (signed), AH = remainder
IDIV r/m16    ; AX = DX:AX ÷ r/m16 (signed), DX = remainder
IDIV r/m32    ; EAX = EDX:EAX ÷ r/m32 (signed), EDX = remainder
IDIV r/m64    ; RAX = RDX:RAX ÷ r/m64 (signed), RDX = remainder
```

**Example (signed 8-bit division):**

```nasm
section .data
    signed_dividend db -50
    signed_divisor db 7
    
section .text
signed_divide_8:
    mov al, [signed_dividend]  ; AL = -50
    cbw                         ; Sign-extend AL to AX (AH = 0xFF)
    idiv byte [signed_divisor]  ; AL = -50 ÷ 7 = -7, AH = -1
    
    ; AL = -7 (0xF9), AH = -1 (0xFF)
    ; -50 = (-7 × 7) + (-1)
    ret
```

**Example (signed 16-bit division):**

```nasm
section .data
    signed_val dw -1000
    divisor dw 30
    
section .text
signed_divide_16:
    mov ax, [signed_val]    ; AX = -1000
    cwd                     ; Sign-extend AX to DX:AX
    idiv word [divisor]     ; AX = -1000 ÷ 30 = -33, DX = -10
    
    ; -1000 = (-33 × 30) + (-10)
    ret
```

**Example (signed 32-bit division):**

```nasm
section .data
    signed_num dd -100000
    divisor32 dd 3
    
section .text
signed_divide_32:
    mov eax, [signed_num]   ; EAX = -100000
    cdq                     ; Sign-extend EAX to EDX:EAX
    idiv dword [divisor32]  ; EAX = -100000 ÷ 3 = -33333, EDX = -1
    
    ; -100000 = (-33333 × 3) + (-1)
    ret
```

**Example (sign extension for division):**

```nasm
section .text
; Sign extension instructions for preparing dividends

; 8-bit to 16-bit
prepare_8bit:
    mov al, [byte_value]
    cbw                  ; Convert Byte to Word: sign-extend AL to AX
    ; If AL = 0x80 (-128), AX becomes 0xFF80
    ret

; 16-bit to 32-bit
prepare_16bit:
    mov ax, [word_value]
    cwd                  ; Convert Word to Dword: sign-extend AX to DX:AX
    ; If AX = 0x8000 (-32768), DX:AX becomes 0xFFFF8000
    ret

; 32-bit to 64-bit
prepare_32bit:
    mov eax, [dword_value]
    cdq                  ; Convert Dword to Qword: sign-extend EAX to EDX:EAX
    ; If EAX = 0x80000000, EDX:EAX becomes 0xFFFFFFFF80000000
    ret

; 64-bit to 128-bit (64-bit mode)
prepare_64bit:
    mov rax, [qword_value]
    cqo                  ; Convert Qword to Oword: sign-extend RAX to RDX:RAX
    ret
```

**Example (comparing DIV vs IDIV with negative values):**

```nasm
section .data
    neg_value dw -100    ; 0xFF9C in 16-bit
    
section .text
compare_div_idiv:
    ; Using DIV (treats as unsigned)
    xor dx, dx
    mov ax, [neg_value]  ; AX = 0xFF9C (65436 unsigned)
    mov bx, 10
    div bx               ; AX = 6543, DX = 6
    
    ; Using IDIV (treats as signed)
    mov ax, [neg_value]  ; AX = -100 (signed)
    cwd                  ; Sign-extend to DX:AX
    mov bx, 10
    idiv bx              ; AX = -10, DX = 0
    ret
```

### Dividing by Powers of Two

Division by powers of two can be optimized using shift instructions for unsigned values.

**Example (unsigned division by shifting):**

```nasm
section .text
; Divide by 2: x ÷ 2 = x >> 1
divide_by_2:
    mov eax, [value]
    shr eax, 1           ; Unsigned divide by 2
    ret

; Divide by 4: x ÷ 4 = x >> 2
divide_by_4:
    mov eax, [value]
    shr eax, 2
    ret

; Divide by 8: x ÷ 8 = x >> 3
divide_by_8:
    mov eax, [value]
    shr eax, 3
    ret
```

**Example (signed division by power of two):**

```nasm
section .text
; Signed division by 2 using SAR (Shift Arithmetic Right)
signed_divide_by_2:
    mov eax, [signed_value]
    sar eax, 1           ; Signed divide by 2
    ; For negative odd numbers, this rounds toward negative infinity
    ret

; Correct signed division by power of two with rounding toward zero
signed_divide_by_power_of_2_correct:
    mov eax, [signed_value]
    mov ecx, 3           ; Divide by 8
    
    ; Add bias for negative numbers
    cdq                  ; Sign-extend EAX to EDX
    and edx, 7           ; EDX = (EAX < 0) ? 7 : 0
    add eax, edx         ; Add bias
    sar eax, cl          ; Divide
    ret
```

**Example (getting remainder when dividing by power of two):**

```nasm
section .text
; Get remainder when dividing by power of two
modulo_power_of_2:
    mov eax, [value]
    mov ebx, eax
    and ebx, 7           ; Remainder when dividing by 8 (2^3)
    ; EBX = value mod 8
    
    shr eax, 3           ; Quotient
    ; EAX = value ÷ 8
    ret
```

