## Register Allocation Strategies


Efficient register allocation minimizes memory access overhead by keeping frequently-used values in registers rather than memory.

**x86 Register Overview**:

**General Purpose Registers (GPR)** - 64-bit mode:

```
RAX, RBX, RCX, RDX    - Traditional accumulator/base/count/data
RSI, RDI              - Source/destination index
RBP, RSP              - Base/stack pointer
R8-R15                - Additional registers (64-bit mode only)
```

**32-bit mode**: EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP (8 registers)

**Calling Convention Considerations**:

Different conventions specify which registers are preserved across function calls:

**System V AMD64 ABI** (Linux, macOS):

- **Caller-saved**: RAX, RCX, RDX, RSI, RDI, R8-R11
- **Callee-saved**: RBX, RBP, R12-R15
- **Parameters**: RDI, RSI, RDX, RCX, R8, R9
- **Return value**: RAX

**Microsoft x64 calling convention** (Windows):

- **Caller-saved**: RAX, RCX, RDX, R8-R11
- **Callee-saved**: RBX, RBP, RDI, RSI, R12-R15
- **Parameters**: RCX, RDX, R8, R9
- **Return value**: RAX

```assembly
; Function using callee-saved registers
optimized_function:
    ; Save callee-saved registers we'll use
    push rbx
    push r12
    push r13
    push r14
    
    ; Now we have 4 additional registers for computation
    mov rbx, rdi        ; Use rbx for parameter
    xor r12, r12        ; Use r12 as accumulator
    mov r13, 1000       ; Use r13 as counter
    
.loop:
    mov r14, [rbx]      ; Use r14 for temp
    add r12, r14
    add rbx, 8
    dec r13
    jnz .loop
    
    mov rax, r12        ; Return result
    
    ; Restore callee-saved registers
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
```

**Register Pressure**:

Register pressure occurs when there aren't enough registers for all values that should be kept in registers, forcing memory spills.

```assembly
; High register pressure - needs 10 values simultaneously
high_pressure:
    mov eax, [input1]
    mov ebx, [input2]
    mov ecx, [input3]
    mov edx, [input4]
    mov esi, [input5]
    mov edi, [input6]
    mov r8d, [input7]
    mov r9d, [input8]
    ; Out of registers! Must spill to memory
    mov [temp1], eax    ; SPILL
    mov eax, [input9]
    ; ... compute ...
    mov r10d, [temp1]   ; RELOAD
    ret

; Memory spills hurt performance significantly
```

**Reducing Register Pressure**:

**Technique 1: Recompute vs Spill**:

```assembly
; Spilling value
with_spill:
    lea eax, [rbx + rcx*4 + 8]  ; Compute address
    mov [temp], eax             ; Spill to memory
    ; ... many operations ...
    mov edx, [temp]             ; Reload
    ret

; Recomputing value (if computation cheap)
with_recompute:
    lea eax, [rbx + rcx*4 + 8]  ; Compute address
    ; ... many operations ...
    lea edx, [rbx + rcx*4 + 8]  ; Recompute (faster than memory access)
    ret
```

**Technique 2: Narrow Live Ranges**:

```assembly
; Wide live range - value needed for long time
wide_live_range:
    mov eax, [input1]       ; EAX allocated here
    ; ... 100 lines of code ...
    add eax, [input2]       ; EAX still needed here
    ret
; EAX tied up for entire function

; Narrow live range - defer computation
narrow_live_range:
    ; ... 100 lines of code ...
    mov eax, [input1]       ; EAX allocated late
    add eax, [input2]       ; Used immediately
    ret
; EAX only tied up for 2 instructions
```

**Technique 3: Register Reuse**:

```assembly
; Poor reuse - each value gets separate register
poor_reuse:
    mov eax, [input1]
    add eax, 10
    mov [output1], eax
    
    mov ebx, [input2]       ; Could reuse EAX
    add ebx, 20
    mov [output2], ebx
    
    mov ecx, [input3]       ; Could reuse EAX or EBX
    add ecx, 30
    mov [output3], ecx
    ret
; Uses 3 registers unnecessarily

; Good reuse - recycle registers after values no longer needed
good_reuse:
    mov eax, [input1]
    add eax, 10
    mov [output1], eax
    
    mov eax, [input2]       ; Reuse EAX
    add eax, 20
    mov [output2], eax
    
    mov eax, [input3]       ; Reuse EAX again
    add eax, 30
    mov [output3], eax
    ret
; Uses only 1 register
```

**Register Allocation Algorithms**:

**Linear Scan Allocation**: Simple, fast algorithm suitable for JIT compilation

