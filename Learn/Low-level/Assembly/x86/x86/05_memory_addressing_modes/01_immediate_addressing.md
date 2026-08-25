## Immediate Addressing


Immediate addressing embeds constant values directly within the instruction encoding. The operand is part of the instruction itself rather than stored in a register or memory location. When the CPU fetches the instruction, it obtains both the operation code and the operand value in a single memory access.

**Syntax and Usage** in x86 assembly shows the immediate value following the instruction mnemonic:

```nasm
mov rax, 42          ; Load decimal 42 into RAX
mov rbx, 0x2A        ; Load hexadecimal 2A (42) into RBX
add rcx, 100         ; Add 100 to RCX
sub rdx, 0x10        ; Subtract 16 from RDX
cmp rsi, 0           ; Compare RSI with zero
```

The immediate value appears as a literal number in the assembly source. Assemblers encode this value as part of the machine code instruction. Different instruction formats accommodate immediate values of various sizes, typically 8-bit, 16-bit, 32-bit, or in some cases 64-bit operands.

**Size Limitations** constrain immediate values based on instruction encoding. Most x86-64 instructions support 32-bit immediate values that are sign-extended to 64 bits when operating on 64-bit registers. Moving a 64-bit immediate directly requires the `movabs` instruction:

```nasm
mov rax, 0x123456789ABCDEF0     ; Not valid - exceeds 32-bit immediate
movabs rax, 0x123456789ABCDEF0  ; Valid - uses 64-bit immediate encoding
```

Sign extension treats the most significant bit of the immediate as a sign bit, extending it to fill the larger operand size. A 32-bit immediate value 0xFFFFFFFF becomes 0xFFFFFFFFFFFFFFFF when sign-extended to 64 bits, representing -1 in two's complement. This mechanism allows negative constants to work correctly across different operand sizes.

**Performance Characteristics** make immediate addressing efficient. The CPU fetches the operand along with the instruction, requiring no additional memory accesses beyond instruction fetch. No register or memory operand needs loading before the operation executes. Immediate values don't consume registers, leaving them available for other values. The operation completes in a single cycle for simple arithmetic and logical instructions, though complex operations may take longer regardless of addressing mode.

**Common Use Cases** include initializing registers to known values at program start or function entry, loading loop counters with iteration counts, setting up constant parameters for calculations, loading bit masks for bitwise operations, and comparing values against constant thresholds. Immediate addressing appears frequently in assembly programs due to its simplicity and efficiency.

**Encoding Details** vary by instruction format. x86 uses variable-length instruction encoding where immediate values follow the opcode and addressing mode bytes. An 8-bit immediate adds one byte to instruction length, 16-bit adds two bytes, 32-bit adds four bytes, and 64-bit immediates (for movabs) add eight bytes. Smaller immediate values produce more compact code, improving instruction cache utilization.

