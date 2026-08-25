## Memory Access Profiling


Using DWT comparators to profile memory access patterns:

```assembly
// Configure DWT comparator for memory access tracking
    // Enable trace
    LDR     R0, =DEM_CR
    LDR     R1, [R0]
    ORR     R1, R1, #(1<<24)
    STR     R1, [R0]
    
    // Configure comparator 0 for address range
    LDR     R0, =DWT_COMP0
    LDR     R1, =MONITORED_ADDR_START
    STR     R1, [R0]
    
    // Configure mask for range
    LDR     R0, =DWT_MASK0
    MOV     R1, #4                  // Monitor 16-byte range
    STR     R1, [R0]
    
    // Configure function: match on read/write
    LDR     R0, =DWT_FUNCTION0
    MOV     R1, #0x07               // Match on R/W, generate event
    STR     R1, [R0]
```

