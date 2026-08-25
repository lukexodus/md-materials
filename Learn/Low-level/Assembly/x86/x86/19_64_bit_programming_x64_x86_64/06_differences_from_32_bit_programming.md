## Differences from 32-bit Programming


x64 introduces numerous changes from 32-bit x86, affecting registers, calling conventions, addressing modes, and programming paradigms.

### Register Extensions

x64 provides significantly more registers than 32-bit x86.

**General-purpose registers**:

- **32-bit**: 8 registers (EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP)
- **64-bit**: 16 registers (RAX, RBX, RCX, RDX, RSI, RDI, RBP, RSP, R8-R15)

**Extended register naming**:

```
R8-R15 access modes:
  R8-R15    (64-bit)
  R8D-R15D  (32-bit, zero-extends to 64)
  R8W-R15W  (16-bit)
  R8B-R15B  (8-bit, low byte)
```

**Example** using extended registers:

```nasm
; 32-bit x86 - limited registers
mov eax, [data1]
mov ebx, [data2]
mov ecx, [data3]
mov edx, [data4]
; Already used 4 of 8 registers

; 64-bit x64 - more registers available
mov rax, [rel data1]
mov rbx, [rel data2]
mov rcx, [rel data3]
mov rdx, [rel data4]
mov r8, [rel data5]
mov r9, [rel data6]
mov r10, [rel data7]
mov r11, [rel data8]
; Still have R12-R15 available
```

**XMM/YMM register extensions**:

- **32-bit SSE**: 8 XMM registers (XMM0-XMM7)
- **64-bit SSE**: 16 XMM registers (XMM0-XMM15)
- **64-bit AVX**: 16 YMM registers (YMM0-YMM15)

### Calling Conventions

x64 introduces new, more efficient calling conventions that differ significantly from 32-bit.

#### System V AMD64 ABI (Linux, BSD, macOS)

**Argument passing**:

- **Integer/pointer arguments** (in order): RDI, RSI, RDX, RCX, R8, R9
- **Floating-point arguments**: XMM0-XMM7
- **Additional arguments**: Passed on stack (right-to-left)
- **Return values**: RAX (integer/pointer), XMM0 (float/double)

**Register preservation**:

- **Caller-saved** (volatile): RAX, RCX, RDX, RSI, RDI, R8-R11, XMM0-XMM15
- **Callee-saved** (non-volatile): RBX, RBP, R12-R15
- **Special**: RSP must be preserved, RBP optionally used for frame pointer

**Example** of System V calling convention:

```nasm
global my_function
; Prototype: int64_t my_function(int64_t a, int64_t b, int64_t c, int64_t d, int64_t e, int64_t f, int64_t g)

my_function:
    push rbp
    mov rbp, rsp
    
    ; Arguments:
    ; a = RDI
    ; b = RSI
    ; c = RDX
    ; d = RCX
    ; e = R8
    ; f = R9
    ; g = [rbp + 16] (on stack)
    
    ; Save callee-saved registers if used
    push rbx
    push r12
    
    ; Use arguments
    mov rax, rdi                      ; a
    add rax, rsi                      ; + b
    add rax, rdx                      ; + c
    add rax, rcx                      ; + d
    add rax, r8                       ; + e
    add rax, r9                       ; + f
    add rax, [rbp + 16]              ; + g
    
    ; Restore callee-saved registers
    pop r12
    pop rbx
    
    pop rbp
    ret                               ; Return value in RAX
```

**Calling a function** (System V):

```nasm
; Call my_function(1, 2, 3, 4, 5, 6, 7)
mov rdi, 1                            ; First argument
mov rsi, 2                            ; Second argument
mov rdx, 3                            ; Third argument
mov rcx, 4                            ; Fourth argument
mov r8, 5                             ; Fifth argument
mov r9, 6                             ; Sixth argument
push 7                                ; Seventh argument (stack)
call my_function
add rsp, 8                            ; Clean up stack
; Result in RAX
```

#### Microsoft x64 Calling Convention (Windows)

**Argument passing**:

- **Integer/pointer arguments** (in order): RCX, RDX, R8, R9
- **Floating-point arguments**: XMM0-XMM3 (same positions as integer)
- **Additional arguments**: Passed on stack (left-to-right)
- **Shadow space**: 32 bytes reserved on stack for first 4 arguments
- **Return values**: RAX (integer/pointer), XMM0 (float/double)

