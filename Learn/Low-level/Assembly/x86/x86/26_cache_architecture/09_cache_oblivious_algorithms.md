## Cache-Oblivious Algorithms


Cache-oblivious algorithms perform well across different cache sizes and hierarchies without explicit tuning for specific cache parameters.

### Principles of Cache-Oblivious Algorithms

**Key Characteristics:**

1. **Recursive divide-and-conquer**: Automatically adapts to cache sizes
2. **No explicit blocking parameters**: Works for unknown cache sizes
3. **Optimal performance**: [Inference] Achieves same asymptotic cache complexity as cache-aware algorithms
4. **Hierarchical locality**: Exploits all levels of memory hierarchy

### Cache-Oblivious Matrix Transpose

```nasm
; Recursive cache-oblivious matrix transpose
; Automatically adapts to L1, L2, L3 cache sizes

matrix_transpose_recursive:
    ; Input:
    ;   ESI = source matrix
    ;   EDI = destination matrix
    ;   ECX = row start
    ;   EDX = column start
    ;   EAX = number of rows
    ;   EBX = number of columns
    ;   [n] = matrix dimension
    
    push ebp
    mov ebp, esp
    sub esp, 32                 ; Local variables
    
    ; Base case: small enough to transpose directly
    cmp eax, 16
    jg .recurse_rows
    cmp ebx, 16
    jg .recurse_cols
    
.base_case:
    ; Direct transpose of small block
    mov r8d, ecx                ; row
.row_loop:
    mov r9d, edx                ; col
.col_loop:
    ; Calculate source offset: src[row][col]
    mov r10d, r8d
    imul r10d, [n]
    add r10d, r9d
    shl r10d, 2                 ; × 4 bytes
    
    ; Calculate dest offset: dst[col][row]
    mov r11d, r9d
    imul r11d, [n]
    add r11d, r8d
    shl r11d, 2
    
    ; Transpose element
    mov r12d, [esi + r10]
    mov [edi + r11], r12d
    
    inc r9d
    mov r10d, edx
    add r10d, ebx
    cmp r9d, r10d
    jl .col_loop
    
    inc r8d
    mov r10d, ecx
    add r10d, eax
    cmp r8d, r10d
    jl .row_loop
    
    jmp .done
    
.recurse_rows:
    ; Split rows in half
    mov r8d, eax
    shr r8d, 1                  ; rows / 2
    
    ; Transpose top half
    push ebx
    push r8d                    ; rows/2
    push edx
    push ecx
    call matrix_transpose_recursive
    
    ; Transpose bottom half
    mov ecx, [ebp - 16]         ; Original row start
    add ecx, r8d                ; + rows/2
    push ebx
    push r8d
    push edx
    push ecx
    call matrix_transpose_recursive
    
    jmp .done
    
.recurse_cols:
    ; Split columns in half
    mov r8d, ebx
    shr r8d, 1                  ; cols / 2
    
    ; Transpose left half
    push r8d
    push eax
    push edx
    push ecx
    call matrix_transpose_recursive
    
    ; Transpose right half
    mov edx, [ebp - 12]         ; Original col start
    add edx, r8d                ; + cols/2
    push r8d
    push eax
    push edx
    push ecx
    call matrix_transpose_recursive
    
.done:
    mov esp, ebp
    pop ebp
    ret
```

### Cache-Oblivious Matrix Multiplication

