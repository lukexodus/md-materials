## Stack Alignment Requirements


Proper stack alignment is critical for correctness and performance. Misaligned stacks can cause crashes (particularly with SIMD instructions) or performance degradation.

### x86-64 ABI Alignment Requirements

The x86-64 System V ABI (used on Linux, macOS, BSD) and Windows x64 calling convention specify:

**16-byte alignment requirement**: RSP must be aligned to a 16-byte boundary before executing a CALL instruction.

More precisely: RSP must be 16-byte aligned **plus 8 bytes** immediately after CALL (because CALL pushes an 8-byte return address).

This means that at function entry (after CALL pushes return address), RSP % 16 = 8.

### Why Alignment Matters

**SIMD Instructions**: SSE/AVX instructions operating on aligned data can be significantly faster [Inference based on typical SIMD performance characteristics]. Some SIMD instructions require aligned memory:

```nasm
; Aligned load/store (requires 16-byte alignment)
movaps xmm0, [rsp]          ; Crash if RSP not 16-byte aligned

; Unaligned load/store (slower but works with any alignment)
movups xmm0, [rsp]          ; Works regardless of alignment
```

**ABI Compliance**: Functions may assume proper alignment and use aligned instructions without checking. Calling with misaligned stack leads to undefined behavior.

**Performance**: Even without explicit SIMD, aligned access patterns can improve cache line utilization and reduce memory access penalties [Inference about cache behavior].

### Ensuring Proper Alignment

**At Function Entry**:

After CALL pushes the 8-byte return address, RSP is (16n + 8) aligned. The function prologue must maintain or adjust alignment:

```nasm
; Function entry: RSP = 16n + 8 (due to return address)
function:
    push rbp                ; RSP = 16n + 0 (16-byte aligned)
    mov rbp, rsp
    sub rsp, 32             ; RSP = 16n - 32 = 16m (still aligned)
    
    ; Now RSP is 16-byte aligned, suitable for aligned operations
```

If the function needs to CALL another function, it must ensure RSP returns to (16n + 8) alignment:

```nasm
function:
    push rbp                ; RSP = 16n (after CALL's return address push)
    mov rbp, rsp
    sub rsp, 32             ; RSP = 16n - 32
    
    ; Before calling another function, adjust if necessary
    ; Currently RSP is 16-byte aligned, need (16n + 8)
    sub rsp, 8              ; RSP = 16n - 40 = 16m + 8
    call other_function     ; Stack properly aligned for callee
    add rsp, 8              ; Restore
```

**Alignment Patterns**:

```nasm
; Method 1: Calculate alignment explicitly
function:
    push rbp
    mov rbp, rsp
    and rsp, -16            ; Force RSP to 16-byte boundary
    ; ... function body ...
    mov rsp, rbp            ; Restore original stack position
    pop rbp
    ret

; Method 2: Allocate aligned space
function:
    push rbp
    mov rbp, rsp
    sub rsp, 48             ; 32 for locals + 16 for alignment adjustment
    ; Ensure final RSP is 16-byte aligned
    ; ... function body ...
    leave
    ret
```

### Stack Alignment in Calling Conventions

**System V AMD64 ABI** (Linux, macOS):

- RSP must be 16-byte aligned before CALL
- At function entry (after CALL), RSP % 16 = 8
- Functions must preserve alignment

**Windows x64 Calling Convention**:

- RSP must be 16-byte aligned before CALL
- At function entry (after CALL), RSP % 16 = 8
- Caller must allocate 32-byte "shadow space" for register parameters

```nasm
; Windows x64 calling example
caller:
    sub rsp, 32             ; Shadow space for parameters
    ; Parameters passed in RCX, RDX, R8, R9
    mov rcx, arg1
    mov rdx, arg2
    call function
    add rsp, 32             ; Clean up shadow space
```

### Variable-Length Arrays and Dynamic Allocation

When allocating variable-sized data on the stack, maintaining alignment requires calculation:

```c
// C code
void function(int n) {
    char buffer[n];  // Variable-length array
    // ...
}
```

```nasm
; Assembly with alignment
function:
    push rbp
    mov rbp, rsp
    
    ; Allocate n bytes, rounded up to 16-byte alignment
    mov rax, rdi            ; n in RDI (first parameter)
    add rax, 15             ; Add 15 for rounding
    and rax, -16            ; Round down to multiple of 16
    sub rsp, rax            ; Allocate aligned space
    
    ; buffer at [rsp]
    
    ; Function body
    
    leave                   ; Restore stack
    ret
```

### Detecting Alignment Issues

Common symptoms of alignment problems:

- Segmentation faults when executing SIMD instructions
- Crashes in system libraries or called functions
- Intermittent failures depending on call stack depth

Debugging alignment:

```nasm
; Check alignment at runtime (debugging)
mov rax, rsp
test rax, 0xF               ; Test if lower 4 bits are zero
jnz alignment_error         ; Jump if not 16-byte aligned

alignment_error:
    ; Log error or trigger breakpoint
    int 3                   ; Debugger breakpoint
```

### Compiler-Generated Alignment

Modern compilers automatically handle stack alignment:

```c
// C code - compiler handles alignment
void function() {
    __m128 vec;             // 16-byte aligned SSE variable
    char buffer[100];       // May be padded for next variable
    __m256 vec2;            // 32-byte aligned AVX variable
}
```

The compiler inserts appropriate padding and alignment directives:

```nasm
; Compiler-generated assembly
function:
    push rbp
    mov rbp, rsp
    and rsp, -32            ; Align to 32 bytes for AVX
    sub rsp, 160            ; Allocate space with padding
    ; vec at [rsp + 144] (16-byte aligned)
    ; buffer at [rsp + 32]
    ; vec2 at [rsp + 0] (32-byte aligned)
```

