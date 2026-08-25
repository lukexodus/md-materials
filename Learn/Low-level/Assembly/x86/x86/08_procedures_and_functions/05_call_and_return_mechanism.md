## Call and Return Mechanism


The `CALL` instruction transfers control to a procedure by pushing the return address (address of the instruction following `CALL`) onto the stack and jumping to the procedure's address. The `RET` instruction pops this return address from the stack and jumps back to continue execution.

**Example:**

```nasm
main:
    call my_procedure    ; Push return address, jump to my_procedure
    ; execution continues here after my_procedure returns
    mov eax, 5
    
my_procedure:
    ; procedure code here
    ret                  ; Pop return address, return to caller
```

