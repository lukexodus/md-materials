## Bitwise Tricks and Optimizations


### Power of Two Operations

```nasm
section .text
    ; Check if power of two
    ; A number is power of 2 if: (n > 0) && ((n & (n-1)) == 0)
    mov eax, 16                ; Test value
    test eax, eax              ; Check if zero
    jle .not_power_of_two
    
    lea ebx, [eax - 1]
    test eax, ebx              ; AND with (n-1)
    jnz .not_power_of_two
    ; It's a power of two
    
    ; Round up to next power of two (32-bit)
    mov eax, 100               ; Input value
    dec eax                    ; EAX = 99
    
    mov ebx, eax
    shr ebx, 1
    or eax, ebx                ; Propagate highest bit
    
    mov ebx, eax
    shr ebx, 2
    or eax, ebx
    
    mov ebx, eax
    shr ebx, 4
    or eax, ebx
    
    mov ebx, eax
    shr ebx, 8
    or eax, ebx
    
    mov ebx, eax
    shr ebx, 16
    or eax, ebx
    
    inc eax                    ; EAX = 128 (next power of 2)
    
    ; Fast modulo by power of two
    ; n % 8 == n & 7
    mov eax, 25
    and eax, 7                 ; EAX = 1 (same as 25 % 8)
    
    ; Fast division by power of two
    ; n / 8 == n >> 3
    mov eax, 100
    shr eax, 3                 ; EAX = 12 (same as 100 / 8)
    
    ; Fast multiplication by power of two
    ; n * 8 == n << 3
    mov eax, 12
    shl eax, 3                 ; EAX = 96 (same as 12 * 8)
```

### Bit Manipulation Tricks

**Isolate rightmost 1-bit:**

```nasm
section .text
    ; Extract lowest set bit: n & (-n)
    mov eax, 0b10110100        ; Binary value
    mov ebx, eax
    neg ebx                    ; Two's complement
    and eax, ebx               ; EAX = 0b00000100 (isolated bit)
```

**Clear rightmost 1-bit:**

```nasm
section .text
    ; Clear lowest set bit: n & (n-1)
    mov eax, 0b10110100
    lea ebx, [eax - 1]
    and eax, ebx               ; EAX = 0b10110000
```

**Set rightmost 0-bit:**

```nasm
section .text
    ; Set lowest zero bit: n | (n+1)
    mov eax, 0b10110101
    lea ebx, [eax + 1]
    or eax, ebx                ; EAX = 0b10110111
```

**Isolate rightmost 0-bit:**

```nasm
section .text
    ; Extract lowest zero bit: ~n & (n+1)
    mov eax, 0b10110101
    mov ebx, eax
    not ebx
    lea ecx, [eax + 1]
    and ebx, ecx               ; EBX = 0b00000010 (isolated zero)
```

**Turn off rightmost contiguous 1s:**

```nasm
section .text
    ; Clear trailing ones: n & (n+1)
    mov eax, 0b10110111
    lea ebx, [eax + 1]
    and eax, ebx               ; EAX = 0b10110000
```

**Create mask with n rightmost bits set:**

```nasm
section .text
    ; Create mask: (1 << n) - 1
    mov ecx, 5                 ; n = 5
    mov eax, 1
    shl eax, cl
    dec eax                    ; EAX = 0b00011111 (5 bits set)
    
    ; Alternative for n bits: -1 << (32 - n)
    mov ecx, 5
    mov eax, -1
    mov ebx, 32
    sub ebx, ecx
    shl eax, cl
    shr eax, cl                ; EAX = 0b00011111
```

### Sign Extension Tricks

