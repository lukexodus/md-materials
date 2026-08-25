## Immediate Values and Operands


### Immediate Value Encoding

ARM instructions are fixed-width (32 bits in ARM state, 16 bits in Thumb state), limiting the space available for encoding immediate values within instructions. The instruction format must accommodate the opcode, destination register, source registers, and immediate value.

**ARM32 Encoding Scheme**

In ARM32 state, data processing instructions encode immediates as an 8-bit value and a 4-bit rotation. The immediate is formed by rotating the 8-bit value right by twice the 4-bit rotation value (0-30 in steps of 2). This allows encoding values like 0xFF (rotate 0), 0xFF00 (rotate by 8), 0xFF000000 (rotate by 24), but not arbitrary 32-bit values.

**Assembler Transformation**

When an immediate cannot be encoded directly, the assembler may substitute equivalent instructions. For example, `MOV r0, #-1` might become `MVN r0, #0` (move NOT 0). Addition of negative values may become subtraction: `ADD r0, r1, #-8` becomes `SUB r0, r1, #8`.

**Literal Pools**

For truly arbitrary 32-bit constants, the assembler creates literal pools - areas of read-only data embedded in the code section. The pseudo-instruction `LDR rd, =constant` loads from these pools using PC-relative addressing. The assembler places literal pools at convenient locations, typically after function boundaries or when forced by `.ltorg` directive.

### Operand Types

ARM instructions support different operand combinations depending on the instruction type. Data processing instructions typically accept two source operands and produce one result, while memory instructions use one register operand and one address expression.

**Register Operands**

Register operands refer directly to one of the 16 general-purpose registers (r0-r15). Most instructions can use any register, though some have restrictions: r13 (SP) should only be used for stack operations, r15 (PC) has special behavior when read or written, and certain instructions prohibit specific registers.

**Immediate Operands**

Immediate operands are constant values encoded within the instruction. They must satisfy encoding constraints specific to each instruction type. The assembler reports errors for values that cannot be encoded and may suggest alternatives.

**Shifted Register Operands**

Many ARM data processing instructions accept a shifted register as the second operand. The register value is shifted or rotated before use in the operation. Available shifts include LSL (logical shift left), LSR (logical shift right), ASR (arithmetic shift right), ROR (rotate right), and RRX (rotate right extended through carry).

**Example:**

```assembly
ADD r0, r1, r2           @ r0 = r1 + r2 (register operand)
ADD r0, r1, #100         @ r0 = r1 + 100 (immediate operand)
ADD r0, r1, r2, LSL #2   @ r0 = r1 + (r2 << 2), shifted register
SUB r0, r1, r2, LSR #4   @ r0 = r1 - (r2 >> 4)
MOV r0, r1, ROR #8       @ r0 = r1 rotated right by 8 bits
```

