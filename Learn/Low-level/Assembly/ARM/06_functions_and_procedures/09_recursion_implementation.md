## Recursion Implementation


Recursive functions call themselves, creating multiple active instances simultaneously. Each invocation requires its own stack frame to maintain separate local state and return addresses.

### Direct Recursion

Direct recursion occurs when a function explicitly calls itself. Each recursive call creates a new stack frame, and stack frames accumulate until the base case is reached.

**Base Case**

Every recursive function must have a base case that stops recursion. Without a base case, recursion continues until stack overflow occurs. The base case typically tests arguments and returns directly without recursing.

**Recursive Case**

The recursive case modifies arguments to progress toward the base case, then calls the function recursively. The return value from the recursive call is typically used to compute the current invocation's return value.

**Example:**

```assembly
@ Recursive factorial: factorial(n) = n * factorial(n-1)
@ Base case: factorial(0) = 1
factorial:
    PUSH {r4, lr}           @ Save registers
    
    @ Base case: if (n == 0) return 1
    CMP r0, #0
    MOVEQ r0, #1
    POPEQ {r4, pc}          @ Conditional return for base case
    
    @ Recursive case: n * factorial(n-1)
    MOV r4, r0              @ Save n in callee-saved register
    SUB r0, r0, #1          @ n - 1
    BL factorial            @ Recursive call: r0 = factorial(n-1)
    MUL r0, r4, r0          @ n * factorial(n-1)
    
    POP {r4, pc}            @ Return

@ Calling factorial(5) creates stack frames:
@ factorial(5) → factorial(4) → factorial(3) → factorial(2) → factorial(1) → factorial(0)
@ Then returns: 1 → 1 → 2 → 6 → 24 → 120
```

### Stack Frame Accumulation

Each recursive call adds a stack frame containing saved registers and local variables. The stack grows until recursion reaches the base case, then shrinks as each invocation returns.

**Memory Usage**

Recursive depth determines memory usage. Recursion depth of N with F bytes per frame consumes N × F stack bytes. For factorial(5), six frames are active simultaneously. Deep recursion with large frames quickly exhausts stack space.

**Frame Content**

Each frame contains at minimum the return address (saved LR) and any callee-saved registers used. Additional local variables increase frame size. Minimizing per-frame size reduces total stack consumption for a given recursion depth.

**Example Analysis:**

```assembly
@ Stack state during factorial(3) execution:

@ Initial state: factorial(3) called from main
@ [High addresses]
@ main's saved registers
@ [factorial(3) frame]
@   saved r4 = (garbage)
@   saved LR = return to main
@   r4 = 3

@ After calling factorial(2):
@ [High addresses]  
@ main's saved registers
@ [factorial(3) frame]
@   saved r4 = 3
@   saved LR = return to main
@ [factorial(2) frame]
@   saved r4 = 2
@   saved LR = return to factorial(3)

@ After calling factorial(1):
@ [All previous frames...]
@ [factorial(1) frame]
@   saved r4 = 1
@   saved LR = return to factorial(2)

@ After calling factorial(0):
@ [All previous frames...]
@ [factorial(0) frame]
@   saved r4 = (unused in base case)
@   saved LR = return to factorial(1)
@ [Low addresses - current SP]

@ Then frames are popped in reverse order as functions return
```

### Tail Recursion Optimization

Tail-recursive functions where the recursive call is the last operation can be optimized to avoid stack frame accumulation. The optimization transforms recursion into iteration.

**Identification**

A function is tail-recursive if its recursive call is in tail position: the call's return value is immediately returned without further computation. For example, `return recursive_call(args)` is tail-recursive, but `return n * recursive_call(args)` is not because multiplication occurs after the call.

**Optimization Strategy**

Instead of calling the function recursively with BL (creating a new frame), the optimized version updates arguments and branches back to the function start with B. This reuses the current stack frame, maintaining constant stack usage regardless of recursion depth.

**Example:**

```assembly
@ Tail-recursive sum: sum(n, acc) = sum(n-1, acc+n) with base sum(0, acc) = acc
@ Not optimized:
sum_recursive:
    PUSH {r4-r5, lr}
    
    @ Base case: if (n == 0) return acc
    CMP r0, #0
    MOVEQ r0, r1
    POPEQ {r4-r5, pc}
    
    @ Recursive case: sum(n-1, acc+n)
    MOV r4, r0              @ Save n
    SUB r0, r0, #1          @ First arg: n-1
    ADD r1, r1, r4          @ Second arg: acc+n
    BL sum_recursive        @ Recursive call
    
    POP {r4-r5, pc}

@ Tail-call optimized version:
sum_optimized:
    @ Base case: if (n == 0) return acc
    CMP r0, #0
    MOVEQ r0, r1
    BXEQ lr
    
    @ Update arguments in place
    ADD r1, r1, r0          @ acc = acc + n
    SUB r0, r0, #1          @ n = n - 1
    B sum_optimized         @ Branch (not call) back to start
                             @ Reuses the same stack frame

@ sum_optimized(5, 0):
@ Iteration 1: n=5, acc=0  → n=4, acc=5
@ Iteration 2: n=4, acc=5  → n=3, acc=9
@ Iteration 3: n=3, acc=9  → n=2, acc=12
@ Iteration 4: n=2, acc=12 → n=1, acc=14
@ Iteration 5: n=1, acc=14 → n=0, acc=15
@ Base case reached: return 15
@ Only one stack frame exists throughout
```

