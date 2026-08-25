## Architectural Overview


### Register Set

SSE/SSE2 introduced eight 128-bit XMM registers (XMM0-XMM7) in 32-bit mode, expanded to sixteen registers (XMM0-XMM15) in 64-bit mode. Unlike MMX, these registers are independent and do not alias with x87 FPU registers, eliminating state management overhead.

**Register characteristics**:

- **Width**: 128 bits per register
- **Count**: 8 registers (32-bit mode), 16 registers (64-bit mode)
- **Independence**: No aliasing with other register sets
- **State management**: MXCSR control/status register for floating-point behavior

### Data Types

**SSE data types** (single-precision floating-point):

- **Packed single-precision**: Four 32-bit floats
- **Scalar single-precision**: Single 32-bit float in lowest position

**SSE2 data types** (extends SSE):

- **Packed double-precision**: Two 64-bit doubles
- **Scalar double-precision**: Single 64-bit double in lowest position
- **Packed bytes**: Sixteen 8-bit integers
- **Packed words**: Eight 16-bit integers
- **Packed doublewords**: Four 32-bit integers
- **Packed quadwords**: Two 64-bit integers
- **Aligned quadword**: Single 128-bit integer

