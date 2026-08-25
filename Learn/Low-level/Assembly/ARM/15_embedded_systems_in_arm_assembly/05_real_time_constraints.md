## Real-time Constraints


Real-time constraints define the temporal requirements that embedded systems must satisfy to function correctly. In real-time systems, correctness depends not only on logical results but also on the time at which results are produced.

### Hard Real-time vs Soft Real-time

Hard real-time systems must meet deadlines absolutely—missing a deadline constitutes system failure. Examples include automotive airbag controllers, medical device monitors, and aircraft control systems. Soft real-time systems tolerate occasional deadline misses with degraded performance rather than catastrophic failure, such as video streaming or user interface responsiveness.

### Interrupt Latency

Interrupt latency is the time between an interrupt request and the execution of the first instruction in the interrupt service routine (ISR). ARM processors minimize this through:

**Interrupt handling sequence:**

- Interrupt signal assertion
- Current instruction completion
- Pipeline flush
- Context saving (automatic in ARM Cortex-M)
- Vector fetch and branch
- ISR execution begins

In ARM Cortex-M processors, hardware automatically saves registers R0-R3, R12, LR, PC, and xPSR to the stack, reducing interrupt latency to typically 12 cycles. The Cortex-M4 with FPU adds lazy stacking—floating-point registers are only saved if the ISR uses them.

```assembly
// Minimal ISR with fast execution
    .syntax unified
    .thumb
    
// Timer interrupt handler
TIM2_IRQHandler:
    PUSH    {LR}                    // Save return address
    
    // Clear interrupt flag (memory-mapped register)
    LDR     R0, =TIM2_SR            // Status register address
    LDR     R1, [R0]                // Read current value
    BIC     R1, R1, #0x01           // Clear UIF bit
    STR     R1, [R0]                // Write back
    
    // Critical time-sensitive code here
    LDR     R0, =GPIO_ODR           // Output data register
    LDR     R1, [R0]
    EOR     R1, R1, #(1<<5)         // Toggle pin
    STR     R1, [R0]
    
    POP     {PC}                    // Return from interrupt
```

### Deterministic Execution

Real-time systems require deterministic execution times. ARM assembly allows precise cycle counting:

```assembly
// Deterministic delay function (Cortex-M at known clock)
// R0 contains delay count
delay_cycles:
    SUBS    R0, R0, #1              // 1 cycle
    BNE     delay_cycles            // 2 cycles when taken, 1 when not
    BX      LR                      // 3 cycles
    
// Each loop iteration: 3 cycles
// Formula: (3 * count) + 4 cycles total
```

### Priority Inversion

Priority inversion occurs when a high-priority task waits for a resource held by a low-priority task, while a medium-priority task preempts the low-priority task. ARM Cortex-M processors implement priority levels (0-255, configurable groups) with hardware priority boosting:

```assembly
// Setting interrupt priorities (Cortex-M)
    LDR     R0, =NVIC_IPR0          // Interrupt priority register
    
    // Set UART interrupt to priority 2 (high priority)
    MOV     R1, #(2 << 5)           // Bits [7:5] for priority
    STRB    R1, [R0, #UART_IRQn]    // Set priority
    
    // Set Timer interrupt to priority 5 (lower priority)
    MOV     R1, #(5 << 5)
    STRB    R1, [R0, #TIM_IRQn]
```

### RTOS Context Switching

Real-time operating systems manage task scheduling. Context switching in ARM involves saving and restoring task states:

```assembly
// Simplified context switch (Cortex-M with RTOS)
PendSV_Handler:
    // Disable interrupts
    CPSID   I
    
    // Save context of current task
    MRS     R0, PSP                 // Get process stack pointer
    STMDB   R0!, {R4-R11}          // Save R4-R11 (R0-R3 already saved)
    
    // Save stack pointer to TCB
    LDR     R1, =current_task
    LDR     R1, [R1]
    STR     R0, [R1]                // Store SP in task control block
    
    // Load next task context
    LDR     R0, =next_task
    LDR     R0, [R0]
    LDR     R1, =current_task
    STR     R0, [R1]                // Update current task pointer
    
    LDR     R0, [R0]                // Load new SP from TCB
    LDMIA   R0!, {R4-R11}          // Restore R4-R11
    MSR     PSP, R0                 // Set process stack pointer
    
    // Re-enable interrupts
    CPSIE   I
    
    BX      LR                      // Return (hardware restores R0-R3)
```

