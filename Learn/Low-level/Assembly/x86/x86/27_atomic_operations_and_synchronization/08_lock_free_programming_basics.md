## Lock-Free Programming Basics


Lock-free programming uses atomic operations to coordinate threads without traditional locks, avoiding deadlock and reducing contention.

### Lock-Free Data Structures Fundamentals

**Lock-Free Properties**:

- **Lock-Free**: At least one thread makes progress in finite steps
- **Wait-Free**: Every thread makes progress in finite steps (stronger guarantee)
- **Obstruction-Free**: Thread makes progress if it runs in isolation (weaker guarantee)

**ABA Problem**: Value changes from A to B back to A, CAS doesn't detect the intermediate change.

```assembly
; ABA problem demonstration
; Initial: head -> Node1 -> Node2
; Thread 1: Reads head (Node1)
; Thread 2: Removes Node1, removes Node2, adds Node1 back
; Thread 1: CAS succeeds (head still Node1) but list structure changed!
```

**Solutions to ABA**:

1. Use version counters (DCAS)
2. Use hazard pointers
3. Use epoch-based reclamation
4. Tagged pointers (use unused bits for version)

### Lock-Free Stack (Treiber Stack)

```assembly
; Lock-free stack node
struc stack_node
    .next: resq 1           ; Pointer to next node
    .data: resq 1           ; Node data
endstruc

section .data
align 64
stack_head: dq 0            ; Top of stack

; Lock-free push
; Input: RDI = pointer to new node
lockfree_push:
    mov rax, [stack_head]   ; Load current head
.retry:
    mov [rdi + stack_node.next], rax  ; new_node->next = head
    
    ; Try to CAS new node as new head
    mov rbx, rdi
    lock cmpxchg [stack_head], rbx
    jnz .retry              ; Retry if head changed
    ret

; Lock-free pop
; Output: RAX = popped node (or 0 if empty)
lockfree_pop:
.retry:
    mov rax, [stack_head]   ; Load current head
    test rax, rax
    jz .empty               ; Stack empty
    
    mov rbx, [rax + stack_node.next]  ; next = head->next
    
    ; Try to CAS head->next as new head
    lock cmpxchg [stack_head], rbx
    jnz .retry              ; Retry if head changed
    
    ; Successfully popped RAX
    ret
    
.empty:
    xor rax, rax
    ret
```

**ABA Problem in Stack**:

```assembly
; Dangerous scenario:
; Initial: head -> A -> B
; Thread 1: pop(), reads A, preempted
; Thread 2: pop() A, pop() B, push() A
; Current: head -> A (but different A or recycled memory!)
; Thread 1: CAS succeeds, sets head = A->next (DANGLING POINTER!)

; Solution: Use DCAS with version counter
struc versioned_stack
    .head: resq 1           ; Pointer to top node
    .version: resq 1        ; ABA prevention counter
endstruc

section .data
align 64
stack_versioned:
    istruc versioned_stack
        at versioned_stack.head, dq 0
        at versioned_stack.version, dq 0
    iend

; Lock-free push with version counter
; Input: RDI = pointer to new node
lockfree_push_versioned:
    mov rax, [stack_versioned.head]
    mov rdx, [stack_versioned.version]
.retry:
    mov [rdi + stack_node.next], rax  ; new_node->next = head
    
    ; Prepare new version
    mov rbx, rdi                      ; New head pointer
    mov rcx, rdx
    inc rcx                           ; Increment version
    
    ; Atomic DCAS
    lock cmpxchg16b [stack_versioned]
    jnz .retry
    ret

; Lock-free pop with version counter
; Output: RAX = popped node (or 0 if empty)
lockfree_pop_versioned:
.retry:
    mov rax, [stack_versioned.head]
    mov rdx, [stack_versioned.version]
    
    test rax, rax
    jz .empty
    
    mov rbx, [rax + stack_node.next]  ; Next node
    mov rcx, rdx
    inc rcx                           ; Increment version
    
    lock cmpxchg16b [stack_versioned]
    jnz .retry
    
    ; Successfully popped RAX
    ret
    
.empty:
    xor rax, rax
    ret

; Now ABA is prevented:
; Even if pointer cycles back to same address,
; version counter will be different, CAS will fail
```

### Lock-Free Queue (Michael-Scott Queue)

