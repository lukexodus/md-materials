## ARM Procedure Call Standard (AAPCS)


The ARM Architecture Procedure Call Standard (AAPCS) defines conventions for function calls, ensuring interoperability between separately compiled code modules and different programming languages. Adhering to AAPCS allows assembly code to interface correctly with C/C++ and other high-level language code.

### Purpose and Scope

AAPCS standardizes the interface between caller and callee functions, specifying:

- Which registers pass parameters
- Which registers preserve values across calls
- How return values are communicated
- Stack organization and alignment requirements
- Special considerations for variadic functions

The standard exists in variants for different ARM profiles:

- AAPCS for ARMv7-A (32-bit application processors)
- AAPCS64 for ARMv8-A AArch64 (64-bit application processors)
- Embedded AAPCS variants for Cortex-R and Cortex-M processors

Following AAPCS is mandatory when interfacing with compiled code but optional for internal assembly-only code, though consistency with the standard simplifies maintenance.

### Register Usage Conventions (ARMv7 32-bit)

AAPCS defines specific roles for the 16 general-purpose registers (R0-R15):

**R0-R3 (Argument/Result registers)**: Pass the first four integer arguments to functions. R0 also returns integer results up to 32 bits. These registers are **caller-saved**—the caller cannot assume they preserve values across function calls.

**R4-R8, R10-R11 (Variable registers)**: Available for general use. These registers are **callee-saved**—a called function must preserve their values, saving them on entry and restoring them before returning if it uses them.

**R9 (Platform register)**: Role varies by platform. May be reserved for platform-specific purposes or available as an additional variable register. Portable code should avoid R9 or follow platform-specific conventions.

**R12 (IP - Intra-Procedure-call scratch register)**: Temporary register used by linker veneers and PLT code. May be corrupted by function calls, even if the called function doesn't explicitly use it. Treat as caller-saved.

**R13 (SP - Stack Pointer)**: Points to the current stack position. Must remain valid at all times and maintain 4-byte alignment (8-byte alignment at public interfaces). Callee-saved semantically—functions return with SP restored to entry value.

**R14 (LR - Link Register)**: Holds the return address when a function is called using BL or BLX. Caller-saved since the called function may call other functions, overwriting LR.

**R15 (PC - Program Counter)**: Contains the address of the current instruction plus 8 (or 4 in Thumb). Not directly manipulated for parameter passing but used implicitly in branches and returns.

### Register Usage Conventions (ARMv8 64-bit)

AAPCS64 defines conventions for 64-bit AArch64 mode with 31 general-purpose registers (X0-X30) plus special registers:

**X0-X7 (Argument/Result registers)**: Pass the first eight integer arguments. X0-X1 return integer results up to 128 bits. Caller-saved registers.

**X8 (Indirect result location)**: Holds the address for returning large structures that don't fit in registers. Caller-saved.

**X9-X15 (Temporary registers)**: Available for general use. Caller-saved—values not preserved across calls.

**X16-X17 (IP0, IP1 - Intra-Procedure-call temporary registers)**: Used by linker veneers and PLT code. May be corrupted by function calls. Caller-saved.

**X18 (Platform register)**: Role varies by platform. On some platforms reserved; on others available as temporary. Portable code should avoid X18.

**X19-X28 (Callee-saved registers)**: Must be preserved across function calls. A function using these registers must save them on entry and restore before returning.

**X29 (FP - Frame Pointer)**: Optional frame pointer. When used, points to the saved frame record (FP, LR pair) on the stack. Callee-saved.

**X30 (LR - Link Register)**: Holds the return address. Callee must save if calling other functions.

**SP (Stack Pointer)**: Must maintain 16-byte alignment at all times in AArch64. Points to the lowest used address on the stack.

**PC (Program Counter)**: Not directly accessible as a general-purpose register in AArch64. Branch and return instructions manipulate it implicitly.

Additionally, 32-bit **W0-W30** registers are the lower 32 bits of corresponding X registers.

### Floating-Point and SIMD Register Conventions

ARM processors with floating-point and NEON/SIMD support use separate register files:

**ARMv7 VFP registers**:

- S0-S31: 32 single-precision (32-bit) registers
- D0-D31: 32 double-precision (64-bit) registers (D0-D15 overlap with S0-S31)
- S0-S15 (D0-D7): Pass floating-point arguments and return values. Caller-saved.
- S16-S31 (D8-D15 lower halves): Callee-saved, must be preserved if used
- D16-D31: Caller-saved (if present on the processor)

**ARMv8 SIMD/FP registers**:

- V0-V31: 128-bit SIMD/FP registers
- Can be accessed as B (8-bit), H (16-bit), S (32-bit), D (64-bit), or Q (128-bit)
- V0-V7: Pass floating-point/SIMD arguments and return values. Caller-saved.
- V8-V15: Callee-saved—lower 64 bits (D8-D15) must be preserved if used
- V16-V31: Caller-saved

The distinction between caller-saved and callee-saved determines optimization opportunities—caller-saved registers allow the called function to use them freely, while callee-saved registers require save/restore overhead but allow the caller to maintain values across calls.

### Subroutine Call Instruction

Function calls use branch-with-link instructions that save the return address:

**ARMv7**:

```
BL function_name      @ Branch to function, LR = return address
BLX r0                @ Branch to address in r0, LR = return address
                      @ BLX can also switch ARM/Thumb modes
```

**ARMv8**:

```
BL function_name      @ Branch to function, X30 = return address
BLR x0                @ Branch to address in x0, X30 = return address
```

