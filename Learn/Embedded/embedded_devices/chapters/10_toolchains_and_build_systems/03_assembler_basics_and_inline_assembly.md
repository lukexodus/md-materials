## Assembler Basics and Inline Assembly

### Overview

This content covers the assembler layer of the toolchain introduced in the prior GCC-based-toolchains content — `arm-none-eabi-as` and its inputs — along with inline assembly, the mechanism by which C, C++, and Rust code can embed target-specific assembly instructions directly within otherwise high-level source. Assembly-level work remains relevant in embedded systems specifically for operations no high-level language construct can express: certain privileged CPU instructions, precise cycle-level timing, and the very earliest boot-time code before a C runtime environment (stack pointer, `.data`/`.bss` initialization, as discussed in the linker-scripts content) has even been established.

### Assembly Language Fundamentals for Embedded Targets

An assembler translates human-readable mnemonic instructions into the target's machine code, one instruction (or a small, well-defined set of pseudo-instructions) at a time — a much more direct, mechanical translation than a compiler performs for a high-level language, with comparatively little independent "optimization" latitude.

```asm
    .syntax unified
    .thumb

    .global reset_handler
    .type reset_handler, %function

reset_handler:
    ldr r0, =_estack      @ load top-of-stack address into r0
    mov sp, r0             @ set the stack pointer
    bl  copy_data_section   @ branch-and-link to a C function
    bl  main                @ jump to main, never returns
loop:
    b   loop                @ infinite loop if main() returns
```

- `.syntax unified` selects ARM's "Unified Assembler Language" syntax (as opposed to the older, divergent ARM and Thumb syntax dialects) — **[Unverified]** the specific default and required directives vary somewhat by assembler version and target, so this should be confirmed against the toolchain's current documentation for a given project rather than assumed universal.
- `.thumb` selects Thumb (or Thumb-2) instruction encoding, matching the `-mthumb` compiler flag discussed in the GCC-toolchains content — assembly and C code within the same project must agree on this encoding choice for the linker to combine them correctly.
- `.global` and `.type` are assembler directives (not actual instructions) providing symbol visibility and metadata the linker and debugger use — directly analogous in purpose to how `extern`/`#[no_mangle]` control symbol visibility across the C/Rust FFI boundary discussed in the prior interoperability content.
- Labels (`reset_handler:`, `loop:`) mark addresses referenced by branch instructions and, when marked `.global`, become linker-visible symbols resolvable from C code via `extern`.

### Registers, Instructions, and the ARM Cortex-M Register Model

**[Inference]** A baseline understanding of the target's register model is a prerequisite for writing or reading any inline assembly meaningfully, since inline assembly syntax (discussed below) is fundamentally about specifying which registers hold which C-level values. For ARM Cortex-M cores specifically:

- General-purpose registers `r0`–`r12`: available for general computation; calling-convention rules (part of the ABI discussed in the interoperability and cross-compilation content) dictate which are caller-saved vs. callee-saved, and which conventionally hold function arguments/return values (`r0`–`r3` for the first four arguments and `r0` for a scalar return value, in the standard ARM EABI).
- `sp` (r13, stack pointer), `lr` (r14, link register — holds the return address for a `bl` branch-and-link instruction), `pc` (r15, program counter).
- `xPSR` (program status register) and related special registers, holding condition-code flags and execution-mode state, generally not directly accessed by ordinary application-level assembly but relevant to interrupt/exception handling and fault diagnosis.

### Why Assembly Remains Necessary in Embedded Systems

Despite modern compilers generating highly efficient code (per the zero-cost-abstraction discussion in the C++/templates content), certain operations remain outside what any high-level language construct — even `volatile`-qualified C or `unsafe` Rust — can directly express:

- **Reset/startup code**: before the stack pointer is set up and `.data`/`.bss` initialization (from the linker-scripts content) has run, no C function can safely execute at all, since C code generally assumes a valid stack exists — the very earliest instructions after reset are necessarily hand-written (or vendor-supplied) assembly for this reason.
- **Privileged/special instructions**: certain ARM instructions (`wfi` — wait for interrupt, entering a low-power sleep state; `cpsid`/`cpsie` — disable/enable interrupts at the core level; `dsb`/`dmb`/`isb` — memory and instruction barriers) have no direct C-language equivalent and must be issued as literal assembly instructions, though compiler-provided intrinsics (discussed below) commonly wrap them.
- **Context switching**: RTOS kernels implementing task switching must save and restore the full register set of a task, an operation requiring direct control over register save/restore sequencing that C's abstraction (which manages register allocation itself, invisibly) cannot provide.
- **Cycle-exact timing**: as flagged in the compiler-optimization-flags content, instruction-counting delay loops are fragile across optimization levels even in C; hand-written assembly with a known, fixed instruction count (and known cycle-per-instruction cost for the specific core) is occasionally used where a hardware timer genuinely isn't available, though a hardware timer remains the generally preferred approach per that earlier content.

