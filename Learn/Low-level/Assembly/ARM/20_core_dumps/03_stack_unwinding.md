## Stack Unwinding


Stack unwinding reconstructs the call chain leading to a fault:

```assembly
// Stack backtrace function
// R0 = current stack pointer
// R1 = buffer to store PC values
// R2 = max depth
stack_backtrace:
    PUSH    {R4-R7, LR}
    MOV     R4, R0                  // Current SP
    MOV     R5, R1                  // Output buffer
    MOV     R6, R2                  // Depth counter
    MOV     R7, #0                  // Frame counter
    
backtrace_loop:
    CMP     R7, R6
    BGE     backtrace_done
    
    // Validate stack pointer
    LDR     R0, =STACK_START
    CMP     R4, R0
    BLO     backtrace_invalid
    LDR     R0, =STACK_END
    CMP     R4, R0
    BHS     backtrace_invalid
    
    // Read saved LR from stack frame
    // ARM stack frame: R0-R3, R12, LR, PC, xPSR (8 words)
    LDR     R0, [R4, #24]           // PC at offset 24
    STR     R0, [R5], #4            // Store to output
    
    // Move to previous frame
    // [Inference: Frame size depends on function prologue]
    ADD     R4, R4, #32             // Typical frame size
    ADD     R7, R7, #1
    B       backtrace_loop
    
backtrace_done:
    MOV     R0, R7                  // Return frame count
    POP     {R4-R7, PC}
    
backtrace_invalid:
    MOV     R0, #-1                 // Error indicator
    POP     {R4-R7, PC}
```

