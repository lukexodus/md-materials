## Scalar Operations


Scalar operations process only the lowest element of an XMM register while leaving the upper elements unchanged. This is useful for single-value computations while maintaining compatibility with SIMD code paths.

**Scalar Single-Precision Operations (SSE):**

`ADDSS xmm1, xmm2/m32` - Add Scalar Single-Precision Adds the lowest 32 bits of both operands, stores result in lowest 32 bits of destination. Bits 127:32 of destination are unchanged.

`SUBSS xmm1, xmm2/m32` - Subtract Scalar Single-Precision `MULSS xmm1, xmm2/m32` - Multiply Scalar Single-Precision `DIVSS xmm1, xmm2/m32` - Divide Scalar Single-Precision `SQRTSS xmm1, xmm2/m32` - Square Root Scalar Single-Precision

**Comparison:**

`CMPSS xmm1, xmm2/m32, imm8` - Compare Scalar Single-Precision Compares lowest 32 bits using the specified predicate, writes result to lowest 32 bits.

`COMISS xmm1, xmm2/m32` - Compare Ordered Scalar Single-Precision `UCOMISS xmm1, xmm2/m32` - Unordered Compare Scalar Single-Precision

These set EFLAGS (ZF, PF, CF) based on comparison results, enabling conditional branches.

**Conversion:**

`CVTSI2SS xmm1, r/m32` - Convert Doubleword Integer to Scalar Single-Precision `CVTSS2SI r32, xmm/m32` - Convert Scalar Single-Precision to Doubleword Integer `CVTTSS2SI r32, xmm/m32` - Convert with Truncation Scalar Single-Precision to Integer

**Scalar Double-Precision Operations (SSE2):**

`ADDSD xmm1, xmm2/m64` - Add Scalar Double-Precision Operates on lowest 64 bits, preserving bits 127:64 of destination.

`SUBSD xmm1, xmm2/m64` - Subtract Scalar Double-Precision `MULSD xmm1, xmm2/m64` - Multiply Scalar Double-Precision `DIVSD xmm1, xmm2/m64` - Divide Scalar Double-Precision `SQRTSD xmm1, xmm2/m64` - Square Root Scalar Double-Precision

**Comparison:**

`CMPSD xmm1, xmm2/m64, imm8` - Compare Scalar Double-Precision `COMISD xmm1, xmm2/m64` - Compare Ordered Scalar Double-Precision `UCOMISD xmm1, xmm2/m64` - Unordered Compare Scalar Double-Precision

**Conversion:**

`CVTSI2SD xmm1, r/m32` - Convert Doubleword Integer to Scalar Double-Precision `CVTSD2SI r32, xmm/m64` - Convert Scalar Double-Precision to Doubleword Integer `CVTTSD2SI r32, xmm/m64` - Convert with Truncation `CVTSS2SD xmm1, xmm2/m32` - Convert Scalar Single to Scalar Double `CVTSD2SS xmm1, xmm2/m64` - Convert Scalar Double to Scalar Single

