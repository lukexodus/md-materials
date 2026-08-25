## Exception Trace


Tracing exception entry/exit and prioritization:

```assembly
// Enable exception trace
    LDR     R0, =DWT_CTRL
    LDR     R1, [R0]
    ORR     R1, R1, #(1<<16)        // EXCTRCENA
    STR     R1, [R0]
    
    // Configure ITM to output exception events
    LDR     R0, =ITM_TCR
    LDR     R1, [R0]
    ORR     R1, R1, #(1<<11)        // Enable exception trace
    STR     R1, [R0]

// Exception overhead measurement
measure_exception_overhead:
    PUSH    {R4-R6, LR}
    
    // Record pre-exception cycle count
    LDR     R4, =DWT_CYCCNT
    LDR     R5, [R4]
    
    // Trigger software interrupt
    LDR     R0, =NVIC_STIR          // Software Trigger Interrupt Register
    MOV     R1, #TEST_IRQn
    STR     R1, [R0]
    
    // Wait for ISR completion (set by ISR)
    LDR     R0, =isr_completed_flag
wait_isr:
    LDR     R1, [R0]
    CMP     R1, #0
    BEQ     wait_isr
    
    // Record post-exception cycle count
    LDR     R6, [R4]
    
    // Calculate overhead
    SUB     R0, R6, R5
    LDR     R1, =exception_overhead
    STR     R0, [R1]
    
    POP     {R4-R6, PC}

// Test ISR
test_ISR:
    PUSH    {LR}
    
    // Minimal ISR - just set flag
    LDR     R0, =isr_completed_flag
    MOV     R1, #1
    STR     R1, [R0]
    
    POP     {PC}
```