```nasm
section .text
    ; Sign extend 8-bit to 32-bit without MOVSX
    movzx eax, byte [value]    ; Zero extend first
    shl eax, 24                ; Shift sign bit to bit 31
    sar eax, 24                ; Arithmetic shift right
    
    ; Faster: use MOVSX (recommended)
    movsx eax, byte [value]
    
    ; Check if two integers have opposite signs
    mov eax, -5
    mov ebx, 10
    xor ecx, eax
    xor ecx, ebx
    test ecx, 0x80000000       ; Test sign bit
    jnz .opposite_signs        ; Non-zero = opposite signs
```

### Absolute Value Without Branching

```nasm
section .text
    ; Absolute value: n = (n XOR mask) - mask, where mask = n >> 31
    mov eax, -42               ; Input value
    mov edx, eax
    sar edx, 31                ; EDX = 0xFFFFFFFF (all 1s for negative)
    xor eax, edx
    sub eax, edx               ; EAX = 42
    
    ; For positive: mask=0, so (n XOR 0) - 0 = n
    ; For negative: mask=-1, so (n XOR -1) - (-1) = -n - (-1) = -n + 1 - 1 = -n
```

### Min/Max Without Branching

```nasm
section .text
    ; Minimum of two values
    mov eax, 42                ; First value
    mov ebx, 17                ; Second value
    
    sub eax, ebx               ; EAX = difference
    mov ecx, eax
    sar ecx, 31                ; ECX = mask (0 or -1)
    and eax, ecx               ; Zero if EAX was positive
    add eax, ebx               ; EAX = min(42, 17) = 17
    
    ; Using CMOV (Pentium Pro+, more efficient)
    mov eax, 42
    mov ebx, 17
    cmp eax, ebx
    cmovg eax, ebx             ; EAX = min(42, 17) = 17
```

### Swap Without Temporary

```nasm
section .text
    ; XOR swap
    mov eax, 10
    mov ebx, 20
    
    xor eax, ebx               ; EAX = 10 ^ 20
    xor ebx, eax               ; EBX = 20 ^ (10 ^ 20) = 10
    xor eax, ebx               ; EAX = (10 ^ 20) ^ 10 = 20
    
    ; Note: XCHG is simpler and often faster on modern CPUs
    mov eax, 10
    mov ebx, 20
    xchg eax, ebx              ; Swap (preferred method)
```

### Fast Multiplication by Constants

```nasm
section .text
    ; Multiply by 3: n * 3 = (n << 1) + n
    mov eax, 100
    lea ebx, [eax + eax*2]     ; EBX = 300
    
    ; Multiply by 5: n * 5 = (n << 2) + n
    mov eax, 100
    lea ebx, [eax + eax*4]     ; EBX = 500
    
    ; Multiply by 7: n * 7 = (n << 3) - n
    mov eax, 100
    mov ebx, eax
    shl ebx, 3
    sub ebx, eax               ; EBX = 700
    
    ; Multiply by 10: n * 10 = (n << 3) + (n << 1)
    mov eax, 100
    mov ebx, eax
    shl ebx, 3                 ; EBX = 800
    lea ebx, [ebx + eax*2]     ; EBX = 1000
```

### Reverse Bits

```nasm
section .text
reverse_bits_32:
    ; Input: EAX = value
    ; Output: EAX = bit-reversed value
    
    ; Swap bytes
    bswap eax                  ; Reverse byte order
    
    ; Swap nibbles within bytes
    mov ebx, eax
    and eax, 0xF0F0F0F0
    shr eax, 4
    and ebx, 0x0F0F0F0F
    shl ebx, 4
    or eax, ebx
    
    ; Swap bit pairs within nibbles
    mov ebx, eax
    and eax, 0xCCCCCCCC
    shr eax, 2
    and ebx, 0x33333333
    shl ebx, 2
    or eax, ebx
    
    ; Swap bits within pairs
    mov ebx, eax
    and eax, 0xAAAAAAAA
    shr eax, 1
    and ebx, 0x55555555
    shl ebx, 1
    or eax, ebx
    ret
```

### Gray Code Conversion

