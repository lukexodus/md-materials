## Module 5: Data Lakes


### 5.1 Data Lake Architecture

- Schema-on-read vs schema-on-write
- Raw, processed, and curated zones
- Metadata management
- Data cataloging
- Governance and lineage
- Lake house architecture

### 5.2 Storage Formats

- Parquet: Columnar, compression, nested data
- ORC: Optimized row columnar, ACID
- Avro: Row-based, schema evolution
- JSON and CSV: Human-readable formats
- Delta Lake format
- Iceberg format
- Hudi format

### 5.3 Data Lake Platforms

#### 5.3.1 Cloud Object Storage

- Amazon S3: Versioning, lifecycle, storage classes
- Azure Data Lake Storage: Hierarchical namespace, ACLs
- Google Cloud Storage: Uniform/fine-grained access

#### 5.3.2 Processing Frameworks

- Apache Hadoop: HDFS, MapReduce
- Apache Spark: RDDs, DataFrames, Catalyst optimizer
- Apache Flink: Stream processing, state management
- Presto/Trino: Distributed SQL query engine
- Apache Hive: SQL on Hadoop, metastore

### 5.4 Lake House Patterns

- Delta Lake: ACID transactions, time travel, schema evolution
- Apache Iceberg: Hidden partitioning, snapshot isolation
- Apache Hudi: Incremental processing, record-level updates
- Table format comparison

### 5.5 Data Lake Challenges

- Data swamps prevention
- Metadata management
- Data quality monitoring
- Access control and security
- Cost optimization
- Performance tuning

### 5.6 Data Lake Use Cases

- Raw data archive
- Machine learning feature stores
- Data science exploration
- Batch analytics
- Real-time streaming integration

---

