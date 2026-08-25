## Thread Synchronization Primitives


Thread synchronization primitives coordinate access to shared resources and ensure correct concurrent execution.

### Atomic Operations

**Compare-and-Swap (CAS):**

```nasm
; Compare and swap (atomic)
compare_and_swap:
    ; Input:
    ;   RDI = address
    ;   RSI = expected value
    ;   RDX = new value
    ; Output:
    ;   RAX = old value
    ;   ZF = 1 if swap succeeded
    
    mov rax, rsi                ; Expected value
    lock cmpxchg [rdi], rdx     ; Atomic compare and exchange
    ret

; CAS with retry loop
cas_retry:
.retry:
    mov rax, [rdi]              ; Load current value
    mov rbx, rax
    ; Compute new value based on current
    add rbx, 1
    
    lock cmpxchg [rdi], rbx
    jnz .retry                  ; Retry if failed
    ret
```

**Atomic Fetch-and-Add:**

```nasm
; Atomic increment and return old value
atomic_fetch_add:
    ; Input:
    ;   RDI = address
    ;   ESI = increment
    ; Output:
    ;   EAX = old value
    
    mov eax, esi
    lock xadd [rdi], eax        ; Atomic exchange and add
    ; EAX now contains old value
    ret

; Atomic increment
atomic_inc:
    lock inc dword [rdi]
    ret

; Atomic decrement and test
atomic_dec_and_test:
    lock dec dword [rdi]
    ; ZF set if result is zero
    ret
```

**Atomic Bit Operations:**

```nasm
; Atomic bit test and set
atomic_bit_test_set:
    ; Input:
    ;   RDI = address
    ;   ESI = bit position
    ; Output:
    ;   CF = old bit value
    
    lock bts [rdi], esi
    ret

; Atomic bit test and clear
atomic_bit_test_clear:
    lock btr [rdi], esi
    ret

; Atomic bit test and complement
atomic_bit_test_complement:
    lock btc [rdi], esi
    ret
```

### Spinlocks

**Basic Spinlock:**

```nasm
section .data
    spinlock: dd 0              ; 0 = unlocked, 1 = locked

; Acquire spinlock
spin_lock:
    mov eax, 1
.spin:
    pause                       ; Hint: this is a spin loop
    lock xchg [spinlock], eax   ; Try to acquire
    test eax, eax               ; Was it unlocked?
    jnz .spin                   ; No, keep spinning
    ret

; Release spinlock
spin_unlock:
    mov dword [spinlock], 0     ; Simple store (with implicit memory barrier)
    ret
```

**Test-and-Test-and-Set (TATAS) Spinlock:**

```nasm
; More cache-friendly spinlock
tatas_lock:
    mov eax, 1
.spin:
    ; Test without atomic operation (cache-friendly)
    cmp dword [spinlock], 0
    jne .spin_pause
    
    ; Try to acquire with atomic operation
    lock xchg [spinlock], eax
    test eax, eax
    jnz .spin
    ret
    
.spin_pause:
    pause
    jmp .spin
```

**Ticket Lock (Fair Spinlock):**

```nasm
; Ticket lock ensures FIFO ordering

struc TicketLock
    .next_ticket:   resd 1
    .now_serving:   resd 1
endstruc

section .bss
align 64
    ticket_lock: resb TicketLock_size

; Acquire ticket lock
ticket_lock_acquire:
    ; Get ticket number
    mov eax, 1
    lock xadd [ticket_lock + TicketLock.next_ticket], eax
    ; EAX = our ticket number
    
.wait:
    pause
    mov ebx, [ticket_lock + TicketLock.now_serving]
    cmp eax, ebx
    jne .wait
    ret

; Release ticket lock
ticket_lock_release:
    lock inc dword [ticket_lock + TicketLock.now_serving]
    ret
```

**MCS Lock (Scalable Queue Lock):**

