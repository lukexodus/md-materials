## Thread Local Storage (TLS)


Thread Local Storage provides each thread with its own private instance of data, eliminating the need for synchronization when accessing thread-specific variables.

### TLS Implementation Methods

**1. FS/GS Segment Registers (x86/x86-64):**

On x86, the FS register (32-bit) or GS register (64-bit) typically points to thread-local storage.

```nasm
; Linux x86-64: GS register points to TLS
; Windows x86-64: GS register points to TEB (Thread Environment Block)
; Linux x86-32: GS register points to TLS
; Windows x86-32: FS register points to TEB

; Access TLS variable (Linux x86-64)
mov rax, gs:[offset]            ; Read from TLS

; Access TLS variable (Windows x86-64)
mov rax, gs:[0x58]              ; TEB.ThreadLocalStoragePointer
mov rbx, [rax + offset]         ; Read actual TLS variable

; Access TLS variable (Windows x86-32)
mov eax, fs:[0x2C]              ; TEB.ThreadLocalStoragePointer
mov ebx, [eax + offset]
```

**Setting Up FS/GS Base:**

```nasm
; x86-64: Set GS base using MSR (requires kernel mode)
mov ecx, 0xC0000101             ; IA32_GS_BASE MSR
mov eax, [tls_base_low]
mov edx, [tls_base_high]
wrmsr

; User-mode: Use arch_prctl syscall (Linux)
mov rax, 158                    ; sys_arch_prctl
mov rdi, 0x1002                 ; ARCH_SET_GS
mov rsi, [tls_base]
syscall

; Windows: Use NtSetInformationThread
mov rcx, -2                     ; Current thread pseudo-handle
mov edx, 27                     ; ThreadZeroTlsCell (example)
lea r8, [tls_data]
xor r9d, r9d
call NtSetInformationThread
```

### TLS Access Patterns

**Static TLS (Known at Link Time):**

```nasm
section .tdata
    tls_counter: dd 0
    tls_buffer: times 256 db 0

section .text
; GCC/Linux TLS access
access_static_tls:
    ; Compiler generates:
    mov rax, fs:0               ; Get TLS base (or gs: on x86-64)
    mov ebx, [rax + tls_counter@TPOFF]
    inc ebx
    mov [rax + tls_counter@TPOFF], ebx
    ret
```

**Dynamic TLS (Runtime Allocation):**

```nasm
; Allocate TLS index (Windows)
allocate_tls_index:
    ; Call TlsAlloc()
    sub rsp, 32                 ; Shadow space
    call TlsAlloc
    add rsp, 32
    ; RAX = TLS index
    mov [my_tls_index], eax
    ret

; Set TLS value (Windows)
set_tls_value:
    ; Input: ECX = value
    sub rsp, 32
    mov edx, ecx                ; Value
    mov ecx, [my_tls_index]     ; Index
    call TlsSetValue
    add rsp, 32
    ret

; Get TLS value (Windows)
get_tls_value:
    ; Output: EAX = value
    sub rsp, 32
    mov ecx, [my_tls_index]
    call TlsGetValue
    add rsp, 32
    ret
```

**Manual TLS Implementation:**

```nasm
; Simple TLS using per-thread arrays

MAX_THREADS equ 64

section .data
    thread_count: dd 0
    
section .bss
align 64
    ; Each thread gets a cache-line-aligned slot
    tls_array: resb 64 * MAX_THREADS

section .text
; Allocate TLS slot for new thread
allocate_tls_slot:
    ; Atomically increment thread count
    mov eax, 1
    lock xadd [thread_count], eax
    ; EAX = thread ID
    
    ; Calculate TLS base for this thread
    imul eax, 64
    lea rax, [tls_array + rax]
    ; RAX = thread's TLS base
    
    ret

; Access TLS using thread ID
access_manual_tls:
    ; Get current thread ID (OS-specific)
    call get_current_thread_id  ; Returns in EAX
    
    ; Calculate offset
    imul eax, 64
    lea rbx, [tls_array + rax]
    
    ; Access TLS data
    mov ecx, [rbx]              ; Read TLS variable
    inc ecx
    mov [rbx], ecx              ; Write back
    
    ret
```

