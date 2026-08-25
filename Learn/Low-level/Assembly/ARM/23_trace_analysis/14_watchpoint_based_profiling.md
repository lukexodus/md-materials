## Watchpoint-based Profiling


Using hardware watchpoints for variable access profiling:

```assembly
// Configure watchpoint for variable profiling
profile_variable_access:
    // R0 = variable address
    PUSH    {R4, LR}
    MOV     R4, R0
    
    // Configure DWT comparator 2
    LDR     R0, =DWT_COMP2
    STR     R4, [R0]
    
    // Configure for read/write detection
    LDR     R0, =DWT_FUNCTION2
    MOV     R1, #0x06               // Generate watchpoint on R/W
    ORR     R1, R1, #(1<<4)         // Generate debug event
    STR     R1, [R0]
    
    // Enable DebugMonitor exception
    LDR     R0, =SCB_DEMCR
    LDR     R1, [R0]
    ORR     R1, R1, #(1<<16)        // MON_EN
    STR     R1, [R0]
    
    POP     {R4, PC}

// Debug Monitor exception handler
DebugMon_Handler:
    PUSH    {R4-R6, LR}
    
    // Check DWT match
    LDR     R0, =DWT_FUNCTION2
    LDR     R1, [R0]
    TST     R1, #(1<<24)            // MATCHED bit
    BEQ     debugmon_done
    
    // Record access
    LDR     R4, =variable_access_log
    LDR     R5, =access_count
    LDR     R6, [R5]
    
    // Get PC of access (from stack)
    MRS     R0, MSP
    LDR     R1, [R0, #24]           // PC
    
    // Get timestamp
    LDR     R2, =DWT_CYCCNT
    LDR     R2, [R2]
    
    // Store log entry
    LSL     R3, R6, #3              // 8 bytes per entry
    STR     R1, [R4, R3]            // PC
    STR     R2, [R4, R3, #4]        // Timestamp
    
    // Increment count
    ADD     R6, R6, #1
    STR     R6, [R5]
    
    // Clear matched bit
    LDR     R1, [R0]
    BIC     R1, R1, #(1<<24)
    STR     R1, [R0]
    
debugmon_done:
    POP     {R4-R6, PC}
```

**Key Points**

- Core dumps capture system state at failure including registers, stack, and fault information for post-mortem analysis
- Performance counters provide hardware-based measurement of cycles, cache misses, branch predictions, and other microarchitectural events
- Profiling techniques include instrumentation (adding measurement code), sampling (periodic PC capture), and call graph analysis for identifying bottlenecks
- Trace analysis uses CoreSight components (ITM, ETM, ETB, TPIU) to capture detailed execution flow, data accesses, and timing information with minimal overhead

**Important related topics:** JTAG and SWD debug protocols, GDB remote debugging integration, real-time operating system awareness in debuggers, symbol table and DWARF debug information, flash breakpoint implementation, semihosting for I/O during debugging.

---

