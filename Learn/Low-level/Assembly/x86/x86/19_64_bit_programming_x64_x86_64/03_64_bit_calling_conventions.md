## 64-bit Calling Conventions


Calling conventions define how functions receive parameters, return values, preserve registers, and manage the stack. Unlike 32-bit x86 where multiple incompatible conventions existed (cdecl, stdcall, fastcall), 64-bit programming standardized around two primary conventions: the System V AMD64 ABI used on Unix-like systems, and the Microsoft x64 calling convention used on Windows.

### System V AMD64 ABI (Linux, BSD, macOS)

#### Parameter Passing

The System V AMD64 ABI passes the first six integer or pointer arguments in registers:

```
1st argument: RDI
2nd argument: RSI
3rd argument: RDX
4th argument: RCX
5th argument: R8
6th argument: R9
```

Floating-point and vector arguments use XMM registers:

```
1st FP argument: XMM0
2nd FP argument: XMM1
3rd FP argument: XMM2
4th FP argument: XMM3
5th FP argument: XMM4
6th FP argument: XMM5
7th FP argument: XMM6
8th FP argument: XMM7
```

Arguments beyond these register parameters are passed on the stack in right-to-left order, with the first stack argument at [RSP] immediately after the CALL instruction pushes the return address.

```nasm
; Calling function(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
mov rdi, [arg1]    ; 1st argument
mov rsi, [arg2]    ; 2nd argument
mov rdx, [arg3]    ; 3rd argument
mov rcx, [arg4]    ; 4th argument
mov r8, [arg5]     ; 5th argument
mov r9, [arg6]     ; 6th argument
push [arg8]        ; 8th argument on stack (pushed first)
push [arg7]        ; 7th argument on stack
call function
add rsp, 16        ; Clean up stack arguments (2 × 8 bytes)
```

**Example**: Simple function call

```nasm
; int add_numbers(int a, int b, int c)
; Returns a + b + c
add_numbers:
    lea eax, [rdi + rsi]    ; a + b (32-bit operation, zero-extends)
    add eax, edx            ; + c
    ret

; Calling code
mov edi, 10         ; First argument
mov esi, 20         ; Second argument
mov edx, 30         ; Third argument
call add_numbers    ; Result in EAX = 60
```

#### Argument Classification

The System V ABI includes complex rules for classifying structure and union arguments. Small structures (up to 16 bytes) are passed in registers if they fit, with classification determining which registers (integer or XMM) receive each portion.

Structures are decomposed into eightbyte chunks, and each chunk is classified as INTEGER, SSE, SSEUP, X87, X87UP, COMPLEX_X87, or MEMORY class:

- **INTEGER**: Passed in integer registers (RDI, RSI, RDX, RCX, R8, R9)
- **SSE**: Passed in XMM registers
- **MEMORY**: Entire structure passed on stack

[Inference] This classification system enables efficient passing of small structures in registers while handling larger or complex structures through memory, balancing performance and implementation complexity.

**Example**: Passing small structure

```nasm
; struct Point { int x; int y; };
; Point process(Point p, int scale);

; Struct fits in one 64-bit register (8 bytes total)
; Caller places x in lower 32 bits, y in upper 32 bits of RDI
mov edi, [point.x]
mov eax, [point.y]
shl rax, 32
or rdi, rax         ; RDI = {y, x}
mov esi, [scale]    ; Second argument
call process
```

#### Return Values

Integer and pointer return values use RAX. If a 64-bit value requires 128 bits (rare), RDX contains the upper 64 bits (RAX:RDX pair).

Floating-point return values use XMM0 for single floating-point values. If multiple floating-point values are returned, XMM1 may also be used.

Structures up to 16 bytes are returned in registers using the same classification system as argument passing. Larger structures are returned through a hidden pointer argument: the caller allocates space and passes a pointer in RDI (becoming the first argument), which the function uses to write the return value. The pointer is also returned in RAX.

```nasm
; Returning integer value
mov rax, return_value
ret

; Returning 128-bit value (rare)
mov rax, low_64_bits
mov rdx, high_64_bits
ret

; Returning floating-point value
movsd xmm0, [result]
ret

; Returning large structure (caller passes hidden pointer in RDI)
large_struct_return:
    ; RDI contains pointer to caller-allocated space
    mov rax, rdi            ; Save for return
    ; ... compute structure members ...
    mov [rdi], qword value1
    mov [rdi+8], qword value2
    ; RAX already contains pointer
    ret
```

