## Vector Registers


NEON and VFP share a unified register bank with dual addressing modes. The register file consists of 32 single-precision (32-bit) registers or 16 double-precision (64-bit) registers in VFP mode, and 32 64-bit registers or 16 128-bit registers in NEON mode.

**Register Naming Conventions:**

**VFP Registers:**

- S0-S31: 32 single-precision (32-bit) registers
- D0-D15: 16 double-precision (64-bit) registers
- Overlapping mapping: D0 = {S1, S0}, D1 = {S3, S2}, etc.

**NEON Registers:**

- D0-D31: 32 doubleword (64-bit) registers
- Q0-Q15: 16 quadword (128-bit) registers
- Overlapping mapping: Q0 = {D1, D0}, Q1 = {D3, D2}, etc.

**Register Bank Structure:**

```
128-bit Quadword Registers (Q):
Q0:  |    D1    |    D0    |
Q1:  |    D3    |    D2    |
Q2:  |    D5    |    D4    |
...
Q15: |   D31    |   D30    |

64-bit Doubleword Registers (D):
D0, D1, D2, D3, ..., D31

32-bit Single Registers (S):
S0, S1, S2, S3, ..., S31 (map to D0-D15)
```

**Physical Organization:** [Inference based on ARM documentation] The register file physically contains 32×64-bit storage elements. Q registers access pairs of consecutive D registers. Writes to a Q register modify both constituent D registers; writes to a D register affect the corresponding half of the Q register.

**Register Overlap Examples:**

```assembly
; Writing to Q0 affects D0 and D1
VMOV.I32 Q0, #0          ; Clear Q0 (D0 and D1 become zero)

; Writing to D1 affects Q0
VMOV.I32 D1, #0xFF       ; Modify D1 (upper half of Q0)

; VFP S registers map to NEON D0-D15 only
VMOV.F32 S0, #1.0        ; S0 is lower 32 bits of D0
```

**Register Allocation:** Compilers typically allocate registers following calling conventions:

**ARM Procedure Call Standard (AAPCS):**

- D0-D7 (Q0-Q3, S0-S15): Argument passing and return values, caller-saved
- D8-D15 (Q4-Q7): Callee-saved (must be preserved across function calls)
- D16-D31 (Q8-Q15): Caller-saved, not used for parameter passing

Functions must preserve D8-D15 if modified, but D0-D7 and D16-D31 can be freely used without preservation.

**Register Usage Patterns:**

**Scalar VFP operations:**

```assembly
VLDR.F32  S0, [R0]       ; Load single float into S0
VLDR.F32  S1, [R1]       ; Load single float into S1
VADD.F32  S2, S0, S1     ; S2 = S0 + S1 (scalar addition)
VSTR.F32  S2, [R2]       ; Store result
```

**Vector NEON operations:**

```assembly
VLD1.32   {D0, D1}, [R0] ; Load 4×32-bit values into Q0
VLD1.32   {D2, D3}, [R1] ; Load 4×32-bit values into Q1
VADD.I32  Q2, Q0, Q1     ; Q2 = Q0 + Q1 (4 additions in parallel)
VST1.32   {D4, D5}, [R2] ; Store 4×32-bit results
```

**Lane Extraction:** Individual elements within vector registers can be accessed:

```assembly
VMOV.32   R0, D0[0]      ; Extract lane 0 of D0 to R0
VMOV.32   D1[1], R1      ; Insert R1 into lane 1 of D1
```

**Register Pressure Management:** With only 32 D registers (16 Q registers), register pressure becomes significant in complex NEON code. Strategies include:

- Reusing registers after values are consumed
- Spilling to memory when necessary
- Loop unrolling limited by available registers
- Careful ordering to minimize live ranges

**FPSCR (Floating-Point Status and Control Register):** Controls floating-point and NEON behavior:

- Rounding modes (VFP only)
- Flush-to-zero mode
- Default NaN mode
- Exception flags (invalid operation, divide by zero, overflow, underflow, inexact)
- Vector length and stride (deprecated in NEON)

```assembly
VMRS  R0, FPSCR          ; Read FPSCR to R0
VMSR  FPSCR, R1          ; Write R1 to FPSCR
```

