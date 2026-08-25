## Heap and Static Memory


Heap and static memory serve different purposes in program memory organization. Static memory exists for the program's entire lifetime with fixed addresses, while heap memory provides dynamic allocation and deallocation controlled by program logic.

### Static Memory Organization

Static memory encompasses several categories of data with different characteristics:

**.text section** contains executable code. The linker places all function instructions here. This section is marked read-only and executable in page tables. Position-independent executables use PC-relative addressing to reference code within this section. The section typically loads at fixed addresses (for static executables) or randomized addresses (with ASLR enabled).

**.rodata section** stores read-only data including string literals, constant arrays, and const-qualified variables. Page protection marks this non-writable, causing faults if code attempts modification. Compilers often merge identical string literals across translation units to reduce size.

**.data section** contains initialized static and global variables with non-zero initial values. The loader copies initial values from the executable file to memory at program startup. This section has read-write page permissions.

**.bss section** (Block Started by Symbol) holds uninitialized or zero-initialized static and global variables. The section doesn't consume space in the executable file - only metadata describing its size. The loader allocates and zero-fills this region at program startup. Large zero-initialized arrays use .bss rather than .data to avoid bloating executable size.

**Thread-local storage (TLS)** sections (.tdata, .tbss) store per-thread static variables. The system creates separate copies of these sections for each thread. Access requires special instruction sequences or runtime library calls to locate the current thread's TLS block.

### Accessing Static Memory

PC-relative addressing enables position-independent access to static data. The ADRP instruction computes the address of a 4KB page relative to the current PC:

```
    adrp x0, variable       // x0 = page address of 'variable'
    ldr x1, [x0, :lo12:variable]  // Load from page offset
```

ADRP loads bits [63:12] of the target address into X0, with bits [11:0] cleared. The `:lo12:` relocation adds the low 12 bits (page offset). This two-instruction sequence can address any symbol within ±4GB of current PC.

For data within ±1MB, a single ADR instruction suffices:

```
    adr x0, nearby_data     // x0 = address of 'nearby_data'
```

Global Offset Table (GOT) provides indirection for shared library symbols and dynamic linking. The GOT contains absolute addresses of global symbols, updated by the dynamic linker at load time:

```
    adrp x0, :got:global_var     // Page of GOT entry
    ldr x0, [x0, :got_lo12:global_var]  // Load address from GOT
    ldr w1, [x0]                  // Load actual value
```

This three-instruction sequence first locates the GOT entry, loads the actual variable address from the GOT, then accesses the variable. [Inference: The GOT indirection overhead motivates link-time optimization to convert GOT access to direct PC-relative access when possible.]

### Heap Memory Management

The heap provides dynamically allocated memory managed through allocator interfaces (malloc/free in C, new/delete in C++). The heap typically grows upward from low addresses toward higher addresses, opposite to the stack's downward growth.

**System allocators** (malloc implementations) request large memory regions from the operating system through system calls (mmap on Linux, VirtualAlloc on Windows) and subdivide these regions for application allocations. Allocators maintain metadata tracking free and allocated blocks, implementing various strategies (first-fit, best-fit, segregated free lists, buddy allocation) balancing performance, fragmentation, and overhead.

**Alignment requirements** constrain allocator behavior. Standard allocators guarantee alignment suitable for any standard data type - typically 16 bytes on AArch64 to satisfy SIMD requirements. Allocating smaller objects still returns 16-byte aligned addresses; the allocator's internal fragmentation wastes the unused bytes.

**Metadata overhead** includes block headers storing size information and allocation status. Allocators often store metadata immediately before allocated blocks:

```
Block layout:
[Header: 8-16 bytes][User data: requested size][Padding for next alignment]
                    ^
                    malloc returns this address
```

The header might contain the block size, allocation flags, and pointers for free list management. On free(), the allocator accesses the header by subtracting from the user pointer. [Inference: Writing before allocated blocks corrupts allocator metadata, causing crashes or vulnerabilities during subsequent allocations/deallocations.]

**Fragmentation** occurs in two forms. External fragmentation leaves free memory scattered in small unusable pieces. Internal fragmentation wastes space within allocated blocks due to alignment and minimum size constraints. Allocators employ various strategies to mitigate fragmentation, including coalescing adjacent free blocks and segregating allocations by size class.

### Memory Pools and Arena Allocation

Applications with specific allocation patterns often implement custom allocators:

**Memory pools** pre-allocate fixed-size blocks, eliminating allocation overhead and fragmentation for uniform-sized objects. Allocation returns the next available block from a free list; deallocation returns blocks to the free list. This provides O(1) allocation/deallocation and excellent cache locality.

**Arena allocators** (bump allocators, linear allocators) allocate sequentially from a large buffer by incrementing a pointer. Individual deallocations are not supported - the entire arena releases at once. This suits temporary allocations with bulk deallocation (parser nodes, per-frame game objects).

**Stack allocators** function like arena allocators but support last-in-first-out deallocation. Allocations increment a stack pointer; deallocations must occur in reverse order, decrementing the pointer back.

### Cache Considerations for Memory Layout

Memory access patterns significantly impact performance on modern processors with multi-level caches. [Inference: Understanding cache behavior helps optimize data structure layout, though specific cache parameters vary by processor implementation.]

**Spatial locality** benefits from storing related data contiguously. Accessing one element brings nearby elements into cache. Array traversal exhibits excellent spatial locality; linked list traversal exhibits poor spatial locality.

**Temporal locality** benefits from reusing recently accessed data while still cache-resident. Algorithms processing the same data repeatedly should minimize working set size to fit in cache.

**Cache line size** (typically 64 bytes on ARM) determines granularity of data transfer between memory and cache. Straddling cache line boundaries may require two cache line loads. Aligning frequently accessed structures to cache line boundaries can improve performance.

**False sharing** occurs when threads write to different variables occupying the same cache line, causing cache coherency traffic. Padding structures to occupy full cache lines prevents false sharing in multi-threaded code.

