## Linker Scripts and Memory Placement

### Overview

A linker script is a text file that instructs the linker how to combine compiled object files into a final executable image — specifically, how to map input sections (`.text`, `.data`, `.bss`, etc.) from object files onto the physical memory regions of the target device, and what addresses symbols should resolve to. In embedded/bare-metal development, the linker script is not optional boilerplate; it is the mechanism that determines where code executes from, where variables live, and how startup code initializes RAM — errors here produce binaries that compile and link successfully but fail to run, or fail intermittently, on real hardware.

### Why Embedded Systems Need Explicit Linker Scripts

- Bare-metal targets have no operating system or loader to allocate memory dynamically at load time; every region of flash and RAM must be explicitly assigned at link time.
- A microcontroller typically has multiple distinct physical memory types at different addresses: on-chip flash (program storage, non-volatile), on-chip SRAM (working memory, volatile), sometimes CCM/TCM (tightly-coupled memory with different access latency), and memory-mapped peripheral registers.
- The reset/startup sequence must know exactly where the initial stack pointer is, where the vector table lives (frequently must be at a fixed, hardware-mandated address), and how to copy initialized-data values from flash into RAM before `main()` runs.
- Without a correctly configured linker script, code may link to addresses the physical hardware doesn't have, or may overlap regions that must not overlap (e.g., stack growing into `.bss`).

### GNU LD Linker Script Structure (GCC-based toolchains)

The most common linker script format in embedded GCC toolchains (arm-none-eabi-gcc, etc.) is GNU `ld` script syntax, typically given a `.ld` extension and passed via `-T script.ld`.

#### MEMORY Command

Declares the physical memory regions available on the target, each with an origin address and length.



```
MEMORY
{
    FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 512K
    RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 128K
}
```

- The region name (`FLASH`, `RAM`) is arbitrary but referenced later in the `SECTIONS` block.
- The attribute letters (`r` readable, `w` writable, `x` executable) document intended usage; `ld` **[Unverified]** does not strictly enforce these at link time on all targets in the way a runtime MPU would — they primarily serve documentation and certain linker warning/placement heuristics, not hardware-level protection, which is a separate mechanism (MPU/MMU configuration).
- The `ORIGIN` and `LENGTH` values must match the actual silicon's memory map, taken from the microcontroller's reference manual/datasheet — a mismatch here does not necessarily produce a link error if the mismatch is still within valid address space, but produces a binary that will fault or corrupt memory on real hardware.

#### SECTIONS Command

Maps input sections from object files to output sections, and assigns those output sections to memory regions defined above.



```
SECTIONS
{
    .text :
    {
        KEEP(*(.isr_vector))
        *(.text)
        *(.text*)
        *(.rodata)
        *(.rodata*)
    } > FLASH

    .data :
    {
        _sdata = .;
        *(.data)
        *(.data*)
        _edata = .;
    } > RAM AT> FLASH

    .bss :
    {
        _sbss = .;
        *(.bss)
        *(.bss*)
        *(COMMON)
        _ebss = .;
    } > RAM
}
```

Key elements:

- `*(.text)` collects the `.text` section (executable code) from every input object file (`*` is a wildcard over input files).
- `KEEP(*(.isr_vector))` prevents the linker's garbage collection (`--gc-sections`) from discarding the interrupt vector table, which appears unreferenced from the linker's perspective but is required by hardware at a fixed address.
- `> FLASH` assigns the output section's load address (VMA/LMA, discussed below) into the `FLASH` region.
- `AT> FLASH` on the `.data` section is critical: it means the section's *virtual* address (where it's accessed from at runtime) is in `RAM`, but its *load* address (where its initial values are stored in the binary image) is in `FLASH`. This is what enables startup code to copy initial values from flash into RAM.
- Symbols like `_sdata`, `_edata`, `_sbss`, `_ebss` are defined directly in the linker script and referenced by name from the C startup code, giving the startup routine the addresses it needs to perform the flash-to-RAM copy and BSS zeroing.

### VMA vs. LMA: The Core Concept for Flash-Resident, RAM-Executing Data

This distinction is the single most important and most commonly misunderstood concept in embedded linker scripts:

- **LMA (Load Memory Address)**: where a section's bytes physically reside in the flash image as programmed onto the device.
- **VMA (Virtual/Run Memory Address)**: where the section is accessed from during program execution.