Lock-free FIFO queue with separate head and tail pointers.

```assembly
struc queue_node
    .next: resq 1
    .data: resq 1
endstruc

struc lockfree_queue
    .head: resq 1           ; Dequeue from head
    .head_version: resq 1
    .tail: resq 1           ; Enqueue at tail
    .tail_version: resq 1
endstruc

section .data
align 64
queue:
    istruc lockfree_queue
        at lockfree_queue.head, dq dummy_node
        at lockfree_queue.head_version, dq 0
        at lockfree_queue.tail, dq dummy_node
        at lockfree_queue.tail_version, dq 0
    iend

align 64
dummy_node:
    istruc queue_node
        at queue_node.next, dq 0
        at queue_node.data, dq 0
    iend

; Lock-free enqueue
; Input: RDI = pointer to new node
lockfree_enqueue:
    mov qword [rdi + queue_node.next], 0
    
.retry:
    ; Load tail pointer and version
    mov rax, [queue.tail]
    mov rdx, [queue.tail_version]
    
    ; Load tail->next
    mov r8, [rax + queue_node.next]
    
    ; Check if tail is still consistent
    mov r9, [queue.tail]
    cmp r9, rax
    jne .retry              ; Tail changed, retry
    
    test r8, r8
    jnz .help_enqueue       ; Tail->next not null, help other thread
    
    ; Try to link new node at tail->next
    xor ebx, ebx
    mov rcx, rdi
    lea r10, [rax + queue_node.next]
    lock cmpxchg [r10], rcx
    jnz .retry              ; Failed to link, retry
    
    ; Try to swing tail to new node
    mov rbx, rdi
    mov rcx, rdx
    inc rcx
    lock cmpxchg16b [queue.tail]
    ; Don't care if this fails - another thread will help
    ret
    
.help_enqueue:
    ; Help other thread complete enqueue
    mov rbx, r8             ; Tail->next
    mov rcx, rdx
    inc rcx
    lock cmpxchg16b [queue.tail]
    jmp .retry

; Lock-free dequeue
; Output: RAX = dequeued node (or 0 if empty)
lockfree_dequeue:
.retry:
    ; Load head, tail, and versions
    mov rax, [queue.head]
    mov rdx, [queue.head_version]
    mov r8, [queue.tail]
    
    ; Load head->next
    mov r9, [rax + queue_node.next]
    
    ; Check if head is still consistent
    mov r10, [queue.head]
    cmp r10, rax
    jne .retry
    
    ; Check if queue is empty
    cmp rax, r8
    jne .not_empty
    
    test r9, r9
    jz .empty               ; Head == tail and head->next == null
    
    ; Tail falling behind, help update it
    mov rbx, r9
    mov rcx, [queue.tail_version]
    inc rcx
    lock cmpxchg16b [queue.tail]
    jmp .retry
    
.not_empty:
    ; Queue not empty, try to dequeue
    test r9, r9
    jz .retry               ; Inconsistent state
    
    ; Try to swing head to head->next
    mov rbx, r9
    mov rcx, rdx
    inc rcx
    lock cmpxchg16b [queue.head]
    jnz .retry
    
    ; Successfully dequeued
    mov rax, r9
    ret
    
.empty:
    xor rax, rax
    ret
```

### Lock-Free Reference Counting

Safe memory reclamation in lock-free structures.

