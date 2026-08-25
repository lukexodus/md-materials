## Migration Considerations


Migrating from AArch32 to AArch64 requires code changes and architectural understanding.

**Register size changes:**

```asm
; AArch32: 32-bit registers
MOV R0, #42
LDR R1, [R2]

; AArch64: Must specify size
MOV W0, #42                 ; 32-bit operation
MOV X0, #42                 ; 64-bit operation
LDR W1, [X2]                ; 32-bit load
LDR X1, [X2]                ; 64-bit load

; Data type mapping
; AArch32 int       (32-bit) -> AArch64 int/W register
; AArch32 long      (32-bit) -> AArch64 long (64-bit)/X register
; AArch32 pointer   (32-bit) -> AArch64 pointer (64-bit)/X register
; AArch32 long long (64-bit) -> AArch64 long long/X register

; Structure alignment changes
; AArch32: 32-bit pointers
struct data32 {
    void *ptr;              // 4 bytes
    int value;              // 4 bytes
};                          // Total: 8 bytes

; AArch64: 64-bit pointers
struct data64 {
    void *ptr;              // 8 bytes
    int value;              // 4 bytes
    // padding               // 4 bytes (for 8-byte alignment)
};                          // Total: 16 bytes
```

**Calling convention differences:**

```asm
; AArch32 AAPCS (ARM Architecture Procedure Call Standard)
; R0-R3: Arguments and return value
; R4-R11: Callee-saved
; R12: IP (scratch)
; R13: SP
; R14: LR
; R15: PC

; AArch32 function
function_a32:
    PUSH {R4-R11, LR}       ; Save callee-saved registers
    ; R0-R3 contain arguments
    ; Function body
    ; Return value in R0
    POP {R4-R11, PC}        ; Restore and return

; AArch64 AAPCS64
; X0-X7: Arguments
; X8: Indirect result location
; X9-X15: Temporary registers
; X16-X17: Intra-procedure-call temporary (IP0, IP1)
; X18: Platform register (reserved)
; X19-X28: Callee-saved
; X29: Frame pointer (FP)
; X30: Link register (LR)
; SP: Stack pointer

; AArch64 function
function_a64:
    STP X29, X30, [SP, #-16]!   ; Save FP and LR
    MOV X29, SP                  ; Setup frame pointer
    STP X19, X20, [SP, #-16]!   ; Save callee-saved if needed
    
    ; X0-X7 contain arguments (8 registers vs 4)
    ; More arguments passed in registers (better performance)
    
    ; Return value in X0
    LDP X19, X20, [SP], #16     ; Restore callee-saved
    LDP X29, X30, [SP], #16     ; Restore FP and LR
    RET

; Variadic functions
; AArch32: Difficult, uses stack
; AArch64: Named registers for first 8 args, then stack

vararg_func:
    ; X0-X7 may contain arguments
    ; Must save X0-X7 to stack if needed
    STP X0, X1, [SP, #-80]!
    STP X2, X3, [SP, #16]
    STP X4, X5, [SP, #32]
    STP X6, X7, [SP, #48]
    ; Now can process variable arguments
    RET
```

**Stack alignment:**

```asm
; AArch32: 8-byte stack alignment (AAPCS)
; AArch64: 16-byte stack alignment (AAPCS64)

; AArch32 stack frame
function_a32_frame:
    PUSH {FP, LR}           ; 8 bytes
    SUB SP, SP, #16         ; Local variables
    ; ... (SP now 8-byte aligned)
    ADD SP, SP, #16
    POP {FP, PC}

; AArch64 stack frame (must maintain 16-byte alignment)
function_a64_frame:
    STP X29, X30, [SP, #-32]!   ; 16 bytes
    MOV X29, SP
    ; Local space (32 - 16 = 16 bytes available)
    ; SP always 16-byte aligned
    
    LDP X29, X30, [SP], #32
    RET

; Incorrect alignment (causes issues)
bad_alignment:
    SUB SP, SP, #8          ; Now misaligned!
    ; Some operations may fault or perform poorly
    
; Correct alignment
good_alignment:
    SUB SP, SP, #16         ; Maintains 16-byte alignment
    ; Or use pairs:
    STP X0, X1, [SP, #-16]! ; Atomic 16-byte operation
```

**Floating-point differences:**

