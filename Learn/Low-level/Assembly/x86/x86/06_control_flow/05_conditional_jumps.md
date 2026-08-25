## Conditional Jumps


Conditional jumps test one or more flags and jump only if the condition is true. If the condition is false, execution continues with the next instruction.

### Signed Comparisons

These jumps interpret operands as signed (two's complement) integers.

**JE / JZ (Jump if Equal / Jump if Zero):**

Jumps if ZF = 1. Used after CMP when operands are equal, or after any operation that produces zero.

```asm
cmp eax, ebx
je equal            ; Jump if EAX == EBX

sub eax, ebx
jz was_equal        ; Jump if EAX - EBX == 0
```

**JNE / JNZ (Jump if Not Equal / Jump if Not Zero):**

Jumps if ZF = 0. Used when operands are not equal or result is not zero.

```asm
cmp eax, ebx
jne not_equal       ; Jump if EAX != EBX

test eax, eax
jnz not_zero        ; Jump if EAX != 0
```

**JG / JNLE (Jump if Greater / Jump if Not Less or Equal):**

Jumps if ZF = 0 AND SF = OF. Tests if left operand > right operand (signed).

```asm
cmp eax, ebx
jg greater          ; Jump if EAX > EBX (signed)
```

**JGE / JNL (Jump if Greater or Equal / Jump if Not Less):**

Jumps if SF = OF. Tests if left operand >= right operand (signed).

```asm
cmp eax, ebx
jge greater_equal   ; Jump if EAX >= EBX (signed)
```

**JL / JNGE (Jump if Less / Jump if Not Greater or Equal):**

Jumps if SF != OF. Tests if left operand < right operand (signed).

```asm
cmp eax, ebx
jl less             ; Jump if EAX < EBX (signed)
```

**JLE / JNG (Jump if Less or Equal / Jump if Not Greater):**

Jumps if ZF = 1 OR SF != OF. Tests if left operand <= right operand (signed).

```asm
cmp eax, ebx
jle less_equal      ; Jump if EAX <= EBX (signed)
```

**Example: Signed Comparison:**

```asm
section .data
    a dd -5
    b dd 10

section .text
compare_signed:
    mov eax, [a]        ; EAX = -5
    mov ebx, [b]        ; EBX = 10
    
    cmp eax, ebx        ; -5 - 10
                        ; Result is negative
                        ; SF = 1, OF = 0, SF != OF
    
    jl a_less_than_b    ; Jumps (true: -5 < 10)
    mov ecx, 0
    jmp done
    
a_less_than_b:
    mov ecx, 1
    
done:
    ret
```

### Unsigned Comparisons

These jumps interpret operands as unsigned integers.

**JA / JNBE (Jump if Above / Jump if Not Below or Equal):**

Jumps if CF = 0 AND ZF = 0. Tests if left operand > right operand (unsigned).

```asm
cmp eax, ebx
ja above            ; Jump if EAX > EBX (unsigned)
```

**JAE / JNB / JNC (Jump if Above or Equal / Jump if Not Below / Jump if No Carry):**

Jumps if CF = 0. Tests if left operand >= right operand (unsigned).

```asm
cmp eax, ebx
jae above_equal     ; Jump if EAX >= EBX (unsigned)

add eax, ebx
jnc no_overflow     ; Jump if no carry occurred
```

**JB / JNAE / JC (Jump if Below / Jump if Not Above or Equal / Jump if Carry):**

Jumps if CF = 1. Tests if left operand < right operand (unsigned).

```asm
cmp eax, ebx
jb below            ; Jump if EAX < EBX (unsigned)

add eax, ebx
jc overflow         ; Jump if carry occurred
```

**JBE / JNA (Jump if Below or Equal / Jump if Not Above):**

Jumps if CF = 1 OR ZF = 1. Tests if left operand <= right operand (unsigned).

```asm
cmp eax, ebx
jbe below_equal     ; Jump if EAX <= EBX (unsigned)
```

**Example: Unsigned Comparison:**

```asm
section .data
    a dd 0xFFFFFFF0     ; Large unsigned number
    b dd 10

section .text
compare_unsigned:
    mov eax, [a]        ; EAX = 0xFFFFFFF0
    mov ebx, [b]        ; EBX = 10
    
    cmp eax, ebx        ; 0xFFFFFFF0 - 10
                        ; CF = 0 (0xFFFFFFF0 > 10 unsigned)
                        ; But SF = 1 (result is negative when viewed as signed)
    
    ja a_above_b        ; Jumps (true: unsigned comparison)
    mov ecx, 0
    jmp done
    
a_above_b:
    mov ecx, 1
    
done:
    ret
```

### Single Flag Tests

These jumps test individual flags directly.

**JS (Jump if Sign):**

Jumps if SF = 1. Indicates negative result in signed arithmetic.

```asm
mov eax, -5
add eax, 0
js negative         ; Jumps (SF = 1)
```

**JNS (Jump if Not Sign):**

Jumps if SF = 0. Indicates non-negative result in signed arithmetic.

```asm
mov eax, 5
add eax, 0
jns non_negative    ; Jumps (SF = 0)
```

**JO (Jump if Overflow):**

Jumps if OF = 1. Indicates signed arithmetic overflow.

```asm
mov al, 127
add al, 1           ; Overflow: 127 + 1 = -128
jo overflow_occurred    ; Jumps (OF = 1)
```

**JNO (Jump if Not Overflow):**

Jumps if OF = 0. Indicates no signed overflow.

```asm
mov al, 50
add al, 50          ; No overflow: 50 + 50 = 100
jno no_overflow     ; Jumps (OF = 0)
```

**JP / JPE (Jump if Parity / Jump if Parity Even):**

Jumps if PF = 1. Indicates even number of 1 bits in result.

```asm
mov al, 0b00000011  ; Two 1 bits (even)
test al, al
jp even_parity      ; Jumps (PF = 1)
```

**JNP / JPO (Jump if Not Parity / Jump if Parity Odd):**

Jumps if PF = 0. Indicates odd number of 1 bits in result.

```asm
mov al, 0b00000111  ; Three 1 bits (odd)
test al, al
jnp odd_parity      ; Jumps (PF = 0)
```

**JC (Jump if Carry) / JNC (Jump if No Carry):**

Already covered under unsigned comparisons.

**Example: Overflow Detection:**

```asm
section .text
safe_add:
    ; Parameters: EAX, EBX
    ; Returns: EAX = result, CF = overflow flag
    
    add eax, ebx
    jo overflow_detected
    
    clc                 ; Clear carry (no overflow)
    ret
    
overflow_detected:
    stc                 ; Set carry (overflow occurred)
    ret
```

### Conditional Jump Ranges

Conditional jumps have limited range:

**Short Conditional Jumps:** All conditional jumps are encoded with 8-bit signed displacement, limiting range to -128 to +127 bytes from the end of the instruction.

**Example:**

```asm
cmp eax, 5
je target           ; If target is far away, this won't assemble
```

**Workaround for Long Jumps:**

If the target is beyond short jump range, use the opposite condition with a short jump over an unconditional jump:

```asm
; Instead of:
cmp eax, 5
je far_target       ; Error if far_target is too far

; Use:
cmp eax, 5
jne skip
jmp far_target      ; Unconditional jump has longer range
skip:
```

Most assemblers handle this automatically when using labels, but understanding the limitation is important for manual optimization.

