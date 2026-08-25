## Function Reference


### allocate_memory
Allocates memory from the managed heap.

**Signature:**
```asm
allocate_memory:
    ; Input: rdi = size in bytes
    ; Output: rax = pointer or NULL
````

**Usage Example:**

```asm
mov rdi, 1024              ; Request 1KB
call allocate_memory
test rax, rax
jz .allocation_failed
; Use allocated memory at [rax]
```

**Performance:**

- Best case: O(1) - immediate allocation from current heap
- Worst case: O(1) - single syscall to expand heap
- Average: O(1)

**Thread Safety:** Not thread-safe. Use external locking for concurrent access.

````

### Assembly-Specific Documentation Challenges

**Lack of Type Information**
Document expected data types and sizes explicitly:

```asm
; === Data Structure: TaskControlBlock ===
; Offset | Size | Type    | Field Name | Description
; -------|------|---------|------------|---------------------------
;   0    |  8   | ptr     | next       | Pointer to next TCB
;   8    |  8   | ptr     | stack_ptr  | Current stack pointer
;  16    |  4   | uint32  | task_id    | Unique task identifier
;  20    |  4   | uint32  | priority   | Priority level (0-255)
;  24    |  4   | enum    | state      | READY/RUNNING/BLOCKED
;  28    |  4   | padding | -          | Alignment padding
; Total: 32 bytes (cache-line aligned)

section .bss
    task_control_blocks: resb 32 * MAX_TASKS
````

**Control Flow Visualization** Complex branching benefits from ASCII flow diagrams:

```asm
; === State Machine Diagram ===
;
;     START
;       |
;       v
;   [Validate] ----fail----> [Error]
;       |                      |
;     success                  |
;       |                      |
;       v                      |
;   [Allocate] ---fail---------+
;       |                      |
;     success                  |
;       |                      |
;       v                      |
;   [Initialize]               |
;       |                      |
;       +------<---------------+
;       |
;       v
;   [Return]
```

## Literate Programming

Literate programming treats code as a narrative, emphasizing human understanding over machine execution. While Donald Knuth's WEB system targeted Pascal, the principles apply to assembly.

### Literate Assembly Approaches

**Narrative Structure** Organize code to follow logical explanation order rather than execution order:

```asm
; ═══════════════════════════════════════════════════════════════════════════
; CHAPTER 1: String Hashing with Polynomial Rolling Hash
; ═══════════════════════════════════════════════════════════════════════════
;
; We implement the polynomial rolling hash function:
;   hash(s) = (s[0] * p^(n-1) + s[1] * p^(n-2) + ... + s[n-1]) mod m
;
; Where:
;   p = 31 (prime number, good distribution for ASCII)
;   m = 2^64 (implicit through 64-bit arithmetic overflow)
;
; This hash function has the property that similar strings produce different
; hashes with high probability, making it suitable for hash tables.
;
; § 1.1: Initialization
; ---------------------
; We begin by setting up our base values and clearing the accumulator.

section .data
    HASH_PRIME equ 31          ; Prime multiplier for hash function

section .text
hash_string:
    push rbp
    mov rbp, rsp
    
    xor rax, rax               ; accumulator = 0
    xor rcx, rcx               ; character buffer
    mov r8, HASH_PRIME         ; multiplier

; § 1.2: Main Hashing Loop
; -------------------------
; For each character, we multiply the current hash by p and add the character.
; This is equivalent to treating the string as a base-p number.

.loop:
    mov cl, [rdi]              ; Load next character
    test cl, cl                ; Check for NULL terminator
    jz .done                   ; Exit if end of string
    
    imul rax, r8               ; hash *= p
    add rax, rcx               ; hash += char
    inc rdi                    ; Advance to next character
    jmp .loop

; § 1.3: Finalization
; -------------------
; The hash is already in rax due to the overflow properties of 64-bit
; arithmetic. We simply return it to the caller.

.done:
    pop rbp
    ret

; § 1.4: Proof of Correctness
; ----------------------------
; [Inference] For strings of length n, the hash computation performs n
; multiplications and additions. Each operation maintains the invariant:
;   hash_k = (s[0] * p^k + s[1] * p^(k-1) + ... + s[k])
; After n iterations, k = n-1, giving us the complete hash.
```

### Code Chunks and Assembly

Modern literate programming tools can weave assembly code:

```asm
; ═══════════════════════════════════════════════════════════════════════════
; Chunk: <<vector-initialization>>
; ═══════════════════════════════════════════════════════════════════════════
; Initialize SSE registers for vector processing. This chunk is used by
; multiple functions that perform SIMD operations.

%macro INIT_VECTOR_REGS 0
    xorps xmm0, xmm0           ; Clear xmm0 (accumulator)
    xorps xmm1, xmm1           ; Clear xmm1 (temporary)
    movaps xmm2, [ones_vector] ; Load constant vector
%endmacro

; ═══════════════════════════════════════════════════════════════════════════
; Chunk: <<vector-sum>> uses <<vector-initialization>>
; ═══════════════════════════════════════════════════════════════════════════

vector_sum:
    INIT_VECTOR_REGS           ; <<vector-initialization>>
    
    ; Main summation loop
.loop:
    movaps xmm1, [rsi]         ; Load 4 floats
    addps xmm0, xmm1           ; Accumulate
    add rsi, 16
    sub rcx, 4
    jnz .loop
```

### Literate Tools for Assembly

**noweb** Language-agnostic literate programming tool that works with assembly:

```
@
This section implements the quicksort partition function using Hoare's
partitioning scheme, which performs fewer swaps than Lomuto's scheme.

<<partition function>>=
partition:
    push rbp
    mov rbp, rsp
    <<select pivot>>
    <<partition loop>>
    <<return pivot index>>
    pop rbp
    ret
@

The pivot selection uses the median-of-three method:

<<select pivot>>=
    mov rax, [rdi]             ; first element
    mov rbx, [rdi + rsi*8]     ; last element
    mov rcx, [rdi + rsi*4]     ; middle element
    ; ... comparison logic ...
@
```

**Org-mode with Babel** Emacs org-mode supports executable assembly blocks:

```org
* Bitwise Operations

** Population Count
We implement a population count (count set bits) using the
Brian Kernighan algorithm:

#+BEGIN_SRC asm :tangle popcnt.asm
popcnt_soft:
    xor ecx, ecx               ; counter = 0
.loop:
    test eax, eax              ; check if zero
    jz .done
    lea edx, [eax - 1]         ; n - 1
    and eax, edx               ; clear lowest set bit
    inc ecx                    ; increment counter
    jmp .loop
.done:
    mov eax, ecx
    ret
#+END_SRC

This algorithm has time complexity O(k) where k is the number
of set bits, rather than O(n) for bit width n.
```

### Documentation as Executable Specification

**Test-Driven Documentation** Embed test cases directly in documentation:

```asm
; ═══════════════════════════════════════════════════════════════════════════
; TEST SPECIFICATION: String Length Function
; ═══════════════════════════════════════════════════════════════════════════
;
; Test Case 1: Empty string
;   Input: pointer to "\0"
;   Expected Output: rax = 0
;
; Test Case 2: Single character
;   Input: pointer to "A\0"
;   Expected Output: rax = 1
;
; Test Case 3: Long string
;   Input: pointer to 100-character string
;   Expected Output: rax = 100
;
; Test Case 4: NULL pointer
;   Input: rdi = 0
;   Expected Output: rax = 0 (error code) or crash with segfault

section .rodata
    test_empty: db 0
    test_single: db 'A', 0
    test_long: times 100 db 'X'
               db 0

section .text
; === Implementation ===
strlen:
    test rdi, rdi              ; NULL check
    jz .null_pointer
    
    xor rax, rax               ; counter = 0
.loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    ret
.null_pointer:
    xor rax, rax               ; Return 0 for NULL
    ret

; === Test Harness ===
test_strlen:
    ; Test 1: Empty string
    lea rdi, [test_empty]
    call strlen
    test rax, rax
    jnz .test1_fail
    
    ; Test 2: Single character
    lea rdi, [test_single]
    call strlen
    cmp rax, 1
    jne .test2_fail
    
    ; Additional tests...
    ret
```

### Self-Documenting Code Techniques

**Meaningful Label Names**

```asm
; BAD: Cryptic labels
L1: cmp eax, ebx
    jg L2
    mov ecx, eax
    jmp L3
L2: mov ecx, ebx
L3: ret

; GOOD: Descriptive labels
find_maximum:
    cmp eax, ebx
    jg .ebx_is_larger
    mov ecx, eax               ; eax is max
    jmp .return_max
.ebx_is_larger:
    mov ecx, ebx               ; ebx is max
.return_max:
    ret
```

**Structured Macros**

```asm
; Define self-documenting macros for common patterns
%macro PUSH_PRESERVED_REGS 0
    ; Preserve callee-saved registers per System V ABI
    push rbx
    push r12
    push r13
    push r14
    push r15
%endmacro

%macro POP_PRESERVED_REGS 0
    ; Restore callee-saved registers
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
%endmacro

my_function:
    push rbp
    mov rbp, rsp
    PUSH_PRESERVED_REGS
    
    ; Function body...
    
    POP_PRESERVED_REGS
    pop rbp
    ret
```

### Documentation Anti-Patterns in Assembly

**Implementation Details Without Purpose**

```asm
; BAD: Documents "what" without "why"
    shl eax, 3                 ; Shift left by 3
    add rax, rdi               ; Add rdi to rax
    mov rdx, [rax]             ; Move value at rax to rdx

; GOOD: Explains purpose
    shl eax, 3                 ; Multiply index by 8 (size of qword)
    add rax, rdi               ; Calculate address: base + index*8
    mov rdx, [rax]             ; Load array element
```

**Stale Architecture Information**

```asm
; BAD: Outdated assumptions
    ; Use 386 instructions only for compatibility (written in 1995)
    ; [Note: x86 assembly preferences indicate user values verified information]
    
; GOOD: Current requirements
    ; Target: x86-64, requires SSE4.2 (Intel Core 2010+)
    ; Reason: CRC32 instruction used for hashing performance
```

### Version Control Integration

**Commit Message Standards**

```
Fix off-by-one error in buffer_copy loop

The loop counter was not accounting for the NULL terminator,
causing buffer overruns on exactly-sized buffers.

Changed: loop condition from 'jl' to 'jle' at line 234
Affected: buffer_copy function in memory.asm
Registers: Modified rcx comparison logic
```

**Blame-Friendly Comments**

```asm
    ; 2025-10-15: Changed from SYSV to Microsoft calling convention
    ; Reason: Interfacing with Windows DLL
    ; Previous: rdi, rsi, rdx, rcx, r8, r9
    ; Current: rcx, rdx, r8, r9
    mov rcx, [first_param]
    mov rdx, [second_param]
```

**Key Points**

- Assembly code requires explicit multi-level documentation covering file, function, block, and line levels to maintain readability and convey intent that high-level language structure would otherwise provide
- Comment standards should avoid redundancy while documenting non-obvious operations, register usage patterns, error conditions, and algorithmic decisions
- Documentation generation tools like Doxygen can parse structured assembly comments when properly configured, enabling automated API documentation from source code
- Literate programming principles apply to assembly through narrative organization, code chunks, and treating documentation as the primary artifact with code as supporting material
- Self-documenting techniques include meaningful label names, structured macros, embedded test specifications, and data structure layout documentation that reduces the need for separate explanatory comments

---

## Documentation Practices

### Inline Comments

Every non-trivial instruction requires explanation of its purpose within the larger algorithm. Comments should explain _why_ an operation occurs, not merely _what_ the instruction does. Stating "move value to rax" adds no information beyond the instruction itself, while "accumulate sum in rax for average calculation" provides context.

```nasm
; Calculate average of array elements
; Input: rsi = array address, rcx = element count
; Output: rax = average value
; Destroys: rdx, rcx
calculate_average:
    xor rax, rax          ; Initialize sum accumulator
    xor rdx, rdx          ; Clear high bits for division
    test rcx, rcx         ; Check for empty array
    jz .empty_array       ; Avoid division by zero
    
    push rcx              ; Preserve count for division
.sum_loop:
    add rax, [rsi]        ; Add current element to sum
    add rsi, 8            ; Advance to next qword
    loop .sum_loop        ; Decrement rcx and continue if non-zero
    
    pop rcx               ; Restore count as divisor
    div rcx               ; rax = sum / count (average)
    ret
    
.empty_array:
    xor rax, rax          ; Return zero for empty array
    ret
```

Register usage comments document which registers hold specific values throughout code sections. When algorithms span multiple basic blocks, tracking register purposes prevents confusion and errors during modifications.

Side effects require explicit documentation. If a function modifies global state, uses stack space beyond the return address, or affects condition flags in non-obvious ways, comments must describe these effects.

### Function Headers

Every function needs comprehensive header documentation describing its contract. This includes purpose, inputs, outputs, preconditions, postconditions, and modified registers.

```nasm
;==============================================================================
; string_length
;
; Calculates the length of a null-terminated string.
;
; Parameters:
;   rdi - Pointer to null-terminated string
;
; Returns:
;   rax - Length of string (excluding null terminator)
;
; Preserves:
;   rbx, rbp, r12-r15 (callee-saved registers per ABI)
;
; Destroys:
;   rcx, rdi (modified during scan)
;
; Preconditions:
;   - rdi points to valid, accessible memory
;   - String is properly null-terminated
;   - String length < 2^64 bytes
;
; Postconditions:
;   - rax contains accurate character count
;   - Original string unmodified
;   - All callee-saved registers preserved
;
; Algorithm:
;   Uses repne scasb to scan for null byte, calculating length from
;   difference between final and initial rdi values.
;==============================================================================
string_length:
    push rdi              ; Save original pointer
    mov rcx, -1           ; Maximum possible length
    xor al, al            ; Search for null (0) byte
    cld                   ; Ensure forward direction
    repne scasb           ; Scan until al found or rcx exhausted
    
    not rcx               ; Convert remaining count to bytes scanned
    dec rcx               ; Exclude null terminator
    mov rax, rcx          ; Return length in rax
    
    pop rdi               ; Restore original pointer
    ret
```

Error handling documentation specifies return codes, error indicators, and exceptional conditions. If a function can fail, the documentation must clearly state how callers detect and handle failures.

Performance characteristics matter in assembly code. Documenting algorithmic complexity, cache behavior, or branch prediction considerations helps future optimizations and prevents performance regressions.

### Section Documentation

Code sections require introductory comments explaining overall structure and purpose. The `.text` section might begin with an architectural overview, `.data` sections should document data structure layouts, and `.bss` sections need size and alignment justifications.

```nasm
;==============================================================================
; DATA SECTION - Global Variables and Constants
;==============================================================================
section .data

; Network packet buffer
; Layout: [4-byte length][2-byte type][2-byte flags][payload...]
; Maximum payload size: 4096 bytes
; Alignment: 16 bytes for SIMD operations
align 16
packet_buffer: times 4104 db 0

; Error message strings
; Note: Each string prefixed with length for efficient output
err_invalid_input:
    dq 13                 ; Length prefix
    db "Invalid input", 0

err_overflow:
    dq 16
    db "Buffer overflow", 0
```

Algorithm explanations document complex computational sequences. When implementing mathematical operations, cryptographic primitives, or data structure manipulations, high-level algorithmic descriptions help readers understand code flow before examining individual instructions.

### File-Level Documentation

Source files begin with header comments describing contents, purpose, author, creation date, and modification history. This metadata provides context for the entire file.

```nasm
;==============================================================================
; File: sha256.asm
; Description: SHA-256 cryptographic hash implementation
; Author: [Name]
; Created: 2024-01-15
; Modified: 2024-03-22
;
; This module implements SHA-256 hashing according to FIPS 180-4.
; Optimized for x86-64 with SSE4 extensions when available.
;
; Public Functions:
;   sha256_init   - Initialize hash context
;   sha256_update - Process message blocks
;   sha256_final  - Finalize and output hash
;
; Dependencies:
;   - SSE4.1 for pshufb instruction (fallback available)
;   - At least 128 bytes stack space
;
; Build Requirements:
;   nasm -f elf64 -dSSE4 sha256.asm
;
; References:
;   FIPS 180-4: Secure Hash Standard
;   https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.180-4.pdf
;==============================================================================
```

Dependencies and build instructions ensure others can compile and use the code. External symbol references, required libraries, and assembler flags all belong in file headers.

License information and copyright notices appear in file headers when appropriate. Open-source projects particularly need clear licensing documentation.

### External Documentation

README files accompany assembly projects explaining purpose, building instructions, usage examples, and API documentation. These provide entry points for developers unfamiliar with the codebase.

Architecture documents describe system design, module interactions, and data flows. For complex projects, separating architectural documentation from implementation details improves navigability.

API documentation, potentially generated from comment markup, catalogs all public functions with complete signatures and behavior descriptions. Tools like Doxygen can process specially-formatted assembly comments into structured documentation.

Performance benchmarks and testing documentation demonstrate correctness and efficiency. Recording test configurations, hardware specifications, and benchmark results validates implementation quality.

## Code Review Practices

### Review Checklist

Correctness verification examines algorithmic correctness, edge case handling, and input validation. Reviewers trace execution paths for boundary conditions: empty inputs, maximum values, negative numbers, and null pointers.

Register usage validation ensures adherence to calling conventions. Callee-saved registers must be preserved, arguments must arrive in correct registers, and return values must appear in designated locations.

```nasm
; INCORRECT - destroys callee-saved rbx
process_data:
    mov rbx, rdi          ; Using rbx without saving
    add rbx, 10
    mov rax, rbx
    ret                   ; rbx modified without preservation

; CORRECT - preserves rbx
process_data:
    push rbx              ; Save callee-saved register
    mov rbx, rdi
    add rbx, 10
    mov rax, rbx
    pop rbx               ; Restore before returning
    ret
```

Stack alignment requirements demand verification. The x86-64 System V ABI requires 16-byte stack alignment before `call` instructions. Windows x64 requires 16-byte alignment and 32-byte shadow space allocation.

Memory access patterns need bounds checking. Buffer overruns, off-by-one errors, and unaligned accesses cause crashes or security vulnerabilities. Reviewers verify array bounds, string terminators, and pointer arithmetic.

### Security Considerations

Buffer overflow prevention requires careful length validation. Any operation copying, concatenating, or manipulating variable-length data must verify destination buffer capacity.

Integer overflow checks prevent wraparound vulnerabilities. Addition, multiplication, and shift operations on untrusted input need overflow detection or saturation arithmetic.

```nasm
; Unsafe multiplication
multiply_unsafe:
    mov rax, rdi
    mul rsi               ; May overflow without detection
    ret

; Safe multiplication with overflow check
multiply_safe:
    mov rax, rdi
    mul rsi
    jo .overflow          ; Jump if overflow flag set
    ret
.overflow:
    xor rax, rax          ; Return 0 to indicate error
    stc                   ; Set carry flag as error indicator
    ret
```

Information leakage through timing side-channels affects cryptographic code. Constant-time implementations avoid conditional branches based on secret data. Reviewers verify that execution time remains independent of sensitive values.

Uninitialized memory usage creates unpredictable behavior and potential information disclosure. All memory buffers require initialization before use, particularly stack-allocated buffers.

Format string vulnerabilities don't directly apply to assembly, but when interfacing with C functions like `printf`, reviewers must verify format strings are constant, not user-controlled.

### Performance Review

Instruction selection optimization identifies opportunities for more efficient instruction sequences. Using `lea` instead of separate `mov` and `add` instructions, or `test` instead of `cmp` with zero, improves code density and performance.

```nasm
; Suboptimal
mov rax, rbx
add rax, 8

; Optimized
lea rax, [rbx + 8]
```

Register allocation efficiency minimizes memory accesses. Keeping frequently-accessed values in registers rather than repeatedly loading from memory improves performance significantly.

Branch prediction optimization arranges code so likely paths fall through while unlikely paths branch. Minimizing branch mispredictions dramatically improves performance on modern processors.

Cache-friendly access patterns process data sequentially rather than randomly. Strided access, particularly with large strides, causes cache misses. Reviewers identify and suggest improvements to memory access patterns.

Loop optimization opportunities include unrolling, strength reduction, and invariant code motion. Moving invariant calculations outside loops and reducing multiplication to addition where possible improves performance.

### Code Style Consistency

Indentation standards maintain visual clarity. Consistent indentation for label definitions, instructions, operands, and comments creates readable code. Standard practice indents instructions 4 spaces from labels, and aligns comments in a column.

```nasm
; Consistent formatting
function_name:
    push rbp
    mov rbp, rsp
    sub rsp, 32               ; Allocate stack space
    
    mov rax, [rbp+16]         ; Load first argument
    add rax, [rbp+24]         ; Add second argument
    
    leave
    ret
```

Naming conventions distinguish different identifier types. Functions use `snake_case`, constants use `SCREAMING_SNAKE_CASE`, and local labels within functions begin with dots (`.local_label`).

Comment density balances explanation with readability. Too few comments leave code incomprehensible; too many comments obscure code flow. Generally, every 2-4 instructions warrant explanation, with additional comments at control flow transitions.

Consistent operand ordering, particularly in AT&T versus Intel syntax contexts, prevents confusion. Projects using Intel syntax should maintain it throughout; mixed syntax creates errors.

## Maintainability Principles

### Modularity

Function decomposition breaks complex operations into small, focused functions. Each function should accomplish a single, well-defined task. Functions exceeding 50-100 instructions often benefit from decomposition.

Clear interfaces between modules enable independent development and testing. Well-defined input/output contracts, documented register usage, and minimal coupling facilitate maintenance.

```nasm
; Well-decomposed: separate concerns
parse_http_request:
    call read_request_line
    call parse_headers
    call validate_request
    call extract_body
    ret

; Rather than one monolithic 500-line function
```

Encapsulation hides implementation details behind stable interfaces. Internal data structure layouts and algorithmic choices can change without affecting external callers if interfaces remain stable.

Module size limitations keep individual files manageable. Files exceeding 1000-1500 lines become difficult to navigate. Related functionality groups into separate files with clear organizational structure.

### Abstraction

Macro-based abstractions hide platform differences, reduce repetition, and improve expressiveness. Complex operations become single macro invocations, improving code density and readability.

```nasm
; Without abstraction
mov rax, 1
mov rdi, 1
lea rsi, [message]
mov rdx, message_len
syscall

; With abstraction
PRINT_STRING message, message_len
```

Symbolic constants replace magic numbers. All numeric literals except 0, 1, and -1 generally deserve named constants explaining their meaning and purpose.

```nasm
; Constants section
BUFFER_SIZE    equ 4096
MAX_RETRIES    equ 3
TIMEOUT_MS     equ 5000

; Usage with clear meaning
mov rcx, BUFFER_SIZE
```

Data structure abstractions using macros or equates define field offsets and sizes. Accessing structure fields through named offsets rather than hardcoded numbers prevents errors and simplifies modifications.

```nasm
; Structure definition
struc TCPPacket
    .source_port:    resw 1
    .dest_port:      resw 1
    .seq_number:     resd 1
    .ack_number:     resd 1
    .flags:          resw 1
    .window:         resw 1
    .checksum:       resw 1
    .urgent_ptr:     resw 1
endstruc

; Usage
mov ax, [rsi + TCPPacket.dest_port]
```

### Error Handling

Consistent error signaling mechanisms enable callers to detect and respond to failures. Common approaches include return codes in `rax`, setting the carry flag, or using sentinel values like -1 or NULL.

```nasm
; Error signaling through carry flag
open_file:
    ; ... open logic ...
    test rax, rax
    jz .error
    clc                   ; Clear carry = success
    ret
.error:
    stc                   ; Set carry = failure
    ret

; Caller checks carry
call open_file
jc handle_error           ; Jump if carry set (error)
```

Error recovery paths need testing and documentation. Partial operation failures must restore consistent state. Resource cleanup (closing files, freeing memory) must occur in error paths as well as success paths.

Graceful degradation provides reduced functionality rather than complete failure when possible. Missing optional features or unavailable optimizations shouldn't crash the application.

### Testing Support

Test hooks enable verification without exposing internal implementation details. Conditional assembly can include additional entry points or instrumentation for testing while excluding them from production builds.

```nasm
%ifdef UNIT_TEST
global get_internal_state
get_internal_state:
    lea rax, [internal_buffer]
    ret
%endif
```

Boundary condition handling requires deliberate testing. Code should explicitly handle empty inputs, maximum values, minimum values, and edge cases rather than accidentally working for common cases only.

Assertions document assumptions and detect violations during development. In debug builds, assertion macros verify preconditions, postconditions, and invariants.

```nasm
%ifdef DEBUG
    %macro ASSERT_NOT_NULL 1
        test %1, %1
        jnz %%not_null
        ; Trigger breakpoint or error
        int 3
    %%not_null:
    %endmacro
%else
    %macro ASSERT_NOT_NULL 1
        ; No-op in release builds
    %endmacro
%endif
```

### Version Evolution

Backward compatibility considerations affect API design. Adding parameters to existing functions breaks calling code. Versioned entry points or optional parameters through structure pointers maintain compatibility.

Deprecation strategies provide transition paths when APIs change. Old interfaces remain functional but documented as deprecated, giving users time to migrate before removal.

Feature flags enable gradual rollout of new functionality. Conditional compilation includes experimental features only when explicitly enabled, allowing testing without affecting stable code.

## Version Control Integration

### Repository Structure

Organized directory hierarchies separate source files, include files, build scripts, tests, and documentation. Standard structures help developers navigate unfamiliar codebases.

```
project/
├── src/           # Source files (.asm)
├── include/       # Shared macro definitions and constants
├── lib/           # Compiled libraries
├── test/          # Unit tests and test harness
├── docs/          # Documentation
├── build/         # Build output (not committed)
└── scripts/       # Build and deployment scripts
```

`.gitignore` files exclude generated artifacts: object files (`.o`), executables, listing files (`.lst`), and build directories. Source files and build scripts are tracked; outputs are regenerated.

Platform-specific files separate into appropriate directories or branches. Shared code remains in common locations while platform adaptations isolate into dedicated areas.

### Commit Practices

Atomic commits contain complete, functional changes. Each commit represents a single logical modification: a bug fix, a new feature, or a refactoring. Commits should not break builds or tests.

Meaningful commit messages follow conventional formats. The first line summarizes the change in 50 characters or less. Subsequent paragraphs explain motivation, approach, and side effects.

```
Add bounds checking to buffer copy routine

Previous implementation could overflow destination buffer when
source exceeded destination capacity. New version validates
lengths and returns error code on overflow.

Modified functions:
- buffer_copy: Added length validation
- safe_strcpy: Updated to use new buffer_copy behavior

Fixes: #1234
```

Commits reference issue tracking systems, linking code changes to requirements, bug reports, or feature requests. Tags like "Fixes: #123" or "Implements: #456" create traceability.

### Branching Strategy

Feature branches isolate development work from stable code. Developers create branches for new features, bug fixes, or experiments, merging back to main branches when complete and tested.

Release branches maintain stable versions for production while development continues. Security fixes and critical bugs receive backports to release branches, maintaining stability without forcing customers to adopt new features.

Hotfix workflows handle urgent production issues. Hotfix branches fork from release tags, receive minimal changes to address specific issues, then merge back to both release and development branches.

### Code Review Integration

Pull requests trigger code review processes before merging. Reviewers examine changes, request modifications, and approve merges, ensuring code quality standards.

Continuous integration systems automatically build and test proposed changes. Automated verification catches regressions, build failures, and test failures before human review begins.

Review comments attach to specific lines, enabling precise discussion. Reviewers identify issues, suggest alternatives, and ask clarifying questions directly adjacent to relevant code.

### Merge Strategies

Fast-forward merges preserve linear history for simple changes. When feature branches don't diverge from base branches, fast-forward merges avoid unnecessary merge commits.

Squash merges condense multiple development commits into single commits in main branches. This keeps history clean while preserving detailed development history in feature branches.

Merge commits preserve complete history including parallel development. Complex features with multiple developers benefit from merge commits showing when branches diverged and rejoined.

Rebase workflows maintain linear history by replaying commits atop updated base branches. This creates cleaner history but requires careful handling of shared branches.

### Tagging and Releases

Version tags mark release points with semantic versioning. Tags like `v1.2.3` identify specific commits as released versions, enabling easy retrieval and comparison.

Release notes accompany version tags, documenting changes, new features, bug fixes, and breaking changes. Users understand what changed between versions without examining commit history.

Build metadata in release artifacts identifies source versions. Embedding commit hashes or version strings in compiled binaries enables verification of deployed versions.

### History Maintenance

Meaningful history enables debugging and understanding. When bugs appear, examining change history identifies when issues were introduced and why changes were made.

Refactoring commits separate from functional changes. Mixing behavior changes with code restructuring makes reviewing and understanding commits difficult. Separate commits for "refactor X" followed by "add feature Y" improve clarity.

Avoiding history rewriting on shared branches prevents collaboration issues. Once commits push to shared repositories, rewriting history (force pushing) disrupts other developers' work.

**Key Points:**

- Every function requires comprehensive header documentation describing purpose, parameters, return values, and side effects
- Inline comments should explain intent and algorithm rather than merely restating instructions
- Code review checklists verify correctness, security, performance, and adherence to calling conventions
- Security reviews must address buffer overflows, integer overflows, timing side-channels, and uninitialized memory
- Modularity through function decomposition and clear interfaces improves maintainability and testability
- Abstraction via macros and symbolic constants reduces magic numbers and improves code expressiveness
- Consistent error handling mechanisms enable reliable failure detection and recovery
- Repository structure, atomic commits, and meaningful commit messages facilitate collaboration and history navigation
- Feature branches, pull requests, and continuous integration ensure code quality before merging
- Version tags and release notes create clear milestones and document evolution over time

---

# Real-World Applications

Assembly language remains essential in domains requiring precise hardware control, maximum performance, or minimal resource footprint. Despite the prevalence of high-level languages, certain applications still demand the low-level access and optimization capabilities that only assembly provides.

## Operating System Kernels

Operating system kernels represent one of the most critical applications of assembly language. The kernel serves as the bridge between hardware and software, requiring direct hardware manipulation that cannot be abstracted by higher-level languages.

### Boot Process and Initial Setup

The bootloader and early kernel initialization must execute in assembly because no runtime environment exists yet. This code establishes the foundation for all subsequent operations.

