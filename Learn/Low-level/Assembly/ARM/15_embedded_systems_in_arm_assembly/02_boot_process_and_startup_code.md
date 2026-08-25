## Boot Process and Startup Code


The ARM boot sequence is hardware-defined and varies between Cortex-M and Cortex-A architectures. Understanding this sequence is critical for reliable system initialization.

**Cortex-M Boot Sequence:**

**Power-On Reset** When power is applied or reset is released, the processor reads two 32-bit values from memory address 0x00000000 (or remapped location):

- **Initial Stack Pointer (SP)**: Loaded from address 0x00000000
- **Reset Handler Address**: Loaded from address 0x00000004

The processor automatically loads these values, sets the stack pointer, and branches to the reset handler. This happens in hardware before any instruction executes.

**Reset Handler Execution** The reset handler is the first C-callable code. Standard operations include:

1. **Copy initialized data** from flash (.data section) to SRAM
2. **Zero-initialize BSS section** (uninitialized global/static variables)
3. **Initialize FPU** (if Cortex-M4F/M7F)
4. **Set up clock system** (PLL configuration, clock source selection)
5. **Call C library initialization** (if using newlib/standard library)
6. **Call main()** function

**Example** - Cortex-M startup code:

```assembly
.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

.global Reset_Handler
.type Reset_Handler, %function

Reset_Handler:
    @ Load stack pointer (already done by hardware, but shown for clarity)
    LDR r0, =_estack
    MOV sp, r0
    
    @ Copy .data section from flash to SRAM
    LDR r0, =_sdata        @ Destination start
    LDR r1, =_edata        @ Destination end
    LDR r2, =_sidata       @ Source start
    MOVS r3, #0
    B copy_data_check

copy_data_loop:
    LDR r4, [r2, r3]       @ Read from flash
    STR r4, [r0, r3]       @ Write to SRAM
    ADDS r3, r3, #4

copy_data_check:
    ADDS r4, r0, r3
    CMP r4, r1
    BCC copy_data_loop
    
    @ Zero-initialize .bss section
    LDR r0, =_sbss
    LDR r1, =_ebss
    MOVS r2, #0
    B clear_bss_check

clear_bss_loop:
    STR r2, [r0]
    ADDS r0, r0, #4

clear_bss_check:
    CMP r0, r1
    BCC clear_bss_loop
    
    @ Enable FPU (Cortex-M4F)
    LDR r0, =0xE000ED88    @ CPACR address
    LDR r1, [r0]
    ORR r1, r1, #(0xF << 20) @ Enable CP10 and CP11
    STR r1, [r0]
    DSB
    ISB
    
    @ Call system initialization
    BL SystemInit
    
    @ Call C library initialization
    BL __libc_init_array
    
    @ Call main
    BL main
    
    @ If main returns, loop forever
hang:
    B hang
```

**Cortex-A Boot Sequence:**

**Multiple Exception Levels** Cortex-A processors boot in privileged modes (often Supervisor mode on ARMv7-A or EL3 on ARMv8-A). The boot process is more complex:

1. **ROM bootloader** executes (manufacturer-provided)
2. **Secondary bootloader** (U-Boot, etc.) loads from flash/SD
3. **Kernel/application** loaded to DRAM
4. **MMU configuration** for virtual memory
5. **Cache enablement** (separate I-cache and D-cache)
6. **Jump to application** entry point

[Inference] Most production systems use multi-stage boot due to size limitations of on-chip ROM.

