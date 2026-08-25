## Process and Thread Concepts


Processes and threads are fundamental abstractions for program execution in modern operating systems. Understanding their management is essential for system programming.

### Process Basics

A **process** is an instance of a program in execution, consisting of:

- Memory space (text/code, data, heap, stack)
- Process ID (PID)
- Open file descriptors
- Signal handlers
- Environment variables
- Current working directory
- User and group IDs
- Resource limits

**Process States:**

- Running: Executing on CPU
- Ready: Waiting for CPU time
- Waiting/Blocked: Waiting for I/O or event
- Zombie: Terminated but not yet reaped by parent
- Stopped: Suspended (via signal)

### Creating Processes (fork)

**sys_fork System Call:**

```asm
; Prototype: pid_t fork(void)
; System call number: 57
; Returns: 0 in child process, child PID in parent, -1 on error
```

`fork()` creates a new process by duplicating the calling process. The child process is an almost exact copy of the parent, with separate memory space.

**Example 10: Basic fork**

```asm
section .data
    parent_msg: db "Parent process, PID: ", 0
    child_msg: db "Child process, PID: ", 0
    newline: db 10

section .text
    global _start

_start:
    ; Fork the process
    mov rax, 57                      ; sys_fork
    syscall
    
    cmp rax, 0
    jl fork_error                    ; Error
    je child_process                 ; Child (fork returns 0)
    
parent_process:
    ; Parent code (rax contains child PID)
    mov rdi, rax                     ; Save child PID
    
    ; Print parent message
    mov rax, 1
    mov rdi, 1
    lea rsi, [parent_msg]
    mov rdx, 21
    syscall
    
    ; Wait for child to complete
    mov rax, 61                      ; sys_wait4
    mov rdi, -1                      ; Wait for any child
    xor rsi, rsi                     ; Don't care about status
    xor rdx, rdx                     ; No options
    xor r10, r10                     ; No rusage
    syscall
    
    jmp exit_program

child_process:
    ; Child code
    mov rax, 1
    mov rdi, 1
    lea rsi, [child_msg]
    mov rdx, 20
    syscall
    
    jmp exit_program

fork_error:
    ; Handle error
    jmp exit_program

exit_program:
    mov rax, 60                      ; sys_exit
    xor rdi, rdi
    syscall
```

**Output:**

```
Parent process, PID: 
Child process, PID: 
```

[Inference: Actual PIDs would be displayed if we converted them to strings and printed them.]

### Process Termination

**sys_exit System Call:**

```asm
; Prototype: void exit(int status)
; System call number: 60
; Argument: rdi = exit status
; Does not return
```

**Example 11: Exit with Status Code**

```asm
section .text
    global _start

_start:
    ; Perform some work...
    
    ; Exit with status 0 (success)
    mov rax, 60
    mov rdi, 0                       ; Exit status
    syscall
```

### Program Execution (exec family)

**sys_execve System Call:**

```asm
; Prototype: int execve(const char *pathname, char *const argv[], char *const envp[])
; System call number: 59
; Arguments: rdi = pathname, rsi = argv, rdx = envp
; Returns: -1 on error (never returns on success)
```

`execve()` replaces the current process image with a new program. The process ID remains the same, but the code, data, heap, and stack are replaced.

**Example 12: Execute Another Program**

```asm
section .data
    program: db "/bin/ls", 0
    arg0: db "/bin/ls", 0
    arg1: db "-l", 0
    arg2: dq 0                       ; NULL terminator
    
    argv: dq arg0, arg1, arg2        ; Argument array
    envp: dq 0                       ; Empty environment

section .text
    global _start

_start:
    ; execve("/bin/ls", ["/bin/ls", "-l", NULL], [NULL])
    mov rax, 59                      ; sys_execve
    lea rdi, [program]
    lea rsi, [argv]
    lea rdx, [envp]
    syscall
    
    ; If we reach here, execve failed
    mov rax, 60
    mov rdi, 1                       ; Error exit
    syscall
```

**Output:** Directory listing (output of `ls -l`)

### Waiting for Child Processes

**sys_wait4 System Call:**

