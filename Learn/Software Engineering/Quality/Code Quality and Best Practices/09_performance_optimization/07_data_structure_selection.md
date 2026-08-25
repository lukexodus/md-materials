## Data structure selection


### Memory Locality and CPU Cache Optimization

The theoretical Big O notation often fails to account for modern hardware architecture, specifically the latency hierarchy between CPU registers, L1/L2/L3 caches, and main memory. Selecting data structures must prioritize spatial locality to maximize cache line utilization.

- **Contiguous vs. Dispersed Allocation:** Prefer contiguous memory structures (e.g., `ArrayList`, `std::vector`, arrays) over pointer-linked structures (e.g., `LinkedList`, `std::list`). A linked list traversal invariably leads to pointer chasing, causing frequent cache misses and stalling the CPU pipeline. For small to medium datasets, an $O(n)$ linear scan on an array often outperforms an $O(\log n)$ lookup on a binary search tree due to prefetching and cache coherency.
    
- **Struct of Arrays (SoA) vs. Array of Structs (AoS):** In high-performance computing and game engine development, use SoA layouts. SoA maximizes SIMD (Single Instruction, Multiple Data) throughput by grouping identical fields of multiple entities contiguously, allowing vector registers to process multiple data points in a single cycle.
    

### Concurrency and Lock-Free Architectures

Standard collections are rarely suitable for high-concurrency environments due to global locking mechanisms that induce contention and context switching.

- **Lock-Stripping:** Utilize structures like `ConcurrentHashMap` which employ lock stripping (partitioning the map into segments). This allows multiple threads to write to different segments simultaneously without blocking, converting $O(1)$ access into a scalable operation under load.
    
- **Copy-On-Write (COW):** For read-heavy, write-rare scenarios (e.g., configuration caches, event listener lists), employ `CopyOnWriteArrayList`. This eliminates locking for readers entirely by creating a fresh copy of the backing array upon modification.
    
- **Wait-Free/Lock-Free Queues:** In low-latency trading or real-time telemetry, traditional blocking queues introduce unacceptable jitter. Implement ring buffers (e.g., LMAX Disruptor pattern) or non-blocking queues using Compare-And-Swap (CAS) primitives to ensure bounded latency and prevent priority inversion.
    

### Probabilistic Data Structures for Massive Scale

When strict accuracy is negotiable, and memory constraints are tight, deterministic structures should be replaced with probabilistic alternatives.

- **Bloom Filters:** Use for set membership testing in distributed databases or cache avoidance layers to prevent "cache penetration." They offer $O(1)$ time complexity and constant space overhead, at the cost of false positives (but no false negatives).
    
- **HyperLogLog:** Employ for cardinality estimation of massive streams (e.g., counting unique IP addresses). This structure achieves constant space complexity regardless of input size, typically with an error rate below 1%.
    
- **Count-Min Sketch:** Suitable for frequency estimation in streams where storing a full frequency map is prohibitive.
    

### Persistent and Immutable Data Structures

In functional programming and distributed systems requiring snapshot isolation, mutable structures introduce side-effect risks and race conditions.

- **Structural Sharing:** Use persistent data structures (e.g., Hash Array Mapped Tries - HAMT). When a "modification" occurs, path copying is used to create a new version of the root while sharing the sub-trees that did not change. This minimizes memory churn compared to full cloning and enables $O(1)$ historic access.
    
- **Log-Structured Merge-Trees (LSM):** For write-heavy workloads (e.g., NoSQL databases), traditional B-Trees suffer from random write I/O. LSM trees buffer writes in memory and flush them sequentially to disk as immutable Sorted String Tables (SSTables), optimizing for write throughput and SSD endurance.
    

### Anti-Patterns in Selection

- **Primitive Obsession:** Representing domain concepts with generic collections (e.g., `Map<String, Object>` for a User entity). This bypasses type safety, hinders compiler optimization, and obscures domain logic.
    
- **Premature Generalization:** Defaulting to `LinkedList` for "frequent insertions" without profiling. Modern array copying `System.arraycopy` / `memmove` is heavily optimized; the overhead of shifting elements in an array is often negligible compared to the allocation and GC overhead of list nodes until the dataset size is substantial.
    
- **Ignoring Key Distribution:** Using standard HashMaps without analyzing key distribution. Poor hash functions lead to bucket collisions, degrading performance to $O(n)$. In security-sensitive contexts, this exposes the system to HashDoS attacks. Use cryptographically secure hash functions or randomized seeding (e.g., SipHash).

---

