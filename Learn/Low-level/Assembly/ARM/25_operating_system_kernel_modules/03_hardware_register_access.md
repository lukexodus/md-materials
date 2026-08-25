## Hardware Register Access


Modules that control hardware must perform memory-mapped I/O with proper barriers and cache maintenance.

**Example:**

```assembly
// Read from memory-mapped hardware register
// X0 = register address
// Returns value in X0

hw_read_reg:
        // Use load-acquire to ensure ordering
        LDAR    W0, [X0]
        RET

// Write to memory-mapped hardware register
// X0 = register address
// X1 = value to write

hw_write_reg:
        // Use store-release to ensure ordering
        STLR    W1, [X0]
        
        // Data synchronization barrier
        DSB     SY
        
        RET

// Read-modify-write operation on hardware register
// X0 = register address
// X1 = bits to set
// X2 = bits to clear

hw_rmw_reg:
        STP     X29, X30, [SP, #-32]!
        STP     X19, X20, [SP, #16]
        
        MOV     X19, X0                     // Save address
        MOV     X20, X1                     // Save set mask
        
        // Read current value
        LDAR    W0, [X19]
        
        // Clear specified bits
        BIC     W0, W0, W2
        
        // Set specified bits
        ORR     W0, W0, W20
        
        // Write back
        STLR    W0, [X19]
        DSB     SY
        
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #32
        RET
```

