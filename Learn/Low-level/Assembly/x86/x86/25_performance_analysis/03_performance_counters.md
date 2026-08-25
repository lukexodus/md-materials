## Performance Counters


Modern x86 processors provide hardware performance counters to measure various events without significant overhead.

### Performance Monitoring Infrastructure

**Model-Specific Registers (MSRs) for Performance:**

- **IA32_PMC0 - IA32_PMC7** (0xC1-0xC8): Performance counter registers
- **IA32_PERFEVTSEL0 - IA32_PERFEVTSEL7** (0x186-0x18D): Event select registers
- **IA32_FIXED_CTR0 - IA32_FIXED_CTR2** (0x309-0x30B): Fixed-function counters
- **IA32_PERF_GLOBAL_CTRL** (0x38F): Global counter control
- **IA32_PERF_GLOBAL_STATUS** (0x38E): Global counter status
- **IA32_PERF_GLOBAL_OVF_CTRL** (0x390): Overflow control

### Configuring Performance Counters

**Basic Counter Setup:**

```nasm
; Check if performance monitoring available
mov eax, 0x0A
cpuid
; EAX bits 7-0: Version ID
; EAX bits 15-8: Number of general-purpose counters
; EAX bits 23-16: Bit width of counters

; Disable counter before programming
mov ecx, 0x186                  ; IA32_PERFEVTSEL0
xor eax, eax
xor edx, edx
wrmsr

; Reset counter
mov ecx, 0xC1                   ; IA32_PMC0
xor eax, eax
xor edx, edx
wrmsr

; Configure event (example: count instructions retired)
mov ecx, 0x186                  ; IA32_PERFEVTSEL0
; Event Select: 0xC0 (instructions retired)
; Unit Mask: 0x00
; USR: bit 16 (count in user mode)
; OS: bit 17 (count in OS mode)
; EN: bit 22 (enable counter)
mov eax, 0x004300C0             ; EN=1, USR=1, OS=1, Event=0xC0
xor edx, edx
wrmsr
```

**Event Select Register Format:**

```
Bits 7-0:   Event Select (which event to count)
Bits 15-8:  Unit Mask (sub-event specification)
Bit 16:     USR (count in ring 1-3)
Bit 17:     OS (count in ring 0)
Bit 18:     Edge (count 0→1 transitions)
Bit 19:     PC (pin control)
Bit 20:     INT (interrupt on overflow)
Bit 21:     ANY (count from any thread)
Bit 22:     EN (enable counter)
Bit 23:     INV (invert counter mask)
Bits 31-24: Counter Mask (count only if events ≥ mask)
```

### Common Performance Events

**Instructions and Cycles:**

```nasm
; Count instructions retired
; Event: 0xC0, UMask: 0x00
mov eax, 0x004300C0

; Count CPU cycles (not halted)
; Event: 0x3C, UMask: 0x00
mov eax, 0x0043003C

; Count reference cycles (unaffected by frequency scaling)
; Event: 0x3C, UMask: 0x01
mov eax, 0x0043013C
```

**Cache Events:**

```nasm
; L1 data cache misses
; Event: 0x51, UMask: 0x01 (varies by CPU)
mov eax, 0x00430151

; L2 cache misses
; Event: 0x24, UMask: 0x24 (varies by CPU)
mov eax, 0x00432424

; LLC (Last Level Cache) references
; Event: 0x2E, UMask: 0x4F
mov eax, 0x00434F2E

; LLC misses
; Event: 0x2E, UMask: 0x41
mov eax, 0x00434  12E
```

**Branch Events:**

```nasm
; Branch instructions retired
; Event: 0xC4, UMask: 0x00
mov eax, 0x004300C4

; Branch mispredictions
; Event: 0xC5, UMask: 0x00
mov eax, 0x004300C5

; Conditional branches
; Event: 0xC4, UMask: 0x01
mov eax, 0x004301C4
```

**Memory Events:**

```nasm
; Load instructions retired
; Event: 0xD0, UMask: 0x81
mov eax, 0x004381D0

; Store instructions retired
; Event: 0xD0, UMask: 0x82
mov eax, 0x004382D0

; Memory loads retired
; Event: 0xD1, UMask: 0x01
mov eax, 0x004301D1
```

### Reading Performance Counters

