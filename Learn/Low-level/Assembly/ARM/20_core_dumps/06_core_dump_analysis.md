## Core Dump Analysis


Reading and interpreting stored dumps on next boot:

```assembly
// Check for core dump on startup
startup_check_dump:
    PUSH    {LR}
    
    // Check validity flag
    LDR     R0, =FLASH_DUMP_VALID_FLAG
    LDR     R1, [R0]
    LDR     R2, =0xDEADBEEF
    CMP     R1, R2
    BNE     no_dump_found
    
    // Valid dump exists
    LDR     R0, =FLASH_COREDUMP_ADDR
    BL      analyze_core_dump
    
    // Clear flag
    LDR     R0, =FLASH_DUMP_VALID_FLAG
    MOV     R1, #0
    STR     R1, [R0]
    
no_dump_found:
    POP     {PC}

analyze_core_dump:
    PUSH    {R4, LR}
    MOV     R4, R0                  // Dump address
    
    // Extract PC at fault
    LDR     R0, [R4, #24]           // PC offset in stack frame
    BL      log_fault_pc
    
    // Extract fault status
    LDR     R0, [R4, #64]           // CFSR offset
    BL      decode_fault_status
    
    // Extract fault address if applicable
    LDR     R0, [R4, #72]           // MMFAR offset
    BL      log_fault_address
    
    POP     {R4, PC}
```

