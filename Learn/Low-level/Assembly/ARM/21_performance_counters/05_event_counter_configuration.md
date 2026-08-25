## Event Counter Configuration


```assembly
// Configure event counter to track cache misses (Cortex-A)
    // Select counter 0
    MOV     R0, #0
    MCR     p15, 0, R0, c9, c12, 5  // Write PMSELR
    
    // Configure to count L1 data cache misses (event 0x03)
    MOV     R0, #0x03
    MCR     p15, 0, R0, c9, c13, 1  // Write PMXEVTYPER
    
    // Enable counter 0
    MOV     R0, #1
    MCR     p15, 0, R0, c9, c12, 1  // Write PMCNTENSET
    
    // Reset counter
    MOV     R0, #1
    MCR     p15, 0, R0, c9, c12, 3  // Write PMCNTENCLEAR

// Read event counter
    MOV     R0, #0                  // Select counter 0
    MCR     p15, 0, R0, c9, c12, 5  // Write PMSELR
    MRC     p15, 0, R0, c9, c13, 2  // Read PMXEVCNTR
```

