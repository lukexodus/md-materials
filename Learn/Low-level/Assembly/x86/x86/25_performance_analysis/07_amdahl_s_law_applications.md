## Amdahl's Law Applications


Amdahl's Law quantifies the maximum speedup achievable through parallelization or optimization, considering that only a portion of the code can be improved.

### Amdahl's Law Formula

**Mathematical Expression:**

```
Speedup = 1 / ((1 - P) + P/S)

Where:
- P = Proportion of execution time that can be optimized
- S = Speedup of the optimized portion
- (1 - P) = Serial portion that cannot be optimized
```

### Basic Amdahl's Law Calculation

```assembly
; Calculate Amdahl's Law speedup
; Inputs: P (parallel fraction, fixed-point), S (speedup factor)
; Output: Overall speedup

calculate_amdahl:
    push ebp
    mov ebp, esp
    
    ; Parameters
    mov eax, [ebp + 8]      ; P (scaled by 1000, e.g., 800 = 80%)
    mov ebx, [ebp + 12]     ; S (speedup factor)
    
    ; Calculate (1 - P)
    mov ecx, 1000
    sub ecx, eax            ; ECX = (1 - P) * 1000
    
    ; Calculate P/S
    xor edx, edx
    div ebx                 ; EAX = P/S * 1000
    
    ; Add (1 - P) + P/S
    add eax, ecx            ; EAX = denominator * 1000
    
    ; Calculate 1 / denominator
    mov ecx, 1000000        ; Scale for division
    xor edx, edx
    div eax                 ; EAX = 1000 * speedup
    
    pop ebp
    ret

; Example: 80% parallelizable, 4x speedup on parallel part
; P = 800, S = 4
; Speedup = 1 / (0.2 + 0.8/4) = 1 / 0.4 = 2.5x
```

### Practical Application: Identifying Optimization Targets

**Profiling to Find P:**

```assembly
; Profile to determine what percentage can be optimized
profile_for_amdahl:
    ; Measure total execution time
    rdtsc
    mov [start_lo], eax
    mov [start_hi], edx

    call entire_program

    rdtsc
    mov [end_lo], eax
    mov [end_hi], edx

    ; Calculate total time
    mov eax, [end_lo]
    sub eax, [start_lo]
    mov [total_time], eax

    ; Measure time in optimizable section
    rdtsc
    mov [opt_start_lo], eax
    mov [opt_start_hi], edx

    call optimizable_function

    rdtsc
    mov [opt_end_lo], eax
    mov [opt_end_hi], edx

    ; Calculate optimizable time
    mov eax, [opt_end_lo]
    sub eax, [opt_start_lo]
    mov [opt_time], eax

    ; Calculate P = opt_time / total_time
    xor edx, edx
    mov eax, [opt_time]
    imul eax, 1000              ; Scale by 1000
    div dword [total_time]
    mov [fraction_P], eax       ; P as percentage * 10

    ret

; Example results:
; Total time: 10,000,000 cycles
; Optimizable section: 8,000,000 cycles
; P = 80%
````

### Diminishing Returns Analysis

**Calculating Maximum Achievable Speedup:**

```assembly
; Calculate maximum theoretical speedup
; when optimized portion is infinitely fast (S = ∞)
calculate_max_speedup:
    ; Max speedup = 1 / (1 - P)
    
    mov eax, [fraction_P]   ; P * 1000
    mov ecx, 1000
    sub ecx, eax            ; (1 - P) * 1000
    
    ; 1 / (1 - P)
    mov eax, 1000000
    xor edx, edx
    div ecx                 ; EAX = max speedup * 1000
    
    ret

; Example: If P = 90% (900)
; Max speedup = 1 / (1 - 0.9) = 1 / 0.1 = 10x
; No matter how much we optimize that 90%, we can never exceed 10x

; Example: If P = 95% (950)
; Max speedup = 1 / (1 - 0.95) = 1 / 0.05 = 20x

; This shows why the serial portion matters so much
````

### Multi-Level Optimization Planning

**Iterative Optimization Strategy:**

