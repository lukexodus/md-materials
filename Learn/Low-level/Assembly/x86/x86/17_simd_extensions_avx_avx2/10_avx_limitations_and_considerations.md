## AVX Limitations and Considerations


**Lane-based operation model**: Many AVX operations work within 128-bit lanes, limiting some cross-lane operations.

**Power consumption**: [Inference] AVX instructions consume more power than scalar operations, potentially triggering frequency scaling.

**Code size**: VEX encoding adds prefix bytes, potentially increasing code size compared to legacy encoding.

**Processor support**: Requires runtime detection (CPUID) for AVX/AVX2 support before use.

**Alignment sensitivity**: [Inference] While unaligned operations exist, aligned data provides better performance on most microarchitectures.

**Limited gather performance**: [Inference] Gather operations, while convenient, may have lower throughput than alternative approaches for regular access patterns.

