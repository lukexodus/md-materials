## Registers and Register Conventions


ARM processors provide general-purpose registers for computation, special-purpose registers for processor control, and system registers for privileged operations. The register organization differs between 32-bit (AArch32) and 64-bit (AArch64) execution states.

### AArch64 Register Organization

AArch64 provides thirty-one 64-bit general-purpose registers named X0 through X30, plus a zero register (XZR) and stack pointer (SP). Each 64-bit register can also be accessed as a 32-bit register using W naming (W0-W30, WZR). When accessing the 32-bit form, the upper 32 bits are typically zero-extended (though this behavior depends on the specific instruction).

**X0-X7** serve as argument registers for function calls and return values. X0 holds the first argument and primary return value. X1-X7 hold subsequent arguments (second through eighth). Functions returning small structures use multiple registers starting from X0. Large structures use pointer passing.

**X8** serves as the indirect result location register. When a function returns a structure too large for registers, the caller allocates space and passes the address in X8. The callee writes the result to this location.

**X9-X15** function as temporary registers (caller-saved). Functions may freely modify these without preservation. Callers expecting to use values across function calls must save them explicitly.

**X16-X17** (IP0, IP1) are intra-procedure-call temporary registers. Linkers and dynamic linkers may use these for veneers and trampolines during function calls. Normal application code treats them as additional temporary registers.

**X18** has platform-specific usage. Some platforms reserve it as a platform register for special purposes (like accessing thread-local storage or shadow call stacks). Other platforms treat it as an additional temporary register. [Inference: Code portability benefits from avoiding X18 unless platform conventions are well-understood.]

**X19-X28** serve as callee-saved registers. Functions must preserve these values if they modify them, typically by saving to the stack in the function prologue and restoring in the epilogue. Callers can rely on these registers maintaining values across function calls.

**X29** (FP) serves as the frame pointer in debugging builds or when required by calling conventions. It points to the previous frame pointer on the stack, creating a linked list of stack frames for debugger stack unwinding. Optimized builds may omit frame pointers and repurpose X29 as a general callee-saved register.

**X30** (LR) holds the link register containing the return address. The BL (branch with link) instruction automatically stores the return address here. Functions typically save LR to the stack if they call other functions, since nested calls would overwrite it.

**SP** (Stack Pointer) maintains the current stack position. The stack grows downward (toward lower addresses) on ARM. Instructions cannot use SP and XZR interchangeably; the encoding determines which applies based on context.

**XZR/WZR** (Zero Register) reads as zero and discards writes. This simplifies certain operations like testing values (by subtracting from zero) or clearing registers (by moving zero).

**PC** (Program Counter) is not directly accessible as a general-purpose register in AArch64 (unlike AArch32). Instruction encoding no longer permits reading PC directly, improving pipeline efficiency. PC-relative addressing remains available through specific instruction forms.

### Vector and Floating-Point Registers

AArch64 provides thirty-two 128-bit SIMD and floating-point registers named V0-V31. These support multiple access modes:

**B0-B31** access the lowest 8 bits (byte)
**H0-H31** access the lowest 16 bits (half-word, for 16-bit float)
**S0-S31** access the lowest 32 bits (single-precision float)
**D0-D31** access the lowest 64 bits (double-precision float)
**Q0-Q31** access the full 128 bits (quad-word, for SIMD operations)

Calling conventions designate V0-V7 as argument and return value registers for floating-point and SIMD operations. V0 returns scalar floating-point values. V8-V15 are callee-saved (lower 64 bits must be preserved). V16-V31 are caller-saved temporaries.

Scalable Vector Extension (SVE) introduces variable-length vector registers Z0-Z31 (extending V registers) and predicate registers P0-P15 for masked operations. SVE2 enhances these capabilities further. [Unverified: Specific SVE availability varies by processor implementation.]

### System Registers

System registers control processor operation and are accessible only at appropriate privilege levels. Common system registers include:

**SPSR_EL1, SPSR_EL2, SPSR_EL3** (Saved Program Status Register) preserve processor state during exception handling at each exception level.

**ELR_EL1, ELR_EL2, ELR_EL3** (Exception Link Register) store return addresses for exceptions at each level.

**SCTLR_EL1** (System Control Register) configures MMU, caches, alignment checking, and other system features.

**TTBR0_EL1, TTBR1_EL1** (Translation Table Base Register) point to page tables for virtual memory translation. TTBR0 typically maps user space; TTBR1 maps kernel space.

**VBAR_EL1, VBAR_EL2, VBAR_EL3** (Vector Base Address Register) specify exception vector table locations for each exception level.

**CurrentEL** indicates the current exception level (EL0-EL3).

**FPCR** (Floating-Point Control Register) and **FPSR** (Floating-Point Status Register) control floating-point behavior and report floating-point exceptions.

### AArch32 Register Organization

AArch32 provides sixteen 32-bit general-purpose registers R0-R15. R0-R12 serve general purposes. R13 functions as the stack pointer (SP). R14 serves as the link register (LR). R15 is the program counter (PC) and can be read/written directly in many contexts (though this practice is discouraged for portability).

AArch32 has multiple register banks that switch depending on processor mode. For example, FIQ mode has banked R8-R14, giving it private copies of these registers for fast interrupt handling. Other modes have fewer banked registers. [Inference: This banking complexity contributed to ARM's architectural simplification in AArch64.]

The Current Program Status Register (CPSR) contains condition flags (N, Z, C, V), processor mode bits, interrupt disable flags, and instruction set state (ARM, Thumb, ThumbEE, Jazelle). Each exception mode has a Saved Program Status Register (SPSR) preserving CPSR during exception entry.

### Calling Convention Summary

The Procedure Call Standard for the ARM Architecture (AAPCS) standardizes register usage for interoperability between compilers and libraries. Key principles include:

Arguments pass in X0-X7 (or V0-V7 for floating-point). Additional arguments spill to the stack. Variadic functions follow special rules where the variadic portion always uses the stack.

Return values use X0 (or X0-X1 for 128-bit values, or V0 for floating-point). Structures up to 16 bytes return in registers; larger structures use indirect return via X8.

Stack alignment requires 16-byte alignment at public interfaces. The stack pointer must be 16-byte aligned when calling functions.

Callee-saved registers (X19-X28, bottom 64 bits of V8-V15) must be preserved. Caller-saved registers (X0-X18, X30, V0-V7, V16-V31) may be modified freely.

Red zone: [Unverified: AArch64 may not guarantee a red zone below SP in all environments]. Interrupt handlers and signal handlers can corrupt stack memory below SP.

