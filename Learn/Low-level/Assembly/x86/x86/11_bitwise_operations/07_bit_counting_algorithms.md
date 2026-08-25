## Bit Counting Algorithms


Bit counting involves determining the number of set bits (population count), finding the position of specific bits, or counting leading/trailing zeros.

### Population Count (Popcount)

Population count determines how many bits are set to 1 in a value.

**Hardware instruction (POPCNT - SSE4.2):**

```nasm
section .text
    ; Modern CPUs with SSE4.2
    mov eax, 0b11010110        ; 5 bits set
    popcnt eax, eax            ; EAX = 5
    
    ; 64-bit version
    mov rax, 0xFFFFFFFF00000000
    popcnt rax, rax            ; RAX = 32
```

**Software implementation - Brian Kernighan's algorithm:**

```nasm
; Count set bits by repeatedly clearing the lowest set bit
; Complexity: O(number of set bits)
section .text
popcount_kernighan:
    ; Input: EAX = value
    ; Output: EAX = bit count
    xor ecx, ecx               ; Counter = 0
    
.loop:
    test eax, eax              ; Check if zero
    jz .done
    
    lea edx, [eax - 1]         ; EDX = EAX - 1
    and eax, edx               ; Clear lowest set bit
    inc ecx                    ; Increment counter
    jmp .loop
    
.done:
    mov eax, ecx               ; Return count
    ret
```

**Parallel bit counting (32-bit):**

```nasm
; Count bits using parallel addition
; Complexity: O(log n) operations
section .text
popcount_parallel:
    ; Input: EAX = value
    ; Output: EAX = bit count
    
    ; Count bits in pairs
    mov edx, eax
    shr eax, 1
    and eax, 0x55555555        ; Mask: 01010101...
    sub edx, eax               ; edx now has counts in pairs
    
    ; Count bits in nibbles
    mov eax, edx
    shr edx, 2
    and eax, 0x33333333        ; Mask: 00110011...
    and edx, 0x33333333
    add eax, edx               ; eax now has counts in nibbles
    
    ; Count bits in bytes
    mov edx, eax
    shr eax, 4
    add eax, edx
    and eax, 0x0F0F0F0F        ; Mask: 00001111...
    
    ; Sum all bytes
    imul eax, eax, 0x01010101  ; Multiply to sum bytes
    shr eax, 24                ; Extract high byte
    ret
```

**Lookup table method:**

```nasm
section .data
    ; Precomputed popcount for all byte values (0-255)
    popcount_table:
    db 0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4  ; 0x00-0x0F
    db 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5  ; 0x10-0x1F
    db 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5  ; 0x20-0x2F
    db 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6  ; 0x30-0x3F
    db 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5  ; 0x40-0x4F
    db 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6  ; 0x50-0x5F
    db 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6  ; 0x60-0x6F
    db 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7  ; 0x70-0x7F
    db 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5  ; 0x80-0x8F
    db 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6  ; 0x90-0x9F
    db 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6  ; 0xA0-0xAF
    db 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7  ; 0xB0-0xBF
    db 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6  ; 0xC0-0xCF
    db 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7  ; 0xD0-0xDF
    db 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7  ; 0xE0-0xEF
    db 4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8  ; 0xF0-0xFF

section .text
popcount_lut:
    ; Input: EAX = 32-bit value
    ; Output: EAX = bit count
    xor edx, edx               ; Clear counter
    
    ; Process each byte
    movzx ecx, al
    add dl, [popcount_table + ecx]
    
    movzx ecx, ah
    add dl, [popcount_table + ecx]
    
    shr eax, 16
    movzx ecx, al
    add dl, [popcount_table + ecx]
    
    movzx ecx, ah
    add dl, [popcount_table + ecx]
    
    movzx eax, dl              ; Return total count
    ret
```

### Counting Leading Zeros (CLZ)

**Hardware instruction (BSR/LZCNT):**

```nasm
section .text
    ; BSR (Bit Scan Reverse) - available on all x86
    mov eax, 0x00001000        ; Bit 12 is highest set bit
    bsr ecx, eax               ; ECX = 12 (position of highest bit)
    jz .all_zeros              ; ZF set if EAX was zero
    
    ; Calculate leading zeros from BSR result
    mov edx, 31
    sub edx, ecx               ; EDX = 31 - 12 = 19 leading zeros
    
.all_zeros:
    ; Handle zero input case
    
    ; LZCNT (BMI1) - better handling of zero
    lzcnt eax, eax             ; Direct leading zero count
    ; Returns 32 for zero input
```

**Software implementation:**

```nasm
section .text
count_leading_zeros:
    ; Input: EAX = value
    ; Output: EAX = number of leading zeros
    test eax, eax
    jnz .not_zero
    mov eax, 32                ; All zeros
    ret
    
.not_zero:
    bsr ecx, eax               ; Find highest set bit
    mov eax, 31
    sub eax, ecx               ; Calculate leading zeros
    ret
```

### Counting Trailing Zeros (CTZ)

**Hardware instruction (BSF/TZCNT):**

```nasm
section .text
    ; BSF (Bit Scan Forward)
    mov eax, 0x00001000        ; Bit 12 is lowest set bit
    bsf ecx, eax               ; ECX = 12 (position of lowest bit)
    jz .all_zeros              ; ZF set if EAX was zero
    
    ; TZCNT (BMI1) - better handling of zero
    tzcnt eax, eax             ; Direct trailing zero count
    ; Returns 32 for zero input
```

**Software implementation - isolate lowest bit:**

```nasm
section .text
count_trailing_zeros:
    ; Input: EAX = value
    ; Output: EAX = number of trailing zeros
    test eax, eax
    jnz .not_zero
    mov eax, 32
    ret
    
.not_zero:
    bsf eax, eax               ; Find lowest set bit position
    ret

; Alternative: Using De Bruijn sequence
section .data
    align 4
    debruijn_table:
    db 0, 1, 28, 2, 29, 14, 24, 3, 30, 22, 20, 15, 25, 17, 4, 8
    db 31, 27, 13, 23, 21, 19, 16, 7, 26, 12, 18, 6, 11, 5, 10, 9

section .text
ctz_debruijn:
    ; Input: EAX = value (must not be zero)
    ; Output: EAX = trailing zeros
    
    ; Isolate lowest set bit
    mov edx, eax
    neg eax
    and eax, edx               ; EAX = lowest set bit isolated
    
    ; Multiply by De Bruijn constant
    imul eax, eax, 0x077CB531
    shr eax, 27                ; Use top 5 bits as index
    
    movzx eax, byte [debruijn_table + eax]
    ret
```

### Parity Calculation

Determine if the number of set bits is even or odd.

```nasm
section .text
    ; Hardware parity flag (PF) checks low byte only
    mov al, 0b10110110         ; 5 bits set (odd parity)
    test al, al                ; Set flags
    jpo .odd_parity            ; Jump if parity odd
    
    ; Full 32-bit parity using XOR reduction
    mov eax, 0x12345678
    mov edx, eax
    shr edx, 16
    xor eax, edx               ; XOR upper and lower 16 bits
    
    mov edx, eax
    shr edx, 8
    xor eax, edx               ; XOR upper and lower 8 bits
    
    mov edx, eax
    shr edx, 4
    xor eax, edx               ; XOR nibbles
    
    mov edx, eax
    shr edx, 2
    xor eax, edx               ; XOR pairs
    
    mov edx, eax
    shr edx, 1
    xor eax, edx               ; XOR individual bits
    
    and eax, 1                 ; EAX = 0 (even) or 1 (odd)
```

