## CMP and TEST Instructions


Before conditional jumps, you typically need to set the appropriate flags. The CMP and TEST instructions are designed specifically for this purpose.

### CMP (Compare)

The CMP instruction performs subtraction (left operand - right operand) but discards the result, only updating flags.

**Syntax:**

```asm
cmp destination, source     ; Compute destination - source, set flags
```

**Flags Set:**

- ZF: Set if operands are equal
- CF: Set if unsigned destination < source
- SF: Set based on sign of result
- OF: Set on signed overflow

**Example:**

```asm
mov eax, 10
cmp eax, 5          ; 10 - 5 = 5
                    ; ZF = 0 (not equal)
                    ; CF = 0 (10 >= 5 unsigned)
                    ; SF = 0 (positive result)

mov eax, 5
cmp eax, 10         ; 5 - 10 = -5
                    ; ZF = 0 (not equal)
                    ; CF = 1 (5 < 10 unsigned)
                    ; SF = 1 (negative result)

mov eax, 5
cmp eax, 5          ; 5 - 5 = 0
                    ; ZF = 1 (equal)
                    ; CF = 0 (5 >= 5)
                    ; SF = 0 (zero result)
```

**Memory Operands:**

```asm
cmp byte [buffer], 0        ; Compare byte at buffer with 0
cmp dword [counter], 100    ; Compare dword at counter with 100
cmp eax, [ebx + ecx*4]      ; Compare EAX with memory value
```

### TEST (Logical Compare)

The TEST instruction performs a bitwise AND operation but discards the result, only updating flags.

**Syntax:**

```asm
test destination, source    ; Compute destination AND source, set flags
```

**Flags Set:**

- ZF: Set if result is zero
- SF: Set based on sign of result
- PF: Set based on parity
- CF: Always cleared to 0
- OF: Always cleared to 0

**Common Uses:**

**Test if value is zero:**

```asm
test eax, eax       ; AND EAX with itself
jz is_zero          ; Jump if ZF = 1 (EAX is zero)
```

**Test specific bits:**

```asm
test al, 0x01       ; Test if bit 0 is set
jnz bit_set         ; Jump if not zero (bit is set)

test eax, 0x80000000    ; Test sign bit
jnz negative            ; Jump if set (negative)
```

**Test multiple bits:**

```asm
test al, 0x03       ; Test if bits 0 or 1 are set
jz neither_set      ; Jump if both clear
```

**Example:**

```asm
mov al, 0b10101010
test al, 0b00001111     ; Test lower 4 bits
                        ; Result: 0b00001010
                        ; ZF = 0 (not all tested bits are clear)
                        ; SF = 0 (bit 7 of result is 0)

mov al, 0b11110000
test al, 0b00001111     ; Test lower 4 bits
                        ; Result: 0b00000000
                        ; ZF = 1 (all tested bits are clear)
```

