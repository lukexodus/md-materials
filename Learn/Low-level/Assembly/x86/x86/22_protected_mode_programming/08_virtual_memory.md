## Virtual Memory


Virtual memory is an abstraction that provides each process with its own address space, independent of physical memory. It enables memory protection, demand paging, shared memory, and efficient memory utilization.

### Virtual Address Space Layout

A typical 32-bit virtual address space is organized into regions:

```
0xFFFFFFFF +------------------+
           |  Kernel Space    |  1 GB (configurable)
           |  (Shared)        |
0xC0000000 +------------------+
           |                  |
           |  User Space      |  3 GB
           |  (Per Process)   |
           |                  |
0x00000000 +------------------+
```

Common user space layout:

```
0xC0000000 +------------------+
           |  Kernel (mapped) |
0xBFFFFFFF +------------------+
           |  Stack           |  (grows down)
           |        ↓         |
           |                  |
           |  Free Space      |
           |                  |
           |        ↑         |
           |  Heap            |  (grows up)
           +------------------+
           |  BSS (uninitialized) |
           +------------------+
           |  Data (initialized)  |
           +------------------+
           |  Text (code)     |
0x08048000 +------------------+
           |  Reserved        |
0x00000000 +------------------+
```

### Demand Paging

Demand paging is a technique where pages are loaded into physical memory only when accessed, rather than loading the entire program at startup. This reduces memory usage and startup time.

**Implementation:**

1. Mark pages as not present in page tables
2. When page is accessed, page fault occurs
3. Page fault handler loads page from disk
4. Update page table entry to mark present
5. Resume execution

```assembly
; Simplified demand paging handler
demand_paging_handler:
    push eax
    push ebx
    push ecx
    
    ; Get faulting address
    mov eax, cr2
    
    ; Get error code
    mov ebx, [esp + 16]
    
    ; Check if not present
    test ebx, 1
    jnz .not_demand_paging
    
    ; Find page in process's virtual memory descriptor
    call find_vma
    test eax, eax
    jz .invalid_access
    
    ; Allocate physical page
    call allocate_physical_page
    test eax, eax
    jz .out_of_memory
    
    mov ebx, eax            ; Physical address in EBX
    
    ; Check if page needs to be loaded from disk
    mov eax, cr2
    call check_page_on_disk
    test eax, eax
    jz .zero_page
    
    ; Load page from disk
    mov ecx, eax            ; Disk location
    mov eax, ebx            ; Physical address
    call load_page_from_disk
    jmp .map_page
    
.zero_page:
    ; Zero out the page
    mov edi, ebx
    xor eax, eax
    mov ecx, 1024           ; 4096 bytes / 4
    rep stosd
    
.map_page:
    ; Map page into process's page table
    mov eax, cr2
    and eax, 0xFFFFF000     ; Align to page boundary
    call map_page_to_address
    
    ; Invalidate TLB
    mov eax, cr2
    invlpg [eax]
    
    pop ecx
    pop ebx
    pop eax
    add esp, 4              ; Remove error code
    iret
    
.invalid_access:
    ; Segmentation fault - terminate process
    call terminate_process
    
.out_of_memory:
    ; Try to free memory or kill process
    call handle_oom
    
.not_demand_paging:
    ; Different type of page fault
    jmp other_page_fault_handler
```

### Copy-on-Write (COW)

Copy-on-write is an optimization where multiple processes share the same physical pages until one attempts to modify them. When a write occurs, a private copy is created for the writing process.

**Implementation:**

1. Map pages as read-only in child process after fork
2. Parent and child share same physical pages
3. On write attempt, page fault occurs
4. Allocate new physical page
5. Copy original page to new page
6. Map new page as read/write
7. Update original page reference count

