## Calling Conventions and ABI


A calling convention is a standardized protocol that governs how subroutines receive arguments, return values, and manage the call stack. The **Application Binary Interface (ABI)** is the broader contract that encompasses calling conventions alongside data layout, alignment rules, name mangling, system call interfaces, and object file format expectations. ABI conformance is what makes separately compiled translation units — and separately compiled libraries — interoperate correctly at the binary level.

---

### The Stack Frame (Activation Record)

Each function invocation produces a **stack frame** on the call stack. The frame persists for the lifetime of the call and is reclaimed on return.

<svg viewBox="0 0 520 420" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <!-- Title --> <text x="260" y="22" text-anchor="middle" font-size="14" font-weight="bold" fill="#e2e8f0">Typical Stack Frame Layout (grows downward)</text> <!-- High address label -->

<text x="420" y="50" fill="#64748b" font-size="11">high address</text>

<!-- Caller frame indicator --> <rect x="80" y="55" width="240" height="30" fill="#1e3a5f" stroke="#3b82f6" stroke-dasharray="4,2"/> <text x="200" y="75" text-anchor="middle" fill="#93c5fd">caller's frame (above)</text> <!-- Arguments passed on stack --> <rect x="80" y="85" width="240" height="35" fill="#1e293b" stroke="#475569"/> <text x="200" y="108" text-anchor="middle" fill="#e2e8f0">stack-passed arguments</text> <text x="330" y="108" fill="#64748b" font-size="11">← pushed by caller</text> <!-- Return address --> <rect x="80" y="120" width="240" height="35" fill="#292524" stroke="#78716c"/> <text x="200" y="143" text-anchor="middle" fill="#fde68a">return address</text> <text x="330" y="143" fill="#64748b" font-size="11">← CALL pushes this</text> <!-- Saved frame pointer --> <rect x="80" y="155" width="240" height="35" fill="#1e293b" stroke="#475569"/> <text x="200" y="178" text-anchor="middle" fill="#e2e8f0">saved frame pointer (RBP)</text> <text x="330" y="178" fill="#64748b" font-size="11">← callee saves old RBP</text> <!-- Frame pointer arrow --> <line x1="70" y1="172" x2="80" y2="172" stroke="#f59e0b" stroke-width="2" marker-end="url(#arr)"/> <text x="30" y="176" fill="#f59e0b" font-size="11">RBP</text> <!-- Callee-saved registers --> <rect x="80" y="190" width="240" height="35" fill="#1e293b" stroke="#475569"/> <text x="200" y="213" text-anchor="middle" fill="#e2e8f0">callee-saved registers</text> <text x="330" y="213" fill="#64748b" font-size="11">← must be preserved</text> <!-- Local variables --> <rect x="80" y="225" width="240" height="60" fill="#0f2027" stroke="#334155"/> <text x="200" y="260" text-anchor="middle" fill="#86efac">local variables</text> <text x="330" y="253" fill="#64748b" font-size="11">← automatic storage</text> <!-- Padding/alignment --> <rect x="80" y="285" width="240" height="25" fill="#1a1a2e" stroke="#334155" stroke-dasharray="3,2"/> <text x="200" y="303" text-anchor="middle" fill="#475569">alignment padding</text> <!-- Stack pointer arrow --> <line x1="70" y1="310" x2="80" y2="310" stroke="#34d399" stroke-width="2" marker-end="url(#arr2)"/> <text x="30" y="314" fill="#34d399" font-size="11">RSP</text> <!-- Callee outgoing args --> <rect x="80" y="310" width="240" height="35" fill="#1e293b" stroke="#475569" stroke-dasharray="4,2"/> <text x="200" y="333" text-anchor="middle" fill="#94a3b8">outgoing args (if any)</text> <text x="330" y="333" fill="#64748b" font-size="11">← for calls made here</text> <!-- Low address label -->

<text x="420" y="360" fill="#64748b" font-size="11">low address</text>

<!-- Arrow showing growth direction --> <line x1="50" y1="85" x2="50" y2="340" stroke="#64748b" stroke-width="1.5"/> <polygon points="50,345 45,332 55,332" fill="#64748b"/> <text x="10" y="220" fill="#64748b" font-size="11" transform="rotate(-90,10,220)">stack grows</text> <!-- Arrow markers --> <defs> <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#f59e0b"/> </marker> <marker id="arr2" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#34d399"/> </marker> </defs> </svg>

---

### ABI vs. Calling Convention

|Concern|Calling Convention|Full ABI|
|---|---|---|
|Argument passing order|✓|✓|
|Register usage rules|✓|✓|
|Stack alignment|✓|✓|
|Return value location|✓|✓|
|Struct layout and padding|✗|✓|
|Name mangling (C++)|✗|✓|
|Exception handling tables|✗|✓|
|Object file format (ELF, PE)|✗|✓|
|System call interface|✗|✓|
|Thread-local storage layout|✗|✓|

