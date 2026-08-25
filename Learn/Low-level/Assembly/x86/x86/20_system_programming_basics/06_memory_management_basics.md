## Memory Management Basics


Memory management in system programming involves allocating, deallocating, and managing memory regions for program use. Understanding virtual memory, paging, and memory allocation strategies is essential.

### Virtual Memory Concepts

Modern operating systems use **virtual memory**, providing each process with its own address space. Virtual addresses are translated to physical addresses by the Memory Management Unit (MMU).

**x86-64 Virtual Address Space Layout (Linux, typical):**

```
0x0000000000000000 - Start of user space
0x0000000000400000 - Typical program text (code) start
...                - Program data, BSS
...                - Heap (grows upward)
...                - Memory-mapped regions
...                - Thread stacks
0x00007FFFFFFFFFFF - Top of user space (128TB for 48-bit addresses)
0x0000800000000000 - Kernel space start (non-accessible from user mode)
```

**Memory Segments:**

- **Text (Code):** Executable instructions (read-only, shared)
- **Data:** Initialized global/static variables
- **BSS:** Uninitialized global/static variables (zeroed at startup)
- **Heap:** Dynamic memory (grows upward via brk/sbrk/mmap)
- **Stack:** Function call frames, local variables (grows downward)
- **Memory-mapped:** Files and shared memory regions

### Dynamic Memory Allocation

**brk/sbrk System Calls:**

The traditional Unix method for heap management adjusts the program break (end of data segment).

```asm
; Prototype: int brk(void *addr)
; System call number: 12
; Sets program break to addr
; Returns: 0 on success, -1 on error

; Prototype: void *sbrk(intptr_t increment)
; Not a system call, implemented via brk in libc
; Increments program break by increment bytes
```

**Example 19: Simple Heap Allocation Using brk**

```asm
section .bss
    heap_start: resq 1
    heap_current: resq 1

section .text
    global _start

; Initialize heap
heap_init:
    push rbp
    mov rbp, rsp
    
    ; Get current program break
    mov rax, 12                      ; sys_brk
    xor rdi, rdi                     ; brk(0) returns current break
    syscall
    
    mov [heap_start], rax
    mov [heap_current], rax
    
    pop rbp
    ret

; Allocate memory from heap
; rdi = size in bytes
; Returns: pointer in rax (or 0 on failure)
heap_alloc:
    push rbp
    mov rbp, rsp
    push rdi                         ; Save size
    
    ; Calculate new break
    mov rax, [heap_current]
    add rax, rdi                     ; new_break = current + size
    
    ; Set new program break
    mov rdi, rax
    push rax                         ; Save new break
    mov rax, 12                      ; sys_brk
    syscall
    
    pop rdx                          ; Restore new break
    pop rdi                          ; Restore size
    
    ; Check if brk succeeded
    cmp rax, rdx
    jne .failure
    
    ; Success: return old heap_current
    mov rax, [heap_current]
    mov [heap_current], rdx          ; Update current
    
    pop rbp
    ret

.failure:
    xor rax, rax                     ; Return NULL
    pop rbp
    ret

_start:
    ; Initialize heap
    call heap_init
    
    ; Allocate 1024 bytes
    mov rdi, 1024
    call heap_alloc
    
    ; rax now contains pointer to allocated memory
    mov r12, rax                     ; Save pointer
    
    ; Use allocated memory...
    mov byte [r12], 0xFF             ; Write to first byte
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
```

### Memory Allocation with mmap

Modern programs typically use `mmap` for dynamic memory allocation instead of `brk`, as it's more flexible and efficient for large allocations.

**Example 20: Allocate Anonymous Memory**

```asm
section .bss
    mem_ptr: resq 1

section .text
    global _start

_start:
    ; Allocate 4096 bytes (1 page) of anonymous memory
    mov rax, 9                       ; sys_mmap
    xor rdi, rdi                     ; Let kernel choose address
    mov rsi, 4096                    ; Size: 4KB
    mov rdx, 3                       ; PROT_READ | PROT_WRITE
    mov r10, 0x22                    ; MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1                       ; fd (ignored for anonymous)
    xor r9, r9                       ; offset (ignored)
    syscall
    
    cmp rax, -1
    je error_exit
    
    mov [mem_ptr], rax               ; Save pointer
    
    ; Use memory
    mov rdi, rax
    mov byte [rdi], 42               ; Write value
    
    ; Deallocate memory
    mov rax, 11                      ; sys_munmap
    mov rdi, [mem_ptr]
    mov rsi, 4096
    syscall
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

error_exit:
    mov rax, 60
    mov rdi, 1
    syscall
```

### Memory Protection

Memory regions can have different protection attributes set via `mmap` or changed with `mprotect`.

**sys_mprotect System Call:**

```asm
; Prototype: int mprotect(void *addr, size_t len, int prot)
; System call number: 10
; Changes protection on memory region
; Returns: 0 on success, -1 on error
```

**Example 21: Change Memory Protection**

