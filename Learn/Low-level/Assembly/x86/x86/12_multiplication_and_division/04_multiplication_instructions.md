## Multiplication Instructions


x86 provides two primary multiplication instructions: MUL for unsigned multiplication and IMUL for signed multiplication. These instructions handle operands of various sizes and produce results that may be twice the size of the operands.

### MUL (Unsigned Multiplication)

MUL performs unsigned multiplication with implicit operands. One operand is always the accumulator (AL/AX/EAX/RAX), and the other is specified explicitly.

**Syntax and Operation:**

```nasm
MUL r/m8     ; AX = AL × r/m8
MUL r/m16    ; DX:AX = AX × r/m16
MUL r/m32    ; EDX:EAX = EAX × r/m32
MUL r/m64    ; RDX:RAX = RAX × r/m64 (64-bit mode)
```

**Flags Affected:**

- CF and OF are set if the upper half of the result is non-zero
- SF, ZF, AF, PF are undefined after MUL

**Example (8-bit multiplication):**

```nasm
section .data
    num1 db 15
    num2 db 20
    
section .bss
    result resw 1
    
section .text
multiply_8bit:
    mov al, [num1]       ; AL = 15
    mul byte [num2]      ; AX = AL × 20 = 300 (0x012C)
    mov [result], ax     ; Store 16-bit result
    
    ; Check for overflow in upper byte
    jc overflow_detected ; CF set if AH != 0
    ; No overflow, result fits in AL
    ret
    
overflow_detected:
    ; Result requires full 16 bits
    ret
```

**Example (16-bit multiplication):**

```nasm
section .data
    value1 dw 1000
    value2 dw 2000
    
section .bss
    result_lo resw 1
    result_hi resw 1
    
section .text
multiply_16bit:
    mov ax, [value1]     ; AX = 1000
    mul word [value2]    ; DX:AX = 1000 × 2000 = 2,000,000
    
    ; Result: DX = 0x001E (high word), AX = 0x8480 (low word)
    mov [result_lo], ax  ; Store low 16 bits
    mov [result_hi], dx  ; Store high 16 bits
    ret
```

**Example (32-bit multiplication):**

```nasm
section .data
    multiplicand dd 100000
    multiplier dd 50000
    
section .bss
    product_low resd 1
    product_high resd 1
    
section .text
multiply_32bit:
    mov eax, [multiplicand]  ; EAX = 100000
    mul dword [multiplier]   ; EDX:EAX = 100000 × 50000 = 5,000,000,000
    
    ; Result: EDX:EAX = 0x0000000129A2D000
    mov [product_low], eax   ; Low 32 bits
    mov [product_high], edx  ; High 32 bits
    
    ; Check if result fits in 32 bits
    test edx, edx
    jnz overflow_32bit
    ret
    
overflow_32bit:
    ; Handle overflow condition
    ret
```

**Example (64-bit multiplication in 64-bit mode):**

```nasm
section .data
    factor1 dq 1000000000
    factor2 dq 2000000000
    
section .bss
    result_low resq 1
    result_high resq 1
    
section .text
multiply_64bit:
    mov rax, [factor1]       ; RAX = 1000000000
    mul qword [factor2]      ; RDX:RAX = 1000000000 × 2000000000
    
    ; Result is 2,000,000,000,000,000,000 (0x1BC16D674EC80000)
    mov [result_low], rax    ; Low 64 bits
    mov [result_high], rdx   ; High 64 bits
    ret
```

### IMUL (Signed Multiplication)

IMUL performs signed multiplication and has three forms: one-operand (like MUL), two-operand, and three-operand.

**One-Operand Form (similar to MUL):**

```nasm
IMUL r/m8     ; AX = AL × r/m8 (signed)
IMUL r/m16    ; DX:AX = AX × r/m16 (signed)
IMUL r/m32    ; EDX:EAX = EAX × r/m32 (signed)
IMUL r/m64    ; RDX:RAX = RAX × r/m64 (signed, 64-bit mode)
```

**Two-Operand Form:**

