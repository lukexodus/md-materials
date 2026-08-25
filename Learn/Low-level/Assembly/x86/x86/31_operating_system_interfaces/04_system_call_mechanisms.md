## System Call Mechanisms


### x86 32-bit (i386) System Calls

**Interrupt-based (Legacy)**:

The traditional method uses `int 0x80` to trigger a software interrupt that transfers control to the kernel:

```asm
mov eax, 1          ; syscall number (sys_exit)
mov ebx, 0          ; exit code
int 0x80            ; invoke system call
```

Parameters are passed in registers:

- `eax`: System call number
- `ebx`: First argument
- `ecx`: Second argument
- `edx`: Third argument
- `esi`: Fourth argument
- `edi`: Fifth argument
- `ebp`: Sixth argument

Return value appears in `eax`, with negative values indicating errors (negated errno).

**SYSENTER/SYSEXIT (Fast System Calls)**:

Intel introduced `sysenter` and `sysexit` for lower-overhead system calls:

```asm
mov eax, syscall_number
mov ebx, arg1
mov ecx, return_address
mov edx, stack_pointer
sysenter
```

**Key Points:**

- `sysenter` transitions to ring 0 with minimal overhead
- Requires kernel support and proper MSR configuration
- `sysexit` returns to ring 3
- Register conventions may differ from `int 0x80`

### x86-64 (x64) System Calls

**SYSCALL/SYSRET**:

The `syscall` instruction is the standard mechanism on x86-64:

```asm
mov rax, 1          ; syscall number (sys_write)
mov rdi, 1          ; fd (stdout)
mov rsi, msg        ; buffer
mov rdx, len        ; count
syscall             ; invoke system call
```

x86-64 register conventions:

- `rax`: System call number (also return value)
- `rdi`: First argument
- `rsi`: Second argument
- `rdx`: Third argument
- `r10`: Fourth argument (rcx used by syscall itself)
- `r8`: Fifth argument
- `r9`: Sixth argument

**Key Points:**

- `rcx` and `r11` are clobbered by `syscall` (saved return address and flags)
- Return values in `rax` (negative for errors)
- Faster than interrupt-based calls
- System call numbers differ between 32-bit and 64-bit

