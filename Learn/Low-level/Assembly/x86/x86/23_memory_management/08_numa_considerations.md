## NUMA Considerations


Non-Uniform Memory Access (NUMA) systems have multiple memory nodes, each with different access latencies depending on which CPU accesses them.

### NUMA Architecture Basics

**NUMA Characteristics:**

- Multiple CPU nodes, each with local memory
- [Inference] Local memory access is faster than remote memory access
- [Inference] Memory access latency varies based on distance between CPU and memory node
- Cache coherency maintained across all nodes

**Topology Example:**

```
    CPU Node 0          CPU Node 1
    +--------+          +--------+
    | CPU 0  |          | CPU 2  |
    | CPU 1  |          | CPU 3  |
    +--------+          +--------+
        |                   |
    +--------+          +--------+
    | Local  |          | Local  |
    | Memory |          | Memory |
    | Node 0 |          | Node 1 |
    +--------+          +--------+
        |___________________|
           Interconnect
```

### Detecting NUMA Configuration

**CPUID NUMA Information:**

```nasm
; Check for NUMA support
mov eax, 0x80000008
cpuid
; AL contains physical address bits
; CL contains number of CPU cores
```

**ACPI SRAT (System Resource Affinity Table):**

The SRAT table provides information about CPU and memory affinity. [Inference] Operating systems parse this table during boot to build NUMA topology.

**ACPI SLIT (System Locality Information Table):**

The SLIT table provides relative distance between memory nodes. [Inference] Used to determine optimal memory allocation strategies.

### NUMA Memory Allocation Strategies

**Local Allocation:**

[Inference] Allocate memory from the same NUMA node as the requesting CPU for optimal performance.

```nasm
; Example: Check current CPU's NUMA node (OS-specific)
; Typically done through OS memory allocator APIs

; Pseudo-code representation of NUMA-aware allocation
get_current_cpu_node:
    ; Read APIC ID to identify CPU
    mov eax, 1
    cpuid
    shr ebx, 24                 ; APIC ID in bits 24-31
    ; Map APIC ID to NUMA node (OS maintains this mapping)
    ; Return node ID in EAX
    ret
```

**Interleaved Allocation:**

[Inference] Distributes memory across multiple NUMA nodes to balance load and bandwidth.

```nasm
; Round-robin allocation across nodes
allocate_interleaved:
    mov eax, [allocation_counter]
    xor edx, edx
    mov ecx, [num_numa_nodes]
    div ecx                     ; EDX = node to allocate from
    ; Allocate from node in EDX
    inc dword [allocation_counter]
    ret

allocation_counter: dd 0
num_numa_nodes: dd 2
```

**Preferred Node with Fallback:**

```nasm
; Try local node first, fallback to remote on failure
allocate_preferred:
    call get_current_cpu_node
    mov esi, eax                ; Preferred node
    
    ; Try allocation from preferred node
    push esi
    call allocate_from_node
    test eax, eax
    jnz .success
    
    ; Fallback to any available node
    call allocate_from_any_node
    
.success:
    ret
```

### NUMA Page Table Considerations

**Node-Local Page Tables:**

[Inference] Page table structures themselves should be allocated on the NUMA node where they will be most frequently accessed.

```nasm
; Allocate page directory on same node as the process will run
create_process_paging:
    ; Determine target CPU/node for process
    mov esi, [target_numa_node]
    
    ; Allocate PML4 on target node
    push esi
    push 4096                   ; Size
    call allocate_from_node
    mov [pml4_addr], eax
    
    ; Allocate PDPT on same node
    push esi
    push 4096
    call allocate_from_node
    mov [pdpt_addr], eax
    
    ret
```

**Cross-Node Page Mappings:**

```nasm
; Map memory from different NUMA nodes
; Physical addresses may need node-specific encoding

map_remote_memory:
    ; Node 0 memory: 0x00000000 - 0x3FFFFFFF (example)
    ; Node 1 memory: 0x40000000 - 0x7FFFFFFF (example)
    
    ; Map 2 MB from Node 1 memory
    mov eax, 0x40000000         ; Physical address on Node 1
    or eax, 0x083               ; Present, R/W, Large page
    mov [pd_entry], rax
    
    ret
```

