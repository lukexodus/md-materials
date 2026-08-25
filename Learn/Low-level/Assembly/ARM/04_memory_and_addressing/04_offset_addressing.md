## Offset Addressing


Offset addressing provides flexible memory access patterns without modifying the base register.

### Simple Offset

The base register remains unchanged; only the effective address is calculated.

**Syntax:**

```assembly
ldr r0, [r1, #offset]     @ Address = r1 + offset, r1 unchanged
ldr r0, [r1, r2]          @ Address = r1 + r2, r1 unchanged
```

**Examples:**

```assembly
# Structure member access
# struct { int x; int y; int z; } point;
# r0 points to structure
ldr r1, [r0, #0]      @ r1 = point.x
ldr r2, [r0, #4]      @ r2 = point.y
ldr r3, [r0, #8]      @ r3 = point.z
# r0 still points to structure base

# Multiple accesses to same structure
ldr r0, =my_struct
ldr r1, [r0, #0]      @ Load member 1
add r1, r1, #10       @ Process
str r1, [r0, #0]      @ Store back
ldr r2, [r0, #4]      @ Load member 2
mul r2, r2, r1        @ Process
str r2, [r0, #4]      @ Store back
# r0 unchanged throughout
```

### Complex Data Structure Access

**Nested Structure Example:**

```assembly
# struct Outer {
#     int id;              @ offset 0
#     struct Inner {
#         int x;           @ offset 4
#         int y;           @ offset 8
#     } inner;
#     int value;           @ offset 12
# };

# r0 points to Outer structure
ldr r1, [r0, #0]      @ outer.id
ldr r2, [r0, #4]      @ outer.inner.x
ldr r3, [r0, #8]      @ outer.inner.y
ldr r4, [r0, #12]     @ outer.value
```

**Array of Structures:**

```assembly
# struct Point { int x; int y; } points[10];
# Each structure is 8 bytes
# r0 = array base, r1 = index

# Calculate structure address
mov r2, #8            @ Structure size
mul r3, r1, r2        @ Offset = index * size
add r4, r0, r3        @ Address of points[index]

# Access members
ldr r5, [r4, #0]      @ points[index].x
ldr r6, [r4, #4]      @ points[index].y

# Alternative: direct calculation
lsl r3, r1, #3        @ index * 8 (shift left by 3)
ldr r5, [r0, r3]      @ points[index].x
add r3, r3, #4
ldr r6, [r0, r3]      @ points[index].y
```

### Base Register with Multiple Offsets

**Accessing Multiple Array Elements:**

```assembly
# Process adjacent array elements
ldr r0, =array
ldr r1, [r0, #0]      @ array[0]
ldr r2, [r0, #4]      @ array[1]
ldr r3, [r0, #8]      @ array[2]
ldr r4, [r0, #12]     @ array[3]

# Calculate sum
add r5, r1, r2
add r5, r5, r3
add r5, r5, r4
```

**Sliding Window Operations:**

```assembly
# 3-element moving average
# r0 = array pointer, r1 = index
lsl r2, r1, #2        @ Convert index to byte offset
ldr r3, [r0, r2]      @ current element
sub r2, r2, #4
ldr r4, [r0, r2]      @ previous element
add r2, r2, #8
ldr r5, [r0, r2]      @ next element

add r6, r3, r4
add r6, r6, r5
mov r7, #3
udiv r6, r6, r7       @ Average = (prev + curr + next) / 3
```

### Bit Field Access

**Loading and Extracting Bit Fields:**

```assembly
# Extract bits [15:8] from word at [r0]
ldr r1, [r0]          @ Load full word
ubfx r2, r1, #8, #8   @ Extract 8 bits starting at bit 8

# Insert bit field
ldr r1, [r0]          @ Load current value
bfi r1, r3, #8, #8    @ Insert r3 bits [7:0] into r1 bits [15:8]
str r1, [r0]          @ Store modified value
```

### Memory-Mapped I/O Access

**Peripheral Register Access:**

```assembly
# GPIO peripheral access
.equ GPIO_BASE, 0x40020000
.equ GPIO_IDR,  0x10      @ Input Data Register offset
.equ GPIO_ODR,  0x14      @ Output Data Register offset
.equ GPIO_BSRR, 0x18      @ Bit Set/Reset Register offset

# Read input
ldr r0, =GPIO_BASE
ldr r1, [r0, #GPIO_IDR]   @ Read input register

# Write output
ldr r2, =0xFF
str r2, [r0, #GPIO_ODR]   @ Write output register

# Set specific bits
mov r3, #(1 << 5)
str r3, [r0, #GPIO_BSRR]  @ Set bit 5
```

