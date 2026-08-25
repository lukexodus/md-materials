## Permute Operations


AVX-512 dramatically enhances data permutation capabilities, providing fine-grained control over element rearrangement within and across registers.

### Permute Instructions

**VPERMD/VPERMQ - Permute Doublewords/Quadwords**

`VPERMD zmm1 {k1}{z}, zmm2, zmm3/m512/m32bcst` - Permute 32-bit elements `VPERMQ zmm1 {k1}{z}, zmm2, zmm3/m512/m64bcst` - Permute 64-bit elements

Each element in zmm2 contains an index specifying which element from zmm3 to select.

**VPERMPS/VPERMPD - Permute Single/Double Precision****

`VPERMPS zmm1 {k1}{z}, zmm2, zmm3/m512/m32bcst` - Permute floats `VPERMPD zmm1 {k1}{z}, zmm2, zmm3/m512/m64bcst` - Permute doubles

These provide variable permutation based on index vectors, enabling arbitrary element rearrangement.

**VPERMI2D/VPERMI2Q/VPERMI2PS/VPERMI2PD - Two-Source Permute**

`VPERMI2D zmm1 {k1}{z}, zmm2, zmm3/m512/m32bcst` - Permute doublewords from two sources `VPERMI2Q zmm1 {k1}{z}, zmm2, zmm3/m512/m64bcst` - Permute quadwords from two sources `VPERMI2PS zmm1 {k1}{z}, zmm2, zmm3/m512/m32bcst` - Permute single-precision from two sources `VPERMI2PD zmm1 {k1}{z}, zmm2, zmm3/m512/m64bcst` - Permute double-precision from two sources

The index vector (zmm1) selects elements from two source vectors (zmm2 and zmm3), providing 32-element or 16-element selection space for 32-bit or 64-bit elements respectively.

Operation (for VPERMI2D):

```
For i = 0 to 15:
    index = zmm1[i*32+4:i*32]    ; 5-bit index (0-31)
    if (index < 16)
        zmm1[i*32+31:i*32] = zmm2[index*32+31:index*32]
    else
        zmm1[i*32+31:i*32] = zmm3[(index-16)*32+31:(index-16)*32]
```

**VPERMT2D/VPERMT2Q/VPERMT2PS/VPERMT2PD - Two-Source Permute (Alternative Form)**

`VPERMT2D zmm1 {k1}{z}, zmm2, zmm3/m512/m32bcst` `VPERMT2Q zmm1 {k1}{z}, zmm2, zmm3/m512/m64bcst` `VPERMT2PS zmm1 {k1}{z}, zmm2, zmm3/m512/m32bcst` `VPERMT2PD zmm1 {k1}{z}, zmm2, zmm3/m512/m64bcst`

Similar to VPERMI2*, but with operand roles swapped. The index vector is zmm2, and sources are zmm1 and zmm3.

**VPERMB/VPERMW - Byte/Word Permutation (AVX-512VBMI/BW)**

`VPERMB zmm1 {k1}{z}, zmm2, zmm3/m512` - Permute bytes `VPERMW zmm1 {k1}{z}, zmm2, zmm3/m512` - Permute words

Enable fine-grained 8-bit and 16-bit element permutation.

VPERMB operation:

```
For i = 0 to 63:
    index = zmm2[i*8+5:i*8]      ; 6-bit index (0-63)
    zmm1[i*8+7:i*8] = zmm3[index*8+7:index*8]
```

**VPERMI2B/VPERMI2W - Two-Source Byte/Word Permutation**

`VPERMI2B zmm1 {k1}{z}, zmm2, zmm3/m512` `VPERMI2W zmm1 {k1}{z}, zmm2, zmm3/m512`

Two-source permutation for bytes and words, enabling selection from 128 bytes or 64 words total.

**VSHUFF32X4/VSHUFF64X2/VSHUFI32X4/VSHUFI64X2 - Shuffle 128-bit Lanes**

`VSHUFF32X4 zmm1 {k1}{z}, zmm2, zmm3/m512/m32bcst, imm8` - Shuffle float 128-bit lanes `VSHUFF64X2 zmm1 {k1}{z}, zmm2, zmm3/m512/m64bcst, imm8` - Shuffle double 128-bit lanes `VSHUFI32X4 zmm1 {k1}{z}, zmm2, zmm3/m512, imm8` - Shuffle integer 128-bit lanes `VSHUFI64X2 zmm1 {k1}{z}, zmm2, zmm3/m512, imm8` - Shuffle 64-bit pair lanes