```asm
; Prototype: pid_t wait4(pid_t pid, int *wstatus, int options, struct rusage *rusage)
; System call number: 61
; Arguments: rdi = pid, rsi = wstatus, rdx = options, r10 = rusage
; Returns: PID of terminated child, -1 on error
```

**PID argument values:**

- < -1: Wait for any child in process group |pid|
- -1: Wait for any child
- 0: Wait for any child in same process group
- > 0: Wait for specific child with that PID
    

**Options:**

- WNOHANG (1): Return immediately if no child has exited
- WUNTRACED (2): Return if child has stopped
- WCONTINUED (8): Return if stopped child has been resumed

**Example 13: Fork and Wait**

```asm
section .data
    child_msg: db "Child executing", 10
    child_msg_len equ $ - child_msg
    parent_msg: db "Parent waiting for child", 10
    parent_msg_len equ $ - parent_msg
    done_msg: db "Child finished", 10
    done_msg_len equ $ - done_msg

section .bss
    child_pid: resq 1
    wait_status: resd 1

section .text
    global _start

_start:
    ; Fork
    mov rax, 57
    syscall
    
    cmp rax, 0
    je child_code
    
    ; Parent code
    mov [child_pid], rax
    
    ; Print parent message
    mov rax, 1
    mov rdi, 1
    lea rsi, [parent_msg]
    mov rdx, parent_msg_len
    syscall
    
    ; Wait for child
    mov rax, 61                      ; sys_wait4
    mov rdi, [child_pid]
    lea rsi, [wait_status]
    xor rdx, rdx                     ; No options
    xor r10, r10                     ; No rusage
    syscall
    
    ; Print done message
    mov rax, 1
    mov rdi, 1
    lea rsi, [done_msg]
    mov rdx, done_msg_len
    syscall
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

child_code:
    ; Print child message
    mov rax, 1
    mov rdi, 1
    lea rsi, [child_msg]
    mov rdx, child_msg_len
    syscall
    
    ; Simulate work
    mov rax, 35                      ; sys_nanosleep
    lea rdi, [timespec]
    xor rsi, rsi
    syscall
    
    ; Exit child
    mov rax, 60
    xor rdi, rdi
    syscall

section .data
    timespec:
        dq 1                         ; 1 second
        dq 0                         ; 0 nanoseconds
```

**Output:**

```
Parent waiting for child
Child executing
Child finished
```

### Thread Basics

A **thread** (lightweight process) shares the same memory space with other threads in the same process but has its own:

- Thread ID (TID)
- Stack
- Register context
- Signal mask
- Thread-local storage

**Advantages of threads:**

- Lower creation overhead than processes
- Shared memory enables efficient communication
- Better resource sharing
- Parallelism on multi-core systems

**Thread creation on Linux (clone system call):**

**sys_clone System Call:**

```asm
; Prototype: long clone(unsigned long flags, void *stack, int *parent_tid, int *child_tid, unsigned long tls)
; System call number: 56
; Arguments: rdi = flags, rsi = stack, rdx = parent_tid, r10 = child_tid, r8 = tls
```

**Clone flags (simplified):**

- CLONE_VM (0x00000100): Share memory space
- CLONE_FS (0x00000200): Share filesystem information
- CLONE_FILES (0x00000400): Share file descriptor table
- CLONE_SIGHAND (0x00000800): Share signal handlers
- CLONE_THREAD (0x00010000): Create thread (requires CLONE_SIGHAND and CLONE_VM)
- CLONE_PARENT (0x00008000): Share parent
- CLONE_CHILD_CLEARTID (0x00200000): Clear TID at child exit

**Example 14: Create Thread Using clone**