```nasm
IMUL r16, r/m16       ; r16 = r16 × r/m16
IMUL r32, r/m32       ; r32 = r32 × r/m32
IMUL r64, r/m64       ; r64 = r64 × r/m64
```

**Three-Operand Form (with immediate):**

```nasm
IMUL r16, r/m16, imm8/imm16    ; r16 = r/m16 × immediate
IMUL r32, r/m32, imm8/imm32    ; r32 = r/m32 × immediate
IMUL r64, r/m64, imm8/imm32    ; r64 = r/m64 × immediate
```

**Example (signed 8-bit multiplication):**

```nasm
section .data
    num1 db -10          ; Signed byte
    num2 db 5
    
section .text
signed_multiply_8:
    mov al, [num1]       ; AL = -10 (0xF6)
    imul byte [num2]     ; AX = -10 × 5 = -50 (0xFFCE)
    
    ; AH = 0xFF (sign extension), AL = 0xCE
    ; CF and OF are clear if result fits in AL with sign
    ret
```

**Example (two-operand IMUL):**

```nasm
section .data
    value dd 25
    multiplier dd -4
    
section .text
signed_multiply_two_op:
    mov eax, [value]         ; EAX = 25
    imul eax, [multiplier]   ; EAX = 25 × -4 = -100
    
    ; Only lower 32 bits stored in EAX
    ; CF and OF set if result doesn't fit in destination
    jo overflow_occurred
    ret
    
overflow_occurred:
    ; Result was truncated
    ret
```

**Example (three-operand IMUL with immediate):**

```nasm
section .data
    base_value dd 100
    
section .text
multiply_by_constant:
    mov eax, [base_value]    ; EAX = 100
    imul ebx, eax, 7         ; EBX = EAX × 7 = 700
    
    ; EAX unchanged, result in EBX
    imul ecx, [base_value], -3   ; ECX = 100 × -3 = -300
    ret
```

**Example (comparing MUL vs IMUL with signed values):**

```nasm
section .data
    signed_num dw -5         ; 0xFFFB in 16-bit
    
section .text
compare_mul_imul:
    ; Using MUL (treats as unsigned)
    mov ax, [signed_num]     ; AX = 0xFFFB (65531 unsigned)
    mov bx, 2
    mul bx                   ; DX:AX = 65531 × 2 = 131062 (0x0001FFFA)
    ; Result: DX = 0x0001, AX = 0xFFFA
    
    ; Using IMUL (treats as signed)
    mov ax, [signed_num]     ; AX = -5 (signed)
    mov bx, 2
    imul bx                  ; DX:AX = -5 × 2 = -10 (0xFFFFFFF6)
    ; Result: DX = 0xFFFF, AX = 0xFFF6
    ret
```

### Multiplying by Powers of Two

Multiplication by powers of two can be optimized using shift instructions.

**Example (multiplication by shifting):**

```nasm
section .text
; Multiply by 2: x × 2 = x << 1
multiply_by_2:
    mov eax, [value]
    shl eax, 1           ; Multiply by 2
    ret

; Multiply by 4: x × 4 = x << 2
multiply_by_4:
    mov eax, [value]
    shl eax, 2           ; Multiply by 4
    ret

; Multiply by 8: x × 8 = x << 3
multiply_by_8:
    mov eax, [value]
    shl eax, 3           ; Multiply by 8
    ret

; Multiply by 16: x × 16 = x << 4
multiply_by_16:
    mov eax, [value]
    shl eax, 4           ; Multiply by 16
    ret
```

**Example (checking overflow with shift multiplication):**

```nasm
section .text
safe_multiply_by_power_of_2:
    mov eax, [value]
    mov ecx, 3           ; Multiply by 8 (shift left 3)
    
    ; Check if shift will overflow
    mov ebx, eax
    shr ebx, cl          ; Shift right by same amount
    shl ebx, cl          ; Shift back
    cmp ebx, eax         ; If equal, no overflow occurred
    jne shift_overflow
    
    shl eax, cl          ; Safe to multiply
    clc                  ; Clear carry flag
    ret
    
shift_overflow:
    stc                  ; Set carry flag to indicate overflow
    ret
```

