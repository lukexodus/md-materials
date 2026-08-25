## Assembly Language Basics


Assembly language is the lowest symbolic representation of a processor's instruction set — a thin, structured layer over raw machine code that replaces binary opcodes and addresses with human-readable mnemonics, labels, and directives. It maintains a strict one-to-one correspondence with machine instructions (with the exception of pseudo-instructions, which the assembler expands).

---

### Structure of an Assembly Program

An assembly source file is divided into logical sections. The exact syntax varies by assembler (NASM, GAS, MASM), but the conceptual structure is universal.

```nasm
section .data           ; initialized data
    msg db "hello", 0   ; byte string with null terminator

section .bss            ; uninitialized data (zero-filled at load)
    buf resb 64         ; reserve 64 bytes

section .text           ; executable code
    global _start

_start:
    mov eax, 1
    mov ebx, 0
    int 0x80            ; Linux syscall: exit(0)
```

|Section|Purpose|
|---|---|
|`.data`|Initialized global/static variables|
|`.bss`|Uninitialized globals; no space in binary, allocated at load|
|`.text`|Machine instructions|
|`.rodata`|Read-only constants (string literals, lookup tables)|

---

### Instruction Anatomy

Every assembly instruction follows the same basic structure:

```
[label:]  mnemonic  [operand1 [, operand2 [, operand3]]]  [; comment]
```

- **Label** — a symbolic name that resolves to the address of the next instruction or datum. Optional on any line.
- **Mnemonic** — the operation name (`mov`, `add`, `jmp`, `call`).
- **Operands** — source(s) and destination. Order is assembler-convention-dependent (Intel: `dst, src`; AT&T: `src, dst`).
- **Comment** — ignored by the assembler; delimited by `;` (NASM/MASM) or `#` (GAS).

---

### Operand Types

|Type|Intel Syntax Example|Meaning|
|---|---|---|
|Immediate|`mov eax, 42`|Literal constant embedded in instruction|
|Register|`mov eax, ebx`|Value from a named register|
|Direct memory|`mov eax, [0x4000]`|Value at fixed address|
|Register indirect|`mov eax, [ebx]`|Value at address in `ebx`|
|Base + offset|`mov eax, [ebx+8]`|Address computed as `ebx + 8`|
|Scaled index|`mov eax, [ebx+ecx*4]`|Array indexing: `ebx + ecx×4`|

---

### Core Instruction Classes

#### Data Movement

```nasm
mov   eax, ebx        ; eax ← ebx
mov   eax, [esp+8]    ; eax ← memory at esp+8
mov   [ebp-4], eax    ; memory at ebp-4 ← eax
movzx eax, byte [esi] ; zero-extend byte to 32-bit
movsx eax, byte [esi] ; sign-extend byte to 32-bit
lea   eax, [ebx+ecx*4+8] ; load effective address (no memory read)
xchg  eax, ebx        ; swap
push  eax             ; esp ← esp-4; mem[esp] ← eax
pop   eax             ; eax ← mem[esp]; esp ← esp+4
```

`lea` computes an address but never dereferences it — frequently used for fast arithmetic (e.g., `lea eax, [eax+eax*4]` computes `eax × 5`).

#### Arithmetic and Logic

```nasm
add   eax, ebx        ; eax ← eax + ebx
sub   eax, 1          ; eax ← eax - 1
imul  eax, ecx, 5     ; eax ← ecx * 5  (signed)
idiv  ecx             ; edx:eax ÷ ecx → quotient in eax, remainder in edx
inc   eax             ; eax ← eax + 1
dec   eax             ; eax ← eax - 1
neg   eax             ; eax ← -eax (two's complement)
and   eax, 0xFF       ; bitwise AND (mask low byte)
or    eax, ebx        ; bitwise OR
xor   eax, eax        ; eax ← 0  (canonical zero idiom)
not   eax             ; bitwise NOT
shl   eax, 2          ; logical left shift by 2 (×4)
shr   eax, 1          ; logical right shift by 1 (÷2, unsigned)
sar   eax, 1          ; arithmetic right shift by 1 (÷2, signed)
```

#### Comparison and Flags

```nasm
cmp   eax, ebx        ; compute eax - ebx, set flags, discard result
test  eax, eax        ; compute eax AND eax, set flags, discard result
```

Both instructions set the **EFLAGS** register without storing the result. Subsequent conditional jumps read the flags.

Key flags:

|Flag|Name|Set when|
|---|---|---|
|ZF|Zero|Result is zero|
|SF|Sign|MSB of result is 1|
|CF|Carry|Unsigned carry/borrow out|
|OF|Overflow|Signed overflow occurred|
|PF|Parity|Low byte has even number of 1-bits|

