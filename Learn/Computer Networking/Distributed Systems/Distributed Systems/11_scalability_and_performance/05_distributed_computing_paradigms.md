## Distributed Computing Paradigms


### MapReduce

**Architectural Model**

Batch-oriented data-parallel computation model designed for large-scale data processing across clusters of commodity hardware. Splits computation into two primary phases: map (stateless parallel transformation) and reduce (aggregation with shuffle). Programming model enforces functional semantics where map and reduce functions must be deterministic and side-effect-free to enable transparent fault recovery through re-execution.

**Execution Flow**

Input data partitioned into splits, typically aligned with HDFS block boundaries (64MB-128MB). Master node assigns map tasks to worker nodes, preferring data-local assignment to minimize network transfer. Map phase produces intermediate key-value pairs buffered in memory, spilled to local disk when threshold exceeded, and sorted by key. Shuffle phase transfers intermediate data from mappers to reducers based on key-space partitioning (hash or range). Reduce phase performs parallel aggregation within partitions, writing final output to distributed filesystem.

**Fault Tolerance Model**

Master maintains task state (idle, in-progress, completed) and worker heartbeats. Task failure detected via timeout or worker failure triggers re-execution on different node. Map tasks re-executed from scratch since intermediate data stored on local disk of failed worker. Reduce tasks re-executed only if incomplete or output not yet persisted. Speculative execution launches duplicate tasks for stragglers, accepting first completion. No partial failure recovery within task execution—task is atomic unit of fault tolerance.

**Data Locality and Scheduling**

Three-tier locality preference: same-node (rack-local transfer avoided), same-rack (single switch hop), off-rack (multiple switch hops). Scheduler assigns tasks based on data location advertised by distributed filesystem. Locality conflicts arise when available slots and data location misalign. Delay scheduling permits temporary scheduling delay to improve locality, trading off immediate resource utilization for reduced network transfer.

**Shuffle Architecture**

Most expensive phase due to all-to-all communication pattern. Map output partitioned by hash function over keys, written to local disk in sorted runs per partition. Reducers fetch partitions via HTTP from mapper nodes, performing merge-sort over fetched data. Shuffle represents synchronization barrier—all mappers must complete before reducers begin. Network becomes bottleneck for data-intensive workloads. Combiner functions (optional) perform map-side pre-aggregation to reduce shuffle volume.

**Scalability Constraints**

Master node represents single point of coordination, limiting cluster scale to ~4,000 nodes in original implementation. Task scheduling and metadata management become bottleneck at scale. Intermediate data shuffle scales quadratically with cluster size in worst case (M mappers × R reducers data transfers). Small file problem: excessive map tasks for fine-grained input splits overwhelm master scheduling capacity.

**Performance Characteristics**

High-latency model unsuitable for interactive queries or iterative algorithms. Job startup overhead (10s-60s) dominated by task scheduling and container allocation. Intermediate data materialization to disk adds latency but enables fault tolerance without checkpointing. Throughput-optimized rather than latency-optimized. Effective for ETL, log processing, batch analytics on cold data.

**Limitations**

Single-pass computation model requires chaining multiple jobs for complex workflows, incurring repeated disk I/O and scheduling overhead. Iterative algorithms (machine learning, graph processing) perform poorly due to repeated data loading and job initialization. No support for streaming or incremental computation. Limited expressiveness—complex operations require manual decomposition into map-reduce sequences. Shuffle barrier prevents pipelining between stages.

### Spark

**Architectural Model**

General-purpose cluster computing framework built on Resilient Distributed Datasets (RDDs) abstraction. Directed Acyclic Graph (DAG) execution model allows arbitrary composition of transformations without enforcing two-stage constraint. In-memory computation model caches intermediate results in memory across JVM heaps, eliminating repeated disk I/O for iterative workloads. Lazy evaluation defers execution until action triggered, enabling query optimization.

**Resilient Distributed Datasets (RDD)**

Immutable, partitioned collection of records distributed across cluster. Coarse-grained transformations (map, filter, join) create new RDDs without modifying source. Lineage graph tracks transformation sequence from base data, enabling fault recovery through recomputation. Persistence levels control materialization strategy: memory-only, memory-and-disk, disk-only, off-heap, replicated variants. Partitioning function determines data distribution—hash partitioning default, custom partitioners for co-location optimization.

**Execution Architecture**

Driver program constructs logical DAG of RDD transformations. DAGScheduler analyzes DAG, identifies stage boundaries at shuffle dependencies, and submits stages to TaskScheduler. Stages consist of tasks operating on single partition, executed in parallel without shuffle. TaskScheduler assigns tasks to executors based on locality preferences. Executors are long-lived JVM processes on worker nodes, maintaining in-memory cache and executing tasks in thread pools.

**Fault Tolerance and Lineage**

Lineage-based recovery eliminates need for replication of intermediate data. Partition loss triggers recomputation of missing partition by tracing lineage backward to available data. Narrow dependencies (map, filter) allow pipelined recovery within single stage. Wide dependencies (shuffle) require recomputation of parent stage partitions. Checkpointing truncates lineage for long chains, trading storage for bounded recovery cost. Driver failure requires full application restart—no automatic driver recovery in original design.

