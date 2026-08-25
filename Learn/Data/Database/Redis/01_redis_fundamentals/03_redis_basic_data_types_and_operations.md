## Redis Basic Data Types and Operations


### String Operations

Redis strings are the most basic data type and can store text, numbers, or binary data up to 512MB. String operations form the foundation of Redis functionality and are highly optimized for performance.

The GET command retrieves the value of a key, returning nil if the key doesn't exist. SET stores a value at a specified key, with optional parameters for expiration and conditional setting. The INCR and DECR commands perform atomic increment and decrement operations on numeric strings, making them ideal for counters and metrics. APPEND concatenates a value to an existing string, extending its length efficiently.

**Key points**: String operations are atomic, thread-safe, and support both text and binary data. Numeric operations automatically convert strings to integers, and all string commands have O(1) time complexity for basic operations.

**Example**:

```
SET user:1000:name "John Doe"
GET user:1000:name
INCR page:views:homepage
DECR inventory:item:123
APPEND log:2024 " - New entry added"
```

### Understanding Redis Keys and Expiration

Redis keys are binary-safe strings that serve as unique identifiers for data. Key naming conventions typically use colons as separators to create hierarchical structures, though this is purely conventional. Keys can contain any binary sequence except empty strings.

Expiration mechanisms allow automatic key deletion after specified time periods. TTL (Time To Live) can be set in seconds using EXPIRE or in milliseconds using PEXPIRE. Keys with expiration are stored in a separate dictionary and cleaned up through both active and passive expiration processes.

**Key points**: Keys are case-sensitive, support UTF-8 encoding, and have no inherent size limit beyond available memory. Expiration is precise and doesn't significantly impact performance. Keys without expiration persist indefinitely until manually deleted.

**Example**:

```
SET session:abc123 "user_data"
EXPIRE session:abc123 3600
SET cache:user:1000 "cached_data" EX 1800
PEXPIRE temporary:data 5000
```

### Basic Commands: EXISTS, DEL, EXPIRE, TTL, KEYS, SCAN

EXISTS checks for key existence, returning 1 if the key exists and 0 if it doesn't. Multiple keys can be checked simultaneously, with the command returning the count of existing keys. DEL removes one or more keys immediately, returning the number of keys that were successfully deleted.

EXPIRE sets a timeout on existing keys, while TTL returns the remaining time to live in seconds. PTTL provides millisecond precision for TTL queries. Both commands return -1 for keys without expiration and -2 for non-existent keys.

KEYS pattern matching uses glob-style patterns to find keys, but should be avoided in production due to its O(N) complexity that can block the server. SCAN provides a cursor-based iterator for key traversal, offering better performance and non-blocking behavior for large datasets.

**Key points**: EXISTS and DEL support multiple keys in a single command. TTL commands distinguish between non-existent keys and keys without expiration. SCAN is always preferable to KEYS for production applications due to its non-blocking nature and consistent performance.

**Example**:

```
EXISTS user:1000 user:2000 user:3000
DEL temporary:data1 temporary:data2
EXPIRE user:session:abc123 7200
TTL user:session:abc123
SCAN 0 MATCH user:* COUNT 100
```

### Advanced String Operations

String operations extend beyond basic GET/SET to include sophisticated manipulation commands. GETRANGE extracts substrings by byte position, while SETRANGE modifies specific portions of existing strings. STRLEN returns the byte length of string values.

Bit-level operations enable efficient storage and manipulation of binary data. SETBIT and GETBIT operate on individual bits, BITCOUNT counts set bits, and BITOP performs bitwise operations between multiple keys. These operations are particularly useful for analytics, bloom filters, and compact data structures.

**Key points**: Range operations use zero-based indexing and support negative indices. Bit operations treat strings as bit arrays and are highly memory-efficient. String modifications are atomic and preserve existing expiration settings.

### Atomic Operations and Patterns

Redis provides several atomic operations that enable safe concurrent access patterns. SETNX sets a key only if it doesn't exist, useful for implementing locks and preventing race conditions. GETSET atomically sets a new value and returns the old value, enabling atomic swaps.

SET command extensions include NX (not exists), XX (exists), EX (expire seconds), and PX (expire milliseconds) options. These combinations enable sophisticated conditional operations in a single atomic command.

**Key points**: All Redis operations are atomic within a single command. Atomic operations prevent race conditions in multi-client environments. Conditional operations reduce network round-trips and improve performance.

### Memory and Performance Considerations

String values in Redis are stored with additional metadata including encoding information and reference counting. Small integers are stored as actual integers rather than strings, and short strings may be stored inline with the key structure for improved memory efficiency.

Redis automatically optimizes string storage based on content and size. Numeric strings use integer encoding when possible, and longer strings may be compressed or stored in specialized formats. Understanding these optimizations helps in designing efficient data structures.

**Key points**: Redis uses different encodings for strings based on content and size. Memory usage includes overhead for metadata and structure. Proper key design and value sizes significantly impact memory efficiency and performance.

**Conclusion**: Redis string operations provide a robust foundation for caching, counters, sessions, and general data storage. Understanding key expiration, atomic operations, and performance characteristics enables effective Redis utilization in production applications.

**Next steps**: Practice combining string operations with expiration policies, explore advanced bit operations for analytics use cases, and learn about Redis transactions for multi-command atomic operations.

---