#### Control Flow

```nasm
jmp   label           ; unconditional jump
je    label           ; jump if ZF=1  (equal)
jne   label           ; jump if ZF=0  (not equal)
jl    label           ; jump if SF≠OF (signed less than)
jg    label           ; jump if ZF=0 and SF=OF (signed greater)
jb    label           ; jump if CF=1  (unsigned below)
ja    label           ; jump if CF=0 and ZF=0 (unsigned above)
call  label           ; push return address, jump to label
ret                   ; pop return address, jump to it
```

The signed (`jl`, `jg`, `jle`, `jge`) and unsigned (`jb`, `ja`, `jbe`, `jae`) variants are distinct because they test different flag combinations. Using the wrong variant on a signed comparison is a common source of bugs.

---

### The Stack

The stack is a contiguous region of memory that grows **downward** (toward lower addresses) on x86 and most modern architectures. `esp` (x86) or `rsp` (x86-64) always points to the current top (lowest address in use).

<svg viewBox="0 0 500 320" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13"> <!-- Stack frames --> <rect x="150" y="20" width="200" height="40" fill="#1a237e" stroke="#5c6bc0" stroke-width="1.2"/> <text x="250" y="45" text-anchor="middle" fill="#9fa8da">caller's frame</text> <rect x="150" y="60" width="200" height="40" fill="#1b5e20" stroke="#66bb6a" stroke-width="1.2"/> <text x="250" y="85" text-anchor="middle" fill="#a5d6a7">return address</text> <rect x="150" y="100" width="200" height="40" fill="#1b5e20" stroke="#66bb6a" stroke-width="1.2"/> <text x="250" y="125" text-anchor="middle" fill="#a5d6a7">saved ebp</text> <rect x="150" y="140" width="200" height="40" fill="#263238" stroke="#78909c" stroke-width="1.2"/> <text x="250" y="165" text-anchor="middle" fill="#cfd8dc">local var 1 [ebp-4]</text> <rect x="150" y="180" width="200" height="40" fill="#263238" stroke="#78909c" stroke-width="1.2"/> <text x="250" y="205" text-anchor="middle" fill="#cfd8dc">local var 2 [ebp-8]</text> <rect x="150" y="220" width="200" height="40" fill="#37474f" stroke="#78909c" stroke-width="1" stroke-dasharray="4,3"/> <text x="250" y="245" text-anchor="middle" fill="#90a4ae">(unused / next push)</text> <!-- ESP arrow --> <line x1="130" y1="240" x2="150" y2="240" stroke="#ef9a9a" stroke-width="1.5" marker-end="url(#arr)"/> <text x="60" y="244" fill="#ef9a9a" font-size="12">esp</text> <!-- EBP arrow --> <line x1="130" y1="120" x2="150" y2="120" stroke="#fff59d" stroke-width="1.5" marker-end="url(#arr)"/> <text x="60" y="124" fill="#fff59d" font-size="12">ebp</text> <!-- Address direction -->

<text x="370" y="30" fill="#888" font-size="11">high addr</text> <line x1="390" y1="35" x2="390" y2="255" stroke="#555" stroke-width="1" marker-end="url(#arr2)"/> <text x="370" y="270" fill="#888" font-size="11">low addr</text> <text x="370" y="283" fill="#ef9a9a" font-size="11">stack grows ↓</text>

<defs> <marker id="arr" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#ef9a9a"/> </marker> <marker id="arr2" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#555"/> </marker> </defs> </svg>

`ebp` serves as the **frame pointer** — a stable reference to the current function's stack frame. Local variables are accessed at negative offsets from `ebp`; function arguments passed on the stack are at positive offsets.

---

### The Standard Function Prologue and Epilogue

Every function that uses the stack follows a fixed entry and exit sequence (cdecl and similar conventions):

```nasm
; --- Prologue ---
push  ebp          ; save caller's base pointer
mov   ebp, esp     ; establish new frame pointer
sub   esp, 16      ; allocate 16 bytes for locals

; --- Function body ---
mov   [ebp-4], eax ; store local variable

; --- Epilogue ---
mov   esp, ebp     ; deallocate locals
pop   ebp          ; restore caller's base pointer
ret                ; return to caller
```

The `enter` and `leave` instructions are hardware shortcuts for the prologue and epilogue respectively, though compilers typically emit the explicit sequence for performance transparency.

---

### Labels and Control Flow Patterns

#### If–Else

