## Basic CRUD Operations


### INSERT Statements and Write Operations

Cassandra's INSERT statement creates new rows or overwrites existing rows with the same primary key. The operation follows an upsert semantic, meaning it functions as both insert and update depending on whether the primary key already exists in the table.

The basic INSERT syntax requires specifying all primary key columns and can include any subset of regular columns. Cassandra treats missing columns as null values rather than preserving existing values, distinguishing it from traditional UPDATE operations.

```cql
INSERT INTO users (user_id, name, email, created_at) 
VALUES (123, 'John Doe', 'john@example.com', '2024-01-15');
```

**Key points** about INSERT operations:

- Primary key columns must always be specified and cannot be null
- Missing regular columns are set to null, not preserved from existing rows
- Timestamps are automatically assigned by the coordinator node unless explicitly provided
- Write operations are atomic at the row level but not across multiple rows

### Write Path Architecture

Write operations follow a specific path through Cassandra's storage engine. The coordinator node first writes to the commit log for durability, then updates the memtable in memory. When memtables reach configured thresholds, they flush to immutable SSTables on disk.

The write path includes several consistency mechanisms. The commit log ensures write durability even during node failures, while memtables provide fast write performance. [Inference] The dual-write approach likely balances performance with data safety, though specific ordering guarantees depend on implementation details.

**Key points** of write path processing:

- Commit log writes occur before memtable updates for durability
- Multiple memtables may exist simultaneously during flush operations
- SSTable creation involves sorting and compacting data from memtables
- Write acknowledgments depend on configured consistency levels

### SELECT Statements and Read Operations

SELECT statements retrieve data from Cassandra tables using various filtering and ordering options. The most efficient queries specify the complete primary key, enabling single-partition reads that can be served directly from the appropriate nodes.

```cql
SELECT * FROM users WHERE user_id = 123;
SELECT name, email FROM users WHERE user_id = 123 AND created_at > '2024-01-01';
```

Cassandra supports several query patterns with different performance characteristics. Single-partition queries provide the best performance, while multi-partition queries require coordination across multiple nodes. Range queries within partitions can use clustering columns for efficient filtering.

### Read Path and Data Retrieval

Read operations involve complex processes to ensure data consistency and performance. The coordinator node may need to query multiple replicas, merge results, and perform read repair operations to maintain consistency.

**Key points** about read path mechanics:

- Bloom filters quickly eliminate SSTables that don't contain requested keys
- Multiple SSTables may contain different versions of the same row
- Memtables are checked first, followed by SSTables in reverse chronological order
- Read repair processes detect and fix inconsistencies between replicas

The read path includes several optimization mechanisms. Partition caches store frequently accessed rows in memory, while key caches maintain partition key locations. [Inference] These caching layers likely reduce disk I/O for hot data, though cache effectiveness depends on access patterns and configuration.

### UPDATE Operations and Row Modifications

UPDATE statements modify existing rows by changing specific column values while preserving others. Unlike INSERT operations, UPDATE only affects specified columns, leaving unmentioned columns unchanged.

```cql
UPDATE users SET email = 'newemail@example.com' WHERE user_id = 123;
UPDATE users SET email = 'updated@example.com', last_login = '2024-01-20' 
WHERE user_id = 123;
```

UPDATE operations internally function similarly to INSERT operations in Cassandra's storage model. The system creates new timestamped values for modified columns rather than modifying existing data in place. This immutable approach supports Cassandra's distributed architecture and eventual consistency model.

**Key points** about UPDATE behavior:

- Only specified columns are modified; others remain unchanged
- Primary key columns cannot be updated and must be specified in WHERE clauses
- Conditional updates using IF clauses provide lightweight transaction capabilities
- Update operations may trigger read-before-write for conditional logic

### DELETE Operations and Tombstone Management

DELETE operations remove rows or specific columns from tables. Cassandra implements deletes using tombstones, special markers that indicate deleted data, rather than immediately removing data from storage.

```cql
DELETE FROM users WHERE user_id = 123;
DELETE email FROM users WHERE user_id = 123;
DELETE FROM users WHERE user_id = 123 AND created_at = '2024-01-15';
```

Tombstone management presents unique challenges in distributed systems. Deleted data cannot be immediately removed because other replicas might not have received the delete operation. Tombstones persist until compaction processes can safely remove both the tombstone and any associated data.

**Key points** about delete operations:

- Tombstones mark deleted data but don't immediately reclaim storage space
- Range deletions create tombstones that can affect query performance
- Compaction processes eventually remove tombstones and associated data
- gc_grace_seconds setting controls tombstone retention duration