---

### Core Concepts

#### Caller-Saved vs. Callee-Saved Registers

Register preservation responsibility is divided between the two parties of every call.

**Caller-saved (volatile):** The caller must save these before issuing a call if their values are needed afterward. The callee is free to overwrite them without saving.

**Callee-saved (non-volatile):** The callee must restore these to their original values before returning. If the callee uses them, it must push/pop them explicitly.

This division is a trade-off: more callee-saved registers reduce caller overhead in leaf-heavy call trees; more caller-saved registers reduce prologue/epilogue overhead in callees that use few registers.

#### Stack Alignment

Most modern ABIs require the stack pointer to be aligned to a specific boundary at the point of a `CALL` instruction. The x86-64 System V ABI mandates **16-byte alignment** at the point of `CALL` (so RSP is 16-byte aligned before the call, and 8-byte aligned at function entry after the return address is pushed).

Misaligned stacks cause faults when SSE/AVX instructions access memory with alignment-required variants (`movaps`, `vmovdqa`).

#### Red Zone

The x86-64 System V ABI defines a **128-byte red zone** — a region below RSP that the OS signal handler and interrupt mechanism will not clobber. Leaf functions can use this area for temporaries without adjusting RSP, eliminating the overhead of a full frame setup.

---

### x86-64 System V ABI (Linux, macOS, BSD)

This is the dominant ABI for 64-bit Unix-like systems, standardized in the _System V Application Binary Interface AMD64 Architecture Processor Supplement_.

#### Integer/Pointer Argument Registers

Arguments are assigned to registers in this order:

|Position|Register|
|---|---|
|1st|RDI|
|2nd|RSI|
|3rd|RDX|
|4th|RCX|
|5th|R8|
|6th|R9|
|7th+|pushed on stack (right to left)|

#### Floating-Point Argument Registers

XMM0–XMM7 hold the first eight floating-point or SSE arguments, independently of the integer registers. A function receiving both integer and float arguments consumes both sequences simultaneously.

#### Return Values

|Type|Location|
|---|---|
|Integer / pointer (≤64-bit)|RAX|
|Integer (65–128-bit)|RAX:RDX (low:high)|
|Float / double|XMM0|
|Small struct (≤16 bytes)|RAX + RDX (classified per field)|
|Large struct (>16 bytes)|Caller allocates; RDI holds pointer|

#### Register Classification

|Caller-saved (volatile)|Callee-saved (non-volatile)|
|---|---|
|RAX, RCX, RDX, RSI, RDI|RBX, RBP, R12–R15|
|R8–R11|RSP (structurally preserved)|
|XMM0–XMM15 (all float regs)|—|

**Example — C to x86-64 assembly:**

```c
long add(long a, long b, long c) {
    return a + b + c;
}
```

```asm
add:
    ; a → RDI, b → RSI, c → RDX
    lea  rax, [rdi + rsi]   ; rax = a + b
    add  rax, rdx           ; rax += c
    ret                     ; return value in RAX
```

---

### x86-64 Windows ABI (Microsoft)

Windows uses a distinct ABI that is **not compatible** with System V.

#### Argument Registers

|Position|Integer/Pointer|Float|
|---|---|---|
|1st|RCX|XMM0|
|2nd|RDX|XMM1|
|3rd|R8|XMM2|
|4th|R9|XMM3|
|5th+|stack|stack|

Each argument slot corresponds to one position — an integer argument in position 2 uses RDX and leaves XMM1 unused for that slot.

#### Shadow Space

The Windows ABI requires the **caller** to allocate 32 bytes of **shadow space** (home space) on the stack immediately before the call, regardless of the number of arguments. This gives the callee space to spill its register arguments for debugging and variadic use.

#### Callee-Saved Registers (Windows)

RBX, RBP, RDI, RSI, RSP, R12–R15, XMM6–XMM15.

Note that XMM6–XMM15 are callee-saved under Windows but volatile under System V — a critical difference when writing cross-platform assembly.

---

### ARM64 (AArch64) ABI — AAPCS64

The **ARM 64-bit Procedure Call Standard (AAPCS64)** governs Linux, macOS (Apple Silicon), and Android on AArch64.

#### Argument and Return Registers

- **X0–X7**: first eight integer/pointer arguments; X0 holds integer return value.
- **V0–V7** (SIMD/FP): first eight floating-point arguments; V0 holds float return value.
- Arguments beyond eight are passed on the stack.

#### Register Classification

