## Call Graph Profiling


Building call relationships and inclusive/exclusive time:

```assembly
// Call graph node structure
// Offset 0: Function address
// Offset 4: Call count
// Offset 8: Exclusive time (time in function only)
// Offset 12: Inclusive time (time including callees)
// Offset 16: Parent pointer
// Offset 20: Caller count

// Function entry hook
profile_function_entry:
    PUSH    {R4-R6, LR}
    MOV     R4, LR                  // Save return address (caller)
    
    // Get current function address from return address
    SUB     R5, R4, #4              // Approximate function start
    
    // Find or create call graph node
    LDR     R0, =call_graph_root
    MOV     R1, R5
    BL      find_or_create_node
    MOV     R6, R0                  // Node pointer
    
    // Increment call count
    LDR     R1, [R6, #4]
    ADD     R1, R1, #1
    STR     R1, [R6, #4]
    
    // Record entry timestamp
    BL      read_cycle_count
    STR     R0, [R6, #24]           // Temporary timestamp storage
    
    // Push node onto call stack
    LDR     R0, =profile_call_stack
    LDR     R1, =profile_stack_ptr
    LDR     R2, [R1]
    STR     R6, [R0, R2, LSL #2]
    ADD     R2, R2, #1
    STR     R2, [R1]
    
    POP     {R4-R6, PC}

// Function exit hook
profile_function_exit:
    PUSH    {R4-R6, LR}
    
    // Read exit timestamp
    BL      read_cycle_count
    MOV     R4, R0
    
    // Pop from call stack
    LDR     R0, =profile_stack_ptr
    LDR     R1, [R0]
    SUB     R1, R1, #1
    STR     R1, [R0]
    
    LDR     R0, =profile_call_stack
    LDR     R5, [R0, R1, LSL #2]    // Node pointer
    
    // Calculate elapsed time
    LDR     R6, [R5, #24]           // Entry timestamp
    SUB     R4, R4, R6              // Elapsed cycles
    
    // Update exclusive time (subtract callee time)
    LDR     R0, [R5, #8]
    ADD     R0, R0, R4
    STR     R0, [R5, #8]
    
    // Update inclusive time
    LDR     R0, [R5, #12]
    ADD     R0, R0, R4
    STR     R0, [R5, #12]
    
    // Update parent's exclusive time (subtract this call)
    CMP     R1, #0
    BEQ     no_parent
    SUB     R1, R1, #1
    LDR     R0, =profile_call_stack
    LDR     R6, [R0, R1, LSL #2]    // Parent node
    LDR     R0, [R6, #8]
    SUB     R0, R0, R4
    STR     R0, [R6, #8]
    
no_parent:
    POP     {R4-R6, PC}
```

