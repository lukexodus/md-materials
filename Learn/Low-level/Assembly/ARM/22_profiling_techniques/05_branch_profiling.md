## Branch Profiling


Tracking branch taken/not-taken statistics:

```assembly
// Instrumented conditional branch
    CMP     R0, R1
    BEQ     branch_taken
    
    // Branch not taken path
    LDR     R2, =branch_not_taken_count
    LDR     R3, [R2]
    ADD     R3, R3, #1
    STR     R3, [R2]
    B       branch_continue
    
branch_taken:
    // Branch taken path
    LDR     R2, =branch_taken_count
    LDR     R3, [R2]
    ADD     R3, R3, #1
    STR     R3, [R2]
    
branch_continue:
    // Continue execution
```

