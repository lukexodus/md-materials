## Profiling Tools and Techniques


### Time-Based Profiling

**Simple Function Timer:**

```nasm
section .data
    timer_start: dq 0
    timer_count: dd 0
    timer_total: dq 0

section .text
; Start timing
profile_start:
    push eax
    push edx
    
    rdtsc
    mov [timer_start], eax
    mov [timer_start + 4], edx
    
    pop edx
    pop eax
    ret

; End timing and accumulate
profile_end:
    push eax
    push edx
    push ebx
    
    rdtsc
    mov ebx, eax
    mov ecx, edx
    
    ; Calculate elapsed time
    sub ebx, [timer_start]
    sbb ecx, [timer_start + 4]
    
    ; Accumulate
    add [timer_total], ebx
    adc [timer_total + 4], ecx
    inc dword [timer_count]
    
    pop ebx
    pop edx
    pop eax
    ret

; Get average cycles
profile_get_average:
    mov eax, [timer_total]
    mov edx, [timer_total + 4]
    mov ecx, [timer_count]
    div ecx                     ; EAX = average cycles
    ret
```

**Hierarchical Profiling:**

```nasm
section .data
    MAX_PROFILE_ENTRIES equ 100
    
struc ProfileEntry
    .name:          resq 1      ; Function name pointer
    .total_cycles:  resq 1      ; Total cycles spent
    .call_count:    resd 1      ; Number of calls
    .parent_index:  resd 1      ; Parent function index
endstruc

section .bss
    profile_stack:  resd 32     ; Call stack for hierarchy
    stack_depth:    resd 1
    profile_data:   resb ProfileEntry_size * MAX_PROFILE_ENTRIES
    current_entry:  resd 1

section .text
profile_enter:
    ; Save registers
    push eax
    push edx
    
    ; Find or create profile entry
    call find_profile_entry     ; Returns index in EAX
    
    ; Record start time
    rdtsc
    mov ebx, [current_entry]
    lea ebx, [profile_data + ebx * ProfileEntry_size]
    mov [ebx + ProfileEntry.start_time], eax
    mov [ebx + ProfileEntry.start_time + 4], edx
    
    ; Push to call stack
    mov ecx, [stack_depth]
    mov [profile_stack + ecx * 4], eax
    inc dword [stack_depth]
    
    pop edx
    pop eax
    ret

profile_exit:
    push eax
    push edx
    push ebx
    
    ; Read end time
    rdtsc
    mov esi, eax
    mov edi, edx
    
    ; Pop from stack
    dec dword [stack_depth]
    mov ecx, [stack_depth]
    mov ebx, [profile_stack + ecx * 4]
    
    ; Calculate elapsed and accumulate
    lea ebx, [profile_data + ebx * ProfileEntry_size]
    sub esi, [ebx + ProfileEntry.start_time]
    sbb edi, [ebx + ProfileEntry.start_time + 4]
    add [ebx + ProfileEntry.total_cycles], esi
    adc [ebx + ProfileEntry.total_cycles + 4], edi
    inc dword [ebx + ProfileEntry.call_count]
    
    pop ebx
    pop edx
    pop eax
    ret
```

### Cache Profiling

**Detect Cache Line Conflicts:**

```nasm
; Test for cache line conflicts
test_cache_conflicts:
    ; Access pattern that tests specific cache sets
    mov esi, [test_array]
    mov ecx, 1000
    
    rdtsc
    mov [start_time], eax
    
.test_loop:
    ; Access elements that map to same cache set
    mov eax, [esi]              ; Line 0
    mov eax, [esi + 4096]       ; Line 64 (same set, different way)
    mov eax, [esi + 8192]       ; Line 128 (conflict?)
    mov eax, [esi + 12288]      ; Line 192 (conflict?)
    
    add esi, 64                 ; Move to next cache line
    loop .test_loop
    
    rdtsc
    sub eax, [start_time]
    ; High cycle count indicates cache conflicts
    
    ret
```

**Cache Miss Profiling:**

