## Extended Vector Operations


AVX and AVX2 provide expanded functionality beyond register width increases, including new operation categories and enhanced existing operations.

### Arithmetic Operations

AVX extends SSE arithmetic to 256-bit width, processing twice as many elements simultaneously.

#### Floating-Point Addition/Subtraction

**VADDPS/VADDPD** - Add Packed Floats/Doubles

```nasm
vaddps ymm0, ymm1, ymm2   ; Add 8 single-precision floats
vaddpd ymm0, ymm1, ymm2   ; Add 4 double-precision doubles
vaddps xmm0, xmm1, xmm2   ; Add 4 single-precision floats (128-bit)
```

**VSUBPS/VSUBPD** - Subtract Packed Floats/Doubles

```nasm
vsubps ymm0, ymm1, ymm2   ; Subtract 8 floats
vsubpd ymm0, ymm1, ymm2   ; Subtract 4 doubles
```

**VADDSUBPS/VADDSUBPD** - Add/Subtract Packed

```nasm
vaddsubps ymm0, ymm1, ymm2    ; Alternating add/sub operations
; Result[0] = YMM1[0] - YMM2[0]
; Result[1] = YMM1[1] + YMM2[1]
; Result[2] = YMM1[2] - YMM2[2]
; Result[3] = YMM1[3] + YMM2[3]
; Pattern repeats for elements 4-7
```

#### Floating-Point Multiplication/Division

**VMULPS/VMULPD** - Multiply Packed Floats/Doubles

```nasm
vmulps ymm0, ymm1, ymm2   ; Multiply 8 floats
vmulpd ymm0, ymm1, ymm2   ; Multiply 4 doubles
```

**VDIVPS/VDIVPD** - Divide Packed Floats/Doubles

```nasm
vdivps ymm0, ymm1, ymm2   ; Divide 8 floats: YMM1 / YMM2
vdivpd ymm0, ymm1, ymm2   ; Divide 4 doubles: YMM1 / YMM2
```

#### Fused Multiply-Add (FMA)

FMA instructions (technically part of FMA3/FMA4 extensions, often grouped with AVX2) perform a*b+c in a single operation with improved precision and performance.

**VFMADD** variants - Multiply and Add

```nasm
vfmadd132ps ymm0, ymm1, ymm2  ; YMM0 = YMM0 * YMM2 + YMM1
vfmadd213ps ymm0, ymm1, ymm2  ; YMM0 = YMM1 * YMM0 + YMM2
vfmadd231ps ymm0, ymm1, ymm2  ; YMM0 = YMM1 * YMM2 + YMM0
```

The three-digit suffix indicates which operand is multiplied/added:

- **132**: (dest * src2) + src1
- **213**: (src1 * dest) + src2
- **231**: (src1 * src2) + dest

**VFMSUB** variants - Multiply and Subtract

```nasm
vfmsub132ps ymm0, ymm1, ymm2  ; YMM0 = YMM0 * YMM2 - YMM1
vfmsub213ps ymm0, ymm1, ymm2  ; YMM0 = YMM1 * YMM0 - YMM2
vfmsub231ps ymm0, ymm1, ymm2  ; YMM0 = YMM1 * YMM2 - YMM0
```

**VFNMADD/VFNMSUB** - Negated multiply-add/subtract variants also exist.

**Example** of FMA usage:

```nasm
; Compute: result = a * b + c (8 floats)
; Traditional approach (2 operations):
vmulps ymm0, ymm1, ymm2       ; ymm0 = a * b
vaddps ymm0, ymm0, ymm3       ; ymm0 = (a * b) + c

; FMA approach (1 operation, better precision):
vfmadd231ps ymm3, ymm1, ymm2  ; ymm3 = a * b + ymm3
vmovaps ymm0, ymm3            ; Move result to ymm0
; Or directly:
vfmadd213ps ymm1, ymm2, ymm3  ; ymm1 = ymm2 * ymm1 + ymm3
```

### AVX2 Integer Operations

AVX2 extends integer SIMD operations to 256-bit width, processing double the number of integer elements compared to SSE.

#### Integer Addition/Subtraction

**VPADDB/VPADDW/VPADDD/VPADDQ** - Add Packed Integers

```nasm
vpaddb ymm0, ymm1, ymm2       ; Add 32 bytes
vpaddw ymm0, ymm1, ymm2       ; Add 16 words
vpaddd ymm0, ymm1, ymm2       ; Add 8 doublewords
vpaddq ymm0, ymm1, ymm2       ; Add 4 quadwords
```

**VPSUBB/VPSUBW/VPSUBD/VPSUBQ** - Subtract Packed Integers

```nasm
vpsubb ymm0, ymm1, ymm2       ; Subtract 32 bytes
vpsubw ymm0, ymm1, ymm2       ; Subtract 16 words
vpsubd ymm0, ymm1, ymm2       ; Subtract 8 doublewords
vpsubq ymm0, ymm1, ymm2       ; Subtract 4 quadwords
```

#### Saturating Arithmetic (AVX2)

**VPADDSB/VPADDSW** - Add with Saturation (Signed)

```nasm
vpaddsb ymm0, ymm1, ymm2      ; Add 32 signed bytes with saturation
vpaddsw ymm0, ymm1, ymm2      ; Add 16 signed words with saturation
```

