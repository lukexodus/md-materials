## Memory Dump Functions


```assembly
// Dump memory region to buffer
// R0 = source address, R1 = destination, R2 = size in bytes
memory_dump:
    PUSH    {R4-R6, LR}
    MOV     R4, R0
    MOV     R5, R1
    MOV     R6, R2
    
    // Align to word boundary
    ANDS    R3, R6, #3
    BEQ     dump_aligned
    ADD     R6, R6, #4
    BIC     R6, R6, #3
    
dump_aligned:
    MOVS    R3, #0
dump_loop:
    CMP     R3, R6
    BGE     dump_done
    
    LDR     R0, [R4, R3]            // Read word
    STR     R0, [R5, R3]            // Write to dump
    ADD     R3, R3, #4
    B       dump_loop
    
dump_done:
    POP     {R4-R6, PC}
```

