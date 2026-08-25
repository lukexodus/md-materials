## Bottleneck Identification


A bottleneck is any component or resource that limits overall system performance. Identifying bottlenecks is crucial because optimizing non-bottleneck code provides minimal benefit while consuming development resources.

### Types of Bottlenecks

**Compute-Bound Bottlenecks:**

Code limited by computational throughput rather than memory or I/O. The processor's execution units are fully utilized.

```assembly
; Compute-bound example - intensive calculations
compute_intensive:
    push ebp
    mov ebp, esp
    
    mov ecx, 1000000        ; Large iteration count
    xor eax, eax            ; Result accumulator
    
.loop:
    ; Many arithmetic operations per iteration
    mov ebx, ecx
    imul ebx, ebx           ; Square
    imul ebx, ecx           ; Cube
    add eax, ebx            ; Accumulate
    
    ; More calculations
    mov edx, eax
    xor edx, ecx
    add eax, edx
    
    dec ecx
    jnz .loop
    
    pop ebp
    ret
    
; Characteristics of compute-bound code:
; - High CPU utilization (near 100%)
; - Low cache miss rate
; - Few memory stalls
; - Execution units saturated
```

**Memory-Bound Bottlenecks:**

Code limited by memory bandwidth or latency. The processor stalls waiting for data.

```assembly
; Memory-bound example - poor cache behavior
memory_intensive:
    push ebp
    mov ebp, esp
    push esi
    push edi
    
    mov esi, [ebp + 8]      ; Source array
    mov edi, [ebp + 12]     ; Destination array
    mov ecx, [ebp + 16]     ; Count
    
.loop:
    ; Random access pattern - cache misses
    mov eax, [random_indices + ecx*4]
    mov ebx, [esi + eax*4]  ; Cache miss likely
    mov [edi + eax*4], ebx  ; Another potential miss
    
    dec ecx
    jnz .loop
    
    pop edi
    pop esi
    pop ebp
    ret
    
; Characteristics of memory-bound code:
; - Low CPU utilization (lots of stalls)
; - High cache miss rate
; - Memory bandwidth saturated
; - Long average instruction latency
```

**Bandwidth vs Latency Bound:**

```assembly
; Latency-bound - pointer chasing
traverse_linked_list:
    mov esi, [list_head]
    xor eax, eax            ; Sum
    
.loop:
    add eax, [esi + Node.data]      ; Quick computation
    mov esi, [esi + Node.next]      ; Must wait for load
    test esi, esi
    jnz .loop
    ; Each iteration depends on previous - latency bound
    ret

; Bandwidth-bound - streaming access
stream_array:
    mov esi, array
    mov ecx, count
    xor eax, eax
    
.loop:
    add eax, [esi]          ; Sequential access
    add eax, [esi + 4]      ; Multiple loads per cycle
    add eax, [esi + 8]      ; Limited by memory bandwidth
    add eax, [esi + 12]
    add esi, 16
    sub ecx, 4
    ja .loop
    ; Can issue loads faster than memory can supply - bandwidth bound
    ret
```

**Branch Misprediction Bottlenecks:**

Code with unpredictable branches causing frequent pipeline flushes.

```assembly
; Branch-heavy code with unpredictable patterns
process_conditionally:
    mov ecx, count
    xor esi, esi
    xor eax, eax            ; Result
    
.loop:
    mov ebx, [data + esi]
    
    ; Unpredictable branch based on data
    test ebx, 1
    jz .even
    
.odd:
    imul ebx, 3
    add ebx, 1
    jmp .continue
    
.even:
    shr ebx, 1
    
.continue:
    add eax, ebx
    add esi, 4
    dec ecx
    jnz .loop
    
    ret
    
; If data is random, ~50% misprediction rate
; 15-20 cycle penalty per misprediction
; Can dominate execution time
```

**Instruction Dependency Bottlenecks:**

Long dependency chains preventing parallel execution.