#### Register Preservation

The ABI divides registers into caller-saved (volatile) and callee-saved (non-volatile) categories:

**Caller-saved registers** (function may modify without preserving):

- RAX (return value register)
- RCX, RDX (parameter registers)
- RSI, RDI (parameter registers)
- R8, R9, R10, R11 (R8-R9 are parameter registers)
- XMM0-XMM15 (all XMM registers volatile)
- All YMM and ZMM registers
- All mask registers (k0-k7)

**Callee-saved registers** (function must preserve if used):

- RBX
- RBP (frame pointer)
- R12, R13, R14, R15
- Stack pointer RSP

[Inference] The large number of caller-saved registers reflects that most functions are short and do not use many registers, allowing callers to keep values in volatile registers across calls without save/restore overhead. The six callee-saved registers (RBX, R12-R15, and RBP) provide sufficient persistent storage for functions needing to preserve state across nested calls.

**Example**: Function using callee-saved registers

```nasm
process_array:
    push rbx                ; Save callee-saved registers
    push r12
    push r13
    
    mov r12, rdi            ; Array pointer (preserve across calls)
    mov r13, rsi            ; Array length
    xor ebx, ebx            ; Counter
    
loop_process:
    mov rdi, [r12 + rbx*8]  ; Get array element
    call helper_function    ; May modify caller-saved registers
    inc rbx
    cmp rbx, r13
    jb loop_process
    
    pop r13                 ; Restore callee-saved registers
    pop r12
    pop rbx
    ret
```

#### Red Zone

The System V ABI defines a 128-byte "red zone" below the stack pointer that functions can use for temporary storage without adjusting RSP. Signal handlers and interrupts must preserve this region.

```nasm
; Using red zone for temporary storage (leaf function)
compute_something:
    mov [rsp-8], rdi     ; Store temporary in red zone
    mov [rsp-16], rsi
    ; ... computation using RDI and RSI for other purposes ...
    mov rdi, [rsp-8]     ; Retrieve temporaries
    mov rsi, [rsp-16]
    ; ... final computation ...
    ret
```

[Inference] The red zone enables leaf functions (functions that make no calls) to avoid stack pointer manipulation entirely, reducing prologue and epilogue overhead. However, signal-unsafe code or functions that might be called from signal handlers must avoid the red zone or risk corruption if a signal occurs.

**Restrictions**:

- Functions that call other functions should not use the red zone for persistent storage, as called functions may use it
- Signal handlers corrupt the red zone
- Kernel code and interrupt handlers cannot rely on red zone preservation

#### Stack Alignment

The stack must be 16-byte aligned immediately before executing a CALL instruction. Since CALL pushes an 8-byte return address, the stack is misaligned (8 modulo 16) upon function entry. Functions requiring stack space must adjust RSP to restore 16-byte alignment.

```nasm
; Function prologue with proper alignment
function_with_stack:
    push rbp                ; Save frame pointer (RSP now 0 mod 16)
    mov rbp, rsp            ; Set up frame pointer
    sub rsp, 32             ; Allocate space (RSP now 0 mod 16)
    ; ... function body ...
    leave                   ; Equivalent to: mov rsp, rbp; pop rbp
    ret

; Calling nested function requires alignment check
function_calls_nested:
    push rbp
    mov rbp, rsp
    sub rsp, 16             ; Allocate 16 bytes (RSP = RBP - 16, 0 mod 16)
    ; Before nested call, RSP is already aligned
    call nested_func        ; Stack properly aligned
    leave
    ret
```

[Inference] The 16-byte alignment requirement ensures compatibility with SSE/AVX instructions that may be used within called functions, even if the current function doesn't use them. This prevents subtle bugs from misaligned vector operations and maintains consistent ABI behavior.

#### Variadic Functions

Variadic functions (functions with variable argument counts, like printf) receive special treatment. The caller must set AL to the number of vector registers (XMM0-XMM7) used for floating-point arguments. This allows the callee to determine which XMM registers contain valid arguments.

