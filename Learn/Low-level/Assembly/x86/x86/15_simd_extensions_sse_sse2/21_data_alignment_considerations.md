## Data Alignment Considerations


SSE/SSE2 instructions have strict alignment requirements for optimal performance and correctness.

**Alignment requirements**:

- **Aligned operations** (MOVAPS, MOVAPD, MOVDQA): Require 16-byte alignment, cause #GP fault if violated
- **Unaligned operations** (MOVUPS, MOVUPD, MOVDQU): Accept any alignment but perform slower on misaligned data
- **Non-temporal stores**: Always require 16-byte alignment

**Example** of checking and handling alignment:

```nasm
; Check if address is 16-byte aligned
mov eax, buffer_address
test eax, 0x0F            ; Check low 4 bits
jnz use_unaligned         ; If non-zero, not aligned

; Aligned path
aligned_path:
    movaps xmm0, [buffer_address]
    jmp continue

; Unaligned path
use_unaligned:
    movups xmm0, [buffer_address]

continue:
    ; ... rest of code ...
```

**Example** of aligning data in memory:

```nasm
section .data
align 16
aligned_buffer: times 16 dd 0.0    ; 16-byte aligned array of 16 floats

section .bss
align 16
output_buffer: resb 256            ; 16-byte aligned 256-byte buffer
```

