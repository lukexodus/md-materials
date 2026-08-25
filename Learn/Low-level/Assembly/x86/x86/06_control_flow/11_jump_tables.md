## Jump Tables


Jump tables provide efficient multi-way branching by storing addresses in memory and using computed indices to select the target address. This technique implements switch statements, dispatch tables, and other control structures requiring selection among multiple destinations.

**Basic Jump Table Structure** consists of an array of addresses followed by code that indexes into the array:

```nasm
section .data
    jump_table:
        dq case_0
        dq case_1
        dq case_2
        dq case_3

section .text
    ; Assume RAX contains case number (0-3)
    cmp rax, 3
    ja default_case          ; Jump if above 3
    
    lea rbx, [rel jump_table]
    jmp [rbx + rax*8]        ; Jump to address at jump_table[rax]

case_0:
    ; Handle case 0
    jmp end_switch

case_1:
    ; Handle case 1
    jmp end_switch

case_2:
    ; Handle case 2
    jmp end_switch

case_3:
    ; Handle case 3
    jmp end_switch

default_case:
    ; Handle invalid case

end_switch:
    ; Continue execution
```

The jump table contains quadword pointers (8 bytes each) to code locations. The index multiplies by 8 (the pointer size) to calculate the correct offset. Bounds checking prevents invalid indices from accessing memory outside the table.

**Sparse Jump Tables** handle cases where valid indices are not consecutive:

```nasm
section .data
    ; Map input values to table indices
    value_map:
        dq 10, 0    ; Value 10 maps to index 0
        dq 25, 1    ; Value 25 maps to index 1
        dq 50, 2    ; Value 50 maps to index 2
        dq -1, -1   ; Sentinel
    
    jump_table:
        dq handler_10
        dq handler_25
        dq handler_50

section .text
    ; Search for RAX in value_map
    lea rbx, [rel value_map]
.search_loop:
    mov rcx, [rbx]
    cmp rcx, -1
    je default_handler       ; Not found
    cmp rcx, rax
    je .found
    add rbx, 16              ; Next entry (value + index pair)
    jmp .search_loop

.found:
    mov rcx, [rbx + 8]       ; Get table index
    lea rbx, [rel jump_table]
    jmp [rbx + rcx*8]
```

This approach trades memory efficiency for flexibility when valid cases are sparse. The lookup loop adds overhead compared to direct indexing but remains faster than long chains of comparisons for many cases.

**Computed Goto Pattern** uses jump tables for interpreted language implementations:

```nasm
section .data
    opcode_table:
        dq op_add
        dq op_sub
        dq op_mul
        dq op_div
        dq op_load
        dq op_store

section .text
interpret_loop:
    movzx rax, byte [rsi]    ; Fetch opcode byte
    inc rsi                  ; Advance instruction pointer
    
    lea rbx, [rel opcode_table]
    jmp [rbx + rax*8]        ; Dispatch to handler

op_add:
    ; Execute ADD operation
    jmp interpret_loop

op_sub:
    ; Execute SUB operation
    jmp interpret_loop

; Additional handlers...
```

Interpreters and virtual machines use this pattern to dispatch operations based on bytecode or instruction encoding. Each handler processes one operation then jumps back to the interpretation loop.

**Performance Characteristics** of jump tables depend on several factors. Direct indexing into a jump table requires 3-5 cycles including bounds check, table lookup, and indirect jump. Branch prediction may struggle with indirect jumps since the target varies based on data. [Inference] Modern CPUs use indirect branch predictors that track patterns in jump table usage, potentially improving performance for predictable access patterns. Jump tables eliminate chains of conditional branches, providing consistent performance regardless of which case executes.

**Comparison with If-Else Chains** shows when jump tables are beneficial:

```nasm
; If-else chain approach
    cmp rax, 0
    je case_0
    cmp rax, 1
    je case_1
    cmp rax, 2
    je case_2
    cmp rax, 3
    je case_3
    jmp default_case
```

Linear if-else chains require average N/2 comparisons for N cases. Jump tables require constant time regardless of case count after bounds checking. Jump tables become advantageous when handling 4 or more cases with dense indices. Sparse cases or fewer alternatives may perform better with conditional branches.

**Position-Independent Jump Tables** use RIP-relative addressing for shared libraries:

```nasm
section .data
    jump_table:
        dq case_0 - jump_table
        dq case_1 - jump_table
        dq case_2 - jump_table

section .text
    lea rbx, [rel jump_table]
    mov rcx, [rbx + rax*8]   ; Load offset
    add rcx, rbx             ; Add base address
    jmp rcx                  ; Jump to computed address
```

Storing offsets rather than absolute addresses allows the code to work at any load address. This technique supports position-independent executables (PIE) and shared libraries.

**Indirect Threading** in interpreters uses addresses instead of returning to a central dispatch loop:

```nasm
section .data
    opcode_table:
        dq op_add
        dq op_sub
        dq op_mul

section .text
op_add:
    ; Perform addition
    movzx rax, byte [rsi]    ; Fetch next opcode
    inc rsi
    lea rbx, [rel opcode_table]
    jmp [rbx + rax*8]        ; Jump directly to next handler

op_sub:
    ; Perform subtraction
    movzx rax, byte [rsi]
    inc rsi
    lea rbx, [rel opcode_table]
    jmp [rbx + rax*8]
```

Each handler fetches the next opcode and jumps directly to its handler, eliminating the return to a central loop. This technique reduces jump overhead in interpreter inner loops.

