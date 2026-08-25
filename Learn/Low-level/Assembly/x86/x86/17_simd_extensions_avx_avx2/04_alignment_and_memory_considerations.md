## Alignment and Memory Considerations


### Alignment Requirements

**Aligned operations** (VMOVAPS, VMOVAPD, VMOVDQA):

- Require 32-byte alignment for 256-bit operations
- Cause #GP (general protection fault) if violated
- Provide optimal performance

**Unaligned operations** (VMOVUPS, VMOVUPD, VMOVDQU):

- Accept any alignment
- [Inference] Performance penalty for misaligned accesses varies by microarchitecture (modern processors have reduced penalties)
- Safer for unknown alignment scenarios

**Example** of alignment checking:

```nasm
; Check if pointer is 32-byte aligned
mov rax, buffer_ptr
test rax, 0x1F                    ; Check low 5 bits
jnz use_unaligned

aligned_path:
    vmovaps ymm0, [rax]
    jmp continue

use_unaligned:
    vmovups ymm0, [rax]

continue:
    ; Rest of code...
```

**Declaring aligned data**:

```nasm
section .data
align 32
float_array: times 8 dd 1.0       ; 32-byte aligned array

section .bss
align 32
output_buffer: resb 1024          ; 32-byte aligned buffer
```

### Cache Line Optimization

AVX operations benefit from cache-line-aware access patterns. Modern x86 processors typically use 64-byte cache lines.

**Example** of cache-friendly processing:

```nasm
; Process array in 64-byte chunks (2 × 32-byte AVX operations)
process_array:
    mov rsi, input_ptr
    mov rdi, output_ptr
    mov rcx, element_count
    shr rcx, 4                    ; Process 16 floats per iteration

loop_start:
    vmovaps ymm0, [rsi]           ; Load first 8 floats
    vmovaps ymm1, [rsi + 32]      ; Load next 8 floats (same cache line)
    
    ; Process both registers
    vaddps ymm0, ymm0, ymm2
    vaddps ymm1, ymm1, ymm2
    
    vmovaps [rdi], ymm0
    vmovaps [rdi + 32], ymm1
    
    add rsi, 64
    add rdi, 64
    dec rcx
    jnz loop_start
```

