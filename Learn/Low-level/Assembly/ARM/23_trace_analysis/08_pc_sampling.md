## PC Sampling


Periodic program counter sampling for statistical profiling:

```assembly
// Configure PC sampling via DWT
    LDR     R0, =DWT_CTRL
    LDR     R1, [R0]
    
    // Enable PC sampling
    ORR     R1, R1, #(1<<12)        // PCSAMPLENA
    
    // Configure sample rate (CYCTAP + SYNCTAP)
    // CYCTAP=0, SYNCTAP=01 -> sample every 2^10 cycles
    BIC     R1, R1, #(1<<9)         // CYCTAP = 0
    BIC     R1, R1, #(3<<10)        // Clear SYNCTAP
    ORR     R1, R1, #(1<<10)        // SYNCTAP = 01
    
    STR     R1, [R0]
    
    // PC samples will be output via trace port
```

