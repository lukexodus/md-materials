## MMX Register Set


MMX provides eight 64-bit registers designated MM0 through MM7. These registers are aliased to the mantissa portion of the x87 floating-point unit (FPU) registers ST(0) through ST(7), creating a critical architectural constraint.

### Register Architecture

The MMX registers occupy the same physical space as the FPU registers:

- **MM0-MM7**: Eight 64-bit MMX registers
- **Physical mapping**: MM0 maps to ST(0), MM1 to ST(1), and so on
- **Register width**: 64 bits per register
- **No separate register file**: Shares silicon with FPU

### Register Usage Constraints

Due to register aliasing, MMX and x87 FPU instructions cannot be freely intermixed:

- Using MMX instructions places the FPU in MMX mode
- The FPU tag word is set to all valid (00) when entering MMX state
- Mixing MMX and x87 without proper transitions causes incorrect results
- The EMMS (Empty MMX State) instruction must be called before returning to x87 operations

**Example** of register state transition:

```nasm
; x87 FPU code
fld qword [value]
fadd st0, st1

; Transition to MMX - corrupts FPU state
movq mm0, [data]
paddb mm0, mm1

; MUST call EMMS before x87 operations
emms

; Now safe to use x87 again
fld qword [another_value]
```

### Register Naming Convention

MMX registers follow Intel's naming pattern:

- **MM**: Multimedia register prefix
- **0-7**: Register index (no letters like AX, BX)
- Cannot be subdivided (no 32-bit, 16-bit, or 8-bit portions addressable independently)

