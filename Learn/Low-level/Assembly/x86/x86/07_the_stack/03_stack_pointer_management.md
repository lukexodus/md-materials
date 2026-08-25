## Stack Pointer Management


Proper stack pointer management is critical for program stability. Incorrect RSP manipulation causes crashes, data corruption, and security vulnerabilities. Understanding stack pointer behavior enables correct implementation of functions, exception handlers, and low-level system code.

### Manual Stack Pointer Adjustment

Direct manipulation of RSP allows efficient allocation and deallocation of stack space without using PUSH/POP for each item.

**Allocating stack space**:

```asm
SUB RSP, 64        ; Allocate 64 bytes of stack space
```

This reserves 64 bytes on the stack for local variables or temporary data. The allocated space can be accessed using [RSP + offset]:

```asm
SUB RSP, 64
MOV QWORD [RSP], RAX       ; Store RAX at RSP+0
MOV QWORD [RSP+8], RBX     ; Store RBX at RSP+8
MOV QWORD [RSP+16], RCX    ; Store RCX at RSP+16
; ... use local storage ...
ADD RSP, 64                ; Deallocate
```

**Stack allocation requirements**:

- Allocation size should maintain stack alignment (multiples of 16 bytes in 64-bit)
- Allocation must not exceed available stack space (guard against stack overflow)
- Every SUB RSP must have a matching ADD RSP before function return
- Allocated space should account for red zone considerations (System V AMD64 ABI)

**Red zone**: The System V AMD64 ABI defines a 128-byte "red zone" below RSP that functions can use without explicitly adjusting RSP. Asynchronous events (signal handlers, interrupts) must preserve this area. Leaf functions (functions that don't call other functions) can use the red zone for temporary storage without allocating stack frames:

```asm
; Leaf function using red zone
MOV [RSP-8], RAX           ; Store in red zone
MOV [RSP-16], RBX
; ... computation ...
MOV RAX, [RSP-8]           ; Restore
MOV RBX, [RSP-16]
RET                        ; No stack adjustment needed
```

The red zone optimization eliminates the overhead of stack frame setup/teardown in leaf functions. However, signal handlers and interrupt handlers must respect the red zone, and Windows x64 calling convention does not provide a red zone.

### Stack Pointer Alignment

Maintaining proper stack alignment is mandatory for correct operation under modern calling conventions.

**Checking current alignment**:

```asm
MOV RAX, RSP
AND RAX, 15        ; RAX = RSP % 16
; If RAX = 0, RSP is 16-byte aligned
; If RAX = 8, RSP is 8-byte aligned but not 16-byte aligned
```

**Ensuring alignment before allocation**:

```asm
; Allocate 37 bytes, maintaining 16-byte alignment
; Round up to next multiple of 16: 48 bytes
SUB RSP, 48        ; Allocate 48 bytes (aligned)
; Use first 37 bytes, last 11 bytes are padding
```

**Dynamic alignment** (rarely needed):

```asm
PUSH RBP           ; Save frame pointer
MOV RBP, RSP       ; Establish frame
AND RSP, -16       ; Align RSP to 16-byte boundary
                   ; (clear low 4 bits)
SUB RSP, 64        ; Allocate space
; ... function body ...
MOV RSP, RBP       ; Restore original RSP
POP RBP
RET
```

This technique aligns RSP but requires RBP to restore the original stack pointer, as the aligned RSP value lost information about the previous RSP.

### Stack Probing

Large stack allocations require stack probing to ensure all pages between the current stack pointer and the newly allocated space are committed. Operating systems typically allocate stack memory with guard pages - uncommitted pages that trigger page faults when accessed.

Simply subtracting a large value from RSP can skip over guard pages, causing a segmentation fault or access violation when the space is actually used:

```asm
; INCORRECT - may skip guard pages
SUB RSP, 100000    ; Allocate 100KB
MOV [RSP], RAX     ; May crash if page not committed
```

Stack probing touches pages sequentially, ensuring each page is committed before moving past it:

```asm
; Correct stack probing for large allocation
MOV RAX, 100000    ; Allocation size
probe_loop:
    SUB RSP, 4096  ; One page at a time
    MOV [RSP], 0   ; Touch the page
    SUB RAX, 4096
    JA probe_loop
```

Compilers automatically generate stack probing code for large allocations. Windows provides the __chkstk runtime function that performs stack probing. System V systems typically rely on compiler-generated inline probing sequences.

[Inference] Stack probing overhead is minimal for typical allocations (< 4KB) but becomes noticeable for very large allocations. Functions requiring large stack frames may experience measurable performance impact from probing.

### Stack Overflow Detection and Prevention

Stack overflow occurs when the stack grows beyond its allocated region, typically due to:

- Excessive recursion depth
- Large local variable allocations
- Unbounded alloca() usage
- Stack pointer corruption

**Guard pages**: Operating systems place guard pages at the stack limit. Accessing a guard page triggers a page fault, which the OS can convert to a stack overflow exception or signal (SIGSEGV on Linux, STATUS_STACK_OVERFLOW on Windows).

**Manual overflow checking**:

```asm
; Check if allocation would overflow
MOV RAX, RSP
SUB RAX, 4096      ; Proposed new RSP
CMP RAX, [stack_limit]  ; Compare with known limit
JB stack_overflow_handler
SUB RSP, 4096      ; Safe to allocate
```

This requires knowing the stack limit, which may be available through thread-local storage or OS APIs.

**Stack canaries**: Compilers can insert stack canaries (random values) on the stack during function prologue and verify them before return. Stack buffer overflows overwrite the canary, triggering an abort:

```asm
; Prologue with stack canary
MOV RAX, [FS:0x28]      ; Load canary value
PUSH RBP
MOV RBP, RSP
SUB RSP, 64
MOV [RBP-8], RAX        ; Store canary on stack
; ... function body ...
; Epilogue
MOV RAX, [RBP-8]        ; Load canary
XOR RAX, [FS:0x28]      ; Compare with original
JNE canary_mismatch     ; Abort if mismatched
MOV RSP, RBP
POP RBP
RET
```

Stack canaries protect against buffer overflow attacks but add performance overhead and don't prevent all overflow scenarios.

### Stack Unwinding

Stack unwinding is the process of traversing stack frames, typically for:

- Exception handling (C++ exceptions, SEH on Windows)
- Debugging (backtrace, stack trace)
- Profiling and performance analysis
- Garbage collection in some language runtimes

Stack unwinding requires information about each function's stack frame structure. This information can come from:

- Frame pointers (RBP-based frames)
- Unwind tables (DWARF .eh_frame on Linux, exception tables on Windows)
- Statically compiled metadata

**Frame pointer-based unwinding**:

```asm
; Current frame: RBP points to saved RBP, RBP+8 is return address
MOV RBX, [RBP]     ; RBX = previous frame's RBP
; Return address is at [RBP+8]
MOV RBP, RBX       ; Move to previous frame
; Repeat to traverse entire stack
```

This simple chain traversal works when frame pointers are consistently used but breaks when optimizations omit frame pointers.

**Unwind table-based unwinding**: Modern systems use unwind tables that describe how to restore registers and find return addresses without requiring frame pointers. These tables map instruction addresses to unwinding rules, allowing debuggers and exception handlers to traverse optimized code.

