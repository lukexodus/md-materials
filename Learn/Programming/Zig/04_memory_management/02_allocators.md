## Allocators


### Allocator Interface Design

#### Core Allocator Interface

Zig's allocator system is built around the `std.mem.Allocator` interface, which provides a uniform API for memory management across different allocation strategies. The interface defines a function pointer structure that all allocators must implement:

```zig
pub const Allocator = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        alloc: *const fn (ctx: *anyopaque, len: usize, ptr_align: u8, ret_addr: usize) ?[*]u8,
        resize: *const fn (ctx: *anyopaque, buf: []u8, buf_align: u8, new_len: usize, ret_addr: usize) bool,
        free: *const fn (ctx: *anyopaque, buf: []u8, buf_align: u8, ret_addr: usize) void,
    };
};
```

#### Primary Allocation Methods

**alloc() Function:** The fundamental allocation method that requests memory of a specific size and alignment:

- Returns optional pointer to allocated memory or null on failure
- Accepts length in bytes and alignment requirements
- Includes return address for debugging and tracking

**resize() Function:** Attempts to resize existing allocated memory in-place:

- Returns boolean indicating success or failure
- More efficient than alloc/copy/free cycle when successful
- Not all allocators support meaningful resize operations

**free() Function:** Deallocates previously allocated memory:

- Accepts the exact slice that was returned by alloc()
- Must match original alignment requirements
- Some allocators may ignore free operations (like arena allocators)

#### High-Level Convenience Methods

**create() and destroy():** Type-safe allocation for single objects:

```zig
const ptr = allocator.create(MyStruct);
defer allocator.destroy(ptr);
```

**alloc() and free() for Slices:** Type-safe slice allocation:

```zig
const slice = allocator.alloc(u32, 100);
defer allocator.free(slice);
```

**dupe() Method:** Creates a copy of existing data:

```zig
const copy = allocator.dupe(u8, original_slice);
defer allocator.free(copy);
```

### Standard Allocators

#### General Purpose Allocator (GPA)

The `std.heap.GeneralPurposeAllocator` is Zig's default allocator for general use:

- Thread-safe by default
- Includes extensive debugging features in debug builds
- Detects memory leaks, double-free errors, and use-after-free
- Uses system malloc/free underneath but adds safety checks

**Usage Example:**

```zig
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
defer _ = gpa.deinit();
const allocator = gpa.allocator();
```

**Debug Features:**

- Memory leak detection with stack trace reporting
- Double-free detection
- Use-after-free detection through poisoning freed memory
- Buffer overflow detection with guard pages [Inference - based on typical GPA implementation patterns]

#### Page Allocator

The `std.heap.page_allocator` allocates memory directly from the operating system:

- Allocates entire memory pages (typically 4KB minimum)
- Minimal overhead but wasteful for small allocations
- Thread-safe without additional synchronization
- Suitable for large allocations or when interfacing with system APIs

**Characteristics:**

- Always allocates page-aligned memory
- Cannot resize allocations
- Free operations return memory directly to the OS
- No fragmentation tracking or coalescing

#### C Allocator

The `std.heap.c_allocator` provides direct access to the system's malloc/free:

- Thin wrapper around standard C library functions
- Minimal overhead and good performance
- No additional safety checks or debugging features
- Suitable for interfacing with C libraries

#### Fixed Buffer Allocator

The `std.heap.FixedBufferAllocator` operates within a pre-allocated buffer:

- Linear allocation within a fixed memory region
- Cannot free individual allocations
- Extremely fast allocation with no system calls
- Useful for temporary allocations or embedded systems

**Usage Pattern:**

```zig
var buffer: [1024]u8 = undefined;
var fba = std.heap.FixedBufferAllocator.init(&buffer);
const allocator = fba.allocator();
```

### Custom Allocator Implementation

#### Implementing the Allocator Interface

Custom allocators must implement the three core vtable functions. Here's a basic structure:

```zig
const CustomAllocator = struct {
    // Allocator state/data
    
    fn alloc(ctx: *anyopaque, len: usize, ptr_align: u8, ret_addr: usize) ?[*]u8 {
        // Implementation
    }
    
    fn resize(ctx: *anyopaque, buf: []u8, buf_align: u8, new_len: usize, ret_addr: usize) bool {
        // Implementation
    }
    
    fn free(ctx: *anyopaque, buf: []u8, buf_align: u8, ret_addr: usize) void {
        // Implementation
    }
    
    pub fn allocator(self: *CustomAllocator) std.mem.Allocator {
        return std.mem.Allocator{
            .ptr = self,
            .vtable = &.{
                .alloc = alloc,
                .resize = resize,
                .free = free,
            },
        };
    }
};
```

