## Advanced Patterns


### Bucketing Strategies for Large Datasets

Bucketing is a fundamental technique for distributing large datasets across partitions to prevent hotspots and ensure balanced cluster utilization. This approach divides data into smaller, manageable segments that can be efficiently queried and maintained.

#### Time-Based Bucketing

Time-based bucketing distributes temporal data across multiple partitions using time intervals as partition boundaries.

**Key points:**

- Prevents unbounded partition growth over time
- Enables efficient time-range queries
- Supports data aging and TTL strategies
- Balances write load across cluster nodes

**Example:**

```cql
CREATE TABLE user_events_daily (
    user_id uuid,
    bucket_date date,
    event_timestamp timestamp,
    event_type text,
    event_data map<text, text>,
    PRIMARY KEY ((user_id, bucket_date), event_timestamp)
);
```

This pattern creates daily buckets for user events, allowing efficient queries within date ranges while preventing any single partition from growing indefinitely.

**Bucket size considerations:**

- Daily buckets: Suitable for moderate event volumes (< 100MB per user per day)
- Hourly buckets: High-frequency events or large event payloads
- Weekly/Monthly buckets: Low-frequency events or historical data

#### Hash-Based Bucketing

Hash-based bucketing uses deterministic hashing to distribute data across a fixed number of buckets, providing even distribution regardless of data patterns.

**Example:**

```cql
CREATE TABLE user_sessions (
    user_id uuid,
    bucket_id int,
    session_id timeuuid,
    session_data text,
    created_at timestamp,
    PRIMARY KEY ((user_id, bucket_id), session_id)
);
```

**Implementation approach:**

```cql
-- Application logic determines bucket_id
bucket_id = hash(user_id) % bucket_count
```

**Key points:**

- Provides consistent distribution across partitions
- Requires application-level bucket calculation
- Bucket count should be chosen based on expected data volume
- [Inference] Optimal bucket counts are typically powers of 2 for even hash distribution

#### Composite Bucketing

Composite bucketing combines multiple bucketing strategies to address complex data distribution requirements.

**Example:**

```cql
CREATE TABLE metrics_data (
    metric_name text,
    datacenter text,
    time_bucket timestamp,
    metric_timestamp timestamp,
    value double,
    tags map<text, text>,
    PRIMARY KEY ((metric_name, datacenter, time_bucket), metric_timestamp)
);
```

This pattern buckets by metric name, datacenter, and time period, enabling efficient queries across multiple dimensions while maintaining balanced partitions.

#### Dynamic Bucketing Strategies

[Inference] Advanced applications may implement dynamic bucketing that adjusts bucket size based on data growth patterns, though this requires careful coordination to maintain query efficiency.

**Considerations for dynamic bucketing:**

- Monitoring partition sizes and query patterns
- Implementing bucket migration strategies
- Maintaining query compatibility during transitions
- [Unverified] Performance impact during bucket restructuring operations

### Queue and Message Patterns

Cassandra can implement queue-like patterns for message processing, though it lacks native queue semantics and requires careful design to handle ordering and delivery guarantees.

#### Simple Message Queue Pattern

**Example:**

```cql
CREATE TABLE message_queue (
    queue_name text,
    priority int,
    message_id timeuuid,
    payload text,
    status text,
    created_at timestamp,
    processed_at timestamp,
    PRIMARY KEY ((queue_name, priority), message_id)
) WITH CLUSTERING ORDER BY (message_id ASC);
```

**Key points:**

- Uses timeuuid for natural ordering and uniqueness
- Priority-based partitioning for message prioritization
- Status tracking for message lifecycle management
- Clustering order ensures chronological message retrieval

#### Distributed Work Queue

For distributed processing across multiple consumers:

**Example:**

```cql
CREATE TABLE work_queue (
    shard_id int,
    status text,
    message_id timeuuid,
    payload text,
    worker_id text,
    created_at timestamp,
    claimed_at timestamp,
    completed_at timestamp,
    retry_count int,
    PRIMARY KEY ((shard_id, status), message_id)
);
```

**Processing workflow:**

1. Messages initially inserted with status = 'pending'
2. Workers claim messages by updating status to 'processing'
3. Successful completion updates status to 'completed'
4. Failed messages can be retried or moved to dead letter status

#### Message Deduplication Pattern

**Example:**

```cql
CREATE TABLE message_dedup (
    idempotency_key text,
    message_id timeuuid,
    payload text,
    created_at timestamp,
    PRIMARY KEY (idempotency_key)
);

CREATE TABLE message_store (
    topic text,
    partition_id int,
    message_id timeuuid,
    idempotency_key text,
    payload text,
    created_at timestamp,
    PRIMARY KEY ((topic, partition_id), message_id)
);
```

