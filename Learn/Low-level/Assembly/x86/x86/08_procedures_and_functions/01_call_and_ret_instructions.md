## CALL and RET Instructions


The CALL instruction transfers program control to a procedure by pushing the return address onto the stack and jumping to the target address. The RET instruction returns control to the caller by popping the return address from the stack and jumping to it.

**CALL Instruction Mechanics:**

```assembly
call procedure_name    ; Direct call
call eax              ; Indirect call through register
call [ebx]            ; Indirect call through memory
```

When CALL executes, the CPU performs these operations:

1. Pushes the address of the next instruction (return address) onto the stack
2. Transfers control to the specified address by loading it into EIP/RIP

**RET Instruction Mechanics:**

```assembly
ret          ; Return, pop return address
ret 8        ; Return and clean up 8 bytes from stack
```

The RET instruction:

1. Pops the return address from the stack into EIP/RIP
2. Optionally adds a value to ESP to clean up parameters (used in stdcall)

**Example:**

```assembly
section .text
global _start

_start:
    mov eax, 5
    mov ebx, 10
    call add_numbers    ; Push return address, jump to add_numbers
    ; Execution continues here after return
    mov [result], eax
    
    ; Exit program
    mov eax, 1
    xor ebx, ebx
    int 0x80

add_numbers:
    add eax, ebx        ; eax = eax + ebx
    ret                 ; Pop return address, jump back

section .bss
    result resd 1
```

**Stack State During CALL/RET:**

```
Before CALL:
    ESP -> [previous data]

After CALL (inside procedure):
    ESP -> [return address]
           [previous data]

After RET:
    ESP -> [previous data]  (return address popped)
```

