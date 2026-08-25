## Synchronization and Memory Ordering


MFENCE (Memory Fence) ensures all memory operations before the MFENCE complete before any memory operations after it begin. MFENCE provides full memory barrier semantics for both loads and stores.

LFENCE (Load Fence) ensures all load operations before LFENCE complete before any load operations after it. LFENCE provides a barrier for read operations.

SFENCE (Store Fence) ensures all store operations before SFENCE complete before any store operations after it. SFENCE provides a barrier for write operations.

These fence instructions are critical for proper synchronization in multi-threaded and multi-core environments. Without fences, the processor can reorder memory operations for performance, potentially breaking synchronization assumptions.

Memory ordering example - without fences, this code could fail:

```
; Thread 1
MOV [data], RAX      ; Write data
MOV [ready_flag], 1  ; Set flag

; Thread 2
spin:
    CMP [ready_flag], 1
    JNE spin
    MOV RBX, [data]  ; Read data
```

If memory operations reorder, Thread 2 might read stale data. Adding MFENCE after the data write in Thread 1 ensures correct ordering.

LOCK prefix makes certain instructions atomic with respect to other processors. When LOCK prefixes an instruction with a memory operand, it ensures exclusive access to that memory location. `LOCK ADD [counter], 1` atomically increments the memory location, preventing race conditions.

LOCK can prefix: ADD, ADC, AND, BTC, BTR, BTS, CMPXCHG, CMPXCHG8B, CMPXCHG16B, DEC, INC, NEG, NOT, OR, SBB, SUB, XOR, XADD, and XCHG. XCHG with a memory operand has implicit LOCK behavior.

LOCK prefix causes the instruction to assert the LOCK# signal on the system bus or lock the cache line containing the memory operand, providing atomicity. This is essential for implementing locks, counters, and lock-free data structures.

XADD (Exchange and Add) atomically exchanges the source and destination, then adds them and stores the result in the destination. `XADD [RBX], EAX` atomically performs: temp = [RBX], [RBX] = [RBX] + EAX, EAX = temp. When combined with LOCK, this provides atomic fetch-and-add operations.

