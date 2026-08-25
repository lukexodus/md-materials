## False Sharing


False sharing occurs when threads on different cores modify variables that reside on the same cache line, causing unnecessary cache coherency traffic.

### Understanding False Sharing

**Cache Line Ping-Pong:**

```
Core 0 writes to byte 0:
  Cache line transitions to Modified state in Core 0
  Cache line invalidated in Core 1

Core 1 writes to byte 32 (same line):
  Must request cache line from Core 0
  Cache line transitions to Modified state in Core 1
  Cache line invalidated in Core 0

Result: Severe performance degradation despite no logical sharing
```

### Detecting False Sharing

```nasm
; Bad: False sharing example
section .data
align 64
shared_counters:
    counter0: dd 0              ; Used by thread 0
    counter1: dd 0              ; Used by thread 1 (same cache line!)
    counter2: dd 0              ; Used by thread 2 (same cache line!)
    counter3: dd 0              ; Used by thread 3 (same cache line!)

; Thread incrementing counter
thread_increment_bad:
    mov esi, [thread_id]
    lea edi, [counter0 + esi * 4]
    
    mov ecx, 1000000
.loop:
    lock inc dword [edi]        ; Causes cache line bouncing
    pause
    loop .loop
    
    ret
```

**Measuring False Sharing Impact:**

```nasm
measure_false_sharing:
    ; Setup performance counters for cache coherency events
    
    ; Event: L2_RQSTS.RFO_HIT (Request For Ownership - coherency traffic)
    ; Event code varies by CPU model
    mov ecx, 0x186
    mov eax, 0x00430824         ; Example event code
    xor edx, edx
    wrmsr
    
    mov ecx, 0xC1
    xor eax, eax
    xor edx, edx
    wrmsr
    
    ; Run test with false sharing
    call spawn_threads_bad
    call join_threads
    
    ; Read RFO count
    mov ecx, 0xC1
    rdmsr
    mov [rfo_count_bad], eax
    
    ; Reset counter
    mov ecx, 0xC1
    xor eax, eax
    xor edx, edx
    wrmsr
    
    ; Run test without false sharing
    call spawn_threads_good
    call join_threads
    
    ; Read RFO count
    mov ecx, 0xC1
    rdmsr
    mov [rfo_count_good], eax
    
    ; Compare: rfo_count_bad should be much higher
    
    ret
```

### Preventing False Sharing

**Padding to Cache Line Boundaries:**

```nasm
; Good: Pad each counter to separate cache lines
section .data
align 64
counter0: dd 0
    times 15 dd 0               ; Padding (64 bytes total)

align 64
counter1: dd 0
    times 15 dd 0               ; Padding

align 64
counter2: dd 0
    times 15 dd 0               ; Padding

align 64
counter3: dd 0
    times 15 dd 0               ; Padding
```

**Using Structure Padding:**

```nasm
; Cache-line padded structure
struc ThreadData
    .counter:       resd 1
    .padding:       resb 60     ; Pad to 64 bytes
endstruc

section .bss
align 64
thread_data: resb ThreadData_size * 16  ; 16 threads

; Thread access
thread_increment_good:
    mov esi, [thread_id]
    imul esi, ThreadData_size
    lea edi, [thread_data + esi + ThreadData.counter]
    
    mov ecx, 1000000
.loop:
    lock inc dword [edi]        ; No false sharing
    pause
    loop .loop
    
    ret
```

**Array of Structures vs Structure of Arrays:**

```nasm
; Bad: Array of Structures (AoS) - potential false sharing
struc Particle_AoS
    .x:         resd 1
    .y:         resd 1
    .z:         resd 1
    .vx:        resd 1
    .vy:        resd 1
    .vz:        resd 1
endstruc

section .bss
particles_aos: resb Particle_AoS_size * 1000

; Multiple threads update different particles
; BUT particles are small (24 bytes), so 2+ particles per cache line
; Threads working on adjacent particles cause false sharing

; Good: Structure of Arrays (SoA) - better cache locality
section .bss
align 64
particles_x:  resd 1000
align 64
particles_y:  resd 1000
align 64
particles_z:  resd 1000
align 64
particles_vx: resd 1000
align 64
particles_vy: resd 1000
align 64
particles_vz: resd 1000

; Each thread works on a range of indices
; Arrays are cache-line aligned
; Better: partition work by cache-line-sized chunks
```

