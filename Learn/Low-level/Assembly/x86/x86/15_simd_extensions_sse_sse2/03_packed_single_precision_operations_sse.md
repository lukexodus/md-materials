## Packed Single-Precision Operations (SSE)


Packed operations process multiple data elements in parallel within a single instruction. SSE's packed single-precision operations work on four 32-bit floating-point values simultaneously.

**Arithmetic Operations:**

`ADDPS xmm1, xmm2/m128` - Add Packed Single-Precision Adds four pairs of single-precision floating-point values. Each of the four 32-bit lanes performs an independent addition.

`SUBPS xmm1, xmm2/m128` - Subtract Packed Single-Precision Subtracts four single-precision values in the source from the destination.

`MULPS xmm1, xmm2/m128` - Multiply Packed Single-Precision Multiplies four pairs of single-precision values simultaneously.

`DIVPS xmm1, xmm2/m128` - Divide Packed Single-Precision Divides four single-precision values in the destination by those in the source.

`SQRTPS xmm1, xmm2/m128` - Square Root Packed Single-Precision Computes square roots of four single-precision values.

**Comparison Operations:**

`CMPPS xmm1, xmm2/m128, imm8` - Compare Packed Single-Precision Compares four pairs of single-precision values using a comparison predicate specified by imm8. Results are written as all-ones (0xFFFFFFFF) for true or all-zeros (0x00000000) for false in each 32-bit lane.

Comparison predicates:

- 0x00: Equal (EQ)
- 0x01: Less Than (LT)
- 0x02: Less Than or Equal (LE)
- 0x03: Unordered (NaN involved)
- 0x04: Not Equal (NEQ)
- 0x05: Not Less Than (NLT)
- 0x06: Not Less Than or Equal (NLE)
- 0x07: Ordered (no NaN)

**Logical Operations:**

`ANDPS xmm1, xmm2/m128` - Bitwise AND `ANDNPS xmm1, xmm2/m128` - Bitwise AND NOT `ORPS xmm1, xmm2/m128` - Bitwise OR `XORPS xmm1, xmm2/m128` - Bitwise XOR

These operate on the bit patterns of the registers, treating the 128-bit register as a whole.

**Min/Max Operations:**

`MAXPS xmm1, xmm2/m128` - Maximum Packed Single-Precision `MINPS xmm1, xmm2/m128` - Minimum Packed Single-Precision

Compare corresponding elements and select maximum or minimum values.

**Reciprocal Operations:**

`RCPPS xmm1, xmm2/m128` - Reciprocal Packed Single-Precision Computes approximate reciprocals (1/x) of four single-precision values. Provides fast but less accurate results (relative error ≤ 1.5 × 2^-12).

`RSQRTPS xmm1, xmm2/m128` - Reciprocal Square Root Packed Single-Precision Computes approximate reciprocal square roots (1/√x) with similar accuracy characteristics.

