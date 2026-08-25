## 16-bit Instruction Encoding


Thumb's 16-bit encoding scheme packs essential instruction information into a compact format. The encoding uses various bit field arrangements depending on the instruction type:

**Format 1 - Move shifted register:**

```
15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
|  Op  |   Offset5    |  Rs  |  Rd  |
```

**Format 2 - Add/subtract:**

```
15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
| 0  0  0  1  1|I|Op| Rn/imm3|Rs|Rd|
```

**Format 3 - Move/compare/add/subtract immediate:**

```
15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
| 0  0  1 | Op |  Rd  |   Offset8    |
```

The encoding constraints impose several limitations:

**Register Access:** Most instructions can only access R0-R7. Special instructions like ADD, CMP, and MOV can access high registers R8-R15, but with reduced functionality.

**Immediate Values:** Limited to small constants. Add/subtract operations support 3-bit immediates (0-7), while move/compare operations support 8-bit immediates (0-255).

**Conditional Execution:** Unlike ARM instructions where almost every instruction can be conditionally executed, only branch instructions support conditions in Thumb. This requires additional branch instructions for conditional code sequences.

**Shift Operations:** Cannot combine shifts with data processing in a single instruction. Shifts must be performed as separate instructions.

**Load/Store Offsets:** Restricted offset ranges. Word loads use 5-bit offsets (0-124 in steps of 4), halfword loads use 5-bit offsets (0-62 in steps of 2), and byte loads use 5-bit offsets (0-31).

**Example** of encoding density comparison:

ARM code (32-bit instructions):

```assembly
ADD  R0, R1, R2      ; 32 bits
SUB  R3, R4, #100    ; 32 bits
LDR  R5, [R6, #16]   ; 32 bits
```

Thumb code (16-bit instructions):

```assembly
ADD  R0, R1, R2      ; 16 bits
MOV  R0, #100        ; 16 bits (immediate split)
SUB  R3, R4, R0      ; 16 bits
LDR  R5, [R6, #16]   ; 16 bits
```

