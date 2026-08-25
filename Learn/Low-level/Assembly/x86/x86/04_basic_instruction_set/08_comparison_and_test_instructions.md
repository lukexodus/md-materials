## Comparison and TEST Instructions


Comparison and test instructions evaluate operand relationships and set flags without modifying operands (except for the flags register). These instructions are fundamental to conditional execution and branching.

### CMP Instruction

CMP (Compare) subtracts the source operand from the destination operand and sets flags based on the result, but does not store the result anywhere. The operands remain unchanged. `CMP RAX, RBX` computes RAX - RBX, setting flags as if the subtraction occurred.

CMP sets all arithmetic flags: CF indicates unsigned result would be negative (destination < source unsigned), ZF indicates equality (destination == source), SF indicates signed result would be negative, OF indicates signed overflow, PF indicates parity, and AF indicates auxiliary carry.

The flags set by CMP enable conditional jumps to implement comparisons:
- ZF=1: operands are equal (CMP RAX, RBX followed by JE jumps if RAX == RBX)
- ZF=0: operands are not equal (JNE jumps if RAX != RBX)
- CF=0 and ZF=0: unsigned greater than (JA jumps if RAX > RBX unsigned)
- CF=1: unsigned less than (JB jumps if RAX < RBX unsigned)
- CF=0: unsigned greater or equal (JAE jumps if RAX >= RBX unsigned)
- CF=1 or ZF=1: unsigned less or equal (JBE jumps if RAX <= RBX unsigned)
- SF=OF and ZF=0: signed greater than (JG jumps if RAX > RBX signed)
- SF!=OF: signed less than (JL jumps if RAX < RBX signed)
- SF=OF: signed greater or equal (JGE jumps if RAX >= RBX signed)
- SF!=OF or ZF=1: signed less or equal (JLE jumps if RAX <= RBX signed)

CMP accepts the same operand combinations as SUB: register-register, register-memory, memory-register, register-immediate, memory-immediate. Comparing memory-to-memory requires loading one operand into a register first.

Common patterns include comparing to zero: `CMP RAX, 0` sets ZF if RAX is zero, SF if RAX is negative (as a signed value). However, `TEST RAX, RAX` or `OR RAX, RAX` can achieve similar flag settings with potentially better performance.

CMP combined with conditional jumps implements all comparison operations:

```
CMP RAX, 10
JE equal_label      ; Jump if RAX == 10
JL less_label       ; Jump if RAX < 10 (signed)
JG greater_label    ; Jump if RAX > 10 (signed)
```

Multiple comparisons can be chained by testing different flags after a single CMP, though this requires careful understanding of the flag semantics.

### TEST Instruction

TEST performs bitwise AND between its operands and sets flags based on the result, but unlike AND, neither operand is modified. `TEST RAX, RBX` computes RAX & RBX, sets flags, and discards the result.

TEST clears CF and OF to zero, sets ZF if the result is zero, SF to the most significant bit of the result, and PF to the parity of the low byte. AF becomes undefined.

Common usage patterns:

**Testing if a register is zero**: `TEST RAX, RAX` sets ZF if RAX is zero (all bits are clear). This is equivalent to `CMP RAX, 0` but often encoded more compactly. Conditional jumps like JZ/JE and JNZ/JNE test ZF.

**Testing specific bits**: `TEST AL, 0x80` checks if bit 7 of AL is set. If bit 7 is set, SF=1 (because the result's high bit is set) and ZF=0. If bit 7 is clear, SF=0 and ZF depends on other bits. To specifically test if bit 7 is set, use JS (jump if sign) after TEST.

**Testing multiple bits with a mask**: `TEST EAX, 0x0F` checks if any of the low 4 bits are set. If any bit in the mask is set in EAX, ZF=0. If all masked bits are clear, ZF=1. JZ/JNZ can then branch based on whether any bits were set.

**Testing for odd/even**: `TEST AL, 1` checks if AL is odd (bit 0 set). ZF=0 if odd, ZF=1 if even.

**Testing sign**: `TEST RAX, RAX` sets SF to bit 63 (the sign bit). JS jumps if negative, JNS jumps if non-negative. This is equivalent to comparing with zero but may execute faster.

TEST is commonly used in conditional logic where specific bits or flags need checking. The instruction never modifies any operands, making it safe for repeated testing.

Comparing TEST vs CMP: Both set flags without side effects on operands, but TEST performs AND while CMP performs subtraction. TEST is used for bit testing and zero checking; CMP is used for relational comparisons (less than, greater than, etc.).

### Other Comparison Instructions

CMPXCHG (Compare and Exchange) atomically compares the destination operand with the accumulator (AL/AX/EAX/RAX) and, if equal, loads the source operand into the destination. If not equal, it loads the destination into the accumulator. `CMPXCHG [RBX], ECX` compares EAX with the 32-bit value at [RBX]. If equal, it stores ECX to [RBX] and sets ZF=1. If not equal, it loads [RBX] into EAX and clears ZF=0.

CMPXCHG is fundamental to lock-free algorithms and synchronization primitives. When used with the LOCK prefix on memory operands, it provides atomic compare-and-swap semantics.

CMPXCHG8B and CMPXCHG16B compare and exchange 8-byte or 16-byte values. CMPXCHG8B compares EDX:EAX with an 8-byte memory value; if equal, stores ECX:EBX to memory. CMPXCHG16B operates on 16 bytes using RDX:RAX and RCX:RBX. These are used for lock-free data structures requiring wider atomic operations.

CMPS (Compare String) compares bytes, words, dwords, or qwords at [RSI] with [RDI], sets flags, then increments or decrements both RSI and RDI based on DF. CMPSB compares bytes, CMPSW compares words, CMPSD compares dwords, CMPSQ compares qwords.

CMPS is typically used with the REP prefix for block comparison: `REPE CMPSB` compares bytes while they remain equal (ZF=1) and RCX is non-zero. It stops when a mismatch occurs or RCX reaches zero. REPNE CMPSB compares while bytes differ.

SCAS (Scan String) compares the accumulator (AL/AX/EAX/RAX) with the value at [RDI], sets flags, then adjusts RDI. `SCASB` compares AL with [RDI], `SCASQ` compares RAX with [RDI]. Combined with REP prefixes: `REPNE SCASB` searches memory for the byte in AL.

These string instructions are useful for implementing memory search, comparison, and scanning operations, though modern code often uses SSE/AVX instructions for better performance on large blocks.