```nasm
; Calling printf with floating-point arguments
section .rodata
format: db "Values: %f %f", 10, 0

section .text
    mov rdi, format         ; Format string (1st argument)
    movsd xmm0, [value1]    ; 1st FP argument
    movsd xmm1, [value2]    ; 2nd FP argument
    mov al, 2               ; Indicate 2 XMM registers used
    xor eax, eax            ; Alternative: clear entire EAX (sets AL=0 for no FP)
    call printf
```

Variadic functions that need to access all arguments typically save the register parameters to the stack and process arguments sequentially using va_list mechanisms.

### Microsoft x64 Calling Convention (Windows)

#### Parameter Passing

The Microsoft x64 convention passes the first four integer or pointer arguments in registers:

```
1st argument: RCX
2nd argument: RDX
3rd argument: R8
4th argument: R9
```

Floating-point arguments use XMM registers in corresponding positions:

```
1st FP argument: XMM0
2nd FP argument: XMM1
3rd FP argument: XMM2
4th FP argument: XMM3
```

When an argument position contains a floating-point value, the corresponding integer register is unused (and vice versa). This differs from System V ABI where integer and floating-point arguments use independent register sequences.

Arguments beyond the first four are passed on the stack in left-to-right order. The caller must allocate at least 32 bytes of "shadow space" (also called "home space") on the stack for the register parameters, even if fewer than four arguments are passed.

```nasm
; Calling function(arg1, arg2, arg3, arg4, arg5, arg6)
sub rsp, 48         ; Allocate shadow space (32) + stack args (16)
mov rcx, [arg1]     ; 1st argument
mov rdx, [arg2]     ; 2nd argument
mov r8, [arg3]      ; 3rd argument
mov r9, [arg4]      ; 4th argument
mov rax, [arg5]
mov [rsp+32], rax   ; 5th argument on stack (above shadow space)
mov rax, [arg6]
mov [rsp+40], rax   ; 6th argument on stack
call function
add rsp, 48         ; Clean up
```

**Example**: Function with mixed parameter types

```nasm
; double compute(int count, double value, int flag, double scale)
compute:
    ; RCX = count (integer)
    ; XMM1 = value (double)
    ; R8 = flag (integer)
    ; XMM3 = scale (double)
    
    cvtsi2sd xmm0, ecx      ; Convert count to double
    mulsd xmm0, xmm1        ; Multiply by value
    test r8, r8             ; Check flag
    jz skip_scale
    mulsd xmm0, xmm3        ; Apply scale if flag set
skip_scale:
    ret                     ; Result in XMM0
```

#### Shadow Space

The caller must allocate 32 bytes of "shadow space" on the stack immediately above the return address, even when passing fewer than four arguments. This space is reserved for the callee to spill the register parameters if needed, though the callee is not required to use it.

[Inference] Shadow space simplifies function implementation by guaranteeing that register parameters have accessible stack locations. This facilitates debugging (parameters visible in stack traces), taking addresses of parameters, and handling variadic functions where all parameters must be accessible sequentially.

The shadow space belongs to the callee and may be used arbitrarily. The callee need not preserve the parameter values stored there.

```nasm
; Callee using shadow space
function:
    ; May spill parameters to shadow space if needed
    mov [rsp+8], rcx     ; Spill 1st parameter
    mov [rsp+16], rdx    ; Spill 2nd parameter
    ; ... use RCX and RDX for other purposes ...
    mov rcx, [rsp+8]     ; Reload parameter
    ret
```

#### Return Values

Integer and pointer return values use RAX. Floating-point return values use XMM0.

Structures up to 8 bytes are returned by value in RAX. For structures between 8 and 16 bytes or structures not fitting power-of-2 sizes (1, 2, 4, 8 bytes), a hidden pointer argument is passed in RCX (becoming the first parameter), and all explicit parameters shift to subsequent registers. The caller allocates space for the return value and passes its address. The callee returns the pointer in RAX.

```nasm
; Returning small structure (≤ 8 bytes) by value
; struct SmallStruct { int a; int b; }; // 8 bytes total
return_small:
    mov eax, [struct.a]     ; Lower 32 bits
    mov edx, [struct.b]     ; Load second member
    shl rdx, 32             ; Shift to upper 32 bits
    or rax, rdx             ; Combine in RAX
    ret

; Returning large structure (> 8 bytes)
; Caller passes hidden pointer in RCX, explicit params shift to RDX, R8, R9
return_large:
    ; RCX contains pointer to caller-allocated space
    ; RDX, R8, R9 contain explicit parameters
    mov [rcx], qword value1      ; Write structure members
    mov [rcx+8], qword value2
    mov [rcx+16], qword value3
    mov rax, rcx                 ; Return pointer in RAX
    ret
```