**Register preservation**:

- **Caller-saved** (volatile): RAX, RCX, RDX, R8-R11, XMM0-XMM5
- **Callee-saved** (non-volatile): RBX, RBP, RDI, RSI, RSP, R12-R15, XMM6-XMM15
- **Special**: RSP must be 16-byte aligned before CALL

**Shadow space requirement**:

```
Stack before calling function:
+------------------+
| Argument 6       |
+------------------+
| Argument 5       |
+------------------+
| Shadow (RCX)     | <-- 32 bytes shadow space
| Shadow (RDX)     |    (caller allocates, callee may use)
| Shadow (R8)      |
| Shadow (R9)      |
+------------------+ <-- RSP (16-byte aligned)
```

**Example** of Windows x64 calling convention:

```nasm
global windows_function
; Prototype: int64_t windows_function(int64_t a, int64_t b, int64_t c, int64_t d, int64_t e)

windows_function:
    ; Arguments:
    ; a = RCX
    ; b = RDX
    ; c = R8
    ; d = R9
    ; e = [rsp + 40] (32 bytes shadow + 8 bytes return address)
    
    push rbp
    mov rbp, rsp
    sub rsp, 32                       ; Allocate shadow space for any calls we make
    
    ; Save non-volatile registers if needed
    push rsi
    push rdi
    
    ; Use arguments
    mov rax, rcx                      ; a
    add rax, rdx                      ; + b
    add rax, r8                       ; + c
    add rax, r9                       ; + d
    add rax, [rbp + 16]              ; + e (adjusted for saved RBP)
    
    ; Restore non-volatile registers
    pop rdi
    pop rsi
    
    add rsp, 32
    pop rbp
    ret                               ; Return value in RAX
```

**Calling a function** (Windows):

```nasm
; Call windows_function(1, 2, 3, 4, 5)
sub rsp, 40                           ; Shadow space (32) + argument 5 (8)
mov rcx, 1                            ; First argument
mov rdx, 2                            ; Second argument
mov r8, 3                             ; Third argument
mov r9, 4                             ; Fourth argument
mov qword [rsp + 32], 5              ; Fifth argument (after shadow space)
call windows_function
add rsp, 40                           ; Clean up
; Result in RAX
```

### Instruction Encoding Differences

**REX Prefix**: x64 introduces the REX prefix byte for accessing extended features:

```
REX prefix format: 0100WRXB
  W: 1 = 64-bit operand size
  R: Extension of ModR/M reg field
  X: Extension of SIB index field
  B: Extension of ModR/M r/m field, SIB base, or opcode reg
```

**Example** of REX prefix usage:

```nasm
; 32-bit operation (no REX prefix needed)
mov eax, ebx                          ; 89 D8

; 64-bit operation (REX.W prefix)
mov rax, rbx ; 48 89 D8            ; REX.W = 48h

; Using extended registers (REX.R or REX.B)
mov r8, rax ; 49 89 C0             ; REX.WR = 49h
mov rax, r8 ; 4C 89 C0             ; REX.WB = 4Ch
mov r15, r8 ; 4D 89 C7             ; REX.WRB = 4Dh
````

**Default operand size**:
- **32-bit mode**: Default operand size is 32 bits
- **64-bit mode**: Default operand size is 32 bits (except for operations that implicitly use 64-bit)
- **REX.W prefix**: Forces 64-bit operand size

**Example** of operand size behavior:
```nasm
; In 64-bit mode, these are 32-bit operations by default
mov eax, 42                           ; 32-bit operation
add ebx, ecx                          ; 32-bit operation
; Upper 32 bits of RAX, RBX are zeroed

; 64-bit operations require REX.W or register names
mov rax, 42                           ; 64-bit operation (REX.W prefix)
add rbx, rcx                          ; 64-bit operation
````

**Zero-extension behavior**: Operations on 32-bit registers automatically zero-extend to 64 bits, unlike 16-bit and 8-bit operations.