```assembly
; Hazard pointer approach
section .data
MAX_THREADS equ 16
MAX_HAZARDS equ 4

align 64
hazard_pointers:
    times MAX_THREADS * MAX_HAZARDS dq 0

; Acquire hazard pointer
; Input: RDI = pointer to protect, RSI = thread ID
acquire_hazard:
    mov rax, rsi
    imul rax, MAX_HAZARDS * 8   ; Thread's hazard pointer array
    lea rbx, [hazard_pointers + rax]
    
    ; Find free slot (value 0)
    xor ecx, ecx
.find_slot:
    cmp qword [rbx + rcx*8], 0
    je .found_slot
    inc ecx
    cmp ecx, MAX_HAZARDS
    jl .find_slot
    ; No free slots - error
    xor rax, rax
    ret
    
.found_slot:
    mov [rbx + rcx*8], rdi  ; Store hazard pointer
    mfence                  ; Ensure visible to other threads
    mov rax, 1              ; Success
    ret

; Release hazard pointer
; Input: RDI = pointer to release, RSI = thread ID
release_hazard:
    mov rax, rsi
    imul rax, MAX_HAZARDS * 8
    lea rbx, [hazard_pointers + rax]
    
    ; Find and clear matching pointer
    xor ecx, ecx
.find_entry:
    cmp [rbx + rcx*8], rdi
    je .found_entry
    inc ecx
    cmp ecx, MAX_HAZARDS
    jl .find_entry
    ret
    
.found_entry:
    mov qword [rbx + rcx*8], 0
    ret

; Check if pointer is hazardous (protected by any thread)
; Input: RDI = pointer to check
; Output: RAX = 1 if hazardous, 0 if safe to reclaim
is_hazardous:
    xor ecx, ecx            ; Thread index
.check_thread:
    mov rax, rcx
    imul rax, MAX_HAZARDS * 8
    lea rbx, [hazard_pointers + rax]
    
    xor edx, edx            ; Hazard index
.check_hazard:
    cmp [rbx + rdx*8], rdi
    je .is_hazardous
    inc edx
    cmp edx, MAX_HAZARDS
    jl .check_hazard
    
    inc ecx
    cmp ecx, MAX_THREADS
    jl .check_thread
    
    xor rax, rax            ; Not hazardous
    ret
    
.is_hazardous:
    mov rax, 1
    ret

; Safe lock-free pop with hazard pointers
; Input: RSI = thread ID
; Output: RAX = popped node (or 0 if empty)
safe_lockfree_pop:
.retry:
    mov rax, [stack_head]
    test rax, rax
    jz .empty
    
    ; Acquire hazard pointer for head
    mov rdi, rax
    call acquire_hazard
    test rax, rax
    jz .retry               ; Failed to acquire hazard
    
    ; Re-check head is still the same
    mov rax, [stack_head]
    cmp rax, rdi
    jne .release_retry      ; Changed, release hazard and retry
    
    ; Load next
    mov rbx, [rdi + stack_node.next]
    
    ; Try to CAS
    mov rax, rdi
    lock cmpxchg [stack_head], rbx
    jnz .release_retry
    
    ; Successfully popped, keep hazard until we're done with node
    mov rax, rdi
    ret
    
.release_retry:
    call release_hazard
    jmp .retry
    
.empty:
    xor rax, rax
    ret

; Deferred reclamation - retire node for later freeing
; Input: RDI = node to retire, RSI = thread ID
retire_node:
    ; Add to thread's retired list
    ; ...
    
    ; Periodically scan retired list and free non-hazardous nodes
    call scan_retired_list
    ret

scan_retired_list:
    ; For each retired node:
    ;   if not is_hazardous(node):
    ;       free(node)
    ; Implementation details omitted for brevity
    ret
```

### Lock-Free Hash Table

```assembly
; Lock-free hash table with chaining
struc hash_node
    .key: resq 1
    .value: resq 1
    .next: resq 1
    .version: resq 1        ; For ABA prevention
endstruc

section .data
HASH_SIZE equ 256
align 64
hash_table:
    times HASH_SIZE * 2 dq 0  ; pointer + version for each bucket

; Lock-free insert
; Input: RDI = key, RSI = value, RDX = new node
lockfree_hash_insert:
    ; Calculate bucket index
    mov rax, rdi
    xor edx, edx
    mov rbx, HASH_SIZE
    div rbx                 ; RDX = key % HASH_SIZE
    
    ; RDX now contains bucket index
    shl rdx, 4              ; Multiply by 16 (pointer + version)
    lea rbx, [hash_table + rdx]
    
.retry:
    ; Load current bucket head and version
    mov rax, [rbx]          ; Head pointer
    mov r8, [rbx + 8]       ; Version
    
    ; Search for existing key
    mov r9, rax
.search:
    test r9, r9
    jz .not_found           ; End of list
    
    cmp [r9 + hash_node.key], rdi
    je .found_existing      ; Key already exists
    
    mov r9, [r9 + hash_node.next]
    jmp .search
    
.not_found:
    ; Key doesn't exist, insert new node at head
    mov r10, [node_to_insert]
    mov [r10 + hash_node.key], rdi
    mov [r10 + hash_node.value], rsi
    mov [r10 + hash_node.next], rax
    
    ; Try to CAS new node as bucket head
    mov rcx, r8
    inc rcx                 ; Increment version
    mov r11, r10
    
    ; We need CMPXCHG16B for pointer + version
    ; RAX:RDX = expected, RBX:RCX = new
    mov rdx, r8
    mov rcx, r8
    inc rcx
    lock cmpxchg16b [rbx]
    jnz .retry
    
    mov rax, 1              ; Success
    ret
    
.found_existing:
    ; Update existing value (could use CAS on value field)
    mov [r9 + hash_node.value], rsi
    mov rax, 1
    ret

; Lock-free lookup
; Input: RDI = key
; Output: RAX = value (or 0 if not found)
lockfree_hash_lookup:
    ; Calculate bucket
    mov rax, rdi
    xor edx, edx
    mov rbx, HASH_SIZE
    div rbx
    
    shl rdx, 4
    lea rbx, [hash_table + rdx]
    
    ; Load bucket head
    mov rax, [rbx]
    
.search:
    test rax, rax
    jz .not_found
    
    cmp [rax + hash_node.key], rdi
    je .found
    
    mov rax, [rax + hash_node.next]
    jmp .search
    
.found:
    mov rax, [rax + hash_node.value]
    ret
    
.not_found:
    xor rax, rax
    ret
```

