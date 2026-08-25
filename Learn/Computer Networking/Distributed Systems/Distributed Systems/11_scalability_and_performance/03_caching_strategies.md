## Caching Strategies


### Cache-Aside (Lazy Loading)

Application logic directly manages cache population. On read, application queries cache first; on miss, fetches from authoritative data store, writes to cache, then returns data. Writes bypass cache entirely and go directly to data store, requiring explicit cache invalidation or TTL-based expiration.

**Consistency Model:** Eventually consistent. Stale reads possible between write completion and cache invalidation propagation. Time-to-inconsistency bounded by TTL or invalidation latency.

**Failure Modes:** Cache unavailability degrades to direct data store access. Thundering herd on cache miss under high concurrency—mitigate with request coalescing, probabilistic early expiration, or distributed locking (e.g., Redlock pattern). Cold start requires warming strategies.

**Partitioning:** Cache sharding follows data store partitioning scheme (consistent hashing, range-based). Hot key concentration requires dedicated cache instances or local L1 caches per application node.

**Operational Characteristics:** Application bears coordination burden. Cache miss amplification factor directly impacts tail latency. Observability requires tracking cache hit ratio, miss penalty, eviction rate, and TTL effectiveness per key namespace.

### Read-Through

Cache sits as intermediary layer with responsibility for data store interaction. On cache miss, cache itself fetches from backing store, populates entry, then returns data. Application treats cache as authoritative interface.

**Data Flow:** Unidirectional read path: Application → Cache → Data Store. Cache acts as transparent proxy with automatic population semantics.

**Consistency Model:** Similar to cache-aside but centralized miss handling eliminates thundering herd at application tier. Single request to backing store per unique miss across all application instances.

**Scalability Constraints:** Cache becomes critical path and potential SPOF. Requires cache clustering (Redis Cluster, Memcached consistent hashing) with replication for availability. Cache-to-data-store connection pooling must scale with aggregate miss rate.

**Failure Isolation:** Cache failure exposes data store to full request load. Circuit breaker pattern essential. Fallback to cache-aside mode or degraded service with elevated latency SLOs.

### Write-Through

All writes synchronously update both cache and data store within same transaction boundary. Write acknowledgment only after both succeed. Guarantees cache coherence at cost of write latency.

**Consistency Model:** Strong consistency for cached items. Read-your-writes guaranteed. No stale cache entries assuming atomic dual-write semantics.

**Coordination Overhead:** Requires distributed transaction or two-phase commit if cache and data store are separate systems. Write amplification factor of 2×. Write latency is max(cache_write_latency, datastore_write_latency) plus coordination overhead.

**Failure Handling:** Write failure in either system requires rollback. Cache write failure must not commit to data store. Idempotency requirements for retry semantics. Partial failure scenarios require careful compensation logic.

**Use Cases:** Write-heavy workloads where read consistency is critical and write latency penalty is acceptable. Session stores, configuration systems, inventory management with strong consistency requirements.

### Write-Behind (Write-Back)

Writes acknowledged immediately after cache update. Asynchronous background process flushes cache entries to data store in batches. Decouples write path latency from backing store.

**Data Flow:** Application → Cache (sync) → Data Store (async). Cache becomes temporary authoritative source with eventual data store convergence.

**Consistency Model:** Cache is ahead of data store. Data loss window exists between cache write and successful flush. Durability depends on cache persistence mechanisms (AOF, RDB snapshots in Redis). Requires write-ahead log or persistent queue for crash recovery.

**Batching Strategies:** Temporal batching (flush every N seconds), size-based batching (flush every M entries), or hybrid. Coalesces multiple updates to same key, reducing write amplification to data store.

**Failure Modes:** Cache failure before flush results in data loss unless cache has persistent storage. Data store unavailability causes write queue buildup—requires backpressure mechanism and overflow policies (reject new writes, evict least recently written, spill to disk).

**Scalability:** Dramatically reduces data store write load. Flush rate decoupled from application write rate. Contention at data store minimized through batch optimization and upsert semantics.

**Operational Complexity:** Requires monitoring flush lag, queue depth, and failure-to-flush rates. Recovery procedures must replay unflushed writes from persistent cache storage or WAL.

### Refresh-Ahead

Proactively refreshes cache entries before expiration based on access patterns. Predictive refresh using heuristics (access frequency, time-to-expiration) or ML-based models.

**Consistency Model:** Reduces stale read window but does not eliminate. Refresh may complete after TTL expiration under load. Still eventually consistent.

**Implementation Patterns:** Background refresh thread monitors access patterns and TTL proximity. Refresh triggered at configurable threshold (e.g., 80% of TTL elapsed). Alternative: client-side refresh on access if TTL below threshold.

**Thundering Herd Mitigation:** Spreads refresh load temporally. Reduces synchronized cache miss storms on popular keys. Requires locking or lease mechanism to prevent redundant refreshes from concurrent refresh workers.

**Resource Utilization:** Increases background CPU and network for speculative refreshes. Risk of refreshing entries that won't be accessed again (wasted resources). Effectiveness depends on access pattern predictability—works well for hot keys with stable access frequencies.

### Cache Invalidation Patterns

**Time-Based Expiration (TTL):** Simplest invalidation. Fixed or sliding window TTL per entry. Trades staleness tolerance for simplicity. Inappropriate for strong consistency requirements.

