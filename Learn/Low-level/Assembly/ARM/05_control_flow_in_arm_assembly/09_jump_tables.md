## Jump Tables


Jump tables provide efficient multi-way branching using computed addresses.

### Basic Jump Table

**Implementation:**

```assembly
# Dispatch based on command index
# r0 = command (0-4)
command_dispatcher:
    cmp r0, #4
    movhi r0, #-1
    bxhi lr              @ Invalid command
    
    adr r1, command_table
    ldr pc, [r1, r0, LSL #2]

    .align 2
command_table:
    .word cmd_start
    .word cmd_stop
    .word cmd_pause
    .word cmd_resume
    .word cmd_reset

cmd_start:
    # Start command implementation
    mov r0, #0
    bx lr

cmd_stop:
    # Stop command implementation
    mov r0, #0
    bx lr

cmd_pause:
    # Pause command implementation
    mov r0, #0
    bx lr

cmd_resume:
    # Resume command implementation
    mov r0, #0
    bx lr

cmd_reset:
    # Reset command implementation
    mov r0, #0
    bx lr
```

### Position-Independent Jump Table

For position-independent code, use offsets instead of absolute addresses.

**Implementation:**

```assembly
# Position-independent jump table
dispatch_pic:
    cmp r0, #4
    bhi dispatch_invalid
    
    adr r1, offset_table
    ldr r2, [r1, r0, LSL #2]  @ Load offset
    add pc, r1, r2            @ PC = table_base + offset

    .align 2
offset_table:
    .word (handler_0 - offset_table)
    .word (handler_1 - offset_table)
    .word (handler_2 - offset_table)
    .word (handler_3 - offset_table)
    .word (handler_4 - offset_table)

handler_0:
    mov r0, #100
    bx lr

handler_1:
    mov r0, #101
    bx lr

handler_2:
    mov r0, #102
    bx lr

handler_3:
    mov r0, #103
    bx lr

handler_4:
    mov r0, #104
    bx lr

dispatch_invalid:
    mov r0, #-1
    bx lr
```

### Computed Goto (State Machine)

Jump tables are ideal for implementing state machines.

**State Machine Example:**

```assembly
# Simple state machine with 4 states
# r4 = current state, r5 = input, r6 = output
# States: 0=IDLE, 1=RUNNING, 2=PAUSED, 3=ERROR

state_machine_loop:
    cmp r4, #3
    bhi state_error
    
    # Dispatch to current state handler
    adr r0, state_table
    ldr pc, [r0, r4, LSL #2]

    .align 2
state_table:
    .word state_idle
    .word state_running
    .word state_paused
    .word state_error

state_idle:
    # Check input for start command
    cmp r5, #1           @ Start command?
    moveq r4, #1         @ Transition to RUNNING
    beq state_machine_loop
    
    # Stay in IDLE
    b state_machine_loop

state_running:
    # Check for pause or stop
    cmp r5, #2           @ Pause command?
    moveq r4, #2         @ Transition to PAUSED
    beq state_machine_loop
    
    cmp r5, #3           @ Stop command?
    moveq r4, #0         @ Transition to IDLE
    beq state_machine_loop
    
    # Process work
    add r6, r6, #1       @ Increment output
    b state_machine_loop

state_paused:
    # Check for resume or stop
    cmp r5, #4           @ Resume command?
    moveq r4, #1         @ Transition to RUNNING
    beq state_machine_loop
    
    cmp r5, #3           @ Stop command?
    moveq r4, #0         @ Transition to IDLE
    beq state_machine_loop
    
    # Stay paused
    b state_machine_loop

state_error:
    # Error handling
    mov r6, #-1          @ Set error output
    mov r4, #0           @ Reset to IDLE
    bx lr                @ Exit state machine
```

### Virtual Function Table (vtable)

Implementing C++ virtual functions using jump tables.

**Class Structure:**