#### Register Preservation

**Caller-saved registers** (volatile, may be modified):

- RAX (return value register)
- RCX, RDX (parameter registers)
- R8, R9, R10, R11 (R8-R9 are parameter registers)
- XMM0-XMM5 (parameter and temporary registers)
- Upper portions of YMM0-YMM15 (YMM state above XMM)
- All ZMM registers
- All mask registers (k0-k7)

**Callee-saved registers** (non-volatile, must be preserved):

- RBX
- RBP (frame pointer)
- RDI, RSI
- RSP (stack pointer)
- R12, R13, R14, R15
- XMM6-XMM15 (lower 128 bits only)

[Inference] The Windows convention designates RDI and RSI as callee-saved, contrasting with System V ABI where they are volatile parameter registers. This difference requires careful attention when porting assembly code between platforms or when writing cross-platform assembly code.

The lower 128 bits of XMM6-XMM15 must be preserved, but the upper bits (bits 128-255 of YMM registers) need not be. [Inference] This split reflects that the convention was defined before AVX became widespread, with YMM extensions added later in a way that minimized compatibility impact on existing code.

**Example**: Function preserving callee-saved registers

```nasm
process_data:
    push rbx                    ; Save callee-saved registers
    push rsi
    push rdi
    sub rsp, 32                 ; Allocate shadow space
    
    mov rbx, rcx                ; Save parameter (RCX is volatile)
    mov rsi, rdx                ; Save parameter
    
    ; Use preserved values across multiple calls
    mov rcx, rbx
    call helper1                ; RBX preserved across call
    
    mov rcx, rsi
    mov rdx, rax
    call helper2                ; RSI preserved across call
    
    add rsp, 32                 ; Deallocate shadow space
    pop rdi                     ; Restore callee-saved registers
    pop rsi
    pop rbx
    ret
```

#### Stack Alignment

The stack must be 16-byte aligned before CALL instructions, identical to System V ABI. After CALL pushes the 8-byte return address, the stack becomes misaligned (8 modulo 16) at function entry.

The required shadow space (32 bytes) combined with the return address means functions typically allocate additional stack space in multiples of 16 bytes to maintain alignment:

```nasm
; Proper stack alignment with shadow space
function:
    sub rsp, 40             ; Shadow space (32) + alignment (8)
                            ; Total 40 = 32 + 8 maintains 16-byte alignment
    ; ... function body ...
    ; Before calling nested function:
    ; RSP is 16-byte aligned (original RSP - 8 from CALL - 40 from SUB = aligned)
    call nested_function
    add rsp, 40
    ret

; Alternative: allocating local variables
function_with_locals:
    sub rsp, 56             ; Shadow (32) + locals (16) + align (8)
    ; Use [rsp+32] through [rsp+47] for local variables
    ; ... function body ...
    add rsp, 56
    ret
```

[Inference] Allocating stack space in multiples of 16 bytes (after accounting for the return address) simplifies alignment maintenance and enables consistent frame layout across different functions.

#### No Red Zone

The Microsoft x64 convention does not define a red zone. Functions must not access memory below RSP, as interrupts, exceptions, and asynchronous procedure calls may overwrite that region without warning.

[Inference] This reflects Windows' exception handling and asynchronous execution architecture where the stack below RSP cannot be assumed safe. Code must explicitly allocate stack space via SUB RSP before using it.

```nasm
; Invalid on Windows (no red zone)
; leaf_function:
;     mov [rsp-8], rax    ; UNSAFE: may be corrupted
;     ret

; Correct approach on Windows
leaf_function:
    sub rsp, 16             ; Must allocate stack space
    mov [rsp+8], rax        ; Safe: within allocated space
    ; ... use temporary storage ...
    mov rax, [rsp+8]
    add rsp, 16
    ret
```

#### Variadic Functions

