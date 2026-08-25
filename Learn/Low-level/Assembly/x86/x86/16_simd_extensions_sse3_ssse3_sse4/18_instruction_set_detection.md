## Instruction Set Detection


Proper feature detection ensures code runs only on supporting processors.

**CPUID Feature Flags:**

Execute CPUID with EAX=1:

- ECX bit 0: SSE3 support
- ECX bit 9: SSSE3 support
- ECX bit 19: SSE4.1 support
- ECX bit 20: SSE4.2 support
- ECX bit 23: POPCNT support (often associated with SSE4.2)

**Example Detection Code:**

```asm
section .text
    ; Check for SSE3
    mov eax, 1
    cpuid
    test ecx, 0x1                    ; Test bit 0
    jz no_sse3
    
    ; Check for SSSE3
    test ecx, 0x200                  ; Test bit 9
    jz no_ssse3
    
    ; Check for SSE4.1
    test ecx, 0x80000                ; Test bit 19
    jz no_sse41
    
    ; Check for SSE4.2
    test ecx, 0x100000               ; Test bit 20
    jz no_sse42
    
    ; All features present
    ; ... use SSE4.2 code path ...
```

**Key Points:**

- Blending operations eliminate branches in conditional element selection
- Dot product instructions significantly reduce instruction count for vector mathematics
- Improved shuffle operations provide fine-grained data reorganization
- String instructions accelerate text processing with hardware support
- Horizontal operations enable within-register reductions and transformations
- Feature detection is mandatory to ensure compatibility across processors

---

