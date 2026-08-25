## Overview

cl /DYNAMICBASE program.c
```

**Related topics:** Position-independent code (PIC/PIE), ASLR (Address Space Layout Randomization), GOT/PLT internals, lazy vs eager binding, symbol interposition/hooking, library search paths, SONAME versioning, weak symbols, hidden visibility, export maps, dynamic loader internals (ld.so, dyld), DLL injection, code signing, secure boot, address sanitizers, debugger interaction with dynamic linker

---

# Code Injection and Patching

Code injection and patching involve modifying or extending existing executable code at runtime or before execution. These techniques enable debugging, instrumentation, security research, game modding, and malware analysis, though they can also be misused for malicious purposes.

## Hot Patching Techniques

Hot patching modifies running code without restarting the process. This requires careful attention to instruction boundaries, atomicity, and thread safety.

### Basic Hot Patching Principles

**Instruction Atomicity**:

On x86/x64, certain write operations are atomic and can safely patch running code:

```asm
; Single-byte patch (atomic on x86)
mov byte [target_addr], 0xC3    ; Replace with 'ret'

; Multi-byte patch (NOT atomic)
mov dword [target_addr], 0x90909090  ; Four NOPs
; Risk: Another thread may execute during partial write
```

**Key Points:**

- Single-byte writes are atomic on aligned addresses
- Multi-byte modifications require synchronization
- Instruction cache coherency must be maintained
- Self-modifying code may require cache flushes

**Minimal Patch Patterns**:

**Short Jump Patch (2 bytes)**:

```asm
; Original code at 0x401000:
original_instruction:
    push ebp
    mov ebp, esp
    ; ...

; Patch with short jump (offset -128 to +127)
patch_short_jump:
    db 0xEB         ; JMP short
    db offset       ; relative offset (1 byte)
    ; Original code after patch point must be preserved
```

**Near Jump Patch (5 bytes)**:

```asm
; Patch with near jump
patch_near_jump:
    db 0xE9         ; JMP near
    dd offset       ; relative offset (4 bytes)
    ; Remaining bytes of original instruction become NOPs or preserved
```

**Key Points:**

- 5-byte patch is the standard for x86/x64 hot patching
- Relative jump offset = (destination - (current_addr + 5))
- Must not split multi-byte instructions

**Return Address Modification**:

```asm
; Modify return address on stack to redirect execution
push rax
mov rax, [rsp + 8]      ; Get return address
; Analyze or modify return address
mov [rsp + 8], new_addr ; Replace with patched destination
pop rax
ret                      ; Returns to new_addr
```

### Microsoft Hot Patching

Windows supports structured hot patching for security updates:

```asm
; Function prologue prepared for hot patching
; Function begins at +5 bytes from actual entry
function_entry_minus_5:
    mov edi, edi        ; 2-byte instruction (hot patch point)
    push ebp            ; Standard prologue
    mov ebp, esp
    ; Function body...

; When patched:
patch_applied:
    jmp patch_function  ; 5-byte jump backwards to -5 position
    ; Original 2-byte mov edi, edi is overwritten with short jmp
    ; The 5 bytes before function are replaced with long jmp to patch
```

**Key Points:**

- Functions compiled with `/hotpatch` reserve 5 bytes before entry
- Initial 2-byte mov edi,edi is patchable without affecting function
- Allows atomic patching through coordinated jump installation
- Patch function can execute original code via trampoline

### Inline Hook Installation

**Basic Inline Hook**:

```asm
; Original function at target_addr:
original_function:
    push ebp
    mov ebp, esp
    sub esp, 0x20
    ; ... more code

; Allocate trampoline (stores original bytes + jump back)
trampoline:
    push ebp            ; Original bytes copied here
    mov ebp, esp
    sub esp, 0x20
    jmp original_function + 8  ; Jump past hook

; Install hook (5-byte patch)
install_hook:
    ; Save original bytes
    mov rsi, target_addr
    mov rdi, trampoline
    mov ecx, 5
    rep movsb
    
    ; Calculate relative offset
    mov eax, hook_function
    sub eax, target_addr
    sub eax, 5
    
    ; Write jump (ensure atomic if threads running)
    mov byte [target_addr], 0xE9
    mov dword [target_addr + 1], eax
```

**Hook Function**:

```asm
hook_function:
    ; Preserve all registers
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push rbp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
    pushfq
    
    ; Custom code execution
    ; Can examine/modify arguments on stack
    
    ; Restore registers
    popfq
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rbp
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    
    ; Execute original code via trampoline
    jmp trampoline
```

**Key Points:**

- Trampoline preserves original function behavior
- Hook function must preserve all registers and flags
- Original bytes must be copied before overwriting
- Return path must account for modified instruction flow

### Thread-Safe Hot Patching

**Suspend-Patch-Resume Method**:

```asm
; Pseudocode showing thread suspension approach
suspend_all_threads:
    ; Enumerate all threads in process
    ; Suspend each thread except current
    
apply_patch:
    ; Ensure no thread executing target code
    check_thread_contexts:
        ; Verify no thread IP points to patch region
        ; If any thread in range, wait or relocate
    
    ; Apply patch atomically
    mov byte [target], 0xE9
    mov dword [target+1], offset
    
    ; Flush instruction cache
    ; Windows: FlushInstructionCache
    ; Linux: __builtin___clear_cache or explicit flush
    
resume_all_threads:
    ; Resume suspended threads
```

**Atomic Multi-Byte Patching**:

```asm
; Method: Use single-byte atomic write as commit
prepare_patch:
    ; Write last 4 bytes of 5-byte jump first
    mov dword [target + 1], offset_value
    
    ; Memory barrier to ensure ordering
    mfence
    
    ; Atomic commit: write first byte
    mov byte [target], 0xE9     ; JMP opcode
    
    ; Now patch is active
```

**Key Points:**

- Write order matters to maintain validity
- First byte should be written last as atomic commit
- Memory barriers prevent reordering
- x86 guarantees cache coherency across cores

### Hardware Breakpoint Hooking

Uses debug registers instead of code modification:

```asm
; Set hardware breakpoint via debug registers
; DR0-DR3 hold breakpoint addresses
; DR7 controls breakpoint conditions

set_hw_breakpoint:
    ; Set breakpoint address
    mov dr0, target_addr
    
    ; Configure DR7
    ; Bits 0-1: Enable DR0 (local/global)
    ; Bits 16-17: Condition (00=exec, 01=write, 11=read/write)
    ; Bits 18-19: Size (00=1byte, 01=2bytes, 11=4bytes)
    mov rax, 1              ; Enable local DR0
    or rax, (0 << 16)       ; Execution breakpoint
    or rax, (0 << 18)       ; 1-byte size
    mov dr7, rax

; Exception handler receives control on breakpoint
exception_handler:
    ; Check if DR6 indicates which breakpoint fired
    mov rax, dr6
    test rax, 1             ; Check B0 bit
    jz not_our_breakpoint
    
    ; Execute hook logic
    ; ...
    
    ; Clear breakpoint status
    and rax, ~1
    mov dr6, rax
    
    ; Adjust RIP to skip instruction or continue
    ; Return from exception
```

**Key Points:**

- Limited to 4 breakpoints (DR0-DR3)
- No code modification required
- Causes debug exception (requires exception handler)
- Can detect execution, read, or write access
- Requires appropriate privileges to set debug registers

### Return-Oriented Programming (ROP) for Patching

**[Inference]** While ROP is typically associated with exploitation, it can be used for legitimate runtime code modification by chaining existing code sequences:

```asm
; Stack prepared with sequence of return addresses
; Each points to a "gadget" (existing code ending in ret)

setup_rop_chain:
    ; Overwrite return address or stack region
    mov rdi, stack_location
    mov rsi, gadget1_addr
    mov [rdi], rsi
    add rdi, 8
    mov rsi, gadget2_addr
    mov [rdi], rsi
    add rdi, 8
    ; Continue building chain...

; Example gadgets from existing code:
gadget1:    ; pop rdi; ret
    pop rdi
    ret

gadget2:    ; pop rsi; ret  
    pop rsi
    ret

gadget3:    ; mov [rdi], rsi; ret
    mov [rdi], rsi
    ret
```

**Key Points:**

- Uses existing code to avoid executable memory allocation
- Bypasses DEP/NX protections
- More complex than direct patching
- Useful when code modification is prevented

### Position-Independent Code (PIC) Patching

When patching position-independent code:

```asm
; Original PIC code using RIP-relative addressing
original_pic:
    lea rax, [rip + data]   ; RIP-relative
    mov rbx, [rax]
    ret

; Patch must maintain PIC property
; Calculate new offsets
patch_pic:
    ; If inserting jump, ensure target uses PIC
    ; Use RIP-relative jumps
    lea rax, [rip + hook_function]
    jmp rax

hook_function:
    ; Hook code also PIC
    lea rdi, [rip + hook_data]
    ; ... hook logic
    lea rax, [rip + original_function]
    jmp rax
```

**Key Points:**

- Must preserve RIP-relative addressing
- Cannot use absolute addresses in shared libraries
- Offsets must be recalculated for new code location
- Essential for patching shared libraries

## Code Caves

Code caves are unused memory regions within executables where injected code can be placed. These regions may be padding, unused space, or newly allocated memory.

### Finding Code Caves

**Examining PE/ELF Sections**:

```asm
; Common locations for code caves:
; - Padding between sections
; - End of last section
; - Unused code sections (.text section padding)
; - Data sections if marked executable

; PE file structure considerations:
; Section alignment typically 0x1000 (4KB)
; File alignment typically 0x200 (512 bytes)
; Gap between FileSize and VirtualSize

search_code_cave:
    ; Load PE headers
    mov rax, [image_base]
    mov ebx, [rax + 0x3C]       ; e_lfanew (PE offset)
    add rbx, rax                 ; RBX = PE header
    
    ; Get section count
    movzx ecx, word [rbx + 0x6] ; NumberOfSections
    lea rsi, [rbx + 0xF8]       ; First section header (x64)
    
find_cave_loop:
    ; Check VirtualSize vs SizeOfRawData
    mov eax, [rsi + 0x08]       ; VirtualSize
    mov edx, [rsi + 0x10]       ; SizeOfRawData
    cmp eax, edx
    jle next_section
    
    ; Found potential cave
    sub eax, edx                 ; Cave size
    cmp eax, required_size
    jge cave_found
    
next_section:
    add rsi, 0x28                ; sizeof(IMAGE_SECTION_HEADER)
    loop find_cave_loop
    
cave_found:
    ; Calculate cave address
    mov eax, [rsi + 0x0C]       ; VirtualAddress
    add rax, [image_base]
    add rax, edx                 ; Add SizeOfRawData
    ; RAX now points to code cave
```

**NOP Sleds in Executables**:

Some executables contain long sequences of NOPs that can be repurposed:

```asm
; Search for NOP sequences
find_nop_sled:
    mov rdi, search_start
    mov ecx, search_length
    
scan_loop:
    cmp byte [rdi], 0x90        ; NOP
    jne not_nop
    
    ; Count consecutive NOPs
    push rdi
    push rcx
    xor eax, eax
count_nops:
    cmp byte [rdi], 0x90
    jne done_counting
    inc eax
    inc rdi
    loop count_nops
    
done_counting:
    pop rcx
    pop rdi
    
    cmp eax, minimum_cave_size
    jge found_cave
    
not_nop:
    inc rdi
    loop scan_loop
```

**Key Points:**

- Code caves must be executable (check section permissions)
- Size must accommodate injected code plus any trampolines
- Location affects relative jump distances
- May need to mark memory as executable if not already

### Using Code Caves

**Redirecting Execution to Cave**:

```asm
; Original code location
original_code:
    mov eax, [rbx + 0x10]
    test eax, eax
    jz error_path
    ; ... more code

; Install jump to code cave
install_cave_redirect:
    ; Calculate relative offset
    mov rax, code_cave_addr
    sub rax, original_code
    sub rax, 5
    
    ; Write jump
    mov byte [original_code], 0xE9
    mov dword [original_code + 1], eax