```nasm
; Recursive cache-oblivious matrix multiplication
; C = A × B, all matrices are n×n

matrix_multiply_recursive:
    ; Input:
    ;   [matrix_a] = matrix A base
    ;   [matrix_b] = matrix B base
    ;   [matrix_c] = matrix C base
    ;   [a_row] = A starting row
    ;   [a_col] = A starting column
    ;   [b_row] = B starting row
    ;   [b_col] = B starting column
    ;   [c_row] = C starting row
    ;   [c_col] = C starting column
    ;   [size] = submatrix size
    ;   [n] = full matrix dimension
    
    push ebp
    mov ebp, esp
    
    mov eax, [size]
    cmp eax, 32                 ; Base case threshold
    jle .base_case
    
    ; Divide: split matrices into quadrants
    shr eax, 1                  ; size / 2
    mov [half_size], eax
    
    ; C11 = A11×B11 + A12×B21
    ; C12 = A11×B12 + A12×B22
    ; C21 = A21×B11 + A22×B21
    ; C22 = A21×B12 + A22×B22
    
    ; Recursively compute 8 multiplications
    ; (Implementation of all 8 recursive calls omitted for brevity)
    ; Each call processes a quadrant
    
    jmp .done
    
.base_case:
    ; Base case: use standard multiplication for small blocks
    mov r8d, [c_row]
    mov r9d, [c_row]
    add r9d, [size]
    
.i_loop:
    mov r10d, [c_col]
    mov r11d, [c_col]
    add r11d, [size]
    
.j_loop:
    ; C[i][j] = sum(A[i][k] × B[k][j])
    pxor xmm0, xmm0             ; Accumulator
    
    mov r12d, [a_col]
    mov r13d, [a_col]
    add r13d, [size]
    
.k_loop:
    ; Load A[i][k]
    mov eax, r8d
    imul eax, [n]
    add eax, r12d
    movss xmm1, [matrix_a + rax * 4]
    
    ; Load B[k][j]
    mov eax, r12d
    imul eax, [n]
    add eax, r10d

    movss xmm2, [matrix_b + rax * 4]
    
    ; Multiply and accumulate
    mulss xmm1, xmm2
    addss xmm0, xmm1
    
    inc r12d
    cmp r12d, r13d
    jl .k_loop
    
    ; Store C[i][j]
    mov eax, r8d
    imul eax, [n]
    add eax, r10d
    movss [matrix_c + rax * 4], xmm0
    
    inc r10d
    cmp r10d, r11d
    jl .j_loop
    
    inc r8d
    cmp r8d, r9d
    jl .i_loop
    
.done:
    pop ebp
    ret
```

### Cache-Oblivious Binary Search Tree

```nasm
; Van Emde Boas layout for cache-oblivious BST
; Tree stored in array with recursive subdivision

struc VEBNode
    .key:       resd 1
    .value:     resd 1
endstruc

; Build VEB layout recursively
build_veb_layout:
    ; Input:
    ;   ESI = sorted array
    ;   EDI = output VEB array
    ;   ECX = start index
    ;   EDX = end index
    ;   EAX = output position
    
    push ebp
    mov ebp, esp
    
    ; Base case: empty range
    cmp ecx, edx
    jg .done
    
    ; Find middle element (top of subtree)
    mov ebx, ecx
    add ebx, edx
    shr ebx, 1                  ; mid = (start + end) / 2
    
    ; Store middle element at current position
    mov r8d, [esi + rbx * 8]    ; key
    mov r9d, [esi + rbx * 8 + 4] ; value
    mov [edi + rax * 8], r8d
    mov [edi + rax * 8 + 4], r9d
    
    ; Recursively layout left subtree
    push eax
    push edx
    push ebx
    dec ebx
    mov edx, ebx
    inc eax
    call build_veb_layout
    
    ; Recursively layout right subtree
    pop ebx
    inc ebx
    mov ecx, ebx
    pop edx
    pop eax
    
    ; Calculate next output position
    mov ebx, edx
    sub ebx, ecx
    inc ebx                     ; Right subtree size
    add eax, ebx
    
    call build_veb_layout
    
.done:
    pop ebp
    ret

; Search in VEB layout
search_veb:
    ; Input:
    ;   ESI = VEB array
    ;   ECX = search key
    ;   EDX = tree size
    ; Output:
    ;   EAX = value (or -1 if not found)
    
    xor eax, eax                ; Current position
    
.search_loop:
    cmp eax, edx
    jge .not_found
    
    ; Compare with current node
    mov ebx, [esi + rax * 8]    ; key
    cmp ecx, ebx
    je .found
    jl .go_left
    
.go_right:
    ; Right child in VEB layout
    ; Calculate size of left subtree
    ; (complex calculation based on recursive structure)
    ; Simplified here
    inc eax
    jmp .search_loop
    
.go_left:
    ; Left child is at position + 1
    inc eax
    jmp .search_loop
    
.found:
    mov eax, [esi + rax * 8 + 4] ; Return value
    ret
    
.not_found:
    mov eax, -1
    ret
```

### Cache-Oblivious Sorting (Funnelsort)