**VPADDUSB/VPADDUSW** - Add with Saturation (Unsigned)

```nasm
vpaddusb ymm0, ymm1, ymm2     ; Add 32 unsigned bytes with saturation
vpaddusw ymm0, ymm1, ymm2     ; Add 16 unsigned words with saturation
```

**VPSUBSB/VPSUBSW** - Subtract with Saturation (Signed)

```nasm
vpsubsb ymm0, ymm1, ymm2      ; Subtract 32 signed bytes with saturation
vpsubsw ymm0, ymm1, ymm2      ; Subtract 16 signed words with saturation
```

**VPSUBUSB/VPSUBUSW** - Subtract with Saturation (Unsigned)

```nasm
vpsubusb ymm0, ymm1, ymm2     ; Subtract 32 unsigned bytes with saturation
vpsubusw ymm0, ymm1, ymm2     ; Subtract 16 unsigned words with saturation
```

#### Integer Multiplication (AVX2)

**VPMULLW** - Multiply Packed Signed Words (Low Result)

```nasm
vpmullw ymm0, ymm1, ymm2      ; Multiply 16 words, keep low 16 bits
```

**VPMULHW** - Multiply Packed Signed Words (High Result)

```nasm
vpmulhw ymm0, ymm1, ymm2      ; Multiply 16 signed words, keep high 16 bits
```

**VPMULHUW** - Multiply Packed Unsigned Words (High Result)

```nasm
vpmulhuw ymm0, ymm1, ymm2     ; Multiply 16 unsigned words, keep high 16 bits
```

**VPMULLD** - Multiply Packed Signed Doublewords (Low Result)

```nasm
vpmulld ymm0, ymm1, ymm2      ; Multiply 8 doublewords, keep low 32 bits
```

**VPMULDQ** - Multiply Packed Signed Doublewords to Quadwords

```nasm
vpmuldq ymm0, ymm1, ymm2      ; Multiply 4 pairs of dwords to produce 4 qwords
; Result[0] = YMM1[0] * YMM2[0] (64-bit result)
; Result[1] = YMM1[2] * YMM2[2] (64-bit result)
; Result[2] = YMM1[4] * YMM2[4] (64-bit result)
; Result[3] = YMM1[6] * YMM2[6] (64-bit result)
; Even-indexed elements only
```

**VPMULUDQ** - Multiply Packed Unsigned Doublewords to Quadwords

```nasm
vpmuludq ymm0, ymm1, ymm2     ; Multiply 4 pairs of unsigned dwords
```

### Horizontal Operations

Horizontal operations perform computations across elements within a single vector, rather than between corresponding elements of two vectors.

#### Horizontal Add/Subtract

**VHADDPS/VHADDPD** - Horizontal Add Packed Floats/Doubles

```nasm
vhaddps ymm0, ymm1, ymm2      ; Horizontal add
; YMM0[0] = YMM1[0] + YMM1[1]
; YMM0[1] = YMM1[2] + YMM1[3]
; YMM0[2] = YMM2[0] + YMM2[1]
; YMM0[3] = YMM2[2] + YMM2[3]
; YMM0[4] = YMM1[4] + YMM1[5]
; YMM0[5] = YMM1[6] + YMM1[7]
; YMM0[6] = YMM2[4] + YMM2[5]
; YMM0[7] = YMM2[6] + YMM2[7]
```

**VHSUBPS/VHSUBPD** - Horizontal Subtract Packed Floats/Doubles

```nasm
vhsubps ymm0, ymm1, ymm2      ; Horizontal subtract
; YMM0[0] = YMM1[0] - YMM1[1]
; YMM0[1] = YMM1[2] - YMM1[3]
; (pattern continues as with VHADDPS)
```

**Example** of summing vector elements:

```nasm
; Sum all 8 floats in YMM0 to produce scalar result
vhaddps ymm0, ymm0, ymm0      ; Pairwise add: [0+1, 2+3, 0+1, 2+3, 4+5, 6+7, 4+5, 6+7]
vhaddps ymm0, ymm0, ymm0      ; Pairwise add again: [(0+1)+(2+3), ...]
; Extract and add 128-bit halves
vextractf128 xmm1, ymm0, 1    ; Extract upper 128 bits
vaddps xmm0, xmm0, xmm1       ; Add upper and lower halves
; Final horizontal adds to get scalar
vhaddps xmm0, xmm0, xmm0
vhaddps xmm0, xmm0, xmm0
; XMM0[0] now contains sum of all 8 original elements
```

#### Horizontal Integer Operations (AVX2)

**VPHADDD/VPHADDW** - Horizontal Add Packed Integers

```nasm
vphaddd ymm0, ymm1, ymm2      ; Horizontal add 8 pairs of dwords
vphaddw ymm0, ymm1, ymm2      ; Horizontal add 16 pairs of words
```

**VPHSUBD/VPHSUBW** - Horizontal Subtract Packed Integers

```nasm
vphsubd ymm0, ymm1, ymm2      ; Horizontal subtract dwords
vphsubw ymm0, ymm1, ymm2      ; Horizontal subtract words
```

**VPHADDSW/VPHSUBSW** - Horizontal Add/Subtract with Saturation

