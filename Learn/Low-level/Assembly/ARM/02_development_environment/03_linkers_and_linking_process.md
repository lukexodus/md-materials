## Linkers and Linking Process


### Linker Basics

The linker combines object files and libraries into a final executable, resolving symbols and organizing memory layout.

**GNU Linker (ld) Invocation:**

```bash
# Basic linking
arm-none-eabi-ld -o program.elf file1.o file2.o -T linker_script.ld

# Common options
-T script.ld    # Use linker script
-Map=output.map # Generate map file
-nostdlib       # Don't link standard libraries
--gc-sections   # Remove unused sections
-L/path         # Add library search path
-lfoo           # Link library libfoo.a
```

**Linking Process Stages:**

1. **Symbol Resolution**: Match symbol references with definitions
2. **Relocation**: Adjust addresses based on final memory layout
3. **Section Merging**: Combine similar sections from multiple files
4. **Memory Allocation**: Assign final addresses according to linker script

### Linker Scripts

Linker scripts control memory layout and section placement.

**Basic Structure:**

```ld
/* Memory regions definition */
MEMORY
{
    FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 256K
    RAM (rwx)   : ORIGIN = 0x20000000, LENGTH = 64K
}

/* Entry point */
ENTRY(Reset_Handler)

/* Section definitions */
SECTIONS
{
    /* Vector table in Flash */
    .isr_vector :
    {
        . = ALIGN(4);
        KEEP(*(.isr_vector))
        . = ALIGN(4);
    } >FLASH

    /* Code section */
    .text :
    {
        . = ALIGN(4);
        *(.text)
        *(.text*)
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

    /* Initialized data - Load address in FLASH, runtime in RAM */
    .data :
    {
        . = ALIGN(4);
        _sdata = .;        /* Start of data in RAM */
        *(.data)
        *(.data*)
        . = ALIGN(4);
        _edata = .;        /* End of data in RAM */
    } >RAM AT>FLASH
    
    _sidata = LOADADDR(.data);  /* Load address in FLASH */

    /* Uninitialized data */
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
    } >RAM

    /* Stack section */
    ._user_heap_stack :
    {
        . = ALIGN(8);
        PROVIDE (end = .);
        PROVIDE (_end = .);
        . = . + 0x400;     /* Heap size */
        . = . + 0x800;     /* Stack size */
        . = ALIGN(8);
    } >RAM
}
```

**Advanced Linker Script Features:**

```ld
/* Define symbols */
_stack_size = 0x1000;
_heap_size = 0x800;

/* Alignment functions */
. = ALIGN(4);           /* Align to 4 bytes */
. = ALIGN(. != 0 ? 4 : 1);  /* Conditional alignment */

/* Fill unused memory */
.text :
{
    *(.text)
    FILL(0xFF)          /* Fill with 0xFF */
} >FLASH

/* Assertions */
ASSERT(_edata < 0x20010000, "Data section overflow")
ASSERT((_ebss - _sbss) < 0x4000, "BSS too large")

/* Keep sections from garbage collection */
KEEP(*(.isr_vector))
KEEP(*(.init))
KEEP(*(.fini))

/* Discard sections */
/DISCARD/ :
{
    *(.note.GNU-stack)
    *(.gnu_debuglink)
    *(.comment)
}
```

### Symbol Resolution

**Symbol Types:**

- **Global symbols**: Visible across all files (`.global` directive)
- **Local symbols**: Visible within single file only
- **Weak symbols**: Can be overridden by strong symbols (`.weak` directive)
- **Common symbols**: Uninitialized global variables

**Symbol Visibility:**

```assembly
.global _start      # Export symbol
.weak weak_func     # Weak symbol
.local local_var    # Local symbol (not exported)
.hidden hidden_sym  # Hidden from dynamic linking
```

**Weak Symbol Example:**

```assembly
# Default implementation (weak)
.weak default_handler
.type default_handler, %function
default_handler:
    b default_handler    # Infinite loop

# Strong implementation overrides weak
.global irq_handler
.type irq_handler, %function
irq_handler:
    push {lr}
    bl handle_interrupt
    pop {pc}
```

### Relocation

Relocation adjusts addresses after final memory layout is determined.

**Relocation Types:**

- `R_ARM_ABS32`: Absolute 32-bit address
- `R_ARM_REL32`: PC-relative 32-bit offset
- `R_ARM_THM_CALL`: Thumb branch relocation
- `R_ARM_THM_JUMP24`: Thumb long jump

**Viewing Relocations:**

```bash
# Display relocation entries
arm-none-eabi-objdump -r file.o

# Example output:
# RELOCATION RECORDS FOR [.text]:
# OFFSET   TYPE              VALUE
# 00000004 R_ARM_THM_CALL    function
# 0000000c R_ARM_ABS32       variable
```

### Map Files

Map files show the final memory layout and symbol addresses.

```bash
# Generate map file
arm-none-eabi-ld -Map=output.map -o program.elf file.o

# Map file contents include:
# - Memory configuration
# - Section addresses and sizes
# - Symbol table with addresses
# - Cross-reference table
```

**Map File Sections:**

```
Memory Configuration:
Name    Origin      Length      Attributes
FLASH   0x08000000  0x00040000  xr
RAM     0x20000000  0x00010000  xrw

Linker script and memory map:
.text           0x08000000     0x1234
 *(.text)
 .text          0x08000000      0x100 file1.o
                0x08000000      _start
                0x08000020      main
```