**Work Partitioning to Avoid False Sharing:**

```nasm
; Bad: Fine-grained partitioning
distribute_work_bad:
    ; Thread 0: processes indices 0, 4, 8, 12...
    ; Thread 1: processes indices 1, 5, 9, 13...
    ; Thread 2: processes indices 2, 6, 10, 14...
    ; Thread 3: processes indices 3, 7, 11, 15...
    ; Adjacent indices likely on same cache line!
    
    mov eax, [thread_id]
    mov ecx, [num_threads]
    
.work_loop:
    ; Process array[eax]
    mov ebx, [array + eax * 4]
    ; ... processing ...
    
    add eax, ecx                ; Jump by num_threads
    cmp eax, [array_size]
    jl .work_loop
    
    ret

; Good: Coarse-grained, cache-line-aligned partitioning
distribute_work_good:
    ; Thread 0: processes 0-249
    ; Thread 1: processes 250-499
    ; Thread 2: processes 500-749
    ; Thread 3: processes 750-999
    ; Contiguous ranges reduce false sharing
    
    mov eax, [array_size]
    xor edx, edx
    div dword [num_threads]     ; EAX = chunk_size
    
    mov ebx, [thread_id]
    imul ebx, eax               ; Start index
    
    add eax, ebx                ; End index
    
.work_loop:
    ; Process array[ebx]
    mov ecx, [array + ebx * 4]
    ; ... processing ...
    
    inc ebx
    cmp ebx, eax
    jl .work_loop
    
    ret
```

### Lock-Free Algorithms and False Sharing

```nasm
; Producer-consumer queue with false sharing prevention

struc QueueNode
    .data:      resd 1
    .next:      resd 1
    .padding:   resb 56         ; Pad to 64 bytes
endstruc

section .bss
align 64
queue_head: resd 1              ; Read by consumer
    times 15 dd 0               ; Padding

align 64
queue_tail: resd 1              ; Written by producer
    times 15 dd 0               ; Padding

; Producer enqueue
enqueue:
    ; Input: EAX = data
    push ebp
    mov ebp, esp
    
    ; Allocate new node
    call allocate_node
    mov esi, eax
    
    ; Fill node
    mov eax, [ebp + 8]
    mov [esi + QueueNode.data], eax
    mov dword [esi + QueueNode.next], 0
    
    ; Atomically append to tail
.retry:
    mov eax, [queue_tail]
    lock cmpxchg [eax + QueueNode.next], esi
    jnz .retry
    
    ; Update tail
    lock cmpxchg [queue_tail], esi
    
    pop ebp
    ret

; Consumer dequeue
dequeue:
    ; Output: EAX = data or 0 if empty
    
.retry:
    mov eax, [queue_head]
    mov ebx, [eax + QueueNode.next]
    test ebx, ebx
    jz .empty
    
    ; Try to advance head
    lock cmpxchg [queue_head], ebx
    jnz .retry
    
    ; Get data from old head
    mov eax, [ebx + QueueNode.data]
    
    ; Free old head node
    push eax
    push ebx
    call free_node
    pop eax
    
    ret
    
.empty:
    xor eax, eax
    ret
```

**Per-CPU Data Structures:**

```nasm
; Eliminate sharing by using per-CPU structures

struc PerCPUData
    .counter:       resd 1
    .local_sum:     resd 1
    .temp_buffer:   resd 16
    .padding:       resb 32     ; Pad to 64 bytes minimum
endstruc

section .bss
align 64
per_cpu_data: resb PerCPUData_size * 64  ; Support up to 64 CPUs

; Get current CPU's data
get_cpu_data:
    ; Read APIC ID to get CPU number
    mov eax, 1
    cpuid
    shr ebx, 24                 ; APIC ID
    
    ; Map to per-CPU data
    imul ebx, PerCPUData_size
    lea eax, [per_cpu_data + ebx]
    ret

; Increment per-CPU counter (no lock needed)
increment_percpu_counter:
    call get_cpu_data
    inc dword [eax + PerCPUData.counter]
    ret

; Aggregate all per-CPU counters
aggregate_counters:
    xor eax, eax                ; Total
    mov ecx, 64                 ; Number of CPUs
    lea esi, [per_cpu_data]
    
.sum_loop:
    add eax, [esi + PerCPUData.counter]
    add esi, PerCPUData_size
    loop .sum_loop
    
    ; EAX = total count
    ret
```

