## Boot Process Overview


The typical ARM boot sequence follows these stages:

**Boot ROM (First-stage bootloader):**

- Executes from on-chip ROM immediately after reset
- Initializes minimal hardware (CPU core, internal RAM)
- Verifies and loads second-stage bootloader from external storage
- **[Inference]** Usually implemented by SoC vendor and immutable

**Second-stage bootloader (SPL/U-Boot SPL):**

- Initializes external DRAM
- Sets up clocks and critical peripherals
- Loads main bootloader into DRAM
- Size-constrained to fit in internal SRAM

**Main bootloader (U-Boot/GRUB):**

- Full-featured environment with filesystem support
- Loads kernel and device tree
- Provides boot menu and command interface
- Implements verified boot if required

