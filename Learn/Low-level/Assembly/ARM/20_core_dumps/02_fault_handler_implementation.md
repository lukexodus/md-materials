## Fault Handler Implementation


```assembly
// Hard fault handler with state capture
    .syntax unified
    .thumb
    
    .section .bss
    .align 4
core_dump_buffer:
    .space 512                      // Reserve space for dump

    .section .text
    .global HardFault_Handler
    .type HardFault_Handler, %function
    
HardFault_Handler:
    // Determine which stack was in use
    TST     LR, #4                  // Check EXC_RETURN bit 2
    ITE     EQ
    MRSEQ   R0, MSP                 // Main stack pointer
    MRSNE   R0, PSP                 // Process stack pointer
    
    // R0 now points to stack frame
    // Save to core dump structure
    B       save_fault_info
    
save_fault_info:
    // Save stacked registers (hardware saved these)
    // Stack frame: R0, R1, R2, R3, R12, LR, PC, xPSR
    LDR     R1, =core_dump_buffer
    
    // Copy hardware-saved registers
    LDMIA   R0!, {R2-R9}            // Load 8 stacked registers
    STMIA   R1!, {R2-R9}            // Save to buffer
    
    // Save remaining core registers
    MRS     R2, MSP
    STR     R2, [R1], #4
    MRS     R2, PSP
    STR     R2, [R1], #4
    MRS     R2, PRIMASK
    STR     R2, [R1], #4
    MRS     R2, FAULTMASK
    STR     R2, [R1], #4
    MRS     R2, BASEPRI
    STR     R2, [R1], #4
    MRS     R2, CONTROL
    STR     R2, [R1], #4
    
    // Save fault status registers
    LDR     R2, =SCB_CFSR           // Configurable Fault Status
    LDR     R3, [R2]
    STR     R3, [R1], #4
    
    LDR     R2, =SCB_HFSR           // Hard Fault Status
    LDR     R3, [R2]
    STR     R3, [R1], #4
    
    LDR     R2, =SCB_MMFAR          // MemManage Fault Address
    LDR     R3, [R2]
    STR     R3, [R1], #4
    
    LDR     R2, =SCB_BFAR           // Bus Fault Address
    LDR     R3, [R2]
    STR     R3, [R1], #4
    
    // Trigger breakpoint for debugger
    BKPT    #0
    
    // If no debugger, infinite loop
fault_loop:
    B       fault_loop
```

