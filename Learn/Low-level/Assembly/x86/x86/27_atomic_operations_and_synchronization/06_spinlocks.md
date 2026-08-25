## Spinlocks


Spinlocks are the simplest synchronization primitive, where a thread continuously checks (spins) until a lock becomes available.

### Basic Spinlock Implementation

```assembly
section .data
align 64                    ; Avoid false sharing
spinlock: dd 0              ; 0 = unlocked, 1 = locked

; Naive spinlock - test and set
naive_spinlock_acquire:
    mov eax, 1
.spin:
    lock xchg [spinlock], eax   ; Atomic swap
    test eax, eax               ; Was it unlocked?
    jnz .spin                   ; Spin if locked
    ret                         ; Lock acquired

naive_spinlock_release:
    mov dword [spinlock], 0     ; Release (simple store is sufficient)
    ret
```

**Problem with Naive Spinlock**: Every XCHG generates bus traffic (RFO), even when lock is held by another thread. With high contention, this creates cache line bouncing and bus congestion.

```assembly
; Performance problem visualization
; 4 threads spinning on lock held by Thread 0:
; Thread 0: Holds lock (lock in Modified state on core 0)
; Thread 1: lock xchg -> RFO -> bounces cache line to core 1
; Thread 2: lock xchg -> RFO -> bounces cache line to core 2
; Thread 3: lock xchg -> RFO -> bounces cache line to core 3
; Thread 1: lock xchg -> RFO -> bounces back to core 1
; ... constant cache line bouncing, high bus traffic
```

### Test-and-Test-and-Set (TTAS) Spinlock

Improved spinlock that tests with regular load before attempting atomic swap.

```assembly
; TTAS spinlock - much better performance
ttas_spinlock_acquire:
.test:
    mov eax, [spinlock]         ; Read without LOCK
    test eax, eax               ; Is it locked?
    jnz .test                   ; Spin on read (no RFO traffic)
    
.test_and_set:
    mov eax, 1
    lock xchg [spinlock], eax   ; Try to acquire
    test eax, eax
    jnz .test                   ; Failed, go back to spinning on read
    ret                         ; Lock acquired

ttas_spinlock_release:
    mov dword [spinlock], 0
    ret
```

**TTAS Advantages**:

- Spinning on shared read doesn't generate RFO traffic
- Cache line stays in Shared state across all spinning cores
- Only one atomic operation attempted when lock released
- Dramatically reduces cache coherency traffic

```assembly
; TTAS with contention
; Thread 0: Holds lock (lock in Modified state on core 0)
; Threads 1-3: Spinning on read (lock in Shared state on cores 1-3)
; ... no cache line bouncing during spin, minimal bus traffic ...
; Thread 0: Releases lock -> invalidates copies
; One thread wins XCHG, others return to spinning on read
```

### Ticket Spinlock

Ensures fairness (FIFO ordering) by using ticket numbers.

```assembly
section .data
align 64
ticket_lock:
    .now_serving: dw 0      ; Current ticket being served
    .next_ticket: dw 0      ; Next ticket to be issued

; Acquire ticket spinlock
ticket_lock_acquire:
    ; Get our ticket number
    mov ax, 1
    lock xadd [ticket_lock.next_ticket], ax  ; Fetch-and-add
    ; AX now contains our ticket number
    
.wait:
    ; Wait until our ticket is being served
    mov bx, [ticket_lock.now_serving]
    cmp ax, bx
    jne .wait
    ; Lock acquired when our ticket matches now_serving
    ret

; Release ticket spinlock
ticket_lock_release:
    lock inc word [ticket_lock.now_serving]  ; Serve next ticket
    ret
```

**Ticket Lock Advantages**:

- Fair: Threads acquire lock in FIFO order
- Prevents starvation
- Predictable latency

**Ticket Lock Disadvantages**:

- All spinning threads monitor same variable (now_serving)
- Cache line still bounces on every release

### MCS (Mellor-Crummey Scott) Lock

Queue-based lock that eliminates cache line bouncing by having each thread spin on its own local variable.

