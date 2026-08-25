## Code Examples


**Example 1: Horizontal Sum using SSE3**

```asm
section .data
    align 16
    values: dd 10.0, 20.0, 30.0, 40.0
    result: dd 0.0

section .text
    movaps xmm0, [values]            ; xmm0 = [10, 20, 30, 40]
    movaps xmm1, xmm0                ; xmm1 = [10, 20, 30, 40]
    haddps xmm0, xmm1                ; xmm0 = [30, 70, 30, 70]
    haddps xmm0, xmm0                ; xmm0 = [100, 100, 100, 100]
    movss [result], xmm0             ; Extract lowest element
```

**Output:** result = 100.0

The first HADDPS adds adjacent pairs: (10+20=30, 30+40=70, 10+20=30, 30+40=70). The second HADDPS adds those results: (30+70=100, 30+70=100, 30+70=100, 30+70=100).

**Example 2: Complex Number Multiplication using SSE3**

```asm
section .data
    align 16
    ; Complex numbers: (a + bi) and (c + di)
    ; Stored as [a, b, c, d]
    complex1: dd 3.0, 4.0, 3.0, 4.0      ; (3 + 4i) duplicated
    complex2: dd 5.0, 6.0, 6.0, 5.0      ; (5 + 6i) rearranged
    result: times 4 dd 0.0

section .text
    movaps xmm0, [complex1]          ; xmm0 = [3, 4, 3, 4]
    movaps xmm1, [complex2]          ; xmm1 = [5, 6, 6, 5]
    
    mulps xmm0, xmm1                 ; xmm0 = [15, 24, 18, 20]
    addsubps xmm0, xmm0              ; Real: 15-24=-9, Imag: 18+20=38
    ; Further processing needed for complete complex multiplication
```

This demonstrates the ADDSUBPS pattern useful in complex arithmetic where alternating subtract/add operations are required.

**Example 3: Byte Shuffle using SSSE3**

```asm
section .data
    align 16
    data: db 0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77
         db 0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF
    
    ; Shuffle mask to reverse bytes
    reverse_mask: db 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0
    
    result: times 16 db 0

section .text
    movdqa xmm0, [data]              ; Load data
    movdqa xmm1, [reverse_mask]      ; Load shuffle mask
    pshufb xmm0, xmm1                ; Shuffle bytes
    movdqa [result], xmm0            ; Store result
```

**Output:** result = [0xFF, 0xEE, 0xDD, 0xCC, 0xBB, 0xAA, 0x99, 0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0x00]

**Example 4: Extract Misaligned Data using PALIGNR**

```asm
section .data
    align 16
    stream1: dd 1, 2, 3, 4
    stream2: dd 5, 6, 7, 8
    result: times 4 dd 0

section .text
    movdqa xmm0, [stream1]           ; xmm0 = [1, 2, 3, 4]
    movdqa xmm1, [stream2]           ; xmm1 = [5, 6, 7, 8]
    palignr xmm1, xmm0, 8            ; Shift by 8 bytes (2 dwords)
    movdqa [result], xmm1            ; Store result
```

**Output:** result = [3, 4, 5, 6]

PALIGNR concatenates xmm1:xmm0 as [5,6,7,8,1,2,3,4], shifts right by 8 bytes, and keeps the lower 128 bits.

**Example 5: Conditional Blending using SSE4.1**

```asm
section .data
    align 16
    values_a: dd 10.0, 20.0, 30.0, 40.0
    values_b: dd 15.0, 25.0, 35.0, 45.0
    result: times 4 dd 0

section .text
    movaps xmm0, [values_a]          ; xmm0 = [10, 20, 30, 40]
    movaps xmm1, [values_b]          ; xmm1 = [15, 25, 35, 45]
    
    ; Blend: take elements 0 and 2 from xmm0, elements 1 and 3 from xmm1
    ; Immediate mask: 0b1010 = 0xA
    blendps xmm0, xmm1, 0xA          ; xmm0 = [10, 25, 30, 45]
    movaps [result], xmm0
```