```
1. Calculate live intervals for each variable
2. Sort intervals by starting point
3. Scan intervals, assigning registers to active intervals
4. Spill when no registers available
```

**Graph Coloring**: More sophisticated, used by optimizing compilers

```
1. Build interference graph (variables that are live simultaneously)
2. Color graph with K colors (K = number of registers)
3. Spill nodes that cannot be colored
```

[Inference: These algorithms are typically implemented in compilers, but understanding them helps write register-friendly assembly]

**Register Allocation Example - Matrix Multiply**:

```assembly
; Poor register allocation
matrix_mult_poor:
    ; Repeatedly loads same values
.loop_i:
    .loop_j:
        .loop_k:
            mov eax, [a + i_offset]     ; Load A element
            imul eax, [b + j_offset]    ; Load B element
            add [c + ij_offset], eax    ; Store to C
            ; Every iteration reloads from memory
            dec k_counter
            jnz .loop_k
        dec j_counter
        jnz .loop_j
    dec i_counter
    jnz .loop_i
    ret

; Good register allocation - block matrix multiply
matrix_mult_good:
    ; Process small blocks that fit in registers
    ; Keep frequently accessed values in registers
.loop_i:
    .loop_j:
        ; Load block of A into registers
        mov r8, [a + i_offset]
        mov r9, [a + i_offset + 8]
        mov r10, [a + i_offset + 16]
        mov r11, [a + i_offset + 24]
        
        ; Initialize accumulator block in registers
        xor eax, eax
        xor ebx, ebx
        xor ecx, ecx
        xor edx, edx
        
.loop_k:
        ; Load B elements
        mov r12, [b + k_offset]
        mov r13, [b + k_offset + 8]
        mov r14, [b + k_offset + 16]
        mov r15, [b + k_offset + 24]
        
        ; Compute using register values
        imul r12, r8
        add eax, r12d
        imul r13, r9
        add ebx, r13d
        imul r14, r10
        add ecx, r14d
        imul r15, r11
        add edx, r15d
        
        dec k_counter
        jnz .loop_k
        
        ; Store accumulated results
        mov [c + ij_offset], eax
        mov [c + ij_offset + 8], ebx
        mov [c + ij_offset + 16], ecx
        mov [c + ij_offset + 24], edx
        
    dec j_counter
    jnz .loop_j
    dec i_counter
    jnz .loop_i
    ret

; Dramatic reduction in memory traffic
; Values loaded once per block vs once per element
```

**Register Allocation for Loop Invariants**:

```assembly
; Loop invariant computed repeatedly
invariant_poor:
    mov ecx, 1000
.loop:
    mov eax, [base_ptr]
    lea ebx, [eax + offset]     ; Invariant - always same value
    mov edx, [ebx]              ; Use invariant address
    ; ... process edx ...
    dec ecx
    jnz .loop
    ret

; Hoist invariant outside loop
invariant_good:
    mov eax, [base_ptr]
    lea ebx, [eax + offset]     ; Compute once, keep in register
    mov ecx, 1000
.loop:
    mov edx, [ebx]              ; Use register value
    ; ... process edx ...
    dec ecx
    jnz .loop
    ret

; EBX stays allocated for entire loop but saves 2 instructions per iteration
```

**Induction Variable Optimization**:

```assembly
; Array indexing with multiplication
array_access_poor:
    xor ecx, ecx            ; i = 0
    mov edx, 1000
.loop:
    mov eax, ecx
    shl eax, 2              ; i * 4 (recomputed each iteration)
    mov ebx, [array + eax]
    ; ... process ebx ...
    inc ecx
    cmp ecx, edx
    jl .loop
    ret

; Strength reduction - use addition instead
array_access_good:
    xor eax, eax            ; offset = 0 (induction variable)
    mov ecx, 1000
.loop:
    mov ebx, [array + eax]  ; Direct offset use
    ; ... process ebx ...
    add eax, 4              ; offset += 4 (addition vs multiplication)
    dec ecx
    jnz .loop
    ret

; EAX tracks array offset directly - simpler, faster
```

**Pointer Arithmetic Optimization**:

```assembly
; Multiple pointer calculations
pointer_calc_poor:
    mov rsi, [array_ptr]
.loop:
    mov eax, [rsi + offset1]    ; First array access
    add eax, [rsi + offset2]    ; Second array access
    mov [rsi + offset3], eax    ; Third array access
    add rsi, 16
    dec ecx
    jnz .loop
    ret

; Pre-calculate multiple pointers
pointer_calc_good:
    mov rsi, [array_ptr]
    lea rdi, [rsi + offset1]    ; Pointer to first element
    lea r8, [rsi + offset2]     ; Pointer to second element
    lea r9, [rsi + offset3]     ; Pointer to third element
.loop:
    mov eax, [rdi]              ; No offset calculation
    add eax, [r8]
    mov [r9], eax
    add rdi, 16                 ; Increment all pointers
    add r8, 16
    add r9, 16
    dec ecx
    jnz .loop
    ret

; More registers used but eliminates repeated offset calculations
```

