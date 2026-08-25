## Loops (For, While, Do-While Patterns)


### While Loop

A while loop tests the condition before executing the loop body.

**Pattern:**

```c
// C code
while (condition) {
    // body
}
```

**Assembly Implementation:**

```assembly
# while (i < 10) { sum += i; i++; }
# r0 = i, r1 = sum
    mov r0, #0           @ i = 0
    mov r1, #0           @ sum = 0

while_loop:
    cmp r0, #10          @ Compare i with 10
    bge while_end        @ Exit if i >= 10
    
    add r1, r1, r0       @ sum += i
    add r0, r0, #1       @ i++
    b while_loop         @ Continue loop

while_end:
    # r1 contains final sum
```

**Complex While Loop:**

```assembly
# while (arr[i] != 0 && i < size) { process(arr[i]); i++; }
# r0 = array base, r1 = size, r2 = i
    mov r2, #0           @ i = 0

while_array:
    cmp r2, r1           @ Check i < size
    bge while_array_end
    
    ldr r3, [r0, r2, LSL #2]  @ Load arr[i]
    cmp r3, #0           @ Check arr[i] != 0
    beq while_array_end
    
    push {r0-r2}         @ Save registers
    mov r0, r3           @ Argument for process
    bl process
    pop {r0-r2}          @ Restore registers
    
    add r2, r2, #1       @ i++
    b while_array
    
while_array_end:
```

### Do-While Loop

A do-while loop executes the body at least once before testing the condition.

**Pattern:**

```c
// C code
do {
    // body
} while (condition);
```

**Assembly Implementation:**

```assembly
# do { sum += i; i++; } while (i < 10);
# r0 = i, r1 = sum
    mov r0, #0           @ i = 0
    mov r1, #0           @ sum = 0

do_while_loop:
    add r1, r1, r0       @ sum += i
    add r0, r0, #1       @ i++
    cmp r0, #10          @ Compare i with 10
    blt do_while_loop    @ Continue if i < 10

    # r1 contains final sum
```

**Input Validation Example:**

```assembly
# do { input = read(); } while (input < 0 || input > 100);
# r0 = input
validate_input:
    bl read_input        @ Get input in r0
    cmp r0, #0           @ Check lower bound
    blt validate_input
    cmp r0, #100         @ Check upper bound
    bgt validate_input
    
    # r0 contains valid input
```

### For Loop

A for loop has initialization, condition, and increment sections.

**Pattern:**

```c
// C code
for (init; condition; increment) {
    // body
}
```

**Basic For Loop:**

```assembly
# for (i = 0; i < 10; i++) { sum += i; }
# r0 = i, r1 = sum
    mov r0, #0           @ i = 0 (initialization)
    mov r1, #0           @ sum = 0

for_loop:
    cmp r0, #10          @ condition: i < 10
    bge for_end
    
    add r1, r1, r0       @ body: sum += i
    
    add r0, r0, #1       @ increment: i++
    b for_loop

for_end:
    # r1 contains final sum
```

**Array Iteration:**

```assembly
# for (i = 0; i < n; i++) { result += array[i]; }
# r0 = array base, r1 = n, r2 = i, r3 = result
    mov r2, #0           @ i = 0
    mov r3, #0           @ result = 0

for_array:
    cmp r2, r1           @ i < n
    bge for_array_end
    
    ldr r4, [r0, r2, LSL #2]  @ Load array[i]
    add r3, r3, r4       @ result += array[i]
    
    add r2, r2, #1       @ i++
    b for_array

for_array_end:
    mov r0, r3           @ Return result
```

**Nested For Loop (Matrix):**

