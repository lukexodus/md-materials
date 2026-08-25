## CQL Basics and Data Types


### CQL vs SQL Differences

Cassandra Query Language (CQL) was designed to provide a familiar SQL-like interface while accommodating Cassandra's distributed architecture and data model. Despite syntactic similarities, fundamental differences exist between CQL and traditional SQL that reflect the underlying NoSQL nature of Cassandra.

CQL lacks support for JOINs between tables, a core feature of relational databases. This limitation stems from Cassandra's distributed architecture where related data might reside on different nodes, making cross-table operations expensive and potentially inconsistent. Instead, CQL encourages denormalization and designing tables around specific query patterns.

Subqueries are not supported in CQL, requiring developers to restructure complex queries into multiple separate operations. This constraint aligns with Cassandra's focus on predictable performance and scalability, as subqueries can introduce unpredictable execution costs in distributed systems.

Transaction support in CQL is limited compared to SQL. Traditional SQL databases provide ACID transactions across multiple tables and operations, while CQL offers only lightweight transactions for single-partition operations using IF conditions. Batch statements exist but don't provide the same atomicity guarantees as SQL transactions.

CQL enforces strict limitations on WHERE clauses to maintain query performance predictability. Queries must specify the partition key and can only filter on clustering columns in the order they're defined in the primary key. This restriction prevents full table scans that would be prohibitively expensive in a distributed system.

**Key points:**

- No JOINs or subqueries supported
- Limited transaction capabilities
- Restricted WHERE clause flexibility
- Denormalization encouraged over normalization
- Query patterns must be designed upfront

### Keyspaces and Tables

Keyspaces in Cassandra serve as the top-level namespace for organizing tables, similar to databases in relational systems. Each keyspace defines replication settings that apply to all tables within it, including the replication strategy and replication factor.

When creating a keyspace, the replication configuration must be specified. For single-datacenter deployments, SimpleStrategy with an appropriate replication factor (typically 3) is common. Multi-datacenter environments require NetworkTopologyStrategy with replication factors specified per datacenter.

```cql
CREATE KEYSPACE ecommerce 
WITH REPLICATION = {
    'class': 'NetworkTopologyStrategy',
    'datacenter1': 3,
    'datacenter2': 2
};
```

Tables within a keyspace contain the actual data and define the schema including column names, data types, and primary key structure. Unlike relational databases, Cassandra tables are designed around specific query patterns rather than normalized data relationships.

The primary key structure in Cassandra tables serves multiple purposes: it determines data distribution across nodes (partition key) and data ordering within partitions (clustering columns). This dual role makes primary key design crucial for both performance and functionality.

Table creation requires careful consideration of the partition key to ensure even data distribution. Large partitions can create hotspots and performance issues, while too many small partitions can impact query efficiency. The ideal partition size is typically between 100MB and 1GB.

**Key points:**

- Keyspaces define replication settings for contained tables
- Tables designed around query patterns, not normalization
- Primary key determines both distribution and ordering
- Partition size optimization critical for performance

### Primary Data Types

Cassandra supports a rich set of primary data types that map to common programming language primitives and specialized database requirements. Understanding these types is essential for proper schema design and application development.

Text and varchar types store UTF-8 encoded strings of variable length. These types are functionally identical in Cassandra, with varchar provided for SQL compatibility. Text fields can store strings up to 2GB in size, though practical limits are much smaller for performance reasons.

Numeric types include int (32-bit signed integer), bigint (64-bit signed integer), smallint (16-bit signed integer), tinyint (8-bit signed integer), float (32-bit IEEE 754), double (64-bit IEEE 754), and decimal (arbitrary precision). The choice between these types affects storage efficiency and query performance.

The boolean type stores true/false values and is commonly used for flags and status indicators. Boolean columns can be indexed and used in WHERE clauses like other primitive types.

Timestamp types store date and time information with millisecond precision. Cassandra internally stores timestamps as 64-bit integers representing milliseconds since the Unix epoch. Time zone information is not stored with the timestamp value.

UUID and timeuuid types provide unique identifiers with different characteristics. UUID generates random 128-bit values, while timeuuid incorporates timestamp information and provides chronological ordering. Timeuuid is particularly useful for clustering columns where time-based ordering is desired.

The blob type stores arbitrary binary data as hexadecimal strings. While useful for storing binary content, large blob values can impact query performance and should be used judiciously.

**Key points:**

- Text and varchar are functionally identical
- Multiple numeric types for different precision and storage requirements
- Timestamp precision limited to milliseconds
- Timeuuid provides both uniqueness and chronological ordering
- Blob type for binary data with performance considerations

### Collection Types

Cassandra provides three collection types that allow storing multiple values within a single column: set, list, and map. These collections enable more flexible data modeling while maintaining the benefits of Cassandra's distributed architecture.

Set collections store unique values of a specified type, similar to mathematical sets. Sets automatically enforce uniqueness and don't maintain insertion order. They're useful for storing tags, categories, or any scenario where duplicate values should be avoided.

```cql
CREATE TABLE products (
    id UUID PRIMARY KEY,
    name text,
    tags set<text>
);
```