**Register Packing for Small Values**:

```assembly
; Storing multiple small values in one register (when appropriate)
pack_values:
    ; Pack two 16-bit values in one 32-bit register
    movzx eax, word [value1]    ; Low 16 bits
    movzx ebx, word [value2]
    shl ebx, 16                 ; Shift to high 16 bits
    or eax, ebx                 ; Combine: EAX = [value2:value1]
    
    ; Now use EAX instead of two separate registers
    
    ; Unpack when needed
    mov ebx, eax
    and eax, 0xFFFF             ; Extract low 16 bits
    shr ebx, 16                 ; Extract high 16 bits
    ret

; Useful when register pressure is extreme
; Trade-off: packing/unpacking overhead vs register savings
```

**Register Allocation with SIMD**:

```assembly
; Scalar processing - one value per register
scalar_process:
    xor eax, eax            ; 1 accumulator
    mov ecx, 1000
.loop:
    add eax, [esi]
    add esi, 4
    dec ecx
    jnz .loop
    ret

; SIMD processing - 4 values per register
simd_process:
    pxor xmm0, xmm0         ; 1 register holds 4 accumulators
    mov ecx, 250            ; Process 4x elements per iteration
.loop:
    paddd xmm0, [esi]       ; Add 4 values simultaneously
    add esi, 16
    dec ecx
    jnz .loop
    
    ; Horizontal sum
    movdqa xmm1, xmm0
    psrldq xmm1, 8
    paddd xmm0, xmm1
    movdqa xmm1, xmm0
    psrldq xmm1, 4
    paddd xmm0, xmm1
    movd eax, xmm0
    ret

; XMM registers effectively multiply register capacity
; 16 XMM registers × 4 integers = 64 integer values
```

**Function Inlining to Improve Register Allocation**:

```assembly
; Function call forces register saves/restores
with_call:
    mov eax, [data1]
    mov ebx, [data2]
    push rbx                ; Save register
    push rax
    call helper_function
    pop rax                 ; Restore
    pop rbx
    add eax, ebx
    ret

; Inlined - no save/restore needed
inlined:
    mov eax, [data1]
    mov ebx, [data2]
    ; Inline helper_function code here
    ; ... helper operations using available registers ...
    add eax, ebx
    ret

; Saves push/pop overhead and preserves register allocation
```

**Register Allocation Heuristics**:

**Priority Guidelines**:

1. **Loop counters and induction variables**: Keep in registers (accessed every iteration)
2. **Frequently accessed variables**: Higher priority for registers
3. **Address calculations**: Pre-compute and store in registers
4. **Function parameters**: Already in registers (calling convention), keep them there
5. **Constants**: Load once, keep in registers rather than immediate operands

```assembly
; Applying priorities
optimized_loop:
    ; Loop counter (highest priority)
    mov ecx, 1000               ; ECX dedicated to counter
    
    ; Frequently accessed base address (high priority)
    mov rsi, [array_base]       ; RSI for array base
    
    ; Accumulator (high priority)
    xor eax, eax                ; EAX for sum
    
    ; Pre-computed constant (medium priority)
    mov ebx, 42                 ; Constant used in loop
    
.loop:
    ; All key values in registers
    mov edx, [rsi]              ; Temporary in EDX (low priority)
    add edx, ebx                ; Use pre-loaded constant
    add eax, edx                ; Update accumulator
    add rsi, 4                  ; Update pointer
    dec ecx                     ; Update counter
    jnz .loop
    ret

; No memory spills, all critical values stay in registers
```

**Analyzing Register Usage**:

```assembly
; Color-coded register lifetimes (conceptual)
analyze_usage:
    mov eax, [input]        ; EAX born here -----------+
    mov ebx, [data]         ; EBX born here -------+   |
    add eax, ebx            ; Both used           |   |
    mov [output1], eax      ; EAX dies here ------+   |
    shl ebx, 2              ; EBX still live      |
    mov eax, [input2]       ; EAX reborn ---------+   |
    add eax, ebx            ; Both used           |   |
    mov [output2], eax      ; EAX dies -----------+   |
    mov [output3], ebx      ; EBX dies ---------------+
    ret

; EAX has two separate lifetimes - can reuse register
; EBX has one continuous lifetime
; Optimal: 2 registers needed (not 3)
```

