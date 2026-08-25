## Feature Detection


[Inference] Applications should use the CPUID instruction to detect SSE3, SSSE3, SSE4.1, and SSE4.2 support before using these instructions to ensure compatibility across processor generations.

SSE3: CPUID.01H:ECX.SSE3[bit 0] SSSE3: CPUID.01H:ECX.SSSE3[bit 9]  
SSE4.1: CPUID.01H:ECX.SSE4_1[bit 19] SSE4.2: CPUID.01H:ECX.SSE4_2[bit 20] POPCNT: CPUID.01H:ECX.POPCNT[bit 23]

**Example**: Runtime feature detection

```nasm
mov eax, 1
cpuid
test ecx, (1 << 20)         ; Test SSE4.2 bit
jz no_sse42_support
; Use SSE4.2 instructions
```