These shuffle entire 128-bit lanes (4 lanes in 512-bit register) based on immediate control byte.

Immediate byte encoding (for VSHUFF32X4):

- Bits 1-0: Select lane for destination bits 127:0
- Bits 3-2: Select lane for destination bits 255:128
- Bits 5-4: Select lane for destination bits 383:256
- Bits 7-6: Select lane for destination bits 511:384

Lanes 0-1 come from zmm2, lanes 2-3 come from zmm3.

**VALIGNQ/VALIGND - Align Quadwords/Doublewords**

`VALIGNQ zmm1 {k1}{z}, zmm2, zmm3/m512/m64bcst, imm8` - Align quadwords `VALIGND zmm1 {k1}{z}, zmm2, zmm3/m512/m32bcst, imm8` - Align doublewords

Concatenates two vectors and extracts aligned result, similar to PALIGNR but operating on larger elements.

Operation (for VALIGND):

```
temp[1023:0] = {zmm2, zmm3}
shift_count = imm8 * 32
temp = temp >> shift_count
zmm1 = temp[511:0]
```

**VPSHUFBITQMB - Shuffle Bits (AVX-512BITALG)**

`VPSHUFBITQMB k1 {k2}, zmm2, zmm3/m512`

Performs bit-level shuffling within quadwords, enabling complex bit permutations.

### Cross-Lane Permutations

AVX-512 eliminates many of the cross-lane restrictions present in AVX/AVX2, allowing more flexible data movement.

**VPERMQ with Immediate**

`VPERMQ zmm1 {k1}{z}, zmm2/m512/m64bcst, imm8` - Permute quadwords with immediate

For 512-bit operation with 8 quadwords, the immediate provides 2 bits per output element (selecting from 4 groups).

**VPERMPD with Immediate**

`VPERMPD zmm1 {k1}{z}, zmm2/m512/m64bcst, imm8` - Permute doubles with immediate

### Compress and Expand Operations

AVX-512 introduces unique compress and expand instructions for scatter/gather-like operations within registers.

**VPCOMPRESSD/VPCOMPRESSQ - Compress Packed Integers**

`VPCOMPRESSD zmm1/m512 {k1}{z}, zmm2` - Compress doublewords `VPCOMPRESSQ zmm1/m512 {k1}{z}, zmm2` - Compress quadwords

Packs elements selected by the mask to the low portion of the destination, leaving upper portions zeroed or unchanged.

Operation (for VPCOMPRESSD):

```
dest_index = 0
For i = 0 to 15:
    if (k1[i] == 1):
        zmm1[dest_index*32+31:dest_index*32] = zmm2[i*32+31:i*32]
        dest_index++
For remaining positions:
    zmm1[...] = 0 (if zero-masking) or unchanged (if merge-masking)
```

**VCOMPRESSPS/VCOMPRESSPD - Compress Packed Floats**

`VCOMPRESSPS zmm1/m512 {k1}{z}, zmm2` - Compress single-precision `VCOMPRESSPD zmm1/m512 {k1}{z}, zmm2` - Compress double-precision

**VPEXPANDD/VPEXPANDQ - Expand Packed Integers**

`VPEXPANDD zmm1 {k1}{z}, zmm2/m512` - Expand doublewords `VPEXPANDQ zmm1 {k1}{z}, zmm2/m512` - Expand quadwords

Inverse of compress: reads packed elements from low portion of source and scatters them to positions indicated by the mask.

Operation (for VPEXPANDD):

```
src_index = 0
For i = 0 to 15:
    if (k1[i] == 1):
        zmm1[i*32+31:i*32] = zmm2[src_index*32+31:src_index*32]
        src_index++
    else:
        zmm1[i*32+31:i*32] = 0 (if zero-masking) or unchanged
```

**VEXPANDPS/VEXPANDPD - Expand Packed Floats**

`VEXPANDPS zmm1 {k1}{z}, zmm2/m512` - Expand single-precision `VEXPANDPD zmm1 {k1}{z}, zmm2/m512` - Expand double-precision

