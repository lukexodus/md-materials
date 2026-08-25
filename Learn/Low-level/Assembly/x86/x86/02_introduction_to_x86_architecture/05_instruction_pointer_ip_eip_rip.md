## Instruction Pointer (IP/EIP/RIP)


The instruction pointer is a critical register that holds the memory address of the next instruction to be executed. This register has evolved through different x86 generations:

**IP (Instruction Pointer)** existed in 16-bit x86 processors (8086, 8088, 80186, 80286 in real mode). It was a 16-bit register that could address up to 64 KB when combined with the code segment register. The actual physical address was calculated as CS * 16 + IP in real mode.

**EIP (Extended Instruction Pointer)** appeared with 32-bit x86 processors starting with the 80386. This 32-bit register could theoretically address up to 4 GB of memory. In protected mode, EIP works with segment descriptors rather than direct segment values, though in flat memory models, this distinction becomes largely transparent to programmers.

**RIP (Register Instruction Pointer)** is the 64-bit version used in x86-64 architecture. While theoretically capable of addressing 16 exabytes, current implementations typically support 48-bit or 57-bit addressing, depending on the processor generation.

The instruction pointer cannot be directly accessed or modified through standard move instructions. Instead, it changes implicitly through control flow instructions:

Sequential execution advances the instruction pointer by the length of the current instruction after execution. Jump instructions (JMP, JE, JNE, etc.) modify the instruction pointer to transfer control to different code locations. Call instructions (CALL) push the current instruction pointer value onto the stack before jumping to a subroutine. Return instructions (RET) pop a value from the stack into the instruction pointer, returning control to the caller.

In x86-64 long mode, RIP-relative addressing became available, allowing instructions to reference data relative to the current instruction pointer. This facilitates position-independent code, which is essential for shared libraries and modern security features like Address Space Layout Randomization (ASLR).