```nasm
vphaddsw ymm0, ymm1, ymm2     ; Horizontal add words with saturation
vphsubsw ymm0, ymm1, ymm2     ; Horizontal subtract words with saturation
```

### Comparison Operations

AVX extends comparison operations to 256-bit width with enhanced functionality.

#### Floating-Point Comparisons

**VCMPPS/VCMPPD** - Compare Packed Floats/Doubles

```nasm
vcmpps ymm0, ymm1, ymm2, imm8     ; Compare 8 floats with predicate
vcmppd ymm0, ymm1, ymm2, imm8     ; Compare 4 doubles with predicate
```

**Comparison predicates** (imm8 values, expanded from SSE):

- **0x00**: EQ_OQ (equal, ordered, quiet)
- **0x01**: LT_OS (less than, ordered, signaling)
- **0x02**: LE_OS (less than or equal, ordered, signaling)
- **0x03**: UNORD_Q (unordered, quiet)
- **0x04**: NEQ_UQ (not equal, unordered, quiet)
- **0x05**: NLT_US (not less than, unordered, signaling)
- **0x06**: NLE_US (not less than or equal, unordered, signaling)
- **0x07**: ORD_Q (ordered, quiet)
- **0x08-0x1F**: Additional predicates for signaling/quiet NaN handling

**Example** using comparison masks:

```nasm
; Find elements in YMM1 greater than YMM2
vcmpps ymm0, ymm1, ymm2, 0x1E     ; Greater than predicate (GT_OQ)
; YMM0 now contains mask: 0xFFFFFFFF where true, 0x00000000 where false

; Use mask for conditional selection
vandps ymm3, ymm0, ymm1           ; Select YMM1 where mask is true
vandnps ymm4, ymm0, ymm2          ; Select YMM2 where mask is false
vorps ymm5, ymm3, ymm4            ; Combine: max(YMM1, YMM2)
```

#### Integer Comparisons (AVX2)

**VPCMPEQB/W/D/Q** - Compare Packed Integers for Equal

```nasm
vpcmpeqb ymm0, ymm1, ymm2         ; Compare 32 bytes
vpcmpeqw ymm0, ymm1, ymm2         ; Compare 16 words
vpcmpeqd ymm0, ymm1, ymm2         ; Compare 8 doublewords
vpcmpeqq ymm0, ymm1, ymm2         ; Compare 4 quadwords
```

**VPCMPGTB/W/D/Q** - Compare Packed Signed Integers for Greater Than

```nasm
vpcmpgtb ymm0, ymm1, ymm2         ; Compare 32 signed bytes
vpcmpgtw ymm0, ymm1, ymm2         ; Compare 16 signed words
vpcmpgtd ymm0, ymm1, ymm2         ; Compare 8 signed doublewords
vpcmpgtq ymm0, ymm1, ymm2         ; Compare 4 signed quadwords
```

### Logical Operations

AVX logical operations work on entire 256-bit registers, treating them as bit vectors.

**VANDPS/VANDPD** - Bitwise AND

```nasm
vandps ymm0, ymm1, ymm2           ; YMM0 = YMM1 AND YMM2
vandpd ymm0, ymm1, ymm2           ; YMM0 = YMM1 AND YMM2 (double variant)
```

**VPAND** - Bitwise AND (Integer)

```nasm
vpand ymm0, ymm1, ymm2            ; YMM0 = YMM1 AND YMM2
```

**VANDNPS/VANDNPD** - Bitwise AND NOT

```nasm
vandnps ymm0, ymm1, ymm2          ; YMM0 = (NOT YMM1) AND YMM2
```

**VPANDN** - Bitwise AND NOT (Integer)

```nasm
vpandn ymm0, ymm1, ymm2           ; YMM0 = (NOT YMM1) AND YMM2
```

**VORPS/VORPD** - Bitwise OR

```nasm
vorps ymm0, ymm1, ymm2            ; YMM0 = YMM1 OR YMM2
```

**VPOR** - Bitwise OR (Integer)

```nasm
vpor ymm0, ymm1, ymm2             ; YMM0 = YMM1 OR YMM2
```

**VXORPS/VXORPD** - Bitwise XOR

```nasm
vxorps ymm0, ymm1, ymm2           ; YMM0 = YMM1 XOR YMM2
vxorps ymm0, ymm0, ymm0           ; Zero out YMM0 (common idiom)
```

**VPXOR** - Bitwise XOR (Integer)

```nasm
vpxor ymm0, ymm1, ymm2            ; YMM0 = YMM1 XOR YMM2
```

### Shift Operations (AVX2)

AVX2 extends shift operations to 256-bit integer vectors.

#### Logical Shifts

**VPSRLW/D/Q** - Packed Shift Right Logical

```nasm
vpsrlw ymm0, ymm1, xmm2           ; Shift 16 words right by XMM2[0]
vpsrlw ymm0, ymm1, imm8           ; Shift 16 words right by immediate
vpsrld ymm0, ymm1, xmm2           ; Shift 8 dwords right
vpsrlq ymm0, ymm1, xmm2           ; Shift 4 qwords right
```

**VPSLLW/D/Q** - Packed Shift Left Logical