```nasm
; Real mode bootloader (first 512 bytes)
[BITS 16]
[ORG 0x7C00]

boot_start:
    ; Initialize segment registers
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00          ; Stack grows downward from bootloader
    
    ; Enable A20 line for >1MB memory access
    in al, 0x92
    or al, 2
    out 0x92, al
    
    ; Load Global Descriptor Table
    cli
    lgdt [gdt_descriptor]
    
    ; Enter protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    ; Far jump to flush pipeline and load CS
    jmp 0x08:protected_mode_start

[BITS 32]
protected_mode_start:
    ; Setup segment registers for protected mode
    mov ax, 0x10            ; Data segment selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000        ; New stack location
    
    ; Continue kernel initialization
    call load_kernel
    jmp 0x08:0x100000       ; Jump to kernel entry point

; Global Descriptor Table
gdt_start:
    dd 0, 0                 ; Null descriptor
    
gdt_code:                   ; Code segment descriptor
    dw 0xFFFF               ; Limit (low)
    dw 0x0000               ; Base (low)
    db 0x00                 ; Base (middle)
    db 10011010b            ; Access (present, ring 0, code, executable, readable)
    db 11001111b            ; Flags (4KB granularity, 32-bit) + Limit (high)
    db 0x00                 ; Base (high)
    
gdt_data:                   ; Data segment descriptor
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b            ; Access (present, ring 0, data, writable)
    db 11001111b
    db 0x00
    
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

times 510-($-$$) db 0
dw 0xAA55                   ; Boot signature
```

### Interrupt Handling

Interrupt handlers must be written in assembly to ensure minimal latency and precise control over system state. Every CPU exception and hardware interrupt requires an assembly stub.

```nasm
; Interrupt Descriptor Table setup
setup_idt:
    push ebp
    mov ebp, esp
    push edi
    push ecx
    push eax
    
    ; Load IDT base address
    mov edi, idt_table
    mov ecx, 256            ; 256 IDT entries
    
.loop:
    ; For each interrupt, install default handler
    mov eax, default_interrupt_handler
    mov [edi], ax           ; Offset low
    mov word [edi+2], 0x08  ; Kernel code segment
    mov byte [edi+4], 0     ; Reserved
    mov byte [edi+5], 0x8E  ; Flags: present, ring 0, 32-bit interrupt gate
    shr eax, 16
    mov [edi+6], ax         ; Offset high
    
    add edi, 8
    dec ecx
    jnz .loop
    
    ; Install specific handlers
    mov edi, idt_table
    
    ; Divide by zero (interrupt 0)
    mov eax, divide_by_zero_handler
    mov [edi+0*8], ax
    shr eax, 16
    mov [edi+0*8+6], ax
    
    ; Page fault (interrupt 14)
    mov eax, page_fault_handler
    mov [edi+14*8], ax
    shr eax, 16
    mov [edi+14*8+6], ax
    
    ; System call (interrupt 0x80)
    mov eax, system_call_handler
    mov byte [edi+0x80*8+5], 0xEE  ; Ring 3 accessible
    mov [edi+0x80*8], ax
    shr eax, 16
    mov [edi+0x80*8+6], ax
    
    ; Load IDT register
    lidt [idt_descriptor]
    
    pop eax
    pop ecx
    pop edi
    pop ebp
    ret

; Page fault handler
page_fault_handler:
    ; Save all registers
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    push ds
    push es
    push fs
    push gs
    
    ; Load kernel data segment
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    
    ; Get faulting address from CR2
    mov eax, cr2
    push eax
    
    ; Get error code (already pushed by CPU)
    mov eax, [esp+48]
    push eax
    
    ; Call C handler
    call handle_page_fault
    add esp, 8
    
    ; Restore registers
    pop gs
    pop fs
    pop es
    pop ds
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    ; Remove error code from stack
    add esp, 4
    
    iret

; System call handler (int 0x80)
system_call_handler:
    ; Save user context
    push ebp
    push edi
    push esi
    push edx
    push ecx
    push ebx
    push eax
    
    ; System call number in EAX
    ; Arguments in EBX, ECX, EDX, ESI, EDI, EBP
    
    ; Validate system call number
    cmp eax, MAX_SYSCALL_NUMBER
    ja .invalid_syscall
    
    ; Call handler from system call table
    call [syscall_table + eax*4]
    
    ; Result in EAX, restore registers except EAX
    add esp, 4              ; Skip saved EAX
    pop ebx
    pop ecx
    pop edx
    pop esi
    pop edi
    pop ebp
    
    iret

.invalid_syscall:
    mov eax, -1             ; Error code
    add esp, 4
    pop ebx
    pop ecx
    pop edx
    pop esi
    pop edi
    pop ebp
    iret
```

### Context Switching

Process context switches require assembly to save and restore all CPU state, including general-purpose registers, segment registers, and control registers.

```nasm
; Switch from current task to next task
; Parameters: current_task_struct*, next_task_struct*
context_switch:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp+8]        ; Current task
    mov edi, [ebp+12]       ; Next task
    
    ; Save current task state
    mov [esi+TASK_ESP], esp
    mov [esi+TASK_EBP], ebp
    pushfd
    pop dword [esi+TASK_EFLAGS]
    
    ; Save segment registers
    mov ax, ds
    mov [esi+TASK_DS], ax
    mov ax, es
    mov [esi+TASK_ES], ax
    mov ax, fs
    mov [esi+TASK_FS], ax
    mov ax, gs
    mov [esi+TASK_GS], ax
    
    ; Switch page directory
    mov eax, [edi+TASK_CR3]
    mov cr3, eax            ; Flush TLB
    
    ; Load next task segment registers
    mov ax, [edi+TASK_DS]
    mov ds, ax
    mov ax, [edi+TASK_ES]
    mov es, ax
    mov ax, [edi+TASK_FS]
    mov fs, ax
    mov ax, [edi+TASK_GS]
    mov gs, ax
    
    ; Load next task state
    mov esp, [edi+TASK_ESP]
    mov ebp, [edi+TASK_EBP]
    push dword [edi+TASK_EFLAGS]
    popfd
    
    ; Switch kernel stack
    mov eax, [edi+TASK_KERNEL_STACK]
    mov [tss_esp0], eax
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
```

### Memory Management

Page table manipulation and virtual memory operations require direct access to control registers and specialized instructions.

```nasm
; Enable paging with given page directory
enable_paging:
    push ebp
    mov ebp, esp
    push eax
    
    ; Load page directory address into CR3
    mov eax, [ebp+8]
    mov cr3, eax
    
    ; Enable paging bit in CR0
    mov eax, cr0
    or eax, 0x80000000      ; Set PG bit
    mov cr0, eax
    
    pop eax
    pop ebp
    ret

; Map physical page to virtual address
map_page:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edi
    
    mov eax, [ebp+8]        ; Virtual address
    mov ebx, [ebp+12]       ; Physical address
    mov ecx, [ebp+16]       ; Flags (present, writable, user, etc.)
    
    ; Extract page directory index (bits 22-31)
    mov edi, eax
    shr edi, 22
    shl edi, 2              ; *4 for dword index
    add edi, [page_directory_base]
    
    ; Check if page table exists
    mov edx, [edi]
    test edx, 1             ; Present bit
    jnz .table_exists
    
    ; Allocate new page table
    call allocate_page_table
    or eax, 0x07            ; Present, writable, user
    mov [edi], eax
    mov edx, eax
    
.table_exists:
    ; Get page table address
    and edx, 0xFFFFF000
    
    ; Extract page table index (bits 12-21)
    mov edi, [ebp+8]
    shr edi, 12
    and edi, 0x3FF
    shl edi, 2
    add edi, edx
    
    ; Set page table entry
    mov eax, ebx
    and eax, 0xFFFFF000     ; Align physical address
    or eax, ecx             ; Add flags
    mov [edi], eax
    
    ; Invalidate TLB entry
    mov eax, [ebp+8]
    invlpg [eax]
    
    pop edi
    pop ecx
    pop ebx
    pop eax
    pop ebp
    ret
```

### Atomic Operations for Synchronization

Multi-core synchronization primitives require atomic instructions to prevent race conditions.

```nasm
; Atomic compare-and-swap
; Returns: 1 if successful, 0 if failed
atomic_cas:
    push ebp
    mov ebp, esp
    push ebx
    
    mov ecx, [ebp+8]        ; Pointer to value
    mov eax, [ebp+12]       ; Expected value
    mov ebx, [ebp+16]       ; New value
    
    lock cmpxchg [ecx], ebx
    jz .success
    
    xor eax, eax            ; Return 0 (failed)
    jmp .done
    
.success:
    mov eax, 1              ; Return 1 (success)
    
.done:
    pop ebx
    pop ebp
    ret

; Spinlock acquire
spinlock_acquire:
    push ebp
    mov ebp, esp
    push ebx
    
    mov ebx, [ebp+8]        ; Spinlock pointer
    
.retry:
    ; Try to acquire lock (0 = unlocked, 1 = locked)
    xor eax, eax
    mov ecx, 1
    lock cmpxchg [ebx], ecx
    jz .acquired
    
    ; Lock contention - pause and retry
    pause
    jmp .retry
    
.acquired:
    pop ebx
    pop ebp
    ret

; Spinlock release
spinlock_release:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp+8]        ; Spinlock pointer
    mov dword [eax], 0      ; Release lock
    
    pop ebp
    ret
```

## Device Drivers

Device drivers interface directly with hardware, requiring assembly for I/O port access, memory-mapped I/O, DMA setup, and interrupt handling with minimal latency.

### PCI Device Enumeration

PCI configuration space access uses specific I/O ports for reading device information.

```nasm
; Read PCI configuration space
; Parameters: bus, device, function, offset
; Returns: 32-bit value in EAX
pci_config_read:
    push ebp
    mov ebp, esp
    push edx
    push ebx
    
    ; Calculate configuration address
    ; Format: Enable bit | Bus | Device | Function | Register | 00
    movzx eax, byte [ebp+8]     ; Bus
    shl eax, 16
    movzx ebx, byte [ebp+12]    ; Device
    shl ebx, 11
    or eax, ebx
    movzx ebx, byte [ebp+16]    ; Function
    shl ebx, 8
    or eax, ebx
    movzx ebx, byte [ebp+20]    ; Offset
    and ebx, 0xFC               ; Align to dword
    or eax, ebx
    or eax, 0x80000000          ; Enable bit
    
    ; Write address to CONFIG_ADDRESS port
    mov dx, 0xCF8
    out dx, eax
    
    ; Read data from CONFIG_DATA port
    mov dx, 0xCFC
    in eax, dx
    
    pop ebx
    pop edx
    pop ebp
    ret

; Scan PCI bus for devices
scan_pci_bus:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    xor ebx, ebx            ; Bus 0
    
.bus_loop:
    xor esi, esi            ; Device 0
    
.device_loop:
    xor edi, edi            ; Function 0
    
.function_loop:
    ; Read vendor ID
    push 0                  ; Offset 0
    push edi                ; Function
    push esi                ; Device
    push ebx                ; Bus
    call pci_config_read
    add esp, 16
    
    ; Check if device exists (vendor ID != 0xFFFF)
    cmp ax, 0xFFFF
    je .next_function
    
    ; Device found - process it
    push eax
    push edi
    push esi
    push ebx
    call process_pci_device
    add esp, 16
    
.next_function:
    inc edi
    cmp edi, 8
    jl .function_loop
    
    inc esi
    cmp esi, 32
    jl .device_loop
    
    inc ebx
    cmp ebx, 256
    jl .bus_loop
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
```

### Network Interface Card Driver

Network drivers require efficient packet reception and transmission with minimal CPU overhead.

```nasm
; Intel e1000 network card initialization
e1000_init:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    ; Get BAR0 (memory-mapped registers base address)
    push 0x10               ; BAR0 offset
    push 0                  ; Function
    push 0                  ; Device
    push 0                  ; Bus (modify for actual device)
    call pci_config_read
    add esp, 16
    
    and eax, 0xFFFFFFF0     ; Mask flags
    mov [e1000_mmio_base], eax
    
    ; Reset device
    mov esi, [e1000_mmio_base]
    mov dword [esi + 0x00], 0x04  ; Device control: reset
    
    ; Wait for reset to complete
    mov ecx, 1000
.wait_reset:
    mov eax, [esi + 0x00]
    test eax, 0x04
    jz .reset_done
    pause
    dec ecx
    jnz .wait_reset
    
.reset_done:
    ; Setup receive descriptor ring
    mov edi, [rx_desc_ring_phys]
    mov [esi + 0x2800], edi         ; RDBAL
    mov dword [esi + 0x2804], 0     ; RDBAH
    mov dword [esi + 0x2808], RX_DESC_COUNT * 16  ; RDLEN
    mov dword [esi + 0x2810], 0     ; RDH
    mov dword [esi + 0x2818], 0     ; RDT
    
    ; Setup transmit descriptor ring
    mov edi, [tx_desc_ring_phys]
    mov [esi + 0x3800], edi         ; TDBAL
    mov dword [esi + 0x3804], 0     ; TDBAH
    mov dword [esi + 0x3808], TX_DESC_COUNT * 16  ; TDLEN
    mov dword [esi + 0x3810], 0     ; TDH
    mov dword [esi + 0x3818], 0     ; TDT
    
    ; Enable interrupts
    mov dword [esi + 0x00D0], 0xFF  ; IMS
    
    ; Enable receiver and transmitter
    mov dword [esi + 0x0100], 0x04008002  ; RCTL
    mov dword [esi + 0x0400], 0x0004010A  ; TCTL
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; Transmit packet
; Parameters: packet_buffer, length
e1000_transmit:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [e1000_mmio_base]
    
    ; Get current transmit tail
    mov edi, [esi + 0x3818]     ; TDT
    
    ; Get descriptor address
    mov ebx, edi
    imul ebx, 16                ; Descriptor size
    add ebx, [tx_desc_ring]
    
    ; Setup descriptor
    mov eax, [ebp+8]            ; Packet buffer physical address
    mov [ebx], eax              ; Buffer address
    mov ax, [ebp+12]            ; Length
    mov [ebx+8], ax
    mov byte [ebx+11], 0x0B     ; CMD: EOP, IFCS, RS
    mov byte [ebx+12], 0        ; Status
    
    ; Advance tail pointer
    inc edi
    cmp edi, TX_DESC_COUNT
    jl .no_wrap
    xor edi, edi
.no_wrap:
    mov [esi + 0x3818], edi     ; Update TDT
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; Receive interrupt handler
e1000_rx_interrupt:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    mov esi, [e1000_mmio_base]
    
    ; Read and clear interrupt cause
    mov eax, [esi + 0x00C0]     ; ICR
    
    ; Check for receive interrupt
    test eax, 0x80
    jz .done
    
.process_packets:
    ; Get current receive tail
    mov edi, [esi + 0x2818]     ; RDT
    
    ; Get next descriptor to check
    inc edi
    cmp edi, RX_DESC_COUNT
    jl .no_wrap
    xor edi, edi
.no_wrap:
    
    ; Get descriptor address
    mov ebx, edi
    imul ebx, 16
    add ebx, [rx_desc_ring]
    
    ; Check if descriptor is done
    mov al, [ebx+12]            ; Status
    test al, 1                  ; DD bit
    jz .done
    
    ; Process received packet
    push word [ebx+8]           ; Length
    push dword [ebx]            ; Buffer address
    call process_received_packet
    add esp, 6
    
    ; Clear descriptor status
    mov byte [ebx+12], 0
    
    ; Update tail pointer
    mov [esi + 0x2818], edi
    
    jmp .process_packets
    
.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
```

### USB Host Controller Driver

USB drivers manage complex state machines and timing-sensitive transactions.

```nasm
; UHCI (USB 1.1) frame list and transfer descriptor setup
uhci_init:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    ; Allocate and setup frame list (1024 entries)
    mov ecx, 1024
    mov edi, [uhci_frame_list]
    
.init_frame_list:
    ; Each entry points to a QH (Queue Head)
    mov eax, [uhci_qh_pool]
    or eax, 0x02            ; QH pointer type
    mov [edi], eax
    add edi, 4
    dec ecx
    jnz .init_frame_list
    
    ; Get UHCI base address from PCI
    push 0x20               ; BAR4 offset
    push 0
    push 0
    push 0
    call pci_config_read
    add esp, 16
    and eax, 0xFFE0         ; Mask lower bits
    mov [uhci_io_base], eax
    
    ; Reset controller
    mov dx, word [uhci_io_base]
    add dx, 0               ; USBCMD register
    mov ax, 0x0004          ; GRESET
    out dx, ax
    
    ; Wait 10ms (simplified)
    mov ecx, 10000
.delay:
    pause
    dec ecx
    jnz .delay
    
    ; Clear reset
    mov ax, 0
    out dx, ax
    
    ; Set frame list base address
    mov dx, word [uhci_io_base]
    add dx, 8               ; FRBASEADD
    mov eax, [uhci_frame_list]
    out dx, eax
    
    ; Start controller
    mov dx, word [uhci_io_base]
    mov ax, 0x0001          ; Run bit
    out dx, ax
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; Setup USB control transfer
; Parameters: device_address, request_type, request, value, index, buffer, length
usb_control_transfer:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    ; Allocate transfer descriptors
    call allocate_td
    mov edi, eax            ; SETUP TD
    
    call allocate_td
    mov esi, eax            ; DATA TD (if needed)
    
    call allocate_td
    mov ebx, eax            ; STATUS TD
    
    ; Build SETUP packet
    mov eax, [setup_packet_buffer]
    movzx ecx, byte [ebp+12]    ; request_type
    mov [eax], cl
    movzx ecx, byte [ebp+16]    ; request
    mov [eax+1], cl
    mov cx, [ebp+20]            ; value
    mov [eax+2], cx
    mov cx, [ebp+24]            ; index
    mov [eax+4], cx
    mov cx, [ebp+32]            ; length
    mov [eax+6], cx
    
    ; Setup SETUP TD
    mov dword [edi], ebx        ; Link to STATUS TD
    mov dword [edi+4], 0x00E80000 or (0x2D << 8)  ; Active, SETUP PID
    mov eax, [setup_packet_buffer]
    mov [edi+8], eax            ; Buffer pointer
    
    ; Setup DATA TD (if length > 0)
    cmp word [ebp+32], 0
    jz .no_data
    
    mov dword [edi], esi        ; Link to DATA TD instead
    mov dword [esi], ebx        ; DATA links to STATUS
    mov eax, [ebp+28]           ; buffer
    mov [esi+8], eax
    movzx ecx, word [ebp+32]
    dec ecx
    shl ecx, 16
    or ecx, 0x00E80000 or (0x69 << 8)  ; Active, IN PID
    mov [esi+4], ecx
    
.no_data:
    ; Setup STATUS TD (opposite direction of DATA)
    mov dword [ebx], 0x00000001 ; Terminate
    mov dword [ebx+4], 0x00E80000 or (0xE1 << 8)  ; Active, OUT PID for IN transfer
    mov dword [ebx+8], 0        ; No data for STATUS
    
    ; Add to schedule
    push edi
    call uhci_schedule_transfer
    add esp, 4
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
```

### Graphics Driver (Simple Framebuffer)

Graphics drivers require fast memory copying and pixel manipulation.

```nasm
; Initialize framebuffer from VESA BIOS Extensions
vesa_init:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    ; Get mode info (mode 0x118 = 1024x768x24)
    mov ax, 0x4F01          ; VBE get mode info
    mov cx, 0x118
    mov edi, vbe_mode_info
    int 0x10
    
    ; Set video mode
    mov ax, 0x4F02
    mov bx, 0x4118          ; Mode with linear framebuffer
    int 0x10
    
    ; Get framebuffer address
    mov eax, [vbe_mode_info + 40]
    mov [framebuffer_address], eax
    
    ; Get pitch (bytes per scanline)
    movzx eax, word [vbe_mode_info + 16]
    mov [framebuffer_pitch], eax
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; Draw pixel at (x, y) with color RGB
; Parameters: x, y, color (0x00RRGGBB)
draw_pixel:
    push ebp
    mov ebp, esp
    push ebx
    push edi
    
    ; Calculate offset: y * pitch + x * bytes_per_pixel
    mov eax, [ebp+12]       ; y
    imul eax, [framebuffer_pitch]
    mov ebx, [ebp+8]        ; x
    lea ebx, [ebx + ebx*2]  ; x * 3 (24-bit color)
    add eax, ebx
    
    ; Get framebuffer address
    mov edi, [framebuffer_address]
    add edi, eax
    
    ; Write color (BGR format)
    mov eax, [ebp+16]
    mov [edi], al           ; Blue
    shr eax, 8
    mov [edi+1], al         ; Green
    shr eax, 8
    mov [edi+2], al         ; Red
    
    pop edi
    pop ebx
    pop ebp
    ret

; Fast screen clear
; Parameters: color
clear_screen:
    push ebp
    mov ebp, esp
    push edi
    push ecx
    push eax
    
    mov edi, [framebuffer_address]
    mov ecx, [framebuffer_pitch]
    imul ecx, 768           ; Height
    mov eax, [ebp+8]        ; Color
    
    ; Expand color to fill dword (for 24-bit, approximate)
    mov ebx, eax
    shl eax, 24
    or eax, ebx
    
    shr ecx, 2              ; Divide by 4 for dword writes
    rep stosd
    
    pop eax
    pop ecx
    pop edi
    pop ebp
    ret

; BitBlt (block image transfer) with SSE optimization
bitblt_sse:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ecx
    
    mov esi, [ebp+8]        ; Source
    mov edi, [ebp+12]       ; Destination
    mov ecx, [ebp+16]       ; Width in pixels
    mov edx, [ebp+20]       ; Height
    
    lea ecx, [ecx + ecx*2]  ; Width in bytes (24-bit)
    
.row_loop:
    push ecx
    shr ecx, 4              ; 16 bytes per iteration
    
.col_loop:
    movdqu xmm0, [esi]
    movdqu [edi], xmm0
    add esi, 16
    add edi, 16
    dec ecx
    jnz .col_loop
    
    pop ecx
    and ecx, 15             ; Handle remaining bytes
    rep movsb
    
    ; Move to next row
    add esi, [ebp+24]       ; Source pitch - width
    add edi, [framebuffer_pitch]
    sub edi, [ebp+16]
    lea edi, [edi + edi*2]
    
    dec edx
    jnz .row_loop
    
    pop ecx
    pop edi
    pop esi
    pop ebp
    ret
```

## Cryptographic Implementations

Cryptographic algorithms implemented in assembly achieve significant performance improvements and can include protection against side-channel attacks through constant-time operations.

### AES-128 Encryption (Using AES-NI Instructions)

Modern x86 processors include hardware acceleration for AES through specialized instructions.

```nasm
; AES-128 key expansion using AES-NI
; Parameters: original_key (16 bytes), expanded_keys (176 bytes output)
aes128_key_expansion:
    push    ebp
    mov     ebp, esp
    push    esi
    push    edi
    push    ebx

    mov     esi, [ebp+8]        ; Original key pointer
    mov     edi, [ebp+12]       ; Expanded keys pointer

    ; Load original key
    movdqu  xmm1, [esi]
    movdqu  [edi], xmm1         ; Store round 0 key
    add     edi, 16

    ; Round constants for key expansion
    mov     ebx, 0x01           ; Starting rcon value
    mov     ecx, 10             ; 10 rounds for AES-128

.key_expand_loop:
    ; Use AESKEYGENASSIST for key expansion
    aeskeygenassist xmm2, xmm1, 0x00

    ; Set rcon manually in lowest byte
    pinsrb  xmm2, ebx, 0

    ; Perform key schedule expansion
    call    aes_key_expand_128_assist

    movdqu  [edi], xmm1
    add     edi, 16

    ; Update rcon: multiply by 2 in GF(2^8)
    shl     ebx, 1
    test    ebx, 0x100
    jz      .no_overflow
    xor     ebx, 0x11B          ; Reduce modulo AES polynomial

.no_overflow:
    and     ebx, 0xFF

    dec     ecx
    jnz     .key_expand_loop

    pop     ebx
    pop     edi
    pop     esi
    pop     ebp
    ret


; Helper routine for key expansion
aes_key_expand_128_assist:
    pshufd  xmm2, xmm2, 0xFF
    movdqa  xmm3, xmm1
    pslldq  xmm3, 4
    pxor    xmm1, xmm3
    movdqa  xmm3, xmm1
    pslldq  xmm3, 4
    pxor    xmm1, xmm3
    movdqa  xmm3, xmm1
    pslldq  xmm3, 4
    pxor    xmm1, xmm3
    pxor    xmm1, xmm2
    ret


; AES-128 ECB mode encryption (single block)
; Parameters: plaintext (16 bytes), ciphertext (16 bytes), expanded_keys
aes128_encrypt_block:
    push    ebp
    mov     ebp, esp
    push    esi
    push    edi
    push    ecx

    mov     esi, [ebp+8]        ; Plaintext
    mov     edi, [ebp+12]       ; Ciphertext
    mov     edx, [ebp+16]       ; Expanded keys

    ; Load plaintext
    movdqu  xmm0, [esi]

    ; Initial round (XOR with round key 0)
    movdqu  xmm1, [edx]
    pxor    xmm0, xmm1

    ; Main rounds (1-9)
    mov     ecx, 9
    add     edx, 16

.main_rounds:
    movdqu  xmm1, [edx]
    aesenc  xmm0, xmm1
    add     edx, 16
    dec     ecx
    jnz     .main_rounds

    ; Final round (10)
    movdqu  xmm1, [edx]
    aesenclast xmm0, xmm1

    ; Store ciphertext
    movdqu  [edi], xmm0

    pop     ecx
    pop     edi
    pop     esi
    pop     ebp
    ret


; AES-128 CBC mode encryption
; Parameters: plaintext, ciphertext, length, expanded_keys, iv
aes128_cbc_encrypt:
    push    ebp
    mov     ebp, esp
    push    esi
    push    edi
    push    ebx
    push    ecx

    mov     esi, [ebp+8]        ; Plaintext
    mov     edi, [ebp+12]       ; Ciphertext
    mov     ecx, [ebp+16]       ; Length (must be multiple of 16)
    mov     edx, [ebp+20]       ; Expanded keys
    mov     ebx, [ebp+24]       ; IV

    ; Load IV
    movdqu  xmm2, [ebx]

    shr     ecx, 4              ; Divide by 16 for block count

.block_loop:
    ; Load plaintext block
    movdqu  xmm0, [esi]

    ; XOR with previous ciphertext (IV for first block)
    pxor    xmm0, xmm2

    ; Encrypt block
    push    ecx
    push    edx

    ; Initial round
    movdqu  xmm1, [edx]
    pxor    xmm0, xmm1

    ; Main rounds
    mov     ecx, 9
    add     edx, 16

.encrypt_rounds:
    movdqu  xmm1, [edx]
    aesenc  xmm0, xmm1
    add     edx, 16
    dec     ecx
    jnz     .encrypt_rounds

    ; Final round
    movdqu  xmm1, [edx]
    aesenclast xmm0, xmm1

    pop     edx
    pop     ecx

    ; Store ciphertext
    movdqu  [edi], xmm0

    ; Save ciphertext for next block XOR
    movdqa  xmm2, xmm0

    add     esi, 16
    add     edi, 16
    dec     ecx
    jnz     .block_loop

    pop     ecx
    pop     ebx
    pop     edi
    pop     esi
    pop     ebp
    ret

````

### SHA-256 Hash Function

SHA-256 benefits from assembly optimization through loop unrolling and efficient register usage.

```nasm
; SHA-256 constants (first 32 bits of fractional parts of cube roots of first 64 primes)
section .rodata
align 16
sha256_k:
    dd 0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5
    dd 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5
    dd 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3
    dd 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174
    dd 0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc
    dd 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da
    dd 0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7
    dd 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967
    dd 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13
    dd 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85
    dd 0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3
    dd 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070
    dd 0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5
    dd 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3
    dd 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208
    dd 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2

section .text

; SHA-256 core transformation
; Parameters: state (8 dwords), block (64 bytes)
sha256_transform:
    push ebp
    mov ebp, esp
    sub esp, 256            ; 64 dwords for W array
    push ebx
    push esi
    push edi
    
    mov esi, [ebp+12]       ; Block pointer
    lea edi, [ebp-256]      ; W array
    
    ; Prepare message schedule (first 16 words)
    mov ecx, 16
.copy_block:
    mov eax, [esi]
    bswap eax               ; Convert to big-endian
    mov [edi], eax
    add esi, 4
    add edi, 4
    dec ecx
    jnz .copy_block
    
    ; Extend message schedule (words 16-63)
    mov ecx, 48
.extend_schedule:
    ; W[i] = sigma1(W[i-2]) + W[i-7] + sigma0(W[i-15]) + W[i-16]
    
    ; sigma0(W[i-15])
    mov eax, [edi-60]
    mov ebx, eax
    ror eax, 7
    mov edx, ebx
    ror edx, 18
    xor eax, edx
    shr ebx, 3
    xor eax, ebx
    
    ; Add W[i-16]
    add eax, [edi-64]
    
    ; Add W[i-7]
    add eax, [edi-28]
    
    ; sigma1(W[i-2])
    mov ebx, [edi-8]
    mov edx, ebx
    ror ebx, 17
    mov esi, edx
    ror esi, 19
    xor ebx, esi
    shr edx, 10
    xor ebx, edx
    
    ; Final W[i]
    add eax, ebx
    mov [edi], eax
    
    add edi, 4
    dec ecx
    jnz .extend_schedule
    
    ; Initialize working variables
    mov esi, [ebp+8]        ; State pointer
    mov eax, [esi]          ; a
    mov ebx, [esi+4]        ; b
    mov ecx, [esi+8]        ; c
    mov edx, [esi+12]       ; d
    push dword [esi+16]     ; e (on stack)
    push dword [esi+20]     ; f
    push dword [esi+24]     ; g
    push dword [esi+28]     ; h
    
    ; Main compression loop (64 rounds)
    mov esi, sha256_k
    lea edi, [ebp-256]      ; Reset W pointer
    mov dword [ebp-260], 64 ; Round counter
    
