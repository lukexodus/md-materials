## Debugging and Common Pitfalls


**Horizontal Operation Confusion:** Horizontal operations combine elements within operands differently than packed operations. Carefully verify which elements are being combined - diagrams of data flow are helpful.

**PSHUFB Masking:** The high bit of each shuffle control byte zeros the result. This is useful but can cause unexpected zeros if control values aren't properly managed. Values must be in range 0-15 for valid selections.

**PALIGNR Byte Offset:** The immediate value specifies bytes, not elements. Shifting by 4 bytes moves one dword, not four bytes. Misunderstanding this leads to incorrect alignment.

**INSERTPS Zero Mask:** INSERTPS can zero elements based on bits 3-0 of the control byte. Forgetting about this feature may result in unintended zeros in the destination register.

**Dot Product Control Byte:** DPPS/DPPD control bytes have separate fields for source mask and destination mask. Setting only one field leads to incorrect results. The destination mask determines where results are written, not which computation occurs.

**String Comparison Length:** PCMPESTR* instructions require explicit lengths in EAX and EDX. Forgetting to set these or using incorrect values causes wrong comparison results. PCMPISTR* instructions scan for null terminators - ensure strings are properly terminated.

**CRC32 Initialization:** CRC32 instructions accumulate into a register, requiring proper initialization (typically 0 or 0xFFFFFFFF depending on the protocol). Incorrect initialization produces wrong checksums.

**Blending Sign Bit:** BLENDVPS and BLENDVPD use the sign bit of the mask register, not all bits. A mask value of 0x00000001 (positive) selects from the first operand, while 0x80000000 (negative) selects from the second. This differs from comparison result masks which use all ones (0xFFFFFFFF).

**Rounding Mode Encoding:** ROUNDPS/ROUNDPD immediate values use bits 1-0 for rounding mode. Values outside 0-3 are reserved. Bit 2 controls exception suppression, which is usually desired for performance.

**Sign Extension Source Size:** PMOVSX*/PMOVZX* instructions read only the necessary bytes from memory. PMOVSXBW reads 64 bits (8 bytes), not 128 bits. Using the wrong memory size leads to reading incorrect data or alignment faults.

**PHMINPOSUW Output Format:** The result contains both the minimum value (bits 15:0) and its index (bits 18:16). The index occupies only 3 bits, and the rest of the register is zeroed. Extracting the index requires proper bit manipulation.

**SSE4 Feature Detection:** Not all processors supporting SSE4.1 support SSE4.2, and vice versa. Always use CPUID to detect specific instruction set support before using these instructions. Attempting to execute unsupported instructions causes invalid opcode exceptions.