```nasm
vpsllw ymm0, ymm1, xmm2           ; Shift 16 words left
vpslld ymm0, ymm1, imm8           ; Shift 8 dwords left by immediate
vpsllq ymm0, ymm1, xmm2           ; Shift 4 qwords left
```

#### Arithmetic Shifts

**VPSRAW/D** - Packed Shift Right Arithmetic

```nasm
vpsraw ymm0, ymm1, xmm2           ; Shift 16 signed words right (sign extend)
vpsrad ymm0, ymm1, imm8           ; Shift 8 signed dwords right by immediate
```

#### Variable Shifts (AVX2)

AVX2 introduced variable per-element shift amounts:

**VPSRLVD/Q** - Variable Shift Right Logical

```nasm
vpsrlvd ymm0, ymm1, ymm2          ; Shift each dword by corresponding amount in YMM2
vpsrlvq ymm0, ymm1, ymm2          ; Shift each qword by corresponding amount
```

**VPSLLVD/Q** - Variable Shift Left Logical

```nasm
vpsllvd ymm0, ymm1, ymm2          ; Shift each dword left by varying amounts
vpsllvq ymm0, ymm1, ymm2          ; Shift each qword left by varying amounts
```

**VPSRAVD** - Variable Shift Right Arithmetic

```nasm
vpsravd ymm0, ymm1, ymm2          ; Arithmetic shift each dword by varying amounts
```

**Example** of variable shifts:

```nasm
; YMM1: [1000][2000][3000][4000][5000][6000][7000][8000]
; YMM2: [1][2][3][4][5][6][7][8] (shift amounts)
vpsrlvd ymm0, ymm1, ymm2
; YMM0: [500][500][375][250][156][93][54][31]
;       (each element shifted right by its corresponding amount)
```

### Blend Operations

Blend operations provide efficient conditional selection between two sources based on masks or immediate values.

**VBLENDPS/VBLENDPD** - Blend Packed Floats/Doubles (Immediate Mask)

```nasm
vblendps ymm0, ymm1, ymm2, imm8   ; Blend 8 floats using 8-bit mask
vblendpd ymm0, ymm1, ymm2, imm8   ; Blend 4 doubles using 4-bit mask
; Each bit in imm8 selects: 0 = YMM1, 1 = YMM2
```

**VBLENDVPS/VBLENDVPD** - Blend Packed Floats/Doubles (Variable Mask)

```nasm
vblendvps ymm0, ymm1, ymm2, ymm3  ; Blend using YMM3 as mask
; If YMM3 element's sign bit is 0, select from YMM1; if 1, select from YMM2
```

**VPBLENDW** - Blend Packed Words (Immediate Mask)

```nasm
vpblendw ymm0, ymm1, ymm2, imm8   ; Blend 16 words using 8-bit mask
; Each bit controls 2 words (pattern repeats for upper/lower 128 bits)
```

**VPBLENDVB** - Blend Packed Bytes (Variable Mask) (AVX2)

```nasm
vpblendvb ymm0, ymm1, ymm2, ymm3  ; Blend 32 bytes using YMM3 as mask
; If YMM3 byte's sign bit is 0, select from YMM1; if 1, select from YMM2
```

**VPBLENDD** - Blend Packed Doublewords (Immediate Mask) (AVX2)

```nasm
vpblendd ymm0, ymm1, ymm2, imm8   ; Blend 8 doublewords using 8-bit mask
; Each bit in imm8 selects: 0 = YMM1, 1 = YMM2
```

**Example** of blend-based conditional selection:

```nasm
; Select maximum of two vectors
vcmpps ymm3, ymm0, ymm1, 0x1E     ; Compare: YMM0 > YMM1
vblendvps ymm2, ymm1, ymm0, ymm3  ; Blend: select YMM0 where true, YMM1 where false
; YMM2 now contains element-wise maximum
```

### Permute and Shuffle Operations

Permute and shuffle operations rearrange elements within vectors, enabling complex data reorganization.

#### Single-Vector Permutations

**VPERMILPS/VPERMILPD** - Permute Floats/Doubles Within 128-bit Lanes

```nasm
vpermilps ymm0, ymm1, ymm2        ; Permute each float using control from YMM2
vpermilps ymm0, ymm1, imm8        ; Permute using immediate control

vpermilpd ymm0, ymm1, imm8        ; Permute doubles using immediate
```

**VPERMILPS** with immediate operates independently on each 128-bit lane:

```nasm
; imm8 controls permutation:
; Bits [1:0] select element for position 0 (from elements 0-3 of same lane)
; Bits [3:2] select element for position 1
; Bits [5:4] select element for position 2
; Bits [7:6] select element for position 3
; Pattern repeats for upper 128-bit lane

vpermilps ymm0, ymm1, 0b11100100  ; [3][2][1][0] -> [3][2][1][0] in each lane
; Lower lane: [ymm1[3]][ymm1[2]][ymm1[1]][ymm1[0]]
; Upper lane: [ymm1[7]][ymm1[6]][ymm1[5]][ymm1[4]]
```

#### Cross-Lane Permutations (AVX2)

**VPERM2I128** - Permute 128-bit Integer Lanes

