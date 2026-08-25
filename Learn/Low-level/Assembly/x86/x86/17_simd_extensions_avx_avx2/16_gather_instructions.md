## Gather Instructions


Gather instructions represent one of AVX2's most significant additions, enabling efficient gathering of non-contiguous memory elements indexed by a vector of offsets or indices. Before gather instructions, accessing scattered memory locations required scalar operations or complex shuffle sequences.

### Gather Operation Mechanics

**VGATHERDPS**, **VGATHERQPS**, **VGATHERDPD**, **VGATHERQPD** gather floating-point values. The instruction name encodes both the index size (D for 32-bit, Q for 64-bit indices) and the data type (PS for single-precision, PD for double-precision).

**VPGATHERDD**, **VPGATHERQD**, **VPGATHERDQ**, **VPGATHERQQ** gather integer values with corresponding index and data sizes.

The gather operation computes memory addresses as:

```
address[i] = base + (index[i] * scale)
```

The scale factor can be 1, 2, 4, or 8 bytes, matching typical element sizes.

```nasm
vmovdqa ymm0, [indices]     ; Load 8 indices (32-bit)
vpcmpeqd ymm1, ymm1, ymm1   ; Create all-ones mask
vgatherdps ymm2, [base + ymm0*4], ymm1
; ymm2[i] = memory[base + indices[i] * 4]
```

### Mask Register

Gather instructions require a mask register that serves dual purposes:

1. Controls which elements are gathered (only elements with mask bit set)
2. Updated during execution to track completion

The instruction zeros mask bits as corresponding elements are gathered. [Inference] This mechanism allows the hardware to track progress and handle faults, as gather operations may take multiple cycles to complete due to cache misses and memory latency.

After execution, the mask register contains all zeros if the gather completed successfully. Interrupts or faults during gather execution preserve the mask state, allowing restart at the interruption point.

### Performance Characteristics

[Unverified] Gather instructions provide convenience and code density improvements but do not necessarily offer performance advantages over equivalent scalar loads in all scenarios. The performance depends on cache behavior, memory access patterns, and the specific microarchitecture.

[Inference] Gather operations are most beneficial when:

- Accessed memory locations are cache-resident, minimizing memory latency impact
- The alternative would require complex scalar code with multiple instructions per element
- The access pattern is truly random and cannot be coalesced or reorganized

[Unverified] For predictable access patterns or when most accessed data resides in the same cache line, traditional memory operations combined with shuffle instructions may achieve competitive or superior performance to gather operations.

[Inference] The primary advantage of gather instructions is programmability and code simplicity rather than raw throughput. They eliminate complex indexing code and reduce instruction count substantially.

### Gather Limitations

Gather instructions have several constraints:

Each gather operation accesses at most the number of elements in the vector register (4 or 8 depending on element size and register width). [Inference] Larger datasets require multiple gather instructions.

Gathered memory accesses can trigger page faults or protection violations. The mask mechanism enables proper exception handling by allowing the operation to partially complete.

[Unverified] On some microarchitectures, gather instructions decompose into multiple micro-operations, with execution latency proportional to the number of cache misses encountered. Sequential cache misses are particularly expensive.

### Gather Example: Indirect Array Access

```nasm
; Gather elements: output[i] = input[indices[i]]
section .data
align 32
indices: dd 0, 5, 2, 7, 1, 4, 3, 6
input: times 16 dd 0

section .text
mov rax, input
vmovdqa ymm0, [indices]     ; Load 8 indices
vpcmpeqd ymm1, ymm1, ymm1   ; Create mask (all ones)
vgatherdps ymm2, [rax + ymm0*4], ymm1
; ymm2 now contains 8 gathered values
vmovdqa [output], ymm2
```