```nasm
; MCS lock: each thread spins on its own cache line

struc MCSNode
    .next:      resq 1
    .locked:    resd 1
    .padding:   resb 52         ; Pad to 64 bytes
endstruc

section .data
align 64
    mcs_lock_tail: dq 0

; Acquire MCS lock
mcs_lock_acquire:
    ; Input: RDI = pointer to thread's MCSNode
    
    mov qword [rdi + MCSNode.next], 0
    mov dword [rdi + MCSNode.locked], 1
    
    ; Atomically swap with tail
    mov rax, rdi
    lock xchg [mcs_lock_tail], rax
    
    ; Check if we're first
    test rax, rax
    jz .acquired
    
    ; Link ourselves to predecessor
    mov [rax + MCSNode.next], rdi
    
    ; Spin on our own locked flag
.spin:
    pause
    cmp dword [rdi + MCSNode.locked], 0
    jne .spin
    
.acquired:
    ret

; Release MCS lock
mcs_lock_release:
    ; Input: RDI = pointer to thread's MCSNode
    
    ; Check if we have a successor
    mov rax, [rdi + MCSNode.next]
    test rax, rax
    jnz .has_successor
    
    ; Try to set tail to NULL
    mov rax, rdi
    xor ebx, ebx
    lock cmpxchg [mcs_lock_tail], rbx
    jz .released
    
    ; Someone is being added, wait for next pointer
.wait_successor:
    pause
    mov rax, [rdi + MCSNode.next]
    test rax, rax
    jz .wait_successor
    
.has_successor:
    ; Unlock successor
    mov dword [rax + MCSNode.locked], 0
    
.released:
    ret
```

### Mutexes

**Fast User-Space Mutex (Futex-style):**

```nasm
; Mutex states
MUTEX_UNLOCKED equ 0
MUTEX_LOCKED equ 1
MUTEX_CONTENDED equ 2

section .data
align 64
    mutex: dd MUTEX_UNLOCKED

; Acquire mutex
mutex_lock:
    ; Fast path: try uncontended acquisition
    xor eax, eax
    mov ebx, MUTEX_LOCKED
    lock cmpxchg [mutex], ebx
    jz .acquired
    
    ; Slow path: mark as contended and wait
    mov ebx, MUTEX_CONTENDED
    
.contended_loop:
    ; Try to acquire contended mutex
    lock xchg [mutex], ebx
    test eax, eax
    jz .acquired
    
    ; Wait in kernel (futex syscall on Linux)
    mov rax, 202                ; SYS_futex
    lea rdi, [mutex]
    mov rsi, 0                  ; FUTEX_WAIT
    mov rdx, MUTEX_CONTENDED    ; Expected value
    xor r10, r10                ; No timeout
    syscall
    
    jmp .contended_loop
    
.acquired:
    ret

; Release mutex
mutex_unlock:
    ; Decrement state
    lock dec dword [mutex]
    jz .no_waiters
    
    ; Wake one waiter
    mov dword [mutex], MUTEX_UNLOCKED
    
    mov rax, 202                ; SYS_futex
    lea rdi, [mutex]
    mov rsi, 1                  ; FUTEX_WAKE
    mov rdx, 1                  ; Wake 1 thread
    syscall
    
.no_waiters:
    ret
```

**Recursive Mutex:**

```nasm
struc RecursiveMutex
    .lock:          resd 1
    .owner:         resq 1
    .recursion:     resd 1
    .padding:       resb 44
endstruc

section .bss
align 64
    rmutex: resb RecursiveMutex_size

; Acquire recursive mutex
recursive_mutex_lock:
    call get_current_thread_id
    mov rbx, rax
    
    ; Check if we already own it
    mov rax, [rmutex + RecursiveMutex.owner]
    cmp rax, rbx
    je .recursive
    
    ; Try to acquire
.acquire:
    xor eax, eax
    mov ecx, 1
    lock cmpxchg [rmutex + RecursiveMutex.lock], ecx
    jnz .acquire
    
    ; We acquired it
    mov [rmutex + RecursiveMutex.owner], rbx
    mov dword [rmutex + RecursiveMutex.recursion], 1
    ret
    
.recursive:
    ; Increment recursion count
    inc dword [rmutex + RecursiveMutex.recursion]
    ret

; Release recursive mutex
recursive_mutex_unlock:
    ; Decrement recursion count
    dec dword [rmutex + RecursiveMutex.recursion]
    jnz .still_owned
    
    ; Release lock
    mov qword [rmutex + RecursiveMutex.owner], 0
    mov dword [rmutex + RecursiveMutex.lock], 0
    
.still_owned:
    ret
```

### Read-Write Locks