The return address stored in LR (R14 or X30) points to the instruction immediately following the call. Functions return by branching to this address.

### Function Return Mechanisms

Functions return control to the caller by restoring the program counter to the saved return address:

**ARMv7 simple return** (when LR not overwritten):

```
BX lr                 @ Return, can switch ARM/Thumb modes
MOV pc, lr            @ Alternative return (ARM mode only)
```

**ARMv7 return with register restoration**:

```
POP {r4-r8, pc}       @ Restore saved registers and return in one operation
```

**ARMv8 simple return**:

```
RET                   @ Return to address in X30 (LR)
RET x5                @ Return to address in specified register (rare)
```

**ARMv8 return with register restoration**:

```
LDP x29, x30, [sp], #16   @ Restore FP and LR from stack
RET                       @ Return to caller
```

When a function calls other functions, it must save LR before the nested call overwrites it, typically by pushing it onto the stack.

### Interworking Between ARM and Thumb

ARMv7 supports both ARM (32-bit instructions) and Thumb (16-bit instructions) modes. AAPCS defines interworking conventions:

The LSB of a function pointer or return address indicates the target mode:

- LSB = 0: ARM mode
- LSB = 1: Thumb mode

**BX** and **BLX** instructions examine the target address LSB and switch modes appropriately:

```
BX r0                 @ Branch to address in r0, switch to mode indicated by r0[0]
BLX label             @ Call function, switch modes if necessary
```

When taking function addresses, the assembler or compiler sets the LSB according to the function's mode:

```
.thumb_func           @ Declares following function as Thumb
function:
    @ Function body...
    BX lr

@ Later, loading this address produces an odd address (LSB=1)
LDR r0, =function     @ r0 gets address with LSB=1
```

ARMv8 AArch64 uses only 64-bit fixed-width instructions, eliminating mode switching complexity.

### C Language Type Mapping

AAPCS defines how C types map to registers and memory:

**ARMv7 (32-bit)**:

- `char`: 8 bits, zero or sign-extended to 32 bits in registers
- `short`: 16 bits, zero or sign-extended to 32 bits in registers
- `int`, `long`: 32 bits, occupy one register
- `long long`: 64 bits, occupy two consecutive registers (even-odd pair)
- Pointers: 32 bits, one register
- `float`: 32 bits, S register (or core register if no VFP)
- `double`: 64 bits, D register (or two core registers if no VFP)
- Structures: Passed by value using multiple registers or stack

**ARMv8 (64-bit)**:

- `char`: 8 bits, zero or sign-extended to 32/64 bits in registers
- `short`: 16 bits, zero or sign-extended to 32/64 bits in registers
- `int`: 32 bits, occupy lower 32 bits of register (W register)
- `long`, `long long`: 64 bits, occupy one X register
- Pointers: 64 bits, occupy one X register
- `float`: 32 bits, S register
- `double`: 64 bits, D register
- Structures: Passed by value using multiple registers or stack

### Endianness

ARM supports both little-endian and big-endian byte ordering, though little-endian is predominant in modern systems. AAPCS defines that:

- Multi-byte values stored in memory follow the configured endianness
- Register values are endian-neutral (bits have fixed positions)
- Data structures passed between functions must use consistent endianness

Code must not assume specific endianness unless targeting a known platform. Most modern ARM systems (including all Cortex-A application processors) use little-endian mode.

### Variadic Functions

Functions with variable numbers of arguments (variadic functions, like `printf`) follow special conventions:

**ARMv7**: Arguments are passed in the same manner as fixed-argument functions. The first four arguments use R0-R3, with additional arguments on the stack. The callee doesn't know which registers contain valid arguments without examining the format string or other metadata.

**ARMv8**: Similar to ARMv7, using X0-X7 for the first eight arguments. Variadic functions may need to save all argument registers to support `va_start`/`va_arg` operations.

The caller is responsible for stack cleanup in variadic functions, ensuring alignment and removing arguments after the call.

### Struct and Union Passing

Small structures may be passed in registers; larger structures use memory:

**ARMv7**:

- Structures ≤ 32 bits: Passed in one register
- Structures 33-64 bits: Passed in two registers
- Larger structures: Caller allocates memory, passes pointer in register

**ARMv8**:

- Homogeneous structures (all elements same type, ≤ 4 elements): May be passed in consecutive registers of appropriate type
- Structures ≤ 16 bytes: Passed in registers if sufficient registers available
- Larger structures: Passed by reference (pointer in X8 or stack)

The exact rules are complex, accounting for structure alignment and register availability. [Inference] Compilers handle these details automatically, but assembly programmers must follow the rules precisely for correct interoperation.

### Position-Independent Code (PIC)

AAPCS defines conventions for position-independent code, allowing code to execute correctly regardless of its load address. This is essential for shared libraries:

**ARMv7**: Uses R9 as the static base register (SB) or R10 as the global offset table (GOT) pointer, depending on the PIC variant. Function calls may indirect through a procedure linkage table (PLT).

**ARMv8**: Uses PC-relative addressing for position-independent access. The `ADRP` instruction calculates page addresses relative to PC, and subsequent instructions add page offsets.

**Example** ARMv8 position-independent global access:

```
ADRP x0, global_var       @ x0 = page address of global_var
LDR x1, [x0, :lo12:global_var]  @ Load from page offset
```

Position-independent code follows standard AAPCS register conventions but adds constraints on global data access patterns.