```nasm
; 32-bit operation zeros upper 32 bits
mov rax, -1                           ; RAX = 0xFFFFFFFFFFFFFFFF
mov eax, 42                           ; RAX = 0x0000000000000042 (zero-extended)

; 16-bit operation preserves upper bits
mov rax, -1                           ; RAX = 0xFFFFFFFFFFFFFFFF
mov ax, 42                            ; RAX = 0xFFFFFFFFFFFF002A (upper bits preserved)

; 8-bit operation preserves upper bits
mov rax, -1                           ; RAX = 0xFFFFFFFFFFFFFFFF
mov al, 42                            ; RAX = 0xFFFFFFFFFFFFFF2A (upper bits preserved)
```

### Addressing Modes

x64 removes and modifies several addressing modes from 32-bit x86.

**Removed addressing modes**:

- **No 32-bit absolute addressing**: Cannot use `mov rax, [0x12345678]` with 32-bit address
- **No segment-based addressing** (except FS/GS): CS, DS, ES, SS segment overrides are ignored in 64-bit mode

**New addressing modes**:

- **RIP-relative addressing**: `mov rax, [rip + displacement]`
- **64-bit absolute addressing**: `movabs rax, [0x123456789ABCDEF0]` (rare, large encoding)

**Address size override**: The 67h prefix reduces address size to 32 bits (rarely used):

```nasm
mov rax, [rbx]                        ; 64-bit address
mov rax, [ebx]                        ; 32-bit address (67h prefix, sign-extended)
```

**Comparison of addressing modes**:

```nasm
; 32-bit x86 addressing
mov eax, [ds:0x12345678]              ; Absolute address with segment
mov ebx, [esi + 0x100]                ; Base + displacement
mov ecx, [ebp + esi*4 + 0x20]         ; Base + index*scale + displacement

; 64-bit x64 addressing (segment overrides ignored except FS/GS)
mov rax, [rel symbol]                 ; RIP-relative (new)
mov rbx, [rsi + 0x100]                ; Base + displacement
mov rcx, [rbp + rsi*4 + 0x20]         ; Base + index*scale + displacement
mov rdx, fs:[0x28]                    ; FS-relative (TLS, canary)
```

### Removed Instructions and Features

**Segmentation largely removed**:

- CS, DS, ES, SS segment overrides ignored in 64-bit mode
- FS and GS still functional (used for TLS)
- Segment registers cannot be used for application-level segmentation

**32-bit instructions not available**:

```nasm
; These 32-bit instructions do not exist in 64-bit mode
pusha                                 ; Push all 32-bit registers (removed)
popa                                  ; Pop all 32-bit registers (removed)
aaa, aas, aam, aad                    ; BCD adjust instructions (removed)
bound                                 ; Array bounds check (removed)

; Use 64-bit equivalents or alternatives
; Instead of pusha/popa, manually push/pop needed registers
push rax
push rbx
; ...
pop rbx
pop rax
```

**INC/DEC single-byte encoding removed**: In 32-bit mode, INC/DEC had single-byte opcodes (40h-4Fh). In 64-bit mode, these opcodes are used for REX prefixes.

```nasm
; 32-bit encoding
inc eax                               ; 40h (1 byte)
dec ebx                               ; 4Bh (1 byte)

; 64-bit encoding (uses REX prefix space, needs longer encoding)
inc eax                               ; FF C0 (2 bytes)
dec ebx                               ; FF CB (2 bytes)
inc rax                               ; 48 FF C0 (3 bytes with REX.W)
```

### New Instructions in x64

**MOVSXD** - Move with Sign Extension Doubleword

```nasm
movsxd rax, dword [rsi]               ; Load 32-bit signed value, extend to 64-bit
movsxd rbx, ecx                       ; Sign-extend ECX to RBX
```

**SWAPGS** - Swap GS Base Register

```nasm
swapgs                                ; Exchange GS base with kernel GS base
; Used for kernel entry/exit to switch between user/kernel TLS
```

**SYSCALL/SYSRET** - Fast System Call

```nasm
; User space to kernel transition
syscall                               ; Fast system call (replaces INT 80h)

; Kernel space to user return (kernel only)
sysret                                ; Return from system call
```

**RDFSBASE/WRFSBASE** - Read/Write FS Base

```nasm
rdfsbase rax                          ; Read FS segment base to RAX
wrfsbase rax                          ; Write RAX to FS segment base
; Requires FSGSBASE CPU feature
```

### Integer Size Changes

**Size promotions**:

