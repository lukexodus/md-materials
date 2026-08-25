## Single and Double Precision Operations


**Single-precision operations use S registers:**

**Basic arithmetic:**

```asm
VADD.F32 S0, S1, S2         ; S0 = S1 + S2
VSUB.F32 S0, S1, S2         ; S0 = S1 - S2
VMUL.F32 S0, S1, S2         ; S0 = S1 * S2
VDIV.F32 S0, S1, S2         ; S0 = S1 / S2
VNEG.F32 S0, S1             ; S0 = -S1
VABS.F32 S0, S1             ; S0 = |S1|
VSQRT.F32 S0, S1            ; S0 = √S1
```

**Fused multiply-add/subtract (VFPv4+):**

```asm
VFMA.F32 S0, S1, S2         ; S0 = S0 + (S1 * S2) - single rounding
VFMS.F32 S0, S1, S2         ; S0 = S0 - (S1 * S2) - single rounding
VFNMA.F32 S0, S1, S2        ; S0 = -S0 - (S1 * S2)
VFNMS.F32 S0, S1, S2        ; S0 = -S0 + (S1 * S2)
```

**Multiply-accumulate (older VFP):**

```asm
VMLA.F32 S0, S1, S2         ; S0 = S0 + (S1 * S2) - two roundings
VMLS.F32 S0, S1, S2         ; S0 = S0 - (S1 * S2)
VNMLA.F32 S0, S1, S2        ; S0 = -S0 - (S1 * S2)
VNMLS.F32 S0, S1, S2        ; S0 = -S0 + (S1 * S2)
VNMUL.F32 S0, S1, S2        ; S0 = -(S1 * S2)
```

**Comparison:**

```asm
VCMP.F32 S0, S1             ; Compare S0 with S1, set FPSCR flags
VCMP.F32 S0, #0.0           ; Compare S0 with zero
VMRS APSR_nzcv, FPSCR       ; Transfer FPSCR flags to APSR
BEQ equal                   ; Branch based on comparison
BGT greater
BLT less
```

**Move and load immediate:**

```asm
VMOV.F32 S0, S1             ; Copy S1 to S0
VMOV.F32 S0, #1.0           ; Load immediate (limited values)
VMOV.F32 S0, #-2.0
VMOV.F32 S0, #0.5

; Immediate values must fit encoding constraints
; Can represent values like: ±n/16, ±n/8, ±n/4, ±n/2, ±n, ±2n, ±4n, etc.
; where n is power of 2 from 0.5 to 31
```

**Load and store:**

```asm
VLDR.F32 S0, [R0]           ; Load from memory address in R0
VSTR.F32 S0, [R0]           ; Store to memory address in R0
VLDR.F32 S0, [R0, #4]       ; Load with offset
VSTR.F32 S0, [R0, #-8]      ; Store with offset

; Load/store multiple (stack operations)
VPUSH {S0-S3}               ; Push S0, S1, S2, S3 to stack
VPOP {S0-S3}                ; Pop from stack to S0-S3
VSTM R0, {S0-S7}            ; Store multiple to memory
VLDM R0, {S0-S7}            ; Load multiple from memory
```

**Double-precision operations use D registers:**

**Basic arithmetic:**

```asm
VADD.F64 D0, D1, D2         ; D0 = D1 + D2
VSUB.F64 D0, D1, D2         ; D0 = D1 - D2
VMUL.F64 D0, D1, D2         ; D0 = D1 * D2
VDIV.F64 D0, D1, D2         ; D0 = D1 / D2
VNEG.F64 D0, D1             ; D0 = -D1
VABS.F64 D0, D1             ; D0 = |D1|
VSQRT.F64 D0, D1            ; D0 = √D1
```

**Fused multiply-add/subtract:**

```asm
VFMA.F64 D0, D1, D2         ; D0 = D0 + (D1 * D2)
VFMS.F64 D0, D1, D2         ; D0 = D0 - (D1 * D2)
VFNMA.F64 D0, D1, D2        ; D0 = -D0 - (D1 * D2)
VFNMS.F64 D0, D1, D2        ; D0 = -D0 + (D1 * D2)
```

**Comparison:**

```asm
VCMP.F64 D0, D1             ; Compare D0 with D1
VCMP.F64 D0, #0.0           ; Compare D0 with zero
VMRS APSR_nzcv, FPSCR       ; Transfer flags to condition codes
```

**Move and load immediate:**

```asm
VMOV.F64 D0, D1             ; Copy D1 to D0
VMOV.F64 D0, #1.0           ; Load immediate
VMOV.F64 D0, #3.14159       ; Not possible - use memory load instead
```

**Load and store:**

```asm
VLDR.F64 D0, [R0]           ; Load from memory
VSTR.F64 D0, [R0]           ; Store to memory
VLDR.F64 D0, [R0, #8]       ; Load with offset
VPUSH {D0-D7}               ; Push to stack
VPOP {D0-D7}                ; Pop from stack
```

**Example:**

```asm
; Calculate: result = (a + b) * (c - d)
; Single precision
VLDR.F32 S0, [R0]           ; Load a
VLDR.F32 S1, [R0, #4]       ; Load b
VLDR.F32 S2, [R0, #8]       ; Load c
VLDR.F32 S3, [R0, #12]      ; Load d

VADD.F32 S4, S0, S1         ; S4 = a + b
VSUB.F32 S5, S2, S3         ; S5 = c - d
VMUL.F32 S6, S4, S5         ; S6 = (a + b) * (c - d)
VSTR.F32 S6, [R1]           ; Store result

; Double precision version
VLDR.F64 D0, [R0]           ; Load a
VLDR.F64 D1, [R0, #8]       ; Load b
VLDR.F64 D2, [R0, #16]      ; Load c
VLDR.F64 D3, [R0, #24]      ; Load d

VADD.F64 D4, D0, D1         ; D4 = a + b
VSUB.F64 D5, D2, D3         ; D5 = c - d
VMUL.F64 D6, D4, D5         ; D6 = (a + b) * (c - d)
VSTR.F64 D6, [R1]           ; Store result
```

