## Loop Instructions


Loop instructions combine decrement, compare, and conditional jump into single instructions. They use the ECX register (or RCX in 64-bit) as a counter.

### LOOP (Loop)

Decrements ECX and jumps to target if ECX != 0.

**Syntax:**

```asm
loop target
```

**Equivalent to:**

```asm
dec ecx
jnz target
```

**Example:**

```asm
section .text
count_to_ten:
    mov ecx, 10         ; Loop counter
    xor eax, eax        ; EAX = 0
    
loop_start:
    add eax, ecx        ; Add counter to sum
    loop loop_start     ; Decrement ECX, jump if ECX != 0
    
    ; EAX now contains 10+9+8+7+6+5+4+3+2+1 = 55
    ret
```

### LOOPE / LOOPZ (Loop if Equal / Loop if Zero)

Decrements ECX and jumps to target if ECX != 0 AND ZF = 1.

**Syntax:**

```asm
loope target
loopz target        ; Same instruction
```

**Equivalent to:**

```asm
dec ecx
jz done
cmp ecx, 0          ; This doesn't affect ZF from previous comparison
jnz target
done:
```

**Example: Find Non-Zero Byte:**

```asm
section .data
    buffer db 0, 0, 0, 5, 0, 0, 0, 0
    buffer_len equ $ - buffer

section .text
find_nonzero:
    lea esi, [buffer]
    mov ecx, buffer_len
    
loop_check:
    mov al, [esi]
    test al, al         ; Set ZF if byte is zero
    loopz loop_check    ; Continue while zero and ECX != 0
    
    ; If loop ended with ECX = 0, no non-zero found
    ; If loop ended with ECX != 0, non-zero found at ESI
    
    test ecx, ecx
    jz not_found
    
    ; Found non-zero byte at ESI
    ; ECX contains remaining count
    
not_found:
    ret
```

### LOOPNE / LOOPNZ (Loop if Not Equal / Loop if Not Zero)

Decrements ECX and jumps to target if ECX != 0 AND ZF = 0.

**Syntax:**

```asm
loopne target
loopnz target       ; Same instruction
```

**Example: Find Zero Byte:**

```asm
section .text
find_zero:
    lea esi, [buffer]
    mov ecx, buffer_len
    
loop_check:
    mov al, [esi]
    inc esi
    test al, al         ; Set ZF if byte is zero
    loopnz loop_check   ; Continue while non-zero and ECX != 0
    
    ; If ZF = 1, found zero byte
    ; If ZF = 0, reached end without finding zero
    
    ret
```

### JECXZ / JRCXZ (Jump if ECX/RCX is Zero)

Jumps to target if ECX (or RCX in 64-bit mode) is zero without modifying flags.

**Syntax:**

```asm
jecxz target        ; 32-bit
jrcxz target        ; 64-bit
```

**Use Case:** Check if counter is zero before entering loop.

**Example:**

```asm
section .text
process_array:
    mov ecx, [array_length]
    jecxz array_empty   ; Skip processing if length is 0
    
    lea esi, [array]
    
process_loop:
    ; Process element at ESI
    add esi, 4
    loop process_loop
    
array_empty:
    ret
```

### Loop Performance Considerations

[Inference] Modern processors may execute simple loop constructs faster than LOOP instructions because the LOOP instruction combines multiple operations into one micro-op, which can be less efficient than separate DEC and JNZ instructions on some architectures.

**Traditional Loop:**

```asm
mov ecx, 100
loop_start:
    ; loop body
    loop loop_start
```

**Optimized Alternative:**

```asm
mov ecx, 100
loop_start:
    ; loop body
    dec ecx
    jnz loop_start
```

[Inference] The separate DEC/JNZ pattern may allow better instruction scheduling and branch prediction on modern CPUs, though the performance difference is typically minimal for simple loops.

