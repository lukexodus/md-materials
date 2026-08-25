## MUL and IMUL Instructions


### MUL (Unsigned Multiplication)

MUL performs unsigned multiplication between the accumulator (AL/AX/EAX/RAX) and a specified operand, storing the result in a register pair.

**Operand Sizes and Register Usage:**

```assembly
; 8-bit: AL × operand → AX (16-bit result)
mul bl          ; AX = AL × BL
mul byte [mem]  ; AX = AL × [mem]

; 16-bit: AX × operand → DX:AX (32-bit result)
mul cx          ; DX:AX = AX × CX (high word in DX, low word in AX)
mul word [mem]  ; DX:AX = AX × [mem]

; 32-bit: EAX × operand → EDX:EAX (64-bit result)
mul ebx         ; EDX:EAX = EAX × EBX (high dword in EDX, low in EAX)
mul dword [mem] ; EDX:EAX = EAX × [mem]

; 64-bit: RAX × operand → RDX:RAX (128-bit result, 64-bit mode)
mul rcx         ; RDX:RAX = RAX × RCX
```

**Flags Affected:**

- **CF and OF:** Set if high-order bits contain significant data (upper half is non-zero)
- **SF, ZF, AF, PF:** Undefined after MUL

**Basic Examples:**

```assembly
; 8-bit multiplication
mov al, 15          ; AL = 15
mov bl, 10          ; BL = 10
mul bl              ; AX = 150 (0x0096)
                    ; AH = 0, AL = 150
                    ; CF = 0, OF = 0 (result fits in AL)

; 8-bit with overflow
mov al, 200         ; AL = 200
mov bl, 3           ; BL = 3
mul bl              ; AX = 600 (0x0258)
                    ; AH = 2, AL = 88
                    ; CF = 1, OF = 1 (result needs AH)

; 16-bit multiplication
mov ax, 1000        ; AX = 1000
mov cx, 50          ; CX = 50
mul cx              ; DX:AX = 50000 (0x0000C350)
                    ; DX = 0, AX = 50000
                    ; CF = 0, OF = 0

; 32-bit multiplication with overflow
mov eax, 100000     ; EAX = 100000
mov ebx, 50000      ; EBX = 50000
mul ebx             ; EDX:EAX = 5,000,000,000 (0x12A05F200)
                    ; EDX = 1, EAX = 0x2A05F200
                    ; CF = 1, OF = 1
```

**Example - Large Number Multiplication:**

```assembly
section .data
    num1 dd 0xFFFFFFFF  ; Maximum 32-bit value (4,294,967,295)
    num2 dd 0xFFFFFFFF

section .bss
    result resq 1       ; 64-bit result

section .text
multiply_large:
    mov eax, [num1]
    mul dword [num2]        ; EDX:EAX = num1 × num2
    
    ; Store 64-bit result
    mov [result], eax       ; Low 32 bits
    mov [result+4], edx     ; High 32 bits
    
    ; Result: 0xFFFFFFFE00000001
    ; = 18,446,744,065,119,617,025
```

**Checking for Overflow:**

```assembly
; Multiply and check if result fits in lower register
mov eax, 1000
mov ebx, 2000
mul ebx             ; EDX:EAX = 2,000,000

jc overflow_occurred    ; CF set if EDX contains data
; or
jo overflow_occurred    ; OF also set

; Alternative: check EDX directly
test edx, edx
jnz overflow_occurred   ; Jump if EDX is non-zero

no_overflow:
    ; Result fits in EAX, use EAX only
    mov [result], eax
    jmp done

overflow_occurred:
    ; Use both EDX:EAX for full result
    mov [result], eax
    mov [result+4], edx

done:
```

### IMUL (Signed Multiplication)

IMUL performs signed multiplication and comes in three forms: one-operand (like MUL), two-operand, and three-operand.

**One-Operand Form (Same as MUL):**

```assembly
; 8-bit: AL × operand → AX
imul bl         ; AX = AL × BL (signed)

; 16-bit: AX × operand → DX:AX
imul cx         ; DX:AX = AX × CX (signed)

; 32-bit: EAX × operand → EDX:EAX
imul ebx        ; EDX:EAX = EAX × EBX (signed)

; 64-bit: RAX × operand → RDX:RAX
imul rcx        ; RDX:RAX = RAX × RCX (signed)
```

**Two-Operand Form:**

```assembly
; dest = dest × src (result truncated to operand size)
imul dest, src

imul eax, ebx       ; EAX = EAX × EBX (32-bit result only)
imul ecx, [mem]     ; ECX = ECX × [mem]
imul edx, 5         ; EDX = EDX × 5 (immediate)
```

