## Device Tree Handling


Modern ARM bootloaders pass hardware information to the kernel via Device Tree Blob (DTB).

**Example:**

```assembly
// Load and prepare device tree
// X0 = DTB load address
// Returns DTB address in X0

prepare_dtb:
        STP     X29, X30, [SP, #-32]!
        STP     X19, X20, [SP, #16]
        MOV     X29, SP
        
        MOV     X19, X0                     // Save DTB address
        
        // Verify DTB magic number (0xD00DFEED)
        LDR     W1, [X19]
        REV     W1, W1                      // DTB is big-endian
        LDR     W2, =0xD00DFEED
        CMP     W1, W2
        B.NE    dtb_invalid
        
        // Get DTB size
        LDR     W1, [X19, #4]
        REV     W1, W1
        MOV     W20, W1                     // Save size
        
        // Add bootloader-specific properties
        MOV     X0, X19
        BL      add_bootloader_props
        
        // Clean cache for DTB area
        MOV     X0, X19
        MOV     X1, X20
        BL      clean_cache_range
        
        MOV     X0, X19                     // Return DTB address
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #32
        RET

dtb_invalid:
        MOV     X0, #0                      // Return NULL
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #32
        RET
```

