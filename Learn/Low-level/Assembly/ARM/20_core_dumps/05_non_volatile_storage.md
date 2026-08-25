## Non-Volatile Storage


Storing core dumps in flash or EEPROM for post-mortem analysis:

```assembly
// Write core dump to flash
    LDR     R0, =core_dump_buffer
    LDR     R1, =FLASH_COREDUMP_ADDR
    LDR     R2, =512                // Dump size
    
    // Unlock flash
    BL      flash_unlock
    
    // Erase sector
    LDR     R0, =FLASH_COREDUMP_SECTOR
    BL      flash_erase_sector
    
    // Write data
    LDR     R0, =core_dump_buffer
    LDR     R1, =FLASH_COREDUMP_ADDR
    LDR     R2, =512
    BL      flash_write
    
    // Lock flash
    BL      flash_lock
    
    // Set flag indicating valid dump
    LDR     R0, =FLASH_DUMP_VALID_FLAG
    LDR     R1, =0xDEADBEEF
    STR     R1, [R0]
```