**Event-Based Invalidation:** Data store mutations trigger explicit cache invalidation via pub-sub, CDC (change data capture), or application-level notification. Requires reliable message delivery and ordering guarantees. Out-of-order invalidation can cause write-after-invalidate anomalies.

**Version-Based Invalidation:** Each cache entry tagged with version or ETag. Reads include version check; mismatches trigger refresh. Requires version metadata in data store. Supports optimistic concurrency control.

**Lease-Based Coherence:** Cache entries granted time-bounded leases by authoritative source. Write operations invalidate all outstanding leases. Readers validate lease before trusting cached data. Scales poorly with large reader populations but provides bounded staleness.

**Write Invalidation vs Write Update:** Invalidation removes entry, forcing next read to repopulate. Update propagates new value directly. Update requires reliable multicast or point-to-point invalidation to all cache replicas. Invalidation simpler but incurs miss penalty.

### Multi-Level Caching Hierarchies

**L1 (Local/In-Process):** In-memory cache within application process (Guava Cache, Caffeine, local HashMap). Sub-microsecond latency. No network overhead. Limited to single JVM heap or process memory. Coherence with L2/data store via TTL or invalidation messages.

**L2 (Distributed/Remote):** Shared cache cluster (Redis, Memcached). Millisecond-scale latency. Shared across application instances. Provides cross-process coherence boundary.

**L3 (CDN/Edge):** Geographic distribution for static or semi-static content. Tens to hundreds of milliseconds. Purge/invalidation propagation delay proportional to edge POP count.

**Coherence Protocols:** L1 invalidation on L2 update requires pub-sub channel or invalidation queue. Cache stampede protection via locking at L2 layer. L1 acts as victim cache—absorbs read load but introduces additional staleness window.

**Promotion/Demotion Policies:** Frequently accessed L2 entries promoted to L1. Evicted L1 entries written back to L2 if modified (for write-back scenarios). Inclusion vs exclusion policies—inclusive caches contain superset of lower levels, exclusive caches partition keyspace.

### Partitioning and Sharding

**Consistent Hashing:** Distributes keys uniformly across cache nodes with minimal reshuffling on node addition/removal. Virtual nodes improve load distribution. Jump hash provides deterministic assignment without hash ring overhead.

**Range-Based Partitioning:** Keys partitioned by range (lexicographic or numeric). Enables range queries but risks hot partition if access patterns skewed.

**Hash Slot Partitioning:** Used in Redis Cluster—16384 hash slots mapped to nodes. Slot migration for rebalancing. CRC16 hash function for slot assignment.

**Hot Key Mitigation:** Replicate hot keys across multiple cache nodes. Local L1 cache shields L2 from hot key load. Key-specific TTL reduction for high-churn hot keys.

### Replication Topologies

**Primary-Replica:** Single primary handles writes, asynchronously replicates to read replicas. Read scalability but write bottleneck at primary. Replica lag introduces read staleness.

**Multi-Primary:** Multiple primaries accept writes. Requires conflict resolution (LWW, CRDTs, application-specific merge). Higher write throughput but complex consistency semantics.

**Peer-to-Peer:** Gossip-based replication (Riak, Cassandra). Eventual consistency with tunable quorum reads/writes (R+W>N for strong consistency). Anti-entropy mechanisms for conflict reconciliation.

### CAP and PACELC Trade-offs

Caching systems typically prioritize availability and partition tolerance over consistency. Cache unavailability acceptable—degrade to data store access. Network partitions isolate cache nodes but application continues operating.

PACELC: Under normal operation (E), cache optimizes for low latency (L) over consistency (C). Under partition (P), prioritizes availability (A) over consistency (C). Tunable via synchronous vs asynchronous replication, quorum configurations, and invalidation guarantees.

### Observability Requirements

**Metrics:** Hit rate, miss rate, eviction rate, entry count, memory utilization, command latency (p50/p99), network throughput, replication lag, TTL distribution, hot key identification.

**Distributed Tracing:** Cache operations instrumented as trace spans. Correlate cache hits/misses with downstream data store queries and overall request latency.

**Logging:** Cache invalidation events, replication failures, eviction policy triggers, configuration changes.

### Security and Isolation

**Encryption:** At-rest encryption for persistent cache storage. In-transit TLS for cache cluster communication and client connections.

**Authentication/Authorization:** Client authentication via API keys, certificates, or RBAC. Key namespace isolation per tenant in multi-tenant environments.

**Injection Attacks:** Input validation on cache keys. Avoid user-controlled key construction to prevent cache poisoning or collision attacks.

**Denial of Service:** Rate limiting per client. Memory limits with bounded eviction policies. Protection against cache stampede via request coalescing and admission control.

### Related Topics

- Content Delivery Networks (CDN) and edge caching architectures
- Database query result caching and materialized views
- HTTP caching headers and reverse proxy caching
- Application-level caching frameworks (Spring Cache, Rails caching)
- CPU cache hierarchies and hardware caching protocols (MESI, MOESI)
- Distributed consensus for cache coordination (Raft, Paxos)
- CQRS and event sourcing with read-side caching
- Service mesh sidecar caching patterns
- GraphQL response caching and DataLoader patterns
- Cache warming and pre-population strategies

---

