## Fundamental Bitwise Instructions


### AND Operation

The AND instruction performs a logical AND between corresponding bits of two operands. The result is 1 only when both bits are 1.

**Truth table:**

```
A  B  Result
0  0    0
0  1    0
1  0    0
1  1    1
```

**Syntax and usage:**

```nasm
and dest, source                        ; dest = dest AND source
```

**Common applications:**

```nasm
; Clear specific bits (masking)
mov al, 10110111b
and al, 11110000b                       ; AL = 10110000b (clear lower 4 bits)

; Test if a bit is set (non-destructive with TEST)
mov al, 0x42
test al, 0x02                           ; Test bit 1, AL unchanged
jz bit_not_set                          ; Jump if bit is 0

; Isolate specific bits
mov eax, 0x12345678
and eax, 0x0000FF00                     ; EAX = 0x00005600 (extract byte 1)

; Check if value is even
test al, 1                              ; Test bit 0
jz is_even                              ; Jump if bit 0 = 0

; Force value to be even
and al, 0xFE                            ; Clear bit 0

; Align address to boundary (align to 16 bytes)
mov eax, some_address
and eax, 0xFFFFFFF0                     ; Clear lower 4 bits
```

### OR Operation

The OR instruction performs a logical OR between corresponding bits. The result is 1 when at least one bit is 1.

**Truth table:**

```
A  B  Result
0  0    0
0  1    1
1  0    1
1  1    1
```

**Syntax and usage:**

```nasm
or dest, source                         ; dest = dest OR source
```

**Common applications:**

```nasm
; Set specific bits
mov al, 10110000b
or al, 00000111b                        ; AL = 10110111b (set lower 3 bits)

; Combine bit flags
mov al, FLAG_ACTIVE                     ; AL = 0x01
or al, FLAG_VISIBLE                     ; AL = 0x03 (both flags set)

; Convert ASCII lowercase to uppercase
mov al, 'a'                             ; AL = 0x61 (01100001b)
or al, 0x20                             ; AL = 0x61 (still lowercase)
; Wait, to convert TO uppercase:
and al, 0xDF                            ; AL = 0x41 = 'A'

; Check if any bits are set in a mask
mov al, [flags]
test al, 0x0F                           ; Test lower 4 bits
jnz some_bits_set

; Set multiple flag bits
or dword [status], FLAG_READY | FLAG_ENABLED | FLAG_VISIBLE
```

### XOR Operation

The XOR (exclusive OR) instruction performs a logical XOR. The result is 1 when bits are different.

**Truth table:**

```
A  B  Result
0  0    0
0  1    1
1  0    1
1  1    0
```

**Syntax and usage:**

```nasm
xor dest, source                        ; dest = dest XOR source
```

**Common applications:**

```nasm
; Clear a register (faster than mov reg, 0)
xor eax, eax                            ; EAX = 0

; Toggle specific bits
mov al, 10110000b
xor al, 00001111b                       ; AL = 10111111b (toggle lower 4 bits)

; Swap two values without temporary variable
mov eax, 5
mov ebx, 10
xor eax, ebx                            ; EAX = 15
xor ebx, eax                            ; EBX = 5
xor eax, ebx                            ; EAX = 10

; Simple encryption (XOR cipher)
mov al, [plaintext]
xor al, [key]                           ; Encrypt
mov [ciphertext], al
; Decrypt with same key
mov al, [ciphertext]
xor al, [key]                           ; AL = original plaintext

; Check if two values are equal
xor eax, ebx
jz values_equal                         ; If result is 0, they were equal

; Toggle flag bit
xor byte [flags], FLAG_ACTIVE           ; Flip bit state

; Parity checking (XOR all bits)
mov al, data_byte
xor al, al                              ; Sets PF based on bit count
jp even_parity                          ; Jump if even number of 1 bits
```

### NOT Operation

The NOT instruction performs a one's complement (inverts all bits).

**Syntax and usage:**

```nasm
not dest                                ; dest = ~dest
```

**Common applications:**

```nasm
; Bit inversion
mov al, 10110000b
not al                                  ; AL = 01001111b

; Create inverse mask
mov eax, 0x0000FF00
not eax                                 ; EAX = 0xFFFF00FF

; Negate and subtract 1 (for two's complement conversion)
mov eax, 5
not eax                                 ; EAX = 0xFFFFFFFA (-6 in two's complement)
inc eax                                 ; EAX = 0xFFFFFFFB (-5)

; Compute -1
xor eax, eax
not eax                                 ; EAX = 0xFFFFFFFF (-1)

; Clear all bits except specific ones
mov al, 0x0F                            ; Mask for bits to keep
not al                                  ; AL = 0xF0
and [flags], al                         ; Clear lower 4 bits
```

### TEST Operation

The TEST instruction performs a bitwise AND but only updates flags without storing the result.

**Syntax and usage:**

```nasm
test dest, source                       ; Flags = dest AND source (dest unchanged)
```

**Common applications:**

```nasm
; Check if specific bit is set
test al, 0x80                           ; Test bit 7
jnz bit7_set                            ; Jump if bit 7 = 1
jz bit7_clear                           ; Jump if bit 7 = 0

; Check if value is zero
test eax, eax                           ; Sets ZF if EAX = 0
jz is_zero

; Check if value is negative (sign bit)
test eax, eax                           ; Sets SF based on bit 31
js is_negative

; Check multiple bits simultaneously
test al, 0x03                           ; Check if bit 0 or bit 1 is set
jnz at_least_one_set
jz both_clear

; Check if any of multiple flags are set
test dword [status], FLAG_ERROR | FLAG_WARNING
jnz has_issues

; Verify alignment (check if address is 16-byte aligned)
test eax, 0x0F                          ; Test lower 4 bits
jz is_aligned                           ; Jump if all lower bits = 0
```

