## XMM Registers


SSE introduces eight 128-bit registers (XMM0-XMM7) in 32-bit mode, extended to sixteen registers (XMM0-XMM15) in 64-bit mode. These registers are distinct from the general-purpose and FPU registers, providing dedicated storage for SIMD operations.

**Register Organization:** Each 128-bit XMM register can be interpreted in multiple ways depending on the operation:

- Four single-precision floating-point values (32 bits each)
- Two double-precision floating-point values (64 bits each)
- Sixteen 8-bit integers
- Eight 16-bit integers
- Four 32-bit integers
- Two 64-bit integers

**Register Naming Convention:** The registers are referenced as XMM0, XMM1, XMM2, through XMM7 (or XMM15 in 64-bit). Unlike general-purpose registers, XMM registers do not have size variants (no partial register access like AL, AX, EAX, RAX).

**Register Preservation:** In most calling conventions, XMM registers have specific preservation requirements. XMM6-XMM15 are typically callee-saved in Windows x64, while XMM0-XMM5 are used for parameter passing. In System V AMD64 ABI (Linux/Unix), XMM0-XMM15 are caller-saved.

