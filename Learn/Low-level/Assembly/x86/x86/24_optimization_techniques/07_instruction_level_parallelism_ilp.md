## Instruction-Level Parallelism (ILP)


Instruction-level parallelism exploits the ability of modern superscalar processors to execute multiple independent instructions simultaneously.

**Processor Execution Model**:

Modern x86 processors (Intel Core, AMD Ryzen) are:

- **Superscalar**: Multiple execution units (4-8 ALUs, 2-3 load/store units, etc.)
- **Out-of-Order**: Instructions execute when dependencies resolved, not in program order
- **Speculative**: Execute beyond branches based on prediction

**Execution Pipeline Stages**:

```
Fetch → Decode → Rename → Schedule → Execute → Retire
```

**Execution Throughput vs Latency**:

Each instruction has:

- **Latency**: Cycles from operand available to result available
- **Throughput**: Instructions per cycle the unit can accept

```assembly
; Example: ADD instruction
; Latency: 1 cycle (result available next cycle)
; Throughput: 4 per cycle (4 ALU ports available)

; This means 4 independent ADD instructions can start per cycle
; But each individual ADD takes 1 cycle for its result
```

**Dependency Types**:

**True Dependency (Read-After-Write - RAW)**:

```assembly
; Instruction 2 depends on instruction 1 result
add eax, ebx        ; Cycle 1
add ecx, eax        ; Must wait for eax result (dependency)
; Cannot execute in parallel
```

**Anti-Dependency (Write-After-Read - WAR)**:

```assembly
; Instruction 2 overwrites register instruction 1 reads
add ecx, eax        ; Reads eax
mov eax, ebx        ; Writes eax
; Out-of-order execution handles this via register renaming
```

**Output Dependency (Write-After-Write - WAW)**:

```assembly
; Both write same register
mov eax, ebx
mov eax, ecx
; Register renaming resolves this
```

**Independent Instructions**:

```assembly
; No dependencies - can execute in parallel
add eax, ebx        ; Uses eax, ebx
add ecx, edx        ; Uses ecx, edx - independent
add esi, edi        ; Uses esi, edi - independent
add r8d, r9d        ; Uses r8d, r9d - independent
; All 4 can issue simultaneously (if enough ALU ports)
```

**Exploiting ILP - Breaking Dependency Chains**:

```assembly
; Poor ILP - long dependency chain
sum_dependent:
    xor eax, eax
    mov ecx, 1000
.loop:
    add eax, [esi]      ; Cycle N: depends on previous eax
    add esi, 4
    add eax, [esi]      ; Cycle N+3: depends on previous add
    add esi, 4          ; Cycle N+3: independent
    add eax, [esi]      ; Cycle N+6: depends on previous add
    add esi, 4          ; Cycle N+6: independent
    add eax, [esi]      ; Cycle N+9: depends on previous add
    add esi, 4          ; Cycle N+9: independent
    sub ecx, 4
    jnz .loop
    ret

; Each add depends on previous add result
; Even though we have 4 adds, they execute sequentially
; Total latency: 4 * add_latency per iteration
```

```assembly
; Good ILP - multiple independent accumulators
sum_parallel:
    xor eax, eax        ; acc1
    xor ebx, ebx        ; acc2
    xor edx, edx        ; acc3
    xor edi, edi        ; acc4
    mov ecx, 1000
    shr ecx, 2
.loop:
    add eax, [esi]          ; Independent
    add ebx, [esi + 4]      ; Independent
    add edx, [esi + 8]      ; Independent
    add edi, [esi + 12]     ; Independent
    add esi, 16
    dec ecx
    jnz .loop
    
    ; Combine accumulators
    add eax, ebx        ; 2-way parallel
    add edx, edi
    add eax, edx        ; Final sum
    ret

; All 4 adds are independent - execute in parallel
; Total latency: add_latency per iteration (not 4x)
; 4x speedup from ILP
```

**Memory Access Parallelism**:

```assembly
; Sequential loads - limited parallelism
load_sequential:
    mov eax, [esi]          ; Load 1
    mov ebx, [esi + eax]    ; Load 2 - depends on Load 1
    mov ecx, [esi + ebx]    ; Load 3 - depends on Load 2
    ret

; Parallel loads - maximum parallelism
load_parallel:
    mov eax, [esi]          ; Load 1
    mov ebx, [esi + 64]     ; Load 2 - independent
    mov ecx, [esi + 128]    ; Load 3 - independent
    mov edx, [esi + 192]    ; Load 4 - independent
    ; All 4 loads can issue simultaneously (memory bandwidth permitting)
    ret
```

**Instruction Scheduling for ILP**:

```assembly
; Poor scheduling - operations interleaved with dependencies
matrix_mult_poor:
    mov eax, [matrix_a]
    imul eax, [matrix_b]        ; Depends on eax load
    mov [result], eax           ; Depends on multiply
    mov ebx, [matrix_a + 4]     ; Stalled waiting for previous store
    imul ebx, [matrix_b + 4]
    mov [result + 4], ebx
    ret

; Good scheduling - independent operations grouped
matrix_mult_good:
    ; Load phase - all independent
    mov eax, [matrix_a]
    mov ebx, [matrix_a + 4]
    mov ecx, [matrix_a + 8]
    mov edx, [matrix_a + 12]
    
    ; Multiply phase - all independent (waiting for loads)
    imul eax, [matrix_b]
    imul ebx, [matrix_b + 4]
    imul ecx, [matrix_b + 8]
    imul edx, [matrix_b + 12]
    
    ; Store phase - independent stores
    mov [result], eax
    mov [result + 4], ebx
    mov [result + 8], ecx
    mov [result + 12], edx
    ret

; Loads execute in parallel, multiplies execute in parallel,
; stores execute in parallel - better hardware utilization
```

**Interleaving Independent Operations**:

```assembly
; Processing two arrays simultaneously
process_two_arrays:
    xor eax, eax        ; sum_a
    xor ebx, ebx        ; sum_b
    mov ecx, 1000
.loop:
    ; Interleave operations from both arrays
    mov edx, [array_a + ecx*4]  ; Load from A
    mov edi, [array_b + ecx*4]  ; Load from B - independent
    add eax, edx                ; Process A
    add ebx, edi                ; Process B - independent
    dec ecx
    jnz .loop
    ret

; Loads and adds for both arrays can execute in parallel
```

**Loop Carried Dependencies**:

```assembly
; Loop carried dependency - limits ILP
fibonacci_recursive:
    mov eax, 1          ; fib[0]
    mov ebx, 1          ; fib[1]
    mov ecx, 10
.loop:
    mov edx, eax        ; temp = fib[n-2]
    add eax, ebx        ; fib[n] = fib[n-1] + fib[n-2]
    mov ebx, edx        ; fib[n-1] = temp
    dec ecx
    jnz .loop
    ret

; Each iteration depends on previous - cannot parallelize
; This is inherent to algorithm, not fixable with ILP techniques
```

**Reducing Critical Path Length**:

```assembly
; Long critical path
compute_long_path:
    mov eax, [input]
    add eax, 10         ; Cycle 1
    imul eax, 5         ; Cycle 4 (3-cycle latency)
    sub eax, 7          ; Cycle 5
    shr eax, 2          ; Cycle 6
    ret
; Total latency: 6 cycles

; Reorganized with parallel operations
compute_short_path:
    mov eax, [input]
    mov ebx, eax
    add eax, 10         ; Path 1: Cycle 1
    imul ebx, 5         ; Path 2: Cycle 1 (parallel with add)
    ; Now we have two partial results
    ; Combine them (requires algorithmic change)
    ; [Inference: Actual reduction depends on algorithm flexibility]
```

**Using LEA for Multiple Operations**:

```assembly
; Multiple separate operations
calculate_separate:
    mov eax, ebx
    add eax, ecx        ; Cycle 1
    shl eax, 2          ; Cycle 2
    ret
; 2-cycle dependency chain

; Combined with LEA
calculate_lea:
    lea eax, [ebx + ecx*4]  ; Single instruction, 1-cycle latency
    ret
; 1-cycle operation - 2x faster

; LEA can compute: base + index*scale + displacement
; Useful for: (a + b*4), (a + b + c), array indexing
```

