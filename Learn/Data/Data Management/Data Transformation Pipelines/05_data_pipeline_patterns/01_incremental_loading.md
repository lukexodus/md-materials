## Incremental Loading


### Delta Identification Mechanics

Incremental loading relies on the precise identification of the delta vector $\Delta D$ between state $T_{n}$ and $T_{n+1}$. In distributed architectures, identification strategies generally fall into three categories, each with distinct consistency guarantees and resource profiles.

- **High-Water Mark (HWM):** Relies on monotonically increasing attributes (e.g., `updated_at` timestamps or auto-incrementing `sequence_id`). The pipeline persists the maximum value observed in the previous run ($Val_{max}$) and queries the source for $Val > Val_{max}$.
    
    - _Limitation:_ Standard HWM implementations cannot detect hard deletes in the source.
        
    - _Skew Risk:_ Relies on source system clock synchronization. Clock skew or transaction commit lag (where a transaction with a lower timestamp commits after the HWM has been read) can result in silent data loss.
        
- **Log-Based Change Data Capture (CDC):** Decouples extraction from query execution by reading the source system's Write-Ahead Log (WAL) or binary logs (e.g., MySQL Binlog, PostgreSQL WAL).1
    
    - _Completeness:_ Captures all DML events (`INSERT`, `UPDATE`, `DELETE`) and DDL changes.2
        
    - _Ordering:_ Provides strict ordering guarantees per source partition/shard.
        
- **Full Diff / Hash Comparison:** Required for legacy sources lacking reliable HWM or CDC support. Involves ingesting the full dataset into a staging area and performing a distributed `FULL OUTER JOIN` or hash comparison (MD5/SHA256) against the current target state to derive the delta.
    
    - _Cost:_ Extremely high I/O and compute overhead; generally reserved for small dimension tables or strongly consistent master data.
        

### State Persistence and Checkpointing

The integrity of an incremental pipeline is defined by the atomicity of the data write and the state commit (the offset or HWM).

- **Dual-Phase Commit (2PC):** Required when the state store and the data target are distinct systems (e.g., storing offsets in Zookeeper while writing data to S3). Failure during the window between data write and offset commit leads to duplicate processing (requiring idempotency) or data loss.
    
- **Transactional Lakes:** Modern table formats (Delta Lake, Apache Iceberg, Apache Hudi) embed the operation metadata within the storage layer itself.3 The "last processed version" or commit timestamp is stored as a transaction property, ensuring that data materialization and state advancement are an atomic unit.
    
- **Source-Aligned Checkpoints:** In streaming implementations (e.g., Flink), checkpoints align with source offsets (Kafka offsets). On recovery, the system rewinds to the last stable checkpoint, ensuring exactly-once processing via state rollback.
    

### Target Materialization Patterns

Applying increments to distributed file systems (HDFS/S3) or columnar stores is non-trivial due to the immutable nature of the underlying blocks/objects.

- **Copy-on-Write (CoW):** When an `UPDATE` or `DELETE` affects a record, the entire file/partition containing that record is rewritten with the new version.
    
    - _Profile:_ High write amplification, optimal read performance. Suitable for read-heavy workloads with low-frequency updates.
        
- **Merge-on-Read (MoR):** Updates are appended to separate delta log files (row-based, e.g., Avro) rather than rewriting the base files (columnar, e.g., Parquet). A compaction service asynchronously merges delta logs into base files.
    
    - _Profile:_ Low write latency, variable read latency (readers must reconcile base + delta files at runtime). Suitable for high-frequency streaming ingestion.
        
- **Partition Swapping:** For partition-based increments, data is written to a staging directory. Upon completion, a metadata operation (atomic rename or partition registration) swaps the new data into the production table, ensuring read isolation during the write process.
    

### Handling Deletes and Hard Updates

Standard HWM pipelines fail to capture physical deletions. Architectures must implement specific patterns to address this:

- **Soft Deletes:** Source systems implement logical deletes (e.g., `is_deleted=true`). The HWM strategy treats this as a standard update.
    
- **Tombstoning:** In message bus architectures (Kafka), a delete is represented as a message with a `null` payload (tombstone).4 The downstream consumer interprets this as a command to remove the key from the materialized view.
    
- **Periodic Reconciliation:** A hybrid pattern where frequent low-latency incremental loads (HWM) are supplemented by infrequent full-load reconciliation jobs (e.g., weekly) to garbage-collect orphaned records missed by the HWM strategy.5
    

### Late Arriving Data and Watermarks

In event-time processing, data may arrive significantly later than its generation timestamp due to network partitions or source outages.

- **Watermarking:** A dynamic threshold defining how long the system waits for late data before finalizing a window or batch. Data arriving after the watermark is either discarded, diverted to a side-output (dead letter queue) for manual remediation, or triggers a re-computation of the previously finalized result (retraction/correction).
    
- **Lookback Windows:** In HWM batch scenarios, the query often includes a safety buffer (e.g., `WHERE updated_at > Last_Run_Time - Buffer_Interval`) to catch transactions that committed late but carried earlier timestamps. This introduces intentional duplication, mandating deduplication logic in the transformation layer.
    

### Schema Evolution in Increments

Incremental pipelines are tightly coupled to source schemas.

- **Additive Changes:** New columns in the source can often be handled by schema evolution features in formats like Parquet/Avro (schema merging).6 The target schema is updated, and previous files are read with nulls for the new column.
    
- **Destructive Changes:** Column renames or type changes break the append-only contract. This typically triggers a "Schema Reset," forcing a new full load or a complex in-place migration of the historical data to align with the new schema version.
    

### Related Execution Models

- Change Data Capture (CDC)
    
- Slowly Changing Dimensions (SCD Type 1/2)
    
- Lambda Architecture
    
- Kappa Architecture
    
- Micro-batch Processing

---