```nasm
; Cache-oblivious merge sort with multi-way merging
; Achieves optimal cache complexity: O(N/B × log_{M/B}(N/B))

funnelsort:
    ; Input:
    ;   ESI = array
    ;   ECX = size
    
    push ebp
    mov ebp, esp
    
    ; Base case: use insertion sort for small arrays
    cmp ecx, 32
    jle .insertion_sort
    
    ; Divide array into sqrt(N) pieces
    mov eax, ecx
    call integer_sqrt          ; EAX = sqrt(size)
    mov [piece_size], eax
    
    ; Recursively sort each piece
    xor ebx, ebx               ; piece index
    
.sort_pieces:
    push ebx
    push ecx
    
    ; Calculate piece start
    mov eax, ebx
    imul eax, [piece_size]
    lea edi, [esi + rax * 4]
    
    ; Calculate piece size (last piece may be smaller)
    mov ecx, [piece_size]
    mov edx, ebx
    inc edx
    imul edx, [piece_size]
    mov eax, [ebp + 12]        ; Total size
    cmp edx, eax
    jle .normal_size
    sub eax, edx
    add ecx, eax
    
.normal_size:
    push edi
    push ecx
    call funnelsort
    add esp, 8
    
    pop ecx
    pop ebx
    inc ebx
    cmp ebx, [piece_size]
    jl .sort_pieces
    
    ; Merge sorted pieces using k-way merge (funnel)
    call k_way_merge
    
    jmp .done
    
.insertion_sort:
    ; Simple insertion sort for base case
    mov edi, esi
    mov edx, 1
    
.insert_loop:
    cmp edx, ecx
    jge .done
    
    mov eax, [edi + rdx * 4]   ; Current element
    mov ebx, edx
    
.shift_loop:
    test ebx, ebx
    jz .insert_here
    
    mov r8d, [edi + rbx * 4 - 4]
    cmp eax, r8d
    jge .insert_here
    
    mov [edi + rbx * 4], r8d   ; Shift right
    dec ebx
    jmp .shift_loop
    
.insert_here:
    mov [edi + rbx * 4], eax
    inc edx
    jmp .insert_loop
    
.done:
    pop ebp
    ret

; K-way merge using recursive funnel structure
k_way_merge:
    ; Merges k sorted sequences
    ; Cache-oblivious through recursive funnel structure
    ; (Detailed implementation omitted for brevity)
    ret

; Integer square root helper
integer_sqrt:
    ; Input: EAX = N
    ; Output: EAX = floor(sqrt(N))
    
    test eax, eax
    jz .done
    
    mov ebx, eax
    shr ebx, 1                 ; Initial guess
    
.newton_loop:
    mov ecx, eax
    xor edx, edx
    div ebx                    ; N / guess
    add eax, ebx
    shr eax, 1                 ; (guess + N/guess) / 2
    
    cmp eax, ebx
    je .done
    mov ebx, eax
    mov eax, ecx
    jmp .newton_loop
    
.done:
    mov eax, ebx
    ret
```

### Cache-Oblivious B-Tree

```nasm
; Cache-oblivious B-tree using van Emde Boas layout

struc COBTree
    .height:        resd 1
    .size:          resd 1
    .root_offset:   resd 1
endstruc

struc COBNode
    .num_keys:      resd 1
    .keys:          resd 16        ; Max 16 keys per node
    .children:      resd 17        ; Max 17 children
endstruc

; Insert into cache-oblivious B-tree
cobtree_insert:
    ; Input:
    ;   ESI = tree structure
    ;   EAX = key to insert
    ;   EBX = value
    
    push ebp
    mov ebp, esp
    sub esp, 16
    
    mov [ebp - 4], eax         ; Save key
    mov [ebp - 8], ebx         ; Save value
    
    ; Find insertion point using cache-oblivious search
    call cobtree_search_path
    
    ; Check if node has space
    mov edi, eax               ; Node pointer
    mov ecx, [edi + COBNode.num_keys]
    cmp ecx, 16
    jl .has_space
    
    ; Split node (cache-oblivious split)
    call cobtree_split_node
    
.has_space:
    ; Insert key in sorted position
    mov eax, [ebp - 4]         ; Key
    mov ebx, [ebp - 8]         ; Value
    
    ; Find insertion position
    xor ecx, ecx
.find_pos:
    cmp ecx, [edi + COBNode.num_keys]
    jge .insert_at_end
    
    mov edx, [edi + COBNode.keys + rcx * 4]
    cmp eax, edx
    jl .found_pos
    
    inc ecx
    jmp .find_pos
    
.found_pos:
    ; Shift keys to make room
    mov esi, [edi + COBNode.num_keys]
    
.shift_loop:
    cmp esi, ecx
    jle .do_insert
    
    mov edx, [edi + COBNode.keys + rsi * 4 - 4]
    mov [edi + COBNode.keys + rsi * 4], edx
    
    dec esi
    jmp .shift_loop
    
.do_insert:
    mov [edi + COBNode.keys + rcx * 4], eax
    inc dword [edi + COBNode.num_keys]
    jmp .done
    
.insert_at_end:
    mov ecx, [edi + COBNode.num_keys]
    mov [edi + COBNode.keys + rcx * 4], eax
    inc dword [edi + COBNode.num_keys]
    
.done:
    mov esp, ebp
    pop ebp
    ret
```

