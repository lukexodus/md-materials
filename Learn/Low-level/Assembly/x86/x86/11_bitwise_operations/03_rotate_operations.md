## Rotate Operations


### Rotate Left (ROL)

Rotates bits left; the leftmost bit wraps around to the rightmost position and also goes to Carry Flag.

```nasm
rol dest, count                         ; Rotate left
```

**Behavior:**

```
Before: 10110101 (CF = ?)
ROL 1:  01101011 (CF = 1, bit 7 rotates to bit 0)
ROL 3:  10101101 (CF = 1)
```

**Common applications:**

```nasm
; Circular buffer index management
mov eax, [buffer_index]
rol eax, 1                              ; Circular shift
and eax, BUFFER_MASK                    ; Keep within bounds

; Hash function mixing
mov eax, hash_value
rol eax, 13
xor eax, input_data
add eax, constant

; Endianness conversion (byte swap) for 32-bit value
mov eax, 0x12345678
rol eax, 8                              ; EAX = 0x34567812
rol eax, 8                              ; EAX = 0x56781234
rol eax, 8                              ; EAX = 0x78123456
rol eax, 8                              ; EAX = 0x12345678 (back to original)
; Better method: use BSWAP

; Bit permutation
mov al, input_bits
rol al, 3                               ; Reorder bits

; Quick test of all bit positions
mov al, test_value
mov cl, 8                               ; 8 bits to test
test_loop:
    rol al, 1                           ; Rotate next bit to position
    jc bit_is_set                       ; Check carry flag
    dec cl
    jnz test_loop
```

### Rotate Right (ROR)

Rotates bits right; the rightmost bit wraps around to the leftmost position and also goes to Carry Flag.

```nasm
ror dest, count                         ; Rotate right
```

**Behavior:**

```
Before: 10110101 (CF = ?)
ROR 1:  11011010 (CF = 1, bit 0 rotates to bit 7)
ROR 3:  10110110 (CF = 1)
```

**Common applications:**

```nasm
; Reverse rotate operation
mov eax, value
rol eax, 5                              ; Rotate left 5
ror eax, 5                              ; Back to original

; Extract bits from different positions iteratively
mov eax, bitmap
mov cl, 32                              ; Process all bits
process_bits:
    ror eax, 1                          ; Bring next bit to position 0
    jc bit_set                          ; Test in carry flag
    ; Process bit...
    dec cl
    jnz process_bits

; Pseudo-random number generator (simple mixing)
mov eax, [seed]
ror eax, 7
xor eax, 0x12345678
add eax, ecx
mov [seed], eax

; Bit reversal within byte
mov al, input_byte
mov cl, 8
reverse_loop:
    ror al, 1
    rcl bl, 1                           ; Collect in BL
    dec cl
    jnz reverse_loop
```

### Rotate Through Carry Left (RCL)

Rotates bits left through the Carry Flag; CF becomes bit 0, and bit 7/15/31 goes to CF.

```nasm
rcl dest, count                         ; Rotate through carry left
```

**Behavior:**

```
CF = 1, Value = 10110101
RCL 1: CF = 1, Value = 01101011 (old CF → bit 0, bit 7 → CF)
```

**Common applications:**

```nasm
; Multi-precision (128-bit) left shift
; Shift EDX:EAX:EBX:ECX left by 1
shl ecx, 1                              ; Shift lowest dword
rcl ebx, 1                              ; Rotate through carry
rcl eax, 1                              ; Rotate through carry
rcl edx, 1                              ; Rotate through carry (highest)

; Serial bit transmission
mov al, data_byte
mov cl, 8
transmit_loop:
    rcl al, 1                           ; Rotate bit into carry
    ; Send bit from carry flag
    call send_bit
    dec cl
    jnz transmit_loop

; Bit collection from carry flag
; Collect 8 bits from various operations into AL
xor al, al                              ; Clear accumulator
; ... some operation that sets CF
rcl al, 1                               ; Collect bit 0
; ... another operation that sets CF
rcl al, 1                               ; Collect bit 1
; ... continue for 8 bits

; Extended precision multiply-add
; Multiply and accumulate into 64-bit result
mov eax, multiplicand
mul multiplier                          ; Result in EDX:EAX
add eax, accumulator_low
adc edx, accumulator_high               ; Add with carry
; Now shift 64-bit result
shl eax, 1
rcl edx, 1                              ; Propagate carry
```

### Rotate Through Carry Right (RCR)

Rotates bits right through the Carry Flag; CF becomes the highest bit, and bit 0 goes to CF.

```nasm
rcr dest, count                         ; Rotate through carry right
```

**Behavior:**

```
CF = 1, Value = 10110101
RCR 1: CF = 1, Value = 11011010 (old CF → bit 7, bit 0 → CF)
```

**Common applications:**

```nasm
; Multi-precision (64-bit) right shift
; Shift EDX:EAX right by 1
shr edx, 1                              ; Shift high dword
rcr eax, 1                              ; Rotate low dword through carry

; Multi-precision (96-bit) right shift
shr high_dword, 1
rcr mid_dword, 1
rcr low_dword, 1

; Serial bit reception
mov cl, 8
xor al, al
receive_loop:
    call receive_bit                    ; Get bit into carry
    rcr al, 1                           ; Shift into position
    dec cl
    jnz receive_loop

; Divide 64-bit number by 2
rcr dword [value_high], 1
rcr dword [value_low], 1

; Extract bits from right to left
mov eax, bitfield
mov cl, num_bits
extract_loop:
    rcr eax, 1                          ; Bit goes to CF
    ; Process bit from CF
    dec cl
    jnz extract_loop
```

