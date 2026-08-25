## Batch Processing Systems


### Execution Topology and DAG Construction

Batch processing architectures fundamentally rely on the construction and optimization of a Directed Acyclic Graph (DAG) of execution stages. Unlike streaming topologies which maintain persistent operators, batch execution materializes the DAG dynamically, allowing for global optimization prior to execution. The logical plan—comprising transformations such as `map`, `filter`, `join`, and `reduce`—is transmuted into a physical execution plan where "narrow" dependencies (pipelineable within a single partition) are fused into single stages, while "wide" dependencies (requiring data redistribution) enforce stage barriers.

- **Stage Fusion:** Pipeline compilation techniques (e.g., Whole-Stage Code Generation) fuse multiple narrow operators into a single executable function to maximize CPU register locality and minimize virtual function calls.
    
- **Barrier Synchronization:** Wide dependencies act as hard barriers. No task in the child stage can commence until all parent partitions have materialized their output, simplifying fault recovery models but introducing latency floors.
    

### Distributed Shuffle and Sort Mechanisms

The shuffle phase represents the primary bottleneck in batch architectures, dictating network I/O and disk I/O throughput. It is the mechanism by which data is redistributed across the cluster to satisfy grouping or join requirements.

- **Sort-Merge Shuffle:** The dominant strategy for large-scale batch processing. Map tasks write sorted blocks to local disk. Reducer tasks fetch relevant blocks via HTTP/RPC, merge-sort them, and process. This approach minimizes memory footprint for high-cardinality keys but incurs significant disk I/O.
    
- **Hash Shuffle:** Optimization for lower cardinality scenarios where map outputs are written to separate files for each reducer. Avoids sorting but can cause inode exhaustion and random I/O fragmentation on the OS filesystem.
    
- **External Shuffle Service:** Decouples shuffle state from executor lifecycles. This allows compute containers to be preempted or killed without losing intermediate shuffle data, essential for dynamic resource allocation and cost-spot instance usage.
    

### Partitioning Strategies and Skew Handling

Data partitioning determines parallelism and resource distribution. Incorrect partitioning leads to "straggler" tasks that define the total job duration.

- **Hash Partitioning:** Deterministic distribution using `hash(key) % num_partitions`. Vulnerable to data skew if key distribution is non-uniform.
    
- **Range Partitioning:** Used for total ordering. Requires a sampling pass (reservoir sampling) to determine partition boundaries (split points) to ensure uniform data distribution.
    
- **Salting:** A technique to mitigate skew in join operations. High-frequency keys are appended with a random suffix (salt) to disperse them across multiple partitions, forcing a broadcast join or a salted-shuffle join.
    
- **Adaptive Query Execution (AQE):** Runtime re-optimization where the engine inspects intermediate shuffle file statistics to dynamically coalesce small partitions or split skewed partitions before the reduce stage begins.
    

### Storage Interaction and Commit Protocols

Batch jobs typically interact with object stores (S3, GCS, Azure Blob) or HDFS. The "output commit" phase is critical for ensuring exactly-once semantics and data consistency.

- **Staging and Renaming (HDFS):** Tasks write to temporary directories. The driver performs a metadata operation to rename directories to the final location upon successful job completion. This is atomic on HDFS but O(N) or non-atomic on object stores.
    
- **Direct Write / Multipart Upload (Object Stores):** Modern connectors (e.g., S3A Magic Committer) utilize the atomic properties of multipart upload completion. Tasks upload data segments but do not complete the manifest. The driver commits the job by finalizing the multipart uploads, avoiding the expensive `rename` simulation (copy-delete) pattern.
    
- **Columnar Formats (Parquet/ORC):** Heavily utilized for predicate pushdown and vectorized reading. Schema enforcement is handled at the read layer, but write-side validation ensures compatibility with the target metastore.
    

### Fault Tolerance and Lineage

Batch systems utilize coarse-grained lineage tracking rather than fine-grained replication to achieve fault tolerance.

- **Recomputation:** If a task fails, the scheduler inspects the lineage graph. If the parent stage's output (shuffle data) is still available, only the failed partition is recomputed. If shuffle data is lost, the lineage is traced back to the stable source or the last checkpoint.
    
- **Speculative Execution:** The scheduler identifies tasks running significantly slower than the median and launches duplicate copies on different nodes. The first copy to commit succeeds; the other is killed. This mitigates hardware degradation or noisy neighbor issues.
    

### Resource Management and Isolation

Execution occurs within containerized environments (Kubernetes, YARN) requiring strict resource isolation.

- **Memory Management:** Heap is divided into execution memory (shuffles, joins, sorts) and storage memory (caching). Dynamic occupancy allows execution to borrow from storage, evicting cached blocks to disk (spill) to prevent OOMs during heavy transformations.
    
- **Off-Heap Memory:** Utilization of `sun.misc.Unsafe` or explicit native memory allocation for serialized data storage reduces GC pressure and enables zero-copy transfer during network shuffle.
    

### Related Topics

- MapReduce Execution Model
    
- Micro-batch Processing
    
- Lambda Architecture
    
- Kappa Architecture
    
- Vectorized Query Execution
    
- Distributed File Systems (HDFS)
    
- Table Formats (Iceberg, Hudi, Delta Lake)

---