```assembly
# for (i = 0; i < rows; i++)
#     for (j = 0; j < cols; j++)
#         sum += matrix[i][j];
# r0 = matrix base, r1 = rows, r2 = cols
# r4 = i, r5 = j, r6 = sum
    push {r4-r7}
    mov r4, #0           @ i = 0
    mov r6, #0           @ sum = 0

outer_loop:
    cmp r4, r1           @ i < rows
    bge nested_end
    
    mov r5, #0           @ j = 0

inner_loop:
    cmp r5, r2           @ j < cols
    bge inner_end
    
    # Calculate offset: (i * cols + j) * 4
    mul r7, r4, r2       @ i * cols
    add r7, r7, r5       @ i * cols + j
    ldr r3, [r0, r7, LSL #2]  @ Load matrix[i][j]
    add r6, r6, r3       @ sum += matrix[i][j]
    
    add r5, r5, #1       @ j++
    b inner_loop

inner_end:
    add r4, r4, #1       @ i++
    b outer_loop

nested_end:
    mov r0, r6           @ Return sum
    pop {r4-r7}
    bx lr
```

**Countdown Loop (More Efficient):**

```assembly
# for (i = n-1; i >= 0; i--) { process(array[i]); }
# Counting down to zero is more efficient
# r0 = array, r1 = n
    mov r2, r1           @ i = n

countdown_loop:
    subs r2, r2, #1      @ i--, set flags
    blt countdown_end    @ Exit if negative
    
    ldr r3, [r0, r2, LSL #2]  @ Load array[i]
    # Process r3
    
    b countdown_loop

countdown_end:
```

**Optimized Loop (Test at End):**

```assembly
# Reduces branches by testing at loop end
# for (i = 0; i < n; i++) { work; }
# r0 = n, r1 = i
    mov r1, #0
    cmp r0, #0           @ Check if n > 0
    ble loop_skip        @ Skip if n <= 0

loop_start:
    # Loop body here
    
    add r1, r1, #1       @ i++
    cmp r1, r0           @ i < n
    blt loop_start       @ Continue if less

loop_skip:
```

### Loop Unrolling

Unrolling reduces loop overhead by processing multiple iterations per loop.

**Manual Unrolling:**

```assembly
# Unrolled by factor of 4
# for (i = 0; i < n; i++) { sum += array[i]; }
# r0 = array, r1 = n, r2 = sum
    mov r2, #0           @ sum = 0
    mov r3, #0           @ i = 0
    
    # Check if at least 4 iterations
    sub r4, r1, #4
    cmp r3, r4
    bgt unroll_remainder

unrolled_loop:
    ldr r5, [r0, r3, LSL #2]      @ array[i]
    ldr r6, [r0, r3, LSL #2]      @ array[i+1]
    ldr r7, [r0, r3, LSL #2]      @ array[i+2]
    ldr r8, [r0, r3, LSL #2]      @ array[i+3]
    
    add r2, r2, r5
    add r2, r2, r6
    add r2, r2, r7
    add r2, r2, r8
    
    add r3, r3, #4       @ i += 4
    cmp r3, r4
    ble unrolled_loop

unroll_remainder:
    cmp r3, r1
    bge unroll_end

remainder_loop:
    ldr r5, [r0, r3, LSL #2]
    add r2, r2, r5
    add r3, r3, #1
    cmp r3, r1
    blt remainder_loop

unroll_end:
    mov r0, r2           @ Return sum
```

### Software Pipelining

Overlapping loop iterations for better instruction scheduling.

**Example:**

```assembly
# Pipelined loop for better performance
# Process array: output[i] = process(input[i])
# r0 = input, r1 = output, r2 = count
    subs r2, r2, #1
    blt pipeline_end
    
    ldr r3, [r0], #4     @ Load first element (prologue)
    
pipeline_loop:
    bl process           @ Process current (r3 -> r3)
    subs r2, r2, #1      @ Decrement counter
    ldr r4, [r0], #4     @ Load next element (overlap)
    str r3, [r1], #4     @ Store result
    mov r3, r4           @ Move next to current
    bge pipeline_loop
    
    bl process           @ Process last element (epilogue)
    str r3, [r1]         @ Store last result

pipeline_end:
```

