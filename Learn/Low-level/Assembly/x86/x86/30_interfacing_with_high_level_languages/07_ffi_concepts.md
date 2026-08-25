## FFI Concepts


### Foreign Function Interface Overview

FFI (Foreign Function Interface) is the mechanism by which code written in one language can call code written in another language. For assembly interfacing with high-level languages, this primarily involves understanding calling conventions, name mangling, and data representation.

### Name Mangling

High-level languages often mangle function names to encode additional information. Assembly must use the correct mangled names or extern "C" linkage.

**C++ name mangling:**

```cpp
// C++ code
namespace Math {
    int add(int a, int b);
    int add(double a, double b);  // Overload
}
```

**Mangled names (GCC/Clang example):**

```
_ZN4Math3addEii      // Math::add(int, int)
_ZN4Math3addEdd      // Math::add(double, double)
```

**[Inference]** Mangled names are compiler-specific and should generally be avoided for FFI. Use `extern "C"` linkage instead.

**Using extern "C" to prevent mangling:**

```cpp
extern "C" {
    int add(int a, int b);  // No mangling, name is just "add"
}
```

**Assembly side:**

```nasm
; Can now reference by simple name
global add
add:
    mov eax, edi
    add eax, esi
    ret
```

### C Calling Convention Review

**System V AMD64 ABI (Linux, macOS, BSD):**

- Integer/pointer arguments: `rdi, rsi, rdx, rcx, r8, r9`, then stack
- Floating-point arguments: `xmm0-xmm7`, then stack
- Return value: `rax` (integer), `xmm0` (float)
- Callee-saved: `rbx, rbp, r12-r15`
- Caller-saved: `rax, rcx, rdx, rsi, rdi, r8-r11`
- Stack must be 16-byte aligned before `call`

**Windows x64 calling convention:**

- First 4 integer/pointer arguments: `rcx, rdx, r8, r9`, then stack
- First 4 float arguments: `xmm0-xmm3`, then stack
- Return value: `rax` (integer), `xmm0` (float)
- Callee-saved: `rbx, rbp, rdi, rsi, r12-r15`
- Caller-saved: `rax, rcx, rdx, r8-r11`
- Shadow space: 32 bytes reserved on stack for first 4 parameters
- Stack must be 16-byte aligned before `call`

### Calling Assembly from C

**C declaration:**

```c
// C header
extern int asm_add(int a, int b);
```

**Assembly implementation (System V):**

```nasm
global asm_add
asm_add:
    ; Parameters: edi = a, esi = b
    mov eax, edi
    add eax, esi
    ret
```

**Assembly implementation (Windows):**

```nasm
global asm_add
asm_add:
    ; Parameters: ecx = a, edx = b
    mov eax, ecx
    add eax, edx
    ret
```

### Calling C from Assembly

**C function:**

```c
void log_message(const char* msg);
```

**Assembly calling C (System V):**

```nasm
extern log_message

section .rodata
    msg: db "Hello from assembly", 0

section .text
global my_function
my_function:
    push rbp
    mov rbp, rsp
    
    ; Load string pointer into rdi (first argument)
    lea rdi, [rel msg]
    
    ; Stack already aligned (after push rbp, before call)
    ; Need to align to 16 bytes before call
    sub rsp, 8          ; Align stack
    
    call log_message
    
    add rsp, 8          ; Restore stack
    
    pop rbp
    ret
```

**Assembly calling C (Windows):**

```nasm
extern log_message

section .data
    msg: db "Hello from assembly", 0

section .text
global my_function
my_function:
    push rbp
    mov rbp, rsp
    
    ; Allocate shadow space + alignment
    sub rsp, 32         ; Shadow space (required)
    
    ; Load string pointer into rcx (first argument)
    lea rcx, [msg]
    
    call log_message
    
    add rsp, 32         ; Clean up shadow space
    
    pop rbp
    ret
```

### Passing Structures by Value

When structures are passed by value, the mechanism varies by size and platform.

**Small structures (System V, ≤16 bytes):**

- Passed in registers if they fit
- Classification algorithm determines which registers

**Example:**

```c
struct Point {
    int x, y;  // 8 bytes total
};

int get_x(struct Point p);  // Passed in rdi (entire struct)
```

**Assembly:**

