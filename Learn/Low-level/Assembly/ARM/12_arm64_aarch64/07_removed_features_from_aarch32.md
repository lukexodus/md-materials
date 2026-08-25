## Removed Features from AArch32


AArch64 removes several AArch32 features to simplify the architecture and improve performance.

**Removed: Conditional execution (IT blocks)**

```asm
; AArch32: Conditional execution of almost any instruction
CMP R0, R1
ADDNE R2, R2, #1            ; Execute only if not equal
MOVEQ R3, #0                ; Execute only if equal

; AArch32: IT block in Thumb
IT EQ                       ; If equal, then...
ADDEQ R0, R0, #1            ; Conditionally executed

; AArch64: Must use branches or conditional select
CMP X0, X1
B.EQ skip
ADD X2, X2, #1              ; Executed if not equal
skip:

; Or use conditional select
CMP X0, X1
ADD X3, X2, #1              ; Calculate new value
CSEL X2, X3, X2, NE         ; Select based on condition

; Conditional increment macro
.macro CINC reg, cond
    ADD X9, \reg, #1
    CSEL \reg, X9, \reg, \cond
.endm

; Usage
CMP X0, X1
CINC X2, NE                 ; Increment X2 if not equal
```

**Conditional operations in AArch64:**

```asm
; Conditional select
CSEL Xd, Xn, Xm, cond       ; Xd = (cond) ? Xn : Xm
CSINC Xd, Xn, Xm, cond      ; Xd = (cond) ? Xn : Xm + 1
CSINV Xd, Xn, Xm, cond      ; Xd = (cond) ? Xn : ~Xm
CSNEG Xd, Xn, Xm, cond      ; Xd = (cond) ? Xn : -Xm

; Examples
CMP X0, #0
CSEL X1, X2, X3, GT         ; X1 = (X0 > 0) ? X2 : X3
CSINC X1, X2, XZR, EQ       ; X1 = (X0 == 0) ? X2 : 1
CSINV X1, X2, X2, NE        ; X1 = (X0 != 0) ? X2 : ~X2

; Conditional set (set to 0 or 1 based on condition)
CSET Xd, cond               ; Xd = (cond) ? 1 : 0
CSETM Xd, cond              ; Xd = (cond) ? -1 : 0

CMP X0, X1
CSET X2, GT                 ; X2 = (X0 > X1) ? 1 : 0
CSETM X3, EQ                ; X3 = (X0 == X1) ? -1 : 0

; Conditional increment/negate
CINC Xd, Xn, cond           ; Xd = (cond) ? Xn + 1 : Xn
CNEG Xd, Xn, cond           ; Xd = (cond) ? -Xn : Xn

CMP X0, #0
CINC X1, X1, EQ             ; Increment X1 if X0 == 0
CNEG X2, X2, LT             ; Negate X2 if X0 < 0

; Absolute value using conditional negate
ABS X0, X1:
    CMP X1, #0
    CNEG X0, X1, LT         ; X0 = (X1 < 0) ? -X1 : X1
```

**Removed: Predicated/conditional returns**

```asm
; AArch32: Conditional return
CMP R0, #0
BXEQ LR                     ; Return if equal

; AArch64: Must use branch
CMP X0, #0
B.NE continue
RET
continue:

; Or restructure code
CMP X0, #0
B.EQ early_return
; Normal path
; ...
RET

early_return:
RET
```

**Removed: Direct PC manipulation**

```asm
; AArch32: PC is R15, can be loaded/stored
LDR PC, [R0]                ; Jump to address in [R0]
ADD PC, PC, R1              ; Computed branch
MOV PC, LR                  ; Return

; AArch64: PC not accessible, must use dedicated instructions
LDR X0, [X1]
BR X0                       ; Branch to register

ADD X0, X0, X1
BR X0                       ; Computed branch

RET                         ; Return (uses X30/LR)

; Branch to register
BR Xn                       ; Branch to Xn
BLR Xn                      ; Branch with link to Xn
RET                         ; Return to X30 (LR)
RET Xn                      ; Return to Xn
```