### Cache-Oblivious Linked List Traversal

```nasm
; Blocked linked list for cache-oblivious traversal
; Group nodes into cache-line-sized blocks

BLOCK_SIZE equ 8               ; Nodes per block

struc BlockedListNode
    .keys:          resd BLOCK_SIZE
    .values:        resd BLOCK_SIZE
    .count:         resd 1
    .next_block:    resd 1
endstruc

; Traverse blocked linked list
traverse_blocked_list:
    ; Input: ESI = head block
    
    mov edi, esi
    
.block_loop:
    test edi, edi
    jz .done
    
    ; Process all nodes in current block
    mov ecx, [edi + BlockedListNode.count]
    xor ebx, ebx
    
.node_loop:
    cmp ebx, ecx
    jge .next_block
    
    ; Process node
    mov eax, [edi + BlockedListNode.keys + rbx * 4]
    mov edx, [edi + BlockedListNode.values + rbx * 4]
    
    ; ... processing ...
    
    inc ebx
    jmp .node_loop
    
.next_block:
    ; Prefetch next block
    mov esi, [edi + BlockedListNode.next_block]
    test esi, esi
    jz .no_prefetch
    prefetcht0 [esi]
    
.no_prefetch:
    mov edi, esi
    jmp .block_loop
    
.done:
    ret
```

### Cache-Oblivious FFT

```nasm
; Cache-oblivious Fast Fourier Transform
; Uses six-step algorithm with automatic cache adaptation

fft_cache_oblivious:
    ; Input:
    ;   ESI = complex array (interleaved real/imag)
    ;   ECX = size (power of 2)
    
    push ebp
    mov ebp, esp
    
    ; Base case: size <= threshold
    cmp ecx, 64
    jle .base_fft
    
    ; Divide into two halves
    shr ecx, 1                 ; N/2
    
    ; FFT of even indices
    push ecx
    push esi
    call fft_even_indices
    
    ; FFT of odd indices
    push ecx
    lea esi, [esi + 8]         ; Skip first element (8 bytes = complex)
    call fft_odd_indices
    
    ; Combine results (butterfly operations)
    call fft_combine
    
    jmp .done
    
.base_fft:
    ; Use standard iterative FFT for base case
    call fft_iterative_base
    
.done:
    pop ebp
    ret

; Separate even/odd for cache efficiency
fft_even_indices:
    ; Extract even-indexed elements
    ; Layout in cache-friendly manner
    mov edi, [temp_buffer]
    xor ebx, ebx
    
.extract_loop:
    cmp ebx, ecx
    jge .recursion
    
    ; Copy even element
    movsd xmm0, [esi + rbx * 16]    ; Complex number (2 × 8 bytes)
    movsd [edi + rbx * 8], xmm0
    
    inc ebx
    jmp .extract_loop
    
.recursion:
    mov esi, edi
    call fft_cache_oblivious
    ret
```

### Practical Cache-Oblivious Techniques

**Automatic Blocking:**

```nasm
; Matrix operation with recursive subdivision
; Automatically finds optimal block size

recursive_matrix_op:
    ; Keep subdividing until working set fits in cache
    ; No explicit cache size parameter needed
    
    mov eax, [block_rows]
    imul eax, [block_cols]
    shl eax, 2                 ; × 4 bytes per element
    
    ; Heuristic: if working set < ~8KB, use direct computation
    cmp eax, 8192
    jl .direct_compute
    
    ; Otherwise, subdivide
    shr dword [block_rows], 1
    call recursive_matrix_op
    
    ; Restore and process other half
    shl dword [block_rows], 1
    ; ... continue subdivision ...
    
.direct_compute:
    ; Perform operation on small block
    ret
```

