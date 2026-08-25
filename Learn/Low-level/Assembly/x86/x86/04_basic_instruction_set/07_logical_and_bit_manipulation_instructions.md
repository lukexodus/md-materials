## Logical and Bit Manipulation Instructions


Logical instructions perform Boolean operations on operands, treating them as bit vectors. Bit manipulation instructions provide fine-grained control over individual bits and bit fields.

### Logical Operations

AND performs bitwise AND: `AND RAX, RBX` computes RAX = RAX & RBX, clearing any bit in RAX where the corresponding bit in RBX is 0. AND always clears CF and OF, sets ZF if result is zero, SF to the result's sign bit, and PF to the low byte's parity. AF becomes undefined.

AND is frequently used for masking and testing bits. `AND EAX, 0xFF` isolates the low 8 bits of EAX, clearing the upper 24 bits. Testing a register against itself with AND: `AND EAX, EAX` sets flags based on EAX's value without modifying EAX (though technically it's redundant).

OR performs bitwise OR: `OR RAX, RBX` computes RAX = RAX | RBX, setting any bit in RAX where the corresponding bit in RBX is 1. OR clears CF and OF, and sets SF, ZF, and PF based on the result.

OR is used for setting bits and combining bit flags. `OR EAX, 0x80` sets bit 7 of EAX. OR with zero is sometimes used to test a register and set flags: `OR EAX, EAX` sets ZF if EAX is zero, SF if EAX is negative.

XOR performs bitwise exclusive OR: `XOR RAX, RBX` computes RAX = RAX ^ RBX, setting each bit where the operands differ and clearing where they match. XOR clears CF and OF, sets SF, ZF, and PF based on the result.

XOR is commonly used to clear registers: `XOR EAX, EAX` sets EAX to zero. This is preferred over `MOV EAX, 0` because it's encoded in fewer bytes and modern processors recognize it as a zero-idiom. XOR is also used for toggling bits: `XOR EAX, 0x01` toggles bit 0 of EAX.

NOT performs bitwise complement: `NOT RAX` computes RAX = ~RAX, inverting every bit. NOT does not affect any flags, which is unusual among logical operations.

### Shift Instructions

Shift instructions move bits left or right within an operand, discarding bits shifted out and filling vacated positions with zeros or sign bits.

SHL (Shift Left) shifts bits left, filling the right side with zeros. `SHL RAX, 1` shifts RAX left by 1 bit, effectively multiplying by 2. `SHL EAX, CL` shifts EAX left by the number of bits specified in CL. The last bit shifted out goes into CF. SHL sets CF to the last bit shifted out, OF to indicate sign change (for 1-bit shifts), ZF if result is zero, SF to the sign bit, and PF to low byte parity.

SHL and SAL (Shift Arithmetic Left) are identical operations with the same encoding. Shifting left by N positions multiplies by 2^N (truncating overflow).

SHR (Shift Right) shifts bits right, filling the left side with zeros. `SHR RAX, 1` divides unsigned RAX by 2 (rounding down). The last bit shifted out goes into CF. SHR performs unsigned division by powers of two.

SAR (Shift Arithmetic Right) shifts bits right, filling the left side with copies of the sign bit. This performs signed division by powers of two, rounding toward negative infinity. `SAR EAX, 2` divides signed EAX by 4. SAR preserves the sign of signed integers.

Shift counts greater than the operand size produce [Inference] undefined results on older processors, though modern processors mask the count (to 5 bits for 32-bit operands, 6 bits for 64-bit operands). Shifting by CL allows variable shifts but is typically slower than immediate shifts.

Double-precision shifts SHLD and SHRD shift bits between two operands. `SHLD RAX, RBX, 4` shifts RAX left 4 bits, filling the right side with the upper 4 bits of RBX. RBX remains unchanged. `SHRD RAX, RBX, 4` shifts RAX right 4 bits, filling the left side with the lower 4 bits of RBX. These are useful for multi-precision shifts and for extracting bit fields spanning register boundaries.

### Rotate Instructions

Rotate instructions shift bits circularly, with bits shifted out one end reappearing at the other end.

ROL (Rotate Left) rotates bits left: `ROL RAX, 1` shifts all bits left, with bit 63 moving to bit 0 and also copied to CF. `ROL EAX, CL` rotates by CL bits. OF is set if the rotation caused the sign bit to change (for 1-bit rotates).

ROR (Rotate Right) rotates bits right: `ROR EAX, 8` shifts all bits right by 8, with bits 0-7 moving to bits 24-31.

RCL (Rotate Through Carry Left) rotates bits left through the carry flag: the carry flag becomes bit 0, and the bit shifted out becomes the new carry. `RCL RAX, 1` shifts CF into bit 0, shifts all bits left, and shifts bit 63 into CF. The carry flag acts as an additional bit in the rotation.

RCR (Rotate Through Carry Right) rotates right through carry: CF shifts into the high bit, and the low bit shifts into CF.

Rotates are useful for bit manipulation, cryptography, and certain algorithms requiring circular shifts. Extracting bits from arbitrary positions can use rotate to position them conveniently.

### Bit Scanning and Testing

BSF (Bit Scan Forward) scans for the first set bit (from low to high): `BSF RAX, RBX` searches RBX for the first 1 bit and stores its position (0-63) in RAX. If RBX is zero, ZF is set and RAX is undefined. Otherwise, ZF is cleared.

BSR (Bit Scan Reverse) scans for the first set bit from high to low: `BSR RAX, RBX` finds the highest set bit in RBX. BSR can compute the position of the most significant bit, useful for logarithmic calculations.

BT (Bit Test) tests a single bit: `BT RAX, 5` copies bit 5 of RAX to CF. The operand remains unchanged. `BT [RSI], RCX` tests bit RCX of the memory location, allowing bit indices beyond the operand size to access subsequent memory locations.

BTC (Bit Test and Complement) tests a bit and toggles it: `BTC RAX, 5` copies bit 5 to CF, then inverts bit 5.

BTR (Bit Test and Reset) tests a bit and clears it: `BTR RAX, 5` copies bit 5 to CF, then clears bit 5 to 0.

BTS (Bit Test and Set) tests a bit and sets it: `BTS RAX, 5` copies bit 5 to CF, then sets bit 5 to 1.

BT, BTC, BTR, and BTS with memory operands are atomic when combined with the LOCK prefix, making them useful for synchronization and lock-free algorithms.

LZCNT (Leading Zero Count) counts the number of leading zero bits: `LZCNT RAX, RBX` counts zeros from bit 63 downward until finding the first 1 bit. If RBX is zero, RAX is set to the operand size (64). This is a BMI (Bit Manipulation Instruction) extension.

TZCNT (Trailing Zero Count) counts trailing zero bits: `TZCNT RAX, RBX` counts zeros from bit 0 upward. If RBX is zero, RAX is set to the operand size.

POPCNT (Population Count) counts the number of set bits: `POPCNT RAX, RBX` counts all 1 bits in RBX. Useful for Hamming weight calculations, bitmap operations, and certain algorithms.

BEXTR, BLSI, BLSMSK, BLSR, and other BMI/BMI2 instructions provide additional bit manipulation capabilities. These instructions are not universally available and require CPUID feature detection.

