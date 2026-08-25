## IT Blocks (If-Then)


IT (If-Then) blocks enable conditional execution in Thumb-2, replacing ARM's predicated instruction capability within the Thumb instruction set.

### IT Instruction Syntax

```assembly
IT{x{y{z}}} cond

; x, y, z can be:
; T = Then (same condition as cond)
; E = Else (opposite condition)
; cond = condition code (EQ, NE, GT, LT, etc.)
```

### Basic IT Block Structure

**Example** - Simple conditional execution:

```assembly
; ARM predicated instructions
CMP r0, #10
ADDGT r1, r1, #1        ; Add if greater
MOVGT r2, #5            ; Move if greater

; Thumb-2 equivalent with IT
CMP r0, #10
ITT GT                  ; If-Then-Then (2 instructions, both GT)
ADDGT r1, r1, #1        ; Executes if GT
MOVGT r2, #5            ; Executes if GT
```

### IT Block Patterns

Up to 4 conditional instructions can follow IT:

```assembly
; IT - 1 instruction
CMP r0, #0
IT EQ
MOVEQ r1, #1

; ITT - 2 instructions (Then-Then)
CMP r0, #0
ITT NE
ADDNE r1, r1, #1
SUBNE r2, r2, #1

; ITE - 2 instructions (Then-Else)
CMP r0, #0  
ITE EQ
MOVEQ r1, #1            ; If equal
MOVNE r1, #0            ; If not equal

; ITTE - 3 instructions (Then-Then-Else)
CMP r0, #10
ITTE GT
ADDGT r1, r1, #1        ; If greater
MOVGT r2, #5            ; If greater
MOVLE r2, #0            ; If less or equal

; ITTEE - 4 instructions (Then-Then-Else-Else)
CMP r0, r1
ITTEE EQ
ADDEQ r2, r2, #1        ; If equal
MOVEQ r3, #1            ; If equal
ADDNE r2, r2, #2        ; If not equal
MOVNE r3, #0            ; If not equal
```

### Condition Codes in IT Blocks

All standard ARM condition codes work with IT:

```assembly
; EQ/NE - Equal/Not Equal
CMP r0, r1
ITE EQ
MOVEQ r2, #1
MOVNE r2, #0

; GT/LE - Greater Than/Less or Equal
CMP r0, #100
ITT GT
ADDGT r1, r1, #1
STRGT r1, [r2]

; GE/LT - Greater or Equal/Less Than
CMP r0, #0
ITE GE
MOVGE r3, r0
RSBLT r3, r0, #0        ; Negate if negative

; HI/LS - Higher/Lower or Same (unsigned)
CMP r0, #255
IT HI
MOVHI r0, #255          ; Clamp to maximum

; CS/CC - Carry Set/Carry Clear
ADDS r0, r1, r2
IT CS
MOVCS r3, #1            ; Set overflow flag
```

### IT Block Restrictions

**Critical restrictions:**

- All instructions in IT block must match pattern (T or E as specified)
- Cannot branch into middle of IT block
- Cannot use IT inside another IT block
- IT blocks cannot contain other IT instructions
- Some instructions prohibited in IT blocks (explained below)

**Example** - Invalid IT usage:

```assembly
; INVALID - condition mismatch
CMP r0, #10
ITT GT
ADDGT r1, r1, #1        ; OK - matches GT
ADDLE r2, r2, #1        ; ERROR - should be GT, not LE

; INVALID - branch into IT block
CMP r0, #10
ITT GT
target:                 ; ERROR - cannot branch here
    ADDGT r1, r1, #1
    MOVGT r2, #5

; INVALID - nested IT
CMP r0, #10
ITT GT
    IT NE               ; ERROR - IT inside IT block
    ADDNE r1, r1, #1
    MOVGT r2, r5
```

### Instructions Prohibited in IT Blocks

Certain instructions cannot appear in IT blocks on ARMv8-A and later (Thumb-2 only):

```assembly
; These instructions CANNOT be in IT blocks (ARMv8-A):
IT EQ
PUSHEQ {r0-r3}          ; ERROR - PUSH not allowed
POPEQ {r0-r3}           ; ERROR - POP not allowed
LDM/STM                 ; ERROR - Load/Store Multiple not allowed
CB(N)Z                  ; ERROR - Compare and Branch not allowed

; Must use branches instead:
CMP r0, #0
BNE skip
PUSH {r0-r3}
skip:
```

### Combining IT with Barrel Shifter

**Example** - Conditional operations with shifts:

```assembly
CMP r0, #0
ITTE GT
ADDGT.W r1, r2, r3, LSL #2      ; 32-bit encoding for shift
MOVGT r4, #100
MOVLE r4, #0
```

### Performance Considerations

**Benefits:**

- Eliminates branch misprediction penalties for simple conditionals
- Reduces code size compared to branch-based conditionals
- Maintains straight-line code flow

**Limitations:**

- IT blocks limited to 4 instructions (longer conditionals need branches)
- [Inference] Some processors may have lower throughput for IT blocks
- Overuse can reduce code readability

**Example** - Performance comparison:

```assembly
; Branch-based (may mispredict)
CMP r0, #10
BLE skip
ADD r1, r1, #1
MOV r2, #5
skip:
; 2-3 instructions if taken, potential branch penalty

; IT block (no branch)
CMP r0, #10
ITT GT
ADDGT r1, r1, #1
MOVGT r2, #5
; Always 3 instructions, no branch penalty
```

### Practical IT Block Examples

**Example** - Absolute value:

```assembly
; Compute absolute value of r0
CMP r0, #0
IT LT
RSBLT r0, r0, #0        ; Negate if negative
```

**Example** - Min/Max operations:

```assembly
; r0 = max(r0, r1)
CMP r0, r1
IT LT
MOVLT r0, r1            ; If r0 < r1, r0 = r1

; r0 = min(r0, r1)  
CMP r0, r1
IT GT
MOVGT r0, r1            ; If r0 > r1, r0 = r1
```

**Example** - Saturating arithmetic:

```assembly
; Saturate r0 to range [0, 255]
CMP r0, #0
ITE LT
MOVLT r0, #0            ; Clamp to 0 if negative
CMPGE r0, #255          ; Compare if >= 0
IT GT
MOVGT r0, #255          ; Clamp to 255 if > 255
```

**Example** - Conditional update pattern:

```assembly
; Update counter if condition met
LDR r0, [r1]            ; Load value
CMP r0, #100
ITTE LT
ADDLT r0, r0, #1        ; Increment if < 100
STRLT r0, [r1]          ; Store if < 100
MOVGE r0, #100          ; Cap at 100
```