**Three-Operand Form:**

```assembly
; dest = src × immediate (result truncated to operand size)
imul dest, src, immediate

imul eax, ebx, 10   ; EAX = EBX × 10
imul ecx, [mem], 5  ; ECX = [mem] × 5
imul edx, esi, -3   ; EDX = ESI × (-3)
```

**Signed vs Unsigned Examples:**

```assembly
; Positive numbers (same result for MUL and IMUL)
mov al, 10
mov bl, 5
imul bl             ; AX = 50 (signed)

mov al, 10
mov bl, 5
mul bl              ; AX = 50 (unsigned)

; Negative numbers (different results)
mov al, -10         ; AL = 0xF6 (246 unsigned, -10 signed)
mov bl, 5
imul bl             ; AX = -50 (0xFFCE, interprets as signed)

mov al, 246         ; Same bit pattern
mov bl, 5
mul bl              ; AX = 1230 (0x04CE, interprets as unsigned)
```

**Negative Number Multiplication:**

```assembly
; -10 × 5 = -50
mov al, -10         ; AL = 0xF6
mov bl, 5
imul bl             ; AX = 0xFFCE (-50 in two's complement)
                    ; AH = 0xFF (sign extension)
                    ; CF = 1, OF = 1 (sign bit propagated to AH)

; -10 × -5 = 50
mov al, -10         ; AL = 0xF6
mov bl, -5          ; BL = 0xFB
imul bl             ; AX = 0x0032 (50)
                    ; AH = 0x00
                    ; CF = 0, OF = 0
```

**Two-Operand IMUL Examples:**

```assembly
; Multiply without extended result
mov eax, 1000
imul eax, 50        ; EAX = 50,000 (no EDX used)

; Using with memory
section .data
    multiplier dd 25

section .text
    mov ebx, 400
    imul ebx, [multiplier]  ; EBX = 10,000

; Chaining multiplications
mov eax, 10
imul eax, 5         ; EAX = 50
imul eax, 2         ; EAX = 100
imul eax, eax       ; EAX = 10,000 (self-multiply)
```

**Three-Operand IMUL Examples:**

```assembly
; Calculate: result = value × 3
mov ebx, 100
imul eax, ebx, 3        ; EAX = 300, EBX unchanged

; Array indexing with scaling
; address = base + (index × element_size)
mov esi, 5              ; Index
imul edi, esi, 4        ; EDI = index × 4 (dword size)
mov eax, [array + edi]  ; Access array[5]

; Formula calculation: y = 2x + 5
mov ebx, 10             ; x = 10
imul eax, ebx, 2        ; EAX = 2 × 10 = 20
add eax, 5              ; EAX = 25
```

**Flag Behavior with Two/Three-Operand IMUL:**

```assembly
; CF and OF set if result doesn't fit in destination size
mov eax, 100000
imul eax, 50000         ; EAX = truncated result
                        ; CF = 1, OF = 1 (overflow occurred)

; No overflow
mov eax, 10
imul eax, 5             ; EAX = 50
                        ; CF = 0, OF = 0 (result fits)
```

**Performance Considerations:**

```assembly
; Multiply by power of 2: use shift instead
mov eax, 100
imul eax, 8         ; Slower
; vs
shl eax, 3          ; Faster (multiply by 2³ = 8)

; Multiply by (2ⁿ + 1): use LEA
mov ebx, 100
imul eax, ebx, 5    ; Multiply by 5
; vs
lea eax, [ebx + ebx*4]  ; Faster: EAX = EBX + EBX×4 = 5×EBX

; Multiply by (2ⁿ - 1): use LEA with subtraction
mov ebx, 100
imul eax, ebx, 7    ; Multiply by 7
; vs
lea eax, [ebx*8]    ; EAX = 8×EBX
sub eax, ebx        ; EAX = 8×EBX - EBX = 7×EBX
```

**Example - Factorial Calculation:**

```assembly
; Calculate n! (factorial)
; Limited to values that fit in 32-bit result

factorial:
    push ebp
    mov ebp, esp
    push ebx
    
    mov ecx, [ebp+8]    ; Get n
    mov eax, 1          ; Result = 1
    
    cmp ecx, 1
    jle .done           ; 0! = 1, 1! = 1
    
.loop:
    imul eax, ecx       ; result *= n
    dec ecx
    cmp ecx, 1
    jg .loop
    
.done:
    pop ebx
    pop ebp
    ret

; Usage:
push 5
call factorial
add esp, 4
; EAX = 120 (5! = 5×4×3×2×1)
```

