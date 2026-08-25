## Register Architecture


### ZMM Registers

AVX-512 introduces 32 512-bit vector registers named ZMM0-ZMM31 in 64-bit mode. In 32-bit mode, only ZMM0-ZMM7 are accessible. These registers overlay and extend the existing XMM and YMM registers:

- **ZMM0-ZMM15:** Overlay YMM0-YMM15 (lower 256 bits) and XMM0-XMM15 (lower 128 bits)
- **ZMM16-ZMM31:** New registers available only in 64-bit mode

Register structure:

```
ZMM (512 bits): [511:256] [255:128] [127:0]
                   New      YMM        XMM
```

Each ZMM register can hold:

- 64 bytes (8-bit integers)
- 32 words (16-bit integers)
- 16 doublewords (32-bit integers or single-precision floats)
- 8 quadwords (64-bit integers or double-precision floats)

### Mask Registers (K-registers)

AVX-512 introduces eight dedicated 64-bit mask registers named K0-K7, fundamentally changing how predication works in x86 SIMD.

**Characteristics:**

- K0 has special semantics: when used as a write mask, it means "no masking" (all elements are written)
- K1-K7 are general-purpose mask registers
- Each bit in the mask corresponds to one element in the vector (element size-dependent)
- Masks enable merge-masking and zero-masking behaviors

**Mask Operations:**

Masks control which elements participate in operations:

```
For 32-bit elements in ZMM register:
k1 = 0b1010101010101010 (bits 15:0 active)
Results written only to elements where corresponding bit is 1
```

**Mask Register Instructions:**

`KMOVB/KMOVW/KMOVD/KMOVQ k1, k2` - Move between mask registers `KMOVB/KMOVW/KMOVD/KMOVQ k1, r32/r64` - Move from general-purpose register to mask `KMOVB/KMOVW/KMOVD/KMOVQ r32/r64, k1` - Move from mask to general-purpose register

`KANDW/KANDB/KANDD/KANDQ k1, k2, k3` - Bitwise AND `KORW/KORB/KORD/KORQ k1, k2, k3` - Bitwise OR `KXORW/KXORB/KXORD/KXORQ k1, k2, k3` - Bitwise XOR `KNOTW/KNOTB/KNOTD/KNOTQ k1, k2` - Bitwise NOT `KADDW/KADDB/KADDD/KADDQ k1, k2, k3` - Add mask registers

`KTESTW/KTESTB/KTESTD/KTESTQ k1, k2` - Test mask and set flags

`KSHIFTLW/KSHIFTLB/KSHIFTLD/KSHIFTLQ k1, k2, imm8` - Shift left `KSHIFTRW/KSHIFTRB/KSHIFTRD/KSHIFTRQ k1, k2, imm8` - Shift right

### Instruction Encoding

AVX-512 uses EVEX (Enhanced VEX) encoding, a 4-byte prefix that extends instruction capabilities:

- Support for 32 registers (ZMM0-ZMM31)
- Embedded mask register selection
- Embedded broadcast control
- Embedded rounding mode control
- Vector length specification

EVEX prefix structure enables compact encoding of complex operations with multiple modifiers.

