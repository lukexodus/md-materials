## Compare-and-Swap Patterns


Compare-and-swap (CAS) is the foundation for many lock-free data structures and synchronization primitives.

### Lock-Free Linked List

```assembly
struc LLNode
    .next   resd 1
    .data   resd 1
endstruc

; Lock-free list insertion at head
ll_insert_head:
    ; Parameter: EAX = new node
    push ebx
    push ecx
    
    mov ebx, eax                ; New node
    
.retry:
    mov eax, [list_head]        ; Read current head
    mov [ebx + LLNode.next], eax ; Link new node to current head
    mov ecx, ebx
    lock cmpxchg [list_head], ecx
    jnz .retry                  ; Retry if head changed
    
    pop ecx
    pop ebx
    ret

; Lock-free list removal (mark-and-sweep approach)
ll_remove:
    ; Parameter: EAX = node to remove
    ; More complex: requires tagged pointers to avoid ABA
    push ebx
    push ecx
    push esi
    
    mov esi, eax                ; Node to remove
    
.find:
    mov eax, [list_head]
    test eax, eax
    jz .not_found
    
    cmp eax, esi
    je .remove_head
    
    ; Search list
    mov ebx, eax
.search:
    mov ecx, [ebx + LLNode.next]
    cmp ecx, esi
    je .remove_middle
    
    mov ebx, ecx
    test ebx, ebx
    jnz .search
    
.not_found:
    xor eax, eax
    pop esi
    pop ecx
    pop ebx
    ret
    
.remove_head:
    mov ebx, [eax + LLNode.next]
    lock cmpxchg [list_head], ebx
    jnz .find                   ; Retry if failed
    pop esi
    pop ecx
    pop ebx
    ret
    
.remove_middle:
    ; EBX points to node before target
    ; ECX is target node
    mov edx, [ecx + LLNode.next]
    mov eax, ecx
    lock cmpxchg [ebx + LLNode.next], edx
    jnz .find
    pop esi
    pop ecx
    pop ebx
    ret
```

### Lock-Free Queue

```assembly
struc QNode
    .next   resd 1
    .data   resd 1
endstruc

struc LockFreeQueue
    .head   resd 1
    .tail   resd 1
endstruc

; Lock-free queue enqueue (Michael-Scott algorithm)
lf_enqueue:
    ; Parameter: EAX = new node
    push ebx
    push ecx
    push edx
    push esi
    
    mov esi, eax                ; New node
    mov dword [esi + QNode.next], 0
    
.retry:
    mov ebx, [queue + LockFreeQueue.tail]
    mov ecx, [ebx + QNode.next]
    
    ; Check if tail is still consistent
    cmp ebx, [queue + LockFreeQueue.tail]
    jne .retry
    
    test ecx, ecx
    jz .try_insert
    
    ; Tail not pointing to last node, help update it
    mov eax, ebx
    lock cmpxchg [queue + LockFreeQueue.tail], ecx
    jmp .retry
    
.try_insert:
    ; Try to link new node
    xor eax, eax
    mov edx, esi
    lock cmpxchg [ebx + QNode.next], edx
    jnz .retry
    
    ; Try to update tail
    mov eax, ebx
    mov edx, esi
    lock cmpxchg [queue + LockFreeQueue.tail], edx
    ; Don't care if this fails, another thread will fix it
    
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

; Lock-free queue dequeue
lf_dequeue:
    push ebx
    push ecx
    push edx
    push esi
    
.retry:
    mov ebx, [queue + LockFreeQueue.head]
    mov esi, [queue + LockFreeQueue.tail]
    mov ecx, [ebx + QNode.next]
    
    ; Check consistency
    cmp ebx, [queue + LockFreeQueue.head]
    jne .retry
    
    cmp ebx, esi
    jne .try_dequeue
    
    ; Queue might be empty or tail falling behind
    test ecx, ecx
    jz .empty
    
    ; Tail falling behind, help update it
    mov eax, esi
    lock cmpxchg [queue + LockFreeQueue.tail], ecx
    jmp .retry
    
.try_dequeue:
    ; Try to swing head to next node
    mov eax, ebx
    mov edx, ecx
    lock cmpxchg [queue + LockFreeQueue.head], edx
    jnz .retry
    
    ; Successfully dequeued
    mov eax, [ecx + QNode.data]
    
    ; EBX points to old dummy node (can be freed)
    
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    
.empty:
    xor eax, eax
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
```