```asm
section .data
    code_bytes: db 0xC3              ; RET instruction
    code_len equ $ - code_bytes

section .bss
    exec_mem: resq 1

section .text
    global _start

_start:
    ; Allocate executable memory
    mov rax, 9                       ; sys_mmap
    xor rdi, rdi
    mov rsi, 4096                    ; One page
    mov rdx, 7                       ; PROT_READ | PROT_WRITE | PROT_EXEC
    mov r10, 0x22                    ; MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1
    xor r9, r9
    syscall
    
    mov [exec_mem], rax
    
    ; Copy code to executable memory
    mov rdi, rax
    lea rsi, [code_bytes]
    mov rcx, code_len
    rep movsb
    
    ; Call the code
    mov rax, [exec_mem]
    call rax                         ; Execute the RET instruction
    
    ; Change protection to read-only
    mov rax, 10                      ; sys_mprotect
    mov rdi, [exec_mem]
    mov rsi, 4096
    mov rdx, 1                       ; PROT_READ only
    syscall
    
    ; Attempt to write would now cause segfault
    ; mov rdi, [exec_mem]
    ; mov byte [rdi], 0x90           ; Would segfault
    
    ; Cleanup
    mov rax, 11                      ; sys_munmap
    mov rdi, [exec_mem]
    mov rsi, 4096
    syscall
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
```

### Simple Memory Allocator Implementation

A basic allocator managing a memory pool with free list.

**Example 22: First-Fit Allocator**

```asm
section .data
    pool_size: equ 65536             ; 64KB memory pool

section .bss
    align 16
    memory_pool: resb pool_size
    free_list_head: resq 1           ; Pointer to first free block

section .text
    global _start

; Block structure (stored at beginning of each block):
; [size: 8 bytes][next: 8 bytes][data...]
BLOCK_SIZE_OFFSET equ 0
BLOCK_NEXT_OFFSET equ 8
BLOCK_HEADER_SIZE equ 16

; Initialize allocator
allocator_init:
    push rbp
    mov rbp, rsp
    
    ; Set up initial free block spanning entire pool
    lea rax, [memory_pool]
    mov [free_list_head], rax
    
    ; Set block size (pool_size - header)
    mov qword [rax + BLOCK_SIZE_OFFSET], pool_size - BLOCK_HEADER_SIZE
    
    ; No next block
    mov qword [rax + BLOCK_NEXT_OFFSET], 0
    
    pop rbp
    ret

; Allocate memory
; rdi = requested size
; Returns: pointer to data in rax (or 0 if failed)
allocator_alloc:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    
    ; Align size to 16 bytes
    add rdi, 15
    and rdi, -16
    mov r12, rdi                     ; r12 = aligned size
    
    ; Search free list for suitable block
    mov rbx, [free_list_head]        ; rbx = current block
    xor r13, r13                     ; r13 = previous block

.search:
    test rbx, rbx
    jz .no_memory                    ; End of list, no suitable block
    
    ; Check if block is large enough
    mov rax, [rbx + BLOCK_SIZE_OFFSET]
    cmp rax, r12
    jge .found_block
    
    ; Move to next block
    mov r13, rbx
    mov rbx, [rbx + BLOCK_NEXT_OFFSET]
    jmp .search

.found_block:
    ; Block found at rbx with size in rax
    ; Check if we should split the block
    mov rdx, rax
    sub rdx, r12
    cmp rdx, BLOCK_HEADER_SIZE + 16  ; Minimum useful block size
    jl .use_entire_block
    
    ; Split block
    ; New free block starts at rbx + BLOCK_HEADER_SIZE + r12
    lea rcx, [rbx + BLOCK_HEADER_SIZE]
    add rcx, r12                     ; rcx = new block address
    
    ; Set new block size
    sub rax, r12
    sub rax, BLOCK_HEADER_SIZE
    mov [rcx + BLOCK_SIZE_OFFSET], rax
    
    ; Set new block next pointer
    mov rax, [rbx + BLOCK_NEXT_OFFSET]
    mov [rcx + BLOCK_NEXT_OFFSET], rax
    
    ; Update allocated block size
    mov [rbx + BLOCK_SIZE_OFFSET], r12
    
    ; Update previous block's next pointer or free_list_head
    test r13, r13
    jz .update_head_split
    mov [r13 + BLOCK_NEXT_OFFSET], rcx
    jmp .return_allocated

.update_head_split:
    mov [free_list_head], rcx
    jmp .return_allocated

.use_entire_block:
    ; Use entire block, remove from free list
    mov rax, [rbx + BLOCK_NEXT_OFFSET]
    
    test r13, r13
    jz .update_head_entire
    mov [r13 + BLOCK_NEXT_OFFSET], rax
    jmp .return_allocated

.update_head_entire:
    mov [free_list_head], rax

.return_allocated:
    ; Return pointer to data (after header)
    lea rax, [rbx + BLOCK_HEADER_SIZE]
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

.no_memory:
    xor rax, rax                     ; Return NULL
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; Free memory
; rdi = pointer to data (as returned by allocator_alloc)
allocator_free:
    push rbp
    mov rbp, rsp
    
    ; Get block header address
    sub rdi, BLOCK_HEADER_SIZE
    
    ; Insert at head of free list (simplified - no coalescing)
    mov rax, [free_list_head]
    mov [rdi + BLOCK_NEXT_OFFSET], rax
    mov [free_list_head], rdi
    
    pop rbp
    ret

_start:
    ; Initialize allocator
    call allocator_init
    
    ; Allocate 100 bytes
    mov rdi, 100
    call allocator_alloc
    mov r12, rax                     ; Save pointer
    
    ; Use memory
    test rax, rax
    jz allocation_failed
    mov byte [r12], 65               ; Write 'A'
    
    ; Allocate another 200 bytes
    mov rdi, 200
    call allocator_alloc
    mov r13, rax
    
    ; Free first allocation
    mov rdi, r12
    call allocator_free
    
    ; Free second allocation
    mov rdi, r13
    call allocator_free
    
    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

allocation_failed:
    mov rax, 60
    mov rdi, 1
    syscall
```

