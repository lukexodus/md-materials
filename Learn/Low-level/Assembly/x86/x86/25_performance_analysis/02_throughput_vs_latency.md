## Throughput vs Latency


### Conceptual Difference

**Latency**: Time for single operation to complete. **Throughput**: Rate at which operations can be completed.

[Inference] An instruction can have high latency but high throughput if multiple instances can execute concurrently.

### Practical Examples

**Memory Copy - Optimizing for Throughput:**

```nasm
; Low throughput: Sequential loads and stores
mov eax, [esi]
mov [edi], eax
add esi, 4
add edi, 4
; Limited by load-store dependency

; High throughput: Interleaved operations
mov eax, [esi]
mov ebx, [esi + 4]
mov ecx, [esi + 8]
mov edx, [esi + 12]
mov [edi], eax
mov [edi + 4], ebx
mov [edi + 8], ecx
mov [edi + 12], edx
add esi, 16
add edi, 16
; Multiple loads/stores in flight simultaneously
```

**SIMD Throughput Optimization:**

```nasm
; Single accumulator - limited by latency
pxor xmm0, xmm0                 ; Clear accumulator
loop_start:
    paddd xmm0, [esi]           ; Accumulate (dependent on previous)
    add esi, 16
    dec ecx
    jnz loop_start

; Multiple accumulators - better throughput
pxor xmm0, xmm0
pxor xmm1, xmm1
pxor xmm2, xmm2
pxor xmm3, xmm3
loop_start:
    paddd xmm0, [esi]           ; Independent
    paddd xmm1, [esi + 16]      ; Independent
    paddd xmm2, [esi + 32]      ; Independent
    paddd xmm3, [esi + 48]      ; Independent
    add esi, 64
    sub ecx, 4
    jnz loop_start
; Final reduction
paddd xmm0, xmm1
paddd xmm2, xmm3
paddd xmm0, xmm2
```

**Division - High Latency, Low Throughput:**

```nasm
; Division is both slow and serializing
div ebx                         ; ~25-40 cycles latency, low throughput

; Avoid division when possible
; Replace division by constant with multiplication
; x / 10 ≈ (x * 0xCCCCCCCD) >> 35 (for 32-bit unsigned)
mov eax, [value]
mov edx, 0xCCCCCCCD
mul edx                         ; EDX:EAX = value * constant
shr edx, 3                      ; Result in EDX (value / 10)
```

**Floating-Point Throughput:**

```nasm
; Poor throughput: Single FP operation chain
movss xmm0, [data]
addss xmm0, [data + 4]
addss xmm0, [data + 8]
addss xmm0, [data + 12]
; Limited by addss latency (3-4 cycles)

; Better throughput: Multiple independent chains
movss xmm0, [data]
movss xmm1, [data + 4]
movss xmm2, [data + 8]
movss xmm3, [data + 12]
addss xmm0, [data + 16]
addss xmm1, [data + 20]
addss xmm2, [data + 24]
addss xmm3, [data + 28]
; Multiple additions in flight
```

### Instruction-Level Parallelism (ILP)

**ILP**: Number of instructions that can execute simultaneously.

```nasm
; Low ILP - sequential dependencies
mov eax, [esi]
add eax, 10
mov [edi], eax
inc esi
inc edi
; Limited parallelism

; High ILP - independent operations
mov eax, [esi]                  ; Load
mov ebx, [esi + 4]              ; Independent load
add eax, 10                     ; Independent add
add ebx, 20                     ; Independent add
mov [edi], eax                  ; Store
mov [edi + 4], ebx              ; Independent store
add esi, 8                      ; Address update
add edi, 8                      ; Independent update
; Many operations can execute in parallel
```

### Loop Unrolling for Throughput

```nasm
; Original loop
mov ecx, 1000
loop_start:
    add eax, [esi]
    add esi, 4
    dec ecx
    jnz loop_start
; Loop overhead limits throughput

; Unrolled loop
mov ecx, 250                    ; 1000 / 4
loop_start:
    add eax, [esi]
    add eax, [esi + 4]
    add eax, [esi + 8]
    add eax, [esi + 12]
    add esi, 16
    dec ecx
    jnz loop_start
; Reduced branch overhead, more ILP
```

### Software Pipelining

```nasm
; Traditional loop - each iteration fully completes before next
loop_start:
    mov eax, [esi]              ; Load
    add eax, ebx                ; Process
    mov [edi], eax              ; Store
    add esi, 4
    add edi, 4
    dec ecx
    jnz loop_start

; Software pipelined - overlap iterations
    mov eax, [esi]              ; Prologue: start first load
loop_start:
    add esi, 4
    add eax, ebx                ; Process previous load
    mov edx, [esi]              ; Load for next iteration (parallel)
    mov [edi], eax              ; Store previous result
    add edi, 4
    mov eax, edx                ; Move for next iteration
    dec ecx
    jnz loop_start
    add eax, ebx                ; Epilogue: finish last iteration
    mov [edi], eax
```

