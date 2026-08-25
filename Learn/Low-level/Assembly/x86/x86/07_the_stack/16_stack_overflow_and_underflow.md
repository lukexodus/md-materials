## Stack Overflow and Underflow


Stack overflow and underflow represent critical errors that can crash programs or create security vulnerabilities. Understanding these conditions is essential for robust and secure programming.

### Stack Overflow

Stack overflow occurs when the stack grows beyond its allocated region, typically by excessive allocation or unbounded recursion.

**Causes**:

1. **Excessive Local Variables**: Allocating large buffers on the stack

```nasm
function_with_large_local:
    push rbp
    mov rbp, rsp
    sub rsp, 10000000       ; Attempt to allocate 10MB - likely overflow
```

2. **Unbounded Recursion**: Recursive calls without proper termination

```nasm
infinite_recursion:
    push rbp
    mov rbp, rsp
    sub rsp, 16             ; Each call allocates 16 bytes
    call infinite_recursion ; Recurse indefinitely
    leave
    ret
```

3. **Buffer Overrun**: Writing beyond local buffer boundaries

```c
// C code
void vulnerable() {
    char buffer[64];
    gets(buffer);           // Can write past buffer end
}
```

```nasm
; If input exceeds 64 bytes, overwrites:
; - Other local variables
; - Saved RBP
; - Return address
; - Caller's stack frame
```

### Stack Overflow Detection

**Operating System Guard Pages**: Most operating systems place unmapped guard pages at the stack boundary. Accessing these pages triggers a page fault:

```
┌─────────────────────┐
│   Valid stack       │
├─────────────────────┤ ← Stack limit
│   Guard page        │ ← Unmapped, triggers fault on access
│   (typically 4KB)   │
└─────────────────────┘
```

When stack overflow occurs:

1. Stack grows into guard page
2. Page fault exception raised
3. OS delivers SIGSEGV (Linux) or access violation (Windows)
4. Program typically terminates unless handled

**Stack Probing**: Windows requires explicit stack probing for allocations exceeding one page (4KB):

```nasm
; Windows stack probing
large_allocation:
    push rbp
    mov rbp, rsp
    
    ; Allocate 16KB (4 pages)
    mov rax, 16384
    call __chkstk           ; Windows stack probe function
    sub rsp, rax
    
    ; Stack has been properly probed and allocated
```

The `__chkstk` function touches each page to ensure it's allocated before RSP is adjusted.

**Compiler Stack Protection**: Compilers can insert stack canaries to detect buffer overflows:

```nasm
; Compiled with -fstack-protector
function:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    ; Place canary value on stack
    mov rax, [fs:0x28]      ; Load canary from TLS
    mov [rbp - 8], rax      ; Store canary before locals
    xor eax, eax            ; Clear RAX
    
    ; Function body with local variables
    ; [rbp - 64] through [rbp - 16] : local variables
    ; [rbp - 8] : stack canary
    
    ; Before return, check canary
    mov rax, [rbp - 8]
    xor rax, [fs:0x28]      ; Compare with original
    jne stack_chk_fail      ; Jump if modified
    
    leave
    ret

stack_chk_fail:
    call __stack_chk_fail   ; Terminate program
```

If a buffer overflow overwrites the canary, the program terminates before the corrupted return address is used.

### Stack Overflow Exploitation

Stack buffer overflows are a classic security vulnerability. Attackers overwrite the return address to redirect execution:

```nasm
; Vulnerable function
vulnerable:
    push rbp
    mov rbp, rsp
    sub rsp, 64             ; 64-byte buffer
    
    lea rax, [rbp - 64]
    mov rdi, rax
    call gets               ; Dangerous: no bounds checking
    
    leave                   ; If return address overwritten...
    ret                     ; ...jumps to attacker-controlled address
```

Stack layout after overflow:

```
Before overflow:
┌──────────────┐
│   buffer[64] │ [rbp - 64] to [rbp - 1]
├──────────────┤
│   Saved RBP  │ [rbp]
├──────────────┤
│   Return addr│ [rbp + 8]
└──────────────┘

After overflow:
┌──────────────┐
│ Attacker data│ Overwrites buffer
├──────────────┤
│ Attacker data│ Overwrites saved RBP
├──────────────┤
│ Malicious ptr│ Overwrites return address
└──────────────┘
```

**Modern Protections**:

- **Stack Canaries**: Detect buffer overruns before return
- **ASLR**: Randomizes stack addresses, making exploits harder
- **DEP/NX**: Marks stack as non-executable, preventing shellcode execution
- **Control Flow Integrity**: Validates return addresses against expected values [Inference about advanced protection mechanisms]

### Stack Underflow

Stack underflow occurs when more data is popped from the stack than was pushed, causing RSP to move beyond the valid stack region.

**Causes**:

1. **Mismatched PUSH/POP**: Popping more than pushed

```nasm
function:
    push rax
    push rbx
    ; ... code ...
    pop rax
    pop rbx
    pop rcx                 ; ERROR: nothing to pop
    ret
```

2. **Incorrect Stack Cleanup**: Adding too much to RSP

```nasm
function:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    ; ... code ...
    add rsp, 64             ; ERROR: should be 32
    pop rbp
    ret
```

3. **RET Imbalance**: Calling RET without corresponding CALL

```nasm
; Jump to function instead of call
jmp function               ; No return address pushed

function:
    ; ... code ...
    ret                    ; Pops garbage into RIP
```

### Stack Underflow Detection

Stack underflow is harder to detect than overflow:

- May access valid memory outside the stack region
- Can corrupt other data structures
- Often manifests as unpredictable behavior or crashes later

**Red Zone** (System V AMD64 ABI): A 128-byte area below RSP that leaf functions can use without adjusting RSP:

```
┌─────────────────┐
│  Valid stack    │
├─────────────────┤ ← RSP
│   Red zone      │ 128 bytes below RSP
│  (leaf functions│   usable without adjustment
│   can use this) │
└─────────────────┘
```

This is **not a protection mechanism** but an optimization. Stack underflow can corrupt red zone data.

### Recursion Depth and Stack Exhaustion

Deep recursion consumes stack space linearly with depth:

```c
// C code
int factorial(int n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);  // Each call uses stack space
}

// Deep recursion causes overflow
factorial(1000000);  // Likely stack overflow
```

**Tail Call Optimization**: When a function's last operation is calling another function (or itself), the compiler can reuse the current stack frame:

```c
// Tail-recursive factorial
int factorial_tail(int n, int acc) {
    if (n <= 1) return acc;
    return factorial_tail(n - 1, n * acc);  // Tail call
}
```

```nasm
; Without tail call optimization
factorial_tail:
    ; ... check base case ...
    ; ... compute arguments ...
    call factorial_tail     ; New stack frame allocated
    ret

; With tail call optimization
factorial_tail:
    ; ... check base case ...
    ; ... compute arguments ...
    jmp factorial_tail      ; Reuse current stack frame (no new allocation)
```

Tail call optimization prevents stack overflow in recursive algorithms, though not all compilers implement it in all cases [Unverified: compiler behavior varies].

### Stack Size Limits

**Default Stack Sizes** (typical values):

- **Linux**: 8 MB default (configurable via `ulimit -s`)
- **Windows**: 1 MB default (configurable via linker options)
- **macOS**: 8 MB default main thread, 512 KB additional threads

**Checking and Modifying Stack Size**:

Linux shell:

```bash
ulimit -s              # Show stack size in KB
ulimit -s 16384        # Set stack size to 16 MB
ulimit -s unlimited    # Remove stack size limit (not recommended)
```

Compile-time configuration (linker flags):

```bash
# GCC/Clang
gcc -Wl,-z,stack-size=16777216 program.c  # 16 MB stack

# Windows (Visual Studio)
link /STACK:16777216 program.obj          # 16 MB stack
```

Runtime configuration (pthread):

```c
// C code
#include <pthread.h>

pthread_attr_t attr;
pthread_attr_init(&attr);
pthread_attr_setstacksize(&attr, 16 * 1024 * 1024);  // 16 MB
pthread_create(&thread, &attr, function, arg);
```

### Preventing Stack Issues

**Best Practices**:

1. **Avoid Large Stack Allocations**: Use heap allocation for large buffers

```c
// Bad: large stack allocation
void function() {
    char buffer[1000000];  // 1 MB on stack - risky
}

// Good: heap allocation
void function() {
    char *buffer = malloc(1000000);  // Allocated on heap
    // ... use buffer ...
    free(buffer);
}
```

2. **Bounds Checking**: Always validate buffer operations

```c
// Bad: no bounds checking
char buffer[64];
gets(buffer);  // Dangerous

// Good: bounded input
char buffer[64];
fgets(buffer, sizeof(buffer), stdin);  // Limited to buffer size
```

3. **Limit Recursion Depth**: Add explicit depth checks

```c
int recursive_function(int n, int depth) {
    if (depth > MAX_DEPTH) {
        // Handle error: recursion too deep
        return ERROR;
    }
    // ... recursive logic ...
    return recursive_function(n - 1, depth + 1);
}
```

4. **Use Iterative Algorithms**: Convert recursion to iteration when possible

