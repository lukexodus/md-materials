## Timestamp Generation


Generating timestamps for trace correlation:

```assembly
// Configure timestamp generation
    LDR     R0, =DWT_CTRL
    LDR     R1, [R0]
    
    // Enable exception trace
    ORR     R1, R1, #(1<<16)        // EXCTRCENA
    
    // Enable PC sampling
    ORR     R1, R1, #(1<<12)        // PCSAMPLENA
    
    // Configure PC sample rate
    BIC     R1, R1, #(3<<10)        // Clear SYNCTAP
    ORR     R1, R1, #(1<<10)        // SYNCTAP = 1 (every 2^24 cycles)
    
    // Enable timestamp counter
    BIC     R1, R1, #(15<<1)        // Clear TSTAMP_PRESCALE
    ORR     R1, R1, #(1<<1)         // Prescale = 1 (divide by 4)
    
    STR     R1, [R0]
```

