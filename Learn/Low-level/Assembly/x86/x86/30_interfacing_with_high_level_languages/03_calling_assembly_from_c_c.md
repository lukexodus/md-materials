## Calling Assembly from C/C++


Calling assembly routines from C/C++ requires declaring the function prototype in C/C++ and implementing it in assembly following the target platform's ABI.

### Basic Approach

**Declare the Function**: Create a header file with function prototypes, using `extern "C"` in C++ to prevent mangling.

```c
// math_funcs.h
#ifdef __cplusplus
extern "C" {
#endif

int add_numbers(int a, int b);
long multiply_64(long a, long b);

#ifdef __cplusplus
}
#endif
```

**Implement in Assembly**: Create an assembly file with the function implementation, marking symbols as global and following the calling convention.

```nasm
; math_funcs.asm (NASM syntax, x86-64 System V ABI)
section .text
global add_numbers
global multiply_64

add_numbers:
    ; Parameters: edi = a, esi = b
    mov eax, edi        ; Move first arg to return register
    add eax, esi        ; Add second arg
    ret                 ; Return value in eax

multiply_64:
    ; Parameters: rdi = a, rsi = b
    mov rax, rdi        ; Move first arg to rax
    imul rax, rsi       ; Multiply by second arg
    ret                 ; Return value in rax
```

**Compile and Link**: Assemble the assembly file and link with C/C++ object files.

```bash
nasm -f elf64 math_funcs.asm -o math_funcs.o
gcc main.c math_funcs.o -o program
```

### Platform Considerations

**System V ABI (Linux/macOS)**: Integer arguments in RDI, RSI, RDX, RCX, R8, R9. Return in RAX. Must preserve RBX, RBP, R12-R15.

**Windows x64**: Integer arguments in RCX, RDX, R8, R9. Must allocate shadow space. Must preserve RBX, RBP, RDI, RSI, RSP, R12-R15.

**32-bit**: Default cdecl convention passes all arguments on stack (right-to-left), caller cleans up. Return value in EAX.

### Advanced Examples

**Preserving Registers** (System V):

```nasm
section .text
global process_array

process_array:
    ; void process_array(int* arr, size_t len)
    ; rdi = arr, rsi = len
    push rbx            ; Save callee-saved register
    push r12
    
    mov r12, rdi        ; Save array pointer
    xor rbx, rbx        ; Counter = 0
    
.loop:
    cmp rbx, rsi        ; Compare counter with length
    jge .done
    
    mov eax, [r12 + rbx*4]  ; Load array[i]
    add eax, 10             ; Process element
    mov [r12 + rbx*4], eax  ; Store back
    
    inc rbx
    jmp .loop
    
.done:
    pop r12             ; Restore registers
    pop rbx
    ret
```

**Floating-Point Parameters**:

```nasm
section .text
global compute_distance

compute_distance:
    ; double compute_distance(double x1, double y1, double x2, double y2)
    ; xmm0 = x1, xmm1 = y1, xmm2 = x2, xmm3 = y2
    
    subsd xmm2, xmm0    ; dx = x2 - x1
    subsd xmm3, xmm1    ; dy = y2 - y1
    
    mulsd xmm2, xmm2    ; dx^2
    mulsd xmm3, xmm3    ; dy^2
    
    addsd xmm2, xmm3    ; dx^2 + dy^2
    sqrtsd xmm0, xmm2   ; sqrt(dx^2 + dy^2)
    ret                 ; Return in xmm0
```

**Windows x64 Example**:

```nasm
section .text
global add_numbers

add_numbers:
    ; int add_numbers(int a, int b)
    ; ecx = a, edx = b
    
    ; Shadow space already allocated by caller
    mov eax, ecx        ; Move first arg to return register
    add eax, edx        ; Add second arg
    ret
```

### Inline Assembly

Some compilers support inline assembly for embedding assembly instructions directly in C/C++ code:

**GCC/Clang Extended Asm**:

```c
int add_numbers(int a, int b) {
    int result;
    asm("addl %1, %2"
        : "=r" (result)           // Output: result in any register
        : "r" (a), "0" (b)        // Inputs: a in register, b in same as output
    );
    return result;
}
```

**MSVC Inline Assembly** (x86 only, not x64):

```c
int add_numbers(int a, int b) {
    __asm {
        mov eax, a
        add eax, b
    }
    // Return value in eax
}
```

[Inference] Inline assembly is less portable and harder to optimize than separate assembly files, but useful for small optimizations or accessing special instructions.

