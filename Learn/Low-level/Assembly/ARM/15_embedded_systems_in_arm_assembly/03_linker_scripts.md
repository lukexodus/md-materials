## Linker Scripts


Linker scripts are text files that instruct the linker how to organize compiled object files into the final executable. They define memory regions, section placement, and symbol creation.

**Memory Definition:**

The `MEMORY` command defines available memory regions with their base addresses and sizes:

```ld
MEMORY
{
    FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 512K
    SRAM (rwx)  : ORIGIN = 0x20000000, LENGTH = 128K
}
```

Attributes: `r` (read), `w` (write), `x` (execute), `a` (allocatable), `i` (initialized).

**Section Definitions:**

The `SECTIONS` command places code/data sections into memory regions:

**Example** - Complete linker script for Cortex-M:

```ld
/* Entry point */
ENTRY(Reset_Handler)

/* Highest address of the user mode stack */
_estack = ORIGIN(SRAM) + LENGTH(SRAM);

/* Minimum heap size */
_Min_Heap_Size = 0x200;
_Min_Stack_Size = 0x400;

MEMORY
{
    FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 512K
    SRAM (rwx)  : ORIGIN = 0x20000000, LENGTH = 128K
}

SECTIONS
{
    /* Vector table must be at start of flash */
    .isr_vector :
    {
        . = ALIGN(4);
        KEEP(*(.isr_vector))
        . = ALIGN(4);
    } >FLASH
    
    /* Program code */
    .text :
    {
        . = ALIGN(4);
        *(.text)           /* .text sections (code) */
        *(.text*)          /* .text* sections (code) */
        *(.glue_7)         /* ARM/Thumb interworking */
        *(.glue_7t)
        *(.eh_frame)
        
        KEEP(*(.init))
        KEEP(*(.fini))
        
        . = ALIGN(4);
        _etext = .;        /* End of code section */
    } >FLASH
    
    /* Read-only data */
    .rodata :
    {
        . = ALIGN(4);
        *(.rodata)
        *(.rodata*)
        . = ALIGN(4);
    } >FLASH
    
    /* ARM exception unwinding */
    .ARM.extab :
    {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    } >FLASH
    
    .ARM.exidx :
    {
        __exidx_start = .;
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
        __exidx_end = .;
    } >FLASH
    
    /* Used by startup to initialize data */
    _sidata = LOADADDR(.data);
    
    /* Initialized data goes to SRAM, loaded from FLASH */
    .data :
    {
        . = ALIGN(4);
        _sdata = .;        /* Start of data section */
        *(.data)
        *(.data*)
        
        . = ALIGN(4);
        _edata = .;        /* End of data section */
    } >SRAM AT>FLASH
    
    /* Uninitialized data section */
    .bss :
    {
        . = ALIGN(4);
        _sbss = .;
        __bss_start__ = _sbss;
        *(.bss)
        *(.bss*)
        *(COMMON)
        
        . = ALIGN(4);
        _ebss = .;
        __bss_end__ = _ebss;
    } >SRAM
    
    /* Heap and stack */
    ._user_heap_stack :
    {
        . = ALIGN(8);
        PROVIDE(end = .);
        PROVIDE(_end = .);
        . = . + _Min_Heap_Size;
        . = . + _Min_Stack_Size;
        . = ALIGN(8);
    } >SRAM
    
    /* Remove debug sections */
    /DISCARD/ :
    {
        libc.a (*)
        libm.a (*)
        libgcc.a (*)
    }
}
```

**Key Concepts:**

**LMA vs VMA**

- **Load Memory Address (LMA)**: Where section is stored in flash
- **Virtual Memory Address (VMA)**: Where section runs in SRAM

The `.data` section has different LMA (FLASH) and VMA (SRAM). Startup code copies from LMA to VMA.

**KEEP Directive** Prevents linker from removing sections during garbage collection (`--gc-sections`). Critical for vector tables and initialization code.

**Symbol Creation** `_sdata`, `_edata`, `_sbss`, `_ebss` are symbols used by startup code to know where sections begin and end.

