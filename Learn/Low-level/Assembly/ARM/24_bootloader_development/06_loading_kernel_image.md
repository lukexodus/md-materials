## Loading Kernel Image


The bootloader must read the kernel from storage (SD card, eMMC, flash) and load it into memory.

**Example:**

```assembly
// Load kernel from storage device
// X0 = storage device base address
// X1 = kernel load address in DRAM
// X2 = kernel size in bytes

load_kernel:
        STP     X29, X30, [SP, #-48]!
        STP     X19, X20, [SP, #16]
        STP     X21, X22, [SP, #32]
        MOV     X29, SP
        
        MOV     X19, X0                     // Storage device base
        MOV     X20, X1                     // Load address
        MOV     X21, X2                     // Size
        
        // Initialize storage device
        MOV     X0, X19
        BL      storage_init
        CBNZ    X0, load_failed
        
        // Read kernel image
        MOV     X0, X19                     // Device base
        MOV     X1, #KERNEL_STORAGE_OFFSET  // Offset in storage
        MOV     X2, X20                     // Destination
        MOV     X3, X21                     // Size
        BL      storage_read
        CBNZ    X0, load_failed
        
        // Verify kernel signature/checksum
        MOV     X0, X20
        MOV     X1, X21
        BL      verify_kernel
        CBNZ    X0, verification_failed
        
        // Clean cache to ensure kernel is in DRAM
        MOV     X0, X20
        MOV     X1, X21
        BL      clean_cache_range
        
        MOV     X0, #0                      // Success
        LDP     X21, X22, [SP, #32]
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #48
        RET

load_failed:
        MOV     X0, #1                      // Error code
        LDP     X21, X22, [SP, #32]
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #48
        RET

verification_failed:
        MOV     X0, #2                      // Verification error
        LDP     X21, X22, [SP, #32]
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #48
        RET
```

