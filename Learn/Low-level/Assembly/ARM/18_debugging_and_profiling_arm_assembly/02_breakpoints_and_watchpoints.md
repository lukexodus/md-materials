## Breakpoints and Watchpoints


ARM debug hardware provides breakpoint and watchpoint capabilities through the Debug Access Port (DAP) and dedicated debug registers. These operate independently of program execution, with minimal performance impact.

**Hardware Breakpoints:**

Hardware breakpoints halt execution when the program counter reaches a specific address. Implemented using comparator units in the Flash Patch and Breakpoint (FPB) unit on Cortex-M or debug registers on Cortex-A.

**Cortex-M FPB Unit:**

The FPB typically provides 6-8 instruction comparators:

- **FP_CTRL**: Control and status register
- **FP_COMP0-7**: Comparator registers for addresses
- **FP_REMAP**: Instruction remapping (literal patch)

Setting a breakpoint writes the target address to a comparator register:

```c
// Pseudocode for FPB configuration
#define FP_CTRL   (*((volatile uint32_t*)0xE0002000))
#define FP_COMP0  (*((volatile uint32_t*)0xE0002008))

// Enable FPB
FP_CTRL |= 0x00000003;  // KEY=1, ENABLE=1

// Set breakpoint at 0x08000400
FP_COMP0 = 0x08000400 | 0x1;  // Address with ENABLE bit
```

When PC matches the comparator value, the processor generates a debug event and halts.

**Software Breakpoints:**

When hardware breakpoints are exhausted, debuggers use software breakpoints by replacing instructions with breakpoint instructions:

- **ARM mode**: `0xE1200070` (BKPT instruction)
- **Thumb mode**: `0xBE00` (BKPT #0)

**Example** - BKPT instruction in assembly:

```assembly
.thumb
main:
    MOV r0, #5
    BKPT #0          @ Software breakpoint
    MOV r1, #10
```

The debugger saves the original instruction, replaces it with BKPT, and restores it when removing the breakpoint. This modifies program memory, which can be problematic in flash or when code is checksummed.

**Watchpoints (Data Breakpoints):**

Watchpoints monitor memory accesses and trigger when specific addresses are read, written, or accessed. Implemented via the Data Watchpoint and Trace (DWT) unit on Cortex-M.

**DWT Comparators:**

Typically 4 comparators support:

- **Read watchpoints**: Break on memory read
- **Write watchpoints**: Break on memory write
- **Access watchpoints**: Break on read or write

**Example** - Setting a write watchpoint:

```c
// DWT registers
#define DWT_CTRL       (*((volatile uint32_t*)0xE0001000))
#define DWT_COMP0      (*((volatile uint32_t*)0xE0001020))
#define DWT_MASK0      (*((volatile uint32_t*)0xE0001024))
#define DWT_FUNCTION0  (*((volatile uint32_t*)0xE0001028))

// Enable DWT
DWT_CTRL |= 0x00000001;

// Watch writes to 0x20000100
DWT_COMP0 = 0x20000100;
DWT_MASK0 = 0;              // Match exact address
DWT_FUNCTION0 = 0x5;        // FUNCTION=5 (write watchpoint)
```

**GDB Usage:**

Setting breakpoints and watchpoints in GDB:

```gdb
# Hardware breakpoint at function
hbreak my_function

# Hardware breakpoint at address
hbreak *0x08000400

# Software breakpoint
break my_function

# Write watchpoint
watch variable_name
watch *0x20000100

# Read watchpoint
rwatch variable_name

# Access watchpoint (read or write)
awatch variable_name

# Conditional breakpoint
break my_function if r0 == 5
```

**Breakpoint Limitations:**

On Cortex-M4:

- 6-8 hardware instruction breakpoints (FPB)
- 4 hardware data watchpoints (DWT)
- Unlimited software breakpoints (if flash can be modified)

[Inference] Software breakpoints are typically used for most breakpoints, reserving hardware breakpoints for flash/ROM code that cannot be modified.

**Tracepoints:**

Some ARM cores support tracing without halting via the Embedded Trace Macrocell (ETM). The processor logs execution information to a trace buffer while running at full speed.