|Caller-saved|Callee-saved|
|---|---|
|X0–X18 (+ IP0/IP1 = X16/X17)|X19–X28|
|V0–V7, V16–V31|V8–V15 (lower 64 bits only)|
|X29 (FP) is callee-saved|X30 (LR) caller-saved|

**Key Points**

- X29 is the **frame pointer (FP)**; X30 is the **link register (LR)**, holding the return address.
- Unlike x86 which uses the stack for the return address (`CALL` pushes it), AArch64 `BL` writes the return address into X30. The callee must save X30 to the stack before making further calls.
- The stack must be **16-byte aligned** at all times, not just at call boundaries — misalignment is a synchronous fault on AArch64 (unlike x86 where it may be silently handled).

---

### RISC-V Calling Convention (RISC-V ELF psABI)

|Register|ABI Name|Role|Saver|
|---|---|---|---|
|x0|zero|hardwired zero|—|
|x1|ra|return address|caller|
|x2|sp|stack pointer|callee|
|x3|gp|global pointer|—|
|x4|tp|thread pointer|—|
|x5–x7|t0–t2|temporaries|caller|
|x8|s0/fp|saved / frame pointer|callee|
|x9|s1|saved register|callee|
|x10–x11|a0–a1|args / return values|caller|
|x12–x17|a2–a7|arguments|caller|
|x18–x27|s2–s11|saved registers|callee|
|x28–x31|t3–t6|temporaries|caller|

Floating-point arguments use fa0–fa7 (f10–f17), mirroring the integer convention.

---

### Variadic Functions

Variadic calling conventions (`printf`-style) require special handling because the number and types of arguments are not known at the call site at compile time.

Under **x86-64 System V**, the caller must pass the number of used XMM registers in AL (lower byte of RAX) before calling a variadic function. The callee uses `va_start`/`va_arg` macros that consult a `va_list` structure containing:

- `gp_offset`: next integer register argument offset into register save area
- `fp_offset`: next float register argument offset
- `overflow_arg_area`: pointer to stack arguments
- `reg_save_area`: pointer to saved register dump area

Under **Windows ABI**, variadic arguments are always treated as if passed on the stack (the shadow space model simplifies this).

---

### Struct Passing and Return

How structs are passed depends on their size and field classification. The System V AMD64 ABI classification algorithm:

<svg viewBox="0 0 560 320" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <text x="280" y="22" text-anchor="middle" font-size="13" font-weight="bold" fill="#e2e8f0">System V AMD64 Struct Classification</text> <!-- Start --> <rect x="210" y="35" width="140" height="30" rx="15" fill="#1e3a5f" stroke="#3b82f6"/> <text x="280" y="55" text-anchor="middle" fill="#93c5fd">struct argument</text> <!-- Size check --> <rect x="195" y="90" width="170" height="30" rx="4" fill="#1e293b" stroke="#64748b"/> <text x="280" y="110" text-anchor="middle" fill="#e2e8f0">size > 16 bytes?</text> <line x1="280" y1="120" x2="280" y2="90" stroke="#64748b"/> <line x1="280" y1="65" x2="280" y2="90" stroke="#64748b"/> <!-- Yes → memory --> <line x1="365" y1="105" x2="440" y2="105" stroke="#64748b"/> <text x="395" y="100" fill="#f59e0b" font-size="11">yes</text> <rect x="440" y="90" width="100" height="30" rx="4" fill="#292524" stroke="#78716c"/> <text x="490" y="110" text-anchor="middle" fill="#fde68a">pass in memory</text> <text x="490" y="130" text-anchor="middle" fill="#fde68a">(ptr in RDI)</text> <!-- No → field check --> <line x1="280" y1="120" x2="280" y2="150" stroke="#64748b"/> <text x="285" y="140" fill="#f59e0b" font-size="11">no</text> <rect x="175" y="150" width="210" height="30" rx="4" fill="#1e293b" stroke="#64748b"/> <text x="280" y="170" text-anchor="middle" fill="#e2e8f0">any unaligned / x87 field?</text> <!-- Yes → memory --> <line x1="385" y1="165" x2="440" y2="165" stroke="#64748b"/> <text x="405" y="160" fill="#f59e0b" font-size="11">yes</text> <line x1="490" y1="120" x2="490" y2="165" stroke="#78716c" stroke-dasharray="3,2"/> <line x1="490" y1="165" x2="490" y2="165" stroke="#78716c"/> <!-- No → classify 8-byte chunks --> <line x1="280" y1="180" x2="280" y2="210" stroke="#64748b"/> <text x="285" y="200" fill="#f59e0b" font-size="11">no</text> <rect x="155" y="210" width="250" height="30" rx="4" fill="#1e293b" stroke="#64748b"/> <text x="280" y="230" text-anchor="middle" fill="#e2e8f0">classify each 8-byte chunk</text> <!-- Integer chunk --> <line x1="195" y1="240" x2="130" y2="270" stroke="#64748b"/> <rect x="60" y="270" width="140" height="30" rx="4" fill="#0f2027" stroke="#334155"/> <text x="130" y="290" text-anchor="middle" fill="#86efac">INTEGER → GPR</text> <text x="130" y="308" text-anchor="middle" fill="#64748b" font-size="11">(RDI/RSI/RDX...)</text> <!-- SSE chunk --> <line x1="365" y1="240" x2="430" y2="270" stroke="#64748b"/> <rect x="360" y="270" width="140" height="30" rx="4" fill="#0f2027" stroke="#334155"/> <text x="430" y="290" text-anchor="middle" fill="#86efac">SSE → XMM reg</text> <text x="430" y="308" text-anchor="middle" fill="#64748b" font-size="11">(XMM0/XMM1...)</text> </svg>

