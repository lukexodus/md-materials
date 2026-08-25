## Atomic Instructions


Atomic instructions guarantee that memory read-modify-write operations execute as single, indivisible units, preventing other processors from observing intermediate states.

### XCHG - Atomic Exchange

The XCHG instruction atomically exchanges values between a register and memory location, or between two registers. When used with memory, XCHG is implicitly atomic even without the LOCK prefix.

```assembly
; XCHG syntax: xchg dest, src
; Atomically swaps contents of dest and src

; Example: Atomic variable swap
atomic_swap:
    mov eax, new_value
    xchg [shared_var], eax      ; Atomic exchange
    ; EAX now contains old value
    ; [shared_var] now contains new_value
    ; No other processor can see intermediate state
    ret

; Simple spinlock using XCHG
acquire_spinlock:
    mov eax, 1                  ; Locked state
.spin:
    xchg [lock_var], eax        ; Try to acquire lock
    test eax, 0                 ; Check if was unlocked (0)
    jnz .spin                   ; If locked, spin
    ; Lock acquired
    ret

release_spinlock:
    mov dword [lock_var], 0     ; Release lock
    ret

; Register-to-register XCHG (also atomic, single cycle)
xchg eax, ebx                   ; Swap EAX and EBX
xchg ecx, edx                   ; Swap ECX and EDX

; XCHG characteristics:
; - Always atomic for memory operations
; - Implicit LOCK prefix for memory operands
; - Can be slower than MOV due to cache coherency protocol
; - Causes full memory barrier (see below)
```

**XCHG Use Cases:**

```assembly
; Thread-safe queue tail pointer update
enqueue_item:
    mov eax, [new_node]
.retry:
    mov ecx, [queue_tail]       ; Read current tail
    mov [new_node + Node.next], ecx  ; Link new node
    xchg [queue_tail], eax      ; Atomically update tail
    ; EAX contains old tail, link it to new node
    mov [eax + Node.next], ecx
    ret

; Atomic counter increment using XCHG (inefficient, see XADD)
increment_with_xchg:
.retry:
    mov eax, [counter]
    mov ebx, eax
    inc ebx
    xchg [counter], ebx         ; Try to store new value
    cmp eax, ebx                ; Check if another thread changed it
    jne .retry                  ; If changed, retry
    ret
```

### CMPXCHG - Compare and Exchange

CMPXCHG performs an atomic compare-and-swap operation, fundamental for lock-free algorithms and synchronization primitives.

```assembly
; CMPXCHG syntax: cmpxchg [mem], reg
; Compares EAX with [mem]:
;   If equal: ZF=1, [mem] = reg
;   If not equal: ZF=0, EAX = [mem]
; Must use LOCK prefix for multi-processor atomicity

; Basic CMPXCHG example
atomic_compare_and_swap:
    mov eax, expected_value     ; Compare against this
    mov ebx, new_value          ; Store this if equal
    lock cmpxchg [shared_var], ebx
    jz .success                 ; ZF=1 means swap succeeded
    
.failure:
    ; EAX now contains actual value
    ; Can retry with updated expected value
    ret
    
.success:
    ; Swap succeeded
    ret

; CMPXCHG8B - 64-bit compare and exchange on 32-bit systems
; Compares EDX:EAX with [mem64]:
;   If equal: [mem64] = ECX:EBX
;   If not equal: EDX:EAX = [mem64]

atomic_cas_64bit:
    mov eax, [expected_lo]      ; Expected low 32 bits
    mov edx, [expected_hi]      ; Expected high 32 bits
    mov ebx, [new_lo]           ; New low 32 bits
    mov ecx, [new_hi]           ; New high 32 bits
    lock cmpxchg8b [shared_var64]
    jz .success
    ; EDX:EAX contains actual value
    ret

; CMPXCHG16B - 128-bit compare and exchange (64-bit mode)
; Uses RAX, RDX, RBX, RCX for 128-bit values
atomic_cas_128bit:
    mov rax, [expected_lo]
    mov rdx, [expected_hi]
    mov rbx, [new_lo]
    mov rcx, [new_hi]
    lock cmpxchg16b [shared_var128]
    jz .success
    ret
```

**CMPXCHG-Based Algorithms:**

```assembly
; Lock-free stack push using CMPXCHG
lockfree_push:
    ; Parameters: EAX = node to push
    push ebx
    push ecx
    
    mov ebx, eax                ; Node to push
    
.retry:
    mov eax, [stack_top]        ; Read current top
    mov [ebx + Node.next], eax  ; Link new node to current top
    mov ecx, ebx                ; New top will be our node
    lock cmpxchg [stack_top], ecx
    jnz .retry                  ; If failed, retry
    
    pop ecx
    pop ebx
    ret

; Lock-free stack pop
lockfree_pop:
    push ebx
    
.retry:
    mov eax, [stack_top]        ; Read current top
    test eax, eax
    jz .empty                   ; Stack is empty
    
    mov ebx, [eax + Node.next]  ; Get next node
    lock cmpxchg [stack_top], ebx
    jnz .retry                  ; If failed, retry
    
    ; EAX contains popped node
    pop ebx
    ret
    
.empty:
    xor eax, eax                ; Return NULL
    pop ebx
    ret

; Atomic increment using CMPXCHG (better approaches exist)
atomic_increment_cas:
.retry:
    mov eax, [counter]          ; Read current value
    mov ebx, eax
    inc ebx                     ; Calculate new value
    lock cmpxchg [counter], ebx
    jnz .retry                  ; Retry on failure
    ret

; ABA problem demonstration
; Problem: Value changes from A to B and back to A
; CMPXCHG succeeds but intermediate change was missed

lockfree_pop_with_aba:
    ; Thread 1: Reads top = node_A
    mov eax, [stack_top]
    
    ; Thread 2: Pops node_A, pops node_B, pushes node_A back
    ; Stack top is node_A again, but structure has changed
    
    ; Thread 1: CAS succeeds even though stack was modified!
    mov ebx, [eax + Node.next]
    lock cmpxchg [stack_top], ebx  ; Succeeds incorrectly
    
    ; Solution: Use version counter or tagged pointers
    ret
```

