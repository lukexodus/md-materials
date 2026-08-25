## SSE4.1 Enhancements


### Blending Operations

**PBLENDVB** conditionally selects bytes from two source operands based on a mask register. The high bit of each byte in the implicit XMM0 register determines whether the corresponding byte comes from the destination or source operand.

**BLENDPS**, **BLENDPD**, **PBLENDW** provide similar selective blending for single-precision floats, double-precision floats, and 16-bit words respectively, using immediate control values rather than a mask register.

**Example**: Conditional value selection without branches

```nasm
movdqa xmm0, [mask]         ; High bits indicate selection
movdqa xmm1, [values_a]
movdqa xmm2, [values_b]
pblendvb xmm1, xmm2         ; Blend based on xmm0 mask
```

### Dot Product Instructions

**DPPS** computes dot products of single-precision floating-point vectors with optional element masking. An 8-bit immediate operand specifies which elements participate in the multiplication (high nibble) and which elements of the result receive the sum (low nibble).

```nasm
movaps xmm0, [vector_a]
movaps xmm1, [vector_b]
dpps xmm0, xmm1, 0xF1       ; Multiply all 4, sum to element 0
```

**DPPD** provides the same functionality for double-precision values with two elements per register.

### Min/Max Extensions

**PMINUW**, **PMINUD**, **PMINSB**, **PMINSD** compute minimum values of packed unsigned 16-bit, unsigned 32-bit, signed 8-bit, and signed 32-bit integers respectively, extending the min/max operations available in earlier SSE versions.

**PMAXUW**, **PMAXUD**, **PMAXSB**, **PMAXSD** provide corresponding maximum operations.

These instructions fill gaps in the original SSE integer min/max operations, which only supported signed 16-bit and unsigned 8-bit comparisons.

### Packed Integer Extension

**PMOVSXBW**, **PMOVSXBD**, **PMOVSXBQ**, **PMOVSXWD**, **PMOVSXWQ**, **PMOVSXDQ** sign-extend packed integers from smaller to larger element sizes. The instruction names encode source and destination sizes: B (byte), W (word), D (doubleword), Q (quadword).

**PMOVZXBW**, **PMOVZXBD**, **PMOVZXBQ**, **PMOVZXWD**, **PMOVZXWQ**, **PMOVZXDQ** provide zero-extension variants.

**Example**: Converting 8-bit signed to 32-bit signed

```nasm
movd xmm0, [byte_data]      ; Load 4 bytes
pmovsxbd xmm0, xmm0         ; Sign-extend to 4 dwords
```

### Multiply Extensions

**PMULDQ** multiplies packed signed 32-bit integers and produces 64-bit signed results, operating on alternating doubleword elements (elements 0 and 2) from each operand.

**PMULLD** multiplies packed signed 32-bit integers and stores the low 32 bits of each 64-bit result, providing full 32-bit multiplication with wrap-around behavior.

### Insertion and Extraction

**PINSRB**, **PINSRD**, **PINSRQ** insert byte, doubleword, or quadword values from general-purpose registers or memory into specified positions within XMM registers.

**PEXTRB**, **PEXTRW**, **PEXTRD**, **PEXTRQ** extract individual elements from XMM registers to general-purpose registers or memory locations.

**INSERTPS** and **EXTRACTPS** provide similar functionality for single-precision floating-point elements with additional control over zero-masking.

### Test and Compare

**PTEST** performs logical AND and ANDN operations between two operands and sets processor flags based on the results, enabling efficient all-zeros or all-ones testing without destroying operand values.

**PCMPEQQ** compares packed 64-bit integers for equality, producing all-ones masks for equal quadwords and all-zeros for unequal quadwords.

**PACKUSDW** converts four signed 32-bit integers to unsigned 16-bit integers with saturation, clamping negative values to zero and values exceeding 65535 to 65535.

### Rounding Control

**ROUNDPS**, **ROUNDPD**, **ROUNDSS**, **ROUNDSD** round floating-point values according to a specified rounding mode provided in an immediate operand, overriding the rounding mode in the MXCSR control register.

Rounding modes include nearest (even), down (floor), up (ceiling), and toward zero (truncate). This eliminates the need to modify MXCSR for temporary rounding mode changes.

