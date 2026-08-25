## Profiling Report Generation


Analyzing collected profiling data:

```assembly
// Generate profiling report
generate_profile_report:
    PUSH    {R4-R8, LR}
    
    // Sort functions by total cycles
    LDR     R4, =function_profiles
    LDR     R5, =function_count
    LDR     R5, [R5]
    
    MOV     R6, #0                  // Outer loop counter
sort_outer:
    CMP     R6, R5
    BGE     sort_done
    
    MOV     R7, R6
    ADD     R7, R7, #1              // Inner loop starts at outer+1
    
sort_inner:
    CMP     R7, R5
    BGE     sort_next_outer
    
    // Compare total cycles
    LSL     R0, R6, #4              // 16 bytes per entry
    LDR     R1, [R4, R0, #4]        // Total cycles for R6
    
    LSL     R0, R7, #4
    LDR     R2, [R4, R0, #4]        // Total cycles for R7
    
    CMP     R2, R1
    BLE     sort_no_swap
    
    // Swap entries
    LSL     R0, R6, #4
    LSL     R1, R7, #4
    MOV     R8, #0
swap_loop:
    CMP     R8, #16
    BGE     sort_no_swap
    
    LDR     R2, [R4, R0, R8]
    LDR     R3, [R4, R1, R8]
    STR     R3, [R4, R0, R8]
    STR     R2, [R4, R1, R8]
    
    ADD     R8, R8, #4
    B       swap_loop
    
sort_no_swap:
    ADD     R7, R7, #1
    B       sort_inner
    
sort_next_outer:
    ADD     R6, R6, #1
    B       sort_outer
    
sort_done:
    // Calculate percentages and output
    LDR     R4, =function_profiles
    LDR     R5, =function_count
    LDR     R5, [R5]
    
    // Calculate total cycles
    MOV     R6, #0                  // Total accumulator
    MOV     R7, #0                  // Index
calc_total:
    CMP     R7, R5
    BGE     calc_done
    
    LSL     R0, R7, #4
    LDR     R1, [R4, R0, #4]        // Total cycles
    ADD     R6, R6, R1
    
    ADD     R7, R7, #1
    B       calc_total
    
calc_done:
    // Output report (via ITM or store in memory)
    MOV     R7, #0
output_loop:
    CMP     R7, R5
    BGE     report_done
    
    LSL     R0, R7, #4
    
    // Get function data
    LDR     R1, [R4, R0]            // Call count
    LDR     R2, [R4, R0, #4]        // Total cycles
    LDR     R3, [R4, R0, #8]        // Max cycles
    
    // Calculate percentage: (cycles * 100) / total
    MOV     R0, #100
    MUL     R0, R2, R0
    // [Inference: Division implementation depends on CPU features]
    // UDIV available on Cortex-M3+
    UDIV    R0, R0, R6              // Percentage
    
    // Store or output results
    BL      output_profile_line
    
    ADD     R7, R7, #1
    B       output_loop
    
report_done:
    POP     {R4-R8, PC}
```