```nasm
global get_x
get_x:
    ; rdi contains both x and y
    ; x in lower 32 bits, y in upper 32 bits
    mov eax, edi        ; Extract x (lower 32 bits)
    ret
```

**Large structures (>16 bytes on System V, any size on Windows):**

- Caller allocates space and passes pointer
- Pointer to structure becomes first argument

**Example:**

```c
struct Large {
    long data[10];  // 80 bytes
};

void process(struct Large s);
```

**Assembly (System V):**

```nasm
global process
process:
    ; rdi points to Large structure (not the structure itself)
    mov rax, [rdi]      ; Access first element
    ; ...
    ret
```

### Returning Structures

**Small structures (≤16 bytes on System V):**

- Returned in `rax` (and `rdx` if needed)

**Example:**

```c
struct Point make_point(int x, int y);
```

**Assembly:**

```nasm
global make_point
make_point:
    ; edi = x, esi = y
    ; Return in rax: lower 32 bits = x, upper 32 bits = y
    mov eax, edi
    shl rsi, 32
    or rax, rsi
    ret
```

**Large structures:**

- Caller allocates space
- Pointer passed as hidden first argument
- Function writes to that space and returns pointer

**Example:**

```c
struct Large make_large(void);
```

**Assembly (System V):**

```nasm
global make_large
make_large:
    ; rdi points to caller-allocated space (hidden first argument)
    ; Fill the structure
    mov qword [rdi], 123        ; First element
    mov qword [rdi + 8], 456    ; Second element
    ; ... fill rest ...
    
    ; Return pointer in rax
    mov rax, rdi
    ret
```

### Variable Arguments (Varargs)

Functions with variable arguments (`printf`, etc.) require special handling.

**System V varargs:**

- Register save area: caller doesn't know how many arguments function uses
- `va_list` contains state to walk through arguments
- Assembly generally shouldn't implement varargs functions

**Calling varargs function from assembly:**

```nasm
extern printf

section .rodata
    fmt: db "Value: %d, %f", 10, 0

section .text
call_printf:
    push rbp
    mov rbp, rsp
    
    ; Format string in rdi
    lea rdi, [rel fmt]
    
    ; Integer argument in esi
    mov esi, 42
    
    ; Float argument in xmm0
    mov eax, __float32__(3.14)
    movd xmm0, eax
    
    ; AL contains number of vector registers used (for varargs)
    mov al, 1
    
    ; Align stack
    sub rsp, 8
    call printf
    add rsp, 8
    
    pop rbp
    ret
```

**Windows varargs:**

- Simpler: all arguments beyond first 4 go on stack
- Floating-point arguments consume both integer and XMM register slots

### Function Pointers and Callbacks

Function pointers allow high-level languages to call assembly functions dynamically.

**C code with callback:**

```c
typedef int (*callback_t)(int);

int call_with_value(callback_t func, int value) {
    return func(value);
}
```

**Assembly function to use as callback (System V):**

```nasm
global my_callback
my_callback:
    ; Parameter in edi
    mov eax, edi
    imul eax, eax       ; Square the value
    ret
```

**Using the callback from C:**

```c
extern int my_callback(int);

int result = call_with_value(my_callback, 5);  // result = 25
```

**Assembly calling through function pointer:**

```nasm
; rdi = function pointer, esi = value
call_function_pointer:
    push rbp
    mov rbp, rsp
    
    ; Save function pointer
    mov r10, rdi
    
    ; Setup argument
    mov edi, esi
    
    ; Call through pointer
    call r10
    
    pop rbp
    ret
```

### Thread-Local Storage (TLS)

Accessing thread-local variables from assembly requires platform-specific mechanisms.

**Linux TLS access (x86-64):**

```nasm
; C declaration: __thread int tls_var;

extern tls_var

section .text
access_tls:
    ; General dynamic model
    lea rdi, [rel tls_var]
    call __tls_get_addr@PLT
    mov eax, [rax]      ; Read TLS variable
    ret
```

**[Unverified]** Windows TLS uses different mechanism with `gs` segment register on x64.

### Dynamic Linking and Position-Independent Code

**Position-Independent Code (PIC) for shared libraries (Linux):**

