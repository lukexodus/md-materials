## Stack Architecture and Operations


The x86 stack is a region of memory managed through dedicated registers and instructions. Unlike typical data structures where "stack" refers to an abstract concept, the x86 stack is a concrete memory region with hardware-level support.

### Stack Memory Organization

The stack occupies a contiguous region of virtual memory allocated by the operating system. Each thread in a program receives its own stack with a specific size determined at thread creation. Typical stack sizes range from hundreds of kilobytes to several megabytes, depending on the operating system and thread type.

The x86 stack grows downward - from high memory addresses toward low memory addresses. This design choice, while counterintuitive, has historical reasons and is consistent across x86 implementations. When data is pushed onto the stack, the stack pointer decreases. When data is popped, the stack pointer increases.

A typical stack layout in virtual memory:

```
High Address (0x7FFFFFFFFFFF in 64-bit)
    ↓ Stack grows downward
    [Stack base / top of allocated region]
    [Local variables]
    [Saved registers]
    [Return addresses]
    [Function parameters]
    [More stack frames...]
    ↑ Stack pointer (RSP) points here
    [Unused stack space]
    [Stack limit / guard page]
Low Address
```

The stack has boundaries defined by its allocated region. Exceeding the upper boundary (growing past the stack limit) causes a stack overflow, triggering a page fault or access violation. Most operating systems place guard pages at the stack limit to detect overflows.

Stack alignment requirements vary by architecture mode and calling convention. In 64-bit mode, the System V AMD64 ABI requires the stack to be 16-byte aligned immediately before a CALL instruction. Windows x64 calling convention has similar requirements. Misaligned stacks can cause reduced performance or exceptions when using SIMD instructions that require aligned memory access.

### Stack Pointer Register

The stack pointer register (RSP in 64-bit mode, ESP in 32-bit mode, SP in 16-bit mode) contains the memory address of the top of the stack - the most recently pushed item. The processor automatically updates RSP during stack operations.

RSP points to the last item pushed onto the stack, not to the next available location. This means the memory at [RSP] contains valid data. When pushing a new value, the processor first decrements RSP, then writes the data. When popping, it reads from [RSP], then increments RSP.

The stack pointer must remain valid throughout program execution. Corrupting RSP typically causes immediate crashes when the next function call or return attempts to use the stack. Debugging stack corruption issues is challenging because the corruption often occurs well before its effects become visible.

Direct manipulation of RSP is possible but requires care:

```asm
SUB RSP, 32        ; Allocate 32 bytes of stack space
; Use [RSP], [RSP+8], [RSP+16], [RSP+24] for local storage
ADD RSP, 32        ; Deallocate stack space
```

Modern calling conventions discourage direct RSP manipulation outside function prologues and epilogues, preferring to use the base pointer (RBP) for accessing stack data.

### Base Pointer Register

The base pointer register (RBP in 64-bit mode, EBP in 32-bit mode, BP in 16-bit mode) traditionally provides a stable reference point for accessing function parameters and local variables. While RSP moves as items are pushed and popped, RBP remains constant throughout a function's execution.

Many functions establish a stack frame by saving the previous RBP value and setting RBP to the current RSP:

```asm
PUSH RBP           ; Save caller's base pointer
MOV RBP, RSP       ; Establish new base pointer
SUB RSP, 64        ; Allocate space for local variables
```

With RBP established, the function can access parameters and locals using fixed offsets:

- Parameters (passed on stack): [RBP + 16], [RBP + 24], etc.
- Saved RBP: [RBP]
- Return address: [RBP + 8]
- Local variables: [RBP - 8], [RBP - 16], etc.

Modern optimizing compilers sometimes omit the frame pointer, using RSP-relative addressing throughout the function. This optimization (enabled by -fomit-frame-pointer in GCC/Clang) frees RBP for use as an additional general-purpose register, potentially improving performance. However, it complicates debugging and stack unwinding.

Frame pointer omission is safe when:

- The function doesn't use variable-length arrays (VLAs)
- The function doesn't call alloca()
- Stack unwinding metadata is available (DWARF information on Linux, exception tables on Windows)

### Stack Operations Fundamentals

All stack operations maintain the LIFO ordering. The stack serves multiple purposes simultaneously:

- Temporary storage during expression evaluation
- Parameter passing between functions
- Return address storage for function calls
- Local variable allocation
- Register preservation across function calls
- Exception handling and unwinding

Stack discipline requires matching every PUSH with a corresponding POP (or equivalent adjustment) to maintain stack balance. Unbalanced stack operations cause return address corruption, parameter misalignment, and crashes.

Consider a sequence of operations:

```asm
PUSH RAX           ; RSP = RSP - 8, [RSP] = RAX
PUSH RBX           ; RSP = RSP - 8, [RSP] = RBX
; At this point, [RSP] = RBX, [RSP+8] = RAX
POP RCX            ; RCX = [RSP] = RBX, RSP = RSP + 8
POP RDX            ; RDX = [RSP] = RAX, RSP = RSP + 8
; Stack returns to original state
```

The stack enables recursion by allowing multiple invocations of the same function to maintain separate local state. Each recursive call creates a new stack frame with its own parameters, local variables, and return address.

Stack overflow occurs when recursive depth or local variable allocation exceeds available stack space. [Inference] Unlike heap exhaustion, which may be recoverable, stack overflow typically terminates the thread or process immediately.

