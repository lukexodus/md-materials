## Instrumentation Trace Macrocell (ITM)


ITM provides printf-style debugging with minimal overhead:

```assembly
// ITM stimulus port write
// R0 = port number (0-31), R1 = data
itm_send_char:
    PUSH    {R4, R5, LR}
    MOV     R4, R0
    MOV     R5, R1
    
    // Check if ITM and stimulus port enabled
    LDR     R0, =ITM_TCR
    LDR     R1, [R0]
    TST     R1, #1                  // ITM enabled?
    BEQ     itm_done
    
    LDR     R0, =ITM_TER
    LDR     R1, [R0]
    MOV     R2, #1
    LSL     R2, R2, R4              // Check port bit
    TST     R1, R2
    BEQ     itm_done
    
    // Wait for port ready
    LDR     R0, =ITM_STIM0
    LSL     R4, R4, #2
    ADD     R0, R0, R4              // Calculate port address
    
itm_wait:
    LDR     R1, [R0]
    TST     R1, #1                  // Check ready bit
    BEQ     itm_wait
    
    // Write data
    STRB    R5, [R0]
    
itm_done:
    POP     {R4, R5, PC}

// ITM printf-like function
itm_print:
    // R0 = string pointer
    PUSH    {R4, R5, LR}
    MOV     R4, R0
    MOV     R5, #0                  // Use port 0
    
print_loop:
    LDRB    R1, [R4], #1
    CMP     R1, #0
    BEQ     print_done
    
    MOV     R0, R5
    BL      itm_send_char
    B       print_loop
    
print_done:
    POP     {R4, R5, PC}
```

