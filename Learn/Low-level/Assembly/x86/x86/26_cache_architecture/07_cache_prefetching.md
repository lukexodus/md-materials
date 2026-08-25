## Cache Prefetching


Cache prefetching brings data into cache before it's explicitly requested, reducing memory access latency.

### Hardware Prefetching

**Types of Hardware Prefetchers:**

1. **Next-line prefetcher**: Fetches adjacent cache line
2. **Stream prefetcher**: Detects sequential access patterns
3. **Stride prefetcher**: Detects constant-stride patterns
4. **Spatial prefetcher**: Prefetches within a memory region

**Hardware prefetchers operate automatically but can be controlled:**

```nasm
; Disable/enable hardware prefetchers (Intel-specific)
control_hw_prefetch:
    mov ecx, 0x1A4              ; MSR_MISC_FEATURE_CONTROL
    rdmsr
    
    ; Bit 0: L2 hardware prefetcher disable
    ; Bit 1: L2 adjacent cache line prefetch disable
    ; Bit 2: DCU (L1) prefetcher disable
    ; Bit 3: DCU IP prefetcher disable
    
    or eax, 0x0F                ; Disable all prefetchers
    ; and eax, ~0x0F            ; Enable all prefetchers
    
    wrmsr
    ret
```

### Software Prefetching Instructions

**Prefetch Instruction Variants:**

```nasm
; PREFETCHT0 - Prefetch to all cache levels (temporal data)
prefetcht0 [memory]             ; Highest priority

; PREFETCHT1 - Prefetch to L2 and L3 (less temporal)
prefetcht1 [memory]             ; Medium priority

; PREFETCHT2 - Prefetch to L3 only (least temporal)
prefetcht2 [memory]             ; Lowest priority

; PREFETCHNTA - Prefetch non-temporal (minimize cache pollution)
prefetchnta [memory]            ; Hint: won't be reused soon
```

**Prefetch Distance and Timing:**

```nasm
; Sequential memory copy with prefetching
optimized_memcpy:
    mov esi, [src]
    mov edi, [dst]
    mov ecx, [size]
    shr ecx, 6                  ; Divide by 64 (cache line size)
    
    ; Prefetch distance: ~10-20 cache lines ahead
    ; Too close: Prefetch doesn't complete in time
    ; Too far: Data might be evicted before use
    
    mov eax, 10                 ; Prefetch distance in cache lines
    
.copy_loop:
    ; Prefetch ahead
    lea ebx, [esi + eax * 64]
    prefetcht0 [ebx]
    
    ; Copy current cache line
    movdqa xmm0, [esi]
    movdqa xmm1, [esi + 16]
    movdqa xmm2, [esi + 32]
    movdqa xmm3, [esi + 48]
    
    movdqa [edi], xmm0
    movdqa [edi + 16], xmm1
    movdqa [edi + 32], xmm2
    movdqa [edi + 48], xmm3
    
    add esi, 64
    add edi, 64
    dec ecx
    jnz .copy_loop
    
    ret
```

**Stride-Based Prefetching:**

```nasm
; Prefetch for strided access pattern
prefetch_strided_access:
    mov esi, [array_base]
    mov ecx, [element_count]
    mov edx, [stride]           ; Stride in bytes
    
    ; Prefetch several elements ahead
    mov eax, 8                  ; Prefetch 8 strides ahead
    
.process_loop:
    ; Prefetch future element
    push ecx
    mov ebx, eax
    imul ebx, edx
    add ebx, esi
    prefetcht0 [ebx]
    pop ecx
    
    ; Process current element
    mov eax, [esi]
    ; ... processing ...
    
    add esi, edx                ; Move to next stride
    loop .process_loop
    
    ret
```

**Linked List Prefetching:**

