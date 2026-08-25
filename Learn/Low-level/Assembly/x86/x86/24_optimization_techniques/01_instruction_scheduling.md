## Instruction Scheduling


Instruction scheduling is the process of ordering instructions to maximize throughput by exploiting instruction-level parallelism (ILP) and minimizing pipeline stalls. Modern x86 processors can execute multiple instructions simultaneously if they don't have dependencies and target different execution units.

### Understanding Execution Units

Modern x86 processors contain multiple specialized execution units that can operate in parallel:

**Intel Microarchitectures (typical configuration):**

- **Arithmetic Logic Units (ALU)**: 3-4 units for integer operations
- **Address Generation Units (AGU)**: 2-3 units for memory address calculations
- **Floating-Point Units (FPU)**: 2 units for floating-point operations
- **Vector Units**: 1-2 units for SIMD operations (SSE, AVX)
- **Load/Store Units**: 2 load units, 1 store unit
- **Branch Unit**: 1 unit for branch processing
- **Multiply/Divide Unit**: Shared or dedicated units

**AMD Zen Microarchitectures:**

- Similar structure with variations in unit count and capabilities
- 4 integer ALUs, 2 AGUs
- Multiple FPUs and vector units
- Enhanced branch prediction

```assembly
; Poor scheduling - sequential dependencies
mov eax, [array + 0]
add eax, 10             ; Depends on previous instruction
mov [result], eax       ; Depends on previous instruction
mov ebx, [array + 4]    ; Cannot execute in parallel
add ebx, 20
mov [result + 4], ebx

; Better scheduling - reduced dependencies
mov eax, [array + 0]
mov ebx, [array + 4]    ; Independent load, can execute in parallel
add eax, 10             ; Can execute while EBX loads
add ebx, 20             ; Can execute in parallel with EAX add
mov [result], eax       ; Store operations
mov [result + 4], ebx
```

### Dependency Analysis

Instructions with data dependencies must execute in order, creating dependency chains that limit parallelism.

**Types of Dependencies:**

**True Dependency (Read After Write - RAW):**

```assembly
; True dependency - second instruction needs result from first
add eax, ebx            ; Writes EAX
imul ecx, eax           ; Reads EAX - must wait for ADD to complete
```

**Anti-Dependency (Write After Read - WAR):**

```assembly
; Anti-dependency - mitigated by register renaming in modern CPUs
imul ecx, eax           ; Reads EAX
mov eax, edx            ; Writes EAX - could theoretically interfere
; Modern CPUs rename registers internally, eliminating this issue
```

**Output Dependency (Write After Write - WAW):**

```assembly
; Output dependency - also handled by register renaming
mov eax, 10
mov eax, 20             ; Both write to EAX
```

### Breaking Dependency Chains

Long dependency chains reduce parallelism. Breaking them allows more instructions to execute concurrently.

```assembly
; Long dependency chain - poor parallelism
mov eax, [data]
add eax, 5              ; Latency: ~1 cycle
imul eax, 3             ; Latency: ~3 cycles, depends on ADD
add eax, 100            ; Latency: ~1 cycle, depends on IMUL
shr eax, 2              ; Latency: ~1 cycle, depends on ADD
; Total latency: ~6 cycles (sequential)

; Broken dependency chain - better parallelism
mov eax, [data1]
mov ebx, [data2]        ; Independent, executes in parallel
mov ecx, [data3]        ; Independent, executes in parallel
add eax, 5              ; Can start immediately
add ebx, 10             ; Can execute in parallel with EAX
add ecx, 15             ; Can execute in parallel
imul eax, 3             ; Depends on EAX ADD
imul ebx, 2             ; Can execute in parallel with EAX IMUL
; Multiple operations execute simultaneously
```

### Loop Unrolling for Better Scheduling

Unrolling loops exposes more instructions for scheduling and reduces loop overhead.

