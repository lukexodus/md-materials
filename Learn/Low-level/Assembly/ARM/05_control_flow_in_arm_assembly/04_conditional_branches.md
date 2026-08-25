## Conditional Branches


Conditional branches combine branch instructions with condition codes to implement control flow structures like if-statements, loops, and case selections. They form the foundation of structured programming in assembly.

### Comparison-Based Branches

The typical pattern compares two values with CMP or TST, then branches based on the resulting flags. This implements conditional statements and loop tests.

**Equality and Inequality**

CMP followed by BEQ or BNE implements equality tests. `CMP r0, r1` then `BEQ equal_block` branches if r0 equals r1. BNE branches when operands differ. These are the most common conditional branches for if-statements and loop conditions.

**Relational Comparisons**

Signed comparisons use BGT (greater than), BGE (greater or equal), BLT (less than), BLE (less or equal). Unsigned comparisons use BHI (higher), BHS (higher or same), BLO (lower), BLS (lower or same). The signed variants test N and V flags together, unsigned variants test C and Z flags.

**Example:**

```assembly
@ If-then-else structure
CMP r0, r1
BNE else_block          @ If r0 != r1, jump to else
    @ Then block
    MOV r2, #1
    B endif
else_block:
    @ Else block
    MOV r2, #0
endif:

@ For loop: for (i = 10; i > 0; i--)
MOV r0, #10             @ i = 10
for_loop:
    @ Loop body
    SUBS r0, r0, #1     @ i--, set flags
    BGT for_loop        @ Continue if i > 0
```

### Condition Code Reference

The complete set of condition codes and their flag tests:

**EQ (Equal)**: Z set. Used after comparison when operands are equal.

**NE (Not Equal)**: Z clear. Used when operands differ.

**CS/HS (Carry Set / Higher or Same)**: C set. Unsigned greater-or-equal after comparison.

**CC/LO (Carry Clear / Lower)**: C clear. Unsigned less-than after comparison.

**MI (Minus/Negative)**: N set. Result is negative.

**PL (Plus/Positive or Zero)**: N clear. Result is non-negative.

**VS (Overflow Set)**: V set. Signed overflow occurred.

**VC (Overflow Clear)**: V clear. No signed overflow.

**HI (Higher)**: C set AND Z clear. Unsigned greater-than after comparison.

**LS (Lower or Same)**: C clear OR Z set. Unsigned less-or-equal after comparison.

**GE (Greater or Equal)**: N equals V. Signed greater-or-equal after comparison.

**LT (Less Than)**: N not-equal-to V. Signed less-than after comparison.

**GT (Greater Than)**: Z clear AND N equals V. Signed greater-than after comparison.

**LE (Less or Equal)**: Z set OR N not-equal-to V. Signed less-or-equal after comparison.

