## Translation Table Setup


Bootloaders must configure the MMU to enable caching and access control for different memory regions.

**Example:**

```assembly
// Set up identity-mapped translation tables for bootloader
// Creates 1GB sections for simplicity

setup_page_tables:
        STP     X29, X30, [SP, #-16]!
        
        // Get page table base
        LDR     X0, =__page_table_start
        
        // Clear page tables
        MOV     X1, #4096                   // 4KB table
        MOV     X2, X0
clear_tables:
        STP     XZR, XZR, [X2], #16
        SUB     X1, X1, #16
        CBNZ    X1, clear_tables
        
        // Set up MAIR_EL3
        BL      setup_mair
        
        // Create level 1 table entries (1GB blocks)
        LDR     X0, =__page_table_start
        
        // Entry 0: Device memory (0x0000_0000 - 0x3FFF_FFFF)
        MOV     X1, #0x00000000
        ORR     X1, X1, #0x1                // Valid
        ORR     X1, X1, #(0x0 << 2)         // AttrIndx = 0 (Device)
        ORR     X1, X1, #(0x1 << 10)        // AF = 1
        ORR     X1, X1, #(0x1 << 54)        // UXN
        ORR     X1, X1, #(0x1 << 53)        // PXN
        STR     X1, [X0], #8
        
        // Entry 1: Normal memory (0x4000_0000 - 0x7FFF_FFFF)
        MOV     X1, #0x40000000
        ORR     X1, X1, #0x1                // Valid
        ORR     X1, X1, #(0x1 << 2)         // AttrIndx = 1 (Normal)
        ORR     X1, X1, #(0x3 << 8)         // Inner shareable
        ORR     X1, X1, #(0x1 << 10)        // AF = 1
        STR     X1, [X0], #8
        
        // Entry 2: DRAM (0x8000_0000 - 0xBFFF_FFFF)
        MOV     X1, #0x80000000
        ORR     X1, X1, #0x1
        ORR     X1, X1, #(0x1 << 2)         // Normal memory
        ORR     X1, X1, #(0x3 << 8)         // Inner shareable
        ORR     X1, X1, #(0x1 << 10)        // AF = 1
        STR     X1, [X0], #8
        
        // Configure TCR_EL3
        MOV     X1, #0x0
        ORR     X1, X1, #(0x1 << 20)        // TBI (Top Byte Ignore)
        ORR     X1, X1, #(25 << 0)          // T0SZ = 25 (39-bit address space)
        ORR     X1, X1, #(0x0 << 14)        // TG0 = 4KB granule
        ORR     X1, X1, #(0x3 << 12)        // SH0 = Inner shareable
        ORR     X1, X1, #(0x1 << 10)        // ORGN0 = Write-back write-alloc
        ORR     X1, X1, #(0x1 << 8)         // IRGN0 = Write-back write-alloc
        MSR     TCR_EL3, X1
        
        // Set TTBR0_EL3
        LDR     X1, =__page_table_start
        MSR     TTBR0_EL3, X1
        ISB
        
        LDP     X29, X30, [SP], #16
        RET

setup_mair:
        // MAIR0: Device-nGnRnE
        // MAIR1: Normal memory, write-back cacheable
        MOV     X0, #0x00                   // Device-nGnRnE
        ORR     X0, X0, #(0xFF << 8)        // Normal WB
        MSR     MAIR_EL3, X0
        RET
```