```assembly
# struct Animal {
#     vtable_ptr;
#     int age;
# };
# 
# vtable = { speak, move, eat };

    .data
    .align 2
# Dog vtable
dog_vtable:
    .word dog_speak
    .word dog_move
    .word dog_eat

# Cat vtable
cat_vtable:
    .word cat_speak
    .word cat_move
    .word cat_eat

    .text
# Create dog object
# Returns pointer in r0
create_dog:
    push {r4, lr}
    
    mov r0, #8           @ Size: vtable_ptr + age
    bl malloc            @ Allocate memory
    
    mov r4, r0           @ Save object pointer
    ldr r1, =dog_vtable
    str r1, [r4]         @ Set vtable pointer
    mov r1, #0
    str r1, [r4, #4]     @ Initialize age = 0
    
    mov r0, r4
    pop {r4, pc}

# Call virtual function
# r0 = object pointer, r1 = method index (0=speak, 1=move, 2=eat)
call_virtual:
    push {r4, lr}
    
    mov r4, r0           @ Save object pointer
    ldr r2, [r0]         @ Load vtable pointer
    ldr r3, [r2, r1, LSL #2]  @ Load method address
    
    mov r0, r4           @ Pass object as 'this'
    blx r3               @ Call virtual method
    
    pop {r4, pc}

# Virtual function implementations
dog_speak:
    # this pointer in r0
    push {lr}
    ldr r0, =dog_bark_msg
    bl printf
    pop {pc}

dog_move:
    push {lr}
    ldr r0, =dog_walk_msg
    bl printf
    pop {pc}

dog_eat:
    push {lr}
    ldr r0, =dog_eat_msg
    bl printf
    pop {pc}

cat_speak:
    push {lr}
    ldr r0, =cat_meow_msg
    bl printf
    pop {pc}

cat_move:
    push {lr}
    ldr r0, =cat_walk_msg
    bl printf
    pop {pc}

cat_eat:
    push {lr}
    ldr r0, =cat_eat_msg
    bl printf
    pop {pc}

    .section .rodata
dog_bark_msg: .asciz "Woof!\n"
dog_walk_msg: .asciz "Dog walks\n"
dog_eat_msg:  .asciz "Dog eats\n"
cat_meow_msg: .asciz "Meow!\n"
cat_walk_msg: .asciz "Cat walks\n"
cat_eat_msg:  .asciz "Cat eats\n"
```

### Interrupt Vector Table

Jump tables are fundamental to interrupt handling.

**Vector Table Example:**

```assembly
# Cortex-M vector table
    .section .isr_vector, "a"
    .align 2
    .global vector_table

vector_table:
    .word _estack            @ 0: Initial stack pointer
    .word Reset_Handler      @ 1: Reset
    .word NMI_Handler        @ 2: Non-maskable interrupt
    .word HardFault_Handler  @ 3: Hard fault
    .word MemManage_Handler  @ 4: Memory management
    .word BusFault_Handler   @ 5: Bus fault
    .word UsageFault_Handler @ 6: Usage fault
    .word 0                  @ 7: Reserved
    .word 0                  @ 8: Reserved
    .word 0                  @ 9: Reserved
    .word 0                  @ 10: Reserved
    .word SVC_Handler        @ 11: Supervisor call
    .word DebugMon_Handler   @ 12: Debug monitor
    .word 0                  @ 13: Reserved
    .word PendSV_Handler     @ 14: Pendable service
    .word SysTick_Handler    @ 15: System tick timer
    .word EXTI0_Handler      @ 16: External interrupt 0
    .word EXTI1_Handler      @ 17: External interrupt 1
    # ... more interrupt handlers ...

    .text
    .thumb
    .thumb_func
Reset_Handler:
    # Initialize data section
    ldr r0, =_sdata
    ldr r1, =_edata
    ldr r2, =_sidata
    
copy_data:
    cmp r0, r1
    bge copy_data_done
    ldr r3, [r2], #4
    str r3, [r0], #4
    b copy_data

copy_data_done:
    # Zero BSS section
    ldr r0, =_sbss
    ldr r1, =_ebss
    mov r2, #0

zero_bss:
    cmp r0, r1
    bge zero_bss_done
    str r2, [r0], #4
    b zero_bss

zero_bss_done:
    # Call main
    bl main
    
    # Infinite loop if main returns
infinite_loop:
    b infinite_loop

    .weak NMI_Handler
    .thumb_set NMI_Handler, Default_Handler

    .weak HardFault_Handler
    .thumb_set HardFault_Handler, Default_Handler

Default_Handler:
    b Default_Handler
```

### Callback Registration System

Using function pointers for event-driven programming.

**Implementation:**