```assembly
; Copy-on-write handler
cow_handler:
    push eax
    push ebx
    push ecx
    push esi
    push edi
    
    ; Get faulting address
    mov eax, cr2
    
    ; Get error code
    mov ebx, [esp + 24]
    
    ; Check if write attempt to read-only page
    test ebx, 2             ; Write bit
    jz .not_cow
    test ebx, 1             ; Present bit
    jz .not_cow
    
    ; Get page table entry
    call get_pte_for_address
    mov ebx, eax
    
    ; Check if page is marked as COW
    test dword [ebx], 0x200 ; Custom COW bit (bit 9)
    jz .not_cow
    
    ; Check reference count
    mov ecx, [ebx]
    and ecx, 0xFFFFF000     ; Get physical address
    call get_page_refcount
    cmp eax, 1
    je .make_writable       ; Only reference, just make writable
    
    ; Allocate new page
    call allocate_physical_page
    test eax, eax
    jz .out_of_memory
    
    mov edi, eax            ; New physical page
    
    ; Copy original page to new page
    mov esi, [ebx]
    and esi, 0xFFFFF000     ; Original physical address
    mov ecx, 1024           ; 4096 bytes / 4
    rep movsd
    
    ; Decrement reference count on original page
    mov eax, [ebx]
    and eax, 0xFFFFF000
    call decrement_page_refcount
    
    ; Update page table entry
    mov eax, edi
    or eax, 0x03            ; Present + R/W
    mov [ebx], eax
    
    jmp .done
    
.make_writable:
    ; Only one reference, just make page writable
    or dword [ebx], 0x02    ; Set R/W bit
    and dword [ebx], ~0x200 ; Clear COW bit
    
.done:
    ; Invalidate TLB
    mov eax, cr2
    invlpg [eax]
    
    pop edi
    pop esi
    pop ecx
    pop ebx
    pop eax
    add esp, 4
    iret
    
.out_of_memory:
    call handle_oom
    
.not_cow:
    jmp other_page_fault_handler
```

### ### Swapping and Page Replacement

When physical memory is exhausted, the operating system must select pages to evict to disk storage (swap space) to make room for new pages. This process requires page replacement algorithms to determine which pages to swap out.

**Common Page Replacement Algorithms:**

**Least Recently Used (LRU):**

Evicts the page that has not been accessed for the longest time. The processor sets the Accessed bit when a page is referenced, which the OS can use to approximate LRU.

```assembly
; Simplified LRU-approximation using accessed bits
find_lru_page:
    push ebx
    push ecx
    push esi
    
    mov esi, page_frame_array
    mov ecx, num_page_frames
    xor ebx, ebx            ; Best candidate
    mov edx, 0xFFFFFFFF     ; Lowest access time
    
.scan_loop:
    ; Get page table entry for this frame
    mov eax, [esi + PAGE_FRAME.pte_addr]
    
    ; Check if page is swappable
    test dword [eax], 0x100 ; Check locked bit (custom)
    jnz .next_frame
    
    ; Check accessed bit
    test dword [eax], 0x20  ; Accessed bit
    jz .good_candidate      ; Not accessed recently
    
    ; Clear accessed bit (second chance)
    and dword [eax], ~0x20
    jmp .next_frame
    
.good_candidate:
    ; Compare access time
    mov eax, [esi + PAGE_FRAME.last_access]
    cmp eax, edx
    jae .next_frame
    
    mov edx, eax
    mov ebx, esi
    
.next_frame:
    add esi, PAGE_FRAME_size
    loop .scan_loop
    
    mov eax, ebx            ; Return best candidate
    
    pop esi
    pop ecx
    pop ebx
    ret
```

**Clock Algorithm (Second Chance):**

A simpler approximation of LRU that uses a circular list and the Accessed bit.

```assembly
; Clock algorithm for page replacement
clock_algorithm:
    push ebx
    push ecx
    
    mov ebx, [clock_hand]   ; Current position in circular list
    
.search_loop:
    ; Get page table entry
    mov eax, [ebx + PAGE_FRAME.pte_addr]
    
    ; Check if swappable
    test dword [eax], 0x100 ; Locked bit
    jnz .advance
    
    ; Check accessed bit
    test dword [eax], 0x20
    jz .found_victim        ; Not accessed, evict this page
    
    ; Clear accessed bit and give second chance
    and dword [eax], ~0x20
    
.advance:
    ; Move to next frame
    add ebx, PAGE_FRAME_size
    cmp ebx, page_frame_array_end
    jl .search_loop
    
    ; Wrap around
    mov ebx, page_frame_array
    jmp .search_loop
    
.found_victim:
    ; Update clock hand
    mov [clock_hand], ebx
    
    ; Return page frame
    mov eax, ebx
    
    pop ecx
    pop ebx
    ret
```

**Page Eviction Process:**

