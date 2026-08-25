## Stack Inspection and Debugging


Stack inspection techniques are essential for debugging and understanding program behavior.

### Manual Stack Walking

Walking the stack using frame pointers:

```asm
; Print stack trace (pseudocode)
print_backtrace:
    MOV RBX, RBP        ; Start with current frame
walk_loop:
    CMP RBX, 0          ; Check for null
    JE done
    
    ; Return address at [RBX+8]
    MOV RAX, [RBX+8]
    ; Print or record RAX
    
    ; Previous frame at [RBX]
    MOV RBX, [RBX]
    JMP walk_loop
done:
    RET
```

This traversal works only when frame pointers are consistently used. Optimized code without frame pointers requires unwind tables.

### Stack Canaries for Buffer Overflow Detection

Detecting stack corruption using canaries:

```asm
vulnerable_function:
    ; Prologue with canary
    PUSH RBP
    MOV RBP, RSP
    SUB RSP, 128
    
    ; Load canary value (thread-specific)
    MOV RAX, [FS:0x28]  ; Linux TLS canary location
    MOV [RBP-8], RAX    ; Place on stack
    XOR RAX, RAX        ; Clear register
    
    ; Function body with potential buffer overflow
    LEA RDI, [RBP-120]  ; Buffer address
    MOV RSI, user_input ; Source
    CALL strcpy         ; Potentially unsafe copy
    
    ; Epilogue with canary check
    MOV RAX, [RBP-8]    ; Load saved canary
    XOR RAX, [FS:0x28]  ; Compare with original
    JNE stack_corrupted ; Jump if mismatch
    
    MOV RSP, RBP
    POP RBP
    RET

stack_corrupted:
    ; Call __stack_chk_fail or similar
    CALL abort
```

Stack canaries detect overwrites that modify the canary value, indicating buffer overflow. [Inference] Canaries are effective against sequential buffer overflows but may not detect all forms of stack corruption, such as precise overwrites that avoid the canary location.

### Debugging Stack Issues

Common stack-related bugs and symptoms:

**Stack imbalance**: Mismatched PUSH/POP or incorrect stack pointer adjustment.

```asm
; Bug: missing POP
function_bug:
    PUSH RBX
    PUSH R12
    ; ... work ...
    POP R12
    ; BUG: Missing POP RBX
    RET         ; Returns to wrong address
```

Symptom: Function returns to wrong address, often causing immediate crash.

**Stack overflow**: Excessive recursion or large allocations.

```asm
; Bug: unbounded recursion
infinite_recursion:
    CALL infinite_recursion  ; Never terminates
    RET
```

Symptom: Segmentation fault when guard page is hit. Stack trace shows deep recursion.

**Use-after-scope**: Returning pointer to local variable.

```asm
; Bug: returning stack address
bad_function:
    SUB RSP, 16
    MOV [RSP], RAX      ; Store value on stack
    MOV RAX, RSP        ; Return pointer to stack
    ADD RSP, 16
    RET                 ; Caller receives invalid pointer
```

Symptom: Pointer corruption, unpredictable behavior when dereferenced.

**Misaligned stack**: Breaking calling convention alignment requirements.

```asm
; Bug: calling with misaligned stack
bad_caller:
    PUSH RAX            ; RSP now misaligned (not 16-byte)
    CALL strict_function ; Function expects aligned stack
    POP RAX
    RET
```

Symptom: Crashes or exceptions in called function, especially with SSE/AVX instructions.

### GDB Stack Inspection Commands

Common GDB commands for stack debugging:

- `backtrace` or `bt`: Display stack trace
- `frame N`: Switch to frame N
- `info frame`: Display current frame information
- `info args`: Display function arguments
- `info locals`: Display local variables
- `x/16gx $rsp`: Examine 16 quadwords at stack pointer
- `x/16gx $rbp`: Examine stack around frame pointer

### Stack Analysis Tools

**AddressSanitizer (ASan)**: Detects stack buffer overflows, use-after-return, and use-after-scope.

**Valgrind**: Provides stack and memory debugging, though with performance overhead.

**Stack unwinders**: libunwind (Linux), DbgHelp (Windows) provide programmatic stack walking.

**Core dumps**: Post-mortem debugging using saved stack state from crashed processes.

