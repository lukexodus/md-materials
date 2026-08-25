## Nested Function Calls


Nested function calls occur when a function calls another function, which may itself call others, creating a chain of active stack frames. Managing nested calls requires careful preservation of return addresses and register values.

### Call Chain Management

Each function call pushes a new return address onto the stack (explicitly or implicitly via saved LR). The chain of return addresses forms the call stack, enabling each function to return to its caller in sequence.

**Stack Growth**

Each nested call that saves registers and allocates local variables grows the stack downward (on full descending stacks). The stack pointer decreases with each call and increases during returns. Running out of stack space causes stack overflow.

**Register Window**

At any point in nested calls, only the most recent function's registers are visible. Previous functions' register values are saved on the stack. As functions return, saved register values are restored, recreating previous contexts.

**Example:**

```assembly
@ Function A calls B, which calls C
function_a:
    PUSH {r4, lr}           @ Save A's registers, LR points to A's caller
    MOV r4, #10
    BL function_b           @ Call B, new LR points to A's code after BL
    ADD r0, r4, r0          @ After B returns, r4 still contains 10
    POP {r4, pc}            @ Return to A's caller

function_b:
    PUSH {r4, lr}           @ Save B's registers, LR points to A
    MOV r4, #20
    BL function_c           @ Call C, new LR points to B's code after BL
    ADD r0, r4, r0          @ After C returns, r4 still contains 20
    POP {r4, pc}            @ Return to A (saved LR)

function_c:
    MOV r0, #30             @ Leaf function, no save needed
    BX lr                   @ Return to B (current LR)

@ Call sequence creates stack frames:
@ [High addresses]
@ A's saved r4, A's saved LR (points to A's caller)
@ B's saved r4, B's saved LR (points to A)
@ [Low addresses - current SP]
```

### Deep Call Stacks

Deeply nested function calls accumulate many stack frames. Each frame occupies memory, and excessive nesting can exhaust available stack space. [Inference: Stack overflow typically results in undefined behavior, corrupting other data or causing program crashes, depending on the system's memory protection mechanisms].

**Stack Depth Considerations**

Embedded systems often have limited stack space (kilobytes rather than megabytes). Deep recursion or many nested calls with large local variable allocations can exhaust this space. Iterative algorithms are preferred over recursive ones in stack-constrained environments.

**Frame Size Impact**

Functions that save many registers and allocate large local variable arrays create large stack frames. Multiplied by call depth, this can quickly consume stack space. Minimizing saved registers and local variable size reduces per-frame overhead.

### Register Pressure in Nested Calls

Functions in the middle of call chains experience register pressure: they need registers for their own computations while preserving values across nested calls to functions lower in the chain.

**Callee-Saved Register Usage**

Using callee-saved registers (r4-r11) allows values to survive nested calls without manual preservation. A function stores important values in r4-r7, calls helpers that might use r0-r3, and finds r4-r7 unchanged afterward. This is the primary advantage of the caller/callee-saved division.

**Spilling to Stack**

When all suitable registers are occupied, values must be spilled to the stack. Load and store instructions around computations and function calls transfer values between registers and stack slots. Excessive spilling indicates high register pressure and may suggest refactoring.

**Example:**

```assembly
@ Function with register pressure
complex_function:
    PUSH {r4-r8, lr}        @ Need many callee-saved registers
    
    MOV r4, r0              @ Save arguments and intermediates
    MOV r5, r1              @ in callee-saved registers
    MOV r6, r2
    MOV r7, r3
    
    MOV r0, r4
    BL process_1            @ r4-r7 survive this call
    MOV r8, r0              @ Save result
    
    MOV r0, r5
    BL process_2            @ r4-r8 survive this call
    
    ADD r0, r8, r0          @ Combine results from saved registers
    ADD r0, r0, r6
    ADD r0, r0, r7
    
    POP {r4-r8, pc}
```