```nasm
profile_cache_behavior:
    ; Configure cache miss counter
    mov ecx, 0x186
    mov eax, 0x00430151         ; L1 load misses
    xor edx, edx
    wrmsr
    
    mov ecx, 0xC1
    xor eax, eax
    xor edx, edx
    wrmsr
    
    ; Run code
    call target_function
    
    ; Read miss count
    mov ecx, 0xC1
    rdmsr
    mov [l1_misses], eax
    
    ; Calculate miss rate
    ; miss_rate = misses / total_accesses
    
    ret
```

### Branch Prediction Profiling

```nasm
profile_branch_prediction:
    ; Configure counters
    ; Counter 0: Total branches
    mov ecx, 0x186
    mov eax, 0x004300C4         ; Branch instructions retired
    xor edx, edx
    wrmsr
    
    ; Counter 1: Branch mispredictions
    mov ecx, 0x187
    mov eax, 0x004300C5         ; Mispredicted branches
    xor edx, edx
    wrmsr
    
    ; Reset counters
    mov ecx, 0xC1
    xor eax, eax
    xor edx, edx
    wrmsr
    
    mov ecx, 0xC2
    xor eax, eax
    xor edx, edx
    wrmsr
    
    ; Run code to profile
    call target_function
    
    ; Read total branches
    mov ecx, 0xC1
    rdmsr
    mov [total_branches], eax
    
    ; Read mispredictions
    mov ecx, 0xC2
    rdmsr
    mov [mispredictions], eax
    
    ; Calculate misprediction rate
    ; rate = (mispredictions * 100) / total_branches
    mov eax, [mispredictions]
    mov ebx, 100
    mul ebx
    div dword [total_branches]
    mov [mispredict_rate], eax  ; Percentage
    
    ret
```

### Memory Bandwidth Profiling

```nasm
measure_memory_bandwidth:
    ; Setup: Configure counter for memory reads
    mov ecx, 0x186
    mov eax, 0x004381D0         ; Memory loads retired
    xor edx, edx
    wrmsr
    
    mov ecx, 0xC1
    xor eax, eax
    xor edx, edx
    wrmsr
    
    ; Read TSC start
    rdtsc
    mov [start_cycles], eax
    mov [start_cycles + 4], edx
    
    ; Perform memory-intensive operation
    mov esi, [large_buffer]
    mov ecx, 1048576            ; 1M iterations
    
.bandwidth_loop:
    movdqa xmm0, [esi]          ; Load 16 bytes
    movdqa xmm1, [esi + 16]
    movdqa xmm2, [esi + 32]
    movdqa xmm3, [esi + 48]
    add esi, 64
    loop .bandwidth_loop
    
    ; Read TSC end
    rdtsc
    sub eax, [start_cycles]
    sbb edx, [start_cycles + 4]
    mov [elapsed_cycles], eax
    
    ; Read load count
    mov ecx, 0xC1
    rdmsr
    mov [load_count], eax
    
    ; Calculate bandwidth (bytes/cycle)
    ; bandwidth = (bytes_transferred) / elapsed_cycles
    mov eax, 1048576
    mov ebx, 64                 ; 64 bytes per iteration
    mul ebx                     ; Total bytes in EDX:EAX
    div dword [elapsed_cycles]  ; EAX = bytes/cycle
    
    ret
```

### TLB Miss Profiling

```nasm
profile_tlb_behavior:
    ; Configure TLB miss counter (event varies by CPU)
    ; Example: DTLB load misses
    mov ecx, 0x186
    mov eax, 0x00430108         ; DTLB_LOAD_MISSES.WALK_COMPLETED
    xor edx, edx
    wrmsr
    
    mov ecx, 0xC1
    xor eax, eax
    xor edx, edx
    wrmsr
    
    ; Test with different page access patterns
    call target_function
    
    ; Read TLB miss count
    mov ecx, 0xC1
    rdmsr
    mov [tlb_misses], eax
    
    ret

; Test TLB pressure with scattered accesses
test_tlb_pressure:
    mov esi, [memory_region]
    mov ecx, 1000
    
.tlb_test:
    ; Access different pages (4KB apart)
    mov eax, [esi]
    add esi, 4096               ; Next page
    loop .tlb_test
    
    ret
```

