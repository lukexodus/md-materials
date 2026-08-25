## Data Trace


Capturing data read/write operations using DWT:

```assembly
// Configure DWT for data trace
setup_data_trace:
    PUSH    {R4, LR}
    
    // Enable trace
    LDR     R0, =DEM_CR
    LDR     R1, [R0]
    ORR     R1, R1, #(1<<24)        // TRCENA
    STR     R1, [R0]
    
    // Configure comparator 0 for variable monitoring
    LDR     R0, =DWT_COMP0
    LDR     R1, =monitored_variable
    STR     R1, [R0]
    
    // Set function to generate trace on R/W
    LDR     R0, =DWT_FUNCTION0
    MOV     R1, #0x0C               // Data trace: read and write
    ORR     R1, R1, #(1<<8)         // DATAVMATCH
    STR     R1, [R0]
    
    // Configure comparator 1 for array range
    LDR     R0, =DWT_COMP1
    LDR     R1, =monitored_array
    STR     R1, [R0]
    
    // Set mask for range
    LDR     R0, =DWT_MASK1
    MOV     R1, #7                  // Monitor 256-byte range (2^8)
    STR     R1, [R0]
    
    // Set function
    LDR     R0, =DWT_FUNCTION1
    MOV     R1, #0x0C
    STR     R1, [R0]
    
    POP     {R4, PC}
```