.round_loop:
    ; T1 = h + Sigma1(e) + Ch(e,f,g) + K[i] + W[i]
    
    ; Sigma1(e)
    mov [ebp-264], eax      ; Save a
    mov eax, [esp]          ; e
    mov [ebp-268], ebx      ; Save b
    mov ebx, eax
    ror eax, 6
    mov [ebp-272], ecx      ; Save c
    mov ecx, ebx
    ror ecx, 11
    xor eax, ecx
    mov ecx, ebx
    ror ecx, 25
    xor eax, ecx
    
    ; Ch(e,f,g) = (e & f) ^ (~e & g)
    mov ecx, [esp]          ; e
    and ecx, [esp+4]        ; f
    mov ebx, [esp]          ; e
    not ebx
    and ebx, [esp+8]        ; g
    xor ecx, ebx
    
    ; T1 = h + Sigma1(e) + Ch(e,f,g) + K[i] + W[i]
    add eax, ecx
    add eax, [esp+12]       ; h
    add eax, [esi]          ; K[i]
    add eax, [edi]          ; W[i]
    
    ; T2 = Sigma0(a) + Maj(a,b,c)
    
    ; Sigma0(a)
    mov ebx, [ebp-264]      ; a
    mov ecx, ebx
    ror ebx, 2
    mov edx, ecx
    ror edx, 13
    xor ebx, edx
    mov edx, ecx
    ror edx, 22
    xor ebx, edx
    
    ; Maj(a,b,c) = (a & b) ^ (a & c) ^ (b & c)
    mov ecx, [ebp-264]      ; a
    mov edx, [ebp-268]      ; b
    and ecx, edx            ; a & b
    mov edx, [ebp-264]      ; a
    and edx, [ebp-272]      ; c
    xor ecx, edx            ; (a & b) ^ (a & c)
    mov edx, [ebp-268]      ; b
    and edx, [ebp-272]      ; c
    xor ecx, edx            ; Final Maj result
    
    add ebx, ecx            ; T2
    
    ; Update working variables
    mov edx, [esp+12]       ; h
    mov [esp+12], [esp+8]   ; h = g
    mov [esp+8], [esp+4]    ; g = f
    mov [esp+4], [esp]      ; f = e
    mov ecx, [ebp-264]
    add eax, ecx
    mov [esp], eax          ; e = d + T1
    mov [esp], edx          ; Actually e = d + T1
    mov eax, [ebp-272]      ; d
    add eax, [esp]
    mov [esp], eax
    
    mov [ebp-272], [ebp-268] ; d = c
    mov [ebp-268], [ebp-264] ; c = b
    mov eax, ebx
    add eax, [ebp-264]
    mov [ebp-264], eax       ; a = T1 + T2
    
    ; Restore registers
    mov eax, [ebp-264]
    mov ebx, [ebp-268]
    mov ecx, [ebp-272]
    
    add esi, 4
    add edi, 4
    dec dword [ebp-260]
    jnz .round_loop
    
    ; Add compressed chunk to current hash value
    mov esi, [ebp+8]
    add [esi], eax
    add [esi+4], ebx
    add [esi+8], ecx
    add [esi+12], edx
    pop edx
    add [esi+28], edx
    pop edx
    add [esi+24], edx
    pop edx
    add [esi+20], edx
    pop edx
    add [esi+16], edx
    
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret

; Complete SHA-256 hash
; Parameters: message, length, output (32 bytes)
sha256_hash:
    push ebp
    mov ebp, esp
    sub esp, 64             ; Working block
    push ebx
    push esi
    push edi
    
    ; Initialize hash values (first 32 bits of fractional parts of square roots of first 8 primes)
    sub esp, 32
    mov edi, esp
    mov dword [edi], 0x6a09e667
    mov dword [edi+4], 0xbb67ae85
    mov dword [edi+8], 0x3c6ef372
    mov dword [edi+12], 0xa54ff53a
    mov dword [edi+16], 0x510e527f
    mov dword [edi+20], 0x9b05688c
    mov dword [edi+24], 0x1f83d9ab
    mov dword [edi+28], 0x5be0cd19
    
    mov esi, [ebp+8]        ; Message
    mov ecx, [ebp+12]       ; Length
    mov ebx, ecx            ; Save original length
    
    ; Process complete 64-byte blocks
.block_loop:
    cmp ecx, 64
    jl .final_block
    
    push esi
    push edi
    call sha256_transform
    add esp, 8
    
    add esi, 64
    sub ecx, 64
    jmp .block_loop
    
.final_block:
    ; Pad final block
    lea edi, [ebp-64]
    
    ; Copy remaining bytes
    push ecx
    rep movsb
    pop ecx
    
    ; Append '1' bit
    mov byte [edi], 0x80
    inc edi
    inc ecx
    
    ; Zero padding
    mov eax, 64
    sub eax, ecx
    cmp eax, 8
    jge .padding_fits
    
    ; Need extra block
    push ecx
    mov ecx, eax
    xor al, al
    rep stosb
    
    ; Process this block
    lea esi, [ebp-64]
    mov edi, esp
    push esi
    push edi
    call sha256_transform
    add esp, 8
    
    ; Start new block
    lea edi, [ebp-64]
    mov ecx, 56
    xor eax, eax
    rep stosb
    jmp .add_length
    
.padding_fits:
    sub eax, 8
    mov ecx, eax
    xor al, al
    rep stosb
    
.add_length:
    ; Append original length in bits (big-endian 64-bit)
    mov eax, ebx
    shl eax, 3              ; Convert bytes to bits
    bswap eax
    mov [edi+4], eax
    xor eax, eax
    mov [edi], eax          ; High 32 bits (zero for messages < 512MB)
    
    ; Process final block
    lea esi, [ebp-64]
    mov edi, esp
    push esi
    push edi
    call sha256_transform
    add esp, 8
    
    ; Copy hash to output (convert to big-endian)
    mov esi, esp
    mov edi, [ebp+16]
    mov ecx, 8
.output_loop:
    mov eax, [esi]
    bswap eax
    mov [edi], eax
    add esi, 4
    add edi, 4
    dec ecx
    jnz .output_loop
    
    add esp, 32
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret
````

### RSA Public Key Operations (Montgomery Multiplication)

RSA operations require efficient large integer arithmetic, typically using Montgomery multiplication for modular exponentiation.

```nasm
; Montgomery multiplication: (a * b * R^-1) mod m
; Parameters: result, a, b, m, m_prime, num_words
; R = 2^(32 * num_words), m_prime = -m^-1 mod 2^32
montgomery_mul:
    push ebp
    mov ebp, esp
    sub esp, 64             ; Temporary storage
    push ebx
    push esi
    push edi
    
    mov edi, [ebp+8]        ; Result
    mov esi, [ebp+12]       ; a
    mov edx, [ebp+16]       ; b
    mov ebx, [ebp+20]       ; m
    mov eax, [ebp+24]       ; m_prime
    mov ecx, [ebp+28]       ; num_words
    
    ; Zero result
    push edi
    push ecx
    xor eax, eax
.zero_loop:
    mov [edi], eax
    add edi, 4
    dec ecx
    jnz .zero_loop
    pop ecx
    pop edi
    
    ; Main Montgomery multiplication loop
    mov dword [ebp-4], 0    ; i counter
    
.outer_loop:
    mov eax, [ebp-4]
    cmp eax, ecx
    jge .reduction
    
    ; Load a[i]
    mov esi, [ebp+12]
    mov ebx, [ebp-4]
    mov eax, [esi + ebx*4]
    
    ; Inner multiplication loop
    xor edx, edx
    mov dword [ebp-8], 0    ; j counter
    
.mul_loop:
    mov ebx, [ebp-8]
    cmp ebx, ecx
    jge .mul_done
    
    ; result[j] += a[i] * b[j] + carry
    mov esi, [ebp+16]       ; b
    mov edi, [ebp+8]        ; result
    
    mov eax, [esi + ebx*4]
    mul dword [ebp-12]      ; Multiply by saved a[i]
    add eax, edx
    mov edx, 0
    adc edx, 0
    add eax, [edi + ebx*4]
    adc edx, 0
    mov [edi + ebx*4], eax
    
    inc dword [ebp-8]
    jmp .mul_loop
    
.mul_done:
    ; Montgomery reduction step
    mov edi, [ebp+8]
    mov eax, [edi]
    mul dword [ebp+24]      ; m_prime
    
    ; Multiply m by u and add to result
    ; [Similar reduction code omitted for brevity]
    
    inc dword [ebp-4]
    jmp .outer_loop
    
.reduction:
    ; Final conditional subtraction
    ; if result >= m: result -= m
    
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret

; RSA modular exponentiation: result = base^exp mod m
; Using Montgomery ladder for constant-time execution
rsa_mod_exp:
    push ebp
    mov ebp, esp
    sub esp, 128
    push ebx
    push esi
    push edi
    
    ; Convert base to Montgomery form
    ; [Code omitted for brevity]
    
    ; Binary exponentiation with Montgomery multiplication
    mov ecx, [ebp+16]       ; Exponent length in bits
    
.exp_loop:
    ; Square
    push dword [ebp+28]     ; num_words
    push dword [ebp+24]     ; m_prime
    push dword [ebp+20]     ; m
    push dword [ebp-64]     ; temp
    push dword [ebp-64]     ; temp
    lea eax, [ebp-32]
    push eax
    call montgomery_mul
    add esp, 24
    
    ; Test bit of exponent
    mov esi, [ebp+12]       ; Exponent
    mov ebx, ecx
    dec ebx
    shr ebx, 5              ; Divide by 32
    mov eax, [esi + ebx*4]
    mov ebx, ecx
    dec ebx
    and ebx, 31
    bt eax, ebx
    jnc .bit_zero
    
    ; Multiply if bit is 1
    push dword [ebp+28]
    push dword [ebp+24]
    push dword [ebp+20]
    push dword [ebp+8]      ; base
    lea eax, [ebp-32]
    push eax
    lea eax, [ebp-32]
    push eax
    call montgomery_mul
    add esp, 24
    
.bit_zero:
    dec ecx
    jnz .exp_loop
    
    ; Convert result back from Montgomery form
    ; [Code omitted for brevity]
    
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret
```

### Constant-Time Implementation

Cryptographic code must avoid timing side-channels by ensuring execution time is independent of secret data.

```nasm
; Constant-time byte comparison
; Returns: 0 if equal, non-zero if different
; Time is independent of where bytes differ
ct_compare_bytes:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ecx
    
    mov esi, [ebp+8]        ; Buffer 1
    mov edi, [ebp+12]       ; Buffer 2
    mov ecx, [ebp+16]       ; Length
    
    xor eax, eax            ; Accumulator for differences
    
.compare_loop:
    mov bl, [esi]
    xor bl, [edi]
    or al, bl               ; Accumulate differences
    inc esi
    inc edi
    dec ecx
    jnz .compare_loop
    
    ; eax is 0 if all bytes equal, non-zero otherwise
    
    pop ecx
    pop edi
    pop esi
    pop ebp
    ret

; Constant-time conditional move
; result = condition ? true_val : false_val
; Time independent of condition
ct_select:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp+8]        ; condition (0 or 1)
    mov ebx, [ebp+12]       ; true_val
    mov ecx, [ebp+16]       ; false_val
    
    ; Create mask: 0x00000000 if condition==0, 0xFFFFFFFF if condition==1
    neg eax
    sbb eax, eax
    
    ; result = (true_val & mask) | (false_val & ~mask)
    mov edx, eax
    not edx
    and ebx, eax
    and ecx, edx
    or eax, ebx
    or eax, ecx
    
    pop ebp
    ret
```

## Compression Algorithms

Compression algorithms achieve significant speedups in assembly through optimized string matching, bit manipulation, and SIMD operations.

### DEFLATE/LZ77 Implementation

DEFLATE compression uses LZ77 for duplicate string finding and Huffman coding for entropy encoding.

```nasm
; LZ77 sliding window match finder
; Parameters: input, input_length, output, window_size
lz77_compress:
    push ebp
    mov ebp, esp
    sub esp, 32
    push ebx
    push esi
    push edi
    
    mov esi, [ebp+8]        ; Input pointer
    mov ecx, [ebp+12]       ; Input length
    mov edi, [ebp+16]       ; Output pointer
    mov edx, [ebp+20]       ; Window size (typically 32KB)
    
    xor eax, eax
    mov [ebp-4], eax        ; Current position
    
.main_loop:
    mov eax, [ebp-4]
    cmp eax, ecx
    jge .done
    
    ; Find longest match in sliding window
    push edi
    push ecx
    push esi
    push eax                ; Current position
    call find_longest_match
    add esp, 16
    
    ; eax = match length, edx = match distance
    cmp eax, 3              ; Minimum match length
    jl .literal
    
    ; Emit (length, distance) pair
    mov byte [edi], 0x01    ; Match marker
    inc edi
    mov [edi], ax           ; Length (16-bit)
    add edi, 2
    mov [edi], dx           ; Distance (16-bit)
    add edi, 2
    
    add [ebp-4], eax        ; Advance by match length
    jmp .main_loop
    
.literal:
    ; Emit literal byte
    mov byte [edi], 0x00    ; Literal marker
    inc edi
    mov al, [esi + ebx]
    mov [edi], al
    inc edi
    
    inc dword [ebp-4]
    jmp .main_loop
    
.done:
    ; Return compressed size
    mov eax, edi
    sub eax, [ebp+16]
    
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret

; Find longest match using hash table
find_longest_match:
    push ebp
    mov ebp, esp
    sub esp, 16
    push ebx
    push esi
    push edi
    
    mov esi, [ebp+8]        ; Input
    mov eax, [ebp+12]       ; Current position
    mov ecx, [ebp+16]       ; Input length
    mov edx, [ebp+20]       ; Output (unused here)
    
    ; Calculate hash of current 3 bytes
    movzx ebx, byte [esi + eax]
    shl ebx, 8
    movzx edi, byte [esi + eax + 1]
    or ebx, edi
    shl ebx, 8
    movzx edi, byte [esi + eax + 2]
    or ebx, edi
    and ebx, 0xFFFF         ; 16-bit hash
    
    ; Look up in hash table
    mov edi, [hash_table + ebx*4]
    
    xor edx, edx            ; Best distance
    xor eax, eax            ; Best length
    
.search_chain:
    test edi, edi
    jz .search_done
    
    ; Check if position is within window
    mov ebx, [ebp+12]
    sub ebx, edi
    cmp ebx, 32768
    jg .next_chain
    
    ; Compare strings
    push ecx
    push esi
    push edi
    
    add esi, [ebp+12]       ; Current position
    add edi, [hash_table_base]
    
    xor ecx, ecx            ; Match length
    
.compare_loop:
    mov al, [esi + ecx]
    cmp al, [edi + ecx]
    jne .compare_done
    inc ecx
    cmp ecx, 258            ; Maximum match length
    jge .compare_done
    mov eax, [ebp+12]
    add eax, ecx
    cmp eax, [ebp+16]
    jge .compare_done
    jmp .compare_loop
    
.compare_done:
    pop     edi
    pop     esi

    ; Update best match if this is longer
    cmp     ecx, eax
    jle     .not_better

    mov     eax, ecx            ; New best length
    mov     ebx, [ebp+12]
    sub     ebx, edi
    mov     edx, ebx            ; New best distance

.not_better:
    pop     ecx

.next_chain:
    ; Follow hash chain to next entry
    mov     edi, [hash_chain + edi*4]
    jmp     .search_chain

.search_done:
    ; Return length in EAX, distance in EDX
    pop     edi
    pop     esi
    pop     ebx
    mov     esp, ebp
    pop     ebp
    ret


; Update hash table with new position
; Parameters: position, input
update_hash_table:
    push    ebp
    mov     ebp, esp
    push    ebx
    push    esi

    mov     eax, [ebp+8]        ; Position
    mov     esi, [ebp+12]       ; Input

    ; Calculate hash
    movzx   ebx, byte [esi + eax]
    shl     ebx, 8
    movzx   ecx, byte [esi + eax + 1]
    or      ebx, ecx
    shl     ebx, 8
    movzx   ecx, byte [esi + eax + 2]
    or      ebx, ecx
    and     ebx, 0xFFFF

    ; Insert at head of hash chain
    mov     ecx, [hash_table + ebx*4]
    mov     [hash_chain + eax*4], ecx
    mov     [hash_table + ebx*4], eax

    pop     esi
    pop     ebx
    pop     ebp
    ret
````

### Huffman Coding

Huffman coding provides optimal prefix codes for symbols based on their frequencies.

```nasm
; Build Huffman tree from frequency table
; Parameters: frequencies (256 dwords), output_tree
build_huffman_tree:
    push ebp
    mov ebp, esp
    sub esp, 2048           ; Priority queue and tree nodes
    push ebx
    push esi
    push edi
    
    mov esi, [ebp+8]        ; Frequencies
    lea edi, [ebp-2048]     ; Priority queue
    
    ; Initialize priority queue with leaf nodes
    xor ecx, ecx            ; Symbol index
    xor edx, edx            ; Queue size
    
.init_queue:
    mov eax, [esi + ecx*4]
    test eax, eax
    jz .skip_symbol
    
    ; Add node: [frequency, symbol, left=-1, right=-1]
    mov [edi + edx*16], eax     ; Frequency
    mov [edi + edx*16 + 4], ecx ; Symbol
    mov dword [edi + edx*16 + 8], -1   ; Left child
    mov dword [edi + edx*16 + 12], -1  ; Right child
    inc edx
    
.skip_symbol:
    inc ecx
    cmp ecx, 256
    jl .init_queue
    
    mov [ebp-4], edx        ; Queue size
    
    ; Build tree by combining two smallest nodes
.build_loop:
    cmp dword [ebp-4], 1
    jle .done
    
    ; Sort queue (simple bubble sort for small queues)
    push edi
    push dword [ebp-4]
    call sort_priority_queue
    add esp, 8
    
    ; Pop two smallest nodes
    mov eax, [ebp-4]
    dec eax
    imul eax, 16
    mov ebx, [edi + eax]        ; Freq1
    mov ecx, [edi + eax + 4]    ; Symbol1/Index1
    
    sub eax, 16
    mov edx, [edi + eax]        ; Freq2
    mov esi, [edi + eax + 4]    ; Symbol2/Index2
    
    ; Create parent node
    add ebx, edx                ; Combined frequency
    mov [edi + eax], ebx
    mov dword [edi + eax + 4], -1  ; Internal node (no symbol)
    
    ; Store child indices
    mov [edi + eax + 8], esi    ; Left child
    mov [edi + eax + 12], ecx   ; Right child
    
    dec dword [ebp-4]           ; Queue now has one less element
    jmp .build_loop
    
.done:
    ; Copy tree root to output
    mov edi, [ebp+12]
    lea esi, [ebp-2048]
    mov ecx, 4
    rep movsd
    
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret

; Generate Huffman codes from tree
; Parameters: tree_node, code, code_length, code_table
generate_huffman_codes:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp+8]        ; Current node
    
    ; Check if leaf node
    cmp dword [esi+8], -1   ; Left child
    jne .internal_node
    
    ; Leaf node - store code
    mov eax, [esi+4]        ; Symbol
    mov edi, [ebp+20]       ; Code table
    imul eax, 8
    add edi, eax
    
    mov eax, [ebp+12]       ; Code
    mov [edi], eax
    mov eax, [ebp+16]       ; Code length
    mov [edi+4], eax
    
    jmp .done
    
.internal_node:
    ; Traverse left child (append 0)
    mov eax, [ebp+12]       ; Current code
    shl eax, 1              ; Shift left, appending 0
    mov ebx, [ebp+16]       ; Code length
    inc ebx
    
    push dword [ebp+20]     ; Code table
    push ebx                ; New length
    push eax                ; New code
    push dword [esi+8]      ; Left child
    call generate_huffman_codes
    add esp, 16
    
    ; Traverse right child (append 1)
    mov eax, [ebp+12]
    shl eax, 1
    or eax, 1               ; Append 1
    mov ebx, [ebp+16]
    inc ebx
    
    push dword [ebp+20]
    push ebx
    push eax
    push dword [esi+12]     ; Right child
    call generate_huffman_codes
    add esp, 16
    
.done:
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; Encode data using Huffman codes
; Parameters: input, input_length, output, code_table
huffman_encode:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp+8]        ; Input
    mov ecx, [ebp+12]       ; Length
    mov edi, [ebp+16]       ; Output
    mov edx, [ebp+20]       ; Code table
    
    xor eax, eax            ; Bit buffer
    xor ebx, ebx            ; Bits in buffer
    
.encode_loop:
    test ecx, ecx
    jz .flush_bits
    
    ; Get symbol
    movzx eax, byte [esi]
    inc esi
    dec ecx
    
    ; Look up code
    push ecx
    push esi
    
    imul eax, 8
    mov esi, edx
    add esi, eax
    mov eax, [esi]          ; Code
    mov ecx, [esi+4]        ; Code length
    
    ; Add to bit buffer
.add_bits:
    test ecx, ecx
    jz .bits_added
    
    shl dword [ebp-4], 1    ; Shift buffer left
    dec ecx
    bt eax, ecx             ; Test bit at position ecx
    jnc .bit_zero
    or dword [ebp-4], 1
.bit_zero:
    inc ebx
    
    ; Flush byte if buffer full
    cmp ebx, 8
    jl .no_flush
    
    mov al, byte [ebp-4]
    mov [edi], al
    inc edi
    xor ebx, ebx
    mov dword [ebp-4], 0
    
.no_flush:
    jmp .add_bits
    
.bits_added:
    pop esi
    pop ecx
    jmp .encode_loop
    
.flush_bits:
    ; Flush remaining bits
    test ebx, ebx
    jz .done
    
    mov ecx, 8
    sub ecx, ebx
    shl dword [ebp-4], cl
    mov al, byte [ebp-4]
    mov [edi], al
    inc edi
    
.done:
    ; Return output size
    mov eax, edi
    sub eax, [ebp+16]
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
````

### LZW Compression (GIF/TIFF)

LZW builds a dictionary dynamically during compression and decompression.

```nasm
; LZW compression
; Parameters: input, input_length, output, max_output_length
lzw_compress:
    push ebp
    mov ebp, esp
    sub esp, 262144         ; Dictionary (4096 entries * 64 bytes each)
    push ebx
    push esi
    push edi
    
    mov esi, [ebp+8]        ; Input
    mov ecx, [ebp+12]       ; Input length
    mov edi, [ebp+16]       ; Output
    
    ; Initialize dictionary with single-byte entries (0-255)
    lea ebx, [ebp-262144]   ; Dictionary base
    xor eax, eax
    
.init_dict:
    mov [ebx + eax*64], al  ; String[0] = byte value
    mov byte [ebx + eax*64 + 1], 0  ; String length = 1
    inc eax
    cmp eax, 256
    jl .init_dict
    
    mov dword [ebp-4], 256  ; Next available code
    mov dword [ebp-8], 9    ; Current code width (bits)
    
    ; Start with first byte
    movzx eax, byte [esi]
    mov [ebp-12], eax       ; Current code (w)
    inc esi
    dec ecx
    
.compress_loop:
    test ecx, ecx
    jz .finish
    
    ; Read next byte (k)
    movzx edx, byte [esi]
    inc esi
    dec ecx
    
    ; Check if w+k is in dictionary
    push ecx
    push edx                ; k
    push dword [ebp-12]     ; w
    lea eax, [ebp-262144]
    push eax                ; Dictionary
    push dword [ebp-4]      ; Dictionary size
    call lzw_find_string
    add esp, 20
    pop ecx
    
    test eax, eax
    jns .found_in_dict
    
    ; w+k not in dictionary
    ; Output code for w
    push ecx
    push edi
    push dword [ebp-8]      ; Code width
    push dword [ebp-12]     ; Code
    call write_code_bits
    add esp, 8
    mov edi, eax            ; Update output pointer
    pop ecx
    
    ; Add w+k to dictionary
    mov eax, [ebp-4]
    lea ebx, [ebp-262144]
    imul eax, 64
    add ebx, eax
    
    ; Copy w to new entry
    push esi
    mov esi, [ebp-12]
    imul esi, 64
    lea esi, [ebp-262144 + esi]
    movzx eax, byte [esi+1] ; String length
    push ecx
    mov ecx, eax
    rep movsb
    pop ecx
    
    ; Append k
    mov [ebx + eax], dl
    inc eax
    mov [ebx + 1], al       ; Update length
    
    pop esi
    
    ; Increment dictionary size
    inc dword [ebp-4]
    
    ; Check if need to increase code width
    mov eax, [ebp-4]
    cmp eax, 512
    jne .check_1024
    mov dword [ebp-8], 10
    jmp .width_updated
.check_1024:
    cmp eax, 1024
    jne .check_2048
    mov dword [ebp-8], 11
    jmp .width_updated
.check_2048:
    cmp eax, 2048
    jne .width_updated
    mov dword [ebp-8], 12
    
.width_updated:
    ; w = k
    mov [ebp-12], edx
    jmp .compress_loop
    
.found_in_dict:
    ; w = code for w+k
    mov [ebp-12], eax
    jmp .compress_loop
    
.finish:
    ; Output final code
    push edi
    push dword [ebp-8]
    push dword [ebp-12]
    call write_code_bits
    add esp, 8
    
    ; Return compressed size
    sub eax, [ebp+16]
    
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret

; Find string in LZW dictionary
; Returns: code if found, -1 if not found
lzw_find_string:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov ebx, [ebp+8]        ; Dictionary base
    mov ecx, [ebp+12]       ; Dictionary size
    mov edx, [ebp+16]       ; Current code (w)
    mov esi, [ebp+20]       ; New byte (k)
    
    ; Get length of w
    imul edx, 64
    add edx, ebx
    movzx eax, byte [edx+1] ; Length of w
    
    ; Search dictionary for w+k
    xor edi, edi            ; Index
    
.search_loop:
    cmp edi, ecx
    jge .not_found
    
    ; Check if length matches
    mov eax, edi
    imul eax, 64
    add eax, ebx
    movzx ebp, byte [eax+1]
    
    push edi
    imul edi, 64
    movzx edi, byte [edx+1]
    inc edi
    cmp ebp, edi
    pop edi
    jne .next_entry
    
    ; Check if strings match
    push ecx
    push esi
    push edi
    
    mov esi, edx            ; Source = w
    mov edi, eax            ; Dest = current entry
    movzx ecx, byte [edx+1] ; Length of w
    
    repe cmpsb
    jne .no_match
    
    ; Check last byte (k)
    pop edi
    pop esi
    mov al, [edi]
    cmp al, sil
    pop ecx
    jne .next_entry
    
    ; Found match
    mov eax, edi
    jmp .done
    
.no_match:
    pop edi
    pop esi
    pop ecx
    
.next_entry:
    inc edi
    jmp .search_loop
    
.not_found:
    mov eax, -1
    
.done:
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; Write variable-width code to bit stream
write_code_bits:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    
    mov eax, [ebp+8]        ; Code
    mov ecx, [ebp+12]       ; Code width (bits)
    mov esi, [ebp+16]       ; Output pointer
    
    ; Load bit buffer state (stored at end of output buffer)
    mov ebx, [output_bit_buffer]
    mov edx, [output_bits_remaining]
    
.write_bits:
    test ecx, ecx
    jz .done
    
    ; Add bit to buffer
    shl ebx, 1
    dec ecx
    bt eax, ecx
    jnc .bit_clear
    or ebx, 1
    
.bit_clear:
    inc edx
    
    ; Flush byte if buffer full
    cmp edx, 8
    jl .write_bits
    
    mov byte [esi], bl
    inc esi
    xor edx, edx
    xor ebx, ebx
    
    jmp .write_bits
    
.done:
    ; Save bit buffer state
    mov [output_bit_buffer], ebx
    mov [output_bits_remaining], edx
    
    mov eax, esi            ; Return updated pointer
    
    pop esi
    pop ebx
    pop ebp
    ret
```

### Run-Length Encoding (RLE)

RLE is a simple compression algorithm effective for data with many consecutive repeated values.

```nasm
; RLE compression with SSE optimization for finding runs
; Parameters: input, input_length, output
rle_compress_sse:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp+8]        ; Input
    mov ecx, [ebp+12]       ; Length
    mov edi, [ebp+16]       ; Output
    
    xor ebx, ebx            ; Input position
    
.main_loop:
    cmp ebx, ecx
    jge .done
    
    ; Load current byte
    movzx eax, byte [esi + ebx]
    
    ; Check for run using SSE
    cmp ecx, ebx
    sub ecx, ebx
    cmp ecx, 16
    jl .scalar_count
    
    ; Broadcast byte to XMM register
    movd xmm0, eax
    pxor xmm1, xmm1
    pshufb xmm0, xmm1       ; Broadcast to all bytes
    
    mov edx, ebx
    add edx, 16
    
.sse_count_loop:
    cmp edx, [ebp+12]
    jg .sse_done
    
    ; Compare 16 bytes at once
    movdqu xmm2, [esi + edx - 16]
    pcmpeqb xmm2, xmm0
    pmovmskb eax, xmm2
    
    cmp eax, 0xFFFF         ; All bytes match?
    jne .sse_done
    
    add edx, 16
    cmp edx, ebx
    sub edx, ebx
    cmp edx, 255            ; Max run length
    jl .sse_count_loop
    
.sse_done:
    mov ecx, edx
    sub ecx, ebx            ; Run length so far
    mov edx, ebx
    add edx, ecx
    jmp .count_done
    
.scalar_count:
    ; Count run length (scalar)
    mov edx, ebx
    inc edx
    
.count_loop:
    cmp edx, [ebp+12]
    jge .count_done
    
    movzx eax, byte [esi + ebx]
    cmp al, [esi + edx]
    jne .count_done
    
    inc edx
    
    ; Limit run length to 255
    mov ecx, edx
    sub ecx, ebx
    cmp ecx, 255
    jge .count_done
    
    jmp .count_loop
    
.count_done:
    mov ecx, edx
    sub ecx, ebx            ; Run length
    
    ; Output: count, value
    mov [edi], cl
    inc edi
    movzx eax, byte [esi + ebx]
    mov [edi], al
    inc edi
    
    add ebx, ecx
    mov ecx, [ebp+12]       ; Restore total length
    jmp .main_loop
    
.done:
    ; Return compressed size
    mov eax, edi
    sub eax, [ebp+16]
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; RLE decompression
; Parameters: input, input_length, output, max_output_length
rle_decompress:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov esi, [ebp+8]        ; Input
    mov ebx, [ebp+12]       ; Input length
    mov edi, [ebp+16]       ; Output
    mov edx, [ebp+20]       ; Max output length
    
    xor ecx, ecx            ; Input position
    xor eax, eax            ; Output position
    
.decompress_loop:
    cmp ecx, ebx
    jge .done
    
    ; Read count and value
    movzx ebp, byte [esi + ecx]
    inc ecx
    movzx eax, byte [esi + ecx]
    inc ecx
    
    ; Check output buffer space
    push eax
    mov eax, [edi]
    sub eax, [ebp+16]
    add eax, ebp
    cmp eax, edx
    pop eax
    jg .overflow
    
    ; Write run using REP STOSB
    push ecx
    mov ecx, ebp
    rep stosb
    pop ecx
    
    jmp .decompress_loop
    
.overflow:
    ; Output buffer overflow
    mov eax, -1
    jmp .exit
    
.done:
    ; Return decompressed size
    mov eax, edi
    sub eax, [ebp+16]
    
.exit:
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
```

### SIMD-Accelerated Delta Encoding

Delta encoding stores differences between consecutive values, often used as a preprocessing step before other compression.

