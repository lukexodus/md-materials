## Strength Reduction


Strength reduction replaces expensive operations with cheaper equivalent operations to improve performance. In ARM assembly, this primarily involves replacing multiplication and division with shifts, additions, and subtractions.

**Multiplication by constants:**

- Multiplying by powers of 2: Replace `MUL` with logical shift left (`LSL`)
- Multiplying by (2^n ± 1): Use shift and add/subtract combinations
- Multiplying by small constants: Decompose into shifts and adds

**Division by constants:**

- Dividing by powers of 2: Replace with arithmetic shift right (`ASR`) for signed, logical shift right (`LSR`) for unsigned
- Dividing by other constants: Use multiplication by reciprocal (fixed-point arithmetic) when division hardware is unavailable or slow

**Common transformations:**

- `x * 2` → `x << 1` or `LSL x, x, #1`
- `x * 4` → `x << 2` or `LSL x, x, #2`
- `x * 3` → `x + (x << 1)` or `ADD x, x, x, LSL #1`
- `x * 5` → `x + (x << 2)` or `ADD x, x, x, LSL #2`
- `x * 7` → `x - (x << 3)` (negated) or `RSB x, x, x, LSL #3`
- `x / 8` → `x >> 3` or `ASR x, x, #3` (signed)

**Example:**

```asm
; Inefficient - multiplication
MOV r1, #12
MUL r0, r1, r0          ; r0 = r0 * 12

; Optimized - strength reduction
; 12 = 8 + 4 = (x << 3) + (x << 2)
ADD r0, r0, r0, LSL #2  ; r0 = r0 + (r0 * 4) = r0 * 5
ADD r0, r0, r0, LSL #1  ; r0 = r0 + (r0 * 2) = r0 * 3
; Alternative: 12 = 3 * 4
ADD r0, r0, r0, LSL #1  ; r0 = r0 * 3
LSL r0, r0, #2          ; r0 = r0 * 4
```

**Address calculation optimization:** Array indexing can be optimized using shifted register operands instead of separate multiplication:

```asm
; Accessing array[i] where each element is 4 bytes
; Inefficient
MOV r2, #4
MUL r2, r1, r2          ; offset = i * 4
LDR r0, [r0, r2]        ; load array[i]

; Optimized - use shifted register addressing
LDR r0, [r0, r1, LSL #2] ; load array[i], offset = i << 2
```

