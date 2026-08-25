## Memory Management in Modules


Kernel modules must use kernel memory allocation functions and handle virtual-to-physical address translation.

**Example:**

```assembly
// Allocate DMA-capable memory buffer
// X0 = size in bytes
// Returns virtual address in X0, physical in X1

alloc_dma_buffer:
        STP     X29, X30, [SP, #-32]!
        STP     X19, X20, [SP, #16]
        MOV     X29, SP
        
        MOV     X19, X0                     // Save size
        
        // Call kmalloc with GFP_DMA flag
        MOV     X1, #0x00000001             // GFP_DMA flag
        BL      kmalloc
        CBZ     X0, alloc_failed
        
        MOV     X20, X0                     // Save virtual address
        
        // Get physical address
        BL      virt_to_phys
        MOV     X1, X0                      // Physical address in X1
        MOV     X0, X20                     // Virtual address in X0
        
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #32
        RET

alloc_failed:
        MOV     X0, #0
        MOV     X1, #0
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #32
        RET
```

