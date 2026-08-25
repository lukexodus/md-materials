## Storage Engine and Data Structures


### SSTables (Sorted String Tables)

SSTables form the foundation of Cassandra's persistent storage layer, representing immutable, sorted files that contain key-value pairs along with metadata. Each SSTable consists of multiple components that work together to provide efficient data access and storage.

**SSTable Components**:

- **Data file (.db)**: Contains the actual row data in a binary format, with rows sorted by partition key and clustering columns
- **Index file (.Index.db)**: Stores partition key offsets pointing to locations in the data file, enabling fast partition lookups
- **Summary file (.Summary.db)**: Contains a sampling of partition keys from the index file, loaded into memory for quick index navigation
- **Filter file (.Filter.db)**: Houses bloom filter data to quickly determine if a partition key exists in the SSTable
- **Statistics file (.Statistics.db)**: Stores metadata including row counts, tombstone counts, and compaction-related statistics
- **Digest file (.Digest.crc32)**: Contains checksums for data integrity verification

**SSTable Structure and Organization**: Each SSTable organizes data hierarchically, starting with partitions identified by partition keys. Within each partition, rows are ordered by clustering columns, and within each row, columns are stored with their names, values, and timestamps. This structure enables efficient range queries and supports Cassandra's wide-row data model.

**Immutability Benefits**: SSTables' immutable nature provides several advantages including simplified concurrent access patterns, reduced locking overhead, and enhanced data safety. Once written, SSTables never change, eliminating concerns about partial writes or corruption during updates. This design enables Cassandra to achieve high write throughput while maintaining data consistency.

### Memtables and Commit Logs

**Memtable Architecture**: Memtables serve as in-memory representations of data before it gets written to disk as SSTables. Each column family maintains its own memtable, implemented as a sorted data structure that maintains the same ordering as SSTables. Memtables store the most recent data modifications and serve as the primary source for recent writes during read operations.

**Write Path Process**: When Cassandra receives a write operation, it first appends the operation to the commit log for durability, then updates the corresponding memtable. This dual-write approach ensures data persistence while maintaining fast write performance. The memtable accumulates changes until it reaches configurable size thresholds or time limits.

**Commit Log Functionality**: The commit log provides write-ahead logging to ensure durability of operations before they reach persistent storage. Cassandra writes commit log entries sequentially to disk, optimizing for write performance. Each commit log entry contains the keyspace, column family, and mutation data necessary to reconstruct lost memtable contents during recovery scenarios.

**Flush Operations**: Memtables flush to disk as SSTables when they exceed size thresholds (typically 64MB) or after specific time intervals. During flush operations, Cassandra creates new SSTables while continuing to serve reads from existing memtables and SSTables. This process maintains system availability while transitioning data from memory to persistent storage.

**Recovery Mechanisms**: During startup or failure recovery, Cassandra replays commit log entries to reconstruct memtables that weren't flushed before shutdown. The system tracks which commit log segments correspond to flushed SSTables, allowing safe cleanup of old commit log files while maintaining recovery capabilities.

### Compaction Strategies

Compaction strategies determine how Cassandra merges SSTables to maintain read performance and manage disk space utilization. Different strategies optimize for various workload patterns and operational requirements.

**Size Tiered Compaction Strategy (STCS)**: STCS groups SSTables of similar sizes and merges them when enough tables accumulate in each size tier. This strategy works well for write-heavy workloads with time-series data patterns. However, it can create large SSTables over time and may not efficiently handle data with high update frequencies.

**Leveled Compaction Strategy (LCS)**: LCS organizes SSTables into levels, with each level containing approximately 10 times more data than the previous level. This strategy maintains smaller, more predictable SSTable sizes and provides better read performance for workloads with frequent updates. LCS requires more I/O overhead but offers more consistent performance characteristics.

**Time Window Compaction Strategy (TWCS)**: TWCS groups SSTables based on time windows, making it ideal for time-series workloads where data has natural expiration patterns. This strategy enables efficient deletion of entire time windows and works particularly well with TTL-based data lifecycle management.

