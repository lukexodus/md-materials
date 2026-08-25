## Multiple Counter Monitoring


```assembly
// Configure multiple performance counters
setup_perf_counters:
    PUSH    {R4, LR}
    
    // Counter 0: L1 I-cache misses (0x01)
    MOV     R0, #0
    MCR     p15, 0, R0, c9, c12, 5  // Select counter 0
    MOV     R0, #0x01
    MCR     p15, 0, R0, c9, c13, 1  // Set event type
    
    // Counter 1: L1 D-cache misses (0x03)
    MOV     R0, #1
    MCR     p15, 0, R0, c9, c12, 5  // Select counter 1
    MOV     R0, #0x03
    MCR     p15, 0, R0, c9, c13, 1  // Set event type
    
    // Counter 2: Branch mispredictions (0x10)
    MOV     R0, #2
    MCR     p15, 0, R0, c9, c12, 5  // Select counter 2
    MOV     R0, #0x10
    MCR     p15, 0, R0, c9, c13, 1  // Set event type
    
    // Enable all configured counters
    MOV     R0, #0x07               // Bits 0-2 for counters 0-2
    MCR     p15, 0, R0, c9, c12, 1  // Write PMCNTENSET
    
    POP     {R4, PC}

// Read all counters
read_all_counters:
    PUSH    {R4-R6, LR}
    LDR     R4, =perf_results
    
    // Read cycle counter
    MRC     p15, 0, R0, c9, c13, 0
    STR     R0, [R4], #4
    
    // Read counter 0
    MOV     R0, #0
    MCR     p15, 0, R0, c9, c12, 5
    MRC     p15, 0, R0, c9, c13, 2
    STR     R0, [R4], #4
    
    // Read counter 1
    MOV     R0, #1
    MCR     p15, 0, R0, c9, c12, 5
    MRC     p15, 0, R0, c9, c13, 2
    STR     R0, [R4], #4
    
    // Read counter 2
    MOV     R0, #2
    MCR     p15, 0, R0, c9, c12, 5
    MRC     p15, 0, R0, c9, c13, 2
    STR     R0, [R4], #4
    
    POP     {R4-R6, PC}
```