**Timer Configuration:**

```assembly
# TIM2 peripheral configuration
.equ TIM2_BASE, 0x40000000
.equ TIM_CR1,   0x00      @ Control register 1
.equ TIM_PSC,   0x28      @ Prescaler
.equ TIM_ARR,   0x2C      @ Auto-reload register

ldr r0, =TIM2_BASE
mov r1, #1000
str r1, [r0, #TIM_PSC]    @ Set prescaler
mov r1, #10000
str r1, [r0, #TIM_ARR]    @ Set auto-reload value
mov r1, #1
str r1, [r0, #TIM_CR1]    @ Enable timer
```

### DMA Buffer Operations

**Setting Up DMA Transfer:**

```assembly
# Configure DMA for memory-to-memory transfer
.equ DMA1_BASE,     0x40020000
.equ DMA_CCR,       0x08      @ Configuration register
.equ DMA_CNDTR,     0x0C      @ Number of data register
.equ DMA_CPAR,      0x10      @ Peripheral address register
.equ DMA_CMAR,      0x14      @ Memory address register

ldr r0, =DMA1_BASE
ldr r1, =source_buffer
str r1, [r0, #DMA_CPAR]       @ Source address
ldr r1, =dest_buffer
str r1, [r0, #DMA_CMAR]       @ Destination address
mov r1, #1024
str r1, [r0, #DMA_CNDTR]      @ Transfer size
ldr r1, =0x00004081           @ Configuration flags
str r1, [r0, #DMA_CCR]        @ Start DMA
```

### Volatile Access

**Ensuring Memory Access Ordering:**

```assembly
# Volatile read (force memory access)
ldr r0, [r1]          @ Load from memory
dmb                   @ Data Memory Barrier

# Volatile write (ensure completion)
str r0, [r1]          @ Store to memory
dsb                   @ Data Synchronization Barrier

# Critical section with barriers
dmb                   @ Barrier before critical section
ldr r0, [r1]          @ Protected read
add r0, r0, #1
str r0, [r1]          @ Protected write
dmb                   @ Barrier after critical section
```

**Memory Barrier Types:**

```assembly
dmb                   @ Data Memory Barrier (full system)
dmb sy                @ System-wide
dmb ish               @ Inner Shareable domain
dmb osh               @ Outer Shareable domain
dmb nsh               @ Non-shareable domain

dsb                   @ Data Synchronization Barrier
isb                   @ Instruction Synchronization Barrier
```

### Optimization Considerations

**Cache Line Alignment:**

```assembly
# Align data to cache line boundary (typically 32 or 64 bytes)
.align 6              @ Align to 64-byte boundary
buffer:
    .space 1024

# Access aligned data more efficiently
ldr r0, =buffer       @ Already cache-aligned
ldm r0, {r1-r8}       @ Load 32 bytes (likely single cache line)
```

**Prefetching:**

```assembly
# Hint processor to prefetch data
pld [r0, #64]         @ Prefetch data at r0 + 64
pldw [r0, #128]       @ Prefetch for write
pli [r0, #32]         @ Prefetch instruction

# Prefetch in loop
mov r1, #1000
loop:
    pld [r0, #64]     @ Prefetch next iteration
    ldr r2, [r0], #4  @ Load current element
    # Process r2
    subs r1, r1, #1
    bne loop
```

**Burst Access Optimization:**

```assembly
# Sequential loads are more efficient
ldm r0!, {r1-r8}      @ 8 loads in one instruction
                      @ More efficient than individual loads

# Compare with individual loads
ldr r1, [r0], #4      @ Less efficient
ldr r2, [r0], #4
ldr r3, [r0], #4
ldr r4, [r0], #4
ldr r5, [r0], #4
ldr r6, [r0], #4
ldr r7, [r0], #4
ldr r8, [r0], #4
```

### Write-Combining and Write Buffers

**Write Buffer Behavior:**

```assembly
# Sequential writes may be combined
str r1, [r0, #0]      @ Write 1
str r2, [r0, #4]      @ Write 2
str r3, [r0, #8]      @ Write 3
str r4, [r0, #12]     @ Write 4
# Processor may combine these into burst write

# Ensure writes complete
dsb                   @ Wait for write buffer to drain

# Memory-mapped I/O requires ordering
ldr r0, =PERIPHERAL_BASE
str r1, [r0, #REG1]   @ Write register 1
dsb                   @ Ensure write completes
str r2, [r0, #REG2]   @ Write register 2
```

