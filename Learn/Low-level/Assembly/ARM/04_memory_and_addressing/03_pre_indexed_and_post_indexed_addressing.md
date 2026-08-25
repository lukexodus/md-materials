## Pre-Indexed and Post-Indexed Addressing


These addressing modes update the base register automatically during load/store operations.

### Pre-Indexed Addressing (Write-Back)

The base register is updated with the calculated address before the memory access, and this updated value is written back.

**Syntax:**

```assembly
ldr r0, [r1, #offset]!    @ r1 = r1 + offset, then r0 = [r1]
ldr r0, [r1, r2]!         @ r1 = r1 + r2, then r0 = [r1]
```

**The exclamation mark (!) indicates write-back.**

**Examples:**

```assembly
# Increment pointer before access
ldr r0, [r1, #4]!     @ r1 += 4, then load from [r1]
                      @ Equivalent to:
                      @ add r1, r1, #4
                      @ ldr r0, [r1]

# Array traversal
mov r0, #0            @ Sum accumulator
ldr r1, =array        @ Array pointer
mov r2, #10           @ Counter

loop:
    ldr r3, [r1, #4]! @ Pre-increment pointer, load element
    add r0, r0, r3    @ Add to sum
    subs r2, r2, #1   @ Decrement counter
    bne loop          @ Loop if not zero

# Stack operations (growing downward)
str r0, [sp, #-4]!    @ Pre-decrement sp, store r0 (push)
ldr r0, [sp], #4      @ Load r0, post-increment sp (pop)
```

**String/Buffer Operations:**

```assembly
# Copy string with pre-increment
# r0 = source, r1 = destination
copy_loop:
    ldrb r2, [r0, #1]!    @ Pre-increment source, load byte
    strb r2, [r1, #1]!    @ Pre-increment dest, store byte
    cmp r2, #0            @ Check for null terminator
    bne copy_loop
```

### Post-Indexed Addressing

The memory access occurs using the current base register value, then the base register is updated afterward.

**Syntax:**

```assembly
ldr r0, [r1], #offset     @ r0 = [r1], then r1 = r1 + offset
ldr r0, [r1], r2          @ r0 = [r1], then r1 = r1 + r2
```

**No exclamation mark; the update happens automatically after access.**

**Examples:**

```assembly
# Access then increment pointer
ldr r0, [r1], #4      @ Load from [r1], then r1 += 4
                      @ Equivalent to:
                      @ ldr r0, [r1]
                      @ add r1, r1, #4

# Array traversal with post-increment
ldr r0, =array        @ Array pointer
mov r1, #10           @ Counter
mov r2, #0            @ Sum

loop:
    ldr r3, [r0], #4  @ Load element, post-increment pointer
    add r2, r2, r3    @ Add to sum
    subs r1, r1, #1   @ Decrement counter
    bne loop

# Sequential memory access
mov r0, #0x20000000   @ Buffer start
ldr r1, [r0], #4      @ Load word 0, advance to word 1
ldr r2, [r0], #4      @ Load word 1, advance to word 2
ldr r3, [r0], #4      @ Load word 2, advance to word 3
# r0 now points to word 3
```

**Buffer Processing:**

```assembly
# Process buffer elements
# r0 = buffer pointer, r1 = count
process_buffer:
    push {r4, lr}
    mov r4, #0            @ Running total

process_loop:
    ldr r2, [r0], #4      @ Load element, advance pointer
    add r4, r4, r2        @ Process element
    subs r1, r1, #1       @ Decrement count
    bne process_loop
    
    mov r0, r4            @ Return total
    pop {r4, pc}
```

### Pre-Indexed vs Post-Indexed Comparison

**Pre-Indexed:**

```assembly
# Update happens BEFORE memory access
ldr r0, [r1, #4]!     
# 1. r1 = r1 + 4
# 2. r0 = memory[r1]

# Use when you want to:
# - Access next element and keep pointer there
# - Skip first element
# - Implement pre-increment loops
```

**Post-Indexed:**

```assembly
# Update happens AFTER memory access
ldr r0, [r1], #4      
# 1. r0 = memory[r1]
# 2. r1 = r1 + 4

# Use when you want to:
# - Access current element then advance
# - Sequential processing
# - Implement post-increment loops
```

**Example Comparison:**

```assembly
# Pre-indexed: Skip first element
ldr r0, =array
ldr r1, [r0, #4]!     @ r0 now points to array[1]
ldr r2, [r0, #4]!     @ r0 now points to array[2]

# Post-indexed: Start from first element
ldr r0, =array
ldr r1, [r0], #4      @ r1 = array[0], r0 points to array[1]
ldr r2, [r0], #4      @ r2 = array[1], r0 points to array[2]
```

### Stack Operations Using Indexed Addressing

**Full Descending Stack (ARM standard):**

```assembly
# Push (store with pre-decrement)
str r0, [sp, #-4]!    @ sp -= 4, then [sp] = r0
stmdb sp!, {r0-r3}    @ Push multiple (decrement before)

# Pop (load with post-increment)
ldr r0, [sp], #4      @ r0 = [sp], then sp += 4
ldmia sp!, {r0-r3}    @ Pop multiple (increment after)
```

**Other Stack Types:**

```assembly
# Full Ascending (sp points to last used)
stmib sp!, {r0-r3}    @ Increment before store
ldmda sp!, {r0-r3}    @ Decrement after load

# Empty Descending (sp points to next free)
stmda sp!, {r0-r3}    @ Decrement after store
ldmib sp!, {r0-r3}    @ Increment before load

# Empty Ascending (sp points to next free)
stmia sp!, {r0-r3}    @ Increment after store
ldmdb sp!, {r0-r3}    @ Decrement before load
```