### Code Examples with Permute Operations

**Example 1: Reverse Vector Elements**

```asm
section .data
    align 64
    values: dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
    indices: dd 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0
    result: times 16 dd 0

section .text
    vmovdqa32 zmm0, [values]         ; Load values
    vmovdqa32 zmm1, [indices]        ; Load reverse indices
    vpermd zmm2, zmm1, zmm0          ; Permute
    vmovdqa32 [result], zmm2
```

**Output:** result = [16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]

**Example 2: Interleave Two Vectors**

```asm
section .data
    align 64
    vec_a: dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
    vec_b: dd 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32
    ; Indices to interleave: [a0, b0, a1, b1, a2, b2, ...]
    indices: dd 0, 16, 1, 17, 2, 18, 3, 19, 4, 20, 5, 21, 6, 22, 7, 23
    result: times 16 dd 0

section .text
    vmovdqa32 zmm0, [vec_a]          ; Source 1
    vmovdqa32 zmm1, [vec_b]          ; Source 2
    vmovdqa32 zmm2, [indices]        ; Index vector
    vpermi2d zmm2, zmm0, zmm1        ; Two-source permute
    vmovdqa32 [result], zmm2
```

**Output:** result = [1, 17, 2, 18, 3, 19, 4, 20, 5, 21, 6, 22, 7, 23, 8, 24]

**Example 3: Gather Even and Odd Elements**

```asm
section .data
    align 64
    values: dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
    even_indices: dd 0, 2, 4, 6, 8, 10, 12, 14, 0, 0, 0, 0, 0, 0, 0, 0
    odd_indices: dd 1, 3, 5, 7, 9, 11, 13, 15, 0, 0, 0, 0, 0, 0, 0, 0
    result_even: times 16 dd 0
    result_odd: times 16 dd 0

section .text
    vmovdqa32 zmm0, [values]
    vmovdqa32 zmm1, [even_indices]
    vmovdqa32 zmm2, [odd_indices]
    
    vpermd zmm3, zmm1, zmm0          ; Gather even elements
    vpermd zmm4, zmm2, zmm0          ; Gather odd elements
    
    vmovdqa32 [result_even], zmm3
    vmovdqa32 [result_odd], zmm4
```

**Output:**

- result_even = [1, 3, 5, 7, 9, 11, 13, 15, 1, 1, 1, 1, 1, 1, 1, 1]
- result_odd = [2, 4, 6, 8, 10, 12, 14, 16, 2, 2, 2, 2, 2, 2, 2, 2]

**Example 4: Rotate Elements**

```asm
section .data
    align 64
    values: dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
    ; Rotate left by 3 positions
    rot_indices: dd 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0, 1, 2
    result: times 16 dd 0

section .text
    vmovdqa32 zmm0, [values]
    vmovdqa32 zmm1, [rot_indices]
    vpermd zmm2, zmm1, zmm0
    vmovdqa32 [result], zmm2
```

**Output:** result = [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 1, 2, 3]

**Example 5: Shuffle 128-bit Lanes**

```asm
section .data
    align 64
    data: dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
    result: times 16 dd 0

section .text
    vmovdqa32 zmm0, [data]
    vmovdqa32 zmm1, zmm0
    
    ; Swap middle two 128-bit lanes
    ; Original lanes: [0:1,2,3,4], [1:5,6,7,8], [2:9,10,11,12], [3:13,14,15,16]
    ; Desired order: lane 0, lane 2, lane 1, lane 3
    ; Control byte: 11 01 10 00 = 0b11011000 = 0xD8
    vshufi32x4 zmm2, zmm0, zmm1, 0xD8
    vmovdqa32 [result], zmm2
```

**Output:** result = [1, 2, 3, 4, 9, 10, 11, 12, 5, 6, 7, 8, 13, 14, 15, 16]

**Example 6: Align Vectors**

```asm
section .data
    align 64
    vec1: dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
    vec2: dd 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32
    result: times 16 dd 0

section .text
    vmovdqa32 zmm0, [vec1]
    vmovdqa32 zmm1, [vec2]
    
    ; Align by 3 doublewords (extract elements 3-18 from concatenation)
    valignd zmm2, zmm0, zmm1, 3
    vmovdqa32 [result], zmm2
```