### Memory Ordering in Lock-Free Code

```assembly
; Example: Lock-free flag + data pattern
section .data
align 64
shared_data: dq 0
align 64
data_ready: dq 0

; Producer (writer thread)
lockfree_producer:
    ; Write data
    mov qword [shared_data], 12345
    
    ; Memory barrier to ensure data write completes before flag
    mfence
    
    ; Set flag
    mov qword [data_ready], 1
    ret

; Consumer (reader thread)
lockfree_consumer:
.wait:
    ; Read flag
    mov rax, [data_ready]
    test rax, rax
    jz .wait
    
    ; Flag set, now safe to read data
    ; x86 TSO model ensures data is visible
    mov rbx, [shared_data]
    ; RBX now contains valid data
    ret

; Relaxed ordering example (careful!)
lockfree_relaxed:
    ; Write data without barrier
    mov qword [shared_data], 12345
    mov qword [data_ready], 1       ; Could be reordered!
    ; On x86, stores are not reordered with stores (TSO)
    ; But on weaker models (ARM, PowerPC), needs barrier
    ret
```

### Practical Lock-Free Patterns

**Single-Producer-Single-Consumer (SPSC) Queue**:

```assembly
; SPSC ring buffer (no CAS needed!)
struc spsc_queue
    .buffer: resq 256       ; Power of 2 size
    .head: resq 1          ; Consumer reads from head
    .tail: resq 1          ; Producer writes to tail
endstruc

section .data
align 64
spsc_q:
    istruc spsc_queue
        times 256 dq 0
        at spsc_queue.head, dq 0
        at spsc_queue.tail, dq 0
    iend

; Producer enqueue (only one producer, no contention)
spsc_enqueue:
    ; Input: RDI = value
    mov rax, [spsc_q.tail]
    mov rbx, rax
    inc rbx
    and rbx, 255            ; Wrap around (256 - 1)
    
    ; Check if queue full
    mov rcx, [spsc_q.head]
    cmp rbx, rcx
    je .full
    
    ; Write value
    mov [spsc_q.buffer + rax*8], rdi
    
    ; Update tail (store release semantics)
    ; On x86, normal store is sufficient due to TSO
    mov [spsc_q.tail], rbx
    
    mov rax, 1              ; Success
    ret
    
.full:
    xor rax, rax            ; Queue full
    ret

; Consumer dequeue (only one consumer, no contention)
spsc_dequeue:
    ; Output: RAX = value (or 0 if empty)
    mov rax, [spsc_q.head]
    mov rbx, [spsc_q.tail]
    
    ; Check if queue empty
    cmp rax, rbx
    je .empty
    
    ; Read value
    mov rcx, [spsc_q.buffer + rax*8]
    
    ; Update head
    inc rax
    and rax, 255
    mov [spsc_q.head], rax
    
    mov rax, rcx            ; Return value
    ret
    
.empty:
    xor rax, rax
    ret

; SPSC is very fast - no atomic operations needed!
; Producer and consumer don't contend for same variables
```