For `.text` (code), VMA and LMA are typically the same address — code executes directly from flash on most microcontrollers (execute-in-place). For `.data` (initialized global/static variables), VMA and LMA *must* differ: the variable needs to be in RAM at runtime (since it's writable), but its initial value must be stored in flash (since flash is what persists across power cycles) and copied into RAM during startup.

===MERMAID_DIAGRAM===

flowchart LR

subgraph Flash[Flash Memory - LMA]

A[".text code"]

B[".data initial values"]

C[".rodata constants"]

end

subgraph RAM[SRAM - VMA]

D[".data runtime copy"]

E[".bss zero-initialized"]

F["stack and heap"]

end

B -->|"startup code copies"| D

A -.executes in place.-> A

### The .bss Section and Zero Initialization

`.bss` holds zero-initialized and uninitialized global/static variables. It has no corresponding data in the flash image at all — including its actual content would waste flash space storing zeros. Instead, the linker script only records its start and end addresses in RAM, and startup code explicitly zeroes that memory range before `main()` executes.

```c
/* Placed in .bss: no initializer, or explicit zero initializer */
static uint32_t sensor_buffer[64];
static int error_count = 0;

/* Placed in .data: non-zero initializer, requires flash storage
   and a startup-time copy into RAM */
static int32_t calibration_offset = 100;
```

### Startup Code: Connecting the Linker Script to C Runtime Initialization

The linker script defines symbols; the startup assembly/C code (commonly `startup_<device>.s` or `startup_<device>.c`, often vendor-supplied) uses them to perform the actual copy and zero operations before `main()` is called.

```c
/* Simplified conceptual startup sequence, referencing symbols
   defined by the linker script */
extern uint32_t _sdata, _edata, _sidata; /* _sidata = LMA start in flash */
extern uint32_t _sbss, _ebss;

void Reset_Handler(void) {
    uint32_t *src = &_sidata;
    uint32_t *dst = &_sdata;
    while (dst < &_edata) {
        *dst++ = *src++;
    }
    dst = &_sbss;
    while (dst < &_ebss) {
        *dst++ = 0;
    }
    main();
}
```

**[Inference]** A linker script and its corresponding startup code are tightly coupled and must agree on symbol names exactly; a common source of hard-to-diagnose bring-up failures is a mismatch between the symbol names a vendor-supplied startup file expects and the symbol names an engineer's custom linker script actually defines, since this is typically not caught as a link error if the names simply don't match and the startup code silently uses garbage/zero values instead.

### The Interrupt Vector Table Placement

Most ARM Cortex-M targets require the vector table to reside at a fixed, architecturally-mandated address (commonly the very start of flash, address `0x00000000` or `0x08000000` depending on boot configuration), because the hardware reads the initial stack pointer and reset vector directly from that location on power-up/reset, before any software has executed.



```
SECTIONS
{
    .isr_vector :
    {
        KEEP(*(.isr_vector))
    } > FLASH
    /* Must be the first section placed in FLASH */

    .text :
    {
        *(.text)
    } > FLASH
}
```

Getting this placement wrong — or allowing the linker's section garbage collection to discard the seemingly-unreferenced vector table — typically results in a device that fails to boot at all, since the CPU loads an invalid or stale stack pointer/reset address on power-up.

### Stack and Heap Placement

The linker script commonly defines the top-of-stack address (often the end of RAM, since the ARM Cortex-M stack grows downward) and may reserve space for a heap if dynamic allocation is used (though MISRA-oriented and many safety-critical embedded projects avoid heap allocation entirely, as noted in prior MISRA C content).



```
_estack = ORIGIN(RAM) + LENGTH(RAM); /* top of RAM, stack grows down */

.heap :
{
    . = ALIGN(8);
    _sheap = .;
    . = . + 0x400; /* reserve 1KB, example only */
    _eheap = .;
} > RAM
```

**[Inference]** Without explicit stack/heap size reservation and boundary checking, stack overflow (stack growing downward into `.bss`/`.data`, or into a heap region growing upward) is a real and notoriously hard-to-diagnose failure mode on microcontrollers, since there is typically no MMU-backed guard page to fault on overflow the way there often is on a general-purpose OS; some toolchains/linker scripts add an explicit `.stack` section with a defined size specifically so a link-time or runtime check can catch overflow before it silently corrupts adjacent memory. Vendor-supplied linker scripts and RTOS ports frequently differ in exactly how they express this reservation.

### Placing Specific Functions or Data at Custom Locations

Linker scripts and compiler section attributes together allow explicit placement of specific symbols outside the default flow — commonly used for:

- **Fast/tightly-coupled memory (TCM/CCM)**: performance-critical functions or ISR handlers placed in low-latency RAM rather than flash, using a custom section plus a `KEEP`/placement rule.
- **Bootloader/application partitioning**: reserving a fixed flash region for a bootloader, with the application linked to start at a fixed offset beyond it, and vice versa — essential for any project with in-field firmware update capability.
- **Non-volatile configuration storage**: a specific flash sector reserved (and excluded from normal code/data placement) for calibration data or settings that must survive firmware updates.

```c
/* Compiler attribute marks the function for a custom section */
__attribute__((section(".ramfunc")))
void critical_isr_handler(void) {
    /* placed in fast RAM instead of flash */
}
```



```
SECTIONS
{
    .ramfunc :
    {
        _sramfunc = .;
        *(.ramfunc)
        _eramfunc = .;
    } > RAM AT> FLASH
    /* Requires the same copy-at-startup treatment as .data,
       since the code must be relocated from flash to RAM */
}
```

**[Inference]** Since `.ramfunc`-style sections use the same VMA/LMA split as `.data`, they require an additional explicit copy loop in startup code beyond the default `.data`/`.bss` handling — this is easy to forget when adding such a section to an existing project, resulting in a jump to uninitialized/stale RAM content.

### Symbol Export for C Code Access

Any address defined purely within the linker script (region boundaries, section start/end markers) must be explicitly declared `extern` in C to be usable — the linker script symbol itself has no type; its *address* is what C code accesses via the `&` operator, not its value.

```c
extern uint32_t _sdata;   /* address of _sdata is what matters,
                              not treating it as a uint32_t value */
uint32_t *data_start = &_sdata;
```

**[Inference]** A frequent beginner error is referencing a linker-script-defined symbol as `_sdata` directly (as if it were a variable holding a value) rather than `&_sdata` (the address the linker assigned to that symbol) — since the symbol has no actual storage or type, dereferencing this mistake produces undefined/garbage behavior rather than a compile error in many cases.

### Common Linker Script Errors and Symptoms

| Symptom | Likely Cause |
| --- | --- |
| Device fails to boot at all / no output | Vector table not at required fixed address, or discarded by `--gc-sections` without `KEEP` |
| Global variables have wrong/garbage initial values | `.data` VMA/LMA copy missing or symbol name mismatch between linker script and startup code |
| Static/global variables not zero as expected | `.bss` zeroing loop missing or symbol mismatch |
| Link succeeds but binary doesn't fit / silent overflow | `MEMORY` region `LENGTH` doesn't match actual silicon, or region overflow not caught |
| Random corruption after deep call stacks or heavy stack use | No stack size reservation/checking; stack colliding with `.bss`/heap |
| Code works after flashing but breaks after firmware update via bootloader | Application linked at wrong flash offset relative to bootloader partition |
| Function crashes only when called from certain contexts | Function intended for `.ramfunc`/TCM placement executing from flash unexpectedly, or vice versa, due to missing custom-section copy step |

### Vendor-Supplied vs. Custom Linker Scripts

Most microcontroller vendors (STMicroelectronics, NXP, Microchip, etc.) ship a default linker script with their SDK/HAL that correctly encodes the part's memory map and standard section layout. **[Inference]** Starting from and modifying the vendor-supplied script, rather than writing one from scratch, is generally the safer approach for most projects, since the `MEMORY` region values and vector table placement are the parts most likely to be device-specific and easy to get subtly wrong; custom placement (TCM functions, bootloader partitioning, reserved config sectors) is then layered on top of that known-correct baseline.

### Verifying Linker Script Output

After linking, the resulting placement can and generally should be verified against the intended layout rather than assumed correct:

- `arm-none-eabi-size` (or equivalent for the target) reports the size of `.text`, `.data`, `.bss` and confirms the binary fits within the declared `MEMORY` regions.
- `arm-none-eabi-objdump -h` or `-t` lists section headers and symbol addresses, allowing direct confirmation that sections landed at expected addresses.
- `arm-none-eabi-nm` lists all symbols with their resolved addresses, useful for confirming linker-script-defined symbols (`_sdata`, `_estack`, etc.) resolved to sane values within the target's actual memory map.
- A generated `.map` file (via `-Wl,-Map=output.map`) gives a full, human-readable account of every section and symbol placement decision the linker made, and is the primary diagnostic artifact when placement behaves unexpectedly.

### Linker Script to Runtime Memory Layout Flow

===MERMAID_DIAGRAM===

flowchart TD

A[".ld linker script:\nMEMORY + SECTIONS"] --> B[Linker places sections,\ndefines boundary symbols]

B --> C[".elf/.bin/.hex output\nwith flash image"]

C --> D[Startup code runs\non reset]

D --> E["Copy .data:\nFLASH LMA to RAM VMA"]

D --> F["Zero .bss in RAM"]

D --> G["Set initial SP from\nvector table / _estack"]

E --> H["Call main()"]

F --> H

G --> H

**Related Topics**

- Bootloader design and flash partitioning for in-field firmware updates
- MPU (Memory Protection Unit) configuration for runtime memory access enforcement
- ELF file format internals and section/segment structure
- RTOS memory pool and stack-per-task allocation strategies
- Debugging with `.map` files and `objdump`/`nm` for post-link verification
- Placing and protecting non-volatile configuration/calibration data in flash
- Startup code (`Reset_Handler`) design across different vendor SDKs