### Spinlock Implementation

```assembly
; Simple test-and-set spinlock
spinlock_acquire:
    mov eax, 1
.spin:
    xchg [lock], eax
    test eax, eax
    jnz .spin
    ret

spinlock_release:
    mov dword [lock], 0
    ret

; Improved spinlock with backoff
spinlock_acquire_backoff:
    mov eax, 1
    mov ecx, 1                  ; Initial backoff
    
.spin:
    xchg [lock], eax
    test eax, eax
    jz .acquired
    
    ; Backoff before retrying
    mov edx, ecx
.backoff:
    pause                       ; Hint to CPU (reduce power)
    dec edx
    jnz .backoff
    
    ; Exponential backoff
    shl ecx, 1
    cmp ecx, MAX_BACKOFF
    jle .spin
    mov ecx, MAX_BACKOFF
    jmp .spin
    
.acquired:
    ret

; Test-and-test-and-set spinlock (TATAS)
; Reduces cache coherency traffic
tatas_spinlock_acquire:
.test:
    cmp dword [lock], 0
    jne .test                   ; Spin on read (no cache invalidation)
    
    ; Lock appears free, try to acquire
    mov eax, 1
    xchg [lock], eax
    test eax, eax
    jnz .test                   ; Failed, back to spinning
    
    ret
```

### Ticket Lock

```assembly
; Ticket lock: Provides fairness (FIFO ordering)
struc TicketLock
    .now_serving    resw 1
    .next_ticket    resw 1
endstruc

ticket_lock_acquire:
    ; Get ticket number
    mov ax, 1
    lock xadd [lock + TicketLock.next_ticket], ax
    ; AX now contains our ticket number

.wait:
    pause
    cmp ax, [lock + TicketLock.now_serving]
    jne .wait        ; Wait for our turn

    ; Lock acquired
    ret

ticket_lock_release:
    lock inc word [lock + TicketLock.now_serving]
    ret

; Ticket lock advantages:
; - Fair: FIFO ordering
; - No starvation
; - Cache-friendly: only one atomic op per acquire

; Example with statistics
ticket_lock_with_stats:
    push ebx

    ; Get ticket
    mov ax, 1
    lock xadd [lock + TicketLock.next_ticket], ax
    mov bx, ax                  ; Save our ticket

    ; Count waits
    xor ecx, ecx

.wait:
    pause
    inc ecx                     ; Count iterations
    cmp ax, [lock + TicketLock.now_serving]
    jne .wait

    ; Record contention metric
    add [total_wait_count], ecx

    pop ebx
    ret
````

### Reader-Writer Lock with CAS

```assembly
; Reader-Writer lock using atomic operations
; Upper 16 bits: writer flag
; Lower 16 bits: reader count

struc RWLock
    .value  resd 1              ; Combined writer/reader state
endstruc

WRITER_BIT equ 0x80000000

; Acquire read lock
rwlock_read_acquire:
.retry:
    mov eax, [rwlock + RWLock.value]
    
    ; Check if writer active
    test eax, WRITER_BIT
    jnz .retry                  ; Wait for writer
    
    ; Increment reader count
    mov ebx, eax
    inc ebx                     ; Add one reader
    lock cmpxchg [rwlock + RWLock.value], ebx
    jnz .retry
    
    ret

; Release read lock
rwlock_read_release:
.retry:
    mov eax, [rwlock + RWLock.value]
    mov ebx, eax
    dec ebx                     ; Remove one reader
    lock cmpxchg [rwlock + RWLock.value], ebx
    jnz .retry
    ret

; Acquire write lock
rwlock_write_acquire:
.retry:
    xor eax, eax                ; Expect no readers or writers
    mov ebx, WRITER_BIT         ; Set writer flag
    lock cmpxchg [rwlock + RWLock.value], ebx
    jnz .retry                  ; Failed, retry
    ret

; Release write lock
rwlock_write_release:
    mov dword [rwlock + RWLock.value], 0
    ret