```assembly
section .data
align 64
mcs_lock_tail: dq 0         ; Pointer to tail of queue

struc mcs_node
    .next: resq 1           ; Pointer to next node
    .locked: resq 1         ; Local spin variable
endstruc

; Acquire MCS lock
; Input: RDI = pointer to thread-local mcs_node
mcs_lock_acquire:
    ; Initialize node
    mov qword [rdi + mcs_node.next], 0
    mov qword [rdi + mcs_node.locked], 1
    
    ; Atomically swap node into tail
    mov rax, rdi
    lock xchg [mcs_lock_tail], rax
    ; RAX now contains previous tail (or 0 if we're first)
    
    test rax, rax
    jz .acquired            ; We're first, lock is ours
    
    ; Link ourselves to previous tail
    mov [rax + mcs_node.next], rdi
    
    ; Spin on our local locked variable
.spin:
    mov rbx, [rdi + mcs_node.locked]
    test rbx, rbx
    jnz .spin               ; Spin on LOCAL variable (no contention!)
    
.acquired:
    ret

; Release MCS lock
; Input: RDI = pointer to thread-local mcs_node
mcs_lock_release:
    ; Check if anyone is waiting
    mov rax, [rdi + mcs_node.next]
    test rax, rax
    jnz .has_successor
    
    ; Try to clear tail if we're last
    mov rax, rdi
    xor ebx, ebx
    lock cmpxchg [mcs_lock_tail], rbx
    jnz .has_successor_now  ; Failed, someone added themselves
    ret                     ; Success, we were last
    
.has_successor_now:
    ; Wait for successor to link themselves
.wait_link:
    mov rax, [rdi + mcs_node.next]
    test rax, rax
    jz .wait_link
    
.has_successor:
    ; Unlock successor
    mov qword [rax + mcs_node.locked], 0
    ret
```

**MCS Lock Advantages**:

- Each thread spins on its own cache line
- No cache line bouncing during spinning
- Scalable to many cores
- FIFO fairness

**MCS Lock Disadvantages**:

- More complex implementation
- Requires per-thread storage (node structure)
- Higher overhead for low contention

### Spinlock with Backoff

Reduces contention by introducing delays between acquisition attempts.

```assembly
; Exponential backoff spinlock
section .data
align 64
backoff_lock: dd 0

backoff_spinlock_acquire:
    mov ecx, 1              ; Initial backoff = 1
    
.retry:
    ; Test phase
.test:
    mov eax, [backoff_lock]
    test eax, eax
    jnz .backoff           ; Locked, backoff
    
    ; Test-and-set phase
    mov eax, 1
    lock xchg [backoff_lock], eax
    test eax, eax
    jz .acquired           ; Success!
    
.backoff:
    ; Exponential backoff delay
    mov edx, ecx
.delay:
    pause                   ; Hint to CPU we're spinning
    dec edx
    jnz .delay
    
    ; Increase backoff (with max limit)
    shl ecx, 1              ; Double backoff
    cmp ecx, 4096
    jl .retry
    mov ecx, 4096           ; Cap at maximum
    jmp .retry
    
.acquired:
    ret

backoff_spinlock_release:
    mov dword [backoff_lock], 0
    ret
```

**PAUSE Instruction**: Hints to processor that code is in a spin-wait loop:

- Improves performance on hyper-threaded CPUs
- Reduces power consumption
- Prevents pipeline flushes on loop exit
- Typical latency: ~10-40 cycles

```assembly
; Effect of PAUSE
spin_without_pause:
.loop:
    mov eax, [lock_var]
    test eax, eax
    jnz .loop
    ; Tight loop causes speculation, pipeline flushes on exit
    ret

spin_with_pause:
.loop:
    pause                   ; Hint: spinning
    mov eax, [lock_var]
    test eax, eax
    jnz .loop
    ; Better behavior, less speculation waste
    ret
```

### Spinlock Use Cases and Considerations

**When to Use Spinlocks**:

- Critical sections are very short (< 100 cycles)
- Low to moderate contention
- Real-time systems where sleeping is unacceptable
- Kernel code where sleeping is impossible
- Lock-free algorithm fallback paths

**When NOT to Use Spinlocks**:

- Long critical sections (> 1000 cycles)
- High contention scenarios
- Priority inversion risk (low-priority thread holds lock)
- User-space with thread schedulers (wastes CPU time)

```assembly
; Good spinlock use: Very short critical section
good_spinlock_use:
    call ttas_spinlock_acquire
    
    ; Ultra-short critical section
    inc dword [shared_counter]      ; ~20 cycles
    
    call ttas_spinlock_release
    ret

; Poor spinlock use: Long critical section
poor_spinlock_use:
    call ttas_spinlock_acquire
    
    ; Long critical section
    call complex_computation        ; 10,000+ cycles
    mov [result], eax
    
    call ttas_spinlock_release
    ret
; Other threads waste CPU spinning for milliseconds
```

