## Processor Initialization


After reset, the ARM processor begins execution at the reset vector in Secure EL3. The bootloader must configure the processor for proper operation.

**Example:**

```assembly
// Reset vector - execution starts here after power-on
// Processor is in Secure EL3, AArch64 state

.section .text.reset
.global _reset_vector

_reset_vector:
        // Disable interrupts
        MSR     DAIFSet, #0xF               // Mask all interrupts
        
        // Check current exception level
        MRS     X0, CurrentEL
        CMP     X0, #(3 << 2)               // Check if EL3
        B.NE    unexpected_el
        
        // Initialize processor state
        BL      init_cpu_state
        
        // Initialize system control registers
        BL      init_system_control
        
        // Set up exception vectors
        LDR     X0, =exception_vector_table
        MSR     VBAR_EL3, X0
        
        // Initialize stack pointer for EL3
        LDR     X0, =__stack_el3_end
        MOV     SP, X0
        
        // Branch to main bootloader code
        B       bootloader_main

unexpected_el:
        // Should never happen after reset
        WFI
        B       unexpected_el
```

**Example:**

```assembly
// Initialize CPU state registers
init_cpu_state:
        // Initialize SCTLR_EL3 - System Control Register
        MOV     X0, #0x0
        ORR     X0, X0, #(1 << 12)          // I bit - Enable instruction cache
        ORR     X0, X0, #(1 << 2)           // C bit - Enable data cache
        ORR     X0, X0, #(1 << 0)           // M bit - Enable MMU (set later)
        BIC     X0, X0, #(1 << 0)           // Initially disable MMU
        MSR     SCTLR_EL3, X0
        
        // Initialize SCR_EL3 - Secure Configuration Register
        MOV     X0, #0x0
        ORR     X0, X0, #(1 << 10)          // RW bit - EL2/EL1 are AArch64
        ORR     X0, X0, #(1 << 0)           // NS bit - Initially 0 (Secure)
        ORR     X0, X0, #(1 << 3)           // EA bit - External aborts to EL3
        ORR     X0, X0, #(1 << 2)           // FIQ to EL3
        MSR     SCR_EL3, X0
        
        // Initialize CPTR_EL3 - Architectural Feature Trap Register
        MSR     CPTR_EL3, XZR               // Don't trap FP/SIMD
        
        ISB                                 // Synchronize context
        
        RET

init_system_control:
        // Disable MMU and caches initially
        MRS     X0, SCTLR_EL3
        BIC     X0, X0, #(1 << 0)           // Disable MMU
        BIC     X0, X0, #(1 << 2)           // Disable D-cache
        BIC     X0, X0, #(1 << 12)          // Disable I-cache
        MSR     SCTLR_EL3, X0
        ISB
        
        // Invalidate instruction cache
        IC      IALLUIS
        ISB
        
        // Invalidate data cache
        BL      invalidate_dcache_all
        
        // Invalidate TLB
        TLBI    ALLE3
        DSB     SY
        ISB
        
        RET
```