**Work-Stealing Queue**:

```assembly
; Deque with lock-free steal operation
struc work_stealing_deque
    .buffer: resq 256
    .top: resq 1            ; Owner pushes/pops at top
    .bottom: resq 1         ; Thieves steal from bottom
endstruc

; Owner push (private, no atomics)
ws_push:
    ; Input: RDI = value
    mov rax, [deque.top]
    mov [deque.buffer + rax*8], rdi
    inc rax
    mov [deque.top], rax    ; Store-release
    ret

; Owner pop (private, but must handle concurrent steals)
ws_pop:
    mov rax, [deque.top]
    dec rax
    mov [deque.top], rax    ; Store-release
    
    mov rbx, [deque.bottom] ; Load-acquire
    
    cmp rax, rbx
    jl .empty_or_stolen     ; Top < bottom means empty
    
    je .last_item           ; Top == bottom means last item, must CAS
    
    ; Multiple items, we got one
    mov rcx, [deque.buffer + rax*8]
    mov rax, rcx
    ret
    
.last_item:
    ; Last item, race with steals
    inc rbx
    lock cmpxchg [deque.bottom], rbx
    jz .got_last
    
.empty_or_stolen:
    mov [deque.top], rbx    ; Reset top
    xor rax, rax
    ret
    
.got_last:
    mov rax, [deque.buffer + rax*8]
    ret

; Thief steal (lock-free from bottom)
ws_steal:
    mov rax, [deque.bottom] ; Load-acquire
    mov rbx, [deque.top]    ; Load-acquire
    
    cmp rax, rbx
    jge .empty              ; Bottom >= top means empty
    
    ; Try to steal
    mov rcx, [deque.buffer + rax*8]
    inc rax
    lock cmpxchg [deque.bottom], rax
    jnz .retry              ; Failed, retry
    
    mov rax, rcx            ; Return stolen item
    ret
    
.empty:
    xor rax, rax
    ret
    
.retry:
    jmp ws_steal
```

### Debugging Lock-Free Code

```assembly
; Assertions for lock-free invariants
check_lockfree_invariant:
    ; Verify stack head is valid pointer or null
    mov rax, [stack_head]
    test rax, rax
    jz .valid
    
    ; Check pointer is in valid range
    cmp rax, heap_start
    jl .invalid
    cmp rax, heap_end
    jg .invalid
    
.valid:
    ret
    
.invalid:
    ; Trigger debugger or log error
    int3                    ; Breakpoint
    ret

; Performance counter for debugging
section .data
align 64
cas_attempts: dq 0
cas_failures: dq 0

instrumented_cas:
    lock inc qword [cas_attempts]
    
    ; Actual CAS
    lock cmpxchg [target], rbx
    jz .success
    
    lock inc qword [cas_failures]
    
.success:
    ret

; Monitor contention
print_stats:
    mov rax, [cas_failures]
    mov rbx, [cas_attempts]
    ; Calculate failure rate
    ; High failure rate indicates contention
    ret
```

**Key Points**:

- Atomic operations are foundation of lock-free programming
- LOCK prefix ensures atomicity of read-modify-write operations
- XCHG is implicitly atomic without LOCK prefix
- CMPXCHG enables conditional atomic updates (CAS pattern)
- CMPXCHG16B prevents ABA problem with version counters
- x86 TSO memory model is relatively strong but still requires fences
- MFENCE/SFENCE/LFENCE control memory ordering
- Spinlocks should use PAUSE instruction and test-and-test-and-set pattern
- Lock-free algorithms avoid deadlock but require careful design
- ABA problem is major challenge in lock-free data structures
- Hazard pointers enable safe memory reclamation
- Lock-free code typically performs better under low contention
- High contention causes CAS retry storms, degrading performance
- SPSC queues avoid atomics entirely, providing best performance
- Debugging lock-free code is challenging - use invariant checks
- Profile CAS failure rates to identify contention hotspots

**Related Topics for Further Study**: Transactional Memory (Hardware/Software), Sequence locks (seqlocks), Read-Copy-Update (RCU), Memory reclamation schemes (epoch-based, hazard pointers, reference counting), Wait-free algorithms, Persistent memory and atomic operations, Formal verification of concurrent algorithms, Performance analysis of synchronization primitives

---

