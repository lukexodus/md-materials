## Real-time Trace Streaming


Streaming trace data to external host:

```assembly
// Configure trace streaming via SWO
setup_swo_streaming:
    PUSH    {R4, LR}
    
    // Configure TPIU for SWO
    BL      configure_tpiu_swo
    
    // Enable all ITM stimulus ports
    LDR     R0, =ITM_TER
    LDR     R1, =0xFFFFFFFF         // Enable all 32 ports
    STR     R1, [R0]
    
    // Configure ITM
    LDR     R0, =ITM_TCR
    MOV     R1, #0x00010005         // Enable ITM, sync, DWT packets
    STR     R1, [R0]
    
    // Start streaming thread/task
    BL      start_trace_stream_task
    
    POP     {R4, PC}

// Streaming task (called periodically)
trace_stream_task:
    PUSH    {R4-R7, LR}
    
    // Get trace buffer pointers
    LDR     R4, =trace_buffer_read
    LDR     R5, [R4]                // Read pointer
    LDR     R6, =trace_buffer_write
    LDR     R7, [R6]                // Write pointer
    
    // Check if data available
    CMP     R5, R7
    BEQ     stream_done
    
stream_loop:
    // Read byte from buffer
    LDR     R0, =trace_buffer_base
    LDRB    R1, [R0, R5]
    
    // Send via ITM port 0
    MOV     R0, #0
    BL      itm_send_char
    
    // Advance read pointer (circular buffer)
    ADD     R5, R5, #1
    LDR     R0, =TRACE_BUFFER_SIZE
    CMP     R5, R0
    MOVGE   R5, #0                  // Wrap around
    
    // Check if more data
    CMP     R5, R7
    BNE     stream_loop
    
    // Update read pointer
    STR     R5, [R4]
    
stream_done:
    POP     {R4-R7, PC}
```

