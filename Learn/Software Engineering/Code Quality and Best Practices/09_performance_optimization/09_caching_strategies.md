## Caching Strategies


### Architectural Patterns

Cache-Aside (Lazy Loading)

The application code maintains responsibility for loading data into the cache. On a cache miss, the application reads from the system of record (SoR) and updates the cache.

- **Use Case:** Read-heavy workloads with resilient tolerance for eventual consistency.
    
- **Edge Case - Stale Data:** There is a race condition if data is updated in the SoR immediately after a cache miss but before the cache is populated by the reading thread.
    
- **Anti-Pattern:** Using Cache-Aside for write-heavy data results in high churn and cache thrashing, negating performance gains.
    

Read-Through

The cache serves as the primary data store proxy. The application queries the cache; if a miss occurs, the cache component (provider) loads the data from the SoR transparently.

- **Implementation Note:** Requires the cache provider to have specific knowledge of the data model or a plugin mechanism (e.g., `CacheLoader` in Ehcache/Guava).
    
- **Advantage:** Simplifies application code; creates a "thinner" client.
    

Write-Through

Data is written to the cache and the SoR synchronously. The write is confirmed only when both are updated.

- **Consistency:** Provides strong data consistency (Read-your-writes).
    
- **Latency Penalty:** Write latency is strictly defined by the slowest write operation (typically the SoR).
    
- **Best Practice:** Combine with Read-Through to ensure the cache is always fresh and eliminates the "first-read" penalty of Cache-Aside.
    

Write-Behind (Write-Back)

Data is written to the cache immediately, and the acknowledgement is sent to the client. The write to the SoR occurs asynchronously via a queue or background thread.

- **Risk:** High risk of data loss if the cache node crashes before flushing to the SoR.
    
- **Mitigation:** Implementation of Write-Ahead Logs (WAL) or replication to non-volatile memory before acknowledgement.
    
- **Optimization:** Allows for **Write Coalescing** (merging multiple updates to the same key) and batch processing to reduce IOPS on the database.
    

### Concurrency and Failure Modes

Cache Stampede (Thundering Herd)

Occurs when a "hot" key expires or is evicted, causing simultaneous requests to penetrate the cache and hit the database, potentially causing cascading failure.

- **Mitigation 1: Probabilistic Early Expiration.** Introduce a randomization factor (jitter) to the TTL or use an algorithm like X-Fetch, where the application recomputes the value probabilistically before the physical TTL expires.
    
- **Mitigation 2: Mutex Locking.** The first thread to encounter a miss acquires a lock (or a distributed lease) to regenerate the value. Other threads block or return stale data (Soft TTL) until the lock is released.
    

Cache Penetration

Requests for keys that do not exist in the SoR (and thus are never cached) constantly hit the database. This is often a vector for DoS attacks.

- **Solution:** Implement **Bloom Filters**. Before querying the cache or DB, check the Bloom filter to verify if the key _might_ exist. If the filter returns negative, short-circuit the request.
    
- **Alternative:** Cache `null` or empty objects with a short TTL.
    

Cache Avalanche

A massive number of keys expire simultaneously, causing a spike in DB load.

- **Implementation:** Never use fixed TTLs for batch-loaded data. Append a random variance (e.g., TTL + `rand(0, 300)s`) to disperse expiration times.
    

### Distributed Caching Topologies

Sharded Caching (Partitioned)

Data is distributed across multiple nodes using consistent hashing (e.g., Ring Hash with vnodes).

- **Scalability:** Linearly scalable storage capacity.
    
- **Resiliency:** Loss of a node only invalidates $1/N$ of the cache.
    
- **Constraint:** Does not support multi-key operations transactionally.
    

Near-Cache (L1/L2 Architecture)

Combines a local in-process cache (L1) with a remote distributed cache (L2).

- **Latency:** L1 provides microsecond-level access.
    
- **Complexity - Invalidation:** Requires a pub/sub mechanism (e.g., Redis Pub/Sub, JMS) to broadcast invalidation messages to all L1 instances when data changes. Without this, L1 caches drift significantly.
    

### Advanced Eviction Policies

Scan Resistance

Standard LRU (Least Recently Used) is vulnerable to full table scans. A single one-off operation traversing large datasets can flush the entire hot set.

- **SLRU (Segmented LRU):** Splits cache into "probationary" and "protected" segments. New items enter probation; only subsequent hits promote them to protected status.
    
- **TinyLFU:** Uses a Count-Min Sketch to approximate access frequency with minimal memory overhead. It rejects new items unless their estimated frequency is higher than the victim item in the cache (Admission Policy over Eviction Policy).
    

**Time-based Eviction**

- **Sliding Window:** Extends TTL on access. Useful for session data.
    
- **Fixed Window:** Hard expiration regardless of access frequency. Essential for data with strict freshness requirements (e.g., regulatory financial data).


---