**Z-Order (Morton) Layout:**

```nasm
; Convert 2D coordinates to Z-order (Morton code)
; Cache-oblivious locality preservation

xy_to_morton:
    ; Input: EAX = x, EBX = y
    ; Output: ECX = Morton code
    
    xor ecx, ecx
    mov edx, 0
    
.interleave_loop:
    cmp edx, 16                ; For 32-bit coordinates
    jge .done
    
    ; Extract bit from x
    mov esi, eax
    shr esi, cl
    and esi, 1
    shl esi, cl
    shl esi, cl                ; Position in result
    or ecx, esi
    
    ; Extract bit from y
    mov esi, ebx
    shr esi, cl
    and esi, 1
    shl esi, cl
    inc cl
    shl esi, cl
    or ecx, esi
    
    inc edx
    jmp .interleave_loop
    
.done:
    ret

; Access 2D array in Z-order
access_z_order_array:
    ; Convert (x, y) to Z-order index
    call xy_to_morton
    
    ; Access array[morton_index]
    mov eax, [array_base + rcx * 4]
    ret
```

**Hilbert Curve Layout:**

```nasm
; Hilbert curve provides even better locality than Z-order
; (Full implementation complex, showing concept)

xy_to_hilbert:
    ; Input: EAX = x, EBX = y, ECX = order
    ; Output: EDX = Hilbert index
    
    ; Recursive transformation through rotation/reflection
    ; Preserves locality better than Morton code
    ; [Inference] Provides optimal cache behavior for 2D traversal
    
    push ebp
    mov ebp, esp
    
    xor edx, edx               ; Result accumulator
    
    ; (Detailed implementation omitted for brevity)
    ; Involves recursive quadrant subdivision
    
    pop ebp
    ret
```

### Performance Comparison

```nasm
; Compare cache-aware vs cache-oblivious performance

benchmark_algorithms:
    ; Test 1: Matrix multiplication
    
    ; Cache-aware (explicit blocking)
    rdtsc
    mov [start_time], eax
    
    call matrix_multiply_blocked  ; Uses explicit 32×32 blocks
    
    rdtsc
    sub eax, [start_time]
    mov [time_aware], eax
    
    ; Cache-oblivious (recursive)
    rdtsc
    mov [start_time], eax
    
    call matrix_multiply_recursive
    
    rdtsc
    sub eax, [start_time]
    mov [time_oblivious], eax
    
    ; Compare results
    ; [Inference] Cache-oblivious often within 10-20% of tuned cache-aware
    ; but works across all cache sizes without modification
    
    ret
```

**Key Points:**

- Cache prefetching uses PREFETCHT0/T1/T2/NTA instructions to load data before needed; optimal prefetch distance is typically 10-20 cache lines ahead for sequential access
- [Inference] Hardware prefetchers detect sequential and strided patterns automatically but software prefetching helps with irregular access patterns like linked lists
- False sharing occurs when threads modify different variables on the same 64-byte cache line, causing cache line ping-pong between cores with severe performance degradation
- Preventing false sharing requires padding structures to 64-byte boundaries, partitioning work by cache-line-sized chunks, and using per-CPU data structures
- Cache-oblivious algorithms use recursive divide-and-conquer to automatically adapt to all cache hierarchy levels without explicit blocking parameters
- Matrix operations benefit from cache-oblivious recursive subdivision: matrices split until submatrices fit in cache, achieving optimal cache complexity
- Van Emde Boas layout for trees and Z-order/Hilbert curves for 2D arrays preserve spatial locality in cache-oblivious manner
- [Inference] Cache-oblivious algorithms typically perform within 10-20% of optimally-tuned cache-aware code but require no cache-size-specific tuning
- Structure-of-Arrays (SoA) layout reduces false sharing compared to Array-of-Structures (AoS) when multiple threads process different fields
- Detecting cache behavior requires performance counters for cache miss rates, RFO (Request For Ownership) events indicating coherency traffic, and comparing execution times with different access patterns

---

