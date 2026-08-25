## Read-Modify-Write Operations


Read-modify-write (RMW) operations atomically read a value, modify it, and write it back.

### Atomic Arithmetic Operations

```assembly
; Atomic increment/decrement
atomic_inc_dec:
    lock inc dword [counter]        ; counter++
    lock dec dword [counter]        ; counter--
    ret

; Atomic add/subtract
atomic_add_sub:
    mov eax, 10
    lock add [counter], eax         ; counter += 10
    lock sub [counter], eax         ; counter -= 10
    ret

; Fetch-and-add (XADD)
fetch_and_add:
    mov eax, 5
    lock xadd [counter], eax        ; Atomic: tmp=counter; counter+=5; eax=tmp
    ; EAX now contains old value of counter
    ; Counter now contains old value + 5
    ret

; Use case: Generating unique IDs
generate_unique_id:
    mov eax, 1
    lock xadd [id_counter], eax     ; Atomic fetch-and-increment
    ; EAX contains unique ID
    ret
```

### Atomic Bitwise Operations

```assembly
; Atomic OR (set bits)
atomic_or:
    lock or [flags], 0x01           ; Atomically set bit 0
    ret

; Atomic AND (clear bits)
atomic_and:
    lock and [flags], ~0x01         ; Atomically clear bit 0
    ret

; Atomic XOR (toggle bits)
atomic_xor:
    lock xor [flags], 0x01          ; Atomically toggle bit 0
    ret

; Bit test and set/reset/complement
atomic_bit_ops:
    lock bts dword [bitmap], 5      ; Test bit 5, then set it
    ; CF contains old bit value
    jc .was_set
    
.was_clear:
    ; Bit was 0, now it's 1
    ret
    
.was_set:
    ; Bit was already 1
    ret

; Use case: Lock-free bitmap allocation
allocate_bit:
    xor ecx, ecx                    ; Start at bit 0
.find_free:
    lock bts [bitmap], ecx          ; Try to claim bit
    jnc .found                      ; If bit was 0, we claimed it
    inc ecx
    cmp ecx, 64
    jl .find_free
    ; No free bits
    mov eax, -1
    ret
.found:
    mov eax, ecx                    ; Return bit index
    ret
```

### Compare-and-Swap (CAS) Patterns

```assembly
; CAS loop - retry until success
cas_increment:
.retry:
    mov eax, [counter]              ; Load current value
    mov ebx, eax
    inc ebx                         ; Calculate new value
    lock cmpxchg [counter], ebx     ; Try to update
    jnz .retry                      ; Retry if someone else modified it
    ret

; CAS with bounded retries
cas_bounded:
    mov ecx, 100                    ; Max retries
.retry:
    mov eax, [value]
    mov ebx, eax
    add ebx, 10
    lock cmpxchg [value], ebx
    jz .success
    
    pause
    dec ecx
    jnz .retry
    
    ; Failed after max retries
    xor eax, eax                    ; Return failure
    ret
    
.success:
    mov eax, 1                      ; Return success
    ret
```

### Double-Compare-and-Swap (DCAS)

```assembly
; ABA problem demonstration
; Thread 1 reads A, Thread 2 changes A→B→A, Thread 1's CAS succeeds
; but doesn't detect the intermediate change

; Solution: Use version counter with DCAS
struc versioned_ptr
    .pointer: resq 1
    .version: resq 1
endstruc

; Update pointer with version checking
dcas_update_pointer:
    ; Load current pointer and version
    mov rax, [ptr_struct.pointer]
    mov rdx, [ptr_struct.version]
    
    ; Calculate new values
    mov rbx, new_pointer
    mov rcx, rdx
    inc rcx                         ; Increment version
    
    ; Atomic double-width CAS
    lock cmpxchg16b [ptr_struct]
    jz .success
    ; Failed - someone else modified it
    ret
    
.success:
    ; Successfully updated pointer and version
    ret

; Solving ABA problem
; Now A→B→A becomes (A,v1)→(B,v2)→(A,v3)
; Version counter detects the change even though pointer value matches
```

### Atomic Exchange Patterns

```assembly
; Atomic swap
atomic_swap:
    mov eax, new_value
    xchg [variable], eax            ; Atomic swap
    ; EAX now contains old value
    mov [old_value_out], eax
    ret

; Conditional atomic swap (only if condition met)
conditional_swap:
    mov eax, [variable]
.retry:
    test eax, eax
    jz .skip                        ; Don't swap if zero
    
    mov ebx, new_value
    lock cmpxchg [variable], ebx
    jnz .retry
    
.skip:
    ret
```

### Memory Reclamation with RMW

```assembly
; Reference counting with atomic operations
struc ref_counted_object
    .ref_count: resd 1
    .data: resb 60
endstruc

; Increment reference count
add_ref:
    lock inc dword [rdi + ref_counted_object.ref_count]
    ret

; Decrement reference count, free if zero
release_ref:
    lock dec dword [rdi + ref_counted_object.ref_count]
    jnz .still_alive
    
    ; Reference count reached zero, free object
    call free_object
    
.still_alive:
    ret

; Safe reference acquisition (check for zero)
try_add_ref:
.retry:
    mov eax, [rdi + ref_counted_object.ref_count]
    test eax, eax
    jz .already_dead                ; Can't acquire ref to dead object
    
    mov ebx, eax
    inc ebx
    lock cmpxchg [rdi + ref_counted_object.ref_count], ebx
    jnz .retry                      ; Retry if count changed
    
    mov eax, 1                      ; Success
    ret
    
.already_dead:
    xor eax, eax                    ; Failure
    ret
```

