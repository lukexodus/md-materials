## CPU Cycles and Instruction Latency


### Fundamental Performance Metrics

**Latency**: Time from when instruction receives its operands until it produces its result (measured in clock cycles).

**Throughput** (Reciprocal): How frequently an instruction can be issued (measured in cycles per instruction or instructions per cycle).

**Execution Port**: Functional unit where instruction executes. Modern CPUs have multiple ports enabling parallel execution.

### Clock Cycles and Timing

**Reading Time Stamp Counter (TSC):**

```nasm
; RDTSC - Read Time Stamp Counter
rdtsc                           ; EDX:EAX = 64-bit cycle count
; EDX = high 32 bits, EAX = low 32 bits

; Store starting time
rdtsc
mov [start_time_low], eax
mov [start_time_high], edx

; Code to measure
; ... instructions ...

; Read ending time
rdtsc
mov [end_time_low], eax
mov [end_time_high], edx

; Calculate elapsed cycles
mov eax, [end_time_low]
sub eax, [start_time_low]
mov ebx, [end_time_high]
sbb ebx, [start_time_high]
; EBX:EAX = elapsed cycles
```

**RDTSCP - Serializing TSC Read:**

```nasm
; RDTSCP ensures all previous instructions complete
rdtscp                          ; EDX:EAX = TSC, ECX = processor ID
; Returns CPU/core ID in ECX (useful for detecting thread migration)
```

**Serializing Instructions for Accurate Measurement:**

```nasm
; Full serialization before measurement
cpuid                           ; Serializes all previous instructions
rdtsc
mov [start_time_low], eax
mov [start_time_high], edx

; Code to measure
; ...

; Serialize before reading end time
cpuid
rdtsc
mov [end_time_low], eax
mov [end_time_high], edx
```

**LFENCE for Lighter Serialization:**

```nasm
; LFENCE prevents later loads from executing early
lfence
rdtsc
mov [start_time], eax

; Code to measure
; ...

lfence
rdtsc
sub eax, [start_time]           ; Elapsed cycles
```

### Instruction Latency Examples

**Integer ALU Operations:**

```nasm
; ADD - Latency: 1 cycle, Throughput: 4 per cycle (typical modern CPU)
add eax, ebx                    ; Result available next cycle

; INC - Latency: 1 cycle, Throughput: 4 per cycle
inc ecx                         ; Result available next cycle

; IMUL (32-bit) - Latency: 3 cycles, Throughput: 1 per cycle
imul eax, ebx                   ; Result available after 3 cycles

; DIV (32-bit) - Latency: ~25-40 cycles, Throughput: ~25-40 cycles
div ebx                         ; Very slow, blocks execution
```

**Memory Operations:**

```nasm
; MOV from L1 cache - Latency: 4-5 cycles
mov eax, [memory]               ; If in L1 data cache

; MOV from L2 cache - Latency: 12-14 cycles
mov eax, [memory]               ; If in L2 cache

; MOV from L3 cache - Latency: 40-50 cycles
mov eax, [memory]               ; If in L3 cache

; MOV from main memory - Latency: 200+ cycles
mov eax, [memory]               ; Cache miss to RAM
```

**Floating-Point Operations:**

```nasm
; ADDSS (scalar single-precision) - Latency: 3-4 cycles, Throughput: 1-2 per cycle
addss xmm0, xmm1

; MULSS (scalar single-precision) - Latency: 4-5 cycles, Throughput: 0.5-1 per cycle
mulss xmm0, xmm1

; DIVSS (scalar single-precision) - Latency: 10-14 cycles, Throughput: 3-14 cycles
divss xmm0, xmm1                ; Slow, avoid if possible

; SQRTSS (scalar single-precision) - Latency: 12-18 cycles, Throughput: 3-18 cycles
sqrtss xmm0, xmm1               ; Very slow
```

**SSE/AVX Operations:**

```nasm
; PADDD (packed 32-bit integer add) - Latency: 1 cycle, Throughput: 2-3 per cycle
paddd xmm0, xmm1

; PMULLD (packed 32-bit integer multiply) - Latency: 10 cycles, Throughput: 1-2 cycles
pmulld xmm0, xmm1

; VADDPS (AVX packed single-precision add) - Latency: 3-4 cycles, Throughput: 1-2 per cycle
vaddps ymm0, ymm1, ymm2

; VFMADD (Fused multiply-add) - Latency: 4-5 cycles, Throughput: 0.5-1 per cycle
vfmadd231ps ymm0, ymm1, ymm2    ; ymm0 = (ymm1 * ymm2) + ymm0
```

