## Bit Manipulation Techniques


### Setting Individual Bits

**Set bit N (make it 1):**

```nasm
; Using OR with bit mask
mov al, value
or al, (1 << N)                         ; Set bit N
mov value, al

; Using BTS (Bit Test and Set) - sets bit and stores old value in CF
bts dword [value], N                    ; Set bit N, CF = old bit value

; Set multiple specific bits
mov al, value
or al, 00101010b                        ; Set bits 1, 3, 5

; Set bits based on position in register
mov cl, bit_position                    ; CL = bit number
mov al, 1
shl al, cl                              ; AL = bit mask
or [value], al                          ; Set the bit
```

### Clearing Individual Bits

**Clear bit N (make it 0):**

```nasm
; Using AND with inverted mask
mov al, value
and al, ~(1 << N)                       ; Clear bit N
mov value, al

; Using BTC (Bit Test and Complement) then conditionally clear
; Using BTR (Bit Test and Reset) - clears bit and stores old value in CF
btr dword [value], N                    ; Clear bit N, CF = old bit value

; Clear multiple specific bits
mov al, value
and al, 11010101b                       ; Clear bits 1, 3, 5

; Clear bits based on position
mov cl, bit_position
mov al, 1
shl al, cl                              ; AL = bit mask
not al                                  ; Invert mask
and [value], al                         ; Clear the bit
```

### Toggling Individual Bits

**Toggle bit N (flip between 0 and 1):**

```nasm
; Using XOR with bit mask
mov al, value
xor al, (1 << N)                        ; Toggle bit N
mov value, al

; Using BTC (Bit Test and Complement) - toggles bit and stores old value in CF
btc dword [value], N                    ; Toggle bit N, CF = old bit value

; Toggle multiple bits
mov al, value
xor al, 00101010b                       ; Toggle bits 1, 3, 5

; Toggle based on position
mov cl, bit_position
mov al, 1
shl al, cl                              ; AL = bit mask
xor [value], al                         ; Toggle the bit
```

### Testing Individual Bits

**Test if bit N is set:**

```nasm
; Using TEST instruction
mov al, value
test al, (1 << N)                       ; Test bit N
jz bit_is_zero                          ; Jump if bit is 0
jnz bit_is_one                          ; Jump if bit is 1

; Using BT (Bit Test) - copies bit to carry flag
bt dword [value], N                     ; CF = bit N
jc bit_is_set                           ; Jump if bit is 1
jnc bit_is_clear                        ; Jump if bit is 0

; Test multiple bits (any set)
test al, 00001111b                      ; Test if any of lower 4 bits set
jnz at_least_one_set

; Test multiple bits (all set)
mov al, value
and al, 00001111b
cmp al, 00001111b
je all_four_bits_set

; Test bit based on position
mov cl, bit_position
bt dword [value], cl                    ; CF = bit at position
```

### Counting Set Bits (Population Count)

**Count number of 1 bits in a value:**

```nasm
; Using POPCNT instruction (SSE4.2, not universally available)
popcnt eax, value                       ; EAX = number of 1 bits

; Manual bit counting (Brian Kernighan's algorithm)
mov eax, value
xor ecx, ecx                            ; Counter = 0
count_loop:
    test eax, eax                       ; Check if zero
    jz count_done
    mov edx, eax
    dec edx
    and eax, edx                        ; Clear lowest set bit
    inc ecx                             ; Increment counter
    jmp count_loop
count_done:
    ; ECX contains bit count

; Parallel bit counting (lookup table method)
section .data
    bit_count_table db 0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4  ; For 4-bit nibbles

section .text
    mov eax, value
    xor ecx, ecx                        ; Result accumulator
    
    ; Count lower byte
    mov edx, eax
    and edx, 0x0F
    mov cl, [bit_count_table + edx]
    
    shr edx, 4
    and edx, 0x0F
    add cl, [bit_count_table + edx]
    
    ; Continue for remaining bytes...
```

### Finding First/Last Set Bit

**Find first set bit (LSB):**

