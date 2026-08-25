## Logical Instructions


Logical instructions perform bitwise operations on operands.

### AND Instruction

AND performs bitwise logical AND operation.

```nasm
and rax, rbx                ; RAX = RAX & RBX
and rax, 0x0F               ; RAX = RAX & 0x0F (mask lower 4 bits)
and byte [rax], 0xFE        ; Clear least significant bit of byte
```

**Flags affected**: CF (cleared), OF (cleared), PF, ZF, SF, AF (undefined)

AND is commonly used for:

- Masking specific bits
- Testing if specific bits are set (similar to TEST instruction)
- Clearing specific bits
- Aligning addresses (e.g., `and rsp, -16` aligns to 16-byte boundary)

### OR Instruction

OR performs bitwise logical OR operation.

```nasm
or rax, rbx                 ; RAX = RAX | RBX
or rax, 0x01                ; Set least significant bit
or rax, rax                 ; Test if RAX is zero (common idiom)
```

**Flags affected**: CF (cleared), OF (cleared), PF, ZF, SF, AF (undefined)

OR is commonly used for:

- Setting specific bits
- Combining bit flags
- Testing if a register is zero (using `or reg, reg`)
- Merging values

### XOR Instruction

XOR performs bitwise logical exclusive OR operation.

```nasm
xor rax, rbx                ; RAX = RAX ^ RBX
xor rax, rax                ; Clear RAX (RAX = 0, efficient zeroing idiom)
xor al, 0xFF                ; Flip all bits in AL
```

**Flags affected**: CF (cleared), OF (cleared), PF, ZF, SF, AF (undefined)

XOR is commonly used for:

- Zeroing registers (`xor reg, reg` is smaller and often faster than `mov reg, 0`)
- Toggling bits
- Implementing simple encryption/obfuscation
- Swap without temporary variable (though not recommended for performance [Inference])

The XOR swap pattern:

```nasm
xor rax, rbx
xor rbx, rax
xor rax, rbx                ; RAX and RBX values are swapped
```

### NOT Instruction

NOT performs bitwise logical NOT operation (one's complement).

```nasm
not rax                     ; RAX = ~RAX
not byte [rbx]              ; Flip all bits in byte at address
```

**Flags affected**: None

NOT operates on a single operand and inverts all bits. This differs from NEG, which computes the two's complement (arithmetic negation).

### TEST Instruction

TEST performs bitwise AND without storing the result, only updating flags.

```nasm
test rax, rbx               ; Compute RAX & RBX, set flags only
test rax, rax               ; Test if RAX is zero
test al, 0x01               ; Test if least significant bit is set
```

**Flags affected**: CF (cleared), OF (cleared), PF, ZF, SF, AF (undefined)

TEST is primarily used before conditional jumps:

```nasm
test rax, rax
jz zero_label               ; Jump if RAX is zero
jnz nonzero_label           ; Jump if RAX is non-zero
```