```nasm
section .text
    ; Binary to Gray code: gray = n ^ (n >> 1)
    mov eax, 12                ; Binary: 1100
    mov ebx, eax
    shr ebx, 1
    xor eax, ebx               ; EAX = 10 (Gray: 1010)
    
    ; Gray to Binary code
    mov eax, 10                ; Gray: 1010
    mov ebx, eax
    shr ebx, 1
    xor eax, ebx
    
    mov ebx, eax
    shr ebx, 2
    xor eax, ebx
    
    mov ebx, eax
    shr ebx, 4
    xor eax, ebx
    
    mov ebx, eax
    shr ebx, 8
    xor eax, ebx
    
    mov ebx, eax
    shr ebx, 16
    xor eax, ebx               ; EAX = 12 (Binary: 1100)
```

### Bit Interleaving (Morton Code/Z-order)

```nasm
section .text
    ; Interleave bits of two 16-bit values into 32-bit
interleave_bits:
    ; Input: AX = x, BX = y
    ; Output: EAX = interleaved (y1x1y0x0...)
    
    movzx eax, ax              ; Zero extend x
    movzx ebx, bx              ; Zero extend y
    
    ; Spread x bits
    and eax, 0x0000FFFF
    mov ecx, eax
    shl ecx, 8
    or eax, ecx
    and eax, 0x00FF00FF
    
    mov ecx, eax
    shl ecx, 4
    or eax, ecx
    and eax, 0x0F0F0F0F
    
    mov ecx, eax
    shl ecx, 2
    or eax, ecx
    and eax, 0x33333333
    
    mov ecx, eax
    shl ecx, 1
    or eax, ecx
    and eax, 0x55555555        ; x bits at even positions
    
    ; Spread y bits
    and ebx, 0x0000FFFF
    mov ecx, ebx
    shl ecx, 8
    or ebx, ecx
    and ebx, 0x00FF00FF
    
    mov ecx, ebx
    shl ecx, 4
    or ebx, ecx
    and ebx, 0x0F0F0F0F
    
    mov ecx, ebx
    shl ecx, 2
    or ebx, ecx
    and ebx, 0x33333333
    
    mov ecx, ebx
    shl ecx, 1
    or ebx, ecx
    and ebx, 0x55555555
    
    shl ebx, 1                 ; Shift y to odd positions
    or eax, ebx                ; Combine
    ret
```

### BMI (Bit Manipulation Instructions) - Modern CPUs

```nasm
section .text
    ; ANDN (Bitwise AND NOT) - Haswell+
    mov eax, 0xFF00FF00
    mov ebx, 0xF0F0F0F0
    andn ecx, eax, ebx         ; ECX = (~EAX) & EBX = 0x000F0F00

; BLSI (Extract Lowest Set Bit)
mov eax, 0b10110100
blsi ebx, eax              ; EBX = 0b00000100

; BLSMSK (Mask From Lowest Set Bit)
mov eax, 0b10110100
blsmsk ebx, eax            ; EBX = 0b00000111 (mask up to lowest bit)

; BLSR (Reset Lowest Set Bit)
mov eax, 0b10110100
blsr ebx, eax              ; EBX = 0b10110000

; BEXTR (Bit Field Extract)
mov eax, 0x12345678
mov ebx, 0x0810           ; Start at bit 16, length 8
bextr ecx, eax, ebx       ; ECX = 0x00000034

; BZHI (Zero High Bits)
mov eax, 0xFFFFFFFF
mov ebx, 12               ; Keep lowest 12 bits
bzhi ecx, eax, ebx        ; ECX = 0x00000FFF

; PDEP (Parallel Bits Deposit)
mov eax, 0b11111111       ; Source bits
mov ebx, 0b10101010       ; Mask
pdep ecx, eax, ebx        ; ECX = 0b10101010 (deposit to mask positions)

; PEXT (Parallel Bits Extract)
mov eax, 0b10110100       ; Source
mov ebx, 0b11110000       ; Mask
pext ecx, eax, ebx        ; ECX = 0b00001011 (extract masked bits)
````

### Flag Manipulation Tricks

```nasm
section .text
    ; Set carry flag without affecting other registers
    stc                        ; Set carry flag
    
    ; Clear carry flag
    clc                        ; Clear carry flag
    
    ; Complement carry flag
    cmc                        ; Complement carry flag
    
    ; Copy carry to register bit
    setc al                    ; AL = 1 if CF=1, else 0
    
    ; Add with carry trick for multi-precision
    mov eax, [low_part1]
    add eax, [low_part2]       ; Sets CF if overflow
    mov [result_low], eax
    
    mov eax, [high_part1]
    adc eax, [high_part2]      ; Add with carry from previous
    mov [result_high], eax
    
    ; Rotate through carry for extended shifts
    mov eax, [value_high]
    mov ebx, [value_low]
    shr eax, 1                 ; Shift high part, CF gets LSB
    rcr ebx, 1                 ; Rotate low part with carry