**Incremental Compaction Strategy (ICS)**: [Unverified] ICS represents a newer approach that aims to reduce compaction overhead by performing smaller, more frequent compaction operations. This strategy attempts to balance the benefits of other strategies while minimizing resource utilization spikes.

**Compaction Process Details**: During compaction, Cassandra reads multiple SSTables, merges their contents while resolving conflicts using timestamps, removes tombstoned data past gc_grace_seconds, and writes the result as new SSTables. The process maintains data ordering and updates secondary indexes as necessary.

### Bloom Filters and Compression

**Bloom Filter Implementation**: Cassandra employs bloom filters as probabilistic data structures to quickly determine whether a partition key might exist in an SSTable without reading the actual data. Each SSTable maintains its own bloom filter, loaded into memory during startup to accelerate read operations.

**Bloom Filter Characteristics**: Bloom filters provide fast negative lookups with no false negatives but may produce false positives. Cassandra configures bloom filter sizing based on the expected number of partitions and desired false positive rates. Typical configurations target false positive rates between 0.01% and 1%, balancing memory usage with lookup efficiency.

**Compression Algorithms**: Cassandra supports multiple compression algorithms including LZ4, Snappy, and Deflate for SSTable compression. LZ4 provides fast compression and decompression with moderate compression ratios, making it suitable for most workloads. Snappy offers similar performance characteristics, while Deflate achieves higher compression ratios at the cost of increased CPU usage.

**Compression Configuration**: Column families can configure compression parameters including algorithm selection, chunk sizes, and compression ratios. Smaller chunk sizes enable more granular decompression but may reduce compression efficiency. Larger chunks improve compression ratios but require reading more data for small access patterns.

**Block-Level Compression**: Cassandra compresses SSTables at the block level rather than compressing entire files, enabling efficient random access to compressed data. This approach allows the database to decompress only the specific blocks needed for read operations rather than entire SSTables.

### Column Family Storage Model

**Keyspace and Column Family Hierarchy**: Cassandra organizes data within keyspaces, which function similarly to database schemas in relational systems. Each keyspace contains multiple column families (tables), and each column family defines the structure and storage characteristics for related data.

**Partition and Row Structure**: Column families store data in partitions identified by partition keys, with each partition containing multiple rows organized by clustering columns. This structure enables efficient data distribution across cluster nodes while maintaining ordering within partitions for range queries.

**Wide Row Support**: Cassandra's storage model supports wide rows containing millions of columns, enabling use cases like time-series data storage where each row represents a partition key and columns represent time-ordered data points. This model efficiently stores sparse data where different rows may contain different sets of columns.

**Column Storage Format**: Individual columns store names, values, timestamps, and optional TTL information. Column names can be dynamic, enabling flexible schema evolution without requiring DDL changes. The storage format optimizes for both dense columns (present in most rows) and sparse columns (present in few rows).

**Secondary Index Storage**: Secondary indexes maintain separate column families that store mappings from indexed column values to partition keys. These indexes enable efficient queries on non-partition key columns but require additional storage overhead and maintenance during write operations.

**Materialized View Storage**: Materialized views create additional column families with different partition and clustering key arrangements, enabling efficient queries with different access patterns. Cassandra maintains these views automatically, updating them when base table data changes.

**Storage Optimization Features**: The column family storage model includes various optimization features such as column compression, where repeated column names are stored efficiently, and row-level TTL support for automatic data expiration. These features enable efficient storage utilization while supporting diverse application requirements.

**Key points**: Cassandra's storage engine combines multiple data structures and strategies to provide scalable, high-performance data storage. SSTables provide immutable, sorted persistent storage while memtables enable fast writes. Compaction strategies manage SSTable organization for optimal read performance, while bloom filters and compression reduce I/O requirements. The column family model enables flexible schema design while maintaining efficient storage characteristics.

**Important related topics**: SSTable format evolution and compatibility, compaction tuning and monitoring, memory management and heap optimization, storage performance optimization techniques, and data lifecycle management strategies.

---

