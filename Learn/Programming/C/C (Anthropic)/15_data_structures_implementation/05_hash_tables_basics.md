## Hash Tables Basics


Hash tables (hash maps) store key-value pairs using hash functions to compute array indices for efficient data access.

**Core Components:**

- Hash function: Converts keys to array indices
- Bucket array: Storage locations for key-value pairs
- Collision resolution mechanism
- Load factor: Ratio of stored elements to array size

**Hash Function Properties:**

- Deterministic: Same input always produces same output
- Uniform distribution: Spreads keys evenly across array
- Fast computation: Efficient to calculate
- Avalanche effect: Small input changes cause large output changes [Inference - desired property]

**Collision Resolution:**

- Separate Chaining: Use linked lists at each bucket
- Open Addressing: Find alternative locations within array
    - Linear Probing: Check next sequential positions
    - Quadratic Probing: Use quadratic function for position calculation
    - Double Hashing: Use second hash function for step size

**Dynamic Resizing:**

- Rehashing when load factor exceeds threshold
- Typically resize when load factor > 0.75 [Inference - common practice]
- Creates new larger array and rehashes all elements

**Time Complexity:**

- Average case: O(1) for search, insertion, deletion
- Worst case: O(n) when many collisions occur
- Amortized: O(1) accounting for occasional resizing

**Space Complexity:** O(n) for n key-value pairs

**Load Factor Impact:**

- Low load factor: More memory usage, fewer collisions
- High load factor: Memory efficient, more collisions
- Optimal range: 0.5 to 0.75 [Inference - commonly recommended]

**Applications:**

- Database indexing
- Caching systems
- Symbol tables in compilers
- Associative arrays in programming languages
- Set data structure implementation

**Implementation Considerations:**

- Choice of hash function affects performance
- Collision resolution strategy impacts memory and speed trade-offs
- Dynamic resizing maintains performance as data grows
- Key equality comparison needed for collision handling

These data structures form the foundation for more complex structures and algorithms. Understanding their implementation details, performance characteristics, and appropriate use cases is essential for efficient programming and system design.

---

