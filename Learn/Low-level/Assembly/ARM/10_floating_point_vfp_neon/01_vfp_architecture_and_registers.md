## VFP Architecture and Registers


The Vector Floating Point (VFP) architecture provides hardware support for IEEE 754 floating-point arithmetic on ARM processors. NEON is ARM's SIMD (Single Instruction Multiple Data) extension that extends VFP capabilities.

**VFP versions:**

- VFPv1: Initial implementation (rare)
- VFPv2: ARMv5TE and ARMv6
- VFPv3: ARMv7-A, added 32 double-precision registers
- VFPv4: ARMv7-A, added fused multiply-add
- VFPv5: ARMv8-A integration with NEON

**Register organization (VFPv3/VFPv4):**

**Single-precision registers (S registers):**

- S0-S31: 32 single-precision (32-bit) registers
- Each holds one single-precision floating-point value

**Double-precision registers (D registers):**

- D0-D31: 32 double-precision (64-bit) registers in VFPv3-D32
- D0-D15: 16 double-precision registers in VFPv3-D16
- Each holds one double-precision floating-point value

**Quad-word registers (Q registers - NEON):**

- Q0-Q15: 16 quad-word (128-bit) registers
- Used for SIMD operations

**Register aliasing:** The S and D registers share the same physical register file:

- D0 overlaps with S0 (low 32 bits) and S1 (high 32 bits)
- D1 overlaps with S2 and S3
- D16-D31 have no S register aliases (VFPv3-D32 only)
- Q0 overlaps with D0 and D1 (or S0-S3)

```
Q0:  [    D0    |    D1    ]
     [S0 |S1    |S2 |S3    ]

Q1:  [    D2    |    D3    ]
     [S4 |S5    |S6 |S7    ]
```

**FPSCR (Floating-Point Status and Control Register):** Controls floating-point behavior and stores status flags:

- Rounding modes: Round to nearest, toward +∞, toward -∞, toward zero
- Exception flags: Invalid operation, Division by zero, Overflow, Underflow, Inexact
- Flush-to-zero mode: Denormalized numbers treated as zero
- Default NaN mode: All NaN operations produce default NaN

**Enabling VFP/NEON:**

```asm
; Enable VFP/NEON coprocessor access (typically done by OS)
MRC p15, 0, r0, c1, c0, 2   ; Read CP Access Control Register
ORR r0, r0, #0xF00000       ; Enable CP10 and CP11 (VFP/NEON)
MCR p15, 0, r0, c1, c0, 2   ; Write CP Access Control Register
ISB

; Enable VFP
MOV r0, #0x40000000
VMSR FPEXC, r0              ; Set EN bit in FPEXC
```

**Register naming conventions:**

- ARMv7 (32-bit): S, D, Q registers
- ARMv8 AArch64: V registers (V0-V31) replace S/D/Q, accessed with type suffixes

