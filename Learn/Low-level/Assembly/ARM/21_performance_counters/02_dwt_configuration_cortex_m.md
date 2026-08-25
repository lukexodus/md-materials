## DWT Configuration (Cortex-M)


```assembly
// Enable DWT cycle counter (Cortex-M4/M7)
    // Enable trace system
    LDR     R0, =DEM_CR             // Debug Exception and Monitor Control
    LDR     R1, [R0]
    ORR     R1, R1, #(1<<24)        // Set TRCENA bit
    STR     R1, [R0]
    
    // Reset cycle counter
    LDR     R0, =DWT_CYCCNT
    MOV     R1, #0
    STR     R1, [R0]
    
    // Enable cycle counter
    LDR     R0, =DWT_CTRL
    LDR     R1, [R0]
    ORR     R1, R1, #1              // CYCCNTENA bit
    STR     R1, [R0]

// Read cycle counter
read_cycle_count:
    LDR     R0, =DWT_CYCCNT
    LDR     R0, [R0]
    BX      LR
```

