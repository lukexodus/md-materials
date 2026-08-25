## Cache Management for DMA


Modules performing DMA must ensure cache coherency between CPU and device.

**Example:**

```assembly
// Flush cache for DMA buffer (CPU to device)
// X0 = virtual address
// X1 = size in bytes

dma_cache_flush:
        STP     X29, X30, [SP, #-32]!
        STP     X19, X20, [SP, #16]
        
        MOV     X19, X0                     // Start address
        ADD     X20, X0, X1                 // End address
        
        // Align to cache line size (assume 64 bytes)
        AND     X19, X19, #~63
        ADD     X20, X20, #63
        AND     X20, X20, #~63

flush_loop:
        // Clean and invalidate data cache line
        DC      CIVAC, X19
        ADD     X19, X19, #64
        CMP     X19, X20
        B.LT    flush_loop
        
        // Data synchronization barrier
        DSB     SY
        
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #32
        RET

// Invalidate cache for DMA buffer (device to CPU)
// X0 = virtual address
// X1 = size in bytes

dma_cache_invalidate:
        STP     X29, X30, [SP, #-32]!
        STP     X19, X20, [SP, #16]
        
        MOV     X19, X0
        ADD     X20, X0, X1
        
        // Align to cache line
        AND     X19, X19, #~63
        ADD     X20, X20, #63
        AND     X20, X20, #~63

inval_loop:
        // Invalidate data cache line
        DC      IVAC, X19
        ADD     X19, X19, #64
        CMP     X19, X20
        B.LT    inval_loop
        
        // Data synchronization barrier
        DSB     SY
        
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #32
        RET
```

