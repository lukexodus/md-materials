## Memory Protection


Memory protection mechanisms enforce access control policies, preventing unauthorized access and maintaining system stability and security.

**Protection Mechanisms in x86**:

x86 provides multiple layers of memory protection:

1. **Privilege Levels**: Ring-based protection (rings 0-3)
2. **Segmentation Protection**: Segment-level access control
3. **Paging Protection**: Page-level access control
4. **Execute Disable (NX/XD)**: Prevents code execution from data pages
5. **Supervisor Mode Access Prevention (SMAP)**: Restricts kernel access to user memory
6. **Supervisor Mode Execution Prevention (SMEP)**: Prevents kernel execution of user code

### Privilege Levels (Ring Protection)

x86 defines four privilege levels (rings), with ring 0 being most privileged:

```
Ring 0: Kernel/OS (highest privilege)
Ring 1: Device drivers (rarely used in modern systems)
Ring 2: Device drivers (rarely used in modern systems)
Ring 3: User applications (lowest privilege)
```

**Current Privilege Level (CPL)**: Stored in CS register bits 1-0, indicates current execution privilege.

**Descriptor Privilege Level (DPL)**: Stored in segment descriptors and page table entries, specifies required privilege to access resource.

**Requested Privilege Level (RPL)**: Stored in segment selector bits 1-0, prevents privilege escalation through pointer passing.

**Privilege Checking Rules**:

For data segment access:

```
CPL <= DPL (numerically) AND RPL <= DPL
```

For code segment access (far call/jump):

- **Conforming code**: CPL >= DPL (can call more privileged)
- **Non-conforming code**: CPL = DPL (same privilege only)

**Example**: Privilege level transitions

```assembly
; Ring 3 to Ring 0 transition via interrupt
; User code (Ring 3)
user_code:
    mov eax, 1
    int 0x80                ; System call
    ; CPU automatically switches to Ring 0 handler
    
; Kernel handler (Ring 0)
system_call_handler:
    ; CPL now 0 (from CS register)
    ; Can access kernel data structures
    ; ...
    iret                    ; Return to Ring 3

; Attempting direct privilege escalation fails
try_escalate:
    mov ax, 0x08            ; Kernel code segment (DPL=0)
    mov cs, ax              ; FAILS: General Protection Fault
    ; Cannot directly modify CS to higher privilege
```

**Call Gates**: Controlled mechanisms for transferring control between privilege levels:

```assembly
; Call gate descriptor in GDT
call_gate_descriptor:
    dw target_offset_low    ; Offset 0-15 in target segment
    dw code_selector        ; Target code segment selector
    db param_count          ; Parameters to copy
    db 0x8C                 ; Type: 32-bit call gate, DPL=0
    dw target_offset_high   ; Offset 16-31 in target segment

; Using call gate from Ring 3
    call far [call_gate_selector:0]
    ; CPU checks privileges, copies parameters, switches to Ring 0
```

### Segmentation Protection

Segment descriptors contain protection information enforced during segment access.

**Access Rights Byte**:

```
Bit 7: Present (P) - segment present in memory
Bits 6-5: DPL - Descriptor Privilege Level (0-3)
Bit 4: S - Descriptor type (0=system, 1=code/data)
Bit 3: E - Executable (1=code, 0=data)
Bit 2: DC - Direction/Conforming
  For code: Conforming (1=can be called from lower privilege)
  For data: Direction (0=expand up, 1=expand down for stack)
Bit 1: RW - Read/Write
  For code: Readable (1=can read from code segment)
  For data: Writable (1=can write to data segment)
Bit 0: A - Accessed (set by CPU when segment accessed)
```

**Protection Violations**:

**General Protection Fault (#GP)**:

- Accessing segment beyond limit
- Writing to read-only segment
- Loading SS with non-writable segment
- Privilege violations

```assembly
; Example: Segment limit violation
segment_limit_test:
    mov ax, 0x10            ; Data segment, limit = 64KB
    mov ds, ax
    mov eax, [0x20000]      ; Access beyond 64KB limit
    ; FAULT: General Protection Fault (#GP)
```

**Segment Not Present Fault (#NP)**:

- Accessing segment with Present bit = 0
- Used for demand-loaded segments

**Stack Segment Fault (#SS)**:

- Stack operations beyond stack segment limit
- Loading invalid stack segment

### Paging Protection

Page-level protection provides fine-grained access control and is the primary protection mechanism in modern systems.

**Page-Level Protection Bits**:

**User/Supervisor (U/S) - Bit 2**:

- 0: Supervisor page (accessible only in rings 0-2)
- 1: User page (accessible from any ring)

```assembly
; Map kernel page (supervisor only)
create_kernel_page:
    mov eax, physical_addr
    or eax, 0x03            ; Present + R/W (U/S=0)
    mov [page_table_entry], eax
    
; Map user page (accessible from user mode)
create_user_page:
    mov eax, physical_addr
    or eax, 0x07            ; Present + R/W + User
    mov [page_table_entry], eax
```

**Read/Write (R/W) - Bit 1**:

- 0: Read-only page
- 1: Read/write page

Combined with U/S bit:

```
U/S=0, R/W=0: Kernel read-only
U/S=0, R/W=1: Kernel read-write
U/S=1, R/W=0: User read-only, kernel read-write (if CR0.WP=1)
U/S=1, R/W=1: User and kernel read-write
```

**Write Protection (WP) - CR0 Bit 16**:

When CR0.WP=1, supervisor mode respects R/W bit even for user pages:

```assembly
; Enable write protection
enable_wp:
    mov eax, cr0
    or eax, 0x10000         ; Set WP bit
    mov cr0, eax
    ; Now kernel cannot write to R/W=0 pages
    ret
```

This is critical for:

- Copy-on-write implementations
- Enforcing read-only memory in kernel
- Security (prevents kernel from bypassing user-space protections)

**Execute Disable (XD/NX) - Bit 63**:

Prevents instruction execution from pages marked with XD bit (requires CPU support and enabled in EFER.NXE):

```assembly
; Enable NX support (64-bit)
enable_nx:
    mov ecx, 0xC0000080     ; EFER MSR
    rdmsr
    or eax, 0x800           ; Set NXE bit (bit 11)
    wrmsr
    ret

; Mark data page non-executable
create_data_page:
    mov rax, physical_addr
    or rax, 0x07            ; Present + R/W + User
    bts rax, 63             ; Set XD bit
    mov [page_table_entry], rax
```

**Key benefit**: Prevents execution of injected code in data regions (stack, heap), mitigating buffer overflow exploits.

**Example**: Implementing execute-disable protection

```assembly
; Setup page with different permissions
setup_protected_pages:
    ; Code page: executable, read-only
    mov rax, code_physical
    or rax, 0x05            ; Present + User (R/W=0, XD=0)
    mov [code_pte], rax
    
    ; Data page: non-executable, read-write
    mov rax, data_physical
    or rax, 0x07            ; Present + R/W + User
    bts rax, 63             ; Set XD bit
    mov [data_pte], rax
    
    ; Stack page: non-executable, read-write
    mov rax, stack_physical
    or rax, 0x07
    bts rax, 63             ; Set XD bit
    mov [stack_pte], rax
    ret

; Attempt to execute from data page causes Page Fault
execute_from_data:
    call data_page_address
    ; FAULT: Page Fault with error code bit 4 set (instruction fetch)
```

### Advanced Protection Features

**Supervisor Mode Execution Prevention (SMEP) - CR4 Bit 20**:

Prevents kernel from executing code in user-space pages (ring 0 cannot execute U/S=1 pages):

```assembly
; Enable SMEP
enable_smep:
    mov eax, cr4
    or eax, 0x100000        ; Set SMEP bit (bit 20)
    mov cr4, eax
    ret
```

**Benefits**:

- Prevents kernel exploitation via user-space code injection
- Protects against privilege escalation attacks
- Forces attackers to use return-oriented programming (ROP)

**Supervisor Mode Access Prevention (SMAP) - CR4 Bit 21**:

Prevents kernel from accessing user-space pages unless explicitly allowed:

```assembly
; Enable SMAP
enable_smap:
    mov eax, cr4
    or eax, 0x200000        ; Set SMAP bit (bit 21)
    mov cr4, eax
    ret

; Temporarily allow user access in kernel
access_user_memory:
    stac                    ; Set AC flag (allow access)
    mov eax, [user_buffer]  ; Access user memory
    clac                    ; Clear AC flag (prevent access)
    ret
```

**STAC/CLAC instructions**:

- STAC: Set AC flag in RFLAGS, temporarily disable SMAP
- CLAC: Clear AC flag, re-enable SMAP

**Benefits**:

- Prevents kernel from accidentally dereferencing user pointers
- Mitigates kernel vulnerabilities that rely on user-supplied addresses
- Forces explicit verification of user pointers

**Protection Keys (PKU/PKEY) - CR4 Bit 22**:

Provides user-space memory protection domains (16 domains, 4 bits per page):

```assembly
; Enable protection keys
enable_pku:
    mov eax, cr4
    or eax, 0x400000        ; Set PKE bit (bit 22)
    mov cr4, eax
    ret

; Set protection key for page (bits 62-59 in PTE)
set_page_pkey:
    mov rax, [page_table_entry]
    and rax, ~(0xF << 59)   ; Clear existing key
    or rax, (5 << 59)       ; Set key = 5
    mov [page_table_entry], rax
    ret

; Configure access rights for protection keys (PKRU register)
configure_pkey_rights:
    xor ecx, ecx            ; PKRU register
    xor edx, edx
    mov eax, 0x00000030     ; Disable access and write for key 5
    ; Bits: [key_5_write_disable=1][key_5_access_disable=1]
    wrpkru
    ret
```

**Memory Protection Keys (MPK)** allow:

- Fast permission changes without TLB flushes
- User-space memory isolation within single address space
- Fine-grained memory protection for security-critical data

### Page Fault Handling and Protection

Page faults occur when protection is violated or pages are not present. The error code identifies the fault type:

**Page Fault Error Code Format**:

```
Bit 4 (I/D): Instruction fetch (1) or data access (0)
Bit 3 (RSVD): Reserved bit violation
Bit 2 (U/S): User mode (1) or supervisor mode (0)
Bit 1 (W/R): Write (1) or read (0)
Bit 0 (P): Page not present (0) or protection violation (1)
```

**Example**: Page fault handler with protection checking

```assembly
page_fault_handler:
    push eax
    push ebx
    
    ; Get error code (pushed by CPU)
    mov eax, [esp + 12]     ; Error code location
    mov ebx, cr2            ; Faulting address
    
    ; Check if present
    test eax, 1
    jz .not_present
    
    ; Protection violation
    test eax, 2             ; Write access?
    jz .read_violation
    
.write_violation:
    test eax, 4             ; User mode?
    jnz .user_write_violation
    
.kernel_write_violation:
    ; Kernel attempted to write read-only page
    ; Could be copy-on-write or actual error
    call handle_kernel_write_fault
    jmp .done
    
.user_write_violation:
    ; User attempted to write read-only/kernel page
    call handle_user_write_fault
    jmp .done
    
.read_violation:
    test eax, 4
    jnz .user_read_violation
    
.kernel_read_violation:
    ; Kernel read from inaccessible page (rare)
    call handle_kernel_read_fault
    jmp .done
    
.user_read_violation:
    ; User attempted to read kernel page
    call handle_user_read_fault
    jmp .done
    
.not_present:
    ; Page not present - demand paging
    test eax, 16            ; Instruction fetch?
    jnz .execute_not_present
    
    call handle_page_not_present
    jmp .done
    
.execute_not_present:
    ; Instruction fetch from non-executable page
    test eax, 1
    jz .demand_page_code
    
    ; Tried to execute from NX page
    call handle_execute_violation
    
.demand_page_code:
    call handle_code_page_fault
    
.done:
    pop ebx
    pop eax
    add esp, 4              ; Remove error code
    iret

handle_user_write_fault:
    ; Log violation
    ; Terminate process or deliver SIGSEGV signal
    ; [Inference: Typical OS response to protection violation]
    ret
```

### Copy-on-Write (COW) Implementation

Copy-on-write uses page protection to defer copying until necessary:

```assembly
; Setup COW mapping (mark both parent and child pages read-only)
setup_cow_page:
    ; Original page PTE
    mov eax, [parent_pte]
    and eax, ~2             ; Clear R/W bit (make read-only)
    mov [parent_pte], eax
    mov [child_pte], eax    ; Both point to same physical page
    
    ; Increment page reference count
    inc dword [page_refcount]
    
    ; Invalidate TLB
    invlpg [page_virtual_addr]
    ret

; Page fault handler for COW
cow_page_fault_handler:
    mov eax, [esp + 12]     ; Error code
    test eax, 2             ; Write access?
    jz .not_cow
    test eax, 1             ; Page present?
    jz .not_cow
    
    ; Check if page is COW (reference count > 1)
    mov ebx, cr2            ; Faulting address
    call get_page_refcount
    cmp eax, 1
    jle .not_cow
    
    ; Perform COW
    call allocate_new_page  ; Get new physical page
    mov edi, eax            ; New page physical address
    
    ; Copy old page content
    mov esi, [old_page_physical]
    mov ecx, 4096 / 4
    rep movsd
    
    ; Update PTE with new page, make writable
    mov eax, edi
    or eax, 0x07            ; Present + R/W + User
    mov [faulting_pte], eax
    
    ; Decrement old page reference count
    dec dword [old_page_refcount]
    
    ; Invalidate TLB
    invlpg [ebx]
    jmp .done
    
.not_cow:
    ; Real protection violation
    call handle_protection_violation
    
.done:
    ; Return from page fault
    ; Instruction will be retried with writable page
    pop ebx
    pop eax
    add esp, 4
    iret
```

### Memory Protection in Practice

**Kernel vs User Space Separation**:

```assembly
; Typical memory layout with protection
; 0x00000000 - 0x7FFFFFFF: User space (U/S=1)
; 0x80000000 - 0xFFFFFFFF: Kernel space (U/S=0)

; Map user code segment
map_user_code:
    mov edi, user_code_pt
    mov eax, user_code_physical
    or eax, 0x05            ; Present + User (R/W=0 for code)
    mov ecx, user_code_pages
.loop:
    stosd
    add eax, 0x1000
    loop .loop
    ret

; Map kernel data segment
map_kernel_data:
    mov edi, kernel_data_pt
    mov eax, kernel_data_physical
    or eax, 0x03            ; Present + R/W (U/S=0 for kernel)
    mov ecx, kernel_data_pages
.loop:
    stosd
    add eax, 0x1000
    loop .loop
    ret
```

**Stack Protection**:

```assembly
; Allocate stack with guard page
allocate_protected_stack:
    ; Allocate stack pages (e.g., 16KB = 4 pages)
    call allocate_pages
    mov ebx, eax            ; Stack base
    
    ; Map stack pages (top 3 pages)
    mov edi, stack_page_table
    mov eax, ebx
    add eax, 0x1000         ; Skip guard page
    or eax, 0x07            ; Present + R/W + User
    mov ecx, 3
.map_stack:
    stosd
    add eax, 0x1000
    loop .map_stack
    
    ; Guard page (bottom page) - not present
    mov eax, ebx
    and eax, ~1             ; Clear present bit
    mov [stack_guard_pte], eax
    
    ; Stack overflow causes page fault on guard page
    ret
```

**Executable Space Protection**:

```assembly
; Modern executable layout with NX
setup_process_memory:
    ; Code: executable, read-only
    call map_code_segment   ; XD=0, R/W=0
    
    ; Read-only data: non-executable, read-only
    call map_rodata_segment ; XD=1, R/W=0
    
    ; Data: non-executable, read-write
    call map_data_segment   ; XD=1, R/W=1
    
    ; Heap: non-executable, read-write
    call map_heap_segment   ; XD=1, R/W=1
    
    ; Stack: non-executable, read-write
    call map_stack_segment  ; XD=1, R/W=1
    ret
```

**Key Points**:

- Privilege levels provide coarse-grained ring-based protection
- Segmentation protection is legacy, mostly replaced by paging in modern systems
- Paging provides fine-grained per-page access control
- U/S bit separates kernel and user space
- R/W bit controls write permissions
- XD/NX bit prevents code execution, critical for security
- CR0.WP forces kernel to respect read-only pages
- SMEP prevents kernel from executing user code
- SMAP prevents kernel from accessing user memory without explicit permission
- Protection keys enable fast user-space memory isolation
- Page faults deliver protection violations to operating system
- Copy-on-write uses protection mechanisms for efficient memory sharing
- Guard pages detect stack overflows
- All modern systems use NX to implement W^X (write xor execute) policy
- Protection violations generate page faults with detailed error codes
- Proper protection setup is critical for system security and stability

**Related Topics for Further Study**: Virtual memory management algorithms, Demand paging and page replacement, Process address space layout, Memory-mapped I/O and device memory protection, Security mitigations (ASLR, DEP, CFI), Virtualization and Extended Page Tables (EPT), Memory management in multi-core systems

---

