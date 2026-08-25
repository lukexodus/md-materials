## Stack Operations


The stack provides temporary storage for function local variables, saved registers, return addresses, and function arguments that don't fit in registers. ARM uses a full descending stack where the stack pointer points to the last occupied location and the stack grows toward lower memory addresses.

### Stack Pointer Management

In AArch64, the stack pointer (SP) must maintain 16-byte alignment at public interfaces (function calls). The hardware may enforce this alignment, triggering alignment faults for misaligned stack access. Within a function body, the stack pointer can temporarily lose alignment, but must restore 16-byte alignment before calling other functions.

Functions typically allocate stack space in the prologue by subtracting from SP and deallocate in the epilogue by adding back to SP:

```
function_prologue:
    stp x29, x30, [sp, #-32]!   // Pre-index: decrement SP by 32, store FP and LR
    mov x29, sp                  // Set up frame pointer
    stp x19, x20, [sp, #16]      // Save callee-saved registers
```

The pre-indexed addressing mode `[sp, #-32]!` atomically decrements SP by 32 bytes and uses the new value as the store address. This single instruction allocates stack space and saves registers. Post-indexed addressing would update SP after using its current value.

The corresponding epilogue restores registers and deallocates stack space:

```
function_epilogue:
    ldp x19, x20, [sp, #16]      // Restore callee-saved registers
    ldp x29, x30, [sp], #32      // Post-index: load FP and LR, increment SP by 32
    ret                          // Return using address in LR (x30)
```

Stack allocation sizes must be multiples of 16 bytes to maintain alignment. For odd-sized local variables, the compiler rounds up allocation. For example, allocating 20 bytes of locals requires subtracting 32 from SP (20 bytes for locals plus 12 bytes padding to reach the next 16-byte boundary, considering any saved registers).

### Stack Frame Layout

A typical stack frame contains several components in order from higher to lower addresses:

1. **Previous frame's data** (belongs to caller)
2. **Saved frame pointer (X29)** - points to previous frame's FP location, creating linked list
3. **Saved link register (X30)** - return address to caller
4. **Saved callee-saved registers** (X19-X28, V8-V15 lower 64 bits)
5. **Local variables** - function's automatic variables
6. **Alignment padding** - ensures 16-byte alignment
7. **Outgoing argument space** - arguments beyond X0-X7 for called functions
8. **Current SP location** - points here at function call points

The frame pointer (X29) enables stack unwinding by debuggers and exception handlers. Each frame's FP points to the previous frame's FP location, creating a linked chain back through all active function calls. Release builds often omit frame pointers (compiling with `-fomit-frame-pointer`) to free X29 for general use, improving performance but complicating debugging.

### Variable-Length Stack Allocation

Functions allocating variable-length arrays (VLAs) or using `alloca()` require dynamic stack adjustment. Since the allocation size isn't known at compile time, these functions must establish a frame pointer:

```
    stp x29, x30, [sp, #-16]!
    mov x29, sp                  // FP now marks frame base
    
    // Compute allocation size in x0
    add x0, x0, #15              // Round up to 16-byte boundary
    and x0, x0, #-16             // Clear low 4 bits
    sub sp, sp, x0               // Allocate variable space
    
    // Use allocated space...
    
    mov sp, x29                  // Restore SP from FP
    ldp x29, x30, [sp], #16
    ret
```

The frame pointer remains constant throughout function execution, allowing SP to move freely for dynamic allocations. At function exit, copying FP back to SP deallocates all variable-sized allocations in one instruction.

### Stack Probing for Large Allocations

Large stack allocations (typically >4KB) risk extending past the stack guard page, potentially causing silent stack overflow where the stack grows into other memory regions. Operating systems typically protect a page below the committed stack region; accessing this guard page triggers automatic stack extension.

For large allocations, code must probe the stack at page intervals to ensure proper guard page triggering:

```
large_allocation:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // Allocate 16KB (exceeds page size, requires probing)
    mov x9, #4096               // Page size
    
probe_loop:
    sub sp, sp, x9              // Decrease SP by one page
    str xzr, [sp]               // Touch the page (probe)
    subs x10, x10, x9           // Decrement remaining size
    b.gt probe_loop             // Continue if more to allocate
```

Modern compilers automatically insert probing code when detecting large stack allocations. The exact threshold and mechanism depend on the operating system's stack management. [Inference: Stack probing behavior varies across operating systems and may be configured through compiler flags.]

### Red Zone Considerations

Some ABIs define a "red zone" - a small region below the stack pointer that functions can use without adjusting SP, avoiding stack pointer manipulation for leaf functions with minimal local storage. [Unverified: AArch64 does not guarantee a red zone in all environments.] Signal handlers and interrupt service routines can corrupt memory below SP, making red zone usage unsafe in contexts where asynchronous events occur. [Inference: Portable code should avoid assuming red zone availability.]

### Stack Unwinding

Exception handling mechanisms (C++ exceptions, setjmp/longjmp) require stack unwinding - traversing the stack to find exception handlers and execute cleanup code. Unwinding can use frame pointer chains (following X29 links) or DWARF unwind information embedded in executables.

DWARF unwind info describes how to restore registers at each instruction address without requiring frame pointers. This allows optimized builds to omit FP while preserving exception handling capability. The information specifies canonical frame address (CFA) computation and register restore locations for each function at each instruction offset.

### Stack Protection Mechanisms

Stack buffer overflow attacks historically exploited overwrites of saved return addresses. Modern systems employ several countermeasures:

**Stack canaries** place random values between local variables and saved return addresses. Function epilogues verify canary integrity before returning; modification indicates buffer overflow and triggers termination. The compiler inserts canary checking code controlled by flags like `-fstack-protector-strong`.

**Stack address randomization (ASLR)** randomizes stack base addresses, making exploitation harder by preventing attackers from predicting return address locations.

**Shadow call stacks** maintain a separate stack storing only return addresses, protected from buffer overflows in regular stack data. [Unverified: Shadow call stack support varies by platform and requires specific compiler/runtime support.]

**Non-executable stacks** mark stack pages non-executable, preventing injected shellcode execution. ARM's Execute Never (XN) page attribute implements this at the hardware level through page tables.

