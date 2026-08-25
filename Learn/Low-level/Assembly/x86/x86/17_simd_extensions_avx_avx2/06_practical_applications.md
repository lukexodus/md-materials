## Practical Applications


### Matrix Multiplication

**Example** of 8x8 matrix multiplication using AVX:

```nasm
; Multiply two 8x8 matrices of floats
; rsi = matrix A (row-major)
; rdx = matrix B (row-major)
; rdi = result matrix C

matrix_multiply_8x8:
    xor r8, r8                    ; Row counter

row_loop:
    xor r9, r9                    ; Column counter
    
col_loop:
    vxorps ymm0, ymm0, ymm0       ; Accumulator = 0
    
    ; Compute dot product of row r8 with column r9
    xor r10, r10                  ; Element counter
    
dot_product:
    ; Load 8 elements from row of A
    lea rax, [rsi + r8*32]        ; Row r8 of A
    vmovaps ymm1, [rax]
    
    ; Load 8 elements from column of B (needs gathering or transposition)
    ; For simplicity, assume B is transposed beforehand
    lea rax, [rdx + r9*32]        ; Row r9 of B_transposed
    vmovaps ymm2, [rax]
    
    ; Multiply and accumulate
    vfmadd231ps ymm0, ymm1, ymm2  ; ymm0 += ymm1 * ymm2
    
    ; Horizontal sum to get final dot product
    vhaddps ymm0, ymm0, ymm0
    vhaddps ymm0, ymm0, ymm0
    vextractf128 xmm1, ymm0, 1
    vaddss xmm0, xmm0, xmm1
    
    ; Store result
    lea rax, [rdi + r8*32 + r9*4]
    vmovss [rax], xmm0
    
    inc r9
    cmp r9, 8
    jl col_loop
    
    inc r8
    cmp r8, 8
    jl row_loop
    
    vzeroupper
    ret
```

### Image Processing: Brightness Adjustment

**Example** of adjusting brightness for 8 pixels simultaneously:

```nasm
; Adjust brightness of RGB image (packed bytes)
; rsi = source image (RGB bytes)
; rdi = destination image
; rcx = pixel count (multiple of 32)
; ymm15 = brightness adjustment factor (broadcasted)

brightness_adjust:
    shr rcx, 5                    ; Process 32 bytes at a time
    
process_loop:
    ; Load 32 bytes (10-11 RGB pixels, simplified)
    vmovdqu ymm0, [rsi]
    
    ; Unpack to words for processing
    vpxor ymm1, ymm1, ymm1        ; Zero register
    vpunpcklbw ymm2, ymm0, ymm1   ; Low 16 bytes -> words
    vpunpckhbw ymm3, ymm0, ymm1   ; High 16 bytes -> words
    
    ; Convert to dwords for float conversion
    vpunpcklwd ymm4, ymm2, ymm1   ; Low words -> dwords
    vpunpckhwd ymm5, ymm2, ymm1   ; High words -> dwords
    vpunpcklwd ymm6, ymm3, ymm1
    vpunpckhwd ymm7, ymm3, ymm1
    
    ; Convert to float and apply brightness
    vcvtdq2ps ymm4, ymm4
    vcvtdq2ps ymm5, ymm5
    vcvtdq2ps ymm6, ymm6
    vcvtdq2ps ymm7, ymm7
    
    vmulps ymm4, ymm4, ymm15      ; Apply brightness factor
    vmulps ymm5, ymm5, ymm15
    vmulps ymm6, ymm6, ymm15
    vmulps ymm7, ymm7, ymm15
    
    ; Convert back to integers with saturation
    vcvtps2dq ymm4, ymm4
    vcvtps2dq ymm5, ymm5
    vcvtps2dq ymm6, ymm6
    vcvtps2dq ymm7, ymm7
    
    ; Pack back to bytes
    vpackssdw ymm4, ymm4, ymm5    ; Dwords -> words
    vpackssdw ymm6, ymm6, ymm7
    vpackuswb ymm0, ymm4, ymm6    ; Words -> bytes (unsigned saturation)
    
    ; Store result
    vmovdqu [rdi], ymm0
    
    add rsi, 32
    add rdi, 32
    dec rcx
    jnz process_loop
    
    vzeroupper
    ret
```

### Audio Processing: Stereo Mixing

**Example** of mixing two stereo audio streams with volume control:

```nasm
; Mix two stereo float audio streams
; rsi = stream A (interleaved L/R floats)
; rdx = stream B (interleaved L/R floats)
; rdi = output stream
; rcx = sample count (multiple of 8)
; ymm14 = volume A (broadcasted)
; ymm15 = volume B (broadcasted)

audio_mix:
    shr rcx, 3                    ; Process 8 floats (4 stereo pairs) at a time
    
mix_loop:
    vmovaps ymm0, [rsi]           ; Load 8 samples from A
    vmovaps ymm1, [rdx]           ; Load 8 samples from B
    
    vmulps ymm0, ymm0, ymm14      ; Apply volume A
    vmulps ymm1, ymm1, ymm15      ; Apply volume B
    
    vaddps ymm0, ymm0, ymm1       ; Mix streams
    
    vmovaps [rdi], ymm0           ; Store mixed output
    
    add rsi, 32
    add rdx, 32
    add rdi, 32
    dec rcx
    jnz mix_loop
    
    vzeroupper
    ret
```

