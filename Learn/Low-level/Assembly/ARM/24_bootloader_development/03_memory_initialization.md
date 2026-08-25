## Memory Initialization


The bootloader must initialize DRAM controllers before accessing external memory. This involves configuring timing parameters, training sequences, and controller registers.

**Example:**

```assembly
// Initialize external DRAM controller
// [Inference] Specific register addresses and values depend on SoC
// This example shows the general pattern

init_dram:
        STP     X29, X30, [SP, #-16]!
        MOV     X29, SP
        
        // Define base addresses
        LDR     X19, =DRAM_CTRL_BASE
        
        // Reset DRAM controller
        MOV     W0, #0x1
        STR     W0, [X19, #DRAM_CTRL_RESET]
        
        // Wait for reset completion
        MOV     W1, #10000
reset_wait:
        SUB     W1, W1, #1
        CBNZ    W1, reset_wait
        
        // Configure DRAM timing parameters
        LDR     W0, =DRAM_TIMING_VALUE      // [Unverified] Value depends on DRAM type
        STR     W0, [X19, #DRAM_TIMING_REG]
        
        // Configure DRAM size and organization
        LDR     W0, =DRAM_CONFIG_VALUE
        STR     W0, [X19, #DRAM_CONFIG_REG]
        
        // Enable DRAM controller
        MOV     W0, #0x1
        STR     W0, [X19, #DRAM_CTRL_ENABLE]
        
        // Perform DRAM training sequence
        BL      dram_training
        
        // Test DRAM connectivity
        BL      dram_test
        CMP     X0, #0
        B.NE    dram_init_failed
        
        LDP     X29, X30, [SP], #16
        RET

dram_init_failed:
        // Handle initialization failure
        // [Inference] Typically enters recovery mode or infinite loop
        B       .
```

**Example:**

```assembly
// Simple DRAM connectivity test
// Returns 0 in X0 if test passes, non-zero otherwise

dram_test:
        LDR     X0, =DRAM_BASE_ADDR
        LDR     X1, =DRAM_TEST_SIZE
        
        // Write test pattern
        MOV     X2, X0                      // Current address
        MOV     X3, #0x0
write_loop:
        // Create walking-ones pattern
        MOV     X4, #1
        LSL     X4, X4, X3
        STR     X4, [X2], #8
        
        ADD     X3, X3, #1
        AND     X3, X3, #0x3F               // Wrap at 64
        SUB     X1, X1, #8
        CBNZ    X1, write_loop
        
        // Read and verify pattern
        LDR     X0, =DRAM_BASE_ADDR
        LDR     X1, =DRAM_TEST_SIZE
        MOV     X3, #0x0
        
read_loop:
        MOV     X4, #1
        LSL     X4, X4, X3
        LDR     X5, [X0], #8
        
        CMP     X4, X5
        B.NE    test_failed
        
        ADD     X3, X3, #1
        AND     X3, X3, #0x3F
        SUB     X1, X1, #8
        CBNZ    X1, read_loop
        
        // Test passed
        MOV     X0, #0
        RET

test_failed:
        // Return error code indicating failure address
        MOV     X0, #1
        RET
```

