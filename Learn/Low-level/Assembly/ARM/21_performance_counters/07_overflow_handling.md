## Overflow Handling


```assembly
// Configure overflow interrupt
    // Set overflow flag on cycle counter overflow
    MOV     R0, #0x80000000
    MCR     p15, 0, R0, c9, c14, 1  // Write PMINTENSET
    
    // Enable PMU interrupt in NVIC
    LDR     R0, =NVIC_ISER
    LDR     R1, =(1 << PMU_IRQn)
    STR     R1, [R0]

// PMU overflow interrupt handler
PMU_IRQHandler:
    PUSH    {LR}
    
    // Read overflow status
    MRC     p15, 0, R0, c9, c12, 3  // Read PMOVSR
    
    // Check cycle counter overflow
    TST     R0, #0x80000000
    BNE     cycle_overflow
    
    // Check event counter overflows
    TST     R0, #0x01
    BNE     counter0_overflow
    
    // Clear overflow flags
    MCR     p15, 0, R0, c9, c12, 3  // Write PMOVSR
    
    POP     {PC}
    
cycle_overflow:
    // Increment software counter for cycle overflow
    LDR     R1, =cycle_overflow_count
    LDR     R2, [R1]
    ADD     R2, R2, #1
    STR     R2, [R1]
    B       clear_overflow
```

