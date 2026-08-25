## Debugging and Common Pitfalls


**Mask Register Confusion:** K0 has special semantics (no masking when used as write mask). Using K0 when masking is intended produces unexpected results where all elements are written.

**Broadcast Size Mismatch:** Using `{1to16}` with 64-bit element operations causes errors. Element size must match broadcast notation (32-bit uses `{1to16}`, 64-bit uses `{1to8}`).

**Embedded Rounding Restrictions:** Embedded rounding works only with register-to-register operations, not memory operands. Attempting to use rounding with memory operands fails.

**Zero-Masking Initialization:** Zero-masking (`{z}`) zeroes non-selected elements. If subsequent operations expect specific values in those positions, results will be incorrect.

**Gather/Scatter Address Calculation:** Scale factor applies to index values, not to the element size. A scale of 4 means indices are multiplied by 4, requiring careful address computation.

**EVEX Prefix Requirements:** AVX-512 instructions require EVEX encoding and cannot be used with VEX prefixes. Assemblers automatically handle this, but hand-coded machine code must use correct encoding.

**Ternary Logic Truth Tables:** The immediate value encodes a complete 8-bit truth table. Incorrect values produce wrong logic operations. Use standard boolean algebra to derive correct immediate values.

**Permutation Index Bounds:** Out-of-range indices in permutation operations produce implementation-defined results (typically wrap or return zero). Validate index ranges.

**Compress/Expand Mask Misuse:** Compress packs to low elements based on mask bit count. If mask has N bits set, only the lowest N source elements are used. Understanding this behavior is critical.

**Alignment Faults:** 512-bit operations on unaligned addresses may fault or perform poorly. Ensure 64-byte alignment for arrays accessed by AVX-512.

**Feature Detection:** AVX-512 has many subsets. Code using VNNI, VBMI, or FP16 instructions must verify those specific features via CPUID, not just AVX-512F.

**Register Naming Confusion:** ZMM, YMM, and XMM refer to the same physical registers but different portions. Writing to XMM0 affects the lower 128 bits of ZMM0. Some processors zero upper bits on XMM writes; others preserve them.

**Masked Load Confusion:** Unlike masked arithmetic operations, masked load instructions (gather) consume mask bits differently. Each successful load clears the corresponding mask bit to prevent re-reading.