```assembly
; Plan optimization sequence based on Amdahl's Law
optimization_planner:
    ; Initial profile
    call profile_all_functions
    
    ; Results (example):
    ; Function A: 50% of time, can achieve 2x speedup
    ; Function B: 30% of time, can achieve 3x speedup
    ; Function C: 15% of time, can achieve 10x speedup
    ; Function D: 5% of time, can achieve 5x speedup
    
    ; Calculate expected overall speedup for each
    
    ; Function A: P=0.5, S=2
    ; Speedup = 1 / (0.5 + 0.5/2) = 1 / 0.75 = 1.33x
    push 500                ; P = 50%
    push 2                  ; S = 2x
    call calculate_amdahl
    mov [speedup_A], eax
    
    ; Function B: P=0.3, S=3
    ; Speedup = 1 / (0.7 + 0.3/3) = 1 / 0.8 = 1.25x
    push 300
    push 3
    call calculate_amdahl
    mov [speedup_B], eax
    
    ; Function C: P=0.15, S=10
    ; Speedup = 1 / (0.85 + 0.15/10) = 1 / 0.865 = 1.16x
    push 150
    push 10
    call calculate_amdahl
    mov [speedup_C], eax
    
    ; Function D: P=0.05, S=5
    ; Speedup = 1 / (0.95 + 0.05/5) = 1 / 0.96 = 1.04x
    push 50
    push 5
    call calculate_amdahl
    mov [speedup_D], eax
    
    ; Priority: A > B > C > D
    ; Optimize Function A first for maximum impact
    
    ret
```

### Cumulative Optimization Effects

**Multiple Sequential Optimizations:**

```assembly
; Calculate cumulative speedup from multiple optimizations
; Each optimization changes the baseline for the next

calculate_cumulative_speedup:
    push ebp
    mov ebp, esp
    
    ; Stage 1: Optimize Function A (50% of original, 2x speedup)
    ; New time = 0.5 * original + 0.5/2 * original = 0.75 * original
    ; Speedup so far: 1/0.75 = 1.33x
    
    ; Stage 2: Function B now represents what % of new total?
    ; Original B time: 0.3 * original
    ; New total time: 0.75 * original
    ; B's new fraction: 0.3 / 0.75 = 0.4 (40% of new total)
    
    ; Apply Amdahl to stage 2
    ; Speedup = 1 / (0.6 + 0.4/3) = 1 / 0.733 = 1.36x over stage 1
    ; Combined: 1.33 * 1.36 = 1.81x over original
    
    ; Implementation:
    mov eax, 10000          ; Original time (scaled)
    mov [baseline_time], eax
    
    ; Stage 1
    mov ebx, 5000           ; 50% of time
    mov ecx, 2              ; 2x speedup
    xor edx, edx
    mov eax, ebx
    div ecx                 ; Optimized portion time
    mov esi, 5000           ; Unoptimized portion
    add eax, esi            ; New total
    mov [stage1_time], eax
    
    ; Calculate stage 1 speedup
    mov eax, [baseline_time]
    imul eax, 1000
    xor edx, edx
    div dword [stage1_time]
    mov [stage1_speedup], eax   ; 1.33x * 1000
    
    ; Stage 2 (Function B in context of stage 1)
    mov eax, 3000           ; Original B time
    imul eax, 1000
    xor edx, edx
    div dword [stage1_time] ; B's fraction of stage 1
    mov ebx, eax            ; New P for B
    
    ; Apply optimization
    mov ecx, 3              ; 3x speedup on B
    ; ... calculate new time ...
    
    ; Continue for all optimizations
    
    pop ebp
    ret
```

### Amdahl's Law for Parallel Processing

**Multi-Core Scaling Analysis:**

```assembly
; Calculate speedup with N cores
; Assuming perfect parallelization of parallel portion

calculate_parallel_speedup:
    ; Speedup = 1 / ((1 - P) + P/N)
    ; Where N = number of cores
    
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 8]      ; P (parallel fraction * 1000)
    mov ebx, [ebp + 12]     ; N (number of cores)
    
    ; Calculate (1 - P)
    mov ecx, 1000
    sub ecx, eax            ; Serial portion * 1000
    
    ; Calculate P/N
    xor edx, edx
    div ebx                 ; P/N * 1000
    
    ; Sum: (1-P) + P/N
    add eax, ecx
    
    ; Calculate 1 / sum
    mov ecx, 1000000
    xor edx, edx
    mov ebx, eax
    mov eax, ecx
    div ebx                 ; Speedup * 1000
    
    pop ebp
    ret

; Example: 95% parallelizable code
; 1 core: 1.0x (baseline)
; 2 cores: 1 / (0.05 + 0.95/2) = 1 / 0.525 = 1.90x
; 4 cores: 1 / (0.05 + 0.95/4) = 1 / 0.2875 = 3.48x
; 8 cores: 1 / (0.05 + 0.95/8) = 1 / 0.16875 = 5.93x
; 16 cores: 1 / (0.05 + 0.95/16) = 1 / 0.109375 = 9.14x
; ∞ cores: 1 / 0.05 = 20x (maximum possible)

; Note: With only 95% parallel, 16 cores gives < 10x speedup
; The 5% serial portion dominates at high core counts
```