```assembly
; Original loop - limited scheduling opportunities
mov ecx, 1000
mov esi, source
mov edi, dest
.loop:
    mov eax, [esi]
    add eax, 10
    mov [edi], eax
    add esi, 4
    add edi, 4
    dec ecx
    jnz .loop

; Unrolled loop - better instruction-level parallelism
mov ecx, 250            ; 1000 / 4 iterations
mov esi, source
mov edi, dest
.loop:
    mov eax, [esi]
    mov ebx, [esi + 4]
    mov edx, [esi + 8]
    mov ebp, [esi + 12]
    
    add eax, 10         ; These can execute in parallel
    add ebx, 10
    add edx, 10
    add ebp, 10
    
    mov [edi], eax
    mov [edi + 4], ebx
    mov [edi + 8], edx
    mov [edi + 12], ebp
    
    add esi, 16
    add edi, 16
    dec ecx
    jnz .loop
```

### Instruction Selection for Scheduling

Different instructions have different latencies and throughput characteristics.

**Latency vs Throughput:**

- **Latency**: Cycles from when inputs are ready until result is available
- **Throughput**: How many of these instructions can be issued per cycle

```assembly
; High latency instruction
imul eax, ebx           ; Latency: 3 cycles, Throughput: 1 per cycle

; Lower latency alternative when multiplying by constants
lea eax, [ebx + ebx*2]  ; EAX = EBX * 3, Latency: 1 cycle
shl eax, 1              ; EAX = EBX * 6, Latency: 1 cycle

; Division - very high latency
mov eax, dividend
xor edx, edx
div divisor             ; Latency: 20-40 cycles (varies by CPU)

; Alternative for power-of-2 division
shr eax, 3              ; Divide by 8, Latency: 1 cycle
```

**Common Instruction Latencies (approximate, varies by microarchitecture):**

```assembly
; Integer operations
mov reg, reg            ; 0-1 cycles (register renaming)
add/sub/and/or/xor     ; 1 cycle
lea                     ; 1-3 cycles (depending on addressing mode)
imul reg, reg          ; 3-4 cycles
imul reg, imm          ; 3 cycles
div                     ; 20-40 cycles
shl/shr/sar            ; 1 cycle

; Memory operations
mov reg, [mem]         ; 4-5 cycles (L1 cache hit)
mov [mem], reg         ; 1 cycle (store buffer, actual write later)

; Floating-point operations
addss/addsd            ; 3-4 cycles
mulss/mulsd            ; 4-5 cycles
divss/divsd            ; 10-20 cycles
sqrtss/sqrtsd          ; 10-20 cycles
```

### Software Pipelining

Software pipelining overlaps iterations of a loop by scheduling instructions from different iterations to execute in parallel.

```assembly
; Standard loop - each iteration completes before next starts
mov ecx, count
.loop:
    mov eax, [esi]          ; Load
    add eax, ebx            ; Process
    mov [edi], eax          ; Store
    add esi, 4
    add edi, 4
    dec ecx
    jnz .loop

; Software pipelined loop - overlapping iterations
mov ecx, count
mov eax, [esi]              ; Prologue: load for iteration 0
dec ecx
jz .epilogue

.loop:
    add eax, ebx            ; Process iteration N
    mov edx, [esi + 4]      ; Load for iteration N+1 (parallel)
    mov [edi], eax          ; Store iteration N
    
    add esi, 4
    add edi, 4
    
    mov eax, edx            ; Move loaded value for next iteration
    dec ecx
    jnz .loop

.epilogue:
    add eax, ebx            ; Process final iteration
    mov [edi], eax          ; Store final result
```

### Avoiding False Dependencies

Some instructions create false dependencies that limit parallelism.

```assembly
; False dependency with partial register writes
mov al, 5               ; Writes AL (8-bit)
mov ebx, eax            ; Reads EAX - false dependency on previous EAX value
; Modern CPUs may stall because AL write doesn't clear upper bits

; Solution: Use full register operations
movzx eax, byte [value] ; Zero-extends, no false dependency
mov ebx, eax            ; No stall

; XOR idiom to break dependencies
xor eax, eax            ; Processor recognizes this as zeroing, breaks dependency
; Better than: mov eax, 0 (which may have dependencies)

; Partial flag register dependencies
add al, bl              ; Sets flags
; ... many instructions ...
adc cl, dl              ; Depends on carry flag - long dependency chain

; Solution: Use separate instruction sequences or LEA
lea ecx, [eax + ebx]    ; Doesn't affect flags, breaks dependency
```