; Code cave contents
code_cave:
    ; Custom functionality
    push rax
    push rbx
    ; ... hook code
    pop rbx
    pop rax
    
    ; Execute replaced original instructions
    mov eax, [rbx + 0x10]
    test eax, eax
    jz error_path
    
    ; Jump back past patch
    jmp original_code + 5
```

**Expanding Functionality**:

```asm
; Use cave to add extensive new features
code_cave_extended:
    ; Save all registers
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push rbp
    push r8
    push r9
    push r10
    push r11
    
    ; New functionality with many instructions
    ; Can implement complex logic here
    mov rdi, [rbx + 0x10]
    test rdi, rdi
    jz skip_processing
    
    ; Call to logging function
    call log_function
    
    ; Additional validation
    cmp rax, expected_value
    jne validation_failed
    
skip_processing:
    ; Restore registers
    pop r11
    pop r10
    pop r9
    pop r8
    pop rbp
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    
    ; Original instruction(s)
    mov eax, [rbx + 0x10]
    
    ; Return to original flow
    jmp return_address

validation_failed:
    ; Error handling
    xor eax, eax
    ; Restore and return
    ; ...
```

**Key Points:**

- Code caves allow complex modifications without allocating new memory
- Must preserve all registers unless intentionally modifying
- Can chain multiple caves for large injections
- Return path must account for original instruction replacement

### Expanding Sections

When no suitable cave exists, expand executable sections:

```asm
; Expanding last section (requires file patching)
; Modify PE header to increase section size

expand_section:
    ; Load section header
    mov rax, last_section_header
    
    ; Increase VirtualSize
    mov ebx, [rax + 0x08]       ; Current VirtualSize
    add ebx, expansion_size
    mov [rax + 0x08], ebx       ; Update VirtualSize
    
    ; Increase SizeOfRawData (must align to FileAlignment)
    mov ecx, [rax + 0x10]       ; Current SizeOfRawData
    add ecx, expansion_size
    ; Align to FileAlignment (typically 0x200)
    add ecx, 0x1FF
    and ecx, ~0x1FF
    mov [rax + 0x10], ecx       ; Update SizeOfRawData
    
    ; Update SizeOfImage in PE header
    mov rax, pe_header
    mov ebx, [rax + 0x50]       ; SizeOfImage
    add ebx, expansion_size
    ; Align to SectionAlignment (typically 0x1000)
    add ebx, 0xFFF
    and ebx, ~0xFFF
    mov [rax + 0x50], ebx
```

**Key Points:**

- Requires modifying file on disk before loading
- Must maintain alignment requirements
- Need to update multiple PE/ELF header fields
- Expanded region initially contains zeros

### Creating New Sections

Add entirely new sections to executables:

```asm
; Adding new section to PE file
add_section:
    ; Find location for new section header
    mov rax, pe_header
    movzx ecx, word [rax + 0x06]    ; NumberOfSections
    lea rbx, [rax + 0xF8]            ; First section header
    imul edx, ecx, 0x28              ; Size of section headers
    add rbx, rdx                      ; RBX = new section header location
    
    ; Fill section header
    ; Name (.inject, padded with zeros)
    mov dword [rbx + 0x00], '.inj'
    mov dword [rbx + 0x04], 'ect'
    
    ; VirtualSize
    mov dword [rbx + 0x08], section_size
    
    ; VirtualAddress (after last section)
    mov eax, [rbx - 0x28 + 0x0C]    ; Previous section VirtualAddress
    add eax, [rbx - 0x28 + 0x08]    ; Plus VirtualSize
    add eax, 0xFFF
    and eax, ~0xFFF                  ; Align
    mov [rbx + 0x0C], eax
    
    ; SizeOfRawData
    mov eax, section_size
    add eax, 0x1FF
    and eax, ~0x1FF                  ; Align to FileAlignment
    mov [rbx + 0x10], eax
    
    ; PointerToRawData
    mov eax, [rbx - 0x28 + 0x14]    ; Previous PointerToRawData
    add eax, [rbx - 0x28 + 0x10]    ; Plus SizeOfRawData
    mov [rbx + 0x14], eax
    
    ; Characteristics (CODE | EXECUTE | READ)
    mov dword [rbx + 0x24], 0x60000020
    
    ; Increment NumberOfSections
    inc word [rax + 0x06]
    
    ; Update SizeOfImage
    mov ebx, [rbx + 0x0C]           ; New section VirtualAddress
    add ebx, [rbx + 0x08]           ; Plus VirtualSize
    add ebx, 0xFFF
    and ebx, ~0xFFF
    mov [rax + 0x50], ebx
```

**Key Points:**

- Requires file modification before execution
- Must update multiple header fields
- Section characteristics control permissions
- New section automatically mapped at load time

### Memory Allocation for Caves

At runtime, allocate new executable memory:

```asm
; Linux: mmap for executable memory
allocate_cave_linux:
    mov rax, 9                  ; sys_mmap
    xor rdi, rdi                ; addr (NULL = kernel chooses)
    mov rsi, cave_size          ; length
    mov rdx, 7                  ; PROT_READ | PROT_WRITE | PROT_EXEC
    mov r10, 34                 ; MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1                  ; fd (ignored)
    xor r9, r9                  ; offset
    syscall
    ; RAX = address of new cave

; Windows: VirtualAlloc
allocate_cave_windows:
    ; Using direct syscall (example)
    ; Or call VirtualAlloc via imports
    sub rsp, 0x28               ; Shadow space + alignment
    xor rcx, rcx                ; lpAddress (NULL)
    mov rdx, cave_size          ; dwSize
    mov r8d, 0x1000             ; MEM_COMMIT
    mov r9d, 0x40               ; PAGE_EXECUTE_READWRITE
    call [VirtualAlloc]
    add rsp, 0x28
    ; RAX = address of new cave
```

**Key Points:**

- Allocated memory can be far from original code (affects jump distances)
- May require indirect jumps or trampolines
- Memory permissions must include execute
- Should deallocate when done (mprotect or VirtualFree)

## Import Address Table (IAT) Hooking

IAT hooking redirects function calls by modifying the Import Address Table, which contains pointers to imported functions from DLLs.

### IAT Structure

**PE Import Directory**:

```asm
; Import descriptor structure
struc IMAGE_IMPORT_DESCRIPTOR
    .OriginalFirstThunk:    resd 1  ; RVA to INT
    .TimeDateStamp:         resd 1
    .ForwarderChain:        resd 1
    .Name:                  resd 1  ; RVA to DLL name
    .FirstThunk:            resd 1  ; RVA to IAT
endstruc

; Import Name Table (INT) and Import Address Table (IAT)
; INT contains import information (original)
; IAT contains actual function addresses (modified at load)
```

**Locating IAT**:

```asm
locate_iat:
    ; Get image base
    mov rax, [gs:0x60]          ; PEB (x64 Windows)
    mov rax, [rax + 0x10]       ; ImageBaseAddress
    
    ; Get PE header
    mov ebx, [rax + 0x3C]       ; e_lfanew
    add rbx, rax                 ; RBX = PE header
    
    ; Get import directory RVA
    mov edx, [rbx + 0x90]       ; Import Directory RVA (x64)
    test edx, edx
    jz no_imports
    
    add rdx, rax                 ; RDX = Import directory
    
    ; Iterate import descriptors
parse_imports:
    mov ecx, [rdx + IMAGE_IMPORT_DESCRIPTOR.Name]
    test ecx, ecx
    jz done_imports              ; NULL entry = end
    
    ; Get DLL name
    add rcx, rax
    ; Compare against target DLL (e.g., "kernel32.dll")
    
    ; Get IAT
    mov edi, [rdx + IMAGE_IMPORT_DESCRIPTOR.FirstThunk]
    add rdi, rax                 ; RDI = IAT
    
    ; Iterate IAT entries
    mov esi, [rdx + IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk]
    add rsi, rax                 ; RSI = INT
    
next_import:
    mov rbx, [rsi]
    test rbx, rbx
    jz next_descriptor
    
    ; Check if import by name (bit 63 clear) or ordinal
    test rbx, 0x8000000000000000
    jnz import_by_ordinal
    
    ; Get name
    add rbx, rax
    add rbx, 2                   ; Skip hint
    ; RBX points to function name string
    
    ; Compare against target function
    ; If match, RDI points to function pointer in IAT
    
import_by_ordinal:
    add rsi, 8
    add rdi, 8
    jmp next_import
    
next_descriptor:
    add rdx, IMAGE_IMPORT_DESCRIPTOR_size
    jmp parse_imports
    
done_imports:
    ; Found target function in IAT at RDI
```

**Key Points:**

- IAT contains actual function addresses after loader resolution
- Multiple imports may exist for same DLL
- Import can be by name or ordinal
- IAT is in a readable/writable section

### Installing IAT Hook

**Basic IAT Hook**:

```asm
install_iat_hook:
    ; RDI points to IAT entry for target function
    ; Save original function pointer
    mov rax, [rdi]
    mov [original_function_ptr], rax
    
    ; Change memory protection to writable
    ; Windows: VirtualProtect
    ; Linux: mprotect
    
    ; Windows approach:
    sub rsp, 0x28
    mov rcx, rdi                ; lpAddress
    mov rdx, 8                  ; dwSize
    mov r8d, 0x04               ; PAGE_READWRITE
    lea r9, [old_protect]       ; lpflOldProtect
    call [VirtualProtect]
    
    ; Write hook function address
    mov rax, hook_function
    mov [rdi], rax
    
    ; Restore protection
    mov rcx, rdi
    mov rdx, 8
    mov r8d, [old_protect]
    lea r9, [old_protect]
    call [VirtualProtect]
    add rsp, 0x28
```

**Hook Function Template**:

```asm
hook_function:
    ; Preserve registers
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push rbp
    push r8
    push r9
    push r10
    push r11
    
    ; Parameters already in registers per calling convention
    ; RCX = first parameter (x64 Windows)
    ; RDX = second parameter
    ; R8 = third parameter
    ; R9 = fourth parameter
    
    ; Custom hook logic
    ; Can examine/modify parameters
    ; Can log calls, filter arguments, etc.
    
    ; Example: Log function call
    ; mov rdi, log_message
    ; call log_function
    
    ; Restore registers
    pop r11
    pop r10
    pop r9
    pop r8
    pop rbp
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    
    ; Call original function
    jmp [original_function_ptr]
    
    ; Alternative: Call original and post-process result
    ; call [original_function_ptr]
    ; Custom post-processing
    ; ret
```

**Key Points:**

- Must preserve calling convention
- Parameters already in correct registers/stack positions
- Can call original function before or after custom logic
- Return value in RAX must be preserved unless intentionally changed

### Hooking Specific Functions

**Example: Hooking WriteFile**:

```asm
; Find WriteFile in kernel32.dll IAT
find_writefile:
    ; ... IAT traversal code ...
    ; When found, RDI points to WriteFile IAT entry
    
    ; Install hook
    mov rax, [rdi]
    mov [original_WriteFile], rax
    mov qword [rdi], WriteFile_hook

WriteFile_hook:
    ; Windows x64 calling convention
    ; RCX = HANDLE hFile
    ; RDX = LPCVOID lpBuffer
    ; R8 = DWORD nNumberOfBytesToWrite
    ; R9 = LPDWORD lpNumberOfBytesWritten
    ; Stack: lpOverlapped
    
    push rbp
    mov rbp, rsp
    sub rsp, 0x30
    
    ; Save parameters
    mov [rbp - 0x08], rcx
    mov [rbp - 0x10], rdx
    mov [rbp - 0x18], r8
    mov [rbp - 0x20], r9
    
    ; Examine buffer contents
    mov rdi, rdx
    mov rsi, r8
    ; Can scan for sensitive data, log output, etc.
    
    ; Restore parameters
    mov rcx, [rbp - 0x08]
    mov rdx, [rbp - 0x10]
    mov r8, [rbp - 0x18]
    mov r9, [rbp - 0x20]
    
    add rsp, 0x30
    pop rbp
    
    ; Call original
    jmp [original_WriteFile]