**ABA Problem Solution - Tagged Pointers:**

```assembly
; Use upper bits as version counter (assumes pointers < 4GB)
struc TaggedPointer
    .pointer    resd 1          ; Lower 32 bits: actual pointer
    .version    resd 1          ; Upper 32 bits: version counter
endstruc

lockfree_push_tagged:
    push ebx
    push ecx
    push esi
    push edi
    
    mov esi, [new_node]         ; Node to push
    
.retry:
    ; Read tagged pointer atomically
    mov eax, [stack_top + TaggedPointer.pointer]
    mov edx, [stack_top + TaggedPointer.version]
    
    ; Link new node
    mov [esi + Node.next], eax
    
    ; Prepare new tagged pointer
    mov ebx, esi                ; New pointer
    mov ecx, edx
    inc ecx                     ; Increment version
    
    ; Atomic compare-exchange of 64-bit value
    lock cmpxchg8b [stack_top]
    jnz .retry
    
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
```

### XADD - Exchange and Add

XADD atomically adds a value to memory and returns the original value, useful for atomic counters and fetch-and-add operations.

```assembly
; XADD syntax: xadd [mem], reg
; Atomically:
;   temp = [mem]
;   [mem] = [mem] + reg
;   reg = temp
; Requires LOCK prefix for multi-processor atomicity

; Atomic increment with fetch-old
atomic_fetch_and_increment:
    mov eax, 1
    lock xadd [counter], eax
    ; EAX now contains value before increment
    ; [counter] has been incremented
    ret

; Atomic decrement with fetch-old
atomic_fetch_and_decrement:
    mov eax, -1
    lock xadd [counter], eax
    ; EAX contains value before decrement
    ret

; Atomic add with fetch-old
atomic_fetch_and_add:
    ; Parameter: EBX = value to add
    mov eax, ebx
    lock xadd [counter], eax
    ; EAX contains old value
    ; Can check for overflow, etc.
    ret

; Reference counting implementation
addref:
    mov eax, 1
    lock xadd [object + RefCount.count], eax
    inc eax                     ; EAX = new count
    ret

release:
    mov eax, -1
    lock xadd [object + RefCount.count], eax
    dec eax                     ; EAX = new count
    jnz .not_zero
    
    ; Count reached zero, destroy object
    call destroy_object
    
.not_zero:
    ret

; Work distribution using XADD
get_next_work_item:
    mov eax, 1
    lock xadd [work_index], eax
    ; EAX contains index for this thread
    cmp eax, [total_work_items]
    jae .no_more_work
    
    ; Calculate work item address
    imul eax, WORK_ITEM_SIZE
    add eax, work_array
    ret
    
.no_more_work:
    xor eax, eax
    ret
```

### Atomic Bit Operations

x86 provides atomic bit test and modify instructions useful for bit flags and bitmaps.

```assembly
; BTS - Bit Test and Set
; Atomically sets bit, returns old bit value in CF

lock bts dword [bitmap], 5      ; Set bit 5, CF = old bit value
jc .was_set                     ; Jump if bit was already set

; BTC - Bit Test and Complement
lock btc dword [flags], 3       ; Toggle bit 3

; BTR - Bit Test and Reset
lock btr dword [bitmap], 7      ; Clear bit 7

; Example: Thread-safe bitmap allocator
allocate_bit:
    xor ecx, ecx                ; Start from bit 0
    
.scan:
    lock bts [bitmap], ecx      ; Try to set bit
    jnc .allocated              ; If was clear, we got it
    
    inc ecx
    cmp ecx, MAX_BITS
    jl .scan
    
    ; No bits available
    mov eax, -1
    ret
    
.allocated:
    mov eax, ecx                ; Return bit index
    ret

free_bit:
    ; Parameter: EAX = bit index
    lock btr [bitmap], eax      ; Clear bit
    ret

; Atomic flag setting
set_flag:
    ; Parameter: EBX = flag bit number
    lock bts [flags], ebx
    ret

test_and_clear_flag:
    ; Parameter: EBX = flag bit number
    lock btr [flags], ebx
    jc .was_set
    xor eax, eax                ; Return 0 (was clear)
    ret
.was_set:
    mov eax, 1                  ; Return 1 (was set)
    ret
```