**Key points:**

- Idempotency keys prevent duplicate message processing
- Separate deduplication table enables fast duplicate detection
- [Inference] Requires application-level coordination for atomic operations across tables

#### Limitations of Queue Patterns

**Key points:**

- No native FIFO guarantees across partitions
- No automatic message acknowledgment or timeout handling
- Requires application-level logic for failure handling
- [Unverified] Performance degradation under high contention scenarios
- Eventual consistency may cause temporary message visibility issues

### Geospatial Data Modeling

Geospatial data modeling in Cassandra requires specialized patterns to efficiently store and query location-based information, as Cassandra lacks native geospatial indexing.

#### Geohash-Based Approach

Geohashing converts latitude/longitude coordinates into string representations that preserve spatial locality.

**Example:**

```cql
CREATE TABLE locations_by_geohash (
    geohash_prefix text,
    geohash_full text,
    location_id uuid,
    latitude double,
    longitude double,
    name text,
    category text,
    created_at timestamp,
    PRIMARY KEY (geohash_prefix, geohash_full, location_id)
);
```

**Key points:**

- Geohash prefixes enable range queries for proximity searches
- Multiple precision levels support different zoom levels
- Requires application-level geohash calculation
- [Inference] Geohash precision should be chosen based on query resolution requirements

**Query implementation:**

```cql
-- Find locations within geohash prefix "9q8yy"
SELECT * FROM locations_by_geohash 
WHERE geohash_prefix = '9q8yy';
```

#### Grid-Based Partitioning

Dividing geographic areas into fixed grid cells for spatial partitioning.

**Example:**

```cql
CREATE TABLE locations_by_grid (
    grid_x int,
    grid_y int,
    zoom_level int,
    location_id uuid,
    latitude double,
    longitude double,
    metadata map<text, text>,
    PRIMARY KEY ((grid_x, grid_y, zoom_level), location_id)
);
```

**Grid calculation logic:**

```
grid_x = floor(longitude / grid_size)
grid_y = floor(latitude / grid_size)
```

**Key points:**

- Fixed grid sizes enable predictable partitioning
- Multiple zoom levels support different query granularities
- Simpler calculation compared to geohashing
- [Inference] May have uneven distribution in areas with varying location density

#### Hierarchical Location Pattern

**Example:**

```cql
CREATE TABLE locations_hierarchical (
    country text,
    region text,
    city text,
    location_id uuid,
    latitude double,
    longitude double,
    address text,
    PRIMARY KEY ((country, region), city, location_id)
);

CREATE TABLE location_search (
    search_term text,
    location_type text,
    location_id uuid,
    full_address text,
    latitude double,
    longitude double,
    PRIMARY KEY ((search_term, location_type), location_id)
);
```

**Key points:**

- Enables queries by administrative boundaries
- Supports text-based location searches
- Requires denormalization for different access patterns
- [Inference] Works well for applications with known geographic hierarchies

### Graph Data Representation

Representing graph structures in Cassandra requires denormalization strategies since Cassandra lacks native graph traversal capabilities.

#### Adjacency List Pattern

**Example:**

```cql
CREATE TABLE user_relationships (
    user_id uuid,
    relationship_type text,
    related_user_id uuid,
    created_at timestamp,
    relationship_data map<text, text>,
    PRIMARY KEY ((user_id, relationship_type), related_user_id)
);

CREATE TABLE user_relationships_reverse (
    related_user_id uuid,
    relationship_type text,
    user_id uuid,
    created_at timestamp,
    PRIMARY KEY ((related_user_id, relationship_type), user_id)
);
```

**Key points:**

- Separate tables for forward and reverse lookups
- Relationship types enable different edge types
- Denormalization supports bidirectional traversal
- Requires application-level consistency management

#### Activity Feed Pattern

**Example:**

```cql
CREATE TABLE user_feed (
    user_id uuid,
    bucket_timestamp timestamp,
    activity_timestamp timestamp,
    activity_id uuid,
    actor_id uuid,
    activity_type text,
    activity_data text,
    PRIMARY KEY ((user_id, bucket_timestamp), activity_timestamp, activity_id)
) WITH CLUSTERING ORDER BY (activity_timestamp DESC);

CREATE TABLE activity_propagation (
    activity_id uuid,
    target_user_id uuid,
    propagated_at timestamp,
    PRIMARY KEY (activity_id, target_user_id)
);
```

