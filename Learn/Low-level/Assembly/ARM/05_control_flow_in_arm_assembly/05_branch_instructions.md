## Branch Instructions


### Unconditional Branches

Branch instructions transfer control to a different location in the program.

**Basic Branch Types:**

```assembly
b label               @ Branch to label (relative, ±16MB range)
bl function          @ Branch with Link (call function, saves return in LR)
bx r0                @ Branch and Exchange (can switch ARM/Thumb modes)
blx r0               @ Branch with Link and Exchange

# Example
main:
    bl function1     @ Call function1
    b next           @ Jump to next
    # This code never executes
    mov r0, #1

next:
    mov r0, #0
    bx lr            @ Return
```

**Long Branches:**

```assembly
# For addresses beyond ±16MB
ldr pc, =far_label   @ Load address into PC
# or
adr r0, far_label    @ Load address
bx r0                @ Branch to it
```

### Conditional Branches

Conditional branches depend on condition flags in the CPSR (Current Program Status Register).

**Condition Codes:**

```assembly
beq label            @ Branch if Equal (Z=1)
bne label            @ Branch if Not Equal (Z=0)
bgt label            @ Branch if Greater Than (signed)
bge label            @ Branch if Greater or Equal (signed)
blt label            @ Branch if Less Than (signed)
ble label            @ Branch if Less or Equal (signed)
bhi label            @ Branch if Higher (unsigned)
bhs/bcs label        @ Branch if Higher or Same / Carry Set (unsigned)
blo/bcc label        @ Branch if Lower / Carry Clear (unsigned)
bls label            @ Branch if Lower or Same (unsigned)
bmi label            @ Branch if Minus (N=1)
bpl label            @ Branch if Plus (N=0)
bvs label            @ Branch if Overflow Set (V=1)
bvc label            @ Branch if Overflow Clear (V=0)
```

**Condition Flags (CPSR):**

- **N (Negative)**: Set if result is negative
- **Z (Zero)**: Set if result is zero
- **C (Carry)**: Set on unsigned overflow or borrow
- **V (Overflow)**: Set on signed overflow

**Setting Condition Flags:**

```assembly
cmp r0, r1           @ Compare: sets flags based on r0 - r1
cmn r0, r1           @ Compare negative: flags based on r0 + r1
tst r0, r1           @ Test: flags based on r0 AND r1
teq r0, r1           @ Test equivalence: flags based on r0 XOR r1

# Data processing with 'S' suffix
adds r0, r1, r2      @ Add and set flags
subs r0, r1, r2      @ Subtract and set flags
ands r0, r1, r2      @ AND and set flags
```

**Conditional Execution (ARM mode, pre-ARMv8):**

```assembly
# Instructions can be conditionally executed
cmp r0, #10
addgt r1, r1, #1     @ Execute only if r0 > 10
movle r2, #0         @ Execute only if r0 <= 10

# Without branches
mov r0, #5
cmp r0, #3
movgt r1, #1         @ r1 = 1 if r0 > 3
movle r1, #0         @ r1 = 0 if r0 <= 3
```

**IT Blocks (Thumb-2):**

```assembly
# IT (If-Then) provides conditional execution in Thumb
cmp r0, #10
ite gt               @ If-Then-Else
movgt r1, #1         @ Execute if greater
movle r1, #0         @ Execute if less or equal

# Multiple instructions
cmp r0, r1
ittt eq              @ If-Then-Then-Then (all equal condition)
addeq r2, r2, #1
moveq r3, #0
streq r2, [r4]

# Mixed conditions
cmp r0, #5
ittee gt             @ If-Then-Then-Else-Else
addgt r1, r1, #1     @ Execute if GT
subgt r2, r2, #1     @ Execute if GT
addle r1, r1, #2     @ Execute if LE
subsle r2, r2, #2    @ Execute if LE
```

