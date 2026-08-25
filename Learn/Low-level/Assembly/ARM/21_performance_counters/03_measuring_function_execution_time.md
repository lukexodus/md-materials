## Measuring Function Execution Time


```assembly
// Measure cycles for function execution
measure_function:
    PUSH    {R4, R5, LR}
    
    // Read start cycle count
    BL      read_cycle_count
    MOV     R4, R0                  // Save start count
    
    // Execute function to measure
    BL      target_function
    
    // Read end cycle count
    BL      read_cycle_count
    MOV     R5, R0                  // Save end count
    
    // Calculate elapsed cycles
    SUB     R0, R5, R4
    
    // Store result
    LDR     R1, =measurement_result
    STR     R0, [R1]
    
    POP     {R4, R5, PC}
```