- **Pointer size**: 32 bits → 64 bits
- **Long integers**: Remain 32 bits (in C `long` is 64-bit on Unix, 32-bit on Windows)
- **Size_t**: 32 bits → 64 bits

**Example** showing size considerations:

```nasm
section .data
; Define 64-bit pointers and sizes
ptr: dq 0x123456789ABCDEF0            ; 64-bit pointer
size: dq 1024                         ; 64-bit size value

; 32-bit values still valid
counter: dd 42                        ; 32-bit integer
flags: dw 0xFF                        ; 16-bit value

section .text
handle_sizes:
    ; Load 64-bit pointer
    mov rax, [rel ptr]                ; Full 64-bit address
    
    ; Load 32-bit value and zero-extend
    mov ecx, [rel counter]            ; ECX = 42, RCX = 0x0000000000000042
    
    ; Explicit 64-bit load
    mov rdx, [rel size]               ; RDX = 1024
    
    ret
```

### Stack and Function Prologue Differences

**Stack alignment**:

- **32-bit**: 4-byte alignment typically sufficient
- **64-bit**: 16-byte alignment required before CALL instructions

**Frame pointer usage**:

- **32-bit**: EBP commonly used as frame pointer
- **64-bit**: RBP optional; many functions omit frame pointer for optimization

**Example** comparing function prologues:

32-bit function prologue:

```nasm
; 32-bit x86 function
my_function_32:
    push ebp                          ; Save frame pointer
    mov ebp, esp                      ; Establish new frame
    sub esp, 16                       ; Allocate local space (any size)
    
    ; Function body...
    
    mov esp, ebp                      ; Restore stack pointer
    pop ebp                           ; Restore frame pointer
    ret
```

64-bit function prologue (with frame pointer):

```nasm
; 64-bit x64 function with frame pointer
my_function_64:
    push rbp                          ; Save frame pointer
    mov rbp, rsp                      ; Establish new frame
    sub rsp, 32                       ; Allocate space (must maintain 16-byte alignment)
    
    ; Function body...
    
    leave                             ; mov rsp, rbp; pop rbp (more efficient)
    ret
```

64-bit function prologue (without frame pointer):

```nasm
; 64-bit x64 function without frame pointer (optimized)
my_function_64_opt:
    sub rsp, 32                       ; Allocate space, maintain alignment
    
    ; Function body - access locals via RSP offsets
    mov [rsp + 8], rdi                ; Save argument
    mov [rsp + 16], rsi
    
    ; No frame pointer to restore
    add rsp, 32                       ; Deallocate space
    ret
```

### Immediate Value Limitations

x64 places restrictions on immediate values with 64-bit operations.

**Immediate size limits**:

- **Most instructions**: Maximum 32-bit immediate (sign-extended to 64 bits)
- **MOV instruction**: Can use full 64-bit immediate with MOVABS

**Example** of immediate value handling:

```nasm
; 32-bit immediate (sign-extended to 64 bits)
mov rax, 0x7FFFFFFF                   ; Valid: positive 32-bit value
mov rbx, -1                           ; Valid: 0xFFFFFFFFFFFFFFFF (sign-extended)
add rcx, 0x12345678                   ; Valid: 32-bit immediate

; Full 64-bit immediate (only with MOVABS)
movabs rdx, 0x123456789ABCDEF0        ; Valid: 64-bit immediate (10-byte instruction)

; These would be invalid - cannot use 64-bit immediate with most instructions
; add rax, 0x123456789ABCDEF0         ; INVALID
; cmp rbx, 0x8000000000000000         ; INVALID (exceeds signed 32-bit range)

; Workaround: Use MOVABS then operate
movabs rax, 0x123456789ABCDEF0
add rbx, rax                          ; Valid: register-to-register
```

### Improved Performance Characteristics

[Inference] x64 provides several performance advantages over 32-bit:

**More registers**: 16 general-purpose registers reduce memory spills and improve register allocation.

**Register parameter passing**: Arguments in registers avoid memory accesses, improving performance significantly.

**Larger caches**: [Inference] 64-bit processors typically have larger L1/L2/L3 caches, reducing cache misses.

**Enhanced instructions**: New instructions like MOVSXD and improved SIMD support (16 XMM/YMM registers).

**Example** demonstrating register pressure improvement:

32-bit code (limited registers):

