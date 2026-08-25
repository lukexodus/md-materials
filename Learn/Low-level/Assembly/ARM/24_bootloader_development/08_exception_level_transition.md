## Exception Level Transition


Before jumping to the kernel, the bootloader must transition from EL3 to EL2 or EL1, depending on virtualization support.

**Example:**

```assembly
// Drop to EL2/EL1 and jump to kernel
// X0 = DTB address
// X1 = kernel entry point

jump_to_kernel:
        // Save kernel parameters
        MOV     X20, X0                     // DTB address for kernel
        MOV     X21, X1                     // Kernel entry
        
        // Disable MMU before transition
        MRS     X0, SCTLR_EL3
        BIC     X0, X0, #(1 << 0)           // Disable MMU
        BIC     X0, X0, #(1 << 2)           // Disable D-cache
        MSR     SCTLR_EL3, X0
        ISB
        
        // Prepare EL2 state
        MRS     X0, SCR_EL3
        ORR     X0, X0, #(1 << 0)           // NS bit - Non-secure
        ORR     X0, X0, #(1 << 10)          // RW bit - EL2 is AArch64
        MSR     SCR_EL3, X0
        
        // Set return address to kernel
        MSR     ELR_EL3, X21
        
        // Configure processor state after ERET
        MOV     X0, #0x3C9                  // EL2h, IRQ/FIQ masked
        MSR     SPSR_EL3, X0
        
        // Set up registers for kernel
        MOV     X0, X20                     // X0 = DTB address
        MOV     X1, #0                      // X1 = 0 (reserved)
        MOV     X2, #0                      // X2 = 0 (reserved)
        MOV     X3, #0                      // X3 = 0 (reserved)
        
        // Jump to kernel in EL2
        ERET
```

