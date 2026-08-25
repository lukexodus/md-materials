## Exception Handling Integration


### Overview of Exception Models

Modern high-level languages use structured exception handling (SEH on Windows, or stack unwinding with DWARF on Unix/Linux). Assembly code that interfaces with these languages must be aware of exception handling mechanisms to maintain correct program behavior.

**[Unverified]** Exception handling in assembly requires generating metadata that describes how to unwind the stack through assembly functions. The exact format and requirements vary significantly between platforms.

### Windows SEH (Structured Exception Handling)

Windows x64 uses table-based exception handling. The executable contains metadata describing each function's stack frame layout, allowing the system to unwind the stack during exceptions.

**Basic SEH concepts:**

- **Prologue/Epilogue**: Standardized function entry/exit sequences
- **Unwind data**: Metadata describing stack frame
- **Exception directory**: Table mapping code addresses to unwind data
- **Language-specific handler**: Optional handler for language-specific cleanup

**Function prologue with unwind info:**

```nasm
; Windows x64 function with SEH
MyFunction:
    .seh_proc MyFunction       ; Begin SEH directives
    
    ; Prologue
    push rbp
    .seh_pushreg rbp           ; Record that rbp was pushed
    
    sub rsp, 32
    .seh_stackalloc 32         ; Record stack allocation
    
    lea rbp, [rsp + 32]
    .seh_setframe rbp, 32      ; Record frame pointer
    
    .seh_endprologue           ; Prologue ends here
    
    ; Function body
    ; ... code ...
    
    ; Epilogue
    add rsp, 32
    pop rbp
    ret
    
    .seh_endproc               ; End SEH directives
```

**SEH directives (MASM/NASM syntax varies):**

- `.seh_proc`: Begin function with SEH
- `.seh_pushreg`: Record register push
- `.seh_stackalloc`: Record stack space allocation
- `.seh_setframe`: Record frame pointer setup
- `.seh_endprologue`: Mark end of prologue (must be within 255 bytes)
- `.seh_endproc`: End function

**Requirements for SEH compatibility:**

- Prologue must be contiguous and match unwind directives exactly
- All stack manipulations in prologue must be recorded
- Prologue must be ≤255 bytes
- No stack operations between prologue and first instruction that might fault

**Example with saved registers:**

```nasm
MyFunc:
    .seh_proc MyFunc
    
    push rbp
    .seh_pushreg rbp
    push rbx
    .seh_pushreg rbx
    push rsi
    .seh_pushreg rsi
    
    sub rsp, 48
    .seh_stackalloc 48
    
    lea rbp, [rsp + 48]
    .seh_setframe rbp, 48
    
    .seh_endprologue
    
    ; ... function body ...
    
    ; Epilogue (symmetrical)
    add rsp, 48
    pop rsi
    pop rbx
    pop rbp
    ret
    
    .seh_endproc
```

### Linux/Unix Exception Handling (DWARF)

Unix-like systems use DWARF debugging information format for exception handling. GCC and Clang generate `.eh_frame` sections describing how to unwind each function.

**CFI (Call Frame Information) directives:**

```nasm
; GAS (GNU Assembler) syntax
.cfi_startproc              ; Begin function

push %rbp
.cfi_def_cfa_offset 16      ; CFA is now rsp + 16
.cfi_offset rbp, -16        ; rbp saved at CFA - 16

mov %rsp, %rbp
.cfi_def_cfa_register rbp   ; CFA now relative to rbp

sub $32, %rsp               ; Allocate stack space

; ... function body ...

leave                       ; Restore stack
.cfi_def_cfa rsp, 8        ; CFA back to rsp + 8

ret
.cfi_endproc               ; End function
```

**CFI directive meanings:**

- `.cfi_startproc`: Mark function start
- `.cfi_endproc`: Mark function end
- `.cfi_def_cfa_offset`: Define CFA (Canonical Frame Address) offset from stack pointer
- `.cfi_def_cfa_register`: Change CFA base register
- `.cfi_offset`: Record where register was saved
- `.cfi_restore`: Mark register as restored

**CFA (Canonical Frame Address):** The CFA is the value of the stack pointer at the call site. Exception unwinder uses CFA to reconstruct the caller's frame.

**Example with multiple saved registers:**

```nasm
.globl my_function
.type my_function, @function
my_function:
    .cfi_startproc
    
    push %rbp
    .cfi_def_cfa_offset 16
    .cfi_offset rbp, -16
    
    push %rbx
    .cfi_def_cfa_offset 24
    .cfi_offset rbx, -24
    
    push %r12
    .cfi_def_cfa_offset 32
    .cfi_offset r12, -32
    
    mov %rsp, %rbp
    .cfi_def_cfa_register rbp
    
    sub $16, %rsp
    
    ; ... function body ...
    
    add $16, %rsp
    pop %r12
    .cfi_restore r12
    pop %rbx
    .cfi_restore rbx
    pop %rbp
    .cfi_restore rbp
    .cfi_def_cfa rsp, 8
    
    ret
    .cfi_endproc
```