```nasm
; Read-write lock structure
struc RWLock
    .state:         resd 1      ; Bit 31: write locked
                                ; Bits 0-30: reader count
    .padding:       resb 60
endstruc

RW_WRITE_LOCKED equ 0x80000000
RW_READER_MASK equ 0x7FFFFFFF

section .bss
align 64
    rwlock: resb RWLock_size

; Acquire read lock
rwlock_read_lock:
.retry:
    mov eax, [rwlock + RWLock.state]
    
    ; Check if write-locked
    test eax, RW_WRITE_LOCKED
    jnz .wait_writer
    
    ; Try to increment reader count
    mov ebx, eax
    inc ebx
    lock cmpxchg [rwlock + RWLock.state], ebx
    jnz .retry
    ret
    
.wait_writer:
    pause
    jmp .retry

; Release read lock
rwlock_read_unlock:
    lock dec dword [rwlock + RWLock.state]
    ret

; Acquire write lock
rwlock_write_lock:
.retry:
    xor eax, eax                ; Must be completely unlocked
    mov ebx, RW_WRITE_LOCKED
    lock cmpxchg [rwlock + RWLock.state], ebx
    jnz .retry
    ret

; Release write lock
rwlock_write_unlock:
    mov dword [rwlock + RWLock.state], 0
    ret
```

### Semaphores

```nasm
; Counting semaphore

struc Semaphore
    .count:         resd 1
    .waiters:       resd 1
    .padding:       resb 56
endstruc

section .bss
align 64
    semaphore: resb Semaphore_size

; Wait (P operation / down)
sem_wait:
.retry:
    mov eax, [semaphore + Semaphore.count]
    test eax, eax
    jle .block
    
    ; Try to decrement
    mov ebx, eax
    dec ebx
    lock cmpxchg [semaphore + Semaphore.count], ebx
    jnz .retry
    ret
    
.block:
    ; Increment waiters
    lock inc dword [semaphore + Semaphore.waiters]
    
    ; Futex wait
    mov rax, 202                ; SYS_futex
    lea rdi, [semaphore + Semaphore.count]
    mov rsi, 0                  ; FUTEX_WAIT
    xor edx, edx                ; Expected value (0 or negative)
    xor r10, r10
    syscall
    
    lock dec dword [semaphore + Semaphore.waiters]
    jmp .retry

; Signal (V operation / up)
sem_signal:
    ; Increment count
    lock inc dword [semaphore + Semaphore.count]
    
    ; Check if there are waiters
    mov eax, [semaphore + Semaphore.waiters]
    test eax, eax
    jz .no_waiters
    
    ; Wake one waiter
    mov rax, 202                ; SYS_futex

    lea rdi, [semaphore + Semaphore.count]
    mov rsi, 1                  ; FUTEX_WAKE
    mov rdx, 1                  ; Wake 1 thread
    syscall
    
.no_waiters:
    ret
```

### Condition Variables

```nasm
; Condition variable structure
struc CondVar
    .waiters:       resd 1
    .wakeups:       resd 1
    .padding:       resb 56
endstruc

section .bss
align 64
    condvar: resb CondVar_size

; Wait on condition variable
; Atomically releases mutex and waits
condvar_wait:
    ; Input: RDI = mutex address
    push rdi
    
    ; Increment waiters
    lock inc dword [condvar + CondVar.waiters]
    
    ; Get current wakeup count
    mov eax, [condvar + CondVar.wakeups]
    mov [rbp - 4], eax          ; Save for comparison
    
    ; Release mutex
    call mutex_unlock
    
    ; Wait for wakeup
.wait_loop:
    mov rax, 202                ; SYS_futex
    lea rdi, [condvar + CondVar.wakeups]
    mov rsi, 0                  ; FUTEX_WAIT
    mov edx, [rbp - 4]          ; Expected wakeup count
    xor r10, r10
    syscall
    
    ; Check if actually woken up
    mov eax, [condvar + CondVar.wakeups]
    cmp eax, [rbp - 4]
    je .wait_loop
    
    ; Decrement waiters
    lock dec dword [condvar + CondVar.waiters]
    
    ; Reacquire mutex
    pop rdi
    call mutex_lock
    ret

; Signal one waiter
condvar_signal:
    ; Check if there are waiters
    mov eax, [condvar + CondVar.waiters]
    test eax, eax
    jz .no_waiters
    
    ; Increment wakeup count
    lock inc dword [condvar + CondVar.wakeups]
    
    ; Wake one thread
    mov rax, 202                ; SYS_futex
    lea rdi, [condvar + CondVar.wakeups]
    mov rsi, 1                  ; FUTEX_WAKE
    mov rdx, 1                  ; Wake 1 thread
    syscall
    
.no_waiters:
    ret

; Broadcast to all waiters
condvar_broadcast:
    mov eax, [condvar + CondVar.waiters]
    test eax, eax
    jz .no_waiters
    
    ; Increment wakeup count
    lock inc dword [condvar + CondVar.wakeups]
    
    ; Wake all threads
    mov rax, 202                ; SYS_futex
    lea rdi, [condvar + CondVar.wakeups]
    mov rsi, 1                  ; FUTEX_WAKE
    mov rdx, 0x7FFFFFFF         ; Wake all
    syscall
    
.no_waiters:
    ret
```

