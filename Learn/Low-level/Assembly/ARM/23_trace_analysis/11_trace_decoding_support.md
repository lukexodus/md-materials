## Trace Decoding Support


Markers and annotations for offline trace analysis:

```assembly
// Insert trace marker
insert_trace_marker:
    // R0 = marker ID
    PUSH    {R4, LR}
    MOV     R4, R0
    
    // Send marker via ITM port 31 (reserved for markers)
    MOV     R0, #31
    MOV     R1, R4
    BL      itm_send_char
    
    // Also log to trace buffer if enabled
    LDR     R0, =trace_marker_buffer
    LDR     R1, =trace_marker_index
    LDR     R2, [R1]
    
    // Get timestamp
    LDR     R3, =DWT_CYCCNT
    LDR     R3, [R3]
    
    // Store marker entry (timestamp + ID)
    ADD     R2, R2, R2, LSL #1      // R2 *= 3 (3 words per entry)
    LSL     R2, R2, #2              // Convert to byte offset
    STR     R3, [R0, R2]            // Timestamp
    STR     R4, [R0, R2, #4]        // Marker ID
    
    // Increment index
    LDR     R2, [R1]
    ADD     R2, R2, #1
    STR     R2, [R1]
    
    POP     {R4, PC}

// Checkpoint function for trace analysis
trace_checkpoint:
    // R0 = checkpoint name pointer
    // R1 = checkpoint ID
    PUSH    {R4, R5, LR}
    MOV     R4, R0
    MOV     R5, R1
    
    // Send checkpoint ID via trace
    MOV     R0, R5
    BL      insert_trace_marker
    
    // Record checkpoint data
    LDR     R0, =checkpoint_log
    LDR     R1, =checkpoint_count
    LDR     R2, [R1]
    
    // Calculate offset (4 words per checkpoint)
    LSL     R3, R2, #4              // R3 = R2 * 16 bytes
    
    // Store checkpoint info
    LDR     R6, =DWT_CYCCNT
    LDR     R6, [R6]
    STR     R6, [R0, R3]            // Timestamp
    STR     R5, [R0, R3, #4]        // ID
    STR     R4, [R0, R3, #8]        // Name pointer
    
    // Increment count
    ADD     R2, R2, #1
    STR     R2, [R1]
    
    POP     {R4, R5, PC}
```

