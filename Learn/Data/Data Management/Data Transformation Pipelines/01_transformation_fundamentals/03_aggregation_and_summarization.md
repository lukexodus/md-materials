## Aggregation and Summarization


### Data Flow Topology and Ownership Boundaries

In distributed processing, aggregation nodes function as high-contention accumulation points. The topology must explicitly define `map` (local aggregation) and `reduce` (global aggregation) boundaries to minimize shuffle cost.

- **Pre-Aggregation (Combiners):** Nodes must execute partial aggregations on ingress data before network transmission. This reduces cardinality at the source, transmitting only intermediate algebraic states (e.g., `(sum, count)` tuples for averages) rather than raw record sets.
    
- **Key Grouping & Sharding:** Data ownership is determined by the hash partitioning of the grouping keys. Skew handling mechanisms (e.g., salting highly frequent keys with random suffixes) must be implemented upstream to prevent "hot" reducer partitions that straggle the entire pipeline.
    
- **Fan-in Architectures:** For high-cardinality summarizations (e.g., global counters), implement multi-tier aggregation trees (Source → Local Aggregator → Regional Aggregator → Global Sink) to distribute state updates across multiple worker nodes, avoiding single-point bottlenecks.
    

### Stateless vs Stateful Transformation Operators

Aggregation is inherently stateful. The choice of state backend dictates throughput and recovery capabilities.

- **In-Memory State:** Suitable only for bounded, low-cardinality windows. Provides lowest latency but risks OOM (Out of Memory) failures during spikes in key cardinality.
    
- **Managed Disk-Based State (e.g., RocksDB):** Mandatory for unbounded streams or high-cardinality groups. State is spilled to local SSDs, organized in Log-Structured Merge (LSM) trees.
    
    - **Incremental Checkpointing:** Only state deltas (changelogs) are flushed to durable storage (e.g., S3/HDFS) during checkpoints, decoupling snapshot time from total state size.
        
    - **State TTL:** All stateful operators must enforce Time-To-Live (TTL) eviction policies to prevent infinite state growth from zombie keys or abandoned sessions.
        

### Execution Models

- **Batch:** Executes holistic aggregations by sorting or hashing the entire dataset.
    
    - **Vectorized Execution:** Modern engines utilize SIMD instructions to aggregate columnar data batches in CPU L1/L2 cache, minimizing memory bandwidth pressure.
        
- **Streaming (Continuous):** Maintains running state. Output is triggered by watermark progression or processing time timers.
    
- **Micro-Batch:** Emulates streaming by processing small, discrete time-slices. State is persisted as "snapshots" between batches. Latency is floored by the batch interval (typically seconds), but allows for higher throughput per core due to batch compression.
    

### Partitioning, Shuffling, and Data Locality

- **Hash-Based Partitioning:** The standard strategy for `GROUP BY` operations. Deterministically routes records with the same key to the same physical node.
    
- **Broadcast Aggregation:** If one side of a join or a specific dimension table is small, it is broadcasted to all aggregation nodes to avoid shuffling the larger fact table (Map-Side Join/Aggregation).
    
- **Locality-Aware Scheduling:** The scheduler prefers placing reducer tasks on nodes containing the largest partitions of pre-aggregated map outputs to minimize cross-rack network traffic.
    

### Incremental Processing and Reprocessing

- **Algebraic Decomposition:** Aggregations must be defined algebraically (Initialize, Update, Merge, Evaluate) to support incremental re-computation.
    
    - _Example:_ A sliding window average is computed by adding entering values and subtracting exiting values from the running sum, rather than summing the entire window from scratch.
        
- **Retraction Streams:** Downstream systems must handle "retraction" or "correction" messages. If an upstream aggregation updates a previously emitted result (e.g., late data arrives), it emits a `-1` (retract) message followed by the new `+1` (accumulate) message to maintain consistency.
    
- **Merge-On-Read:** For batch reprocessing, new data increments are written as separate files. The query engine merges base data with increments at runtime, trading read latency for write throughput.
    

### Ordering Guarantees, Windowing, and Watermarks

- **Event-Time Processing:** Aggregation logic must strictly follow event timestamps, not ingestion clock time, to guarantee determinism.
    
- **Watermarks:** Monotonically increasing timestamps that signal the "completeness" of a stream up to a point in time $T$.
    
    - _Late Data handling:_ Records arriving after watermark $W$ (where $Timestamp < W$) are either dropped, diverted to a dead-letter queue (DLQ), or trigger a specific "late-fire" update depending on business SLA.
        
- **Window Types:**
    
    - _Tumbling:_ Non-overlapping, fixed-size (e.g., every 5 minutes).
        
    - _Sliding:_ Overlapping (e.g., every 1 minute, look back 5 minutes).
        
    - _Session:_ Dynamic sizing based on activity gaps (timeout), requiring complex state merging logic when out-of-order events bridge two distinct sessions.
        

### Schema Evolution

- **Binary Compatibility:** Aggregation state stored in binary formats (e.g., Avro, Protobuf) must allow for field addition without breaking state deserialization.
    
- **State Schema Migration:** If the aggregation logic changes (e.g., changing `SUM` to `AVG`), the existing state is incompatible. Strategies include:
    
    - _Savepoint & Drain:_ Stop the pipeline, drain in-flight data, restart with new logic (loses state unless manually migrated).
        
    - _Dual-Pipeline:_ Spin up the new pipeline in parallel, wait for it to hydrate its window state, then switch traffic.
        

### Fault Tolerance and Semantics

- **Exactly-Once Processing:** Achieved via distributed snapshots (e.g., Chandy-Lamport algorithm) aligning source offsets with operator state.
    
    - _Sink Idempotency:_ The final write to the data store must be idempotent or transactional (Two-Phase Commit) to prevent duplicate counting during replay.
        
- **State Recovery:** On failure, the aggregator recovers state from the last successful checkpoint and replays only the input log from the corresponding offset.
    

### Approximate Aggregation (Sketches)

For high-cardinality/holistic problems where exactness is cost-prohibitive, utilize probabilistic data structures:

- **HyperLogLog (HLL):** For `COUNT DISTINCT`. Uses $O(1)$ memory to estimate cardinality with defined error bounds (typically < 1%).
    
- **T-Digest / Q-Digest:** For `PERCENTILE` and `QUANTILE` estimation over data streams. Mergeable and parallelizable.
    
- **Bloom Filters:** For set membership checks (e.g., "Have we seen this user ID before?") to filter duplicates before aggregation.
    

### Scalability Limits and Cost Models

- **Memory Bound:** Scale is limited by the size of the "working set" (active keys).
    
- **Network Bound:** Shuffle phases in aggregations consume massive bisection bandwidth. Optimization requires maximizing map-side combiners.
    
- **Cost:** Stateful aggregations incur linear storage costs with key cardinality. Cost optimization involves aggressive TTLs and reducing the granularity of grouping keys (e.g., aggregating by minute instead of second).
    

### Related Topics

- MapReduce Programming Model
    
- Log-Structured Merge-Trees (LSM)
    
- Stream-Table Duality
    
- Change Data Capture (CDC)
    
- Vectorized Query Execution

---