### Visualizing Scalability Limits

```assembly
; Generate Amdahl's Law curve for different P values
generate_scalability_data:
    push ebp
    mov ebp, esp
    push esi
    push edi
    
    mov esi, scalability_data
    mov edi, 1              ; Start with 1 core
    
.core_loop:
    ; For P = 50%
    push edi                ; N cores
    push 500                ; P = 50%
    call calculate_parallel_speedup
    mov [esi], eax          ; Store speedup for 50%
    add esi, 4
    
    ; For P = 75%
    push edi
    push 750
    call calculate_parallel_speedup
    mov [esi], eax
    add esi, 4
    
    ; For P = 90%
    push edi
    push 900
    call calculate_parallel_speedup
    mov [esi], eax
    add esi, 4
    
    ; For P = 95%
    push edi
    push 950
    call calculate_parallel_speedup
    mov [esi], eax
    add esi, 4
    
    ; For P = 99%
    push edi
    push 990
    call calculate_parallel_speedup
    mov [esi], eax
    add esi, 4
    
    inc edi
    cmp edi, 64             ; Up to 64 cores
    jle .core_loop
    
    pop edi
    pop esi
    pop ebp
    ret

; Results show:
; P=50%: Max 2x speedup (hits wall quickly)
; P=90%: Max 10x speedup (good up to ~8 cores)
; P=99%: Max 100x speedup (scales to many cores)
```

### Practical Optimization Decision Making

**Cost-Benefit Analysis:**

```assembly
; Calculate optimization priority score
; Priority = (Speedup - 1) * Time_Percentage / Development_Effort

calculate_optimization_priority:
    push ebp
    mov ebp, esp
    
    ; Inputs:
    ; [ebp+8]: Time percentage (0-1000)
    ; [ebp+12]: Potential speedup (scaled by 1000)
    ; [ebp+16]: Development effort (hours)
    
    ; Calculate Amdahl's Law speedup
    mov eax, [ebp + 8]      ; P
    mov ebx, [ebp + 12]     ; S
    push ebx
    push eax
    call calculate_amdahl
    add esp, 8
    
    ; EAX = overall speedup * 1000
    ; Calculate benefit: (speedup - 1) * 1000
    sub eax, 1000           ; Benefit
    
    ; Multiply by time percentage
    imul eax, [ebp + 8]
    mov ecx, 1000
    xor edx, edx
    div ecx                 ; Benefit score
    
    ; Divide by effort
    xor edx, edx
    div dword [ebp + 16]    ; Priority score
    
    pop ebp
    ret

; Example comparison:
; Option A: 40% of time, 2x speedup, 10 hours effort
;   Amdahl speedup: 1.25x
;   Benefit: (1.25 - 1) * 40 = 10
;   Priority: 10 / 10 = 1.0
;
; Option B: 10% of time, 10x speedup, 5 hours effort
;   Amdahl speedup: 1.09x
;   Benefit: (1.09 - 1) * 10 = 0.9
;   Priority: 0.9 / 5 = 0.18
;
; Choose Option A: Better overall impact
```

### Measuring Real vs Theoretical Speedup

**Validation Framework:**

```assembly
; Compare actual speedup to Amdahl's Law prediction
validate_optimization:
    push ebp
    mov ebp, esp
    
    ; Measure baseline performance
    call benchmark_baseline
    mov [baseline_time], eax
    
    ; Apply optimization
    call apply_optimization
    
    ; Measure optimized performance
    call benchmark_optimized
    mov [optimized_time], eax
    
    ; Calculate actual speedup
    mov eax, [baseline_time]
    imul eax, 1000
    xor edx, edx
    div dword [optimized_time]
    mov [actual_speedup], eax
    
    ; Calculate predicted speedup using Amdahl
    push dword [local_speedup]      ; S
    push dword [fraction_optimized] ; P
    call calculate_amdahl
    mov [predicted_speedup], eax
    
    ; Compare
    mov eax, [actual_speedup]
    mov ebx, [predicted_speedup]
    sub eax, ebx
    mov [speedup_delta], eax
    
    ; If actual < predicted: overhead not accounted for
    ; If actual > predicted: secondary benefits (cache, etc.)
    
    pop ebp
    ret
```

### Overhead Considerations in Amdahl's Law

**Extended Amdahl's Law with Overhead:**

