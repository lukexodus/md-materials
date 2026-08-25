## Handling NaN and Infinity


SSE/SSE2 floating-point operations follow IEEE 754 semantics for special values.

**NaN propagation**: Most operations propagate NaN values. If any input is NaN, the result is NaN.

**Infinity handling**: Operations with infinity follow IEEE 754 rules (e.g., infinity + finite = infinity).

**Comparison with NaN**: Unordered comparisons detect NaN presence. UCOMISS/UCOMISD set PF=1 when either operand is NaN.

**Example** of NaN detection:

```nasm
; Check if XMM0 contains any NaN values
; NaN != NaN (only value not equal to itself)

movaps xmm1, xmm0
cmpneqps xmm1, xmm0       ; Each element: 0xFF if NaN, 0x00 if not NaN

movmskps eax, xmm1        ; Extract mask to integer register
test eax, eax             ; Check if any bits set
jnz has_nan               ; Branch if NaN detected
```