#### Alignment Handling

Custom allocators must properly handle alignment requirements:

- Calculate aligned size using `std.mem.alignForward()`
- Ensure returned pointers meet alignment constraints
- Account for alignment padding in size calculations
- Store original allocation size for proper freeing

#### Error Handling Patterns

**Allocation Failure:** Return `null` from alloc() function when memory cannot be allocated:

- Out of memory conditions
- Alignment requirements cannot be met
- Allocator-specific constraints violated

**Debugging Integration:** Utilize the `ret_addr` parameter for debugging:

- Track allocation sites for leak detection
- Provide meaningful error messages with stack traces
- Integrate with Zig's built-in debugging infrastructure

### Arena Allocators

#### Arena Allocator Concept

Arena allocators allocate memory in large chunks and sub-allocate from these chunks linearly. The key characteristic is that individual allocations cannot be freed - only the entire arena can be reset or destroyed.

#### Standard Arena Allocator

The `std.heap.ArenaAllocator` provides arena allocation functionality:

- Wraps another allocator (typically GPA) for chunk allocation
- Extremely fast allocation with simple pointer arithmetic
- No fragmentation within arena chunks
- Perfect for temporary allocations with known lifetime

**Usage Pattern:**

```zig
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
defer arena.deinit();
const allocator = arena.allocator();

// Many allocations...
// All freed with arena.deinit()
```

#### Arena Allocation Benefits

**Performance Advantages:**

- O(1) allocation time with minimal bookkeeping
- No need to track individual allocations for freeing
- Excellent cache locality for sequential allocations
- Reduced system call overhead through chunk pre-allocation

**Use Cases:**

- Temporary data structures during function execution
- Parser and compiler implementations
- Request/response processing in servers
- Any scenario with clear allocation lifetime boundaries

#### Arena Reset Functionality

Some arena implementations support reset operations:

- Rewind allocation pointer to beginning
- Reuse existing chunks without system calls
- Maintain chunk allocations for future use
- Useful for iterative processing with similar memory patterns

### Memory Pool Patterns

#### Fixed-Size Pool Allocator

Pool allocators manage a collection of fixed-size blocks:

- Pre-allocate many blocks of identical size
- Maintain free list of available blocks
- O(1) allocation and deallocation
- Eliminate fragmentation for uniform allocations

**Implementation Strategy:**

```zig
const PoolAllocator = struct {
    free_list: ?*Block,
    chunk_data: []u8,
    block_size: usize,
    
    const Block = struct {
        next: ?*Block,
    };
};
```

#### Multi-Size Pool Systems

Advanced pool systems manage multiple pool sizes:

- Segregated pools for different allocation sizes
- Size classes (e.g., 8, 16, 32, 64, 128 bytes)
- Route allocations to appropriate size pool
- Combine with backup allocator for unusual sizes

#### Pool Allocation Benefits

**Performance Characteristics:**

- Predictable allocation/deallocation time
- Reduced memory fragmentation
- Better cache behavior through spatial locality
- Lower system call overhead

**Memory Efficiency:**

- No per-allocation metadata overhead
- Predictable memory usage patterns
- Effective utilization for known allocation patterns
- Reduced external fragmentation

#### Pool Implementation Considerations

**Free List Management:**

- Intrusive free lists store next pointers in freed blocks
- Non-intrusive lists require separate metadata storage
- Stack-based (LIFO) vs queue-based (FIFO) free list ordering
- Thread-safety considerations for concurrent access

**Chunk Growth Strategies:**

- Static pools with fixed total capacity
- Dynamic pools that grow by allocating new chunks
- Exponential vs linear growth policies
- Chunk size optimization for memory efficiency

**Alignment and Padding:**

- Ensure all blocks meet maximum alignment requirements
- Account for alignment padding in block size calculations
- Consider cache line alignment for performance-critical applications

**Key Points**

- Zig's allocator interface provides uniform memory management across different strategies
- Standard allocators cover most use cases from debugging (GPA) to performance (page allocator)
- Custom allocators enable specialized memory management for specific application needs
- Arena allocators excel for temporary allocations with clear lifetime boundaries
- Pool allocators eliminate fragmentation and provide predictable performance for uniform allocations

**Related Topics**: Thread-safe allocator design, allocator composition patterns, memory debugging techniques, allocator performance profiling, and integration with garbage collection strategies would provide deeper insight into advanced memory management in Zig.

---

