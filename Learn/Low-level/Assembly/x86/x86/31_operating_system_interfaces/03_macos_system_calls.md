## macOS System Calls


macOS (and other BSD-derived systems) use a system call interface similar to Linux but with important differences in numbering, conventions, and available syscalls.

### macOS System Call Mechanisms

**32-bit (x86) syscall interface:**

- Syscall number in EAX
- Arguments on stack (pushed right-to-left)
- Invoke using `int 0x80` instruction
- Syscall number must be biased with class code
- Return value in EAX and EDX
- Carry flag indicates error (CF=1 means error, errno in EAX)

**64-bit (x86-64) syscall interface:**

- Syscall number in RAX (with class code in upper bits)
- Arguments in RDI, RSI, RDX, RCX, R8, R9 (up to 6 arguments)
- Seventh argument and beyond on stack
- Invoke using `syscall` instruction
- Return value in RAX and RDX
- Carry flag indicates error
- Note: RCX argument position differs from Linux (R10 on Linux)

### macOS System Call Classes

macOS syscalls are organized into classes with different number ranges:

```nasm
; Syscall class codes (upper bits)
BSD_SYSCALL_CLASS       equ 0x2000000    ; BSD/POSIX syscalls
MACH_SYSCALL_CLASS      equ 0x1000000    ; Mach kernel calls
MACHDEP_SYSCALL_CLASS   equ 0x3000000    ; Machine-dependent
DIAG_SYSCALL_CLASS      equ 0x4000000    ; Diagnostics
```

### Common macOS System Call Numbers

**BSD syscalls (most common):**

```nasm
SYS_exit        equ 1
SYS_fork        equ 2
SYS_read        equ 3
SYS_write       equ 4
SYS_open        equ 5
SYS_close       equ 6
SYS_mmap        equ 197
SYS_munmap      equ 73

; Actual values used in code
SYSCALL_exit    equ 0x2000001
SYSCALL_fork    equ 0x2000002
SYSCALL_read    equ 0x2000003
SYSCALL_write   equ 0x2000004
SYSCALL_open    equ 0x2000005
SYSCALL_close   equ 0x2000006
```

### macOS 64-bit System Call Examples

**Hello World:**

```nasm
section .data
    msg db 'Hello, World!', 0x0A
    len equ $ - msg

section .text
    global _main

_main:
    ; write(1, msg, len)
    mov rax, 0x2000004      ; SYS_write
    mov rdi, 1              ; fd = stdout
    lea rsi, [rel msg]      ; buffer
    mov rdx, len            ; count
    syscall
    
    ; exit(0)
    mov rax, 0x2000001      ; SYS_exit
    xor rdi, rdi            ; status = 0
    syscall
```

**File operations:**

```nasm
section .data
    filename db 'test.txt', 0
    buffer times 512 db 0

section .text
    ; open("test.txt", O_RDONLY)
    mov rax, 0x2000005      ; SYS_open
    lea rdi, [rel filename]
    xor rsi, rsi            ; O_RDONLY = 0
    mov rdx, 0              ; mode (not used)
    syscall
    jc error                ; Check carry flag
    mov r12, rax            ; Save fd
    
    ; read(fd, buffer, 512)
    mov rax, 0x2000003      ; SYS_read
    mov rdi, r12            ; fd
    lea rsi, [rel buffer]
    mov rdx, 512            ; count
    syscall
    jc error
    
    ; close(fd)
    mov rax, 0x2000006      ; SYS_close
    mov rdi, r12            ; fd
    syscall
    
error:
    ret
```

### macOS 32-bit System Call Examples

**[Inference]** 32-bit macOS syscalls use stack-based arguments:

```nasm
section .data
    msg db 'Hello, World!', 0x0A
    len equ $ - msg

section .text
    global _main

_main:
    push ebp
    mov ebp, esp
    
    ; write(1, msg, len)
    push dword len          ; count
    push dword msg          ; buffer
    push dword 1            ; fd
    mov eax, 0x2000004      ; SYS_write
    sub esp, 4              ; Darwin requires 16-byte alignment
    int 0x80
    add esp, 16
    
    ; exit(0)
    push dword 0            ; status
    mov eax, 0x2000001      ; SYS_exit
    sub esp, 4
    int 0x80
```

### Mach System Calls

macOS is built on the Mach microkernel, which provides its own set of low-level system calls:

```nasm
; Mach syscalls use class 0x1000000
MACH_msg_trap           equ 0x1000001
MACH_reply_port         equ 0x1000002
MACH_thread_self        equ 0x1000003
MACH_task_self          equ 0x1000004
MACH_host_self          equ 0x1000005
```

**Example:** Getting task port:

```nasm
; mach_task_self()
mov rax, 0x1000004      ; MACH_task_self
syscall
; RAX contains task port
```

### Memory Management on macOS

**mmap syscall:**

