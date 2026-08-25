## Instrumentation Profiling


Adding measurement code at function entry/exit points:

```assembly
// Function instrumentation prologue
instrumented_function:
    PUSH    {R4, R5, LR}
    
    // Record entry time
    LDR     R4, =DWT_CYCCNT
    LDR     R4, [R4]                // Save start cycles
    
    // Function body
    // ... actual function code ...
    
    // Record exit time
    LDR     R5, =DWT_CYCCNT
    LDR     R5, [R5]                // Read end cycles
    
    // Calculate elapsed
    SUB     R5, R5, R4
    
    // Update profile data
    LDR     R0, =function_profile
    LDR     R1, [R0]                // Load call count
    ADD     R1, R1, #1
    STR     R1, [R0]
    
    LDR     R1, [R0, #4]            // Load total cycles
    ADD     R1, R1, R5
    STR     R1, [R0, #4]
    
    LDR     R1, [R0, #8]            // Load max cycles
    CMP     R5, R1
    STRGT   R5, [R0, #8]            // Update if greater
    
    LDR     R1, [R0, #12]           // Load min cycles
    CMP     R1, #0
    CMPNE   R5, R1
    STRLT   R5, [R0, #12]           // Update if less
    
    POP     {R4, R5, PC}

// Profile data structure per function
function_profile:
    .word   0                       // Call count
    .word   0                       // Total cycles
    .word   0                       // Max cycles
    .word   0xFFFFFFFF              // Min cycles
```

