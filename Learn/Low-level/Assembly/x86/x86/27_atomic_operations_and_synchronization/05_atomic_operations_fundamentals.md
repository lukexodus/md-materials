## Atomic Operations Fundamentals


**Atomicity Definition**: An atomic operation appears to execute instantaneously from the perspective of other threads—either the operation completes entirely, or it doesn't execute at all. No thread can observe a partially-completed atomic operation.

**Hardware Support**: x86 processors provide hardware mechanisms for atomic operations through:

- **Bus locking**: Locks the memory bus for the duration of the operation
- **Cache locking**: Locks the cache line containing the operand (faster than bus locking)
- **LOCK prefix**: Makes read-modify-write instructions atomic
- **Implicit atomicity**: Some operations are naturally atomic on x86

### Naturally Atomic Operations

On x86, certain operations are guaranteed atomic without explicit locking:

**Atomic Reads and Writes** (with alignment constraints):

```assembly
; Naturally atomic operations (aligned operands)
atomic_read_write:
    ; 8-bit read/write - always atomic
    mov al, [byte_var]          ; Atomic read
    mov [byte_var], al          ; Atomic write
    
    ; 16-bit read/write - atomic if aligned to 2-byte boundary
    mov ax, [word_var]          ; Atomic if word_var % 2 == 0
    mov [word_var], ax
    
    ; 32-bit read/write - atomic if aligned to 4-byte boundary
    mov eax, [dword_var]        ; Atomic if dword_var % 4 == 0
    mov [dword_var], eax
    
    ; 64-bit read/write (64-bit mode) - atomic if aligned to 8-byte boundary
    mov rax, [qword_var]        ; Atomic if qword_var % 8 == 0
    mov [qword_var], rax
    ret

; Non-atomic due to misalignment
section .data
align 1
misaligned_dword: dd 0

non_atomic_access:
    mov eax, [misaligned_dword] ; NOT atomic if crosses cache line boundary
    ; Could read partial old + partial new value in concurrent scenario
    ret
```

**Cache Line Atomicity**: The critical constraint is that the operand must not cross a cache line boundary (64 bytes on modern x86).

```assembly
; Demonstrating cache line boundary issue
section .data
align 64
cache_line_data:
    times 63 db 0
    dd 0                        ; Starts at byte 63, crosses to byte 67
                                ; Spans two cache lines!

cross_boundary_access:
    mov eax, [cache_line_data + 63]  ; NOT atomic - crosses cache line
    ; Could see inconsistent data if another thread writes simultaneously
    ret

; Proper alignment
align 64
cache_line_data_aligned:
    times 60 db 0               ; Padding
    dd 0                        ; Aligned within single cache line

aligned_access:
    mov eax, [cache_line_data_aligned + 60]  ; Atomic - within cache line
    ret
```

### LOCK Prefix

The LOCK prefix makes read-modify-write instructions atomic by ensuring exclusive access during the entire operation.

**LOCK-Compatible Instructions**:

```assembly
; Arithmetic operations
lock add [memory], reg
lock sub [memory], reg
lock adc [memory], reg
lock sbb [memory], reg

; Bitwise operations
lock and [memory], reg
lock or [memory], reg
lock xor [memory], reg

; Increment/decrement
lock inc [memory]
lock dec [memory]

; Negation/complement
lock neg [memory]
lock not [memory]

; Bit test operations
lock bts [memory], bit      ; Bit test and set
lock btr [memory], bit      ; Bit test and reset
lock btc [memory], bit      ; Bit test and complement

; Exchange operations (implicitly locked)
xchg [memory], reg          ; LOCK prefix implicit
cmpxchg [memory], reg       ; Requires explicit LOCK for atomicity
```

**LOCK Prefix Behavior**:

```assembly
; Non-atomic increment (race condition)
non_atomic_increment:
    mov eax, [counter]      ; Read
    inc eax                 ; Modify
    mov [counter], eax      ; Write
    ret
; Race condition: Two threads can read same value, both increment,
; one write overwrites the other - lost update

; Atomic increment
atomic_increment:
    lock inc dword [counter]
    ret
; Hardware ensures exclusive access during entire read-modify-write
; No lost updates possible
```

**Lock Implementation**: Modern processors use cache line locking when possible:

```
1. Request For Ownership (RFO) - Acquire cache line in Exclusive/Modified state
2. Perform read-modify-write on cache line
3. Release exclusivity
4. Other cores see the complete operation atomically

If cache line is shared or uncacheable:
1. Lock memory bus (expensive)
2. Perform operation with exclusive memory access
3. Unlock bus
```

```assembly
; Comparing locked vs unlocked performance
section .data
align 64
shared_counter: dd 0

; Without LOCK - fast but incorrect with multiple threads
fast_but_wrong:
    inc dword [shared_counter]  ; ~1 cycle
    ret

; With LOCK - correct but slower
correct_atomic:
    lock inc dword [shared_counter]  ; ~20-100 cycles depending on contention
    ret

; Lock cost depends on:
; - Cache line state (Exclusive: fast, Shared/Invalid: slow)
; - Memory type (cached vs uncached)
; - Contention level
```

### Exchange Operations

**XCHG - Exchange**: Atomically swaps register and memory (implicitly locked).