```assembly
; Evict page to swap space
evict_page:
    ; Parameters: EAX = page frame to evict
    push ebx
    push ecx
    push edx
    
    mov ebx, eax
    
    ; Get page table entry
    mov ecx, [ebx + PAGE_FRAME.pte_addr]
    
    ; Check dirty bit
    test dword [ecx], 0x40  ; Dirty bit
    jz .not_dirty
    
    ; Page is dirty, write to swap
    mov eax, [ebx + PAGE_FRAME.phys_addr]
    call allocate_swap_slot
    mov edx, eax            ; Swap slot number
    
    ; Write page to disk
    mov eax, [ebx + PAGE_FRAME.phys_addr]
    call write_page_to_swap
    
    ; Store swap location in PTE
    mov eax, edx
    shl eax, 12             ; Swap slot in upper bits
    or eax, 0x800           ; Mark as swapped (custom bit)
    mov [ecx], eax
    jmp .update_pte
    
.not_dirty:
    ; Clean page, can discard if backed by file
    mov eax, [ebx + PAGE_FRAME.backing]
    test eax, eax
    jz .must_swap
    
    ; Just mark as not present
    mov dword [ecx], 0
    jmp .done
    
.must_swap:
    ; Must write to swap even if clean
    jmp .not_dirty
    
.update_pte:
    ; Clear present bit
    and dword [ecx], ~0x01
    
.done:
    ; Invalidate TLB
    mov eax, [ebx + PAGE_FRAME.virt_addr]
    invlpg [eax]
    
    ; Mark frame as free
    mov dword [ebx + PAGE_FRAME.state], PAGE_FREE
    
    pop edx
    pop ecx
    pop ebx
    ret
```

### Memory Mapped Files

Memory mapped files allow files to be accessed as if they were part of the process's address space, using page faults to load file contents on demand.

```assembly
; Map file into virtual address space
mmap_file:
    ; Parameters:
    ; EAX = file descriptor
    ; EBX = virtual address (or 0 for automatic)
    ; ECX = length
    ; EDX = protection flags
    ; ESI = offset in file
    
    push edi
    push ebp
    
    ; Find free virtual address range if needed
    test ebx, ebx
    jnz .address_specified
    
    call find_free_vma
    mov ebx, eax
    
.address_specified:
    ; Create VMA (Virtual Memory Area) structure
    call allocate_vma
    mov edi, eax
    
    ; Fill VMA fields
    mov [edi + VMA.start], ebx
    add ecx, ebx
    mov [edi + VMA.end], ecx
    mov [edi + VMA.prot], edx
    mov [edi + VMA.file], eax
    mov [edi + VMA.offset], esi
    mov dword [edi + VMA.flags], VMA_FILE
    
    ; Mark pages as not present
    mov eax, ebx
    mov ecx, [edi + VMA.end]
    
.mark_loop:
    call get_pte_for_address
    mov dword [eax], 0      ; Not present
    add ebx, 0x1000
    cmp ebx, ecx
    jl .mark_loop
    
    ; Insert VMA into process's VMA list
    call insert_vma
    
    mov eax, [edi + VMA.start]  ; Return mapped address
    
    pop ebp
    pop edi
    ret

; Handle page fault for memory-mapped file
mmap_page_fault_handler:
    push eax
    push ebx
    push ecx
    push edx
    
    ; Get faulting address
    mov eax, cr2
    
    ; Find VMA for this address
    call find_vma
    test eax, eax
    jz .invalid_access
    
    mov ebx, eax            ; VMA structure
    
    ; Check if file-backed
    test dword [ebx + VMA.flags], VMA_FILE
    jz .not_file_backed
    
    ; Allocate physical page
    call allocate_physical_page
    test eax, eax
    jz .out_of_memory
    
    mov ecx, eax            ; Physical page
    
    ; Calculate file offset
    mov eax, cr2
    and eax, 0xFFFFF000     ; Page align
    sub eax, [ebx + VMA.start]
    add eax, [ebx + VMA.offset]
    
    ; Read page from file
    mov edx, [ebx + VMA.file]
    push ecx
    call read_file_page
    pop ecx
    
    ; Map page
    mov eax, cr2
    and eax, 0xFFFFF000
    mov ebx, ecx            ; Physical address
    mov ecx, [ebx + VMA.prot]
    or ecx, 0x01            ; Set present
    call map_page
    
    ; Invalidate TLB
    mov eax, cr2
    invlpg [eax]
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    add esp, 4
    iret
    
.invalid_access:
    call terminate_process
    
.out_of_memory:
    call handle_oom
    
.not_file_backed:
    jmp demand_paging_handler
```