```assembly
; Long dependency chain - poor ILP
dependency_chain:
    mov eax, [data]
    add eax, 5              ; Depends on load
    imul eax, 3             ; Depends on add
    add eax, 100            ; Depends on imul
    shr eax, 2              ; Depends on add
    xor eax, 0xFF           ; Depends on shr
    mov [result], eax       ; Depends on xor
    ; All instructions serialized
    ret

; Broken dependencies - better ILP
independent_operations:
    mov eax, [data1]
    mov ebx, [data2]        ; Independent
    mov ecx, [data3]        ; Independent
    mov edx, [data4]        ; Independent
    
    add eax, 5              ; Can execute in parallel
    add ebx, 10             ; with these operations
    add ecx, 15
    add edx, 20
    
    ; Combine results
    add eax, ebx
    add ecx, edx
    add eax, ecx
    mov [result], eax
    ret
```

### Profiling Methods

**Time-Based Profiling:**

Measuring execution time to identify hot spots.

```assembly
; Using RDTSC (Read Time-Stamp Counter) for timing
; Returns 64-bit cycle count in EDX:EAX

profile_function:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push esi
    push edi
    
    ; Read start time
    rdtsc
    mov [start_time_lo], eax
    mov [start_time_hi], edx
    
    ; Code to profile
    call target_function
    
    ; Read end time
    rdtsc
    mov [end_time_lo], eax
    mov [end_time_hi], edx
    
    ; Calculate elapsed cycles
    mov eax, [end_time_lo]
    sub eax, [start_time_lo]
    mov ebx, [end_time_hi]
    sbb ebx, [start_time_hi]
    
    ; EBX:EAX = cycle count
    mov [cycle_count_lo], eax
    mov [cycle_count_hi], ebx
    
    pop edi
    pop esi
    pop ecx
    pop ebx
    pop ebp
    ret

; Note: RDTSC has some overhead and may be affected by:
; - Out-of-order execution
; - Frequency scaling
; - Context switches
```

**More Accurate Timing with Serialization:**

```assembly
; Serialize execution before timing
profile_accurate:
    push ebp
    mov ebp, esp
    
    ; Serialize to ensure previous instructions complete
    cpuid                   ; Serializing instruction
    
    rdtsc                   ; Read start time
    mov esi, eax
    mov edi, edx
    
    ; Function to measure
    call target_function
    
    ; Serialize again
    cpuid
    
    rdtsc                   ; Read end time
    sub eax, esi            ; Calculate difference
    sbb edx, edi
    
    pop ebp
    ret
```

**Statistical Profiling:**

Sampling program state at intervals to identify hotspots.

```assembly
; Sampling-based profiling (conceptual)
; Timer interrupt handler increments counter for current EIP

profiling_interrupt_handler:
    push eax
    push ebx
    
    ; Get interrupted instruction address
    mov eax, [esp + 12]     ; Saved EIP on stack
    
    ; Hash EIP to bucket
    mov ebx, eax
    shr ebx, 4              ; Align to 16-byte boundary
    and ebx, 0xFFF          ; 4096 buckets
    
    ; Increment sample count
    inc dword [sample_buckets + ebx*4]
    
    pop ebx
    pop eax
    iret

; After collection, buckets with high counts indicate hotspots
```

**Hardware Performance Counters:**

Using CPU performance monitoring units for detailed analysis.

```assembly
; Configure and read performance counters
; Intel: Use Model-Specific Registers (MSRs)

setup_perf_counter:
    ; Configure counter 0 to count L1 cache misses
    mov ecx, 0x186          ; IA32_PERFEVTSEL0
    mov eax, 0x00410151     ; Event select: L1 misses
    xor edx, edx
    wrmsr                   ; Write MSR (requires ring 0)
    
    ; Enable counter
    mov ecx, 0x38F          ; IA32_PERF_GLOBAL_CTRL
    mov eax, 0x01           ; Enable counter 0
    xor edx, edx
    wrmsr
    ret

read_perf_counter:
    ; Read counter 0
    mov ecx, 0              ; Counter index
    rdpmc                   ; Read performance counter
    ; EDX:EAX = counter value
    ret

; Common events to monitor:
; - Instructions retired
; - Cycles elapsed
; - Branch mispredictions
; - L1/L2/L3 cache misses
; - TLB misses
; - Stall cycles
```