### Exclusive Access for Synchronization

**Load-Exclusive and Store-Exclusive:**

```assembly
# Atomic increment using exclusive access
ldrex r1, [r0]        @ Load exclusive
add r1, r1, #1        @ Increment
strex r2, r1, [r0]    @ Store exclusive, r2 = success flag
cmp r2, #0            @ Check if store succeeded
bne .-12              @ Retry if failed

# Clear exclusive monitor
clrex                 @ Clear exclusive access state
```

**Semaphore Implementation:**

```assembly
# Acquire semaphore
acquire_semaphore:
    mov r1, #1
retry_acquire:
    ldrex r2, [r0]        @ Load semaphore value
    cmp r2, #0            @ Check if available
    itt ne                @ If-Then-Then block
    strexne r3, r1, [r0]  @ Try to acquire
    cmpne r3, #0          @ Check success
    bne retry_acquire     @ Retry if failed
    dmb                   @ Memory barrier
    bx lr

# Release semaphore
release_semaphore:
    dmb                   @ Memory barrier before release
    mov r1, #0
    str r1, [r0]          @ Release semaphore
    dsb                   @ Ensure write completes
    sev                   @ Signal event (wake other cores)
    bx lr
```

### Compare and Swap (CAS)

**Atomic Compare-and-Swap:**

```assembly
# bool cas(int *ptr, int old_val, int new_val)
# Returns true if swap succeeded
compare_and_swap:
    # r0 = ptr, r1 = old_val, r2 = new_val
cas_retry:
    ldrex r3, [r0]        @ Load current value
    cmp r3, r1            @ Compare with expected
    bne cas_fail          @ Exit if not equal
    strex r3, r2, [r0]    @ Try to store new value
    cmp r3, #0            @ Check if store succeeded
    bne cas_retry         @ Retry if failed
    dmb                   @ Memory barrier
    mov r0, #1            @ Success
    bx lr

cas_fail:
    clrex                 @ Clear exclusive monitor
    mov r0, #0            @ Failure
    bx lr
```

### Lock-Free Data Structures

**Lock-Free Stack Push:**

```assembly
# struct Node { void *data; struct Node *next; };
# void push(struct Node **head, struct Node *node)
# r0 = head pointer, r1 = new node
lock_free_push:
push_retry:
    ldr r2, [r0]          @ Load current head
    str r2, [r1, #4]      @ node->next = current head
    dmb                   @ Memory barrier
    ldrex r3, [r0]        @ Load-exclusive head
    cmp r3, r2            @ Check if head changed
    bne push_retry        @ Retry if changed
    strex r3, r1, [r0]    @ Try to update head
    cmp r3, #0
    bne push_retry        @ Retry if failed
    dmb
    bx lr
```

**Lock-Free Stack Pop:**

```assembly
# struct Node *pop(struct Node **head)
# r0 = head pointer, returns node in r0
lock_free_pop:
pop_retry:
    ldrex r1, [r0]        @ Load-exclusive head
    cmp r1, #0            @ Check if empty
    beq pop_empty         @ Return NULL if empty
    ldr r2, [r1, #4]      @ Load next pointer
    strex r3, r2, [r0]    @ Try to update head
    cmp r3, #0
    bne pop_retry         @ Retry if failed
    dmb
    mov r0, r1            @ Return popped node
    bx lr

pop_empty:
    clrex
    mov r0, #0            @ Return NULL
    bx lr
```

### Memory Region Attributes

**Memory Type Configuration:**

```assembly
# Cortex-M Memory Protection Unit (MPU) configuration
.equ MPU_BASE,  0xE000ED90
.equ MPU_TYPE,  0x00      @ Type register
.equ MPU_CTRL,  0x04      @ Control register
.equ MPU_RNR,   0x08      @ Region number register
.equ MPU_RBAR,  0x0C      @ Region base address
.equ MPU_RASR,  0x10      @ Region attribute and size

configure_mpu_region:
    # r0 = region number, r1 = base address, r2 = attributes
    ldr r3, =MPU_BASE
    str r0, [r3, #MPU_RNR]    @ Select region
    str r1, [r3, #MPU_RBAR]   @ Set base address
    str r2, [r3, #MPU_RASR]   @ Set attributes
    bx lr

# Memory attributes
.equ TEX_NORMAL,    0x01  @ Normal memory
.equ TEX_DEVICE,    0x02  @ Device memory
.equ CACHEABLE,     0x08  @ Cacheable
.equ BUFFERABLE,    0x04  @ Bufferable
.equ SHAREABLE,     0x10  @ Shareable
```