### Shared Memory

Shared memory allows multiple processes to access the same physical memory pages, enabling fast inter-process communication.

```assembly
; Create shared memory segment
create_shared_memory:
    ; Parameters: EAX = size in bytes
    push ebx
    push ecx
    push edi
    
    ; Round up to page size
    add eax, 0xFFF
    and eax, 0xFFFFF000
    mov ecx, eax            ; Total size
    
    ; Allocate physical pages
    shr eax, 12             ; Number of pages
    call allocate_physical_pages
    test eax, eax
    jz .failed
    
    mov ebx, eax            ; First physical page
    
    ; Create shared memory descriptor
    call allocate_shm_descriptor
    mov edi, eax
    
    ; Fill descriptor
    mov [edi + SHM.phys_base], ebx
    mov [edi + SHM.size], ecx
    mov dword [edi + SHM.refcount], 0
    
    ; Generate unique key
    call generate_shm_key
    mov [edi + SHM.key], eax
    
    ; Add to system shared memory table
    call register_shm
    
    mov eax, [edi + SHM.key]    ; Return key
    
    pop edi
    pop ecx
    pop ebx
    ret
    
.failed:
    xor eax, eax
    pop edi
    pop ecx
    pop ebx
    ret

; Attach shared memory to process
attach_shared_memory:
    ; Parameters: EAX = shared memory key, EBX = virtual address hint
    push ecx
    push edx
    push esi
    push edi
    
    ; Find shared memory descriptor
    call find_shm_by_key
    test eax, eax
    jz .not_found
    
    mov esi, eax            ; SHM descriptor
    
    ; Find virtual address range
    mov eax, ebx
    mov ecx, [esi + SHM.size]
    call find_or_allocate_vma
    mov edi, eax            ; Virtual address
    
    ; Map shared pages
    mov eax, edi            ; Virtual address
    mov ebx, [esi + SHM.phys_base]  ; Physical base
    mov ecx, [esi + SHM.size]
    shr ecx, 12             ; Number of pages
    
.map_loop:
    push eax
    push ebx
    push ecx
    
    ; Map one page
    mov ecx, 0x07           ; Present + R/W + User
    call map_page
    
    pop ecx
    pop ebx
    pop eax
    
    add eax, 0x1000         ; Next virtual page
    add ebx, 0x1000         ; Next physical page
    loop .map_loop
    
    ; Increment reference count
    inc dword [esi + SHM.refcount]
    
    mov eax, edi            ; Return virtual address
    
    pop edi
    pop esi
    pop edx
    pop ecx
    ret
    
.not_found:
    xor eax, eax
    pop edi
    pop esi
    pop edx
    pop ecx
    ret
```

### Address Space Layout Randomization (ASLR)

[Inference] ASLR randomizes the base addresses of key memory regions to make exploitation more difficult. This is implemented by adding random offsets when allocating virtual memory regions.

```assembly
; Get randomized base address for stack
get_random_stack_base:
    push ebx
    
    ; Get random value
    call get_random_value
    
    ; Limit to reasonable range (e.g., 8MB variation)
    and eax, 0x7FFFFF       ; 8MB - 1
    
    ; Add to default stack base
    add eax, DEFAULT_STACK_BASE
    
    ; Align to page boundary
    and eax, 0xFFFFF000
    
    pop ebx
    ret

; Get randomized base address for heap
get_random_heap_base:
    push ebx
    
    call get_random_value
    and eax, 0x3FFFFFF      ; 64MB variation
    add eax, DEFAULT_HEAP_BASE
    and eax, 0xFFFFF000
    
    pop ebx
    ret
```

### Memory Protection Keys (PKU)

[Inference] Memory Protection Keys provide page-level protection by assigning pages to protection domains, allowing rapid permission changes without TLB flushes. This is a hardware feature available on newer x86 processors.

