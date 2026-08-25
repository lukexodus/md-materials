## Leaf and Non-Leaf Functions


Functions are classified as leaf or non-leaf based on whether they call other functions. This classification affects register preservation requirements and prologue/epilogue complexity.

### Leaf Functions

Leaf functions do not call other functions. They represent the terminal nodes of the call tree. Leaf functions have simpler requirements because they don't corrupt the link register through nested calls.

**Simplified Prologue/Epilogue**

Leaf functions that only use caller-saved registers (r0-r3, r12) require no prologue or epilogue. The return address in LR remains valid throughout execution, and the function simply executes `BX LR` to return.

**Register Constraints**

Leaf functions can use r0-r3 freely and return via BX LR. If they need additional registers, they must save and restore callee-saved registers (r4-r11) but still don't need to save LR because no nested call overwrites it.

**Example:**

```assembly
@ Simple leaf function: no prologue/epilogue needed
leaf_simple:
    ADD r0, r0, r1          @ Use only r0-r3
    MUL r0, r0, r2
    BX lr                   @ Return immediately

@ Leaf function using callee-saved registers
leaf_with_saved:
    PUSH {r4-r5}            @ Save only registers being used
                             @ No need to save LR
    MOV r4, r0              @ Use callee-saved for locals
    MOV r5, r1
    ADD r0, r4, r5
    MUL r0, r0, r4
    POP {r4-r5}             @ Restore saved registers
    BX lr                   @ Return (LR still valid)
```

**Performance Benefits**

Leaf functions execute faster because they avoid memory accesses for pushing and popping the link register. Optimizing functions to be leaves when possible improves performance, especially for frequently called small functions.

### Non-Leaf Functions

Non-leaf functions call other functions, requiring them to preserve the link register since nested calls overwrite it. Every non-leaf function must save LR in its prologue and restore it (or directly load it into PC) in its epilogue.

**Mandatory LR Preservation**

When BL or BLX executes, the current LR value is lost. Non-leaf functions must save LR before any nested call. The standard pattern pushes LR in the prologue and pops PC in the epilogue, combining return address restoration with the return branch.

**Prologue Pattern**

The typical non-leaf prologue is `PUSH {r4-r7, lr}` or similar, saving any callee-saved registers the function uses plus LR. The push order doesn't matter functionally, but convention places LR last for consistency.

**Epilogue Pattern**

The epilogue `POP {r4-r7, pc}` restores saved registers and returns in one instruction. Loading the saved LR value into PC branches to the return address. This is more efficient than separate `POP {r4-r7, lr}` followed by `BX lr`.

**Example:**

```assembly
@ Non-leaf function must save LR
non_leaf_function:
    PUSH {r4-r5, lr}        @ Must save LR before nested calls
    
    MOV r4, r0              @ Save argument
    MOV r0, r1
    BL helper               @ Nested call overwrites LR
    
    ADD r0, r4, r0          @ Combine results
    
    POP {r4-r5, pc}         @ Restore registers and return
                             @ (loads saved LR into PC)

helper:
    ADD r0, r0, #1
    BX lr
```

### Tail Call Optimization

A tail call occurs when a function's last action is calling another function and returning that function's result unchanged. Tail calls can be optimized to branches, avoiding stack frame creation for the tail-called function.

**Optimization Technique**

Instead of using BL which pushes a return address, then popping and returning, a tail call uses B to branch directly to the target function. The target function returns directly to the original caller, bypassing the intermediate frame.

**Register Restoration**

Before the tail call branch, the function must restore callee-saved registers but not LR. The saved LR value points to the original caller, and the tail-called function will return there. Arguments for the tail call must be arranged in r0-r3 before branching.

**Example:**

```assembly
@ Tail call optimization
tail_call_example:
    PUSH {r4, lr}
    
    MOV r4, r0              @ Save original argument
    BL first_function       @ Regular call
    
    @ Last action is calling another function
    MOV r0, r4              @ Prepare argument
    POP {r4, lr}            @ Restore registers including LR
    B second_function       @ Tail call: branch instead of BL
                             @ second_function returns directly to our caller

@ Without optimization (less efficient):
tail_call_naive:
    PUSH {r4, lr}
    
    MOV r4, r0
    BL first_function
    
    MOV r0, r4
    BL second_function      @ Normal call
    
    POP {r4, pc}            @ Separate return
```

**Tail Recursion**

Tail-recursive functions where the recursive call is the last operation can be optimized similarly. Instead of creating new stack frames for each recursion level, the optimized version branches back to the function start with updated arguments, transforming recursion into iteration.