### Bottleneck Analysis Process

**Step 1: High-Level Profiling**

Identify which functions/routines consume the most time.

```assembly
; Example: Profile multiple functions
benchmark_suite:
    ; Profile function 1
    call profile_start
    call function1
    call profile_end
    mov [time_function1], eax
    
    ; Profile function 2
    call profile_start
    call function2
    call profile_end
    mov [time_function2], eax
    
    ; Profile function 3
    call profile_start
    call function3
    call profile_end
    mov [time_function3], eax
    
    ; Identify slowest function
    ; Focus optimization there
    ret
```

**Step 2: Microarchitectural Analysis**

Determine what limits performance in the hotspot.

```assembly
; Analyze with performance counters
analyze_hotspot:
    ; Setup counters
    call setup_counter_instructions_retired
    call setup_counter_cycles
    call setup_counter_cache_misses
    call setup_counter_branch_misses
    
    ; Read baseline
    call read_all_counters
    mov [baseline_instrs], eax
    mov [baseline_cycles], ebx
    mov [baseline_cache], ecx
    mov [baseline_branch], edx
    
    ; Run hotspot code
    call hotspot_function
    
    ; Read final counts
    call read_all_counters
    
    ; Calculate metrics
    sub eax, [baseline_instrs]  ; Instructions
    sub ebx, [baseline_cycles]  ; Cycles
    sub ecx, [baseline_cache]   ; Cache misses
    sub edx, [baseline_branch]  ; Branch misses
    
    ; Analyze:
    ; - IPC = instructions / cycles (ideally 2-4)
    ; - Cache miss rate = misses / instructions
    ; - Branch miss rate = misses / branches
    ; - Cycles per instruction (CPI)
    
    ret
```

**Step 3: Interpretation**

```assembly
; Interpretation guidelines:
;
; Low IPC (< 0.5):
;   - Check for long dependency chains
;   - Check for memory stalls
;   - Check for branch mispredictions
;
; High cache miss rate (> 5%):
;   - Improve spatial locality
;   - Improve temporal locality
;   - Use cache blocking
;   - Add prefetching
;
; High branch miss rate (> 5%):
;   - Make branches more predictable
;   - Use branchless code (CMOV)
;   - Reorganize code layout
;
; Memory bandwidth saturated:
;   - Reduce data movement
;   - Use SIMD for parallelism
;   - Compress data
;
; High CPI (> 2):
;   - Break dependency chains
;   - Improve instruction mix
;   - Reduce instruction count
```

### Roofline Model

The roofline model visualizes performance limits based on computational intensity.

```assembly
; Computational intensity = FLOPs / Bytes transferred
; Performance limited by either:
; 1. Peak FLOP rate (compute-bound)
; 2. Memory bandwidth (memory-bound)

; Example: Memory-bound code (low intensity)
memory_bound_kernel:
    mov ecx, count
    xor esi, esi
    pxor xmm0, xmm0         ; Accumulator
    
.loop:
    movss xmm1, [array + esi]   ; 4 bytes loaded
    addss xmm0, xmm1            ; 1 FLOP
    add esi, 4
    loop .loop
    ; Intensity = 1 FLOP / 4 bytes = 0.25 FLOP/byte
    ; Memory-bound: limited by bandwidth
    ret

; Example: Compute-bound code (high intensity)
compute_bound_kernel:
    mov ecx, count
    movss xmm0, [initial_value] ; 4 bytes loaded once
    
.loop:
    mulss xmm0, xmm0            ; Square
    mulss xmm0, [constant]      ; Multiply
    addss xmm0, [constant2]     ; Add
    ; Multiple FLOPs per loaded value
    dec ecx
    jnz .loop
    ; High intensity: compute-bound
    ret

; Optimization strategy depends on which limit is hit:
; - Memory-bound: Improve cache usage, reduce transfers
; - Compute-bound: Reduce operation count, use SIMD
```

### Identifying Cache Bottlenecks

**Cache Miss Patterns:**

