## Conditional Execution Patterns


SSE/SSE2 lack direct conditional execution, but comparison masks enable branchless conditional processing.

**Example** of branchless maximum computation:

```nasm
; Compute maximum of two packed float vectors
; Result = max(XMM0, XMM1)

movaps xmm2, xmm0         ; Copy XMM0
cmpltps xmm2, xmm1        ; Mask: 0xFF where XMM0 < XMM1, 0x00 elsewhere

movaps xmm3, xmm2         ; Copy mask
andps xmm2, xmm1          ; Select XMM1 where mask = 0xFF
andnps xmm3, xmm0         ; Select XMM0 where mask = 0x00
orps xmm2, xmm3           ; Combine selections

movaps xmm0, xmm2         ; Result in XMM0
```

**Example** of conditional clamping (clipping values to range):

```nasm
; Clamp float values to range [min_val, max_val]
; XMM0 = input values
; XMM1 = min_val (broadcasted)
; XMM2 = max_val (broadcasted)

maxps xmm0, xmm1          ; XMM0 = max(XMM0, min_val)
minps xmm0, xmm2          ; XMM0 = min(XMM0, max_val)
```

Note: MAXPS/MINPS are SSE arithmetic instructions, not detailed in this section but commonly used with comparison operations.

