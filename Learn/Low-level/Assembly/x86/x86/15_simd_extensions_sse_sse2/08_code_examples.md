## Code Examples


**Example 1: Packed Single-Precision Vector Addition**

```asm
section .data
    align 16
    vec1: dd 1.0, 2.0, 3.0, 4.0      ; Four floats
    vec2: dd 5.0, 6.0, 7.0, 8.0
    result: times 4 dd 0

section .text
    global _start

_start:
    movaps xmm0, [vec1]              ; Load first vector
    movaps xmm1, [vec2]              ; Load second vector
    addps xmm0, xmm1                 ; Add four pairs simultaneously
    movaps [result], xmm0            ; Store result
```

**Output:** result = [6.0, 8.0, 10.0, 12.0]

**Example 2: Scalar Double-Precision Operation**

```asm
section .data
    val1: dq 3.14159265359
    val2: dq 2.71828182846
    result: dq 0.0

section .text
    movsd xmm0, [val1]               ; Load first value (lower 64 bits)
    movsd xmm1, [val2]               ; Load second value
    mulsd xmm0, xmm1                 ; Multiply scalars
    movsd [result], xmm0             ; Store result
```

**Output:** result ≈ 8.5397342226735671

**Example 3: Horizontal Sum of Four Floats**

```asm
section .data
    align 16
    values: dd 10.0, 20.0, 30.0, 40.0
    sum: dd 0.0

section .text
    movaps xmm0, [values]            ; Load [10, 20, 30, 40]
    movaps xmm1, xmm0                ; Copy
    shufps xmm1, xmm1, 0b00001110    ; Shuffle to [30, 40, 10, 20]
    addps xmm0, xmm1                 ; xmm0 = [40, 60, 40, 60]
    movaps xmm1, xmm0                ; Copy
    shufps xmm1, xmm1, 0b00000001    ; Shuffle to [60, 40, 60, 40]
    addps xmm0, xmm1                 ; xmm0 = [100, 100, 100, 100]
    movss [sum], xmm0                ; Extract lowest element
```

**Output:** sum = 100.0

**Example 4: Integer Packed Addition (SSE2)**

```asm
section .data
    align 16
    arr1: dd 1, 2, 3, 4              ; Four 32-bit integers
    arr2: dd 10, 20, 30, 40
    result: times 4 dd 0

section .text
    movdqa xmm0, [arr1]              ; Load aligned integers
    movdqa xmm1, [arr2]
    paddd xmm0, xmm1                 ; Add four pairs of doublewords
    movdqa [result], xmm0
```

**Output:** result = [11, 22, 33, 44]

**Example 5: Data Interleaving**

```asm
section .data
    align 16
    data1: dd 1, 2, 3, 4
    data2: dd 5, 6, 7, 8
    low: times 4 dd 0
    high: times 4 dd 0

section .text
    movaps xmm0, [data1]             ; xmm0 = [1, 2, 3, 4]
    movaps xmm1, [data2]             ; xmm1 = [5, 6, 7, 8]
    
    movaps xmm2, xmm0
    unpcklps xmm2, xmm1              ; Interleave low halves
    movaps [low], xmm2               ; [1, 5, 2, 6]
    
    unpckhps xmm0, xmm1              ; Interleave high halves
    movaps [high], xmm0              ; [3, 7, 4, 8]
```

**Output:** low = [1, 5, 2, 6] high = [3, 7, 4, 8]

**Example 6: Comparison and Masking**

```asm
section .data
    align 16
    vec1: dd 1.0, 5.0, 3.0, 7.0
    vec2: dd 2.0, 4.0, 6.0, 8.0
    mask: times 4 dd 0

section .text
    movaps xmm0, [vec1]
    movaps xmm1, [vec2]
    cmpltps xmm0, xmm1               ; Compare vec1 < vec2
    movaps [mask], xmm0              ; Store mask
```

**Output:** mask = [0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, 0xFFFFFFFF] (True where vec1 < vec2: positions 0, 2, 3)

**Example 7: Converting Between Integer and Float**

```asm
section .data
    int_val: dd 42
    float_result: dd 0.0

section .text
    mov eax, [int_val]
    movd xmm0, eax                   ; Move integer to XMM
    cvtdq2ps xmm0, xmm0              ; Convert packed dword to packed single
    movss [float_result], xmm0       ; Extract scalar result
```

**Output:** float_result = 42.0