```assembly
; XCHG is implicitly atomic
atomic_exchange:
    mov eax, 42
    xchg [memory], eax      ; Atomic swap, no LOCK prefix needed
    ; EAX now contains old memory value
    ; Memory now contains 42
    ret

; Use case: Simple spinlock
simple_spinlock_xchg:
    mov eax, 1              ; Locked state
.spin:
    xchg [lock_var], eax    ; Atomic swap
    test eax, eax           ; Was it unlocked (0)?
    jnz .spin               ; If not, spin
    ; Lock acquired
    ret

unlock_xchg:
    mov dword [lock_var], 0 ; Release lock
    ret
```

**CMPXCHG - Compare and Exchange**: Atomically compares memory with register and conditionally updates.

```assembly
; CMPXCHG operation
; Compare memory with EAX, if equal: store source to memory, set ZF
; If not equal: load memory to EAX, clear ZF
compare_and_swap:
    mov eax, expected_value
    mov ebx, new_value
    lock cmpxchg [memory], ebx
    jz .success             ; ZF set if exchange occurred
    
.failure:
    ; EAX now contains actual memory value
    ; Memory unchanged
    jmp .retry
    
.success:
    ; Memory updated to new_value
    ret
```

**CMPXCHG8B/CMPXCHG16B - Double-width Compare and Exchange**:

```assembly
; CMPXCHG8B - 64-bit compare and exchange (32-bit mode)
cmpxchg8b_example:
    ; Compare memory with EDX:EAX
    ; If equal: store ECX:EBX to memory
    mov eax, expected_low
    mov edx, expected_high
    mov ebx, new_low
    mov ecx, new_high
    
    lock cmpxchg8b [memory64]
    jz .success
    ; Failure: EDX:EAX loaded with actual memory value
.success:
    ret

; CMPXCHG16B - 128-bit compare and exchange (64-bit mode)
cmpxchg16b_example:
    ; Compare memory with RDX:RAX
    ; If equal: store RCX:RBX to memory
    mov rax, expected_low
    mov rdx, expected_high
    mov rbx, new_low
    mov rcx, new_high
    
    lock cmpxchg16b [memory128]
    jz .success
.success:
    ret

; Use case: Lock-free linked list node replacement
replace_list_node:
    ; Node structure: [next_ptr | data]
    mov rax, [current_node]     ; Expected next pointer
    mov rdx, [current_node + 8] ; Expected data
    mov rbx, [new_next]         ; New next pointer
    mov rcx, [new_data]         ; New data
    
    lock cmpxchg16b [current_node]
    jz .replaced
    ; Another thread modified node, retry
    jmp replace_list_node
.replaced:
    ret
```

### Memory Ordering and Barriers

x86 has a relatively strong memory model (Total Store Order - TSO), but still requires explicit barriers in some cases.

**x86 Memory Ordering Guarantees**:

- Loads are not reordered with other loads
- Stores are not reordered with other stores
- Stores are not reordered with prior loads
- Loads MAY be reordered with prior stores (store-load reordering)
- Atomic operations are not reordered with other atomic operations

```assembly
; Store-load reordering example
; Thread 1:
thread1_reorder:
    mov [data], eax         ; Store to data
    mov ebx, [flag]         ; Load from flag
    ; Load could execute before store completes!
    ret

; Thread 2:
thread2_reorder:
    mov [flag], ecx         ; Store to flag
    mov edx, [data]         ; Load from data
    ; Load could execute before store completes!
    ret

; Possible outcome: Both threads see old values
; Despite stores appearing before loads in program order
```

**Memory Fence Instructions**:

```assembly
; MFENCE - Memory fence (full barrier)
full_barrier:
    mov [data], eax         ; Store
    mfence                  ; Wait for all prior loads/stores to complete
    mov ebx, [flag]         ; Load
    ; Guarantees store completes before load begins
    ret

; SFENCE - Store fence
store_barrier:
    mov [data1], eax        ; Store
    mov [data2], ebx        ; Store
    sfence                  ; Wait for all prior stores to complete
    ; Subsequent stores/loads won't execute until these stores complete
    ret

; LFENCE - Load fence
load_barrier:
    mov eax, [data1]        ; Load
    lfence                  ; Wait for all prior loads to complete
    mov ebx, [data2]        ; Load
    ; Second load won't execute until first completes
    ret

; LOCK prefix - Implicit full fence
lock_as_barrier:
    mov [data], eax         ; Store
    lock add dword [dummy], 0  ; Acts as full memory barrier
    mov ebx, [flag]         ; Load
    ; LOCK implies MFENCE semantics
    ret
```

**Acquire-Release Semantics**:

```assembly
; Acquire semantics - prevents reordering of subsequent operations before the acquire
acquire_load:
    mov eax, [lock_var]     ; Acquire load
    ; Implicit load barrier - subsequent loads/stores can't move before this
    ; (x86 provides this naturally for loads)
    
    ; All these operations stay after acquire
    mov ebx, [protected_data1]
    mov ecx, [protected_data2]
    ret

; Release semantics - prevents reordering of prior operations after the release
release_store:
    ; All these operations stay before release
    mov [protected_data1], eax
    mov [protected_data2], ebx
    
    mfence                  ; Ensure stores complete (or use LOCK)
    mov [lock_var], 0       ; Release store
    ret

; Together: Critical section with acquire-release
critical_section_example:
    ; Acquire
.acquire:
    mov eax, 1
    lock xchg [lock_var], eax
    test eax, eax
    jnz .acquire
    
    ; Critical section - protected operations
    mov eax, [shared_data]
    inc eax
    mov [shared_data], eax
    
    ; Release
    mov dword [lock_var], 0
    ret
```

