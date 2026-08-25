## ETM Configuration


Embedded Trace Macrocell captures instruction execution trace:

```assembly
// Basic ETM configuration (Cortex-M4)
    // Unlock ETM
    LDR     R0, =ETM_LAR
    LDR     R1, =0xC5ACCE55
    STR     R1, [R0]
    
    // Configure main control
    LDR     R0, =ETM_CR
    LDR     R1, =0x00001000         // Basic configuration
    ORR     R1, R1, #(1<<11)        // Timestamp enable
    ORR     R1, R1, #(1<<10)        // Return stack enable
    STR     R1, [R0]
    
    // Set trace enable event (trace always)
    LDR     R0, =ETM_TRACEIDR
    MOV     R1, #0x01               // Trace ID
    STR     R1, [R0]
    
    // Configure trigger event
    LDR     R0, =ETM_TRIGGER
    LDR     R1, =0x0000406F         // Default trigger
    STR     R1, [R0]
    
    // Enable ETM
    LDR     R0, =ETM_CR
    LDR     R1, [R0]
    ORR     R1, R1, #1
    STR     R1, [R0]
```

