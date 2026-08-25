## Debugging and Common Pitfalls


**Alignment Faults:** Using MOVAPS/MOVAPD on unaligned addresses causes general protection faults. Always verify alignment or use unaligned variants.

**Denormal Numbers:** Denormal floating-point numbers can cause severe performance degradation. Set flush-to-zero (FTZ) and denormals-are-zero (DAZ) flags in MXCSR register when precision permits.

**NaN Propagation:** Comparison operations involving NaN values produce specific results. UCOMISS/UCOMISD handle unordered comparisons (NaN present) differently than COMISS/COMISD.

**Partial Register Stalls:** Writing to part of an XMM register then reading the full register can cause stalls. [Inference: This is microarchitecture-dependent and less problematic on modern processors].

**False Dependencies:** Instructions that preserve upper bits create dependencies on previous values. Use zeroing variants when possible.

**Mixed Precision:** Converting between single and double precision requires explicit conversion instructions; binary representations are incompatible.

**Memory Ordering:** Non-temporal stores have relaxed memory ordering. Use SFENCE to ensure stores complete before subsequent operations.

