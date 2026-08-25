## Race Conditions and Data Races


### Race Condition

A race condition occurs when the correctness of a program depends on the relative timing or interleaving of multiple threads. The outcome becomes unpredictable because it depends on which thread executes first or how their operations are scheduled.

In x86 assembly, race conditions commonly appear when multiple threads access shared memory locations without proper synchronization. Consider a simple counter increment:

```nasm
mov eax, [counter]    ; Thread reads current value
inc eax               ; Thread increments
mov [counter], eax    ; Thread writes back
```

If two threads execute this sequence simultaneously, both might read the same initial value, increment it, and write back the same result—effectively losing one increment.

### Data Race

A data race is a specific type of race condition where:

- Two or more threads access the same memory location
- At least one access is a write
- The accesses are not synchronized
- The accesses are not ordered by happens-before relationships

Data races cause undefined behavior. Unlike general race conditions (which might still produce deterministic incorrect results), data races can lead to torn reads, partial writes, or compiler optimizations that assume no concurrent access.

**Example of a data race:**

```nasm
; Thread 1
mov dword [shared_var], 0x12345678

; Thread 2
mov eax, [shared_var]
```

Without synchronization, Thread 2 might read a partially written value, or the CPU's store buffer might delay Thread 1's write indefinitely from Thread 2's perspective.

### x86-Specific Atomicity Guarantees

The x86 architecture provides certain atomicity guarantees:

- **Aligned loads/stores**: Naturally aligned reads and writes of up to 8 bytes (on 64-bit) or 4 bytes (on 32-bit) are atomic
- **Unaligned accesses**: May be split into multiple memory operations, not atomic
- **Cache line splits**: Accesses crossing cache line boundaries are not atomic

```nasm
; Atomic on x86 (assuming alignment)
mov dword [aligned_addr], eax

; NOT atomic - may cross cache line
mov dword [unaligned_addr], eax

; NOT atomic - two separate operations
mov word [addr], ax
mov word [addr+2], dx
```

### LOCK Prefix for Atomic Operations

The `LOCK` prefix ensures atomic read-modify-write operations:

```nasm
lock inc dword [counter]        ; Atomic increment
lock add dword [counter], 5     ; Atomic addition
lock cmpxchg [ptr], ebx         ; Atomic compare-and-exchange
lock xchg [ptr], eax            ; Atomic exchange (LOCK implicit)
```

The `LOCK` prefix:

- Asserts the LOCK# signal on the bus (on older CPUs)
- Locks the cache line (on modern CPUs with cache coherence)
- Prevents other processors from accessing the memory location during the operation
- Provides sequential consistency for that operation

**Example: Thread-safe counter increment:**

```nasm
; Non-atomic (race condition)
inc dword [counter]

; Atomic (no race condition)
lock inc dword [counter]
```

### Compare-and-Swap (CAS)

The `CMPXCHG` instruction with `LOCK` prefix is fundamental for lock-free algorithms:

```nasm
; Compare-and-swap pattern
.retry:
    mov eax, [expected]          ; Load expected value
    mov ebx, [new_value]         ; Load new value
    lock cmpxchg [location], ebx ; Atomic: if [location]==eax, [location]=ebx
    jne .retry                   ; If not equal, retry (ZF=0)
```

**Key Points:**

- Race conditions involve timing-dependent correctness issues
- Data races specifically involve unsynchronized concurrent memory access with at least one write
- x86 guarantees atomicity for aligned loads/stores up to native word size
- LOCK prefix ensures atomicity for read-modify-write operations
- CMPXCHG enables lock-free algorithms through atomic compare-and-swap

