## Trace Filtering


Configuring address range comparators to filter trace:

```assembly
// Configure ETM address comparator for code region filtering
setup_etm_filtering:
    PUSH {R4, R5, LR}

    // Unlock ETM
    LDR     R0, =ETM_LAR
    LDR     R1, =0xC5ACCE55
    STR     R1, [R0]

    // Configure address comparator 0 (start address)
    LDR     R0, =ETM_ACVR0          // Address Comparator Value Register 0
    LDR     R1, =TRACE_START_ADDR
    STR     R1, [R0]

    // Configure address comparator 1 (end address)
    LDR     R0, =ETM_ACVR1
    LDR     R1, =TRACE_END_ADDR
    STR     R1, [R0]

    // Configure address comparator access type
    LDR     R0, =ETM_ACTR0
    MOV     R1, #0x01               // Instruction execute
    STR     R1, [R0]

    LDR     R0, =ETM_ACTR1
    MOV     R1, #0x01
    STR     R1, [R0]

    // Configure trace enable to use address range
    LDR     R0, =ETM_TECR1          // Trace Enable Control Register
    MOV     R1, #0x01000100         // Enable on comparator pair 0
    STR     R1, [R0]

    POP     {R4, R5, PC}
````