```nasm
; Read performance counter
mov ecx, 0xC1                   ; IA32_PMC0
rdmsr                           ; EDX:EAX = counter value

; Read fixed-function counter (instructions retired)
mov ecx, 0x309                  ; IA32_FIXED_CTR0
rdmsr                           ; EDX:EAX = instruction count

; Read fixed-function counter (CPU cycles)
mov ecx, 0x30A                  ; IA32_FIXED_CTR1
rdmsr                           ; EDX:EAX = cycle count
```

### Practical Performance Measurement

**Measure Instructions Per Cycle (IPC):**

```nasm
section .data
    start_cycles: dq 0
    start_instructions: dq 0
    end_cycles: dq 0
    end_instructions: dq 0

section .text
measure_ipc:
    ; Setup performance counters (instructions and cycles)
    call setup_perf_counters
    
    ; Read starting values
    mov ecx, 0x30A              ; Fixed counter 1 (cycles)
    rdmsr
    mov [start_cycles], eax
    mov [start_cycles + 4], edx
    
    mov ecx, 0x309              ; Fixed counter 0 (instructions)
    rdmsr
    mov [start_instructions], eax
    mov [start_instructions + 4], edx
    
    ; Code to measure
    call target_function
    
    ; Read ending values
    mov ecx, 0x30A
    rdmsr
    mov [end_cycles], eax
    mov [end_cycles + 4], edx
    
    mov ecx, 0x309
    rdmsr
    mov [end_instructions], eax
    mov [end_instructions + 4], edx
    
    ; Calculate IPC = instructions / cycles
    ; (simplified for 32-bit values)
    mov eax, [end_instructions]
    sub eax, [start_instructions]
    mov ebx, [end_cycles]
    sub ebx, [start_cycles]
    xor edx, edx
    div ebx                     ; EAX = IPC (integer division)
    
    ret
```

**Measure Cache Miss Rate:**

```nasm
measure_cache_misses:
    ; Configure counter 0 for L1 cache references
    mov ecx, 0x186
    mov eax, 0x00430151         ; L1 load misses
    xor edx, edx
    wrmsr
    
    ; Reset counter
    mov ecx, 0xC1
    xor eax, eax
    xor edx, edx
    wrmsr
    
    ; Code to measure
    call cache_intensive_function
    
    ; Read miss count
    mov ecx, 0xC1
    rdmsr
    ; EDX:EAX = miss count
    
    ret
```

### Overflow Handling

**Setting Up Overflow Interrupt:**

```nasm
; Configure counter with overflow interrupt
mov ecx, 0x186
mov eax, 0x00530000             ; INT=1, EN=1
or eax, 0x00C0                  ; Event select
xor edx, edx
wrmsr

; Set counter to trigger overflow soon
mov ecx, 0xC1
mov eax, 0xFFFFFFF0             ; Will overflow after 16 counts
xor edx, edx
wrmsr

; Overflow generates Performance Monitoring Interrupt (PMI)
; Handler reads IA32_PERF_GLOBAL_STATUS to identify which counter
```

**PMI Handler Example:**

```nasm
pmi_handler:
    push eax
    push edx
    push ecx
    
    ; Read global status
    mov ecx, 0x38E              ; IA32_PERF_GLOBAL_STATUS
    rdmsr
    ; Check which counters overflowed (bits in EAX)
    
    test eax, 1                 ; PMC0 overflow?
    jz .check_next
    ; Handle PMC0 overflow
    call handle_pmc0_overflow
    
.check_next:
    ; Clear overflow status
    mov ecx, 0x390              ; IA32_PERF_GLOBAL_OVF_CTRL
    mov eax, 1                  ; Clear PMC0 overflow
    xor edx, edx
    wrmsr
    
    pop ecx
    pop edx
    pop eax
    iretd
```

### Sampling with Performance Counters

```nasm
; Statistical sampling: overflow every N events
setup_sampling:
    mov ecx, 0x186
    mov eax, 0x00530000         ; Enable INT
    or eax, 0xC0                ; Instructions retired
    xor edx, edx
    wrmsr
    
    ; Set sample period (overflow every 100,000 instructions)
    mov ecx, 0xC1
    mov eax, 0xFFFFFFFF
    sub eax, 100000
    xor edx, edx
    wrmsr
    
    ; On overflow: PMI handler records instruction pointer (EIP)
    ; This creates a statistical profile of where time is spent
    ret
```

