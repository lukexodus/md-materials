## Feature Detection via CPUID


Proper feature detection prevents illegal instruction exceptions on processors lacking specific AVX-512 subsets.

**CPUID Leaf 7, Sub-leaf 0 (EAX=7, ECX=0):**

EBX register:

- Bit 16: AVX-512F (Foundation)
- Bit 17: AVX-512DQ
- Bit 28: AVX-512CD
- Bit 30: AVX-512BW
- Bit 31: AVX-512VL

ECX register:

- Bit 1: AVX-512VBMI
- Bit 6: AVX-512VBMI2
- Bit 11: AVX-512VNNI
- Bit 12: AVX-512BITALG
- Bit 14: AVX-512VPOPCNTDQ

EDX register:

- Bit 2: AVX-512_4VNNIW
- Bit 3: AVX-512_4FMAPS
- Bit 8: AVX-512VP2INTERSECT
- Bit 23: AVX-512FP16

**CPUID Leaf 7, Sub-leaf 1 (EAX=7, ECX=1):**

EAX register:

- Bit 5: AVX-512BF16

**Example Detection Code:**

```asm
section .text
    ; Check AVX-512F support
    mov eax, 7
    xor ecx, ecx
    cpuid
    test ebx, (1 << 16)
    jz no_avx512f
    
    ; Check AVX-512VNNI
    test ecx, (1 << 11)
    jz no_vnni
    
    ; Check AVX-512BF16
    mov eax, 7
    mov ecx, 1
    cpuid
    test eax, (1 << 5)
    jz no_bf16
    
    ; All required features present
    ; ... use AVX-512 code path ...
    
no_avx512f:
    ; Fall back to AVX2 or SSE
no_vnni:
    ; Use alternative implementation
no_bf16:
    ; Use FP32 instead
```

**Key Points:**

- Embedded rounding provides per-instruction rounding control without MXCSR modifications
- Broadcast operations eliminate redundant data replication in memory and instructions
- Permute operations enable arbitrary element rearrangement within and across registers
- Mask registers enable efficient predicated execution
- AVX-512 subsets provide specialized instructions for ML, database, and scientific workloads
- Feature detection is mandatory due to varied subset support across processors
- 32 ZMM registers and 8 K-registers significantly increase available computational resources

---

