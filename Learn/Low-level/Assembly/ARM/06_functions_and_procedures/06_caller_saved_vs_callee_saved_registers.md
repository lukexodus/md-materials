## Caller-Saved vs Callee-Saved Registers


Register preservation responsibilities are divided between calling and called functions. This division balances flexibility for short functions against register availability for complex functions.

### Caller-Saved Registers (r0-r3, r12)

Caller-saved registers are not preserved across function calls. The calling function must save their values before calling if those values are needed afterward. The called function can freely modify these registers without restoration.

**Argument Passing Registers (r0-r3)**

The first four integer or pointer arguments pass through r0-r3 in order. A function receiving three arguments finds them in r0, r1, and r2. Return values occupy r0 for single 32-bit results or r0-r1 for 64-bit results. These registers are caller-saved because they serve as communication channels between caller and callee.

**Scratch Register (r12/IP)**

r12 serves as an intra-procedure-call scratch register. Linker veneers (long-branch trampolines) and position-independent code implementations may corrupt r12 during function calls, even if the target function itself doesn't use it. Therefore, r12 must be treated as caller-saved and cannot hold values across calls.

**Usage Patterns**

Functions use r0-r3 for local computations without saving them. If a value in r0 must survive a function call, the caller either moves it to a callee-saved register before calling or pushes it to the stack. The called function assumes r0-r3 contain garbage upon entry (except for passed arguments) and can overwrite them freely.

**Example:**

```assembly
@ Caller must preserve r0-r3 if needed after call
caller:
    PUSH {lr}
    MOV r0, #5              @ First argument
    MOV r1, #10             @ Second argument
    MOV r4, r0              @ Save r0 value in callee-saved r4
    BL callee               @ r0-r3, r12 may be corrupted
    ADD r0, r4, r0          @ Use saved value from r4, return value from r0
    POP {pc}

callee:
    @ Can freely use r0-r3, r12 without saving
    ADD r0, r0, r1          @ r0 = arg1 + arg2 (return value)
    BX lr
```

### Callee-Saved Registers (r4-r11)

Callee-saved registers must be preserved by any function that uses them. If a function modifies r4-r11, it must save the original values in its prologue and restore them in its epilogue. This guarantees the calling function finds these registers unchanged after the call.

**Variable Preservation**

Long-lived local variables and values that must survive nested function calls are typically stored in callee-saved registers. This avoids repeatedly loading from memory or the stack across multiple operations and function calls.

**Prologue and Epilogue**

The function prologue saves registers at function entry, the epilogue restores them before return. Typically, PUSH saves multiple registers to the stack efficiently, and POP restores them. Including LR in the push and PC in the pop combines register preservation with call/return mechanics.

**Selective Preservation**

Functions need only save callee-saved registers they actually modify. A function using only r0-r3 requires no prologue or epilogue for register preservation. A function using r4 and r5 saves only those two registers, not all of r4-r11.

**Example:**

```assembly
@ Callee preserves r4-r7 which it uses
preserve_example:
    PUSH {r4-r7, lr}        @ Save registers to be modified
    
    MOV r4, r0              @ Use callee-saved registers
    MOV r5, r1              @ for local variables
    MOV r6, r2
    
    BL helper_function      @ r4-r7 survive this call
    
    ADD r0, r4, r5          @ Callee-saved values still available
    ADD r0, r0, r6
    
    POP {r4-r7, pc}         @ Restore and return
```

### Stack Frame Structure

Functions that use local variables beyond available registers or need to save many registers create stack frames. The stack frame holds saved registers, local variables, and sometimes saved arguments for nested calls.

**Frame Pointer (r11/FP)**

Some calling conventions use r11 as a frame pointer that points to a fixed location in the current stack frame. This simplifies debugging and stack unwinding but reduces available registers. Many embedded systems omit frame pointers to maximize register availability.

**Stack Layout**

A typical stack frame contains (from high to low addresses): previous frame data, saved callee-saved registers including LR, local variables, and space for outgoing arguments beyond r0-r3. The stack pointer points to the lowest used address (full descending stack convention).

**Example:**

```assembly
@ Function with local stack variables
stack_frame_example:
    PUSH {r4-r7, lr}        @ Save registers
    SUB sp, sp, #16         @ Allocate 16 bytes for local variables
                             @ [sp+0]  = local var 1
                             @ [sp+4]  = local var 2
                             @ [sp+8]  = local var 3
                             @ [sp+12] = local var 4
    
    MOV r0, #42
    STR r0, [sp, #0]        @ Store to local variable 1
    
    LDR r1, [sp, #0]        @ Load from local variable 1
    ADD r0, r1, #10
    
    ADD sp, sp, #16         @ Deallocate local variables
    POP {r4-r7, pc}         @ Restore and return
```

### Argument Passing Beyond r0-r3

When functions require more than four integer arguments, additional arguments pass through the stack. The caller pushes arguments beyond the fourth in reverse order before calling, and the callee accesses them relative to the stack pointer.

**Stack Argument Access**

After pushing r4-r7 and lr (5 words = 20 bytes), stack arguments are at sp + 20 or higher. The fifth argument is at [sp + 20], sixth at [sp + 24], etc. These offsets account for registers saved in the callee's prologue.

**Variadic Functions**

Functions with variable argument counts (like printf) must save all argument registers to the stack to create a contiguous argument array. The stdarg macros then access arguments sequentially from this stack location.

**Example:**

```assembly
@ Calling function with 6 arguments
caller_many_args:
    PUSH {lr}
    MOV r0, #1              @ Arg 1
    MOV r1, #2              @ Arg 2
    MOV r2, #3              @ Arg 3
    MOV r3, #4              @ Arg 4
    MOV r4, #5
    MOV r5, #6
    PUSH {r4, r5}           @ Args 5-6 on stack
    BL callee_many_args
    ADD sp, sp, #8          @ Clean up stack arguments
    POP {pc}

callee_many_args:
    PUSH {r4-r5, lr}
    @ r0-r3 contain args 1-4
    LDR r4, [sp, #12]       @ Arg 5 (sp+12: 3 saved regs * 4 bytes)
    LDR r5, [sp, #16]       @ Arg 6
    @ Use all six arguments
    POP {r4-r5, pc}
```

