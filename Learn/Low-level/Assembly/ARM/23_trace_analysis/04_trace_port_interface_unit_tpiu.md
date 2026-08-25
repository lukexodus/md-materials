## Trace Port Interface Unit (TPIU)


TPIU formats and outputs trace data:

```assembly
// Configure TPIU for trace output
    // Unlock TPIU
    LDR     R0, =TPIU_LAR
    LDR     R1, =0xC5ACCE55
    STR     R1, [R0]
    
    // Set protocol (synchronous or asynchronous)
    LDR     R0, =TPIU_SPPR
    MOV     R1, #0x02               // SWO (Serial Wire Output)
    STR     R1, [R0]
    
    // Configure async prescaler for baud rate
    // Baud = (System Clock / (Prescaler + 1))
    LDR     R0, =TPIU_ACPR
    LDR     R1, =(72000000/2000000 - 1)  // 2 Mbps at 72 MHz
    STR     R1, [R0]
    
    // Set formatter and flush control
    LDR     R0, =TPIU_FFCR
    MOV     R1, #0x00000100         // Formatter enabled
    STR     R1, [R0]
````