**Key points:**

- Time-bucketed feeds prevent unbounded partition growth
- Reverse chronological ordering for recent-first access
- Separate propagation tracking for fanout management
- [Inference] Requires background processes for feed generation and maintenance

#### Graph Traversal Patterns

Multi-hop graph traversal requires multiple queries and application-level coordination:

**Two-hop friend recommendation:**

```cql
-- Step 1: Get direct friends
SELECT related_user_id FROM user_relationships 
WHERE user_id = ? AND relationship_type = 'friend';

-- Step 2: Get friends of friends (application logic)
SELECT related_user_id FROM user_relationships 
WHERE user_id IN (...) AND relationship_type = 'friend';
```

**Key points:**

- Multi-step queries required for graph traversal
- Application must handle duplicate elimination
- [Unverified] Performance degrades significantly with traversal depth
- Consider dedicated graph databases for complex traversal requirements

### Audit Log Patterns

Audit logging patterns ensure comprehensive tracking of data changes and system activities for compliance and debugging purposes.

#### Immutable Event Log

**Example:**

```cql
CREATE TABLE audit_log (
    entity_type text,
    entity_id text,
    event_date date,
    event_timestamp timestamp,
    event_id timeuuid,
    event_type text,
    user_id uuid,
    changes map<text, text>,
    metadata map<text, text>,
    PRIMARY KEY ((entity_type, entity_id, event_date), event_timestamp, event_id)
) WITH CLUSTERING ORDER BY (event_timestamp DESC);
```

**Key points:**

- Daily partitioning prevents unbounded partition growth
- Immutable records ensure audit trail integrity
- Reverse chronological ordering for recent-first access
- Composite partition key enables efficient entity-specific queries

#### Change Data Capture Pattern

**Example:**

```cql
CREATE TABLE user_changes (
    user_id uuid,
    change_date date,
    change_timestamp timestamp,
    change_id timeuuid,
    change_type text, -- INSERT, UPDATE, DELETE
    old_values map<text, text>,
    new_values map<text, text>,
    changed_by uuid,
    PRIMARY KEY ((user_id, change_date), change_timestamp, change_id)
);

CREATE TABLE global_change_feed (
    change_date date,
    change_timestamp timestamp,
    change_id timeuuid,
    entity_type text,
    entity_id text,
    change_type text,
    changed_by uuid,
    PRIMARY KEY (change_date, change_timestamp, change_id)
) WITH CLUSTERING ORDER BY (change_timestamp DESC);
```

**Key points:**

- Entity-specific and global views of changes
- Before/after value tracking for complete audit trail
- Time-based partitioning for efficient querying
- [Inference] Requires application-level coordination to maintain consistency between tables

#### Compliance and Retention Pattern

**Example:**

```cql
CREATE TABLE audit_events (
    tenant_id uuid,
    compliance_category text,
    event_date date,
    event_timestamp timestamp,
    event_id timeuuid,
    event_details text,
    retention_until timestamp,
    PRIMARY KEY ((tenant_id, compliance_category, event_date), event_timestamp, event_id)
) WITH default_time_to_live = 2592000; -- 30 days default

CREATE TABLE audit_retention_policy (
    tenant_id uuid,
    compliance_category text,
    retention_days int,
    legal_hold boolean,
    PRIMARY KEY (tenant_id, compliance_category)
);
```

**Key points:**

- Tenant and category-based partitioning for compliance isolation
- TTL-based automatic data expiration
- Legal hold capability for litigation requirements
- [Inference] Requires background processes for custom retention policy enforcement

#### Performance Considerations for Audit Patterns

**Key points:**

- High write volumes require careful partition design
- [Unverified] Audit logging can impact application performance by 10-30%
- Asynchronous logging patterns reduce application latency
- Separate clusters may be warranted for high-volume audit requirements

**Asynchronous audit implementation:**

- Application writes to message queue
- Background workers process audit events
- Eventual consistency acceptable for audit use cases
- [Inference] Provides better application performance isolation

**Conclusion:** These advanced patterns demonstrate Cassandra's flexibility for complex data modeling scenarios. Each pattern involves trade-offs between consistency, performance, and operational complexity. Bucketing strategies are essential for scalability, queue patterns require careful design due to Cassandra's limitations, geospatial modeling needs application-level indexing, graph representations require extensive denormalization, and audit patterns must balance completeness with performance.

**Related important topics:** Data modeling best practices, partition key design strategies, TTL and compaction strategies, monitoring and alerting for advanced patterns, performance tuning for complex data models.

---

