## Redis Bitmaps


### Overview

Redis Bitmaps are not a separate data type but a set of bit-oriented operations on Redis Strings. They provide an extremely memory-efficient way to store and manipulate binary information, where each bit represents a boolean state. Bitmaps can theoretically hold up to 2^32 bits (512MB) and offer powerful bitwise operations for analytics and flag management.

### Core Operations

### Setting and Getting Bits

SETBIT sets individual bits at specified positions, returning the previous value. GETBIT retrieves the value of a bit at a given position. Both operations use zero-based indexing and automatically expand the bitmap as needed.

```redis
SETBIT user:visits:20240101 123 1    # Set bit 123 to 1
GETBIT user:visits:20240101 123      # Returns 1
SETBIT user:visits:20240101 456 0    # Set bit 456 to 0
```

### Counting Operations

BITCOUNT returns the number of set bits (bits with value 1) in the entire bitmap or within a specified byte range. This operation is highly optimized and uses population count algorithms for efficient execution.

```redis
BITCOUNT user:visits:20240101           # Count all set bits
BITCOUNT user:visits:20240101 0 10      # Count bits in bytes 0-10
```

### Bitwise Operations

BITOP performs bitwise operations (AND, OR, XOR, NOT) between multiple bitmaps, storing the result in a destination key. This enables complex analytical queries across multiple datasets.

```redis
BITOP AND result daily:visits weekly:active    # Users active both daily and weekly
BITOP OR combined day1:visits day2:visits      # Users active on either day
BITOP XOR exclusive set1 set2                  # Users in one set but not both
BITOP NOT inverted original                    # Flip all bits
```

### Advanced Bitmap Operations

### Position Finding

BITPOS finds the position of the first bit set to a specified value (0 or 1), optionally within a byte range. This operation is useful for finding the first available slot or detecting patterns.

```redis
BITPOS user:flags 1        # Find first set bit
BITPOS user:flags 0 2 5    # Find first unset bit in bytes 2-5
```

### Field Operations

BITFIELD allows atomic manipulation of multiple bit fields within a single bitmap, supporting various integer types and overflow behaviors. This enables packed data structures and atomic counter operations.

```redis
BITFIELD stats SET u8 0 255 GET u16 8 INCRBY u32 16 1
```

### Real-world Applications

### User Analytics and Tracking

Bitmaps excel at tracking user behavior across time periods. Each user ID corresponds to a bit position, enabling efficient daily, weekly, or monthly activity tracking.

**Key points**: Each bit represents user activity, different bitmaps for different time periods, bitwise operations for complex queries.

**Example**: Daily active users tracking where bit position represents user ID and value indicates activity:

```redis
SETBIT users:active:20240101 12345 1    # User 12345 was active
SETBIT users:active:20240101 67890 1    # User 67890 was active
BITCOUNT users:active:20240101          # Count daily active users
```

### Feature Flags and Permissions

Bitmaps provide efficient storage for feature flags and user permissions where each bit position represents a specific feature or permission level.

**Key points**: Compact permission storage, fast permission checks, bulk permission updates.

**Example**: User permissions system where each bit represents a different permission:

```redis
SETBIT user:permissions:123 0 1    # Read permission
SETBIT user:permissions:123 1 1    # Write permission  
SETBIT user:permissions:123 2 0    # Admin permission
GETBIT user:permissions:123 1      # Check write permission
```

### A/B Testing and Experiments

Bitmaps efficiently track user participation in experiments and A/B tests, allowing for quick cohort analysis and experiment result calculations.

**Key points**: User assignment to test groups, overlap analysis between experiments, performance tracking.

**Example**: A/B test tracking where users are assigned to different experimental groups:

```redis
SETBIT experiment:group_a 12345 1      # User in group A
SETBIT experiment:group_b 67890 1      # User in group B
BITOP AND overlap experiment:group_a experiment:group_b
```

### Real-time Analytics

Bitmaps enable real-time analytics for large-scale applications, tracking events, user sessions, and system states with minimal memory overhead.

**Key points**: High-frequency event tracking, time-based analytics, efficient aggregation.

### Memory Efficiency Considerations

### Space Optimization

Bitmaps are extremely space-efficient for sparse data. Each bit requires only 1 bit of storage, making them ideal for scenarios with large ID spaces but relatively few active entities.

**Key points**: 1 bit per boolean value, automatic string compression, efficient for sparse datasets.

**Example**: Tracking 1 million users requires only 125KB of memory, compared to potentially megabytes for other data structures.

### Density Thresholds

Bitmaps become memory-efficient when the data density justifies bit-level storage. For very sparse data (less than 1% density), other data structures might be more appropriate.

**Key points**: Calculate memory usage based on maximum ID, consider Set data type for very sparse data, monitor actual vs. theoretical memory usage.

### Memory Usage Patterns

Redis automatically handles memory allocation for bitmaps, expanding as needed. The memory usage is determined by the highest bit position set, not the number of set bits.

```redis
SETBIT sparse 1000000 1    # Allocates ~125KB even for single bit
```

### Optimization Strategies

### Bit Position Management

Design bit position schemes to minimize memory waste. Sequential or clustered user IDs are more memory-efficient than random sparse IDs.

**Key points**: Use sequential IDs when possible, implement ID mapping for sparse ranges, consider bitmap segmentation for very large ranges.

### Operational Efficiency

Leverage Redis's optimized BITCOUNT implementation and use byte-aligned operations when possible for better performance.

**Key points**: BITCOUNT is highly optimized, byte-aligned ranges improve performance, combine operations to reduce round trips.

### Time-based Partitioning

Partition bitmaps by time periods to manage memory usage and enable efficient data retention policies.

**Key points**: Daily/weekly/monthly partitions, automatic cleanup of old data, time-series analysis capabilities.

### Performance Characteristics

### Time Complexity

SETBIT and GETBIT operations execute in O(1) time. BITCOUNT runs in O(N) time where N is the number of bytes, but uses optimized algorithms for fast execution. BITOP complexity depends on the size of the largest bitmap involved.

### Scalability Considerations

Bitmaps scale well for read-heavy workloads and support efficient bulk operations. Consider bitmap sharding for extremely large datasets or high-concurrency scenarios.

### Memory vs. Performance Trade-offs

While bitmaps offer excellent memory efficiency, they may not be optimal for very sparse data or scenarios requiring frequent range queries on non-bit-aligned boundaries.

**Conclusion**: Redis Bitmaps provide unparalleled memory efficiency for boolean data storage and manipulation, making them ideal for user analytics, feature flags, and real-time tracking systems where space optimization and fast bitwise operations are crucial.

---