**Output:** result = [10.0, 25.0, 30.0, 45.0]

**Example 6: Variable Blending based on Comparison**

```asm
section .data
    align 16
    values_a: dd 10.0, 50.0, 30.0, 70.0
    values_b: dd 40.0, 20.0, 60.0, 35.0
    threshold: dd 40.0, 40.0, 40.0, 40.0
    result: times 4 dd 0

section .text
    movaps xmm0, [values_a]          ; xmm0 = [10, 50, 30, 70]
    movaps xmm1, [values_b]          ; xmm1 = [40, 20, 60, 35]
    movaps xmm2, [threshold]         ; xmm2 = [40, 40, 40, 40]
    
    ; Create mask: values_a < threshold
    cmpltps xmm2, xmm0               ; xmm2 = [1, 0, 1, 0] (as 0xFFFFFFFF or 0)
    
    ; If value < threshold, take from values_b, else from values_a
    blendvps xmm0, xmm1              ; Uses XMM0 implicit (note: uses sign bit)
    movaps [result], xmm0
```

[Inference: The actual behavior depends on how the mask is set up - the sign bit determines selection in BLENDVPS.]

**Example 7: 3D Vector Dot Product using DPPS**

```asm
section .data
    align 16
    vec1: dd 1.0, 2.0, 3.0, 0.0      ; 3D vector with padding
    vec2: dd 4.0, 5.0, 6.0, 0.0
    result: dd 0.0

section .text
    movaps xmm0, [vec1]              ; xmm0 = [1, 2, 3, 0]
    movaps xmm1, [vec2]              ; xmm1 = [4, 5, 6, 0]
    
    ; Multiply first 3 elements (bits 7-5 set), write to all 4 (bits 3-0 set)
    ; Control byte: 0b01110001 = 0x71
    dpps xmm0, xmm1, 0x71            ; 1*4 + 2*5 + 3*6 = 32
    movss [result], xmm0
```

**Output:** result = 32.0 (1×4 + 2×5 + 3×6 = 4 + 10 + 18 = 32)

**Example 8: 4D Vector Dot Product**

```asm
section .data
    align 16
    vec1: dd 1.0, 2.0, 3.0, 4.0
    vec2: dd 5.0, 6.0, 7.0, 8.0
    result: dd 0.0

section .text
    movaps xmm0, [vec1]              ; xmm0 = [1, 2, 3, 4]
    movaps xmm1, [vec2]              ; xmm1 = [5, 6, 7, 8]
    
    ; Multiply all 4 elements (bits 7-4 set), write to element 0 (bit 0 set)
    ; Control byte: 0b11110001 = 0xF1
    dpps xmm0, xmm1, 0xF1            ; 1*5 + 2*6 + 3*7 + 4*8 = 70
    movss [result], xmm0
```

**Output:** result = 70.0 (1×5 + 2×6 + 3×7 + 4×8 = 5 + 12 + 21 + 32 = 70)

**Example 9: Rounding Operations**

```asm
section .data
    align 16
    values: dd 1.7, 2.3, -1.7, -2.3
    round_nearest: times 4 dd 0
    round_down: times 4 dd 0
    round_up: times 4 dd 0
    truncate: times 4 dd 0

section .text
    movaps xmm0, [values]            ; xmm0 = [1.7, 2.3, -1.7, -2.3]
    
    ; Round to nearest
    roundps xmm1, xmm0, 0x00         ; xmm1 = [2, 2, -2, -2]
    movaps [round_nearest], xmm1
    
    ; Round down (floor)
    roundps xmm1, xmm0, 0x01         ; xmm1 = [1, 2, -2, -3]
    movaps [round_down], xmm1
    
    ; Round up (ceil)
    roundps xmm1, xmm0, 0x02         ; xmm1 = [2, 3, -1, -2]
    movaps [round_up], xmm1
    
    ; Truncate (toward zero)
    roundps xmm1, xmm0, 0x03         ; xmm1 = [1, 2, -1, -2]
    movaps [truncate], xmm1
```