Variadic functions in the Microsoft x64 convention receive all arguments accessible from the stack or shadow space. Even arguments that would normally be passed in registers must be accessible from their shadow space locations.

The callee typically spills all register parameters to the shadow space immediately in the function prologue, then processes arguments sequentially using traditional va_list mechanisms.

```nasm
; Variadic function example
variadic_func:
    ; Spill register parameters to shadow space
    mov [rsp+8], rcx        ; 1st parameter
    mov [rsp+16], rdx       ; 2nd parameter
    mov [rsp+24], r8        ; 3rd parameter
    mov [rsp+32], r9        ; 4th parameter
    
    ; Now all parameters accessible sequentially starting at [rsp+8]
    lea rax, [rsp+8]        ; Address of first parameter
    ; ... process variadic arguments using RAX as base pointer ...
    ret
```

### Leaf Function Optimization

Functions that make no calls (leaf functions) can optimize their prologue and epilogue by avoiding frame pointer setup and minimizing stack adjustments.

**System V AMD64 leaf function**:

```nasm
; Using red zone for temporary storage
leaf_sum:
    mov [rsp-8], rbx        ; Save callee-saved register in red zone
    xor eax, eax            ; Initialize sum
    xor ebx, ebx            ; Counter
sum_loop:
    add eax, [rdi + rbx*4]  ; Accumulate array element
    inc ebx
    cmp ebx, esi            ; Check count
    jb sum_loop
    mov rbx, [rsp-8]        ; Restore from red zone
    ret
```

**Microsoft x64 leaf function**:

```nasm
; Must allocate stack space (no red zone)
leaf_sum:
    sub rsp, 16             ; Allocate minimum space
    mov [rsp], rbx          ; Save callee-saved register
    xor eax, eax            ; Initialize sum
    xor ebx, ebx            ; Counter
sum_loop:
    add eax, [rcx + rbx*4]  ; Accumulate array element
    inc ebx
    cmp ebx, edx            ; Check count
    jb sum_loop
    mov rbx, [rsp]          ; Restore
    add rsp, 16
    ret
```

[Inference] Leaf function optimization significantly reduces overhead for small utility functions by eliminating unnecessary stack manipulation. The performance benefit is most pronounced for frequently-called simple functions where prologue/epilogue overhead represents a significant fraction of execution time.

### Exception Handling and Unwinding

Both platforms require functions to provide unwind information for exception handling, debugging, and profiling:

#### Windows Unwind Information

Windows requires functions to register unwind information in .pdata (procedure data) and .xdata (exception data) sections. The unwind information describes:

- Function start and end addresses
- Unwind codes describing prologue operations
- Exception handler addresses (if applicable)
- Frame register usage

```nasm
section .text
my_function:
    push rbp
    sub rsp, 32
    mov rbp, rsp
    ; ... function body ...
    leave
    ret

section .pdata
    dd my_function          ; Begin address
    dd my_function_end      ; End address
    dd unwind_info          ; Unwind info address

section .xdata
unwind_info:
    db 1, 4, 1, 0           ; Version, flags, prologue size, frame reg
    db 4                    ; Unwind code count
    ; Unwind codes (processed in reverse)
    dw 4, 0x0302            ; MOV RBP, RSP at offset 4
    dw 2, 0x4203            ; SUB RSP, 32 at offset 2
    dw 1, 0x0500            ; PUSH RBP at offset 1
```

[Inference] The unwind information enables stack walking during exception handling without requiring frame pointers, allowing RBP to be used as a general-purpose register while maintaining debuggability and exception safety.

#### System V Exception Handling

System V platforms use DWARF (Debugging With Attributed Record Formats) call frame information stored in .eh_frame sections. This information enables stack unwinding for C++ exceptions, debugging, and profiling.

```nasm
; Assembly code
section .text
my_function:
    .cfi_startproc          ; CFI (Call Frame Information) directive
    push rbp
    .cfi_def_cfa_offset 16
    .cfi_offset rbp, -16
    mov rbp, rsp
    .cfi_def_cfa_register rbp
    sub rsp, 32
    ; ... function body ...
    leave
    .cfi_def_cfa rsp, 8
    ret
    .cfi_endproc
```

[Inference] CFI directives allow the assembler to generate appropriate .eh_frame entries automatically. Hand-written assembly should include these directives to maintain proper exception handling behavior in mixed C++/assembly code.