### Compiler Intrinsics: The Preferred First Option

Before reaching for raw inline assembly, most compiler-provided **intrinsics** — C functions that map directly to a specific assembly instruction or short instruction sequence, without the syntax complexity of true inline assembly — cover the majority of common special-instruction needs.

```c
#include <cmsis_gcc.h>  /* or similar CMSIS core header */

__disable_irq();  /* maps directly to a CPSID instruction */
__WFI();          /* maps directly to a WFI instruction */
__DSB();          /* data synchronization barrier instruction */
```

These map to the CMSIS core intrinsics referenced in the prior GCC-toolchains content — thin, standardized wrappers that most vendor SDKs and the CMSIS layer already provide. **[Inference]** Intrinsics are generally preferable to raw inline assembly wherever an equivalent intrinsic exists, since they let the compiler's register allocator and optimizer continue to reason about the surrounding code normally (the intrinsic is treated similarly to an ordinary function call with known semantics), whereas raw inline assembly — discussed next — imposes real constraints and risks on the compiler's ability to safely optimize the surrounding code if not written carefully.

### GCC Extended Inline Assembly Syntax

For the cases genuinely requiring assembly with no available intrinsic, GCC's extended `asm` syntax allows embedding assembly directly within C/C++ source, with explicit declarations of which C variables map to which operands, and which registers/memory the assembly clobbers.

```c
uint32_t read_special_register(void) {
    uint32_t result;
    asm volatile (
        "mrs %0, control"      /* assembly template */
        : "=r" (result)         /* output operands */
        :                        /* input operands (none here) */
        :                        /* clobbers (none here) */
    );
    return result;
}
```

