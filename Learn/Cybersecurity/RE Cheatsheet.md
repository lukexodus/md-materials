# Syllabus

## Modular Topic List for Kali Linux

### Module 1: Foundations

- Binary file formats (ELF, PE, Mach-O)
- Number systems and data representation
- CPU architecture basics (x86, x64, ARM)
- Instruction sets and assembly language fundamentals
- Program memory layout (stack, heap, text, data segments)

### Module 2: Static Analysis Tools

- **objdump** – disassembly and binary inspection
- **strings** – extracting readable strings
- **file** – identifying file types
- **nm** – symbol table examination
- **readelf** – ELF file analysis
- **IDA Pro / Ghidra** – interactive disassemblers
- **Radare2** – framework for binary analysis
- Decompilers (Ghidra decompiler, Hex-Rays)

### Module 3: Dynamic Analysis Tools

- **gdb (GNU Debugger)** – breakpoints, registers, memory inspection
- **lldb** – LLVM debugger
- **strace** – system call tracing
- **ltrace** – library call tracing
- **valgrind** – memory debugging
- Debugger workflows and scripts

### Module 4: Assembly Language Deep Dive

- x86/x64 instruction families (mov, add, sub, jmp, call, ret)
- Stack operations and calling conventions
- Control flow (conditionals, loops, function calls)
- Registers and flags
- Function prologue/epilogue
- Position-independent code (PIC)

### Module 5: Common Protections & Obfuscation

- Address Space Layout Randomization (ASLR)
- Data Execution Prevention (DEP/NX)
- Stack canaries
- Code signing and verification
- Anti-debugging techniques
- Packing and UPX
- Virtualization and emulation-based obfuscation
- Code polymorphism and metamorphism

### Module 6: Cryptanalysis Basics

- Symmetric cryptography recognition
- Hash function identification
- Asymmetric crypto concepts
- Common implementations (OpenSSL, libsodium)
- Weak cryptographic patterns

### Module 7: Vulnerability Classes

- Buffer overflows and stack smashing
- Format string vulnerabilities
- Integer overflows/underflows
- Use-after-free
- Double-free vulnerabilities
- Off-by-one errors
- Return-oriented programming (ROP)

### Module 8: Scripting & Automation

- Python scripting for binary analysis
- **pwntools** library
- Creating custom GDB scripts
- Radare2 scripting (r2pipe)
- Automating exploit generation

### Module 9: Platform-Specific Analysis

- **Linux ELF binaries** – GOT, PLT, relocation
- **Windows PE binaries** – imports, exports, sections
- **Android APK analysis** – Dalvik bytecode
- **Embedded/ARM binaries** – THUMB mode, architecture specifics

### Module 10: Reverse Engineering Workflows

- Identifying main entry point
- Function boundary detection
- Control flow graph reconstruction
- Data flow analysis
- Loop analysis and pattern recognition
- Recognizing compiler-generated code
- Identifying standard library functions

### Module 11: Special Techniques

- Kernel-level debugging (kgdb)
- Hypervisor-level analysis
- Side-channel analysis basics
- Firmware extraction and analysis
- Container and sandbox escape analysis
- Time-based and speculative execution exploits

### Module 12: CTF-Specific Challenges

- Flag extraction and verification
- Forensic RE (finding hidden data)
- Malware analysis (CTF-style)
- Keygen creation and license validation
- Custom protocol reverse engineering
- Constraint solving in binary challenges

### Module 13: Advanced Angr & Symbolic Execution

- **Angr framework** setup and fundamentals
- Path exploration strategies
- State management
- Hooking functions
- Constraint solving

### Module 14: Documentation & Reporting

- Annotating disassembly
- Creating analysis notes
- Documenting findings for teams
- Writing proof-of-concept (PoC) code

---

This modular structure allows you to pick starting points based on challenge types and build skill progression systematically.