```nasm
; Access global variable through GOT
global get_global
get_global:
    ; Get RIP-relative address
    lea rax, [rel global_var@GOTPCREL]
    mov rax, [rax]
    mov eax, [rax]
    ret
```

**Calling external function with PLT:**

```nasm
extern external_func

call_external:
    call external_func@PLT  ; Through Procedure Linkage Table
    ret
```

### Inline Assembly in C

Many compilers support inline assembly, allowing assembly code within C functions.

**GCC/Clang inline assembly (extended syntax):**

```c
int add_asm(int a, int b) {
    int result;
    __asm__ (
        "movl %1, %%eax\n\t"
        "addl %2, %%eax\n\t"
        "movl %%eax, %0"
        : "=r" (result)          // Output operands
        : "r" (a), "r" (b)       // Input operands
        : "%eax"                 // Clobbered registers
    );
    return result;
}

````

**Inline assembly syntax components:**
- **Assembly template**: The actual assembly instructions
- **Output operands**: Variables to receive results (`=` for write-only, `+` for read-write)
- **Input operands**: Variables to pass as inputs
- **Clobbers**: Registers/memory modified by the assembly

**Constraint letters:**
- `"r"`: General-purpose register
- `"a"`, `"b"`, `"c"`, `"d"`: Specific registers (rax, rbx, rcx, rdx)
- `"m"`: Memory operand
- `"i"`: Immediate constant
- `"x"`: SSE register
- `"=r"`: Output in register
- `"+r"`: Input/output in register

**Example with memory operand:**
```c
void atomic_increment(int *ptr) {
    __asm__ volatile (
        "lock incl %0"
        : "+m" (*ptr)      // Read-write memory operand
        :
        : "cc"             // Condition codes clobbered
    );
}
````

**Example with specific registers:**

```c
uint64_t rdtsc_inline(void) {
    uint32_t lo, hi;
    __asm__ volatile (
        "rdtsc"
        : "=a" (lo), "=d" (hi)   // eax and edx outputs
    );
    return ((uint64_t)hi << 32) | lo;
}
```

**Volatile keyword:** The `volatile` qualifier prevents the compiler from optimizing away or reordering the assembly block:

```c
__asm__ volatile ("mfence" ::: "memory");  // Memory barrier
```

**Memory clobber:** Using `"memory"` in clobbers tells the compiler the assembly might read/write any memory:

```c
__asm__ volatile (
    "some_instruction"
    :
    :
    : "memory"    // Prevents memory-related optimizations across this point
);
```

### MSVC Inline Assembly

**MSVC x86 (32-bit) inline assembly:**

```c
int add_msvc(int a, int b) {
    __asm {
        mov eax, a
        add eax, b
    }
    // Result implicitly in eax
}
```

**Note:** MSVC x64 does **not** support inline assembly. Must use intrinsics or separate .asm files.

**MSVC intrinsics (x64 alternative):**

```c
#include <intrin.h>

void atomic_increment_msvc(long volatile *ptr) {
    _InterlockedIncrement(ptr);
}

void memory_barrier_msvc(void) {
    _mm_mfence();
}
```

### Compiler Intrinsics

Intrinsics provide a middle ground between C and assembly—they look like C functions but compile directly to specific assembly instructions.

**Common intrinsics (GCC/Clang):**

```c
#include <x86intrin.h>

// Atomic operations
int old = __sync_fetch_and_add(&counter, 1);
bool success = __sync_bool_compare_and_swap(&value, expected, new_val);

// Memory barriers
__sync_synchronize();  // Full memory barrier

// Bit manipulation
int count = __builtin_popcount(value);      // Count set bits
int leading = __builtin_clz(value);         // Count leading zeros

// SIMD operations
__m128 v = _mm_set_ps(1.0f, 2.0f, 3.0f, 4.0f);
__m128 result = _mm_add_ps(v, v);
```

**MSVC intrinsics:**

```c
#include <intrin.h>

// Atomic operations
long old = _InterlockedExchangeAdd(&counter, 1);
long old_val = _InterlockedCompareExchange(&value, new_val, expected);

// Memory barriers
_ReadWriteBarrier();   // Compiler barrier
_mm_mfence();         // Hardware memory fence

// Bit manipulation
int count = __popcnt(value);
unsigned long index;
_BitScanReverse(&index, value);  // Find highest set bit
```

