## Table of Contents: Elasticsearch

### Introduction to Elasticsearch

- What is Elasticsearch
- History and evolution of the Elastic Stack
- Use cases and industry applications
- Elasticsearch vs relational databases
- Elasticsearch vs other search engines
- Core concepts overview
- The Elastic Stack ecosystem (Kibana, Logstash, Beats, Fleet)

### Installation and Environment Setup

- System requirements and prerequisites
- Installing Elasticsearch on Linux
- Installing Elasticsearch on macOS
- Installing Elasticsearch on Windows
- Docker and Docker Compose setup
- Kubernetes deployment basics
- Directory structure and configuration files
- Environment variables and JVM options
- Running multiple nodes locally

### Core Architecture

- Nodes and node roles
- Clusters and cluster formation
- Shards and replicas
- Primary vs replica shards
- Index lifecycle overview
- Segment merging and Lucene internals
- The inverted index
- Document routing
- Write path and read path

### Data Modeling and Indexing

- Indices, documents, and fields
- Mappings and mapping types
- Dynamic vs explicit mappings
- Field data types
- Multi-fields
- Nested objects and nested type
- Parent-child relationships (join field)
- Index templates
- Component templates
- Index aliases
- Data streams

### CRUD Operations

- Indexing a document
- Retrieving a document by ID
- Updating a document
- Partial updates with update API
- Deleting a document
- Bulk API
- Multi-get API
- Upserts
- Optimistic concurrency control
- Version types and sequencing

### Search Fundamentals

- The search API
- URI search vs request body search
- Query DSL overview
- Relevance scoring and TF-IDF
- BM25 scoring model
- Explain API
- Source filtering
- Pagination (from/size)
- Search after and point-in-time API
- Scroll API

### Query DSL – Full Text Queries

- match query
- match_phrase query
- match_phrase_prefix query
- multi_match query
- query_string query
- simple_query_string query
- intervals query
- Boosting fields and queries

### Query DSL – Term Level Queries

- term query
- terms query
- range query
- exists query
- prefix query
- wildcard query
- regexp query
- fuzzy query
- ids query
- terms_set query

### Query DSL – Compound Queries

- bool query (must, should, must_not, filter)
- boosting query
- constant_score query
- dis_max query
- function_score query
- script_score query

### Query DSL – Specialized Queries

- nested query
- has_child and has_parent queries
- percolate query
- more_like_this query
- wrapper query
- pinned query
- knn query

### Filters, Sorting, and Field Collapsing

- Filter context vs query context
- Filter caching
- Sorting by field value
- Sorting by score
- Sorting by geo distance
- Sort on nested fields
- Field collapsing

### Aggregations

- Aggregation structure and syntax
- Bucket aggregations overview
- terms aggregation
- histogram aggregation
- date_histogram aggregation
- range aggregation
- filter and filters aggregation
- nested aggregation
- Metric aggregations overview
- avg, sum, min, max, value_count
- stats and extended_stats
- cardinality aggregation
- percentiles and percentile_ranks
- top_hits aggregation
- Pipeline aggregations overview
- derivative and cumulative_sum
- moving_avg and moving_fn
- bucket_sort and bucket_selector
- Composite aggregation
- Significant terms and significant text

### Text Analysis

- Analysis pipeline overview
- Character filters
- Tokenizers
- Token filters
- Built-in analyzers
- Custom analyzers
- Language analyzers
- Normalizers
- Analyze API
- Index-time vs search-time analysis
- Synonym handling
- Stop words configuration

### Geo and Spatial Search

- geo_point field type
- geo_shape field type
- geo_distance query
- geo_bounding_box query
- geo_polygon query
- geo_shape query
- Geo aggregations (geo_distance, geohash_grid, geotile_grid)
- Sorting by geo distance

### Vector Search and Semantic Search

- dense_vector field type
- sparse_vector field type
- kNN search API
- Approximate kNN vs exact kNN
- HNSW algorithm basics
- Hybrid search (combining kNN and BM25)
- Semantic search with ELSER
- Inference API and model management
- Embedding model integration

### Mappings and Schema Management

- Viewing and updating mappings
- Dynamic mapping rules
- Dynamic templates
- Mapping explosion and field limit
- Runtime fields
- Flattened field type
- Keyword vs text field decisions
- Mapping versioning and migration

### Index Management

- Open and close index
- Reindex API
- Shrink and split index
- Clone index
- Rollover API
- Index lifecycle management (ILM)
- ILM phases (hot, warm, cold, frozen, delete)
- Searchable snapshots
- Force merge
- Refresh and flush