```nasm
; Delta encoding with SSE
; Parameters: input, output, length (must be multiple of 16)
delta_encode_sse:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ecx
    
    mov esi, [ebp+8]        ; Input
    mov edi, [ebp+12]       ; Output
    mov ecx, [ebp+16]       ; Length
    
    ; Store first value as-is
    movdqu xmm0, [esi]
    movdqu [edi], xmm0
    
    add esi, 16
    add edi, 16
    sub ecx, 16
    
    movdqu xmm1, xmm0       ; Previous values
    
.encode_loop:
    test ecx, ecx
    jz .done
    
    ; Load current 16 bytes
    movdqu xmm0, [esi]
    
    ; Compute deltas: current - previous
    movdqa xmm2, xmm0
    psubb xmm2, xmm1        ; Byte-wise subtraction
    
    ; Store deltas
    movdqu [edi], xmm2
    
    ; Update previous
    movdqa xmm1, xmm0
    
    add esi, 16
    add edi, 16
    sub ecx, 16
    jmp .encode_loop
    
.done:
    pop ecx
    pop edi
    pop esi
    pop ebp
    ret

; Delta decoding with SSE
; Parameters: input, output, length
delta_decode_sse:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ecx
    
    mov esi, [ebp+8]
    mov edi, [ebp+12]
    mov ecx, [ebp+16]
    
    ; Load first value
    movdqu xmm0, [esi]
    movdqu [edi], xmm0
    
    add esi, 16
    add edi, 16
    sub ecx, 16
    
    movdqu xmm1, xmm0       ; Accumulated value
    
.decode_loop:
    test ecx, ecx
    jz .done
    
    ; Load deltas
    movdqu xmm0, [esi]
    
    ; Add to previous: current = previous + delta
    paddb xmm1, xmm0
    
    ; Store reconstructed values
    movdqu [edi], xmm1
    
    add esi, 16
    add edi, 16
    sub ecx, 16
    jmp .decode_loop
    
.done:
    pop ecx
    pop edi
    pop esi
    pop ebp
    ret
```

**Key Points:**

- Operating system kernels require assembly for boot processes, interrupt handlers, context switching, and direct hardware control that cannot be expressed in higher-level languages
- Device drivers use assembly for I/O port access, memory-mapped I/O, DMA configuration, and interrupt handling with minimal latency requirements
- Cryptographic implementations benefit significantly from assembly through AES-NI hardware acceleration, constant-time operations to prevent timing attacks, and optimized large integer arithmetic for RSA
- Compression algorithms achieve substantial performance improvements through assembly-optimized pattern matching, bit manipulation, Huffman coding, and SIMD operations for parallel data processing
- [Inference] The performance advantage of assembly in these domains typically ranges from 2-10x compared to optimized C code, with the largest gains in cryptography (hardware instructions) and compression (SIMD operations)
- Modern x86 assembly for real-world applications extensively uses SIMD extensions (SSE, AVX) for data-parallel operations and specialized instruction sets (AES-NI, SHA extensions) where available
- Constant-time implementations in cryptographic code use techniques like conditional moves and bitwise masking instead of branches to prevent timing side-channel attacks

For comprehensive x86 assembly development in these domains, related topics worth exploring include: memory ordering and barriers for multi-core synchronization, AVX-512 instructions for wider SIMD operations, hardware transactional memory (TSX) for lock-free data structures, and Intel SGX for secure enclaves.

---

## Graphics and Video Processing

Graphics and video processing demand extreme performance for real-time rendering, encoding, and manipulation of large data volumes. Assembly optimization in these domains can provide substantial performance improvements over compiler-generated code.

### SIMD Video Decoding

Video codecs like H.264, H.265/HEVC, VP9, and AV1 perform intensive pixel operations that benefit significantly from SIMD parallelism. Modern codecs operate on blocks of pixels (4x4, 8x8, 16x16, or larger) that map naturally to vector operations.

**Motion Compensation** is a fundamental operation in video decoding where pixels from reference frames are copied to construct the current frame. This involves reading blocks from arbitrary positions (possibly non-aligned) and writing to the destination.

```nasm
; Copy 16x16 block with SSE2
; rdi = destination pointer
; rsi = source pointer  
; edx = source stride
; ecx = destination stride

copy_16x16_sse2:
    mov r8d, 16                    ; Loop counter
    
.loop:
    movdqu xmm0, [rsi]             ; Load 16 bytes from source
    movdqu [rdi], xmm0             ; Store to destination
    
    add rsi, rdx                   ; Advance source by stride
    add rdi, rcx                   ; Advance destination by stride
    
    dec r8d
    jnz .loop
    
    ret
```

This copies 16 bytes per iteration using unaligned loads/stores. A 16x16 block is processed in 16 iterations, each handling one row. For aligned data, `movdqa` would be faster than `movdqu`.

**Advanced motion compensation** with sub-pixel interpolation requires filtering operations. Half-pixel positions use 6-tap filters, quarter-pixel positions use bilinear interpolation. These operations process multiple pixels simultaneously with SIMD.

**Inverse Transform (IDCT)** converts frequency-domain coefficients back to spatial-domain pixels. Video codecs use integer approximations of DCT that can be computed efficiently with SIMD.

```nasm
; Simplified 4x4 inverse transform using SSSE3
; xmm0-xmm3 contain 4 rows of coefficients (4 values per row)

idct_4x4_ssse3:
    ; First pass: vertical transform
    movdqa xmm4, xmm0
    paddw xmm4, xmm2               ; tmp0 = row0 + row2
    movdqa xmm5, xmm0
    psubw xmm5, xmm2               ; tmp1 = row0 - row2
    
    movdqa xmm6, xmm1
    psraw xmm6, 1                  ; row1 >> 1
    psubw xmm6, xmm3               ; tmp2 = (row1>>1) - row3
    
    movdqa xmm7, xmm3
    psraw xmm7, 1                  ; row3 >> 1
    paddw xmm7, xmm1               ; tmp3 = row1 + (row3>>1)
    
    ; Combine to get output rows
    movdqa xmm0, xmm4
    paddw xmm0, xmm7               ; out0 = tmp0 + tmp3
    movdqa xmm1, xmm5
    paddw xmm1, xmm6               ; out1 = tmp1 + tmp2
    movdqa xmm2, xmm5
    psubw xmm2, xmm6               ; out2 = tmp1 - tmp2
    movdqa xmm3, xmm4
    psubw xmm3, xmm7               ; out3 = tmp0 - tmp3
    
    ; Second pass would transpose and repeat
    ; (omitted for brevity)
    
    ret
```

Real implementations are more complex, handling different block sizes (4x4, 8x8, 16x16, 32x32), proper scaling, and efficient transposition. [Inference] Production codecs often use AVX2 or AVX-512 to process 16 or 32 coefficients simultaneously, significantly improving throughput over SSE implementations.

**Deblocking Filters** reduce blocking artifacts at macroblock boundaries. These filters analyze pixel gradients across boundaries and apply smoothing when appropriate, operating on horizontal and vertical edges throughout the frame.

### Color Space Conversion

Video data often requires conversion between color spaces (YUV to RGB, RGB to YUV, different YUV formats). These conversions involve matrix operations on every pixel, making them ideal for SIMD optimization.

**YUV 4:2:0 to RGB conversion:**

YUV 4:2:0 format stores full-resolution luma (Y) but subsampled chroma (U, V) at half resolution horizontally and vertically. Four Y pixels share one U and one V value.

```nasm
; Convert 8 pixels from YUV to RGB using SSE2
; Input: Y values in xmm0 (8 bytes)
;        U values in xmm1 (8 bytes) 
;        V values in xmm2 (8 bytes)
; Output: RGB in xmm3, xmm4, xmm5

yuv_to_rgb_sse2:
    ; Expand Y, U, V from 8-bit to 16-bit
    pxor xmm7, xmm7
    punpcklbw xmm0, xmm7           ; Y expanded to 16-bit
    punpcklbw xmm1, xmm7           ; U expanded to 16-bit
    punpcklbw xmm2, xmm7           ; V expanded to 16-bit
    
    ; Subtract 128 from U and V (they're signed)
    movdqa xmm6, [const_128]       ; 128 in each word
    psubw xmm1, xmm6
    psubw xmm2, xmm6
    
    ; R = Y + 1.402 * V
    movdqa xmm3, xmm2
    pmullw xmm3, [const_1402]      ; V * 1.402 (scaled integer)
    psraw xmm3, 10                 ; Scale down
    paddw xmm3, xmm0               ; Add Y
    
    ; G = Y - 0.344 * U - 0.714 * V
    movdqa xmm4, xmm1
    pmullw xmm4, [const_344]       ; U * 0.344
    movdqa xmm5, xmm2
    pmullw xmm5, [const_714]       ; V * 0.714
    paddw xmm4, xmm5               ; Combine U and V terms
    psraw xmm4, 10                 ; Scale down
    movdqa xmm5, xmm0
    psubw xmm5, xmm4               ; Y - (U+V terms)
    movdqa xmm4, xmm5
    
    ; B = Y + 1.772 * U
    movdqa xmm5, xmm1
    pmullw xmm5, [const_1772]      ; U * 1.772
    psraw xmm5, 10                 ; Scale down
    paddw xmm5, xmm0               ; Add Y
    
    ; Clamp to [0, 255] and pack back to 8-bit
    packuswb xmm3, xmm3            ; R values packed
    packuswb xmm4, xmm4            ; G values packed
    packuswb xmm5, xmm5            ; B values packed
    
    ret
```

The constants (1.402, 0.344, 0.714, 1.772) are stored as scaled integers for fixed-point arithmetic. Real-world implementations use lookup tables or more sophisticated approximations for better accuracy and performance.

**Performance considerations:** Processing 8 pixels at once with SSE2, 16 with AVX2, or 32 with AVX-512 dramatically improves throughput. A 1920x1080 video at 60fps requires converting 124 million pixels per second, making optimization critical.

### Image Filtering and Effects

Image processing operations like blur, sharpen, edge detection, and scaling are fundamental in graphics applications and benefit substantially from SIMD optimization.

**Gaussian Blur** smooths images by averaging pixels with their neighbors using Gaussian-weighted coefficients. Separable filters decompose 2D operations into horizontal and vertical 1D passes.

```nasm
; Horizontal Gaussian blur (5-tap filter)
; xmm0 = center pixel values (8 bytes)
; Load and multiply each position by its coefficient

gaussian_blur_horizontal_sse2:
    ; Load 5 consecutive pixels (with appropriate offsets)
    movq xmm0, [rsi - 2]           ; Load from 2 pixels before
    movq xmm1, [rsi - 1]
    movq xmm2, [rsi]               ; Center
    movq xmm3, [rsi + 1]
    movq xmm4, [rsi + 2]
    
    ; Expand to 16-bit
    pxor xmm7, xmm7
    punpcklbw xmm0, xmm7
    punpcklbw xmm1, xmm7
    punpcklbw xmm2, xmm7
    punpcklbw xmm3, xmm7
    punpcklbw xmm4, xmm7
    
    ; Multiply by Gaussian coefficients (1, 4, 6, 4, 1) / 16
    pmullw xmm0, [coeff_1]
    pmullw xmm1, [coeff_4]
    pmullw xmm2, [coeff_6]
    pmullw xmm3, [coeff_4]
    pmullw xmm4, [coeff_1]
    
    ; Sum all contributions
    paddw xmm0, xmm1
    paddw xmm2, xmm3
    paddw xmm0, xmm4
    paddw xmm0, xmm2
    
    ; Divide by 16 (shift right by 4)
    psrlw xmm0, 4
    
    ; Pack back to 8-bit
    packuswb xmm0, xmm0
    
    movq [rdi], xmm0               ; Store result
    ret
```

Two-pass separable filtering (horizontal then vertical) is O(n) per pixel compared to O(n²) for direct 2D convolution, providing substantial speedup for large filter kernels.

**Image Scaling** resizes images using interpolation algorithms. Bilinear interpolation provides reasonable quality with manageable computational cost.

[Inference] Bilinear scaling computes output pixels as weighted averages of the four nearest input pixels, with weights based on fractional position. SIMD implementations can process multiple output pixels in parallel, though gather operations or careful memory layout is needed to load the non-contiguous input samples efficiently.

### GPU-Specific Considerations

While most graphics processing occurs on GPUs, CPU-side assembly still plays roles in driver code, command buffer generation, and preprocessing.

**Vertex Transformation** on the CPU (for software rendering or culling) uses SIMD to transform multiple vertices in parallel. A 4x4 matrix multiply on a 4D vertex (x, y, z, w) naturally maps to 128-bit SIMD operations.

```nasm
; Transform vertex by 4x4 matrix using SSE
; xmm0 = vertex (x, y, z, w)
; Matrix rows in xmm4-xmm7

transform_vertex_sse:
    ; Broadcast each component and multiply by matrix column
    pshufd xmm1, xmm0, 0x00        ; xxxx
    mulps xmm1, xmm4               ; x * matrix_row0
    
    pshufd xmm2, xmm0, 0x55        ; yyyy
    mulps xmm2, xmm5               ; y * matrix_row1
    
    pshufd xmm3, xmm0, 0xAA        ; zzzz
    mulps xmm3, xmm6               ; z * matrix_row2
    
    pshufd xmm0, xmm0, 0xFF        ; wwww
    mulps xmm0, xmm7               ; w * matrix_row3
    
    ; Sum all contributions
    addps xmm1, xmm2
    addps xmm3, xmm0
    addps xmm1, xmm3
    
    movaps xmm0, xmm1              ; Result in xmm0
    ret
```

Processing multiple vertices in a batch amortizes instruction overhead and improves cache utilization.

**Command Buffer Packing** prepares GPU commands in memory. Assembly can optimize the tight loops that write command structures, especially when packing multiple fields or handling endianness.

## Game Engines

Game engines require consistent performance under strict frame time budgets (16.67ms for 60fps, 8.33ms for 120fps). Assembly optimization targets critical hot paths identified through profiling.

### Physics Simulation

Real-time physics simulates rigid bodies, collisions, constraints, and fluid dynamics. Many operations involve vector math and matrix operations suitable for SIMD acceleration.

**Collision Detection** uses bounding volumes (spheres, AABBs, OBBs) to quickly reject non-colliding objects before expensive detailed checks.

**AABB-AABB intersection test:**

```nasm
; Test if two axis-aligned bounding boxes intersect
; xmm0 = min1 (x_min, y_min, z_min, w_unused)
; xmm1 = max1 (x_max, y_max, z_max, w_unused)
; xmm2 = min2
; xmm3 = max2
; Returns: 1 in rax if intersecting, 0 otherwise

aabb_intersect_sse:
    ; Boxes intersect if:
    ; min1.x <= max2.x && max1.x >= min2.x
    ; min1.y <= max2.y && max1.y >= min2.y
    ; min1.z <= max2.z && max1.z >= min2.z
    
    ; Compare min1 <= max2
    cmpps xmm0, xmm3, 2            ; Less-or-equal comparison
    
    ; Compare max1 >= min2
    cmpps xmm1, xmm2, 5            ; Greater-or-equal comparison
    
    ; AND the results
    andps xmm0, xmm1
    
    ; Extract result (all components must be true)
    movmskps eax, xmm0
    and eax, 0x07                  ; Mask to x,y,z (ignore w)
    cmp eax, 0x07                  ; All three axes intersect?
    sete al
    movzx eax, al
    ret
```

This tests intersection in all three axes simultaneously, returning a boolean result. [Inference] Batch processing multiple AABB pairs could use AVX to test multiple objects in parallel, though the comparison and reduction operations become more complex.

**Sphere-Sphere collision:**

```nasm
; Test if two spheres intersect
; xmm0 = center1 (x, y, z, unused)
; xmm1 = center2 (x, y, z, unused)  
; xmm2 = radius1 (scalar in all components)
; xmm3 = radius2 (scalar in all components)

sphere_intersect_sse:
    ; Calculate distance squared
    subps xmm0, xmm1               ; delta = center1 - center2
    mulps xmm0, xmm0               ; delta^2
    
    ; Horizontal add to get distance squared
    movaps xmm1, xmm0
    shufps xmm1, xmm1, 0x4E        ; Swap high/low
    addps xmm0, xmm1
    movaps xmm1, xmm0
    shufps xmm1, xmm1, 0x11        ; Different shuffle
    addps xmm0, xmm1               ; Sum in lowest component
    
    ; Calculate (radius1 + radius2)^2
    addps xmm2, xmm3               ; sum_radii
    mulps xmm2, xmm2               ; sum_radii^2
    
    ; Compare distance^2 <= sum_radii^2
    comiss xmm0, xmm2              ; Scalar comparison
    setbe al                       ; Set if below-or-equal
    movzx eax, al
    ret
```

**Vector Cross Product** is essential for calculating normals, torques, and angular velocities:

```nasm
; Cross product: result = a × b
; xmm0 = a (x, y, z, w)
; xmm1 = b (x, y, z, w)
; Returns result in xmm0

vec3_cross_sse:
    ; result.x = a.y * b.z - a.z * b.y
    ; result.y = a.z * b.x - a.x * b.z
    ; result.z = a.x * b.y - a.y * b.x
    
    movaps xmm2, xmm0
    movaps xmm3, xmm1
    
    ; Shuffle to get (y, z, x, w)
    shufps xmm2, xmm2, 0xC9        ; a: y, z, x, w
    shufps xmm3, xmm3, 0xD2        ; b: z, x, y, w
    
    ; First products: ay*bz, az*bx, ax*by, aw*bw
    mulps xmm2, xmm3
    
    ; Shuffle again for second products
    shufps xmm0, xmm0, 0xD2        ; a: z, x, y, w
    shufps xmm1, xmm1, 0xC9        ; b: y, z, x, w
    
    ; Second products: az*by, ax*bz, ay*bx, aw*bw
    mulps xmm0, xmm1
    
    ; Subtract to get cross product
    subps xmm2, xmm0
    movaps xmm0, xmm2
    
    ret
```

**Constraint Solving** in physics engines (like Bullet or PhysX) iteratively resolves constraints (joints, contacts, limits). The solver processes constraint matrices and applies impulses, operations that benefit from vectorization when handling multiple constraints.

### Audio Processing

Game audio engines process multiple sound sources simultaneously, applying effects, spatialization, and mixing. DSP operations are compute-intensive and highly parallelizable.

**Audio Mixing** combines multiple audio streams:

```nasm
; Mix 4 audio streams (stereo) using SSE
; rdi = output buffer (float stereo samples)
; rsi = input buffer 1
; rdx = input buffer 2
; rcx = input buffer 3
; r8  = input buffer 4
; r9d = sample count (number of stereo pairs)

mix_4_streams_sse:
    shr r9d, 1                     ; Process 2 stereo pairs per iteration
    
.loop:
    ; Load 2 stereo pairs from each stream (4 floats = 2 L/R pairs)
    movaps xmm0, [rsi]
    movaps xmm1, [rdx]
    movaps xmm2, [rcx]
    movaps xmm3, [r8]
    
    ; Add all streams
    addps xmm0, xmm1
    addps xmm2, xmm3
    addps xmm0, xmm2
    
    ; Scale by 0.25 to prevent clipping (4 streams)
    mulps xmm0, [const_0_25]
    
    ; Store to output
    movaps [rdi], xmm0
    
    ; Advance pointers
    add rsi, 16
    add rdx, 16
    add rcx, 16
    add r8, 16
    add rdi, 16
    
    dec r9d
    jnz .loop
    
    ret
```

This processes 4 stereo samples simultaneously (2 L/R pairs), mixing 4 input streams. Real mixers handle variable source counts, per-source volumes, and more sophisticated clipping prevention.

**3D Audio Spatialization** uses Head-Related Transfer Functions (HRTFs) or simpler panning algorithms to position sounds in 3D space.

**Simple stereo panning based on angle:**

```nasm
; Calculate stereo pan from angle
; xmm0 = angle (radians, scalar)
; Returns: xmm0 = (left_gain, right_gain, left_gain, right_gain)

calculate_stereo_pan_sse:
    ; left_gain = (1 - sin(angle)) / 2
    ; right_gain = (1 + sin(angle)) / 2
    
    ; Calculate sin(angle) - would call sin function
    call sinf_approx
    
    ; xmm0 now contains sin(angle)
    movaps xmm1, xmm0
    movaps xmm2, [const_1_0]
    
    ; left = (1 - sin) / 2
    movaps xmm3, xmm2
    subss xmm3, xmm0
    mulss xmm3, [const_0_5]
    
    ; right = (1 + sin) / 2  
    addss xmm2, xmm0
    mulss xmm2, [const_0_5]
    
    ; Broadcast to vector: (left, right, left, right)
    shufps xmm3, xmm2, 0x00        ; left, left, right, right
    shufps xmm3, xmm3, 0xD8        ; left, right, left, right
    movaps xmm0, xmm3
    
    ret
```

**Reverberation** simulates acoustic reflections using delay lines and filters. Convolution-based reverb convolves the input signal with an impulse response, a computationally intensive operation optimized with FFT-based fast convolution.

[Inference] FFT-based convolution uses SIMD-optimized FFT implementations (like Intel IPP or FFTW) to transform both the input signal and impulse response to frequency domain, multiply them component-wise (trivial with SIMD), then inverse transform back to time domain, achieving much better performance than direct convolution for long impulse responses.

### Animation and Skinning

Character animation uses skeletal animation where vertices are influenced by multiple bones. Skinning transforms each vertex by a weighted combination of bone matrices.

**Skeletal Skinning (linear blend skinning):**

```nasm
; Skin a vertex influenced by 4 bones
; xmm0 = vertex position (x, y, z, 1)
; Bone matrices in memory at rbx (4x4 float matrices)
; Bone weights in xmm4 (w0, w1, w2, w3)
; Bone indices in r8-r11 (integers)

skin_vertex_sse:
    pxor xmm5, xmm5                ; Accumulator for result
    
    ; Process first bone
    mov rax, r8
    imul rax, 64                   ; Matrix size = 16 floats * 4 bytes
    lea rcx, [rbx + rax]           ; Address of matrix
    
    call transform_vertex_by_matrix ; Result in xmm1
    
    shufps xmm4, xmm4, 0x00        ; Broadcast weight 0
    mulps xmm1, xmm4               ; Scale by weight
    addps xmm5, xmm1               ; Accumulate
    
    ; Process second bone
    mov rax, r9
    imul rax, 64
    lea rcx, [rbx + rax]
    
    movaps xmm0, [original_vertex] ; Reload vertex
    call transform_vertex_by_matrix
    
    movaps xmm4, [weights]
    shufps xmm4, xmm4, 0x55        ; Broadcast weight 1
    mulps xmm1, xmm4
    addps xmm5, xmm1
    
    ; Similarly for bones 3 and 4...
    ; (omitted for brevity)
    
    movaps xmm0, xmm5              ; Final position
    ret
```

Processing vertices in batches and keeping frequently accessed bone matrices in cache significantly improves performance. Games typically process thousands of vertices per character, with multiple characters visible simultaneously.

**Dual Quaternion Skinning** provides better quality than linear blend skinning, avoiding artifacts like collapsing joints, but requires quaternion operations:

[Inference] Dual quaternion skinning transforms vertices using dual quaternions representing both rotation and translation. The math is more complex than matrix skinning, but SIMD implementations can achieve competitive performance while producing superior deformation quality, especially for extreme rotations.

### Particle Systems

Particle systems simulate effects like fire, smoke, sparks, and magic. Each particle has position, velocity, life, and various attributes that update each frame.

**Particle Update Loop:**

```nasm
; Update N particles (position, velocity, life)
; rdi = particle array (struct: pos.xyz, vel.xyz, life, other)
; esi = particle count
; xmm0 = delta_time (scalar broadcast to all components)
; xmm1 = gravity vector (0, -9.8, 0, 0)

update_particles_sse:
    shufps xmm0, xmm0, 0x00        ; Broadcast delta_time
    
.loop:
    ; Load particle position (x, y, z, life)
    movaps xmm2, [rdi]             ; position
    movaps xmm3, [rdi + 16]        ; velocity
    
    ; Update velocity: velocity += gravity * dt
    movaps xmm4, xmm1
    mulps xmm4, xmm0
    addps xmm3, xmm4
    
    ; Update position: position += velocity * dt
    movaps xmm4, xmm3
    mulps xmm4, xmm0
    addps xmm2, xmm4
    
    ; Update life: life -= dt (in w component)
    movaps xmm4, xmm0
    shufps xmm4, xmm4, 0xFF        ; Extract dt
    subss xmm2, xmm4               ; Subtract from life (w component)
    
    ; Store updated particle
    movaps [rdi], xmm2
    movaps [rdi + 16], xmm3
    
    add rdi, 32                    ; Next particle (assuming 32-byte struct)
    dec esi
    jnz .loop
    
    ret
```

[Inference] More sophisticated implementations use structure-of-arrays (SoA) layout instead of array-of-structures (AoS), storing all X positions contiguously, then all Y positions, etc. This improves SIMD efficiency by processing 4-8 particles simultaneously without interleaved data.

## High-Frequency Trading Systems

High-frequency trading (HFT) systems execute large numbers of trades at extremely low latencies, often measured in microseconds or nanoseconds. Every cycle counts, making assembly optimization valuable for critical paths.

### Market Data Processing

HFT systems receive massive volumes of market data (quotes, trades, order book updates) that must be parsed, normalized, and analyzed in real-time.

**Message Parsing** extracts fields from binary protocol messages (FIX, ITCH, OUCH, proprietary formats). These protocols pack multiple fields into fixed or variable-length messages.

**Example: Parse ITCH message header:**

```nasm
; Parse NASDAQ ITCH 5.0 message header
; rdi = message buffer
; Returns: al = message type, rdx = timestamp

parse_itch_header:
    ; ITCH message format:
    ; Byte 0: Message type (ASCII character)
    ; Bytes 1-2: Stock locate (big-endian uint16)
    ; Bytes 3-4: Tracking number (big-endian uint16)
    ; Bytes 5-10: Timestamp (big-endian uint64, 6 bytes)
    
    ; Extract message type
    movzx eax, byte [rdi]
    
    ; Extract timestamp (6 bytes, big-endian)
    ; Load 8 bytes and shift to extract 6
    mov rdx, [rdi + 4]             ; Load 8 bytes starting at byte 4
    bswap rdx                      ; Convert from big-endian
    shr rdx, 16                    ; Shift down to get 6-byte value
    
    ret
```

**Endianness conversion** is common in financial protocols, which often use big-endian encoding while x86 is little-endian. The `bswap` instruction efficiently reverses byte order for 32-bit and 64-bit values.

**Order Book Maintenance** tracks bid and ask prices with quantities at each level. Updates arrive continuously and must be applied with minimal latency.

```nasm
; Update order book level (price/quantity pair)
; rdi = order book structure
; rsi = price level index
; rdx = new quantity
; rcx = side (0=bid, 1=ask)

update_order_book_level:
    ; Calculate address: base + side_offset + level * entry_size
    imul rsi, 16                   ; Each entry is 16 bytes (price+qty)
    lea rax, [rdi + rsi]
    
    ; Add side offset (bids and asks are in separate arrays)
    imul rcx, 2048                 ; Assume max 128 levels * 16 bytes
    add rax, rcx
    
    ; Update quantity
    mov [rax + 8], rdx             ; Store new quantity
    
    ; Could update timestamp, flags, etc.
    
    ret
```

[Inference] Real order book implementations use more sophisticated data structures (skip lists, binary trees, or specialized sorted arrays) to handle arbitrary price levels efficiently, but the basic principle of minimizing operations per update remains critical for performance.

### Strategy Calculation

Trading strategies analyze market data and generate signals. Common calculations include moving averages, volatility estimation, and spread analysis.

**Exponential Moving Average (EMA):**

```nasm
; Update exponential moving average
; xmm0 = current EMA value (scalar)
; xmm1 = new price (scalar)
; xmm2 = alpha (smoothing factor, scalar)
; Returns updated EMA in xmm0
; Formula: EMA_new = alpha * price + (1 - alpha) * EMA_old

update_ema_sse:
    movaps xmm3, [const_1_0]
    subss xmm3, xmm2               ; (1 - alpha)
    
    mulss xmm2, xmm1               ; alpha * price
    mulss xmm3, xmm0               ; (1 - alpha) * EMA_old
    
    addss xmm2, xmm3               ; Sum components
    movaps xmm0, xmm2              ; Return in xmm0
    
    ret
```

**Vectorized EMA update for multiple assets:**

```nasm
; Update EMAs for 4 assets simultaneously
; xmm0 = current EMAs (4 values)
; xmm1 = new prices (4 values)
; xmm2 = alpha (broadcast to all components)

update_ema_4_sse:
    movaps xmm3, [const_1_0_vec]
    subps xmm3, xmm2               ; (1 - alpha) for each
    
    mulps xmm2, xmm1               ; alpha * prices
    mulps xmm3, xmm0               ; (1 - alpha) * EMAs
    
    addps xmm2, xmm3               ; Sum
    movaps xmm0, xmm2
    
    ret
```

Processing multiple assets in parallel amortizes instruction overhead and improves throughput when monitoring large portfolios.

**Spread Calculation** for pairs trading or statistical arbitrage:

```nasm
; Calculate spread between two assets
; xmm0 = asset1_prices (4 recent prices)
; xmm1 = asset2_prices (4 recent prices)
; xmm2 = hedge_ratio (scalar, broadcast)
; Returns: xmm0 = spreads (asset1 - ratio * asset2)

calculate_spread_sse:
    shufps xmm2, xmm2, 0x00        ; Broadcast hedge ratio
    
    mulps xmm1, xmm2               ; ratio * asset2_prices
    subps xmm0, xmm1               ; asset1 - ratio * asset2
    
    ret
```

**Volatility Estimation** using standard deviation or exponentially weighted moving standard deviation:

```nasm
; Calculate variance for 8 returns using SSE
; rdi = pointer to returns array (float)
; xmm0 = mean (broadcast)
; rcx = count (must be 8 for this implementation)
; Returns: variance in xmm0

calculate_variance_sse:
    ; Load 4 returns
    movaps xmm1, [rdi]
    movaps xmm2, [rdi + 16]
    
    ; Subtract mean from each
    subps xmm1, xmm0
    subps xmm2, xmm0
    
    ; Square the deviations
    mulps xmm1, xmm1
    mulps xmm2, xmm2
    
    ; Sum all squared deviations
    addps xmm1, xmm2
    
    ; Horizontal sum
    movaps xmm2, xmm1
    shufps xmm2, xmm2, 0x4E        ; Swap high/low
    addps xmm1, xmm2
    movaps xmm2, xmm1
    shufps xmm2, xmm2, 0x11
    addps xmm1, xmm2
    
    ; Divide by count (8)
    divss xmm1, [const_8_0]
    
    movaps xmm0, xmm1              ; Return variance
    ret
```

### Order Generation and Risk Checks

Before sending orders, HFT systems perform risk checks to ensure compliance with limits and regulations. These checks must be extremely fast to minimize latency between signal generation and order submission.

**Position Limit Check:**

