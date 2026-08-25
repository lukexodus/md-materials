## Nested Functions and Closures


Some languages and compiler extensions support nested functions or closures that access variables from enclosing scopes. These require special stack frame handling.

**Static chain approach**: A pointer to the enclosing function's stack frame is passed as a hidden parameter (typically in R10 on x86-64).

```asm
outer_function:
    PUSH RBP
    MOV RBP, RSP
    SUB RSP, 32
    MOV [RBP-8], 100   ; Local variable x
    
    ; Call nested function
    MOV R10, RBP       ; Pass pointer to outer frame
    CALL nested_function
    ; ...

nested_function:
    PUSH RBP
    MOV RBP, RSP
    ; Access outer's local variable
    MOV RAX, [R10-8]   ; Load x from outer frame
    ; ...
````

**Display approach**: Maintain an array of frame pointers for all enclosing scopes. Less common on x86-64.

**Trampoline approach**: Generate executable code on the stack or heap to capture context. [Inference] This approach has security implications due to executable stack requirements and is increasingly restricted by modern operating systems with DEP/NX protections.