### Dependency Chains

**Data Dependencies Impact Performance:**

```nasm
; Chain of dependent operations - executes serially
mov eax, 1
add eax, 2                      ; Depends on previous ADD
add eax, 3                      ; Depends on previous ADD
add eax, 4                      ; Depends on previous ADD
; Total latency: 4 cycles (if ADD latency = 1 cycle)

; Independent operations - can execute in parallel
mov eax, 1
mov ebx, 2
mov ecx, 3
mov edx, 4
add eax, ebx                    ; Independent
add ecx, edx                    ; Independent
; Both ADDs can execute simultaneously on different ports
```

**Breaking Dependency Chains:**

```nasm
; Bad: Long dependency chain
imul eax, 10
imul eax, 10
imul eax, 10
imul eax, 10
; Total: 4 × 3 = 12 cycles

; Better: Parallel multiplication
mov ebx, eax
imul eax, 10
imul ebx, 10
imul eax, ebx                   ; Combine results
imul eax, 10
imul eax, 10
; Faster due to some parallelism
```

**False Dependencies:**

```nasm
; Partial register stall (older CPUs)
mov al, 1                       ; Write 8-bit register
mov eax, [memory]               ; Read full 32-bit register
; May cause stall on older CPUs due to partial register merge

; Avoiding partial register issues
movzx eax, byte [memory]        ; Zero-extend avoids merge
```

### Pipeline Characteristics

**Modern CPU Pipeline Stages:**

1. **Fetch**: Retrieve instructions from L1 instruction cache
2. **Decode**: Convert x86 instructions to micro-ops (μops)
3. **Rename**: Map architectural registers to physical registers
4. **Schedule**: Wait for operands and execution unit availability
5. **Execute**: Perform operation on execution port
6. **Retire**: Commit results in program order

**Branch Misprediction Penalty:**

```nasm
; Branch misprediction costs ~15-20 cycles on modern CPUs
cmp eax, ebx
je target                       ; If mispredicted: pipeline flush

; Minimize branches in hot paths
; Predictable branches are cheaper than unpredictable ones
```

**Branch Prediction Hints:**

```nasm
; Static prediction: forward branches predicted not taken
cmp eax, 0
jz forward_label                ; Predicted not taken

backward_label:
cmp eax, 100
jl backward_label               ; Predicted taken (loop)
```

### Micro-Operation (μop) Fusion

**Macro-fusion: Combining Instructions:**

```nasm
; Compare + branch can fuse into single μop
cmp eax, ebx
je target                       ; Fuses with CMP (1 μop total)

; Test + branch can fuse
test eax, eax
jz target                       ; Fuses with TEST (1 μop total)

; ADD/SUB + branch can fuse
dec ecx
jnz loop_start                  ; Fuses (1 μop total)
```

**Micro-fusion: Memory Operands:**

```nasm
; Memory operand can micro-fuse with ALU operation
add eax, [memory]               ; 1 μop (load + add fused)

; Without micro-fusion would be:
; mov ebx, [memory]             ; 1 μop
; add eax, ebx                  ; 1 μop
```

### Execution Ports and Throughput

**Typical Modern CPU Port Layout:**

```
Port 0: ALU, FP/Vector multiply, divide
Port 1: ALU, FP/Vector add, multiply
Port 2: Load (AGU)
Port 3: Load (AGU)
Port 4: Store data
Port 5: ALU, Vector shuffle
Port 6: ALU, Branch
Port 7: Store address (AGU)
```

**Port Pressure Example:**

```nasm
; High port pressure on Port 0
imul eax, ebx                   ; Port 0
imul ecx, edx                   ; Port 0 (must wait for previous)
imul esi, edi                   ; Port 0 (serialized)
; Throughput limited by single port

; Better: Mix instruction types
imul eax, ebx                   ; Port 0
add ecx, edx                    ; Port 0, 1, 5, or 6 (parallel)
imul esi, edi                   ; Port 0
add r8d, r9d                    ; Port 0, 1, 5, or 6 (parallel)
```