**Register Allocation for Different Data Types**:

```assembly
; Integer computation - use GPRs
integer_work:
    mov eax, [int_data1]
    add eax, [int_data2]
    imul eax, [int_data3]
    mov [int_result], eax
    ret

; Floating-point computation - use XMM registers
float_work:
    movss xmm0, [float_data1]
    addss xmm0, [float_data2]
    mulss xmm0, [float_data3]
    movss [float_result], xmm0
    ret

; Don't mix unnecessarily - transfers between GPR/XMM have latency
mixed_bad:
    mov eax, [int_data]
    movd xmm0, eax          ; GPR → XMM transfer (latency penalty)
    addss xmm0, [float_data]
    movd eax, xmm0          ; XMM → GPR transfer (latency penalty)
    mov [int_result], eax
    ret

; Keep data in appropriate register file
mixed_good:
    cvtsi2ss xmm0, [int_data]   ; Convert directly from memory
    addss xmm0, [float_data]
    cvtss2si eax, xmm0          ; Convert directly to GPR
    mov [int_result], eax
    ret
```

**Spilling Strategies**:

```assembly
; When forced to spill, choose wisely
spill_example:
    ; Need 10 values but only 8 registers available
    mov eax, [var1]         ; Frequently used - keep in register
    mov ebx, [var2]         ; Frequently used
    mov ecx, [var3]         ; Frequently used
    mov edx, [var4]         ; Frequently used
    mov esi, [var5]         ; Moderately used
    mov edi, [var6]         ; Moderately used
    mov r8d, [var7]         ; Infrequently used - candidate for spill
    mov r9d, [var8]         ; Infrequently used - candidate for spill
    mov [temp1], r8d        ; SPILL infrequent value
    mov [temp2], r9d        ; SPILL infrequent value
    mov r8d, [var9]         ; Load new value
    mov r9d, [var10]        ; Load new value
    
    ; Main computation with registers
    add eax, ebx
    add ecx, edx
    ; ...
    
    ; Reload spilled values only when needed
    mov r10d, [temp1]
    add r10d, r8d
    mov [result], r10d
    ret

; Spill least-frequently-used values
; Reload only when necessary
```

**Register Windowing (Advanced)**:

```assembly
; Rotating register usage through loop iterations
register_window:
    ; Iteration 0: use EAX, EBX
    ; Iteration 1: use ECX, EDX
    ; Iteration 2: use ESI, EDI
    ; Then repeat
    
    mov ecx, 100
    xor r8d, r8d            ; Iteration counter
.loop:
    mov eax, r8d
    and eax, 3              ; Modulo 4
    
    cmp eax, 0
    je .use_ab
    cmp eax, 1
    je .use_cd
    cmp eax, 2
    je .use_se
    ; ... branch to different register sets
    
.use_ab:
    mov eax, [data + r8*4]
    mov ebx, [data + r8*4 + 4]
    add eax, ebx
    jmp .continue
    
.use_cd:
    mov ecx, [data + r8*4]
    mov edx, [data + r8*4 + 4]
    add ecx, edx
    jmp .continue
    
    ; ... more cases
.continue:
    inc r8d
    dec ecx
    jnz .loop
    ret

; Reduces register pressure by time-multiplexing
; [Inference: More theoretical than practical for modern x86]
```

**Key Points**:

- x86 has 8 GPRs (32-bit) or 16 GPRs (64-bit), plus 16 XMM/YMM/ZMM registers
- Register allocation is most impactful optimization for assembly code
- Calling conventions determine which registers can be freely used vs must be preserved
- Register pressure increases with complex computations and loop nesting
- Prefer recomputing cheap values over spilling to memory
- Narrow variable live ranges to free registers sooner
- Reuse registers aggressively when values no longer needed
- Keep loop counters, accumulators, and frequently-accessed values in registers
- Hoist loop-invariant computations outside loops and keep results in registers
- Use induction variables and strength reduction to simplify register usage
- SIMD registers effectively multiply available register space
- Function inlining improves register allocation across call boundaries
- Spill least-frequently-used values when register pressure is unavoidable
- Don't transfer unnecessarily between GPR and XMM register files
- Profile code to identify register allocation bottlenecks
- Modern compilers are very good at register allocation, but hand-coded assembly can still optimize critical sections

**Related Topics for Further Study**: Compiler optimization techniques, Software pipelining, Cache optimization and blocking, Vectorization with AVX/AVX-512, Profile-guided optimization (PGO), Micro-architectural analysis with performance counters, Automatic performance tuning frameworks

---