```nasm
vperm2i128 ymm0, ymm1, ymm2, imm8 ; Permute 128-bit lanes
; imm8 controls which 128-bit lanes are selected:
; Bits [1:0]: Source for lower 128 bits (0=YMM1[127:0], 1=YMM1[255:128], 2=YMM2[127:0], 3=YMM2[255:128])
; Bit [3]: Zero lower 128 bits if set
; Bits [5:4]: Source for upper 128 bits
; Bit [7]: Zero upper 128 bits if set
```

**VPERM2F128** - Permute 128-bit Floating-Point Lanes

```nasm
vperm2f128 ymm0, ymm1, ymm2, imm8 ; Permute 128-bit float lanes
; Uses same control format as VPERM2I128
```

**Example** of lane swapping:

```nasm
; Swap upper and lower 128-bit lanes
vperm2f128 ymm0, ymm1, ymm1, 0x01
; Lower lane gets YMM1[255:128]
; Upper lane gets YMM1[127:0]
```

**VPERMD** - Permute Doublewords (AVX2)

```nasm
vpermd ymm0, ymm1, ymm2           ; Permute 8 dwords using YMM1 as indices
; Each dword in YMM1 (bits [2:0]) selects which dword from YMM2 goes to that position
```

**VPERMQ** - Permute Quadwords (AVX2)

```nasm
vpermq ymm0, ymm1, imm8           ; Permute 4 qwords using immediate
; Bits [1:0]: Index for qword position 0
; Bits [3:2]: Index for qword position 1
; Bits [5:4]: Index for qword position 2
; Bits [7:6]: Index for qword position 3
```

**VPERMPD** - Permute Double-Precision (AVX2)

```nasm
vpermpd ymm0, ymm1, imm8          ; Permute 4 doubles using immediate
; Same control format as VPERMQ
```

**VPERMPS** - Permute Single-Precision (AVX2)

```nasm
vpermps ymm0, ymm1, ymm2          ; Permute 8 floats using YMM1 as indices
; Each dword in YMM1 (bits [2:0]) selects which float from YMM2
```

**Example** of full-vector permutation:

```nasm
; Reverse order of 8 floats in YMM1
; Create index vector: [7, 6, 5, 4, 3, 2, 1, 0]
mov eax, 7
vpbroadcastd ymm0, eax            ; Broadcast 7 to all elements
; (Actually need to construct proper index vector)
vmovdqa ymm0, [reverse_indices]   ; Load pre-constructed indices
vpermps ymm2, ymm0, ymm1          ; Permute using indices
; YMM2 now contains reversed elements
```

#### Shuffle Operations

**VSHUFPS/VSHUFPD** - Shuffle Packed Floats/Doubles

```nasm
vshufps ymm0, ymm1, ymm2, imm8    ; Shuffle floats
vshufpd ymm0, ymm1, ymm2, imm8    ; Shuffle doubles
```

**VSHUFPS** operates within 128-bit lanes, selecting elements from both source operands:

```nasm
; imm8 controls shuffle:
; Bits [1:0]: Element from YMM1 for position 0
; Bits [3:2]: Element from YMM1 for position 1
; Bits [5:4]: Element from YMM2 for position 2
; Bits [7:6]: Element from YMM2 for position 3
; Pattern repeats independently for upper 128-bit lane

vshufps ymm0, ymm1, ymm2, 0b11100100
; Lower lane: [ymm2[3]][ymm2[2]][ymm1[1]][ymm1[0]]
; Upper lane: [ymm2[7]][ymm2[6]][ymm1[5]][ymm1[4]]
```

**VPSHUFD** - Shuffle Doublewords (AVX2)

```nasm
vpshufd ymm0, ymm1, imm8          ; Shuffle dwords within 128-bit lanes
; Operates independently on each 128-bit lane
; imm8 bits [1:0] select dword for position 0, etc.
```

**VPSHUFB** - Shuffle Bytes (AVX2)

```nasm
vpshufb ymm0, ymm1, ymm2          ; Shuffle bytes using YMM2 as control
; Each byte in YMM2 controls corresponding output byte:
; Bits [3:0]: Index of byte to select from same 128-bit lane of YMM1
; Bit [7]: If set, output byte is 0
```

**Example** of byte shuffling:

```nasm
; Reverse bytes within each 16-byte lane
; Control mask: [15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0] for each lane
vmovdqa ymm1, [reverse_byte_mask]
vpshufb ymm0, ymm0, ymm1
; Each 128-bit lane now has reversed byte order
```

### Pack and Unpack Operations

Pack and unpack operations convert between different data sizes and interleave data from multiple sources.

#### Pack Operations (AVX2)

**VPACKSSWB** - Pack Signed Words to Signed Bytes with Saturation

```nasm
vpacksswb ymm0, ymm1, ymm2        ; Pack 16+16 words to 32 bytes
; Converts 32 words (16 from each source) to 32 bytes with saturation
```

**VPACKSSDW** - Pack Signed Doublewords to Signed Words with Saturation

```nasm
vpackssdw ymm0, ymm1, ymm2        ; Pack 8+8 dwords to 16 words
```

**VPACKUSWB** - Pack Unsigned Words to Unsigned Bytes with Saturation

```nasm
vpackuswb ymm0, ymm1, ymm2        ; Pack 16+16 words to 32 unsigned bytes
```

