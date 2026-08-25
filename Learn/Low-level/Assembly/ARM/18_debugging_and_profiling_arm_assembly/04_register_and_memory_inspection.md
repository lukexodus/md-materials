## Register and Memory Inspection


Debug interfaces provide full access to processor registers and memory, even while the processor is halted. This enables complete system state inspection.

**Cortex-M Debug Registers:**

**DHCSR (Debug Halting Control and Status Register):** Shows current debug state and controls halting:

```
Bits [31:16]: Debug key (0xA05F for writes)
Bit 25: S_RESET_ST - Reset status
Bit 24: S_RETIRE_ST - Instruction retired
Bit 19: S_LOCKUP - Processor in lockup
Bit 18: S_SLEEP - Processor sleeping
Bit 17: S_HALT - Processor halted
Bit 16: S_REGRDY - Register read/write available
Bit 3: C_MASKINTS - Mask interrupts when stepping
Bit 2: C_STEP - Single-step
Bit 1: C_HALT - Halt request
Bit 0: C_DEBUGEN - Debug enabled
```

**DCRSR (Debug Core Register Selector):** Selects which register to read/write via DCRDR:

```
Bit 16: REGWnR - 1=write, 0=read
Bits [4:0]: REGSEL - Register number
```

Register numbers:

- 0-12: R0-R12
- 13: SP (current stack pointer)
- 14: LR
- 15: PC
- 16: xPSR (combined program status)
- 17: MSP (Main Stack Pointer)
- 18: PSP (Process Stack Pointer)
- 20: CONTROL/FAULTMASK/BASEPRI/PRIMASK

**DCRDR (Debug Core Register Data):** Holds register value for transfer:

**Example** - Reading R0:

```c
// Select R0 for read
DCRSR = 0;  // REGWnR=0 (read), REGSEL=0 (R0)

// Wait for ready
while (!(DHCSR & 0x00010000));

// Read value from DCRDR
uint32_t r0_value = DCRDR;
```

**Example** - Writing to PC:

```c
// Write new PC value
DCRDR = 0x08001000;

// Select PC for write
DCRSR = 0x0001000F;  // REGWnR=1 (write), REGSEL=15 (PC)

// Wait for complete
while (!(DHCSR & 0x00010000));
```

**GDB Register Inspection:**

```gdb
# Display all general-purpose registers
info registers

# Display specific register
print $r0
p/x $r0          # Hexadecimal format
p/d $r0          # Decimal format
p/t $r0          # Binary format

# Display special registers
info all-registers
print $sp
print $pc
print $cpsr      # Program status register (Cortex-A)
print $xpsr      # Combined status register (Cortex-M)

# Modify register
set $r0 = 0x1234
set $pc = main
```

**CPSR/xPSR Flags:**

On Cortex-A (CPSR) and Cortex-M (xPSR), the status register contains condition flags:

```
Bit 31: N - Negative flag
Bit 30: Z - Zero flag
Bit 29: C - Carry flag
Bit 28: V - Overflow flag
Bit 27: Q - Saturation flag
Bits [15:10]: ICI/IT - If-Then state (Thumb)
Bit 9: E - Endianness (Cortex-A)
Bit 24: T - Thumb state (Cortex-A)
Bits [8:0]: Exception number (Cortex-M)
```

**Example** - Checking flags in GDB:

```gdb
# Display status register
print $xpsr

# Check if zero flag is set
print ($xpsr & (1 << 30)) != 0
```

**Memory Inspection:**

**Direct Memory Access:** Debug interfaces access memory through the AHB-AP (AHB Access Port) or APB-AP, bypassing the processor core.

**GDB Memory Commands:**

```gdb
# Examine memory
x/nfu address

# n = count
# f = format (x=hex, d=decimal, u=unsigned, o=octal, t=binary, a=address, c=char, s=string)
# u = unit size (b=byte, h=halfword, w=word, g=giant 8 bytes)

# Examples:
x/16wx 0x20000000    # 16 words in hex starting at 0x20000000
x/32xb 0x08000000    # 32 bytes in hex
x/10i $pc            # 10 instructions at PC
x/s 0x20001000       # String at address

# Display array
x/10dw array_name

# Write memory
set *((uint32_t*)0x20000100) = 0x12345678
set {unsigned int}0x20000100 = 0x12345678
```

**Memory Regions:**

Understanding memory regions is critical for correct debugging:

**Cortex-M Memory Map:**

