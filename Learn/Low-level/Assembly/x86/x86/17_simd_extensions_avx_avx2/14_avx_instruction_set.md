## AVX Instruction Set


### Arithmetic Operations

AVX provides 256-bit variants of SSE arithmetic instructions with the V prefix convention. **VADDPS**, **VSUBPS**, **VMULPS**, **VDIVPS** perform addition, subtraction, multiplication, and division on eight single-precision floating-point values simultaneously.

**VADDPD**, **VSUBPD**, **VMULPD**, **VDIVPD** operate on four double-precision floating-point values per 256-bit register.

```nasm
vmovaps ymm0, [array_a]     ; Load 8 floats
vmovaps ymm1, [array_b]     ; Load 8 floats
vaddps ymm2, ymm0, ymm1     ; ymm2 = ymm0 + ymm1 (8 parallel adds)
vmovaps [result], ymm2      ; Store 8 results
```

### Logical and Comparison Operations

**VANDPS**, **VANDPD**, **VORPS**, **VORPD**, **VXORPS**, **VXORPD** perform bitwise logical operations on floating-point vectors. **VANDNPS** and **VANDNPD** compute AND-NOT operations.

**VCMPPS** and **VCMPPD** compare packed floating-point values using a predicate immediate operand that specifies the comparison type (equal, less than, less than or equal, unordered, not equal, not less than, not less than or equal, ordered). The instruction generates masks with all bits set for true conditions and all bits clear for false conditions.

```nasm
vmovaps ymm0, [values_a]
vmovaps ymm1, [values_b]
vcmpps ymm2, ymm0, ymm1, 1  ; Compare less-than (predicate 1)
; ymm2 now contains mask: 0xFFFFFFFF where true, 0x00000000 where false
```

### Permutation and Shuffle Operations

**VPERM2F128** permutes 128-bit lanes within and between 256-bit operands, enabling cross-lane data movement. The immediate control byte specifies the source lane for each destination lane and can force lanes to zero.

```nasm
vmovaps ymm0, [data1]       ; [A3 A2 A1 A0] (128-bit lanes)
vmovaps ymm1, [data2]       ; [B3 B2 B1 B0]
vperm2f128 ymm2, ymm0, ymm1, 0x20  ; ymm2 = [B1 B0 A1 A0]
```

**VSHUFPS** and **VSHUFPD** shuffle elements within each 128-bit lane independently, operating similarly to their SSE counterparts but processing both lanes in parallel.

**VPERMPD** (AVX2) and **VPERMPS** (AVX2) provide flexible lane-crossing permutation for double-precision and single-precision values respectively.

### Broadcast Operations

**VBROADCASTSS**, **VBROADCASTSD**, **VBROADCASTF128** replicate scalar or 128-bit values across a 256-bit destination. These instructions efficiently initialize vectors with constant values or duplicate single elements.

```nasm
vbroadcastss ymm0, [scalar] ; Replicate one float to all 8 positions
vbroadcastsd ymm1, [double] ; Replicate one double to all 4 positions
```

### Blend Operations

**VBLENDPS**, **VBLENDPD**, **VBLENDVPS**, **VBLENDVPD** conditionally select elements from two source vectors based on immediate control bits or a mask register. The blend instructions enable efficient conditional selection without branches.

```nasm
vmovaps ymm0, [values_true]
vmovaps ymm1, [values_false]
vmovaps ymm2, [mask]
vblendvps ymm3, ymm1, ymm0, ymm2  ; Select based on sign bit of ymm2
```

### Insert and Extract

**VINSERTF128** inserts a 128-bit value into the lower or upper half of a 256-bit register. **VEXTRACTF128** extracts a 128-bit lane from a 256-bit register to memory or another register.

These instructions facilitate transitions between 128-bit and 256-bit processing and enable manipulation of individual lanes.

### Masking Operations

**VMASKMOVPS** and **VMASKMOVPD** conditionally load or store floating-point values based on a mask register. Only elements with the corresponding mask bit set are accessed, preventing page faults or cache pollution from unused elements.

```nasm
vmovaps ymm0, [mask]        ; Mask with sign bits indicating valid elements
vmaskmovps ymm1, ymm0, [source]  ; Load only where mask bits are set
```

[Inference] Masked loads and stores improve performance when processing sparse data or handling boundary conditions where partial vectors must be processed without accessing invalid memory addresses.

