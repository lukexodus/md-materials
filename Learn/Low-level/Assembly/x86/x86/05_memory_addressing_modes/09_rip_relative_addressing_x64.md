## RIP-Relative Addressing (x64)


RIP-relative addressing, introduced in x86-64 long mode, calculates addresses relative to the current instruction pointer. This addressing mode is fundamental for position-independent code (PIC) and modern security features.

### Basic RIP-Relative Syntax

RIP-relative addressing uses the instruction pointer with a displacement:

```nasm
mov rax, [rip + displacement]   ; EA = RIP + displacement
mov [rip + displacement], rax   ; Store relative to RIP
```

The displacement is a signed 32-bit value, allowing access to addresses within ±2GB of the current instruction.

### Implicit RIP-Relative Addressing

Many assemblers use RIP-relative addressing implicitly when accessing labeled memory locations:

```nasm
.data
global_var: dq 0x123456789ABCDEF

.text
mov rax, [global_var]           ; Assembler may encode as RIP-relative
```

The assembler determines whether the target is within ±2GB and encodes appropriately. For absolute addressing or when the target is beyond ±2GB range, different encoding is required.

### Explicit RIP-Relative Syntax

Some assemblers require explicit RIP-relative notation:

```nasm
; NASM syntax
mov rax, [rel global_var]       ; Explicitly RIP-relative

; Gas/AT&T syntax
movq global_var(%rip), %rax     ; RIP-relative addressing
```

### Address Calculation Mechanism

During instruction execution, RIP points to the **next** instruction (the one following the current instruction). The effective address calculation:

EA = RIP + Sign_Extend(Displacement)

Where RIP contains the address of the instruction following the current one.

**Example**: If an instruction at address 0x400500 encodes `mov rax, [rip + 0x100]`, and the instruction is 7 bytes long:

- During execution, RIP points to 0x400507 (next instruction)
- Effective Address = 0x400507 + 0x100 = 0x400607

### Position-Independent Code (PIC)

RIP-relative addressing enables position-independent code, where code can execute correctly regardless of its absolute memory location:

```nasm
.data
message: db "Hello, World!", 0

.text
print_hello:
    lea rdi, [rip + message]    ; Load message address relative to RIP
    call puts                   ; Call C library function
    ret
```

This code works correctly at any memory address because the relative offset between the instruction and the data remains constant, even if both are relocated.

**Shared Libraries**: Dynamic libraries (.so on Linux, .dylib on macOS) extensively use PIC to allow loading at arbitrary addresses:

```nasm
; Accessing global variable in shared library
.data
shared_counter: dq 0

.text
increment_counter:
    mov rax, [rip + shared_counter]  ; Load counter value
    inc rax                          ; Increment
    mov [rip + shared_counter], rax  ; Store back
    ret
```

### Address Space Layout Randomization (ASLR)

Modern operating systems use ASLR to load executables and libraries at randomized addresses for security. RIP-relative addressing supports ASLR by maintaining correct references despite address randomization [Inference about security implementation details].

### Global Offset Table (GOT) Access

When accessing symbols from other modules in position-independent code, the Global Offset Table provides indirection:

```nasm
; Accessing external function
call external_function@PLT      ; Call through Procedure Linkage Table

; Accessing external variable
mov rax, [rip + external_var@GOTPCREL]  ; Load GOT entry address
mov rbx, [rax]                          ; Dereference to get variable value
```

The `@GOTPCREL` notation indicates GOT-relative addressing via RIP-relative mechanism.

### Thread-Local Storage (TLS)

RIP-relative addressing facilitates thread-local storage access:

```nasm
; Accessing thread-local variable (model-specific)
mov rax, [fs:0]                 ; Load thread pointer (Linux)
mov rbx, [rip + tls_offset]     ; Load TLS variable offset
mov rcx, [rax + rbx]            ; Access thread-local variable
```

### Static Data Access Patterns

**Read-Only Data**: Accessing constant data like strings and lookup tables:

```nasm
.rodata
format_string: db "Value: %d", 10, 0
lookup_table: dq 1, 4, 9, 16, 25, 36, 49, 64, 81, 100

.text
use_constants:
    lea rdi, [rip + format_string]  ; Load format string address
    mov rsi, [rip + lookup_table + 24]  ; Load lookup_table[3]
    xor eax, eax                    ; Clear AL for printf
    call printf
    ret
```

**Jump Tables**: Implementing switch statements with RIP-relative addressing:

```nasm
.rodata
jump_table:
    dq .case0
    dq .case1
    dq .case2
    dq .case3

.text
switch_handler:
    cmp rdi, 3                      ; Check if index valid
    ja .default
    lea rax, [rip + jump_table]     ; Load table base
    mov rax, [rax + rdi*8]          ; Load target address
    jmp rax                         ; Jump to case handler

.case0:
    ; Handle case 0
    ret
.case1:
    ; Handle case 1
    ret
; ... more cases
.default:
    ; Handle default case
    ret
```

### Limitations and Considerations

**Range Limitation**: RIP-relative addressing uses 32-bit signed displacement, limiting range to ±2GB from the current instruction. Large executables or libraries may exceed this range, requiring alternative mechanisms.

**Non-RIP-Relative Alternatives**: When RIP-relative addressing isn't suitable:

```nasm
; Absolute 64-bit addressing (using MOVABS)
movabs rax, 0x1234567890ABCDEF  ; Load absolute address into RAX
mov rbx, [rax]                  ; Access memory at absolute address

; Indirect through register
lea rax, [data_address]         ; Load absolute address
mov rbx, [rax + rcx*8]          ; Complex addressing through absolute base
```

**Performance Considerations**: RIP-relative addressing typically has equivalent or better performance compared to absolute addressing [Unverified: performance depends on specific microarchitecture and cache behavior]. The smaller instruction encoding (no need for 64-bit immediate addresses) may improve instruction cache efficiency [Inference].

### Combining with Other Addressing Modes

RIP-relative addressing can be combined with displacement but not with base or index registers:

```nasm
mov rax, [rip + offset]         ; Valid: RIP + displacement
mov rax, [rip + rbx]            ; Invalid: Cannot combine RIP with base register
mov rax, [rip + rcx*4]          ; Invalid: Cannot combine RIP with index register
```

For complex addressing relative to static data, load the address first:

```nasm
.data
array_base: times 100 dq 0

.text
    lea rax, [rip + array_base] ; Load base address
    mov rbx, [rax + rcx*8]      ; Now use regular scaled addressing
```

