## Micro-Benchmarking


Micro-benchmarking measures the performance of small code fragments in isolation. Accurate micro-benchmarking requires careful methodology to avoid measurement artifacts.

### Micro-Benchmark Infrastructure

**Basic Timing Framework:**

```assembly
; Micro-benchmark template
section .data
    iterations dd 1000000
    cycles_total dq 0
    
section .text
microbenchmark:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    ; Warm up caches and branch predictors
    mov ecx, 1000
.warmup:
    call code_to_benchmark
    loop .warmup
    
    ; Actual measurement
    mov esi, [iterations]
    xor edi, edi            ; Cycle accumulator low
    xor ebx, ebx            ; Cycle accumulator high
    
.measure_loop:
    ; Serialize and time
    cpuid
    rdtsc
    push edx
    push eax
    
    ; Code under test
    call code_to_benchmark
    
    ; Serialize and time
    rdtsc
    mov ecx, eax
    mov edx, edx
    pop eax                 ; Start time low
    pop edx                 ; Start time high
    
    ; Calculate elapsed
    sub ecx, eax
    sbb edx, edx
    
    ; Accumulate
    add edi, ecx
    adc ebx, edx
    
    dec esi
    jnz .measure_loop
    
    ; Store total cycles
    mov [cycles_total], edi
    mov [cycles_total + 4], ebx
    
    ; Calculate average: total / iterations
    mov eax, edi
    mov edx, ebx
    mov ecx, [iterations]
    div ecx                 ; EAX = average cycles
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
```

**Isolating Measurement Overhead:**

```assembly
; Measure baseline overhead
measure_overhead:
    ; Time empty call
    cpuid
    rdtsc
    mov esi, eax
    mov edi, edx
    
    ; Empty function
    call empty_function
    
    cpuid
    rdtsc
    sub eax, esi
    sbb edx, edi
    ; EDX:EAX = overhead
    
    mov [timing_overhead], eax
    ret

empty_function:
    ret

; Subtract overhead from measurements
get_true_cycles:
    mov eax, [measured_cycles]
    sub eax, [timing_overhead]
    ; EAX = actual code cycles
    ret
```

### Avoiding Micro-Benchmark Pitfalls

**Problem 1: Compiler/CPU Optimization Interference:**

```assembly
; Problematic: Dead code elimination
benchmark_dead_code:
    mov eax, 10
    add eax, 20
    imul eax, 3
    ; Result never used - might be optimized away
    ret

; Solution: Use result to prevent elimination
benchmark_with_side_effect:
    mov eax, 10
    add eax, 20
    imul eax, 3
    mov [global_result], eax    ; Force computation
    ret
```

**Problem 2: Cache State Effects:**

```assembly
; Cold cache benchmark
benchmark_cold_cache:
    ; Flush cache first
    call flush_all_caches
    
    ; Now benchmark
    rdtsc
    ; ... code ...
    rdtsc
    ret

; Warm cache benchmark
benchmark_warm_cache:
    ; Prime cache
    call code_to_benchmark
    
    ; Now benchmark with hot cache
    rdtsc
    call code_to_benchmark
    rdtsc
    ret

; Both measurements are valuable
; Cold shows worst case, warm shows best case
```

**Problem 3: Context Switching:**

```assembly
; Pin to specific CPU core to avoid migration
; (Linux example using sched_setaffinity syscall)
pin_to_core:
    ; Set CPU affinity mask
    mov eax, 203            ; sys_sched_setaffinity
    mov ebx, 0              ; current process
    mov ecx, 4              ; cpusetsize
    mov edx, cpu_mask       ; Mask with core 0 set
    int 0x80
    ret

section .data
cpu_mask dd 0x01            ; Core 0
```

**Problem 4: Variable Latency Instructions:**

```assembly
; Division latency varies by operand values
benchmark_division:
    mov ecx, iterations
    rdtsc
    mov esi, eax
    
.loop:
    mov eax, 100
    xor edx, edx
    div dword [divisor]     ; Latency depends on divisor value
    loop .loop
    
    rdtsc
    sub eax, esi
    
    ; Run with different divisor values:
    ; divisor = 2: ~20 cycles
    ; divisor = 999999: ~40 cycles
    ret
```

### Micro-Benchmark Examples

**Instruction Latency Measurement:**