List collections maintain ordered sequences of values that may include duplicates. Lists preserve insertion order and support index-based access. They're appropriate for storing ordered data like comments, ratings, or time-series information within reasonable size limits.

Map collections store key-value pairs where both keys and values have specified types. Maps are useful for storing attributes with dynamic names or creating simple embedded documents within a column.

Collection operations support adding, removing, and updating individual elements without reading the entire collection first. This capability enables efficient partial updates, though operations on collections still require careful consideration of partition size and query patterns.

Collection size limitations are important for performance. While Cassandra doesn't enforce hard limits on collection sizes, collections with thousands of elements can impact query performance and should be avoided. Large collections may indicate the need for a different data modeling approach.

**Key points:**

- Set enforces uniqueness without maintaining order
- List maintains order and allows duplicates
- Map stores key-value pairs with typed keys and values
- Partial collection updates supported
- Size limitations important for performance

### User-Defined Types

User-defined types (UDTs) allow creating custom data structures that can be reused across multiple tables and columns. UDTs provide a way to group related fields together, similar to structs in programming languages, enabling more organized and maintainable schema design.

UDTs are defined at the keyspace level and can be used as column types in any table within that keyspace. Once created, UDTs can be referenced by name in table definitions, providing better schema organization and reducing duplication.

```cql
CREATE TYPE address (
    street text,
    city text,
    state text,
    postal_code text,
    country text
);

CREATE TABLE users (
    id UUID PRIMARY KEY,
    name text,
    home_address address,
    work_address address
);
```

UDT fields can be accessed and updated individually using dot notation in CQL statements. This capability allows partial updates without requiring the entire UDT value to be overwritten, providing more efficient data modification operations.

Nested UDTs are supported, allowing complex hierarchical data structures. However, deep nesting should be used carefully as it can complicate queries and impact performance. UDTs can also contain collection types, providing additional flexibility in data modeling.

UDT evolution is supported through ALTER TYPE statements, allowing fields to be added to existing UDTs. However, field removal and type changes are not supported, requiring careful initial design and potentially creating new UDTs for significant schema changes.

**Key points:**

- UDTs defined at keyspace level for reuse across tables
- Individual field access and updates supported
- Nesting and collections within UDTs possible
- Limited evolution capabilities require careful initial design

### Counter Columns

Counter columns provide distributed counting functionality that's challenging to implement correctly in distributed systems. These columns store 64-bit signed integers that can be incremented or decremented atomically across multiple nodes without requiring read-before-write operations.

Counter operations are eventually consistent but commutative, meaning the final value will be correct regardless of the order in which increment and decrement operations are applied. This property makes counters suitable for use cases like page views, likes, votes, or any scenario requiring distributed counting.

Tables containing counter columns have specific restrictions. All non-primary key columns must be counters, and regular columns cannot coexist with counter columns in the same table. This limitation requires separate tables for counter data and regular application data.

```cql
CREATE TABLE page_views (
    page_id UUID,
    view_date date,
    views counter,
    PRIMARY KEY (page_id, view_date)
);

UPDATE page_views SET views = views + 1 
WHERE page_id = ? AND view_date = ?;
```

Counter accuracy can be affected by node failures and network partitions. While Cassandra includes mechanisms to detect and correct counter inconsistencies, applications should be designed to tolerate occasional inaccuracies in counter values.

Counter sharding is a technique used to improve counter performance and accuracy by distributing counter operations across multiple rows. This approach reduces contention on individual counter values but requires application-level aggregation when reading counter totals.

**Key points:**

- Atomic increment/decrement operations without read-before-write
- Eventually consistent with commutative properties
- Separate tables required for counter columns
- Accuracy considerations during failures and partitions
- Counter sharding can improve performance and accuracy

### Data Type Considerations and Best Practices

Choosing appropriate data types affects both storage efficiency and query performance. Text types are variable-length and more storage-efficient than fixed-length alternatives for varying content sizes. However, fixed-length types like int and bigint provide better performance for numeric operations.

Collection types should be used judiciously with consideration for partition size and query patterns. Large collections can create performance bottlenecks and may indicate the need for separate tables with proper primary key design.

UDTs provide schema organization benefits but should be designed with future evolution in mind. Since UDT changes are limited, initial design should anticipate potential future requirements while avoiding over-engineering.

Counter columns solve specific distributed counting problems but come with accuracy trade-offs and table design restrictions. Applications using counters should implement appropriate error handling and consider whether approximate counting is acceptable for their use case.

**Key points:**

- Data type choice affects storage efficiency and query performance
- Collection size impacts partition performance
- UDT design should consider future evolution needs
- Counter accuracy trade-offs require careful application design

**Conclusion:** CQL provides a familiar SQL-like interface while accommodating Cassandra's distributed architecture through specific limitations and extensions. Understanding the differences from traditional SQL, along with proper usage of keyspaces, tables, and data types, is essential for effective Cassandra schema design. The rich type system, including collections, UDTs, and counters, enables flexible data modeling while maintaining the performance and scalability benefits of Cassandra's architecture.

---