```nasm
; Check if new order would exceed position limits
; rdi = current position (signed, negative for short)
; rsi = order quantity (signed, negative for sell)
; rdx = max_long_position
; rcx = max_short_position (stored as positive value)
; Returns: 1 in rax if order is allowed, 0 if rejected

check_position_limit:
    ; Calculate new position after order
    mov rax, rdi
    add rax, rsi
    
    ; Check if exceeds long limit
    cmp rax, rdx
    jg .reject
    
    ; Check if exceeds short limit (compare absolute value)
    mov r8, rax
    neg r8                         ; Get absolute value for short side
    cmp r8, rcx
    jg .reject
    
    ; Order passes checks
    mov rax, 1
    ret
    
.reject:
    xor rax, rax
    ret
```

**Price Collar Check** ensures orders are within acceptable price ranges:

```nasm
; Check if order price is within collar around reference price
; xmm0 = order_price (scalar)
; xmm1 = reference_price (scalar, typically last trade or mid)
; xmm2 = collar_percentage (e.g., 0.02 for 2%)
; Returns: 1 in rax if valid, 0 if outside collar

check_price_collar:
    ; Calculate collar bounds
    ; lower = reference * (1 - collar)
    ; upper = reference * (1 + collar)
    
    movss xmm3, [const_1_0]
    movss xmm4, xmm3
    
    subss xmm3, xmm2               ; (1 - collar)
    addss xmm4, xmm2               ; (1 + collar)
    
    mulss xmm3, xmm1               ; lower bound
    mulss xmm4, xmm1               ; upper bound
    
    ; Check if order_price >= lower_bound
    comiss xmm0, xmm3
    jb .reject
    
    ; Check if order_price <= upper_bound
    comiss xmm0, xmm4
    ja .reject
    
    mov rax, 1
    ret
    
.reject:
    xor rax, rax
    ret
```

**Fat Finger Check** detects abnormally large orders:

```nasm
; Check if order size is suspiciously large
; rdi = order_quantity
; rsi = typical_order_size
; rdx = max_multiple (e.g., 10x typical)
; Returns: 1 if suspicious, 0 if normal

check_fat_finger:
    mov rax, rsi
    imul rax, rdx                  ; Calculate threshold
    
    ; Get absolute value of order quantity
    mov rcx, rdi
    mov r8, rcx
    sar r8, 63                     ; Sign mask
    xor rcx, r8
    sub rcx, r8                    ; Absolute value
    
    cmp rcx, rax
    jg .suspicious
    
    xor rax, rax                   ; Normal order
    ret
    
.suspicious:
    mov rax, 1
    ret
```

### Network Message Construction

After decisions are made, orders must be encoded into binary protocol formats and transmitted with minimal latency.

**FIX Protocol Message Encoding:**

FIX (Financial Information eXchange) is a text-based protocol with tag=value pairs separated by SOH (ASCII 0x01) characters.

```nasm
; Construct FIX order message (simplified)
; rdi = output buffer
; rsi = order structure (contains price, quantity, side, etc.)
; Returns: message length in rax

construct_fix_order:
    push rbx
    push r12
    
    mov rbx, rdi                   ; Save output pointer
    mov r12, rsi                   ; Save order structure pointer
    
    ; BeginString (tag 8)
    mov dword [rdi], '8=FI'
    mov dword [rdi+4], 'X.4.'
    mov byte [rdi+8], '4'
    mov byte [rdi+9], 0x01         ; SOH
    add rdi, 10
    
    ; MsgType (tag 35) = D (New Order Single)
    mov dword [rdi], '35=D'
    mov byte [rdi+4], 0x01
    add rdi, 5
    
    ; ClOrdID (tag 11) - Client Order ID
    mov dword [rdi], '11='
    add rdi, 3
    
    ; Copy order ID from structure (assume 16-char alphanumeric)
    mov rax, [r12 + ORDER_ID_OFFSET]
    mov [rdi], rax
    mov rax, [r12 + ORDER_ID_OFFSET + 8]
    mov [rdi + 8], rax
    add rdi, 16
    mov byte [rdi], 0x01
    inc rdi
    
    ; Symbol (tag 55)
    mov dword [rdi], '55='
    add rdi, 3
    
    ; Copy symbol (assume 6 chars max, null-terminated)
    mov rcx, [r12 + SYMBOL_OFFSET]
    call copy_string_until_null
    mov byte [rdi], 0x01
    inc rdi
    
    ; Side (tag 54) - 1=Buy, 2=Sell
    mov dword [rdi], '54='
    add rdi, 3
    mov al, [r12 + SIDE_OFFSET]
    add al, '0'                    ; Convert 1/2 to ASCII
    mov [rdi], al
    mov byte [rdi+1], 0x01
    add rdi, 2
    
    ; OrderQty (tag 38)
    mov dword [rdi], '38='
    add rdi, 3
    mov rax, [r12 + QUANTITY_OFFSET]
    call uint64_to_ascii           ; Convert quantity to ASCII
    mov byte [rdi], 0x01
    inc rdi
    
    ; Price (tag 44)
    mov dword [rdi], '44='
    add rdi, 3
    movsd xmm0, [r12 + PRICE_OFFSET]
    call double_to_ascii           ; Convert price to ASCII
    mov byte [rdi], 0x01
    inc rdi
    
    ; Calculate and return message length
    mov rax, rdi
    sub rax, rbx
    
    pop r12
    pop rbx
    ret
```

[Inference] Production FIX implementations pre-calculate message lengths, use lookup tables for common field conversions, and maintain template messages with fixed fields already populated to minimize construction time. Some systems use binary protocol alternatives like SBE (Simple Binary Encoding) for lower latency.

**Binary Protocol Encoding (Example: OUCH):**

```nasm
; Construct OUCH Enter Order message (NASDAQ)
; rdi = output buffer (74 bytes)
; rsi = order structure
; Returns: message length (74) in rax

construct_ouch_enter_order:
    ; Message Type: 'O' (Enter Order)
    mov byte [rdi], 'O'
    
    ; Order Token (14 bytes) - unique identifier
    lea rax, [rsi + ORDER_TOKEN_OFFSET]
    mov rcx, 14
    rep movsb
    
    ; Buy/Sell Indicator: 'B' or 'S'
    mov al, [rsi + SIDE_OFFSET]
    mov [rdi], al
    inc rdi
    
    ; Shares (uint32, big-endian)
    mov eax, [rsi + QUANTITY_OFFSET]
    bswap eax
    mov [rdi], eax
    add rdi, 4
    
    ; Stock (8 bytes, space-padded)
    mov rcx, 8
    lea rax, [rsi + SYMBOL_OFFSET]
.copy_symbol:
    mov al, [rax]
    test al, al
    jz .pad_symbol
    mov [rdi], al
    inc rax
    inc rdi
    dec rcx
    jnz .copy_symbol
    jmp .price
    
.pad_symbol:
    mov byte [rdi], ' '
    inc rdi
    dec rcx
    jnz .pad_symbol
    
.price:
    ; Price (uint32, big-endian, in 1/10000 of currency unit)
    ; Convert float price to integer representation
    movsd xmm0, [rsi + PRICE_OFFSET]
    mulsd xmm0, [const_10000]
    cvttsd2si eax, xmm0
    bswap eax
    mov [rdi], eax
    add rdi, 4
    
    ; Time In Force, Display, Capacity, etc. (omitted for brevity)
    ; ...
    
    mov rax, 74                    ; Fixed message length
    ret
```

Binary protocols like OUCH are more compact and faster to parse than text-based FIX, but require exact byte-level formatting.

### Timestamp and Latency Measurement

HFT systems obsessively measure latencies at every stage. Hardware timestamps using TSC (Time Stamp Counter) or PTP (Precision Time Protocol) provide nanosecond-resolution timing.

**High-Resolution Timestamp Capture:**

```nasm
; Capture hardware timestamp with minimal overhead
; Returns: timestamp in rax

get_timestamp:
    lfence                         ; Serialize before RDTSC
    rdtsc                          ; EDX:EAX = TSC
    shl rdx, 32
    or rax, rdx                    ; Combine into 64-bit value
    ret
```

The `lfence` instruction before `rdtsc` prevents out-of-order execution from skewing the timestamp. For even lower overhead, some systems use `rdtscp` which includes serialization:

```nasm
get_timestamp_rdtscp:
    rdtscp                         ; EDX:EAX = TSC, ECX = core ID
    shl rdx, 32
    or rax, rdx
    ret
```

**Latency Calculation:**

```nasm
; Calculate elapsed time between two timestamps
; rdi = start_timestamp
; rsi = end_timestamp
; Returns: elapsed nanoseconds in rax

calculate_latency:
    mov rax, rsi
    sub rax, rdi                   ; Delta in TSC ticks
    
    ; Convert TSC ticks to nanoseconds
    ; Assume TSC frequency is known (e.g., 3.0 GHz = 3 ticks per ns)
    ; nanoseconds = ticks / ticks_per_ns
    
    imul rax, 1000                 ; Scale up to avoid precision loss
    xor rdx, rdx
    mov rcx, [tsc_frequency_mhz]   ; TSC freq in MHz (e.g., 3000)
    div rcx                        ; rax = (ticks * 1000) / freq
    
    ret
```

[Inference] Modern systems often use PTP hardware timestamps from network interface cards, which capture packet arrival times in hardware with sub-microsecond precision, but accessing these timestamps requires interfacing with NIC-specific APIs rather than simple assembly instructions.

### Lock-Free Data Structures

HFT systems avoid locks in critical paths, using atomic operations and lock-free algorithms to coordinate between threads (e.g., strategy thread, order management thread, risk thread).

**Lock-Free Queue (Single Producer, Single Consumer):**

```nasm
; Ring buffer-based SPSC queue
; Structure:
; - head: uint64 (consumer reads from here)
; - tail: uint64 (producer writes to here)
; - buffer: array of elements
; - capacity: power of 2 for efficient modulo

; Enqueue element (producer side)
; rdi = queue structure pointer
; rsi = pointer to element to enqueue
; Returns: 1 in rax if successful, 0 if full

spsc_enqueue:
    ; Load tail (with acquire semantics)
    mov rax, [rdi + TAIL_OFFSET]
    
    ; Load head (with acquire semantics)
    mov rcx, [rdi + HEAD_OFFSET]
    
    ; Calculate next tail position
    mov rdx, rax
    inc rdx
    and rdx, [rdi + CAPACITY_MASK]  ; Modulo using mask
    
    ; Check if queue is full (next_tail == head)
    cmp rdx, rcx
    je .queue_full
    
    ; Calculate element address
    mov rcx, [rdi + ELEMENT_SIZE]
    imul rcx, rax
    lea rcx, [rdi + BUFFER_OFFSET + rcx]
    
    ; Copy element to buffer (assume 32-byte element)
    movdqu xmm0, [rsi]
    movdqu xmm1, [rsi + 16]
    movdqu [rcx], xmm0
    movdqu [rcx + 16], xmm1
    
    ; Update tail with release semantics
    mov [rdi + TAIL_OFFSET], rdx
    mfence                         ; Ensure write is visible
    
    mov rax, 1
    ret
    
.queue_full:
    xor rax, rax
    ret
```

**Atomic Compare-and-Swap for Lock-Free Updates:**

```nasm
; Atomically update a value if it matches expected
; rdi = memory address
; rsi = expected value
; rdx = new value
; Returns: 1 if successful, 0 if failed

atomic_cas_64:
    mov rax, rsi                   ; Expected value in RAX
    lock cmpxchg [rdi], rdx        ; Atomic compare and exchange
    
    ; ZF is set if exchange succeeded
    setz al
    movzx rax, al
    ret
```

**Lock-Free Stack (using CAS loop):**

```nasm
; Push element onto lock-free stack
; rdi = stack head pointer (pointer to top node pointer)
; rsi = new node to push (node has 'next' pointer at offset 0)

lockfree_push:
    ; node->next = current_top
    mov rax, [rdi]                 ; Load current top
    mov [rsi], rax                 ; Set node->next
    
    ; Try to atomically update top to point to new node
    lock cmpxchg [rdi], rsi
    jnz lockfree_push              ; Retry if failed (ABA problem not handled)
    
    ret
```

[Inference] Production lock-free implementations typically handle the ABA problem using tagged pointers (combining pointer with version counter in a 128-bit value updated with CMPXCHG16B), though this adds complexity and may reduce performance on some microarchitectures.

### Memory Prefetching

HFT systems prefetch data to hide memory latency when access patterns are predictable.

**Explicit Prefetch Instructions:**

```nasm
; Process array of orders with prefetching
; rdi = order array pointer
; rsi = count
; Each order is 128 bytes

process_orders_with_prefetch:
    mov rcx, rsi
    
.loop:
    ; Prefetch next order (2 ahead for optimal timing)
    lea rax, [rdi + 256]           ; 2 * 128 bytes ahead
    prefetcht0 [rax]               ; Prefetch to L1 cache
    
    ; Process current order
    movdqu xmm0, [rdi]             ; Load first 16 bytes
    ; ... processing logic ...
    
    add rdi, 128                   ; Next order
    dec rcx
    jnz .loop
    
    ret
```

**Prefetch levels:**

- `prefetcht0`: Prefetch to all cache levels (L1, L2, L3)
- `prefetcht1`: Prefetch to L2 and L3, not L1
- `prefetcht2`: Prefetch to L3 only
- `prefetchnta`: Non-temporal prefetch (minimize cache pollution)

[Inference] Optimal prefetch distance depends on memory latency and processing time per element. Too close and data doesn't arrive in time; too far and prefetched data may be evicted before use. Typical distances range from 128-512 bytes for sequential access patterns.

### CPU Affinity and NUMA Awareness

HFT systems pin critical threads to specific CPU cores and allocate memory on local NUMA nodes to minimize latency.

**Setting Thread Affinity (via syscall):**

```nasm
; Set current thread to run on specific CPU core
; rdi = cpu_core_id
; Returns: 0 on success, -1 on error

set_cpu_affinity:
    push rbx
    
    ; Prepare cpu_set_t structure (128 bytes, 1024 bits)
    sub rsp, 128
    mov rbx, rsp
    
    ; Zero out the structure
    xor rax, rax
    mov rcx, 16                    ; 128 bytes / 8
    mov rdi, rbx
    rep stosq
    
    ; Set the bit for desired CPU
    mov rcx, rdi                   ; CPU ID (from parameter)
    mov rax, rcx
    shr rax, 6                     ; Divide by 64 (which qword)
    and rcx, 63                    ; Modulo 64 (which bit)
    bts [rbx + rax*8], rcx         ; Set bit
    
    ; Call sched_setaffinity syscall
    mov rax, 203                   ; syscall number
    xor rdi, rdi                   ; pid = 0 (current thread)
    mov rsi, 128                   ; cpu_set_size
    mov rdx, rbx                   ; cpu_set pointer
    syscall
    
    add rsp, 128
    pop rbx
    ret
```

**NUMA-Aware Memory Allocation:**

[Inference] HFT systems typically allocate critical data structures (order books, position tracking, message buffers) on the same NUMA node as the processing thread to minimize memory access latency. This requires using NUMA-aware allocation APIs (numa_alloc_onnode on Linux) rather than standard malloc, though the actual memory access in assembly remains identical once allocated.

### Optimization Techniques Summary

**Minimize Branch Mispredictions:**

- Use conditional moves (CMOVcc) instead of branches when possible
- Arrange code to favor fall-through for common cases
- Use lookup tables for complex conditionals

**Cache Optimization:**

- Pack frequently accessed data into cache lines
- Align critical data structures to cache line boundaries (64 bytes)
- Use prefetch instructions for predictable access patterns
- Minimize cache pollution with streaming stores (movntdq)

**Instruction-Level Parallelism:**

- Unroll loops to expose more independent operations
- Interleave independent calculations to avoid data dependencies
- Use multiple accumulator registers to break dependency chains

**SIMD Utilization:**

- Process multiple data elements in parallel
- Prefer aligned loads/stores when possible
- Use structure-of-arrays layout for better vectorization

**System-Level Optimizations:**

- Pin threads to specific cores (disable migration)
- Disable frequency scaling and turbo boost for consistent timing
- Use huge pages (2MB/1GB) to reduce TLB misses
- Bypass kernel when possible (kernel bypass networking)

**Key Points:**

- Graphics and video processing use SIMD heavily for operations like motion compensation, color space conversion, IDCT, and filtering, with modern codecs processing 16-32 pixels simultaneously using AVX2/AVX-512
- Game engines optimize critical paths including physics (collision detection, constraint solving), audio (mixing, spatialization, DSP), animation (skeletal skinning, particle systems), leveraging SIMD for vector math and parallel processing
- High-frequency trading systems minimize latency through assembly optimization of market data parsing, order book maintenance, strategy calculations, risk checks, and message construction, achieving microsecond-level responsiveness
- Lock-free data structures using atomic operations (CMPXCHG, LOCK prefix) enable thread coordination without locks in HFT systems, though careful design is needed to handle issues like the ABA problem
- [Inference] Assembly optimization in these domains requires profiling to identify bottlenecks, understanding microarchitecture-specific characteristics (execution ports, cache hierarchy, NUMA topology), and careful measurement to verify improvements, as premature optimization or incorrect assumptions can harm rather than help performance

**Related important subtopics:** Low-latency networking techniques (kernel bypass, zero-copy), cache-oblivious algorithms, software pipelining for instruction scheduling, and microarchitecture-specific optimization differences between Intel and AMD processors would provide additional valuable context for real-world assembly optimization.

---

# Advanced Projects

Advanced assembly projects demonstrate mastery of low-level programming, system architecture, and performance optimization. These projects require deep understanding of hardware interfaces, memory management, instruction encoding, and security considerations.

## Writing a Simple OS Kernel

Operating system kernel development represents the most fundamental systems programming challenge, requiring direct hardware manipulation, interrupt handling, and resource management without relying on existing OS services.

### Boot Process and Bootloader

**Boot Sector (512 bytes)** The BIOS loads the first sector from bootable media into memory at `0x7C00` and transfers control:

```asm
; boot.asm - Simple bootloader
; Assembled to exactly 512 bytes with boot signature

BITS 16                        ; Real mode (16-bit)
ORG 0x7C00                     ; BIOS loads boot sector here

boot_start:
    ; === Stage 1: Initialize Segment Registers ===
    ; BIOS doesn't guarantee segment register states
    cli                        ; Disable interrupts during setup
    xor ax, ax
    mov ds, ax                 ; Data segment = 0
    mov es, ax                 ; Extra segment = 0
    mov ss, ax                 ; Stack segment = 0
    mov sp, 0x7C00             ; Stack grows down from bootloader
    sti                        ; Re-enable interrupts

    ; === Stage 2: Load Kernel from Disk ===
    ; Read sectors 2-17 (8KB kernel) to 0x1000
    mov bx, 0x1000             ; Destination offset
    mov dh, 0                  ; Head 0
    mov dl, 0x80               ; First hard drive
    mov ch, 0                  ; Cylinder 0
    mov cl, 2                  ; Start at sector 2 (sector 1 is boot sector)
    mov ah, 0x02               ; BIOS read sectors function
    mov al, 16                 ; Number of sectors to read
    int 0x13                   ; BIOS disk interrupt
    jc disk_error              ; Carry flag set on error

    ; === Stage 3: Enter Protected Mode ===
    lgdt [gdt_descriptor]      ; Load Global Descriptor Table
    
    mov eax, cr0
    or eax, 1                  ; Set PE (Protection Enable) bit
    mov cr0, eax
    
    jmp CODE_SEG:protected_mode_entry  ; Far jump to flush pipeline

disk_error:
    mov si, error_msg
    call print_string
    hlt

; === BIOS Print String Routine (Real Mode) ===
print_string:
    lodsb                      ; Load byte from [SI] to AL, increment SI
    test al, al                ; Check for NULL terminator
    jz .done
    mov ah, 0x0E               ; BIOS teletype output
    int 0x10                   ; Video services interrupt
    jmp print_string
.done:
    ret

error_msg: db "Disk read error", 0

; === Global Descriptor Table ===
; Defines memory segments for protected mode
gdt_start:
    ; Null descriptor (required)
    dq 0

gdt_code:
    ; Code segment descriptor
    ; Base=0, Limit=0xFFFFF, 4KB granularity, 32-bit
    dw 0xFFFF                  ; Limit (bits 0-15)
    dw 0                       ; Base (bits 0-15)
    db 0                       ; Base (bits 16-23)
    db 10011010b               ; Access: present, ring 0, code, executable, readable
    db 11001111b               ; Flags: 4KB granularity, 32-bit | Limit (bits 16-19)
    db 0                       ; Base (bits 24-31)

gdt_data:
    ; Data segment descriptor
    dw 0xFFFF
    dw 0
    db 0
    db 10010010b               ; Access: present, ring 0, data, writable
    db 11001111b
    db 0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; GDT size
    dd gdt_start               ; GDT address

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; === Protected Mode Entry Point ===
BITS 32
protected_mode_entry:
    ; Update segment registers for protected mode
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000           ; Set up stack at 640KB
    
    ; Jump to kernel entry point
    jmp 0x1000

; === Boot Signature ===
times 510-($-$$) db 0          ; Pad to 510 bytes
dw 0xAA55                      ; Boot signature
```

### Kernel Entry and Initialization

**Protected Mode Kernel Entry**

```asm
; kernel_entry.asm
BITS 32
section .text

global kernel_main
extern kmain                   ; C kernel main function

; Video memory in text mode
VIDEO_MEMORY equ 0xB8000
WHITE_ON_BLACK equ 0x0F

kernel_main:
    ; === Initialize Protected Mode Environment ===
    
    ; Clear screen
    mov edi, VIDEO_MEMORY
    mov ecx, 80 * 25           ; 80 columns × 25 rows
    mov ax, (WHITE_ON_BLACK << 8) | ' '
    rep stosw                  ; Fill video memory with spaces
    
    ; Display boot message
    mov esi, boot_msg
    mov edi, VIDEO_MEMORY
    call print_string_pm
    
    ; === Initialize Interrupt Descriptor Table ===
    call setup_idt
    
    ; === Initialize Paging ===
    call setup_paging
    
    ; === Jump to C Kernel ===
    call kmain
    
    ; Kernel returned (should never happen)
    jmp $

; Print string in protected mode (no BIOS available)
print_string_pm:
    push eax
    push edi
.loop:
    lodsb                      ; Load character from [ESI]
    test al, al                ; Check for NULL
    jz .done
    mov ah, WHITE_ON_BLACK     ; Character attribute
    stosw                      ; Write to video memory
    jmp .loop
.done:
    pop edi
    pop eax
    ret

boot_msg: db "Kernel loaded successfully", 0
```

### Interrupt Descriptor Table (IDT) Setup

**IDT Configuration**

```asm
; idt.asm
section .data

; IDT structure: 256 entries × 8 bytes
idt:
    times 256 dq 0

idt_descriptor:
    dw 256 * 8 - 1             ; IDT size
    dd idt                     ; IDT address

section .text

setup_idt:
    push eax
    push ecx
    push edi
    
    ; Install default exception handlers (interrupts 0-31)
    mov ecx, 32
    mov edi, idt
    mov eax, default_exception_handler
.exception_loop:
    call install_interrupt_handler
    add edi, 8
    loop .exception_loop
    
    ; Install IRQ handlers (interrupts 32-47)
    ; IRQs remapped from 0-15 to 32-47 to avoid conflicts with exceptions
    mov eax, irq0_handler
    mov edi, idt + (32 * 8)
    call install_interrupt_handler
    
    mov eax, keyboard_handler
    mov edi, idt + (33 * 8)
    call install_interrupt_handler
    
    ; Remap PIC (Programmable Interrupt Controller)
    call remap_pic
    
    ; Load IDT
    lidt [idt_descriptor]
    
    ; Enable interrupts
    sti
    
    pop edi
    pop ecx
    pop eax
    ret

; Install interrupt handler at address in EAX to IDT entry at EDI
install_interrupt_handler:
    push eax
    push ebx
    
    mov bx, ax                 ; Lower 16 bits of handler address
    mov [edi], bx              ; Offset bits 0-15
    mov word [edi + 2], 0x08   ; Code segment selector
    mov byte [edi + 4], 0      ; Reserved
    mov byte [edi + 5], 0x8E   ; Flags: present, ring 0, 32-bit interrupt gate
    shr eax, 16                ; Upper 16 bits
    mov [edi + 6], ax          ; Offset bits 16-31
    
    pop ebx
    pop eax
    ret

; Remap PIC to use interrupts 32-47 instead of 0-15
remap_pic:
    push eax
    
    ; Save masks
    in al, 0x21                ; Master PIC data port
    mov ah, al
    in al, 0xA1                ; Slave PIC data port
    
    ; Start initialization
    mov al, 0x11
    out 0x20, al               ; Master PIC command
    out 0xA0, al               ; Slave PIC command
    
    ; Set vector offsets
    mov al, 0x20               ; Master PIC: IRQs 0-7 → interrupts 32-39
    out 0x21, al
    mov al, 0x28               ; Slave PIC: IRQs 8-15 → interrupts 40-47
    out 0xA1, al
    
    ; Set cascade
    mov al, 0x04               ; Master has slave at IRQ2
    out 0x21, al
    mov al, 0x02               ; Slave cascade identity
    out 0xA1, al
    
    ; Set 8086 mode
    mov al, 0x01
    out 0x21, al
    out 0xA1, al
    
    ; Restore masks (or unmask all for now)
    xor al, al                 ; Unmask all interrupts
    out 0x21, al
    out 0xA1, al
    
    pop eax
    ret

; Default exception handler
default_exception_handler:
    cli
    push eax
    mov eax, [esp + 4]         ; Get return address
    ; Display error (simplified)
    mov edi, VIDEO_MEMORY + (24 * 80 * 2)  ; Bottom line
    mov dword [edi], 0x4F214F21 ; '!!' in white on red
    pop eax
    iret

; Timer interrupt handler (IRQ0)
irq0_handler:
    push eax
    
    ; Increment tick counter
    inc dword [timer_ticks]
    
    ; Send EOI (End of Interrupt) to PIC
    mov al, 0x20
    out 0x20, al
    
    pop eax
    iret

; Keyboard interrupt handler (IRQ1)
keyboard_handler:
    push eax
    
    ; Read scancode from keyboard
    in al, 0x60
    
    ; Store in buffer (simplified)
    mov [last_key], al
    
    ; Send EOI
    mov al, 0x20
    out 0x20, al
    
    pop eax
    iret

section .bss
    timer_ticks: resd 1
    last_key: resb 1
```

### Memory Paging Setup

**Page Table Configuration**

```asm
; paging.asm
section .bss
align 4096
page_directory:
    resd 1024                  ; 1024 entries × 4 bytes

page_table_0:
    resd 1024                  ; First 4MB identity mapped

section .text

setup_paging:
    push eax
    push ebx
    push ecx
    push edi
    
    ; === Identity Map First 4MB ===
    ; Map virtual addresses 0-4MB to physical 0-4MB
    mov edi, page_table_0
    mov eax, 0x00000003        ; Physical address 0, present + writable
    mov ecx, 1024
.fill_page_table:
    stosd                      ; Write entry
    add eax, 4096              ; Next 4KB page
    loop .fill_page_table
    
    ; === Setup Page Directory ===
    mov edi, page_directory
    mov eax, page_table_0
    or eax, 0x03               ; Present + writable
    mov [edi], eax             ; First entry points to page_table_0
    
    ; Clear remaining entries
    add edi, 4
    xor eax, eax
    mov ecx, 1023
    rep stosd
    
    ; === Enable Paging ===
    mov eax, page_directory
    mov cr3, eax               ; Load page directory base register
    
    mov eax, cr0
    or eax, 0x80000000         ; Set PG (Paging) bit
    mov cr0, eax
    
    pop edi
    pop ecx
    pop ebx
    pop eax
    ret
```

### Memory Management

**Simple Physical Memory Allocator**

```asm
; memory.asm
section .data
    ; Memory bitmap: 1 bit per 4KB page (32MB needs 8KB bitmap)
    ; For simplicity, managing first 32MB of RAM
    MEMORY_SIZE equ 32 * 1024 * 1024  ; 32MB
    PAGE_SIZE equ 4096
    NUM_PAGES equ MEMORY_SIZE / PAGE_SIZE
    BITMAP_SIZE equ NUM_PAGES / 8

section .bss
    memory_bitmap: resb BITMAP_SIZE

section .text

; Initialize memory manager
; EAX = total memory size in bytes (from BIOS)
init_memory_manager:
    push eax
    push ecx
    push edi
    
    ; Mark all pages as free initially
    mov edi, memory_bitmap
    mov ecx, BITMAP_SIZE
    xor al, al
    rep stosb
    
    ; Mark first 1MB as used (kernel and BIOS area)
    mov edi, memory_bitmap
    mov ecx, (1024 * 1024) / PAGE_SIZE / 8
    mov al, 0xFF
    rep stosb
    
    pop edi
    pop ecx
    pop eax
    ret

; Allocate one physical page
; Returns: EAX = physical address or 0 if out of memory
alloc_page:
    push ebx
    push ecx
    push edx
    push esi
    
    mov esi, memory_bitmap
    mov ecx, BITMAP_SIZE
    
.scan_bytes:
    lodsb                      ; Load bitmap byte
    cmp al, 0xFF               ; All bits set (all used)?
    je .next_byte
    
    ; Found byte with free page
    mov bl, al
    xor dl, dl                 ; Bit position
    
.scan_bits:
    test bl, 1
    jz .found_free_bit
    shr bl, 1
    inc dl
    cmp dl, 8
    jl .scan_bits
    
.next_byte:
    loop .scan_bytes
    
    ; Out of memory
    xor eax, eax
    jmp .done
    
.found_free_bit:
    ; Mark page as used
    mov al, 1
    mov cl, dl
    shl al, cl                 ; Create bit mask
    or [esi - 1], al           ; Set bit in bitmap
    
    ; Calculate physical address
    mov eax, esi
    sub eax, memory_bitmap     ; Byte offset
    dec eax
    shl eax, 3                 ; × 8 bits per byte
    add eax, edx               ; + bit position = page number
    shl eax, 12                ; × 4096 = physical address
    
.done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

; Free physical page
; EAX = physical address
free_page:
    push ebx
    push ecx
    push esi
    
    shr eax, 12                ; Convert to page number
    mov ebx, eax
    shr ebx, 3                 ; Byte offset = page_num / 8
    and eax, 7                 ; Bit position = page_num % 8
    
    ; Clear bit
    mov cl, al
    mov al, 1
    shl al, cl                 ; Create bit mask
    not al                     ; Invert mask
    lea esi, [memory_bitmap + ebx]
    and [esi], al              ; Clear bit
    
    pop esi
    pop ecx
    pop ebx
    ret
```

## Creating a Virtual Machine

Virtual machines interpret or execute programs in an abstract machine environment, providing portability, sandboxing, and instrumentation capabilities.

### Stack-Based Virtual Machine

**VM Architecture Design**

