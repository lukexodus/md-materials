## Structured Programming in Assembly


Structured programming principles applied to assembly language improve code readability, maintainability, and correctness by organizing control flow into recognizable patterns from high-level languages.

**If-Then-Else Structures** implement conditional execution using comparisons and conditional jumps:

```nasm
    ; if (rax > rbx) {
    ;     // then block
    ; } else {
    ;     // else block
    ; }
    
    cmp rax, rbx
    jle .else_block          ; Jump if less or equal
    
.then_block:
    ; Execute when rax > rbx
    ; ...
    jmp .end_if

.else_block:
    ; Execute when rax <= rbx
    ; ...

.end_if:
    ; Continue after if-else
```

The comparison sets flags in the RFLAGS register. Conditional jumps test these flags to determine whether to take the branch. Inverting the condition (using JLE instead of JG) allows falling through to the then block and jumping around it for the else case.

**Nested If Structures** require careful label management:

```nasm
    ; if (rax > 0) {
    ;     if (rbx > 0) {
    ;         // both positive
    ;     } else {
    ;         // rax positive, rbx not
    ;     }
    ; } else {
    ;     // rax not positive
    ; }
    
    cmp rax, 0
    jle .outer_else
    
    ; Outer then block
    cmp rbx, 0
    jle .inner_else
    
    ; Both positive
    ; ...
    jmp .inner_end
    
.inner_else:
    ; rax positive, rbx not
    ; ...
    
.inner_end:
    jmp .outer_end

.outer_else:
    ; rax not positive
    ; ...

.outer_end:
    ; Continue
```

Unique label names for each level prevent confusion. Prefixing labels with the structure level (outer_, inner_) aids readability.

**While Loops** test the condition before each iteration:

```nasm
    ; while (rax < 100) {
    ;     // loop body
    ;     rax++;
    ; }
    
.while_start:
    cmp rax, 100
    jge .while_end           ; Exit if rax >= 100
    
    ; Loop body
    ; ...
    inc rax
    
    jmp .while_start

.while_end:
    ; Continue after loop
```

The condition check at the loop start ensures the body executes zero or more times. The unconditional jump returns to the condition test after each iteration.

**Do-While Loops** execute the body at least once:

```nasm
    ; do {
    ;     // loop body
    ;     rax++;
    ; } while (rax < 100);
    
.do_while_start:
    ; Loop body
    ; ...
    inc rax
    
    cmp rax, 100
    jl .do_while_start       ; Continue if rax < 100
    
    ; Continue after loop
```

Testing the condition at the end guarantees one execution before checking whether to repeat.

**For Loop Pattern** combines initialization, condition, and increment:

```nasm
    ; for (i = 0; i < 10; i++) {
    ;     // loop body
    ; }
    
    xor rcx, rcx             ; i = 0 (initialization)

.for_loop:
    cmp rcx, 10              ; Check i < 10
    jge .for_end
    
    ; Loop body
    ; ...
    
    inc rcx                  ; i++
    jmp .for_loop

.for_end:
    ; Continue after loop
```

The initialization precedes the loop. The condition test happens at the loop start. The increment occurs at the loop end before jumping back.

**Break and Continue Equivalents** use jumps to specific labels:

```nasm
    ; while (rax < 100) {
    ;     if (rax == 50) break;
    ;     if (rax % 2 == 0) continue;
    ;     // process odd numbers
    ; }
    
.while_start:
    cmp rax, 100
    jge .while_end
    
    cmp rax, 50              ; Check for break condition
    je .while_end            ; Break - jump to loop end
    
    test rax, 1              ; Check if even
    jz .continue             ; Continue - skip to increment
    
    ; Process odd numbers
    ; ...

.continue:
    inc rax
    jmp .while_start

.while_end:
```

Break jumps to the label immediately after the loop. Continue jumps to the loop's increment/continuation point.

**Function Calls as Control Flow** structure programs into reusable units:

```nasm
    ; Call a function
    mov rdi, arg1            ; First argument
    mov rsi, arg2            ; Second argument
    call my_function
    ; Return value in RAX

my_function:
    push rbp
    mov rbp, rsp
    
    ; Function body
    ; Access parameters via RDI, RSI
    ; Set return value in RAX
    
    mov rsp, rbp
    pop rbp
    ret
```

The CALL instruction pushes the return address and jumps to the function. RET pops the return address and jumps to it. Parameters pass in registers following the calling convention. Return values typically use RAX.

**Switch Statement Implementation** combines range checking with jump tables or comparison chains:

```nasm
    ; switch (rax) {
    ;     case 0: ...; break;
    ;     case 1: ...; break;
    ;     case 2: ...; break;
    ;     default: ...;
    ; }
    
    cmp rax, 2
    ja .default_case         ; Jump if above 2
    
    lea rbx, [rel jump_table]
    jmp [rbx + rax*8]

.case_0:
    ; Handle case 0
    jmp .switch_end

.case_1:
    ; Handle case 1
    jmp .switch_end

.case_2:
    ; Handle case 2
    jmp .switch_end

.default_case:
    ; Handle default

.switch_end:
```

Fall-through cases omit the jump to switch_end, allowing execution to continue into the next case label.

**Guard Clauses and Early Returns** simplify function logic:

```nasm
my_function:
    push rbp
    mov rbp, rsp
    
    ; Guard: if (rdi == 0) return -1
    test rdi, rdi
    jnz .continue
    mov rax, -1
    mov rsp, rbp
    pop rbp
    ret
    
.continue:
    ; Main function logic
    ; ...
    
    mov rsp, rbp
    pop rbp
    ret
```

Early returns handle special cases immediately, reducing nesting in the main logic path. Each early return includes proper function epilogue code.

**Macro-Based Control Structures** in some assemblers provide high-level syntax:

```nasm
%macro IF 1
    cmp %1
    je %%if_true
    jmp %%if_false
%%if_true:
%endmacro

%macro ENDIF 0
%%if_false:
%endmacro

    IF rax, rbx              ; Usage
        ; Then block
    ENDIF
```

Macros expand to standard assembly instructions but provide more readable source code. The `%%` prefix creates local labels unique to each macro expansion.

