## Program Counter and Instruction Pointer


The instruction pointer (IP) register holds the address of the next instruction to execute. On x86 architectures, this register is named:

- IP: 16-bit (8086/8088)
- EIP: 32-bit (80386 and later)
- RIP: 64-bit (x86-64)

Under normal sequential execution, the instruction pointer automatically increments to point to the next instruction after the current one completes. Control flow instructions modify the instruction pointer to change execution order.

**Sequential Execution:**

```asm
mov eax, 1          ; EIP points here, then advances
mov ebx, 2          ; EIP points here next, then advances
mov ecx, 3          ; EIP points here next
```

**Non-Sequential Execution:**

```asm
mov eax, 1
jmp skip            ; EIP changes to address of 'skip'
mov ebx, 2          ; This instruction is skipped
skip:
mov ecx, 3          ; Execution continues here
```

