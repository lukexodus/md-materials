## Arithmetic Instructions


Arithmetic instructions perform mathematical operations on integer operands. These instructions typically modify multiple flags in RFLAGS to indicate result properties.

### Addition and Subtraction

ADD performs addition: `ADD RAX, RBX` computes RAX = RAX + RBX. The destination operand is overwritten with the sum. ADD sets CF if unsigned overflow occurs, OF if signed overflow occurs, ZF if result is zero, SF to the sign of the result, and PF to the parity of the low byte. AF is set if carry occurred from bit 3 to bit 4.

ADD accepts register-register, register-memory, memory-register, register-immediate, and memory-immediate combinations. Direct memory-to-memory operations are not supported.

ADC (Add with Carry) adds the source operand, destination operand, and the carry flag: `ADC RAX, RBX` computes RAX = RAX + RBX + CF. This enables multi-precision arithmetic spanning multiple registers. Adding two 128-bit values using 64-bit registers: `ADD RAX, RBX` adds the low 64 bits, then `ADC RDX, RCX` adds the high 64 bits plus any carry from the first addition.

SUB performs subtraction: `SUB RAX, 10` computes RAX = RAX - 10. Flags are set similarly to ADD, with CF indicating borrow (set when the unsigned subtraction would go negative).

SBB (Subtract with Borrow) subtracts the source and carry flag from the destination: `SBB RAX, RBX` computes RAX = RAX - RBX - CF. Used for multi-precision subtraction parallel to ADC.

INC and DEC increment or decrement by 1. `INC RAX` computes RAX = RAX + 1. `DEC ECX` computes ECX = ECX - 1. [Inference] These instructions are typically more compact than ADD/SUB with immediate 1, though modern processors may execute them at similar speeds. INC and DEC affect OF, SF, ZF, AF, and PF but do not affect CF, which can be useful when preserving carry across operations.

NEG computes the two's complement (negation) of the operand: `NEG EAX` computes EAX = -EAX (equivalently, EAX = 0 - EAX). NEG sets flags based on the result.

### Multiplication

x86 provides multiple multiplication instructions for signed and unsigned operations with different result sizes.

MUL performs unsigned multiplication. For 8-bit multiplication, `MUL BL` multiplies AL by BL, storing the 16-bit result in AX. For 16-bit, `MUL CX` multiplies AX by CX, storing the 32-bit result in DX:AX (DX holds the upper 16 bits). For 32-bit, `MUL ECX` multiplies EAX by ECX, storing the 64-bit result in EDX:EAX. For 64-bit, `MUL RCX` multiplies RAX by RCX, storing the 128-bit result in RDX:RAX.

MUL sets CF and OF if the upper half of the result is non-zero (indicating the result doesn't fit in the original operand size). SF, ZF, PF, and AF become undefined.

IMUL performs signed multiplication with three forms. Single-operand IMUL works like MUL but interprets operands as signed: `IMUL BX` multiplies AX by BX (signed), storing the result in DX:AX. Two-operand IMUL multiplies and stores the result in the destination register: `IMUL EAX, ECX` computes EAX = EAX * ECX (signed), truncating to 32 bits. Three-operand IMUL multiplies a source operand by an immediate and stores in the destination: `IMUL RAX, RBX, 10` computes RAX = RBX * 10.

Two-operand and three-operand IMUL set CF and OF if the result doesn't fit in the destination size (significant bits were lost). These forms are often faster than single-operand IMUL when only the lower portion of the result is needed.

Multiplication is relatively expensive compared to addition or bit operations. Multiplying by constants that are powers of two should use shift instructions: `SHL RAX, 3` (RAX = RAX * 8) is faster than multiplication. LEA can efficiently multiply by 2, 3, 4, 5, 8, or 9.

### Division

Division instructions provide signed and unsigned division, producing both quotient and remainder.

DIV performs unsigned division. For 8-bit division, `DIV BL` divides AX by BL, storing the quotient in AL and remainder in AH. For 16-bit, `DIV CX` divides DX:AX by CX, storing quotient in AX and remainder in DX. For 32-bit, `DIV ECX` divides EDX:EAX by ECX, storing quotient in EAX and remainder in EDX. For 64-bit, `DIV RCX` divides RDX:RAX by RCX, storing quotient in RAX and remainder in RDX.

Before division, the dividend must be properly set up. For dividing a 32-bit value in EAX, EDX must be cleared (zero-extended): `XOR EDX, EDX` followed by `DIV ECX`. Division by zero or quotient overflow (quotient too large for destination) generates a divide error exception (INT 0).

IDIV performs signed division with the same operand structure as DIV. Before signed division, the dividend must be sign-extended. CBW sign-extends AL to AX, CWD sign-extends AX to DX:AX, CDQ sign-extends EAX to EDX:EAX, and CQO sign-extends RAX to RDX:RAX.

Signed division example: To divide EAX by ECX, use `CDQ` to sign-extend EAX into EDX:EAX, then `IDIV ECX`. The quotient appears in EAX, remainder in EDX.

Division is extremely expensive compared to most instructions, taking many cycles. Dividing by powers of two should use arithmetic shift (SAR for signed, SHR for unsigned). Compilers often replace division by constants with multiplication by reciprocals or other optimizations.

Flags become undefined after division operations. Division does not provide overflow flags; instead, it generates exceptions for error conditions.

