## Module 3: NoSQL Databases


### 3.1 NoSQL Overview

- Motivation and trade-offs vs relational
- Schema flexibility
- Horizontal scalability approaches
- Consistency vs availability trade-offs
- Use case selection criteria

### 3.2 Key-Value Stores

- Data model and operations
- Hash partitioning
- Consistent hashing
- Use cases: session storage, caching, user preferences

#### 3.2.1 Redis

- Data structures (strings, lists, sets, sorted sets, hashes, streams)
- Persistence options (RDB, AOF)
- Pub/sub messaging
- Lua scripting
- Redis Cluster architecture
- Sentinel for high availability

#### 3.2.2 Other Key-Value Systems

- DynamoDB: Partition/sort keys, GSI/LSI, capacity modes
- Memcached: Memory-only caching
- etcd: Distributed configuration
- Riak: Multi-datacenter replication

### 3.3 Document Databases

- Document model (JSON/BSON)
- Flexible schemas
- Embedded vs referenced documents
- Secondary indexes
- Use cases: content management, catalogs, user profiles

#### 3.3.1 MongoDB

- Collections and documents
- Query language and operators
- Aggregation pipeline
- Replica sets
- Sharding architecture
- Change streams
- Transactions support

#### 3.3.2 Other Document Systems

- Couchbase: N1QL, mobile sync
- CouchDB: HTTP API, eventual consistency
- Amazon DocumentDB: MongoDB-compatible
- Firestore: Real-time sync, offline support

### 3.4 Column-Family Stores

- Wide-column model
- Column families and columns
- Row keys and column keys
- Denormalization patterns
- Use cases: time-series, analytics, IoT

#### 3.4.1 Apache Cassandra

- Ring architecture and consistent hashing
- Tunable consistency (ONE, QUORUM, ALL)
- CQL (Cassandra Query Language)
- Compaction strategies
- Repair and consistency maintenance
- Multi-datacenter replication

#### 3.4.2 Other Column-Family Systems

- HBase: HDFS integration, strong consistency
- ScyllaDB: C++ rewrite of Cassandra
- Google Bigtable: Managed service
- Azure Cosmos DB: Multi-model support

### 3.5 Graph Databases

- Graph model: nodes, edges, properties
- Traversal algorithms
- Path queries
- Use cases: social networks, recommendation engines, fraud detection

#### 3.5.1 Neo4j

- Cypher query language
- ACID transactions
- Index-free adjacency
- Clustering and causal clustering
- Graph algorithms library

#### 3.5.2 Other Graph Systems

- Amazon Neptune: Property graph and RDF
- JanusGraph: Distributed graph database
- ArangoDB: Multi-model with graph support
- TigerGraph: Real-time deep link analytics

### 3.6 Time-Series Databases

- Time-series data characteristics
- Downsampling and aggregation
- Retention policies
- Use cases: monitoring, IoT, financial data

#### 3.6.1 Systems

- InfluxDB: Tags and fields, Flux language
- TimescaleDB: PostgreSQL extension
- Prometheus: Metrics and monitoring
- OpenTSDB: HBase-backed storage

---