```assembly
; Speedup = 1 / ((1-P) + P/S + O)
; Where O = overhead introduced by optimization

calculate_amdahl_with_overhead:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 8]      ; P (parallel fraction * 1000)
    mov ebx, [ebp + 12]     ; S (speedup factor)
    mov ecx, [ebp + 16]     ; O (overhead * 1000)
    
    ; Calculate (1 - P)
    mov edx, 1000
    sub edx, eax
    push edx                ; Save (1-P)
    
    ; Calculate P/S
    xor edx, edx
    div ebx
    push eax                ; Save P/S
    
    ; Sum: (1-P) + P/S + O
    pop eax
    pop ebx
    add eax, ebx
    add eax, ecx
    
    ; Calculate 1 / sum
    mov ecx, 1000000
    xor edx, edx
    mov ebx, eax
    mov eax, ecx
    div ebx
    
    pop ebp
    ret

; Example: Parallelization overhead
; P = 90%, S = 4 (4 cores), O = 5% overhead
; Speedup = 1 / (0.1 + 0.9/4 + 0.05)
;         = 1 / (0.1 + 0.225 + 0.05)
;         = 1 / 0.375
;         = 2.67x
;
; Without overhead: 1 / (0.1 + 0.225) = 3.08x
; Overhead reduces speedup by 13%
```

### Load Balancing and Amdahl's Law

**Unbalanced Parallel Work:**

```assembly
; When parallel work is unbalanced, effective speedup reduces
; Speedup limited by longest-running thread

calculate_unbalanced_speedup:
    push ebp
    mov ebp, esp
    
    ; Assume 4 cores with different workloads:
    ; Core 0: 25% of parallel work
    ; Core 1: 25% of parallel work
    ; Core 2: 25% of parallel work
    ; Core 3: 25% of parallel work (balanced)
    ;
    ; But if unbalanced:
    ; Core 0: 40% of parallel work (bottleneck)
    ; Core 1: 20%
    ; Core 2: 20%
    ; Core 3: 20%
    
    ; Serial portion: 10% of original time
    ; Parallel portion: 90% of original time
    
    ; Balanced execution time:
    ; T_parallel = 0.9 / 4 = 0.225
    ; Total = 0.1 + 0.225 = 0.325
    ; Speedup = 1 / 0.325 = 3.08x
    
    ; Unbalanced execution time (40% on one core):
    ; T_parallel = 0.9 * 0.4 = 0.36 (longest core)
    ; Total = 0.1 + 0.36 = 0.46
    ; Speedup = 1 / 0.46 = 2.17x
    
    ; 30% performance loss due to load imbalance!
    
    pop ebp
    ret
```

### Strong vs Weak Scaling

**Strong Scaling (Fixed Problem Size):**

```assembly
; Strong scaling: Same total work, more processors
; Follows Amdahl's Law directly

measure_strong_scaling:
    ; Fixed problem: process 1,000,000 elements
    
    ; 1 core: 1000ms
    ; 2 cores: 550ms (1.82x speedup)
    ; 4 cores: 320ms (3.13x speedup)
    ; 8 cores: 200ms (5.00x speedup)
    ; 16 cores: 150ms (6.67x speedup)
    
    ; Speedup plateaus due to serial portion
    ret

; Weak scaling: Work per processor stays constant
measure_weak_scaling:
    ; Each core processes 100,000 elements
    
    ; 1 core: 100,000 elements in 100ms
    ; 2 cores: 200,000 elements in ~105ms
    ; 4 cores: 400,000 elements in ~112ms
    ; 8 cores: 800,000 elements in ~125ms
    
    ; Time increases slowly due to communication overhead
    ; But work scales linearly with cores
    ret
```

### Optimization ROI Calculator

**Return on Investment for Optimization:**

