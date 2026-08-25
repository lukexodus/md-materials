## Saturation Arithmetic


Saturation arithmetic clamps results to representable ranges instead of wrapping around on overflow. When an operation would exceed maximum or minimum representable values, saturation sets the result to the boundary value. This behavior is crucial for signal processing, multimedia applications, and control systems where wrapping could cause instability.

### Saturation Concepts

**Wrapping vs Saturation**

Standard arithmetic wraps on overflow: adding 1 to 0x7FFFFFFF (max positive 32-bit signed) produces 0x80000000 (max negative). Saturation instead produces 0x7FFFFFFF, clamping to the maximum representable value. Similarly, subtracting 1 from 0x80000000 produces 0x7FFFFFFF with wrapping, or 0x80000000 with saturation.

**Applications**

Audio processing uses saturation to prevent distortion when mixing signals - clipping is preferable to wraparound which creates severe artifacts. Image processing clamps pixel values to valid ranges (0-255 for 8-bit). Control systems avoid instability from integer overflow in feedback loops.

### Saturating Instructions

ARMv6 and later architectures include dedicated saturation instructions in the DSP extensions.

**SSAT - Signed Saturate**

SSAT saturates a signed value to a specified bit width. The syntax `SSAT rd, #n, rn` saturates the value in `rn` to an n-bit signed range (-2^(n-1) to 2^(n-1)-1) and stores the result in `rd`. The Q (saturation) flag in CPSR is set if saturation occurs.

**Example:**

```assembly
@ Saturate to 8-bit signed range (-128 to 127)
MOV r0, #200                @ Value exceeds 8-bit signed max
SSAT r1, #8, r0             @ r1 = 127 (saturated to max)
                            @ Q flag set

MOV r0, #-200               @ Value below 8-bit signed min
SSAT r1, #8, r0             @ r1 = -128 (saturated to min)
                            @ Q flag set

MOV r0, #50                 @ Value within range
SSAT r1, #8, r0             @ r1 = 50 (no saturation)
                            @ Q flag unchanged

@ Saturate result of arithmetic to 16-bit signed
MOV r0, #30000
MOV r1, #10000
ADD r2, r0, r1              @ r2 = 40000 (exceeds 16-bit signed)
SSAT r2, #16, r2            @ r2 = 32767 (saturated)
```

**USAT - Unsigned Saturate**

USAT saturates an unsigned value to a specified bit width. The syntax `USAT rd, #n, rn` saturates the value in `rn` to an n-bit unsigned range (0 to 2^n-1). Negative input values saturate to 0.

**Example:**

```assembly
@ Saturate to 8-bit unsigned range (0 to 255)
MOV r0, #300                @ Value exceeds 8-bit unsigned max
USAT r1, #8, r0             @ r1 = 255 (saturated to max)

MOV r0, #-50                @ Negative value
USAT r1, #8, r0             @ r1 = 0 (saturated to min)

MOV r0, #100                @ Value within range
USAT r1, #8, r0             @ r1 = 100 (no saturation)
```

**Saturation with Shift**

Both SSAT and USAT accept optional shift amounts applied before saturation. This enables scaling combined with range limiting in a single instruction.

**Example:**

```assembly
@ Saturate with left shift: SSAT rd, #n, rm, LSL #shift
MOV r0, #100
SSAT r1, #8, r0, LSL #2     @ r1 = (100 << 2) saturated to 8-bit signed
                            @ = 400 saturated to 127

@ Saturate with right shift: SSAT rd, #n, rm, ASR #shift
MOV r0, #1000
SSAT r1, #8, r0, ASR #2     @ r1 = (1000 >> 2) saturated to 8-bit signed
                            @ = 250 saturated to 127
```

### Q Flag - Saturation Status

The Q (saturation/overflow) flag in CPSR bit 27 indicates whether saturation or overflow occurred in DSP instructions. Unlike NZCV flags, the Q flag is sticky: once set, it remains set until explicitly cleared by software.

**Checking Q Flag**

The Q flag cannot be tested directly with condition codes like NZCV flags. Instead, the MRS (move from special register) instruction reads CPSR into a general-purpose register, then bit testing determines Q flag state.

**Example:**

```assembly
@ Perform saturating operation
MOV r0, #300
USAT r1, #8, r0             @ Saturation occurs, Q flag set

@ Check if saturation occurred
MRS r2, CPSR                @ Read CPSR into r2
TST r2, #0x08000000         @ Test Q flag (bit 27)
BNE saturation_occurred     @ Branch if Q was set

@ Clear Q flag
MRS r2, CPSR
BIC r2, r2, #0x08000000     @ Clear Q flag bit
MSR CPSR_f, r2              @ Write flags back to CPSR
```

### Software Saturation Implementation

On architectures without hardware saturation instructions, software implements saturation using comparison and conditional moves.

**Example:**

```assembly
@ Software signed saturation to 8-bit range (-128 to 127)
@ Input in r0, output in r1
saturate_8bit_signed:
    MOV r1, r0                  @ Copy input
    CMP r1, #127                @ Compare with max
    MOVGT r1, #127              @ If greater, saturate to max
    CMN r1, #128                @ Compare with min (r1 + 128)
    MOVLT r1, #-128             @ If less, saturate to min
    BX lr

@ Software unsigned saturation to 8-bit range (0 to 255)
@ Input in r0, output in r1
saturate_8bit_unsigned:
    MOV r1, r0                  @ Copy input
    CMP r1, #0                  @ Compare with min
    MOVLT r1, #0                @ If negative, saturate to 0
    CMP r1, #255                @ Compare with max
    MOVGT r1, #255              @ If greater, saturate to max
    BX lr
```