### Barriers

```nasm
; Barrier synchronization primitive
; All threads wait until N threads arrive

struc Barrier
    .count:         resd 1      ; Number of threads
    .arrived:       resd 1      ; Threads that arrived
    .generation:    resd 1      ; Generation number
    .padding:       resb 52
endstruc

section .bss
align 64
    barrier: resb Barrier_size

; Initialize barrier
barrier_init:
    ; Input: ECX = thread count
    mov [barrier + Barrier.count], ecx
    mov dword [barrier + Barrier.arrived], 0
    mov dword [barrier + Barrier.generation], 0
    ret

; Wait at barrier
barrier_wait:
    ; Get current generation
    mov eax, [barrier + Barrier.generation]
    mov [rbp - 4], eax          ; Save generation
    
    ; Atomically increment arrived count
    mov ebx, 1
    lock xadd [barrier + Barrier.arrived], ebx
    inc ebx                     ; EBX = new count
    
    ; Check if we're the last thread
    mov ecx, [barrier + Barrier.count]
    cmp ebx, ecx
    je .last_thread
    
    ; Not last thread - wait
.wait_loop:
    mov rax, 202                ; SYS_futex
    lea rdi, [barrier + Barrier.generation]
    mov rsi, 0                  ; FUTEX_WAIT
    mov edx, [rbp - 4]          ; Expected generation
    xor r10, r10
    syscall
    
    ; Check if generation changed
    mov eax, [barrier + Barrier.generation]
    cmp eax, [rbp - 4]
    je .wait_loop
    
    ret
    
.last_thread:
    ; Reset arrived count
    mov dword [barrier + Barrier.arrived], 0
    
    ; Increment generation
    lock inc dword [barrier + Barrier.generation]
    
    ; Wake all waiting threads
    mov rax, 202                ; SYS_futex
    lea rdi, [barrier + Barrier.generation]
    mov rsi, 1                  ; FUTEX_WAKE
    mov rdx, 0x7FFFFFFF         ; Wake all
    syscall
    
    ret
```

### Lock-Free Data Structures

**Lock-Free Stack:**

```nasm
; Lock-free stack using CAS

struc LFStackNode
    .data:          resq 1
    .next:          resq 1
endstruc

section .data
align 64
    stack_head: dq 0

; Push to lock-free stack
lfstack_push:
    ; Input: RAX = data
    push rbx
    
    ; Allocate node
    push rax
    mov rdi, LFStackNode_size
    call malloc
    mov rbx, rax                ; Node pointer
    pop rax
    
    ; Fill node
    mov [rbx + LFStackNode.data], rax
    
.retry:
    ; Load current head
    mov rax, [stack_head]
    mov [rbx + LFStackNode.next], rax
    
    ; Try to CAS head
    lock cmpxchg [stack_head], rbx
    jnz .retry
    
    pop rbx
    ret

; Pop from lock-free stack
lfstack_pop:
    ; Output: RAX = data (or 0 if empty)
    
.retry:
    mov rax, [stack_head]
    test rax, rax
    jz .empty
    
    ; Try to remove head
    mov rbx, [rax + LFStackNode.next]
    lock cmpxchg [stack_head], rbx
    jnz .retry
    
    ; Successfully removed head
    mov rax, [rax + LFStackNode.data]
    ; Note: Node should be freed, but requires ABA protection
    ret
    
.empty:
    xor eax, eax
    ret
```

**Lock-Free Queue (Michael-Scott):**

