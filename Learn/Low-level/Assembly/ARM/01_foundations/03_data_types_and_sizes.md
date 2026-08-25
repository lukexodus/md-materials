## Data Types and Sizes


ARM assembly operates on data at various granularities, each with specific size and alignment requirements.

### Fundamental Data Sizes

**Byte**: 8 bits, representing values 0-255 (unsigned) or -128 to +127 (signed). ARM uses 'B' suffix in instructions (LDRB, STRB).

**Halfword**: 16 bits (2 bytes), representing values 0-65535 (unsigned) or -32768 to +32767 (signed). ARM uses 'H' suffix in instructions (LDRH, STRH).

**Word**: 32 bits (4 bytes) in ARMv7, representing values 0 to 2^32-1 (unsigned) or -2^31 to 2^31-1 (signed). Default size for most ARM 32-bit operations (LDR, STR).

**Doubleword**: 64 bits (8 bytes), used in ARMv8 64-bit mode and for double-precision floating-point. ARM uses 'D' suffix or 64-bit registers.

### ARMv7 (32-bit) Data Types

In 32-bit ARM architecture, registers are 32 bits wide. Operations default to word size unless specified otherwise with instruction suffixes.

Integer types:

- `char`: typically 8 bits
- `short`: typically 16 bits
- `int`: typically 32 bits
- `long`: typically 32 bits (platform-dependent)
- `long long`: typically 64 bits

Pointer size: 32 bits (can address 4GB of memory)

### ARMv8 (64-bit) Data Types

In 64-bit ARM architecture (AArch64), registers can operate as 32-bit (W registers) or 64-bit (X registers).

Integer types:

- `char`: typically 8 bits
- `short`: typically 16 bits
- `int`: typically 32 bits
- `long`: typically 64 bits (platform-dependent)
- `long long`: typically 64 bits

Pointer size: 64 bits (theoretical 16 exabyte address space, though practical implementations use fewer bits)

### Floating-Point Types

ARM processors with floating-point units support IEEE 754 formats:

**Single-precision (float)**: 32 bits, provides approximately 7 decimal digits of precision. Range approximately ±10^±38. Uses S registers in ARM.

**Double-precision (double)**: 64 bits, provides approximately 16 decimal digits of precision. Range approximately ±10^±308. Uses D registers in ARM.

The VFP (Vector Floating Point) and NEON extensions provide dedicated registers and instructions for floating-point operations.

### SIMD Data Types

ARM NEON extension supports **Single Instruction Multiple Data (SIMD)** operations, processing multiple data elements simultaneously. NEON registers (64-bit or 128-bit) can be interpreted as vectors of smaller elements.

A 128-bit NEON register can hold:

- 16 × 8-bit integers
- 8 × 16-bit integers
- 4 × 32-bit integers or floats
- 2 × 64-bit integers or doubles

This allows parallel processing of multiple values with a single instruction, beneficial for multimedia and signal processing applications.

### Alignment Requirements

ARM processors impose alignment requirements for optimal performance and, in some modes, correctness.

**Natural alignment**: Data should be aligned to addresses that are multiples of their size:

- Bytes: any address (1-byte aligned)
- Halfwords: even addresses (2-byte aligned)
- Words: addresses divisible by 4 (4-byte aligned)
- Doublewords: addresses divisible by 8 (8-byte aligned)

[Unverified] Unaligned access may cause performance penalties or, in some ARM configurations, trigger alignment faults that crash the program. ARMv7 and later generally support unaligned access in specific modes, but aligned access is always faster.

### Structure and Array Layout

Composite data types have specific memory layouts. Structures place members sequentially in memory, potentially with padding bytes to maintain alignment requirements.

**Example** structure:

```c
struct Example {
    char a;      // 1 byte at offset 0
    // 3 bytes padding
    int b;       // 4 bytes at offset 4
    short c;     // 2 bytes at offset 8
    // 2 bytes padding
};  // total size: 12 bytes
```

Arrays store elements contiguously without padding between elements. A word array at address 0x1000 has elements at 0x1000, 0x1004, 0x1008, etc.

### Type Conversions

Converting between data types requires careful handling to preserve or appropriately modify values.

**Narrowing conversion** (larger to smaller) truncates high-order bits:

- 32-bit 0x12345678 → 8-bit 0x78

**Widening conversion** (smaller to larger) requires either zero extension for unsigned or sign extension for signed values:

- Unsigned: 8-bit 0xFF → 32-bit 0x000000FF
- Signed: 8-bit 0xFF (-1) → 32-bit 0xFFFFFFFF (-1)