**Output:**

- round_nearest = [2.0, 2.0, -2.0, -2.0]
- round_down = [1.0, 2.0, -2.0, -3.0]
- round_up = [2.0, 3.0, -1.0, -2.0]
- truncate = [1.0, 2.0, -1.0, -2.0]

**Example 10: Sign Extension with SSSE3**

```asm
section .data
    align 16
    bytes: db -1, 127, -128, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    words: times 8 dw 0

section .text
    movdqa xmm0, [bytes]             ; Load bytes
    pmovsxbw xmm0, xmm0              ; Sign-extend 8 bytes to 8 words
    movdqa [words], xmm0
```

**Output:** words = [-1, 127, -128, 64, 0, 0, 0, 0] (as 16-bit values)

Each byte is sign-extended to a 16-bit word: -1 (0xFF) becomes -1 (0xFFFF), 127 (0x7F) stays 127 (0x007F), -128 (0x80) becomes -128 (0xFF80).

**Example 11: Packed Multiply Low Doubleword**

```asm
section .data
    align 16
    values1: dd 10, 20, 30, 40
    values2: dd 5, 3, 2, 4
    result: times 4 dd 0

section .text
    movdqa xmm0, [values1]           ; xmm0 = [10, 20, 30, 40]
    movdqa xmm1, [values2]           ; xmm1 = [5, 3, 2, 4]
    pmulld xmm0, xmm1                ; xmm0 = [50, 60, 60, 160]
    movdqa [result], xmm0
```

**Output:** result = [50, 60, 60, 160]

Each 32-bit multiplication produces a 64-bit result, but only the lower 32 bits are kept.

**Example 12: Find Minimum Position using PHMINPOSUW**

```asm
section .data
    align 16
    values: dw 50, 30, 70, 20, 90, 40, 60, 10
    min_val: dw 0
    min_idx: dw 0

section .text
    movdqa xmm0, [values]            ; Load 8 words
    phminposuw xmm0, xmm0            ; Find minimum
    
    ; Extract minimum value (bits 15:0)
    pextrw eax, xmm0, 0
    mov [min_val], ax
    
    ; Extract index (bits 18:16)
    pextrw eax, xmm0, 1
    shr eax, 0                        ; Index is in bits 2:0 of second word
    and eax, 0x7
    mov [min_idx], ax
```

**Output:**

- min_val = 10
- min_idx = 7

**Example 13: CRC32 Calculation**

```asm
section .data
    data: db "Hello", 0
    data_len equ $ - data - 1

section .bss
    crc_result: resd 1

section .text
    xor eax, eax                     ; Initialize CRC to 0
    mov esi, data
    mov ecx, data_len

.loop:
    movzx edx, byte [esi]
    crc32 eax, dl                    ; Accumulate CRC
    inc esi
    loop .loop
    
    mov [crc_result], eax            ; Store result
```

**Output:** crc_result contains the CRC32C checksum of "Hello"

**Example 14: String Search using PCMPISTRI**

```asm
section .data
    align 16
    haystack: db "Hello World", 0, 0, 0, 0, 0
    needle: db "World", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

section .bss
    position: resd 1

section .text
    movdqu xmm0, [needle]            ; Load search string
    movdqu xmm1, [haystack]          ; Load target string
    
    ; Equal ordered, unsigned bytes, return index
    ; Control: 0b00001100 = 0x0C
    pcmpistri xmm0, xmm1, 0x0C       ; Search for substring
    
    mov [position], ecx              ; ECX contains position or 16 if not found
```

**Output:** position = 6 (index where "World" starts in "Hello World")

**Example 15: Character Range Check**