```assembly
; Set protection key for page (requires support check first)
set_page_protection_key:
    ; Parameters: EAX = virtual address, EBX = protection key (0-15)
    push ecx
    
    ; Get PTE
    call get_pte_for_address
    mov ecx, eax
    
    ; Clear old protection key bits (59-62)
    mov eax, [ecx]
    and eax, 0x87FFFFFFFFFFFFFF  ; Clear bits 59-62 (64-bit)
    
    ; Set new protection key
    shl rbx, 59
    or rax, rbx
    
    mov [rcx], rax
    
    ; Invalidate TLB entry
    mov eax, [esp + 8]      ; Original virtual address
    invlpg [eax]
    
    pop ecx
    ret

; Write to PKRU register to change permissions
set_pkru:
    ; Parameters: EAX = PKRU value
    ; Bits 0-1: Access disable for key 0
    ; Bits 2-3: Write disable for key 0
    ; Repeat for keys 1-15
    
    xor ecx, ecx
    xor edx, edx
    wrpkru                  ; Write to PKRU register
    ret
```

### Huge Pages (2MB/1GB Pages)

Huge pages reduce TLB pressure and improve performance for applications with large memory footprints.

```assembly
; Map 2MB huge page (requires PSE or PAE)
map_huge_page_2mb:
    ; Parameters: EAX = virtual address, EBX = physical address
    push ecx
    push edx
    push edi
    
    ; Align addresses to 2MB
    and eax, 0xFFE00000
    and ebx, 0xFFE00000
    
    ; Get page directory entry
    mov edi, eax
    shr edi, 22             ; PD index
    shl edi, 2
    add edi, page_directory
    
    ; Set PDE with PS bit
    mov ecx, ebx
    or ecx, 0x83            ; Present + R/W + PS (2MB page)
    mov [edi], ecx
    
    ; Invalidate TLB
    invlpg [eax]
    
    pop edi
    pop edx
    pop ecx
    ret

; Allocate and map 1GB huge page (requires 1GB page support)
map_huge_page_1gb:
    ; Parameters: EAX = virtual address, EBX = physical address
    ; Requires PDPTE with PS bit set
    push ecx
    push edx
    push edi
    
    ; Align to 1GB
    and eax, 0xC0000000
    and ebx, 0xC0000000
    
    ; Get PDPT entry (PAE or 64-bit mode)
    ; ... implementation depends on paging mode ...
    
    ; Set PDPTE with PS bit
    mov ecx, ebx
    or ecx, 0x83            ; Present + R/W + PS (1GB page)
    ; Store in appropriate PDPTE
    
    pop edi
    pop edx
    pop ecx
    ret
```

### NUMA (Non-Uniform Memory Access) Awareness

[Inference] In multi-processor systems with NUMA architecture, memory access latency varies depending on which CPU core accesses which memory bank. Operating systems can optimize by allocating memory from the local NUMA node.

```assembly
; Get NUMA node for current CPU
get_current_numa_node:
    ; Read APIC ID to determine CPU
    mov eax, 1
    cpuid
    shr ebx, 24             ; APIC ID in bits 31-24
    
    ; Map APIC ID to NUMA node (system-specific)
    call apic_to_numa_node
    ret

; Allocate page from specific NUMA node
allocate_page_from_node:
    ; Parameters: EAX = NUMA node ID
    push ebx
    push ecx
    
    mov ebx, eax
    
    ; Get free page list for this node
    shl ebx, 2              ; Node * 4 for pointer offset
    mov ecx, [numa_free_lists + ebx]
    
    ; Check if pages available
    test ecx, ecx
    jz .try_other_nodes
    
    ; Allocate from this node's list
    call allocate_from_list
    jmp .done
    
.try_other_nodes:
    ; Fall back to other nodes
    call allocate_any_page
    
.done:
    pop ecx
    pop ebx
    ret
```

### Page Table Isolation (PTI/KPTI)

[Inference] Page Table Isolation mitigates Meltdown and other speculative execution vulnerabilities by maintaining separate page tables for kernel and user space, with minimal kernel mappings in user page tables.