### Stack Management

The stack is automatically managed by the processor and OS, but understanding its structure is crucial.

**Stack Frame Layout (x86-64 System V ABI):**

```
High addresses
    ...
    [argument 7]        ; Arguments beyond 6 passed on stack
    [argument 6]
    [return address]    ; Pushed by CALL
    [saved RBP]         ; Pushed by function prologue
RBP → [local variables]
    [saved registers]
    [temporary space]
RSP → [top of stack]
Low addresses
```

**Example 23: Manual Stack Frame Management**

```asm
section .text
    global _start

; Function with local variables
my_function:
    ; Prologue: set up stack frame
    push rbp
    mov rbp, rsp
    sub rsp, 32                      ; Allocate 32 bytes for locals
    
    ; Access local variables relative to RBP
    mov qword [rbp - 8], 100         ; Local var 1
    mov qword [rbp - 16], 200        ; Local var 2
    mov qword [rbp - 24], 300        ; Local var 3
    
    ; Function body...
    mov rax, [rbp - 8]
    add rax, [rbp - 16]
    add rax, [rbp - 24]
    
    ; Epilogue: restore stack and return
    mov rsp, rbp                     ; Or: add rsp, 32
    pop rbp
    ret

_start:
    call my_function
    
    ; rax contains 600 (sum of local variables)
    
    mov rax, 60
    xor rdi, rdi
    syscall
```

### Memory-Mapped I/O for IPC

Memory-mapped regions can be shared between processes for inter-process communication.

**Example 24: Shared Memory Between Processes**

```asm
section .data
    shm_name: db "/my_shm", 0
    parent_msg: db "Parent wrote to shared memory", 10, 0
    child_msg: db "Child read from shared memory", 10, 0

section .bss
    shm_ptr: resq 1

section .text
    extern shm_open
    extern shm_unlink
    extern ftruncate
    extern mmap
    extern munmap
    extern fork
    extern wait
    extern printf
    extern exit
    
    global main

main:
    push rbp
    mov rbp, rsp
    
    ; shm_open("/my_shm", O_CREAT | O_RDWR, 0666)
    lea rdi, [shm_name]
    mov rsi, 0x42                    ; O_CREAT | O_RDWR
    mov rdx, 0666o
    call shm_open
    mov r12, rax                     ; Save fd
    
    ; ftruncate(fd, 4096)
    mov rdi, r12
    mov rsi, 4096
    call ftruncate
    
    ; mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0)
    xor rdi, rdi
    mov rsi, 4096
    mov rdx, 3                       ; PROT_READ | PROT_WRITE
    mov rcx, 1                       ; MAP_SHARED
    mov r8, r12                      ; fd
    xor r9, r9                       ; offset
    call mmap
    mov [shm_ptr], rax               ; Save shared memory pointer
    
    ; fork()
    call fork
    cmp rax, 0
    je child_process
    
parent_process:
    ; Write to shared memory
    mov rdi, [shm_ptr]
    lea rsi, [parent_msg]
    mov rcx, 30
    rep movsb
    
    ; Wait for child
    mov rdi, -1
    xor rsi, rsi
    xor rdx, rdx
    xor rcx, rcx
    call wait
    
    ; Cleanup
    mov rdi, [shm_ptr]
    mov rsi, 4096
    call munmap
    
    lea rdi, [shm_name]
    call shm_unlink
    
    xor rdi, rdi
    call exit

child_process:
    ; Read from shared memory
    mov rdi, [shm_ptr]
    xor rax, rax
    call printf
    
    ; Cleanup
    mov rdi, [shm_ptr]
    mov rsi, 4096
    call munmap
    
    xor rdi, rdi
    call exit
```

**Output:**

```
Parent wrote to shared memory
```

[Inference: The child reads what the parent wrote to shared memory.]