**Accumulator Pattern**

Many recursive algorithms can be converted to tail-recursive form using an accumulator parameter. The accumulator carries intermediate results, allowing the function to compute the final result by the time it reaches the base case, eliminating post-recursion computation.

### Mutual Recursion

Mutual recursion occurs when function A calls function B, which calls function A, creating a cycle. Each function must be non-leaf and preserve LR because both participate in recursive calling.

**Forward Declarations**

Assembly doesn't require forward declarations like C, but branch targets must exist. Mutually recursive functions can reference each other freely as long as both are defined before program execution.

**Stack Behavior**

Mutually recursive functions alternate stack frames. The call pattern might be A → B → A → B → ... until base cases are reached in either A or B. Total stack depth is the sum of all active frames across both functions.

**Example:**

```assembly
@ Mutual recursion: even/odd checking
@ is_even(n) = (n == 0) ? true : is_odd(n-1)
@ is_odd(n)  = (n == 0) ? false : is_even(n-1)

is_even:
    PUSH {r4, lr}
    
    @ Base case: is_even(0) = true
    CMP r0, #0
    MOVEQ r0, #1            @ Return true
    POPEQ {r4, pc}
    
    @ Recursive case: is_odd(n-1)
    SUB r0, r0, #1
    BL is_odd               @ Call mutually recursive partner
    
    POP {r4, pc}

is_odd:
    PUSH {r4, lr}
    
    @ Base case: is_odd(0) = false
    CMP r0, #0
    MOVEQ r0, #0            @ Return false
    POPEQ {r4, pc}
    
    @ Recursive case: is_even(n-1)
    SUB r0, r0, #1
    BL is_even              @ Call mutually recursive partner
    
    POP {r4, pc}

@ Calling is_even(4) creates alternating frames:
@ is_even(4) → is_odd(3) → is_even(2) → is_odd(1) → is_even(0)
@ Returns: true ← true ← true ← false ← true
```

### Recursion vs Iteration Trade-offs

Recursive algorithms are often more elegant and easier to understand than iterative equivalents, but they consume more stack space and may execute slower due to function call overhead.

**When to Use Recursion**

Recursion is appropriate when: the algorithm is naturally recursive (tree traversals, divide-and-conquer), maximum depth is small and bounded, code clarity outweighs performance concerns, or tail-call optimization can eliminate stack growth.

**When to Prefer Iteration**

Iteration is preferable when: stack space is limited (embedded systems), recursion depth could be large, performance is critical, or the iterative version is equally clear. Most recursive algorithms can be converted to iterative form using explicit stacks or state machines.

**Iterative Conversion Example:**

```assembly
@ Iterative factorial (no recursion, no stack frames)
factorial_iterative:
    MOV r1, #1              @ result = 1
    CMP r0, #0              @ Handle n = 0
    MOVEQ r0, r1
    BXEQ lr
    
loop:
    MUL r1, r1, r0          @ result *= n
    SUBS r0, r0, #1         @ n--
    BNE loop                @ Continue if n != 0
    
    MOV r0, r1              @ Return result
    BX lr

@ Constant stack usage, no function call overhead
@ Executes faster and uses less memory than recursive version
```

**Key Points:**

- AAPCS defines r0-r3 as caller-saved argument/return registers, r4-r11 as callee-saved, and requires 8-byte stack alignment at function boundaries
- Caller-saved registers (r0-r3, r12) can be freely modified by callees; callers must preserve needed values before calling
- Callee-saved registers (r4-r11) must be preserved by callees if modified; this guarantees callers find them unchanged after calls
- Leaf functions that use only r0-r3 need no prologue/epilogue and return directly via BX LR
- Non-leaf functions must save LR in prologue and restore it (typically by popping into PC) in epilogue to handle nested calls
- Stack frames grow downward with each nested call, containing saved registers, return addresses, and local variables
- Tail calls can be optimized from BL to B, allowing the tail-called function to return directly to the original caller
- Recursive functions create stack frame accumulation with depth equal to recursion depth; each frame consumes stack space
- Tail recursion can be optimized to iteration by updating arguments and branching back to function start, maintaining constant stack usage
- Arguments beyond r0-r3 pass through the stack; the caller pushes them before calling, and the callee accesses them via stack pointer offsets

**Important related topics:** Stack unwinding for exception handling and debugging, frame pointer usage for debuggability vs register availability trade-offs, Position-Independent Code (PIC) and register usage implications, interrupt handler special calling conventions, naked functions without automatic prologue/epilogue, software stack checking and protection mechanisms, profiling and call graph analysis, trampolines and thunks for indirect calls.

---