### Advanced Addressing Examples

**Circular Buffer Implementation:**

```assembly
# Circular buffer with wrapping
# r0 = buffer base, r1 = buffer size, r2 = index
circular_buffer_access:
    # Calculate wrapped index
    udiv r3, r2, r1       @ r3 = index / size
    mls r4, r3, r1, r2    @ r4 = index % size (modulo)
    
    # Access element
    ldr r5, [r0, r4, LSL #2]  @ Load buffer[wrapped_index]
    bx lr

# Optimized version for power-of-2 sizes
circular_buffer_opt:
    # r1 = size (must be power of 2)
    sub r3, r1, #1        @ Create mask (size - 1)
    and r4, r2, r3        @ index & mask = wrapped index
    ldr r5, [r0, r4, LSL #2]
    bx lr
```

**Bit Array Access:**

```assembly
# Set bit in bit array
# r0 = bit array base, r1 = bit index
set_bit:
    lsr r2, r1, #5        @ Word index = bit_index / 32
    and r3, r1, #31       @ Bit position = bit_index % 32
    mov r4, #1
    lsl r4, r4, r3        @ Create bit mask
    ldr r5, [r0, r2, LSL #2]  @ Load word
    orr r5, r5, r4        @ Set bit
    str r5, [r0, r2, LSL #2]  @ Store back
    bx lr

# Clear bit in bit array
clear_bit:
    lsr r2, r1, #5
    and r3, r1, #31
    mov r4, #1
    lsl r4, r4, r3
    mvn r4, r4            @ Invert mask
    ldr r5, [r0, r2, LSL #2]
    and r5, r5, r4        @ Clear bit
    str r5, [r0, r2, LSL #2]
    bx lr

# Test bit in bit array
test_bit:
    lsr r2, r1, #5
    and r3, r1, #31
    ldr r4, [r0, r2, LSL #2]
    lsr r4, r4, r3
    and r0, r4, #1        @ Return bit value
    bx lr
```

**Hash Table Access:**

```assembly
# Simple hash table lookup
# r0 = hash table base, r1 = key, r2 = table size
hash_table_lookup:
    # Calculate hash (simple modulo)
    udiv r3, r1, r2
    mls r3, r3, r2, r1    @ hash = key % size
    
    # Each entry is 8 bytes (key + value)
    lsl r3, r3, #3        @ Multiply by 8
    
    # Load key and value
    ldr r4, [r0, r3]      @ Load key
    cmp r4, r1            @ Compare with search key
    bne hash_miss
    
    ldr r0, [r0, r3, #4]  @ Load value
    bx lr

hash_miss:
    mov r0, #0            @ Return 0 for miss
    bx lr
```

**Sparse Matrix Access (COO format):**

```assembly
# Coordinate (COO) sparse matrix format
# struct Entry { int row; int col; int value; };
# r0 = entries array, r1 = num_entries, r2 = target_row, r3 = target_col
sparse_matrix_lookup:
    mov r4, #0            @ Index counter
    mov r12, #12          @ Entry size (3 words)

search_loop:
    cmp r4, r1            @ Check if done
    bge not_found
    
    mul r5, r4, r12       @ Calculate offset
    ldr r6, [r0, r5]      @ Load row
    cmp r6, r2            @ Compare row
    bne next_entry
    
    add r5, r5, #4
    ldr r6, [r0, r5]      @ Load column
    cmp r6, r3            @ Compare column
    bne next_entry
    
    add r5, r5, #4
    ldr r0, [r0, r5]      @ Load value
    bx lr                 @ Found

next_entry:
    add r4, r4, #1
    b search_loop

not_found:
    mov r0, #0            @ Return 0 for not found
    bx lr
```

### String Operations with Addressing Modes

**String Length (strlen):**

```assembly
# size_t strlen(const char *str)
# r0 = string pointer
strlen:
    mov r1, r0            @ Save start address
    
strlen_loop:
    ldrb r2, [r0], #1     @ Load byte, post-increment
    cmp r2, #0            @ Check for null terminator
    bne strlen_loop
    
    sub r0, r0, r1        @ Calculate length
    sub r0, r0, #1        @ Adjust for extra increment
    bx lr
```

**String Copy (strcpy):**

