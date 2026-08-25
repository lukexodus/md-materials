## AVX2 Enhancements


AVX2, introduced with Intel's Haswell microarchitecture, extended AVX's capabilities to integer operations and added gather instructions. While original AVX focused primarily on floating-point operations, AVX2 provided comprehensive 256-bit integer processing.

### Integer Arithmetic Operations

AVX2 extends integer operations to 256-bit vectors. **VPADDB**, **VPADDW**, **VPADDD**, **VPADDQ** perform packed addition on bytes, words, doublewords, and quadwords across full 256-bit registers.

**VPSUBB**, **VPSUBW**, **VPSUBD**, **VPSUBQ** provide corresponding subtraction operations.

**VPMULLW**, **VPMULLD** multiply packed 16-bit or 32-bit integers, storing the low portion of the result. **VPMULDQ** multiplies alternating 32-bit elements producing 64-bit results.

```nasm
vmovdqa ymm0, [array_a]     ; Load 32 bytes
vmovdqa ymm1, [array_b]     ; Load 32 bytes
vpaddb ymm2, ymm0, ymm1     ; Add 32 bytes in parallel
```

### Shift Operations

**VPSLLW**, **VPSLLD**, **VPSLLQ** perform packed left shift on 16-bit, 32-bit, or 64-bit elements. **VPSRLW**, **VPSRLD**, **VPSRLQ** perform logical right shifts. **VPSRAW**, **VPSRAD** perform arithmetic right shifts preserving sign bits.

AVX2 introduced variable shift instructions where each element can have a different shift count:

**VPSLLVD**, **VPSLLVQ** perform variable left shift per element, with shift counts specified by a second vector operand.

**VPSRLVD**, **VPSRLVQ** and **VPSRAVD** provide variable right shifts.

```nasm
vmovdqa ymm0, [data]        ; Values to shift
vmovdqa ymm1, [shift_counts]; Individual shift counts
vpsllvd ymm2, ymm0, ymm1    ; Each element shifted by its count
```

### Permutation Operations

**VPERMPS** permutes eight single-precision floating-point values according to indices in a control vector, enabling full cross-lane permutation with element granularity.

**VPERMD** provides the same functionality for 32-bit integer elements.

**VPERMPD** and **VPERMQ** permute four double-precision or 64-bit integer elements using an immediate control operand.

```nasm
vmovdqa ymm0, [data]        ; 8 dwords to permute
vmovdqa ymm1, [indices]     ; Index vector (each value 0-7)
vpermd ymm2, ymm1, ymm0     ; ymm2[i] = ymm0[ymm1[i]]
```

**VPERM2I128** permutes 128-bit integer lanes, analogous to VPERM2F128 for floating-point data.

### Pack and Unpack Operations

AVX2 extends packing and unpacking operations to 256-bit vectors. **VPACKSSWB**, **VPACKSSDW**, **VPACKUSWB**, **VPACKUSDW** convert and saturate elements from larger to smaller sizes.

**VPUNPCKLBW**, **VPUNPCKLWD**, **VPUNPCKLDQ**, **VPUNPCKLQDQ** interleave low elements from source operands within each 128-bit lane.

**VPUNPCKHBW**, **VPUNPCKHWD**, **VPUNPCKHDQ**, **VPUNPCKHQDQ** interleave high elements.

### Broadcast Operations

AVX2 extends broadcasting to integer data types. **VPBROADCASTB**, **VPBROADCASTW**, **VPBROADCASTD**, **VPBROADCASTQ** replicate a single byte, word, doubleword, or quadword across all positions in a vector.

```nasm
vpbroadcastd ymm0, [scalar] ; Replicate one dword to 8 positions
vpbroadcastb ymm1, eax      ; Replicate low byte of EAX to 32 positions
```

### Sign Extension and Zero Extension

**VPMOVSXBW**, **VPMOVSXBD**, **VPMOVSXBQ**, **VPMOVSXWD**, **VPMOVSXWQ**, **VPMOVSXDQ** sign-extend packed integers from smaller to larger element sizes.

**VPMOVZXBW**, **VPMOVZXBD**, **VPMOVZXBQ**, **VPMOVZXWD**, **VPMOVZXWQ**, **VPMOVZXDQ** provide zero-extension variants.

