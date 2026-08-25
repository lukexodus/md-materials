## Transition Between SSE and AVX


### Legacy SSE Instructions

AVX includes VEX-encoded versions of SSE instructions that operate on XMM registers with three-operand syntax.

**Example** of SSE vs AVX encoding:

```nasm
; SSE version (two-operand)
addps xmm0, xmm1                  ; XMM0 = XMM0 + XMM1

; AVX version (three-operand, operates on XMM)
vaddps xmm0, xmm0, xmm1           ; XMM0 = XMM0 + XMM1 (functionally same)
vaddps xmm0, xmm1, xmm2           ; XMM0 = XMM1 + XMM2 (non-destructive)
```

### Mixing SSE and AVX Code

When mixing SSE and AVX code, proper state management is critical:

**Rules for mixing**:

- AVX instructions zero upper 128 bits of YMM when writing to XMM
- SSE instructions zero upper 128 bits of YMM when writing to XMM
- Use VZEROUPPER before transitioning to non-AVX code
- [Inference] Avoid performance penalties from SSE-AVX transitions

**Example** of proper mixing:

```nasm
avx_function:
    ; AVX code
    vmovaps ymm0, [data]
    vaddps ymm0, ymm0, ymm1
    
    ; Call SSE function
    vzeroupper                    ; Clean state before SSE code
    call sse_function
    
    ; Resume AVX code
    vmovaps ymm0, [data2]
    
    vzeroupper                    ; Clean state before return
    ret

sse_function:
    ; SSE code (no YMM registers used)
    movaps xmm0, [input]
    addps xmm0, xmm1
    ret
```

