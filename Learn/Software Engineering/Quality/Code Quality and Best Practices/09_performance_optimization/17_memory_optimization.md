## Memory Optimization


### Data Locality and Cache Coherency

Modern CPU throughput is bottlenecked by memory latency rather than cycle speed. Optimization must prioritize spatial locality to maximize L1/L2 cache hits.

- **Structure of Arrays (SoA) vs. Array of Structures (AoS):**
    
    - **AoS (Standard Object Model):** `[ {x, y, z}, {x, y, z} ]`. causing cache pollution if only `x` is processed during an iteration. The CPU loads unnecessary `y` and `z` data into the cache line.
        
    - **SoA (Optimized):** `[x, x...], [y, y...], [z, z...]`. Prefer SoA for high-performance loops (SIMD operations). This ensures that a single cache line load contains only relevant data for the current operation.
        
- **Data Alignment and Padding:**
    
    - Compilers insert padding bytes to align data types to architecture boundaries (e.g., 64-bit alignment).
        
    - _Best Practice:_ Order struct/class members from largest to smallest (e.g., `long`, `int`, `bool`) to minimize padding waste. A poorly ordered struct can waste up to 50% of allocated memory on padding bytes.
        

### Heap Fragmentation and Custom Allocators

Frequent allocation and deallocation of varying-sized objects lead to heap fragmentation, causing allocation failures even when total free memory is sufficient.

- **Arena/Region Allocation:**
    
    - Implement Arena allocators for request-scoped or batch processing. Allocate a large contiguous block upfront and bump a pointer for individual objects. Deallocation is $O(1)$ (resetting the pointer) and creates zero fragmentation.
        
- **Object Pooling:**
    
    - Mandatory for high-churn objects (e.g., connections, network packets, game entities) in managed languages.
        
    - _Anti-pattern:_ Implementing a thread-safe pool with heavy locking (mutex). This shifts the bottleneck from memory allocation to thread contention. Use thread-local pools or lock-free data structures (e.g., concurrent bags) to mitigate.
        

### Managed Runtime Optimization (Java/C#/.NET)

In Garbage Collected (GC) environments, optimization focuses on reducing "GC Pressure"—the frequency and duration of collection cycles.

- **Large Object Heap (LOH):**
    
    - Objects exceeding a specific size threshold (e.g., 85kb in .NET) are allocated on the LOH, which is rarely compacted. Frequent allocation of large temporary buffers causes rapid address space exhaustion.
        
    - _Mitigation:_ Use `ArrayPool<T>` or persistent buffers to reuse large memory blocks.
        
- **Boxing and Unboxing:**
    
    - Implicit conversion of value types (primitives/structs) to reference types (objects) triggers heap allocation.
        
    - _Strict Rule:_ Eliminate boxing in hot paths. Use Generics with constraints to enforce value type handling without casting to `Object`.
        
- **String Interning & Deduplication:**
    
    - Strings are often the largest consumer of heap space. Use String Interning for repetitive low-cardinality strings (e.g., JSON keys, country codes) to store a single reference.
        

### Memory Leakage Patterns in Production

Memory leaks in modern architecture are rarely simple "forgotten frees" but rather subtle retention issues.

- **Observer Pattern Leaks:**
    
    - Subscribing to events without unsubscribing prevents the Garbage Collector from reclaiming the listener, as the publisher holds a strong reference.
        
    - _Solution:_ Implement `WeakReference` patterns for event listeners or enforce strict `IDisposable`/`AutoCloseable` contracts.
        
- **Closure/Lambda Capture:**
    
    - Lambdas implicitly capture variables from their enclosing scope. Capturing `this` or large context objects in a long-lived callback (e.g., a static timer) creates an invisible retention chain.
        

### Structural Efficiency and Compression

- **Flyweight Pattern:**
    
    - Externalize intrinsic state. Instead of creating 1,000 objects each containing distinct but identical data (e.g., font style, texture), share a single immutable instance across all consumers.
        
- **Bit Manipulation:**
    
    - Replace array-of-booleans with BitSets or BitFlags. A standard `bool` consumes 1 byte (8 bits); a BitSet consumes 1 bit per flag, achieving an 8x reduction in footprint.

---

