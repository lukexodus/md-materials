## Kappa


### Topology and Execution Flow

The Kappa model unifies data processing under a single execution paradigm: stream processing. Unlike dual-path systems that segregate batch (cold) and speed (hot) layers to mitigate latency-accuracy trade-offs, Kappa treats all data as an unbounded stream. The canonical system of record is an immutable, partitioned, append-only log (e.g., Apache Kafka, Apache Pulsar).

In this topology, the "batch" processing equivalent is functionally defined as a streaming job executing over a bounded range of the log, typically from the earliest available offset to the current head. This eliminates the "logic drift" inherent in maintaining separate codebases for batch (e.g., Spark SQL/MapReduce) and streaming (e.g., Flink/Storm) engines. The topology consists of:

1. **Ingestion Layer:** Persists raw events into the immutable log with infinite (or effectively infinite via tiered storage) retention.
    
2. **Stream Processing Layer:** A single processing engine (e.g., Apache Flink, Kafka Streams, Spark Structured Streaming) executes transformations.
    
3. **Serving Layer:** State is materialized into essentially "read-optimized views" (e.g., Key-Value stores, Search Indices, OLAP cubes) for query access.
    

### State Management and Materialization

Kappa relies heavily on stateful stream processing operators to replace the aggregating capacity of batch jobs.

- **State Backends:** Operators maintain local state (e.g., RocksDB instances embedded in worker nodes) to support high-throughput `join`, `window`, and `aggregation` operations without remote lookup latency.
    
- **State Consistency:** Local state acts as a materialized view of the stream up to the current offset. Checkpointing mechanisms (e.g., Chandy-Lamport algorithm) ensure global consistency snapshots are persisted to distributed object storage (S3/HDFS).
    
- **Queryable State:** Advanced implementations expose internal operator state directly via interactive queries, blurring the line between the processing and serving layers, though externalizing state to dedicated stores (Redis, Cassandra, Druid) remains the standard for high-concurrency read patterns.
    

### Reprocessing and Determinism

Reprocessing is the primary mechanism for code updates, bug fixes, or logic changes. Instead of running an "alter table" or a batch backfill script, a new instance of the streaming job is instantiated.

- **Parallel Execution:** The new job version starts from the beginning of the log (canonical offset 0) or a specific snapshot, processing data in parallel with the currently running production job.
    
- **Output Switching:** Once the new job catches up to the real-time head of the stream (lag $\to$ 0), the downstream consumer or serving layer is switched to read from the new output topic/sink, and the old job is terminated.
    
- **Determinism Requirements:** To guarantee that replayed output matches expected results, transformation logic must be deterministic. Non-deterministic operations (e.g., calls to external systems, reliance on system time instead of event time) must be eliminated or isolated. Side effects during replay (e.g., sending emails) must be suppressed until the job catches up to the live stream.
    

### Temporal Semantics and Watermarking

Correctness in Kappa relies on strict adherence to Event Time semantics rather than Processing Time.

- **Watermark Propagation:** As data is replayed from historical logs, the ingestion rate is significantly higher than real-time generation. Watermarks (heuristic markers signifying that no events older than time $t$ will arrive) must advance based on the timestamps of records in the log, not the wall-clock time of the processing cluster.
    
- **Skew Handling:** During high-throughput replay, partition skew can occur. Watermarking strategies must account for idle partitions to prevent the global watermark from stalling, which would inhibit window firing and commit accumulation.
    
- **Late Data:** Since the log is the source of truth, "late" data is simply data at a specific offset. However, if the business logic imposes a bounded lateness threshold, reprocessing allows for re-evaluating these constraints, potentially including data previously discarded as too late in a real-time context.
    

### Schema Evolution and Compatibility

Because the log is retained indefinitely, it inevitably contains multi-versioned data.

- **Schema Registry Integration:** All serialization/deserialization must be coupled with a rigorous schema registry. The processing engine must be capable of dynamic schema resolution at runtime.
    
- **Evolution Strategy:**
    
    - **Forward Compatibility:** Old consumer code must be able to read new data (critical for rolling restarts).
        
    - **Backward Compatibility:** New consumer code must be able to read old data (critical for full replay).
        
- **Transformation Handling:** If a schema change breaks compatibility, an intermediate "adapter" job may be required to normalize the raw log into a secondary, versioned topic before the primary business logic processes it.
    

### Fault Tolerance and Semantics

- **Exactly-Once Processing:** End-to-end exactly-once semantics (EOS) are achieved through transactional coupling of the consumption offsets and the state updates/output production. (e.g., Kafka transactions or Flink's two-phase commit sinks).
    
- **Idempotency:** In the absence of transactional sinks, output operations must be idempotent. Upsert semantics into the serving layer are preferred over append-only writes to ensure that replaying a log segment does not duplicate results in the view.
    

### Scalability and Resource Management

Kappa shifts the resource bottleneck from storage I/O (random reads in batch systems) to network and CPU (sequential reads and serialization in stream systems).

- **Throughput Bursting:** Replay jobs require significantly more resources than steady-state streaming jobs to catch up quickly. Architectures often utilize elastic compute clusters (e.g., Kubernetes) to provision ephemeral resources for the duration of the replay.
    
- **Log Storage Tiering:** To make infinite retention economically viable, the underlying log system must support tiered storage, offloading cold log segments from high-performance SSDs to cheaper object storage (S3/GCS) transparently to the consumer.
    

### Related Execution Models

- Lambda
    
- Zeta
    
- Delta Lake / Lakehouse
    
- Change Data Capture (CDC)
    
- Stream-Table Duality

---

