## Application Binary Interface (ABI)


The ABI defines the low-level interface between an application program, the operating system, and between different components of an application. It specifies conventions that enable separately compiled modules to work together.

### Core ABI Components

**Calling Convention**: Defines how function parameters are passed, how return values are handled, who cleans up the stack, and which registers must be preserved.

**Register Usage**: Specifies which registers are caller-saved (volatile) versus callee-saved (non-volatile). In x86-64 System V ABI, RBX, RBP, R12-R15 are callee-saved, while RAX, RCX, RDX, RSI, RDI, R8-R11 are caller-saved.

**Stack Alignment**: x86-64 requires 16-byte stack alignment before a call instruction. This means RSP must be divisible by 16 immediately before the CALL instruction executes.

**Parameter Passing**: In x86-64 System V ABI (Linux, macOS), the first six integer/pointer arguments use RDI, RSI, RDX, RCX, R8, R9. In Windows x64, the first four use RCX, RDX, R8, R9. Floating-point arguments use XMM0-XMM7 (System V) or XMM0-XMM3 (Windows).

**Return Values**: Integer/pointer return values use RAX (and RDX for 128-bit values). Floating-point returns use XMM0.

**Stack Frame Layout**: The stack grows downward (toward lower addresses). A typical frame contains return address, saved frame pointer, local variables, and spilled registers.

**Red Zone**: x86-64 System V ABI provides a 128-byte red zone below RSP that leaf functions can use without adjusting the stack pointer. [Inference] This optimization reduces stack manipulation overhead. Windows x64 does not have a red zone but has a 32-byte shadow space for register parameters.

**Structure Passing**: Small structures (≤16 bytes in System V) may be passed in registers. Larger structures are passed by reference or copied to the stack, depending on the ABI.

### Platform-Specific ABIs

**System V ABI (Linux, BSD, macOS)**: Uses the register order RDI, RSI, RDX, RCX, R8, R9 for integer arguments. Caller cleans up arguments. Stack must be 16-byte aligned before call.

**Microsoft x64 ABI (Windows)**: Uses RCX, RDX, R8, R9 for the first four arguments. All remaining arguments go on the stack. Caller allocates 32 bytes of shadow space for the callee to spill register parameters. Caller cleans up. Stack must be 16-byte aligned before call.

**32-bit ABIs**: cdecl (caller cleans, right-to-left push), stdcall (callee cleans, right-to-left), fastcall (first two arguments in ECX/EDX, rest on stack).

### ABI Violation Consequences

Violating the ABI results in undefined behavior: corrupted data, crashes, incorrect results, or security vulnerabilities. [Inference] Common violations include incorrect stack alignment, failing to preserve callee-saved registers, or using the wrong calling convention.