**VPACKUSDW** - Pack Unsigned Doublewords to Unsigned Words with Saturation (AVX2)

```nasm
vpackusdw ymm0, ymm1, ymm2        ; Pack 8+8 dwords to 16 unsigned words
```

#### Unpack Operations

**VPUNPCKLBW/VPUNPCKHBW** - Unpack Bytes to Words

```nasm
vpunpcklbw ymm0, ymm1, ymm2       ; Interleave low bytes from both sources
vpunpckhbw ymm0, ymm1, ymm2       ; Interleave high bytes from both sources
```

**VPUNPCKLWD/VPUNPCKHWD** - Unpack Words to Doublewords

```nasm
vpunpcklwd ymm0, ymm1, ymm2       ; Interleave low words
vpunpckhwd ymm0, ymm1, ymm2       ; Interleave high words
```

**VPUNPCKLDQ/VPUNPCKHDQ** - Unpack Doublewords to Quadwords

```nasm
vpunpckldq ymm0, ymm1, ymm2       ; Interleave low doublewords
vpunpckhdq ymm0, ymm1, ymm2       ; Interleave high doublewords
```

**VPUNPCKLQDQ/VPUNPCKHQDQ** - Unpack Quadwords to Double-Quadwords

```nasm
vpunpcklqdq ymm0, ymm1, ymm2      ; Interleave low quadwords
vpunpckhqdq ymm0, ymm1, ymm2      ; Interleave high quadwords
```

**VUNPCKLPS/VUNPCKHPS** - Unpack Floats

```nasm
vunpcklps ymm0, ymm1, ymm2        ; Interleave low floats
vunpckhps ymm0, ymm1, ymm2        ; Interleave high floats
```

**VUNPCKLPD/VUNPCKHPD** - Unpack Doubles

```nasm
vunpcklpd ymm0, ymm1, ymm2        ; Interleave low doubles
vunpckhpd ymm0, ymm1, ymm2        ; Interleave high doubles
```

**Example** of structure-of-arrays to array-of-structures conversion:

```nasm
; Convert 8 RGB pixels from planar to interleaved format
; YMM0: [R7][R6][R5][R4][R3][R2][R1][R0]
; YMM1: [G7][G6][G5][G4][G3][G2][G1][G0]
; YMM2: [B7][B6][B5][B4][B3][B2][B1][B0]

; Use multiple unpacks to interleave
vpunpcklbw ymm3, ymm0, ymm1       ; [G3][R3][G2][R2][G1][R1][G0][R0]...
vpunpckhbw ymm4, ymm0, ymm1       ; [G7][R7][G6][R6][G5][R5][G4][R4]...
; Continue unpacking with blue channel...
; (Full RGB interleaving requires additional operations)
```

### Broadcast Operations

Broadcast operations replicate a single element across all positions in the destination register.

**VBROADCASTSS** - Broadcast Single-Precision Float

```nasm
vbroadcastss ymm0, xmm1           ; Broadcast XMM1[0] to all 8 positions
vbroadcastss ymm0, [mem]          ; Broadcast 32-bit memory value
```

**VBROADCASTSD** - Broadcast Double-Precision Float

```nasm
vbroadcastsd ymm0, xmm1           ; Broadcast XMM1[0] to all 4 positions
vbroadcastsd ymm0, [mem]          ; Broadcast 64-bit memory value
```

**VPBROADCASTB/W/D/Q** - Broadcast Integer (AVX2)

```nasm
vpbroadcastb ymm0, xmm1           ; Broadcast byte to 32 positions
vpbroadcastw ymm0, xmm1           ; Broadcast word to 16 positions
vpbroadcastd ymm0, xmm1           ; Broadcast doubleword to 8 positions
vpbroadcastq ymm0, xmm1           ; Broadcast quadword to 4 positions

vpbroadcastd ymm0, [mem]          ; Broadcast from 32-bit memory
```

**Example** of broadcast usage:

```nasm
; Add scalar value to all elements of vector
mov eax, 42
vpbroadcastd ymm1, eax            ; Broadcast 42 to all 8 dwords
vpaddd ymm0, ymm0, ymm1           ; Add 42 to each element
```

### Gather Operations (AVX2)

Gather operations load non-contiguous data from memory using vector indices, enabling efficient sparse data access.

**VGATHERDPS/VGATHERDPD** - Gather Using Doubleword Indices

```nasm
vgatherdps ymm0, [base + ymm1*scale], ymm2    ; Gather 8 floats
vgatherdpd ymm0, [base + xmm1*scale], ymm2    ; Gather 4 doubles
; ymm1/xmm1: Indices (offsets)
; ymm2: Mask (must be initialized to all 1s)
```

**VGATHERQPS/VGATHERQPD** - Gather Using Quadword Indices

```nasm
vgatherqps xmm0, [base + ymm1*scale], xmm2    ; Gather 4 floats
vgatherqpd ymm0, [base + ymm1*scale], ymm2    ; Gather 4 doubles
```

**VPGATHERDD/VPGATHERDQ** - Gather Integers Using Doubleword Indices (AVX2)