; Upgrade read lock to write lock (can fail)
rwlock_upgrade:
.retry:
    mov eax, 1                  ; Expect exactly one reader (us)
    mov ebx, WRITER_BIT         ; Set writer flag
    lock cmpxchg [rwlock + RWLock.value], ebx
    jz .success
    
    ; Failed - other readers present
    xor eax, eax                ; Return failure
    ret
    
.success:
    mov eax, 1                  ; Return success
    ret
````

### Semaphore Implementation

```assembly
; Counting semaphore using atomic operations
struc Semaphore
    .count  resd 1
    .max    resd 1
endstruc

; Wait (P operation, decrement)
semaphore_wait:
    push ebx
    
.retry:
    mov eax, [sem + Semaphore.count]
    test eax, eax
    jz .block                   ; No resources available
    
    mov ebx, eax
    dec ebx
    lock cmpxchg [sem + Semaphore.count], ebx
    jnz .retry
    
    pop ebx
    ret
    
.block:
    ; Would block - in real implementation, sleep/yield
    pause
    jmp .retry

; Post (V operation, increment)
semaphore_post:
    push ebx
    
.retry:
    mov eax, [sem + Semaphore.count]
    cmp eax, [sem + Semaphore.max]
    jae .overflow               ; Already at maximum
    
    mov ebx, eax
    inc ebx
    lock cmpxchg [sem + Semaphore.count], ebx
    jnz .retry
    
    pop ebx
    ret
    
.overflow:
    ; Error: semaphore overflow
    pop ebx
    xor eax, eax
    ret
```

### Double-Compare-Single-Swap (DCSS) Emulation

```assembly
; DCSS emulation using CMPXCHG
; Atomically: if ([addr1] == expected1 && [addr2] == expected2)
;                 [addr1] = new_value

; Simplified version (not fully lock-free)
dcss_emulate:
    ; Parameters:
    ; [ebp+8]: addr1
    ; [ebp+12]: expected1
    ; [ebp+16]: new_value
    ; [ebp+20]: addr2
    ; [ebp+24]: expected2
    
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push esi
    
    mov esi, [ebp + 8]          ; addr1
    mov ebx, [ebp + 16]         ; new_value
    
.retry:
    ; Check first location
    mov eax, [ebp + 12]         ; expected1
    mov ecx, [esi]
    cmp eax, ecx
    jne .failed
    
    ; Check second location
    mov edx, [ebp + 20]         ; addr2
    mov ecx, [edx]
    cmp ecx, [ebp + 24]         ; expected2
    jne .failed
    
    ; Both match, try to swap
    lock cmpxchg [esi], ebx
    jnz .retry
    
    ; Success
    mov eax, 1
    jmp .done
    
.failed:
    xor eax, eax
    
.done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop ebp
    ret
```

### Lock-Free Reference Counting

```assembly
struc RefCounted
    .refcount   resd 1
    .data       resd 1
endstruc

; Acquire reference (increment count)
refcount_acquire:
    ; Parameter: EAX = object pointer
    push ebx
    mov ebx, eax
    
.retry:
    mov eax, [ebx + RefCounted.refcount]
    test eax, eax
    jz .failed                  ; Object already destroyed
    
    mov ecx, eax
    inc ecx
    lock cmpxchg [ebx + RefCounted.refcount], ecx
    jnz .retry
    
    mov eax, 1                  ; Success
    pop ebx
    ret
    
.failed:
    xor eax, eax                ; Failure
    pop ebx
    ret

; Release reference (decrement count)
refcount_release:
    ; Parameter: EAX = object pointer
    push ebx
    mov ebx, eax
    
.retry:
    mov eax, [ebx + RefCounted.refcount]
    mov ecx, eax
    dec ecx
    lock cmpxchg [ebx + RefCounted.refcount], ecx
    jnz .retry
    
    ; Check if last reference
    test ecx, ecx
    jnz .done
    
    ; Last reference - destroy object
    mov eax, ebx
    call destroy_object
    
.done:
    pop ebx
    ret
```

### Hazard Pointers for Memory Reclamation

