## MongoDB Sharding Concepts


### Horizontal vs Vertical Scaling

MongoDB sharding implements horizontal scaling, which distributes data across multiple servers (shards) rather than upgrading hardware on a single machine. This approach contrasts fundamentally with vertical scaling strategies.

**Horizontal Scaling (Scale Out)** Horizontal scaling adds more servers to handle increased load and data volume. In MongoDB's sharded architecture, data gets partitioned across multiple replica sets called shards. Each shard contains a subset of the total data, allowing the system to handle larger datasets and higher throughput by distributing operations across multiple machines.

**Vertical Scaling (Scale Up)** Vertical scaling increases the capacity of existing hardware by adding more CPU, RAM, or storage to a single server. While simpler to implement initially, vertical scaling has physical and economic limitations. MongoDB supports vertical scaling for non-sharded deployments, but eventually reaches hardware constraints that make horizontal scaling necessary.

**Key Points:**

- Horizontal scaling provides theoretically unlimited capacity expansion
- Vertical scaling offers simpler management but has hardware limitations
- MongoDB's sharding enables automatic horizontal scaling across commodity hardware
- Cost efficiency typically favors horizontal scaling for large deployments

### Shard Key Selection

The shard key determines how MongoDB distributes documents across shards and significantly impacts cluster performance, scalability, and query efficiency.

**Shard Key Characteristics** A shard key consists of one or more fields that exist in every document within the sharded collection. MongoDB uses the shard key values to determine which shard stores each document. The shard key becomes immutable after sharding begins, making initial selection crucial.

**Selection Criteria** Effective shard keys exhibit high cardinality, meaning they have many distinct values across the collection. Low cardinality keys create few chunks, limiting distribution effectiveness. The key should also provide good write distribution to prevent hotspots where one shard receives disproportionate write traffic.

Query patterns heavily influence shard key selection. Keys that appear frequently in query predicates enable targeted queries that access specific shards rather than broadcasting across the entire cluster. Compound shard keys can balance write distribution with query targeting by combining multiple fields.

**Common Patterns** Hashed shard keys use MongoDB's hash function to distribute documents evenly, providing excellent write distribution for keys with any cardinality. However, range queries cannot target specific shards effectively with hashed keys.

Ranged shard keys preserve document ordering and enable efficient range queries. They work well when the key values distribute naturally across the expected range. Monotonically increasing keys like timestamps or ObjectIds can create hotspots as all new writes target the same shard.

**Key Points:**

- Shard keys are immutable after collection sharding begins
- High cardinality and good write distribution prevent hotspots
- Query patterns should inform shard key selection
- Compound keys can balance multiple requirements

### Chunk Distribution

MongoDB organizes sharded data into chunks, which are contiguous ranges of shard key values. The chunk system enables granular data distribution and migration between shards.

**Chunk Structure** Each chunk represents a range of shard key values, from a minimum to maximum value. MongoDB initially creates chunks based on the shard key's data type and distribution. For new collections, MongoDB may create empty chunks across the expected key range to prepare for data insertion.

Chunks have a default maximum size of 64MB, though [Inference] this may vary based on MongoDB version and configuration. When a chunk exceeds the maximum size, MongoDB splits it into two smaller chunks at the median shard key value. This splitting process maintains balanced chunk sizes as data grows.

**Distribution Logic** The config servers maintain metadata about chunk ownership, tracking which shard contains each chunk range. When applications insert or query documents, mongos routers use this metadata to direct operations to the appropriate shards.

MongoDB attempts to distribute chunks evenly across available shards. New collections start with chunks distributed across shards, while existing collections may require balancing to achieve even distribution after sharding.

**Migration Process** Chunk migration moves chunks between shards to maintain balance or respond to shard additions or removals. During migration, the source shard continues serving the chunk while copying data to the destination shard. Once copying completes, MongoDB updates the metadata to reflect the new chunk ownership.

**Key Points:**

- Chunks represent contiguous shard key ranges with size limits
- Chunk splitting maintains granular distribution as data grows
- Config servers track chunk-to-shard mappings
- Migration enables dynamic redistribution between shards

### Balancing Process

The MongoDB balancer automatically redistributes chunks across shards to maintain even data distribution and prevent individual shards from becoming overloaded.

**Balancer Operation** The balancer runs as a background process on the primary member of the config server replica set. It periodically evaluates chunk distribution across shards and initiates migrations when imbalances exceed configured thresholds.

By default, the balancer considers shards imbalanced when the difference in chunk counts exceeds specific thresholds based on total cluster size. For clusters with fewer than 20 chunks, a difference of 2 chunks triggers balancing. Larger clusters use proportional thresholds to determine when migration is necessary.

**Migration Coordination** The balancer coordinates chunk migrations to avoid overwhelming the cluster with simultaneous data transfers. It limits concurrent migrations and ensures that critical operations like chunk splits complete before initiating new migrations.

During migration, the balancer tracks progress and handles failures gracefully. If a migration fails, the balancer may retry the operation or select different source and destination shards for subsequent attempts.

**Balancing Windows** Administrators can configure balancing windows to restrict when migrations occur. This prevents balancing operations from impacting application performance during peak usage periods. The balancer respects these windows and defers migrations until permitted times.

**Manual Balancing Control** While automatic balancing handles most scenarios, administrators can disable the balancer temporarily for maintenance operations or troubleshooting. Manual chunk movement commands allow precise control over data distribution when automatic balancing proves insufficient.

**Key Points:**

- Balancer runs automatically on config server primary
- Chunk count thresholds determine when balancing triggers
- Migration limits prevent cluster overload during balancing
- Balancing windows allow scheduling control for operational requirements

### Performance Considerations

**Query Routing Efficiency** Queries that include the shard key in their predicates can target specific shards, reducing network overhead and improving response times. Queries without shard key predicates must broadcast to all shards, increasing latency and resource consumption.

**Write Distribution Impact** Poor shard key selection can create write hotspots where one shard receives significantly more write operations than others. This imbalance reduces overall cluster write capacity and may cause individual shards to become bottlenecks.

**Operational Overhead** Sharded clusters introduce additional complexity through config servers, mongos routers, and balancing operations. This complexity requires more sophisticated monitoring and maintenance procedures compared to replica sets.

**Key Points:**

- Shard-targeted queries significantly outperform broadcast queries
- Write hotspots limit cluster scalability and performance
- Operational complexity increases with sharded deployments
- Proper planning and monitoring become critical for success

---