```assembly
# Event callback system
# Max 8 callbacks
    .data
    .align 2
callback_table:
    .space 32            @ 8 function pointers

callback_count:
    .word 0

    .text
# Register callback
# r0 = function pointer
register_callback:
    push {r4, r5, lr}
    
    ldr r4, =callback_count
    ldr r5, [r4]         @ Current count
    
    cmp r5, #8           @ Check if table full
    movge r0, #-1
    bge register_done
    
    ldr r1, =callback_table
    str r0, [r1, r5, LSL #2]  @ Store callback
    
    add r5, r5, #1       @ Increment count
    str r5, [r4]
    
    mov r0, #0           @ Success

register_done:
    pop {r4, r5, pc}

# Trigger all callbacks
# r0 = event data
trigger_callbacks:
    push {r4-r6, lr}
    
    mov r4, r0           @ Save event data
    ldr r5, =callback_table
    ldr r6, =callback_count
    ldr r6, [r6]         @ Load count
    
    mov r0, #0           @ Index

trigger_loop:
    cmp r0, r6
    bge trigger_done
    
    push {r0}            @ Save index
    ldr r1, [r5, r0, LSL #2]  @ Load callback address
    mov r0, r4           @ Pass event data
    blx r1               @ Call callback
    pop {r0}             @ Restore index
    
    add r0, r0, #1
    b trigger_loop

trigger_done:
    pop {r4-r6, pc}

# Example callbacks
callback_logger:
    push {lr}
    # Log event (r0 = event data)
    ldr r1, =log_msg
    bl printf
    pop {pc}

callback_counter:
    push {r4, lr}
    ldr r4, =event_counter
    ldr r1, [r4]
    add r1, r1, #1
    str r1, [r4]
    pop {r4, pc}

    .data
event_counter:
    .word 0

    .section .rodata
log_msg: .asciz "Event: %d\n"
```

### Dynamic Dispatch (Interpreter Pattern)

Interpreting bytecode using jump tables.

**Bytecode Interpreter:**

```assembly
# Simple stack-based VM
# Opcodes: 0=PUSH, 1=POP, 2=ADD, 3=SUB, 4=MUL, 5=HALT

    .data
    .align 2
vm_stack:
    .space 256           @ 64-element stack
vm_sp:
    .word vm_stack       @ Stack pointer

    .text
# Execute bytecode program
# r0 = bytecode array, r1 = length
vm_execute:
    push {r4-r7, lr}
    
    mov r4, r0           @ Bytecode pointer
    add r5, r0, r1       @ End of bytecode
    ldr r6, =vm_stack    @ Stack base
    mov r7, r6           @ Stack pointer

vm_fetch:
    cmp r4, r5           @ Check if done
    bge vm_halt
    
    ldrb r0, [r4], #1    @ Fetch opcode
    
    cmp r0, #5           @ Range check
    bhi vm_invalid_opcode
    
    adr r1, opcode_table
    ldr pc, [r1, r0, LSL #2]  @ Dispatch

    .align 2
opcode_table:
    .word op_push
    .word op_pop
    .word op_add
    .word op_sub
    .word op_mul
    .word op_halt

op_push:
    # PUSH immediate value (next byte)
    ldrb r0, [r4], #1    @ Fetch value
    str r0, [r7], #4     @ Push to stack
    b vm_fetch

op_pop:
    # POP (discard top)
    sub r7, r7, #4       @ Pop from stack
    b vm_fetch

op_add:
    # ADD: pop two values, push sum
    sub r7, r7, #4
    ldr r1, [r7]         @ Second operand
    sub r7, r7, #4
    ldr r0, [r7]         @ First operand
    add r0, r0, r1       @ Add
    str r0, [r7], #4     @ Push result
    b vm_fetch

op_sub:
    # SUB: pop two values, push difference
    sub r7, r7, #4
    ldr r1, [r7]         @ Second operand
    sub r7, r7, #4
    ldr r0, [r7]         @ First operand
    sub r0, r0, r1       @ Subtract
    str r0, [r7], #4     @ Push result
    b vm_fetch

op_mul:
    # MUL: pop two values, push product
    sub r7, r7, #4
    ldr r1, [r7]         @ Second operand
    sub r7, r7, #4
    ldr r0, [r7]         @ First operand
    mul r0, r0, r1       @ Multiply
    str r0, [r7], #4     @ Push result
    b vm_fetch

op_halt:
    # HALT: return top of stack
    sub r7, r7, #4
    ldr r0, [r7]         @ Get result
    b vm_done

vm_invalid_opcode:
    mov r0, #-1

vm_halt:
vm_done:
    pop {r4-r7, pc}
```

