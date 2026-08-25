## Redis Hashes


### HSET, HGET, HMSET, HMGET, HGETALL

Redis hashes are field-value mappings that provide efficient storage for objects and structured data. They offer superior memory efficiency compared to storing multiple string keys and enable atomic operations on object fields.

HSET stores a single field-value pair within a hash, creating the hash if it doesn't exist. The command returns 1 if the field is new and 0 if it updates an existing field. HGET retrieves the value of a specific field, returning nil if the field or hash doesn't exist.

HMSET allows setting multiple field-value pairs in a single command, significantly reducing network round-trips for object storage. HMGET retrieves multiple field values simultaneously, returning values in the same order as requested fields. HGETALL returns all field-value pairs as a flat array, alternating between field names and values.

**Key points**: Hash operations are atomic at the field level. HMSET and HMGET improve performance by batching operations. HGETALL should be used cautiously on large hashes as it returns all data at once. Hash fields are strings and follow the same rules as Redis keys.

**Example**:

```
HSET user:1000 name "John Doe"
HSET user:1000 email "john@example.com" age 30
HGET user:1000 name
HMSET user:2000 name "Jane Smith" email "jane@example.com" age 25
HMGET user:2000 name age
HGETALL user:1000
```

### HDEL, HEXISTS, HKEYS, HVALS

HDEL removes one or more fields from a hash, returning the number of fields that were successfully deleted. The hash itself is automatically removed when the last field is deleted. HEXISTS checks if a specific field exists within a hash, returning 1 if present and 0 if absent.

HKEYS returns all field names in a hash as an array, useful for iterating over hash structure or implementing field-based operations. HVALS returns all values in a hash without field names, typically used for bulk value processing or analysis.

**Key points**: HDEL supports multiple fields in a single command for efficient batch deletion. Empty hashes are automatically cleaned up by Redis. HKEYS and HVALS return arrays that may be large for extensive hashes, so consider memory implications in production environments.

**Example**:

```
HDEL user:1000 temporary_token session_id
HEXISTS user:1000 email
HKEYS user:1000
HVALS user:1000
```

### HINCRBY for Atomic Increments

HINCRBY performs atomic increment operations on hash fields containing numeric values. The command adds a specified integer value to the field's current value, creating the field with the increment value if it doesn't exist. HINCRBYFLOAT provides similar functionality for floating-point numbers.

These operations are particularly valuable for counters, statistics, and metrics stored within object structures. The atomicity ensures thread safety in concurrent environments without requiring external locking mechanisms.

**Key points**: HINCRBY only works with integer values and strings that can be parsed as integers. The operation is atomic and thread-safe. Non-existent fields are treated as having a value of 0. HINCRBYFLOAT handles decimal precision but may have floating-point arithmetic limitations.

**Example**:

```
HINCRBY user:1000 login_count 1
HINCRBY product:500 views 5
HINCRBY stats:daily page_views 100
HINCRBYFLOAT user:1000 account_balance 25.50
```

### Advanced Hash Operations

Hash operations extend beyond basic field manipulation to include sophisticated querying and manipulation capabilities. HSTRLEN returns the length of a field's value in bytes, useful for validation and size checking. HSETNX sets a field only if it doesn't exist, enabling conditional field creation.

HSCAN provides cursor-based iteration over hash fields, similar to SCAN for keys but operating within a single hash. This command supports pattern matching and count hints for efficient large hash traversal without blocking the server.

**Key points**: HSCAN is non-blocking and suitable for production use on large hashes. Pattern matching in HSCAN uses glob-style patterns. HSETNX prevents accidental field overwrites in concurrent environments.

**Example**:

```
HSTRLEN user:1000 biography
HSETNX user:1000 created_at "2024-01-15"
HSCAN user:1000 0 MATCH profile_* COUNT 10
```

### Memory Optimization and Encoding

Redis optimizes hash storage using different encodings based on size and content. Small hashes use ziplist encoding, which provides excellent memory efficiency by storing fields and values in a compact linear structure. Larger hashes automatically convert to standard hash table encoding for better performance.

Configuration parameters hash-max-ziplist-entries and hash-max-ziplist-value control the ziplist threshold. Understanding these settings helps optimize memory usage for specific use cases and data patterns.

**Key points**: Ziplist encoding significantly reduces memory usage for small hashes. Automatic encoding transitions are transparent to applications. Hash design should consider field count and value sizes for optimal memory efficiency.

### Use Cases: Object Storage

Hashes excel at storing structured objects like user profiles, product information, and configuration data. Each hash represents a single object with its fields mapping to object properties. This approach provides natural data organization and efficient field-level access.

Object storage patterns typically use descriptive hash keys like `user:1000` or `product:item:500` with fields representing object attributes. This design enables efficient querying of specific object properties without retrieving entire objects.

**Key points**: Hash-based object storage reduces memory overhead compared to multiple string keys. Field-level access eliminates unnecessary data transfer. Object versioning and schema evolution are manageable through field additions and removals.

**Example**:

```
HMSET user:1000 
  name "John Doe"
  email "john@example.com"
  age 30
  last_login "2024-07-09T10:30:00Z"
  preferences:theme "dark"
  preferences:language "en"
```

### Use Cases: User Profiles

User profile management represents a primary use case for Redis hashes. Each user profile becomes a hash containing demographic information, preferences, session data, and behavioral metrics. This structure enables efficient profile updates and personalization features.

Profile hashes support both static data (name, email) and dynamic data (last_login, session_count) within the same structure. Atomic increment operations facilitate real-time analytics and user engagement tracking.

**Key points**: Profile hashes enable efficient partial updates without loading entire profiles. Session management integrates naturally with profile data. Privacy and security considerations require careful field design and access control.

**Example**:

```
HMSET profile:user:1000
  username "johndoe"
  email "john@example.com"
  first_name "John"
  last_name "Doe"
  avatar_url "https://example.com/avatars/1000.jpg"
  created_at "2024-01-15T08:00:00Z"
  last_active "2024-07-09T10:30:00Z"
  login_count 42
  notification_preferences "email,push"
```

### Performance Considerations

Hash performance characteristics vary based on encoding, size, and access patterns. Ziplist encoding provides excellent memory efficiency but has O(N) complexity for field operations. Hash table encoding offers O(1) field access but uses more memory.

Field access patterns significantly impact performance. Frequent HGETALL operations on large hashes can cause performance issues, while targeted field access remains efficient. Designing hash structures around access patterns optimizes both memory usage and response times.

**Key points**: Small hashes benefit from ziplist encoding despite O(N) field access. Large hashes require hash table encoding for acceptable performance. Access patterns should drive hash design decisions rather than purely structural considerations.

**Conclusion**: Redis hashes provide efficient object storage with atomic field operations, memory optimization, and flexible querying capabilities. They excel in user profile management, configuration storage, and any scenario requiring structured data with field-level access.

**Next steps**: Implement hash-based user session management, explore hash expiration patterns using separate TTL keys, and investigate hash partitioning strategies for large-scale object storage systems.

---