### TLS-Based Thread Identification

```nasm
; Store thread ID in TLS for fast access
section .tdata
    tls_thread_id: dd 0
    tls_cpu_id: dd 0

; Initialize TLS for new thread
init_thread_tls:
    ; Get thread ID from OS
    call pthread_self           ; Linux
    ; or: call GetCurrentThreadId ; Windows
    
    ; Store in TLS
    mov gs:[tls_thread_id], eax
    
    ; Get CPU ID
    rdtscp                      ; ECX = CPU ID
    mov gs:[tls_cpu_id], ecx
    
    ret

; Fast thread ID retrieval
get_thread_id_fast:
    mov eax, gs:[tls_thread_id]
    ret
```

### Per-Thread Caching

```nasm
; Per-thread memory allocator using TLS

struc ThreadCache
    .free_list:     resq 16     ; Free lists for different sizes
    .allocated:     resd 1      ; Total allocated
    .freed:         resd 1      ; Total freed
    .padding:       resb 24     ; Pad to 64 bytes
endstruc

section .tdata
align 64
    thread_cache: resb ThreadCache_size

; Allocate from thread cache (no locks needed)
tc_alloc:
    ; Input: RCX = size (must be power of 2)
    ; Output: RAX = allocated pointer
    
    ; Calculate free list index (log2 of size)
    bsr rdx, rcx                ; RDX = log2(size)
    
    ; Get thread cache base
    lea r8, [rel thread_cache]
    mov r8, gs:[r8]
    
    ; Check free list
    mov rax, [r8 + ThreadCache.free_list + rdx * 8]
    test rax, rax
    jz .allocate_new
    
    ; Pop from free list
    mov rbx, [rax]              ; Next pointer
    mov [r8 + ThreadCache.free_list + rdx * 8], rbx
    
    ret
    
.allocate_new:
    ; Allocate new block from OS
    push rcx
    call mmap                   ; Or VirtualAlloc on Windows
    pop rcx
    
    ; Update statistics
    lock add [r8 + ThreadCache.allocated], ecx
    
    ret

; Free to thread cache
tc_free:
    ; Input: RAX = pointer, RCX = size
    
    bsr rdx, rcx
    lea r8, [rel thread_cache]
    mov r8, gs:[r8]
    
    ; Push to free list
    mov rbx, [r8 + ThreadCache.free_list + rdx * 8]
    mov [rax], rbx              ; Link to current head
    mov [r8 + ThreadCache.free_list + rdx * 8], rax
    
    ; Update statistics
    lock add [r8 + ThreadCache.freed], ecx
    
    ret
```

### TLS Initialization and Cleanup

```nasm
; Thread initialization callback
thread_init_callback:
    push rbp
    mov rbp, rsp
    
    ; Allocate TLS data
    mov ecx, 4096               ; Size
    call allocate_tls_memory
    
    ; Store TLS base in GS
    mov rdi, 0x1002             ; ARCH_SET_GS
    mov rsi, rax
    mov rax, 158                ; arch_prctl
    syscall
    
    ; Initialize TLS variables
    mov dword gs:[0], 0         ; Counter
    mov qword gs:[8], 0         ; Pointer
    
    pop rbp
    ret

; Thread cleanup callback
thread_cleanup_callback:
    push rbp
    mov rbp, rsp
    
    ; Get TLS base
    mov rdi, 0x1003             ; ARCH_GET_GS
    lea rsi, [rbp - 8]
    mov rax, 158
    syscall
    
    mov rdi, [rbp - 8]
    test rdi, rdi
    jz .done
    
    ; Free TLS memory
    call free_tls_memory
    
.done:
    pop rbp
    ret
```