### Micro-Benchmark Framework

```nasm
section .data
    bench_iterations: dd 10000
    warmup_iterations: dd 1000

section .bss
    min_cycles: resq 1
    max_cycles: resq 1
    total_cycles: resq 1

section .text
; Generic micro-benchmark harness
microbenchmark:
    ; Input: ESI = pointer to function to benchmark
    push ebp
    mov ebp, esp
    
    ; Initialize statistics
    mov dword [min_cycles], 0xFFFFFFFF
    mov dword [min_cycles + 4], 0xFFFFFFFF
    mov qword [max_cycles], 0
    mov qword [total_cycles], 0
    
    ; Warmup phase
    mov ecx, [warmup_iterations]
.warmup:
    call esi
    loop .warmup
    
    ; Measurement phase
    mov ecx, [bench_iterations]
.measure_loop:
    push ecx
    
    ; Serialize and read start time
    cpuid
    rdtsc
    mov [temp_start], eax
    mov [temp_start + 4], edx
    
    ; Execute benchmark
    call esi
    
    ; Serialize and read end time
    cpuid
    rdtsc
    
    ; Calculate elapsed
    sub eax, [temp_start]
    sbb edx, [temp_start + 4]
    
    ; Update statistics
    call update_stats           ; Updates min/max/total
    
    pop ecx
    loop .measure_loop
    
    ; Calculate average
    mov eax, [total_cycles]
    mov edx, [total_cycles + 4]
    mov ecx, [bench_iterations]
    div ecx
    ; EAX = average cycles
    
    pop ebp
    ret

update_stats:
    ; Input: EDX:EAX = current measurement
    push ebx
    push ecx
    
    ; Update total
    add [total_cycles], eax
    adc [total_cycles + 4], edx
    
    ; Update min
    cmp edx, [min_cycles + 4]
    jb .new_min
    ja .check_max
    cmp eax, [min_cycles]
    jae .check_max
.new_min:
    mov [min_cycles], eax
    mov [min_cycles + 4], edx
    
.check_max:
    ; Update max
    cmp edx, [max_cycles + 4]
    ja .new_max
    jb .done
    cmp eax, [max_cycles]
    jbe .done
.new_max:
    mov [max_cycles], eax
    mov [max_cycles + 4], edx
    
.done:
    pop ecx
    pop ebx
    ret

section .bss
    temp_start: resq 1
```

### Loop Performance Analysis

```nasm
; Analyze loop performance characteristics
analyze_loop_performance:
    ; Measure iterations per second
    rdtsc
    mov [start_time], eax
    mov [start_time + 4], edx
    
    mov ecx, 100000000          ; 100M iterations
    xor eax, eax
.test_loop:
    inc eax
    dec ecx
    jnz .test_loop
    
    rdtsc
    sub eax, [start_time]
    sbb edx, [start_time + 4]
    ; EDX:EAX = cycles for 100M iterations
    
    ; Calculate CPI (cycles per iteration)
    mov ebx, 100000000
    div ebx                     ; EAX = average CPI
    
    ret

; Test loop unrolling benefit
compare_loop_unrolling:
    ; Baseline: No unrolling
    rdtsc
    mov [baseline_start], eax
    
    mov ecx, 1000000
.baseline_loop:
    add eax, ebx
    dec ecx
    jnz .baseline_loop
    
    rdtsc
    sub eax, [baseline_start]
    mov [baseline_cycles], eax
    
    ; Unrolled: 4x
    rdtsc
    mov [unrolled_start], eax
    
    mov ecx, 250000             ; 1M / 4
.unrolled_loop:
    add eax, ebx
    add eax, ebx
    add eax, ebx
    add eax, ebx
    dec ecx
    jnz .unrolled_loop
    
    rdtsc
    sub eax, [unrolled_start]
    mov [unrolled_cycles], eax
    
    ; Calculate speedup
    mov eax, [baseline_cycles]
    mov ebx, [unrolled_cycles]
    ; speedup = baseline / unrolled
    
    ret
```

