## Tail Call Optimization


Tail call optimization (TCO) eliminates stack frame creation for functions called in tail position (where the result is immediately returned without further processing).

**Without TCO**:

```asm
function_a:
    PUSH RBP
    MOV RBP, RSP
    ; ... setup ...
    CALL function_b    ; Not a tail call
    ; ... process result ...
    MOV RSP, RBP
    POP RBP
    RET
```

**With TCO**:

```asm
function_a:
    PUSH RBP
    MOV RBP, RSP
    ; ... setup ...
    MOV RSP, RBP       ; Dismantle frame
    POP RBP
    JMP function_b     ; Jump instead of call (tail call)
```

When function_b returns, it returns directly to function_a's caller. The tail call optimization:

- Prevents stack growth in recursive functions
- Improves performance by eliminating call/return overhead
- Enables unbounded recursion without stack overflow

**Recursive tail call example**:

```asm
; factorial_tail(n, accumulator)
factorial_tail:
    CMP RDI, 0
    JE base_case
    ; n * acc -> accumulator
    IMUL RSI, RDI
    ; n - 1 -> n
    DEC RDI
    ; Tail call: factorial_tail(n-1, accumulator)
    JMP factorial_tail  ; Reuse current frame
    
base_case:
    MOV RAX, RSI        ; Return accumulator
    RET
```

This tail-recursive implementation runs in constant stack space regardless of n.

[Inference] Compilers apply TCO selectively based on optimization level and whether the language semantics guarantee tail call behavior. C/C++ compilers typically perform TCO as an optimization but don't guarantee it. Languages like Scheme mandate proper tail calls.