**Removed: LDM/STM (Load/Store Multiple)**

```asm
; AArch32: Load/store multiple registers
PUSH {R4-R11, LR}           ; Save multiple registers
POP {R4-R11, PC}            ; Restore and return

LDMIA R0!, {R1-R8}          ; Load R1-R8 from [R0], increment R0
STMDB R13!, {R0-R3}         ; Store R0-R3, decrement R13 (push)

; AArch64: Must use pairs or individual operations
STP X19, X20, [SP, #-48]!   ; Save pairs
STP X21, X22, [SP, #16]
STP X23, X24, [SP, #32]

LDP X19, X20, [SP]          ; Restore pairs
LDP X21, X22, [SP, #16]
LDP X23, X24, [SP, #32]
ADD SP, SP, #48

; Helper macro for multiple push
.macro PUSH_REGS regs:vararg
    .irp reg, \regs
        SUB SP, SP, #8
        STR \reg, [SP]
    .endr
.endm

; Helper macro for multiple pop
.macro POP_REGS regs:vararg
    .irp reg, \regs
        LDR \reg, [SP]
        ADD SP, SP, #8
    .endr
.endm
```

**Removed: Coprocessor 15 (CP15) instructions**

```asm
; AArch32: Coprocessor instructions for system control
MRC p15, 0, R0, c1, c0, 0   ; Read SCTLR
MCR p15, 0, R0, c1, c0, 0   ; Write SCTLR

; AArch64: Dedicated system register instructions
MRS X0, SCTLR_EL1           ; Read system control register
MSR SCTLR_EL1, X0           ; Write system control register

MRS X0, MPIDR_EL1           ; Read multiprocessor ID
MRS X0, MIDR_EL1            ; Read main ID register
MRS X0, TPIDR_EL0           ; Read thread ID (EL0)
MSR TPIDR_EL0, X0           ; Write thread ID
```

**Removed: 26-bit addressing modes**

```asm
; AArch32 legacy: 26-bit PC with mode bits in upper 6 bits
; (Already removed in ARMv4 and later)

; AArch64: Always 64-bit addressing
; Virtual address space up to 52 bits (implementation dependent)
; Typically 48-bit virtual addressing (256 TB)
```

**Removed: Thumb state**

```asm
; AArch32: Switch between ARM (32-bit) and Thumb (16-bit) states
BX R0                       ; Branch and exchange (may switch state)
BLX R0                      ; Branch with link and exchange

; AArch64: Single instruction set (all 32-bit instructions)
; No state switching needed
BR X0                       ; Always 64-bit instruction set
BLR X0
```

**Removed: Rotate right with extend (RRX)**

```asm
; AArch32: Rotate through carry flag
MOV R0, R1, RRX             ; R0 = {C, R1[31:1]} (33-bit rotate)

; AArch64: Must implement manually
MRS X2, NZCV                ; Read flags
LSR X0, X1, #1              ; Shift right
AND X2, X2, #0x20000000     ; Extract carry flag
ORR X0, X0, X2, LSL #2      ; Insert carry at bit 31
```

**Removed: Separate CPSR/SPSR**

```asm
; AArch32: Current and Saved Program Status Registers
MRS R0, CPSR                ; Read CPSR
MSR CPSR_c, R0              ; Write CPSR control field
MRS R0, SPSR                ; Read SPSR (in exception modes)

; AArch64: PSTATE and system registers
MRS X0, NZCV                ; Read condition flags
MSR NZCV, X0                ; Write condition flags
MRS X0, DAIF                ; Read interrupt masks
MSR DAIF, X0                ; Write interrupt masks
MRS X0, SPSel               ; Read stack pointer select
MRS X0, CurrentEL           ; Read current exception level

; Exception return uses SPSR_ELx
MRS X0, SPSR_EL1            ; Read saved PSTATE for EL1
MSR SPSR_EL1, X0            ; Write saved PSTATE
ERET                        ; Exception return (restores PSTATE)
```