**Memory Management**

Unified memory model partitions heap into execution memory (shuffle, sort, aggregation buffers) and storage memory (cached RDDs). Dynamic allocation allows borrowing between regions under memory pressure. Eviction policies (LRU) spill cached RDDs to disk or recompute from lineage. Off-heap storage via Tachyon/Alluxio bypasses JVM garbage collection overhead. Memory pressure triggers spill-to-disk for shuffle operations, degrading to MapReduce-like performance.

**Shuffle Implementation**

Hash-based shuffle: mapper outputs partitioned by hash into separate files per reducer partition, producing M × R files. Sort-based shuffle: mapper outputs sorted and merged into single file with index, reducing file count to M files. External shuffle service decouples shuffle data from executor lifecycle, preventing data loss on executor failure. Shuffle files persisted to local disk, fetched by reducers via block manager. Configurable serialization (Java, Kryo) and compression codecs control shuffle overhead.

**DAG Scheduling and Optimization**

Stage boundaries identified at shuffle dependencies (wide transformations). TaskSetManager tracks task state within stage, handles failures, and manages speculation. Stage submission follows topological order respecting dependencies. Fusion optimization: consecutive narrow transformations pipelined into single task, eliminating intermediate materialization. Operation pushdown: filter predicates pushed toward data sources to minimize data movement.

**Data Locality Optimization**

Five locality levels: PROCESS_LOCAL (same executor), NODE_LOCAL (same machine, different executor), RACK_LOCAL (same rack), NO_PREF (no preference), ANY (arbitrary node). Delay scheduling allows waiting for preferred locality before accepting lower tier. Cached RDD partitions tracked by block manager, scheduler prioritizes tasks on nodes holding cached data. Data skew causes locality conflicts when partitions concentrated on subset of nodes.

**Dynamic Resource Allocation**

Executors added/removed based on pending task backlog and executor idle time. Minimum and maximum executor bounds prevent resource starvation and over-allocation. External shuffle service required to preserve shuffle data when executors removed. Integration with cluster managers (YARN, Mesos, Kubernetes) for resource negotiation. Overhead of executor startup (JVM initialization) limits effectiveness for short jobs.

**Catalyst Optimizer (DataFrame/Dataset API)**

Logical plan constructed from DataFrame operations, transformed through rule-based optimization passes. Predicate pushdown, projection pruning, constant folding, boolean expression simplification. Cost-based optimization uses statistics (row count, cardinality, column statistics) to select join strategies and access methods. Physical planning generates multiple candidate plans, cost model selects optimal plan. Code generation via Janino compiler produces optimized bytecode, eliminating interpretation overhead.

**Tungsten Execution Engine**

Off-heap binary format eliminates object overhead and garbage collection pressure. Unsafe memory operations bypass JVM abstractions for direct memory access. Cache-aware data structures and algorithms exploit CPU cache hierarchy. Whole-stage code generation fuses operators into single function, eliminating virtual function calls and enabling compiler optimizations. Vectorized processing for columnar formats (Parquet, ORC).

**Streaming Extensions (Spark Structured Streaming)**

Micro-batch processing model treats stream as unbounded table with incremental queries. Trigger intervals control batch frequency (fixed interval, once, continuous). Stateful operations (windowed aggregations, stream-stream joins) maintain versioned state in distributed key-value store. Checkpoint location stores offsets and state for exactly-once semantics. Watermarking defines event-time bounds for late data handling. Output modes: append (new rows only), update (changed rows), complete (entire result table).

**Scalability Envelope**

Driver memory and CPU become bottleneck at scale due to centralized task scheduling and metadata management. Shuffle scales poorly beyond 10,000 tasks per stage due to file handle limits and metadata overhead. Executor heap size constrained by garbage collection pause times—large heaps (>50GB) experience multi-second GC pauses. Broadcast variables limited by driver network bandwidth when distributing to thousands of executors.

**Performance Trade-offs**

Memory-intensive workloads constrain cluster density—fewer executors per node to avoid memory oversubscription. JVM garbage collection overhead increases with heap size and object allocation rate. Serialization overhead for shuffle and network transfer—object creation and serialization dominate CPU for data-intensive workloads. Task startup overhead (10-100ms) makes Spark inefficient for latency-sensitive workloads requiring sub-second response.

**Operational Failure Modes**

Out-of-memory errors from insufficient executor heap, excessive caching, or data skew concentrating partitions. Shuffle fetch failures from network timeouts, executor crashes during shuffle serve, or disk space exhaustion. Task stragglers from data skew, garbage collection pauses, or resource contention. Driver failures unrecoverable without external orchestration. Lineage recomputation amplification when long chains without checkpointing.

**Related Topics**

Dryad, Flink, Hadoop YARN resource management, Distributed shuffle architectures, Pregel (BSP model), Dataflow model (Beam), Query optimization in distributed systems, Adaptive query execution, Partition skew handling strategies

---