### SIMD Performance Analysis

```nasm
; Compare scalar vs SIMD performance
compare_scalar_vs_simd:
    ; Setup test data
    mov esi, [input_array]
    mov edi, [output_array]
    
    ; Scalar version
    rdtsc
    mov [scalar_start], eax
    
    mov ecx, 1000
.scalar_loop:
    mov eax, [esi]
    add eax, 10
    mov [edi], eax
    add esi, 4
    add edi, 4
    loop .scalar_loop
    
    rdtsc
    sub eax, [scalar_start]
    mov [scalar_cycles], eax
    
    ; Reset pointers
    mov esi, [input_array]
    mov edi, [output_array]
    
    ; SIMD version (SSE)
    rdtsc
    mov [simd_start], eax
    
    movdqa xmm1, [constant_10]  ; Load constant
    mov ecx, 250                ; 1000 / 4
.simd_loop:
    movdqa xmm0, [esi]          ; Load 4 integers
    paddd xmm0, xmm1            ; Add 4 values at once
    movdqa [edi], xmm0          ; Store 4 integers
    add esi, 16
    add edi, 16
    loop .simd_loop
    
    rdtsc
    sub eax, [simd_start]
    mov [simd_cycles], eax
    
    ; Calculate speedup
    mov eax, [scalar_cycles]
    xor edx, edx
    div dword [simd_cycles]     ; EAX = speedup factor
    
    ret

section .data
align 16
constant_10: dd 10, 10, 10, 10
```

### Port Pressure Analysis

```nasm
; Detect execution port bottlenecks
analyze_port_pressure:
    ; Different instruction mixes stress different ports
    
    ; Test 1: ALU-heavy (multiple ports)
    rdtsc
    mov [test1_start], eax
    
    mov ecx, 100000
.alu_loop:
    add eax, ebx
    add ecx, edx
    add esi, edi
    sub eax, ebx
    dec ecx
    jnz .alu_loop
    
    rdtsc
    sub eax, [test1_start]
    mov [alu_cycles], eax
    
    ; Test 2: Multiply-heavy (ports 0/1)
    rdtsc
    mov [test2_start], eax
    
    mov ecx, 100000
.mul_loop:
    imul eax, ebx
    imul ecx, edx
    imul esi, edi
    dec ecx
    jnz .mul_loop
    
    rdtsc
    sub eax, [test2_start]
    mov [mul_cycles], eax
    
    ; Test 3: Load/Store-heavy (ports 2/3/4/7)
    rdtsc
    mov [test3_start], eax
    
    mov esi, [buffer]
    mov ecx, 100000
.mem_loop:
    mov eax, [esi]
    mov [esi + 4], eax
    mov ebx, [esi + 8]
    mov [esi + 12], ebx
    add esi, 16
    loop .mem_loop
    
    rdtsc
    sub eax, [test3_start]
    mov [mem_cycles], eax
    
    ; Compare results to identify bottleneck
    ; Higher relative cycles indicate port pressure
    
    ret
```

### Code Alignment Analysis

```nasm
; Test impact of code alignment
test_alignment_impact:
    ; Misaligned version
    mov ecx, 10
.repeat_misaligned:
    push ecx
    
    rdtsc
    mov [start], eax
    
    ; Deliberately misaligned hot loop
    nop                         ; Create misalignment
    nop
    nop
    
    mov ecx, 1000000
.misaligned_loop:
    add eax, ebx
    dec ecx
    jnz .misaligned_loop
    
    rdtsc
    sub eax, [start]
    add [misaligned_total], eax
    
    pop ecx
    loop .repeat_misaligned
    
    ; Aligned version
    mov ecx, 10
.repeat_aligned:
    push ecx
    
    rdtsc
    mov [start], eax
    
    ; Force 16-byte alignment
    align 16
    mov ecx, 1000000
.aligned_loop:
    add eax, ebx
    dec ecx
    jnz .aligned_loop
    
    rdtsc
    sub eax, [start]
    add [aligned_total], eax
    
    pop ecx
    loop .repeat_aligned
    
    ; Calculate difference
    mov eax, [misaligned_total]
    sub eax, [aligned_total]
    ; Positive value indicates alignment benefit
    
    ret
```

