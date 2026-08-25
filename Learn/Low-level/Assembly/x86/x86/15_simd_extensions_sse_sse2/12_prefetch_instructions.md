## Prefetch Instructions


SSE introduced cache prefetch instructions to improve memory access patterns.

`PREFETCHT0 m8` - Prefetch to all cache levels `PREFETCHT1 m8` - Prefetch to L2 and higher `PREFETCHT2 m8` - Prefetch to L3 and higher `PREFETCHNTA m8` - Prefetch non-temporal (minimize cache pollution)

These provide hints to the processor about future memory accesses. [Inference: Effectiveness depends on memory access patterns and microarchitecture implementation].

---