```assembly
; Compulsory misses - first access to data
; Cannot be avoided, but can be hidden with prefetching
first_access:
    mov eax, [never_accessed_before]
    ; Always misses on first access
    
; Capacity misses - working set exceeds cache size
large_working_set:
    ; Processing 10 MB array with 256 KB L2 cache
    mov ecx, 2500000        ; 10 MB / 4 bytes
.loop:
    mov eax, [huge_array + esi]
    ; Data evicted before reuse - capacity miss
    add esi, 4
    loop .loop
    
; Conflict misses - multiple addresses map to same set
conflict_pattern:
    ; Accessing addresses that hash to same cache set
    mov eax, [array + 0]
    mov ebx, [array + 0x10000]  ; May conflict
    mov ecx, [array + 0x20000]  ; May conflict
    ; All might map to same cache sets
```

**Measuring Cache Performance:**

```assembly
; Test different access patterns
test_cache_behavior:
    ; Sequential access
    call profile_start
    mov ecx, count
    xor esi, esi
.seq:
    mov eax, [array + esi]
    add esi, 4
    loop .seq
    call profile_end
    mov [time_sequential], eax
    
    ; Strided access
    call profile_start
    mov ecx, count
    xor esi, esi
.strided:
    mov eax, [array + esi]
    add esi, 64             ; One cache line stride
    loop .strided
    call profile_end
    mov [time_strided], eax
    
    ; Random access
    call profile_start
    mov ecx, count
.random:
    mov esi, [random_indices + ecx*4]
    mov eax, [array + esi]
    loop .random
    call profile_end
    mov [time_random], eax
    
    ; Compare times to identify cache sensitivity
    ; Sequential << Strided << Random indicates cache-sensitive code
    ret
```

### Bandwidth Utilization Analysis

**Measuring Effective Bandwidth:**

```assembly
; Measure achieved memory bandwidth
measure_bandwidth:
    ; Allocate large buffer (> cache size)
    mov esi, large_buffer   ; 64 MB
    mov ecx, 16777216       ; 64 MB / 4 bytes
    
    ; Start timing
    rdtsc
    mov edi, eax
    mov ebp, edx
    
    ; Stream data
.loop:
    mov eax, [esi]
    mov ebx, [esi + 4]
    mov eax, [esi + 8]
    mov ebx, [esi + 12]
    add esi, 16
    sub ecx, 4
    ja .loop
    
    ; End timing
    rdtsc
    sub eax, edi
    sbb edx, ebp
    
    ; Calculate bandwidth:
    ; Bandwidth = Bytes transferred / Time
    ; Bytes = 64 MB
    ; Time = EDX:EAX cycles / CPU frequency
    ; Compare to theoretical peak bandwidth
    
    ret

; Typical results:
; - Theoretical peak: 25-50 GB/s (DDR4)
; - Achieved sequential: 15-30 GB/s (60-80% efficiency)
; - Achieved random: 1-5 GB/s (poor efficiency)
```

### Instruction-Level Bottlenecks

**Port Pressure Analysis:**

Modern CPUs have execution ports with different capabilities. Understanding port utilization reveals bottlenecks.

```assembly
; Example: Intel Skylake has 8 ports (0-7)
; Port 0: ALU, mul, div, branches
; Port 1: ALU, mul
; Port 2, 3: Load (AGU)
; Port 4: Store data
; Port 5: ALU, vector
; Port 6: ALU, branches
; Port 7: Store address (AGU)

; Bottleneck: Too many operations on one port
port_bottleneck:
    ; All multiply instructions use ports 0 and 1
    mov eax, [data1]
    imul eax, 3             ; Port 0 or 1
    mov ebx, [data2]
    imul ebx, 5             ; Port 0 or 1
    mov ecx, [data3]
    imul ecx, 7             ; Port 0 or 1
    ; Serialized through multiply ports
    ret

; Better: Mix operations across ports
port_balanced:
    mov eax, [data1]
    lea ebx, [eax + eax*2]  ; EAX * 3, uses different port
    mov ecx, [data2]
    lea edx, [ecx + ecx*4]  ; ECX * 5, uses different port
    ; More parallel execution
    ret
```