```nasm
; Lock-free FIFO queue

struc LFQueueNode
    .data:          resq 1
    .next:          resq 1
endstruc

struc LFQueue
    .head:          resq 1
    .padding1:      resb 56
    .tail:          resq 1
    .padding2:      resb 56
endstruc

section .bss
align 64
    lfqueue: resb LFQueue_size

; Initialize lock-free queue
lfqueue_init:
    ; Allocate dummy node
    mov rdi, LFQueueNode_size
    call malloc
    
    mov qword [rax + LFQueueNode.next], 0
    mov [lfqueue + LFQueue.head], rax
    mov [lfqueue + LFQueue.tail], rax
    ret

; Enqueue
lfqueue_enqueue:
    ; Input: RDI = data
    push rbx
    push r12
    
    ; Allocate new node
    push rdi
    mov rdi, LFQueueNode_size
    call malloc
    mov rbx, rax                ; New node
    pop rdi
    
    mov [rbx + LFQueueNode.data], rdi
    mov qword [rbx + LFQueueNode.next], 0
    
.retry:
    ; Load tail and next
    mov r12, [lfqueue + LFQueue.tail]
    mov rax, [r12 + LFQueueNode.next]
    
    ; Check if tail is consistent
    cmp r12, [lfqueue + LFQueue.tail]
    jne .retry
    
    ; Check if tail is at end
    test rax, rax
    jz .try_enqueue
    
    ; Tail is not at end, help advance it
    lock cmpxchg [lfqueue + LFQueue.tail], rax
    jmp .retry
    
.try_enqueue:
    ; Try to link new node
    xor eax, eax
    lock cmpxchg [r12 + LFQueueNode.next], rbx
    jnz .retry
    
    ; Try to advance tail
    mov rax, r12
    lock cmpxchg [lfqueue + LFQueue.tail], rbx
    
    pop r12
    pop rbx
    ret

; Dequeue
lfqueue_dequeue:
    ; Output: RAX = data (or 0 if empty)
    push rbx
    push r12
    
.retry:
    ; Load head, tail, and next
    mov rbx, [lfqueue + LFQueue.head]
    mov r12, [lfqueue + LFQueue.tail]
    mov rax, [rbx + LFQueueNode.next]
    
    ; Check if head is consistent
    cmp rbx, [lfqueue + LFQueue.head]
    jne .retry
    
    ; Check if queue is empty
    cmp rbx, r12
    jne .not_empty
    
    test rax, rax
    jz .empty
    
    ; Queue appears empty but tail is behind - help advance
    lock cmpxchg [lfqueue + LFQueue.tail], rax
    jmp .retry
    
.not_empty:
    ; Try to advance head
    lock cmpxchg [lfqueue + LFQueue.head], rax
    jnz .retry
    
    ; Successfully dequeued
    mov rax, [rax + LFQueueNode.data]
    
    ; Free old dummy node (requires careful memory management)
    ; push rax
    ; mov rdi, rbx
    ; call free
    ; pop rax
    
    pop r12
    pop rbx
    ret
    
.empty:
    xor eax, eax
    pop r12
    pop rbx
    ret
```

### Hazard Pointers (Memory Reclamation)

