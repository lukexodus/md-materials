## OS-Specific Features


### Linux-Specific Features

**vsyscall and vDSO**:

Linux provides vsyscall and vDSO (virtual dynamic shared object) for fast system calls that don't require kernel transition:

```asm
; Using vDSO for clock_gettime (faster than syscall)
; vDSO is mapped into process address space by kernel
; Access through dynamic linker or auxiliary vector

; Traditional syscall method:
mov rax, 228        ; sys_clock_gettime
mov rdi, 0          ; CLOCK_REALTIME
mov rsi, timespec
syscall

; vDSO method is automatically used by C library functions
; Direct assembly access requires parsing ELF auxiliary vector
```

**Key Points:**

- vDSO eliminates context switch overhead for certain operations
- Functions include `gettimeofday`, `clock_gettime`, `getcpu`
- Location varies per process, found via auxiliary vectors
- Provides same ABI as regular system calls

**Extended Berkeley Packet Filter (eBPF)**:

```asm
; bpf(cmd, attr, size)
mov rax, 321        ; sys_bpf
mov rdi, BPF_PROG_LOAD
mov rsi, attr       ; pointer to bpf_attr structure
mov rdx, size
syscall
```

eBPF allows running sandboxed programs in kernel space for networking, tracing, and security.

**io_uring**:

Modern async I/O interface:

```asm
; io_uring_setup(entries, params)
mov rax, 425        ; sys_io_uring_setup
mov rdi, entries
mov rsi, params
syscall

; io_uring_enter(fd, to_submit, min_complete, flags, sig)
mov rax, 426        ; sys_io_uring_enter
mov rdi, ring_fd
mov rsi, to_submit
mov rdx, min_complete
mov r10, flags
mov r8, sig
syscall
```

**Key Points:**

- Shared memory ring buffers between kernel and userspace
- Batch submission and completion of I/O operations
- Significantly reduces syscall overhead for I/O-heavy workloads

**Namespaces and Control Groups**:

```asm
; unshare(flags) - disassociate parts of execution context
mov rax, 272        ; sys_unshare
mov rdi, CLONE_NEWNS | CLONE_NEWPID
syscall

; setns(fd, nstype) - join existing namespace
mov rax, 308        ; sys_setns
mov rdi, ns_fd
mov rsi, 0          ; nstype (0 = auto-detect)
syscall
```

Used for containerization and resource isolation.

**Futex (Fast Userspace Mutex)**:

```asm
; futex(uaddr, op, val, timeout, uaddr2, val3)
mov rax, 202        ; sys_futex
mov rdi, uaddr      ; address of futex word
mov rsi, FUTEX_WAIT
mov rdx, expected_val
mov r10, timeout
mov r8, 0
mov r9, 0
syscall
```

Low-level synchronization primitive used by pthread implementations.

**perf_event_open**:

Hardware performance counter access:

```asm
; perf_event_open(attr, pid, cpu, group_fd, flags)
mov rax, 298        ; sys_perf_event_open
mov rdi, attr       ; struct perf_event_attr
mov rsi, pid
mov rdx, cpu
mov r10, group_fd
mov r8, flags
syscall
```

### Windows-Specific Features (x86 Assembly Context)

**Native API (ntdll.dll)**:

Windows assembly typically uses the Native API through `ntdll.dll`:

```asm
; Using syscall directly (requires knowing syscall numbers)
mov r10, rcx        ; Windows uses different calling convention
mov eax, syscall_number
syscall

; More commonly, call through ntdll:
extern NtWriteFile
; Setup parameters according to Windows x64 calling convention
; rcx, rdx, r8, r9, then stack for additional parameters
call NtWriteFile
```

**Key Points:**

- Windows syscall numbers are **[Unverified]** not documented and may change between versions
- Recommended approach is calling ntdll functions
- Windows x64 uses different calling convention than System V (used by Linux)

**Structured Exception Handling (SEH)**:

Windows uses SEH for exception handling, which requires specific assembly structures:

```asm
; Registering exception handler
push offset exception_handler
push fs:[0]
mov fs:[0], esp

; Exception handler function
exception_handler:
    ; EXCEPTION_REGISTRATION_RECORD structure
    ; Handler receives EXCEPTION_RECORD and context
    ; ...
```

**Windows Driver Model (WDM) Interface**:

Kernel-mode drivers use different calling conventions and interfaces than userspace code **[Inference]**, typically involving I/O Request Packets (IRPs) and device objects managed through specific API functions.

### BSD-Specific Features

**kqueue/kevent**:

BSD's event notification mechanism:

```asm
; kqueue() - create kernel event queue
mov rax, syscall_num_kqueue  ; BSD syscall number
syscall

; kevent(kq, changelist, nchanges, eventlist, nevents, timeout)
mov rax, syscall_num_kevent
mov rdi, kq
mov rsi, changelist
mov rdx, nchanges
mov r10, eventlist
mov r8, nevents
mov r9, timeout
syscall
```

More efficient than `select` or `poll` for monitoring multiple file descriptors.

**Capsicum Security Framework**:

Capability-based security:

```asm
; cap_enter() - enter capability mode
mov rax, syscall_num_cap_enter
syscall

; cap_rights_limit(fd, rights)
mov rax, syscall_num_cap_rights_limit
mov rdi, fd
mov rsi, rights
syscall
```

Restricts process capabilities for sandboxing.

**jemalloc Integration**:

FreeBSD integrates jemalloc as default allocator, affecting memory management performance characteristics compared to other systems.

### macOS-Specific Features

**Mach System Calls**:

macOS uses both BSD system calls and Mach kernel calls:

```asm
; Mach system calls use negative numbers
; mach_task_self() - get task port
mov rax, -28        ; Mach syscall for task_self_trap
syscall

; Mach message passing
mov rax, -31        ; mach_msg_trap
mov rdi, msg
mov rsi, option
mov rdx, send_size
mov r10, rcv_size
mov r8, rcv_name
mov r9, timeout
syscall
```

**Key Points:**

- Mach provides microkernel functionality
- Message-based IPC between tasks and kernel
- Ports are communication endpoints
- macOS combines Mach, BSD, and IOKit layers

**Grand Central Dispatch (GCD)**:

While primarily a C API, GCD's underlying mechanism **[Inference]** uses kernel workqueues and synchronization primitives that can be accessed at assembly level through system calls.

**System Integrity Protection (SIP)**:

Restricts even root access to certain files and operations, affecting what assembly code can accomplish even with elevated privileges.

