## Pipeline Awareness


Modern x86 processors use deep pipelines to achieve high clock frequencies. Understanding pipeline characteristics helps avoid stalls and maximize throughput.

### Pipeline Stages

A typical modern x86 pipeline has 14-20+ stages:

1. **Fetch**: Retrieve instruction bytes from cache
2. **Decode**: Decode x86 instructions into micro-ops (μops)
3. **Allocate**: Allocate resources (ROB entries, registers)
4. **Rename**: Rename registers to eliminate false dependencies
5. **Dispatch**: Send micro-ops to reservation stations
6. **Schedule**: Wait for operands and execution unit availability
7. **Execute**: Perform the operation
8. **Writeback**: Write results to register file
9. **Retire**: Commit results in program order

```assembly
; Pipeline-friendly code - smooth flow
mov eax, [esi]          ; Stage 1: Fetch/Decode
add eax, 10             ; Stage 2: Already fetching while Stage 1 executes
mov [edi], eax          ; Stage 3: Already fetching
add esi, 4              ; Stage 4: Already fetching
; All instructions flow smoothly through pipeline
```

### Micro-Operation (μop) Fusion

Modern x86 processors decode complex instructions into simpler micro-operations. Some instruction combinations can be fused into single μops.

**Macro-Fusion: Compare and Branch**

```assembly
; Two instructions fused into one μop
cmp eax, ebx
je .target              ; CMP+JE fused on most modern CPUs

; Supported fusion patterns:
cmp/test + jcc          ; Condition code jump
and/or/xor + jcc       ; Logical operation + jump
add/sub + jcc          ; Arithmetic + jump

; Not fused - extra μop
cmp eax, ebx
mov ecx, 5              ; Instruction between CMP and JE
je .target              ; Cannot fuse with CMP
```

**Micro-Fusion: Memory Operands**

```assembly
; Memory operation micro-fused
add eax, [esi]          ; Address generation + ADD fused into 1-2 μops

; Complex addressing may not fuse
add eax, [esi + edi*4 + offset]  ; May be 2-3 μops

; Separate operations - no fusion
mov ebx, [esi]
add eax, ebx            ; 2 separate μops
```

**Store Address and Store Data Fusion**

```assembly
; Store operations can fuse address and data calculations
mov [edi], eax          ; Address + data = 1 μop (when simple)

; Complex stores may not fuse
mov [edi + esi*4], eax  ; May be 2 μops
```

### Avoiding Pipeline Stalls

Pipeline stalls occur when the processor must wait for resources or resolve dependencies.

**Load-Use Latency:**

```assembly
; Load-use stall - immediate use of loaded data
mov eax, [esi]
add ebx, eax            ; Stalls waiting for load to complete (4-5 cycles)

; Avoid by scheduling other work
mov eax, [esi]
mov ecx, [edi]          ; Independent operation while EAX loads
add edx, 10             ; Independent operation
add ebx, eax            ; EAX ready by now, no stall
```

**Store Forwarding Stalls:**

```assembly
; Store forwarding stall - load from recently stored address
mov [esi], eax
mov ebx, [esi]          ; May stall if sizes/addresses don't match perfectly

; Size mismatch - definite stall
mov byte [esi], al
mov ebx, [esi]          ; Loads 4 bytes, store was 1 byte - stall

; Solution: Keep sizes consistent
mov [esi], eax          ; 4-byte store
mov ebx, [esi]          ; 4-byte load - forwarding works
```

**Partial Register Stalls:**

```assembly
; Partial register stall
mov eax, large_value    ; Full 32-bit write
mov al, 5               ; 8-bit write to low byte
mov ebx, eax            ; Read full 32-bit - may stall to merge values

; Solution: Use full register operations
mov eax, large_value
and eax, 0xFFFFFF00     ; Clear low byte
or eax, 5               ; Set low byte - no merge needed
mov ebx, eax            ; No stall
```

**AGU (Address Generation Unit) Stalls:**

```assembly
; AGU stall - complex address calculation
mov eax, [esi + edi*8 + offset + 100]  ; Complex, may need multiple cycles

; Simpler addressing when possible
lea ebx, [esi + edi*8 + offset]
mov eax, [ebx + 100]    ; Simpler final addressing
```

### Instruction Alignment

[Inference] Instruction alignment affects fetch efficiency. Aligning branch targets and loop entries can improve performance by ensuring they fit within fetch boundaries.

```assembly
; Align loop entry to cache line boundary
align 16                ; Or align 32/64 depending on cache line size
.loop:
    mov eax, [esi]
    add eax, ebx
    mov [edi], eax
    add esi, 4
    add edi, 4
    dec ecx
    jnz .loop

; Align frequently-called functions
align 16
hot_function:
    push ebp
    mov ebp, esp
    ; Function body
    pop ebp
    ret
```

### Macro-Op Cache and Decoded μop Cache

Modern Intel processors cache decoded μops in the DSB (Decoded Stream Buffer) or μop cache. Code that fits in this cache executes more efficiently.

```assembly
; Keeping hot loops small helps them fit in μop cache
; Aim for loops under 28-32 μops (varies by microarchitecture)

; Large loop - may not fit in μop cache
.large_loop:
    ; 50+ μops of code
    ; May need to re-decode on each iteration
    
; Optimized - split into smaller sections or reduce μop count
.small_loop:
    ; 20-25 μops
    ; Fits in μop cache, faster execution
```