### Position-Independent Code (PIC)

System V platforms often require position-independent code for shared libraries. x86-64's RIP-relative addressing mode facilitates PIC implementation:

```nasm
; Accessing global variable in PIC
section .data
global_var: dq 0

section .text
access_global:
    mov rax, [rel global_var]    ; RIP-relative load
    inc rax
    mov [rel global_var], rax    ; RIP-relative store
    ret

; Computing address of data
get_data_address:
    lea rax, [rel data_array]    ; Load effective address
    ret

; Calling function through PLT (Procedure Linkage Table)
call_external:
    call external_func wrt ..plt ; Position-independent call
    ret
```

RIP-relative addressing encodes memory references as signed 32-bit offsets from the instruction pointer, allowing code to execute correctly regardless of its absolute load address. The offset range (±2GB) accommodates typical shared library sizes.

[Inference] RIP-relative addressing was specifically designed to simplify position-independent code generation for x86-64, addressing a major weakness of 32-bit x86 where PIC required complex and inefficient instruction sequences involving GOT (Global Offset Table) access through general-purpose registers.

**Global Offset Table (GOT) Access**:

For accessing data beyond the ±2GB RIP-relative range or for external symbols requiring dynamic resolution:

```nasm
; Accessing external variable through GOT
section .text
access_external:
    mov rax, [rel external_var wrt ..got]  ; Get GOT entry address
    mov rbx, [rax]                          ; Load actual variable address
    mov rcx, [rbx]                          ; Load variable value
    ret
```

### Calling Convention Comparison Summary

|**Aspect**|**System V AMD64**|**Microsoft x64**|
|---|---|---|
|**Integer parameters**|RDI, RSI, RDX, RCX, R8, R9|RCX, RDX, R8, R9|
|**FP parameters**|XMM0-XMM7 (independent sequence)|XMM0-XMM3 (parallel with integer)|
|**Return value**|RAX (int), XMM0 (FP)|RAX (int), XMM0 (FP)|
|**Caller-saved**|RAX, RCX, RDX, RSI, RDI, R8-R11|RAX, RCX, RDX, R8-R11|
|**Callee-saved**|RBX, RBP, R12-R15|RBX, RBP, RDI, RSI, R12-R15|
|**XMM preservation**|None (all volatile)|XMM6-XMM15 (lower 128 bits)|
|**Red zone**|128 bytes below RSP|None|
|**Shadow space**|None|32 bytes above return address|
|**Stack alignment**|16 bytes before CALL|16 bytes before CALL|
|**Variadic indicator**|AL = XMM register count|All params accessible on stack|

### Performance Implications

#### Register Availability Impact

[Inference] The expanded register set dramatically improves performance for register-intensive workloads. Functions can maintain more live values across operations without spilling to memory, reducing load/store instructions and improving instruction-level parallelism.

Comparative studies of equivalent 32-bit and 64-bit code often show 20-40% performance improvements for integer-heavy workloads. [Inference] This improvement is largely attributable to reduced register pressure and elimination of memory spills rather than 64-bit arithmetic capabilities themselves.

**Example**: Register pressure comparison

```nasm
; 32-bit version (6 free registers: EAX, EBX, ECX, EDX, ESI, EDI)
; Processing requiring 8 values - must spill to memory
process_32bit:
    push ebx
    push esi
    push edi
    mov eax, [param1]
    mov ebx, [param2]
    mov ecx, [param3]
    mov edx, [param4]
    mov esi, [param5]
    mov edi, [param6]
    mov [temp1], [param7]    ; Spill to memory
    mov [temp2], [param8]    ; Spill to memory
    ; ... computation with frequent memory access ...

; 64-bit version (14 free registers after RSP and RBP)
; Processing 8 values - all in registers
process_64bit:
    mov rax, rdi             ; param1
    mov rbx, rsi             ; param2
    mov rcx, rdx             ; param3
    mov r8, rcx              ; param4 (from calling convention)
    mov r9, r8               ; param5
    mov r10, r9              ; param6
    mov r11, [rsp+8]         ; param7 (stack)
    mov r12, [rsp+16]        ; param8 (stack)
    ; ... computation entirely in registers ...
```

#### Parameter Passing Efficiency