```

**Example: Hooking malloc (libc)**:

```asm
; Linux: Hook malloc from libc
find_malloc_iat:
    ; Parse ELF GOT (Global Offset Table)
    ; Similar to IAT in PE files
    
    ; ... GOT traversal ...
    
    mov rax, [malloc_got_entry]
    mov [original_malloc], rax
    mov qword [malloc_got_entry], malloc_hook

malloc_hook:
    ; System V AMD64 ABI
    ; RDI = size_t size
    
    push rbp
    mov rbp, rsp
    push rdi
    
    ; Log allocation request
    mov rsi, rdi                ; size parameter
    lea rdi, [malloc_log_msg]
    xor eax, eax
    call printf
    
    pop rdi
    
    ; Call original malloc
    call [original_malloc]
    
    ; Post-process: log returned address
    push rax
    mov rsi, rax
    lea rdi, [malloc_result_msg]
    xor eax, eax
    call printf
    pop rax
    
    leave
    ret
```

**Key Points:**

- Different calling conventions on Windows vs Linux
- Must respect calling convention precisely
- Can intercept both input parameters and return values
- Stack alignment requirements must be maintained

### IAT vs Inline Hooking Comparison

**IAT Hooking Advantages**:

- No code modification required (only data)
- Easier to install and remove
- No instruction boundary concerns
- Works for all calls through IAT

**IAT Hooking Limitations**:

- Only affects imported functions
- Doesn't catch direct calls or dynamic loading
- Doesn't affect calls within same module
- Easy to detect (IAT can be scanned)

**Inline Hooking Advantages**:

- Catches all calls to function
- Works for internal functions
- Harder to bypass

**Inline Hooking Limitations**:

- Requires code modification
- More complex installation
- Instruction boundary issues
- Thread safety concerns

### Delayed Import Hooking

Some executables use delay-loaded imports:

```asm
; Delay import descriptor
struc IMAGE_DELAYLOAD_DESCRIPTOR
    .Attributes:            resd 1
    .DllNameRVA:           resd 1
    .ModuleHandleRVA:      resd 1
    .DelayIAT_RVA:         resd 1
    .DelayINT_RVA:         resd 1
    .BoundDelayImportTable: resd 1
    .UnloadDelayImportTable: resd 1
    .TimeStamp:            resd 1
endstruc

hook_delay_import:
    ; Locate delay import directory
    mov rax, [image_base]
    mov ebx, [rax + 0x3C]
    add rbx, rax
    mov edx, [rbx + 0xE0]       ; Delay Import Descriptor RVA
    test edx, edx
    jz no_delay_imports
    
    add rdx, rax
    
    ; Iterate delay import descriptors
    ; Similar to regular imports but different structure
    ;

parse_delay_imports:
    mov ecx, [rdx + IMAGE_DELAYLOAD_DESCRIPTOR.DllNameRVA]
    test ecx, ecx
    jz done_delay_imports
    
    ; Get DLL name
    add rcx, rax
    ; Compare against target DLL
    
    ; Get delay IAT
    mov edi, [rdx + IMAGE_DELAYLOAD_DESCRIPTOR.DelayIAT_RVA]
    test edi, edi
    jz next_delay_descriptor
    add rdi, rax                ; RDI = Delay IAT
    
    ; Get delay INT
    mov esi, [rdx + IMAGE_DELAYLOAD_DESCRIPTOR.DelayINT_RVA]
    add rsi, rax                ; RSI = Delay INT
    
iterate_delay_iat:
    mov rbx, [rsi]
    test rbx, rbx
    jz next_delay_descriptor
    
    ; Check if already loaded
    mov rcx, [rdi]
    test rcx, rcx
    jz not_yet_loaded
    
    ; Function already loaded, hook like normal IAT
    ; Save original
    mov [original_function_ptr], rcx
    
    ; Change protection and write hook
    ; ... protection change code ...
    mov qword [rdi], hook_function
    
not_yet_loaded:
    ; If not loaded, hook the delay load helper instead
    ; The delay load helper will be called first time function is used
    
    add rsi, 8
    add rdi, 8
    jmp iterate_delay_iat
    
next_delay_descriptor:
    add rdx, IMAGE_DELAYLOAD_DESCRIPTOR_size
    jmp parse_delay_imports
    
done_delay_imports:
    ; Completed
```

**Delay Load Helper Hook**:

```asm
; Hook the delay load helper function itself
; This catches all delay-loaded functions at load time

original_delay_helper: dq 0

delay_load_helper_hook:
    push rbp
    mov rbp, rsp
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11
    
    ; RCX = delay import descriptor
    ; RDX = thunk address (where to write resolved address)
    
    ; Save parameters
    mov [rbp - 0x10], rcx
    mov [rbp - 0x18], rdx
    
    ; Call original helper to resolve function
    call [original_delay_helper]
    
    ; RAX now contains resolved function address
    mov rbx, rax                ; Save resolved address
    
    ; Retrieve thunk address
    mov rdx, [rbp - 0x18]
    
    ; Check if this is a function we want to hook
    ; Compare against target function names/addresses
    
    ; If match, replace with hook instead of original
    cmp rbx, target_function_addr
    jne not_target
    
    mov rbx, hook_function      ; Replace with hook
    mov [original_function_ptr], rax  ; Save real address
    
not_target:
    ; Write resolved (or hooked) address to thunk
    mov [rdx], rbx
    mov rax, rbx                ; Return resolved address
    
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    add rsp, 8                  ; Skip saved RAX
    pop rbp
    ret
```

**Key Points:**

- Delay-loaded functions not resolved until first call
- Must either hook delay helper or check IAT periodically
- Delay IAT initially contains loader helper addresses
- After loading, delay IAT contains actual function addresses

### ELF Global Offset Table (GOT) Hooking

Linux ELF equivalent to IAT hooking:

```asm
; Parse ELF to find GOT
locate_got:
    ; Get base address (from auxiliary vector or /proc/self/maps)
    mov rax, [elf_base]
    
    ; Parse ELF header
    mov rbx, [rax + 0x20]       ; e_phoff (program header offset)
    add rbx, rax                 ; RBX = program headers
    movzx ecx, word [rax + 0x38] ; e_phnum (number of headers)
    
find_dynamic_segment:
    cmp dword [rbx], 2          ; PT_DYNAMIC
    je found_dynamic
    add rbx, 0x38               ; sizeof(Elf64_Phdr)
    loop find_dynamic_segment
    jmp no_dynamic
    
found_dynamic:
    mov rdi, [rbx + 0x10]       ; p_vaddr
    add rdi, rax                 ; RDI = dynamic section
    
    ; Parse dynamic section for GOT
parse_dynamic:
    mov rdx, [rdi]              ; d_tag
    test rdx, rdx
    jz done_dynamic
    
    cmp rdx, 3                  ; DT_PLTGOT
    je found_pltgot
    
    add rdi, 16
    jmp parse_dynamic
    
found_pltgot:
    mov rsi, [rdi + 8]          ; d_un.d_ptr
    ; RSI = address of GOT
    
    ; GOT entries:
    ; GOT[0] = address of _DYNAMIC
    ; GOT[1] = link_map structure
    ; GOT[2] = _dl_runtime_resolve function
    ; GOT[3...] = function pointers
    
    add rsi, 24                 ; Skip first 3 entries
    
    ; Iterate GOT entries
scan_got:
    mov rax, [rsi]
    test rax, rax
    jz done_got
    
    ; Check if this is target function
    ; Can compare against known addresses or names
    
    ; To get function name, parse .dynsym and .dynstr
    ; (more complex, similar to IAT parsing)
    
    add rsi, 8
    jmp scan_got
    
done_dynamic:
no_dynamic:
done_got:
```

**Installing GOT Hook**:

```asm
install_got_hook:
    ; RSI points to GOT entry for target function
    
    ; Save original
    mov rax, [rsi]
    mov [original_function], rax
    
    ; Change memory protection
    ; Get page-aligned address
    mov rdi, rsi
    and rdi, ~0xFFF             ; Page align
    mov rdx, 0x1000             ; Page size
    mov rsi, 7                  ; PROT_READ | PROT_WRITE | PROT_EXEC
    
    ; mprotect(addr, len, prot)
    push rsi                    ; Save GOT entry pointer
    mov rax, 10                 ; sys_mprotect
    mov rsi, rdx
    mov rdx, rsi
    syscall
    pop rsi
    
    ; Write hook address
    mov rax, hook_function
    mov [rsi], rax
    
    ; Optionally restore read-only protection
    ; (some systems have RELRO - read-only after relocation)
```

**Key Points:**

- GOT is functionally similar to IAT
- PLT (Procedure Linkage Table) calls through GOT
- RELRO (RELocation Read-Only) may make GOT read-only
- Full RELRO requires hooking before program starts (LD_PRELOAD)

### LD_PRELOAD Hooking (Linux)

Alternative to direct GOT modification:

```asm
; Compile shared library with hooked functions
; Library loaded before others via LD_PRELOAD

; hooked_malloc.asm
section .data
    original_malloc: dq 0

section .text
global malloc
extern dlsym
extern RTLD_NEXT

malloc:
    ; Check if we have original address
    cmp qword [original_malloc], 0
    jne have_original
    
    ; Get original malloc using dlsym
    push rdi
    sub rsp, 8                  ; Align stack
    
    mov rdi, RTLD_NEXT
    lea rsi, [malloc_name]
    call dlsym
    
    add rsp, 8
    mov [original_malloc], rax
    pop rdi
    
have_original:
    ; Custom logic before malloc
    push rdi
    ; ... logging, validation, etc ...
    pop rdi
    
    ; Call original
    call [original_malloc]
    
    ; Custom logic after malloc
    ; ... track allocation, etc ...
    
    ret

section .rodata
    malloc_name: db "malloc", 0
```

**Key Points:**

- LD_PRELOAD loads library before program's dependencies
- Symbols in preloaded library override later ones
- Requires compiling separate shared library
- Works without modifying target binary
- Can use dlsym(RTLD_NEXT) to get original function

### Vtable Hooking (C++ Objects)

Hooking virtual function calls:

```asm
; C++ object with virtual functions has vtable pointer at offset 0
; Vtable contains function pointers

hook_vtable:
    ; RDI = pointer to object
    mov rax, [rdi]              ; RAX = vtable pointer
    
    ; Save original vtable
    mov [original_vtable], rax
    
    ; Create new vtable (copy original)
    ; Allocate memory for new vtable
    mov rsi, vtable_size
    call allocate_memory
    mov rbx, rax                ; RBX = new vtable
    
    ; Copy original vtable
    mov rsi, [original_vtable]
    mov rdi, rbx
    mov rcx, vtable_size
    rep movsb
    
    ; Modify specific function pointers
    ; Assuming virtual function at index 2 (offset 16)
    mov rax, hooked_virtual_function
    mov [rbx + 16], rax
    
    ; Replace object's vtable pointer
    mov rax, [object_pointer]
    mov [rax], rbx

hooked_virtual_function:
    ; RDI = this pointer (first parameter in System V ABI)
    ; Additional parameters in RSI, RDX, RCX, R8, R9
    
    push rbp
    mov rbp, rsp
    push rdi
    push rsi
    push rdx
    
    ; Custom logic
    ; ...
    
    ; Get original function from original vtable
    mov rax, [original_vtable]
    mov rax, [rax + 16]         ; Original function at index 2
    
    pop rdx
    pop rsi
    pop rdi
    pop rbp
    
    ; Tail call to original
    jmp rax
```

**Hooking All Objects of a Class**:

```asm
; Hook vtable in the class's static data
; Affects all instances created after hook

hook_class_vtable:
    ; Find class vtable in memory
    ; Usually in .rodata or .data.rel.ro section
    
    ; Get vtable address (often from RTTI or first object)
    mov rdi, [first_object_ptr]
    mov rax, [rdi]              ; Original vtable
    
    ; Change protection if needed
    mov rdi, rax
    and rdi, ~0xFFF
    mov rsi, 0x2000             ; Cover multiple pages
    mov rdx, 7                  ; RWX
    mov r10, 10                 ; sys_mprotect
    push rax
    syscall
    pop rax
    
    ; Modify vtable in place
    mov rbx, hooked_function
    mov [rax + function_offset], rbx
    
    ; All existing and future objects now use hooked function
