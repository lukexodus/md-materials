## Packed Double-Precision Operations (SSE2)


SSE2 extends SIMD capabilities to double-precision floating-point and integer operations. Packed double-precision operations work on two 64-bit floating-point values simultaneously.

**Arithmetic Operations:**

`ADDPD xmm1, xmm2/m128` - Add Packed Double-Precision Adds two pairs of double-precision floating-point values.

`SUBPD xmm1, xmm2/m128` - Subtract Packed Double-Precision `MULPD xmm1, xmm2/m128` - Multiply Packed Double-Precision `DIVPD xmm1, xmm2/m128` - Divide Packed Double-Precision `SQRTPD xmm1, xmm2/m128` - Square Root Packed Double-Precision

**Comparison Operations:**

`CMPPD xmm1, xmm2/m128, imm8` - Compare Packed Double-Precision Uses the same predicates as CMPPS but operates on two 64-bit values, producing 64-bit masks.

**Logical Operations:**

`ANDPD xmm1, xmm2/m128` - Bitwise AND `ANDNPD xmm1, xmm2/m128` - Bitwise AND NOT `ORPD xmm1, xmm2/m128` - Bitwise OR `XORPD xmm1, xmm2/m128` - Bitwise XOR

**Min/Max Operations:**

`MAXPD xmm1, xmm2/m128` - Maximum Packed Double-Precision `MINPD xmm1, xmm2/m128` - Minimum Packed Double-Precision

**Integer Operations (SSE2):**

SSE2 introduces comprehensive integer SIMD operations on packed 8-bit, 16-bit, 32-bit, and 64-bit integers.

`PADDB/PADDW/PADDD/PADDQ` - Add packed integers (byte/word/doubleword/quadword) `PSUBB/PSUBW/PSUBD/PSUBQ` - Subtract packed integers `PMULLW/PMULHW` - Multiply packed 16-bit integers (low/high bits) `PMULUDQ` - Multiply packed unsigned 32-bit integers `PAND/PANDN/POR/PXOR` - Logical operations on packed integers `PCMPEQB/PCMPEQW/PCMPEQD` - Compare packed integers for equality `PCMPGTB/PCMPGTW/PCMPGTD` - Compare packed signed integers for greater than `PSLLW/PSLLD/PSLLQ` - Shift left logical packed integers `PSRLW/PSRLD/PSRLQ` - Shift right logical packed integers `PSRAW/PSRAD` - Shift right arithmetic packed integers

