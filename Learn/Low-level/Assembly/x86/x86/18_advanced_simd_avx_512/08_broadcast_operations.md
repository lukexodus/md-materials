## Broadcast Operations


Broadcasting replicates a single value to all elements of a vector register, eliminating the need for explicit data duplication. AVX-512 significantly enhances broadcasting capabilities compared to earlier instruction sets.

### Memory Broadcast

AVX-512 allows broadcasting from memory directly during load operations using the `{1toX}` syntax, where X is the number of elements.

**Broadcast Notation:**

- `{1to16}` - Broadcast to 16 elements (32-bit elements in ZMM)
- `{1to8}` - Broadcast to 8 elements (64-bit elements in ZMM)
- `{1to4}` - Broadcast to 4 elements (128-bit vectors or 128-bit elements)
- `{1to2}` - Broadcast to 2 elements (256-bit vectors with 128-bit elements)

### Broadcast Instructions

**VBROADCAST Family (Legacy AVX2/AVX-512):**

`VBROADCASTSS zmm1, xmm2/m32` - Broadcast single-precision scalar to ZMM `VBROADCASTSD zmm1, xmm2/m64` - Broadcast double-precision scalar to ZMM `VBROADCASTF32X2 zmm1, xmm2/m64` - Broadcast 2 single-precision values `VBROADCASTF32X4 zmm1, m128` - Broadcast 128-bit (4 floats) across ZMM `VBROADCASTF32X8 zmm1, m256` - Broadcast 256-bit (8 floats) `VBROADCASTF64X2 zmm1, m128` - Broadcast 2 double-precision values `VBROADCASTF64X4 zmm1, m256` - Broadcast 4 double-precision values

**Integer Broadcasts:**

`VPBROADCASTB zmm1, xmm2/m8` - Broadcast byte `VPBROADCASTW zmm1, xmm2/m16` - Broadcast word `VPBROADCASTD zmm1, xmm2/m32` - Broadcast doubleword `VPBROADCASTQ zmm1, xmm2/m64` - Broadcast quadword

`VPBROADCASTMB2Q zmm1, k1` - Broadcast mask to quadwords `VPBROADCASTMW2D zmm1, k1` - Broadcast mask to doublewords

### Embedded Broadcast in Arithmetic Operations

AVX-512's most powerful broadcasting feature allows operations to broadcast memory operands inline:

**Syntax:**

```asm
vaddps zmm1, zmm2, [mem]{1to16}    ; Broadcast 32-bit value to all 16 elements
vaddpd zmm1, zmm2, [mem]{1to8}     ; Broadcast 64-bit value to all 8 elements
vfmadd213ps zmm1, zmm2, [mem]{1to16}  ; FMA with broadcast
```

**Supported Operations:**

Embedded broadcast works with most arithmetic, logical, and comparison operations:

- Addition, subtraction, multiplication, division
- FMA operations
- Min/max operations
- Logical operations (AND, OR, XOR)
- Comparisons
- Blending operations

**Element Size Compatibility:**

The broadcast size must match the element size of the operation:

- 32-bit operations use `{1to16}` for 512-bit or `{1to8}` for 256-bit vectors
- 64-bit operations use `{1to8}` for 512-bit or `{1to4}` for 256-bit vectors

### Code Examples with Broadcast

**Example 1: Scalar-Vector Multiplication**

```asm
section .data
    align 64
    vector: dd 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0
           dd 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0
    scalar: dd 2.5
    result: times 16 dd 0

section .text
    vmovaps zmm0, [vector]
    
    ; Multiply vector by scalar (broadcast from memory)
    vmulps zmm1, zmm0, [scalar]{1to16}
    vmovaps [result], zmm1
```

**Output:** result = [2.5, 5.0, 7.5, 10.0, 12.5, 15.0, 17.5, 20.0, 22.5, 25.0, 27.5, 30.0, 32.5, 35.0, 37.5, 40.0]

**Example 2: Add Constant to All Elements**

```asm
section .data
    align 64
    array: dd 100.0, 200.0, 300.0, 400.0, 500.0, 600.0, 700.0, 800.0
          dd 900.0, 1000.0, 1100.0, 1200.0, 1300.0, 1400.0, 1500.0, 1600.0
    offset: dd 42.0
    result: times 16 dd 0

section .text
    vmovaps zmm0, [array]
    vaddps zmm1, zmm0, [offset]{1to16}
    vmovaps [result], zmm1
```

**Output:** Each element increased by 42.0

