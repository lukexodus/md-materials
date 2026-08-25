## Memory Alignment Requirements


Memory alignment refers to the address constraints for accessing data of various types. Properly aligned data can be accessed efficiently in single operations; misaligned data may require multiple memory cycles, trap to software handlers, or cause faults depending on processor configuration and access type.

### Natural Alignment

ARM data types have natural alignment requirements matching their size:

- 8-bit (byte): 1-byte aligned (any address)
- 16-bit (halfword): 2-byte aligned (address divisible by 2)
- 32-bit (word): 4-byte aligned (address divisible by 4)
- 64-bit (doubleword): 8-byte aligned (address divisible by 8)
- 128-bit (quadword): 16-byte aligned (address divisible by 16)

Accessing naturally aligned data guarantees optimal performance. For example, loading a 32-bit word from address 0x1000 executes efficiently since 0x1000 is divisible by 4. Loading from 0x1002 constitutes misaligned access with platform-dependent behavior.

### Misalignment Handling

AArch64 provides configurable misalignment handling through the SCTLR_EL1 system register. The alignment check (A) and alignment fault checking (A/SA) bits control behavior:

**Alignment checking disabled** (typical for user-space): Most load/store instructions tolerate misalignment with performance penalties. The processor may execute multiple memory transactions to access misaligned data. [Unverified: Specific performance penalties depend on processor microarchitecture and memory system implementation.]

**Alignment checking enabled**: Misaligned access triggers alignment faults, causing exceptions. Operating system handlers may emulate the access (slowly) or terminate the process. Kernel code often enables alignment checking to catch bugs.

**Exclusive access restrictions**: Load-exclusive and store-exclusive instructions (LDXR, STXR family) require natural alignment regardless of alignment checking settings. Misaligned exclusive access causes alignment faults unconditionally.

**SIMD/vector restrictions**: Vector load/store instructions accessing multiple elements may impose stricter alignment requirements. [Unverified: Specific SIMD alignment requirements vary by instruction and processor implementation.] Unaligned SIMD access either performs poorly or faults depending on instruction variant and processor.

### Structure Padding and Packing

Compilers insert padding in structures to satisfy alignment requirements:

```c
struct Example {
    char c;      // 1 byte at offset 0
    // 3 bytes padding inserted here
    int i;       // 4 bytes at offset 4
    char d;      // 1 byte at offset 8
    // 7 bytes padding inserted here
    double f;    // 8 bytes at offset 16
};
// Total size: 24 bytes
```

The compiler aligns each member to its natural alignment. The structure's overall alignment equals the maximum member alignment (8 bytes for the double). Structure size rounds up to a multiple of its alignment, ensuring proper alignment in arrays.

Reordering members can reduce padding:

```c
struct Optimized {
    double f;    // 8 bytes at offset 0
    int i;       // 4 bytes at offset 8
    char c;      // 1 byte at offset 12
    char d;      // 1 byte at offset 13
    // 2 bytes padding
};
// Total size: 16 bytes (vs. 24 bytes)
```

The `__attribute__((packed))` directive (GCC/Clang) eliminates padding, placing members contiguously:

```c
struct Packed {
    char c;
    int i;       // Misaligned at offset 1
    char d;
    double f;    // Misaligned at offset 6
} __attribute__((packed));
// Total size: 14 bytes
```

Packed structures save space but incur performance penalties or faults when accessing misaligned members. [Inference: Packed structures suit serialization and hardware register mapping where layout must match external specifications, despite performance costs.]

### Array and Pointer Arithmetic

Arrays of aligned elements maintain alignment if the element size is a power of two. Array element access computes addresses as `base + (index * element_size)`. If base aligns to element_size and element_size is a power of two, all elements align naturally.

Pointer arithmetic preserves alignment relationships. Adding a multiple of N to an N-aligned pointer yields an N-aligned pointer. Incrementing a properly aligned pointer by sizeof(type) maintains alignment.

### Stack Alignment

Function call conventions mandate 16-byte stack alignment on AArch64. The stack pointer must be 16-byte aligned immediately before executing call instructions (BL, BLR). This alignment requirement:

- Enables efficient SIMD operations on stack data
- Simplifies compiler optimizations assuming aligned stack access
- Matches cache line boundaries on some implementations

Functions allocate stack space in multiples of 16 bytes. Local variables requiring stricter alignment (like 128-bit vectors) must consider their position within the frame:

```
    sub sp, sp, #32          // Allocate 32 bytes (maintaining alignment)
    // SP now 16-byte aligned
    // Can safely store 128-bit vectors at [sp, #0] and [sp, #16]
```

The compiler calculates offsets ensuring properly aligned local variables given the guaranteed 16-byte aligned frame base.

### Alignment Attributes and Directives

C11/C++11 provide standardized alignment control through `_Alignas` (C) and `alignas` (C++):

```c
alignas(64) int cache_aligned_array[16];  // 64-byte aligned
```

GCC/Clang support `__attribute__((aligned(N)))`:

```c
struct __attribute__((aligned(32))) AlignedStruct {
    int data[8];
};
```

Assembly directives specify alignment:

```asm
.align 4                    // Align to 2^4 = 16 bytes
.balign 64                  // Align to 64 bytes (byte alignment)
.p2align 6                  // Align to 2^6 = 64 bytes (power-of-2 alignment)
```

Dynamic memory allocators provide alignment-specifying interfaces:

```c
void *aligned_alloc(size_t alignment, size_t size);  // C11
void *memalign(size_t alignment, size_t size);       // POSIX
int posix_memalign(void **memptr, size_t alignment, size_t size);
```

These return pointers aligned to the specified boundary, enabling allocation of SIMD buffers or DMA-suitable memory.

### Over-Alignment

Over-aligned types specify alignment stricter than their size requires. SIMD vector types typically require 16-byte alignment despite being used with various sizes. DMA buffers may require cache line (64-byte) alignment to avoid coherency issues.

Compilers propagate alignment requirements through pointer types. Casting between pointer types with different alignment requirements may cause warnings or undefined behavior:

```c
char *p = malloc(64);                        // Typically 16-byte aligned
alignas(64) char buffer[64];                 // 64-byte aligned
int *q = (int *)buffer;                      // OK: 64-byte > 4-byte requirement

int *r = (int *)p;                           // Potentially problematic
// 'r' assumes 4-byte alignment, but compiler may assume 16-byte
```

[Inference: Casting between pointer types with different alignment assumptions requires care to avoid triggering undefined behavior or compiler mis-optimizations.]