**Output:** result = [20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 1, 2, 3]

The concatenation is [vec2:vec1] = [17...32, 1...16], shifted right by 3 dwords.

**Example 7: Compress Active Elements**

```asm
section .data
    align 64
    values: dd 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160
    result: times 16 dd 0

section .text
    vmovdqa32 zmm0, [values]
    
    ; Create mask: keep elements at positions 0, 2, 5, 7, 10, 13
    mov ax, 0b0010010010100101     ; Binary mask
    kmovw k1, eax
    
    ; Compress: pack selected elements to beginning
    vpcompressd zmm1 {k1}{z}, zmm0
    vmovdqa32 [result], zmm1
```

**Output:** result = [10, 30, 60, 80, 110, 140, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

Selected elements are packed to the left, rest zeroed (due to {z}).

**Example 8: Expand Sparse Elements**

```asm
section .data
    align 64
    packed: dd 100, 200, 300, 400, 500, 600, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    result: times 16 dd 0

section .text
    vmovdqa32 zmm0, [packed]
    
    ; Expand to positions 1, 3, 5, 8, 11, 14
    mov ax, 0b0100100010101010
    kmovw k1, eax
    
    ; Expand: scatter packed elements to masked positions
    vpexpandd zmm1 {k1}{z}, zmm0
    vmovdqa32 [result], zmm1
```

**Output:** result = [0, 100, 0, 200, 0, 300, 0, 0, 400, 0, 0, 500, 0, 0, 600, 0]

**Example 9: Byte-Level Permutation (AVX-512VBMI)**

```asm
section .data
    align 64
    ; Create ASCII string with characters
    text: db "Hello World! AVX", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    
    ; Indices to reverse first 16 bytes
    indices: db 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0
            times 48 db 0
    
    result: times 64 db 0

section .text
    vmovdqa64 zmm0, [text]
    vmovdqa64 zmm1, [indices]
    vpermb zmm2, zmm1, zmm0          ; Permute bytes
    vmovdqa64 [result], zmm2
```

**Output:** result first 16 bytes = "XVA !dlroW olleH" (reversed)

**Example 10: Matrix Transpose (4x4 floats using permute)**

```asm
section .data
    align 64
    ; 4x4 matrix stored row-major
    matrix: dd 1.0, 2.0, 3.0, 4.0        ; Row 0
           dd 5.0, 6.0, 7.0, 8.0         ; Row 1
           dd 9.0, 10.0, 11.0, 12.0      ; Row 2
           dd 13.0, 14.0, 15.0, 16.0     ; Row 3
           times 12 dd 0.0               ; Padding to 64 bytes
    
    result: times 16 dd 0

section .text
    ; Load matrix rows
    vmovaps xmm0, [matrix]           ; Row 0
    vmovaps xmm1, [matrix + 16]      ; Row 1
    vmovaps xmm2, [matrix + 32]      ; Row 2
    vmovaps xmm3, [matrix + 48]      ; Row 3
    
    ; Transpose using unpacks
    vunpcklps xmm4, xmm0, xmm1       ; xmm4 = [1, 5, 2, 6]
    vunpckhps xmm5, xmm0, xmm1       ; xmm5 = [3, 7, 4, 8]
    vunpcklps xmm6, xmm2, xmm3       ; xmm6 = [9, 13, 10, 14]
    vunpckhps xmm7, xmm2, xmm3       ; xmm7 = [11, 15, 12, 16]
    
    vmovlhps xmm0, xmm4, xmm6        ; xmm0 = [1, 5, 9, 13] - Column 0
    vmovhlps xmm1, xmm6, xmm4        ; xmm1 = [2, 6, 10, 14] - Column 1
    vmovlhps xmm2, xmm5, xmm7        ; xmm2 = [3, 7, 11, 15] - Column 2
    vmovhlps xmm3, xmm7, xmm5        ; xmm3 = [4, 8, 12, 16] - Column 3
    
    vmovaps [result], xmm0
    vmovaps [result + 16], xmm1
    vmovaps [result + 32], xmm2
    vmovaps [result + 48], xmm3
```

**Output:** Matrix transposed (rows become columns)

