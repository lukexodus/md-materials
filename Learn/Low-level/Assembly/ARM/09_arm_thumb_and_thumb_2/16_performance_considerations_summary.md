## Performance Considerations Summary


[Inference] Based on typical ARM Cortex-A and Cortex-M processor characteristics:

**Code Density:**

- Thumb-2: ~25-30% smaller than ARM
- Mostly 16-bit instructions for common operations
- 32-bit instructions for complex operations

**Performance:**

- Thumb-2: Typically 95-98% of ARM performance
- Identical execution speed per instruction
- Slight overhead from additional instructions needed for complex operations
- Better instruction cache utilization can offset minor inefficiencies

**When Thumb-2 Matches ARM:**

- Simple data processing (low registers, small immediates)
- Load/store operations
- Branch operations within range
- Most common code patterns

**When Thumb-2 Requires Extra Instructions:**

- High register operations (pre-Thumb-2)
- Complex immediates (pre-MOVW/MOVT)
- Heavily predicated code (requires IT blocks)
- Long-range branches (may need veneers)

**Key Takeaway:** Thumb-2 provides excellent code density with minimal performance penalty, making it the preferred mode for most applications on modern ARM processors.

**Important related topics:** NEON vectorization in Thumb-2 mode, Cortex-M processor-specific Thumb-2 extensions, mixed ARM/Thumb-2 optimization strategies, profile-guided optimization for instruction set selection, cache-aware code placement strategies

---

