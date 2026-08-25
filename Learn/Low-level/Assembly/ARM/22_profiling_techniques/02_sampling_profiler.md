## Sampling Profiler


Periodic sampling using timer interrupts to build execution histogram:

```assembly
// Sampling profiler setup
setup_sampling_profiler:
    PUSH    {LR}
    
    // Allocate histogram (PC ranges to sample buckets)
    LDR     R0, =CODE_START
    LDR     R1, =CODE_END
    SUB     R2, R1, R0              // Code size
    LSR     R2, R2, #4              // Divide by 16 (bucket size)
    LDR     R1, =histogram_buckets
    STR     R2, [R1]
    
    // Configure timer for sampling (1ms interval)
    LDR     R0, =1000               // 1ms at 1MHz timer
    BL      start_sample_timer
    
    POP     {PC}

// Sample timer ISR
sample_timer_ISR:
    PUSH    {R4-R6, LR}
    
    // Get interrupted PC from stack
    MRS     R4, PSP                 // Or MSP depending on context
    LDR     R5, [R4, #24]           // PC at stack offset 24
    
    // Calculate histogram bucket
    LDR     R0, =CODE_START
    SUB     R5, R5, R0              // Offset from code start
    LSR     R5, R5, #4              // Divide by bucket size (16 bytes)
    
    // Increment bucket counter
    LDR     R0, =histogram_data
    LDR     R1, [R0, R5, LSL #2]    // Load current count
    ADD     R1, R1, #1
    STR     R1, [R0, R5, LSL #2]    // Store incremented count
    
    // Increment total samples
    LDR     R0, =total_samples
    LDR     R1, [R0]
    ADD     R1, R1, #1
    STR     R1, [R0]
    
    // Clear timer interrupt flag
    BL      clear_timer_interrupt
    
    POP     {R4-R6, PC}
```

