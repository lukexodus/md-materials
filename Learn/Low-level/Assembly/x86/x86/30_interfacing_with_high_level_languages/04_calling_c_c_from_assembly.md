## Calling C/C++ from Assembly


Assembly code can call C/C++ functions by following the calling convention, setting up parameters correctly, and managing the stack.

### Basic Approach

**Declare External Function**: Mark C/C++ functions as external in assembly.

```nasm
section .text
extern printf           ; C library function
extern my_cpp_function  ; User-defined function
```

**Set Up Parameters**: Place arguments in the correct registers or stack locations according to the ABI.

**Align Stack**: Ensure the stack is 16-byte aligned before the call (especially important on x86-64).

**Call the Function**: Use the CALL instruction to invoke the function.

**Handle Return Value**: The return value will be in RAX (or EAX for 32-bit).

### Calling printf Example (System V)

```nasm
section .data
    format db "Hello, %s! Number: %d", 10, 0
    name db "World", 0

section .text
global main
extern printf

main:
    push rbp            ; Set up stack frame
    mov rbp, rsp
    
    ; Align stack (rsp was 16-byte aligned, push made it 8-byte aligned)
    ; Call will push return address (8 bytes), making it 16-byte aligned again
    
    lea rdi, [rel format]  ; First arg: format string
    lea rsi, [rel name]    ; Second arg: string to print
    mov edx, 42            ; Third arg: number
    xor eax, eax           ; AL = 0 (no vector registers used)
    call printf
    
    xor eax, eax        ; Return 0
    pop rbp
    ret
```

**Key Points:**

- RDI gets the format string address
- RSI gets the name string address
- EDX gets the integer value
- RAX (specifically AL) must be 0 for System V when calling variadic functions with no floating-point arguments
- Stack alignment is maintained through the push/pop sequence

### Stack Alignment Details

x86-64 requires 16-byte alignment before CALL. [Inference] When main is called, RSP is 16-byte aligned. Each PUSH decrements RSP by 8 bytes:

```nasm
; Entry: RSP % 16 == 0
push rbp        ; RSP % 16 == 8 (misaligned)
mov rbp, rsp    ; RBP saved

; Before call: RSP % 16 == 8
; CALL pushes return address: RSP % 16 == 0 (aligned)
call printf

; After return: RSP % 16 == 8 again
pop rbp         ; RSP % 16 == 0
ret
```

If additional stack space is needed, adjust RSP to maintain alignment:

```nasm
push rbp
mov rbp, rsp
sub rsp, 16         ; Allocate 16 bytes (maintains alignment)
; Now RSP % 16 == 8

; ... do work ...

mov rsp, rbp
pop rbp
ret
```

### Calling C++ Functions from Assembly

For C++ functions with `extern "C"` linkage:

```cpp
// mylib.cpp
extern "C" {
    int compute_value(int x, int y) {
        return x * x + y * y;
    }
}
```

```nasm
; caller.asm
section .text
global calculate
extern compute_value

calculate:
    ; int calculate()
    push rbp
    mov rbp, rsp
    
    mov edi, 3          ; First arg
    mov esi, 4          ; Second arg
    call compute_value  ; Returns in eax
    
    ; eax now contains result
    pop rbp
    ret
```

For C++ functions without `extern "C"`, you must use the mangled name:

```cpp
// mylib.cpp
int MyClass::compute(int x) {
    return x * 2;
}
```

```nasm
; caller.asm
extern _ZN7MyClass7computeEi  ; Mangled name for MyClass::compute(int)

call_method:
    mov rdi, [object_ptr]   ; 'this' pointer
    mov esi, 42             ; argument
    call _ZN7MyClass7computeEi
    ret
```

[Inference] Using mangled names directly is fragile because mangling schemes vary between compilers and versions.

### Preserving Registers Across Calls

Caller-saved registers (volatile) may be destroyed by the called function. [Inference] If you need their values after the call, save them first:

```nasm
section .text
extern some_function

my_function:
    push rbp
    mov rbp, rsp
    
    mov r10, 100        ; Store value in caller-saved register
    
    ; Need to call function but preserve r10
    push r10            ; Save it
    
    mov edi, 5          ; Set up argument
    call some_function
    
    pop r10             ; Restore r10
    
    ; Continue using r10
    add eax, r10d       ; Use preserved value
    
    pop rbp
    ret
```

### Windows x64 Calling Convention

Windows requires 32 bytes of shadow space for the callee:

```nasm
; Windows x64
section .text
extern printf
global my_function

my_function:
    push rbp
    mov rbp, rsp
    sub rsp, 32         ; Allocate shadow space (must be multiple of 16)
    
    lea rcx, [rel format]   ; First arg in RCX
    mov edx, 42             ; Second arg in EDX
    call printf
    
    add rsp, 32
    pop rbp
    ret

section .data
    format db "Value: %d", 10, 0
```

### Calling Variadic Functions

When calling variadic functions on System V ABI, RAX (specifically AL) must contain the number of vector registers (XMM) used:

```nasm
extern printf

print_mixed:
    ; printf("Int: %d, Float: %f\n", 42, 3.14)
    
    lea rdi, [rel format]       ; Format string
    mov esi, 42                 ; Integer argument
    movsd xmm0, [rel pi_value]  ; Float argument in xmm0
    mov al, 1                   ; AL = 1 (one XMM register used)
    call printf
    ret

section .data
    format db "Int: %d, Float: %f", 10, 0
    pi_value dq 3.14
```

### Complex Example: Calling C++ Constructor

Calling a C++ constructor requires allocating memory and passing the `this` pointer:

```cpp
// myclass.cpp
class MyClass {
public:
    int value;
    
    MyClass(int v) : value(v) {}
    
    int getValue() { return value; }
};

extern "C" {
    MyClass* create_myclass(int v) {
        return new MyClass(v);
    }
    
    int call_getvalue(MyClass* obj) {
        return obj->getValue();
    }
}
```

```nasm
; caller.asm
extern create_myclass
extern call_getvalue

section .text
global test_function

test_function:
    push rbp
    mov rbp, rsp
    push rbx                ; Save callee-saved
    
    mov edi, 42             ; Constructor argument
    call create_myclass     ; Returns pointer in rax
    
    mov rbx, rax            ; Save object pointer
    
    mov rdi, rbx            ; Pass object pointer
    call call_getvalue      ; Returns value in eax
    
    ; eax contains the result
    
    pop rbx
    pop rbp
    ret
```

### Error Handling

Many C functions return error codes or set errno. [Inference] Assembly code must check these appropriately:

```nasm
extern fopen
extern fclose
extern perror

open_file:
    push rbp
    mov rbp, rsp
    
    lea rdi, [rel filename]
    lea rsi, [rel mode]
    call fopen              ; Returns FILE* in rax
    
    test rax, rax           ; Check for NULL
    jz .error
    
    ; Success: file handle in rax
    mov rbx, rax            ; Save handle
    
    ; ... use file ...
    
    mov rdi, rbx
    call fclose
    
    xor eax, eax            ; Return 0 (success)
    jmp .done
    
.error:
    lea rdi, [rel error_msg]
    call perror
    mov eax, -1             ; Return -1 (error)
    
.done:
    pop rbp
    ret

section .data
    filename db "data.txt", 0
    mode db "r", 0
    error_msg db "File open failed", 0
```

**Key Points:**

- Follow the target platform's calling convention precisely
- Maintain stack alignment before calls
- Preserve callee-saved registers if you use them
- Set AL correctly for variadic functions on System V
- Handle return values and error conditions appropriately
- Use `extern "C"` in C++ headers to prevent name mangling
- Test interoperability thoroughly across different compilers and platforms

---

**Related topics for deeper understanding**: Function prologue and epilogue patterns, Position-Independent Code (PIC) for shared libraries, exception handling across language boundaries, Thread-Local Storage (TLS) access from assembly, SIMD parameter passing conventions, debugging mixed-language programs.

---