- **Assembly template**: the literal instruction(s), with `%0`, `%1`, etc. as placeholders the compiler substitutes with actual register names it chooses, based on the operand constraints below.
- **Output operands** (`"=r" (result)`): `=` marks it write-only (output), `r` constrains it to any general-purpose register, and `(result)` names the C variable the compiler should write the register's final value into after the assembly executes.
- **Input operands**: analogous syntax without the `=`, for C values the assembly reads (a value being written *into* a register before the assembly block executes).
- **Clobber list**: registers, memory, or condition-code flags the assembly modifies as a side effect but that aren't declared as outputs — informing the compiler it cannot assume those registers/memory retain their prior values across the `asm` block, so it must reload/recompute anything it was relying on.
- **`volatile`** (on the `asm` keyword itself, not to be confused with C's `volatile` type qualifier discussed in the compiler-optimization-flags content, though conceptually related): instructs the compiler not to reorder, duplicate, or eliminate this assembly block based on its own optimization analysis, since the compiler generally cannot understand what an opaque assembly block actually does or whether it has side effects the compiler isn't aware of (a memory-mapped I/O access performed via inline assembly, for instance).

### The Danger of Incomplete Clobber/Constraint Declarations

**[Inference]** This is the primary correctness hazard specific to inline assembly, and a meaningfully different failure mode than the UB-reliance issues discussed for ordinary C in the compiler-optimization-flags content: if an `asm` block modifies a register, memory location, or condition-code flag that is *not* correctly declared in its output/clobber list, the compiler's optimizer — operating on the (incorrect) assumption that nothing outside the declared outputs changed — may reuse a stale value it believes is still valid in a register or has cached from memory, producing bugs that are highly sensitive to surrounding code and optimization level, and that can appear or disappear based on seemingly unrelated changes elsewhere in the function (since register allocation decisions shift). This class of bug is generally considered among the more difficult in embedded C to diagnose, precisely because the assembly block itself, viewed in isolation, is correct — the bug lives in the boundary declaration between the assembly and the surrounding compiler-generated code.

```c
/* Incorrect: modifies memory via a pointer but doesn't declare
   "memory" as a clobber, so the compiler may not realize it
   needs to reload any cached values after this executes */
asm volatile (
    "str %1, [%0]"
    :
    : "r" (ptr), "r" (value)
    /* missing: "memory" clobber */
);

/* Corrected: "memory" clobber tells the compiler this instruction
   may have modified arbitrary memory, forcing it to not rely on
   any previously cached memory values across this block */
asm volatile (
    "str %1, [%0]"
    :
    : "r" (ptr), "r" (value)
    : "memory"
);
```

### Rust Inline Assembly: `asm!` Macro

Rust's inline assembly (`core::arch::asm!`, stabilized in more recent Rust editions) follows broadly similar principles to GCC's extended asm — explicit operand binding and clobber declaration — but with Rust-idiomatic syntax and, notably, compile-time-checked operand direction/type correctness that GCC's string-based constraint syntax does not provide.

```rust
use core::arch::asm;

unsafe fn read_control_register() -> u32 {
    let result: u32;
    asm!(
        "mrs {0}, control",
        out(reg) result,
    );
    result
}
```

- `out(reg)` declares `result` as an output bound to a general-purpose register, analogous to GCC's `"=r"` constraint but checked as part of Rust's ordinary type system rather than a separate string-parsed constraint language.
- Like all direct hardware/register-level access in Rust, inline assembly requires an `unsafe` context, consistent with the `unsafe`-boundary discipline discussed extensively in the prior Rust ownership/memory-safety content — the compiler cannot verify an arbitrary assembly block upholds Rust's safety invariants any more than it can for a raw pointer dereference.
- **[Inference]** Rust's `asm!` macro was specifically designed, per its stabilization design goals, to reduce the class of clobber/constraint-declaration bugs described above for GCC-style inline assembly by making the operand-direction and register-class declarations part of syntax the compiler parses and checks structurally, rather than an embedded mini-language within a string literal — though the fundamental risk of an incorrectly specified clobber list producing a compiler/assembly boundary bug is not eliminated entirely, only reduced by better tooling around the declaration syntax.

### Naked Functions

A "naked" function (`__attribute__((naked))` in GCC/Clang, `#[naked]` historically in Rust though its stabilization status has evolved) is a function for which the compiler generates *no* prologue/epilogue code (no automatic stack frame setup, register saving, or return sequence) — the function body must be entirely hand-written assembly responsible for its own complete calling-convention compliance.

**[Inference]** Naked functions are used specifically in contexts (certain exception/interrupt handlers requiring precise control over the exact register-save sequence, or specific RTOS context-switch routines) where even the small, normally-invisible overhead or specific instruction sequence of the compiler's automatically generated prologue/epilogue is unacceptable or incorrect for the situation — a narrower and more specialized use case than ordinary inline assembly, generally reserved for low-level RTOS/HAL implementation code rather than typical application logic. **[Unverified]** Exact language/attribute support and restrictions for naked functions vary meaningfully across GCC, Clang, and Rust versions, and should be verified against current toolchain documentation for the specific compiler and version in use before relying on this mechanism.

### Reading Compiler-Generated Assembly as a Diagnostic Tool

Beyond writing assembly, reading compiler-generated assembly (via `objdump -d`, introduced in the GCC-toolchains content) is a routine diagnostic technique already referenced across this series — verifying `volatile` placement produced the expected re-read behavior (compiler-optimization-flags content), confirming a template instantiation is truly zero-cost (templates content), or diagnosing why a function behaves unexpectedly at a given optimization level.



```
arm-none-eabi-objdump -d build/firmware.elf > firmware.asm
```

**[Inference]** Familiarity with basic assembly reading (recognizing a function prologue/epilogue, a branch instruction, a memory load/store) is therefore a practical prerequisite for effective low-level embedded debugging generally, not solely for engineers who expect to write inline assembly themselves — it is the ground truth of what the CPU actually executes, beneath every abstraction layer (C, C++, Rust, and the compiler optimizations applied to any of them) discussed throughout this series.

### Assembly Involvement Across the Embedded Software Stack

===MERMAID_DIAGRAM===

flowchart TD

A["Power-on reset"] --> B["Hand-written/vendor\nreset_handler assembly:\nset sp, call data/bss init"]

B --> C["C runtime init\n(.data copy, .bss zero)"]

C --> D["main() - ordinary\nhigh-level C/C++/Rust"]

D --> E{"Special instruction\nneeded?"}

E -->|"Covered by intrinsic"| F["Compiler intrinsic\n(__WFI, __disable_irq)"]

E -->|"No intrinsic exists"| G["Inline assembly\n(asm volatile / asm!)"]

D --> H["Interrupt/exception\noccurs"]

H --> I{"Precise register\ncontrol required?"}

I -->|"Yes"| J["Naked function /\nhand-written handler"]

I -->|"No, ordinary handler"| K["Ordinary C/C++/Rust\ninterrupt handler function"]

**Related Topics**

- Writing and debugging a minimal reset handler for a new/custom microcontroller target
- GCC extended asm constraint reference (register classes, memory operands, early-clobber)
- Rust's `asm!` macro operand types and register class specifiers in depth
- RTOS context-switch implementation using naked functions and hand-written assembly
- Interpreting ARM Cortex-M fault handlers and stack frame unwinding after a hard fault
- Memory and instruction barrier instructions (`dsb`, `dmb`, `isb`) and when each is required
- Reading and annotating `objdump` disassembly output for optimization verification