```nasm
; 32-bit: Frequent memory spills due to register pressure
compute_32:
    push ebx
    push esi
    push edi
    
    mov eax, [arg1]
    mov ebx, [arg2]
    mov ecx, [arg3]
    mov edx, [arg4]
    ; Out of registers, must spill to memory
    mov [temp1], eax                  ; Spill to memory
    mov eax, [arg5]
    ; ... frequent memory operations ...
    
    pop edi
    pop esi
    pop ebx
    ret
```

64-bit code (more registers):

```nasm
; 64-bit: All values kept in registers
compute_64:
    ; Arguments already in registers: RDI, RSI, RDX, RCX, R8, R9
    ; Additional registers available: R10, R11, RBX, R12-R15
    
    mov rax, rdi                      ; arg1
    mov rbx, rsi                      ; arg2
    mov r10, rdx                      ; arg3
    mov r11, rcx                      ; arg4
    mov r12, r8                       ; arg5
    ; All values in registers, no memory spills needed
    
    ; Computation using registers only
    add rax, rbx
    imul r10, r11
    add rax, r12
    
    ret                               ; No register restoration needed
```

### Exception and Interrupt Handling

**Interrupt descriptor table changes**:

- **32-bit IDT**: 32-bit gate descriptors (8 bytes each)
- **64-bit IDT**: 64-bit gate descriptors (16 bytes each)

**Interrupt stack frame**: 64-bit mode pushes more information during interrupts:

```
Interrupt stack frame (64-bit):
+------------------+
| SS               | (Pushed by CPU)
| RSP              |
| RFLAGS           |
| CS               |
| RIP              |
| Error Code       | (For some exceptions)
+------------------+
```

**Example** of interrupt handler structure:

```nasm
; 64-bit interrupt handler
interrupt_handler:
    ; Save all registers
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push rbp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
    
    ; Handle interrupt
    ; ...
    
    ; Restore all registers
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rbp
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    
    ; Return from interrupt
    iretq                             ; 64-bit IRET
```

### System Call Interface

**32-bit system call mechanism**:

```nasm
; Linux 32-bit system call (INT 80h)
mov eax, syscall_number               ; Syscall number in EAX
mov ebx, arg1                         ; Arguments in EBX, ECX, EDX, ESI, EDI, EBP
int 0x80                              ; Trigger interrupt
; Return value in EAX
```

**64-bit system call mechanism**:

```nasm
; Linux 64-bit system call (SYSCALL instruction)
mov rax, syscall_number               ; Syscall number in RAX
mov rdi, arg1                         ; Arguments in RDI, RSI, RDX, R10, R8, R9
mov rsi, arg2
mov rdx, arg3
syscall                               ; Fast system call
; Return value in RAX
```

**Example** comparing system call implementations:

32-bit write syscall:

```nasm
; 32-bit Linux write(1, "Hello", 5)
section .data
msg32: db "Hello", 10

section .text
write_32:
    mov eax, 4                        ; sys_write = 4
    mov ebx, 1                        ; stdout
    mov ecx, msg32                    ; buffer
    mov edx, 6                        ; length
    int 0x80                          ; System call
    ret
```

64-bit write syscall:

```nasm
; 64-bit Linux write(1, "Hello", 5)
section .data
msg64: db "Hello", 10

section .text
write_64:
    mov rax, 1                        ; sys_write = 1 (different number!)
    mov rdi, 1                        ; stdout
    lea rsi, [rel msg64]              ; buffer (RIP-relative)
    mov rdx, 6                        ; length
    syscall                           ; Fast system call
    ret
```

**System call number differences**: System call numbers differ between 32-bit and 64-bit Linux. For example:

- **write**: 4 (32-bit), 1 (64-bit)
- **exit**: 1 (32-bit), 60 (64-bit)
- **open**: 5 (32-bit), 2 (64-bit)

### Practical Migration Examples

**Example**: Converting 32-bit function to 64-bit:

32-bit version:

```nasm
; 32-bit: Calculate sum of array
; Arguments: [ebp+8] = array pointer, [ebp+12] = count
; Returns: sum in EAX

global sum_array_32
sum_array_32:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    
    mov esi, [ebp + 8]                ; array pointer
    mov ecx, [ebp + 12]               ; count
    xor eax, eax                      ; sum = 0
    
sum_loop_32:
    add eax, [esi]                    ; sum += *array
    add esi, 4                        ; array++
    dec ecx
    jnz sum_loop_32
    
    pop esi
    pop ebx
    pop ebp
    ret
```