### Language-Specific Considerations

#### Rust FFI

Rust requires explicit `extern "C"` declarations and uses `#[no_mangle]` to prevent name mangling:

**Rust calling assembly:**

```rust
extern "C" {
    fn asm_add(a: i32, b: i32) -> i32;
}

fn main() {
    unsafe {
        let result = asm_add(5, 3);
        println!("Result: {}", result);
    }
}
```

**Assembly callable from Rust (System V):**

```nasm
global asm_add
asm_add:
    mov eax, edi
    add eax, esi
    ret
```

**Rust function callable from assembly:**

```rust
#[no_mangle]
pub extern "C" fn rust_function(x: i32) -> i32 {
    x * 2
}
```

#### Python FFI (ctypes)

Python can call assembly functions through shared libraries:

**Assembly (compiled to shared library):**

```nasm
global add_numbers
add_numbers:
    mov eax, edi
    add eax, esi
    ret
```

**Compile to shared library:**

```bash
nasm -f elf64 add.asm -o add.o
gcc -shared -o libadd.so add.o
```

**Python code:**

```python
import ctypes

# Load shared library
lib = ctypes.CDLL('./libadd.so')

# Define function signature
lib.add_numbers.argtypes = [ctypes.c_int, ctypes.c_int]
lib.add_numbers.restype = ctypes.c_int

# Call function
result = lib.add_numbers(5, 3)
print(f"Result: {result}")
```

**Passing structures:**

```python
class Point(ctypes.Structure):
    _fields_ = [("x", ctypes.c_int),
                ("y", ctypes.c_int)]

lib.process_point.argtypes = [ctypes.POINTER(Point)]
lib.process_point.restype = None

p = Point(10, 20)
lib.process_point(ctypes.byref(p))
```

#### Go FFI (cgo)

Go can interface with C and assembly through cgo:

**Assembly function:**

```nasm
global asm_add
asm_add:
    mov eax, edi
    add eax, esi
    ret
```

**Go code:**

```go
package main

// #cgo LDFLAGS: add.o
// extern int asm_add(int a, int b);
import "C"
import "fmt"

func main() {
    result := C.asm_add(5, 3)
    fmt.Printf("Result: %d\n", result)
}
```

### ABI Compatibility Testing

**[Inference]** Testing ABI compatibility is critical to ensure assembly functions work correctly with high-level language code.

**Test framework example (C):**

```c
// test_abi.c
#include <assert.h>
#include <stdio.h>

// Assembly function declarations
extern int asm_add(int a, int b);
extern struct Point asm_make_point(int x, int y);
extern void asm_modify_array(int *arr, size_t len);

struct Point {
    int x, y;
};

void test_simple_call(void) {
    assert(asm_add(2, 3) == 5);
    assert(asm_add(-1, 1) == 0);
    printf("test_simple_call passed\n");
}

void test_struct_return(void) {
    struct Point p = asm_make_point(10, 20);
    assert(p.x == 10);
    assert(p.y == 20);
    printf("test_struct_return passed\n");
}

void test_array_modification(void) {
    int arr[] = {1, 2, 3, 4, 5};
    asm_modify_array(arr, 5);
    assert(arr[0] == 2);  // Assuming function doubles values
    assert(arr[4] == 10);
    printf("test_array_modification passed\n");
}

int main(void) {
    test_simple_call();
    test_struct_return();
    test_array_modification();
    printf("All tests passed!\n");
    return 0;
}
```

### Debugging FFI Issues

**Common FFI problems:**

1. **Wrong calling convention**: Mismatch between caller and callee expectations

```nasm
; Wrong: Using Windows convention on Linux
global wrong_func
wrong_func:
    mov eax, ecx    ; ecx not used for first param on System V!
    ret
```

2. **Stack misalignment**: Stack not 16-byte aligned before call

```nasm
; Wrong: Odd number of pushes before call
push rbx
call some_function    ; Stack misaligned!
```

3. **Clobbered callee-saved registers**: Not preserving required registers

```nasm
; Wrong: Modifying rbx without saving
modify_rbx:
    mov rbx, 0    ; Violates ABI! rbx is callee-saved
    ret
```

4. **Incorrect structure layout**: Assembly assumptions don't match compiler layout