```asm
section .data
    thread_msg: db "Thread executing", 10
    thread_msg_len equ $ - thread_msg
    main_msg: db "Main thread", 10
    main_msg_len equ $ - main_msg

section .bss
    thread_stack: resb 8192          ; 8KB stack for thread
    thread_stack_top equ thread_stack + 8192
    thread_tid: resd 1

section .text
    global _start

_start:
    ; Print main thread message
    mov rax, 1
    mov rdi, 1
    lea rsi, [main_msg]
    mov rdx, main_msg_len
    syscall
    
    ; Create thread
    mov rax, 56                      ; sys_clone
    mov rdi, 0x00010F00              ; CLONE_VM | CLONE_FS | CLONE_FILES | CLONE_SIGHAND | CLONE_THREAD
    lea rsi, [thread_stack_top]      ; Stack grows down
    xor rdx, rdx                     ; parent_tid
    lea r10, [thread_tid]            ; child_tid
    xor r8, r8                       ; tls
    syscall
    
    cmp rax, 0
    je thread_function
    
    ; Main thread continues
    ; Wait a bit for thread to complete
    mov rax, 35                      ; sys_nanosleep
    lea rdi, [timespec]
    xor rsi, rsi
    syscall
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
    
thread_function:
    ; Thread code
    mov rax, 1                       ; sys_write
    mov rdi, 1                       ; stdout
    lea rsi, [thread_msg]
    mov rdx, thread_msg_len
    syscall
    
    ; Exit thread (not whole process)
    mov rax, 60                      ; sys_exit
    xor rdi, rdi
    syscall

section .data
    timespec:
        dq 2                         ; 2 seconds
        dq 0                         ; 0 nanoseconds
```

**Output:**

```
Main thread
Thread executing
```

[Inference: Thread execution order may vary due to scheduling.]

### Practical Threading with pthread (via libc)

Most real-world applications use the pthread library rather than raw `clone()` system calls, as it provides higher-level abstractions and portability.

**Example 15: Using pthread library (requires linking with -lpthread)**

```asm
section .data
    thread_msg: db "Thread %d running", 10, 0
    main_msg: db "Main thread created worker", 10, 0

section .bss
    thread_id: resq 1

section .text
    extern pthread_create
    extern pthread_join
    extern printf
    extern exit
    
    global main

main:
    push rbp
    mov rbp, rsp
    
    ; Print main message
    lea rdi, [main_msg]
    xor rax, rax
    call printf
    
    ; pthread_create(&thread_id, NULL, thread_func, NULL)
    lea rdi, [thread_id]             ; thread pointer
    xor rsi, rsi                     ; attributes (NULL)
    lea rdx, [thread_func]           ; start routine
    xor rcx, rcx                     ; argument (NULL)
    call pthread_create
    
    ; pthread_join(thread_id, NULL)
    mov rdi, [thread_id]
    xor rsi, rsi                     ; return value pointer (NULL)
    call pthread_join
    
    ; Exit
    xor rdi, rdi
    call exit

thread_func:
    push rbp
    mov rbp, rsp
    
    ; Print thread message
    lea rdi, [thread_msg]
    mov rsi, 1                       ; Thread number
    xor rax, rax
    call printf
    
    xor rax, rax                     ; Return NULL
    pop rbp
    ret
```

**Output:**

```
Main thread created worker
Thread 1 running
```

### Thread Synchronization

When multiple threads access shared data, synchronization primitives prevent race conditions and ensure data consistency.

**Common Synchronization Mechanisms:**

- Mutexes (mutual exclusion locks)
- Semaphores
- Condition variables
- Atomic operations
- Spinlocks
- Read-write locks

### Futex (Fast Userspace Mutex)

Linux provides the `futex` system call for implementing efficient synchronization primitives.

**sys_futex System Call:**

```asm
; Prototype: long futex(int *uaddr, int futex_op, int val, const struct timespec *timeout, int *uaddr2, int val3)
; System call number: 202
; Complex system call with multiple operations
```

**Common futex operations:**

- FUTEX_WAIT (0): Sleep if *uaddr == val
- FUTEX_WAKE (1): Wake up val waiters
- FUTEX_LOCK_PI: Priority-inheritance futex locking
- FUTEX_UNLOCK_PI: Priority-inheritance futex unlocking

**Example 16: Simple Mutex Using Futex**

