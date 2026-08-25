## Conditional Execution


ARM's distinctive feature is its ability to conditionally execute almost any instruction based on processor status flags. This capability reduces branch instructions, improves code density, and can enhance performance by avoiding pipeline disruption.

### Condition Code Suffixes

Instructions can be made conditional by appending a two-letter condition code suffix. The processor evaluates the condition against current flag states before executing the instruction. If the condition is false, the instruction behaves as a NOP (no operation), consuming one cycle but changing no architectural state.

**Condition Code Mnemonics**

Each condition code tests specific combinations of status flags. EQ (equal) tests if Z flag is set, NE (not equal) tests if Z is clear, GT (greater than) tests Z clear AND N equals V for signed comparison, and LT (less than) tests N not equal to V. The complete set includes 15 usable conditions plus AL (always), which is the default when no suffix is specified.

**Syntax Application**

The condition suffix appears between the instruction mnemonic and any size/update suffixes. `ADDEQ` adds if equal, `LDRNEB` loads byte if not equal, `STRHS` stores if unsigned higher or same. The 'S' flag-update suffix comes after the condition code: `ADDNES` adds if not equal and updates flags.

**Example:**

```assembly
CMP r0, r1              @ Compare r0 and r1, set flags
MOVEQ r2, #1            @ r2 = 1 if r0 == r1
MOVNE r2, #0            @ r2 = 0 if r0 != r1
ADDGT r3, r3, #1        @ r3++ if r0 > r1 (signed)
LDRLE r4, [r5]          @ Load if r0 <= r1 (signed)
STRCC r6, [r7]          @ Store if carry clear (unsigned less than)
```

### Predication Benefits

Conditional execution eliminates short forward branches, reducing code size and avoiding branch prediction penalties. A simple if-then-else selecting between two values requires no branches: the comparison sets flags, then conditional moves select the appropriate value based on those flags.

**Branch Avoidance**

Traditional architectures require a conditional branch to skip instructions in an if statement. ARM can predicate the instructions themselves, executing them only when conditions are met. This is particularly effective for short conditional sequences of 1-4 instructions.

**Pipeline Efficiency**

[Inference: Predicated instructions that fail their condition checks typically allow the pipeline to continue smoothly, potentially avoiding the multi-cycle penalty of a mispredicted branch, though the exact performance characteristics depend on the specific ARM implementation].

**Example:**

```assembly
@ Traditional approach with branches
CMP r0, #10
BLT skip_block
ADD r1, r1, #5
MOV r2, #1
skip_block:

@ Predicated approach without branches
CMP r0, #10
ADDGE r1, r1, #5        @ Only execute if r0 >= 10
MOVGE r2, #1            @ Only execute if r0 >= 10
```

### Limitations and Considerations

Not all ARM architectures support predication equally. ARMv8-A in AArch64 state removes most conditional execution, retaining only conditional branches and conditional select instructions. Thumb mode provides limited conditional execution through IT (If-Then) blocks rather than per-instruction conditions.

**IT Blocks in Thumb**

Thumb-2 uses IT (If-Then) instruction to create conditional execution blocks. The IT instruction specifies a condition and up to four following instructions that execute conditionally. Syntax like `ITTTE EQ` means: if equal, then (execute), then (execute), then (execute), else (don't execute the fourth).