```assembly
; Hazard pointers solve memory reclamation in lock-free structures
; Prevent freeing memory that other threads might access

MAX_HAZARD_POINTERS equ 16

struc HazardPointer
    .pointer    resd 1          ; Protected pointer
    .active     resd 1          ; Is this slot active?
endstruc

; Array of hazard pointers (per-thread)
section .bss
hazard_pointers:
    resb HazardPointer_size * MAX_HAZARD_POINTERS

; Acquire hazard pointer
hazard_acquire:
    ; Parameter: EAX = pointer to protect
    push ebx
    push ecx
    
    ; Find free hazard pointer slot
    mov ecx, MAX_HAZARD_POINTERS
    xor ebx, ebx
    
.find_slot:
    cmp dword [hazard_pointers + ebx * HazardPointer_size + HazardPointer.active], 0
    je .found_slot
    
    inc ebx
    loop .find_slot
    
    ; No free slots
    xor eax, eax
    pop ecx
    pop ebx
    ret
    
.found_slot:
    ; Mark slot active and store pointer
    mov [hazard_pointers + ebx * HazardPointer_size + HazardPointer.pointer], eax
    mov dword [hazard_pointers + ebx * HazardPointer_size + HazardPointer.active], 1
    
    mov eax, ebx                ; Return slot index
    pop ecx
    pop ebx
    ret

; Release hazard pointer
hazard_release:
    ; Parameter: EAX = slot index
    mov dword [hazard_pointers + eax * HazardPointer_size + HazardPointer.active], 0
    ret

; Check if pointer is hazardous (protected by any thread)
is_hazardous:
    ; Parameter: EAX = pointer to check
    push ebx
    push ecx
    
    mov ecx, MAX_HAZARD_POINTERS
    xor ebx, ebx
    
.check_loop:
    cmp dword [hazard_pointers + ebx * HazardPointer_size + HazardPointer.active], 0
    je .next
    
    cmp eax, [hazard_pointers + ebx * HazardPointer_size + HazardPointer.pointer]
    je .is_hazardous
    
.next:
    inc ebx
    loop .check_loop
    
    ; Not hazardous
    xor eax, eax
    pop ecx
    pop ebx
    ret
    
.is_hazardous:
    mov eax, 1
    pop ecx
    pop ebx
    ret

; Safe memory reclamation
safe_free:
    ; Parameter: EAX = pointer to free
    push ebx
    
    ; Check if pointer is hazardous
    call is_hazardous
    test eax, eax
    jnz .defer
    
    ; Safe to free immediately
    call free_memory
    pop ebx
    ret
    
.defer:
    ; Add to deferred free list
    ; Will be freed later when no longer hazardous
    call add_to_deferred_list
    pop ebx
    ret
```

### Transactional Memory Primitives (TSX)

Intel TSX provides hardware transactional memory support through restricted transactional memory (RTM) instructions.

```assembly
; XBEGIN - Start transaction
; XEND - End transaction
; XABORT - Abort transaction
; XTEST - Test if in transaction

; Transaction example
transactional_increment:
    mov ecx, MAX_RETRIES
    
.retry:
    xbegin .fallback            ; Start transaction
    
    ; Transaction body
    mov eax, [shared_counter]
    inc eax
    mov [shared_counter], eax
    
    xend                        ; Commit transaction
    ret
    
.fallback:
    ; Transaction aborted, EAX contains abort status
    ; Bits 0-23: Retry (1 if should retry)
    ; Bits 24-31: Abort code
    
    test eax, 1                 ; Check retry flag
    jz .use_lock                ; Use fallback if can't retry
    
    dec ecx
    jnz .retry
    
.use_lock:
    ; Fall back to lock-based implementation
    call lock_based_increment
    ret

; Check transaction status
check_in_transaction:
    xtest
    jz .not_in_transaction
    
    ; In transaction
    mov eax, 1
    ret
    
.not_in_transaction:
    xor eax, eax
    ret

; Explicit abort
abort_transaction:
    mov eax, 0xFF               ; Abort code
    xabort al
    ret

; Transaction with read-set and write-set tracking
transactional_transfer:
    ; Transfer money between accounts atomically
    
    xbegin .fallback
    
    ; Read balances
    mov eax, [account1_balance]
    mov ebx, [account2_balance]
    
    ; Check sufficient funds
    cmp eax, [amount]
    jl .abort_insufficient
    
    ; Perform transfer
    sub eax, [amount]
    add ebx, [amount]
    
    mov [account1_balance], eax
    mov [account2_balance], ebx
    
    xend
    ret
    
.abort_insufficient:
    mov al, 1                   ; Insufficient funds code
    xabort al
    
.fallback:
    ; Use lock-based fallback
    call lock_based_transfer
    ret
```