```

**Key Points:**

- Vtable hooking affects virtual function calls
- Can hook single object or entire class
- Must preserve calling convention (this pointer in RDI/RCX)
- Multiple inheritance complicates vtable layout

### API Set Schema Hooking (Windows 10+)

Windows 10+ uses API sets for forwarding:

```asm
; API sets map names like "api-ms-win-core-*" to actual DLLs
; Hook by modifying API set schema or target DLLs

locate_api_set_schema:
    ; API set schema in PEB
    mov rax, [gs:0x60]          ; PEB
    mov rax, [rax + 0x68]       ; ApiSetMap (x64 Windows 10)
    
    ; ApiSetMap structure contains hash table of API sets
    ; Each entry maps to target DLL name
    
    ; Parsing API set map structure:
    ; (complex structure, varies by Windows version)
    mov ebx, [rax + 0x0C]       ; Count
    mov edi, [rax + 0x10]       ; EntryOffset
    add rdi, rax
    
search_api_set:
    ; Each entry has name, hash, value entries
    ; Compare against target API set name
    
    ; If match found, can modify target DLL name
    ; (requires memory protection changes)
    
    dec ebx
    jnz search_api_set
```

**Key Points:**

- API sets provide indirection for system APIs
- **[Unverified]** Modifying API set schema requires kernel-level access or special privileges in most configurations
- More complex than direct IAT hooking
- Affects all processes if modified globally

### Detecting and Bypassing IAT Hooks

**IAT Hook Detection**:

```asm
detect_iat_hooks:
    ; Compare IAT entries with actual module exports
    
    ; Get IAT entry
    mov rax, [iat_entry]
    
    ; Get module base of import
    ; For example, kernel32.dll
    call GetModuleHandle_kernel32
    mov rbx, rax                ; Module base
    
    ; Parse exports to find target function
    mov edx, [rbx + 0x3C]       ; e_lfanew
    add rdx, rbx
    mov edx, [rdx + 0x88]       ; Export directory RVA
    add rdx, rbx                ; RDX = export directory
    
    ; Search exports for target function name
    mov ecx, [rdx + 0x18]       ; NumberOfNames
    mov edi, [rdx + 0x20]       ; AddressOfNames RVA
    add rdi, rbx
    
search_export:
    mov esi, [rdi]
    add rsi, rbx                ; Function name
    ; Compare against target name
    
    ; If found, get function address
    ; ... export parsing ...
    
    ; Compare actual export address with IAT entry
    cmp rax, [iat_entry]
    jne iat_is_hooked
    
    jmp next_iat_entry
    
iat_is_hooked:
    ; IAT entry differs from export
    ; Likely hooked
```

**Bypassing IAT Hooks**:

```asm
; Method 1: Direct call via export table
call_via_export:
    ; Parse export table to get real address
    ; ... export parsing code ...
    
    ; Call directly, bypassing IAT
    call rax

; Method 2: Manually resolve and cache addresses
resolve_functions:
    call GetModuleHandle_kernel32
    mov rbx, rax
    
    ; Parse exports
    ; Store real addresses in private table
    
    ; Use private table for calls
    call [private_function_table + offset]

; Method 3: Fresh API resolution
fresh_resolve:
    ; Load new copy of DLL
    call LoadLibraryEx           ; With special flags
    
    ; Get function from clean copy
    call GetProcAddress
    
    ; Call resolved function
    call rax
```

**Key Points:**

- Detection compares IAT with actual exports
- Sophisticated hooks may patch exports too
- Fresh resolution can bypass most hooks
- Some anti-cheat systems detect direct export calls

### Security Considerations

**DEP (Data Execution Prevention)**:

```asm
; DEP prevents executing data pages
; IAT is in data section, so IAT hooks still work
; But injected code caves must be in executable memory

; Mark memory executable
make_executable:
    ; Linux: mprotect
    mov rax, 10                 ; sys_mprotect
    mov rdi, page_addr
    mov rsi, page_size
    mov rdx, 7                  ; PROT_READ | PROT_WRITE | PROT_EXEC
    syscall
    
    ; Windows: VirtualProtect
    sub rsp, 0x28
    mov rcx, addr
    mov rdx, size
    mov r8d, 0x40               ; PAGE_EXECUTE_READWRITE
    lea r9, [old_protect]
    call [VirtualProtect]
    add rsp, 0x28
```

**ASLR (Address Space Layout Randomization)**:

```asm
; ASLR randomizes base addresses
; Must calculate addresses dynamically

get_base_runtime:
    ; Linux: Parse /proc/self/maps or use dl_iterate_phdr
    
    ; Windows: Use PEB
    mov rax, [gs:0x60]          ; PEB
    mov rax, [rax + 0x10]       ; ImageBaseAddress
    
    ; Module base addresses from PEB_LDR_DATA
    mov rbx, [rax + 0x18]       ; Ldr
    mov rbx, [rbx + 0x10]       ; InLoadOrderModuleList
    
iterate_modules:
    ; Each entry is LDR_DATA_TABLE_ENTRY
    mov rdx, [rbx + 0x30]       ; DllBase
    mov rsi, [rbx + 0x58]       ; BaseDllName (UNICODE_STRING)
    
    ; Compare names to find target module
    
    mov rbx, [rbx]              ; Next entry
    jmp iterate_modules
```

**Control Flow Guard (CFG)**:

**[Inference]** CFG validates indirect call targets to prevent exploits. IAT hooks may trigger CFG violations if hook addresses aren't registered as valid targets:

```asm
; CFG validation occurs before indirect calls
; Hooked IAT entry must point to valid target

; Windows CFG bitmap checks call targets
; May need to use ROP or return-to-PLT techniques if CFG enabled

; Detecting CFG:
check_cfg:
    ; Check PE header for CFG flags
    mov rax, [image_base]
    mov ebx, [rax + 0x3C]
    add rbx, rax
    mov ecx, [rbx + 0x94]       ; DllCharacteristics
    test ecx, 0x4000            ; IMAGE_DLLCHARACTERISTICS_GUARD_CF
    jnz cfg_enabled
```

**Kernel Patch Protection (PatchGuard)**:

Windows kernel-mode hooking faces PatchGuard:

**[Unverified]** PatchGuard periodically checks kernel structures for modifications and causes blue screen if tampering detected.

```asm
; Kernel-mode hooks must:
; - Avoid direct patching of protected structures
; - Use approved callback mechanisms
; - Register with appropriate APIs

; Approved methods:
; - PsSetCreateProcessNotifyRoutine
; - ObRegisterCallbacks
; - FltRegisterFilter (file system)
```

**Key Points:**

- Modern protections complicate hooking
- User-mode IAT hooking generally still works
- Kernel-mode hooking requires different approaches
- Some protections detectable, others opaque

### Hooking Anti-Tamper Protections

**Detecting Anti-Hook Measures**:

```asm
; Programs may verify their own IAT
detect_integrity_checks:
    ; Look for suspicious patterns:
    
    ; 1. Periodic IAT scanning
    ; Program compares IAT with known values
    
    ; 2. Checksum verification
    ; CRC/hash of code sections
    
    ; 3. Debug register checks
    mov rax, dr0
    test rax, rax
    jnz debugger_detected
    
    ; 4. Timing checks (detecting breakpoints)
    rdtsc
    mov rbx, rax
    ; Execute code
    rdtsc
    sub rax, rbx
    cmp rax, threshold
    ja timing_anomaly

; Hook the integrity check functions themselves
hook_integrity_check:
    ; Find and hook CRC/checksum functions
    ; Return expected values
    
integrity_check_hook:
    ; Instead of computing actual checksum
    ; Return pre-computed valid checksum
    mov rax, expected_checksum
    ret
```

**Bypassing Virtual Machine Detection**:

```asm
; Hook CPUID to hide hypervisor
cpuid_hook:
    ; Check which CPUID leaf being queried
    cmp eax, 1
    je cpuid_leaf_1
    
    cmp eax, 0x40000000
    je cpuid_hypervisor_leaf
    
    ; Pass through to real CPUID
    jmp [original_cpuid]
    
cpuid_hypervisor_leaf:
    ; Hide hypervisor by clearing presence bit
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    ret
    
cpuid_leaf_1:
    ; Clear hypervisor present bit in ECX
    call [original_cpuid]
    and ecx, ~(1 << 31)         ; Clear bit 31
    ret
```

**Key Points:**

- Anti-tamper measures can detect hooks
- Hook detection functions can themselves be hooked
- Arms race between protection and bypass
- Sophisticated protection uses multiple detection methods

**Important subtopics**: Return-Oriented Programming (ROP) chain construction for bypassing DEP, Jump-Oriented Programming (JOP) as alternative to ROP, kernel-mode hooking techniques for rootkit development, hypervisor-based hooking for transparent system monitoring, hardware-assisted hooking using Intel VT-x or AMD-V virtualization extensions.

---

## Inline Hooking

### Overview of Inline Hooking

Inline hooking is a technique where instructions at the beginning of a target function are replaced with a jump to hook code. The hook code can execute custom logic before/after calling the original function, enabling interception of function calls without modifying the call sites.

**Basic concept:**

```
Original function:
  [instructions]  <- Replace with jump to hook
  [instructions]
  ...

Hook function:
  [custom code]
  [execute original instructions]
  [jump to original+offset]
```

### Simple Inline Hook Pattern

**Target function (before hooking):**

```nasm
original_function:
    push rbp                ; 1 byte: 0x55
    mov rbp, rsp            ; 3 bytes: 0x48 0x89 0xE5
    sub rsp, 32             ; 4 bytes: 0x48 0x83 0xEC 0x20
    ; ... rest of function
```

**Hook installed (after patching):**

```nasm
original_function:
    jmp hook_function       ; 5 bytes: 0xE9 [4-byte offset]
    ; Remaining bytes overwritten or preserved
```

**Hook function:**

```nasm
hook_function:
    ; Save registers
    push rax
    push rcx
    push rdx
    ; ... save all registers you'll use
    
    ; Custom logic (logging, modification, etc.)
    call my_custom_code
    
    ; Restore registers
    pop rdx
    pop rcx
    pop rax
    
    ; Execute original instructions that were overwritten
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Jump back to original function (past the hook)
    jmp [original_function + 5]
```

### 32-bit Relative Jump Hook

The most common hook uses a 5-byte relative jump:

**Calculating jump offset:**

```nasm
; Jump instruction format: E9 [offset]
; offset = target_address - (current_address + 5)
```

**Example implementation:**

```c
void install_hook(void *target, void *hook) {
    // Calculate relative offset
    int32_t offset = (char*)hook - ((char*)target + 5);
    
    // Build jump instruction
    unsigned char jump[5];
    jump[0] = 0xE9;  // JMP rel32
    *(int32_t*)(jump + 1) = offset;
    
    // Make memory writable (platform-specific)
    make_writable(target, 5);
    
    // Install hook
    memcpy(target, jump, 5);
    
    // Restore memory protection
    restore_protection(target, 5);
}
```

**Windows memory protection:**

```c
#include <windows.h>

void make_writable(void *addr, size_t size) {
    DWORD old_protect;
    VirtualProtect(addr, size, PAGE_EXECUTE_READWRITE, &old_protect);
}
```

**Linux memory protection:**

```c
#include <sys/mman.h>
#include <unistd.h>

void make_writable(void *addr, size_t size) {
    // Align to page boundary
    size_t page_size = sysconf(_SC_PAGESIZE);
    void *page = (void*)((uintptr_t)addr & ~(page_size - 1));
    
    mprotect(page, size, PROT_READ | PROT_WRITE | PROT_EXEC);
}
```

### Preserving Original Instructions

**[Inference]** When installing a hook, you must preserve the instructions you overwrite to execute them in your hook or trampoline.

**Simple instruction preservation:**

```c
// Save overwritten bytes
unsigned char saved_bytes[5];
memcpy(saved_bytes, target, 5);

// Install hook
install_hook(target, hook);

