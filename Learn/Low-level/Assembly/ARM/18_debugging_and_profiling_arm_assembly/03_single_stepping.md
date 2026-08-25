## Single-Stepping


Single-stepping executes one instruction at a time, allowing detailed program flow examination. ARM debug hardware provides multiple stepping modes.

**Cortex-M Debug Halting:**

The Debug Halting Control and Status Register (DHCSR) controls debug state:

```c
#define DHCSR  (*((volatile uint32_t*)0xE000EDF0))
#define DCRSR  (*((volatile uint32_t*)0xE000EDF4))
#define DCRDR  (*((volatile uint32_t*)0xE000EDF8))

// Halt the processor
DHCSR = 0xA05F0003;  // Key=0xA05F, C_DEBUGEN=1, C_HALT=1

// Single-step (step one instruction and halt)
DHCSR = 0xA05F0007;  // C_DEBUGEN=1, C_HALT=1, C_STEP=1
```

**Step Modes:**

**Instruction Step** Executes exactly one instruction regardless of type. Branches, calls, and returns all count as single steps.

```gdb
stepi    # Step one instruction
si       # Shorthand
```

**Step Over** Executes one source line or instruction, treating function calls as single operations. The debugger sets a temporary breakpoint after the call instruction.

```gdb
next     # Step over (source level)
nexti    # Step over (instruction level)
ni       # Shorthand
```

**Example** sequence:

```assembly
@ PC at this line
BL function_call    @ Step-over places breakpoint at next line
MOV r0, #1          @ Execution stops here
```

**Step Into** Steps into function calls, allowing inspection of called functions:

```gdb
step     # Step into (source level)
stepi    # Step into (instruction level)
si       # Shorthand
```

**Step Out** Continues execution until the current function returns:

```gdb
finish   # Run until function returns
```

This sets a temporary breakpoint at the return address on the stack.

**Hardware Single-Stepping:**

On Cortex-M, the C_STEP bit in DHCSR enables hardware single-step. The processor executes one instruction then immediately re-enters debug state. The debugger reads registers and memory after each step.

**Interrupt Behavior During Stepping:**

**C_MASKINTS Bit:** Controls whether interrupts are masked during single-step:

```c
// Step with interrupts masked
DHCSR = 0xA05F000F;  // C_MASKINTS=1, C_STEP=1, C_HALT=1, C_DEBUGEN=1

// Step with interrupts enabled
DHCSR = 0xA05F0007;  // C_MASKINTS=0, C_STEP=1, C_HALT=1, C_DEBUGEN=1
```

With interrupts enabled during debug, interrupt handlers may execute between steps, complicating debugging. [Inference] Most debuggers mask interrupts by default during single-stepping to prevent confusion.

**Step Over Special Instructions:**

**WFI (Wait For Interrupt):** Single-stepping over WFI can be problematic. The instruction waits for an interrupt, potentially hanging the debugger. Modern debuggers handle this by:

1. Detecting WFI instructions
2. Setting a breakpoint after WFI
3. Continuing execution
4. Halting at the breakpoint when an interrupt occurs

**Branch with Link (BL):** Step-over detects BL instructions and sets a temporary breakpoint at the instruction following the BL, then continues execution.

**Example** - Manual single-step implementation:

```assembly
debug_single_step:
    PUSH {lr}
    
    @ Enable debug
    LDR r0, =DHCSR
    LDR r1, =0xA05F0003     @ Halt with debug enabled
    STR r1, [r0]
    
    @ Wait for halt
1:  LDR r1, [r0]
    TST r1, #0x00020000     @ S_HALT bit
    BEQ 1b
    
    @ Single-step
    LDR r1, =0xA05F0007     @ Step, halt, debug enabled
    STR r1, [r0]
    
    @ Wait for step complete
2:  LDR r1, [r0]
    TST r1, #0x00020000
    BEQ 2b
    
    POP {pc}
```

**GDB Stepping Commands Summary:**

```gdb
si / stepi          # Step one instruction (into calls)
ni / nexti          # Step one instruction (over calls)
step                # Step one source line (into calls)
next                # Step one source line (over calls)
finish              # Run until current function returns
until               # Run until past current loop
advance <location>  # Run until specific location
```