### Cache Coherency and NUMA

**MESI Protocol in NUMA:**

The MESI (Modified, Exclusive, Shared, Invalid) cache coherency protocol operates across NUMA nodes, but with increased latency.

**States:**

- **M (Modified)**: Cache line modified, not in other caches
- **E (Exclusive)**: Cache line clean, not in other caches
- **S (Shared)**: Cache line clean, may be in other caches
- **I (Invalid)**: Cache line invalid

**Cross-Node Coherency Cost:**

[Inference] When a CPU on Node 0 modifies data cached on Node 1, coherency traffic must traverse the interconnect, increasing latency significantly compared to local cache operations.

```nasm
; Prefetch data that will be accessed
prefetch_numa_data:
    ; Prefetch from potentially remote memory
    prefetcht0 [remote_data]    ; Prefetch to L1 cache
    prefetcht1 [more_remote]    ; Prefetch to L2 cache
    prefetcht2 [bulk_data]      ; Prefetch to L3 cache
    ret
```

### NUMA-Aware Memory Barriers

**Memory Fence Instructions:**

```nasm
; Full memory barrier (affects all memory)
mfence                          ; Serialize all loads and stores

; Load barrier (affects loads only)
lfence                          ; Serialize all loads before

; Store barrier (affects stores only)
sfence                          ; Serialize all stores before
```

**Cross-Node Synchronization:**

```nasm
; Acquire semantics (typically used with locks)
acquire_remote_lock:
    mov eax, 1
    lock xchg [remote_lock], eax ; Atomic exchange
    test eax, eax
    jnz acquire_remote_lock      ; Spin if already locked
    
    ; Memory barrier ensures subsequent loads see updated values
    mfence
    ret

; Release semantics
release_remote_lock:
    ; Memory barrier ensures all stores complete
    mfence
    
    mov dword [remote_lock], 0
    ret
```

### NUMA Memory Access Monitoring

**Performance Counters:**

x86 provides performance monitoring counters that can track NUMA-related metrics.

```nasm
; Read performance counter (example: memory accesses)
read_perf_counter:
    mov ecx, 0x186              ; IA32_PERFEVTSEL0
    rdmsr                       ; Read event select
    
    mov ecx, 0xC1               ; IA32_PMC0
    rdmsr                       ; EDX:EAX = counter value
    ret

; Configure counter to track remote memory accesses
setup_numa_monitoring:
    ; Disable counter
    mov ecx, 0x186              ; IA32_PERFEVTSEL0
    xor eax, eax
    xor edx, edx
    wrmsr
    
    ; Reset counter
    mov ecx, 0xC1               ; IA32_PMC0
    xor eax, eax
    xor edx, edx
    wrmsr
    
    ; Configure counter (event-specific, varies by CPU)
    ; Example: Track offcore requests
    mov ecx, 0x186
    mov eax, 0x0043B7B0         ; Event mask for offcore requests
    xor edx, edx
    wrmsr
    
    ret
```

### NUMA Page Migration

[Inference] Operating systems may migrate pages between NUMA nodes to optimize locality.

**Page Migration Process:**

```nasm
; Conceptual page migration steps
migrate_page_to_node:
    ; 1. Allocate new page on target node
    push dword [target_node]
    call allocate_page_on_node
    mov edi, eax                ; Destination page
    
    ; 2. Copy data from old page
    mov esi, [old_page_addr]
    mov ecx, 1024               ; 4 KB / 4 bytes
    rep movsd                   ; Copy page contents
    
    ; 3. Update page table entry
    mov eax, edi
    or eax, 0x003               ; Present, R/W
    mov [pte_addr], eax
    
    ; 4. Invalidate TLB
    invlpg [virtual_addr]
    
    ; 5. Free old page
    push dword [old_page_addr]
    call free_page
    
    ret
```

### Optimizing for NUMA

**False Sharing Avoidance:**

False sharing occurs when multiple CPUs access different data on the same cache line, causing unnecessary coherency traffic.

