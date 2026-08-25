## Memory Barriers and Fences


Memory barriers (fences) enforce ordering constraints on memory operations, preventing reordering by the processor or compiler.

### Memory Ordering Basics

Modern processors can reorder memory operations for performance, but this can cause problems in concurrent code.

```assembly
; Without fence - possible reordering problem
thread1:
    mov [data], eax             ; Write data
    mov [flag], 1               ; Set flag
    ; Processor might reorder these writes!

thread2:
.wait:
    cmp dword [flag], 1
    jne .wait
    mov ebx, [data]             ; Might read stale data!
    
; X86 provides relatively strong ordering guarantees:
; - Loads are not reordered with other loads
; - Stores are not reordered with other stores
; - Stores are not reordered with older loads
; - Loads MAY be reordered with older stores to different locations
; - Atomic operations have full barrier semantics
```

### MFENCE - Memory Fence

MFENCE serializes all load and store operations, ensuring all prior memory operations complete before any subsequent ones begin.

```assembly
; MFENCE - full memory barrier
; Ensures all loads/stores before MFENCE complete
; before any loads/stores after MFENCE begin

producer_thread:
    mov [buffer], eax           ; Write data
    mfence                      ; Ensure write visible
    mov dword [ready_flag], 1   ; Signal ready
    ret

consumer_thread:
.wait:
    cmp dword [ready_flag], 1
    jne .wait
    mfence                      ; Ensure flag read complete
    mov eax, [buffer]           ; Read data (guaranteed fresh)
    ret

; MFENCE use cases:
; - Publish-subscribe patterns
; - Release-acquire semantics
; - Ensuring memory-mapped I/O ordering
```

### LFENCE - Load Fence

LFENCE serializes load operations, preventing speculation past the fence.

```assembly
; LFENCE - load barrier
; Prevents loads from being reordered across the fence

speculative_execution_defense:
    ; Prevent speculative execution attacks
    cmp eax, [array_bounds]
    jae .out_of_bounds
    
    lfence                      ; Prevent speculative loads
    mov ebx, [array + eax*4]    ; Only executed if check passed
    ret

.out_of_bounds:
    xor ebx, ebx
    ret

; LFENCE also waits for all prior instructions to complete
; Useful for timing-sensitive code
rdtsc_serialized:
    lfence                      ; Wait for prior instructions
    rdtsc                       ; Now read timestamp
    lfence                      ; Prevent subsequent reordering
    ret
```

### SFENCE - Store Fence

SFENCE serializes store operations, ensuring writes are globally visible before proceeding.

```assembly
; SFENCE - store barrier
; Ensures all stores before SFENCE are globally visible
; before stores after SFENCE

write_combining_buffer_flush:
    ; When using write-combining memory (framebuffers, etc.)
    movntq [video_mem], mm0     ; Non-temporal store
    movntq [video_mem + 8], mm1
    movntq [video_mem + 16], mm2
    movntq [video_mem + 24], mm3
    sfence                      ; Flush write-combining buffers
    ret

; Non-temporal stores with SFENCE
stream_data:
    mov ecx, count
    xor esi, esi
    
.loop:
    movdqa xmm0, [source + esi]
    movntdq [dest + esi], xmm0  ; Non-temporal store
    add esi, 16
    loop .loop
    
    sfence                      ; Ensure all stores complete
    ret
```

### Fence Ordering Summary

```assembly
; Fence strength (weakest to strongest):
; 1. SFENCE - only stores
; 2. LFENCE - only loads (and instruction serialization)
; 3. MFENCE - both loads and stores

; When to use which fence:

; SFENCE:
; - After non-temporal stores
; - When ordering stores to different locations
; - Write-combining buffer management

; LFENCE:
; - Prevent speculative execution side effects
; - Serialize timing-sensitive code
; - Before reading after a conditional check

; MFENCE:
; - Release-acquire semantics
; - Publish-subscribe patterns
; - General purpose ordering (but most expensive)

; Note: LOCK prefix implies MFENCE semantics
lock_implies_mfence:
    mov [data], eax
    lock add dword [dummy], 0   ; Acts as full memory barrier
    mov [flag], 1
    ; Equivalent to using MFENCE
    ret
```

### Compiler Barriers

Compiler barriers prevent compiler reordering without affecting CPU reordering.

```assembly
; In inline assembly with GCC:
compiler_barrier:
    ; C code: asm volatile("" ::: "memory");
    ; Tells compiler not to reorder memory operations
    ; Does NOT insert any actual instructions
    
; Assembly-only equivalent:
; Use volatile directive or specific compiler pragmas

; Example showing compiler vs CPU barriers:
section .text
global concurrent_write

concurrent_write:
    mov [data], eax             ; Compiler might reorder
    ; Compiler barrier here prevents compile-time reordering
    mov [flag], 1               ; But CPU can still reorder

    mov [data], eax
    mfence                      ; CPU barrier ensures runtime ordering
    mov [flag], 1
    ret
```

### Memory Ordering in Practice

**Sequential Consistency:**

```assembly
; Achieve sequential consistency (strongest guarantee)
; All operations appear to execute in program order

sequentially_consistent_write:
    mov [data], eax
    mfence                      ; Full barrier
    mov [flag], 1
    ret

sequentially_consistent_read:
.wait:
    mov eax, [flag]
    test eax, eax
    jz .wait
    mfence                      ; Full barrier
    mov ebx, [data]
    ret

; Performance cost: MFENCE is expensive (30-100 cycles)
```

**Release-Acquire Semantics:**

```assembly
; Release: Stores before release visible to acquirer
release_semantics:
    mov [data], eax
    ; No loads/stores after this can move before it
    lock inc dword [lock_var]   ; Release (LOCK implies barrier)
    ; Or: mfence + mov
    ret

; Acquire: Loads after acquire see released stores
acquire_semantics:
.spin:
    mov eax, [lock_var]
    test eax, eax
    jz .spin
    ; No loads/stores before this can move after it
    ; LOCK from acquire operation provides barrier
    mov ebx, [data]             ; Guaranteed to see released data
    ret
```

**Relaxed Ordering:**

```assembly
; Relaxed ordering: No synchronization guarantees
; Fastest but requires careful analysis

relaxed_read:
    mov eax, [shared_var]       ; May see stale value
    ; No barriers, no ordering guarantees
    ret

relaxed_write:
    mov [shared_var], eax       ; May not be immediately visible
    ret

; Only safe when:
; - Single writer, multiple readers
; - Values are naturally atomic (aligned 32/64-bit)
; - Stale reads are acceptable
```

