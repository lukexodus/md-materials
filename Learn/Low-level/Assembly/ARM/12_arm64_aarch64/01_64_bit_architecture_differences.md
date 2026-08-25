## 64-bit Architecture Differences


AArch64 introduces fundamental changes compared to the 32-bit ARM (AArch32) architecture, affecting registers, addressing, instruction encoding, and execution model.

### Execution States

**AArch64 vs AArch32:**

- Separate execution states, not instruction set modes
- Cannot switch between states at instruction level
- Exception level (EL) determines available states
- State change only via exception level transitions or processor reset

```assembly
; AArch32 (32-bit ARM/Thumb)
.arm
ADD r0, r1, r2          ; 32-bit registers

; AArch64 (completely different ISA)
.aarch64
ADD X0, X1, X2          ; 64-bit registers
ADD W0, W1, W2          ; 32-bit operations on 64-bit registers
```

**Exception Levels:**

- EL0: Application level (unprivileged)
- EL1: Operating system kernel
- EL2: Hypervisor
- EL3: Secure monitor

AArch64 available at all exception levels; AArch32 support optional and implementation-defined.

### Address Space

**64-bit Virtual Addressing:**

```assembly
; Full 64-bit address capability (implementation may use fewer bits)
; Typical: 48-bit virtual address space

LDR X0, [X1]                    ; Load from 64-bit address in X1
LDR X0, =0x0000FFFF80000000     ; Load 64-bit address
```

**Address Space Layout:**

- User space: 0x0000000000000000 - 0x0000FFFFFFFFFFFF (lower half)
- Kernel space: 0xFFFF000000000000 - 0xFFFFFFFFFFFFFFFF (upper half)
- Implementation-dependent bit width (commonly 48-bit, can be 52-bit)

**Large Physical Addressing:**

- Physical addresses up to 52 bits
- Supports systems with >4GB RAM without PAE complexity

```assembly
; Load/store with 64-bit pointers
LDR X0, [X1, X2]                ; Base + index, both 64-bit
LDR X0, [X1, #0x1000]           ; 64-bit base + 12-bit offset
```

### Data Types and Alignment

**Native Data Sizes:**

```assembly
; Byte operations (8-bit)
LDRB W0, [X1]                   ; Load byte, zero-extend
STRB W0, [X1]                   ; Store byte

; Halfword operations (16-bit)
LDRH W0, [X1]                   ; Load halfword, zero-extend
STRH W0, [X1]                   ; Store halfword

; Word operations (32-bit)
LDR W0, [X1]                    ; Load 32-bit word
STR W0, [X1]                    ; Store 32-bit word

; Doubleword operations (64-bit)
LDR X0, [X1]                    ; Load 64-bit doubleword
STR X0, [X1]                    ; Store 64-bit doubleword
```

**Alignment Requirements:** [Inference] Most AArch64 implementations allow unaligned access to normal memory with performance penalty. Aligned access preferred:

```assembly
; Aligned access (fastest)
LDR X0, [X1]                    ; X1 should be 8-byte aligned

; Unaligned access (may be slower)
LDR X0, [X1, #5]                ; Unaligned load (supported but slower)

; Device memory requires aligned access
LDR X0, [X1]                    ; Must be aligned for device memory
```

### Removed Features from AArch32

**No Predicated Execution:**

- AArch32 conditional execution removed
- Replaced with conditional select instructions
- Branch prediction and speculation preferred over predicates

```assembly
; AArch32 style (not available in AArch64)
; ADDGT r0, r1, r2              ; Conditional add

; AArch64 equivalent
CMP X1, #10
B.LE skip
ADD X0, X1, X2
skip:

; Or using conditional select
CMP X1, #10
ADD X3, X1, X2                  ; Compute speculatively
CSEL X0, X3, X0, GT             ; Select result if GT
```

**No IT Blocks:**

- Thumb-2 IT blocks don't exist in AArch64
- Conditional branches and CSEL instructions used instead

**No Load/Store Multiple (LDM/STM):**

- Replaced with Load/Store Pair (LDP/STP)
- More efficient with modern pipeline designs

```assembly
; AArch32 style
; PUSH {r4-r7, lr}

; AArch64 equivalent (using pairs)
STP X29, X30, [SP, #-16]!       ; Push frame pointer and link register
STP X19, X20, [SP, #-16]!       ; Push callee-saved registers
```

**No Barrel Shifter in Every Instruction:**

- Shift operations available but more restricted
- Separate shift instructions or limited immediate shifts

```assembly
; AArch32 style
; ADD r0, r1, r2, LSL #3

; AArch64 equivalent
LSL X3, X2, #3                  ; Separate shift
ADD X0, X1, X3                  ; Then add

; Or with immediate shift (limited to certain instructions)
ADD X0, X1, X2, LSL #3          ; Available in AArch64 too
```

**No Coprocessor Instructions:**

- CP15 system control replaced with system register instructions
- NEON/SIMD integrated, not separate coprocessor

### New Architectural Features

**Exception Model:**

- Simplified exception handling
- Dedicated exception level stack pointers
- Exception syndrome registers (ESR_ELx) for detailed exception info

**Memory Model:**

- Relaxed memory ordering by default
- Explicit barriers (DMB, DSB, ISB) with wider options
- Load-acquire/Store-release instructions for efficient synchronization

```assembly
; Acquire semantics (prevents reordering of subsequent loads/stores)
LDAR X0, [X1]                   ; Load-acquire

; Release semantics (prevents reordering of previous loads/stores)
STLR X0, [X1]                   ; Store-release

; Stronger than traditional barriers, lighter than full DMB
```

**Cryptographic Extensions:**

- Hardware acceleration for AES, SHA1, SHA256
- CRC32 instructions
- Integrated into instruction set

**PC Relative Addressing:**

- More flexible PC-relative loads
- Position-independent code easier to write

```assembly
; Load address relative to PC
ADRP X0, symbol                 ; Load page address
ADD X0, X0, :lo12:symbol        ; Add low 12 bits

; Load from PC-relative address
LDR X0, symbol                  ; PC-relative load (±1MB range)
```

