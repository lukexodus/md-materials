## Stack Frames


Stack frames (activation records) organize stack memory for each function invocation, storing local variables, saved registers, parameters, and linkage information.

### Stack Growth Direction

ARM stacks typically grow downward (toward lower addresses):

- Stack pointer starts at high address
- Pushing values decrements SP
- Popping values increments SP

The stack pointer must always point to valid, allocated stack memory. AAPCS specifies a "full descending" stack where SP points to the last occupied location.

### Stack Alignment Requirements

AAPCS mandates strict stack alignment:

**ARMv7**:

- SP must maintain 4-byte alignment at all times
- SP must maintain 8-byte alignment at public interfaces (function entry/exit)
- [Inference] 8-byte alignment ensures efficient double-word access and compatibility with LDRD/STRD instructions

**ARMv8**:

- SP must maintain 16-byte alignment at all times
- Violations may cause alignment faults or degraded performance

Proper alignment is the responsibility of both caller and callee. Functions that allocate stack space must ensure alignment is maintained.

### Frame Structure

A typical stack frame contains, from high to low addresses:

1. **Incoming arguments** (beyond register-passed arguments)
2. **Saved LR** (return address)
3. **Saved FP** (if frame pointer is used)
4. **Saved callee-saved registers** (R4-R11 in ARMv7, X19-X28 in ARMv8)
5. **Local variables**
6. **Temporary storage** (for spilled values, intermediate results)
7. **Outgoing arguments** (for nested function calls, beyond register-passed arguments)