```assembly
; Measure instruction latency (dependency chain)
measure_latency:
    mov ecx, 1000
    rdtsc
    push eax
    push edx
    
.loop:
    ; Create dependency chain
    mov eax, 1
    add eax, eax            ; Depends on previous
    add eax, eax            ; Depends on previous
    add eax, eax            ; Depends on previous
    add eax, eax            ; Depends on previous
    ; ... repeat many times ...
    
    dec ecx
    jnz .loop
    
    rdtsc
    pop edx
    pop ebx
    sub eax, ebx
    
    ; Divide by (iterations * operations) to get per-op latency
    ret
```

**Instruction Throughput Measurement:**

```assembly
; Measure instruction throughput (independent operations)
measure_throughput:
    mov ecx, 1000
    rdtsc
    push eax
    push edx
    
.loop:
    ; Independent operations (no dependencies)
    mov eax, 1
    mov ebx, 2
    mov ecx, 3
    mov edx, 4
    add eax, 5
    add ebx, 6
    add ecx, 7
    add edx, 8
    ; These can execute in parallel
    
    dec ecx
    jnz .loop
    
    rdtsc
    pop edx
    pop ebx
    sub eax, ebx
    
    ; Lower time indicates better throughput
    ret
```

**Memory Latency Measurement:**

```assembly
; Measure memory latency via pointer chasing
measure_memory_latency:
    ; Create linked list with large strides
    ; Each node points to next, spaced far apart
    
    mov esi, [list_head]
    mov ecx, 1000
    
    rdtsc
    push eax
    push edx
    
.loop:
    mov esi, [esi]          ; Chase pointer (serialized)
    mov esi, [esi]
    mov esi, [esi]
    mov esi, [esi]
    ; Each load depends on previous
    
    dec ecx
    jnz .loop
    
    rdtsc
    pop edx
    pop ebx
    sub eax, ebx
    
    ; Divide by (iterations * 4) to get per-access latency
    ; Results show cache level latencies:
    ; L1: ~4 cycles
    ; L2: ~12 cycles
    ; L3: ~40 cycles
    ; RAM: ~200 cycles
    ret
```

**Branch Prediction Measurement:**

```assembly
; Measure branch prediction penalty
measure_branch_cost:
    mov ecx, 10000
    
    ; Predictable branch
    rdtsc
    push eax
.predictable:
    cmp ecx, 0
    jle .pred_done
    dec ecx
    jmp .predictable
.pred_done:
    rdtsc
    pop ebx
    sub eax, ebx
    mov [predictable_time], eax
    
    ; Unpredictable branch
    mov ecx, 10000
    rdtsc
    push eax
.unpredictable:
    mov ebx, [random_data + ecx*4]
    test ebx, 1
    jz .unp_target
.unp_target:
    dec ecx
    jnz .unpredictable
    
    rdtsc
    pop ebx
    sub eax, ebx
    mov [unpredictable_time], eax
    
    ; Difference shows misprediction penalty
    ; Typically 15-20 cycles per misprediction
    ret
```

### Statistical Analysis of Benchmarks

**Multiple Measurements:**

```assembly
; Run benchmark multiple times
benchmark_statistical:
    mov edi, num_runs       ; e.g., 100
    mov esi, results_array
    
.run_loop:
    call microbenchmark
    mov [esi], eax          ; Store result
    add esi, 4
    dec edi
    jnz .run_loop
    
    ; Calculate statistics
    call calculate_mean
    mov [mean_cycles], eax
    
    call calculate_median
    mov [median_cycles], eax
    
    call calculate_min
    mov [min_cycles], eax
    
    call calculate_stddev
    mov [stddev_cycles], eax
    
    ret

; Minimum often most meaningful
; (represents best case without interference)
```

**Outlier Detection:**

```assembly
; Detect and remove outliers
remove_outliers:
    ; Calculate mean
    call calculate_mean
    mov [mean], eax
    
    ; Calculate standard deviation
    call calculate_stddev
    mov [stddev], eax
    
    ; Remove values > mean + 2*stddev
    mov esi, results_array
    mov edi, filtered_array
    mov ecx, num_samples
    
.filter_loop:
    mov eax, [esi]
    mov ebx, [mean]
    sub eax, ebx            ; Deviation from mean
    ; Check if abs(dev) > 2*stddev
    mov ebx, [stddev]
    shl ebx, 1              ; 2*stddev
    cmp eax, ebx
    jg .skip                ; Outlier, skip it
    
    mov eax, [esi]
    mov [edi], eax          ; Keep this sample
    add edi, 4
    
.skip:
    add esi, 4
    loop .filter_loop
    
    ret
```