### Statistical Profiling

```nasm
; Sample-based profiling using timer interrupts
section .data
    SAMPLE_BUFFER_SIZE equ 10000
    
section .bss
    sample_buffer: resd SAMPLE_BUFFER_SIZE  ; Store EIP samples
    sample_count: resd 1
    sample_histogram: resd 256              ; Histogram buckets

section .text
; Setup sampling
setup_statistical_profiling:
    ; Configure timer interrupt for sampling
    ; (typically done via APIC timer or performance counter overflow)
    
    ; Reset sample count
    mov dword [sample_count], 0
    
    ; Clear histogram
    mov edi, sample_histogram
    mov ecx, 256
    xor eax, eax
    rep stosd
    
    ret

; Sample handler (called from interrupt)
sample_handler:
    push eax
    push ebx
    push ecx
    
    ; Get current instruction pointer from stack
    mov eax, [esp + 16]         ; EIP pushed by interrupt
    
    ; Store sample
    mov ecx, [sample_count]
    cmp ecx, SAMPLE_BUFFER_SIZE
    jge .buffer_full
    
    mov [sample_buffer + ecx * 4], eax
    inc dword [sample_count]
    
    ; Update histogram (divide address space into buckets)
    shr eax, 16                 ; Use high 16 bits for bucket
    and eax, 0xFF               ; 256 buckets
    inc dword [sample_histogram + eax * 4]
    
.buffer_full:
    pop ecx
    pop ebx
    pop eax
    iretd

; Analyze samples to find hot spots
analyze_samples:
    ; Sort samples to find most frequent addresses
    mov esi, sample_buffer
    mov ecx, [sample_count]
    
    ; Simple histogram analysis
    xor ebx, ebx                ; Max count
    xor edi, edi                ; Hottest bucket
    
    mov ecx, 256
    mov esi, sample_histogram
.find_max:
    lodsd
    cmp eax, ebx
    jle .next_bucket
    mov ebx, eax
    mov edi, ecx
.next_bucket:
    loop .find_max
    
    ; EDI = hottest bucket index
    ; EBX = sample count in hottest bucket
    
    ret
```

### Memory Latency Testing

```nasm
; Measure memory latency at different levels
measure_memory_latency:
    ; Test different stride patterns to hit different cache levels
    
    ; L1 cache latency (sequential access)
    mov esi, [test_buffer]
    rdtsc
    mov [start], eax
    
    mov ecx, 10000
.l1_test:
    mov eax, [esi]              ; Sequential, stays in L1
    add esi, 64                 ; Next cache line
    loop .l1_test
    
    rdtsc
    sub eax, [start]
    mov [l1_latency], eax
    
    ; L2 cache latency (larger stride)
    mov esi, [test_buffer]
    rdtsc
    mov [start], eax
    
    mov ecx, 10000
.l2_test:
    mov eax, [esi]
    add esi, 4096               ; Skip L1, hit L2
    loop .l2_test
    
    rdtsc
    sub eax, [start]
    mov [l2_latency], eax
    
    ; L3/Memory latency (random access)
    mov esi, [test_buffer]
    rdtsc
    mov [start], eax
    
    mov ecx, 10000
.mem_test:
    ; Use random index to prevent prefetching
    mov eax, [random_indices + ecx * 4]
    mov eax, [esi + eax]
    loop .mem_test
    
    rdtsc
    sub eax, [start]
    mov [mem_latency], eax
    
    ; Calculate average latency per access
    mov eax, [l1_latency]
    mov ebx, 10000
    xor edx, edx
    div ebx
    mov [avg_l1], eax
    
    ; Repeat for L2 and memory
    
    ret
```

### Power and Thermal Profiling