```nasm
; Hazard pointers for safe lock-free memory reclamation

MAX_HAZARD_POINTERS equ 128

struc HazardPointer
    .pointer:       resq 1
    .active:        resd 1
    .padding:       resb 52
endstruc

section .bss
align 64
    hazard_pointers: resb HazardPointer_size * MAX_HAZARD_POINTERS

; Acquire hazard pointer
acquire_hazard_pointer:
    ; Output: RAX = hazard pointer slot index
    xor ecx, ecx
    
.find_slot:
    cmp ecx, MAX_HAZARD_POINTERS
    jge .no_slots
    
    ; Try to claim inactive slot
    lea rdi, [hazard_pointers + rcx * HazardPointer_size]
    xor eax, eax
    mov ebx, 1
    lock cmpxchg [rdi + HazardPointer.active], ebx
    jz .claimed
    
    inc ecx
    jmp .find_slot
    
.claimed:
    mov eax, ecx
    ret
    
.no_slots:
    ; Error: no available hazard pointer slots
    mov rax, -1
    ret

; Set hazard pointer
set_hazard_pointer:
    ; Input:
    ;   ECX = slot index
    ;   RDX = pointer to protect
    
    lea rdi, [hazard_pointers + rcx * HazardPointer_size]
    mov [rdi + HazardPointer.pointer], rdx
    mfence                      ; Ensure visibility
    ret

; Release hazard pointer
release_hazard_pointer:
    ; Input: ECX = slot index
    
    lea rdi, [hazard_pointers + rcx * HazardPointer_size]
    mov qword [rdi + HazardPointer.pointer], 0
    mov dword [rdi + HazardPointer.active], 0
    ret

; Check if pointer is hazardous
is_hazardous:
    ; Input: RDI = pointer to check
    ; Output: AL = 1 if hazardous, 0 if safe
    
    xor ecx, ecx
    
.check_loop:
    cmp ecx, MAX_HAZARD_POINTERS
    jge .not_hazardous
    
    lea rsi, [hazard_pointers + rcx * HazardPointer_size]
    
    ; Check if slot is active
    cmp dword [rsi + HazardPointer.active], 0
    je .next_slot
    
    ; Check if pointer matches
    mov rax, [rsi + HazardPointer.pointer]
    cmp rax, rdi
    je .hazardous
    
.next_slot:
    inc ecx
    jmp .check_loop
    
.hazardous:
    mov al, 1
    ret
    
.not_hazardous:
    xor eax, eax
    ret

; Safe lock-free pop with hazard pointers
safe_lfstack_pop:
    push rbx
    push r12
    
    ; Acquire hazard pointer slot
    call acquire_hazard_pointer
    mov r12d, eax               ; Save slot index
    
.retry:
    ; Load head
    mov rbx, [stack_head]
    test rbx, rbx
    jz .empty
    
    ; Protect head with hazard pointer
    mov ecx, r12d
    mov rdx, rbx
    call set_hazard_pointer
    
    ; Verify head didn't change
    mov rax, [stack_head]
    cmp rax, rbx
    jne .retry
    
    ; Try to remove head
    mov rax, [rbx + LFStackNode.next]
    mov rcx, rbx
    lock cmpxchg [stack_head], rax
    jnz .retry
    
    ; Successfully removed - release hazard pointer
    mov ecx, r12d
    call release_hazard_pointer
    
    ; Get data
    mov rax, [rbx + LFStackNode.data]
    
    ; Check if node can be freed
    push rax
    mov rdi, rbx
    call is_hazardous
    test al, al
    jnz .defer_free
    
    ; Safe to free
    mov rdi, rbx
    call free
    
    pop rax
    pop r12
    pop rbx
    ret
    
.defer_free:
    ; Add to retired list for later reclamation
    ; (Implementation omitted for brevity)
    pop rax
    pop r12
    pop rbx
    ret
    
.empty:
    mov ecx, r12d
    call release_hazard_pointer
    xor eax, eax
    pop r12
    pop rbx
    ret
```

### Transactional Memory (Hardware TSX)

```nasm
; Intel TSX (Transactional Synchronization Extensions)

; Transaction status codes
TSX_STARTED equ 0xFFFFFFFF
TSX_ABORT_EXPLICIT equ (1 << 0)
TSX_ABORT_RETRY equ (1 << 1)
TSX_ABORT_CONFLICT equ (1 << 2)
TSX_ABORT_CAPACITY equ (1 << 3)

; Begin restricted transactional memory
transaction_begin:
.retry:
    xbegin .fallback
    
    ; EAX = TSX_STARTED if successful
    cmp eax, TSX_STARTED
    jne .check_abort
    
    ; Transaction started successfully
    ; Perform transactional operations
    ; ...
    
    ; Commit transaction
    xend
    ret
    
.check_abort:
    ; Check abort reason
    test eax, TSX_ABORT_RETRY
    jnz .retry                  ; Retry on soft abort
    
    test eax, TSX_ABORT_CAPACITY
    jnz .fallback               ; Capacity overflow - use lock
    
    ; Other abort - retry limited times
    dec dword [retry_count]
    jnz .retry
    
.fallback:
    ; Fallback to lock-based code
    call mutex_lock
    ; ... perform operations ...
    call mutex_unlock
    ret

; Abort transaction explicitly
transaction_abort:
    ; Input: AL = abort code
    xabort al
    ret

; Check if in transaction
in_transaction:
    xtest
    ; ZF = 0 if in transaction
    ret
```