### Performance Comparison: Different Synchronization Methods

```assembly
; Benchmark different synchronization approaches
benchmark_sync_methods:
    ; Test 1: LOCK prefix
    rdtsc
    mov esi, eax
    mov ecx, 1000000
.test_lock:
    lock inc dword [counter]
    loop .test_lock
    rdtsc
    sub eax, esi
    mov [time_lock], eax
    
    ; Test 2: XCHG (implicit lock)
    rdtsc
    mov esi, eax
    mov ecx, 1000000
.test_xchg:
    mov eax, 1
    xchg [counter], eax
    loop .test_xchg
    rdtsc
    sub eax, esi
    mov [time_xchg], eax
    
    ; Test 3: CMPXCHG loop
    rdtsc
    mov esi, eax
    mov ecx, 1000000
.test_cas:
.cas_retry:
    mov eax, [counter]
    mov ebx, eax
    inc ebx
    lock cmpxchg [counter], ebx
    jnz .cas_retry
    loop .test_cas
    rdtsc
    sub eax, esi
    mov [time_cas], eax
    
    ; Test 4: Non-atomic (baseline)
    rdtsc
    mov esi, eax
    mov ecx, 1000000
.test_normal:
    inc dword [counter]
    loop .test_normal
    rdtsc
    sub eax, esi
    mov [time_normal], eax
    
    ; Typical results (single-threaded):
    ; Normal: ~1 cycle per op
    ; LOCK: ~20 cycles per op
    ; XCHG: ~25 cycles per op
    ; CAS: ~30 cycles per op (with retries)
    
    ret
```

### Advanced: Lock Elision and Hardware Lock Elision (HLE)

```assembly
; Hardware Lock Elision hints (XACQUIRE/XRELEASE)
; Available on some Intel processors

; With HLE, locks may be elided if no conflicts occur
hle_spinlock_acquire:
    mov eax, 1
    xacquire
    xchg [lock], eax            ; May execute transactionally
    test eax, eax
    jnz hle_spinlock_acquire
    ret

hle_spinlock_release:
    xrelease
    mov dword [lock], 0         ; May commit transaction
    ret

; HLE with fallback
hle_with_fallback:
    mov ecx, MAX_ATTEMPTS
    
.try_hle:
    mov eax, 1
    xacquire
    xchg [lock], eax
    test eax, eax
    jz .acquired
    
    ; HLE failed, retry
    dec ecx
    jnz .try_hle
    
    ; Fall back to regular lock
    jmp regular_spinlock_acquire
    
.acquired:
    ret

; Benefits of HLE:
; - Reduced cache coherency traffic when no conflicts
; - Better performance for uncontended locks
; - Automatic fallback to regular locks on conflict
```

**Key Points:**

- XCHG atomically exchanges values and is implicitly atomic for memory operands without requiring the LOCK prefix
- CMPXCHG performs atomic compare-and-swap operations fundamental to lock-free algorithms, with variants supporting 8-byte (CMPXCHG8B) and 16-byte (CMPXCHG16B) atomic updates
- XADD atomically adds to memory while returning the original value, enabling efficient atomic counters and fetch-and-add operations
- The LOCK prefix ensures read-modify-write atomicity in multi-processor systems through cache line locking when possible, falling back to bus locking when operands cross cache line boundaries
- MFENCE provides full memory barrier semantics ensuring all loads and stores complete before subsequent operations, while LFENCE and SFENCE order loads and stores respectively
- Memory barriers prevent both compiler and processor reordering of memory operations, essential for implementing synchronization primitives with correct ordering semantics
- Lock-free data structures using CAS require careful handling of the ABA problem through techniques like tagged pointers with version counters
- Spinlocks with test-and-test-and-set (TATAS) reduce cache coherency traffic by reading before atomic operations, improving performance under contention
- Ticket locks provide FIFO fairness guarantees preventing starvation while maintaining good cache behavior with only one atomic operation per acquisition
- Hardware transactional memory (TSX) enables speculative execution of critical sections with automatic rollback on conflicts, providing lock-free semantics with fallback mechanisms

---