**AL (Always)**: Always execute. Default when no condition specified. [Inference: AL is typically omitted as it's the default condition].

**Example:**

```assembly
@ Unsigned comparison
CMP r0, r1
BHI unsigned_greater    @ r0 > r1 (unsigned)
BLS unsigned_less_eq    @ r0 <= r1 (unsigned)

@ Signed comparison
CMP r2, r3
BGT signed_greater      @ r2 > r3 (signed)
BLE signed_less_eq      @ r2 <= r3 (signed)

@ Overflow checking
ADDS r4, r5, r6         @ Add with flag update
BVS overflow_handler    @ Branch if signed overflow

@ Bit testing
TST r7, #0x04           @ Test bit 2
BNE bit_set             @ Branch if bit is set
BEQ bit_clear           @ Branch if bit is clear
```

### Loop Structures

Common loop patterns in ARM assembly use conditional branches for iteration control.

**While Loop**

A while loop tests the condition before each iteration. The test occurs at the loop start, with a conditional branch exiting when the condition becomes false.

**Example:**

```assembly
@ While (r0 != 0)
while_loop:
    CMP r0, #0
    BEQ end_while       @ Exit if r0 == 0
    @ Loop body
    SUB r0, r0, #1
    B while_loop
end_while:
```

**Do-While Loop**

A do-while loop tests the condition after each iteration, guaranteeing at least one execution. The conditional branch appears at the loop end.

**Example:**

```assembly
@ Do { body } while (r0 != 0)
do_loop:
    @ Loop body
    SUBS r0, r0, #1     @ Decrement and set flags
    BNE do_loop         @ Continue if r0 != 0
```

**For Loop**

For loops combine initialization, test, and increment. The counter update often uses SUBS to simultaneously decrement and set flags for the branch condition.

**Example:**

```assembly
@ For (i = 0; i < 10; i++)
MOV r0, #0              @ i = 0
for_loop:
    CMP r0, #10
    BGE end_for         @ Exit if i >= 10
    @ Loop body
    ADD r0, r0, #1      @ i++
    B for_loop
end_for:
```

**Countdown Loop Optimization**

Counting down to zero is more efficient than counting up because SUBS sets the Z flag, eliminating a separate comparison instruction.

**Example:**

```assembly
@ Efficient countdown: for (i = 10; i != 0; i--)
MOV r0, #10
countdown:
    @ Loop body
    SUBS r0, r0, #1     @ Decrement and set flags
    BNE countdown       @ No separate CMP needed
```

### Switch/Case Implementation

Switch statements with multiple cases can be implemented using comparison chains or jump tables depending on case density and range.

**Comparison Chain**

Sequential comparisons test each case value, branching to the corresponding handler. This works for any case values but requires multiple comparisons.

**Example:**

```assembly
@ Switch (r0)
CMP r0, #1
BEQ case_1
CMP r0, #2
BEQ case_2
CMP r0, #5
BEQ case_5
B default_case

case_1:
    @ Handle case 1
    B end_switch
case_2:
    @ Handle case 2
    B end_switch
case_5:
    @ Handle case 5
    B end_switch
default_case:
    @ Handle default
end_switch:
```

**Jump Table**

For dense consecutive case values, a jump table provides O(1) lookup. An array of branch targets is indexed by the case value, with bounds checking for safety.

**Example:**

```assembly
@ Switch (r0) for cases 0-3
CMP r0, #3              @ Bounds check
BHI default_case        @ Jump to default if > 3

ADR r1, jump_table      @ Load jump table address
LDR pc, [r1, r0, LSL #2] @ Branch to jump_table[r0]

jump_table:
    .word case_0
    .word case_1
    .word case_2
    .word case_3

case_0:
    @ Handle case 0
    B end_switch
case_1:
    @ Handle case 1
    B end_switch
@ ... additional cases
end_switch:
```

### Branch Prediction Considerations

[Inference: Modern ARM processors use branch prediction to speculatively execute instructions before branch outcomes are known. Predictable branches (loop back-edges, consistently taken/not-taken branches) typically predict well, while unpredictable branches may cause pipeline flushes. Conditional execution can eliminate branches entirely for short sequences, potentially improving performance by avoiding prediction altogether].

**Key Points:**

- ARM supports conditional execution of most instructions through two-letter condition code suffixes, reducing branch instructions for short conditional sequences
- Four condition flags (N, Z, C, V) in CPSR encode result properties: negative, zero, carry/borrow, signed overflow
- C flag has inverted meaning for subtraction: set indicates no borrow (first operand >= second operand unsigned)
- Signed comparisons (GT, GE, LT, LE) test N and V flags together to handle overflow cases correctly
- Unsigned comparisons (HI, HS, LO, LS) test C and Z flags for magnitude relationships without sign considerations
- Branch instructions include B (branch), BL (branch with link for calls), BX (branch with instruction set exchange), and BLX (combined call and exchange)
- Return addresses are saved in link register (LR/r14) by BL and BLX, with functions returning via BX LR or POP {pc}
- Conditional branches combine CMP/TST with condition codes (BEQ, BNE, BGT, etc.) to implement control flow structures
- Countdown loops using SUBS are more efficient than count-up loops as they eliminate separate comparison instructions
- Jump tables provide efficient O(1) switch statement implementation for dense consecutive case values

**Important related topics:** IT (If-Then) blocks in Thumb-2 mode, CPSR and SPSR register organization, AArch64 conditional execution changes (elimination of most predication), branch prediction and pipeline effects, function calling conventions and register preservation requirements, long branch veneer generation by assemblers/linkers, performance comparison between predicated execution and branching.

---

