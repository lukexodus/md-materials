## Performance Optimization Tips


**Align data to 32-byte boundaries** for optimal load/store performance.

**Use FMA instructions** when available for combined multiply-add operations.

**Minimize lane-crossing operations** on older microarchitectures.

**Process data in cache-line-sized chunks** (64 bytes = 2 AVX loads).

**Exploit three-operand format** to reduce register pressure and eliminate moves.

**Use appropriate precision** (single vs double) based on application requirements.

**Prefetch data** when memory latency is the bottleneck.

**Profile actual performance** rather than relying on theoretical throughput, as [Inference] microarchitectural details significantly impact real-world performance.

**Important subtopics**: AVX-512 extensions (512-bit ZMM registers, mask registers, embedded rounding), Intel intrinsics guide, microarchitecture-specific optimization (Haswell, Skylake, Zen), auto-vectorization compiler techniques, mixed-precision computation strategies, memory bandwidth optimization, SIMD algorithm design patterns.

---