```nasm
; Bad: Variables on same cache line
section .data
align 64
shared_data:
    counter_node0: dd 0         ; Used by Node 0
    counter_node1: dd 0         ; Used by Node 1 (same cache line!)

; Good: Variables on separate cache lines
section .data
align 64
counter_node0: dd 0
    times 15 dd 0               ; Padding to 64 bytes
align 64
counter_node1: dd 0
    times 15 dd 0               ; Padding to 64 bytes
```

**NUMA-Aware Data Structures:**

```nasm
; Per-node data structure
struc PerNodeData
    .counter:       resd 1
    .padding:       resb 60     ; Pad to cache line
    .buffer:        resb 4096   ; Node-local buffer
endstruc

section .bss
align 64
node_data:
    resb PerNodeData_size * 4   ; 4 NUMA nodes
```

**Lock Scaling on NUMA:**

```nasm
; Per-node locks instead of global lock
section .data
align 64
node_locks:
    times 4 dd 0                ; One lock per node, cache-aligned

; Acquire node-local lock
acquire_node_lock:
    call get_current_cpu_node
    lea ebx, [node_locks + eax * 4]
    
    mov eax, 1
.spin:
    lock xchg [ebx], eax
    test eax, eax
    jnz .spin
    ret
```

### Advanced NUMA Features

**Memory-Side Caching:**

[Inference] Some systems have additional cache levels near memory controllers to reduce remote access latency.

**Transparent Huge Pages (THP) and NUMA:**

```nasm
; Check for THP support
check_thp_support:
    ; Typically controlled via OS, not direct CPU feature
    ; OS may split THPs across NUMA boundaries
    ret
```

**NUMA Balancing:**

[Inference] Modern systems track page access patterns and automatically migrate pages to optimal nodes. This is typically done by the OS using page fault tracking.

```nasm
; Conceptual: Mark pages for access tracking
mark_page_for_tracking:
    ; Clear present bit to trigger soft page fault
    mov eax, [pte_addr]
    and eax, ~1                 ; Clear present bit
    mov [pte_addr], eax
    invlpg [virtual_addr]
    
    ; On fault, OS records which node accessed the page
    ret
```

### Instruction-Level NUMA Considerations

**PAUSE Instruction in Spin-Loops:**

```nasm
; Spin-wait with PAUSE for better performance
numa_spinlock:
    mov eax, 1
.spin:
    pause                       ; Hint to CPU: this is a spin-loop
    lock xchg [lock_var], eax
    test eax, eax
    jnz .spin
    ret
```

[Inference] PAUSE reduces power consumption and can improve performance in NUMA systems by reducing memory ordering speculation that would be rolled back on lock acquisition.

**MONITOR/MWAIT for Cross-Node Synchronization:**

```nasm
; Wait for memory location to change (NUMA-aware)
wait_for_remote_update:
    mov eax, [watch_addr]
    mov ecx, [watch_addr]
    mov edx, 0
    
    ; Set up monitoring
    monitor                     ; Monitor EAX address
    
    ; Check if value already changed
    mov ebx, [watch_addr]
    cmp ebx, ecx
    jne .changed
    
    ; Wait with optional hints
    mov eax, 0                  ; C-state hint
    mov ecx, 0                  ; Extension hint
    mwait                       ; Wait for write to monitored address
    
.changed:
    ret
```

### NUMA Memory Bandwidth Optimization

**Prefetching Strategy:**

```nasm
; Aggressive prefetching for remote NUMA data
prefetch_remote_bandwidth:
    mov esi, [remote_array]
    mov ecx, [array_size]
    
.prefetch_loop:
    prefetchnta [esi]           ; Non-temporal prefetch (bypass cache)
    prefetchnta [esi + 64]
    prefetchnta [esi + 128]
    prefetchnta [esi + 192]
    
    add esi, 256
    sub ecx, 256
    jg .prefetch_loop
    
    ret
```

**Non-Temporal Stores:**