64-bit version (System V ABI):

```nasm
; 64-bit: Calculate sum of array
; Arguments: RDI = array pointer, RSI = count
; Returns: sum in RAX

global sum_array_64
sum_array_64:
    ; No need to save RBX, RSI - using caller-saved registers only
    xor rax, rax                      ; sum = 0
    test rsi, rsi                     ; Check if count is 0
    jz sum_done
    
sum_loop_64:
    add rax, [rdi]                    ; sum += *array (64-bit add)
    add rdi, 8                        ; array++ (8-byte pointers)
    dec rsi
    jnz sum_loop_64
    
sum_done:
    ret                               ; Return sum in RAX
```

**Example**: Accessing structure members:

32-bit structure access:

```nasm
; 32-bit structure
; struct Point { int x; int y; };
; EBX = pointer to Point

mov eax, [ebx]                        ; eax = point->x (offset 0)
mov ecx, [ebx + 4]                    ; ecx = point->y (offset 4)
```

64-bit structure access:

```nasm
; 64-bit structure
; struct Point { int64_t x; int64_t y; };
; RBX = pointer to Point

mov rax, [rbx]                        ; rax = point->x (offset 0)
mov rcx, [rbx + 8]                    ; rcx = point->y (offset 8)
```

**Example**: String operations with optimizations:

32-bit string copy:

```nasm
; 32-bit: Copy string
; ESI = source, EDI = destination
strcpy_32:
    push esi
    push edi
    
copy_loop_32:
    lodsb                             ; AL = *ESI++
    stosb                             ; *EDI++ = AL
    test al, al
    jnz copy_loop_32
    
    pop edi
    pop esi
    ret
```

64-bit string copy with SIMD:

```nasm
; 64-bit: Copy string with SIMD optimization
; RDI = destination, RSI = source
strcpy_64:
    ; Check alignment for SIMD
    mov rax, rsi
    and rax, 0x0F
    jnz scalar_copy                   ; Not aligned, use scalar
    
    ; SIMD copy (16 bytes at a time)
simd_copy:
    movdqu xmm0, [rsi]                ; Load 16 bytes
    ; Check for null terminator in xmm0
    pxor xmm1, xmm1
    pcmpeqb xmm1, xmm0                ; Compare with zero
    pmovmskb eax, xmm1                ; Extract comparison mask
    test eax, eax
    jnz found_null                    ; Null found, finish
    
    movdqu [rdi], xmm0                ; Store 16 bytes
    add rsi, 16
    add rdi, 16
    jmp simd_copy
    
found_null:
    ; Handle remaining bytes with scalar copy
scalar_copy:
    lodsb
    stosb
    test al, al
    jnz scalar_copy
    
    ret
```

### Compatibility Considerations

**Running 32-bit code on 64-bit systems**:

- **Separate address spaces**: 32-bit and 64-bit code typically cannot mix in same process
- **Thunking layers**: OS provides compatibility layers (WOW64 on Windows, multilib on Linux)
- **Performance**: [Inference] 32-bit code may run slightly slower due to compatibility overhead

**Binary compatibility**:

- **ELF format**: 32-bit and 64-bit use different ELF formats (ELF32 vs ELF64)
- **PE format**: Windows uses PE32 and PE32+ (64-bit) formats
- **Libraries**: Separate 32-bit and 64-bit library versions required

**Development considerations**:

- **Pointer arithmetic**: Must account for 8-byte pointers in 64-bit
- **Structure padding**: Alignment rules differ, affecting structure sizes
- **Integer truncation**: Careful when converting between pointer and integer types
- **ABI differences**: Calling conventions fundamentally different

**Important subtopics**: Advanced PIC techniques (lazy binding, symbol interposition), memory management in x64 (page tables, 4-level vs 5-level paging), debugging considerations (hardware breakpoints, watchpoints), performance profiling in 64-bit mode, security features (DEP, ASLR, stack canaries), mixed-mode programming (32/64-bit interop), compiler-specific code generation patterns, microarchitecture-specific optimizations for modern x64 processors.

---