**Avoiding Partial Register Stalls**:

```assembly
; Partial register write causes stall on read
partial_register_bad:
    mov eax, [input]    ; Write full 32-bit EAX
    mov al, 5           ; Write 8-bit AL (partial)
    add ebx, eax        ; Read full EAX - STALL
    ; Processor must merge AL into EAX
    ret

; Use full register writes
partial_register_good:
    mov eax, [input]
    and eax, 0xFFFFFF00 ; Clear low byte
    or eax, 5           ; Set low byte
    add ebx, eax        ; No stall
    ret

; Or better: use separate register
partial_register_best:
    mov eax, [input]
    mov edx, 5          ; Use different register
    ; Process independently or use movzx/movsx
    ret
```

**Avoiding False Dependencies**:

```assembly
; False dependency through XOR idiom
clear_register_bad:
    sub eax, eax        ; Depends on previous eax value
    ; Processor must wait for previous eax writes
    
; Zero idiom - recognized by processor
clear_register_good:
    xor eax, eax        ; Recognized as register clearing
    ; Breaks dependency chain - executes immediately
    
; Same for other idioms
    xor eax, eax        ; Zero
    sub eax, eax        ; Zero (but creates dependency on some CPUs)
    sbb eax, eax        ; Zero (if carry clear) - creates dependency
    xor eax, eax        ; PREFERRED for zeroing
```

**Branch Prediction and ILP**:

```assembly
; Unpredictable branches hurt ILP
process_with_branch:
.loop:
    mov eax, [esi]
    test eax, 1         ; Check if odd
    jz .even
    ; Odd processing
    imul eax, 3
    jmp .continue
.even:
    ; Even processing
    shr eax, 1
.continue:
    mov [edi], eax
    add esi, 4
    add edi, 4
    dec ecx
    jnz .loop
    ret

; Branch mispredictions cause pipeline flushes
; Can lose 15-20 cycles per misprediction
```

```assembly
; Branchless with conditional moves
process_branchless:
.loop:
    mov eax, [esi]
    mov ebx, eax
    mov edx, eax
    
    imul ebx, 3         ; Odd case result
    shr edx, 1          ; Even case result
    
    test eax, 1         ; Check odd/even
    cmovz ebx, edx      ; Select even result if zero
    
    mov [edi], ebx
    add esi, 4
    add edi, 4
    dec ecx
    jnz .loop
    ret

; No branch mispredictions, both paths computed
; Better for unpredictable data
```

**SIMD and ILP**:

```assembly
; SIMD naturally provides data-level parallelism
; Process 4 elements simultaneously
vector_add_sse:
    movdqu xmm0, [array1]       ; Load 4 integers
    movdqu xmm1, [array2]       ; Load 4 more - independent
    movdqu xmm2, [array1 + 16]  ; Load next 4 - independent
    movdqu xmm3, [array2 + 16]  ; Load next 4 - independent
    
    paddd xmm0, xmm1            ; Add 4 elements - independent
    paddd xmm2, xmm3            ; Add 4 more - independent
    
    movdqu [result], xmm0
    movdqu [result + 16], xmm2
    ret

; 8 integer additions with 2 instructions
; Plus loads/stores execute in parallel
```

**Key Points**:

- Modern x86 CPUs can execute 4-8 instructions per cycle with sufficient ILP
- Dependency chains are the primary limiter of ILP
- Breaking computations into independent operations enables parallel execution
- Multiple accumulators reduce dependency chains in loops
- Memory operations can execute in parallel if addresses are independent
- Good instruction scheduling groups independent operations together
- LEA instruction can combine multiple operations with low latency
- XOR reg, reg idiom breaks dependencies for register clearing
- Partial register updates can cause stalls on some processors
- Branch mispredictions destroy ILP - use branchless code for unpredictable branches
- Out-of-order execution automatically exploits ILP, but explicit optimization helps
- Profile with performance counters to identify ILP bottlenecks
- Look for low IPC (instructions per cycle) as indicator of dependency problems