```nasm
; Using BSF (Bit Scan Forward)
bsf eax, value                          ; EAX = index of first 1 bit
jz no_bits_set                          ; ZF set if value = 0

; Using TZCNT (Trailing Zero Count) - BMI1 instruction
tzcnt eax, value                        ; EAX = number of trailing zeros
; [Unverified] If value = 0, result is operand size

; Manual method (isolate lowest set bit)
mov eax, value
neg edx                                 ; EDX = -value
and eax, edx                            ; Isolate lowest set bit
bsf ecx, eax                            ; ECX = bit position
```

**Find last set bit (MSB):**

```nasm
; Using BSR (Bit Scan Reverse)
bsr eax, value                          ; EAX = index of last 1 bit
jz no_bits_set                          ; ZF set if value = 0

; Using LZCNT (Leading Zero Count) - BMI1 instruction
lzcnt eax, value                        ; EAX = number of leading zeros
; Bit position = 31 - LZCNT result

; Manual method for finding MSB position
mov eax, value
xor ecx, ecx                            ; Bit position = 0
find_msb:
    shr eax, 1
    jz found_msb
    inc ecx
    jmp find_msb
found_msb:
    ; ECX contains MSB position
```

### Isolating and Extracting Bits

**Isolate lowest set bit:**

```nasm
mov eax, value
neg edx, eax                            ; EDX = -value (two's complement)
and eax, edx                            ; Isolate lowest set bit
; Example: value = 01011000 → result = 00001000
```

**Clear lowest set bit:**

```nasm
mov eax, value
mov edx, eax
dec edx
and eax, edx                            ; Clear lowest set bit
; Example: value = 01011000 → result = 01010000
```

**Isolate highest set bit:**

```nasm
mov eax, value
bsr ecx, eax                            ; ECX = position of MSB
mov ebx, 1
shl ebx, cl                             ; EBX = isolated MSB
; Example: value = 01011000 → result = 01000000
```

**Extract bit range (bits M through N):**

```nasm
; Extract bits 7:4 from AL
mov al, value
shr al, 4                               ; Shift to position
and al, 0x0F                            ; Mask to 4 bits

; More general: extract N bits starting at position P
mov eax, value
shr eax, P                              ; Shift to position
mov ebx, 1
shl ebx, N                              ; Create mask of N bits
dec ebx                                 ; EBX = (1 << N) - 1
and eax, ebx                            ; Extract N bits
```

### Bit Reversal

**Reverse bits in a byte:**

```nasm
mov al, input_byte
mov cl, 8
xor bl, bl                              ; Result accumulator

reverse_loop:
    shr al, 1                           ; Shift bit into CF
    rcl bl, 1                           ; Rotate into result
    dec cl
    jnz reverse_loop
    ; BL contains reversed bits

; Lookup table method (faster)
section .data
    reverse_table db 0x00,0x80,0x40,0xC0,0x20,0xA0,0x60,0xE0  ; ... 256 entries

section .text
    movzx eax, byte_value
    mov al, [reverse_table + eax]       ; Look up reversed byte
```

**Reverse bits in a 32-bit value:**

```nasm
; Using BSWAP and bit manipulation
mov eax, value
bswap eax                               ; Reverse bytes

; Now reverse bits within each byte
; [Inference] Requires additional bit-level reversal per byte
; Complete implementation requires iterating or using lookup tables per byte
```

### Parity Calculation

**Calculate parity (even/odd number of set bits):**

```nasm
; Parity flag is automatically set by many instructions
mov al, value
test al, al                             ; PF set based on lower 8 bits
jp even_parity                          ; Jump if even parity (even # of 1s)
jnp odd_parity                          ; Jump if odd parity (odd # of 1s)

; Calculate parity for larger values by XORing parts
mov eax, dword_value
mov ebx, eax
shr ebx, 16
xor eax, ebx                            ; XOR upper and lower words
mov ebx, eax
shr ebx, 8
xor eax, ebx                            ; XOR bytes
test al, al                             ; Check parity of result
```

