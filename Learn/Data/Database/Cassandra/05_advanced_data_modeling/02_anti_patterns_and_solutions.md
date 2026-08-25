## Anti-patterns and Solutions


### Common Modeling Mistakes

Many Cassandra modeling failures stem from applying relational database principles without considering Cassandra's distributed architecture. The most frequent mistake involves designing normalized schemas and expecting efficient joins, which Cassandra doesn't support natively.

Another critical error involves ignoring query patterns during design. Developers often create "entity-centric" tables thinking they can adapt queries later, only to discover that their primary queries require expensive operations like ALLOW FILTERING or multiple round trips.

**Key points:**

- Avoid normalizing data across multiple tables requiring joins
- Don't design tables without knowing specific query requirements
- Never rely on secondary indexes as primary access patterns
- Avoid using composite partition keys without understanding distribution implications

**Example:**

```sql
-- Anti-pattern: Normalized design requiring joins
CREATE TABLE users (id uuid PRIMARY KEY, name text, email text);
CREATE TABLE orders (id uuid PRIMARY KEY, user_id uuid, amount decimal);

-- Solution: Denormalized query-specific tables
CREATE TABLE orders_by_user (
    user_id uuid,
    order_date timestamp,
    order_id uuid,
    user_name text,
    amount decimal,
    PRIMARY KEY (user_id, order_date, order_id)
);
```

Attempting to model one-to-many relationships using collections without considering size limits represents another common mistake. Collections in Cassandra have practical limits and can cause performance issues when they grow large.

**Key points:**

- Collections should remain small (typically under 64KB)
- Large collections create read and write performance problems
- Consider separate tables for large one-to-many relationships
- [Unverified] Collection operations may require reading entire collection

### Secondary Index Anti-patterns

Secondary indexes in Cassandra are often misunderstood and misused, leading to significant performance problems. The primary anti-pattern involves treating secondary indexes like relational database indexes, expecting them to provide efficient query performance for any column.

Cassandra's secondary indexes are local to each node and require querying all nodes in the cluster for global searches. This creates expensive operations that don't scale well with cluster size. Additionally, secondary indexes on high-cardinality columns create inefficient queries that may timeout or consume excessive resources.

**Key points:**

- Secondary indexes require querying all cluster nodes
- High-cardinality columns make secondary indexes inefficient
- Low-cardinality columns with uneven distribution create hot spots
- Secondary indexes should not be primary query access patterns

**Example:**

```sql
-- Anti-pattern: Secondary index on high-cardinality column
CREATE TABLE users (id uuid PRIMARY KEY, email text, name text);
CREATE INDEX ON users (email);
SELECT * FROM users WHERE email = 'user@example.com';

-- Solution: Dedicated table for email lookups
CREATE TABLE users_by_email (
    email text PRIMARY KEY,
    user_id uuid,
    name text
);
```

Another anti-pattern involves creating secondary indexes without considering query patterns that combine indexed and non-indexed columns. These queries often require ALLOW FILTERING, which defeats the purpose of the index.

**Key points:**

- Combining indexed and non-indexed columns in queries is inefficient
- ALLOW FILTERING indicates potential performance problems
- Design tables specifically for complex query patterns
- [Inference] Secondary indexes work best for simple, single-column equality queries

### Batch Operation Pitfalls

Cassandra batches serve different purposes than relational database transactions, primarily providing atomicity guarantees rather than performance improvements. Misusing batches can actually degrade performance and create cluster problems.

The most common anti-pattern involves using batches to improve write performance by grouping unrelated writes. Large batches or batches spanning multiple partitions create coordination overhead and can cause timeouts or memory pressure on coordinator nodes.

**Key points:**

- Batches don't improve performance for unrelated writes
- Large batches create memory pressure and potential timeouts
- Cross-partition batches require coordination overhead
- Use batches only for maintaining consistency across related data

**Example:**