````

### Branchless Conditional Execution

```nasm
section .text
    ; Conditional negate without branch
    ; if (condition) x = -x
    mov eax, 42                ; Value to conditionally negate
    xor ebx, ebx
    test byte [condition], 1   ; Check condition
    setnz bl                   ; EBX = 1 if condition true
    neg ebx                    ; EBX = 0 or -1 (all bits set)
    
    xor eax, ebx               ; Flip bits if condition true
    sub eax, ebx               ; Add 1 if condition true
    ; Result: -42 if condition, 42 otherwise
    
    ; Conditional increment without branch
    mov eax, [counter]
    test byte [condition], 1
    setnz bl
    movzx ebx, bl
    add eax, ebx               ; Increment only if condition true
    
    ; Select between two values
    mov eax, [value_a]
    mov ebx, [value_b]
    test byte [condition], 1
    cmovnz eax, ebx            ; Select B if condition true
```

### Bit Field Extraction and Insertion

```nasm
section .text
    ; Extract bit field (bits 12-19, 8 bits wide)
    mov eax, [source_value]
    shr eax, 12                ; Shift to position
    and eax, 0xFF              ; Mask to field width
    
    ; Insert bit field (insert 8 bits at position 12)
    mov ebx, [target_value]
    and ebx, 0xFFF00FFF        ; Clear target bits (12-19)
    mov eax, [field_value]
    and eax, 0xFF              ; Ensure within field width
    shl eax, 12                ; Shift to position
    or ebx, eax                ; Insert field
    mov [target_value], ebx
    
    ; Extract with sign extension
    mov eax, [source_value]
    shl eax, 12                ; Shift sign bit to MSB
    sar eax, 24                ; Arithmetic shift (sign extend)
```

### Population Count in Parallel (SIMD)

```nasm
section .data
    align 16
    popcount_mask1: times 16 db 0x55  ; 01010101
    popcount_mask2: times 16 db 0x33  ; 00110011
    popcount_mask3: times 16 db 0x0F  ; 00001111

section .text
    ; Count bits in 16 bytes simultaneously
    movdqa xmm0, [input_data]     ; Load 16 bytes
    
    ; Count in pairs
    movdqa xmm1, xmm0
    psrlw xmm0, 1
    pand xmm0, [popcount_mask1]
    psubb xmm1, xmm0
    
    ; Count in nibbles
    movdqa xmm0, xmm1
    psrlw xmm1, 2
    pand xmm0, [popcount_mask2]
    pand xmm1, [popcount_mask2]
    paddb xmm0, xmm1
    
    ; Count in bytes
    movdqa xmm1, xmm0
    psrlw xmm0, 4
    paddb xmm0, xmm1
    pand xmm0, [popcount_mask3]
    
    ; Sum horizontally using psadbw
    pxor xmm1, xmm1
    psadbw xmm0, xmm1              ; Sum of absolute differences
    ; XMM0 now contains two 64-bit sums
```