```nasm
    cmp   eax, 0
    je    else_branch
    ; then-body
    jmp   end_if
else_branch:
    ; else-body
end_if:
```

#### Loop

```nasm
    mov   ecx, 10       ; loop counter
loop_start:
    ; loop body
    dec   ecx
    jnz   loop_start    ; jump if ecx ≠ 0
```

x86 also provides the `loop` instruction, which decrements `ecx` and branches if nonzero, but modern compilers avoid it due to poor performance on recent microarchitectures.

#### Array Traversal

```nasm
    mov   esi, arr_base   ; pointer to array start
    mov   ecx, len
traverse:
    mov   eax, [esi]      ; load element
    ; process eax
    add   esi, 4          ; advance by element size (4 bytes for int)
    dec   ecx
    jnz   traverse
```

---

### Assembler Directives

Directives are assembler commands, not processor instructions. They control layout, data definition, and linkage — they produce no opcodes.

|Directive (NASM)|Meaning|
|---|---|
|`db` / `dw` / `dd` / `dq`|Define byte / word / dword / qword|
|`resb` / `resw` / `resd`|Reserve N bytes/words/dwords (`.bss`)|
|`equ`|Define a compile-time constant|
|`global`|Export symbol to linker|
|`extern`|Declare symbol defined in another object file|
|`section`|Switch to named section|
|`%define`|Macro text substitution (NASM)|
|`times N`|Repeat directive N times|

```nasm
ARRAY_LEN equ 64           ; compile-time constant
    times ARRAY_LEN db 0   ; 64 zero bytes
```

---

### Intel vs AT&T Syntax

The same x86 instruction encodes differently depending on the assembler's syntax convention.

|Feature|Intel (NASM/MASM)|AT&T (GAS)|
|---|---|---|
|Operand order|`dst, src`|`src, dst`|
|Register names|`eax`|`%eax`|
|Immediates|`42`|`$42`|
|Memory access|`[ebx+4]`|`4(%ebx)`|
|Size suffix|Absent (inferred)|`movl`, `movb`, `movw`|

**Example — the same instruction:**

```nasm
; Intel
mov eax, [ebx+4]

; AT&T
movl 4(%ebx), %eax
```

GAS (GNU Assembler) defaults to AT&T syntax; it accepts Intel syntax with `.intel_syntax noprefix`. Most vendor documentation and reverse engineering tools use Intel syntax.

---

### Pseudo-Instructions

Some mnemonics are not real machine instructions but are expanded by the assembler into one or more real instructions for convenience.

|Pseudo-instruction|Expansion|
|---|---|
|`mov eax, imm64` (NASM 64-bit)|`movabs rax, imm64`|
|`not eax` then `add eax,1`|Two-instruction negation|
|`ret N`|`add esp, N` then `ret` (cdecl stack cleanup variant)|

RISC architectures make heavier use of pseudo-instructions. On MIPS/RISC-V, `li` (load immediate), `la` (load address), `nop`, and `move` are all assembler expansions with no direct single-instruction equivalent in all cases.

---

### Examining Machine Code

Every assembly instruction assembles to a fixed or variable-length byte sequence. On x86, instructions range from 1 to 15 bytes.

```nasm
nop                  ; 90
xor eax, eax         ; 31 C0
mov eax, 1           ; B8 01 00 00 00
mov eax, [ebx+8]     ; 8B 43 08
```

Tools for inspection:

|Tool|Use|
|---|---|
|`objdump -d`|Disassemble object/binary|
|`nasm -f bin -l`|Produce listing with hex|
|`gdb disassemble`|Runtime disassembly|
|`readelf -s`|Symbol table inspection|

The listing file produced by an assembler maps each source line to its byte offset and encoded bytes — essential for understanding instruction encoding and addressing.

---

**Conclusion**

Assembly language is the direct linguistic interface to a processor's instruction set. Competence in it requires understanding operand types and their addressing modes, the role of the flags register in conditional branching, the stack discipline governing function calls, and the distinction between assembler directives and machine instructions. These fundamentals are architecture-portable in concept, even as syntax and register names differ across x86, ARM, MIPS, and RISC-V.

**Next Steps**

- Calling conventions and ABI — how arguments, return values, and callee/caller-saved registers are formalized across compilers and operating systems, and why the ABI is the contract that makes separate compilation possible.
- Addressing modes — a deeper treatment of how effective addresses are computed, and how ISA design constrains or expands the addressing modes available in a given instruction format.
- Case studies: x86, ARM, MIPS, RISC-V — concrete comparison of how the same constructs (function call, loop, conditional) map to each ISA's assembly.

---

