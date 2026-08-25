## MMU Enablement


**Example:**

```assembly
// Enable MMU and caches
enable_mmu:
        // Ensure all prior operations complete
        DSB     SY
        ISB
        
        // Invalidate TLB
        TLBI    ALLE3
        DSB     SY
        ISB
        
        // Enable MMU and caches
        MRS     X0, SCTLR_EL3
        ORR     X0, X0, #(1 << 0)           // M bit - Enable MMU
        ORR     X0, X0, #(1 << 2)           // C bit - Enable data cache
        ORR     X0, X0, #(1 << 12)          // I bit - Enable instruction cache
        MSR     SCTLR_EL3, X0
        ISB
        
        RET
```

