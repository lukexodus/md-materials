## Multi-Register Operations (LDM, STM)


Load Multiple (LDM) and Store Multiple (STM) instructions transfer multiple registers to/from memory in a single operation, significantly improving performance for bulk data operations.

### Basic LDM/STM Syntax

**Load Multiple (LDM):**

```assembly
ldm r0, {r1-r5}          @ Load r1, r2, r3, r4, r5 from [r0]
ldm r0!, {r1-r5}         @ Load and update r0 (write-back)
ldmia r0, {r1-r5}        @ Increment After (same as ldm)
ldmib r0, {r1-r5}        @ Increment Before
ldmda r0, {r1-r5}        @ Decrement After
ldmdb r0, {r1-r5}        @ Decrement Before
```

**Store Multiple (STM):**

```assembly
stm r0, {r1-r5}          @ Store r1, r2, r3, r4, r5 to [r0]
stm r0!, {r1-r5}         @ Store and update r0 (write-back)
stmia r0, {r1-r5}        @ Increment After (same as stm)
stmib r0, {r1-r5}        @ Increment Before
stmda r0, {r1-r5}        @ Decrement After
stmdb r0, {r1-r5}        @ Decrement Before
```

### Addressing Modes for LDM/STM

**Increment After (IA):**

```assembly
# Address used, then incremented
# r0 = 0x1000, registers = {r1, r2, r3}
ldmia r0!, {r1-r3}

# Memory accesses:
# r1 = [0x1000]
# r2 = [0x1004]
# r3 = [0x1008]
# r0 = 0x100C (updated)
```

**Increment Before (IB):**

```assembly
# Address incremented, then used
# r0 = 0x1000
ldmib r0!, {r1-r3}

# Memory accesses:
# r1 = [0x1004]
# r2 = [0x1008]
# r3 = [0x100C]
# r0 = 0x100C (updated)
```

**Decrement After (DA):**

```assembly
# Address used, then decremented
# r0 = 0x1000
ldmda r0!, {r1-r3}

# Memory accesses:
# r1 = [0x1000]
# r2 = [0x0FFC]
# r3 = [0x0FF8]
# r0 = 0x0FF8 (updated)
```

**Decrement Before (DB):**

```assembly
# Address decremented, then used
# r0 = 0x1000
ldmdb r0!, {r1-r3}

# Memory accesses:
# r1 = [0x0FFC]
# r2 = [0x0FF8]
# r3 = [0x0FF4]
# r0 = 0x0FF4 (updated)
```

### Register List Specifications

**Contiguous Ranges:**

```assembly
ldm r0, {r1-r5}          @ r1, r2, r3, r4, r5
ldm r0, {r0-r7}          @ r0 through r7
```

**Non-Contiguous Lists:**

```assembly
ldm r0, {r1, r3, r5, r7} @ Only odd-numbered registers
ldm r0, {r0, r2, r4-r7}  @ Mixed: r0, r2, r4, r5, r6, r7
```

**Including Special Registers:**

```assembly
ldm r0, {r1-r5, lr}      @ Include link register
stm r0, {r4-r11, lr}     @ Common function prologue pattern
ldm sp!, {r4-r11, pc}    @ Common epilogue (restore and return)
```

**Register Order:** [Inference] LDM/STM operations process registers in ascending numerical order regardless of the order specified in the register list. Lower-numbered registers are transferred to/from lower memory addresses.

```assembly
# These are equivalent
ldm r0, {r7, r3, r5, r1}
ldm r0, {r1, r3, r5, r7}

# Both load in order:
# r1 = [r0 + 0]
# r3 = [r0 + 4]
# r5 = [r0 + 8]
# r7 = [r0 + 12]
```

### Stack Operations Using LDM/STM

**Full Descending Stack (ARM Standard):**

```assembly
# Push (store): decrement before, then store
stmfd sp!, {r0-r3, lr}   @ push {r0-r3, lr}
stmdb sp!, {r0-r3, lr}   @ Same as stmfd

# Pop (load): load, then increment after
ldmfd sp!, {r0-r3, pc}   @ pop {r0-r3, pc}
ldmia sp!, {r0-r3, pc}   @ Same as ldmfd
```

**Other Stack Types:**

```assembly
# Full Ascending (FA)
stmfa sp!, {r0-r3}       @ Increment before
ldmfa sp!, {r0-r3}       @ Decrement after
# Aliases: stmib, ldmda

# Empty Descending (ED)
stmed sp!, {r0-r3}       @ Decrement after
ldmed sp!, {r0-r3}       @ Increment before
# Aliases: stmda, ldmib

# Empty Ascending (EA)
stmea sp!, {r0-r3}       @ Increment after
ldmea sp!, {r0-r3}       @ Decrement before
# Aliases: stmia, ldmdb
```

**Function Prologue and Epilogue:**

```assembly
# Standard function entry
function:
    push {r4-r7, lr}     @ Save callee-saved registers
    # or
    stmdb sp!, {r4-r7, lr}
    
    # Function body
    # ...
    
    # Standard function exit
    pop {r4-r7, pc}      @ Restore registers and return
    # or
    ldmia sp!, {r4-r7, pc}
```