```assembly
; Calculate whether optimization is worthwhile
calculate_optimization_roi:
    push ebp
    mov ebp, esp
    
    ; Inputs:
    ; Current execution time per run
    ; Number of runs per day
    ; Cost of developer time per hour
    ; Expected speedup
    ; Development time required
    
    mov eax, [ebp + 8]      ; Current time (ms per run)
    mov ebx, [ebp + 12]     ; Runs per day
    imul eax, ebx           ; Total ms per day
    mov [current_daily_ms], eax
    
    ; Calculate time after optimization
    mov eax, [ebp + 8]
    mov ecx, [ebp + 16]     ; Speedup factor (scaled)
    xor edx, edx
    imul eax, 1000
    div ecx                 ; New time per run
    imul eax, ebx           ; New total ms per day
    mov [optimized_daily_ms], eax
    
    ; Time saved per day
    mov eax, [current_daily_ms]
    sub eax, [optimized_daily_ms]
    mov [time_saved_ms], eax
    
    ; Convert to hours saved per year
    mov ecx, 365            ; Days per year
    imul eax, ecx
    mov ecx, 3600000        ; ms per hour
    xor edx, edx
    div ecx
    mov [hours_saved_yearly], eax
    
    ; Value of time saved
    imul eax, [ebp + 20]    ; Cost per hour
    mov [value_saved], eax
    
    ; Cost of optimization
    mov ebx, [ebp + 24]     ; Dev hours
    imul ebx, [ebp + 20]    ; Dev cost per hour
    mov [optimization_cost], ebx
    
    ; ROI = (value_saved - cost) / cost * 100
    sub eax, ebx
    imul eax, 100
    xor edx, edx
    div ebx
    ; EAX = ROI percentage
    
    pop ebp
    ret

; Example:
; Current: 1000ms per run, 1000 runs/day
; Speedup: 2x
; Dev time: 40 hours at $100/hour
;
; Time saved: 500ms * 1000 * 365 = 182,500,000ms/year
;           = 50.7 hours/year
; Value: 50.7 * $100 = $5,070/year
; Cost: 40 * $100 = $4,000
; ROI: ($5,070 - $4,000) / $4,000 * 100 = 26.75%
; Payback period: ~9.5 months
```

### Bottleneck Migration Analysis

**How Bottlenecks Shift After Optimization:**

```assembly
; Track how bottleneck changes with each optimization
analyze_bottleneck_migration:
    push ebp
    mov ebp, esp
    
    ; Initial profile:
    ; Function A: 50% time - CPU bound
    ; Function B: 30% time - memory bound
    ; Function C: 20% time - branch misprediction
    
    ; After optimizing A (2x speedup):
    ; New time distribution:
    ; A: 25% (was 50%, now 2x faster)
    ; B: 40% (unchanged time, but larger % of new total)
    ; C: 26.7% (unchanged time, but larger % of new total)
    ; Other: 8.3%
    
    ; B is now the bottleneck! Must optimize next.
    
    ; This is key insight from Amdahl's Law:
    ; Bottleneck shifts to next-largest time consumer
    
    ; After optimizing B (3x speedup):
    ; A: 30% of time
    ; B: 16% of time
    ; C: 32% of time - NOW THE BOTTLENECK
    ; Other: 10%
    
    ; Must continue profiling and optimizing iteratively
    
    pop ebp
    ret
```

### Practical Limits Beyond Amdahl

**Factors Not in Basic Amdahl's Law:**

```assembly
; Real-world complications:

; 1. Superlinear speedup (rare, but possible)
;    - Better cache utilization with smaller per-core datasets
;    - Example: Dataset fits in L2 when split across cores

; 2. Sublinear speedup (common)
;    - Synchronization overhead
;    - False sharing
;    - Load imbalance
;    - Communication costs

; 3. Memory bandwidth saturation
;    - Adding cores doesn't help if memory-bound
;    - All cores share same memory bus

; 4. I/O limitations
;    - Disk/network bandwidth limits parallelism

; 5. Resource contention
;    - Shared execution units
;    - Shared cache causing evictions
```

**Key Points:**

- Bottleneck identification requires profiling compute resources, memory hierarchy, branches, and instruction dependencies to determine which constraint limits performance
- Micro-benchmarking provides isolated performance measurements of specific code sequences but requires careful methodology to avoid artifacts from optimization, caching, and timing overhead
- Statistical analysis of benchmark results including mean, median, minimum, and outlier removal produces more reliable performance characterizations than single measurements
- Amdahl's Law quantifies maximum speedup as 1/((1-P) + P/S) where P is the optimizable fraction and S is that portion's speedup, revealing diminishing returns
- The serial portion (1-P) sets an absolute performance ceiling regardless of how much the parallel portion is accelerated, making it critical to minimize
- Optimization priority should consider both Amdahl's Law predicted speedup and development effort to maximize return on investment
- Bottleneck migration occurs after each optimization as the next-slowest component becomes the new performance limiter, requiring iterative profiling
- Real-world parallel scaling deviates from theoretical predictions due to overhead, load imbalance, synchronization costs, and shared resource contention
- Hardware performance counters measuring cache misses, branch mispredictions, and instruction throughput provide microarchitectural insights beyond simple timing
- [Inference] Cost-benefit analysis incorporating execution frequency, development time, and maintenance costs determines whether optimizations are economically justified

---

