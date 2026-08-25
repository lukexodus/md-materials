## Linux System Calls


Linux provides system calls (syscalls) as the primary interface between user space and the kernel. System calls are invoked using specific instructions and conventions.

### Linux System Call Mechanisms

**32-bit (x86) syscall interface:**

- Syscall number in EAX
- Arguments in EBX, ECX, EDX, ESI, EDI, EBP (up to 6 arguments)
- Invoke using `int 0x80` instruction
- Return value in EAX (negative values indicate errors)

**64-bit (x86-64) syscall interface:**

- Syscall number in RAX
- Arguments in RDI, RSI, RDX, R10, R8, R9 (up to 6 arguments)
- Invoke using `syscall` instruction
- Return value in RAX (negative values indicate errors)
- RCX and R11 are clobbered by syscall

### Common Linux System Call Numbers

**32-bit (x86):**

```nasm
SYS_exit        equ 1
SYS_fork        equ 2
SYS_read        equ 3
SYS_write       equ 4
SYS_open        equ 5
SYS_close       equ 6
SYS_creat       equ 8
SYS_execve      equ 11
SYS_mmap        equ 90
SYS_munmap      equ 91
```

**64-bit (x86-64):**

```nasm
SYS_read        equ 0
SYS_write       equ 1
SYS_open        equ 2
SYS_close       equ 3
SYS_mmap        equ 9
SYS_munmap      equ 11
SYS_exit        equ 60
SYS_fork        equ 57
SYS_execve      equ 59
SYS_creat       equ 85
```

System call numbers differ between 32-bit and 64-bit Linux.

### Basic Linux System Call Examples (32-bit)

**Hello World using write syscall:**

```nasm
section .data
    msg db 'Hello, World!', 0x0A
    len equ $ - msg

section .text
    global _start

_start:
    ; write(1, msg, len)
    mov eax, 4          ; SYS_write
    mov ebx, 1          ; fd = stdout
    mov ecx, msg        ; buffer
    mov edx, len        ; count
    int 0x80
    
    ; exit(0)
    mov eax, 1          ; SYS_exit
    xor ebx, ebx        ; status = 0
    int 0x80
```

**Reading from stdin:**

```nasm
section .bss
    buffer resb 128

section .text
    ; read(0, buffer, 128)
    mov eax, 3          ; SYS_read
    mov ebx, 0          ; fd = stdin
    mov ecx, buffer     ; buffer
    mov edx, 128        ; count
    int 0x80
    ; EAX now contains number of bytes read
```

### Basic Linux System Call Examples (64-bit)

**Hello World using write syscall:**

```nasm
section .data
    msg db 'Hello, World!', 0x0A
    len equ $ - msg

section .text
    global _start

_start:
    ; write(1, msg, len)
    mov rax, 1          ; SYS_write
    mov rdi, 1          ; fd = stdout
    lea rsi, [rel msg]  ; buffer (position-independent)
    mov rdx, len        ; count
    syscall
    
    ; exit(0)
    mov rax, 60         ; SYS_exit
    xor rdi, rdi        ; status = 0
    syscall
```

**File operations:**

```nasm
section .data
    filename db 'test.txt', 0
    buffer times 512 db 0

section .text
    ; open("test.txt", O_RDONLY, 0)
    mov rax, 2          ; SYS_open
    lea rdi, [rel filename]
    xor rsi, rsi        ; O_RDONLY = 0
    xor rdx, rdx        ; mode (not used for reading)
    syscall
    mov rbx, rax        ; Save fd
    
    ; Check for error
    test rax, rax
    js error            ; Jump if negative
    
    ; read(fd, buffer, 512)
    mov rax, 0          ; SYS_read
    mov rdi, rbx        ; fd
    lea rsi, [rel buffer]
    mov rdx, 512        ; count
    syscall
    
    ; close(fd)
    mov rax, 3          ; SYS_close
    mov rdi, rbx        ; fd
    syscall
    
error:
    ret
```

### Memory Management Syscalls

**mmap - Memory mapping:**

```nasm
; void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset)

; 64-bit
mov rax, 9              ; SYS_mmap
xor rdi, rdi            ; addr = NULL (let kernel choose)
mov rsi, 4096           ; length = 4096 bytes
mov rdx, 3              ; prot = PROT_READ | PROT_WRITE
mov r10, 34             ; flags = MAP_PRIVATE | MAP_ANONYMOUS
mov r8, -1              ; fd = -1 (anonymous mapping)
xor r9, r9              ; offset = 0
syscall
; RAX contains address or error

; 32-bit
push 0                  ; offset
push -1                 ; fd
push 34                 ; flags
push 3                  ; prot
push 4096               ; length
push 0                  ; addr
mov eax, 90             ; SYS_mmap (old_mmap on x86)
mov ebx, esp            ; Pointer to arguments
int 0x80
add esp, 24
```

**munmap - Unmap memory:**

```nasm
; 64-bit
mov rax, 11             ; SYS_munmap
mov rdi, [address]      ; addr
mov rsi, 4096           ; length
syscall
```

### Process Control Syscalls

**fork - Create child process:**

```nasm
; 64-bit
mov rax, 57             ; SYS_fork
syscall
test rax, rax
jz child_process        ; RAX = 0 in child
; Parent continues here (RAX = child PID)

child_process:
; Child process code
```

**execve - Execute program:**

```nasm
section .data
    prog db '/bin/sh', 0
    argv dq prog, 0
    envp dq 0

section .text
    ; execve("/bin/sh", argv, envp)
    mov rax, 59         ; SYS_execve
    lea rdi, [rel prog]
    lea rsi, [rel argv]
    lea rdx, [rel envp]
    syscall
```

### Signal Handling

**sigaction - Set signal handler:**

```nasm
section .data
    ; struct sigaction
    sa_handler dq signal_handler
    sa_flags dq 0
    sa_restorer dq 0
    sa_mask times 16 db 0

section .text
    ; sigaction(SIGINT, &sa, NULL)
    mov rax, 13         ; SYS_rt_sigaction (64-bit)
    mov rdi, 2          ; SIGINT
    lea rsi, [rel sa_handler]
    xor rdx, rdx        ; old action = NULL
    mov r10, 8          ; sigsetsize
    syscall

signal_handler:
    ; Signal handler code
    ; Must be careful about async-signal-safety
    ret
```

### Linux vsyscall and VDSO

**[Inference]** Modern Linux kernels provide vsyscall and VDSO (Virtual Dynamic Shared Object) for optimized system calls:

- Certain syscalls like `gettimeofday`, `time`, `getcpu` can execute in user space
- VDSO provides shared library-like interface
- Accessed through normal function calls rather than syscall instruction
- Significantly faster than kernel mode transitions

### Error Handling

Linux syscalls return negative errno values on error:

```nasm
; 64-bit example
mov rax, 2              ; SYS_open
lea rdi, [rel filename]
mov rsi, 0              ; O_RDONLY
syscall

test rax, rax
js handle_error         ; Jump if sign flag set (negative)

; Success path
mov [fd], rax
jmp continue

handle_error:
neg rax                 ; Convert to positive errno
cmp rax, 2              ; ENOENT
je file_not_found
; Other error handling

file_not_found:
; Handle file not found
```

### Linux System Call Table Location

**[Unverified]** System call tables are defined in the kernel source:

- 32-bit: `arch/x86/entry/syscalls/syscall_32.tbl`
- 64-bit: `arch/x86/entry/syscalls/syscall_64.tbl`

