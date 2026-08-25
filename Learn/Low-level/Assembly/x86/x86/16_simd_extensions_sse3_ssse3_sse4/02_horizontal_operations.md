## Horizontal Operations


Horizontal operations process multiple elements within a single SIMD register, contrasting with vertical operations that process corresponding elements across multiple registers. These instructions enable efficient reduction operations and certain algorithm patterns that require element adjacency processing.

### SSE3 Horizontal Addition and Subtraction

**HADDPS** (Horizontal Add Packed Single-Precision) performs addition of adjacent pairs of 32-bit floating-point values. Given two source operands containing four floats each, the instruction produces four results: the first two results come from adding adjacent pairs in the destination operand, and the second two results come from adding adjacent pairs in the source operand.

```
destination: [A3, A2, A1, A0]
source:      [B3, B2, B1, B0]
result:      [B3+B2, B1+B0, A3+A2, A1+A0]
```

**HADDPD** performs the same operation on two packed double-precision floating-point values per register.

**HSUBPS** and **HSUBPD** perform horizontal subtraction with the same element organization, computing differences of adjacent pairs rather than sums.

**Example**: Computing dot product components

```nasm
movaps xmm0, [vector_a]     ; [a3, a2, a1, a0]
movaps xmm1, [vector_b]     ; [b3, b2, b1, b0]
mulps xmm0, xmm1            ; [a3*b3, a2*b2, a1*b1, a0*b0]
haddps xmm0, xmm0           ; [a3*b3+a2*b2, a1*b1+a0*b0, ...]
haddps xmm0, xmm0           ; [sum_all, sum_all, ...]
```

### Performance Characteristics

[Inference] Horizontal operations typically have higher latency and lower throughput compared to vertical operations because they require internal data movement within the execution unit. On many microarchitectures, horizontal operations decompose into multiple micro-operations, reducing their efficiency compared to equivalent sequences of shuffle and vertical operations.

[Unverified] The exact performance characteristics vary significantly across processor generations. On some architectures, manually implementing horizontal operations using shuffle instructions and vertical arithmetic may achieve better throughput for throughput-critical code.

### SSE3 Additional Instructions

**ADDSUBPS** and **ADDSUBPD** perform alternating addition and subtraction on packed floating-point values. Elements at even positions are subtracted while elements at odd positions are added, useful for complex number arithmetic in Cartesian representation.

```
destination: [A3, A2, A1, A0]
source:      [B3, B2, B1, B0]
result:      [A3+B3, A2-B2, A1+B1, A0-B0]
```

**MOVDDUP** duplicates the low 64 bits of a source operand to both the low and high 64 bits of the destination XMM register, facilitating operations that require broadcast of double-precision values.

**MOVSHDUP** and **MOVSLDUP** duplicate the high or low single-precision floating-point values from each pair of adjacent elements, providing efficient element replication for specific computational patterns.