```nasm
; Bypass cache when writing to remote memory
write_remote_streaming:
    mov edi, [remote_buffer]
    mov ecx, [buffer_size]
    shr ecx, 4                  ; Divide by 16
    
    pxor xmm0, xmm0             ; Zero XMM register
    
.store_loop:
    movntdq [edi], xmm0         ; Non-temporal store (128-bit)
    add edi, 16
    loop .store_loop
    
    sfence                      ; Ensure stores complete
    ret
```

### NUMA and Page Coloring

[Inference] Page coloring can be used to optimize cache usage in NUMA systems by controlling which cache sets pages map to.

```nasm
; Allocate pages with specific color (cache set affinity)
allocate_colored_page:
    ; Page color = page_frame_number & color_mask
    mov eax, [desired_color]
    mov ebx, [color_mask]
    
.search:
    call get_free_page
    mov ecx, eax
    shr ecx, 12                 ; Get page frame number
    and ecx, ebx                ; Apply color mask
    cmp ecx, eax                ; Check if matches desired color
    je .found
    
    push eax
    call free_page              ; Wrong color, try again
    jmp .search
    
.found:
    ret
```

### Memory Bandwidth Monitoring

**Intel Memory Bandwidth Allocation (MBA):**

```nasm
; Configure memory bandwidth allocation (requires RDT support)
setup_memory_bandwidth:
    ; Check for MBA support
    mov eax, 0x10
    mov ecx, 0
    cpuid
    test ebx, 0x08              ; Check MBA bit
    jz .no_support
    
    ; Configure MBA MSR (example)
    mov ecx, 0xD50              ; IA32_MBA_BW_BASE
    mov eax, 0x50               ; 50% bandwidth
    xor edx, edx
    wrmsr
    
.no_support:
    ret
```

### NUMA-Specific MSRs

**Memory Controller Configuration:**

```nasm
; Read NUMA node configuration (CPU-specific)
read_numa_config:
    ; AMD: Read from configuration space
    ; Intel: Read from uncore MSRs
    
    ; Example: Intel uncore MSRs (specific to CPU model)
    mov ecx, 0x700              ; Example MSR address
    rdmsr                       ; Read configuration
    ; Parse EDX:EAX for NUMA information
    
    ret
```

### NUMA Distance Matrix

[Inference] Operating systems build a distance matrix indicating relative access costs between nodes.

```nasm
; Example NUMA distance table structure
section .data
numa_distance:
    ; Distance from Node 0 to [0,1,2,3]
    db 10, 20, 30, 30
    ; Distance from Node 1 to [0,1,2,3]
    db 20, 10, 30, 30
    ; Distance from Node 2 to [0,1,2,3]
    db 30, 30, 10, 20
    ; Distance from Node 3 to [0,1,2,3]
    db 30, 30, 20, 10

; Get distance between two nodes
get_numa_distance:
    ; Input: AL = source node, AH = dest node
    ; Output: AL = distance
    movzx ebx, al
    movzx ecx, ah
    shl ebx, 2                  ; * 4 nodes
    add ebx, ecx
    mov al, [numa_distance + ebx]
    ret
```

**Key Points:**

- Virtual address translation uses multi-level page tables with mode-dependent structures: 2 levels for 32-bit, 3 for PAE, 4 for x86-64 long mode
- TLB caching accelerates translation by storing recent mappings; global pages (G flag) persist across CR3 reloads
- Large pages (2 MB) and huge pages (1 GB) reduce TLB pressure and page table overhead by using PS bit to terminate translation early
- PAE extends 32-bit addressing to 36-bit physical addresses using 8-byte descriptors instead of 4-byte entries
- x86-64 canonical addresses require sign-extension of bit 47, creating distinct lower (user) and upper (kernel) address ranges
- Page faults store the faulting address in CR2 and push an error code indicating fault type (present, write, user, reserved, instruction)
- NUMA systems have non-uniform memory latency depending on CPU-to-memory-node distance
- [Inference] NUMA optimization requires node-local allocation strategies, cache-line alignment to avoid false sharing, and memory barriers for cross-node synchronization
- Performance monitoring counters and prefetch instructions help optimize NUMA memory bandwidth
- [Inference] Operating systems use page migration, access tracking, and distance matrices to automatically optimize NUMA placement

---

