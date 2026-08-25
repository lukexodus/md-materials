## DMA Operations


Direct Memory Access requires careful cache management and proper address translation.

**Example:**

```assembly
// Set up DMA transfer
// X0 = device structure
// X1 = source buffer (virtual address)
// X2 = size in bytes
// X3 = direction (0=to device, 1=from device)

setup_dma_transfer:
        STP     X29, X30, [SP, #-64]!
        STP     X19, X20, [SP, #16]
        STP     X21, X22, [SP, #32]
        STP     X23, X24, [SP, #48]
        MOV     X29, SP
        
        MOV     X19, X0                     // Device structure
        MOV     X20, X1                     // Source buffer
        MOV     X21, X2                     // Size
        MOV     X22, X3                     // Direction
        
        // Get device base address
        LDR     X23, [X19, #DEV_BASE_OFFSET]
        
        // Map buffer for DMA
        MOV     X0, X19
        MOV     X1, X20
        MOV     X2, X21
        MOV     X3, X22
        BL      dma_map_single
        CMN     X0, #1                      // Check for DMA_MAPPING_ERROR
        B.EQ    dma_map_failed
        
        MOV     X24, X0                     // Save DMA address
        
        // Configure DMA controller
        // Write source address
        STR     X24, [X23, #DMA_SRC_ADDR]
        
        // Write transfer size
        STR     W21, [X23, #DMA_SIZE]
        
        // Configure control register
        MOV     W0, #0
        ORR     W0, W0, #DMA_ENABLE
        CBZ     W22, write_direction
        ORR     W0, W0, #DMA_DIR_FROM_DEV
        
write_direction:
        ORR     W0, W0, #DMA_INT_ENABLE     // Enable completion interrupt
        STR     W0, [X23, #DMA_CTRL]
        
        // Ensure writes are visible to device
        DSB     SY
        
        // Start DMA transfer
        MOV     W0, #DMA_START
        STR     W0, [X23, #DMA_CMD]
        DSB     SY
        
        MOV     X0, #0                      // Success
        LDP     X23, X24, [SP, #48]
        LDP     X21, X22, [SP, #32]
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #64
        RET

dma_map_failed:
        MOV     X0, #-1
        LDP     X23, X24, [SP, #48]
        LDP     X21, X22, [SP, #32]
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #64
        RET

// DMA completion handler
dma_complete_handler:
        STP     X29, X30, [SP, #-32]!
        STP     X19, X20, [SP, #16]
        MOV     X29, SP
        
        MOV     X19, X0                     // Device structure
        
        // Get device base address
        LDR     X20, [X19, #DEV_BASE_OFFSET]
        
        // Read DMA status
        LDR     W0, [X20, #DMA_STATUS]
        
        // Check for errors
        TBNZ    W0, #DMA_ERROR_BIT, dma_error
        
        // Clear completion flag
        MOV     W1, #DMA_COMPLETE
        STR     W1, [X20, #DMA_STATUS]
        DSB     SY
        
        // Unmap DMA buffer
        LDR     X0, [X19, #DMA_ADDR_SAVE]
        LDR     X1, [X19, #DMA_SIZE_SAVE]
        LDR     X2, [X19, #DMA_DIR_SAVE]
        BL      dma_unmap_single
        
        // Notify completion
        MOV     X0, X19
        BL      complete_dma_transfer
        
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #32
        RET

dma_error:
        // Handle DMA error
        MOV     X0, X19
        BL      handle_dma_error
        
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #32
        RET
```

