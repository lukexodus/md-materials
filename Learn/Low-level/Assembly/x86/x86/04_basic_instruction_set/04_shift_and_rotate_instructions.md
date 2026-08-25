## Shift and Rotate Instructions


Shift and rotate instructions manipulate individual bits within operands, moving them left or right.

### SHL (Shift Left) and SAL (Shift Arithmetic Left)

SHL and SAL are identical operations that shift bits left, filling vacated positions with zeros. The most significant bit shifts into the Carry Flag.

```nasm
shl rax, 1                  ; Shift RAX left by 1 bit
shl rax, cl                 ; Shift RAX left by count in CL
shl dword [rbx], 4          ; Shift dword at memory left by 4 bits
```

**Flags affected**: CF (receives the last bit shifted out), OF (set if sign bit changed, only for 1-bit shifts), PF, ZF, SF

Each left shift by one position multiplies the value by 2 (for values that don't overflow).

The shift count can be:

- Immediate value (0-255, though only low 5 or 6 bits are used depending on operand size)
- CL register (lower 8 bits of RCX)

### SHR (Shift Right Logical)

SHR shifts bits right, filling vacated positions with zeros. The least significant bit shifts into the Carry Flag.

```nasm
shr rax, 1                  ; Shift RAX right by 1 bit (unsigned)
shr rax, cl                 ; Shift RAX right by count in CL
shr word [rbx], 3           ; Shift word at memory right by 3 bits
```

**Flags affected**: CF (receives the last bit shifted out), OF (set to MSB of original value for 1-bit shifts), PF, ZF, SF

Each right shift by one position divides an unsigned value by 2 (rounding toward zero).

### SAR (Shift Arithmetic Right)

SAR shifts bits right while preserving the sign bit (most significant bit), implementing signed division by powers of 2.

```nasm
sar rax, 1                  ; Shift RAX right by 1 bit (signed)
sar rax, cl                 ; Shift RAX right by count in CL
sar dword [rbx], 2          ; Arithmetic shift dword right by 2
```

**Flags affected**: CF (receives the last bit shifted out), OF (cleared for 1-bit shifts), PF, ZF, SF

The sign bit replicates into vacated positions, maintaining the sign of the value. For negative numbers, this implements division by powers of 2 with rounding toward negative infinity [Unverified: exact rounding behavior depends on specific value].

### ROL (Rotate Left)

ROL rotates bits left, with bits shifted out of the MSB position wrapping to the LSB position. The last bit rotated out also goes to the Carry Flag.

```nasm
rol rax, 1                  ; Rotate RAX left by 1 bit
rol rax, cl                 ; Rotate RAX left by count in CL
rol byte [rbx], 3           ; Rotate byte left by 3 bits
```

**Flags affected**: CF (receives the last bit rotated out), OF (set if sign bit changed, only for 1-bit rotations)

### ROR (Rotate Right)

ROR rotates bits right, with bits shifted out of the LSB position wrapping to the MSB position.

```nasm
ror rax, 1                  ; Rotate RAX right by 1 bit
ror rax, cl                 ; Rotate RAX right by count in CL
ror dword [rbx], 5          ; Rotate dword right by 5 bits
```

**Flags affected**: CF (receives the last bit rotated out), OF (set if sign bit changed, only for 1-bit rotations)

### RCL (Rotate Through Carry Left)

RCL rotates bits left through the Carry Flag, treating the operand and CF as a circular chain.

```nasm
rcl rax, 1                  ; Rotate RAX and CF left by 1 bit
rcl rax, cl                 ; Rotate RAX and CF left by count in CL
```

**Flags affected**: CF (participates in rotation), OF (set if sign bit changed, only for 1-bit rotations)

For a 64-bit operand, RCL treats the value as a 65-bit quantity (64 bits + CF). This is useful for multi-precision bit shifts.

### RCR (Rotate Through Carry Right)

RCR rotates bits right through the Carry Flag.

```nasm
rcr rax, 1                  ; Rotate RAX and CF right by 1 bit
rcr rax, cl                 ; Rotate RAX and CF right by count in CL
```

**Flags affected**: CF (participates in rotation), OF (set if sign bit changed, only for 1-bit rotations)

### Variable Shift Counts

When using CL as the shift count, only the relevant bits are used:

- 8-bit and 16-bit operands: 5 bits of CL (count masked to 0-31)
- 32-bit operands: 5 bits of CL (count masked to 0-31)
- 64-bit operands: 6 bits of CL (count masked to 0-63)

```nasm
mov cl, 70
shl rax, cl                 ; Actually shifts by 70 & 0x3F = 6 bits
shl eax, cl                 ; Actually shifts by 70 & 0x1F = 6 bits
```

### Double Precision Shifts

**SHLD (Shift Left Double)** and **SHRD (Shift Right Double)** shift between two operands:

```nasm
shld rax, rbx, 4            ; Shift RAX left 4 bits, filling from RBX high bits
shrd rax, rbx, 4            ; Shift RAX right 4 bits, filling from RBX low bits
shld rax, rbx, cl           ; Variable count from CL
```

These instructions enable efficient multi-word shifts and bit field extraction across register boundaries.

### Bit Manipulation Instructions (BMI)

Modern x86 processors include extended bit manipulation instructions:

**BSWAP**: Reverses byte order (endian conversion)

```nasm
bswap rax                   ; Reverse byte order in RAX
```

**BSF** (Bit Scan Forward): Finds the first set bit (LSB to MSB)

```nasm
bsf rax, rbx                ; RAX = index of first set bit in RBX
```

**BSR** (Bit Scan Reverse): Finds the last set bit (MSB to LSB)

```nasm
bsr rax, rbx                ; RAX = index of last set bit in RBX
```

**BT** (Bit Test): Tests if a specific bit is set

```nasm
bt rax, 5                   ; Test bit 5 of RAX, result in CF
```

**BTC** (Bit Test and Complement): Tests and toggles a bit **BTR** (Bit Test and Reset): Tests and clears a bit **BTS** (Bit Test and Set): Tests and sets a bit

```nasm
btc rax, 5                  ; Test bit 5, then flip it
btr rax, 5                  ; Test bit 5, then clear it
bts rax, 5                  ; Test bit 5, then set it
```

**Key Points**

MOV instructions transfer data between operands without affecting flags, with special variants for sign-extension (MOVSX) and zero-extension (MOVZX), and support complex addressing modes including base+index\*scale+displacement. Arithmetic instructions (ADD, SUB, INC, DEC, NEG) perform calculations and update multiple flags including CF, OF, ZF, SF, PF, which are essential for subsequent conditional operations. Logical instructions (AND, OR, XOR, NOT, TEST) manipulate individual bits and clear CF and OF flags, with XOR commonly used for efficient register zeroing. Shift instructions move bits left (SHL/SAL) or right (SHR/SAR) with different fill behaviors for logical versus arithmetic operations, while rotate instructions (ROL/ROR/RCL/RCR) preserve all bits by wrapping them around. The CL register provides variable shift counts, with actual count masked based on operand size (5 bits for 32-bit, 6 bits for 64-bit operands). Most instructions support multiple operand sizes (byte, word, dword, qword) through register and memory size specifications. The FLAGS register serves as a critical communication mechanism between instructions, enabling comparison, conditional execution, and multi-precision arithmetic.

**Important related topics**: Conditional jump instructions and branch prediction, stack operations (PUSH, POP, CALL, RET), bit manipulation extensions (BMI1, BMI2), SIMD arithmetic and logical operations, instruction encoding and optimization, multi-precision arithmetic patterns, LEA instruction for address calculation and arithmetic shortcuts

---

