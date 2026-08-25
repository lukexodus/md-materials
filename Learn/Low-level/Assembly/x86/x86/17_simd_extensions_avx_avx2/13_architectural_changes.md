## Architectural Changes


### Extended Register Width

AVX extended the XMM registers to 256 bits, renaming them YMM0-YMM15. Each YMM register consists of two 128-bit lanes, with the lower 128 bits aliasing the corresponding XMM register. Operations on XMM registers zero the upper 128 bits of the corresponding YMM register, maintaining clean state transitions.

In 64-bit mode, the architecture provides 16 YMM registers (YMM0-YMM15). The lower 128 bits of YMM0-YMM15 map directly to XMM0-XMM15, preserving backward compatibility with SSE code.

### Three-Operand Instruction Format

AVX introduced VEX (Vector Extensions) encoding, enabling three-operand non-destructive instructions. Unlike SSE's two-operand format where the destination operand is also a source, AVX instructions can specify separate source and destination operands.

```nasm
; SSE two-operand (destructive)
movaps xmm0, [a]
addps xmm0, [b]             ; xmm0 = xmm0 + [b], destroys original

; AVX three-operand (non-destructive)
vmovaps ymm0, [a]
vaddps ymm1, ymm0, [b]      ; ymm1 = ymm0 + [b], preserves ymm0
```

This encoding reduces register pressure by eliminating unnecessary MOV instructions and enables more efficient instruction scheduling. [Inference] The non-destructive format allows compilers and programmers to maintain more live values in registers simultaneously, improving optimization opportunities.

### Lane-Based Architecture

AVX 256-bit operations execute as two independent 128-bit lanes in many cases. Cross-lane operations require explicit instructions, distinguishing AVX from a true 256-bit-wide execution model. This lane structure reflects the hardware implementation where two 128-bit execution units operate in parallel.

```
YMM register organization:
Bits 255-128: High lane
Bits 127-0:   Low lane
```

Most arithmetic operations process each lane independently without data exchange between lanes. Permutation instructions handle cross-lane data movement.

### VEX Prefix Encoding

The VEX prefix replaces traditional x86 instruction prefixes for AVX instructions, encoding operands, vector length (128-bit or 256-bit), and other control information in a compact format. VEX prefixes are 2 or 3 bytes long and eliminate the need for multiple legacy prefixes.

The VEX encoding scheme allows efficient representation of:

- Three-operand instruction format
- Vector length specification (L bit: 0=128-bit, 1=256-bit)
- Implied operand registers
- Mandatory prefix functionality (66H, F2H, F3H)