### Cluster Management and Operations

- Cluster health API
- Cluster stats and node stats
- Cat APIs
- Shard allocation and awareness
- Cluster reroute API
- Master node election
- Voting configuration
- Cluster settings (transient vs persistent)
- Hot-warm-cold architecture
- Cross-cluster replication (CCR)
- Cross-cluster search (CCS)

### Snapshot and Restore

- Snapshot repository types
- Registering a repository
- Creating snapshots
- Restoring snapshots
- Incremental snapshots
- Snapshot lifecycle management (SLM)
- Backup strategies

### Security

- Enabling security (TLS and authentication)
- Built-in users and password setup
- Role-based access control (RBAC)
- Index-level and document-level security
- Field-level security
- API keys
- SAML and OIDC integration
- LDAP and Active Directory integration
- Audit logging
- Encryption at rest

### Performance Tuning

- Indexing performance optimization
- Bulk indexing best practices
- Refresh interval tuning
- Merge policy tuning
- Search performance optimization
- Filter caching strategy
- Fielddata and doc values
- Query profiling with Profile API
- Shard sizing guidelines
- JVM heap and GC tuning
- Circuit breakers
- Thread pool configuration
- Hardware and disk considerations

### Monitoring and Observability

- Cluster monitoring overview
- Stack Monitoring in Kibana
- Node and index metrics
- Slow log configuration (index and search)
- Task management API
- Hot threads API
- Metricbeat for monitoring
- Alerting with Watcher
- Elastic Observability integration

### Ingest Pipelines

- Ingest node overview
- Creating and testing pipelines
- Common processors (set, rename, remove, grok, date, convert)
- Conditional processors
- Pipeline on index and bulk requests
- Failure handling in pipelines
- Enrich processor and enrich policies
- GeoIP processor
- Inference processor

### Logstash Integration

- Logstash architecture and pipeline
- Input plugins
- Filter plugins (grok, mutate, date)
- Output plugin for Elasticsearch
- Multiple pipelines
- Dead letter queues
- Persistent queues
- Logstash monitoring

### Beats and Data Collection

- Filebeat overview and configuration
- Metricbeat overview and configuration
- Packetbeat and Heartbeat
- Winlogbeat and Auditbeat
- Beats modules
- Fleet and Elastic Agent
- Agent policies and integrations

### Kibana Essentials

- Connecting Kibana to Elasticsearch
- Index patterns and data views
- Discover for ad hoc exploration
- Lens and Visualize
- Dashboards
- Canvas
- Maps application
- Dev Tools console
- Stack Management

### The Elasticsearch Client Libraries

- Official clients overview
- Python client
- JavaScript and Node.js client
- Java client
- Go client
- .NET client
- Connection pooling and sniffing
- Retry and error handling patterns
- Bulk helpers in clients

### Advanced Search Features

- Suggesters (term, phrase, completion)
- Autocomplete design patterns
- Highlighting
- Search templates
- Async search API
- Rank feature and rank features field
- Learning to rank (LTR)
- Percolator and reverse search
- Named queries

### Data Streams and Time Series

- Data stream concepts
- Creating and managing data streams
- Backing indices
- Rollover with data streams
- Downsampling time series data
- TSDS (time series data stream) mode
- Synthetic source

### Machine Learning Features

- Anomaly detection jobs
- Datafeed configuration
- Single and multi-metric jobs
- Population analysis
- Forecast API
- Data frame analytics overview
- Outlier detection
- Classification and regression jobs
- Feature importance
- Trained model management
- NLP model deployment

### Application Integration Patterns

- Pagination strategies for production
- Index alias rollover pattern
- Write alias and read alias pattern
- Zero-downtime reindexing
- Search-as-you-type pattern
- Faceted search design
- Multi-tenancy patterns
- Caching layers in front of Elasticsearch
- Event-driven indexing patterns

### Testing and Debugging

- Validate API
- Explain API for scoring
- Profile API for query performance
- Field capabilities API
- Simulate ingest pipeline API
- Integration testing strategies
- Using Docker for test environments
- Mocking Elasticsearch in unit tests

### Upgrades and Migration

- Rolling upgrade process
- Full cluster restart upgrade
- Breaking changes review process
- Reindex for major version migration
- Deprecation API and deprecation logs
- Elasticsearch upgrade assistant
- Mapping and index compatibility

### Production Readiness and Best Practices

- Cluster sizing and capacity planning
- Shard count recommendations
- Deployment topology patterns
- High availability configuration
- Disaster recovery planning
- Security hardening checklist
- Index naming conventions
- Operational runbooks
- Documentation and change management