```assembly
# char *strcpy(char *dest, const char *src)
# r0 = dest, r1 = src
strcpy:
    push {r4, lr}
    mov r4, r0            @ Save dest for return

strcpy_loop:
    ldrb r2, [r1], #1     @ Load from src, post-increment
    strb r2, [r0], #1     @ Store to dest, post-increment
    cmp r2, #0            @ Check for null
    bne strcpy_loop
    
    mov r0, r4            @ Return original dest
    pop {r4, pc}
```

**String Compare (strcmp):**

```assembly
# int strcmp(const char *s1, const char *s2)
# r0 = s1, r1 = s2, returns: <0, 0, >0
strcmp:
strcmp_loop:
    ldrb r2, [r0], #1     @ Load from s1
    ldrb r3, [r1], #1     @ Load from s2
    cmp r2, r3            @ Compare characters
    bne strcmp_diff
    cmp r2, #0            @ Check for end
    bne strcmp_loop
    
    mov r0, #0            @ Strings equal
    bx lr

strcmp_diff:
    sub r0, r2, r3        @ Return difference
    bx lr
```

**Memory Copy (memcpy) - Optimized:**

```assembly
# void *memcpy(void *dest, const void *src, size_t n)
# r0 = dest, r1 = src, r2 = n
memcpy:
    push {r4-r9, lr}
    mov r3, r0            @ Save dest for return
    
    # Copy 32 bytes at a time
    cmp r2, #32
    blt memcpy_small

memcpy_large:
    ldmia r1!, {r4-r9, r12, r14}  @ Load 8 words
    stmia r0!, {r4-r9, r12, r14}  @ Store 8 words
    sub r2, r2, #32
    cmp r2, #32
    bge memcpy_large

memcpy_small:
    cmp r2, #4
    blt memcpy_bytes

memcpy_words:
    ldr r4, [r1], #4      @ Copy word
    str r4, [r0], #4
    sub r2, r2, #4
    cmp r2, #4
    bge memcpy_words

memcpy_bytes:
    cmp r2, #0
    beq memcpy_done

memcpy_byte_loop:
    ldrb r4, [r1], #1     @ Copy byte
    strb r4, [r0], #1
    subs r2, r2, #1
    bne memcpy_byte_loop

memcpy_done:
    mov r0, r3            @ Return original dest
    pop {r4-r9, pc}
```

### SIMD-Style Operations

**Parallel Byte Processing:**

```assembly
# Process 4 bytes in parallel using word operations
# Add constant to each byte (saturating)
parallel_byte_add:
    # r0 = input word (4 bytes), r1 = constant to add
    and r1, r1, #0xFF     @ Ensure constant is single byte
    orr r1, r1, r1, LSL #8
    orr r1, r1, r1, LSL #16   @ Replicate to all 4 bytes
    
    # Saturating add
    uqadd8 r0, r0, r1     @ Parallel saturating add
    bx lr
```

**SIMD Instructions (ARMv7 and later):**

```assembly
# Parallel arithmetic on packed data
usad8 r0, r1, r2      @ Sum of absolute differences (4 bytes)
usada8 r0, r1, r2, r3 @ SAD with accumulate
uhadd8 r0, r1, r2     @ Parallel unsigned halving add
sel r0, r1, r2        @ Select bytes based on GE flags

# Example: Alpha blending of 4 pixels
alpha_blend_4pixels:
    # r0 = src (4 bytes), r1 = dst (4 bytes), r2 = alpha
    uxtb r3, r2           @ Extract alpha
    rsb r4, r3, #256      @ 256 - alpha
    
    # Multiply source by alpha
    mul r5, r0, r3
    lsr r5, r5, #8
    
    # Multiply dest by (256-alpha)
    mul r6, r1, r4
    lsr r6, r6, #8
    
    # Add results
    uqadd8 r0, r5, r6     @ Saturating add
    bx lr
```

**Key Points:**

- ARM's load/store architecture separates memory access from computation, improving pipeline efficiency and predictability
- Addressing modes provide flexible memory access patterns: immediate offsets for structure members, register offsets for arrays, and scaled offsets for efficient indexing
- Pre-indexed addressing updates the base register before access (useful for skipping elements), while post-indexed updates after (useful for sequential processing)
- Write-back addressing modes (indicated by `!`) automatically update base registers, simplifying pointer manipulation in loops
- Exclusive access instructions (LDREX/STREX) enable atomic operations and synchronization primitives without locks
- Memory barriers (DMB, DSB, ISB) ensure proper ordering of memory accesses in multi-core and memory-mapped I/O scenarios
- Optimized memory operations use LDM/STM for burst transfers, which are more efficient than sequential individual loads/stores
- Understanding memory alignment requirements prevents faults and improves performance on different ARM implementations

---

