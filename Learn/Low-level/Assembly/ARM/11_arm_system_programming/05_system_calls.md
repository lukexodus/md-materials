## System Calls


System calls provide the interface between user-space applications and the operating system kernel. On ARM architectures, system calls transition execution from unprivileged user mode to privileged kernel mode, allowing applications to request kernel services such as I/O operations, process management, memory allocation, and device access.

**Supervisor Call Instruction (SVC):** The primary mechanism for invoking system calls. Previously called SWI (Software Interrupt) in older ARM documentation, SVC generates a synchronous exception that vectors to the kernel's system call handler.

**SVC Instruction Format:**

ARM state (32-bit):

```assembly
SVC  #immed24    ; 24-bit immediate value
```

Thumb state (16-bit):

```assembly
SVC  #immed8     ; 8-bit immediate value
```

The immediate value is embedded in the instruction encoding but is typically not used for system call dispatch on modern ARM systems. Instead, the system call number is passed in a register (conventionally R7 on ARM Linux).

**Linux ARM System Call Convention (EABI):**

- **R7:** System call number
- **R0-R6:** System call arguments (up to 7 arguments)
- **R0:** Return value (or error code)
- **R1:** Secondary return value (for some calls like `pipe`)

**Example** - write() system call:

```assembly
; ssize_t write(int fd, const void *buf, size_t count);
; syscall number for write = 4

    MOV    R7, #4         ; System call number (write)
    MOV    R0, #1         ; File descriptor (stdout)
    LDR    R1, =message   ; Buffer pointer
    MOV    R2, #13        ; Count (message length)
    SVC    #0             ; Invoke system call
    ; R0 now contains return value (bytes written or -errno)

message:
    .ascii "Hello, World\n"
```

**System Call Execution Flow:**

1. User application loads system call number into R7 and arguments into R0-R6
2. SVC instruction triggers exception, switching to SVC mode
3. Processor saves return address to LR_svc and CPSR to SPSR_svc
4. PC jumps to SVC exception vector (typically 0x00000008 or 0xFFFF0008)
5. Kernel's SVC handler executes:
    - Saves user context (registers) to stack
    - Validates system call number
    - Dispatches to appropriate kernel function
    - Restores user context
    - Returns to user mode via exception return instruction
6. Execution resumes after SVC instruction with result in R0

**Kernel-side SVC Handler (simplified structure):**

```assembly
vector_svc:
    ; Save user registers
    STMFD   SP!, {R0-R12, LR}
    
    ; Get system call number from R7
    MOV     R10, R7
    
    ; Validate syscall number
    CMP     R10, #NR_syscalls
    BHS     syscall_invalid
    
    ; Load syscall table address
    LDR     R8, =sys_call_table
    
    ; Call handler: handler(R0, R1, R2, R3, R4, R5, R6)
    ; R0-R6 already contain arguments
    LDR     PC, [R8, R10, LSL #2]   ; Branch to handler
    
syscall_return:
    ; Restore registers
    LDMFD   SP!, {R0-R12, PC}^      ; ^ restores CPSR from SPSR_svc
    
syscall_invalid:
    MOV     R0, #-ENOSYS
    B       syscall_return
```

**System Call Table:** The kernel maintains a jump table indexed by system call number:

```c
const void *sys_call_table[NR_syscalls] = {
    [0] = sys_restart_syscall,
    [1] = sys_exit,
    [2] = sys_fork,
    [3] = sys_read,
    [4] = sys_write,
    [5] = sys_open,
    // ... hundreds more
};
```

**Error Handling:** System calls return negative errno values on error. User-space wrappers typically check for negative return values and set the `errno` global variable:

```assembly
; After SVC returns
    CMP     R0, #0
    BXGE    LR              ; Return if success (R0 >= 0)
    
    ; Handle error
    RSB     R0, R0, #0      ; Negate to positive errno
    LDR     R1, =errno
    STR     R0, [R1]        ; Store to errno
    MOV     R0, #-1         ; Return -1
    BX      LR
```

**Alternative System Call Mechanisms:**

**Fast System Calls (ARMv6+):** Some ARM implementations provide optimized system call paths that avoid full exception overhead. These use dedicated instructions or memory-mapped interfaces, though SVC remains the standard portable mechanism.

**vDSO (Virtual Dynamic Shared Object):** Linux kernel maps a page into user-space containing frequently-used system calls implemented without mode switches. Examples include `gettimeofday()` and `clock_gettime()` which read kernel-maintained data structures directly from user mode.

**System Call Example - open, read, close:**

```assembly
.global _start
.text

_start:
    ; open("file.txt", O_RDONLY)
    MOV     R7, #5          ; sys_open
    LDR     R0, =filename
    MOV     R1, #0          ; O_RDONLY
    MOV     R2, #0
    SVC     #0
    CMP     R0, #0
    BLT     error           ; Negative = error
    MOV     R4, R0          ; Save fd
    
    ; read(fd, buffer, 100)
    MOV     R7, #3          ; sys_read
    MOV     R0, R4          ; fd from open
    LDR     R1, =buffer
    MOV     R2, #100
    SVC     #0
    CMP     R0, #0
    BLT     error
    
    ; close(fd)
    MOV     R7, #6          ; sys_close
    MOV     R0, R4
    SVC     #0
    
    ; exit(0)
    MOV     R7, #1          ; sys_exit
    MOV     R0, #0
    SVC     #0

error:
    MOV     R7, #1
    MOV     R0, #1          ; Exit with code 1
    SVC     #0

.data
filename: .asciz "file.txt"
.bss
buffer:   .space 100
```

**ARMv8 System Calls:** ARMv8 AArch64 uses the `SVC` instruction similarly but with different register conventions:

- **X8:** System call number
- **X0-X5:** Arguments
- **X0:** Return value

The calling convention differs due to the 64-bit register set, but the conceptual model remains identical.

