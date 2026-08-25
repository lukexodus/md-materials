## Trace Buffer Management


Managing circular trace buffers in embedded trace buffer (ETB):

```assembly
// Configure ETB (Embedded Trace Buffer)
setup_etb:
    PUSH    {R4, LR}
    
    // Unlock ETB
    LDR     R0, =ETB_LAR
    LDR     R1, =0xC5ACCE55
    STR     R1, [R0]
    
    // Read buffer size
    LDR     R0, =ETB_RDP            // RAM Depth Register
    LDR     R1, [R0]
    LDR     R2, =etb_size
    STR     R1, [R2]                // Store for later use
    
    // Configure formatter and flush control
    LDR     R0, =ETB_FFCR
    MOV     R1, #0x00001403         // Stop on flush, formatter enabled
    STR     R1, [R0]
    
    // Configure circular buffer mode
    LDR     R0, =ETB_MODE
    MOV     R1, #0x00000000         // Circular mode
    STR     R1, [R0]
    
    // Enable ETB
    LDR     R0, =ETB_CTL
    MOV     R1, #0x00000001
    STR     R1, [R0]
    
    POP     {R4, PC}

// Read trace data from ETB
read_etb_trace:
    PUSH    {R4-R7, LR}
    MOV     R4, R0                  // Destination buffer
    MOV     R5, R1                  // Max words to read
    
    // Disable ETB capture
    LDR     R0, =ETB_CTL
    MOV     R1, #0
    STR     R1, [R0]
    
    // Get write pointer (shows how much data)
    LDR     R0, =ETB_RWP
    LDR     R6, [R0]                // RAM write pointer
    
    // Reset read pointer
    LDR     R0, =ETB_RRP
    MOV     R1, #0
    STR     R1, [R0]
    
    // Read loop
    MOV     R7, #0                  // Counter
read_etb_loop:
    CMP     R7, R5
    BGE     read_etb_done
    CMP     R7, R6
    BGE     read_etb_done
    
    // Read data
    LDR     R0, =ETB_RRD            // RAM Read Data
    LDR     R1, [R0]
    STR     R1, [R4], #4
    
    ADD     R7, R7, #1
    B       read_etb_loop
    
read_etb_done:
    MOV     R0, R7                  // Return words read
    
    // Re-enable ETB
    LDR     R1, =ETB_CTL
    MOV     R2, #1
    STR     R2, [R1]
    
    POP     {R4-R7, PC}
```

