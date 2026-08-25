## CPUID Detection


Detect AVX/AVX2 support using CPUID instruction:

**Example** of feature detection:

```nasm
; Detect AVX support
mov eax, 1
cpuid
test ecx, (1 << 28)               ; Check AVX bit (bit 28)
jz no_avx

; Detect AVX2 support
mov eax, 7
xor ecx, ecx
cpuid
test ebx, (1 << 5)                ; Check AVX2 bit (bit 5)
jz no_avx2

; AVX2 is supported
mov dword [avx2_available], 1
jmp continue

no_avx2:
    mov dword [avx2_available], 0
    jmp continue

no_avx:
    mov dword [avx_available], 0

continue:
    ; Proceed with appropriate code path
```