// Restore in hook or trampoline
void execute_original(void) {
    // Copy saved bytes to executable memory
    void *trampoline = allocate_executable(5 + 5);
    memcpy(trampoline, saved_bytes, 5);
    
    // Add jump back to original+5
    unsigned char *ptr = (unsigned char*)trampoline + 5;
    ptr[0] = 0xE9;
    *(int32_t*)(ptr + 1) = ((char*)target + 5) - ((char*)ptr + 5);
    
    // Call trampoline
    ((void(*)())trampoline)();
}
```

### Instruction Length Disassembly

**Problem:** You need to overwrite at least 5 bytes, but instructions may be 1-15 bytes long. Overwriting partial instructions causes crashes.

**[Unverified]** Accurate instruction length detection requires a full x86 disassembler. Simple heuristics work for common cases but may fail on complex instructions.

**Common instruction lengths:**

```nasm
push rbp        ; 1 byte: 0x55
mov rbp, rsp    ; 3 bytes: 0x48 0x89 0xE5
sub rsp, 32     ; 4 bytes: 0x48 0x83 0xEC 0x20
```

**Using length disassembler (pseudo-code):**

```c
size_t find_instruction_boundary(void *addr, size_t min_bytes) {
    size_t total = 0;
    unsigned char *ptr = (unsigned char*)addr;
    
    while (total < min_bytes) {
        size_t len = get_instruction_length(ptr);
        total += len;
        ptr += len;
    }
    
    return total;
}
```

**Available disassembler libraries:**

- Zydis (open source, x86/x64)
- Capstone (multi-architecture)
- Intel XED (official Intel library)
- Distorm3 (lightweight)

### Short Jump Hook (2 bytes)

When hooking functions shorter than 5 bytes, use a 2-byte short jump:

**Short jump format:**

```nasm
jmp short offset    ; EB [1-byte offset]
                    ; Range: -128 to +127 bytes
```

**Limitation:** Target must be within 128 bytes. Requires allocating hook nearby.

**Example:**

```c
void install_short_hook(void *target, void *hook) {
    int8_t offset = (char*)hook - ((char*)target + 2);
    
    if (offset < -128 || offset > 127) {
        // Hook too far, need different technique
        return;
    }
    
    unsigned char jump[2];
    jump[0] = 0xEB;  // JMP short
    jump[1] = (unsigned char)offset;
    
    make_writable(target, 2);
    memcpy(target, jump, 2);
}
```

### Multi-Byte NOP Padding

Some compilers insert multi-byte NOPs between functions. These can be used for hooks without overwriting instructions:

**Multi-byte NOP sequences:**

```nasm
; 1-byte NOP
nop                 ; 0x90

; 2-byte NOP
66 90               ; xchg ax, ax

; 3-byte NOP
0F 1F 00            ; nop dword ptr [rax]

; 4-byte NOP
0F 1F 40 00         ; nop dword ptr [rax+0]

; 5-byte NOP
0F 1F 44 00 00      ; nop dword ptr [rax+rax+0]
```

**Finding NOP padding:**

```c
bool has_5byte_nop_before(void *func) {
    unsigned char *ptr = (unsigned char*)func - 5;
    return (ptr[0] == 0x0F && ptr[1] == 0x1F && 
            ptr[2] == 0x44 && ptr[3] == 0x00 && ptr[4] == 0x00);
}
```

### Hot Patching Technique

**[Inference]** Some compilers (MSVC with /hotpatch) generate 2-byte NOP before functions and 5-byte prologue, designed for easy hooking.

**Hot-patchable function:**

```nasm
; 5-byte NOP before function (for jmp)
0F 1F 44 00 00

function_start:
    mov edi, edi        ; 2-byte instruction (for short jmp)
    push rbp
    mov rbp, rsp
    ; ...
```

**Installing hot patch:**

```c
void install_hotpatch(void *func, void *hook) {
    // Install 5-byte jump before function
    unsigned char *before = (unsigned char*)func - 5;
    before[0] = 0xE9;
    *(int32_t*)(before + 1) = (char*)hook - (char*)func;
    
    // Install 2-byte short jump at function start
    unsigned char *start = (unsigned char*)func;
    start[0] = 0xEB;  // JMP short
    start[1] = 0xF9;  // -7 (to jump to before-5)
}
```

### Atomic Hook Installation

**Problem:** If a thread executes the function while you're writing the hook, it may execute partial/corrupted instructions.

**Solution 1: Suspend all threads (Windows):**

```c
void suspend_all_threads(void) {
    HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
    THREADENTRY32 te;
    te.dwSize = sizeof(te);
    
    DWORD current_thread = GetCurrentThreadId();
    
    if (Thread32First(snapshot, &te)) {
        do {
            if (te.th32OwnerProcessID == GetCurrentProcessId() &&
                te.th32ThreadID != current_thread) {
                HANDLE thread = OpenThread(THREAD_SUSPEND_RESUME, FALSE, 
                                          te.th32ThreadID);
                SuspendThread(thread);
                CloseHandle(thread);
            }
        } while (Thread32Next(snapshot, &te));
    }
    
    CloseHandle(snapshot);
}
```

**Solution 2: Atomic write (x86 guarantees):**

```c
// x86 guarantees aligned 4-byte writes are atomic
// Write first 4 bytes atomically, then 5th byte
void install_hook_atomic(void *target, void *hook) {
    int32_t offset = (char*)hook - ((char*)target + 5);
    
    unsigned char jump[5];
    jump[0] = 0xE9;
    *(int32_t*)(jump + 1) = offset;
    
    make_writable(target, 5);
    
    // Write first 4 bytes (offset)
    *(uint32_t*)((char*)target + 1) = *(uint32_t*)(jump + 1);
    
    // Memory barrier to ensure offset is visible
    __asm__ volatile("mfence" ::: "memory");
    
    // Write opcode (0xE9) last - now hook is active
    *(unsigned char*)target = 0xE9;
}
```

### Hook Chain Management

Multiple hooks on the same function require chain management:

**Hook chain structure:**

```c
struct Hook {
    void *target;
    void *original;      // Trampoline to original code
    void *hook_func;
    struct Hook *next;   // Next hook in chain
    unsigned char saved_bytes[16];
    size_t saved_len;
};
```

**Installing chained hook:**

```c
void install_chained_hook(struct Hook *hook) {
    // Find existing hook
    struct Hook *existing = find_hook(hook->target);
    
    if (existing) {
        // Hook already exists, chain to it
        hook->target = existing->hook_func;
        hook->next = existing;
    }
    
    // Save original bytes
    hook->saved_len = find_instruction_boundary(hook->target, 5);
    memcpy(hook->saved_bytes, hook->target, hook->saved_len);
    
    // Install jump
    install_hook(hook->target, hook->hook_func);
}
```

### VTable Hooking

For C++ objects, hooking virtual functions via VTable is simpler than inline hooking:

**VTable structure:**

```c
// C++ class
class MyClass {
public:
    virtual void func1();
    virtual void func2();
};

// Memory layout
// [object ptr] -> [vtable ptr] -> [func1 ptr]
//                                  [func2 ptr]
```

**Hooking virtual function:**

```c
void hook_vtable_function(void *object, int index, void *hook) {
    // Get vtable pointer
    void ***vtable_ptr = (void***)object;
    void **vtable = *vtable_ptr;
    
    // Save original function pointer
    void *original = vtable[index];
    
    // Replace with hook
    make_writable(&vtable[index], sizeof(void*));
    vtable[index] = hook;
}
```

**Advantages:**

- No instruction disassembly required
- Simpler to implement
- Per-object granularity possible

**Disadvantages:**

- Only works for virtual functions
- Affects all instances if hooking shared vtable

### Import Address Table (IAT) Hooking

Hooking imported functions by modifying the IAT:

**IAT structure (Windows):**

```c
// Each DLL has an IAT with function pointers
// kernel32.dll: [CreateFileW ptr]
//               [ReadFile ptr]
//               [WriteFile ptr]
```

**Hooking IAT entry:**

```c
void hook_iat(const char *module, const char *function, void *hook) {
    HMODULE base = GetModuleHandle(NULL);
    
    // Find IAT
    PIMAGE_DOS_HEADER dos = (PIMAGE_DOS_HEADER)base;
    PIMAGE_NT_HEADERS nt = (PIMAGE_NT_HEADERS)((char*)base + dos->e_lfanew);
    PIMAGE_IMPORT_DESCRIPTOR import = 
        (PIMAGE_IMPORT_DESCRIPTOR)((char*)base + 
        nt->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress);
    
    // Find specific import
    while (import->Name) {
        char *import_name = (char*)base + import->Name;
        if (_stricmp(import_name, module) == 0) {
            // Found the DLL, now find function
            PIMAGE_THUNK_DATA thunk = (PIMAGE_THUNK_DATA)((char*)base + import->FirstThunk);
            PIMAGE_THUNK_DATA original = (PIMAGE_THUNK_DATA)((char*)base + import->OriginalFirstThunk);
            
            while (thunk->u1.Function) {
                PIMAGE_IMPORT_BY_NAME func = (PIMAGE_IMPORT_BY_NAME)((char*)base + original->u1.AddressOfData);
                if (strcmp(func->Name, function) == 0) {
                    // Found it, replace
                    make_writable(&thunk->u1.Function, sizeof(void*));
                    thunk->u1.Function = (ULONGLONG)hook;
                    return;
                }
                thunk++;
                original++;
            }
        }
        import++;
    }
}
```

**Advantages:**

- No instruction modification
- Clean and reversible
- Works for all calls through IAT

**Disadvantages:**

- Only hooks imported functions
- Doesn't catch direct calls or GetProcAddress results
- Windows-specific

**Key Points:**

- Inline hooking replaces function start with jump to hook code
- Minimum 5 bytes needed for 32-bit relative jump (0xE9 + offset)
- Must preserve overwritten instructions in trampoline
- [Inference] Instruction length disassembly critical for not breaking partial instructions
- Atomic installation prevents corruption from concurrent execution
- VTable and IAT hooking are alternatives for specific scenarios
- [Unverified] Production hooking libraries handle many edge cases that simple implementations miss

## Detours and Trampolines

### Trampoline Concept

A trampoline is a small code stub that executes the original instructions displaced by a hook, then jumps back to the original function. This allows the hook to call the original function.

**Trampoline structure:**

```
Trampoline:
    [saved original instructions]
    [jump to original+offset]
```

**Flow with trampoline:**

```
1. Call hooked function
2. Jump to hook handler
3. Hook calls trampoline
4. Trampoline executes original instructions
5. Trampoline jumps to original function continuation
6. Original function returns to hook
7. Hook returns to caller
```

### Building a Trampoline

**Basic trampoline creation:**

```c
void* create_trampoline(void *target, size_t overwrite_len) {
    // Allocate executable memory
    void *trampoline = allocate_executable(overwrite_len + 5);
    
    // Copy original instructions
    memcpy(trampoline, target, overwrite_len);
    
    // Add jump back to original
    unsigned char *jmp = (unsigned char*)trampoline + overwrite_len;
    jmp[0] = 0xE9;  // JMP rel32
    *(int32_t*)(jmp + 1) = ((char*)target + overwrite_len) - ((char*)jmp + 5);
    
    return trampoline;
}
```

**Example usage:**

```nasm
; Original function
original_func:
    push rbp            ; These 8 bytes will be
    mov rbp, rsp        ; overwritten by hook
    sub rsp, 32
    ; ... rest

; After hooking, trampoline contains:
trampoline:
    push rbp            ; Copied from original
    mov rbp, rsp
    sub rsp, 32
    jmp original_func+8 ; Jump to continuation
```

### Microsoft Detours Library Approach

**[Inference]** Microsoft Detours is a production-quality hooking library that handles complex trampoline generation. The basic principle:

**Detour structure:**

```c
// Detours API (simplified concept)
void* original_func = DetourFunction(target_func, hook_func);

