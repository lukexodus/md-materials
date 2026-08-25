## Unconditional Jumps


Unconditional jumps always transfer control to the target address, regardless of any conditions.

### JMP (Jump)

The JMP instruction unconditionally transfers control to a specified address.

**Syntax:**

```asm
jmp target          ; Jump to label or address
```

**Types of Jumps:**

**Short Jump:** Displacement of -128 to +127 bytes from the current instruction. Uses a signed 8-bit offset.

```asm
jmp short nearby    ; 2 bytes: opcode + 8-bit displacement
```

**Near Jump:** Displacement within the same code segment. Uses a 16-bit or 32-bit offset depending on the mode.

```asm
jmp near target     ; 5 bytes in 32-bit: opcode + 32-bit displacement
```

**Far Jump:** Jump to a different code segment. Includes both segment selector and offset.

```asm
jmp far 0x10:0x400000   ; Jump to segment:offset
```

Most modern programming uses near jumps exclusively, as flat memory models don't require segment changes.

**Direct vs Indirect Jumps:**

**Direct Jump:** Target address is encoded in the instruction.

```asm
jmp label           ; Direct jump to label
jmp 0x401000        ; Direct jump to absolute address
```

**Indirect Jump:** Target address is stored in a register or memory location.

```asm
jmp eax             ; Jump to address in EAX
jmp [table + eax*4] ; Jump to address stored in memory
jmp qword [rax]     ; Jump to 64-bit address at [rax]
```

**Example: Simple Jump:**

```asm
section .text
global _start

_start:
    mov eax, 1
    jmp skip_code
    
    ; This code is never executed
    mov ebx, 999
    int 0x80
    
skip_code:
    mov ebx, 0          ; Execution resumes here
    int 0x80            ; sys_exit
```

**Example: Jump Table (Switch Statement):**

```asm
section .data
    jump_table dd case_0, case_1, case_2, case_3
    
section .text
switch_statement:
    cmp eax, 3          ; Check if index is valid
    ja default_case     ; If above 3, go to default
    
    jmp [jump_table + eax*4]    ; Indirect jump based on index
    
case_0:
    mov ebx, 100
    jmp end_switch
    
case_1:
    mov ebx, 200
    jmp end_switch
    
case_2:
    mov ebx, 300
    jmp end_switch
    
case_3:
    mov ebx, 400
    jmp end_switch
    
default_case:
    mov ebx, 0
    
end_switch:
    ret
```

### CALL and RET (Function Calls)

While technically unconditional jumps, CALL and RET deserve special attention as they manage the call stack.

**CALL Instruction:**

The CALL instruction performs two operations:

1. Pushes the return address (address of next instruction) onto the stack
2. Jumps to the target address

```asm
call function       ; Push EIP, then jump to function
```

**Stack Effect:**

```
Before CALL:
ESP -> [other data]

After CALL:
ESP -> [return address]  ; Address of instruction after CALL
       [other data]
```

**RET Instruction:**

The RET instruction returns from a function by:

1. Popping the return address from the stack
2. Jumping to that address

```asm
ret                 ; Pop return address, jump to it
ret 8               ; Pop return address, clean 8 bytes of parameters
```

**Example:**

```asm
section .text
main:
    push 5
    push 10
    call add_numbers    ; Calls function
    add esp, 8          ; Clean up parameters (cdecl convention)
    
    mov ebx, eax        ; Result in EAX
    mov eax, 1
    int 0x80            ; Exit
    
add_numbers:
    push ebp
    mov ebp, esp        ; Setup stack frame
    
    mov eax, [ebp+8]    ; First parameter
    add eax, [ebp+12]   ; Second parameter
    
    pop ebp
    ret                 ; Return to caller
```

