## LOCK Prefix


The LOCK prefix ensures atomic execution of read-modify-write instructions in multi-processor systems by asserting the LOCK# signal on the bus, preventing other processors from accessing the same memory location.

### LOCK Prefix Behavior

```assembly
; LOCK prefix can be used with:
; - ADD, ADC, SUB, SBB, AND, OR, XOR (with memory destination)
; - INC, DEC, NEG, NOT (with memory operand)
; - BTS, BTR, BTC (bit operations)
; - XCHG (implicit LOCK, even without prefix)
; - CMPXCHG, CMPXCHG8B, CMPXCHG16B
; - XADD

; Atomic increment
lock inc dword [shared_counter]

; Atomic decrement
lock dec dword [shared_counter]

; Atomic addition
mov eax, 5
lock add [shared_value], eax

; Atomic AND (clear bits atomically)
lock and dword [flags], 0xFFFFFFFE  ; Clear bit 0

; Atomic OR (set bits atomically)
lock or dword [flags], 0x01         ; Set bit 0

; Invalid LOCK usage (will cause #UD exception):
; lock mov [mem], eax               ; LOCK with MOV invalid
; lock add eax, [mem]               ; LOCK requires memory destination
```

### Cache Line Locking vs Bus Locking

Modern processors use cache line locking instead of bus locking for better performance.

```assembly
; Cache line locking (fast):
; - Operand within single cache line (64 bytes)
; - Processor locks cache line, not entire bus
; - Other cores can access different cache lines

align 64                            ; Align to cache line
shared_var dd 0                     ; Within cache line
lock inc dword [shared_var]         ; Uses cache line locking

; Bus locking (slow):
; - Operand crosses cache line boundary
; - Processor must lock entire bus
; - All other processors stalled

; Example of cache line crossing (BAD):
section .data
    padding db 62 dup(0)            ; 62 bytes
    bad_var dq 0                    ; 8 bytes, crosses 64-byte boundary

section .text
lock inc qword [bad_var]            ; Slow: triggers bus lock!

; Solution: Align properly
align 64
good_var dq 0
lock inc qword [good_var]           ; Fast: cache line lock
```

### LOCK Prefix Overhead

```assembly
; Measuring LOCK overhead
measure_lock_overhead:
    ; Without LOCK
    rdtsc
    mov esi, eax
    mov edi, edx
    
    mov ecx, 10000
.loop1:
    inc dword [test_var]            ; Regular increment
    loop .loop1
    
    rdtsc
    sub eax, esi
    sbb edx, edi
    mov [time_without_lock], eax
    
    ; With LOCK
    rdtsc
    mov esi, eax
    mov edi, edx
    
    mov ecx, 10000
.loop2:
    lock inc dword [test_var]       ; Atomic increment
    loop .loop2
    
    rdtsc
    sub eax, esi
    sbb edx, edi
    mov [time_with_lock], eax
    
    ; Typical results:
    ; Without LOCK: 1 cycle per operation
    ; With LOCK: 20-100 cycles per operation (varies by contention)
    
    ret
```

### Alternative Atomic Patterns

```assembly
; When possible, avoid LOCK by redesigning algorithm

; BAD: Shared counter with heavy contention
increment_shared:
    lock inc dword [global_counter] ; Cache line ping-pongs
    ret

; BETTER: Per-thread counters, sum at end
increment_per_thread:
    ; Get thread ID
    call get_thread_id
    shl eax, 2                      ; * 4 for dword offset
    inc dword [thread_counters + eax]  ; No LOCK needed
    ret

sum_counters:
    xor eax, eax
    mov ecx, NUM_THREADS
    xor esi, esi
.sum:
    add eax, [thread_counters + esi]
    add esi, 4
    loop .sum
    mov [total_count], eax
    ret

; Per-thread counters eliminate contention
; Trade-off: More memory, but much faster
```

