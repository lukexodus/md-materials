## Mask Registers


AVX-512 introduces eight dedicated architectural mask registers (k0-k7) as a fundamental feature distinguishing it from previous SIMD extensions. These mask registers enable fine-grained per-element predication and conditional execution without requiring data-level masking.

### Mask Register Architecture

Each mask register is an architectural 64-bit register, though the effective width depends on the operation and element size. For a given instruction, only the bits corresponding to vector elements are significant.

For 512-bit operations:

- Byte operations: 64 mask bits (64 elements)
- Word operations: 32 mask bits (32 elements)
- Doubleword operations: 16 mask bits (16 elements)
- Quadword operations: 8 mask bits (8 elements)

Mask register k0 has special semantics: when specified as a mask, k0 represents an all-ones mask (no masking). This allows k0 to serve as a "no mask" encoding, and operations can explicitly use k0 to indicate unmasked execution.

### Masking Modes

AVX-512 supports two masking behaviors specified by the instruction encoding:

**Merging masking** preserves destination elements where the mask bit is zero. Only elements with mask bit set are updated from the computation result.

```nasm
; Merging masking: unmasked elements preserved
vaddps zmm0 {k1}, zmm1, zmm2
; zmm0[i] = (k1[i] == 1) ? (zmm1[i] + zmm2[i]) : zmm0[i]_original
```

**Zeroing masking** zeros destination elements where the mask bit is zero. Elements with mask bit set receive computation results, while masked elements become zero.

```nasm
; Zeroing masking: unmasked elements zeroed
vaddps zmm0 {k1}{z}, zmm1, zmm2
; zmm0[i] = (k1[i] == 1) ? (zmm1[i] + zmm2[i]) : 0
```

The {z} decorator in assembly syntax indicates zeroing masking mode. Without {z}, merging masking is the default.

### Mask Register Operations

AVX-512 provides instructions to manipulate mask registers directly:

**KMOVB/KMOVW/KMOVD/KMOVQ** transfers mask values between mask registers and general-purpose registers or memory, with different widths (byte, word, doubleword, quadword).

**KANDW/KANDB/KANDQ/KANDD** performs bitwise AND between mask registers.

**KORW/KORB/KORQ/KORD** performs bitwise OR between mask registers.

**KXORW/KXORB/KXORQ/KXORD** performs bitwise XOR between mask registers.

**KNOTW/KNOTB/KNOTQ/KNOTD** performs bitwise NOT on mask registers.

**KADDW/KADDB/KADDQ/KADDD** performs addition on mask registers, treating them as packed integers.

**KUNPCKBW/KUNPCKWD/KUNPCKDQ** unpacks and interleaves mask register bits.

```nasm
; Creating and manipulating masks
mov eax, 0xAAAA             ; Alternating pattern
kmovw k1, eax               ; Load into mask register
knotw k2, k1                ; k2 = ~k1
kandw k3, k1, k2            ; k3 = k1 & k2
```

### Comparison Operations with Mask Results

Vector comparison instructions write their results directly to mask registers rather than generating data masks. This eliminates the need to convert comparison results for use in predicated operations.

**VCMPPS/VCMPPD** compares packed floating-point values and writes a mask result to the destination mask register.

**VPCMPB/VPCMPW/VPCMPD/VPCMPQ** compares packed integer values with an immediate predicate specifying the comparison type (equal, less than, less than or equal, false, not equal, not less than, not less than or equal, true).

**VPCMPUB/VPCMPUW/VPCMPUD/VPCMPUQ** provides unsigned integer comparisons.

```nasm
; Compare and use result as mask
vcmpps k1, zmm0, zmm1, 1    ; k1 = (zmm0 < zmm1), per element
vaddps zmm2 {k1}{z}, zmm3, zmm4  ; Add only where comparison was true
```

[Inference] Direct mask register output from comparisons eliminates the data register consumption and additional operations required in SSE/AVX for similar functionality, improving both performance and register pressure.

### Mask Register Performance

[Inference] Architectural mask registers enable more efficient predication than data-level masking used in earlier SIMD extensions. The dedicated mask path avoids consumption of vector registers for mask storage and eliminates blend operations to implement conditional execution.

[Unverified] The performance characteristics of masked operations vary by processor implementation. On some microarchitectures, masked operations execute with minimal overhead compared to unmasked operations, while on others there may be throughput or latency penalties for masked execution.