[Inference] Register-based parameter passing eliminates the memory traffic of stack-based parameter passing used in 32-bit cdecl and stdcall conventions. For functions with six or fewer parameters (System V) or four or fewer (Windows), no memory writes occur for parameter transfer.

This translates to measurable performance improvements:

- Reduced memory bandwidth consumption
- Elimination of cache line allocations for parameter passing
- Faster function call overhead (no stack writes before CALL)

**Benchmark comparison** [Inference]:

- 32-bit cdecl with 4 parameters: ~6-10 cycles overhead (4 pushes, 4 pops)
- 64-bit with 4 parameters: ~2-3 cycles overhead (no parameter memory operations)

The combination of fast parameter passing and more available registers enables aggressive function inlining and tail call optimization by compilers, further improving performance.

#### Calling Convention Overhead Comparison

**System V ABI advantages**:

- Six register parameters vs. four (Windows) reduces stack usage
- Red zone eliminates stack allocation for simple leaf functions
- No shadow space requirement reduces stack consumption

**Microsoft x64 advantages**:

- Shadow space simplifies debugging and exception handling
- Parallel integer/FP register assignment is conceptually simpler
- More callee-saved registers (includes RDI, RSI) may reduce save/restore overhead in some cases

[Inference] For typical application code, the System V convention generally has slight performance advantages due to more register parameters and the red zone. However, the differences are modest, and both conventions are significantly more efficient than 32-bit alternatives.

#### Code Size Considerations

[Inference] 64-bit code is generally 10-30% larger than equivalent 32-bit code due to:

**REX prefixes**: Adding one byte to instructions accessing R8-R15 or performing 64-bit operations

**Wider displacements**: Memory references may require larger displacement fields

**Pointer sizes**: 64-bit pointers in data structures double pointer storage

**Immediate values**: Some operations require larger immediate encodings

**Example**: Code size comparison

```nasm
; 32-bit: 3 bytes
add eax, 5              ; 83 C0 05

; 64-bit using RAX: 4 bytes
add rax, 5              ; 48 83 C0 05 (REX.W prefix added)

; 64-bit using R8: 5 bytes
add r8, 5               ; 49 83 C0 05 (REX.W + REX.B)
```

[Inference] The code size increase can impact instruction cache efficiency, particularly for large applications with diverse code paths. However, the performance benefits of additional registers and efficient calling conventions generally outweigh the cache pressure increase in practice.

### Memory Addressing Modes

x86-64 supports the same addressing modes as 32-bit x86, with extended register sets and address calculations:

```nasm
; Direct addressing
mov rax, [address]              ; Absolute address (RIP-relative in PIC)

; Register indirect
mov rax, [rbx]                  ; [base]

; Register indirect with displacement
mov rax, [rbx + 16]             ; [base + disp8]
mov rax, [rbx + 1000]           ; [base + disp32]

; Indexed addressing
mov rax, [rbx + rcx]            ; [base + index]

; Scaled indexed addressing
mov rax, [rbx + rcx*4]          ; [base + index * scale]
mov rax, [rbx + rcx*8 + 32]     ; [base + index * scale + disp]

; RIP-relative (x86-64 specific)
mov rax, [rel symbol]           ; [RIP + disp32]

; Using extended registers
mov rax, [r12 + r13*8 + 64]     ; All addressing modes work with R8-R15
```

[Inference] The addressing mode flexibility, combined with 16 general-purpose registers, enables efficient data structure access with minimal address calculation overhead. Array indexing, structure member access, and pointer dereferencing can often be accomplished in single instructions without separate LEA operations.

### Platform-Specific Considerations

#### Address Space Layout

x86-64 provides 64-bit addressing, though current implementations typically support only 48 or 57 bits of virtual address space. Addresses must be canonical: bits 48-63 (or 57-63) must be sign-extensions of bit 47 (or 56).

```
48-bit address space (older processors):
  Canonical low:  0x0000000000000000 - 0x00007FFFFFFFFFFF
  Non-canonical:  0x0000800000000000 - 0xFFFF7FFFFFFFFFFF (invalid)
  Canonical high: 0xFFFF800000000000 - 0xFFFFFFFFFFFFFFFF

57-bit address space (newer processors with 5-level paging):
  Canonical low:  0x0000000000000000 - 0x00FFFFFFFFFFFFFF
  Non-canonical:  0x0100000000000000 - 0xFEFFFFFFFFFFFFFF (invalid)
  Canonical high: 0xFF00000000000000 - 0xFFFFFFFFFFFFFFFF
```

