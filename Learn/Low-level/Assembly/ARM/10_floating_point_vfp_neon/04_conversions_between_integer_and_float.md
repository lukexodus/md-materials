## Conversions Between Integer and Float


**Integer to floating point:**

**Signed integer to float:**

```asm
; S register to single precision
VCVT.F32.S32 S0, S1         ; S0 = (float)S1 (signed)

; Core register to single precision
VMOV S0, R0                 ; Move integer from core register
VCVT.F32.S32 S0, S0         ; Convert to float

; S register to double precision
VCVT.F64.S32 D0, S1         ; D0 = (double)S1

; Core register to double precision
VMOV S0, R0
VCVT.F64.S32 D0, S0
```

**Unsigned integer to float:**

```asm
; Unsigned conversion
VCVT.F32.U32 S0, S1         ; S0 = (float)S1 (unsigned)
VCVT.F64.U32 D0, S1         ; D0 = (double)S1 (unsigned)

; From core register
VMOV S0, R0
VCVT.F32.U32 S0, S0
```

**Floating point to integer:**

**Float to signed integer (round to nearest):**

```asm
; Single to signed integer
VCVT.S32.F32 S0, S1         ; S0 = (int)S1 (round to nearest)

; Double to signed integer
VCVT.S32.F64 S0, D1         ; S0 = (int)D1

; Move to core register
VCVT.S32.F32 S0, S1
VMOV R0, S0                 ; R0 = integer result
```

**Float to unsigned integer:**

```asm
VCVT.U32.F32 S0, S1         ; S0 = (unsigned)S1
VCVT.U32.F64 S0, D1         ; S0 = (unsigned)D1
```

**Rounding variants:**

```asm
; Round toward zero (truncate)
VCVT.S32.F32 S0, S1         ; Default uses current FPSCR rounding
VCVTR.S32.F32 S0, S1        ; Explicit round toward zero
VCVTR.U32.F32 S0, S1        ; Unsigned, round toward zero

; Round toward minus infinity (floor)
VCVTM.S32.F32 S0, S1        ; Floor (ARMv8)

; Round toward plus infinity (ceiling)
VCVTP.S32.F32 S0, S1        ; Ceiling (ARMv8)

; Round to nearest
VCVTN.S32.F32 S0, S1        ; Round to nearest (ARMv8)

; Round using current mode
VCVTA.S32.F32 S0, S1        ; Round using FPSCR mode (ARMv8)
```

**Fixed-point conversions:**

VFP supports conversion between floating point and fixed-point representations:

```asm
; Float to fixed point
; VCVT.S32.F32 Sd, Sm, #fbits
; Converts float to fixed point with specified fractional bits
VCVT.S32.F32 S0, S1, #16    ; S0 = S1 * 2^16 (16 fractional bits)
VCVT.U32.F32 S0, S1, #8     ; S0 = S1 * 2^8 (8 fractional bits)

; Fixed point to float
VCVT.F32.S32 S0, S1, #16    ; S0 = S1 / 2^16
VCVT.F32.U32 S0, S1, #8     ; S0 = S1 / 2^8

; Range: #fbits can be 1-32
```

**Precision conversions:**

```asm
; Single to double precision
VCVT.F64.F32 D0, S1         ; D0 = (double)S1 (widening)

; Double to single precision
VCVT.F32.F64 S0, D1         ; S0 = (float)D1 (narrowing, may lose precision)
```

**Transfer between core and VFP registers:**

```asm
; Core register to VFP single precision
VMOV S0, R0                 ; S0 = R0 (bitwise copy, no conversion)

; VFP single precision to core register
VMOV R0, S0                 ; R0 = S0 (bitwise copy)

; Core registers to VFP double precision
VMOV D0, R0, R1             ; D0 = {R1, R0} (R0=low, R1=high)

; VFP double precision to core registers
VMOV R0, R1, D0             ; {R1, R0} = D0

; Direct transfer with conversion
VMOV S0, R0                 ; Bitwise move
VCVT.F32.S32 S0, S0         ; Then convert

; Or use combined operation (ARMv8)
; FMOV (AArch64)
```

**Example:**

```asm
; Convert array of integers to floats
; R0 = source array (int32_t*)
; R1 = destination array (float*)
; R2 = count

int_to_float_array:
    PUSH {R4-R5, LR}
    MOV R4, R0
    MOV R5, R1
    
loop:
    LDR R3, [R4], #4        ; Load integer
    VMOV S0, R3             ; Move to VFP
    VCVT.F32.S32 S0, S0     ; Convert to float
    VSTR.F32 S0, [R5], #4   ; Store float
    
    SUBS R2, R2, #1
    BNE loop
    
    POP {R4-R5, PC}

; Convert float array to integers with rounding
float_to_int_array:
    PUSH {R4-R5, LR}
    MOV R4, R0
    MOV R5, R1
    
loop2:
    VLDR.F32 S0, [R4], #4   ; Load float
    VCVTR.S32.F32 S1, S0    ; Convert (round toward zero)
    VMOV R3, S1             ; Move to core register
    STR R3, [R5], #4        ; Store integer
    
    SUBS R2, R2, #1
    BNE loop2
    
    POP {R4-R5, PC}
```

**Handling conversion overflow:**

```asm
; Safe float-to-int with bounds checking
safe_float_to_int:
    VLDR.F32 S0, [R0]       ; Load float value
    
    ; Check if value is in valid range for int32
    VMOV.F32 S1, #2147483648.0  ; INT_MAX + 1 (not exactly representable)
    VNEG.F32 S2, S1         ; -INT_MAX - 1
    
    VCMP.F32 S0, S1
    VMRS APSR_nzcv, FPSCR
    BGE overflow_pos        ; Too large
    
    VCMP.F32 S0, S2
    VMRS APSR_nzcv, FPSCR
    BLE overflow_neg        ; Too small
    
    ; Value is in range
    VCVTR.S32.F32 S3, S0
    VMOV R0, S3
    BX LR
    
overflow_pos:
    MOV R0, #0x7FFFFFFF     ; INT_MAX
    BX LR
    
overflow_neg:
    MOV R0, #0x80000000     ; INT_MIN
    BX LR
```

**Key Points:**

- VFP provides S registers (32-bit single precision) and D registers (64-bit double precision) with register aliasing
- Single and double precision operations follow IEEE 754 standard with support for special values (infinity, NaN, denormals)
- Floating-point arithmetic includes basic operations, fused multiply-add, comparisons, and mathematical functions
- Conversions support integer↔float, float↔fixed-point, and single↔double precision with various rounding modes
- FPSCR controls rounding behavior, exception handling, and flush-to-zero mode

[Inference] Performance characteristics vary across ARM implementations - actual instruction latencies and throughput depend on specific processor microarchitecture (Cortex-A series vs Cortex-M series vs custom designs).

---