### Batch Operations and Coordination

BATCH statements group multiple write operations into a single atomic unit. Cassandra supports two types of batches: logged batches that provide atomicity guarantees and unlogged batches that offer better performance without atomicity.

```cql
BEGIN BATCH
  INSERT INTO users (user_id, name) VALUES (123, 'John');
  UPDATE users SET email = 'john@example.com' WHERE user_id = 123;
  DELETE FROM old_users WHERE user_id = 123;
APPLY BATCH;
```

Logged batches use the batch log to ensure atomicity across multiple partitions or tables. The coordinator writes batch information to multiple nodes before executing individual operations. [Inference] This coordination likely introduces latency overhead compared to individual operations, particularly for batches spanning multiple partitions.

### Batch Limitations and Performance Considerations

Batch operations have several limitations that affect their practical usage. Large batches can overwhelm coordinator nodes and create hotspots, while cross-partition batches require additional coordination overhead.

**Key points** about batch limitations:

- Batches should generally contain operations for the same partition key
- Large batches may cause coordinator node memory pressure
- Cross-partition logged batches require batch log coordination
- Unlogged batches provide better performance but no atomicity guarantees
- Maximum batch size limits prevent resource exhaustion

[Unverified] Specific batch size recommendations vary based on cluster configuration and workload characteristics. Best practices typically suggest keeping batches small and partition-focused to maintain optimal performance.

### TTL Functionality and Expiration

Time To Live (TTL) functionality enables automatic data expiration at the column or row level. TTL values specify seconds until expiration, after which data becomes eligible for removal during compaction processes.

```cql
INSERT INTO session_data (session_id, user_data) 
VALUES ('abc123', 'session_info') USING TTL 3600;

UPDATE users USING TTL 86400 SET last_seen = '2024-01-20' 
WHERE user_id = 123;
```

TTL implementation uses timestamps to track expiration times for individual columns. Expired data becomes invisible to queries immediately upon expiration, though physical removal occurs during compaction. This approach ensures consistent behavior across distributed replicas.

### TTL Mechanics and Expiration Handling

TTL expiration creates special tombstones that mark expired data for removal. These TTL tombstones follow similar lifecycle patterns to deletion tombstones, remaining in storage until compaction processes can safely remove them.

**Key points** about TTL behavior:

- TTL values are specified in seconds from the time of write
- Expired data becomes immediately invisible to queries
- TTL tombstones require compaction for physical data removal
- Different columns in the same row can have different TTL values
- TTL updates require rewriting affected columns with new timestamps

### Advanced CRUD Features

Cassandra provides several advanced features that enhance basic CRUD operations. Conditional operations using IF clauses enable lightweight transactions for specific use cases. JSON support allows storing and querying JSON documents within regular columns.

```cql
UPDATE users SET email = 'new@example.com' 
WHERE user_id = 123 IF email = 'old@example.com';

INSERT INTO user_profiles JSON '{"user_id": 123, "name": "John", "preferences": {"theme": "dark"}}';
```

Counter columns provide distributed counting capabilities with special increment and decrement operations. [Inference] Counter implementation likely requires additional coordination to maintain accuracy across replicas, though specific consistency guarantees may vary.

### Performance Optimization for CRUD Operations

CRUD operation performance depends heavily on data modeling decisions and query patterns. Single-partition operations provide optimal performance, while multi-partition queries require careful consideration of consistency levels and timeout settings.

**Key points** for CRUD optimization:

- Design partition keys to enable single-partition query patterns
- Use clustering columns to support efficient range queries within partitions
- Consider consistency level trade-offs between performance and data accuracy
- Monitor query patterns to identify opportunities for data model improvements
- Leverage prepared statements to reduce parsing overhead

### Error Handling and Operation Failures

CRUD operations may fail due to various conditions including network partitions, node failures, and consistency violations. Understanding failure modes helps design resilient applications that handle temporary outages appropriately.

[Inference] Retry logic and timeout configuration likely play important roles in handling transient failures, though specific strategies depend on application requirements and consistency guarantees.

**Conclusion**

Cassandra's CRUD operations provide the foundation for data manipulation in distributed environments. Understanding the underlying mechanisms including write paths, read repairs, tombstone management, and TTL functionality enables effective application design and troubleshooting. The combination of flexible consistency levels, batch operations, and automatic expiration creates a powerful toolkit for building scalable data-driven applications, though success requires careful attention to data modeling and query pattern optimization.

---