```sql
-- Anti-pattern: Batch for performance with unrelated data
BEGIN BATCH
    INSERT INTO users (id, name) VALUES (uuid(), 'Alice');
    INSERT INTO products (id, name) VALUES (uuid(), 'Widget');
    INSERT INTO orders (id, amount) VALUES (uuid(), 100.00);
APPLY BATCH;

-- Solution: Individual writes for unrelated data
INSERT INTO users (id, name) VALUES (uuid(), 'Alice');
INSERT INTO products (id, name) VALUES (uuid(), 'Widget');
INSERT INTO orders (id, amount) VALUES (uuid(), 100.00);
```

Another pitfall involves using logged batches when atomicity isn't required. Logged batches have additional overhead for maintaining the batch log, which impacts performance when atomicity guarantees aren't necessary.

**Key points:**

- Use UNLOGGED batches when atomicity isn't required
- Logged batches have performance overhead for consistency guarantees
- Consider whether atomicity is actually needed for your use case
- [Unverified] Batch size limits may vary between Cassandra versions

### Hot Partition Mitigation

Hot partitions create performance bottlenecks that can severely impact cluster performance. Mitigation strategies depend on identifying the root cause: poor partition key design, temporal access patterns, or data skew.

Partition key salting involves adding a calculated suffix to partition keys to distribute hot partitions across multiple physical partitions. This technique requires careful implementation to ensure query patterns can still access the distributed data efficiently.

**Key points:**

- Add calculated hash suffixes to distribute hot partitions
- Implement bucketing strategies for time-based hot partitions
- Monitor partition access patterns to identify hotspots early
- Consider application-level sharding for extremely hot data

**Example:**

```sql
-- Anti-pattern: Hot partition on popular content
CREATE TABLE post_comments (
    post_id uuid,
    timestamp timestamp,
    comment_id uuid,
    content text,
    PRIMARY KEY (post_id, timestamp, comment_id)
);

-- Solution: Salted partition key
CREATE TABLE post_comments (
    post_id uuid,
    bucket int,
    timestamp timestamp,
    comment_id uuid,
    content text,
    PRIMARY KEY ((post_id, bucket), timestamp, comment_id)
);
```

Time-based bucketing addresses temporal hot partitions by distributing current activity across multiple partitions. This approach requires application logic to query multiple buckets but provides better load distribution.

**Key points:**

- Use time-based bucketing for temporal hotspots
- Balance bucket count with query complexity
- Implement consistent hashing for bucket selection
- [Inference] Applications must query multiple buckets to get complete results

### Large Partition Handling

Large partitions create multiple problems: increased read latency, memory pressure during reads, longer repair times, and potential timeout issues. Handling requires both prevention strategies and remediation techniques for existing large partitions.

Partition splitting involves redesigning the schema to break large partitions into smaller ones, typically by adding additional elements to the partition key. This process often requires data migration and application changes to handle the new query patterns.

**Key points:**

- Redesign partition keys to limit partition size growth
- Implement data archiving strategies for time-series data
- Use TTL settings to automatically expire old data
- Monitor partition sizes proactively to prevent problems

**Example:**

```sql
-- Problem: Unbounded partition growth
CREATE TABLE user_events (
    user_id uuid,
    timestamp timestamp,
    event_type text,
    data text,
    PRIMARY KEY (user_id, timestamp)
);

-- Solution: Time-bucketed partitions with TTL
CREATE TABLE user_events (
    user_id uuid,
    month text,
    timestamp timestamp,
    event_type text,
    data text,
    PRIMARY KEY ((user_id, month), timestamp)
) WITH default_time_to_live = 7776000; -- 90 days
```

Data archiving strategies involve moving old data to separate tables or external storage systems. This approach maintains query performance on current data while preserving historical information when needed.

**Key points:**

- Implement automated archiving for time-series data
- Use separate tables or external systems for historical data
- Consider compression for archived data
- [Speculation] Cold storage solutions may be more cost-effective for archived data

**Output considerations:** Avoiding these anti-patterns requires understanding Cassandra's distributed architecture and designing schemas that work with rather than against its strengths. Regular monitoring and performance testing help identify problems before they impact production systems.

**Related topics to consider:**

- Monitoring and alerting strategies for partition health
- Data migration techniques for schema changes
- Consistency level tuning for different access patterns
- Compaction strategy optimization for different workloads

---

