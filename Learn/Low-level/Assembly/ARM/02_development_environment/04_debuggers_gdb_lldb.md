## Debuggers (GDB, LLDB)


### GDB for ARM

GNU Debugger with ARM cross-debugging support.

**Starting GDB:**

```bash
# Debug local ARM executable
arm-none-eabi-gdb program.elf

# Connect to remote target (OpenOCD, QEMU, hardware debugger)
arm-none-eabi-gdb program.elf
(gdb) target remote localhost:3333
(gdb) monitor reset halt
(gdb) load
(gdb) continue
```

**Essential GDB Commands:**

```gdb
# Loading and running
file program.elf          # Load executable
load                      # Load program to target
run                       # Start execution
continue (c)              # Continue execution
step (s)                  # Step into
next (n)                  # Step over
finish                    # Step out
until *0x8000100         # Run until address

# Breakpoints
break main                # Break at function
break *0x8000100         # Break at address
break file.c:42          # Break at line
break func if r0==5      # Conditional breakpoint
watch variable           # Data watchpoint
rwatch address           # Read watchpoint
awatch address           # Access watchpoint
info breakpoints         # List breakpoints
delete 1                 # Delete breakpoint 1
disable 2                # Disable breakpoint 2
enable 2                 # Enable breakpoint 2

# Examining registers
info registers           # All registers
info all-registers       # Including system registers
print $r0                # Single register
set $r1 = 10            # Modify register
info registers pc sp lr  # Specific registers

# Examining memory
x/10x 0x20000000        # 10 hex words
x/10i $pc               # 10 instructions at PC
x/s 0x20000100          # String
x/10b 0x20000000        # 10 bytes
print *(int*)0x20000000 # Dereference pointer
dump binary memory out.bin 0x20000000 0x20001000

# Stack examination
backtrace (bt)           # Stack trace
frame 2                  # Select frame
info frame               # Frame details
info locals              # Local variables
info args                # Function arguments

# Disassembly
disassemble main         # Disassemble function
disassemble /r          # Include raw bytes
set disassembly-flavor intel  # Syntax style
```

**ARM-Specific GDB Features:**

```gdb
# Set ARM/Thumb mode
set arm force-mode thumb
set arm force-mode arm

# Vector Floating Point
info float               # FPU registers
set $s0 = 1.5           # Set FP register

# ARM system registers
print $cpsr             # Current Program Status Register
print $spsr             # Saved Program Status Register
set $cpsr = 0x13        # Set to supervisor mode

# Memory-mapped peripherals
set *(int*)0x40021000 = 0x1  # Write to peripheral
print/x *(int*)0x40021000     # Read peripheral
```

**GDB Initialization Script (.gdbinit):**

```gdb
# .gdbinit for ARM Cortex-M4
target remote localhost:3333
set mem inaccessible-by-default off
set architecture arm
set arm force-mode thumb

# Custom commands
define reset
    monitor reset halt
    load
end

define flash
    monitor reset halt
    load
    monitor reset run
end

# Layout
layout regs              # Show registers
layout asm               # Show assembly
layout split             # Show source and assembly

# Pretty printing
set print pretty on
set print array on
set print array-indexes on
```

### OpenOCD Integration

OpenOCD provides debugging interface for ARM hardware.

**Starting OpenOCD:**

```bash
# Start OpenOCD with board config
openocd -f board/st_nucleo_f4.cfg

# Or with interface and target
openocd -f interface/stlink-v2.cfg -f target/stm32f4x.cfg
```

**OpenOCD Commands in GDB:**

```gdb
# Reset commands
monitor reset halt       # Reset and halt
monitor reset run        # Reset and run
monitor reset init       # Reset and init

# Flash operations
monitor flash write_image erase program.elf
monitor flash erase_sector 0 0 last
monitor flash info 0

# Debugging
monitor mdw 0x20000000 10    # Read memory
monitor mww 0x20000000 0x12  # Write memory
monitor reg                   # Show registers
monitor halt                  # Halt target
monitor resume                # Resume execution
```

### LLDB for ARM

LLVM debugger with similar functionality to GDB.

**Basic LLDB Commands:**

```lldb
# Starting
lldb program.elf
(lldb) target create program.elf
(lldb) gdb-remote localhost:3333

# Breakpoints
breakpoint set --name main
breakpoint set --address 0x8000100
breakpoint set --file main.c --line 42
breakpoint list
breakpoint delete 1

# Execution
run
continue
step
next
finish
process kill

# Registers
register read
register read r0 r1 r2
register write r0 42

# Memory
memory read 0x20000000
memory read --size 4 --format x --count 10 0x20000000
memory write 0x20000000 0x12345678

# Disassembly
disassemble --name main
disassemble --start-address 0x8000000 --count 20
```

**LLDB Python Scripting:**

```python
# .lldbinit
script
import lldb

def reset_target(debugger, command, result, internal_dict):
    target = debugger.GetSelectedTarget()
    process = target.GetProcess()
    process.SendCommand("monitor reset halt")
    
lldb.debugger.HandleCommand('command script add -f script.reset_target reset')
end
```

### Hardware Debugging Interfaces

**JTAG (Joint Test Action Group):**

- Full boundary scan capability
- 4-5 signal lines (TMS, TCK, TDI, TDO, optional TRST)
- Supports multiple devices in daisy chain
- Industry standard for ARM debugging

**SWD (Serial Wire Debug):**

- 2-wire interface (SWDIO, SWCLK)
- ARM-specific alternative to JTAG
- Lower pin count, suitable for small packages
- Similar functionality to JTAG

**Debug Probe Connection:**

```bash
# Check connected probes
openocd -f interface/stlink.cfg -c "adapter list"

# Probe-specific configs
-f interface/jlink.cfg        # Segger J-Link
-f interface/stlink.cfg       # ST-Link
-f interface/cmsis-dap.cfg    # ARM CMSIS-DAP
-f interface/ftdi/openocd-usb.cfg  # FTDI-based
```

### Semihosting

Semihosting allows debugging through host I/O operations.

**Enabling Semihosting:**

```gdb
# In GDB
monitor arm semihosting enable

# In code (OpenOCD)
extern void initialise_monitor_handles(void);
initialise_monitor_handles();  # Enable semihosting

printf("Debug output\n");  # Output via debugger
```

**Semihosting System Calls:**

```assembly
# SYS_WRITE (0x05)
mov r0, #0x05          @ SYS_WRITE
ldr r1, =params        @ Parameter block
bkpt #0xAB             @ Semihosting breakpoint

params:
    .word 1            @ File handle (stdout)
    .word message      @ Buffer address
    .word msg_len      @ Length
```

**Key Points:**

- ARM development requires cross-compilation toolchains targeting specific processor architectures
- GNU tools (GAS, ld, GDB) provide free, open-source development capabilities across all platforms
- Linker scripts precisely control memory layout, critical for bare-metal and embedded systems
- Modern debuggers support remote debugging via JTAG/SWD interfaces through tools like OpenOCD
- Semihosting enables printf-style debugging through the debugger connection without UART hardware

---