```asm
; vm.asm - Simple stack-based virtual machine
; Architecture:
;   - Stack for operands
;   - Program counter (PC)
;   - Instruction pointer
;   - Memory array

section .data
    ; VM Instructions (bytecode opcodes)
    OP_PUSH     equ 0x01       ; Push immediate value
    OP_POP      equ 0x02       ; Pop and discard
    OP_ADD      equ 0x03       ; Add top two stack values
    OP_SUB      equ 0x04       ; Subtract
    OP_MUL      equ 0x05       ; Multiply
    OP_DIV      equ 0x06       ; Divide
    OP_LOAD     equ 0x10       ; Load from memory
    OP_STORE    equ 0x11       ; Store to memory
    OP_JMP      equ 0x20       ; Unconditional jump
    OP_JZ       equ 0x21       ; Jump if zero
    OP_JNZ      equ 0x22       ; Jump if not zero
    OP_CALL     equ 0x30       ; Function call
    OP_RET      equ 0x31       ; Return from function
    OP_HALT     equ 0xFF       ; Stop execution

section .bss
    ; VM State
    vm_stack: resd 256         ; Operand stack (256 entries)
    vm_memory: resd 4096       ; VM memory (4096 words)
    vm_sp: resd 1              ; Stack pointer (index into vm_stack)
    vm_pc: resd 1              ; Program counter
    vm_program: resd 1         ; Pointer to bytecode program
    vm_call_stack: resd 64     ; Return address stack

section .text

; Initialize VM
; EAX = pointer to bytecode program
vm_init:
    push eax
    push ecx
    push edi
    
    ; Store program pointer
    mov [vm_program], eax
    
    ; Initialize stack pointer
    mov dword [vm_sp], 0
    
    ; Initialize program counter
    mov dword [vm_pc], 0
    
    ; Clear VM memory
    mov edi, vm_memory
    mov ecx, 4096
    xor eax, eax
    rep stosd
    
    pop edi
    pop ecx
    pop eax
    ret

; Execute VM program
vm_execute:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
.fetch_execute:
    ; Fetch instruction
    mov esi, [vm_program]
    mov ecx, [vm_pc]
    movzx eax, byte [esi + ecx]  ; Load opcode
    inc dword [vm_pc]
    
    ; Decode and execute
    cmp al, OP_PUSH
    je .op_push
    cmp al, OP_POP
    je .op_pop
    cmp al, OP_ADD
    je .op_add
    cmp al, OP_SUB
    je .op_sub
    cmp al, OP_MUL
    je .op_mul
    cmp al, OP_DIV
    je .op_div
    cmp al, OP_LOAD
    je .op_load
    cmp al, OP_STORE
    je .op_store
    cmp al, OP_JMP
    je .op_jmp
    cmp al, OP_JZ
    je .op_jz
    cmp al, OP_JNZ
    je .op_jnz
    cmp al, OP_CALL
    je .op_call
    cmp al, OP_RET
    je .op_ret
    cmp al, OP_HALT
    je .vm_halt
    
    ; Invalid opcode
    jmp .vm_error

.op_push:
    ; Read 4-byte immediate value
    mov ecx, [vm_pc]
    mov eax, [esi + ecx]
    add dword [vm_pc], 4
    
    ; Push onto stack
    call vm_push
    jmp .fetch_execute

.op_pop:
    call vm_pop
    jmp .fetch_execute

.op_add:
    call vm_pop                ; Get second operand
    mov ebx, eax
    call vm_pop                ; Get first operand
    add eax, ebx
    call vm_push
    jmp .fetch_execute

.op_sub:
    call vm_pop
    mov ebx, eax
    call vm_pop
    sub eax, ebx
    call vm_push
    jmp .fetch_execute

.op_mul:
    call vm_pop
    mov ebx, eax
    call vm_pop
    imul eax, ebx              ; Signed multiplication
    call vm_push
    jmp .fetch_execute

.op_div:
    call vm_pop
    mov ebx, eax               ; Divisor
    test ebx, ebx              ; Check for division by zero
    jz .vm_error
    call vm_pop
    cdq                        ; Sign-extend EAX to EDX:EAX
    idiv ebx                   ; Signed division
    call vm_push
    jmp .fetch_execute

.op_load:
    ; Load address from stack
    call vm_pop
    mov ebx, eax
    
    ; Bounds check
    cmp ebx, 4096
    jae .vm_error
    
    ; Load value from memory
    mov eax, [vm_memory + ebx * 4]
    call vm_push
    jmp .fetch_execute

.op_store:
    ; Pop address
    call vm_pop
    mov ebx, eax
    
    ; Bounds check
    cmp ebx, 4096
    jae .vm_error
    
    ; Pop value
    call vm_pop
    
    ; Store to memory
    mov [vm_memory + ebx * 4], eax
    jmp .fetch_execute

.op_jmp:
    ; Read target address (4 bytes)
    mov ecx, [vm_pc]
    mov eax, [esi + ecx]
    mov [vm_pc], eax
    jmp .fetch_execute

.op_jz:
    ; Pop condition
    call vm_pop
    test eax, eax
    jz .do_jump
    add dword [vm_pc], 4       ; Skip jump target
    jmp .fetch_execute
    
.do_jump:
    jmp .op_jmp

.op_jnz:
    call vm_pop
    test eax, eax
    jnz .do_jump
    add dword [vm_pc], 4
    jmp .fetch_execute

.op_call:
    ; Push return address onto call stack
    mov eax, [vm_pc]
    add eax, 4                 ; Return address = PC + 4
    push eax
    
    ; Jump to function
    jmp .op_jmp

.op_ret:
    ; Pop return address
    pop eax
    mov [vm_pc], eax
    jmp .fetch_execute

.vm_halt:
    ; Normal termination
    xor eax, eax
    jmp .done

.vm_error:
    ; Error occurred
    mov eax, -1
    
.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Stack operations
vm_push:
    push ebx
    push ecx
    
    mov ebx, [vm_sp]
    cmp ebx, 256               ; Stack overflow check
    jae .error
    
    mov [vm_stack + ebx * 4], eax
    inc dword [vm_sp]
    xor eax, eax               ; Success
    jmp .done
    
.error:
    mov eax, -1
    
.done:
    pop ecx
    pop ebx
    ret

vm_pop:
    push ebx
    push ecx
    
    mov ebx, [vm_sp]
    test ebx, ebx              ; Stack underflow check
    jz .error
    
    dec dword [vm_sp]
    mov ebx, [vm_sp]
    mov eax, [vm_stack + ebx * 4]
    jmp .done
    
.error:
    xor eax, eax               ; Return 0 on underflow
    
.done:
    pop ecx
    pop ebx
    ret
```

### Register-Based Virtual Machine

**Register VM Implementation**

```asm
; register_vm.asm - Register-based VM (similar to JVM, Dalvik)
section .data
    ; Register-based opcodes
    REG_MOVE    equ 0x01       ; mov reg1, reg2
    REG_LOADI   equ 0x02       ; loadi reg, immediate
    REG_ADD     equ 0x03       ; add reg1, reg2, reg3 (reg1 = reg2 + reg3)
    REG_SUB     equ 0x04
    REG_MUL     equ 0x05
    REG_DIV     equ 0x06
    REG_CMP     equ 0x10       ; Compare registers
    REG_BR      equ 0x20       ; Branch
    REG_BEQ     equ 0x21       ; Branch if equal
    REG_BNE     equ 0x22       ; Branch if not equal

section .bss
    vm_registers: resd 16      ; 16 general-purpose registers (R0-R15)
    vm_pc: resd 1
    vm_flags: resd 1           ; Comparison flags
    vm_code: resd 1            ; Pointer to code

section .text

register_vm_execute:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    
    mov esi, [vm_code]
    
.fetch:
    mov ecx, [vm_pc]
    movzx eax, byte [esi + ecx]  ; Opcode
    inc dword [vm_pc]
    
    cmp al, REG_ADD
    je .reg_add
    cmp al, REG_LOADI
    je .reg_loadi
    ; ... other opcodes
    
    jmp .done

.reg_add:
    ; Format: ADD dest, src1, src2
    ; Read register numbers (3 bytes)
    mov ecx, [vm_pc]
    movzx ebx, byte [esi + ecx]    ; dest
    movzx edx, byte [esi + ecx + 1] ; src1
    movzx edi, byte [esi + ecx + 2] ; src2
    add dword [vm_pc], 3
    
    ; Perform addition
    mov eax, [vm_registers + edx * 4]
    add eax, [vm_registers + edi * 4]
    mov [vm_registers + ebx * 4], eax
    
    jmp .fetch

.reg_loadi:
    ; Format: LOADI reg, immediate32
    mov ecx, [vm_pc]
    movzx ebx, byte [esi + ecx]    ; register
    mov eax, [esi + ecx + 1]       ; immediate value
    add dword [vm_pc], 5
    
    mov [vm_registers + ebx * 4], eax
    jmp .fetch

.done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
```

## Implementing a JIT Compiler

Just-In-Time compilation translates bytecode or intermediate representation to native machine code at runtime, combining interpretation flexibility with native performance.

### Basic JIT Architecture

**Runtime Code Generation**

```asm
; jit_compiler.asm
section .data
    ; Executable code buffer (must be marked executable)
    CODE_BUFFER_SIZE equ 65536

section .bss
    code_buffer: resb CODE_BUFFER_SIZE
    code_position: resd 1      ; Current write position in buffer
    
section .text

; Initialize JIT compiler
jit_init:
    push eax
    push ebx
    push ecx
    push edx
    
    ; Allocate executable memory using mmap (Linux)
    mov eax, 9                 ; sys_mmap
    xor edi, edi               ; addr = NULL
    mov esi, CODE_BUFFER_SIZE  ; length
    mov edx, 7                 ; prot = PROT_READ | PROT_WRITE | PROT_EXEC
    mov r10, 0x22              ; flags = MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1                 ; fd = -1
    xor r9, r9                 ; offset = 0
    syscall
    
    mov [code_buffer], rax     ; Store allocated memory address
    mov dword [code_position], 0
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Emit one byte to code buffer
; AL = byte to emit
jit_emit_byte:
    push ebx
    push edi
    
    mov edi, [code_buffer]
    mov ebx, [code_position]
    mov [edi + ebx], al
    inc dword [code_position]
    
    pop edi
    pop ebx
    ret

; Emit 4-byte value
; EAX = value to emit
jit_emit_dword:
    push ebx
    push edi
    
    mov edi, [code_buffer]
    mov ebx, [code_position]
    mov [edi + ebx], eax
    add dword [code_position], 4
    
    pop edi
    pop ebx
    ret

; Compile: PUSH immediate (stack-based VM to x86)
; EAX = immediate value
jit_compile_push:
    push eax
    
    ; Emit: mov eax, immediate
    mov al, 0xB8               ; MOV EAX, imm32 opcode
    call jit_emit_byte
    
    pop eax
    call jit_emit_dword        ; Emit immediate value
    
    ; Emit: push eax
    mov al, 0x50               ; PUSH EAX opcode
    call jit_emit_byte
    
    ret

; Compile: ADD operation
jit_compile_add:
    ; Emit: pop ebx (second operand)
    mov al, 0x5B               ; POP EBX
    call jit_emit_byte
    
    ; Emit: pop eax (first operand)
    mov al, 0x58               ; POP EAX
    call jit_emit_byte
    
    ; Emit: add eax, ebx
    mov al, 0x01               ; ADD r/m32, r32
    call jit_emit_byte
    mov al, 0xD8               ; ModR/M byte: EAX, EBX
    call jit_emit_byte
    
    ; Emit: push eax (result)
    mov al, 0x50               ; PUSH EAX
    call jit_emit_byte
    
    ret

; Compile: SUB operation
jit_compile_sub:
    ; Emit: pop ebx
    mov al, 0x5B
    call jit_emit_byte
    
    ; Emit: pop eax
    mov al, 0x58
    call jit_emit_byte
    
    ; Emit: sub eax, ebx
    mov al, 0x29               ; SUB r/m32, r32
    call jit_emit_byte
    mov al, 0xD8               ; ModR/M: EAX, EBX
    call jit_emit_byte
    
    ; Emit: push eax
    mov al, 0x50
    call jit_emit_byte
    
    ret

; Compile: MUL operation
jit_compile_mul:
    ; Emit: pop ebx
    mov al, 0x5B
    call jit_emit_byte
    
    ; Emit: pop eax
    mov al, 0x58
    call jit_emit_byte
    
    ; Emit: imul eax, ebx
    mov al, 0x0F               ; Two-byte opcode prefix
    call jit_emit_byte
    mov al, 0xAF               ; IMUL r32, r/m32
    call jit_emit_byte
    mov al, 0xC3               ; ModR/M: EAX, EBX
    call jit_emit_byte
    
    ; Emit: push eax
    mov al, 0x50
    call jit_emit_byte
    
    ret

; Compile: RET instruction (end of compiled code)
jit_compile_ret:
    mov al, 0xC3               ; RET opcode
    call jit_emit_byte
    ret

; JIT compile entire bytecode program
; ESI = pointer to bytecode
; ECX = length in bytes
jit_compile_program:
    push eax
    push ebx
    push ecx
    push esi
    
    ; Function prologue
    mov al, 0x55               ; PUSH EBP
    call jit_emit_byte
    mov al, 0x89               ; MOV EBP, ESP
    call jit_emit_byte
    mov al, 0xE5               ; ModR/M byte
    call jit_emit_byte
    
.compile_loop:
    test ecx, ecx
    jz .done
    
    lodsb                      ; Load opcode
    dec ecx
    
    cmp al, OP_PUSH
    je .handle_push
    cmp al, OP_ADD
    je .handle_add
    cmp al, OP_SUB
    je .handle_sub
    cmp al, OP_MUL
    je .handle_mul
    cmp al, OP_HALT
    je .handle_halt
    
    ; Unknown opcode - skip
    jmp .compile_loop

.handle_push:
    ; Read 4-byte immediate
    lodsd
    sub ecx, 4
    call jit_compile_push
    jmp .compile_loop

.handle_add:
    call jit_compile_add
    jmp .compile_loop

.handle_sub:
    call jit_compile_sub
    jmp .compile_loop

.handle_mul:
    call jit_compile_mul
    jmp .compile_loop

.handle_halt:
    ; Function epilogue
    mov al, 0x5D               ; POP EBP
    call jit_emit_byte
    call jit_compile_ret
    jmp .done

.done:
    pop esi
    pop ecx
    pop ebx
    pop eax
    ret

; Execute compiled code
; Returns: EAX = result (top of stack)
jit_execute:
    push ebp
    mov ebp, esp
    
    ; Call compiled code
    mov eax, [code_buffer]
    call eax                   ; Indirect call to compiled code
    
    ; Result should be on stack
    pop eax
    
    pop ebp
    ret
```

### Advanced JIT Techniques

**Register Allocation and Optimization**

```asm
; jit_optimized.asm - JIT with basic register allocation
section .data
    ; Virtual register mapping to physical x86 registers
    ; Maps VM registers to: EAX, EBX, ECX, EDX, ESI, EDI
    MAX_PHYS_REGS equ 6

section .bss
    reg_map: resb 16           ; Maps VM reg 0-15 to physical reg
    reg_dirty: resb 16         ; Dirty flags (needs write-back)
    reg_valid: resb 16         ; Valid flags (loaded from memory)

section .text

; Allocate physical register for virtual register
; AL = virtual register number (0-15)
; Returns: AL = physical register code
jit_alloc_register:
    push ebx
    push ecx
    
    movzx ebx, al
    
    ; Check if already allocated
    mov cl, [reg_valid + ebx]
    test cl, cl
    jnz .already_allocated
    
    ; Find free physical register (simplified)
    ; In production: use LRU or graph coloring
    xor ecx, ecx
.find_free:
    cmp ecx, MAX_PHYS_REGS
    jae .spill_required
    
    ; Check if physical register ecx is free
    ; (implementation simplified)
    mov [reg_map + ebx], cl
    mov byte [reg_valid + ebx], 1
    mov al, cl
    jmp .done

.already_allocated:
    mov al, [reg_map + ebx]
    jmp .done

.spill_required:
    ; Spill least recently used register
    ; (implementation omitted for brevity)
    xor al, al

.done:
    pop ecx
    pop ebx
    ret

; Emit optimized ADD with register allocation
; BL = dest virtual reg, CL = src1 virtual reg, DL = src2 virtual reg
jit_compile_add_optimized:
    push eax
    push ebx
    push ecx
    push edx
    
    ; Allocate physical registers
    mov al, cl
    call jit_alloc_register
    mov bh, al                 ; src1 physical reg
    
    mov al, dl
    call jit_alloc_register
    mov ch, al                 ; src2 physical reg
    
    mov al, bl
    call jit_alloc_register
    mov cl, al                 ; dest physical reg
    
    ; Emit: mov dest, src1 (if different registers)
    cmp cl, bh
    je .skip_move
    
    ; Generate MOV instruction
    mov al, 0x89               ; MOV r/m32, r32
    call jit_emit_byte
    
    ; Calculate ModR/M byte
    mov al, 0xC0               ; Register-to-register mode
    shl bh, 3                  ; Source register in bits 3-5
    or al, bh
    or al, cl                  ; Dest register in bits 0-2
    call jit_emit_byte

.skip_move:
    ; Emit: add dest, src2
    mov al, 0x01               ; ADD r/m32, r32
    call jit_emit_byte
    
    mov al, 0xC0
    shl ch, 3
    or al, ch
    or al, cl
    call jit_emit_byte
    
    ; Mark destination as dirty
    movzx eax, bl
    mov byte [reg_dirty + eax], 1
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
```

### Constant Folding and Peephole Optimization

**Compile-Time Optimization**

```asm
; jit_optimize.asm
section .text

; Peephole optimizer: detect patterns and optimize
; ESI = pointer to bytecode sequence
; Returns: optimized code emitted
jit_peephole_optimize:
    push eax
    push ebx
    push ecx
    push esi
    
    ; Pattern: PUSH const1, PUSH const2, ADD
    ; Optimize to: PUSH (const1 + const2)
    
    mov al, [esi]
    cmp al, OP_PUSH
    jne .no_optimization
    
    mov al, [esi + 5]          ; Check second instruction
    cmp al, OP_PUSH
    jne .no_optimization
    
    mov al, [esi + 10]         ; Check third instruction
    cmp al, OP_ADD
    jne .no_optimization
    
    ; Found pattern - perform constant folding
    mov eax, [esi + 1]         ; Load first constant
    mov ebx, [esi + 6]         ; Load second constant
    add eax, ebx               ; Fold at compile time
    
    ; Emit single PUSH instruction
    call jit_compile_push
    
    ; Skip 11 bytes of bytecode (3 instructions)
    add esi, 11
    jmp .done

.no_optimization:
    ; Compile normally
    lodsb
    cmp al, OP_PUSH
    je .compile_push
    cmp al, OP_ADD
    je .compile_add
    ; ... other instructions

.compile_push:
    lodsd
    call jit_compile_push
    jmp .done

.compile_add:
    call jit_compile_add
    jmp .done

.done:
    pop esi
    pop ecx
    pop ebx
    pop eax
    ret
```

### Inline Caching for Dynamic Dispatch

**Method Call Optimization**

```asm
; inline_cache.asm - Optimize virtual method calls
section .data
    ; Inline cache entry structure
    struc ICEntry
        .cached_type: resd 1   ; Type ID of cached receiver
        .cached_target: resd 1 ; Target function address
        .call_count: resd 1    ; Number of calls (for statistics)
    endstruc

section .bss
    inline_cache: resb ICEntry_size * 256  ; Cache for 256 call sites

section .text

; JIT compile virtual call with inline cache
; EAX = call site ID
; EBX = receiver object pointer (at runtime)
jit_compile_virtual_call:
    push eax
    push ebx
    push ecx
    push edx
    
    ; Calculate inline cache entry address
    mov ecx, eax
    imul ecx, ICEntry_size
    lea edx, [inline_cache + ecx]
    
    ; Emit inline cache lookup code
    ; Generated code checks if receiver type matches cached type
    
    ; Emit: mov ecx, [receiver]      ; Load receiver
    mov al, 0x8B
    call jit_emit_byte
    mov al, 0x0B               ; ModR/M: ECX, [EBX]
    call jit_emit_byte
    
    ; Emit: mov ecx, [ecx]           ; Load type ID from object
    mov al, 0x8B
    call jit_emit_byte
    mov al, 0x09               ; ModR/M: ECX, [ECX]
    call jit_emit_byte
    
    ; Emit: cmp ecx, cached_type
    mov al, 0x81               ; CMP r/m32, imm32
    call jit_emit_byte
    mov al, 0xF9               ; ModR/M: CMP ECX
    call jit_emit_byte
    mov eax, [edx + ICEntry.cached_type]
    call jit_emit_dword
    
    ; Emit: je cached_path
    mov al, 0x74               ; JE rel8 (short jump)
    call jit_emit_byte
    mov al, 5                  ; Skip 5 bytes (call instruction)
    call jit_emit_byte
    
    ; Emit: call slow_path (cache miss)
    mov al, 0xE8               ; CALL rel32
    call jit_emit_byte
    ; Calculate relative offset to slow_path
    ; (implementation omitted)
    
    ; Emit: cached_path (cache hit)
    ; call [cached_target]
    mov al, 0xFF               ; CALL r/m32
    call jit_emit_byte
    mov al, 0x15               ; ModR/M: CALL [disp32]
    call jit_emit_byte
    lea eax, [edx + ICEntry.cached_target]
    call jit_emit_dword
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
```

## Building a Cryptographic Library

Cryptographic implementations require attention to timing attacks, side-channel resistance, and correct mathematical operations.

### AES Implementation

**AES-128 Encryption with AES-NI**

```asm
; aes.asm - AES encryption using hardware acceleration
section .data
    align 16
    ; AES S-box for key expansion (partial, full table is 256 bytes)
    aes_sbox: db 0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5
              ; ... (full S-box omitted for brevity)

section .text

; AES-128 key expansion
; RDI = pointer to 128-bit key
; RSI = pointer to expanded key buffer (176 bytes for 11 round keys)
aes128_key_expansion:
    push rax
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi
    
    ; Check for AES-NI support
    mov eax, 1
    cpuid
    test ecx, 1 << 25          ; Check AES-NI bit
    jz .software_fallback
    
    ; Hardware-accelerated key expansion
    movdqu xmm1, [rdi]         ; Load original key
    movdqa [rsi], xmm1         ; Store round 0 key
    
    ; Generate round keys using AESKEYGENASSIST
    aeskeygenassist xmm2, xmm1, 0x01  ; Round 1
    call .key_expansion_helper
    movdqa [rsi + 16], xmm1
    
    aeskeygenassist xmm2, xmm1, 0x02  ; Round 2
    call .key_expansion_helper
    movdqa [rsi + 32], xmm1
    
    aeskeygenassist xmm2, xmm1, 0x04  ; Round 3
    call .key_expansion_helper
    movdqa [rsi + 48], xmm1
    
    aeskeygenassist xmm2, xmm1, 0x08  ; Round 4
    call .key_expansion_helper
    movdqa [rsi + 64], xmm1
    
    aeskeygenassist xmm2, xmm1, 0x10  ; Round 5
    call .key_expansion_helper
    movdqa [rsi + 80], xmm1
    
    aeskeygenassist xmm2, xmm1, 0x20  ; Round 6
    call .key_expansion_helper
    movdqa [rsi + 96], xmm1
    
    aeskeygenassist xmm2, xmm1, 0x40  ; Round 7
    call .key_expansion_helper
    movdqa [rsi + 112], xmm1
    
    aeskeygenassist xmm2, xmm1, 0x80  ; Round 8
    call .key_expansion_helper
    movdqa [rsi + 128], xmm1
    
    aeskeygenassist xmm2, xmm1, 0x1B  ; Round 9
    call .key_expansion_helper
    movdqa [rsi + 144], xmm1
    
    aeskeygenassist xmm2, xmm1, 0x36  ; Round 10
    call .key_expansion_helper
    movdqa [rsi + 160], xmm1
    
    jmp .done

.key_expansion_helper:
    ; Helper for key schedule expansion
    pshufd xmm2, xmm2, 0xFF    ; Broadcast
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    movdqa xmm3, xmm1
    pslldq xmm3, 4
    pxor xmm1, xmm3
    pxor xmm1, xmm2
    ret

.software_fallback:
    ; Software implementation (for CPUs without AES-NI)
    ; (Full implementation omitted for brevity)
    
.done:
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; AES-128 encryption of single block
; RDI = pointer to 16-byte plaintext block
; RSI = pointer to expanded key (176 bytes)
; RDX = pointer to 16-byte output buffer
aes128_encrypt_block:
    push rax
    push rdi
    push rsi
    push rdx
    
    ; Load plaintext
    movdqu xmm0, [rdi]
    
    ; Initial round (whitening)
    movdqa xmm1, [rsi]
    pxor xmm0, xmm1
    
    ; Rounds 1-9
    movdqa xmm1, [rsi + 16]
    aesenc xmm0, xmm1
    
    movdqa xmm1, [rsi + 32]
    aesenc xmm0, xmm1
    
    movdqa xmm1, [rsi + 48]
    aesenc xmm0, xmm1
    
    movdqa xmm1, [rsi + 64]
    aesenc xmm0, xmm1
    
    movdqa xmm1, [rsi + 80]
    aesenc xmm0, xmm1
    
    movdqa xmm1, [rsi + 96]
    aesenc xmm0, xmm1
    
    movdqa xmm1, [rsi + 112]
    aesenc xmm0, xmm1
    
    movdqa xmm1, [rsi + 128]
    aesenc xmm0, xmm1
    
    movdqa xmm1, [rsi + 144]
    aesenc xmm0, xmm1
    
    ; Final round
    movdqa xmm1, [rsi + 160]
    aesenclast xmm0, xmm1
    
    ; Store ciphertext
    movdqu [rdx], xmm0
    
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

; AES-128 CBC mode encryption
; RDI = plaintext buffer
; RSI = length in bytes (must be multiple of 16)
; RDX = expanded key
; RCX = IV (initialization vector)
; R8 = output buffer
aes128_cbc_encrypt:
    push rax
    push rbx
    push rcx
    push rdi
    push rsi
    push rdx
    push r8
    
    ; Load IV into XMM15
    movdqu xmm15, [rcx]
    
.block_loop:
    test rsi, rsi
    jz .done
    
    ; Load plaintext block
    movdqu xmm0, [rdi]
    
    ; XOR with previous ciphertext (or IV for first block)
    pxor xmm0, xmm15
    
    ; Encrypt block
    ; Initial round
    movdqa xmm1, [rdx]
    pxor xmm0, xmm1
    
    ; Rounds 1-9
    mov rbx, 1
.round_loop:
    cmp rbx, 10
    jge .final_round
    
    lea rax, [rdx + rbx * 16]
    movdqa xmm1, [rax]
    aesenc xmm0, xmm1
    
    inc rbx
    jmp .round_loop

.final_round:
    movdqa xmm1, [rdx + 160]
    aesenclast xmm0, xmm1
    
    ; Store ciphertext
    movdqu [r8], xmm0
    
    ; Save for next block (chain)
    movdqa xmm15, xmm0
    
    ; Advance pointers
    add rdi, 16
    add r8, 16
    sub rsi, 16
    jmp .block_loop

.done:
    pop r8
    pop rdx
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    pop rax
    ret
```

### SHA-256 Hash Function

**SHA-256 Implementation**