Non-canonical addresses cause general protection faults if dereferenced. [Inference] This requirement maintains address space organization and prevents accidental access to reserved regions, while also simplifying page table hardware by avoiding sparse address translation.

#### Virtual Memory Layout

**Linux typical layout** (48-bit):

```
0x00007FFFFFFFFFFF - User space ceiling
0x00007FFFnnnnnnnn - Stack (grows down)
0x00007FFFnnnnnnnn - Memory-mapped regions, shared libraries
0x0000nnnnnnnnnnnn - Heap (grows up)
0x0000000000400000 - Program text and data
0x0000000000000000 - Null page (unmapped)

0xFFFF800000000000 - Kernel space (inaccessible from user mode)
```

**Windows typical layout**:

```
0x00007FFFFFFFFFFF - User space ceiling
0x00007FFFnnnnnnnn - User mode accessible region
...
0x0000000000000000 - Null page (unmapped)

0xFFFF800000000000 - Kernel space
```

[Inference] The vast address space simplifies memory management and enables applications to use large memory-mapped regions without complex address space management schemes required in 32-bit environments.

#### ABI Stability and Binary Compatibility

Both System V AMD64 ABI and Microsoft x64 calling convention are stable, published specifications that ensure binary compatibility:

- **Libraries** compiled by different compilers can interoperate
- **Static linking** combines objects from various sources
- **Dynamic linking** allows runtime library loading and linking
- **System calls** use consistent interfaces

[Inference] This stability enables modular development, third-party libraries, and long-term binary compatibility across system updates. Hand-written assembly must strictly adhere to the appropriate ABI to maintain compatibility with C/C++ code and system libraries.

#### Cross-Platform Assembly

Writing assembly code that works on both System V and Windows platforms requires:

**Preprocessor conditionals** to select calling convention:

```nasm
%ifdef WINDOWS
    %define PARAM1 rcx
    %define PARAM2 rdx
    %define PARAM3 r8
    %define PARAM4 r9
%else  ; System V
    %define PARAM1 rdi
    %define PARAM2 rsi
    %define PARAM3 rdx
    %define PARAM4 rcx
%endif

function:
    %ifdef WINDOWS
        sub rsp, 40         ; Shadow space + alignment
    %endif
    
    mov rax, PARAM1         ; Platform-agnostic parameter access
    add rax, PARAM2
    
    %ifdef WINDOWS
        add rsp, 40
    %endif
    ret
```

**Alternative**: Write separate implementations for each platform or use compiler intrinsics and inline assembly where the compiler handles calling convention details automatically.

**Key Points:**

- x86-64 extends general-purpose registers to 64 bits (RAX-RSP) and adds eight new registers (R8-R15), doubling the register count to sixteen in 64-bit mode
- 32-bit operations on 64-bit registers automatically zero the upper 32 bits, eliminating explicit zero-extension instructions for unsigned 32-bit to 64-bit conversions
- REX prefix encoding enables 64-bit operations and R8-R15 register access, adding one byte to instruction size but providing essential functionality
- RIP-relative addressing facilitates position-independent code by encoding memory references as offsets from the instruction pointer
- [Inference] The expanded register set dramatically reduces register pressure and memory spill traffic, improving performance by 20-40% for register-intensive workloads compared to 32-bit equivalents
- System V AMD64 ABI passes six integer parameters in registers (RDI, RSI, RDX, RCX, R8, R9) and provides a 128-byte red zone below RSP for leaf function optimization
- Microsoft x64 convention passes four integer parameters in registers (RCX, RDX, R8, R9) and requires 32 bytes of shadow space above the return address for parameter spilling
- Both conventions require 16-byte stack alignment before CALL instructions to support efficient vector operations and maintain ABI consistency
- [Inference] Register-based parameter passing eliminates memory traffic for most function calls, substantially improving call overhead compared to 32-bit stack-based conventions
- Callee-saved register sets differ between platforms: System V preserves RBX, RBP, R12-R15, while Windows additionally preserves RDI, RSI, and XMM6-XMM15 (lower 128 bits)\

---