```nasm
vpgatherdd ymm0, [base + ymm1*scale], ymm2    ; Gather 8 dwords
vpgatherdq ymm0, [base + xmm1*scale], ymm2    ; Gather 4 qwords
```

**VPGATHERQD/VPGATHERQQ** - Gather Integers Using Quadword Indices (AVX2)

```nasm
vpgatherqd xmm0, [base + ymm1*scale], xmm2    ; Gather 4 dwords
vpgatherqq ymm0, [base + ymm1*scale], ymm2    ; Gather 4 qwords
```

**Gather operation characteristics**:

- **Mask register**: Must be initialized to all 1s; bits are cleared as elements are gathered
- **Destination register**: Must be different from index and mask registers
- **Scale factor**: Can be 1, 2, 4, or 8 bytes
- **Base address**: Can be register or memory reference

**Example** of gather usage:

```nasm
; Gather array elements at specific indices
; Array at [rsi], indices in YMM1

vpcmpeqd ymm2, ymm2, ymm2         ; Initialize mask to all 1s
vgatherdps ymm0, [rsi + ymm1*4], ymm2
; YMM0 now contains array[ymm1[0]], array[ymm1[1]], ... array[ymm1[7]]
```

**Example** of indirect lookup table access:

```nasm
; Look up 8 values from table using indices
; Indices: [5, 12, 3, 8, 1, 15, 7, 9]
vmovdqa ymm1, [indices]           ; Load indices
vpcmpeqd ymm2, ymm2, ymm2         ; Mask = all 1s
mov rsi, lookup_table
vpgatherdd ymm0, [rsi + ymm1*4], ymm2
; YMM0 contains table[5], table[12], ... table[9]
```

### Extract and Insert Operations

**VEXTRACTF128** - Extract 128-bit Lane

```nasm
vextractf128 xmm0, ymm1, imm8     ; Extract 128-bit lane (imm8: 0=lower, 1=upper)
vextractf128 [mem], ymm1, imm8    ; Extract lane to memory
```

**VEXTRACTI128** - Extract 128-bit Integer Lane (AVX2)

```nasm
vextracti128 xmm0, ymm1, imm8     ; Extract 128-bit integer lane
```

**VINSERTF128** - Insert 128-bit Lane

```nasm
vinsertf128 ymm0, ymm1, xmm2, imm8    ; Insert XMM2 into YMM1 at lane specified by imm8
```

**VINSERTI128** - Insert 128-bit Integer Lane (AVX2)

```nasm
vinserti128 ymm0, ymm1, xmm2, imm8    ; Insert integer lane
```

**Example** of lane extraction and insertion:

```nasm
; Process upper and lower lanes separately
vextractf128 xmm0, ymm1, 1        ; Extract upper lane
; ... process XMM0 ...
vinsertf128 ymm1, ymm1, xmm0, 1   ; Insert processed lane back
```

### Min/Max Operations

**VMINPS/VMINPD** - Minimum of Packed Floats/Doubles

```nasm
vminps ymm0, ymm1, ymm2           ; Element-wise minimum of 8 floats
vminpd ymm0, ymm1, ymm2           ; Element-wise minimum of 4 doubles
```

**VMAXPS/VMAXPD** - Maximum of Packed Floats/Doubles

```nasm
vmaxps ymm0, ymm1, ymm2           ; Element-wise maximum of 8 floats
vmaxpd ymm0, ymm1, ymm2           ; Element-wise maximum of 4 doubles
```

**VPMINSB/VPMINSW/VPMINSD** - Minimum of Packed Signed Integers (AVX2)

```nasm
vpminsb ymm0, ymm1, ymm2          ; Minimum of 32 signed bytes
vpminsw ymm0, ymm1, ymm2          ; Minimum of 16 signed words
vpminsd ymm0, ymm1, ymm2          ; Minimum of 8 signed dwords
```

**VPMINUB/VPMINUW/VPMINUD** - Minimum of Packed Unsigned Integers (AVX2)

```nasm
vpminub ymm0, ymm1, ymm2          ; Minimum of 32 unsigned bytes
vpminuw ymm0, ymm1, ymm2          ; Minimum of 16 unsigned words
vpminud ymm0, ymm1, ymm2          ; Minimum of 8 unsigned dwords
```

**VPMAXSB/VPMAXSW/VPMAXSD** - Maximum of Packed Signed Integers (AVX2)

```nasm
vpmaxsb ymm0, ymm1, ymm2          ; Maximum of 32 signed bytes
vpmaxsw ymm0, ymm1, ymm2          ; Maximum of 16 signed words
vpmaxsd ymm0, ymm1, ymm2          ; Maximum of 8 signed dwords
```

**VPMAXUB/VPMAXUW/VPMAXUD** - Maximum of Packed Unsigned Integers (AVX2)

```nasm
vpmaxub ymm0, ymm1, ymm2          ; Maximum of 32 unsigned bytes
vpmaxuw ymm0, ymm1, ymm2          ; Maximum of 16 unsigned words
vpmaxud ymm0, ymm1, ymm2          ; Maximum of 8 unsigned dwords
```

### Absolute Value and Sign Operations (AVX2)

**VPABSB/VPABSW/VPABSD** - Absolute Value of Packed Integers