### Physics: Vector Operations

**Example** of computing 3D vector dot products for 8 pairs simultaneously:

```nasm
; Compute dot products of 8 pairs of 3D vectors
; rsi = array of 8 vectors A (each 12 bytes: x,y,z floats, aligned to 16 bytes)
; rdx = array of 8 vectors B
; rdi = output array of 8 dot products

dot_product_batch:
    ; Load X components of all 8 vectors
    vmovaps ymm0, [rsi]           ; A0.xyz, A1.x
    vmovaps ymm1, [rsi + 32]      ; A1.yz, A2.xyz
    vmovaps ymm2, [rsi + 64]      ; A2.x(?), A3.xyz, A4.x
    ; ... (complex extraction pattern for structure-of-arrays)
    
    ; Alternative: Process vectors individually but in SIMD
    ; Load and process 2 vectors at a time using 128-bit operations
    
    xor r8, r8                    ; Counter
    
vec_loop:
    ; Load vector A (x, y, z, padding)
    vmovaps xmm0, [rsi + r8*16]
    
    ; Load vector B (x, y, z, padding)
    vmovaps xmm1, [rdx + r8*16]
    
    ; Multiply components
    vmulps xmm0, xmm0, xmm1       ; [x*x, y*y, z*z, pad*pad]
    
    ; Horizontal add to compute dot product
    vhaddps xmm0, xmm0, xmm0      ; [x*x+y*y, z*z+pad*pad, ...]
    vhaddps xmm0, xmm0, xmm0      ; [dot, dot, dot, dot]
    
    ; Store result
    vmovss [rdi + r8*4], xmm0
    
    inc r8
    cmp r8, 8
    jl vec_loop
    
    vzeroupper
    ret
```

### Data Analytics: Parallel Reduction

**Example** of finding maximum value in array:

```nasm
; Find maximum float value in array
; rsi = array pointer
; rcx = element count (multiple of 8)
; Returns: xmm0 = maximum value

find_max:
    vmovaps ymm0, [rsi]           ; Initialize max with first 8 elements
    add rsi, 32
    sub rcx, 8
    
max_loop:
    vmovaps ymm1, [rsi]           ; Load next 8 elements
    vmaxps ymm0, ymm0, ymm1       ; Element-wise maximum
    
    add rsi, 32
    sub rcx, 8
    ja max_loop
    
    ; Reduce 8 maxima to single maximum
    vextractf128 xmm1, ymm0, 1    ; Extract upper 128 bits
    vmaxps xmm0, xmm0, xmm1       ; Max of upper and lower halves
    
    vshufps xmm1, xmm0, xmm0, 0x4E    ; Swap high/low 64 bits
    vmaxps xmm0, xmm0, xmm1
    
    vshufps xmm1, xmm0, xmm0, 0xB1    ; Swap adjacent pairs
    vmaxss xmm0, xmm0, xmm1       ; Scalar max
    
    vzeroupper
    ret
```

### String/Text Processing with AVX2

**Example** of case conversion (lowercase to uppercase):

```nasm
; Convert ASCII lowercase to uppercase
; rsi = source string
; rdi = destination string
; rcx = length (multiple of 32)

to_uppercase:
    ; Create comparison vectors
    vpbroadcastb ymm2, byte ['a']     ; 0x61 repeated
    vpbroadcastb ymm3, byte ['z']     ; 0x7A repeated
    vpbroadcastb ymm4, byte [32]      ; Space between upper/lower case
    
convert_loop:
    vmovdqu ymm0, [rsi]               ; Load 32 characters
    
    ; Check if characters are in range ['a', 'z']
    vpcmpgtb ymm5, ymm0, ymm2         ; char > 'a' - 1
    vpcmpgtb ymm6, ymm3, ymm0         ; 'z' > char
    vpand ymm5, ymm5, ymm6            ; Combine: 'a' <= char <= 'z'
    
    ; Subtract 32 from lowercase characters
    vpand ymm6, ymm5, ymm4            ; Mask of 32 where lowercase
    vpsubb ymm0, ymm0, ymm6           ; Convert to uppercase
    
    vmovdqu [rdi], ymm0               ; Store result
    
    add rsi, 32
    add rdi, 32
    sub rcx, 32
    ja convert_loop
    
    vzeroupper
    ret
```

### Histogram Computation

**Example** of computing histogram with gather operations (AVX2):

```nasm
; Increment histogram bins based on pixel values
; rsi = pixel array (bytes)
; rdi = histogram array (256 dwords)
; rcx = pixel count

; Note: Gather-based histogram is complex; showing simplified approach
; Real implementation would use scalar or alternative SIMD strategy

histogram_increment:
    ; Process pixels in groups
    xor r8, r8
    
pixel_loop:
    movzx rax, byte [rsi + r8]        ; Load pixel value
    inc dword [rdi + rax*4]           ; Increment histogram bin
    
    inc r8
    cmp r8, rcx
    jl pixel_loop
    
    ret

; More efficient: Use AVX2 for batch loads and conditional processing
histogram_avx2:
    ; ... complex implementation using vpgatherdd and masking ...
```