The exact structure varies based on what the function needs. Simple leaf functions (functions that don't call other functions) may not create a frame at all.

### Frame Pointer Usage

The frame pointer (FP) is an optional feature that simplifies local variable access and debugging:

**ARMv7**: R11 conventionally serves as FP (though R7 is used in some contexts)

**ARMv8**: X29 is the designated frame pointer

When using a frame pointer:

1. On entry, save the previous FP and LR:

```
@ ARMv7
PUSH {fp, lr}         @ Save frame pointer and return address
MOV fp, sp            @ Establish new frame pointer
SUB sp, sp, #local_space  @ Allocate space for locals
```

```
@ ARMv8
STP x29, x30, [sp, #-16]!  @ Save FP and LR, pre-decrement SP
MOV x29, sp                @ Establish new frame pointer
SUB sp, sp, #local_space   @ Allocate space for locals
```

2. Throughout the function, access locals via FP-relative addressing with fixed offsets, even if SP changes
    
3. On exit, restore FP and return:
    

```
@ ARMv7
MOV sp, fp            @ Restore stack pointer
POP {fp, pc}          @ Restore FP and return

@ ARMv8
MOV sp, x29           @ Restore stack pointer
LDP x29, x30, [sp], #16  @ Restore FP and LR
RET
```

**Without frame pointer**, functions access locals via SP-relative addressing, using variable offsets when SP changes. This is more efficient (saves one register, eliminates FP setup) but complicates debugging and exception handling.

### Function Prologue

The function prologue sets up the stack frame on entry:

**ARMv7 example** with saved registers and locals:

```
function:
    PUSH {r4-r8, lr}      @ Save callee-saved registers and return address
    SUB sp, sp, #32       @ Allocate 32 bytes for local variables
    @ Function body...
```

**ARMv8 example**:

```
function:
    STP x29, x30, [sp, #-16]!   @ Save FP and LR
    MOV x29, sp                  @ Set up frame pointer
    STP x19, x20, [sp, #-16]!    @ Save callee-saved registers
    SUB sp, sp, #48              @ Allocate local variable space
    @ Function body...
```

The prologue must maintain stack alignment. If the total push/allocation is not alignment-compliant, adjust accordingly.

### Function Epilogue

The epilogue reverses the prologue, deallocating the frame and restoring saved values:

**ARMv7 example**:

```
    ADD sp, sp, #32       @ Deallocate local variables
    POP {r4-r8, pc}       @ Restore registers and return
```

**ARMv8 example**:

```
    ADD sp, sp, #48               @ Deallocate locals
    LDP x19, x20, [sp], #16       @ Restore callee-saved registers
    LDP x29, x30, [sp], #16       @ Restore FP and LR
    RET                            @ Return to caller
```

Alternatively, using the frame pointer:

```
@ ARMv7
    MOV sp, fp            @ Deallocate everything below FP
    POP {fp, pc}          @ Restore FP and return

@ ARMv8
    MOV sp, x29           @ Restore SP to frame base
    LDP x29, x30, [sp], #16
    RET
```

### Leaf Function Optimization

Leaf functions (functions that don't call other functions) don't need to save LR and may avoid creating a formal stack frame entirely if they don't need local storage or callee-saved registers:

```
@ ARMv7 minimal leaf function
leaf_add:
    ADD r0, r0, r1        @ r0 = r0 + r1
    BX lr                 @ Return (LR unchanged)

@ ARMv8 minimal leaf function
leaf_add:
    ADD x0, x0, x1        @ x0 = x0 + x1
    RET                   @ Return (X30 unchanged)
```

This optimization eliminates all stack overhead for simple functions.

### Stack Frame Example

**Example** C function:

```c
int compute(int a, int b, int c, int d, int e) {
    int x = a + b;
    int y = c * d;
    return x + y + e;
}
```

**ARMv7 implementation**:

```
@ Arguments: a=r0, b=r1, c=r2, d=r3, e=[sp, #0] (fifth arg on stack)
compute:
    PUSH {r4, lr}         @ Save r4 (for local y) and return address
    @ SP now 8 bytes lower, e is at [sp, #8]
    
    ADD r4, r0, r1        @ x = a + b (using r4 for x)
    MUL r0, r2, r3        @ r0 = c * d (y)
    LDR r1, [sp, #8]      @ r1 = e (load fifth argument)
    
    ADD r0, r4, r0        @ r0 = x + y
    ADD r0, r0, r1        @ r0 = x + y + e (result)
    
    POP {r4, pc}          @ Restore r4 and return
```

**ARMv8 implementation**:

```
@ Arguments: a=x0, b=x1, c=x2, d=x3, e=x4
compute:
    @ No need to save registers - using only argument registers
    ADD x5, x0, x1        @ x = a + b
    MUL x6, x2, x3        @ y = c * d
    ADD x0, x5, x6        @ result = x + y
    ADD x0, x0, x4        @ result += e
    RET                   @ Return
```

The ARMv8 version is simpler because all five arguments fit in registers.

### Dynamic Stack Allocation

Functions that require variable stack space (e.g., using `alloca()` or variable-length arrays) must use a frame pointer:

```
@ ARMv7 with variable allocation
function:
    PUSH {fp, lr}
    MOV fp, sp            @ Establish frame pointer
    @ r0 contains requested size
    SUB sp, sp, r0        @ Allocate variable amount
    BIC sp, sp, #7        @ Realign to 8 bytes
    @ Use allocated space via SP...
    MOV sp, fp            @ Restore SP using FP
    POP {fp, pc}
```

Without a frame pointer, the function cannot reliably determine how to restore SP because the allocation amount may vary at runtime.

### Nested Function Support

Some language implementations support nested functions (functions defined inside other functions). [Inference] These typically require a static link or display pointer to access the enclosing function's local variables:

[Inference] One approach uses an additional register (often the platform register) to point to the parent frame, allowing nested functions to access outer scope variables through this link. AAPCS doesn't mandate specific nested function support, leaving implementation to language-specific conventions.

### Red Zone

Some ABIs define a "red zone"—a fixed area below the stack pointer that functions can use without adjusting SP. [Inference] However, AAPCS does not define a red zone. Functions must not use memory below SP because asynchronous events (interrupts, signals) may overwrite it.

### Stack Unwinding and Exception Handling

Stack frames must be constructed to support exception handling and debugging:

[Inference] Frame pointers enable stack unwinding—traversing the call stack by following the chain of saved FP values. Each frame's saved FP points to the previous frame, creating a linked list.

[Inference] Exception handling mechanisms may insert unwind information into the executable, describing how to restore register state and deallocate each function's frame. This allows throwing exceptions through multiple stack frames, properly cleaning up each frame.