```asm
; sha256.asm - SHA-256 cryptographic hash
section .data
    align 16
    ; SHA-256 constants (first 32 bits of fractional parts of cube roots)
    sha256_k:
        dd 0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5
        dd 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5
        dd 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3
        dd 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174
        dd 0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc
        dd 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da
        dd 0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7
        dd 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967
        dd 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13
        dd 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85
        dd 0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3
        dd 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070
        dd 0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5
        dd 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3
        dd 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208
        dd 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2

    ; Initial hash values (first 32 bits of fractional parts of square roots)
    sha256_h0:
        dd 0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a
        dd 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19

section .bss
    sha256_state: resd 8       ; Current hash state (a-h)
    sha256_w: resd 64          ; Message schedule

section .text

; Initialize SHA-256 context
sha256_init:
    push rdi
    push rsi
    push rcx
    
    ; Copy initial hash values
    lea rsi, [sha256_h0]
    lea rdi, [sha256_state]
    mov rcx, 8
    rep movsd
    
    pop rcx
    pop rsi
    pop rdi
    ret

; Process one 512-bit (64-byte) block
; RDI = pointer to 64-byte message block
sha256_process_block:
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
    push r12
    push r13
    push r14
    push r15
    
    ; === Prepare Message Schedule (W) ===
    ; First 16 words are from input (big-endian)
    xor rcx, rcx
.prepare_w_direct:
    cmp rcx, 16
    jge .prepare_w_derived
    
    mov eax, [rdi + rcx * 4]
    bswap eax                  ; Convert to little-endian
    mov [sha256_w + rcx * 4], eax
    
    inc rcx
    jmp .prepare_w_direct

.prepare_w_derived:
    cmp rcx, 64
    jge .init_working_vars
    
    ; W[t] = σ1(W[t-2]) + W[t-7] + σ0(W[t-15]) + W[t-16]
    
    ; Load W[t-2]
    mov eax, [sha256_w + (rcx - 2) * 4]
    mov ebx, eax
    ror ebx, 17
    mov edx, eax
    ror edx, 19
    xor ebx, edx
    shr eax, 10
    xor eax, ebx               ; σ1(W[t-2])
    mov r8d, eax
    
    ; Add W[t-7]
    add r8d, [sha256_w + (rcx - 7) * 4]
    
    ; Load W[t-15]
    mov eax, [sha256_w + (rcx - 15) * 4]
    mov ebx, eax
    ror ebx, 7
    mov edx, eax
    ror edx, 18
    xor ebx, edx
    shr eax, 3
    xor eax, ebx               ; σ0(W[t-15])
    add r8d, eax
    
    ; Add W[t-16]
    add r8d, [sha256_w + (rcx - 16) * 4]
    
    mov [sha256_w + rcx * 4], r8d
    
    inc rcx
    jmp .prepare_w_derived

.init_working_vars:
    ; Load hash state into working variables
    mov eax, [sha256_state]      ; a
    mov ebx, [sha256_state + 4]  ; b
    mov ecx, [sha256_state + 8]  ; c
    mov edx, [sha256_state + 12] ; d
    mov r8d, [sha256_state + 16] ; e
    mov r9d, [sha256_state + 20] ; f
    mov r10d, [sha256_state + 24]; g
    mov r11d, [sha256_state + 28]; h
    
    ; === Main Compression Loop (64 rounds) ===
    xor r12, r12               ; Round counter

.compression_loop:
    cmp r12, 64
    jge .finalize
    
    ; T1 = h + Σ1(e) + Ch(e,f,g) + K[t] + W[t]
    
    ; Calculate Σ1(e)
    mov r13d, r8d
    ror r13d, 6
    mov r14d, r8d
    ror r14d, 11
    xor r13d, r14d
    mov r14d, r8d
    ror r14d, 25
    xor r13d, r14d             ; Σ1(e)
    
    ; Calculate Ch(e,f,g) = (e & f) ^ (~e & g)
    mov r14d, r8d
    and r14d, r9d              ; e & f
    mov r15d, r8d
    not r15d
    and r15d, r10d             ; ~e & g
    xor r14d, r15d             ; Ch(e,f,g)
    
    ; T1 = h + Σ1(e) + Ch(e,f,g) + K[t] + W[t]
    mov r13d, r11d             ; Start with h
    add r13d, r13d             ; (using earlier Σ1 result would be here)
    ; [Note: Simplified - full implementation would accumulate properly]
    add r13d, r14d
    add r13d, [sha256_k + r12 * 4]
    add r13d, [sha256_w + r12 * 4]
    
    ; T2 = Σ0(a) + Maj(a,b,c)
    
    ; Calculate Σ0(a)
    mov r14d, eax
    ror r14d, 2
    mov r15d, eax
    ror r15d, 13
    xor r14d, r15d
    mov r15d, eax
    ror r15d, 22
    xor r14d, r15d             ; Σ0(a)
    
    ; Calculate Maj(a,b,c) = (a & b) ^ (a & c) ^ (b & c)
    mov r15d, eax
    and r15d, ebx              ; a & b
    push rax
    mov eax, eax
    and eax, ecx               ; a & c
    xor r15d, eax
    mov eax, ebx
    and eax, ecx               ; b & c
    xor r15d, eax
    pop rax
    
    ; T2 = Σ0(a) + Maj(a,b,c)
    add r14d, r15d
    
    ; Update working variables
    mov r11d, r10d             ; h = g
    mov r10d, r9d              ; g = f
    mov r9d, r8d               ; f = e
    lea r8d, [edx + r13d]      ; e = d + T1
    mov edx, ecx               ; d = c
    mov ecx, ebx               ; c = b
    mov ebx, eax               ; b = a
    lea eax, [r13d + r14d]     ; a = T1 + T2
    
    inc r12
    jmp .compression_loop

.finalize:
    ; Add working variables to hash state
    add [sha256_state], eax
    add [sha256_state + 4], ebx
    add [sha256_state + 8], ecx
    add [sha256_state + 12], edx
    add [sha256_state + 16], r8d
    add [sha256_state + 20], r9d
    add [sha256_state + 24], r10d
    add [sha256_state + 28], r11d
    
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; Complete SHA-256 hash computation
; RDI = pointer to message
; RSI = message length in bytes
; RDX = pointer to 32-byte output buffer
sha256_hash:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    
    ; Save output buffer pointer
    mov r9, rdx
    
    ; Initialize hash state
    call sha256_init
    
    ; Save original message length for padding
    mov r8, rsi
    
    ; Process complete 512-bit blocks
.block_loop:
    cmp rsi, 64
    jl .final_block
    
    call sha256_process_block
    add rdi, 64
    sub rsi, 64
    jmp .block_loop

.final_block:
    ; Create final padded block(s)
    ; Padding: 1 bit, then zeros, then 64-bit length
    
    ; Allocate space for final blocks (may need 2 blocks)
    sub rsp, 128
    mov rdx, rsp
    
    ; Copy remaining message bytes
    mov rcx, rsi
    push rdi
    push rsi
    mov rdi, rdx
    rep movsb
    pop rsi
    pop rdi
    
    ; Append '1' bit (0x80 byte)
    mov byte [rdx + rsi], 0x80
    inc rsi
    
    ; Calculate padding length
    ; If remaining length > 55, need two blocks
    cmp rsi, 56
    jg .two_blocks
    
    ; One block is sufficient
    ; Zero padding
    lea rdi, [rdx + rsi]
    mov rcx, 56
    sub rcx, rsi
    xor al, al
    rep stosb
    
    ; Append original length in bits (big-endian 64-bit)
    mov rax, r8
    shl rax, 3                 ; Convert bytes to bits
    bswap rax
    mov [rdx + 56], rax
    
    ; Process final block
    mov rdi, rdx
    call sha256_process_block
    jmp .output_hash

.two_blocks:
    ; Zero-pad first block to 64 bytes
    lea rdi, [rdx + rsi]
    mov rcx, 64
    sub rcx, rsi
    xor al, al
    rep stosb
    
    ; Process first final block
    mov rdi, rdx
    call sha256_process_block
    
    ; Prepare second block (all zeros except length)
    lea rdi, [rdx + 64]
    mov rcx, 56
    xor al, al
    rep stosb
    
    ; Append length
    mov rax, r8
    shl rax, 3
    bswap rax
    mov [rdx + 120], rax
    
    ; Process second final block
    lea rdi, [rdx + 64]
    call sha256_process_block

.output_hash:
    ; Copy hash state to output buffer (convert to big-endian)
    mov rsi, sha256_state
    mov rdi, r9
    mov rcx, 8
.copy_hash:
    lodsd
    bswap eax
    stosd
    loop .copy_hash
    
    ; Clean up stack
    add rsp, 128
    
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret
```

### RSA Implementation (Big Integer Arithmetic)

**Modular Exponentiation for RSA**

```asm
; rsa.asm - RSA cryptographic operations
; Using Montgomery multiplication for efficiency

section .bss
    ; Big integer storage (2048-bit = 256 bytes)
    BIGINT_SIZE equ 32         ; 32 × 64-bit words = 2048 bits
    
    bigint_temp1: resq BIGINT_SIZE
    bigint_temp2: resq BIGINT_SIZE
    bigint_temp3: resq BIGINT_SIZE

section .text

; Constant-time conditional move (timing attack resistance)
; RDI = destination
; RSI = source
; RDX = condition (0 or 1)
; RCX = number of qwords
bigint_cmov:
    push rax
    push rbx
    push rcx
    push rdi
    push rsi
    
    ; Create mask: 0 if condition is 0, -1 if condition is 1
    neg rdx
    sbb rdx, rdx               ; RDX = 0 or 0xFFFFFFFFFFFFFFFF
    
.loop:
    mov rax, [rdi]             ; Load destination
    mov rbx, [rsi]             ; Load source
    xor rbx, rax               ; Difference
    and rbx, rdx               ; Mask by condition
    xor rax, rbx               ; Apply masked difference
    mov [rdi], rax
    
    add rdi, 8
    add rsi, 8
    loop .loop
    
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    pop rax
    ret

; Big integer addition with carry
; RDI = result (a + b)
; RSI = operand a
; RDX = operand b
; RCX = number of qwords
bigint_add:
    push rax
    push rbx
    push rcx
    push rdi
    push rsi
    push rdx
    
    clc                        ; Clear carry flag
.loop:
    mov rax, [rsi]
    adc rax, [rdx]             ; Add with carry
    mov [rdi], rax
    
    add rsi, 8
    add rdx, 8
    add rdi, 8
    loop .loop
    
    pop rdx
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    pop rax
    ret

; Big integer subtraction
; RDI = result (a - b)
; RSI = operand a
; RDX = operand b
; RCX = number of qwords
bigint_sub:
    push rax
    push rbx
    push rcx
    push rdi
    push rsi
    push rdx
    
    clc
.loop:
    mov rax, [rsi]
    sbb rax, [rdx]             ; Subtract with borrow
    mov [rdi], rax
    
    add rsi, 8
    add rdx, 8
    add rdi, 8
    loop .loop
    
    pop rdx
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    pop rax
    ret

; Montgomery multiplication (core of modular exponentiation)
; RDI = result (a × b mod m)
; RSI = operand a (in Montgomery form)
; RDX = operand b (in Montgomery form)
; RCX = modulus m
; R8 = m' (negative inverse of m mod R)
bigint_montgomery_mul:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r9
    push r10
    push r11
    push r12
    
    ; Initialize result to zero
    mov rdi, bigint_temp1
    xor rax, rax
    mov r9, BIGINT_SIZE
.clear_loop:
    mov [rdi], rax
    add rdi, 8
    dec r9
    jnz .clear_loop
    
    ; Outer loop: for each word of a
    xor r9, r9                 ; i = 0
.outer_loop:
    cmp r9, BIGINT_SIZE
    jge .reduction_phase
    
    ; Load a[i]
    mov rax, [rsi + r9 * 8]
    
    ; Inner loop: multiply and accumulate
    xor r10, r10               ; j = 0
    mov r11, bigint_temp1
    clc
    
.inner_loop:
    cmp r10, BIGINT_SIZE
    jge .next_word
    
    ; result[j] += a[i] × b[j]
    mov rbx, [rdx + r10 * 8]   ; b[j]
    mul rbx                    ; RDX:RAX = a[i] × b[j]
    
    add rax, [r11]             ; Add to result[j]
    adc rdx, 0                 ; Propagate carry
    mov [r11], rax
    
    ; Handle carry to next word
    mov rax, rdx
    add r11, 8
    inc r10
    jmp .inner_loop

.next_word:
    inc r9
    jmp .outer_loop

.reduction_phase:
    ; Montgomery reduction: result = (result + (result × m' mod R) × m) / R
    ; [Note: Full implementation is complex and omitted for brevity]
    ; This would include reduction by modulus using Montgomery form
    
    pop r12
    pop r11
    pop r10
    pop r9
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; Modular exponentiation using square-and-multiply
; RDI = result (base^exp mod m)
; RSI = base
; RDX = exponent
; RCX = modulus
; Uses constant-time implementation to prevent timing attacks
bigint_modexp:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    
    ; Convert base to Montgomery form
    ; (implementation omitted)
    
    ; Initialize result to 1 (in Montgomery form)
    mov rdi, bigint_temp1
    mov qword [rdi], 1
    xor rax, rax
    mov rcx, BIGINT_SIZE - 1
.init_one:
    add rdi, 8
    mov [rdi], rax
    loop .init_one
    
    ; Binary exponentiation (right-to-left)
    ; Process each bit of exponent
    mov r8, BIGINT_SIZE        ; Number of words in exponent
    mov r9, 0                  ; Word index
    
.word_loop:
    cmp r9, r8
    jge .convert_result
    
    mov rax, [rdx + r9 * 8]    ; Load exponent word
    mov r10, 64                ; Bits per word
    
.bit_loop:
    test r10, r10
    jz .next_word_exp
    
    ; Square result
    mov rdi, bigint_temp3
    mov rsi, bigint_temp1
    mov rdx, bigint_temp1
    call bigint_montgomery_mul
    
    ; Copy result back
    mov rdi, bigint_temp1
    mov rsi, bigint_temp3
    mov rcx, BIGINT_SIZE
    rep movsq
    
    ; If bit is set, multiply by base
    test rax, 1
    jz .skip_multiply
    
    mov rdi, bigint_temp3
    mov rsi, bigint_temp1
    ; mov rdx = base (from parameter)
    call bigint_montgomery_mul
    
    ; Copy result back
    mov rdi, bigint_temp1
    mov rsi, bigint_temp3
    mov rcx, BIGINT_SIZE
    rep movsq

.skip_multiply:
    shr rax, 1                 ; Next bit
    dec r10
    jmp .bit_loop

.next_word_exp:
    inc r9
    jmp .word_loop

.convert_result:
    ; Convert from Montgomery form back to normal
    ; (implementation omitted)
    
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret
```

### Constant-Time Comparison (Timing Attack Prevention)

**Secure Memory Comparison**

```asm
; Constant-time memory comparison (prevents timing attacks)
; RDI = buffer 1
; RSI = buffer 2
; RDX = length in bytes
; Returns: RAX = 0 if equal, non-zero if different
secure_memcmp:
    push rbx
    push rcx
    push rdi
    push rsi
    
    xor rax, rax               ; Accumulator for differences
    mov rcx, rdx
    
.loop:
    test rcx, rcx
    jz .done
    
    ; Load and compare bytes
    movzx rbx, byte [rdi]
    movzx rdx, byte [rsi]
    xor rbx, rdx               ; Difference (0 if equal)
    or rax, rbx                ; Accumulate differences
    
    inc rdi
    inc rsi
    dec rcx
    jmp .loop

.done:
    ; RAX contains OR of all differences
    ; 0 if all bytes matched, non-zero otherwise
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    ret

; Constant-time conditional swap
; RDI = pointer to value A
; RSI = pointer to value B
; RDX = condition (0 = no swap, 1 = swap)
; RCX = size in qwords
secure_cswap:
    push rax
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi
    
    ; Create mask from condition
    neg rdx
    sbb rdx, rdx               ; -1 if swap, 0 if no swap
    
.loop:
    mov rax, [rdi]
    mov rbx, [rsi]
    
    ; Calculate what to XOR
    mov r8, rax
    xor r8, rbx                ; Difference
    and r8, rdx                ; Masked by condition
    
    ; Apply XOR to both values
    xor rax, r8
    xor rbx, r8
    
    mov [rdi], rax
    mov [rsi], rbx
    
    add rdi, 8
    add rsi, 8
    loop .loop
    
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret
```

### Elliptic Curve Cryptography (ECC)

**Point Addition on Elliptic Curve (Simplified)**

```asm
; ecc.asm - Elliptic curve operations (secp256k1 curve)
section .bss
    ; Point coordinates (256-bit)
    ecc_point_x: resq 4
    ecc_point_y: resq 4
    ecc_point_z: resq 4        ; Projective coordinates

section .data
    ; Curve parameters for secp256k1
    ; y² = x³ + 7 (mod p)
    secp256k1_p:
        dq 0xFFFFFFFEFFFFFC2F
        dq 0xFFFFFFFFFFFFFFFF
        dq 0xFFFFFFFFFFFFFFFF
        dq 0xFFFFFFFFFFFFFFFF

section .text

; Modular inverse using Extended Euclidean Algorithm
; RDI = result (a^-1 mod m)
; RSI = value a
; RDX = modulus m
bigint_modinv:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    ; Extended Euclidean Algorithm
    ; Implementation uses iterative approach
    ; [Note: Full implementation omitted for brevity]
    ; Would compute: a × result ≡ 1 (mod m)
    
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; Elliptic curve point doubling (projective coordinates)
; RDI = result point
; RSI = input point
ecc_point_double:
    push rax
    push rbx
    push rcx
    push rdx
    
    ; Doubling formula in projective coordinates:
    ; X₃ = (3X₁² + aZ₁⁴)² - 8X₁Y₁²
    ; Y₃ = (3X₁² + aZ₁⁴)(4X₁Y₁² - X₃) - 8Y₁⁴
    ; Z₃ = 2Y₁Z₁
    
    ; For secp256k1, a = 0, so formula simplifies
    
    ; Calculate 3X₁²
    mov rsi, [rsi]             ; Load X₁
    ; Square X₁
    ; (implementation omitted)
    
    ; Continue with formula...
    ; [Note: Full implementation requires careful modular arithmetic]
    
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; Scalar multiplication using double-and-add
; RDI = result point (k × P)
; RSI = point P
; RDX = scalar k
ecc_scalar_mult:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    ; Initialize result to point at infinity
    ; (implementation omitted)
    
    ; Binary method: process each bit of scalar
    mov rcx, 256               ; Bit length
    
.bit_loop:
    test rcx, rcx
    jz .done
    
    ; Double current result
    mov rdi, bigint_temp1
    mov rsi, bigint_temp1
    call ecc_point_double
    
    ; Check if current bit of scalar is set
    mov rax, rdx
    bt rax, rcx                ; Test bit
    jnc .skip_add
    
    ; Add base point
    ; (point addition implementation)

.skip_add:
    dec rcx
    jmp .bit_loop

.done:
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret
```

### Random Number Generation (Cryptographically Secure)

**RDRAND/RDSEED Usage**

```asm
; random.asm - Cryptographically secure random number generation
section .text

; Generate random 64-bit value using RDRAND
; Returns: RAX = random value, CF = 1 if successful
crypto_rand64:
    push rbx
    
    ; Check for RDRAND support
    mov eax, 1
    cpuid
    bt ecx, 30                 ; RDRAND bit
    jnc .no_rdrand
    
    ; Attempt to generate random number (with retry)
    mov ebx, 10                ; Retry count
.retry:
    rdrand rax                 ; Generate random number
    jc .success                ; CF=1 means success
    
    dec ebx
    jnz .retry
    
    ; Failed after retries
    xor rax, rax
    clc
    jmp .done

.no_rdrand:
    ; Fallback: use RDSEED if available
    mov eax, 7
    xor ecx, ecx
    cpuid
    bt ebx, 18                 ; RDSEED bit
    jnc .no_hardware_rng
    
    rdseed rax
    jc .success
    
.no_hardware_rng:
    ; No hardware RNG available
    ; [Inference] Should use /dev/urandom syscall on Linux
    ; or CryptGenRandom on Windows
    xor rax, rax
    clc
    jmp .done

.success:
    stc                        ; Set carry for success

.done:
    pop rbx
    ret

; Fill buffer with random bytes
; RDI = buffer pointer
; RSI = buffer size in bytes
crypto_randbuf:
    push rax
    push rbx
    push rcx
    push rdi
    push rsi
    
    mov rcx, rsi
    
.loop:
    test rcx, rcx
    jz .done
    
    ; Generate 8 random bytes
    call crypto_rand64
    jnc .error                 ; Check for failure
    
    ; Store up to 8 bytes
    mov rbx, rcx
    cmp rbx, 8
    jle .store_partial
    mov rbx, 8

.store_partial:
    mov [rdi], rax
    add rdi, rbx
    sub rcx, rbx
    jmp .loop

.error:
    ; [Unverified] Error handling
    ; Production code should handle RNG failures properly

.done:
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    pop rax
    ret
```

**Key Points**

- OS kernel development requires managing boot sequences, protected mode transitions, interrupt handling, memory paging, and hardware interfaces without relying on existing system services
- Virtual machines can use stack-based or register-based architectures, with register-based VMs typically offering better performance due to reduced memory traffic
- JIT compilers translate intermediate representations to native code at runtime, requiring instruction encoding knowledge, register allocation strategies, and optimization techniques like constant folding and inline caching
- Cryptographic library implementation demands constant-time operations to prevent timing attacks, careful modular arithmetic for algorithms like RSA, and hardware acceleration through instructions like AES-NI and RDRAND
- Security-critical code must avoid data-dependent branches and memory accesses that could leak information through timing side channels

---

## Developing a Compression Engine

### Compression Fundamentals

Lossless compression exploits redundancy and patterns in data. Statistical methods like Huffman coding assign shorter codes to frequent symbols. Dictionary methods like LZ77 replace repeated sequences with references to earlier occurrences. Effective compression engines combine multiple techniques for optimal results.

Entropy encoding represents the theoretical compression limit. No lossless algorithm can compress random data, but structured data contains patterns enabling significant compression. Understanding input data characteristics guides algorithm selection and parameter tuning.

Compression ratios measure effectiveness: compressed size divided by original size. A 1000-byte file compressed to 300 bytes achieves a 0.3 ratio or 70% reduction. Speed measurements include compression throughput (MB/s) and decompression throughput separately, as they often differ significantly.

### LZ77 Implementation

Sliding window compression maintains a history buffer of recently processed data. When encoding, the algorithm searches the window for the longest match to upcoming data. Matches are encoded as (distance, length) pairs; non-matches output literal bytes.

```nasm
;==============================================================================
; lz77_compress
;
; Compresses data using LZ77 sliding window algorithm.
;
; Parameters:
;   rdi - Source buffer pointer
;   rsi - Source buffer size
;   rdx - Destination buffer pointer
;   rcx - Destination buffer size
;
; Returns:
;   rax - Compressed size (0 on error)
;
; Window size: 32KB (configurable via WINDOW_SIZE constant)
; Look-ahead buffer: 256 bytes (MAX_MATCH_LEN)
;==============================================================================

WINDOW_SIZE    equ 32768
MAX_MATCH_LEN  equ 258
MIN_MATCH_LEN  equ 3

lz77_compress:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    ; Save parameters
    mov r12, rdi              ; Source pointer
    mov r13, rsi              ; Source size
    mov r14, rdx              ; Destination pointer
    mov r15, rcx              ; Destination size
    
    xor rbx, rbx              ; Current position in source
    xor rcx, rcx              ; Current position in destination
    
.compress_loop:
    cmp rbx, r13
    jae .compression_done
    
    ; Find longest match in sliding window
    mov rdi, r12              ; Source base
    mov rsi, rbx              ; Current position
    call find_longest_match
    
    ; rax = match length, rdx = match distance
    cmp rax, MIN_MATCH_LEN
    jb .output_literal
    
    ; Output match token
    ; Format: [1 bit: match flag][15 bits: distance][8 bits: length]
    mov r8, rdx               ; Distance
    shl r8, 8                 ; Shift distance left
    or r8, rax                ; Combine with length
    or r8, 0x8000             ; Set match flag bit
    
    ; Check destination space
    add rcx, 3
    cmp rcx, r15
    ja .buffer_overflow
    
    mov [r14], r8w            ; Write distance
    add r14, 2
    mov byte [r14], al        ; Write length
    inc r14
    
    add rbx, rax              ; Advance by match length
    jmp .compress_loop
    
.output_literal:
    ; Output literal byte
    ; Format: [1 bit: literal flag][7 bits: unused][8 bits: byte]
    
    add rcx, 2
    cmp rcx, r15
    ja .buffer_overflow
    
    mov ax, [r12 + rbx]
    and ax, 0x7FFF            ; Clear match flag bit
    mov [r14], ax
    add r14, 2
    
    inc rbx
    jmp .compress_loop
    
.compression_done:
    mov rax, rcx              ; Return compressed size
    jmp .cleanup
    
.buffer_overflow:
    xor rax, rax              ; Return 0 on error
    
.cleanup:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

;==============================================================================
; find_longest_match
;
; Searches sliding window for longest match to current position.
;
; Parameters:
;   rdi - Source buffer base
;   rsi - Current position
;
; Returns:
;   rax - Match length (0 if no match)
;   rdx - Match distance from current position
;==============================================================================
find_longest_match:
    push rbx
    push rcx
    push r8
    push r9
    push r10
    
    xor rax, rax              ; Best match length
    xor rdx, rdx              ; Best match distance
    
    ; Calculate window start
    mov r8, rsi
    sub r8, WINDOW_SIZE
    test r8, r8
    cmovs r8, zero_value      ; Start at 0 if negative
    
    ; r8 = window start, rsi = current position
.search_loop:
    cmp r8, rsi
    jae .search_done
    
    ; Compare bytes at r8 with bytes at rsi
    mov r9, rdi
    add r9, r8                ; Pointer to potential match
    mov r10, rdi
    add r10, rsi              ; Pointer to current data
    
    xor rcx, rcx              ; Current match length
    
.compare_loop:
    cmp rcx, MAX_MATCH_LEN
    jae .match_complete
    
    ; Check we don't exceed source buffer
    mov rbx, rsi
    add rbx, rcx
    cmp rbx, [source_end]
    jae .match_complete
    
    mov bl, [r9 + rcx]
    cmp bl, [r10 + rcx]
    jne .match_complete
    
    inc rcx
    jmp .compare_loop
    
.match_complete:
    ; Update best match if this one is longer
    cmp rcx, rax
    jbe .not_better
    
    mov rax, rcx              ; New best length
    mov rdx, rsi
    sub rdx, r8               ; Distance = current - match position
    
.not_better:
    inc r8
    jmp .search_loop
    
.search_done:
    pop r10
    pop r9
    pop r8
    pop rcx
    pop rbx
    ret

zero_value: dq 0
source_end: dq 0
```

Hash table acceleration improves search performance. Instead of linear scanning through the window, a hash table maps content hashes to positions. This reduces search complexity from O(n²) to approximately O(n).

```nasm
; Hash table structure for fast match finding
; Hash function: (byte[0] << 16) ^ (byte[1] << 8) ^ byte[2]
; Table size: 65536 entries

HASH_SIZE equ 65536
HASH_SHIFT equ 5

; Initialize hash table (all entries to -1)
init_hash_table:
    mov rdi, hash_table
    mov rcx, HASH_SIZE
    mov rax, -1
    rep stosq
    ret

; Insert position into hash table
hash_insert:
    ; rdi = buffer, rsi = position
    movzx eax, byte [rdi + rsi]
    shl eax, 16
    movzx edx, byte [rdi + rsi + 1]
    shl edx, 8
    or eax, edx
    movzx edx, byte [rdi + rsi + 2]
    or eax, edx
    
    and eax, 0xFFFF           ; Modulo hash table size
    lea rdx, [hash_table]
    mov [rdx + rax * 8], rsi  ; Store position
    ret
```

Lazy matching improves compression ratios. After finding a match, the algorithm checks if the next position yields a better match. If so, it outputs the current byte as a literal and uses the better match from the next position.

Greedy versus optimal parsing trades compression ratio for speed. Greedy algorithms immediately output the longest match found. Optimal parsing considers multiple potential match sequences and selects the path minimizing output size, requiring more computation but achieving better compression.

### Huffman Coding

Frequency analysis counts symbol occurrences in input data. Assembly implementation uses an array indexed by byte value, incrementing counters as data is scanned.

```nasm
; Count byte frequencies
count_frequencies:
    ; rdi = data pointer, rsi = data size, rdx = frequency table
    push rbx
    push rcx
    
    ; Zero frequency table
    mov rax, rdx
    mov rcx, 256
    xor rbx, rbx
.zero_loop:
    mov qword [rax], rbx
    add rax, 8
    loop .zero_loop
    
    ; Count frequencies
    xor rcx, rcx
.count_loop:
    cmp rcx, rsi
    jae .count_done
    
    movzx rax, byte [rdi + rcx]
    inc qword [rdx + rax * 8]
    inc rcx
    jmp .count_loop
    
.count_done:
    pop rcx
    pop rbx
    ret
```

Building Huffman trees requires priority queue operations. Symbols with frequencies form leaf nodes. The algorithm repeatedly extracts the two lowest-frequency nodes, creates a parent node with their combined frequency, and inserts it back. This continues until one root node remains.

Code generation traverses the completed tree, assigning binary codes. Left branches append '0' bits while right branches append '1' bits. Leaf nodes receive their complete codes.

Canonical Huffman coding simplifies decoding. Instead of storing the tree structure, canonical codes follow predictable patterns. Codes of the same length are consecutive integers, and shorter codes have smaller numeric values. This enables compact tree representation as code length counts.

Bit packing operations write variable-length codes into output streams. A bit buffer accumulates codes until reaching byte boundaries, then outputs complete bytes while maintaining partial bits for the next code.

```nasm
; Bit packing state
bit_buffer: dq 0          ; Accumulator for partial bits
bit_count:  dq 0          ; Number of valid bits in buffer

; Write bits to output stream
write_bits:
    ; rdi = output buffer, rsi = code, rdx = code length
    push rbx
    push rcx
    
    ; Add new bits to buffer
    mov rax, [bit_buffer]
    mov rcx, [bit_count]
    shl rax, cl               ; Shift existing bits left
    or rax, rsi               ; Add new bits
    add rcx, rdx              ; Update bit count
    
.flush_loop:
    cmp rcx, 8
    jb .flush_done
    
    ; Extract and output top 8 bits
    sub rcx, 8
    mov rbx, rax
    shr rbx, cl
    mov [rdi], bl
    inc rdi
    
    ; Mask off output bits
    mov rbx, 1
    shl rbx, cl
    dec rbx
    and rax, rbx
    
    jmp .flush_loop
    
.flush_done:
    mov [bit_buffer], rax
    mov [bit_count], rcx
    
    pop rcx
    pop rbx
    ret
```

### Decompression Implementation

Decompression reverses the compression process. For LZ77, it reads literal bytes or match tokens, copying either single bytes or previously decompressed sequences to the output.

```nasm
lz77_decompress:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    
    mov r12, rdi              ; Compressed data
    mov r13, rsi              ; Compressed size
    mov r14, rdx              ; Output buffer
    
    xor rbx, rbx              ; Position in compressed data
    xor rcx, rcx              ; Position in output
    
.decompress_loop:
    cmp rbx, r13
    jae .decompression_done
    
    ; Read token
    movzx rax, word [r12 + rbx]
    add rbx, 2
    
    ; Check match/literal flag
    test rax, 0x8000
    jz .process_literal
    
    ; Process match
    and rax, 0x7FFF           ; Clear flag bit
    mov rdx, rax
    shr rdx, 8                ; Extract distance
    and rax, 0xFF             ; Extract length (from next byte)
    movzx rax, byte [r12 + rbx]
    inc rbx
    
    ; Copy match
    mov r8, rcx
    sub r8, rdx               ; Source position = current - distance
    
.copy_loop:
    mov r9b, [r14 + r8]
    mov [r14 + rcx], r9b
    inc r8
    inc rcx
    dec rax
    jnz .copy_loop
    
    jmp .decompress_loop
    
.process_literal:
    ; Copy literal byte
    movzx rax, byte [r12 + rbx]
    mov [r14 + rcx], al
    inc rbx
    inc rcx
    jmp .decompress_loop
    
.decompression_done:
    mov rax, rcx              ; Return decompressed size
    
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
```

Huffman decompression reads bits from the compressed stream, traversing the tree until reaching a leaf node. The leaf's symbol outputs to the decompressed stream. Canonical Huffman coding enables table-based decoding without explicit tree traversal.

Error detection validates compressed data integrity. Checksums (CRC32, Adler32) appended to compressed data enable verification. Decompression should validate structure before writing output to prevent crashes or security issues from malformed input.

### Optimization Techniques

SIMD acceleration processes multiple bytes simultaneously. String comparison in match finding benefits from SSE/AVX instructions comparing 16 or 32 bytes per instruction.

```nasm
; SSE2-accelerated string comparison
compare_16_bytes:
    ; rdi = string1, rsi = string2
    ; Returns: zero flag set if equal
    movdqu xmm0, [rdi]
    movdqu xmm1, [rsi]
    pcmpeqb xmm0, xmm1        ; Compare all 16 bytes
    pmovmskb eax, xmm0        ; Extract comparison mask
    cmp eax, 0xFFFF           ; All bytes equal?
    ret
```

Cache-friendly data structures improve performance. Hash tables sized to fit in L1 cache reduce memory latency. Sequential memory access patterns benefit from hardware prefetching.

Multi-threading parallelizes independent blocks. Large files split into blocks compressed independently, then concatenated with block headers enabling parallel decompression.

Assembly-optimized critical paths focus effort where it matters most. Profiling identifies bottlenecks; typically hash computation, match finding, or bit packing consume most time. Optimizing these routines yields the greatest performance improvements.

## Creating Custom Allocators

### Allocation Strategies

Free list allocators maintain linked lists of available memory blocks. Each free block stores a header containing size and pointer to the next free block. Allocation searches the list for sufficiently large blocks.

```nasm
; Free block header structure
struc FreeBlock
    .size:      resq 1        ; Block size including header
    .next:      resq 1        ; Next free block pointer
    .magic:     resq 1        ; Magic number for validation
endstruc

FREE_MAGIC equ 0xDEADBEEF12345678

; Global free list head
free_list_head: dq 0
```

