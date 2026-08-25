## POSIX Compatibility


POSIX (Portable Operating System Interface) defines a standard API for Unix-like systems. Assembly programs can interact with POSIX through system calls or C library wrappers.

### Standard POSIX System Calls

**File Operations**:

```asm
; open(filename, flags, mode)
mov rax, 2          ; sys_open
mov rdi, filename
mov rsi, 0          ; O_RDONLY
mov rdx, 0          ; mode (ignored for read)
syscall

; read(fd, buffer, count)
mov rax, 0          ; sys_read
mov rdi, fd
mov rsi, buffer
mov rdx, count
syscall

; write(fd, buffer, count)
mov rax, 1          ; sys_write
mov rdi, fd
mov rsi, buffer
mov rdx, count
syscall

; close(fd)
mov rax, 3          ; sys_close
mov rdi, fd
syscall
```

**Process Management**:

```asm
; fork()
mov rax, 57         ; sys_fork (x86-64)
syscall
; Returns 0 in child, child PID in parent

; execve(pathname, argv, envp)
mov rax, 59         ; sys_execve
mov rdi, pathname
mov rsi, argv
mov rdx, envp
syscall

; exit(status)
mov rax, 60         ; sys_exit
mov rdi, status
syscall
```

**Memory Management**:

```asm
; mmap(addr, length, prot, flags, fd, offset)
mov rax, 9          ; sys_mmap
mov rdi, 0          ; addr (NULL = kernel chooses)
mov rsi, length
mov rdx, 3          ; PROT_READ | PROT_WRITE
mov r10, 34         ; MAP_PRIVATE | MAP_ANONYMOUS
mov r8, -1          ; fd (ignored for anonymous)
mov r9, 0           ; offset
syscall

; munmap(addr, length)
mov rax, 11         ; sys_munmap
mov rdi, addr
mov rsi, length
syscall
```

### POSIX Signal Handling

**Signal Registration**:

```asm
; sigaction(signum, act, oldact)
mov rax, 13         ; sys_rt_sigaction (x86-64)
mov rdi, signum     ; e.g., SIGINT (2)
mov rsi, act        ; pointer to new sigaction struct
mov rdx, oldact     ; pointer to old sigaction struct
mov r10, 8          ; sigsetsize
syscall
```

The sigaction structure:

```asm
struc sigaction
    .sa_handler:    resq 1  ; signal handler function pointer
    .sa_flags:      resq 1  ; flags (SA_RESTART, etc.)
    .sa_restorer:   resq 1  ; restorer function
    .sa_mask:       resb 128 ; signal mask
endstruc
```

**Signal Handler Example**:

```asm
signal_handler:
    ; Save registers if needed
    push rax
    push rdi
    
    ; Handle signal (minimal work)
    ; ...
    
    ; Restore registers
    pop rdi
    pop rax
    
    ; Return from signal handler
    mov rax, 15         ; sys_rt_sigreturn
    syscall
```

### POSIX Threading (pthreads)

**[Inference]** While pthreads are typically accessed through the C library, the underlying mechanism uses the `clone` system call:

```asm
; clone(fn, stack, flags, arg, ptid, tls, ctid)
mov rax, 56         ; sys_clone
mov rdi, fn         ; function to execute in new thread
mov rsi, stack      ; stack pointer for new thread
mov rdx, flags      ; CLONE_VM | CLONE_FS | CLONE_FILES | etc.
mov r10, arg        ; argument to pass to fn
mov r8, ptid        ; parent thread ID pointer
mov r9, tls         ; TLS pointer
; ctid passed on stack
syscall
```

**Key Points:**

- Thread creation requires careful stack management
- TLS (Thread-Local Storage) setup is architecture-specific
- Proper synchronization primitives needed (futex system calls)

### POSIX IPC Mechanisms

**Pipes**:

```asm
; pipe(pipefd) - creates pipe, returns read/write fds in array
mov rax, 22         ; sys_pipe
mov rdi, pipefd     ; pointer to int[2]
syscall
```

**Shared Memory**:

```asm
; shm_open is typically a libc wrapper around open()
; Use mmap with MAP_SHARED for POSIX shared memory

mov rax, 9          ; sys_mmap
mov rdi, 0
mov rsi, size
mov rdx, 3          ; PROT_READ | PROT_WRITE
mov r10, 1          ; MAP_SHARED
mov r8, fd          ; file descriptor from shm_open
mov r9, 0
syscall
```

**Message Queues**:

POSIX message queues use the `mq_*` system calls, which are **[Inference]** typically implemented as library wrappers around underlying kernel mechanisms that vary by operating system.

### System Call Number Portability

System call numbers differ across:

- Architectures (x86 vs x86-64 vs ARM)
- Operating systems (Linux vs BSD vs others)
- Kernel versions (may add new syscalls)

**Example** - Linux write syscall:

- x86 (32-bit): syscall number 4
- x86-64: syscall number 1

For portability, use symbolic constants from system headers or rely on C library wrappers.