### Fast Integer Log2

```nasm
section .text
    ; Calculate floor(log2(n)) using BSR
log2_floor:
    ; Input: EAX = value (must be > 0)
    ; Output: EAX = floor(log2(value))
    bsr eax, eax
    ret
    
    ; Calculate ceil(log2(n))
log2_ceil:
    ; Input: EAX = value (must be > 0)
    ; Output: EAX = ceil(log2(value))
    mov ebx, eax
    dec ebx
    bsr ecx, ebx               ; floor(log2(n-1))
    bsr edx, eax               ; floor(log2(n))
    cmp ecx, edx
    mov eax, edx
    jne .not_power_of_two
    ret
    
.not_power_of_two:
    inc eax
    ret
```

### Bit Reversal for FFT (Fast Fourier Transform)

```nasm
section .text
    ; Reverse bits in specific bit width (e.g., 10 bits for 1024-point FFT)
bit_reverse_n:
    ; Input: EAX = value, ECX = number of bits
    ; Output: EAX = bit-reversed value
    xor edx, edx               ; Result accumulator
    
.loop:
    shl edx, 1                 ; Shift result left
    bt eax, 0                  ; Test lowest bit of input
    adc edx, 0                 ; Add bit to result
    shr eax, 1                 ; Shift input right
    dec ecx
    jnz .loop
    
    mov eax, edx               ; Return result
    ret
```

### Hamming Distance (XOR Popcount)

```nasm
section .text
    ; Calculate number of differing bits between two values
hamming_distance:
    ; Input: EAX = value1, EBX = value2
    ; Output: EAX = number of different bits
    xor eax, ebx               ; XOR gives differing bits
    popcnt eax, eax            ; Count set bits
    ret
    
    ; Without POPCNT instruction
hamming_distance_soft:
    xor eax, ebx               ; Differing bits
    xor ecx, ecx               ; Counter
    
.loop:
    test eax, eax
    jz .done
    lea edx, [eax - 1]
    and eax, edx               ; Clear lowest bit
    inc ecx
    jmp .loop
    
.done:
    mov eax, ecx
    ret
```

### Bit Matrix Transpose

```nasm
section .text
    ; Transpose 8x8 bit matrix (64 bits)
transpose_8x8:
    ; Input: EAX (low 32), EDX (high 32) representing 8 rows of 8 bits
    ; Output: Transposed matrix
    
    ; This is complex but demonstrates advanced bit manipulation
    ; Stage 1: Swap 1-bit groups
    mov ebx, eax
    mov ecx, edx
    
    and ebx, 0xAA55AA55
    and eax, 0x55AA55AA
    shr ebx, 1
    shl eax, 1
    or eax, ebx
    
    and ecx, 0xAA55AA55
    and edx, 0x55AA55AA
    shr ecx, 1
    shl edx, 1
    or edx, ecx
    
    ; Stage 2: Swap 2-bit groups
    mov ebx, eax
    mov ecx, edx
    
    and ebx, 0xCCCC3333
    and eax, 0x3333CCCC
    shr ebx, 2
    shl eax, 2
    or eax, ebx
    
    and ecx, 0xCCCC3333
    and edx, 0x3333CCCC
    shr ecx, 2
    shl edx, 2
    or edx, ecx
    
    ; Stage 3: Swap 4-bit groups
    mov ebx, eax
    mov ecx, edx
    
    and ebx, 0xF0F00F0F
    and eax, 0x0F0FF0F0
    shr ebx, 4
    shl eax, 4
    or eax, ebx
    
    and ecx, 0xF0F00F0F
    and edx, 0x0F0FF0F0
    shr ecx, 4
    shl edx, 4
    or edx, ecx
    
    ret
```

### Next Permutation (Bit Permutation)

