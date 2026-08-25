## Memory Models


Memory models define how addresses are generated, the size of pointers and addresses, and the layout of code and data segments. x64 introduces new memory models that leverage the expanded address space while maintaining efficiency.

### x64 Address Space

x64 theoretically supports 64-bit addresses (16 exabytes), but practical implementations use fewer bits:

**Current implementation limits**:

- **48-bit addressing**: Most current processors (256 TB virtual address space)
- **57-bit addressing**: Some newer processors with 5-level paging (128 PB)
- **Canonical addresses**: Addresses must be sign-extended from the implemented bits

**Canonical address format** (48-bit):

```
Canonical addresses:
  0x0000000000000000 to 0x00007FFFFFFFFFFF  (lower half, user space)
  0xFFFF800000000000 to 0xFFFFFFFFFFFFFFFF  (upper half, kernel space)

Non-canonical addresses (cause #GP fault):
  0x0000800000000000 to 0xFFFF7FFFFFFFFFFF
```

Bit 47 must be sign-extended to bits 48-63. Addresses that don't follow this pattern are non-canonical and cause general protection faults.

**Example** checking canonical address:

```nasm
; Check if address in RAX is canonical (48-bit)
mov rbx, rax
sar rbx, 47                           ; Sign-extend bit 47
sar rax, 47                           ; Sign-extend again
cmp rax, rbx                          ; Should be equal if canonical
jne non_canonical_address

canonical:
    ; Address is valid
    
non_canonical_address:
    ; Handle error
```

### Code Models

Code models define how code and data are positioned in memory and what addressing modes are used. x64 defines several code models for different usage scenarios.

#### Small Code Model

**Characteristics**:

- Default model for most applications
- Code and data fit within 2 GB
- All symbols within ±2 GB of each other
- Uses 32-bit displacements (sign-extended to 64 bits)
- Most efficient addressing modes

**Address ranges**:

- Code, data, BSS: Within ±2 GB range
- Total program size: < 2 GB

**Addressing modes used**:

```nasm
; RIP-relative with 32-bit displacement
mov rax, [rel symbol]                 ; symbol within ±2 GB of RIP

; Direct addressing with 32-bit displacement
mov rax, [rbx + offset]               ; offset is 32-bit

; Function calls with 32-bit relative offset
call function_name                    ; function within ±2 GB
```

**Example** in small code model:

```nasm
section .data
small_data: dq 42
small_array: times 1000 dq 0

section .text
global small_model_func
small_model_func:
    ; All data within ±2 GB, use simple addressing
    mov rax, [rel small_data]
    lea rbx, [rel small_array]
    
    ; Function calls use 32-bit relative offsets
    call another_function
    
    ret
```

#### Kernel Code Model

**Characteristics**:

- Used for operating system kernels
- Code and data in upper 2 GB of address space (negative addresses)
- Symbols at 0xFFFFFFFF80000000 or higher
- Uses 32-bit sign-extended addressing

**Address ranges**:

- Code: 0xFFFFFFFF80000000 to 0xFFFFFFFFFFFFFFFF
- All kernel code and data in highest 2 GB

**Addressing in kernel model**:

```nasm
; Kernel code typically loaded high in address space
section .text
global kernel_function
kernel_function:
    ; Code at high addresses (e.g., 0xFFFFFFFF80100000)
    mov rax, [rel kernel_data]        ; RIP-relative works
    
    ; Absolute addresses are high
    mov rbx, 0xFFFFFFFF80200000       ; Kernel address
    mov rcx, [rbx]
    
    ret

section .data
kernel_data: dq 0xDEADBEEF
```

#### Medium Code Model

**Characteristics**:

- Code within 2 GB range (uses 32-bit relative calls)
- Data can be anywhere in address space
- Uses 64-bit absolute addresses for data
- Suitable for large data sets with moderate code size

**Addressing characteristics**:

```nasm
; Code uses 32-bit relative calls
call function_name                    ; Within ±2 GB

; Data uses 64-bit absolute addressing
section .data
large_data: times 1000000 dq 0

section .text
medium_model_func:
    ; Load 64-bit absolute address for data
    movabs rax, large_data            ; 64-bit immediate address
    mov rbx, [rax]
    
    ret
```

#### Large Code Model

**Characteristics**:

- No size restrictions on code or data
- Code and data can be anywhere in address space
- Uses 64-bit absolute addresses for everything
- Largest, slowest, but most flexible

**Addressing in large model**:

```nasm
section .text
large_model_func:
    ; Load function address with 64-bit immediate
    movabs rax, target_function       ; 64-bit absolute address
    call rax                          ; Indirect call
    
    ; Load data address with 64-bit immediate
    movabs rbx, large_data_array
    mov rcx, [rbx]
    
    ret

section .data
large_data_array: times 10000000 dq 0
```

**Example** comparing code models:

```nasm
; Small model - most efficient
section .text
small_func:
    call target                       ; 5 bytes (E8 disp32)
    mov rax, [rel data]              ; RIP-relative
    ret

; Large model - most flexible but larger/slower
section .text
large_func:
    movabs rax, target                ; 10 bytes (48 B8 imm64)
    call rax                          ; 2 bytes (FF D0)
    movabs rax, data                  ; 10 bytes
    mov rax, [rax]                    ; 3 bytes
    ret
```

### Memory Model Selection

**Guidelines for choosing memory models**:

**Small model** (default):

- Applications under 2 GB total size
- Most user-space programs
- Shared libraries
- Best performance and code density

**Kernel model**:

- Operating system kernels
- Code that runs in upper address space
- High-security environments

**Medium model**:

- Applications with large data sets (> 2 GB)
- Moderate code size (< 2 GB)
- Scientific computing, databases

**Large model**:

- Extremely large applications (code + data > 2 GB)
- Dynamic code generation across large address ranges
- Rare in practice due to performance overhead

**Setting code model** (compiler flags):

```bash
gcc -mcmodel=small program.c          # Default
gcc -mcmodel=kernel kernel.c          # Kernel code
gcc -mcmodel=medium large_data.c      # Large data
gcc -mcmodel=large huge_app.c         # No limits
```

### Thread-Local Storage (TLS)

TLS provides per-thread variables, essential for thread-safe programming. x64 implements TLS through segment registers and specific addressing modes.

**TLS segments**:

- **FS register**: Points to TLS in x64 Linux/BSD
- **GS register**: Points to TLS in x64 Windows; kernel space in Linux

**TLS addressing modes**:

**FS-relative addressing** (Linux/BSD user space):

```nasm
; Access thread-local variable
mov rax, fs:[offset]                  ; Load from TLS

; Common pattern for TLS access
mov rax, fs:[0]                       ; Load TLS base pointer
mov rbx, [rax + tls_variable_offset]
```

**GS-relative addressing** (Windows or Linux kernel):

```nasm
; Windows TLS access
mov rax, gs:[offset]

; Linux kernel per-CPU data
mov rax, gs:[per_cpu_offset]
```

**Example** of TLS variable access:

```nasm
; Linux x64 TLS access pattern
section .tbss
thread_local_counter: resq 1          ; Thread-local variable

section .text
global increment_thread_counter
increment_thread_counter:
    ; Get TLS base
    mov rax, fs:[0]
    
    ; Access thread-local variable
    ; (offset calculated by linker)
    lea rbx, [rax + thread_local_counter@tpoff]
    inc qword [rbx]
    
    ret
```

**TLS models** (different access patterns):

**Local Exec** (fastest, executable-only):

```nasm
; Direct FS-relative access
mov rax, fs:[thread_var@tpoff]
```

**Initial Exec** (shared libraries loaded at startup):

```nasm
; GOT-based TLS access
mov rax, [rel thread_var wrt ..gottpoff]
mov rbx, fs:[rax]
```

**General Dynamic** (fully dynamic, slowest):

```nasm
; Runtime resolution via TLS descriptor
lea rax, [rel thread_var wrt ..tlsgd]
call __tls_get_addr wrt ..plt
mov rbx, [rax]
```

### Stack Layout in x64

The stack grows downward (toward lower addresses) and must maintain 16-byte alignment before call instructions.

**Stack frame structure**:

```
High addresses
+------------------+
| Arguments 7+     | (if needed, older x64 ABI)
+------------------+
| Return address   | <-- Pushed by CALL
+------------------+
| Saved RBP        | <-- Pushed by function prologue
+------------------+ <-- RBP points here
| Local variables  |
+------------------+
| Saved registers  |
+------------------+
| Temp storage     |
+------------------+
| Alignment padding|
+------------------+
| Shadow space (32)| (Windows x64 only)
+------------------+ <-- RSP (16-byte aligned)
Low addresses
```

**Stack alignment requirements**:

- **Before CALL**: RSP must be 16-byte aligned
- **After CALL**: RSP is misaligned by 8 bytes (return address)
- **Function prologue**: Must adjust RSP to restore 16-byte alignment

**Example** of proper stack alignment:

```nasm
global aligned_function
aligned_function:
    push rbp                          ; RSP now misaligned (- 8)
    mov rbp, rsp
    sub rsp, 32                       ; Allocate space, restore alignment
    ; RSP is now 16-byte aligned
    
    ; Local variables at [rbp - 8], [rbp - 16], etc.
    
    ; Prepare to call function
    ; RSP must be 16-byte aligned before CALL
    call other_function
    
    leave                             ; mov rsp, rbp; pop rbp
    ret
```

**Red zone** (System V ABI only):

- 128 bytes below RSP reserved for leaf functions
- Can be used without adjusting RSP
- Not present in Windows x64

**Example** using red zone:

```nasm
; Leaf function (calls no other functions)
leaf_function:
    ; Can use [rsp - 8] through [rsp - 128] without adjusting RSP
    mov [rsp - 8], rdi                ; Save argument
    mov [rsp - 16], rsi
    
    ; Computation...
    mov rax, [rsp - 8]
    add rax, [rsp - 16]
    
    ret                               ; No stack cleanup needed
```