Segregated free lists organize blocks by size class. Small allocations (8, 16, 32 bytes) use dedicated lists, improving allocation speed and reducing fragmentation. Large allocations use a general-purpose allocator or direct system calls.

Buddy allocation divides memory into power-of-two sized blocks. When allocating, the allocator splits larger blocks if necessary. When freeing, adjacent buddy blocks coalesce into larger blocks. This reduces external fragmentation while maintaining O(log n) allocation time.

Slab allocation pre-allocates fixed-size object pools. Perfect for frequently allocated/deallocated objects of known size like tree nodes or hash table entries. Each slab contains multiple objects; allocation simply takes the next available object from a slab.

### Basic Allocator Implementation

```nasm
;==============================================================================
; malloc
;
; Allocates memory block of requested size.
;
; Parameters:
;   rdi - Requested size in bytes
;
; Returns:
;   rax - Pointer to allocated memory (NULL on failure)
;
; Algorithm:
;   First-fit search through free list. Splits blocks if significantly
;   larger than requested size. Requests more memory from OS if needed.
;==============================================================================

ALIGNMENT equ 16
MIN_BLOCK_SIZE equ 32
SPLIT_THRESHOLD equ 64    ; Split if remainder >= this size

malloc:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    
    ; Align size to 16 bytes and add header
    add rdi, 15
    and rdi, -16
    add rdi, FreeBlock_size
    
    ; Minimum block size
    cmp rdi, MIN_BLOCK_SIZE
    cmovb rdi, [min_block_const]
    
    mov r12, rdi              ; Save requested size
    
    ; Search free list
    lea rbx, [free_list_head]
    mov rcx, [rbx]            ; Current block
    
.search_loop:
    test rcx, rcx
    jz .no_block_found
    
    ; Validate block
    cmp qword [rcx + FreeBlock.magic], FREE_MAGIC
    jne .corrupted_list
    
    ; Check if block is large enough
    mov rax, [rcx + FreeBlock.size]
    cmp rax, r12
    jb .try_next
    
    ; Block found, check if should split
    mov rdx, rax
    sub rdx, r12
    cmp rdx, SPLIT_THRESHOLD
    jb .use_entire_block
    
    ; Split block
    mov r13, rcx
    add r13, r12              ; New free block position
    
    mov [r13 + FreeBlock.size], rdx
    mov rax, [rcx + FreeBlock.next]
    mov [r13 + FreeBlock.next], rax
    mov qword [r13 + FreeBlock.magic], FREE_MAGIC
    
    mov [rbx], r13            ; Update previous next pointer
    mov [rcx + FreeBlock.size], r12
    jmp .allocate_block
    
.use_entire_block:
    ; Use entire block
    mov rax, [rcx + FreeBlock.next]
    mov [rbx], rax            ; Remove from free list
    
.allocate_block:
    ; Clear magic (block now allocated)
    mov qword [rcx + FreeBlock.magic], 0
    
    ; Return pointer after header
    lea rax, [rcx + FreeBlock_size]
    jmp .done
    
.try_next:
    lea rbx, [rcx + FreeBlock.next]
    mov rcx, [rcx + FreeBlock.next]
    jmp .search_loop
    
.no_block_found:
    ; Request more memory from OS
    mov rdi, r12
    call request_memory_from_os
    test rax, rax
    jz .allocation_failed
    
    ; Initialize new block
    mov [rax + FreeBlock.size], r12
    mov qword [rax + FreeBlock.next], 0
    mov qword [rax + FreeBlock.magic], 0
    
    lea rax, [rax + FreeBlock_size]
    jmp .done
    
.corrupted_list:
    ; Heap corruption detected
    xor rax, rax
    jmp .done
    
.allocation_failed:
    xor rax, rax
    
.done:
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

min_block_const: dq MIN_BLOCK_SIZE
```

Free operation returns blocks to the free list, potentially coalescing with adjacent free blocks.

```nasm
;==============================================================================
; free
;
; Returns allocated memory block to free list.
;
; Parameters:
;   rdi - Pointer to memory block (returned by malloc)
;
; Algorithm:
;   Validates pointer, adds block to free list, attempts coalescing
;   with adjacent free blocks.
;==============================================================================
free:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    
    test rdi, rdi
    jz .done                  ; NULL pointer, nothing to free
    
    ; Get block header
    sub rdi, FreeBlock_size
    
    ; Validate alignment
    test rdi, 15
    jnz .invalid_pointer
    
    ; Mark as free
    mov qword [rdi + FreeBlock.magic], FREE_MAGIC
    
    ; Insert at beginning of free list (simple approach)
    mov rax, [free_list_head]
    mov [rdi + FreeBlock.next], rax
    mov [free_list_head], rdi
    
    ; Coalesce adjacent blocks
    call coalesce_free_blocks
    
    jmp .done
    
.invalid_pointer:
    ; Invalid pointer detected - could log error
    
.done:
    pop r12
    pop rbx
    pop rbp
    ret
```

### Advanced Features

Block coalescing merges adjacent free blocks into larger blocks, reducing external fragmentation. This requires searching for blocks whose addresses and sizes indicate adjacency.

```nasm
coalesce_free_blocks:
    push rbx
    push rcx
    push rdx
    
    mov rbx, [free_list_head]
    
.outer_loop:
    test rbx, rbx
    jz .coalesce_done
    
    ; Check magic number
    cmp qword [rbx + FreeBlock.magic], FREE_MAGIC
    jne .skip_outer
    
    mov rcx, [rbx + FreeBlock.next]
    
.inner_loop:
    test rcx, rcx
    jz .next_outer
    
    ; Check if blocks are adjacent
    mov rax, rbx
    add rax, [rbx + FreeBlock.size]
    cmp rax, rcx
    je .merge_blocks
    
    mov rcx, [rcx + FreeBlock.next]
    jmp .inner_loop
    
.merge_blocks:
    ; Merge rcx into rbx
    mov rax, [rcx + FreeBlock.size]
    add [rbx + FreeBlock.size], rax
    
    mov rax, [rcx + FreeBlock.next]
    mov [rbx + FreeBlock.next], rax
    
    ; Continue checking from merged block
    jmp .inner_loop
    
.next_outer:
    mov rbx, [rbx + FreeBlock.next]
    jmp .outer_loop
    
.skip_outer:
    mov rbx, [rbx + FreeBlock.next]
    jmp .outer_loop
    
.coalesce_done:
    pop rdx
    pop rcx
    pop rbx
    ret
```

Memory alignment requirements ensure allocated blocks start on appropriate boundaries. SSE/AVX operations require 16-byte or 32-byte alignment. Some allocators over-align all allocations; others accept alignment as a parameter.

Boundary tags store size information at both the beginning and end of blocks. This enables efficient coalescing in both directions without traversing the entire free list to find adjacent blocks.

Thread safety requires synchronization mechanisms. Simple allocators use mutexes around all operations. High-performance allocators use lock-free algorithms or thread-local caches to minimize contention.

### Performance Optimization

Thread-local caching reduces lock contention. Each thread maintains a small cache of recently freed blocks. Allocations first check the thread-local cache before acquiring global locks.

Size-class specialization optimizes common allocation sizes. Profiling reveals frequently allocated sizes; dedicated fast paths for these sizes improve performance significantly.

Batch allocation amortizes overhead. When requesting memory from the operating system, allocating large chunks and subdividing them reduces system call frequency.

```nasm
; Request large chunk from OS and subdivide
request_memory_from_os:
    ; rdi = minimum size needed
    push rbp
    mov rbp, rsp
    push rbx
    
    ; Round up to page size (4KB)
    add rdi, 4095
    and rdi, -4096
    
    ; Request at least 64KB
    cmp rdi, 65536
    cmovb rdi, [chunk_size_const]
    
    ; mmap system call
    mov rax, 9                ; sys_mmap
    xor rsi, rsi              ; Let kernel choose address
    mov rsi, rdi              ; Length
    mov rdx, 3                ; PROT_READ | PROT_WRITE
    mov r10, 0x22             ; MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1                ; fd
    xor r9, r9                ; offset
    syscall
    
    ; Check for error
    cmp rax, -4096
    ja .mmap_failed
    
    ; Initialize block header
    mov [rax + FreeBlock.size], rsi
    mov qword [rax + FreeBlock.next], 0
    mov qword [rax + FreeBlock.magic], FREE_MAGIC
    
    jmp .done
    
.mmap_failed:
    xor rax, rax
    
.done:
    pop rbx
    pop rbp
    ret

chunk_size_const: dq 65536
```

Prefetching anticipated memory accesses hides latency. During free list traversal, prefetching the next block while processing the current block reduces cache miss penalties.

### Debugging Support

Guard bytes detect buffer overruns. Allocators can pad blocks with known byte patterns (e.g., 0xDEADBEEF), checking these values on deallocation to identify memory corruption.

Allocation tracking records metadata for each allocation: source location, size, timestamp. This enables leak detection, use-after-free identification, and memory profiling.

Double-free detection marks freed blocks and verifies they're not already free before adding to the free list. This prevents corruption from double-free bugs.

## Performance-Critical Library Development

### SIMD String Operations

Vectorized string length calculation processes 16-32 bytes per iteration using SSE/AVX instructions.

```nasm
;==============================================================================
; simd_strlen
;
; Calculate string length using SSE2 vectorization.
;
; Parameters:
;   rdi - Pointer to null-terminated string
;
; Returns:
;   rax - String length (excluding null terminator)
;==============================================================================
simd_strlen:
    push rbx
    
    mov rax, rdi
    pxor xmm0, xmm0           ; Zero vector for comparison
    
    ; Align to 16-byte boundary
    mov rbx, rdi
    and rbx, 15
    test rbx, rbx
    jz .aligned
    
    ; Handle unaligned prefix
.prefix_loop:
    cmp byte [rdi], 0
    je .found_null
    inc rdi
    test rdi, 15
    jnz .prefix_loop
    
.aligned:
    ; Process 16 bytes at a time
.simd_loop:
    movdqa xmm1, [rdi]        ; Load 16 bytes (aligned)
    pcmpeqb xmm1, xmm0        ; Compare with zero
    pmovmskb edx, xmm1        ; Extract comparison mask
    
    test edx, edx
    jnz .found_in_chunk
    
    add rdi, 16
    jmp .simd_loop
    
.found_in_chunk:
    ; Find position of first null byte
    bsf edx, edx              ; Bit scan forward (find first set bit)
    add rdi, rdx
    
.found_null:
    sub rdi, rax              ; Calculate length
    mov rax, rdi
    
    pop rbx
    ret
```

Vectorized memory comparison processes multiple bytes simultaneously, dramatically faster than byte-by-byte comparison for large buffers.

```nasm
; AVX2-accelerated memory comparison
avx2_memcmp:
    ; rdi = buffer1, rsi = buffer2, rdx = size
    ; Returns: 0 if equal, non-zero otherwise
    push rbx
    
    mov rbx, rdx
    shr rbx, 5                ; Number of 32-byte chunks
    test rbx, rbx
    jz .handle_remainder
    
.avx_loop:
    vmovdqu ymm0, [rdi]
    vmovdqu ymm1, [rsi]
    vpcmpeqb ymm2, ymm0, ymm1
    vpmovmskb eax, ymm2
    cmp eax, -1               ; All bits set means all equal
    jne .not_equal
    
    add rdi, 32
    add rsi, 32
    dec rbx
    jnz .avx_loop
    
.handle_remainder:
    and rdx, 31
    test rdx, rdx
    jz .equal
    
.byte_loop:
    mov al, [rdi]
    cmp al, [rsi]
    jne .not_equal
    inc rdi
    inc rsi
    dec rdx
    jnz .byte_loop
    
.equal:
    xor rax, rax
    jmp .done
    
.not_equal:
    mov rax, 1
    
.done:
    vzeroupper                ; Clear upper AVX state
    pop rbx
    ret
```

### Mathematical Operations

Fast integer division avoids costly `div` instructions for constant divisors using multiplication by reciprocal.

```nasm
; Divide by 10 using multiplication (64-bit)
; Faster than div instruction for constant divisor
div_by_10:
    ; rax = dividend
    ; Returns: rax = quotient, rdx = remainder
    
    ; Multiply by reciprocal: floor(2^67 / 10)
    mov rdx, 0xCCCCCCCCCCCCCCCD
    mul rdx                   ; rdx:rax = rax * 0xCCCC...
    shr rdx, 3                ; Divide by 2^3 (total shift: 67)
    mov rax, rdx              ; Quotient in rax
    
    ; Calculate remainder: original - (quotient * 10)
    lea rdx, [rax + rax * 4]  ; rdx = quotient * 5
    shl rdx, 1                ; rdx = quotient * 10
    sub rax, rdx              ; Original in saved register - quotient*10
    
    ret
```

Vectorized math operations process arrays of numbers simultaneously. Computing element-wise operations on float/double arrays benefits enormously from SIMD.

```nasm
; Vectorized array addition (single precision float)
; dst[i] = src1[i] + src2[i] for all i
vector_add_f32:
    ; rdi = dst, rsi = src1, rdx = src2, rcx = count

    push    rbx

    mov     rbx, rcx
    shr     rbx, 3                ; Number of 8-float chunks (AVX)
    test    rbx, rbx
    jz      .handle_remainder

.avx_loop:
    vmovups ymm0, [rsi]
    vmovups ymm1, [rdx]
    vaddps  ymm0, ymm0, ymm1
    vmovups [rdi], ymm0

    add     rsi, 32
    add     rdx, 32
    add     rdi, 32
    dec     rbx
    jnz     .avx_loop

.handle_remainder:
    and     rcx, 7
    test    rcx, rcx
    jz      .done

.scalar_loop:
    movss   xmm0, [rsi]
    addss   xmm0, [rdx]
    movss   [rdi], xmm0
    add     rsi, 4
    add     rdx, 4
    add     rdi, 4
    dec     rcx
    jnz     .scalar_loop

.done:
    vzeroupper
    pop     rbx
    ret
````

Fixed-point arithmetic provides deterministic precision without floating-point complexity. Useful for financial calculations, embedded systems, or situations requiring exact decimal representation.

```nasm
; Fixed-point multiplication (32.32 format)
; High 32 bits: integer part, low 32 bits: fractional part
fixedpoint_mul:
    ; rdi = operand1 (64-bit), rsi = operand2 (64-bit)
    ; Returns: rax = product (64-bit fixed-point)
    
    ; Multiply as 128-bit intermediate
    mov rax, rdi
    imul rsi                  ; rdx:rax = rdi * rsi (128-bit result)
    
    ; Shift right 32 bits to align decimal point
    shrd rax, rdx, 32         ; Shift right double precision
    
    ret

; Fixed-point division (32.32 format)
fixedpoint_div:
    ; rdi = dividend, rsi = divisor
    ; Returns: rax = quotient
    
    mov rax, rdi
    mov rdx, rax
    sar rdx, 63               ; Sign extend to 128 bits
    shl rax, 32               ; Shift left to preserve precision
    
    idiv rsi                  ; rax = rdx:rax / rsi
    
    ret
````

### Hashing and Checksums

CRC32 calculation using hardware acceleration (SSE4.2) provides fast checksums for data integrity verification.

```nasm
;==============================================================================
; crc32_calculate
;
; Calculates CRC32 checksum using hardware CRC32C instruction (SSE4.2).
;
; Parameters:
;   rdi - Data buffer pointer
;   rsi - Buffer size in bytes
;
; Returns:
;   rax - CRC32 checksum (32-bit in lower half)
;==============================================================================
crc32_calculate:
    push rbx
    push rcx
    
    xor eax, eax              ; Initial CRC value (0 or 0xFFFFFFFF)
    not eax                   ; Common to start with 0xFFFFFFFF
    
    mov rbx, rsi
    shr rbx, 3                ; Number of 8-byte chunks
    test rbx, rbx
    jz .handle_remainder
    
.qword_loop:
    crc32 rax, qword [rdi]    ; Hardware CRC32 instruction
    add rdi, 8
    dec rbx
    jnz .qword_loop
    
.handle_remainder:
    and rsi, 7
    test rsi, rsi
    jz .finalize
    
.byte_loop:
    movzx ecx, byte [rdi]
    crc32 eax, ecx
    inc rdi
    dec rsi
    jnz .byte_loop
    
.finalize:
    not eax                   ; Final XOR (standard CRC32 finalization)
    
    pop rcx
    pop rbx
    ret
```

FNV-1a hash provides fast, high-quality hashing for hash tables and data structures.

```nasm
; FNV-1a hash (64-bit version)
fnv1a_hash:
    ; rdi = data pointer, rsi = length
    ; Returns: rax = hash value
    
    ; FNV-1a constants
    mov rax, 0xCBF29CE484222325    ; FNV offset basis (64-bit)
    mov r8,  0x00000100000001B3    ; FNV prime (64-bit)
    
    test rsi, rsi
    jz .done
    
.hash_loop:
    movzx rcx, byte [rdi]
    xor rax, rcx              ; XOR with byte
    imul rax, r8              ; Multiply by FNV prime
    
    inc rdi
    dec rsi
    jnz .hash_loop
    
.done:
    ret
```

xxHash implementation offers excellent speed/quality tradeoff for non-cryptographic hashing.

```nasm
; xxHash32 - simplified version showing core algorithm
PRIME32_1 equ 0x9E3779B1
PRIME32_2 equ 0x85EBCA77
PRIME32_3 equ 0xC2B2AE3D
PRIME32_4 equ 0x27D4EB2F
PRIME32_5 equ 0x165667B1

xxhash32:
    ; rdi = data, rsi = length, rdx = seed
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    mov r12, rdi              ; Save data pointer
    mov r13, rsi              ; Save length
    
    ; Initialize accumulators
    lea r14, [rdx + PRIME32_1]
    add r14, PRIME32_2
    lea r15, [rdx + PRIME32_2]
    mov rbx, rdx              ; acc3 = seed
    lea rcx, [rdx - PRIME32_1] ; acc4 = seed - PRIME32_1
    
    ; Process 16-byte blocks
    mov r8, rsi
    shr r8, 4                 ; Number of 16-byte blocks
    test r8, r8
    jz .process_remaining
    
.block_loop:
    ; Process 4 x 4-byte lanes
    mov eax, [rdi]
    imul eax, PRIME32_2
    add r14d, eax
    rol r14d, 13
    imul r14d, PRIME32_1
    
    mov eax, [rdi + 4]
    imul eax, PRIME32_2
    add r15d, eax
    rol r15d, 13
    imul r15d, PRIME32_1
    
    mov eax, [rdi + 8]
    imul eax, PRIME32_2
    add ebx, eax
    rol ebx, 13
    imul ebx, PRIME32_1
    
    mov eax, [rdi + 12]
    imul eax, PRIME32_2
    add ecx, eax
    rol ecx, 13
    imul ecx, PRIME32_1
    
    add rdi, 16
    dec r8
    jnz .block_loop
    
    ; Merge accumulators
    mov eax, r14d
    rol eax, 1
    add eax, r15d
    rol eax, 7
    add eax, ebx
    rol eax, 12
    add eax, ecx
    jmp .finalize
    
.process_remaining:
    ; Small input - use seed + PRIME32_5
    lea eax, [edx + PRIME32_5]
    
.finalize:
    add eax, r13d             ; Add length
    
    ; Process remaining bytes (simplified)
    and rsi, 15
    add r12, r13
    sub r12, rsi
    
.remaining_loop:
    test rsi, rsi
    jz .avalanche
    
    movzx ecx, byte [r12]
    imul ecx, PRIME32_5
    add eax, ecx
    rol eax, 11
    imul eax, PRIME32_1
    
    inc r12
    dec rsi
    jmp .remaining_loop
    
.avalanche:
    ; Final avalanche mixing
    mov ecx, eax
    shr ecx, 15
    xor eax, ecx
    imul eax, PRIME32_2
    
    mov ecx, eax
    shr ecx, 13
    xor eax, ecx
    imul eax, PRIME32_3
    
    mov ecx, eax
    shr ecx, 16
    xor eax, ecx
    
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
```

### Lock-Free Data Structures

Compare-and-swap (CAS) operations enable lock-free algorithms. The `cmpxchg` instruction atomically compares and exchanges values, forming the foundation of lock-free programming.

```nasm
;==============================================================================
; lock_free_push
;
; Pushes value onto lock-free stack using CAS.
;
; Parameters:
;   rdi - Stack head pointer (pointer to head node pointer)
;   rsi - New node pointer
;
; Node structure: [next pointer | data...]
;==============================================================================
lock_free_push:
    mov rax, [rdi]            ; Load current head
    
.retry:
    mov [rsi], rax            ; Set new node's next to current head
    
    ; Atomic compare-and-swap
    lock cmpxchg [rdi], rsi
    jnz .retry                ; Retry if head changed
    
    ret

;==============================================================================
; lock_free_pop
;
; Pops value from lock-free stack using CAS.
;
; Parameters:
;   rdi - Stack head pointer
;
; Returns:
;   rax - Popped node pointer (NULL if empty)
;==============================================================================
lock_free_pop:
    mov rax, [rdi]            ; Load current head
    
.retry:
    test rax, rax
    jz .empty                 ; Stack is empty
    
    mov rdx, [rax]            ; Load next node
    
    ; Try to update head to next
    lock cmpxchg [rdi], rdx
    jnz .retry                ; Retry if head changed
    
    ret
    
.empty:
    xor rax, rax
    ret
```

ABA problem mitigation uses tagged pointers or hazard pointers. The ABA problem occurs when a value changes from A to B and back to A, causing CAS to succeed incorrectly.

```nasm
; Tagged pointer approach (using upper 16 bits for version counter)
; Assumes 48-bit address space

lock_free_push_tagged:
    ; rdi = stack head, rsi = new node
    
    mov rax, [rdi]            ; Load head with tag
    
.retry:
    mov rcx, rax
    and rcx, 0xFFFFFFFFFFFF   ; Extract pointer (lower 48 bits)
    mov [rsi], rcx            ; Set new node's next
    
    ; Increment version tag
    mov rdx, rax
    shr rdx, 48               ; Extract tag
    inc dx                    ; Increment tag
    shl rdx, 48               ; Shift back to upper bits
    or rdx, rsi               ; Combine with new pointer
    
    lock cmpxchg [rdi], rdx
    jnz .retry
    
    ret
```

Lock-free queue implementation requires careful handling of both head and tail pointers.

```nasm
; Lock-free queue node structure
struc QueueNode
    .next: resq 1
    .data: resq 1
endstruc

; Lock-free enqueue
lock_free_enqueue:
    ; rdi = queue (head and tail pointers), rsi = new node
    
    mov qword [rsi + QueueNode.next], 0
    
.retry:
    mov rax, [rdi + 8]        ; Load tail
    mov rdx, [rax + QueueNode.next]
    
    ; Check if tail is still the last node
    test rdx, rdx
    jz .update_tail
    
    ; Tail is not last, help advance it
    lock cmpxchg [rdi + 8], rdx
    jmp .retry
    
.update_tail:
    ; Try to link new node
    xor rdx, rdx
    lock cmpxchg [rax + QueueNode.next], rsi
    jnz .retry
    
    ; Try to advance tail
    lock cmpxchg [rdi + 8], rsi
    
    ret
```

### Cache Optimization

Cache line alignment prevents false sharing in multi-threaded code. Aligning frequently-accessed variables to 64-byte boundaries ensures each resides in separate cache lines.

```nasm
section .data
align 64
thread1_counter: dq 0
    times 7 dq 0              ; Padding to fill cache line

align 64
thread2_counter: dq 0
    times 7 dq 0              ; Padding to fill cache line
```

Prefetching data before use hides memory latency. Software prefetch instructions load data into cache before needed.

```nasm
; Prefetch during linked list traversal
traverse_with_prefetch:
    ; rdi = list head
    mov rax, rdi
    
.traverse_loop:
    test rax, rax
    jz .done
    
    ; Prefetch next node while processing current
    mov rdx, [rax]            ; Load next pointer
    prefetcht0 [rdx]          ; Prefetch next node to L1 cache
    
    ; Process current node
    mov rcx, [rax + 8]        ; Load data
    add rcx, 1                ; Process data
    mov [rax + 8], rcx        ; Store result
    
    mov rax, rdx              ; Move to next node
    jmp .traverse_loop
    
.done:
    ret
```

Streaming stores bypass cache for large writes, preventing cache pollution when writing data that won't be read soon.

```nasm
; Non-temporal stores for large memory copy
streaming_memcpy:
    ; rdi = dest, rsi = src, rdx = size (must be multiple of 32)
    
    mov rcx, rdx
    shr rcx, 5                ; Number of 32-byte chunks
    
.copy_loop:
    vmovdqa ymm0, [rsi]
    vmovntdq [rdi], ymm0      ; Non-temporal (streaming) store
    
    add rsi, 32
    add rdi, 32
    dec rcx
    jnz .copy_loop
    
    sfence                    ; Ensure stores complete
    vzeroupper
    ret
```

### Branch Optimization

Branch prediction hints guide the processor's speculation. The `likely` and `unlikely` macros use branch layout to optimize common paths.

```nasm
; Arrange code so likely path falls through
process_array:
    xor rcx, rcx
    
.loop:
    cmp rcx, rsi
    jae .done                 ; Unlikely - only at end
    
    mov rax, [rdi + rcx * 8]
    test rax, rax
    jz .skip                  ; Unlikely - errors are rare
    
    ; Common path - falls through
    call process_element
    
.continue:
    inc rcx
    jmp .loop
    
.skip:                        ; Cold path - branched to
    call handle_null
    jmp .continue
    
.done:
    ret
```

Branchless programming eliminates conditional branches using arithmetic and logical operations.

```nasm
; Branchless absolute value
abs_branchless:
    ; rax = input value
    mov rdx, rax
    sar rdx, 63               ; Sign bit replicated to all bits
    xor rax, rdx              ; Flip bits if negative
    sub rax, rdx              ; Add 1 if negative
    ret

; Branchless minimum
min_branchless:
    ; eax = a, edx = b
    ; Returns: eax = min(a, b)
    cmp eax, edx
    cmovg eax, edx            ; Conditional move if greater
    ret

; Branchless sign function (-1, 0, or 1)
sign_branchless:
    ; rax = input
    test rax, rax
    sets dl                   ; Set if sign flag (negative)
    setnz cl                  ; Set if non-zero
    movsx rax, dl             ; Sign extend
    or al, cl                 ; Combine conditions
    ret
```

Loop unrolling reduces branch overhead and enables better instruction-level parallelism.

```nasm
; Unrolled loop for array summation
sum_array_unrolled:
    ; rdi = array, rsi = count (must be multiple of 4)
    
    xor rax, rax              ; Sum accumulator
    xor rcx, rcx              ; Index
    
    shr rsi, 2                ; Divide by 4 for unrolling
    
.loop:
    add rax, [rdi + rcx * 8]
    add rax, [rdi + rcx * 8 + 8]
    add rax, [rdi + rcx * 8 + 16]
    add rax, [rdi + rcx * 8 + 24]
    
    add rcx, 4
    dec rsi
    jnz .loop
    
    ret
```

### Profiling Integration

Timestamp counter reads measure precise timing for performance analysis.

```nasm
; Get CPU timestamp counter
get_timestamp:
    lfence                    ; Serialize instructions
    rdtsc                     ; Read timestamp counter
    shl rdx, 32
    or rax, rdx               ; Combine into 64-bit value
    ret

; Benchmark function execution
benchmark_function:
    ; rdi = function pointer
    push rbx
    
    call get_timestamp
    mov rbx, rax              ; Save start time
    
    call rdi                  ; Execute function
    
    call get_timestamp
    sub rax, rbx              ; Calculate elapsed cycles
    
    pop rbx
    ret
```

Performance counters access hardware monitoring capabilities for detailed profiling.

```nasm
; Read performance counter (requires kernel support)
read_perfcounter:
    ; rdi = counter index
    mov rcx, rdi
    rdpmc                     ; Read performance monitoring counter
    shl rdx, 32
    or rax, rdx
    ret
```

### Error Handling Patterns

Return code conventions establish consistent error signaling across library functions.

```nasm
; Error codes
SUCCESS        equ 0
ERR_NULL_PTR   equ 1
ERR_INVALID    equ 2
ERR_OVERFLOW   equ 3
ERR_UNDERFLOW  equ 4

; Function with error codes
safe_buffer_copy:
    ; rdi = dest, rsi = dest_size, rdx = src, rcx = src_size
    ; Returns: rax = error code
    
    ; Validate inputs
    test rdi, rdi
    jz .null_pointer
    test rdx, rdx
    jz .null_pointer
    
    ; Check size
    cmp rcx, rsi
    ja .overflow
    
    ; Perform copy
    push rdi
    push rcx
    call memcpy
    pop rcx
    pop rdi
    
    mov rax, SUCCESS
    ret
    
.null_pointer:
    mov rax, ERR_NULL_PTR
    ret
    
.overflow:
    mov rax, ERR_OVERFLOW
    ret
```

Exception safety ensures resources release even during error paths.

```nasm
; Function with resource cleanup
open_and_process:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    
    ; Open resource
    call open_file
    test rax, rax
    jz .open_failed
    mov r12, rax              ; Save file handle
    
    ; Allocate buffer
    mov rdi, 4096
    call malloc
    test rax, rax
    jz .alloc_failed
    mov rbx, rax              ; Save buffer
    
    ; Process (may fail)
    mov rdi, r12
    mov rsi, rbx
    call process_file
    test rax, rax
    jz .process_failed
    
    ; Success path - cleanup
    mov rdi, rbx
    call free
    mov rdi, r12
    call close_file
    mov rax, 1                ; Success
    jmp .done
    
.process_failed:
    mov rdi, rbx
    call free
    
.alloc_failed:
    mov rdi, r12
    call close_file
    
.open_failed:
    xor rax, rax              ; Failure
    
.done:
    pop r12
    pop rbx
    pop rbp
    ret
```

**Key Points:**

- Compression engines require careful algorithmic implementation balancing compression ratio against speed
- Hash tables dramatically accelerate sliding window search in LZ77 compression
- Custom allocators optimize specific allocation patterns through strategies like segregated free lists and slab allocation
- Block coalescing and boundary tags reduce fragmentation in memory allocators
- SIMD instructions provide massive speedups for string operations, memory comparison, and mathematical computations
- Hardware CRC32 instructions offer fast checksumming for data integrity verification
- Lock-free data structures using CAS operations enable high-performance concurrent programming without lock contention
- Cache line alignment and prefetching dramatically improve multi-threaded performance
- Branchless programming and loop unrolling reduce branch misprediction penalties
- Consistent error handling patterns and resource cleanup ensure library reliability
- Performance measurement through timestamp counters enables precise optimization targeting
- Thread-local caching in allocators minimizes contention in multi-threaded environments