// Now:
// - target_func jumps to hook_func
// - original_func is trampoline that calls original code
// - hook_func can call original_func to invoke original behavior
```

**Implementation concept:**

```c
// Hook function can call original
int hooked_function(int x) {
    printf("Before: x=%d\n", x);
    
    // Call original through trampoline
    int result = original_function(x);
    
    printf("After: result=%d\n", result);
    return result;
}
```

### Handling Relative Instructions

**Problem:** Some instructions use relative addressing. When copied to a trampoline, they still reference original locations.

**Relative instructions to watch for:**

- `call` relative (E8 + offset)
- `jmp` relative (E9/EB + offset)
- `jcc` relative (0F 8x + offset or 7x + offset)
- RIP-relative addressing (x64): `mov rax, [rip+offset]`

**Example problem:**

```nasm
original_func:
    call [rip + 0x1000]     ; Calls function at original_func + 0x1000
    ; ... more code

; If copied to trampoline as-is:
trampoline:
    call [rip + 0x1000]     ; Now calls trampoline + 0x1000 (wrong!)
```

**Solution: Relocate relative instructions:**

```c
void relocate_instruction(unsigned char *dest, unsigned char *src, size_t len) {
    if (src[0] == 0xE8) {  // CALL rel32
        // Copy opcode
        dest[0] = 0xE8;
        
        // Calculate original target
        int32_t old_offset = *(int32_t*)(src + 1);
        void *target = src + 5 + old_offset;
        
        // Calculate new offset from trampoline
        int32_t new_offset = (char*)target - (dest + 5);
        *(int32_t*)(dest + 1) = new_offset;
        
    } else if (src[0] == 0xE9) {  // JMP rel32
        // Similar relocation
        dest[0] = 0xE9;
        int32_t old_offset = *(int32_t*)(src + 1);
        void *target = src + 5 + old_offset;
        int32_t new_offset = (char*)target - (dest + 5);
        *(int32_t*)(dest + 1) = new_offset;
        
    } else {
        // Regular instruction, copy as-is
        memcpy(dest, src, len);
    }
}
```

**RIP-relative addressing (x64):**

```c
bool is_rip_relative(unsigned char *instr, size_t len) {
    // Check for ModR/M byte indicating RIP-relative
    // This is simplified - full implementation is complex
    if (len >= 2 && (instr[0] == 0x48 || instr[0] == 0x4C)) {
        // Common REX prefix
        if (instr[1] == 0x8B || instr[1] == 0x89) {  // MOV
            unsigned char modrm = instr[2];
            return ((modrm & 0xC7) == 0x05);  // RIP+disp32
        }
    }
    return false;
}