### Performance Monitoring for Synchronization

```nasm
; Measure lock contention
measure_lock_contention:
    ; Setup performance counter for lock cycles
    mov ecx, 0x186
    ; Event varies by CPU - example: cycles with lock prefix
    mov eax, 0x004301F2         ; MEM_LOCK_ST_RETIRED.LOCK_CYCLES
    xor edx, edx
    wrmsr
    
    mov ecx, 0xC1
    xor eax, eax
    xor edx, edx
    wrmsr
    
    ; Run test
    call contended_workload
    
    ; Read lock cycles
    mov ecx, 0xC1
    rdmsr
    mov [lock_cycles], eax
    
    ret

; Detect false sharing in synchronization
detect_sync_false_sharing:
    ; Monitor RFO (Request For Ownership) requests
    mov ecx, 0x186
    mov eax, 0x00430824         ; L2_RQSTS.RFO_HIT
    xor edx, edx
    wrmsr
    
    mov ecx, 0xC1
    xor eax, eax
    xor edx, edx
    wrmsr
    
    ; Run synchronized test
    call spawn_sync_threads
    call join_threads
    
    ; Read RFO count
    mov ecx, 0xC1
    rdmsr
    ; High count indicates false sharing
    
    ret
```

### Optimizing Synchronization

**Adaptive Spinning:**

```nasm
; Adaptive mutex with spinning before blocking

SPIN_LIMIT equ 1000

adaptive_mutex_lock:
    mov ecx, SPIN_LIMIT
    
.spin_phase:
    ; Try to acquire
    xor eax, eax
    mov ebx, 1
    lock cmpxchg [mutex], ebx
    jz .acquired
    
    pause
    dec ecx
    jnz .spin_phase
    
.block_phase:
    ; Exhausted spin - block in kernel
    mov rax, 202                ; SYS_futex
    lea rdi, [mutex]
    mov rsi, 0                  ; FUTEX_WAIT
    mov rdx, 1                  ; Expected value (locked)
    xor r10, r10
    syscall
    
    mov ecx, SPIN_LIMIT
    jmp .spin_phase
    
.acquired:
    ret
```

**Backoff Strategies:**

```nasm
; Exponential backoff for reduced contention

MAX_BACKOFF equ 4096

backoff_spinlock:
    mov r12d, 1                 ; Initial backoff
    
.retry:
    ; Try to acquire
    mov eax, 1
    lock xchg [spinlock], eax
    test eax, eax
    jz .acquired
    
    ; Backoff
    mov ecx, r12d
.backoff_loop:
    pause
    loop .backoff_loop
    
    ; Exponential increase
    shl r12d, 1
    cmp r12d, MAX_BACKOFF
    jle .no_cap
    mov r12d, MAX_BACKOFF
    
.no_cap:
    jmp .retry
    
.acquired:
    ret
```

**Key Points:**

- Thread Local Storage uses FS (32-bit Windows) or GS (x86-64) segment registers to provide per-thread data without synchronization overhead
- Static TLS is resolved at link time with direct segment-relative addressing; dynamic TLS requires runtime allocation via TlsAlloc/pthread_key_create
- Context switching saves/restores registers, FPU/SSE state, instruction pointer, and flags; lightweight fiber switches save only callee-saved registers
- [Inference] Context switch overhead ranges from 1000-5000 cycles for full thread switches; fiber switches cost 50-100 cycles
- Lazy FPU switching traps on first FPU use (#NM exception) to save/restore state only when needed, reducing overhead for non-FP threads
- Atomic operations (LOCK prefix, CMPXCHG, XADD) provide foundation for lock-free algorithms but cause cache coherency traffic
- Spinlocks spin in user space; TATAS (test-and-test-and-set) reduces cache traffic by testing without atomic operation first
- Ticket locks provide FIFO fairness; MCS locks provide scalability by having each thread spin on its own cache line
- Lock-free data structures use CAS loops but require memory reclamation strategies like hazard pointers to prevent use-after-free
- [Inference] Condition variables require atomic mutex release and wait to prevent missed wakeups; barriers synchronize N threads at a common point
- Hardware transactional memory (TSX) uses XBEGIN/XEND for optimistic lock elision with automatic rollback on conflicts
- Adaptive synchronization combines spinning (for short waits) with blocking (for long waits) to minimize both CPU waste and context switch overhead

---