### Structure Operations

**Loading Structure Members:**

```assembly
# struct Point3D {
#     int x;  // offset 0
#     int y;  // offset 4
#     int z;  // offset 8
# };
# r0 points to Point3D structure

load_point:
    ldm r0, {r1-r3}      @ r1=x, r2=y, r3=z
    # Process coordinates in r1, r2, r3
    bx lr

# Array of structures
# r0 = array base, r1 = index
load_point_from_array:
    add r2, r1, r1, LSL #1   @ index * 3
    add r0, r0, r2, LSL #2   @ base + (index * 12)
    ldm r0, {r1-r3}          @ Load structure
    bx lr
```

**Storing Structure Members:**

```assembly
# Store Point3D structure
# r0 = destination, r1=x, r2=y, r3=z
store_point:
    stm r0, {r1-r3}      @ Store all three coordinates
    bx lr

# Copy structure
# r0 = dest, r1 = src
copy_point:
    ldm r1, {r2-r4}      @ Load from source
    stm r0, {r2-r4}      @ Store to destination
    bx lr
```

**Large Structure Copy:**

```assembly
# Copy large structure (16 words = 64 bytes)
# r0 = dest, r1 = src
copy_large_struct:
    ldm r1!, {r2-r9}     @ Load 8 words, update src
    stm r0!, {r2-r9}     @ Store 8 words, update dest
    ldm r1!, {r2-r9}     @ Load next 8 words
    stm r0!, {r2-r9}     @ Store next 8 words
    bx lr
```

### Array Operations

**Copy Array:**

```assembly
# Copy array of 8 words
# r0 = dest, r1 = src
copy_array_8:
    ldm r1, {r2-r9}      @ Load 8 elements
    stm r0, {r2-r9}      @ Store 8 elements
    bx lr

# Copy array with loop
# r0 = dest, r1 = src, r2 = count (in words)
copy_array_loop:
    push {r4-r11}
    
copy_loop:
    cmp r2, #8
    blt copy_remainder
    
    ldmia r1!, {r3-r10}  @ Load 8 words
    stmia r0!, {r3-r10}  @ Store 8 words
    sub r2, r2, #8
    b copy_loop

copy_remainder:
    cmp r2, #0
    beq copy_done
    
    ldr r3, [r1], #4     @ Copy remaining words one at a time
    str r3, [r0], #4
    subs r2, r2, #1
    bne copy_remainder

copy_done:
    pop {r4-r11}
    bx lr
```

**Initialize Array:**

```assembly
# Fill array with value
# r0 = array, r1 = value, r2 = count (in words)
fill_array:
    # Replicate value in multiple registers
    mov r3, r1
    mov r4, r1
    mov r5, r1
    mov r6, r1
    mov r7, r1
    mov r8, r1
    mov r9, r1
    mov r10, r1

fill_loop:
    cmp r2, #8
    blt fill_remainder
    
    stmia r0!, {r3-r10}  @ Store 8 copies
    sub r2, r2, #8
    b fill_loop

fill_remainder:
    cmp r2, #0
    beq fill_done
    
    str r1, [r0], #4     @ Store remaining words
    subs r2, r2, #1
    bne fill_remainder

fill_done:
    bx lr
```

### Context Switching

**Save Processor Context:**

```assembly
# Save full context for task switching
# r0 = context save area pointer
save_context:
    # Save general purpose registers
    stmia r0!, {r1-r12}  @ Save r1-r12
    
    # Save SP and LR
    mov r1, sp
    mov r2, lr
    stmia r0!, {r1-r2}
    
    # Save CPSR
    mrs r1, cpsr
    str r1, [r0]
    
    bx lr

# Restore processor context
# r0 = context save area pointer
restore_context:
    # Restore general purpose registers
    ldmia r0!, {r1-r12}
    
    # Restore SP and LR
    ldmia r0!, {r1-r2}
    mov sp, r1
    mov lr, r2
    
    # Restore CPSR
    ldr r1, [r0]
    msr cpsr_c, r1
    
    bx lr
```

### Buffer Management

**Ring Buffer Operations:**

```assembly
# Ring buffer read multiple
# r0 = buffer base, r1 = read_ptr, r2 = count, r3 = buffer_size
# Returns updated read_ptr in r0
ring_buffer_read:
    push {r4-r7}
    
    mov r4, r0           @ Save buffer base
    mov r5, r1           @ Current read position
    mov r6, r2           @ Items to read
    mov r7, r3           @ Buffer size

read_loop:
    cmp r6, #0
    beq read_done
    
    # Calculate wrapped position
    cmp r5, r7
    subge r5, r5, r7     @ Wrap if >= size
    
    # Read from buffer
    ldr r0, [r4, r5, LSL #2]
    # Process r0...
    
    add r5, r5, #1       @ Advance read pointer
    subs r6, r6, #1
    b read_loop

read_done:
    mov r0, r5           @ Return updated pointer
    pop {r4-r7}
    bx lr
```