```asm
; AArch32 VFP: S0-S31 (single), D0-D31 (double)
; AArch64: V0-V31 (128-bit), accessed as:
;   - B0-B31 (8-bit)
;   - H0-H31 (16-bit)
;   - S0-S31 (32-bit)
;   - D0-D31 (64-bit)
;   - Q0-Q31 (128-bit)

; AArch32 floating-point
vmov.f32 s0, #1.0
vadd.f32 s2, s0, s1

; AArch64 floating-point
FMOV S0, #1.0
FADD S2, S0, S1

; Calling convention:
; AArch32: S0-S15 for float args/return
; AArch64: V0-V7 for float args/return (can pass more)

float_function:
    ; V0-V7 contain float/double arguments
    ; V0 for return value
    FADD D0, D0, D1
    RET
```

**Exception level model:**

```asm
; AArch32: Privilege modes (User, FIQ, IRQ, SVC, etc.)
; AArch64: Exception Levels (EL0-EL3)

; EL0: Unprivileged (user applications)
; EL1: Privileged (OS kernel)
; EL2: Hypervisor (virtualization)
; EL3: Secure monitor (TrustZone)

; Check current exception level
get_current_el:
    MRS X0, CurrentEL
    LSR X0, X0, #2          ; Extract EL field
    AND X0, X0, #3          ; Mask to 0-3
    RET

; Exception handling differences
; AArch32: Mode-specific banked registers
; AArch64: EL-specific register banks

; AArch32 exception entry
irq_handler_a32:
    SUB LR, LR, #4          ; Adjust return address
    STMFD SP!, {R0-R3, R12, LR}  ; Save context
    ; Handle interrupt
    LDMFD SP!, {R0-R3, R12, PC}^ ; Return and restore CPSR

; AArch64 exception entry
.align 11                   ; Exception vector table alignment
exception_vectors:
    // Current EL with SP0
    .align 7
    B sync_current_el_sp0
    .align 7
    B irq_current_el_sp0
    .align 7
    B fiq_current_el_sp0
    .align 7
    B serror_current_el_sp0
    
    // Current EL with SPx
    .align 7
    B sync_current_el_spx
    .align 7
    B irq_current_el_spx
    .align 7
    B fiq_current_el_spx
    .align 7
    B serror_current_el_spx
    
    // Lower EL (AArch64)
    .align 7
    B sync_lower_el_a64
    .align 7
    B irq_lower_el_a64
    .align 7
    B fiq_lower_el_a64
    .align 7
    B serror_lower_el_a64
    
    // Lower EL (AArch32)
    .align 7
    B sync_lower_el_a32
    .align 7
    B irq_lower_el_a32
    .align 7
    B fiq_lower_el_a32
    .align 7
    B serror_lower_el_a32

irq_lower_el_a64:
    ; Save context
    STP X0, X1, [SP, #-16]!
    STP X2, X3, [SP, #-16]!
    ; ... save more registers
    
    ; Handle interrupt
    BL irq_handler
    
    ; Restore context
    LDP X2, X3, [SP], #16
    LDP X0, X1, [SP], #16
    ERET                    ; Exception return
```

**System register access:**

```asm
; AArch32: Coprocessor instructions
MRC p15, 0, R0, c0, c0, 0   ; Read MIDR
MCR p15, 0, R0, c1, c0, 0   ; Write SCTLR

; AArch64: Named system registers
MRS X0, MIDR_EL1            ; Read Main ID Register
MSR SCTLR_EL1, X0           ; Write System Control Register

; Common register mappings
; AArch32 SCTLR    -> AArch64 SCTLR_EL1
; AArch32 TTBR0    -> AArch64 TTBR0_EL1
; AArch32 TTBR1    -> AArch64 TTBR1_EL1
; AArch32 MPIDR    -> AArch64 MPIDR_EL1
; AArch32 VBAR     -> AArch64 VBAR_EL1

; Example: Get CPU ID
get_cpu_id_a32:
    MRC p15, 0, R0, c0, c0, 5   ; Read MPIDR
    AND R0, R0, #0x03           ; Extract CPU ID
    BX LR

get_cpu_id_a64:
    MRS X0, MPIDR_EL1
    AND X0, X0, #0xFF           ; Extract Aff0
    RET
```

**Memory management differences:**

