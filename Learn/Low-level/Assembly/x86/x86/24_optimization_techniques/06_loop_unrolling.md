## Loop Unrolling


Loop unrolling reduces loop overhead by replicating loop body instructions, decreasing the number of iterations and branch instructions executed.

**Basic Loop Example**:

```assembly
; Original loop - sum array of 1000 elements
sum_array_simple:
    xor eax, eax            ; sum = 0
    xor ecx, ecx            ; i = 0
    mov edx, 1000           ; count
.loop:
    add eax, [esi + ecx*4]  ; sum += array[i]
    inc ecx                 ; i++
    cmp ecx, edx            ; i < count?
    jl .loop                ; branch if less
    ret

; Loop overhead per iteration:
; - inc (1 cycle)
; - cmp (1 cycle)  
; - jl (branch prediction dependent: 0-20+ cycles on misprediction)
```

**Unrolled by Factor of 4**:

```assembly
sum_array_unroll4:
    xor eax, eax
    xor ecx, ecx
    mov edx, 1000
    shr edx, 2              ; count / 4 (250 iterations)
.loop:
    add eax, [esi + ecx*4]      ; Iteration 1
    add eax, [esi + ecx*4 + 4]  ; Iteration 2
    add eax, [esi + ecx*4 + 8]  ; Iteration 3
    add eax, [esi + ecx*4 + 12] ; Iteration 4
    add ecx, 4              ; i += 4
    cmp ecx, edx
    jl .loop
    
    ; Handle remaining elements (if count not multiple of 4)
.remainder:
    ; ... handle up to 3 remaining elements
    ret

; Benefits:
; - 75% fewer branches (250 vs 1000)
; - 75% fewer increment/compare operations
; - Better instruction-level parallelism (4 adds can partially overlap)
```

**Unrolling Benefits**:

**Reduced Branch Overhead**: Fewer branch instructions and potential mispredictions **Decreased Loop Counter Operations**: Less increment/compare overhead **Improved Instruction-Level Parallelism**: Independent operations can execute in parallel **Better Register Utilization**: More opportunities for register allocation **Enhanced Prefetch Effectiveness**: Predictable memory access patterns

**Unrolling with Multiple Accumulators**:

```assembly
; Unroll with 4 independent accumulators
; Reduces dependency chains for better parallelism
sum_array_unroll_multi_acc:
    xor eax, eax            ; accumulator 1
    xor ebx, ebx            ; accumulator 2
    xor edx, edx            ; accumulator 3
    xor edi, edi            ; accumulator 4
    xor ecx, ecx            ; index
    
    mov r8d, 1000
    shr r8d, 2              ; iterations = count / 4
.loop:
    add eax, [esi + ecx*4]      ; acc1 += array[i]
    add ebx, [esi + ecx*4 + 4]  ; acc2 += array[i+1]
    add edx, [esi + ecx*4 + 8]  ; acc3 += array[i+2]
    add edi, [esi + ecx*4 + 12] ; acc4 += array[i+3]
    add ecx, 4
    cmp ecx, r8d
    jl .loop
    
    ; Combine accumulators
    add eax, ebx
    add eax, edx
    add eax, edi
    ret

; Advantage: Each accumulator has independent dependency chain
; CPU can execute all 4 adds in parallel (if execution units available)
```

**Advanced Unrolling - Duff's Device Pattern**:

```assembly
; Handle arbitrary loop counts efficiently
; Uses computed jump into loop body
sum_array_duffs_device:
    xor eax, eax
    mov ecx, [count]
    test ecx, ecx
    jz .done
    
    ; Calculate entry point: iterations % 8
    mov edx, ecx
    and edx, 7              ; remainder = count & 7
    shr ecx, 3              ; iterations = count / 8
    
    ; Jump table for entry
    lea ebx, [.jump_table]
    jmp [ebx + edx*4]
    
.jump_table:
    dd .entry0, .entry1, .entry2, .entry3
    dd .entry4, .entry5, .entry6, .entry7
    
.loop:
.entry0:
    add eax, [esi]
    add esi, 4
.entry7:
    add eax, [esi]
    add esi, 4
.entry6:
    add eax, [esi]
    add esi, 4
.entry5:
    add eax, [esi]
    add esi, 4
.entry4:
    add eax, [esi]
    add esi, 4
.entry3:
    add eax, [esi]
    add esi, 4
.entry2:
    add eax, [esi]
    add esi, 4
.entry1:
    add eax, [esi]
    add esi, 4
    
    dec ecx
    jnz .loop
    
.done:
    ret
```

**Loop Unrolling with SIMD**:

```assembly
; Vectorized sum using SSE - process 4 integers simultaneously
sum_array_sse:
    pxor xmm0, xmm0         ; accumulator = 0
    xor ecx, ecx
    mov edx, 1000
    shr edx, 4              ; process 16 elements per iteration (4 SIMD ops)
    
.loop:
    movdqu xmm1, [esi + ecx*4]      ; Load 4 integers
    movdqu xmm2, [esi + ecx*4 + 16] ; Load next 4
    movdqu xmm3, [esi + ecx*4 + 32] ; Load next 4
    movdqu xmm4, [esi + ecx*4 + 48] ; Load next 4
    
    paddd xmm0, xmm1        ; Add all 4 elements to accumulator
    paddd xmm0, xmm2
    paddd xmm0, xmm3
    paddd xmm0, xmm4
    
    add ecx, 16
    cmp ecx, edx
    jl .loop
    
    ; Horizontal sum of xmm0
    movdqa xmm1, xmm0
    psrldq xmm1, 8          ; Shift right 8 bytes
    paddd xmm0, xmm1        ; Add high half to low half
    movdqa xmm1, xmm0
    psrldq xmm1, 4          ; Shift right 4 bytes
    paddd xmm0, xmm1
    movd eax, xmm0          ; Extract final sum
    
    ret

; Processes 16 elements per iteration vs 1 in original
; 16x fewer iterations, 16x fewer branches
```

**Unrolling Considerations**:

**Code Size**: Unrolling increases instruction cache pressure. Excessive unrolling can cause cache thrashing.

**Optimal Unroll Factor**: Depends on:

- Loop body size
- Available registers
- Instruction cache size
- Processor execution width
- Memory bandwidth

[Inference: Typical optimal unroll factors range from 2-8 for general-purpose code]

**Partial vs Full Unrolling**:

- **Partial**: Unroll by factor N, still have loop
- **Full**: Completely eliminate loop (only for small, fixed iteration counts)

```assembly
; Full unrolling for fixed small count
sum_10_elements:
    mov eax, [esi]
    add eax, [esi + 4]
    add eax, [esi + 8]
    add eax, [esi + 12]
    add eax, [esi + 16]
    add eax, [esi + 20]
    add eax, [esi + 24]
    add eax, [esi + 28]
    add eax, [esi + 32]
    add eax, [esi + 36]
    ret

; No loop overhead at all - maximum performance for small loops
```

**Handling Remainder Elements**:

```assembly
; Generic unroll with remainder handling
sum_array_unroll8:
    xor eax, eax
    mov ecx, [count]
    mov edx, ecx
    shr ecx, 3              ; main_iterations = count / 8
    and edx, 7              ; remainder = count & 7
    xor ebx, ebx            ; index
    
.main_loop:
    test ecx, ecx
    jz .remainder
    add eax, [esi + ebx*4]
    add eax, [esi + ebx*4 + 4]
    add eax, [esi + ebx*4 + 8]
    add eax, [esi + ebx*4 + 12]
    add eax, [esi + ebx*4 + 16]
    add eax, [esi + ebx*4 + 20]
    add eax, [esi + ebx*4 + 24]
    add eax, [esi + ebx*4 + 28]
    add ebx, 8
    dec ecx
    jnz .main_loop
    
.remainder:
    test edx, edx
    jz .done
.remainder_loop:
    add eax, [esi + ebx*4]
    inc ebx
    dec edx
    jnz .remainder_loop
    
.done:
    ret
```

**Software Pipelining with Unrolling**:

```assembly
; Overlap memory loads with computation
; Reduces load-to-use latency stalls
matrix_multiply_unroll:
    ; Assume multiplying 4x4 matrices
    
    ; Prefetch first elements
    mov eax, [matrix_a]
    mov ebx, [matrix_b]
    
.loop:
    ; Load for next iteration (overlaps with current computation)
    mov ecx, [matrix_a + 4]
    mov edx, [matrix_b + 4]
    
    ; Compute with previously loaded values
    imul eax, ebx
    add [result], eax
    
    ; Move prefetched values to working registers
    mov eax, ecx
    mov ebx, edx
    
    ; Continue loop...
```

**Key Points**:

- Loop unrolling trades code size for execution speed
- Reduces branch instructions and loop overhead
- Enables better instruction-level parallelism
- Multiple accumulators help reduce dependency chains
- Must handle remainder elements when count not divisible by unroll factor
- SIMD instructions amplify unrolling benefits
- Excessive unrolling can hurt performance due to instruction cache pressure
- Optimal unroll factor is workload and architecture dependent
- Modern compilers perform automatic loop unrolling with pragma hints
- Profile-guided optimization helps determine optimal unroll factors