```assembly
; Switch to user page table (simplified)
switch_to_user_pt:
    push eax
    
    ; Get user page table from current task
    mov eax, [current_task]
    mov eax, [eax + TASK.user_cr3]
    
    ; Switch to user page table
    mov cr3, eax
    
    pop eax
    ret

; Switch to kernel page table
switch_to_kernel_pt:
    push eax
    
    ; Load kernel page table
    mov eax, kernel_cr3
    mov cr3, eax
    
    pop eax
    ret

; System call entry with PTI
syscall_entry_pti:
    ; Switch to kernel page table
    swapgs                  ; Swap GS base (64-bit)
    mov [gs:user_cr3], cr3  ; Save user CR3
    mov rax, [gs:kernel_cr3]
    mov cr3, rax            ; Load kernel CR3
    
    ; Continue with system call handling
    ; ...
    
    ret

; System call return with PTI
syscall_return_pti:
    ; Restore user page table
    mov rax, [gs:user_cr3]
    mov cr3, rax
    swapgs
    
    sysretq
```

### Memory Ballooning (Virtualization)

[Inference] In virtualized environments, memory ballooning allows the hypervisor to reclaim memory from guest operating systems by having a balloon driver allocate and pin pages within the guest.

```assembly
; Balloon driver: inflate (give memory back to hypervisor)
balloon_inflate:
    ; Parameters: EAX = number of pages to balloon
    push ebx
    push ecx
    push edi
    
    mov ecx, eax
    
.inflate_loop:
    ; Allocate page
    call allocate_physical_page
    test eax, eax
    jz .done
    
    ; Lock page (prevent swapping)
    call lock_page
    
    ; Add to balloon page list
    mov edi, [balloon_pages]
    mov [edi], eax
    add edi, 4
    mov [balloon_pages], edi
    
    ; Notify hypervisor of page
    call hypercall_add_balloon_page
    
    loop .inflate_loop
    
.done:
    pop edi
    pop ecx
    pop ebx
    ret

; Balloon driver: deflate (get memory back from hypervisor)
balloon_deflate:
    ; Parameters: EAX = number of pages to release
    push ebx
    push ecx
    push edi
    
    mov ecx, eax
    mov edi, [balloon_pages]
    
.deflate_loop:
    ; Get page from balloon list
    sub edi, 4
    mov eax, [edi]
    
    ; Notify hypervisor
    call hypercall_remove_balloon_page
    
    ; Unlock page
    call unlock_page
    
    ; Free page
    call free_physical_page
    
    loop .deflate_loop
    
    mov [balloon_pages], edi
    
    pop edi
    pop ecx
    pop ebx
    ret
```

### Kernel Same-Page Merging (KSM)

[Inference] KSM is a memory deduplication technique that merges identical pages across different processes, marking them as copy-on-write to save physical memory.

```assembly
; Scan for mergeable pages
ksm_scan_pages:
    push ebx
    push ecx
    push esi
    push edi
    
    mov esi, [ksm_scan_position]
    mov ecx, KSM_PAGES_TO_SCAN
    
.scan_loop:
    ; Get page to scan
    call get_next_ksm_candidate
    test eax, eax
    jz .done
    
    mov edi, eax            ; Page address
    
    ; Calculate page hash
    call calculate_page_hash
    mov ebx, eax            ; Hash value
    
    ; Look for matching pages
    call find_identical_page
    test eax, eax
    jz .no_match
    
    ; Found match, merge pages
    mov eax, edi
    call merge_pages
    
.no_match:
    loop .scan_loop
    
.done:
    mov [ksm_scan_position], esi
    
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
```

**Key Points:**

- The Task State Segment stores processor state for hardware task switching and provides stack pointers for privilege level transitions, with different structures for 32-bit and 64-bit modes
- Paging translates virtual addresses to physical addresses through multi-level page tables, with the TLB caching recent translations for performance
- 32-bit protected mode uses two-level page tables (directory and table), while 64-bit long mode uses four levels (PML4, PDPT, PD, PT) to support larger address spaces
- Page table entries contain flags controlling access permissions (present, read/write, user/supervisor), caching behavior, and tracking information (accessed, dirty bits)
- Virtual memory enables process isolation, demand paging, copy-on-write optimization, and memory-mapped files through page fault handling and swap mechanisms
- Page replacement algorithms like LRU and clock determine which pages to evict when physical memory is exhausted, using accessed and dirty bits for decision-making
- Modern features include huge pages for TLB efficiency, ASLR for security, page table isolation for vulnerability mitigation, and memory protection keys for fine-grained access control
- [Inference] Advanced techniques like NUMA-aware allocation, memory ballooning for virtualization, and kernel same-page merging optimize memory usage in specialized environments

---