### Threaded Code Interpreter

More efficient interpreter using indirect threading.

**Direct Threaded Code:**

```assembly
# Direct threaded interpreter
# Each instruction contains address of next instruction

    .text
# Execute threaded code
# r0 = pointer to first instruction cell
execute_threaded:
    push {r4, lr}
    
    ldr r4, =data_stack
    mov r5, r4           @ Stack pointer
    
    ldr pc, [r0]         @ Jump to first instruction

# Threading primitives
next:
    .macro NEXT
    ldr r0, [r0], #4     @ Fetch next instruction address
    ldr pc, [r0]         @ Jump to it
    .endm

# Example instructions
t_push:
    ldr r1, [r0], #4     @ Fetch immediate value
    str r1, [r5], #4     @ Push to stack
    NEXT

t_add:
    sub r5, r5, #4
    ldr r2, [r5]         @ Pop second operand
    sub r5, r5, #4
    ldr r1, [r5]         @ Pop first operand
    add r1, r1, r2       @ Add
    str r1, [r5], #4     @ Push result
    NEXT

t_dup:
    ldr r1, [r5, #-4]    @ Get top
    str r1, [r5], #4     @ Push copy
    NEXT

t_halt:
    pop {r4, pc}

    .data
data_stack:
    .space 256

# Example program: 5 3 + (should give 8)
program:
    .word t_push
    .word 5
    .word t_push
    .word 3
    .word t_add
    .word t_halt
```

### Coroutine Switching

Jump tables for cooperative multitasking.

**Simple Coroutine System:**

```assembly
# Coroutine context structure:
# offset 0: SP
# offset 4: PC
# offset 8: r4-r11 (8 registers)

    .data
    .align 2
coroutine1_ctx:
    .space 40            @ Context size

coroutine2_ctx:
    .space 40

current_coroutine:
    .word coroutine1_ctx

    .text
# Yield to another coroutine
# r0 = next coroutine context
yield:
    # Save current context
    ldr r1, =current_coroutine
    ldr r2, [r1]         @ Current context
    
    # Save registers
    str sp, [r2, #0]     @ Save SP
    str lr, [r2, #4]     @ Save PC (return address)
    add r3, r2, #8
    stm r3, {r4-r11}     @ Save r4-r11
    
    # Switch to new coroutine
    str r0, [r1]         @ Update current
    
    # Restore new context
    ldr sp, [r0, #0]     @ Restore SP
    ldr lr, [r0, #4]     @ Restore PC
    add r3, r0, #8
    ldm r3, {r4-r11}     @ Restore r4-r11
    
    bx lr                @ Resume execution

# Initialize coroutine
# r0 = context, r1 = function, r2 = stack
init_coroutine:
    str r2, [r0, #0]     @ Set SP
    str r1, [r0, #4]     @ Set PC
    bx lr

# Example coroutine 1
coroutine1:
    mov r4, #0           @ Counter

coro1_loop:
    # Do work
    add r4, r4, #1
    
    # Yield to coroutine 2
    ldr r0, =coroutine2_ctx
    bl yield
    
    # Resumed
    cmp r4, #10
    blt coro1_loop
    
    # Done
    b coro1_loop

# Example coroutine 2
coroutine2:
    mov r4, #100

coro2_loop:
    # Do work
    sub r4, r4, #1
    
    # Yield to coroutine 1
    ldr r0, =coroutine1_ctx
    bl yield
    
    # Resumed
    cmp r4, #0
    bgt coro2_loop
    
    b coro2_loop
```

**Key Points:**

- Conditional branches test CPSR flags set by comparison or arithmetic operations; IT blocks enable conditional execution in Thumb mode
- Loop patterns (while, do-while, for) translate naturally to assembly using conditional branches, with countdown loops often more efficient
- Switch statements use binary search for sparse cases, jump tables for dense cases, and hybrid approaches for non-contiguous groups
- AAPCS defines r0-r3 for arguments and return values, r4-r11 as callee-saved, and requires functions to preserve registers they modify
- Non-leaf functions must save LR before calling other functions; tail call optimization eliminates unnecessary stack operations
- Jump tables enable O(1) dispatch for multi-way branches, essential for state machines, virtual functions, and interpreters
- Position-independent jump tables use offsets instead of absolute addresses for relocatable code
- Threaded code interpreters improve performance by eliminating the fetch-decode loop through direct jumps between instruction handlers

---