---

### Prologue and Epilogue

Every non-leaf function that uses the frame pointer follows a standard pattern.

**x86-64 standard prologue:**

```asm
push    rbp           ; save caller's frame pointer
mov     rbp, rsp      ; establish new frame pointer
sub     rsp, N        ; allocate N bytes for locals (N must keep RSP 16-byte aligned)
push    rbx           ; save any callee-saved registers used
push    r12
```

**x86-64 standard epilogue:**

```asm
pop     r12           ; restore callee-saved registers (reverse order)
pop     rbx
mov     rsp, rbp      ; collapse the frame
pop     rbp           ; restore caller's frame pointer
ret                   ; pop return address → jump
```

Modern compilers frequently emit **frame-pointer-omission (FPO)** — RBP is repurposed as a general register, and the stack layout is tracked statically via `.eh_frame` / DWARF CFI records. This improves performance but complicates manual stack walking.

---

### Name Mangling

C compilers emit symbol names unmodified (with an optional leading underscore on some platforms). C++ must encode overload resolution information into the symbol name because multiple functions can share the same source name.

**Example — Itanium C++ ABI (GCC, Clang):**

```cpp
namespace net {
    int connect(const char* host, int port);
}
```

Mangled symbol: `_ZN3net7connectEPKci`

Decomposed:

- `_Z` — mangled name prefix
- `N` — nested name
- `3net` — namespace `net` (length-prefixed)
- `7connect` — function name
- `E` — end of nested name
- `PKc` — `const char*` (pointer to const char)
- `i` — `int`

MSVC uses a completely different mangling scheme, incompatible with the Itanium ABI, which is why mixing GCC-compiled and MSVC-compiled C++ objects requires `extern "C"` at boundaries.

---

### System Call ABI

System calls use a separate convention from function calls because they cross the user/kernel privilege boundary via a software interrupt or dedicated instruction.

**x86-64 Linux system call convention:**

|Field|Register|
|---|---|
|System call number|RAX|
|Argument 1|RDI|
|Argument 2|RSI|
|Argument 3|RDX|
|Argument 4|R10 (not RCX — RCX is clobbered by `syscall`)|
|Argument 5|R8|
|Argument 6|R9|
|Return value|RAX|
|Error indicator|Negative RAX (−errno)|
|Instruction|`syscall`|

The `syscall` instruction saves RIP into RCX and RFLAGS into R11 — both are clobbered. Kernel may clobber RCX, R11 in addition.

---

### ABI Stability and Breaking Changes

An ABI break occurs when a change in a library causes already-compiled code to malfunction without recompilation. Common ABI-breaking changes:

- Adding a virtual function to a class (shifts vtable indices)
- Changing the size or alignment of a struct
- Reordering struct fields
- Changing a function signature
- Changing calling convention of an exported symbol

ABI stability is a significant engineering constraint for system libraries. Linux distributions maintain strict ABI stability for `libc`. C++ standard library implementations version their ABI (GCC's `libstdc++` has maintained backward ABI compatibility since GCC 3.4, with an opt-in ABI v2 for some containers since GCC 5).

---

**Conclusion**

The calling convention and ABI form the invisible contract that makes binary composition possible. Violations — mismatched register expectations, incorrect stack alignment, wrong struct layout assumptions — produce failures that are deterministic but difficult to diagnose without understanding the underlying protocol. Mastery of at least the x86-64 System V ABI is essential for systems programming, compiler development, debugging at the assembly level, and writing interoperability layers between languages or runtimes.

**Next Steps**

Proceed to **Case Studies: x86, ARM, MIPS, RISC-V** to examine how these ABI principles are realized in the full ISA context of each architecture, including their historical evolution and design rationale.

---

