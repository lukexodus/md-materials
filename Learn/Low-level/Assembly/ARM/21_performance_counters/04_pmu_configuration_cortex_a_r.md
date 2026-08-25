## PMU Configuration (Cortex-A/R)


```assembly
// Configure PMU on Cortex-A series
    // Enable user-mode access to PMU
    MRC     p15, 0, R0, c9, c14, 0  // Read PMUSERENR
    ORR     R0, R0, #1              // Enable user access
    MCR     p15, 0, R0, c9, c14, 0  // Write PMUSERENR
    
    // Enable all counters
    MRC     p15, 0, R0, c9, c12, 0  // Read PMCR
    ORR     R0, R0, #1              // Enable all counters
    ORR     R0, R0, #2              // Reset event counters
    ORR     R0, R0, #4              // Reset cycle counter
    MCR     p15, 0, R0, c9, c12, 0  // Write PMCR
    
    // Enable cycle counter
    MOV     R0, #0x80000000
    MCR     p15, 0, R0, c9, c12, 1  // Write PMCNTENSET
```

