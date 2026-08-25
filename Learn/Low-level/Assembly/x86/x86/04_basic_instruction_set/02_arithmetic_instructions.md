## Arithmetic Instructions


Arithmetic instructions perform mathematical operations and update the FLAGS register to reflect results.

### ADD Instruction

ADD performs addition of two operands, storing the result in the destination.

```nasm
add rax, rbx                ; RAX = RAX + RBX
add rax, 42                 ; RAX = RAX + 42
add [rax], rbx              ; Memory[RAX] = Memory[RAX] + RBX
add rbx, [rax]              ; RBX = RBX + Memory[RAX]
```

**Flags affected**: CF (Carry Flag), PF (Parity Flag), AF (Auxiliary Carry Flag), ZF (Zero Flag), SF (Sign Flag), OF (Overflow Flag)

The Carry Flag (CF) indicates unsigned overflow when the result exceeds the destination size. The Overflow Flag (OF) indicates signed overflow when the result cannot be represented in the destination's signed range. The Zero Flag (ZF) is set when the result is zero. The Sign Flag (SF) reflects the most significant bit of the result.

### ADC (Add with Carry)

ADC adds two operands plus the current Carry Flag value, enabling multi-precision arithmetic.

```nasm
add rax, rbx                ; Add lower 64 bits
adc rcx, rdx                ; Add upper 64 bits with carry from previous operation
```

This pattern allows addition of integers larger than the register width by chaining operations.

### SUB Instruction

SUB performs subtraction, subtracting the source from the destination.

```nasm
sub rax, rbx                ; RAX = RAX - RBX
sub rax, 10                 ; RAX = RAX - 10
sub [rax], rbx              ; Memory[RAX] = Memory[RAX] - RBX
```

**Flags affected**: CF, PF, AF, ZF, SF, OF

The Carry Flag after SUB indicates a borrow occurred (when the source is larger than the destination in unsigned arithmetic). This differs from ADD where CF indicates a carry out.

### SBB (Subtract with Borrow)

SBB subtracts the source and the Carry Flag from the destination, enabling multi-precision subtraction.

```nasm
sub rax, rbx                ; Subtract lower 64 bits
sbb rcx, rdx                ; Subtract upper 64 bits with borrow
```

### INC Instruction

INC increments the destination by one, providing a more compact encoding than ADD with immediate value 1.

```nasm
inc rax                     ; RAX = RAX + 1
inc byte [rbx]              ; Increment byte at memory address in RBX
inc dword [rbx + rcx * 4]   ; Increment dword in array
```

**Flags affected**: PF, AF, ZF, SF, OF (but NOT CF)

The preservation of the Carry Flag distinguishes INC from ADD, which can be significant in loop constructs or multi-precision arithmetic.

### DEC Instruction

DEC decrements the destination by one.

```nasm
dec rax                     ; RAX = RAX - 1
dec byte [rbx]              ; Decrement byte at memory address
```

**Flags affected**: PF, AF, ZF, SF, OF (but NOT CF)

Like INC, DEC preserves the Carry Flag.

### NEG Instruction

NEG computes the two's complement negation of the operand, effectively calculating 0 - operand.

```nasm
neg rax                     ; RAX = -RAX (two's complement)
neg dword [rbx]             ; Negate dword at memory address
```

**Flags affected**: CF, PF, AF, ZF, SF, OF

The Carry Flag is set if the source operand is non-zero (since negation is implemented as subtraction from zero). Negating the most negative representable signed value (e.g., 0x8000000000000000 for 64-bit) produces the same value and sets the Overflow Flag.

### CMP Instruction

CMP performs subtraction without storing the result, only updating flags for comparison purposes.

```nasm
cmp rax, rbx                ; Compare RAX with RBX
cmp rax, 100                ; Compare RAX with 100
cmp byte [rax], 0           ; Compare byte at address with 0
```

**Flags affected**: CF, PF, AF, ZF, SF, OF

Conditional jumps and conditional moves use these flags:

- ZF = 1: operands are equal
- CF = 1: first operand is below second (unsigned comparison)
- SF ≠ OF: first operand is less than second (signed comparison)

### MUL and IMUL (Multiply)

**MUL** performs unsigned multiplication. It has an implicit destination in RAX (and RDX for overflow):

```nasm
mul rbx                     ; RDX:RAX = RAX * RBX (unsigned)
mul ecx                     ; EDX:EAX = EAX * ECX (unsigned)
```

For 64-bit multiplication, the 128-bit result is split between RDX (upper 64 bits) and RAX (lower 64 bits).

**IMUL** performs signed multiplication with multiple forms:

```nasm
imul rbx                    ; RDX:RAX = RAX * RBX (signed, two-operand form)
imul rax, rbx               ; RAX = RAX * RBX (result truncated to 64 bits)
imul rax, rbx, 10           ; RAX = RBX * 10 (three-operand form with immediate)
```

The two-operand and three-operand forms of IMUL are commonly used because they don't require specific registers.

### DIV and IDIV (Divide)

**DIV** performs unsigned division:

```nasm
div rbx                     ; RAX = RDX:RAX / RBX (quotient)
                           ; RDX = RDX:RAX % RBX (remainder)
```

The dividend is in RDX:RAX (for 64-bit division), and results place the quotient in RAX and remainder in RDX. Division by zero or quotient overflow triggers a Division Exception (#DE).

**IDIV** performs signed division with the same register usage:

```nasm
idiv rbx                    ; RAX = RDX:RAX / RBX (signed quotient)
                           ; RDX = RDX:RAX % RBX (signed remainder)
```

Before division, the dividend must be properly extended into RDX:RAX. For unsigned division, clear RDX. For signed division, use CWD/CDQ/CQO to sign-extend:

```nasm
; Unsigned 64-bit division
xor rdx, rdx                ; Clear upper 64 bits
div rbx

; Signed 64-bit division
cqo                         ; Sign-extend RAX into RDX:RAX
idiv rbx
```