```nasm
; Read CPU power/thermal information
read_cpu_thermal_status:
    ; Read thermal status MSR
    mov ecx, 0x19C              ; IA32_THERM_STATUS
    rdmsr
    ; Bit 0: Thermal status
    ; Bits 22-16: Digital readout
    
    mov [thermal_status], eax
    
    ; Read package temperature
    mov ecx, 0x1B1              ; IA32_PACKAGE_THERM_STATUS
    rdmsr
    mov [package_temp], eax
    
    ret

; Monitor frequency scaling
monitor_frequency_scaling:
    ; Read current frequency
    mov ecx, 0xE8               ; IA32_PERF_STATUS
    rdmsr
    ; Bits 15-8: Current frequency ratio
    shr eax, 8
    and eax, 0xFF
    mov [current_freq_ratio], al
    
    ; Read maximum frequency
    mov ecx, 0xCE               ; IA32_PLATFORM_INFO
    rdmsr
    ; Bits 15-8: Maximum frequency ratio
    shr eax, 8
    and eax, 0xFF
    mov [max_freq_ratio], al
    
    ; Calculate current frequency as percentage
    movzx eax, byte [current_freq_ratio]
    movzx ebx, byte [max_freq_ratio]
    imul eax, 100
    xor edx, edx
    div ebx
    mov [frequency_percent], eax
    
    ret
```

### Advanced Timing Techniques

```nasm
; Compensate for measurement overhead
calibrate_timing_overhead:
    ; Measure back-to-back RDTSC overhead
    mov ecx, 1000
    xor edi, edi                ; Accumulator
    
.calibrate_loop:
    rdtsc
    mov esi, eax
    rdtsc
    sub eax, esi
    add edi, eax                ; Accumulate overhead
    loop .calibrate_loop
    
    ; Calculate average
    mov eax, edi
    mov ebx, 1000
    xor edx, edx
    div ebx
    mov [rdtsc_overhead], eax   ; Store for subtraction
    
    ret

; High-precision measurement with overhead compensation
measure_with_compensation:
    ; Warm up
    call target_function
    call target_function
    
    ; Measure with multiple iterations
    mov ecx, 100
    xor edi, edi
    
.measure_loop:
    push ecx
    
    lfence
    rdtsc
    mov esi, eax
    
    call target_function
    
    lfence
    rdtsc
    sub eax, esi
    sub eax, [rdtsc_overhead]   ; Compensate for measurement overhead
    
    add edi, eax
    pop ecx
    loop .measure_loop
    
    ; Calculate average
    mov eax, edi
    mov ebx, 100
    xor edx, edx
    div ebx
    ; EAX = average cycles (compensated)
    
    ret
```

**Key Points:**

- CPU cycles are measured with RDTSC/RDTSCP; serializing instructions (CPUID, LFENCE) ensure accurate measurements
- Instruction latency is time from operand availability to result production; throughput is sustained issue rate (can differ significantly)
- Modern CPUs have multiple execution ports enabling parallel instruction execution—port pressure occurs when too many instructions target the same port
- Performance counters accessed via MSRs (0x186-0x18D for event select, 0xC1-0xC8 for counters) track hardware events like cache misses, branch mispredictions, and instructions retired
- [Inference] Breaking dependency chains and increasing ILP through multiple accumulators or independent operations improves throughput despite unchanged latency
- Micro-benchmarking requires warmup iterations, multiple measurements, statistical analysis, and overhead compensation for accuracy
- Cache behavior profiling reveals L1/L2/L3 miss rates and helps identify memory access patterns causing performance degradation
- [Inference] Branch misprediction costs 15-20 cycles on modern CPUs; profiling branch prediction helps identify unpredictable branches in hot paths
- Loop unrolling, software pipelining, and SIMD instructions are profiled to quantify optimization benefits
- Memory latency testing with different stride patterns distinguishes L1 (4-5 cycles), L2 (12-14 cycles), L3 (40-50 cycles), and RAM (200+ cycles) access times
- Statistical sampling via performance counter overflow or timer interrupts provides low-overhead profiling for production code

---

