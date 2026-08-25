## Position-Independent Code (PIC)


Position-independent code is executable code that functions correctly regardless of its absolute memory address. PIC is essential for shared libraries, security features like ASLR (Address Space Layout Randomization), and modern operating system design.

### Why PIC Matters in x64

In x64 systems, PIC has become increasingly important:

**Shared libraries**: Multiple processes share a single copy of library code in memory, but each process maps the library at potentially different virtual addresses.

**ASLR**: Modern operating systems randomize load addresses to mitigate security vulnerabilities, making absolute addresses unpredictable.

**Kernel requirements**: Many operating systems mandate PIC for shared libraries and position-independent executables (PIE).

**Code reusability**: PIC enables code to be loaded anywhere in the address space without modification or relocation.

### RIP-Relative Addressing

x64 introduces RIP-relative addressing, which is the primary mechanism for implementing PIC. RIP (Instruction Pointer) addressing calculates effective addresses relative to the current instruction pointer.

**RIP-relative addressing format**:

```nasm
mov rax, [rel symbol]             ; Load from symbol relative to RIP
mov rax, [rip + offset]           ; Explicit RIP-relative addressing
lea rax, [rel symbol]             ; Load effective address of symbol
```

**How RIP-relative addressing works**:

```nasm
; At address 0x400010:
mov rax, [rel data_value]         ; Encoded as: mov rax, [rip + disp32]

; If data_value is at 0x401000:
; Displacement = 0x401000 - (0x400010 + instruction_length)
; Displacement = 0x401000 - 0x400017 = 0xFE9
; Instruction encodes: mov rax, [rip + 0xFE9]
```

The displacement is calculated at assembly/link time, and the instruction always references the correct location regardless of where the code is loaded.

**Example** comparing absolute vs RIP-relative addressing:

```nasm
; Absolute addressing (not position-independent)
section .data
value: dq 42

section .text
mov rax, [value]                  ; Uses absolute 64-bit address
; Requires relocation if loaded at different address

; RIP-relative addressing (position-independent)
section .data
value: dq 42

section .text
mov rax, [rel value]              ; Uses RIP-relative addressing
; Works at any load address
```

### Global Offset Table (GOT)

The Global Offset Table is a data structure used to access global variables and functions in shared libraries. The GOT contains absolute addresses that are resolved at load time by the dynamic linker.

**GOT structure and purpose**:

- Located in a writable data section
- Contains pointers to global symbols (variables and functions)
- Allows code section to remain read-only and position-independent
- Populated by dynamic linker at load time

**Accessing global variables via GOT**:

```nasm
; Access external variable through GOT
extern global_var

section .text
; Get address of GOT entry for global_var
mov rax, [rel global_var wrt ..got]      ; Load GOT entry address
mov rbx, [rax]                            ; Dereference to get actual address
mov rcx, [rbx]                            ; Load value from global_var

; More efficient with LEA:
lea rax, [rel global_var wrt ..got]
mov rax, [rax]                            ; Load pointer from GOT
mov rax, [rax]                            ; Load actual value
```

**GOT entry structure**:

```
GOT Entry for symbol:
  +0: Absolute address of symbol (filled by dynamic linker)
```

**Example** of GOT-based access pattern:

```nasm
global access_global_data

extern shared_counter                 ; External global variable

section .data
local_data: dq 100

section .text
access_global_data:
    ; Access local data (RIP-relative, direct)
    mov rax, [rel local_data]
    
    ; Access external data (via GOT)
    mov rbx, [rel shared_counter wrt ..got]
    mov rcx, [rbx]                    ; Load value from shared_counter
    
    add rax, rcx
    ret
```

### Procedure Linkage Table (PLT)

The Procedure Linkage Table enables position-independent function calls to external functions in shared libraries. The PLT implements lazy binding, where function addresses are resolved on first call rather than at load time.

**PLT structure**:

- PLT stub: Small code fragment that performs indirect jump
- GOT entry: Contains either the stub address (before resolution) or actual function address (after resolution)
- Dynamic linker: Resolves addresses on first call

**PLT call mechanism (lazy binding)**:

Initial state (before first call):

```
PLT Stub:
  jmp [GOT_entry]          ; GOT_entry points back into PLT
  push reloc_index
  jmp PLT_resolver

GOT Entry:
  Address of push instruction in PLT stub
```

After first call:

```
GOT Entry:
  Actual address of target function (resolved by dynamic linker)
```

**Example** of calling external function via PLT:

```nasm
extern printf                         ; External function

section .data
format_str: db "Value: %d", 10, 0

section .text
global main
main:
    push rbp
    mov rbp, rsp
    
    ; Call printf via PLT
    lea rdi, [rel format_str]         ; First argument (format string)
    mov esi, 42                       ; Second argument (value)
    xor eax, eax                      ; No vector registers used
    
    call printf wrt ..plt             ; Call through PLT
    ; Assembler generates: call [printf@plt]
    ; On first call: jumps to PLT stub, dynamic linker resolves address
    ; On subsequent calls: direct jump to resolved function
    
    xor eax, eax
    pop rbp
    ret
```