```nasm
; Prefetch nodes in linked list traversal
struc ListNode
    .data:  resd 1
    .next:  resd 1
endstruc

traverse_with_prefetch:
    mov esi, [list_head]
    
.traverse_loop:
    ; Prefetch next node before using current
    mov ebx, [esi + ListNode.next]
    test ebx, ebx
    jz .done
    
    prefetcht0 [ebx]            ; Prefetch next node
    
    ; Prefetch node after next (two ahead)
    mov ecx, [ebx + ListNode.next]
    test ecx, ecx
    jz .no_next_next
    prefetcht0 [ecx]
    
.no_next_next:
    ; Process current node
    mov eax, [esi + ListNode.data]
    ; ... processing ...
    
    ; Move to next node
    mov esi, ebx
    jmp .traverse_loop
    
.done:
    ret
```

**Matrix Operations with Prefetching:**

```nasm
; Matrix multiplication with cache-aware prefetching
matrix_multiply_prefetch:
    ; C[i][j] = sum(A[i][k] * B[k][j])
    mov esi, [matrix_a]
    mov edi, [matrix_b]
    mov edx, [matrix_c]
    mov ecx, [n]                ; Matrix dimension
    
    xor r8d, r8d                ; i = 0
.i_loop:
    xor r9d, r9d                ; j = 0
.j_loop:
    ; Prefetch B column ahead
    mov eax, r9d
    add eax, 4                  ; Prefetch 4 columns ahead
    cmp eax, ecx
    jge .no_prefetch_b
    
    ; Prefetch B[0][j+4], B[1][j+4], ... (column)
    mov ebx, 0
.prefetch_col:
    push rax
    imul rax, rcx
    add rax, eax                ; B[ebx][eax]
    shl rax, 2                  ; × 4 bytes
    prefetcht0 [edi + rax]
    pop rax
    inc ebx
    cmp ebx, ecx
    jl .prefetch_col
    
.no_prefetch_b:
    ; Compute C[i][j]
    pxor xmm0, xmm0             ; Accumulator
    
    xor r10d, r10d              ; k = 0
.k_loop:
    ; Load A[i][k]
    mov eax, r8d
    imul eax, ecx
    add eax, r10d
    movss xmm1, [esi + rax * 4]
    
    ; Load B[k][j]
    mov eax, r10d
    imul eax, ecx
    add eax, r9d
    movss xmm2, [edi + rax * 4]
    
    ; Multiply and accumulate
    mulss xmm1, xmm2
    addss xmm0, xmm1
    
    inc r10d
    cmp r10d, ecx
    jl .k_loop
    
    ; Store C[i][j]
    mov eax, r8d
    imul eax, ecx
    add eax, r9d
    movss [edx + rax * 4], xmm0
    
    inc r9d
    cmp r9d, ecx
    jl .j_loop
    
    inc r8d
    cmp r8d, ecx
    jl .i_loop
    
    ret
```

**Prefetching Guidelines:**

[Inference] Effective prefetching requires:

- **Adequate lead time**: Prefetch 10-20 cache lines ahead for sequential access
- **Avoiding over-prefetching**: Don't pollute cache with unneeded data
- **Pattern recognition**: Hardware prefetchers work best with predictable patterns
- **Granularity**: Prefetch entire cache lines (64 bytes), not individual bytes

```nasm
; Example: Tuning prefetch distance
tune_prefetch_distance:
    ; Test different prefetch distances
    mov edi, [test_array]
    mov ecx, 100000
    
    ; Try distance = 8 cache lines
    rdtsc
    mov [start_time], eax
    
    mov esi, edi
    mov ebx, ecx
.test_8:
    prefetcht0 [esi + 8 * 64]   ; 8 lines ahead
    movdqa xmm0, [esi]
    add esi, 64
    dec ebx
    jnz .test_8
    
    rdtsc
    sub eax, [start_time]
    mov [time_8], eax
    
    ; Try distance = 16 cache lines
    rdtsc
    mov [start_time], eax
    
    mov esi, edi
    mov ebx, ecx
.test_16:
    prefetcht0 [esi + 16 * 64]  ; 16 lines ahead
    movdqa xmm0, [esi]
    add esi, 64
    dec ebx
    jnz .test_16
    
    rdtsc
    sub eax, [start_time]
    mov [time_16], eax
    
    ; Compare results to find optimal distance
    
    ret
```

