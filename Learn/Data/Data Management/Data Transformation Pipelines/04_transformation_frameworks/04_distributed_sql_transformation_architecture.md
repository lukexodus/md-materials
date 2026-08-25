## Distributed SQL Transformation Architecture


### Query Compilation and Optimization Lifecycle

In distributed data processing (MPP, Spark SQL, Trino), SQL transformations undergo a multi-phase compilation process converting declarative logic into executable DAGs.

- **Logical Planning:** The `Unresolved Logical Plan` is validated against the catalog (schema resolution). The `Analyzed Logical Plan` is then subjected to Rule-Based Optimization (RBO), applying heuristics such as:
    
    - **Predicate Pushdown:** Moving filters (`WHERE` clauses) as close to the data source as possible to minimize I/O and network transfer.
        
    - **Column Pruning:** Projecting only the subset of columns required by downstream operators or the final result.
        
    - **Constant Folding:** Pre-calculating static expressions at compile time.
        
- **Cost-Based Optimization (CBO):** The optimizer generates multiple `Physical Plans` and selects the most efficient one based on table statistics (cardinality, distinct counts, min/max values, histograms). Cost models evaluate the expense of CPU usage, I/O scans, and network shuffles.
    
- **Whole-Stage Code Generation:** Modern engines (e.g., Spark with Tungsten) collapse the traditional "Volcano Iterator Model" (row-at-a-time virtual function calls) into fused, optimized bytecode or native machine code (LLVM) for an entire stage, keeping data in L1/L2 CPU caches and enabling SIMD instructions.
    

### Distributed Join Strategies

Joins are typically the most expensive operations in SQL-based pipelines due to required data movement. The physical execution strategy is determined by table size and distribution.

- **Broadcast Hash Join (Map-Side Join):**
    
    - **Mechanism:** If one relation is small enough (fitting within a configurable memory threshold), the driver broadcasts the entire table to all worker nodes.
        
    - **Performance:** Eliminates the shuffle phase for the large table.
        
    - **Constraint:** Bounded by driver memory and broadcast timeout limits.
        
- **Shuffle Hash Join:**
    
    - **Mechanism:** Both tables are partitioned (shuffled) based on the join key. Each partition is processed independently. A hash table is built for the smaller partition on each executor, and the larger partition is probed against it.
        
    - **Use Case:** Suitable when neither table fits in memory, but partition-wise hash tables do.
        
- **Sort-Merge Join (SMJ):**
    
    - **Mechanism:** Both tables are shuffled on the join key, sorted within each partition, and then merged via a linear scan.
        
    - **Robustness:** The default strategy for massive datasets in many engines (e.g., Spark) as it handles memory pressure by spilling sorted runs to disk, avoiding OOM errors common in Hash Joins.
        

### Data Layout and I/O Optimization

Efficient SQL transformations rely heavily on the physical layout of the underlying data, particularly in Data Lake/Lakehouse architectures.

- **Partition Pruning:** The engine inspects filter predicates against directory structures (e.g., `/date=2024-01-01/`) to skip scanning irrelevant partitions entirely.
    
- **Data Skipping (Zone Maps/Min-Max):** Using metadata headers in columnar file formats (Parquet, ORC), the engine skips Row Groups or specific data pages if the column statistics indicate the target value cannot exist within that block.
    
- **Vectorized Readers:** Decodes columnar data in batches (vectors) rather than row-by-row, amortizing the overhead of type checking and virtual function calls.
    
- **Z-Ordering / Space-Filling Curves:** A physical layout optimization that co-locates related data points in multi-dimensional space, significantly improving data skipping effectiveness for queries filtering on multiple columns.
    

### Skew Handling and Adaptive Execution

Data skew—where specific partition keys have disproportionately high cardinality—causes straggler tasks that dictate total pipeline latency.

- **Adaptive Query Execution (AQE):** Re-optimizes the query plan at runtime based on intermediate execution statistics.
    
    - **Dynamically Coalescing Shuffle Partitions:** Merging small partitions post-shuffle to prevent task scheduling overhead.
        
    - **Skew Join Optimization:** Automatically detecting skewed keys, splitting the skewed partition into smaller sub-tasks, and replicating the corresponding join partner (salting) to parallelize processing.
        
- **Salting:** A manual or automated technique where a random prefix is added to join keys to redistribute data uniformly across the cluster, preventing single-executor bottlenecks.
    

### Intermediate State and Materialization

Managing intermediate results within complex SQL chains (CTEs, subqueries).

- **Pipelining vs. Blocking:** Most operators (Filter, Project) are pipelined. Aggregations and Joins are blocking boundaries (Stages) that require data to be materialized to shuffle buffers (disk/memory).
    
- **CTE Materialization:** Common Table Expressions can be treated as inline views (re-computed every time referenced) or materialized cached datasets (computed once, stored in memory/disk). This behavior varies by engine and often requires explicit hinting.
    
- **Spill-to-Disk:** When execution memory (RAM) is exhausted by hash tables or sort buffers, the engine serializes data to local ephemeral storage. This prevents failure but significantly degrades performance due to disk I/O latency.
    

### Transactional Guarantees (Lakehouse Semantics)

In modern Lakehouse architectures (Delta Lake, Iceberg, Hudi), SQL transformations operate with ACID guarantees over object storage.

- **Snapshot Isolation:** Readers see a consistent snapshot of the table at the start of the query. Writers do not block readers.
    
- **Optimistic Concurrency Control (OCC):** Write conflicts are resolved by checking if the data modified by a concurrent transaction overlaps with the current transaction's scope.
    
- **Merge-on-Read (MoR) vs. Copy-on-Write (CoW):**
    
    - **CoW:** Updates rewrite entire data files. High write latency, optimal read performance. Best for heavy read workloads.
        
    - **MoR:** Updates are written to delta logs or row-based delta files. Merging happens at read time. Lower write latency, higher read overhead. Best for streaming ingestion.
        

### Related Topics

- dbt (Data Build Tool) Compilation Logic
    
- Columnar Storage Formats (Parquet, ORC, Avro)
    
- Vectorized Query Execution
    
- Massively Parallel Processing (MPP) Architecture
    
- Data Lakehouse Table Formats (Delta Lake, Apache Iceberg, Apache Hudi)

---