```c
struct Wrong {
    char a;
    int b;    // Compiler adds 3 bytes padding here
};
```

```nasm
; Wrong: Assuming no padding
mov al, [rdi]      ; a at offset 0 - correct
mov ebx, [rdi+1]   ; Wrong! b is at offset 4, not 1
```

**Debugging techniques:**

**Use GDB to inspect calling convention:**

```bash
gdb ./program
(gdb) break asm_function
(gdb) run
(gdb) info registers    # Check register values
(gdb) x/10gx $rsp       # Examine stack
```

**Verify structure layout with offsetof:**

```c
#include <stddef.h>
#include <stdio.h>

struct MyStruct {
    char a;
    int b;
    double c;
};

int main(void) {
    printf("Offset of a: %zu\n", offsetof(struct MyStruct, a));
    printf("Offset of b: %zu\n", offsetof(struct MyStruct, b));
    printf("Offset of c: %zu\n", offsetof(struct MyStruct, c));
    printf("Size: %zu\n", sizeof(struct MyStruct));
    return 0;
}
```

**Check stack alignment:**

```nasm
; Debug helper to check stack alignment
check_stack_alignment:
    mov rax, rsp
    and rax, 15         ; Check lower 4 bits
    test rax, rax
    jz .aligned
    ; Stack misaligned - debug break or log
    int3
.aligned:
    ret
```

**Use compiler-generated assembly as reference:**

```bash
# Generate assembly from C
gcc -S -O2 example.c -o example.s

# Or with Clang
clang -S -O2 example.c -o example.s
```

Compare compiler-generated code to understand expected ABI usage.

### Platform Abstraction

For cross-platform assembly, use conditional assembly:

```nasm
%ifdef WINDOWS
    %define PARAM1 rcx
    %define PARAM2 rdx
    %define SHADOW_SPACE 32
%else
    %define PARAM1 rdi
    %define PARAM2 rsi
    %define SHADOW_SPACE 0
%endif

global my_function
my_function:
    push rbp
    mov rbp, rsp
    
%if SHADOW_SPACE > 0
    sub rsp, SHADOW_SPACE
%endif
    
    ; Use PARAM1 and PARAM2 macros
    mov eax, PARAM1
    add eax, PARAM2
    
%if SHADOW_SPACE > 0
    add rsp, SHADOW_SPACE
%endif
    
    pop rbp
    ret
```

**Build system support:**

```makefile
# Makefile
ifeq ($(OS),Windows_NT)
    DEFINES = -DWINDOWS
    ASM_FORMAT = win64
else
    DEFINES = 
    ASM_FORMAT = elf64
endif

%.o: %.asm
    nasm -f $(ASM_FORMAT) $(DEFINES) $< -o $@
```

### Best Practices for FFI

1. **Always use extern "C" linkage** for functions intended for FFI
2. **Document calling convention** explicitly in comments
3. **Preserve callee-saved registers** according to ABI
4. **Maintain stack alignment** (16-byte boundary before calls)
5. **Use simple types** when possible (avoid complex structures)
6. **Test thoroughly** on all target platforms
7. **Provide C wrapper functions** for complex assembly functionality
8. **Use intrinsics** when available instead of inline assembly
9. **Version your ABI** if it might change
10. **Document structure layouts** with explicit padding

**Key Points:**

- FFI requires matching calling conventions precisely between languages
- C linkage (`extern "C"`) prevents name mangling in C++
- Structure passing/returning varies by size and platform
- Inline assembly provides integration within C code but syntax varies by compiler
- Compiler intrinsics offer portable alternative to inline assembly
- [Inference] Cross-platform assembly requires conditional compilation based on target OS/ABI
- Testing ABI compatibility is essential for reliable FFI
- Use compiler-generated assembly as reference for correct ABI usage
- [Unverified] Some language-specific FFI mechanisms (like Rust, Go, Python ctypes) add their own overhead and conventions

**Important related topics:** Platform-specific ABIs in detail (Windows x64, System V AMD64, ARM AAPCS), Name mangling schemes (Itanium C++ ABI), Dynamic linking and symbol resolution (GOT, PLT), SIMD calling conventions (vector parameter passing), WebAssembly interface types for future FFI standards

---