```nasm
; void *mmap(void *addr, size_t len, int prot, int flags, int fd, off_t offset)
mov rax, 0x20000C5      ; SYS_mmap
xor rdi, rdi            ; addr = NULL
mov rsi, 4096           ; length
mov rdx, 3              ; PROT_READ | PROT_WRITE
mov rcx, 0x1002         ; MAP_PRIVATE | MAP_ANON
mov r8, -1              ; fd = -1
xor r9, r9              ; offset = 0
syscall
jc error
; RAX contains address
```

### Process Control on macOS

**fork syscall:**

```nasm
mov rax, 0x2000002      ; SYS_fork
syscall
jc error
test rax, rax
jz child_process        ; RAX = 0 in child
; Parent: RAX = child PID
```

**execve syscall:**

```nasm
section .data
    prog db '/bin/sh', 0
    argv dq prog, 0
    envp dq 0

section .text
    mov rax, 0x200003B      ; SYS_execve
    lea rdi, [rel prog]
    lea rsi, [rel argv]
    lea rdx, [rel envp]
    syscall
```

### macOS Error Handling

macOS syscalls use the carry flag to indicate errors:

```nasm
mov rax, 0x2000005      ; SYS_open
lea rdi, [rel filename]
xor rsi, rsi
syscall

jc handle_error         ; Jump if carry flag set
; Success: RAX contains fd
mov [fd], rax
jmp continue

handle_error:
; Error: RAX contains errno
cmp rax, 2              ; ENOENT
je file_not_found
```

### macOS Stack Alignment

**[Inference]** macOS requires 16-byte stack alignment before system calls:

```nasm
; 64-bit: Ensure RSP is 16-byte aligned
; Before syscall, RSP should be 16n + 8 (because call pushes 8-byte return address)

_start:
    and rsp, -16        ; Align to 16 bytes
    sub rsp, 8          ; Adjust for call convention
    
    ; Now make syscall
    mov rax, 0x2000004
    ; ... rest of syscall
```

### macOS libSystem and System Call Wrappers

**[Inference]** macOS discourages direct syscall usage and provides libSystem.dylib:

- System calls should typically go through libSystem wrappers
- Direct syscalls are not guaranteed to be stable across OS versions
- libSystem provides POSIX-compliant interface

Linking with libSystem:

```nasm
section .text
    global _main
    extern _write
    extern _exit

_main:
    push rbp
    mov rbp, rsp
    
    ; Call write() from libSystem
    lea rdi, [rel msg]      ; First arg
    mov rsi, 1              ; Second arg
    mov rdx, len            ; Third arg
    call _write
    
    xor rdi, rdi
    call _exit
```

### macOS Code Signing and Restrictions

**[Unverified]** Modern macOS versions enforce code signing and security policies:

- Self-modifying code may be restricted
- Executable memory pages require specific permissions
- System Integrity Protection (SIP) limits certain operations

### Comparison Across Operating Systems

**Key Points:**

**Calling mechanisms:**

- Windows: Function calls through DLLs, multiple calling conventions
- Linux 32-bit: `int 0x80` with arguments in registers
- Linux 64-bit: `syscall` instruction with arguments in registers
- macOS 32-bit: `int 0x80` with arguments on stack
- macOS 64-bit: `syscall` with arguments in registers

**Syscall numbering:**

- Windows: Named exports from DLLs
- Linux: Different numbering for 32-bit vs 64-bit
- macOS: Class-based numbering system (BSD vs Mach calls)

**Return values:**

- Windows: Typically in EAX/RAX, errors via GetLastError()
- Linux: Negative values indicate errors (errno)
- macOS: Carry flag indicates error, errno in RAX

**Argument passing:**

- Windows 32-bit: Stack (stdcall/cdecl)
- Windows 64-bit: RCX, RDX, R8, R9, then stack
- Linux 32-bit: EBX, ECX, EDX, ESI, EDI, EBP
- Linux 64-bit: RDI, RSI, RDX, R10, R8, R9
- macOS 32-bit: Stack
- macOS 64-bit: RDI, RSI, RDX, RCX, R8, R9

**Stability:**

- Windows API: Generally stable across versions
- Linux syscalls: Stable interface, but numbers differ between architectures
- macOS syscalls: **[Unverified]** Apple discourages direct syscall usage as interface may change

**Example:** Cross-platform "Hello World" structure:

```nasm
%ifdef WINDOWS
    ; Windows version with API calls
%elifdef LINUX
    ; Linux version with syscalls
%elifdef MACOS
    ; macOS version with syscalls
%endif
```

**Related topics:** Calling conventions (cdecl, stdcall, fastcall, System V ABI, Windows x64), position-independent code (PIC), dynamic linking, library loading (LoadLibrary, dlopen), process memory layout, virtual memory management, signals/exceptions, inter-process communication (pipes, shared memory, sockets)

---