```c
// Recursive (uses stack)
int factorial_recursive(int n) {
    if (n <= 1) return 1;
    return n * factorial_recursive(n - 1);
}

// Iterative (constant stack usage) 
int factorial_iterative(int n) 
{ 
	int result = 1;
	for (int i = 2; i <= n; i++)
	{ 
		result *= i;
	}
	return result; 
}
````

5. **Stack Alignment Verification**: In critical code, verify alignment

```nasm
verify_alignment:
    mov rax, rsp
    test rax, 0xF           ; Check 16-byte alignment
    jz aligned_ok
    ; Handle misalignment error
    mov rdi, misalign_msg
    call abort
aligned_ok:
    ; Continue execution
````

6. **Compiler Warnings and Protections**: Enable stack protection features

```bash
# GCC/Clang compilation flags
gcc -fstack-protector-strong \   # Enable stack canaries
    -Wstack-usage=4096 \          # Warn if function uses >4KB stack
    -D_FORTIFY_SOURCE=2 \         # Enable buffer overflow detection
    program.c
```

### Stack Corruption Detection

**Symptoms of Stack Corruption**:

- Segmentation faults on function return
- Unexpected jumps to invalid addresses
- Local variable values mysteriously changing
- Crashes in unrelated code sections
- Different behavior with optimization levels

**Debugging Techniques**:

```nasm
; Add debug markers to detect corruption
function:
    push rbp
    mov rbp, rsp
    
    ; Store magic value
    mov qword [rbp - 8], 0xDEADBEEFCAFEBABE
    
    sub rsp, 64             ; Allocate locals
    
    ; Function body
    ; ...
    
    ; Check magic value before return
    mov rax, [rbp - 8]
    mov rbx, 0xDEADBEEFCAFEBABE
    cmp rax, rbx
    jne corruption_detected
    
    leave
    ret

corruption_detected:
    ; Log error and abort
    mov rdi, corruption_msg
    call printf
    mov rdi, 1
    call exit
```

Using debuggers to examine stack:

```bash
# GDB commands
(gdb) info frame              # Show current frame information
(gdb) backtrace               # Show call stack
(gdb) x/32gx $rsp             # Examine 32 qwords at RSP
(gdb) info registers rsp rbp  # Show stack pointers
(gdb) set disassemble-next-line on  # Show assembly
```

### Shadow Stack and Hardware Protection

Modern processors include hardware-based stack protection mechanisms:

**Intel Control-flow Enforcement Technology (CET)**:

- **Shadow Stack**: Hardware-maintained second stack storing return addresses
- **Indirect Branch Tracking**: Validates indirect jumps and calls

```nasm
; With CET shadow stack
function:
    push rbp                    ; Pushed to normal stack
    ; Return address automatically pushed to shadow stack
    mov rbp, rsp
    sub rsp, 64
    
    ; Function body
    ; Buffer overflow can corrupt normal stack
    ; but shadow stack remains protected
    
    leave
    ret                         ; Return address verified against shadow stack
    ; If mismatch, #CP exception (Control Protection)
```

The shadow stack prevents return address manipulation, even if the regular stack is corrupted.

**ARM Pointer Authentication** (similar concept on ARM architecture):

- Return addresses are cryptographically signed before storing
- Verified before use
- Corruption detection without separate shadow stack

### Virtual Memory and Stack Growth

Operating systems manage stack growth through virtual memory mechanisms:

**On-Demand Stack Expansion**: When a page fault occurs near the stack boundary, the OS may automatically extend the stack:

```
Initial state:
┌─────────────────┐
│  Allocated      │
│  stack pages    │
├─────────────────┤ ← Stack limit
│  Guard page     │
├─────────────────┤
│  Unmapped       │

After growth:
┌─────────────────┐
│  Allocated      │
│  stack pages    │
├─────────────────┤
│  Newly mapped   │
│  page           │
├─────────────────┤ ← New stack limit
│  Guard page     │ ← Moved down
├─────────────────┤
│  Unmapped       │
```

**Stack Growth Limits**: The OS enforces maximum stack size:

- Hard limit: Absolute maximum (often 8-64 MB)
- Soft limit: Current limit (can be increased up to hard limit)

```c
// C code to query/modify limits
#include <sys/resource.h>

struct rlimit limit;
getrlimit(RLIMIT_STACK, &limit);
printf("Soft limit: %ld\n", limit.rlim_cur);
printf("Hard limit: %ld\n", limit.rlim_max);

// Increase soft limit
limit.rlim_cur = 16 * 1024 * 1024;  // 16 MB
setrlimit(RLIMIT_STACK, &limit);
```

**Split Stacks**: Some language runtimes (e.g., Go, older GCC with `-fsplit-stack`) use segmented stacks:

```
Function A stack
┌─────────────────┐
│  A's locals     │
│  A's frame      │
└─────────────────┘

Function B stack (allocated separately)
┌─────────────────┐
│  B's locals     │
│  B's frame      │
└─────────────────┘
```

When a function runs out of stack space, a new segment is allocated. This prevents overflow but adds complexity and performance overhead [Inference about implementation trade-offs].