```asm
section .data
    shared_counter: dd 0
    mutex: dd 0                      ; 0 = unlocked, 1 = locked
    
section .text
    global _start

; Mutex lock using futex
mutex_lock:
    push rbp
    mov rbp, rsp
    
.spin:
    ; Try to acquire lock (atomic compare-and-swap)
    xor eax, eax                     ; Expected value: 0 (unlocked)
    mov ecx, 1                       ; New value: 1 (locked)
    lea rdx, [mutex]
    lock cmpxchg [rdx], ecx          ; Atomic: if mutex==0, set to 1
    
    jz .acquired                     ; Jump if we got the lock
    
    ; Lock is held, wait using futex
    mov rax, 202                     ; sys_futex
    lea rdi, [mutex]
    mov rsi, 0                       ; FUTEX_WAIT
    mov rdx, 1                       ; Expected value
    xor r10, r10                     ; timeout (NULL = infinite)
    xor r8, r8                       ; uaddr2
    xor r9, r9                       ; val3
    syscall
    
    jmp .spin                        ; Try again

.acquired:
    pop rbp
    ret

; Mutex unlock using futex
mutex_unlock:
    push rbp
    mov rbp, rsp
    
    ; Release lock
    lea rdx, [mutex]
    mov dword [rdx], 0               ; Set to unlocked
    
    ; Wake up one waiter
    mov rax, 202                     ; sys_futex
    lea rdi, [mutex]
    mov rsi, 1                       ; FUTEX_WAKE
    mov rdx, 1                       ; Wake 1 thread
    xor r10, r10
    xor r8, r8
    xor r9, r9
    syscall
    
    pop rbp
    ret

_start:
    ; Lock mutex
    call mutex_lock
    
    ; Critical section: increment shared counter
    lea rax, [shared_counter]
    lock inc dword [rax]             ; Atomic increment
    
    ; Unlock mutex
    call mutex_unlock
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
```

### Atomic Operations

x86 provides atomic instructions essential for lock-free programming and implementing synchronization primitives.

**Key Atomic Instructions:**

`LOCK` prefix: Makes subsequent instruction atomic `CMPXCHG` - Compare and exchange `XCHG` - Exchange (implicitly locked) `XADD` - Exchange and add (implicitly locked)

**Example 17: Atomic Counter Increment**

```asm
section .data
    counter: dd 0

section .text
    global _start

_start:
    ; Atomic increment
    lea rax, [counter]
    lock inc dword [rax]
    
    ; Atomic add
    lock add dword [rax], 5
    
    ; Atomic compare-and-swap
    mov eax, 6                       ; Expected value
    mov ecx, 100                     ; New value
    lock cmpxchg [counter], ecx      ; If counter==6, set to 100
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
```

**Example 18: Lock-Free Stack (Simplified)**

```asm
section .data
    stack_head: dq 0                 ; Pointer to top of stack

section .bss
    align 16
    node1: resq 2                    ; [next_ptr, data]
    node2: resq 2
    node3: resq 2

section .text
    global _start

; Push node onto lock-free stack
; rdi = pointer to node (containing next_ptr at offset 0)
push_node:
    push rbp
    mov rbp, rsp
    
.retry:
    ; Load current head
    mov rax, [stack_head]
    
    ; Set node's next pointer to current head
    mov [rdi], rax
    
    ; Try to update head atomically
    lock cmpxchg [stack_head], rdi   ; If head==rax, set to rdi
    jnz .retry                       ; Retry if another thread modified head
    
    pop rbp
    ret

; Pop node from lock-free stack
; Returns: pointer to node in rax (or NULL if empty)
pop_node:
    push rbp
    mov rbp, rsp
    
.retry:
    ; Load current head
    mov rax, [stack_head]
    
    ; Check if stack is empty
    test rax, rax
    jz .empty
    
    ; Load next pointer from head node
    mov rdx, [rax]                   ; next = head->next
    
    ; Try to update head to next
    lock cmpxchg [stack_head], rdx   ; If head==rax, set to next
    jnz .retry                       ; Retry if another thread modified head
    
    ; Successfully popped, rax contains popped node
    pop rbp
    ret

.empty:
    xor rax, rax                     ; Return NULL
    pop rbp
    ret

_start:
    ; Initialize nodes with data
    mov qword [node1 + 8], 111
    mov qword [node2 + 8], 222
    mov qword [node3 + 8], 333
    
    ; Push nodes
    lea rdi, [node1]
    call push_node
    
    lea rdi, [node2]
    call push_node
    
    lea rdi, [node3]
    call push_node
    
    ; Pop nodes
    call pop_node                    ; Should return node3
    call pop_node                    ; Should return node2
    call pop_node                    ; Should return node1
    call pop_node                    ; Should return NULL
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
```