```
0x00000000 - 0x1FFFFFFF: Code (512MB)
0x20000000 - 0x3FFFFFFF: SRAM (512MB)
0x40000000 - 0x5FFFFFFF: Peripheral (512MB)
0x60000000 - 0x9FFFFFFF: External RAM (1GB)
0xA0000000 - 0xDFFFFFFF: External device (1GB)
0xE0000000 - 0xE00FFFFF: Private peripheral bus
0xE0100000 - 0xFFFFFFFF: System (vendor-specific)
```

**Example** - Inspecting stack:

```gdb
# Display current stack pointer
print $sp

# Show stack contents (32 words)
x/32wx $sp

# Display stack frame
info frame

# Show all stack frames
backtrace
bt
```

**Peripheral Register Inspection:**

Memory-mapped peripheral registers can be examined like any memory:

```gdb
# Define peripheral base
set $GPIOA_BASE = 0x40020000

# Read GPIO input data register
x/1wx ($GPIOA_BASE + 0x10)

# Read with symbolic name
print/x *((uint32_t*)0x40020010)

# Write to GPIO output register
set *((uint32_t*)0x40020014) = 0x0020
```

**Automatic Register Display:**

Configure GDB to display registers after each step:

```gdb
# Show registers after every command
define hook-stop
    info registers
end

# Or display specific registers
define hook-stop
    printf "R0: 0x%08x  R1: 0x%08x  R2: 0x%08x\n", $r0, $r1, $r2
    printf "PC: 0x%08x  SP: 0x%08x  LR: 0x%08x\n", $pc, $sp, $lr
end
```

**Memory Dump to File:**

```gdb
# Dump memory region to binary file
dump binary memory filename.bin 0x20000000 0x20010000

# Dump as hex
dump ihex memory filename.hex 0x08000000 0x08020000

# Restore memory from file
restore filename.bin binary 0x20000000
```

**JTAG/SWD Memory Access:**

Debug probes (J-Link, ST-Link, CMSIS-DAP) access memory through debug protocols:

**SWD (Serial Wire Debug):** Two-wire protocol (SWDIO data, SWCLK clock) providing full debug access. SWD reads/writes use the Debug Port (DP) to access the Access Port (AP):

```
1. Select MEM-AP (memory access port)
2. Write target address to TAR (Transfer Address Register)
3. Read/write DRW (Data Read/Write register)
```

This happens transparently when using debuggers, but understanding the mechanism helps diagnose connection issues.

**OpenOCD Memory Commands:**

```tcl
# Read word at address
mdw 0x20000000

# Read 16 words
mdw 0x20000000 16

# Write word
mww 0x20000100 0x12345678

# Read byte
mdb 0x20000000

# Write byte
mwb 0x20000000 0xFF

# Read peripheral register
mdw 0x40020000

# Fill memory region
mww 0x20000000 0xDEADBEEF 256
```

**Flash Memory Inspection:**

Reading flash memory works identically to RAM, but writing requires flash programming algorithms:

```gdb
# Read flash
x/256xw 0x08000000

# Disassemble flash code
disassemble 0x08000000, 0x08000100

# Cannot directly write flash - use load instead
load program.elf
```

**Register Context During Exceptions:**

When an exception occurs on Cortex-M, hardware automatically stacks registers:

```
[SP-32]: R0
[SP-28]: R1
[SP-24]: R2
[SP-20]: R3
[SP-16]: R12
[SP-12]: LR (return address)
[SP-8]:  PC (exception address)
[SP-4]:  xPSR
```

**Example** - Examining exception frame:

```assembly
HardFault_Handler:
    @ Get stack pointer used for exception
    TST lr, #4
    ITE EQ
    MRSEQ r0, MSP
    MRSNE r0, PSP
    
    @ r0 now points to exception frame
    @ Can be examined in debugger or passed to C function
    B .
```

```gdb
# After hitting HardFault_Handler
x/8wx $r0
# Shows: R0, R1, R2, R3, R12, LR, PC, xPSR
```

**Debugging Optimized Code:**

Compiler optimizations can make debugging difficult. Registers hold multiple variables, values cached, code reordered:

```gdb
# Variables may be optimized out
print my_variable
# Result: <optimized out>

# Use disassembly to see actual instructions
disassemble

# Examine registers where values might be
info registers
```

**Key Points:**

- Debug symbols map machine code to source code using DWARF format
- Hardware breakpoints use comparator units; software breakpoints modify code with BKPT instructions
- Watchpoints monitor memory access and trigger on read/write operations
- Single-stepping executes one instruction at a time with hardware support
- Debug registers (DHCSR, DCRSR, DCRDR) provide full processor and memory access while halted
- Memory-mapped peripherals can be inspected and modified like any memory location
- GDB and OpenOCD provide high-level interfaces to low-level debug hardware

---

