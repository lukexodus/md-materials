## MMX Instruction Set


### Data Transfer Instructions

**MOVD** moves 32 bits between MMX registers and general-purpose registers or memory. The upper 32 bits of the destination MMX register are zeroed when loading from a 32-bit source.

**MOVQ** moves 64 bits between MMX registers, or between MMX registers and memory locations. This is the primary instruction for loading and storing complete MMX register contents.

### Arithmetic Instructions

**PADDB/PADDW/PADDD** performs packed addition on byte, word, or doubleword elements respectively. Each element in the source operand is added to the corresponding element in the destination operand independently, with wraparound behavior on overflow.

**PADDSB/PADDSW** and **PADDUSB/PADDUSW** provide saturating addition for signed and unsigned values. Saturating arithmetic clamps results to the maximum or minimum representable value instead of wrapping around.

**PSUBB/PSUBW/PSUBD** performs packed subtraction with wraparound behavior.

**PSUBSB/PSUBSW** and **PSUBUSB/PSUBUSW** provide saturating subtraction for signed and unsigned values.

**PMULHW** multiplies four packed signed 16-bit integers and stores the high 16 bits of each 32-bit result.

**PMULLW** multiplies four packed signed 16-bit integers and stores the low 16 bits of each 32-bit result.

**PMADDWD** multiplies packed signed 16-bit integers from both operands, producing four intermediate 32-bit results. Adjacent pairs are then added together, yielding two 32-bit final results.

### Comparison Instructions

**PCMPEQB/PCMPEQW/PCMPEQD** compares packed elements for equality. Each element comparison that evaluates to true results in all bits of that element position being set to 1, while false comparisons result in all zeros.

**PCMPGTB/PCMPGTW/PCMPGTD** compares packed signed elements for greater-than relationships using the same mask generation behavior.

### Logical Instructions

**PAND** performs bitwise AND operation between 64-bit MMX operands.

**PANDN** performs AND-NOT operation, computing the bitwise AND of the inverted destination with the source.

**POR** performs bitwise OR operation.

**PXOR** performs bitwise XOR operation. A common idiom is `PXOR MM0, MM0` to zero a register efficiently.

### Shift and Rotate Instructions

**PSLLW/PSLLD/PSLLQ** performs packed logical left shift on word, doubleword, or quadword elements. The shift count can be specified by an immediate value or an MMX register.

**PSRLW/PSRLD/PSRLQ** performs packed logical right shift, filling vacated bits with zeros.

**PSRAW/PSRAD** performs packed arithmetic right shift on signed values, preserving the sign bit by filling vacated positions with copies of the sign bit.

### Pack and Unpack Instructions

**PACKSSWB** converts four signed 16-bit words into eight signed 8-bit bytes with saturation. Values exceeding the 8-bit signed range are clamped to -128 or 127.

**PACKSSDW** converts two signed 32-bit doublewords into four signed 16-bit words with saturation.

**PACKUSWB** converts signed 16-bit words to unsigned 8-bit bytes with saturation, clamping negative values to zero and values above 255 to 255.

**PUNPCKLBW/PUNPCKLWD/PUNPCKLDQ** unpacks and interleaves the low-order elements from source and destination operands.

**PUNPCKHBW/PUNPCKHWD/PUNPCKHDQ** unpacks and interleaves the high-order elements.

