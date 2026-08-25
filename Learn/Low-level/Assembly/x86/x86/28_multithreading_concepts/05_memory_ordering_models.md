## Memory Ordering Models


Memory ordering defines the order in which memory operations become visible to other processors. Different architectures provide different guarantees, and x86 has one of the strongest memory models.

### x86-64 Memory Ordering Model

The x86-64 architecture follows a **Total Store Ordering (TSO)** model, which provides strong ordering guarantees:

**Guaranteed orderings:**

- **Loads are not reordered with loads**: Earlier loads complete before later loads
- **Stores are not reordered with stores**: Earlier stores become visible before later stores
- **Stores are not reordered with earlier loads**: A load followed by a store executes in order
- **Locked instructions have total order**: All processors agree on the order of locked operations
- **Loads are not reordered with earlier locked instructions**
- **Stores are not reordered with earlier locked instructions**

**Allowed reordering:**

- **Loads may be reordered with later stores**: A load can bypass a store to a different location (Store-Load reordering)

```nasm
; This reordering is possible on x86
mov [flag], 1      ; Store
mov eax, [data]    ; Load - may execute before the store becomes visible to others
```

### Store Buffer and Memory Reordering

Modern x86 processors use store buffers for performance. When a CPU executes a store, the value goes into a store buffer first, then eventually commits to cache/memory. This creates the illusion of Store-Load reordering:

```nasm
; Thread 1
mov [x], 1         ; Store to x (goes to store buffer)
mov eax, [y]       ; Load from y (may read before x is visible to Thread 2)

; Thread 2
mov [y], 1         ; Store to y (goes to store buffer)
mov ebx, [x]       ; Load from x (may read before y is visible to Thread 1)

; Possible outcome: eax=0 and ebx=0 (both loads see old values)
```

This happens because:

- Each thread's stores go to its local store buffer
- Loads can read from other caches before the stores drain to memory
- Each thread sees its own writes immediately (store forwarding)
- Other threads see the writes with delay

### Memory Barriers (Fences)

Memory fences prevent reordering and ensure visibility:

#### MFENCE (Memory Fence)

```nasm
mfence    ; Full memory barrier
          ; All loads/stores before complete before any loads/stores after
```

- Serializes all memory operations
- Ensures stores drain from the store buffer
- Prevents all reordering across the fence
- Highest ordering guarantee, most expensive

#### SFENCE (Store Fence)

```nasm
sfence    ; Store fence
          ; All stores before complete before any stores after
```

- Orders stores only
- Ensures earlier stores are visible before later stores
- Does not affect load ordering
- Useful for write-combining operations, non-temporal stores

#### LFENCE (Load Fence)

```nasm
lfence    ; Load fence
          ; All loads before complete before any loads after
```

- Orders loads only
- Prevents speculative execution of loads
- Used primarily for security (Spectre mitigation)
- On x86, loads are already ordered, but LFENCE prevents speculation

**Example: Dekker's algorithm with MFENCE:**

```nasm
; Thread 1
mov [flag1], 1
mfence                  ; Ensure flag1=1 is visible
mov eax, [flag2]        ; Now read flag2
test eax, eax
je .critical_section

; Thread 2
mov [flag2], 1
mfence                  ; Ensure flag2=1 is visible
mov eax, [flag1]        ; Now read flag1
test eax, eax
je .critical_section
```

Without `MFENCE`, both threads might read the other's flag as 0 and both enter the critical section.

### Implicit Barriers

Certain x86 instructions provide implicit memory ordering:

**LOCK prefix:**

```nasm
lock inc dword [counter]    ; Acts as full memory barrier
```

- Any instruction with LOCK prefix acts as a full memory barrier
- All prior memory operations complete before the locked operation
- All subsequent memory operations wait for the locked operation

**XCHG with memory:**

```nasm
xchg [mem], eax    ; Implicit LOCK, full barrier
```

- `XCHG` with memory operand has implicit LOCK
- Provides full barrier semantics automatically

**Serializing instructions:**

```nasm
cpuid              ; Serializing instruction
                   ; Waits for all prior instructions to complete
                   ; Prevents later instructions from starting
```

Instructions like `CPUID`, `IRET`, `MOV to/from control registers` are serializing.

### Acquire and Release Semantics

While x86 doesn't have explicit acquire/release instructions like ARM, the concepts apply:

**Acquire semantics** (load-acquire): Operations after the acquire cannot move before it. **Release semantics** (store-release): Operations before the release cannot move after it.

On x86, regular loads already have acquire semantics (loads don't reorder with later operations), and stores nearly have release semantics (stores don't reorder with earlier operations). The only concern is Store-Load reordering.

**Example: Lock acquisition (acquire semantics):**

```nasm
.spin:
    mov eax, 0
    mov ebx, 1
    lock cmpxchg [lock], ebx    ; Try to acquire lock
    jne .spin                    ; Spin if failed
    ; LOCK provides full barrier - acquire semantics guaranteed
    ; Critical section code here
```

**Example: Lock release (release semantics):**

```nasm
    ; Critical section code
    mov dword [lock], 0         ; Release lock
    ; On x86, this store won't reorder with earlier operations
    ; (stores don't reorder with earlier stores/loads)
    ; However, for strict release, use:
    mfence
    mov dword [lock], 0
    ; Or use locked operation:
    lock mov dword [lock], 0    ; Not valid syntax
    xchg [lock], eax            ; Alternative with implicit LOCK
```

### Practical Examples

**Message passing pattern:**

```nasm
; Producer thread
mov [data], eax        ; Write data
mfence                 ; Ensure data is visible
mov [flag], 1          ; Signal data ready

; Consumer thread
.wait:
    mov eax, [flag]    ; Check if data ready
    test eax, eax
    je .wait
mfence                 ; Ensure we see latest data
mov ebx, [data]        ; Read data
```

**Double-checked locking:**

```nasm
; Check without lock first
mov eax, [initialized]
test eax, eax
jne .done

; Acquire lock
.acquire:
    xor eax, eax
    mov ebx, 1
    lock cmpxchg [lock], ebx
    jne .acquire

; Check again with lock held
mov eax, [initialized]
test eax, eax
jne .release_lock

; Initialize
call initialize_data
mfence                      ; Ensure initialization visible
mov [initialized], 1        ; Mark as initialized

.release_lock:
    mov dword [lock], 0

.done:
    ; Use initialized data
```

**Key Points:**

- x86-64 uses Total Store Ordering (TSO), one of the strongest memory models
- Only Store-Load reordering is allowed (loads can bypass earlier stores)
- MFENCE provides full memory barrier, SFENCE orders stores, LFENCE prevents speculation
- LOCK prefix provides full barrier semantics
- XCHG with memory has implicit LOCK and barrier semantics
- Store buffers are the primary cause of visible reordering on x86