void relocate_rip_relative(unsigned char *dest, unsigned char *src, size_t len) {
    // Example: 48 8B 05 [disp32] = mov rax, [rip+disp32]
    // Copy instruction
    memcpy(dest, src, len);
    
    // Find displacement offset (usually at end-4)
    int32_t *disp = (int32_t*)(dest + len - 4);
    
    // Calculate original target
    void *target = src + len + *disp;
    
    // Calculate new displacement
    *disp = (char*)target - (dest + len);
}
```

### Conditional Jump Handling

**Short conditional jumps (7x opcodes):**

```nasm
; Original
je short target     ; 75 [offset]  (2 bytes, range -128 to +127)
```

**If target is out of range from trampoline, convert to long form:**

```nasm
; Trampoline
jne skip            ; 75 05  (invert condition)
jmp far_target      ; E9 [32-bit offset]
skip:
```

**Implementation:**

```c
void relocate_short_jcc(unsigned char *dest, unsigned char *src) {
    // src[0] = 0x7x (short conditional jump)
    // src[1] = 8-bit offset
    
    unsigned char condition = src[0];
    int8_t old_offset = (int8_t)src[1];
    void *target = src + 2 + old_offset;
    
    int32_t new_offset = (char*)target - (dest + 2);
    
    if (new_offset >= -128 && new_offset <= 127) {
        // Still in range, copy as-is
        dest[0] = condition;
        dest[1] = (unsigned char)new_offset;
    } else {
        // Out of range, convert to long form
        // jne skip; jmp target; skip:
        dest[0] = condition ^ 0x01;  // Invert condition
        dest[1] = 0x05;               // Skip 5 bytes (the jmp)
        dest[2] = 0xE9;               // JMP rel32
        *(int32_t*)(dest + 3) = (char*)target - (dest + 7);
    }
}
```

### Allocating Trampoline Memory

**Memory allocation requirements:**

- Must be executable
- Should be close to original function (for 32-bit relative jumps)
- Should be permanent (not freed)

**Windows allocation:**

```c
void* allocate_trampoline_near(void *target, size_t size) {
    // Try to allocate within 2GB of target
    char *min_addr = (char*)target - 0x7FF00000;
    char *max_addr = (char*)target + 0x7FF00000;
    
    SYSTEM_INFO si;
    GetSystemInfo(&si);
    
    // Align to allocation granularity
    min_addr = (char*)(((uintptr_t)min_addr) & ~(si.dwAllocationGranularity - 1));
    
    for (char *addr = min_addr; addr < max_addr; addr += si.dwAllocationGranularity) {
        void *mem = VirtualAlloc(addr, size, MEM_COMMIT | MEM_RESERVE, 
                                 PAGE_EXECUTE_READWRITE);
        if (mem) return mem;
    }
    
    return NULL;  // Failed to allocate near target
}
```

**Linux allocation:**

```c
void* allocate_trampoline_near(void *target, size_t size) {
    // Try mmap near target
    char *min_addr = (char*)target - 0x7FF00000;
    char *max_addr = (char*)target + 0x7FF00000;
    
    long page_size = sysconf(_SC_PAGESIZE);
    size_t alloc_size = (size + page_size - 1) & ~(page_size - 1);
    
    for (char *addr = min_addr; addr < max_addr; addr += 0x10000) {
        void *mem = mmap(addr, alloc_size, PROT_READ | PROT_WRITE | PROT_EXEC,
                         MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
        if (mem != MAP_FAILED && mem != NULL) {
            return mem;
        }
    }
    
    return NULL;
}
```

### 64-bit Long Jump Trampoline

When trampoline is far from original function (>2GB away), use absolute jump:

**Absolute jump via register:**

```nasm
; 13 bytes total
mov rax, [address]  ; 48 B8 [8-byte address]
jmp rax             ; FF E0
```

**Absolute jump via memory:**

```nasm
; 6 bytes instruction + 8 bytes data
jmp qword [rip+0]   ; FF 25 00 00 00 00
dq target_address   ; 8-byte address
```

**Building long jump trampoline:**

```c
void add_long_jump(unsigned char *dest, void *target) {
    // Method 1: MOV RAX, addr; JMP RAX
    dest[0] = 0x48;  // REX.W
    dest[1] = 0xB8;  // MOV RAX, imm64
    *(uint64_t*)(dest + 2) = (uint64_t)target;
    dest[10] = 0xFF;  // JMP
    dest[11] = 0xE0;  // RAX
}
```

### Trampoline Pool Management

For efficiency, manage a pool of trampolines:

```c
struct TrampolinePool {
    void *memory;
    size_t size;
    size_t used;
    struct Trampoline *trampolines;
};

struct Trampoline {
    void *address;
    size_t size;
    void *target;
    struct Trampoline *next;
};

void* allocate_from_pool(struct TrampolinePool *pool, size_t size) {
    if (pool->used + size > pool->size) {
        return NULL;  // Pool exhausted
    }
    
    void *addr = (char*)pool->memory + pool->used;
    pool->used += size;
    
    // Align to 16 bytes
    pool->used = (pool->used + 15) & ~15;
    
    return addr;
}
```

### Stack Frame Preservation

**[Inference]** Trampolines must preserve the stack frame expected by the original code.

**Example with frame pointer:**

```nasm
original_func:
    push rbp            ; Establishes frame
    mov rbp, rsp
    sub rsp, 32
    ; ... code expects rbp to be set

; Trampoline must execute these exactly
trampoline:
    push rbp            ; Must execute
    mov rbp, rsp        ; Must execute
    sub rsp, 32         ; Must execute
    jmp original_func+8 ; Continue
```

**Broken trampoline example:**

```nasm
; WRONG: Skipping frame setup
trampoline:
    jmp original_func+8  ; WRONG: original code expects rbp set!
```

### Inline Function Handling

**[Inference]** Compiler-inlined functions don't exist as callable entities, making them difficult or impossible to hook with trampolines. Must hook call sites instead or prevent inlining.

**Preventing inlining (C):**

```c
// GCC/Clang
__attribute__((noinline))
void my_function(void) {
    // ...
}

// MSVC
__declspec(noinline)
void my_function(void) {
    // ...
}
```

### Thread Safety in Detours

**Installing detour atomically:**

```c
void install_detour_safe(void *target, void *hook, void **trampoline) {
    // 1. Create trampoline first
    size_t len = find_instruction_boundary(target, 5);
    *trampoline = create_trampoline(target, len);
    
    // 2. Suspend threads (Windows) or use signal (Linux)
    suspend_all_threads();
    
    // 3. Install hook atomically
    install_hook_atomic(target, hook);
    
    // 4. Flush instruction cache
    flush_instruction_cache(target, 5);
    
    // 5. Resume threads
    resume_all_threads();
}
```

**Instruction cache flushing (Windows):**

```c
void flush_instruction_cache(void *addr, size_t size) {
    FlushInstructionCache(GetCurrentProcess(), addr, size);
}
```

**Instruction cache flushing (Linux):**

```c
void flush_instruction_cache(void *addr, size_t size) {
    __builtin___clear_cache((char*)addr, (char*)addr + size);
}
```

**Key Points:**

- Trampolines execute original instructions displaced by hooks
- Must handle relative instructions specially (CALL, JMP, RIP-relative)
- Allocate trampoline memory close to original function for 32-bit jumps
- [Inference] 64-bit absolute jumps required when trampoline is >2GB away
- Preserve stack frame setup instructions in trampoline
- [Inference] Thread safety requires suspending threads during installation
- Instruction cache must be flushed after code modification
- [Unverified] Production detour libraries handle many edge cases including complex instruction relocation

## Self-Modifying Code

### Concept and Use Cases

Self-modifying code (SMC) is code that changes its own instructions at runtime. While generally discouraged in modern programming, it has legitimate uses:

- JIT (Just-In-Time) compilation
- Dynamic optimization
- Code obfuscation
- Runtime patching
- Polymorphic code

**[Inference]** Self-modifying code significantly complicates debugging, security analysis, and maintenance. Use only when necessary.

### Basic Self-Modification

**Simple example - modifying immediate value:**

```nasm
section .text
global modify_self

modify_self:
    ; This instruction will be modified
    mov eax, 0x12345678     ; 5 bytes: B8 78 56 34 12
    ret

; Function to modify the immediate value
global change_value
change_value:
    ; rdi = new value

    ; Calculate address of immediate value
    ; mov eax, imm32 is: B8 [4 bytes]
    ; Immediate is at offset +1 from instruction start
    lea rax, [rel modify_self]
    add rax, 1               ; Point to immediate value

    ; Make memory writable
    ; (platform-specific, shown conceptually)
    call make_executable_writable

    ; Modify the immediate
    mov dword [rax], edi

    ; Flush instruction cache
    call flush_icache
    ret
````

**Using the self-modifying code:**
```c
extern int modify_self(void);
extern void change_value(int new_val);

int main(void) {
    printf("Result: %d\n", modify_self());  // Prints 305419896 (0x12345678)
    
    change_value(0xABCDEF00);
    
    printf("Result: %d\n", modify_self());  // Prints 2882400000 (0xABCDEF00)
    return 0;
}
````

### Memory Protection Issues

Modern operating systems mark code sections as read-only and executable. Self-modifying code must change protection first.

**Windows - VirtualProtect:**

```c
#include <windows.h>

void make_writable(void *addr, size_t size) {
    DWORD old_protect;
    VirtualProtect(addr, size, PAGE_EXECUTE_READWRITE, &old_protect);
}

void restore_executable(void *addr, size_t size, DWORD old_protect) {
    DWORD dummy;
    VirtualProtect(addr, size, old_protect, &dummy);
}
```

**Linux - mprotect:**

```c
#include <sys/mman.h>
#include <unistd.h>

void make_writable(void *addr, size_t size) {
    size_t page_size = sysconf(_SC_PAGESIZE);
    void *page = (void*)((uintptr_t)addr & ~(page_size - 1));
    size_t len = ((char*)addr - (char*)page) + size;
    
    mprotect(page, len, PROT_READ | PROT_WRITE | PROT_EXEC);
}
```

**Complete example with protection:**

```c
void modify_code_safely(void *addr, void *new_code, size_t len) {
    // Get page size and calculate page-aligned address
    size_t page_size = sysconf(_SC_PAGESIZE);
    void *page = (void*)((uintptr_t)addr & ~(page_size - 1));
    size_t protect_len = ((char*)addr - (char*)page) + len;
    
    // Make writable
    mprotect(page, protect_len, PROT_READ | PROT_WRITE | PROT_EXEC);
    
    // Modify code
    memcpy(addr, new_code, len);
    
    // Flush instruction cache
    __builtin___clear_cache((char*)addr, (char*)addr + len);
    
    // Optionally restore protection (for security)
    // mprotect(page, protect_len, PROT_READ | PROT_EXEC);
}
```

### Instruction Cache Coherency

**Problem:** Modern CPUs have separate instruction and data caches. Writing to code through data cache doesn't automatically update instruction cache.

**x86 behavior:**

- x86 maintains instruction cache coherency in hardware
- Self-modifying code still has performance penalty
- Other architectures (ARM, RISC-V) require explicit cache flushing

**Serializing instruction for x86:**

```nasm
; After modifying code, serialize the pipeline
cpuid           ; Serializing instruction
; or
mfence
lfence
```

**Cross-modifying code (multi-core):** When one CPU modifies code that another CPU is executing:

```c
void modify_code_on_other_cpu(void *addr, void *new_code, size_t len) {
    // Modify the code
    make_writable(addr, len);
    memcpy(addr, new_code, len);
    
    // x86: Hardware maintains cache coherency
    // But instruction pipeline may have cached old instructions
    
    // Force other CPUs to refetch instructions
    // Windows: FlushInstructionCache
    FlushInstructionCache(GetCurrentProcess(), addr, len);
    
    // Linux: __builtin___clear_cache
    __builtin___clear_cache((char*)addr, (char*)addr + len);
}
```

### Self-Modifying JMP Target

**Dynamic jump target modification:**

```nasm
section .text

dynamic_jump:
    jmp target_placeholder
    
target_placeholder:
    ret

; Modify jump target at runtime
set_jump_target:
    ; rdi = new target address
    
    ; Calculate offset for relative jump
    lea rax, [rel dynamic_jump]
    add rax, 1              ; Point to offset (after E9 opcode)
    
    ; Calculate relative offset
    ; offset = target - (current + 5)
    lea rcx, [rel dynamic_jump]
    add rcx, 5              ; Address after jmp instruction
    sub rdi, rcx            ; rdi = target - (current + 5)
    
    ; Modify the offset
    mov dword [rax], edi
    
    ret
```

**Using dynamic jump:**

```c
extern void dynamic_jump(void);
extern void set_jump_target(void *target);

void function_a(void) { printf("Function A\n"); }
void function_b(void) { printf("Function B\n"); }

int main(void) {
    set_jump_target(function_a);
    dynamic_jump();  // Calls function_a
    
    set_jump_target(function_b);
    dynamic_jump();  // Calls function_b
    
    return 0;
}
```

### Runtime Code Generation

**Generating code at runtime:**

```c
typedef int (*func_t)(int);

func_t generate_multiply_function(int multiplier) {
    // Allocate executable memory
    void *mem = mmap(NULL, 4096, PROT_READ | PROT_WRITE | PROT_EXEC,
                     MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    
    unsigned char *code = (unsigned char*)mem;
    int offset = 0;
    
    // Generate: mov eax, edi
    code[offset++] = 0x89;
    code[offset++] = 0xF8;
    
    // Generate: imul eax, eax, [multiplier]
    code[offset++] = 0x69;
    code[offset++] = 0xC0;
    *(int32_t*)(&code[offset]) = multiplier;
    offset += 4;
    
    // Generate: ret
    code[offset++] = 0xC3;
    
    return (func_t)mem;
}
```

**Usage:**

```c
func_t multiply_by_5 = generate_multiply_function(5);
func_t multiply_by_10 = generate_multiply_function(10);

printf("%d\n", multiply_by_5(3));   // 15
printf("%d\n", multiply_by_10(3));  // 30

// Don't forget to free
munmap(multiply_by_5, 4096);
munmap(multiply_by_10, 4096);
```

### Polymorphic Code

**Code that changes its appearance while maintaining functionality:**

```nasm
section .text

; Original code
original_version:
    mov eax, 1
    add eax, 2
    ret

; Equivalent polymorphic version
polymorphic_version:
    xor eax, eax
    inc eax
    inc eax
    inc eax
    ret
```

**Runtime polymorphism:**

```c
void morph_code(void *func, int variant) {
    unsigned char *code = (unsigned char*)func;
    make_writable(code, 16);
    
    if (variant == 0) {
        // Version 1: mov eax, 3
        code[0] = 0xB8;
        *(int32_t*)(&code[1]) = 3;
        code[5] = 0xC3;  // ret
    } else if (variant == 1) {
        // Version 2: xor eax, eax; add eax, 3
        code[0] = 0x31;
        code[1] = 0xC0;
        code[2] = 0x83;
        code[3] = 0xC0;
        code[4] = 0x03;
        code[5] = 0xC3;  // ret
    } else {
        // Version 3: push 3; pop eax
        code[0] = 0x6A;
        code[1] = 0x03;
        code[2] = 0x58;
        code[3] = 0xC3;  // ret
    }
    
    flush_instruction_cache(code, 16);
}
```

### Self-Decrypting Code

**Code that decrypts itself before execution:**

```nasm
section .text

decryptor:
    ; Decrypt the encrypted section
    lea rsi, [rel encrypted_code]
    lea rdi, [rel encrypted_code]
    mov rcx, encrypted_code_end - encrypted_code
    
.decrypt_loop:
    mov al, [rsi]
    xor al, 0xAA            ; Simple XOR decryption
    mov [rdi], al
    inc rsi
    inc rdi
    loop .decrypt_loop
    
    ; Jump to decrypted code
    jmp encrypted_code

encrypted_code:
    ; This will contain encrypted bytes initially
    ; After decryption, it becomes valid instructions
    ; Example (encrypted form of: mov eax, 42; ret)
    db 0x18, 0x72, 0xE8, 0xC9
    
encrypted_code_end:
```

**Generating encrypted code:**

```c
void encrypt_code(unsigned char *code, size_t len, unsigned char key) {
    for (size_t i = 0; i < len; i++) {
        code[i] ^= key;
    }
}

// Generate encrypted version
unsigned char original[] = {0xB8, 0x2A, 0x00, 0x00, 0x00, 0xC3};  // mov eax, 42; ret
encrypt_code(original, sizeof(original), 0xAA);
// Result: {0x12, 0x80, 0xAA, 0xAA, 0xAA, 0x68}
```

### JIT Compilation Pattern

**Basic JIT compiler structure:**

```c
struct JITContext {
    unsigned char *code_buffer;
    size_t buffer_size;
    size_t code_offset;
};

void jit_init(struct JITContext *ctx, size_t size) {
    ctx->code_buffer = mmap(NULL, size, 
                           PROT_READ | PROT_WRITE | PROT_EXEC,
                           MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    ctx->buffer_size = size;
    ctx->code_offset = 0;
}

void jit_emit_byte(struct JITContext *ctx, unsigned char byte) {
    if (ctx->code_offset >= ctx->buffer_size) {
        // Buffer full
        return;
    }
    ctx->code_buffer[ctx->code_offset++] = byte;
}

void jit_emit_mov_eax_imm32(struct JITContext *ctx, int32_t value) {
    jit_emit_byte(ctx, 0xB8);  // MOV EAX, imm32
    jit_emit_byte(ctx, value & 0xFF);
    jit_emit_byte(ctx, (value >> 8) & 0xFF);
    jit_emit_byte(ctx, (value >> 16) & 0xFF);
    jit_emit_byte(ctx, (value >> 24) & 0xFF);
}

void jit_emit_ret(struct JITContext *ctx) {
    jit_emit_byte(ctx, 0xC3);  // RET
}

void* jit_finalize(struct JITContext *ctx) {
    return ctx->code_buffer;
}
```

**Using JIT compiler:**

```c
struct JITContext ctx;
jit_init(&ctx, 4096);

// Generate: mov eax, 42; ret
jit_emit_mov_eax_imm32(&ctx, 42);
jit_emit_ret(&ctx);

int (*func)(void) = jit_finalize(&ctx);
printf("Result: %d\n", func());  // Prints: 42

munmap(ctx.code_buffer, ctx.buffer_size);
```

### Stack-Based Code Generation

**Generate code on stack (dangerous but sometimes used):**

```c
int execute_from_stack(void) {
    // Make stack executable (generally bad practice)
    unsigned char code[16];
    
    // Generate code
    code[0] = 0xB8;  // mov eax, 42
    *(int32_t*)(&code[1]) = 42;
    code[5] = 0xC3;  // ret
    
    // Make stack executable (Linux)
    size_t page_size = sysconf(_SC_PAGESIZE);
    void *page = (void*)((uintptr_t)code & ~(page_size - 1));
    mprotect(page, page_size, PROT_READ | PROT_WRITE | PROT_EXEC);
    
    // Execute
    int (*func)(void) = (int(*)(void))code;
    return func();
}
```

**[Inference]** Executing code from the stack is dangerous and defeats security measures like DEP/NX. Avoid in production code.

### Performance Considerations

**Self-modifying code penalties:**

- Instruction cache invalidation
- Pipeline flush
- Branch prediction reset
- Store-to-load forwarding stall

**Measuring SMC overhead:**

```c
#include <time.h>

void benchmark_smc(void) {
    clock_t start, end;
    int iterations = 1000000;
    
    // Benchmark normal execution
    start = clock();
    for (int i = 0; i < iterations; i++) {
        normal_function();
    }
    end = clock();
    double normal_time = (double)(end - start) / CLOCKS_PER_SEC;
    
    // Benchmark with self-modification before each call
    start = clock();
    for (int i = 0; i < iterations; i++) {
        modify_function();  // Modifies code
        modified_function();
    }
    end = clock();
    double smc_time = (double)(end - start) / CLOCKS_PER_SEC;
    
    printf("Normal: %.3f seconds\n", normal_time);
    printf("SMC: %.3f seconds\n", smc_time);
    printf("Overhead: %.1f%%\n", (smc_time/normal_time - 1) * 100);
}
```

### Security Implications

**Security concerns with SMC:**

- Makes static analysis difficult
- Complicates malware detection
- Can bypass code signing
- W^X (Write XOR Execute) policies prevent SMC

**W^X compliance:** Modern systems enforce that memory is either writable OR executable, not both:

```c
void* allocate_code_wx(size_t size) {
    // Allocate writable memory
    void *mem = mmap(NULL, size, PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    
    // Write code
    unsigned char *code = (unsigned char*)mem;
    code[0] = 0xB8;  // mov eax, 42
    *(int32_t*)(&code[1]) = 42;
    code[5] = 0xC3;  // ret
    
    // Make executable, remove write permission
    mprotect(mem, size, PROT_READ | PROT_EXEC);
    
    return mem;
}
```

**JIT compilation in sandboxed environments:** Some environments (iOS, WebAssembly) restrict JIT compilation. Workarounds:

- Ahead-of-time compilation
- Interpreter with optimization
- Template-based code generation

### Debugging Self-Modifying Code

**Challenges:**

- Debuggers show original code, not modified
- Breakpoints may be overwritten
- Disassembly becomes invalid after modification

**Techniques:**

```c
void debug_print_code(void *addr, size_t len) {
    unsigned char *code = (unsigned char*)addr;
    printf("Code at %p:\n", addr);
    for (size_t i = 0; i < len; i++) {
        printf("%02X ", code[i]);
        if ((i + 1) % 16 == 0) printf("\n");
    }
    printf("\n");
}

// Use before and after modification
debug_print_code(func, 32);
modify_code(func);
debug_print_code(func, 32);
```

**GDB hardware breakpoints:**

```
(gdb) hbreak *0x400500    # Hardware breakpoint survives code modification
(gdb) watch *0x400500     # Watch for writes to code location
```

### Code Cave Technique

**Finding unused space in executable for code injection:**

```c
void* find_code_cave(void *start, size_t len, size_t cave_size) {
    unsigned char *ptr = (unsigned char*)start;
    size_t consecutive_nops = 0;
    
    for (size_t i = 0; i < len; i++) {
        if (ptr[i] == 0x90 || ptr[i] == 0xCC) {  // NOP or INT3
            consecutive_nops++;
            if (consecutive_nops >= cave_size) {
                return &ptr[i - cave_size + 1];
            }
        } else {
            consecutive_nops = 0;
        }
    }
    
    return NULL;
}
```

**Using code cave:**

```c
void inject_into_cave(void *cave, void *inject_code, size_t code_size) {
    make_writable(cave, code_size);
    memcpy(cave, inject_code, code_size);
    flush_instruction_cache(cave, code_size);
}
```

### Anti-Debugging with SMC

**[Inference]** Self-modifying code can detect and respond to debugging attempts:

```nasm
section .text

anti_debug_check:
    ; Check for debugger (simplified)
    xor eax, eax
    ; Various detection methods...
    test eax, eax
    jz .no_debugger
    
    ; Debugger detected - modify code to crash or mislead
    lea rdi, [rel sensitive_function]
    mov byte [rdi], 0xCC    ; Replace with INT3
    
.no_debugger:
    ret

sensitive_function:
    ; This might be modified to INT3 if debugger detected
    mov eax, 42
    ret
```

**Key Points:**

- Self-modifying code changes its own instructions at runtime
- Memory protection must be changed before modifying code (PROT_WRITE)
- x86 maintains instruction cache coherency but has performance penalty
- [Inference] Cross-core modification requires explicit cache flushing on some platforms
- JIT compilation is primary legitimate use of runtime code generation
- W^X (Write XOR Execute) policies restrict simultaneous write and execute permissions
- [Inference] Self-modifying code complicates debugging and security analysis significantly
- Modern security features (DEP, ASLR, code signing) limit SMC usage
- [Unverified] Performance overhead of SMC varies widely based on CPU architecture and modification frequency

**Important related topics for deeper understanding:** JIT compiler optimization techniques, Instruction encoding and decoding algorithms, DEP/NX bypass techniques, Code obfuscation and packing methods, Hardware breakpoint implementation, Branch prediction and pipeline behavior with SMC

---

# Reverse Engineering Fundamentals

Reverse engineering is the process of analyzing a compiled binary to understand its functionality, structure, and behavior without access to source code. This discipline combines low-level technical knowledge with analytical skills to extract meaningful information from machine code. Applications include security analysis, malware research, software compatibility, vulnerability discovery, and understanding proprietary systems.

## Disassembly vs Decompilation

Disassembly and decompilation are two fundamental approaches to converting compiled binaries back into human-readable form, each with distinct characteristics, strengths, and limitations.

### Disassembly

Disassembly converts machine code bytes into assembly language mnemonics. This process is relatively deterministic because there's a direct, well-defined mapping between opcodes and assembly instructions.

**Process**: A disassembler reads binary opcodes and translates them to their assembly equivalents. For x86-64, the byte sequence `48 89 F8` disassembles to `mov rax, rdi`. The disassembler also resolves addresses, identifies data references, and formats the output for readability.

**Characteristics**:

- **Accuracy**: [Inference] Disassembly is highly accurate for properly identified code regions because the mapping from opcodes to mnemonics is defined by the processor architecture specification
- **Completeness**: Produces instruction-by-instruction representation of the binary
- **Loss of information**: Variable names, function signatures, type information, and high-level constructs are lost during compilation and cannot be recovered through disassembly alone
- **Code vs Data**: [Inference] Distinguishing code from data is challenging in variable-length instruction sets like x86, as data bytes may appear to disassemble into valid instructions

**Linear Sweep Disassembly**: Disassembles sequentially from start to end, treating everything as code. Simple but prone to errors when encountering data embedded in code sections or when dealing with indirect jumps.

```nasm
; Linear sweep example
00401000: 48 89 F8        mov rax, rdi
00401003: C3              ret
00401004: 90              nop          ; Could be data, not code
00401005: 90              nop
```

**Recursive Traversal Disassembly**: Follows control flow starting from known entry points (program entry, exported functions). Disassembles an instruction, identifies its successors (next instruction, jump targets), and recursively processes them. [Inference] This approach is more accurate as it only disassembles reachable code, but may miss code reached through indirect jumps or complex control flow.

```nasm
; Recursive traversal follows control flow
00401000: 48 89 F8        mov rax, rdi      ; Start here
00401003: 48 85 FF        test rdi, rdi
00401006: 74 05           je 0x40100D       ; Follow jump target
00401008: 48 C1 E0 02     shl rax, 2
0040100C: C3              ret               ; End of path
0040100D: 31 C0           xor eax, eax      ; Jump target
0040100F: C3              ret
```

**Challenges in Disassembly**:

**Indirect Jumps and Calls**: Computed jump targets (jump tables, function pointers) are difficult to resolve statically:

```nasm
lea rax, [rel jump_table]
mov edx, [rax + rcx*4]      ; Load offset from table
add rax, rdx
jmp rax                      ; Jump to computed address
```

[Inference] The disassembler cannot determine all possible targets without runtime information or additional analysis.

**Code Obfuscation**: Intentional obfuscation complicates disassembly:

- Junk instructions that never execute
- Opaque predicates (always true/false conditions)
- Self-modifying code
- Overlapping instructions (jumping into middle of instruction)

**Mixed Code and Data**: x86 allows data in code sections and code in data sections, requiring heuristics to distinguish them.

**Position-Independent Code**: PIC uses complex addressing modes (RIP-relative on x86-64) that make address resolution more difficult:

```nasm
lea rdi, [rel data]         ; Address relative to instruction pointer
call function@PLT           ; Call through Procedure Linkage Table
```

### Decompilation

Decompilation attempts to reconstruct high-level source code (C, C++, etc.) from machine code. This is a complex process involving multiple stages of analysis and transformation.

**Process**: Decompilation consists of several phases:

1. **Disassembly**: Convert machine code to assembly
2. **Control Flow Recovery**: Build control flow graph from assembly
3. **Data Flow Analysis**: Track variable usage and transformations
4. **Type Inference**: Deduce variable types from usage patterns
5. **Idiom Recognition**: Identify compiler-generated patterns
6. **Structure Recovery**: Reconstruct loops, conditionals, function calls
7. **Code Generation**: Generate high-level language syntax

**Characteristics**:

- **Approximation**: [Unverified] Decompilation produces an approximation of the original source, not an exact recreation, as compilation is a lossy process
- **Readability**: Output is more human-readable than assembly, resembling high-level code
- **Information Recovery**: [Inference] Through analysis, decompilers can infer types, structures, and control flow, though variable names and comments are typically unrecoverable
- **Complexity**: Decompilation is computationally expensive and heuristic-based, with varying accuracy depending on optimization level and code complexity

**Example**:

**Original C Code**:

```c
int factorial(int n) {
    if (n <= 1) {
        return 1;
    }
    return n * factorial(n - 1);
}
```

**Compiled Assembly** (x86-64, simplified):

```nasm
factorial:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    mov [rbp-4], edi        ; Store n
    cmp dword [rbp-4], 1
    jg .L2
    mov eax, 1              ; Return 1
    jmp .L3
.L2:
    mov eax, [rbp-4]
    sub eax, 1
    mov edi, eax
    call factorial          ; Recursive call
    imul eax, [rbp-4]       ; Multiply result by n
.L3:
    leave
    ret
```

**Decompiled Code** (approximate):

```c
int factorial(int param_1) {
    int result;
    if (param_1 <= 1) {
        result = 1;
    } else {
        result = param_1 * factorial(param_1 - 1);
    }
    return result;
}
```

The decompiled output closely resembles the original but uses generic names like `param_1` and `result` instead of `n`.

**Challenges in Decompilation**:

**Compiler Optimizations**: Aggressive optimizations transform code significantly:

- **Inlining**: Functions may be expanded inline, eliminating call boundaries
- **Loop unrolling**: Loops may be partially or fully unrolled
- **Register allocation**: Complex register usage patterns obscure variable identity
- **Dead code elimination**: Unused code paths are removed
- **Instruction reordering**: Instructions may be rearranged for performance

[Inference] Heavy optimization makes it difficult to identify original code structure, as the compiler has fundamentally reorganized the logic.

**Type Information Loss**: C/C++ compilation discards type information. Decompilers must infer types from usage:

```nasm
mov eax, [rdi]              ; Load from pointer
add eax, 5                  ; Add immediate
mov [rdi], eax              ; Store back
```

[Inference] This could be `*ptr += 5` where ptr is `int*`, `char*`, or another type. The decompiler uses context (operations, data size) to infer the type.

**Aliasing and Pointer Analysis**: Determining what pointers reference is undecidable in general:

```c
void func(int *a, int *b) {
    *a = 10;
    *b = 20;
    // Does *a still equal 10? Only if a != b
}
```

[Inference] Conservative analysis assumes worst-case (all pointers may alias), producing less readable code.

**Structure and Array Recovery**: Differentiating between arrays, structures, and pointers:

```nasm
mov eax, [rdi + 8]          ; Could be array[2], struct.field, or *(ptr+8)
```

[Inference] Decompilers use access patterns (multiple offsets, consistent spacing) to infer data structures.

**Control Flow Obfuscation**: Complex jumps, computed gotos, and exception handlers complicate structure recovery:

```nasm
lea rax, [rel .L1]
mov ecx, edx
add rax, rcx
jmp rax                     ; Computed jump
```

**Calling Conventions**: Mixing calling conventions or hand-written assembly may violate assumptions about parameter passing and register usage.

**Virtual Functions and Polymorphism**: C++ virtual function calls through vtables are difficult to resolve:

```nasm
mov rax, [rdi]              ; Load vtable pointer
mov rax, [rax + 16]         ; Load function pointer from vtable
call rax                    ; Indirect call
```

[Inference] Without type information, determining which virtual function is called requires complex analysis.

### Comparison

**Accuracy**:

- Disassembly: High accuracy for code regions, direct translation
- Decompilation: [Inference] Approximate reconstruction, accuracy depends on heuristics and optimization level

**Readability**:

- Disassembly: Low-level, verbose, requires assembly knowledge
- Decompilation: High-level, resembles source code, more accessible

**Detail Level**:

- Disassembly: Instruction-level detail, every operation visible
- Decompilation: Statement-level detail, some low-level details abstracted

**Use Cases**:

- Disassembly: Performance analysis, exploit development, understanding specific instruction sequences, analyzing obfuscated code
- Decompilation: Algorithm understanding, porting to other languages, security auditing, recovering lost source code

**Tools**:

- Disassembly: objdump, ndisasm, IDA Pro, Ghidra, Binary Ninja, Hopper
- Decompilation: Hex-Rays (IDA Pro plugin), Ghidra decompiler, RetDec, Snowman, JEB

### Hexadecimal View

Before disassembly or decompilation, reverse engineers often examine raw bytes in hexadecimal:

```
Offset    Hex Bytes                         ASCII
00000000: 55 48 89 E5 48 83 EC 10 89 7D FC  UH..H....}.
0000000B: 83 7D FC 01 7F 07 B8 01 00 00 00  .}..........
00000016: EB 14 8B 45 FC 83 E8 01 89 C7 E8  ...E........
```

[Inference] Hex view is essential for identifying signatures, finding strings, detecting encryption/compression, and understanding data layout. Patterns in hex can reveal file format structures, magic numbers, and encoded data.

## Static Analysis Techniques

Static analysis examines a binary without executing it. This approach is safe (cannot trigger malicious behavior), comprehensive (can analyze all code paths), and reproducible, but has limitations in handling runtime behaviors.

### Binary File Analysis

**File Format Examination**: Understanding the executable format (PE, ELF, Mach-O) reveals structural information:

**Headers**: Provide metadata about target architecture, entry point, required libraries, and section layout:

```bash
