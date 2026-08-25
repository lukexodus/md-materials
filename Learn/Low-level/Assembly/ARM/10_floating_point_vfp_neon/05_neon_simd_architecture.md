## NEON SIMD Architecture


NEON is ARM's Advanced SIMD (Single Instruction, Multiple Data) architecture extension that enables parallel processing of multiple data elements with a single instruction. Introduced with ARMv7-A and available in Cortex-A series processors, NEON operates alongside the Vector Floating Point (VFP) unit, sharing the same register bank but providing distinct instruction sets.

**Architecture Overview:** NEON implements a 128-bit wide datapath capable of processing vectors of 8, 16, 32, or 64-bit elements simultaneously. The architecture supports both integer and floating-point operations, making it suitable for multimedia processing, signal processing, graphics, and computational workloads requiring data parallelism.

**VFP vs NEON Distinction:**

**VFP (Vector Floating Point):** Provides scalar floating-point arithmetic compliant with IEEE 754. VFPv3 and VFPv4 support single-precision (32-bit) and double-precision (64-bit) operations. VFP executes one operation per instruction on scalar values.

**NEON:** Provides SIMD operations on packed integer and floating-point data. NEON can perform multiple operations simultaneously on vector elements. NEON floating-point is not fully IEEE 754 compliant—it lacks support for denormalized numbers, NaN propagation differs, and rounding modes are limited.

**Datapath Configuration:** NEON operates on multiple data types within vectors:

- **8-bit elements:** 8×8 (64-bit vector) or 16×8 (128-bit vector) - bytes
- **16-bit elements:** 4×16 (64-bit) or 8×16 (128-bit) - halfwords/16-bit integers/half-floats
- **32-bit elements:** 2×32 (64-bit) or 4×32 (128-bit) - words/32-bit integers/single-precision floats
- **64-bit elements:** 1×64 (64-bit) or 2×64 (128-bit) - doublewords/64-bit integers

**Instruction Categories:**

**Arithmetic:** Add, subtract, multiply, multiply-accumulate, absolute value, negate operations on vectors.

**Logical:** Bitwise AND, OR, XOR, NOT, bit clear operations.

**Comparison:** Element-wise comparisons generating mask results.

**Shifts and Rotates:** Vector shifts (logical/arithmetic), rotates, narrow/widen operations.

**Load/Store:** Multiple-element structure loads/stores for interleaved data, single-element access, alignment-specific operations.

**Permutation:** Vector extract, zip (interleave), unzip (deinterleave), transpose, reverse, table lookup operations.

**Conversion:** Type conversions between integer/float, widening/narrowing conversions, fixed-point conversions.

**Execution Pipeline:** [Inference based on typical ARM Cortex-A implementations] NEON instructions execute through dedicated SIMD execution units separate from the integer pipeline. The NEON pipeline depth varies by processor (9-10 stages in Cortex-A8/A9, shorter in newer cores). Load/store operations access memory through dedicated NEON load/store units with independent queues.

**IEEE 754 Non-Compliance in NEON:** NEON floating-point deviates from IEEE 754 in specific ways:

- **Denormalized numbers:** Flushed to zero on input and output
- **NaN handling:** Only quiet NaNs supported; operations may not propagate NaNs as IEEE 754 specifies
- **Rounding modes:** Only round-to-nearest supported (no round-toward-zero, toward-infinity modes)
- **Exception handling:** Does not generate floating-point exceptions; sets flags in FPSCR instead

These deviations improve performance and reduce hardware complexity but make NEON unsuitable for applications requiring strict IEEE 754 compliance.