```nasm
vpabsb ymm0, ymm1                 ; Absolute value of 32 signed bytes
vpabsw ymm0, ymm1                 ; Absolute value of 16 signed words
vpabsd ymm0, ymm1                 ; Absolute value of 8 signed dwords
```

**VPSIGNB/VPSIGNW/VPSIGND** - Packed Sign

```nasm
vpsignb ymm0, ymm1, ymm2          ; Negate elements of YMM1 where YMM2 < 0
vpsignw ymm0, ymm1, ymm2          ; Apply sign of YMM2 to YMM1 (words)
vpsignd ymm0, ymm1, ymm2          ; Apply sign of YMM2 to YMM1 (dwords)
```

### Conversion Instructions

AVX extends conversion operations to 256-bit width.

**VCVTPS2PD** - Convert Packed Single to Double Precision

```nasm
vcvtps2pd ymm0, xmm1              ; Convert 4 floats to 4 doubles
```

**VCVTPD2PS** - Convert Packed Double to Single Precision

```nasm
vcvtpd2ps xmm0, ymm1              ; Convert 4 doubles to 4 floats
```

**VCVTDQ2PS** - Convert Packed Integers to Single Precision

```nasm
vcvtdq2ps ymm0, ymm1              ; Convert 8 int32 to 8 floats
```

**VCVTPS2DQ** - Convert Packed Single to Integers

```nasm
vcvtps2dq ymm0, ymm1              ; Convert 8 floats to 8 int32
```

**VCVTTPS2DQ** - Convert with Truncation Packed Single to Integers

```nasm
vcvttps2dq ymm0, ymm1             ; Convert 8 floats to 8 int32 (truncate)
```

**VCVTDQ2PD** - Convert Packed Integers to Double Precision (AVX)

```nasm
vcvtdq2pd ymm0, xmm1              ; Convert 4 int32 (from XMM1) to 4 doubles
```

**VCVTPD2DQ** - Convert Packed Double to Integers

```nasm
vcvtpd2dq xmm0, ymm1              ; Convert 4 doubles to 4 int32
```

**VCVTTPD2DQ** - Convert with Truncation Packed Double to Integers

```nasm
vcvttpd2dq xmm0, ymm1             ; Convert 4 doubles to 4 int32 (truncate)
```

### Data Movement

**VMOVAPS/VMOVAPD** - Move Aligned Packed Floats/Doubles

```nasm
vmovaps ymm0, ymm1                ; Move 256 bits (register to register)
vmovaps ymm0, [mem]               ; Load aligned 256 bits
vmovaps [mem], ymm0               ; Store aligned 256 bits
```

**VMOVUPS/VMOVUPD** - Move Unaligned Packed Floats/Doubles

```nasm
vmovups ymm0, [mem]               ; Load unaligned 256 bits
vmovups [mem], ymm0               ; Store unaligned 256 bits
```

**VMOVDQA** - Move Aligned Double Quadword (AVX2)

```nasm
vmovdqa ymm0, ymm1                ; Move 256 bits (integers)
vmovdqa ymm0, [mem]               ; Load aligned 256 bits
```

**VMOVDQU** - Move Unaligned Double Quadword (AVX2)

```nasm
vmovdqu ymm0, [mem]               ; Load unaligned 256 bits
vmovdqu [mem], ymm0               ; Store unaligned 256 bits
```

**VMASKMOVPS/VMASKMOVPD** - Conditional Masked Move

```nasm
vmaskmovps ymm0, ymm1, [mem]      ; Load floats where YMM1 sign bits are set
vmaskmovps [mem], ymm1, ymm0      ; Store floats where YMM1 sign bits are set
```

**VPMASKMOVD/VPMASKMOVQ** - Conditional Masked Integer Move (AVX2)

```nasm
vpmaskmovd ymm0, ymm1, [mem]      ; Load dwords where YMM1 sign bits are set
vpmaskmovq ymm0, ymm1, [mem]      ; Load qwords where YMM1 sign bits are set
```

**Example** of masked load/store:

```nasm
; Load only specific elements based on condition
vcmpps ymm1, ymm2, ymm3, 0x01     ; Create mask: YMM2 < YMM3
vmaskmovps ymm0, ymm1, [rsi]      ; Load only where mask is true
; Process ymm0...
vmaskmovps [rdi], ymm1, ymm0      ; Store only where mask is true
```

### Zero-Extension Control

**VZEROUPPER** - Zero Upper Bits of YMM Registers

```nasm
vzeroupper                        ; Zero bits [255:128] of all YMM registers
```

VZEROUPPER clears the upper 128 bits of all YMM registers, leaving XMM portions intact. This is important when transitioning between AVX and SSE code to avoid performance penalties.

**VZEROALL** - Zero All YMM Registers

```nasm
vzeroall                          ; Zero all 256 bits of all YMM registers
```

**Performance considerations**: [Inference] Mixing AVX and SSE code without proper transitions can cause performance penalties on some processors due to state transition overhead. VZEROUPPER should be called before returning from AVX functions to non-AVX code.

**Example** of proper state management:

```nasm
avx_function:
    ; AVX code using YMM registers
    vmovaps ymm0, [data]
    vaddps ymm0, ymm0, ymm1
    ; ...
    
    vzeroupper                    ; Clean upper bits before return
    ret
```