**PLT call sequence details**:

```nasm
; First call to external_func:
call external_func@plt

; PLT stub for external_func:
external_func@plt:
    jmp [external_func@got]           ; Jump to GOT entry
    ; On first call, GOT entry points to next instruction
    push reloc_index                  ; Push relocation index
    jmp PLT0                          ; Jump to resolver

PLT0:
    ; Dynamic linker resolver stub
    push [GOT+8]                      ; Push link_map
    jmp [GOT+16]                      ; Jump to dynamic linker
    ; Dynamic linker resolves address and updates GOT entry

; Subsequent calls:
call external_func@plt
external_func@plt:
    jmp [external_func@got]           ; GOT now contains actual function address
    ; Direct jump to target function
```

### Creating PIC Code

**Key principles for writing PIC**:

**Use RIP-relative addressing for all data references**:

```nasm
section .data
local_value: dq 42

section .text
; PIC compliant
mov rax, [rel local_value]

; NOT PIC compliant (uses absolute addressing)
mov rax, [local_value]
```

**Access external symbols via GOT**:

```nasm
extern global_symbol

; PIC compliant
mov rax, [rel global_symbol wrt ..got]
mov rax, [rax]

; Alternative syntax (some assemblers)
mov rax, [global_symbol@GOTPCREL + rip]
```

**Use LEA for address calculations**:

```nasm
section .data
data_array: dq 1, 2, 3, 4

section .text
; PIC compliant - load address relative to RIP
lea rax, [rel data_array]

; NOT PIC compliant - load absolute address
mov rax, data_array
```

**Call external functions via PLT**:

```nasm
extern external_func

; PIC compliant
call external_func wrt ..plt

; Alternative syntax
call external_func@plt
```

**Example** of complete PIC function:

```nasm
global calculate_sum
extern helper_function

section .data
multiplier: dq 3
result_storage: dq 0

section .text
calculate_sum:
    push rbp
    mov rbp, rsp
    
    ; rdi = first argument
    ; rsi = second argument
    
    ; Load multiplier (RIP-relative)
    mov rax, [rel multiplier]
    imul rax, rdi
    
    ; Call external function via PLT
    mov rdi, rax
    call helper_function wrt ..plt
    
    ; Store result (RIP-relative)
    mov [rel result_storage], rax
    
    pop rbp
    ret
```

### PIC Performance Considerations

[Inference] PIC code may have slight performance overhead compared to non-PIC code due to additional indirections:

**GOT access overhead**: Accessing global variables requires loading from GOT, then dereferencing the pointer (two memory accesses instead of one).

**PLT call overhead**: Function calls through PLT involve an extra indirect jump on first call, though subsequent calls are nearly as fast as direct calls after resolution.

**Code size**: PIC code is typically slightly larger due to additional instructions for indirection.

**Register usage**: GOT-relative addressing may consume additional registers for holding intermediate addresses.

[Inference] Modern processors minimize these overheads through aggressive caching and branch prediction, making PIC performance impact negligible for most applications.

**Optimization techniques**:

**Cache GOT pointers**:

```nasm
; Less efficient - multiple GOT accesses
mov rax, [rel global_var wrt ..got]
mov rbx, [rax]
mov rcx, [rel global_var wrt ..got]
mov rdx, [rcx]

; More efficient - cache GOT pointer
mov rax, [rel global_var wrt ..got]    ; Load GOT entry once
mov rbx, [rax]                          ; Use cached pointer
mov rdx, [rax]                          ; Reuse cached pointer
```

**Use local variables when possible**:

```nasm
section .data
local_counter: dq 0                     ; Direct RIP-relative access

extern global_counter                   ; Requires GOT access

section .text
; Prefer local variables for frequently accessed data
inc qword [rel local_counter]           ; Single memory access
```

### Position-Independent Executables (PIE)

PIE extends PIC concepts to entire executables, not just shared libraries. PIE executables can be loaded at any address, enabling full ASLR protection.

**PIE characteristics**:

- Entire program is position-independent
- All code uses RIP-relative addressing
- Stronger ASLR protection
- Required by some security-focused systems

**Compiling as PIE** (typical compiler flags):

```bash
gcc -fPIE -pie program.c -o program      # C program as PIE
nasm -f elf64 program.asm                # Assemble with PIC support
ld -pie program.o -o program             # Link as PIE
```

**Example** of PIE-compatible entry point:

```nasm
global _start

section .data
message: db "Hello from PIE", 10
msg_len: equ $ - message

section .text
_start:
    ; All addressing is position-independent
    
    ; sys_write (syscall number 1)
    mov rax, 1                        ; sys_write
    mov rdi, 1                        ; stdout
    lea rsi, [rel message]            ; RIP-relative address
    mov rdx, msg_len
    syscall
    
    ; sys_exit (syscall number 60)
    mov rax, 60                       ; sys_exit
    xor rdi, rdi                      ; exit code 0
    syscall
```

