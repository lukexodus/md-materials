## Conditional SIMD Operations


NEON provides conditional operations that select or blend results based on comparisons, enabling data-dependent processing within SIMD vectors.

### Vector Comparisons

**VCEQ - Vector Compare Equal**

VCEQ compares corresponding elements from two vectors, setting result lanes to all 1s where elements are equal, all 0s otherwise.

**Example:**

```assembly
@ Compare eight 16-bit values
@ Q0 = {10, 20, 30, 40, 50, 60, 70, 80}
@ Q1 = {10, 25, 30, 35, 50, 65, 70, 75}
VCEQ.I16 Q2, Q0, Q1         @ Q2 = {0xFFFF, 0, 0xFFFF, 0, 0xFFFF, 0, 0xFFFF, 0}
                            @ Lanes 0, 2, 4, 6 match (all bits set)
                            @ Lanes 1, 3, 5, 7 differ (all bits clear)
```

**VCGE/VCGT - Vector Compare Greater Equal/Greater Than**

VCGE and VCGT perform magnitude comparisons with signed or unsigned variants.

**Example:**

```assembly
@ Compare greater than (signed)
@ Q0 = {-10, 20, 30, 40}
@ Q1 = {0, 15, 30, 50}
VCGT.S32 Q2, Q0, Q1         @ Q2 = {0, 0xFFFFFFFF, 0, 0}
                            @ Lane 1: 20 > 15 (true)
                            @ Lane 2: 30 > 30 (false)

@ Compare greater or equal (unsigned)
VCGE.U32 Q3, Q0, Q1         @ Treats values as unsigned
```

**VCLE/VCLT - Vector Compare Less Equal/Less Than**

Less-than comparisons are achieved by reversing operand order or using dedicated VCLE/VCLT instructions.

**Example:**

```assembly
@ Compare less than
VCLT.S16 Q2, Q0, Q1         @ Q2[i] = all 1s if Q0[i] < Q1[i]

@ Equivalent using reversed VCGT
VCGT.S16 Q2, Q1, Q0         @ Q2[i] = all 1s if Q1[i] > Q0[i] (same as Q0[i] < Q1[i])
```

**VTST - Vector Test Bits**

VTST tests whether corresponding elements have any bits in common (bitwise AND is non-zero).

**Example:**

```assembly
@ Test if bits overlap
@ Q0 = {0x0F, 0xF0, 0xFF, 0x00, ...}
@ Q1 = {0x10, 0x0F, 0xAA, 0xFF, ...}
VTST.8 Q2, Q0, Q1           @ Q2 = {0, 0, 0xFF, 0, ...}
                            @ Lane 0: 0x0F & 0x10 = 0 (false)
                            @ Lane 1: 0xF0 & 0x0F = 0 (false)
                            @ Lane 2: 0xFF & 0xAA ≠ 0 (true)
                            @ Lane 3: 0x00 & 0xFF = 0 (false)
```

### Vector Select/Blend

**VBSL - Vector Bitwise Select**

VBSL (Bit Select) selects bits from two sources based on a mask. For each bit position, if the mask bit is 1, select from the first source; if 0, select from the second source.

**Example:**

```assembly
@ Mask in Q0 (typically from comparison results)
@ Q0 = {0xFFFFFFFF, 0, 0xFFFFFFFF, 0} (from previous VCEQ/VCGT)
@ Q1 = {100, 200, 300, 400} (true values)
@ Q2 = {10, 20, 30, 40} (false values)
VBSL Q0, Q1, Q2             @ Q0 = {100, 20, 300, 40}
                            @ Select Q1 where mask is all 1s, Q2 where mask is 0
```

**VBIF/VBIT - Vector Bit Insert if False/True**

VBIF and VBIT conditionally update destination bits based on a mask.

**Example:**

```assembly
@ VBIF: Bit Insert if False - update where mask is 0
@ Q0 = destination
@ Q1 = source values
@ Q2 = mask
VBIF Q0, Q1, Q2             @ Q0[bit] = Q1[bit] if Q2[bit] == 0, else unchanged

@ VBIT: Bit Insert if True - update where mask is 1
VBIT Q0, Q1, Q2             @ Q0[bit] = Q1[bit] if Q2[bit] == 1, else unchanged
```

### Conditional Processing Patterns

**Clamping Values**

Use comparisons and selects to clamp values to ranges.

**Example:**

```assembly
@ Clamp values to range [min, max]
@ Q0 = input values
VDUP.32 Q1, r0              @ Q1 = all min value
VDUP.32 Q2, r1              @ Q2 = all max value

@ Clamp to minimum
VCGE.S32 Q3, Q0, Q1         @ Q3 = mask where Q0 >= min
VBSL Q3, Q0, Q1             @ Q3 = Q0 where >= min, else min

@ Clamp to maximum  
VCLE.S32 Q4, Q3, Q2         @ Q4 = mask where Q3 <= max
VBSL Q4, Q3, Q2             @ Q4 = Q3 where <= max, else max
@ Q4 now contains clamped values

@ Alternatively using VMIN/VMAX:
VMAX.S32 Q0, Q0, Q1         @ Q0 = max(Q0, min)
VMIN.S32 Q0, Q0, Q2         @ Q0 = min(Q0, max)
```

**Conditional Accumulation**

Accumulate only values meeting certain conditions.

**Example:**

```assembly
@ Sum only positive values from a vector
@ Q0 = input values (signed)
@ Q1 = accumulator (initially zero)
VDUP.32 Q2, #0              @ Zero vector for comparison

VCGT.S32 Q3, Q0, Q2         @ Q3 = mask where Q0 > 0
VAND Q4, Q0, Q3             @ Q4 = Q0 where positive, 0 elsewhere
VADD.I32 Q1, Q1, Q4         @ Accumulate only positive values
```

**Conditional Replacement**

Replace elements matching a condition.

**Example:**

```assembly
@ Replace all zeros with a default value
@ Q0 = input values
VDUP.32 Q1, r0              @ Q1 = default value (all lanes)
VDUP.32 Q2, #0              @ Q2 = zero

VCEQ.I32 Q3, Q0, Q2         @ Q3 = mask where Q0 == 0
VBSL Q3, Q1, Q0             @ Q3 = default where Q0==0, else original Q0
```