**Example 3: Matrix-Scalar Operations**

```asm
section .data
    align 64
    matrix: dd 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0
           dd 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0
    divisor: dd 4.0
    result: times 16 dd 0

section .text
    vmovaps zmm0, [matrix]
    
    ; Divide all elements by scalar
    vdivps zmm1, zmm0, [divisor]{1to16}
    vmovaps [result], zmm1
```

**Output:** Each element divided by 4.0

**Example 4: Fused Multiply-Add with Broadcast**

```asm
section .data
    align 64
    x_vals: dd 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0
           dd 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0
    slope: dd 2.0
    intercept: dd 3.0
    result: times 16 dd 0

section .text
    vmovaps zmm0, [x_vals]
    
    ; Compute y = slope * x + intercept
    ; Using vfmadd132ps: dest = dest * src1 + src2
    vmovaps zmm1, zmm0               ; Copy x to zmm1
    vfmadd132ps zmm1, [intercept]{1to16}, [slope]{1to16}
    vmovaps [result], zmm1
```

**Output:** result = 2.0 × x + 3.0 for each element

**Example 5: Integer Broadcast**

```asm
section .data
    align 64
    values: dd 10, 20, 30, 40, 50, 60, 70, 80
           dd 90, 100, 110, 120, 130, 140, 150, 160
    multiplier: dd 5
    result: times 16 dd 0

section .text
    vmovdqa32 zmm0, [values]
    
    ; Multiply integers with broadcast
    vpmulld zmm1, zmm0, [multiplier]{1to16}
    vmovdqa32 [result], zmm1
```

**Output:** Each integer multiplied by 5

**Example 6: Comparison with Broadcast**

```asm
section .data
    align 64
    values: dd 5.0, 15.0, 25.0, 35.0, 45.0, 55.0, 65.0, 75.0
           dd 85.0, 95.0, 105.0, 115.0, 125.0, 135.0, 145.0, 155.0
    threshold: dd 50.0

section .text
    vmovaps zmm0, [values]
    
    ; Compare: which values are greater than threshold?
    vcmpps k1, zmm0, [threshold]{1to16}, 30  ; 30 = NLE_US (not less or equal)
    
    ; k1 now contains mask where values > 50.0
    ; Can be used for masked operations
```

**Output:** k1 mask = 0b1111111100000000 (elements 8-15 are > 50.0)

**Example 7: Broadcast from Register**

```asm
section .data
    align 64
    result: times 16 dd 0

section .text
    mov eax, 0x42C80000              ; 100.0 in IEEE 754
    vmovd xmm0, eax
    vbroadcastss zmm1, xmm0          ; Broadcast to all 16 elements
    vmovaps [result], zmm1
```

**Output:** result = [100.0, 100.0, 100.0, ..., 100.0] (16 copies)

**Example 8: Broadcast Pairs**

```asm
section .data
    align 64
    pair: dd 1.0, 2.0                ; Two values
    result: times 16 dd 0

section .text
    vbroadcastf32x2 zmm0, [pair]     ; Broadcast pair across register
    vmovaps [result], zmm0
```

**Output:** result = [1.0, 2.0, 1.0, 2.0, 1.0, 2.0, 1.0, 2.0, 1.0, 2.0, 1.0, 2.0, 1.0, 2.0, 1.0, 2.0]

**Example 9: Masked Operation with Broadcast**

```asm
section .data
    align 64
    values: dd 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0
           dd 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0
    addend: dd 100.0
    result: times 16 dd 0

section .text
    vmovaps zmm0, [values]
    mov ax, 0xAAAA                   ; Mask: 0b1010101010101010
    kmovw k1, eax
    
    ; Add 100 to every other element (merge masking)
    vaddps zmm0 {k1}, zmm0, [addend]{1to16}
    vmovaps [result], zmm0
```

**Output:** Odd-indexed elements (1, 3, 5, etc.) increased by 100.0, even-indexed unchanged

**Example 10: Zero-Masking with Broadcast**

```asm
section .data
    align 64
    values: dd 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0
           dd 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0
    multiplier: dd 10.0
    result: times 16 dd 0

section .text
    vmovaps zmm0, [values]
    mov ax, 0x00FF                   ; Mask: first 8 elements
    kmovw k1, eax
    
    ; Multiply first 8 elements by 10, zero the rest
    vmulps zmm1 {k1}{z}, zmm0, [multiplier]{1to16}
    vmovaps [result], zmm1
```

**Output:** result = [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

