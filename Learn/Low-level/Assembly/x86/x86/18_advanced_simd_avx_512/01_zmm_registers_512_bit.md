## ZMM Registers (512-bit)


### Register Architecture

AVX-512 extends vector registers to 512 bits, designated ZMM0-ZMM31. In 64-bit mode, the architecture provides 32 ZMM registers, doubling the register count from AVX/AVX2's 16 YMM registers. In 32-bit mode, only ZMM0-ZMM7 are accessible.

The register hierarchy maintains backward compatibility through aliasing:

```
ZMM register: 512 bits [511:0]
  ↓ Lower 256 bits alias YMM register
YMM register: 256 bits [255:0]
  ↓ Lower 128 bits alias XMM register
XMM register: 128 bits [127:0]
```

Operations on XMM registers zero the upper bits of the corresponding YMM/ZMM register. Operations on YMM registers zero bits [511:256] of the corresponding ZMM register. This zero-extension behavior maintains clean state transitions between different vector widths.

### EVEX Encoding

AVX-512 uses EVEX (Enhanced VEX) encoding, extending the VEX prefix format to accommodate:

- 32 register addressing (5-bit register fields)
- Embedded mask register specification (3 bits)
- Embedded broadcast control
- Rounding mode control for floating-point operations
- Suppress all exceptions (SAE) flag

EVEX prefixes are 4 bytes long, larger than VEX prefixes but providing extensive encoding flexibility. The EVEX format enables efficient representation of AVX-512's rich feature set within the existing x86 instruction encoding framework.

### Vector Length Agnostic Programming

AVX-512VL (Vector Length extensions) allows most AVX-512 instructions to operate on 128-bit (XMM) or 256-bit (YMM) registers in addition to 512-bit (ZMM) registers. This enables uniform programming across vector lengths and allows applications to utilize AVX-512 features like masking and embedded broadcast even when full 512-bit width is not required.

```nasm
; Same instruction, different vector lengths
vaddps xmm0 {k1}, xmm1, xmm2    ; 128-bit, 4 elements
vaddps ymm0 {k1}, ymm1, ymm2    ; 256-bit, 8 elements
vaddps zmm0 {k1}, zmm1, zmm2    ; 512-bit, 16 elements
```

[Inference] Vector length agnostic programming improves code portability and allows runtime selection of optimal vector width based on workload characteristics and processor capabilities.