```asm
section .data
    align 16
    ; Ranges: A-Z and a-z
    ranges: db 'A', 'Z', 'a', 'z', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    text: db "Hello123", 0, 0, 0, 0, 0, 0, 0, 0

section .text
    movdqu xmm0, [ranges]            ; Load ranges
    movdqu xmm1, [text]              ; Load text
    
    ; Range check, unsigned bytes, return mask
    ; Control: 0b01000100 = 0x44
    pcmpistrm xmm0, xmm1, 0x44       ; Check which chars are letters
    
    ; XMM0 now contains mask: 0xFF for letters, 0x00 for non-letters
```

**Output:** XMM0 contains a mask where bytes corresponding to letters (H,e,l,l,o) are 0xFF and digits (1,2,3) are 0x00.

**Example 16: Absolute Value using SSSE3**

```asm
section .data
    align 16
    values: dd -10, 20, -30, 40
    result: times 4 dd 0

section .text
    movdqa xmm0, [values]            ; xmm0 = [-10, 20, -30, 40]
    pabsd xmm0, xmm0                 ; xmm0 = [10, 20, 30, 40]
    movdqa [result], xmm0
```

**Output:** result = [10, 20, 30, 40]

**Example 17: Conditional Sign using PSIGND**

```asm
section .data
    align 16
    magnitudes: dd 10, 20, 30, 40
    signs: dd -1, 1, 0, -1
    result: times 4 dd 0

section .text
    movdqa xmm0, [magnitudes]        ; xmm0 = [10, 20, 30, 40]
    movdqa xmm1, [signs]             ; xmm1 = [-1, 1, 0, -1]
    psignd xmm0, xmm1                ; Apply signs
    movdqa [result], xmm0
```

**Output:** result = [-10, 20, 0, -40]

Elements are negated where sign is negative, preserved where positive, zeroed where zero.

**Example 18: Insertion and Extraction**

```asm
section .data
    align 16
    vector: dd 1.0, 2.0, 3.0, 4.0
    new_value: dd 99.0
    extracted: dd 0.0

section .text
    movaps xmm0, [vector]            ; xmm0 = [1, 2, 3, 4]
    
    ; Extract element 2 (third element)
    extractps [extracted], xmm0, 2   ; Extract 3.0
    
    ; Insert new value at position 2, zero elements 0 and 3
    ; Control byte: source[0] -> dest[2], zero mask = 0b1001 = 0x9
    ; Full control: 0b00100000 | 0b1001 = 0x29
    movss xmm1, [new_value]
    insertps xmm0, xmm1, 0x29        ; Insert at position 2, zero positions 0 and 3
    
    movaps [vector], xmm0
```

**Output:**

- extracted = 3.0
- vector = [0.0, 2.0, 99.0, 0.0]

**Example 19: Packed Test Operation**

```asm
section .data
    align 16
    mask1: dd 0xFF00FF00, 0xFF00FF00, 0xFF00FF00, 0xFF00FF00
    test_val: dd 0x12345678, 0x9ABCDEF0, 0x11111111, 0xFFFFFFFF

section .text
    movdqa xmm0, [test_val]
    movdqa xmm1, [mask1]
    ptest xmm0, xmm1                 ; Test bits
    
    ; ZF set if (xmm0 AND xmm1) == 0
    ; CF set if (NOT xmm0 AND xmm1) == 0
    jz all_masked_bits_clear
    jc all_masked_bits_set
```

This tests whether specific bits (defined by the mask) are all clear (ZF=1) or all set (CF=1).

**Example 20: Horizontal Integer Addition Chain**

```asm
section .data
    align 16
    values: dd 1, 2, 3, 4
    result: dd 0

section .text
    movdqa xmm0, [values]            ; xmm0 = [1, 2, 3, 4]
    movdqa xmm1, xmm0
    phaddd xmm0, xmm1                ; xmm0 = [3, 7, 3, 7]
    phaddd xmm0, xmm0                ; xmm0 = [10, 10, 10, 10]
    movd [result], xmm0              ; Extract result
```

**Output:** result = 10 (1 + 2 + 3 + 4)