```asm
; AArch32: 2-level page tables (1MB sections, 4KB pages)
; AArch64: Multi-level page tables (4KB, 16KB, or 64KB granule)

; AArch64 supports:
; - 4KB pages: 4-level translation (48-bit VA)
; - 16KB pages: 4-level translation (47-bit VA)
; - 64KB pages: 3-level translation (48-bit VA)
; - 52-bit VA with ARMv8.2+ (5-level with 4KB pages)

; Page table base setup
; AArch32
setup_mmu_a32:
    LDR R0, =page_table
    MCR p15, 0, R0, c2, c0, 0   ; Set TTBR0
    ; ...

; AArch64
setup_mmu_a64:
    LDR X0, =page_table
    MSR TTBR0_EL1, X0           ; Set TTBR0_EL1
    
    ; Configure TCR_EL1 (Translation Control Register)
    LDR X0, =0x0000000080803520
    ; TG0 = 4KB, T0SZ = 16 (48-bit VA), SH0 = Inner Shareable
    ; ORGN0/IRGN0 = Write-Back Cacheable
    MSR TCR_EL1, X0
    
    ; Configure MAIR_EL1 (Memory Attribute Indirection Register)
    LDR X0, =0x000000000044FF04
    ; Attr0 = Device-nGnRnE, Attr1 = Normal, etc.
    MSR MAIR_EL1, X0
    
    ; Enable MMU
    MRS X0, SCTLR_EL1
    ORR X0, X0, #0x1            ; M bit
    ORR X0, X0, #0x4            ; C bit (data cache)
    ORR X0, X0, #0x1000         ; I bit (instruction cache)
    MSR SCTLR_EL1, X0
    ISB
    RET
```

**Porting strategy:**

```asm
; 1. Identify architecture-specific code
#ifdef __aarch64__
    ; AArch64-specific code
    MOV X0, #42
    RET
#else
    ; AArch32-specific code
    MOV R0, #42
    BX LR
#endif

; 2. Create abstraction macros
.macro PUSH_REGS
#ifdef __aarch64__
    STP X29, X30, [SP, #-16]!
    STP X19, X20, [SP, #-16]!
#else
    PUSH {R4-R11, LR}
#endif
.endm

.macro POP_REGS
#ifdef __aarch64__
    LDP X19, X20, [SP], #16
    LDP X29, X30, [SP], #16
#else
    POP {R4-R11, PC}
#endif
.endm

; 3. Port critical sections first
; - Exception handlers
; - MMU setup
; - Cache maintenance
; - Synchronization primitives

; 4. Test incrementally
; - Start with boot code
; - Add interrupt handling
; - Port device drivers
; - Migrate application code

; 5. Performance validation
; - Benchmark critical paths
; - Profile cache behavior
; - Verify atomic operations
; - Check memory ordering
```

**Interworking (running 32-bit code on 64-bit kernel):**

```asm
; AArch64 kernel can run AArch32 applications (EL0)
; But mode transitions are explicit

; System call from AArch32 app to AArch64 kernel
; AArch32 app:
;   SVC #0
; 
; Kernel receives exception at EL1 in AArch64 mode
; Must handle AArch32 state:

syscall_handler_compat:
    ; Check if from AArch32
    MRS X0, SPSR_EL1
    TST X0, #0x10               ; Check execution state bit
    B.EQ from_aarch64
    
from_aarch32:
    ; Handle AArch32 syscall
    ; Read saved R0-R7 from exception context
    ; R7 contains syscall number (Linux convention)
    ; ...
    ERET                        ; Return to AArch32 mode

from_aarch64:
    ; Handle AArch64 syscall
    ; X8 contains syscall number
    ; ...
    ERET                        ; Return to AArch64 mode
```

**Key Points:**

- AArch64 simplifies addressing with consistent modes and removes complex ARM/Thumb interworking
- Removed features include conditional execution, PC manipulation, and LDM/STM instructions requiring code restructuring
- Performance improvements include more registers, native 64-bit operations, load/store pairs, and advanced atomics
- Migration requires changes to register usage, calling conventions, stack alignment, and exception handling
- Interworking allows 32-bit applications on 64-bit kernels but requires careful state management

[Inference] Specific performance improvements vary significantly across microarchitectures - actual performance gains depend on core design (Cortex-A53 vs Cortex-A76 vs Apple Silicon vs custom cores) and workload characteristics.

[Inference] Migration complexity depends on how much architecture-specific assembly exists in the codebase - high-level language code typically requires only recompilation while low-level system code needs substantial porting effort.

---

