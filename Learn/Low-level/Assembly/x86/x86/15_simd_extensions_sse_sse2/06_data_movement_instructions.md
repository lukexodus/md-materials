## Data Movement Instructions


Efficient data movement between memory, XMM registers, and general-purpose registers is critical for SIMD performance.

**Aligned Loads and Stores:**

`MOVAPS xmm1, xmm2/m128` - Move Aligned Packed Single-Precision `MOVAPS xmm2/m128, xmm1` - Store Aligned Packed Single-Precision Requires 16-byte alignment. Generates general protection fault if memory operand is not aligned. Provides best performance.

`MOVAPD xmm1, xmm2/m128` - Move Aligned Packed Double-Precision `MOVAPD xmm2/m128, xmm1` - Store Aligned Packed Double-Precision Same alignment requirements as MOVAPS.

**Unaligned Loads and Stores:**

`MOVUPS xmm1, xmm2/m128` - Move Unaligned Packed Single-Precision `MOVUPS xmm2/m128, xmm1` - Store Unaligned Packed Single-Precision No alignment requirements but significantly slower performance on unaligned addresses.

`MOVUPD xmm1, xmm2/m128` - Move Unaligned Packed Double-Precision `MOVUPD xmm2/m128, xmm1` - Store Unaligned Packed Double-Precision

**Scalar Loads and Stores:**

`MOVSS xmm1, xmm2/m32` - Move Scalar Single-Precision When loading from memory, loads 32 bits into lowest element and zeros upper 96 bits. When source is XMM register, only lowest 32 bits are moved, upper bits of destination preserved.

`MOVSS xmm2/m32, xmm1` - Store Scalar Single-Precision Stores lowest 32 bits of XMM register.

`MOVSD xmm1, xmm2/m64` - Move Scalar Double-Precision When loading from memory, loads 64 bits into lowest element and zeros upper 64 bits. When source is XMM register, only lowest 64 bits moved.

`MOVSD xmm2/m64, xmm1` - Store Scalar Double-Precision

**High/Low Data Movement:**

`MOVLPS xmm1, m64` - Move Low Packed Single-Precision Loads 64 bits into bits 63:0 of XMM register, leaving bits 127:64 unchanged.

`MOVLPS m64, xmm1` - Store Low Packed Single-Precision Stores bits 63:0 of XMM register.

`MOVHPS xmm1, m64` - Move High Packed Single-Precision Loads 64 bits into bits 127:64 of XMM register, leaving bits 63:0 unchanged.

`MOVHPS m64, xmm1` - Store High Packed Single-Precision Stores bits 127:64 of XMM register.

`MOVLPD/MOVHPD` - Double-precision equivalents with same behavior.

**Data Duplication:**

`MOVLHPS xmm1, xmm2` - Move Low to High Packed Single-Precision Copies bits 63:0 from xmm2 to bits 127:64 of xmm1.

`MOVHLPS xmm1, xmm2` - Move High to Low Packed Single-Precision Copies bits 127:64 from xmm2 to bits 63:0 of xmm1.

**Non-Temporal Stores (SSE/SSE2):**

`MOVNTPS m128, xmm1` - Store Packed Single-Precision Non-Temporal `MOVNTPD m128, xmm1` - Store Packed Double-Precision Non-Temporal `MOVNTDQ m128, xmm1` - Store Doubleword Quad Non-Temporal

Non-temporal stores bypass cache hierarchy, writing directly to memory. Used for write-only data that won't be accessed soon, preventing cache pollution. Requires 16-byte aligned addresses.

`MOVNTI m32, r32` - Store Doubleword Non-Temporal `MOVNTQ m64, mm` - Store Quadword Non-Temporal (MMX)

**Integer Data Movement (SSE2):**

`MOVDQA xmm1, xmm2/m128` - Move Aligned Double Quadword `MOVDQA xmm2/m128, xmm1` - Store Aligned Double Quadword For aligned integer data, equivalent to MOVAPD but semantically clearer for integer operations.

`MOVDQU xmm1, xmm2/m128` - Move Unaligned Double Quadword `MOVDQU xmm2/m128, xmm1` - Store Unaligned Double Quadword Unaligned integer data movement.

`MOVD xmm1, r/m32` - Move Doubleword `MOVD r/m32, xmm1` - Extract Doubleword Transfers 32 bits between XMM register (lowest element) and general-purpose register or memory.

`MOVQ xmm1, xmm2/m64` - Move Quadword `MOVQ xmm2/m64, xmm1` - Store Quadword Transfers 64 bits between XMM registers or memory.

**Interleaving and Extraction:**

`PUNPCKLBW/PUNPCKLWD/PUNPCKLDQ/PUNPCKLQDQ` - Unpack Low Data Interleaves data from low halves of source and destination.

`PUNPCKHBW/PUNPCKHWD/PUNPCKHDQ/PUNPCKHQDQ` - Unpack High Data Interleaves data from high halves of source and destination.

`PEXTRW r32, xmm, imm8` - Extract Word Extracts 16-bit value from specified position into general-purpose register.

`PINSRW xmm, r32/m16, imm8` - Insert Word Inserts 16-bit value from general-purpose register or memory into specified position.

**Shuffle and Permute:**

`SHUFPS xmm1, xmm2/m128, imm8` - Shuffle Packed Single-Precision Selects two elements from destination and two from source using 8-bit immediate control byte. Each 2-bit field selects one element.

`SHUFPD xmm1, xmm2/m128, imm8` - Shuffle Packed Double-Precision Selects one element from destination and one from source using 2-bit immediate.

`PSHUFW mm1, mm2/m64, imm8` - Shuffle Packed Words (MMX) `PSHUFD xmm1, xmm2/m128, imm8` - Shuffle Packed Doublewords `PSHUFHW xmm1, xmm2/m128, imm8` - Shuffle High Words `PSHUFLW xmm1, xmm2/m128, imm8` - Shuffle Low Words

**Broadcast:**

`MOVSHDUP xmm1, xmm2/m128` (SSE3) - Move and Duplicate High Duplicates odd-indexed single-precision elements.

`MOVSLDUP xmm1, xmm2/m128` (SSE3) - Move and Duplicate Low Duplicates even-indexed single-precision elements.

**Streaming Load:**

`MOVNTDQA xmm1, m128` (SSE4.1) - Load Double Quadword Non-Temporal Aligned Hint Provides hint that data is non-temporal (streaming reads from memory).

