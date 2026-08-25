## Alignment and Padding


Alignment refers to the memory address requirements for data types. Processors access aligned data more efficiently, and some architectures require proper alignment.

### Natural Alignment

Each data type has a natural alignment equal to its size:

- `byte` (8-bit): 1-byte alignment (any address)
- `word` (16-bit): 2-byte alignment (address divisible by 2)
- `dword` (32-bit): 4-byte alignment (address divisible by 4)
- `qword` (64-bit): 8-byte alignment (address divisible by 8)
- `xmmword` (128-bit): 16-byte alignment (address divisible by 16)
- `ymmword` (256-bit): 32-byte alignment (address divisible by 32)

### Memory Layout Without Alignment

```nasm
section .data
    ; No explicit alignment
    byte_val: db 0x12              ; Address: 0x1000 (example)
    dword_val: dd 0x12345678       ; Address: 0x1001 (misaligned!)
    word_val: dw 0xABCD            ; Address: 0x1005 (misaligned!)
```

**Issues with misalignment:**

- Performance penalty (multiple memory accesses required)
- On some architectures: hardware exceptions or crashes
- SIMD instructions often require strict alignment

### Explicit Alignment Directives

```nasm
section .data
    align 4                        ; Align to 4-byte boundary
    aligned_dword: dd 0x12345678   ; Guaranteed 4-byte aligned
    
    align 16                       ; Align to 16-byte boundary
    aligned_xmm: dq 0, 0          ; Guaranteed 16-byte aligned for SSE
    
    align 32                       ; Align to 32-byte boundary
    aligned_ymm: times 4 dq 0     ; Guaranteed 32-byte aligned for AVX
```

### Structure Padding

When defining structures, compilers insert padding to maintain alignment:

```nasm
; C structure equivalent:
; struct Example {
;     char a;        // 1 byte
;     // 3 bytes padding
;     int b;         // 4 bytes
;     char c;        // 1 byte
;     // 3 bytes padding
;     int d;         // 4 bytes
; }; // Total: 16 bytes

section .bss
    align 4
    example_struct:
    .a:    resb 1                  ; Offset 0
    .pad1: resb 3                  ; Offset 1-3 (padding)
    .b:    resd 1                  ; Offset 4
    .c:    resb 1                  ; Offset 8
    .pad2: resb 3                  ; Offset 9-11 (padding)
    .d:    resd 1                  ; Offset 12
```

### Cache Line Alignment

Modern processors have cache lines (typically 64 bytes). Aligning frequently accessed data to cache line boundaries prevents false sharing in multithreaded code:

```nasm
section .data
    align 64                       ; Cache line alignment
    thread1_counter: dq 0
    times 7 dq 0                   ; Padding to fill cache line
    
    align 64                       ; Separate cache line
    thread2_counter: dq 0
    times 7 dq 0
```

**Without cache line alignment**, thread1_counter and thread2_counter might share the same cache line, causing cache coherency traffic and performance degradation.

### Stack Alignment

x86-64 System V ABI requires 16-byte stack alignment before `call` instructions:

```nasm
section .text
    ; Function prologue maintaining alignment
    push rbp                       ; RSP -= 8
    mov rbp, rsp
    sub rsp, 32                    ; Allocate local space (16-byte aligned)
    
    ; Local variables with proper alignment
    ; [rbp - 8]:  qword variable
    ; [rbp - 16]: qword variable
    ; [rbp - 24]: qword variable
    ; [rbp - 32]: qword variable
```

### Performance Impact Example

```nasm
section .data
    align 16
    aligned_array: times 1000 dd 0
    
section .bss
    ; Intentionally misaligned for comparison
    misaligned_array: resb 1
    .data: resd 1000

section .text
    ; Aligned access (fast)
    mov ecx, 1000
    xor esi, esi
.loop_aligned:
    mov eax, [aligned_array + esi*4]
    add eax, 1
    mov [aligned_array + esi*4], eax
    inc esi
    loop .loop_aligned
    
    ; Misaligned access (slower)
    mov ecx, 1000
    xor esi, esi
.loop_misaligned:
    mov eax, [misaligned_array.data + esi*4]
    add eax, 1
    mov [misaligned_array.data + esi*4], eax
    inc esi
    loop .loop_misaligned
```

**[Inference]** On modern x86-64 processors, the aligned version may execute 2-10% faster depending on the specific microarchitecture and memory access patterns, though the exact performance difference varies by CPU model and is not guaranteed.

### SSE/AVX Alignment Requirements

```nasm
section .data
    align 16
    sse_data: times 4 dd 1.0       ; Must be 16-byte aligned for movdqa
    
section .text
    ; Aligned move (fast, single instruction)
    movdqa xmm0, [sse_data]        ; Requires 16-byte alignment
    
    ; Unaligned move (slower, may use multiple micro-ops)
    movdqu xmm1, [sse_data + 1]    ; Handles misalignment but slower
```

### Pragma Pack Equivalent in Assembly

To create tightly packed structures without padding:

```nasm
; Packed structure (no automatic padding)
section .bss
    packed_struct:
    .a: resb 1                     ; Offset 0
    .b: resd 1                     ; Offset 1 (misaligned!)
    .c: resb 1                     ; Offset 5
    .d: resd 1                     ; Offset 6 (misaligned!)
    ; Total: 10 bytes

section .text
    ; Access requires careful byte-by-byte handling for misaligned fields
    mov al, [packed_struct.a]
    
    ; Access misaligned dword
    mov eax, [packed_struct.b]     ; May cause performance penalty
```

**Key Points:**

- Natural alignment matches data type size for optimal performance
- Padding maintains alignment at the cost of memory space
- Cache line alignment (64 bytes) prevents false sharing in multithreaded applications
- SIMD instructions often mandate strict alignment (16-byte for SSE, 32-byte for AVX)
- Stack must maintain 16-byte alignment on x86-64 for ABI compliance
- Packed structures sacrifice performance for space efficiency

**Important subtopics:**

- SIMD programming with alignment requirements (SSE, AVX, AVX-512)
- Memory barriers and atomic operations with alignment
- Custom memory allocators with alignment guarantees
- Structure of Arrays (SoA) vs Array of Structures (AoS) for cache optimization

---