### C++ Exception Handling Integration

When assembly code is called from C++ or calls C++ code, exceptions must be able to propagate through the assembly frames.

**Safe approach - non-throwing assembly:**

```nasm
; This function doesn't throw and doesn't call anything that throws
; Simple unwind info is sufficient
my_asm_func:
    .cfi_startproc
    push %rbp
    .cfi_def_cfa_offset 16
    .cfi_offset rbp, -16
    mov %rsp, %rbp
    .cfi_def_cfa_register rbp
    
    ; ... code that doesn't throw ...
    
    pop %rbp
    .cfi_def_cfa rsp, 8
    ret
    .cfi_endproc
```

**When calling C++ functions that might throw:**

```nasm
; Assembly function calling C++ code
call_cpp_function:
    .cfi_startproc
    
    ; Standard prologue
    push %rbp
    .cfi_def_cfa_offset 16
    .cfi_offset rbp, -16
    mov %rsp, %rbp
    .cfi_def_cfa_register rbp
    
    push %rbx               ; Save callee-saved register
    .cfi_offset rbx, -24
    
    sub $16, %rsp           ; Align stack and allocate space
    
    ; Call C++ function (may throw)
    call cpp_function_that_throws
    
    ; If exception thrown, unwinder will use CFI to restore registers
    ; and propagate exception to caller
    
    add $16, %rsp
    pop %rbx
    .cfi_restore rbx
    pop %rbp
    .cfi_restore rbp
    .cfi_def_cfa rsp, 8
    ret
    
    .cfi_endproc
```

### Cleanup Code and Destructors

**[Inference]** If assembly code allocates resources that need cleanup, it cannot rely on exception handling to run cleanup code automatically. Assembly doesn't have RAII or destructors.

**Workaround 1: C wrapper with RAII:**

```c++
// C++ wrapper
extern "C" void asm_worker(void* data);

void safe_asm_call(void* data) {
    // Setup resources with RAII
    Resource resource;
    
    // Call assembly
    asm_worker(data);
    
    // Resource automatically cleaned up on exception
}
```

**Workaround 2: Manual cleanup in assembly:**

```nasm
; Assembly must catch and handle
function_with_cleanup:
    .cfi_startproc
    push %rbp
    mov %rsp, %rbp
    
    ; Allocate resource
    call allocate_resource
    mov %rbx, %rax          ; Save resource handle
    
    ; Do work - if this throws, resource leaks!
    call risky_cpp_function
    
    ; Clean up
    mov %rdi, %rbx
    call free_resource
    
    pop %rbp
    ret
    .cfi_endproc
```

**Better approach - try/catch in C++, only safe operations in assembly:**

```c++
extern "C" void asm_compute(int* data, size_t len);

void safe_compute(std::vector<int>& vec) {
    try {
        // Assembly does pure computation, no exceptions
        asm_compute(vec.data(), vec.size());
    } catch (...) {
        // Handle any exceptions
        // vec's destructor still runs
        throw;
    }
}
```

### Language-Specific Exception Handlers

**Windows SEH allows language-specific handlers:**

```nasm
; Windows x64 with exception handler (pseudo-code)
MyFunction:
    .seh_proc MyFunction
    .seh_handler __CxxFrameHandler3, @unwind
    
    ; Prologue with unwind info
    ; ...
    
    .seh_endprologue
    
    ; Function body
    ; ...
    
    .seh_endproc
```

The handler (`__CxxFrameHandler3` for C++) is called during unwinding and can run destructors and catch blocks.

**[Unverified]** Implementing custom exception handlers in pure assembly requires deep understanding of the language runtime and is platform-specific. Generally not recommended.

### Practical Guidelines

**For assembly functions called from C++:**

1. Always provide correct unwind information
2. Preserve all callee-saved registers per ABI
3. Maintain stack alignment
4. Avoid resource allocation that needs cleanup
5. Keep assembly frame "exception-transparent"

**For assembly calling C++:**

1. Assume any C++ function might throw
2. Don't hold resources across C++ calls
3. Let exceptions propagate (don't catch unless necessary)
4. Ensure unwind info is correct so unwinder can skip your frame

**Testing exception handling:**

```c++
// Test that exceptions propagate through assembly
extern "C" int asm_function(int (*callback)(int), int arg);

void test_exception_propagation() {
    try {
        int result = asm_function([](int x) -> int {
            if (x < 0) throw std::runtime_error("negative");
            return x * 2;
        }, -5);
        assert(false);  // Should not reach here
    } catch (const std::exception& e) {
        // Should catch exception thrown through assembly frame
        assert(std::string(e.what()) == "negative");
    }
}
```

**Key Points:**

- Windows uses SEH with .seh_* directives for unwind information
- Linux/Unix uses DWARF CFI with .cfi_* directives
- Exception handling requires correct stack frame metadata
- Assembly functions must provide unwind information to be exception-safe
- [Inference] Assembly code should avoid resource management when exceptions are possible
- Let C++ wrapper code handle resources with RAII
- Test that exceptions propagate correctly through assembly frames

