## Trace Synchronization


Synchronizing multiple trace sources:

```assembly
// Generate trace synchronization packet
    // ITM sends sync packet periodically
    LDR     R0, =ITM_TCR
    LDR     R1, [R0]
    
    // Trigger sync packet now
    ORR     R1, R1, #(1<<2)         // Trigger sync
    STR     R1, [R0]
    
    // Configure periodic sync
    BIC     R1, R1, #(3<<8)         // Clear prescaler
    ORR     R1, R1, #(2<<8)         // Sync every 2^16 cycles
    STR     R1, [R0]
```