```nasm
section .text
    ; Find next value with same number of 1 bits
    ; Gosper's hack for generating combinations
next_permutation:
    ; Input: EAX = current bit pattern
    ; Output: EAX = next pattern with same popcount
    
    mov ebx, eax
    neg ebx
    and ebx, eax               ; Isolate rightmost 1
    
    add eax, ebx               ; Add isolated bit
    
    mov ecx, eax
    xor ecx, eax
    not ecx                    ; XOR and NOT
    
    shr ecx, 2                 ; Shift right by 2
    
    mov edx, ebx
    dec edx
    and ecx, edx               ; Create ripple
    
    or eax, ecx                ; Combine
    ret

; Example: 0b00010110 -> 0b00011010 -> 0b00011100 -> ...
```

### Constant-Time Comparison (Security)

```nasm
section .text
    ; Compare two values without branching (constant time)
    ; Used in cryptography to prevent timing attacks
constant_time_equal:
    ; Input: ESI = buffer1, EDI = buffer2, ECX = length
    ; Output: EAX = 0 if equal, non-zero if different
    xor eax, eax               ; Result accumulator
    
.loop:
    mov bl, [esi]
    xor bl, [edi]              ; XOR bytes
    or al, bl                  ; Accumulate differences
    inc esi
    inc edi
    dec ecx
    jnz .loop
    
    ; EAX is zero only if all bytes matched
    ret
```

### DeBruijn Sequence for Bit Scanning

```nasm
section .data
    ; 32-bit De Bruijn sequence for CTZ/CLZ
    align 4
    debruijn_ctz: db 0,1,28,2,29,14,24,3,30,22,20,15,25,17,4,8
                  db 31,27,13,23,21,19,16,7,26,12,18,6,11,5,10,9
    
    debruijn_clz: db 31,22,30,21,18,10,29,2,20,17,15,13,9,6,28,1
                  db 23,19,11,3,16,14,7,24,12,4,8,25,5,26,27,0

section .text
    ; Fast CTZ using De Bruijn
ctz_fast:
    ; Input: EAX = value (non-zero)
    mov edx, eax
    neg eax
    and eax, edx               ; Isolate lowest bit
    imul eax, 0x077CB531       ; De Bruijn constant
    shr eax, 27
    movzx eax, byte [debruijn_ctz + eax]
    ret
    
    ; Fast CLZ using De Bruijn
clz_fast:
    ; Input: EAX = value (non-zero)
    or eax, eax
    jz .zero_case
    
    ; Fill bits to the right of highest bit
    mov edx, eax
    shr edx, 1
    or eax, edx
    
    mov edx, eax
    shr edx, 2
    or eax, edx
    
    mov edx, eax
    shr edx, 4
    or eax, edx
    
    mov edx, eax
    shr edx, 8
    or eax, edx
    
    mov edx, eax
    shr edx, 16
    or eax, edx
    
    inc eax                    ; Add 1 to get power of 2
    imul eax, 0x07C4ACDD       ; De Bruijn constant
    shr eax, 27
    movzx eax, byte [debruijn_clz + eax]
    ret
    
.zero_case:
    mov eax, 32
    ret
```

**Key Points:**

- Hardware instructions (POPCNT, LZCNT, TZCNT, BSWAP, BMI) provide optimal performance when available
- Lookup tables trade memory for speed in bit counting operations
- XOR-based tricks enable swapping and comparing without temporary variables or branches
- Bit manipulation can replace expensive division/modulo with powers of two
- Branchless techniques using masks and arithmetic improve performance and security
- SIMD instructions enable parallel bit operations on multiple values simultaneously
- De Bruijn sequences provide fast bit scanning with minimal operations

**Important subtopics:**

- Advanced BMI2 instructions (MULX, RORX, SARX, SHLX, SHRX) for variable-count operations
- Bit-level parallelism with SIMD (SSE/AVX) for bulk bit operations
- Cryptographic applications requiring constant-time implementations
- Hardware feature detection (CPUID) for instruction set availability

---

