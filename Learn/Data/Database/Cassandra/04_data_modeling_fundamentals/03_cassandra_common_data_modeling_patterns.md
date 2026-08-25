## Cassandra Common Data Modeling Patterns


### Time-Series Data Patterns

Time-series data represents one of Cassandra's strongest use cases due to its write-optimized architecture and natural partitioning capabilities. These patterns focus on efficiently storing and querying data that changes over time.

#### Wide Row Pattern

The wide row pattern stores multiple time-ordered records within a single partition. The partition key typically contains an identifier and time bucket, while clustering columns contain timestamps for ordering.

**Key Points:**

- Partition key combines entity ID with time bucket (hour, day, month)
- Clustering columns use timestamp for chronological ordering
- Enables efficient range queries within time windows
- Prevents partition growth beyond recommended limits

**Example:**

```cql
CREATE TABLE sensor_data (
    sensor_id UUID,
    bucket_date DATE,
    timestamp TIMESTAMP,
    temperature DECIMAL,
    humidity DECIMAL,
    PRIMARY KEY ((sensor_id, bucket_date), timestamp)
) WITH CLUSTERING ORDER BY (timestamp DESC);
```

#### Time Window Bucketing

This approach partitions time-series data into discrete time windows to maintain optimal partition sizes and query performance.

**Key Points:**

- Daily, hourly, or monthly buckets based on data volume
- Prevents hot partitions during high-write periods
- Enables efficient time-range queries
- Requires application-level logic for cross-bucket queries

#### Inverted Time Pattern

For scenarios requiring most recent data access, timestamps can be inverted or UUID-based time ordering can be used.

**Key Points:**

- TIMEUUID clustering columns provide natural time ordering
- DESC clustering order places newest data first
- Efficient for "latest N records" queries
- Maintains write performance characteristics

### Lookup Table Patterns

Lookup patterns address Cassandra's limitation of supporting only primary key-based queries by creating additional tables optimized for different access patterns.

#### Secondary Index Tables

Creates dedicated tables for non-primary key lookups, essentially materializing different views of the same data.

**Key Points:**

- Each query pattern requires its own table structure
- Data denormalization across multiple tables
- Application maintains consistency across lookup tables
- Write amplification trade-off for read performance

**Example:**

```cql
-- Primary table
CREATE TABLE users_by_id (
    user_id UUID PRIMARY KEY,
    email TEXT,
    username TEXT,
    created_at TIMESTAMP
);

-- Lookup table for email queries
CREATE TABLE users_by_email (
    email TEXT PRIMARY KEY,
    user_id UUID,
    username TEXT,
    created_at TIMESTAMP
);
```

#### Composite Lookup Keys

Combines multiple attributes into compound partition keys for complex lookup scenarios.

**Key Points:**

- Enables queries on multiple attributes simultaneously
- Reduces number of required lookup tables
- May create uneven partition distribution
- Requires careful cardinality analysis

#### Bucketed Lookups

Distributes lookup data across multiple partitions to prevent hot partitions and improve parallelism.

**Key Points:**

- Adds artificial bucket identifier to partition key
- Improves read parallelism for large result sets
- Complicates application logic for data retrieval
- Useful for high-cardinality lookup scenarios

### Hierarchical Data Modeling

Hierarchical structures require flattening strategies since Cassandra lacks native support for nested queries or joins.

#### Adjacency List Pattern

Stores parent-child relationships directly, similar to traditional relational modeling but optimized for Cassandra's strengths.

**Key Points:**

- Each node stores reference to its parent
- Efficient for immediate parent/child queries
- Requires recursive application logic for deep traversals
- Works well for shallow hierarchies

**Example:**

```cql
CREATE TABLE organizational_hierarchy (
    employee_id UUID,
    parent_id UUID,
    level INT,
    department TEXT,
    name TEXT,
    PRIMARY KEY (parent_id, level, employee_id)
);
```

#### Path Enumeration Pattern

Stores the complete path from root to each node, enabling efficient ancestor and descendant queries.

**Key Points:**

- Full path stored as text or collection
- Enables single-query ancestor lookups
- Requires path updates when hierarchy changes
- Storage overhead increases with depth

#### Materialized Path Trees

Creates multiple denormalized views of hierarchical data optimized for different traversal patterns.

**Key Points:**

- Separate tables for ancestors, descendants, and siblings
- High write amplification during updates
- Optimal read performance for all hierarchy queries
- Complex consistency management

### Many-to-Many Relationships

Cassandra handles many-to-many relationships through junction tables and denormalization strategies.

#### Junction Table Pattern

Creates intermediate tables linking entities in many-to-many relationships.

**Key Points:**

- Separate table for each direction of relationship
- Compound primary keys combining both entity identifiers
- Enables efficient queries in both directions
- Requires multiple writes for relationship changes

**Example:**

```cql
-- User to group relationships
CREATE TABLE user_groups (
    user_id UUID,
    group_id UUID,
    joined_at TIMESTAMP,
    role TEXT,
    PRIMARY KEY (user_id, group_id)
);

-- Group to user relationships (reverse lookup)
CREATE TABLE group_users (
    group_id UUID,
    user_id UUID,
    joined_at TIMESTAMP,
    role TEXT,
    PRIMARY KEY (group_id, user_id)
);
```

#### Embedded Collections

Uses collection columns to store related entity identifiers directly within parent records.

**Key Points:**

- SET, LIST, or MAP collections for relationship storage
- Limited to reasonable collection sizes (< 64KB recommended)
- Atomic collection updates
- May require full collection reads for partial updates

#### Denormalized Relationship Data

Duplicates relationship information across multiple tables to optimize specific query patterns.

**Key Points:**

- Relationship data embedded in both entity tables
- Eliminates need for separate relationship queries
- Significant write amplification
- Complex consistency management requirements

### Event Sourcing Patterns

Event sourcing patterns treat data changes as immutable events, naturally aligning with Cassandra's append-only storage model.

#### Event Log Pattern

Stores all system events in chronological order, treating the event log as the source of truth.

**Key Points:**

- Immutable event records with timestamps
- Natural fit for Cassandra's write-optimized storage
- Partition by entity ID and time bucket
- Enables complete audit trails and replay capabilities

**Example:**

```cql
CREATE TABLE account_events (
    account_id UUID,
    event_date DATE,
    event_id TIMEUUID,
    event_type TEXT,
    event_data TEXT,
    amount DECIMAL,
    PRIMARY KEY ((account_id, event_date), event_id)
) WITH CLUSTERING ORDER BY (event_id ASC);
```

#### Snapshot Pattern

Periodically materializes current state from event streams to optimize read performance.

**Key Points:**

- Combines event sourcing with CQRS principles
- Snapshot tables for current state queries
- Event tables for historical analysis and audit
- Background processes maintain snapshot consistency

#### Command and Event Separation

Separates command processing from event storage, enabling scalable event processing architectures.

**Key Points:**

- Commands stored temporarily for processing validation
- Events represent immutable facts after command processing
- Enables replay and reprocessing scenarios
- Natural partition alignment with event ordering

**Conclusion:** These patterns address Cassandra's unique characteristics by embracing denormalization, write amplification, and eventual consistency. Success requires understanding query patterns upfront and designing table structures that align with Cassandra's strengths while working around its limitations. [Inference] Most production systems combine multiple patterns based on specific access requirements and consistency needs.

**Next Steps:** Consider data volume projections, query frequency analysis, and consistency requirements when selecting appropriate patterns. Prototype critical query paths early to validate performance assumptions before full implementation.

---

