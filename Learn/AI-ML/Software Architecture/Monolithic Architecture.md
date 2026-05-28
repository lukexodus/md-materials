## Single Deployment Unit

A single deployment unit in AI systems represents the smallest atomic artifact that can be independently deployed, versioned, rolled back, and scaled. This architectural pattern encapsulates all dependencies, configurations, and runtime requirements necessary for autonomous operation, enabling operational simplicity and reducing coordination overhead across distributed systems.

### Deployment Unit Composition

**Artifact Boundary Definition**

The deployment unit boundary encompasses model weights, inference runtime, preprocessing logic, postprocessing logic, serving application code, dependency libraries, configuration files, and health check endpoints. All components required for request processing must be self-contained within the unit to eliminate runtime dependencies on external services for core inference functionality.

Contrast with multi-artifact deployments where model weights, feature transformations, and serving logic deploy separately. Single units sacrifice flexibility in independent component updates for operational simplicity and atomic versioning guarantees.

**Immutable Artifact Construction**

Build deployment units as immutable containers or packages with cryptographic signatures. Include exact dependency versions pinned to specific commits or release tags. Reproducible builds from source code and model registry artifacts ensure consistency across environments. Content-addressable storage allows deduplication while maintaining immutability guarantees.

Embed complete metadata within the artifact: model version, training job ID, data version, code commit SHA, build timestamp, performance benchmarks, and resource requirements. Metadata enables automated deployment validation and compatibility checking.

**Size and Complexity Trade-offs**

Deployment unit size impacts deployment velocity, storage costs, and cold start latency. Large language models with hundreds of gigabytes of weights create multi-gigabyte containers. Optimization strategies include weight quantization, layer-wise lazy loading, and shared base image layers.

Complexity within a single unit increases testing scope and deployment risk. Monolithic units bundle multiple models or serving paths, complicating rollback decisions. Requirements for deployment atomicity must balance against operational complexity.

### Container-Based Packaging

**Docker and OCI Image Standards**

Package deployment units as OCI-compliant container images. Multi-stage builds separate build-time dependencies (compilers, training frameworks) from runtime dependencies (inference libraries). Layer ordering optimizes caching: base OS and system libraries in bottom layers, application code in top layers.

Model weights stored as separate layers enable sharing across model versions with identical architectures. Layer size limits (typically <10GB) necessitate weight splitting or external storage references for very large models.

**Runtime Environment Isolation**

Containers provide process isolation, filesystem isolation, and resource limits (CPU, memory, GPU). Specify resource requests (minimum guaranteed) and limits (maximum allowed) in deployment manifests. Resource specifications guide cluster scheduling and prevent resource contention.

GPU isolation requires additional configuration: device passthrough, driver version compatibility, and CUDA library mounting. Multi-GPU assignments use device indices or topology-aware allocation for optimal interconnect bandwidth.

**Health and Readiness Probes**

Implement distinct health check endpoints: liveness probes detect crashed processes, readiness probes validate model loading completion. Liveness failures trigger container restarts. Readiness failures remove containers from load balancer rotation without terminating the process.

Model-specific readiness checks validate weight loading, warm-up inference completion, and dependency availability (feature stores, configuration services). Separate startup probes allow extended initialization periods without triggering liveness failures during model loading.

### Serverless Function Packaging

**Function-as-a-Service Constraints**

Serverless platforms impose strict constraints: deployment package size limits (50-250MB compressed), execution time limits (15 minutes typical maximum), memory limits (128MB-10GB), and cold start overhead. These constraints favor small models or necessitate custom runtimes with pre-loaded weights.

Lambda layers or equivalent mechanisms share common dependencies across functions. Model weights stored in layers reduce deployment package size but introduce version coordination complexity. Layer size limits require weight sharding for large models.

**Cold Start Optimization**

Cold start latency dominates serverless inference performance for infrequently invoked models. Optimization strategies include provisioned concurrency (pre-warmed containers), lightweight runtimes (compiled binaries versus interpreted languages), lazy initialization (load only required model components), and weight format optimization (memory-mapped formats).

Periodic warm-up invocations maintain provisioned capacity and prevent complete cold starts. Cost-performance trade-offs between provisioned concurrency cost and cold start latency impact deployment decisions.

### Binary and Executable Packaging

**Compiled Model Artifacts**

Ahead-of-time compilation produces standalone executables or shared libraries from model graphs. TensorFlow Lite, ONNX Runtime, and TVM generate optimized binaries for target hardware. Compiled artifacts eliminate framework dependencies, reduce deployment size, and improve inference performance.

Compilation increases build complexity and reduces deployment flexibility. Model updates require recompilation and full redeployment. Platform-specific compilation creates separate artifacts per target architecture (x86, ARM, GPU architectures).

**Static Linking and Dependency Bundling**

Statically link all dependencies into single executables to eliminate shared library version conflicts. Static linking increases executable size but ensures consistent runtime behavior across environments. Dynamic linking reduces size but introduces dependency management complexity.

Language-specific packaging (Python wheels, JVM JARs, Go binaries) influences deployment unit characteristics. Interpreted languages bundle source code and runtime, compiled languages produce native binaries with minimal dependencies.

### Model Serving Framework Integration

**Framework-Specific Serving Containers**

TensorFlow Serving, TorchServe, Triton Inference Server, and similar frameworks provide pre-built serving containers with optimized inference runtimes. Deploy by mounting model artifacts into framework containers. Frameworks handle batching, versioning, and monitoring, reducing custom serving code.

Framework containers introduce dependencies on specific model formats (SavedModel, TorchScript, ONNX). Migration across frameworks requires model format conversion. Framework versioning must align with model training framework versions to avoid incompatibilities.

**Model Server Configuration**

Configuration includes batching parameters (max batch size, batch timeout), concurrency limits, model version policies (specific version, latest, multiple concurrent versions), and instance group assignments (CPU, GPU, model parallelism topology).

Configuration embedded in deployment units versus externalized impacts change velocity. Embedded configuration ensures consistent behavior but requires redeployment for configuration changes. External configuration enables runtime tuning but complicates version control.

### Feature Engineering Inclusion

**Preprocessing Logic Co-location**

Embedding feature engineering logic within deployment units prevents training-serving skew. Include data validation, missing value imputation, encoding (one-hot, embeddings), normalization, and feature transformations. Shared preprocessing code between training and serving ensures consistency.

Preprocessing complexity affects deployment unit size and inference latency. Heavy preprocessing (image augmentation, text parsing, complex aggregations) increases resource requirements. Tradeoff between preprocessing in serving versus preprocessing in client applications or dedicated feature services.

**Feature Schema Validation**

Validate input features against expected schemas before inference. Schema validation detects incompatible requests early, preventing silent model failures. Include schema definitions (types, ranges, nullability constraints) in deployment artifacts.

Schema evolution requires versioned schema support. Deployment units must handle requests with older or newer schemas through default values, optional fields, and backward compatibility logic.

### Configuration and Secrets Management

**Environment-Specific Configuration**

Separate environment-specific configuration (endpoints, credentials, resource limits) from deployment artifacts. Inject configuration via environment variables, mounted volumes, or configuration management systems. Enables artifact promotion across environments (dev, staging, production) without rebuilds.

Configuration validation at deployment time catches missing or invalid configuration before serving traffic. Include sensible defaults for optional configuration to simplify deployment.

**Secrets and Credential Injection**

Never embed secrets (API keys, passwords, certificates) in deployment artifacts. Inject secrets at runtime via secrets management systems (Vault, AWS Secrets Manager, Kubernetes Secrets). Rotate secrets independently of deployment artifacts.

Model decryption keys for encrypted model weights require secure injection. Hardware security modules or trusted execution environments provide additional protection for high-value models.

### Multi-Model Deployment Units

**Model Ensemble Packaging**

Deploy multiple models in a single unit for ensemble inference: bagging, boosting, or stacking. Single unit ensures consistent model versions in ensemble and simplifies deployment coordination. Ensemble logic (voting, averaging, stacking) included in serving code.

Resource requirements multiply with model count. GPU memory constraints limit ensemble size. Sequential versus parallel ensemble evaluation trades latency for throughput.

**Multi-Task Model Serving**

Single models serving multiple tasks (classification, regression, segmentation) deploy as unified units. Shared backbone with task-specific heads reduces total parameter count versus separate models. Single deployment simplifies operations but couples unrelated tasks.

Task-specific routing logic within serving application directs requests to appropriate model outputs. Task-specific postprocessing and metrics collection maintain per-task observability.

### Deployment Unit Versioning

**Semantic Versioning Schemes**

Adopt semantic versioning (major.minor.patch) or date-based versioning (YYYY.MM.DD.revision) for deployment units. Major versions indicate breaking API changes, minor versions add backward-compatible functionality, patches fix bugs without behavior changes.

Model retraining on new data typically increments minor version. Architecture changes increment major version. Version metadata enables automatic compatibility checking and routing decisions.

**Version Pinning and Ranges**

Clients specify required deployment unit versions: exact pins (==1.2.3), minimum versions (>=1.2.0), or version ranges (>=1.2.0,<2.0.0). Version negotiation at request time enables gradual rollout and A/B testing.

Maintain multiple concurrent versions for gradual migration. Sunset policies define supported version windows and deprecation timelines.

### Deployment Unit Testing

**Unit-Level Integration Tests**

Test complete deployment units in isolated environments before production deployment. Validate request-response correctness, latency requirements, resource consumption, and error handling. Synthetic request generation covers edge cases and boundary conditions.

Load testing at unit level characterizes throughput and latency under various traffic patterns. Stress testing identifies breaking points and failure modes. Performance regression tests compare against baseline versions.

**Smoke Tests in Production**

Deploy new units to canary instances with minimal production traffic. Automated smoke tests validate basic functionality before traffic ramp-up. Shadow mode testing sends production requests to new units without serving responses to users, comparing outputs against current production version.

### Rollback and Recovery Strategies

**Atomic Rollback Guarantees**

Single deployment units enable atomic rollback to previous versions. Rollback replaces entire unit rather than coordinating updates across multiple artifacts. Maintain N previous versions in registry for rapid rollback.

Automated rollback triggers include error rate thresholds, latency violations, or failed health checks. Manual rollback procedures provide operator override of automated decisions.

**State Management During Rollback**

Stateless deployment units simplify rollback. Stateful units (maintaining request context, caching) require state migration or invalidation during rollback. Design units to tolerate version transitions without state corruption.

In-flight request handling during rollback: drain existing requests before termination, force-terminate after timeout, or route to replacement instances. Requirements specify acceptable request disruption during rollback.

### Resource Requirements Specification

**Compute and Memory Profiles**

Declare explicit resource requirements: CPU cores, memory bytes, GPU count and type. Schedulers use requirements for placement decisions. Under-specified requirements cause out-of-memory errors or CPU throttling. Over-specified requirements waste resources and reduce cluster utilization.

Burstable versus guaranteed QoS classes trade cost for performance predictability. Burstable units use excess capacity but face throttling under contention. Guaranteed units receive dedicated resources regardless of cluster load.

**Storage and Network Requirements**

Specify ephemeral storage for temporary files, model caching, and logs. Persistent storage requirements for model weights if not bundled in container. Network bandwidth requirements for high-throughput serving or distributed inference.

GPU memory requirements constrain batch sizes and model sizes. Specify GPU memory per instance and total GPU count. Multi-GPU topologies (NVLink, PCIe) affect communication overhead and model parallelism strategies.

### Observability Integration

**Embedded Instrumentation**

Include logging, metrics emission, and distributed tracing within deployment units. Structured logging with correlation IDs enables request path reconstruction. Metrics expose inference latency, throughput, error rates, and resource utilization.

Export metrics in standardized formats (Prometheus, OpenMetrics). Include custom metrics for model-specific concerns: prediction confidence distributions, feature distributions, cache hit rates.

**Debugging and Profiling Hooks**

Embed debugging endpoints for runtime inspection: model version, loaded features, configuration values, recent requests. Profiling endpoints expose performance traces for latency debugging. Disable or restrict access to debugging endpoints in production via configuration.

### Deployment Orchestration Integration

**Kubernetes Pod Specifications**

Package deployment units as Kubernetes Pods with declarative specifications: container images, resource requests/limits, volume mounts, environment variables, and probes. Pods serve as atomic scheduling units.

Pod anti-affinity rules spread instances across failure domains (nodes, racks, availability zones). Pod priority classes ensure critical serving workloads preempt lower-priority batch jobs during resource contention.

**Service Mesh Integration**

Service mesh sidecars inject networking capabilities: mutual TLS, traffic routing, circuit breaking, retry logic. Sidecars operate alongside deployment unit containers without modifying unit code. Mesh configuration (routing rules, policies) lives outside deployment units.

Sidecar resource overhead increases per-instance costs. Lightweight proxies or ambient mesh architectures reduce overhead for high-density deployments.

### Compliance and Security Constraints

**Artifact Signing and Verification**

Cryptographically sign deployment artifacts during build process. Verify signatures before deployment to detect tampering. Public key infrastructure manages signing keys and certificate chains.

Supply chain security scans deployment artifacts for vulnerable dependencies. Block deployments with critical CVEs. Track artifact provenance from source code commits through build pipelines to deployment.

**Runtime Security Policies**

Enforce least-privilege execution: non-root users, read-only filesystems, dropped capabilities. Security contexts define allowed syscalls, file access, and network policies. Minimize attack surface by excluding unnecessary tools (shells, compilers) from runtime containers.

### Edge and Embedded Deployment

**Resource-Constrained Environments**

Edge deployment units face extreme resource constraints: megabytes of RAM, limited storage, battery power, intermittent connectivity. Model optimization mandatory: quantization, pruning, knowledge distillation. Specialized model formats (TFLite, ONNX Runtime Mobile) reduce footprint.

Over-the-air updates deploy new units to edge devices with bandwidth constraints. Delta updates transmit only changed bytes. Fallback mechanisms handle failed updates to prevent bricked devices.

**Offline Operation Requirements**

Edge units operate without connectivity to backend services. Bundle all dependencies for autonomous operation: models, configuration, feature engineering logic. Periodic synchronization uploads telemetry and downloads updates when connectivity available.

### Cost Attribution and Metering

**Per-Unit Resource Tracking**

Label deployment units with cost allocation tags: team, project, customer. Cluster resource managers track per-unit CPU, memory, GPU, and storage consumption. Aggregate costs enable chargeback or showback to consuming teams.

Inference request counts and latencies enable cost-per-inference calculations. Break down serving costs by model version and traffic source for optimization prioritization.

### Related Topics

- Container Orchestration for ML
- Model Serving Infrastructure
- Deployment Strategies and Patterns
- Model Versioning and Registry
- Resource Management and Scheduling
- Serverless Inference Architecture
- Edge AI Deployment
- Continuous Deployment for ML
- Multi-Model Serving
- Artifact Management Systems

---

## Shared Database

### Architectural Context

Shared database pattern centralizes data storage accessed by multiple services, components, or tenants through direct database connections. Contrasts with database-per-service and event-driven architectures where data ownership boundaries align with service boundaries. In AI systems, appears in feature stores, training data repositories, model registries, metadata catalogs, and multi-tenant serving platforms.

### Access Patterns in AI Systems

**Feature store queries:** Point lookups (single entity features), batch retrieval (training dataset assembly), streaming ingestion (real-time feature updates). Access from online serving (microsecond-millisecond latency) and offline training (throughput-optimized, latency-tolerant). Schema: entity_id (primary key), feature_name, feature_value, timestamp, version.

**Training data access:** Sequential scans for epoch iteration, random sampling for mini-batch construction, stratified sampling for class balance, temporal range queries for time-series. Columnar formats (Parquet, ORC) optimize for analytical queries, row-oriented for transactional updates.

**Model registry operations:** Write model artifacts, metadata (hyperparameters, metrics, lineage), versioning information. Read operations: model serving (fetch latest approved version), experiment tracking (query by metric thresholds), lineage tracing (dependencies, reproducibility).

**Metadata catalog:** Schema definitions, data quality metrics, access control policies, usage statistics. Powers data discovery, governance, compliance. Query patterns: full-text search, faceted filtering, graph traversal (lineage relationships).

**Experiment tracking:** High write volume (metrics logged every N steps), point queries (specific run details), aggregation queries (compare runs, leaderboards). Time-series nature favors append-optimized storage.

### Schema Design Considerations

**Denormalization for read performance:** Pre-join tables to eliminate runtime joins. Feature tables denormalized to include entity attributes alongside feature values. Trade storage redundancy for query latency. Critical when serving latency budgets measured in single-digit milliseconds.

**Vertical partitioning:** Split wide tables (100s-1000s columns) into feature groups accessed together. User demographic features, behavioral features, computed features in separate tables. Reduces I/O for queries accessing feature subsets.

**Temporal schema patterns:** SCD Type 2 (Slowly Changing Dimensions) tracks feature value history: feature_id, entity_id, value, valid_from, valid_to. Enables point-in-time correctness for training data reconstruction, temporal feature engineering.

**Schema versioning:** Feature schema evolution (add columns, change types) must preserve backward compatibility or coordinate updates across consumers. Schema registry (Confluent, Avro) enforces compatibility rules, provides centralized documentation.

**Polymorphic schemas:** Multi-tenant systems store heterogeneous entities (different customer data models) in shared tables. JSON/JSONB columns for flexible schemas, typed columns for queryable attributes. Trade query performance for schema flexibility.

### Concurrency Control

**Optimistic locking:** Read-compute-write pattern for model training metrics, feature aggregations. Version numbers or timestamps detect conflicts. Retry on conflict. Suitable when conflicts rare, minimizes locking overhead.

**Pessimistic locking:** Acquire exclusive lock before write (SELECT FOR UPDATE). Prevents conflicts but reduces concurrency, risk of deadlocks. Used for critical metadata updates (model promotion, feature registration).

**MVCC (Multi-Version Concurrency Control):** Postgres, MySQL InnoDB provide snapshot isolation. Writers don't block readers, readers see consistent snapshot. Enables high read concurrency during training data extraction alongside concurrent feature updates.

**Serializable isolation:** Strongest guarantee, transactions appear executed sequentially. Performance penalty 2-10× compared to read-committed. Reserved for financial transactions, critical state machines (model deployment approval workflows).

**Lock-free patterns:** Append-only logs, immutable data avoid locking entirely. Training datasets versioned, feature values timestamped never updated in-place. Garbage collection reclaims old versions. Eliminates contention at cost of storage overhead.

### Partitioning Strategies

**Range partitioning:** Partition by timestamp (daily, monthly tables) for time-series data (logs, metrics, events). Old partitions archived to cold storage, dropped entirely after retention period. Queries with temporal predicates scan fewer partitions.

**Hash partitioning:** Distribute entities uniformly across partitions by hashing entity_id. Prevents hotspots, enables parallel query execution. Join operations require co-partitioning (same hash function) to avoid shuffle.

**List partitioning:** Partition by discrete attribute (customer_tier, region, model_version). Isolates tenant data, enables per-tenant quotas, separate performance characteristics. Facilitates regulatory compliance (EU data in EU partition).

**Composite partitioning:** Combine strategies (range-hash: partition by month, sub-partition by entity_id hash). Balances temporal pruning with load distribution.

**Partition pruning optimization:** Query optimizer eliminates irrelevant partitions based on WHERE clauses. Requires partition key in query predicates. Reduces scanned data 10-100×.

### Indexing for AI Workloads

**Primary key indexes:** B-tree on entity_id for point lookups. Training pipelines query features for specific entities (user_ids, item_ids). Clustered indexes (InnoDB) co-locate physically, reduce random I/O.

**Secondary indexes:** Feature name, timestamp, version for range queries, sorting. Covering indexes include query columns to avoid table lookups (index-only scans). Each index adds write overhead, storage cost.

**Composite indexes:** Multi-column indexes support conjunctive queries (entity_id, timestamp) efficiently. Column order matters: most selective predicates first. Training data queries: WHERE entity_id = X AND timestamp > Y benefit from (entity_id, timestamp) index.

**Full-text indexes:** GIN (Postgres), full-text (MySQL) for model description search, hyperparameter queries. Inverted indexes map tokens to rows. Query: "find models with learning_rate > 0.001 AND optimizer LIKE '%adam%'".

**Vector indexes:** HNSW, IVF, ScaNN for similarity search in embedding spaces. Feature stores storing entity embeddings (user vectors, item vectors) enable nearest-neighbor retrieval. Approximate search trades recall for latency.

**Partial indexes:** Index subset of rows (WHERE is_active = true). Smaller index size, faster updates. Feature tables index only recent data (last 30 days), archive queries scan full table.

### Transaction Management

**ACID properties for ML metadata:** Model registration, experiment tracking, deployment workflows require atomicity (all-or-nothing), consistency (constraints enforced), isolation (concurrent transactions don't interfere), durability (committed data survives failures).

**Distributed transactions:** Two-phase commit (2PC) coordinates transactions across database shards. High latency (multiple network round-trips), availability risk (coordinator failure blocks progress). Avoided in latency-sensitive paths.

**Saga pattern:** Long-running workflows (data pipeline → training → evaluation → deployment) decomposed into local transactions, compensating actions on failure. Example: training fails → delete partial checkpoints, update experiment status to "failed".

**Idempotency requirements:** Retry logic requires idempotent operations (executing twice produces same result). Feature ingestion: upsert (INSERT ON CONFLICT UPDATE) rather than insert. Model registration: conditional writes based on version.

### Multi-Tenancy Implementation

**Shared schema, discriminator column:** tenant_id in every table, all queries include tenant_id predicate. Highest density, lowest isolation. Risk: missing predicate leaks data across tenants. Mitigated by row-level security (RLS), query rewriting in ORM layer.

**Schema-per-tenant:** Separate schemas (namespaces) per tenant within database. Better isolation, per-tenant schema evolution, backup/restore granularity. Complexity: 1000s tenants = 1000s schemas, connection pooling per-schema.

**Database-per-tenant:** Complete isolation, independent scaling, straightforward compliance. Operations overhead: provisioning, monitoring, migrations across 1000s databases. Suitable for large enterprise customers, regulated industries.

**Hybrid approach:** Largest tenants get dedicated databases, small tenants share. Balances isolation vs operational overhead. Tenant migration path: grow from shared to dedicated.

**Tenant-aware connection pooling:** Connection pools partitioned by tenant_id. Prevents one tenant monopolizing connections. Pool size per tenant based on tier, usage patterns.

### Performance Optimization Techniques

**Materialized views:** Pre-compute aggregations (average feature values, model performance by segment). Refreshed periodically (REFRESH MATERIALIZED VIEW). Serve dashboard queries, leaderboard rankings without recomputing. Trade freshness for query speed.

**Query result caching:** Application-level (Redis, Memcached) or database-level (query result cache). Cache key: SQL hash + parameters. Invalidation: TTL-based, event-driven (features updated → cache cleared).

**Connection pooling:** Reuse database connections across requests. Avoids connection establishment overhead (TCP handshake, authentication, session setup). Pool size tuning: too small → queuing, too large → database overload.

**Batch operations:** Group inserts/updates into single transaction. COPY command (Postgres), LOAD DATA (MySQL) 10-100× faster than row-by-row inserts. Training data ingestion: batch 10K-100K rows per transaction.

**Prepared statements:** Parse query once, execute many times with different parameters. Eliminates repeated parsing overhead. Protects against SQL injection.

**Parallel query execution:** Modern databases parallelize scans, aggregations across CPU cores. Training data extraction: parallel sequential scans across partitions. Degree of parallelism configured per query or globally.

**Columnar storage extensions:** Postgres cstore_fdw, MySQL ColumnStore for analytical workloads. Compress columns independently (run-length, dictionary encoding), scan only referenced columns. 10-100× compression, 5-50× query speedup for analytical queries.

### Consistency Challenges

**Read-after-write consistency:** Training pipeline writes features, immediately reads for training. Replication lag (master-replica) causes stale reads. Solutions: read-your-writes (route reads to master), session consistency (track write timestamps).

**Cross-table consistency:** Feature tables, model metadata, experiment logs updated in separate transactions. Inconsistencies: model marked "deployed" but features not updated. Solutions: distributed transactions (2PC), eventual consistency with reconciliation, single source of truth.

**Schema migration coordination:** Rolling updates where new code expects schema v2, old code expects v1. Backward-compatible migrations (add columns with defaults, deprecate columns gracefully). Blue-green deployments: full cutover minimizes coexistence period.

**Clock skew impacts:** Distributed feature writers with unsynchronized clocks insert out-of-order timestamps. Time-series queries return inconsistent results. Solutions: logical clocks (Lamport, vector), trusted time source (NTP, GPS), timestamp at ingestion.

### Backup and Recovery

**Point-in-time recovery (PITR):** Restore database to any timestamp within retention window. Requires continuous archival of write-ahead logs (WAL). Training data corruption detected hours later recoverable by restoring pre-corruption snapshot.

**Snapshot strategies:** Full backups (weekly), incremental (daily), continuous archival (WAL). Balance recovery time objective (RTO) vs recovery point objective (RPO) vs storage cost. Hot backups (online, no downtime) vs cold (offline, maintenance window).

**Cross-region replication:** Asynchronous replication to secondary region for disaster recovery. RPO = replication lag (seconds-minutes). Manual or automatic failover on primary region failure.

**Logical backups:** Export schema + data (pg_dump, mysqldump). Portable across database versions, cloud providers. Slower than physical backups, suitable for smaller databases (<100GB).

**Backup validation:** Periodic restore testing to separate environment. Verifies backup integrity, measures actual RTO. Untested backups often fail at critical moment.

### Monitoring and Observability

**Query performance metrics:** Slow query log, query execution plans, index usage statistics. Identify missing indexes, inefficient queries, full table scans. pg_stat_statements (Postgres), performance_schema (MySQL).

**Connection pool metrics:** Active connections, idle connections, wait time. Pool exhaustion indicates under-provisioning or connection leaks. Per-tenant metrics reveal resource hogs.

**Replication lag:** Time delta between master write and replica apply. High lag indicates replica overload, network issues. Impacts read-after-write consistency, disaster recovery RPO.

**Storage metrics:** Table sizes, index sizes, growth rate. Predict capacity exhaustion, identify bloat (dead tuples, fragmented indexes). Vacuum (Postgres), optimize (MySQL) reclaim space.

**Lock contention:** Deadlocks, lock wait time, lock queues. High contention indicates schema design issues (hot rows), transaction scope problems (hold locks too long).

**Error rates:** Connection failures, transaction rollbacks, constraint violations. Spikes indicate application bugs, capacity limits, schema mismatches.

### Security and Access Control

**Row-level security (RLS):** Postgres policies enforce tenant_id filters automatically. Prevents data leakage from missing WHERE clauses. Policy: CREATE POLICY tenant_isolation ON features USING (tenant_id = current_setting('app.tenant_id')).

**Column-level permissions:** Restrict access to sensitive columns (PII, proprietary features). Training jobs get read-only on features, read-write on experiment_logs. GRANT SELECT (entity_id, feature_value) ON features TO training_role.

**Encryption at rest:** Database files, backups encrypted with managed keys (KMS). Protects against disk theft, unauthorized snapshot access. Minimal performance overhead with hardware acceleration.

**Encryption in transit:** TLS for client-database connections. Prevents eavesdropping, man-in-the-middle attacks. Certificate validation, strong cipher suites (TLS 1.3).

**Audit logging:** Track data access, schema changes, privilege modifications. Compliance requirements (SOC2, HIPAA) mandate audit trails. Performance impact: asynchronous log writes, log rotation, retention policies.

**Credential management:** Secrets manager (AWS Secrets Manager, HashiCorp Vault) rotates database credentials, injects at runtime. Never hardcode credentials, commit to repositories.

### Failure Modes and Mitigation

**Single point of failure:** Shared database failure halts all dependent services. Mitigations: high availability (master-replica, multi-AZ), automatic failover, circuit breakers in clients.

**Thundering herd on recovery:** Database restart causes simultaneous reconnection attempts from 1000s clients. Connection establishment floods database, prevents recovery. Mitigations: exponential backoff, jittered retries, connection rate limiting.

**Cascading failures:** Slow query locks table, blocks other queries, connection pool exhausted, clients timeout, retry storm amplifies load. Mitigations: query timeouts, statement timeouts, connection limits per client.

**Data corruption:** Application bug writes invalid data, propagates to replicas, backups. Detection lag compounds impact. Mitigations: application-level validation, database constraints (CHECK, FOREIGN KEY), backup retention, PITR.

**Capacity saturation:** Storage full, connection limit reached, CPU/memory exhausted. Mitigations: alerting thresholds (80% capacity), auto-scaling (vertical, read replicas), query optimization, archival.

**Split-brain scenarios:** Network partition causes both master and replica accept writes. Reconciliation challenging, data loss risk. Mitigations: quorum-based consensus (Raft, Paxos), fencing (STONITH), witness nodes.

### Anti-Patterns and Pitfalls

**N+1 query problem:** Application loops over entities, queries features individually. 1000 entities = 1000 queries. Mitigations: batch queries (WHERE entity_id IN (...)), JOIN operations, ORM eager loading.

**Missing query predicates:** Full table scans on multi-TB tables. Partition pruning disabled. Mitigations: required WHERE clauses enforced at application layer, partial indexes, view-based access control.

**Unbounded result sets:** SELECT * without LIMIT on large tables. Client OOM, network saturation. Mitigations: pagination, cursor-based iteration, LIMIT clauses, application-level result size checks.

**Long-running transactions:** Hold locks for minutes-hours (training job reading features inside transaction). Blocks concurrent writes, replication lag. Mitigations: snapshot exports, read-only transactions, streaming cursors.

**Hot spotting:** Disproportionate load on single shard, partition, table. Celebrity user features accessed 1000× more than typical. Mitigations: caching popular entities, consistent hashing with virtual nodes, partition splitting.

**Schema sprawl:** 1000s tables, 10K+ columns across tables. Management complexity, query optimizer struggles. Mitigations: table consolidation, feature namespacing (JSONB columns for rare features), archival of unused schemas.

**Implicit schema dependencies:** Application assumes column exists, schema migration breaks. Mitigations: schema versioning, feature flags control schema access, graceful degradation on missing columns.

### Trade-offs vs Alternative Patterns

**Shared database vs database-per-service:** Shared enables cross-service queries, transactions, simpler consistency. Per-service enables independent scaling, deployment, technology choices. AI systems often hybrid: shared feature store, per-service application databases.

**Shared database vs event-driven:** Events decouple producers/consumers, enable replay, async processing. Shared database lower latency (no message broker hop), simpler transactions. Training pipelines favor batch from shared database, online serving favors event-driven feature updates.

**Shared database vs data lake:** Lakes handle unstructured, schema-on-read, massive scale (PB). Databases provide ACID, indexes, low-latency queries. Hybrid: data lake for raw training data, database for curated features.

**RDBMS vs NoSQL for shared storage:** RDBMS provides transactions, consistency, rich query language. NoSQL (Cassandra, DynamoDB) provides higher write throughput, horizontal scalability, flexible schemas. Feature stores often use both: RDBMS for metadata, NoSQL for high-throughput feature writes.

### Cost Considerations

**Storage costs:** SSD (high IOPS) vs HDD (high capacity). Compression (columnar, dictionary encoding) reduces footprint 5-10×. Archival to object storage (S3) after retention period. 1PB in RDS EBS = $100K/month, S3 Glacier = $1K/month.

**Compute costs:** Provisioned IOPS, instance size (CPU, memory). Read replicas for read scaling, connection pooling reduces instance requirements. Serverless databases (Aurora Serverless) scale to zero, suitable for intermittent workloads.

**Data transfer costs:** Cross-AZ, cross-region replication, egress to clients. Co-locate database with compute (training, serving) to minimize transfer. 1TB egress = $90 (AWS), 10TB/day = $27K/month.

**Backup costs:** Snapshot storage, WAL archival, cross-region backup copies. Retention policies balance compliance vs cost. 100TB database, daily snapshots, 30 days retention = 3PB snapshot storage = $30K/month.

**Licensing:** Commercial databases (Oracle, SQL Server) charge per-core, per-year. Open-source (Postgres, MySQL) eliminate licensing but require operational expertise. Cloud-managed services bundle licensing in hourly rate.

### Related Topics

- Database-per-Service Pattern
- Feature Store Architecture
- Model Registry Design
- Metadata Management
- Multi-Tenancy Architectures
- Data Partitioning Strategies
- Replication and Consistency Patterns
- Transaction Management in Distributed Systems
- Schema Evolution Strategies
- Database Sharding

---

## Tight Coupling Considerations

Tight coupling in AI systems manifests when components exhibit strong dependencies on internal implementation details, data formats, execution timing, or operational state of other components. These dependencies create fragility, reduce independent evolvability, complicate testing, and constrain operational flexibility. Architectural decisions must explicitly evaluate coupling trade-offs between performance optimization, implementation simplicity, and system maintainability.

### Dependency Manifestations

**Interface Coupling**

Direct invocation of internal APIs or methods bypasses abstraction boundaries, creating brittle dependencies on implementation details. Model serving code directly accessing model internals (layer activations, weight matrices, intermediate representations) couples serving logic to specific model architectures. Feature computation directly querying source database schemas couples feature pipelines to storage implementation. Retrieval systems parsing embedding service response structures rather than using typed interfaces couples clients to provider-specific formats.

**Data Format Coupling**

Shared data structures encode assumptions about format, schema, and semantics across component boundaries. Training pipelines producing model artifacts in framework-specific serialization formats (PyTorch .pth, TensorFlow SavedModel) couple inference servers to training framework choices. Feature stores persisting features in custom binary formats couple consumers to storage implementation. Vector databases returning results in provider-specific JSON structures couple retrieval logic to database selection.

**Temporal Coupling**

Components requiring synchronized execution order or timing create operational fragility. Training pipelines expecting feature stores to refresh before job execution create race conditions during concurrent updates. Inference endpoints requiring embeddings precomputed and cached couple request handling to background job completion. Multi-stage LLM workflows requiring sequential tool invocations prevent parallel execution and introduce cumulative latency.

**State Coupling**

Shared mutable state across components creates hidden dependencies and concurrency hazards. Multiple model servers writing to shared feature cache without coordination risk inconsistent reads. Stateful conversational agents storing context in shared databases couple request handling to database consistency model. Training processes modifying shared configuration during execution couple job outcomes to temporal state rather than declarative inputs.

### Model-System Integration

**Framework Lock-in**

Training and serving infrastructure tightly coupled to specific ML frameworks constrains model architecture evolution. Custom training loops deeply integrated with framework-specific distributed training APIs (PyTorch DDP, TensorFlow MirroredStrategy) prevent framework migration. Serving systems using framework-native model loading (torch.load, tf.saved_model.load) couple deployment infrastructure to training framework versions. Preprocessing logic implemented in framework-specific operations (tf.data, PyTorch transforms) duplicates effort across training and serving.

**Model Architecture Assumptions**

Infrastructure encoding assumptions about model structure creates coupling to architectural patterns. Serving systems expecting single-input single-output models fail with multi-modal architectures accepting image, text, and audio inputs. Batching logic assuming fixed-size inputs breaks with variable-length sequences or dynamic computation graphs. Caching strategies assuming deterministic models fail with stochastic sampling or dropout during inference.

**Serialization Dependencies**

Model persistence formats couple training environments to serving environments through version dependencies. Pickle-based serialization couples Python version, package versions, and execution environment. ONNX export requires model architectures limit operations to supported op-set, constraining model design. Custom serialization formats couple serialization/deserialization code versions across training and serving infrastructure.

### Data Pipeline Integration

**Schema Coupling**

Downstream components directly depending on upstream data schemas create cascading change requirements. Feature engineering code directly querying production database columns couples feature pipelines to database migrations. Model training code expecting specific feature names and types couples model code to feature store schema. Monitoring dashboards querying model output formats couple observability to model API contracts.

**Feature Store Coupling**

Direct dependencies on feature store implementation details limit flexibility and portability. Training code using feature store-specific query APIs couples training pipelines to feature store technology choices. Online serving directly reading from feature store tables couples request path to storage technology. Feature transformation logic embedded in feature store configuration couples feature definitions to platform capabilities.

**Data Lineage Coupling**

Implicit dependencies on data provenance and freshness create operational coupling. Models trained on features expecting specific refresh cadences degrade when upstream batch jobs delay. Inference code assuming feature staleness bounds fails when feature computation lags. A/B experiments comparing model versions require consistent data snapshots across training runs, coupling experiment validity to data versioning.

### Inference Topology Coupling

**Pipeline Stage Dependencies**

Multi-stage inference pipelines with tight coupling between stages reduce operational flexibility. Retrieval-augmented generation systems with retriever output format assumptions couple retrieval and generation stages. Ensemble systems expecting specific model output schemas couple individual model implementations. Reranking stages depending on specific ranking signals couple reranker implementation to upstream ranker output format.

**Prompt Engineering Coupling**

Hard-coded prompts within application logic couple system behavior to specific model capabilities and behaviors. Prompts embedded in source code require redeployment for experimentation. Prompts assuming specific model context window sizes fail when models change. Few-shot examples hard-coded into prompts couple example selection to application release cycles rather than dynamic optimization.

**Tool Integration Coupling**

Agent systems with tight coupling to tool implementations limit tool evolution and substitution. Agents parsing tool output strings rather than structured responses couple to output format. Tool invocation code directly calling tool APIs couples agents to tool availability and versioning. Tool authentication embedded in agent code couples credential management to application deployment.

### Operational Coupling

**Deployment Coupling**

Components requiring synchronized deployment create operational complexity and failure modes. Model serving requiring simultaneous feature store schema migration couples model rollout to data migration completion. A/B testing infrastructure requiring synchronized deployment of routing configuration and model versions couples experimentation to deployment coordination. Multi-service updates requiring specific ordering couples operational procedures to implementation details.

**Scaling Coupling**

Components with tightly coupled resource requirements reduce independent scaling flexibility. Feature computation co-located with model serving couples CPU-intensive preprocessing to GPU-optimized inference scaling. Embedding generation sharing compute with retrieval couples different resource utilization patterns. Synchronous request handling coupling client latency to backend processing time prevents buffering and batching optimizations.

**Configuration Coupling**

Shared configuration across components creates hidden dependencies and change coordination requirements. Multiple services reading shared configuration files couple service restarts to configuration updates. Environment-specific configuration embedded in code couples deployment artifacts to environments. Hierarchical configuration with inheritance couples component behavior to global configuration changes.

### Failure Propagation

**Cascade Failures**

Tight coupling amplifies failure impact through dependency chains. Synchronous RPC calls without timeouts propagate upstream failures downstream. Shared resource exhaustion (database connections, memory) couples component failures across process boundaries. Retry storms from failing dependencies amplify load on already degraded systems.

**Error Handling Coupling**

Components expecting specific error semantics from dependencies create coupling to error handling implementation. Code catching specific exception types couples to dependency exception hierarchies. Error messages parsing dependencies coupling to error message formats. Retry logic assuming specific error meanings couples to dependency error classification.

**Health Check Coupling**

Health check implementations depending on dependency health couple availability to transitive dependencies. Deep health checks recursively validating all dependencies couple service health to entire dependency graph. Shared health check endpoints across multiple services couple monitoring to implementation coordination. Health check timeouts shorter than dependency response times couple health status to timing assumptions.

### Testing Implications

**Test Coupling**

Tightly coupled systems require coordinated test infrastructure and extensive integration testing. Unit tests requiring real dependencies rather than mocks couple test execution to infrastructure availability. Integration tests requiring specific data states couple test reliability to data setup complexity. End-to-end tests requiring synchronized multi-service deployment couple test velocity to deployment orchestration.

**Mock Complexity**

Testing tightly coupled systems requires sophisticated mocking infrastructure. Mocking internal implementation details rather than interfaces couples tests to implementation. Mocks requiring detailed behavior reproduction couple test maintenance to system evolution. Brittle mocks failing on minor implementation changes couple test reliability to internal refactoring.

**Test Data Coupling**

Tests depending on specific data characteristics couple test reliability to data availability and quality. Training tests requiring production data snapshots couple test environments to production data access. Inference tests expecting specific model behavior couple tests to model training outcomes. Quality tests comparing against golden datasets couple test validity to dataset maintenance.

### Performance Trade-offs

**Optimization Coupling**

Performance optimizations often introduce tight coupling through assumptions about execution context. Operator fusion in model compilation couples model graph to execution backend. Custom CUDA kernels for specific operations couple models to GPU architectures. Quantization assuming specific hardware instructions couples model serving to processor capabilities.

**Batching Coupling**

Dynamic batching systems introduce temporal coupling between concurrent requests. Shared batching queues couple individual request latency to concurrent load patterns. Batch size optimization for throughput couples individual request performance to aggregate traffic. Batching logic assuming homogeneous requests couples performance to request diversity.

**Caching Coupling**

Aggressive caching introduces coupling between cache state and application correctness. Embedding caches assuming deterministic embedding generation couple cache validity to model updates. Feature caches with unbounded TTLs couple inference correctness to cache invalidation. Shared caches across tenants couple cache hit rates to workload interference patterns.

### Migration and Evolution

**Version Coupling**

Tight version coupling limits independent component evolution. Shared libraries pinned to specific versions couple dependent services to synchronized upgrades. API contracts without versioning couple clients and servers to coordinated updates. Data formats without version negotiation couple producers and consumers to simultaneous migration.

**Breaking Changes**

Tightly coupled systems amplify breaking change impact across component boundaries. Model API changes requiring client updates couple model deployment to client release coordination. Feature schema changes breaking model inputs couple feature engineering to model retraining. Infrastructure upgrades requiring code changes couple operational maintenance to development cycles.

**Technical Debt Accumulation**

Tight coupling accelerates technical debt accumulation through change resistance. Changing tightly coupled components requires coordinated updates across multiple teams. Fear of breaking dependencies discourages refactoring and improvement. Accumulated dependencies create "ball of mud" architectures resisting modularization.

### Decoupling Strategies

**Interface Abstraction**

Well-defined interfaces isolate implementation details from consumers. Model serving APIs expose prediction endpoints without framework details. Feature stores provide query interfaces abstracting storage technology. Retrieval services return standardized result formats independent of backend implementation.

**Message-Based Communication**

Asynchronous messaging decouples components temporally and reduces direct dependencies. Event streams publish model predictions without requiring synchronous consumers. Message queues buffer requests between producers and consumers tolerating rate differences. Pub-sub patterns allow dynamic consumer addition without producer modification.

**Data Format Standardization**

Standard interchange formats reduce coupling to specific implementations. Protocol Buffers or Apache Arrow for structured data enable cross-language, cross-framework compatibility. ONNX for model interchange decouples training framework from serving infrastructure. Standard embedding formats (dense vectors, sparse vectors) decouple embedding generation from retrieval systems.

**Configuration Externalization**

Externalizing configuration decouples behavior from code deployment. Feature flags enable runtime behavior changes without redeployment. Model routing rules in configuration files decouple traffic distribution from serving code. Prompt templates in version control decouple prompt engineering from application releases.

### Organizational Impact

**Team Dependencies**

Tight technical coupling creates organizational dependencies requiring coordination. Shared codebases couple team velocity to coordination overhead. Synchronized releases couple team autonomy to release planning. Shared infrastructure couple operational responsibilities to cross-team communication.

**Ownership Boundaries**

Poorly defined ownership boundaries around tightly coupled components create operational ambiguity. Shared services with unclear ownership couple incident response to organizational structure. Monolithic repositories couple code organization to team structure. Shared on-call rotations couple operational burden to team boundaries.

**Conway's Law Effects**

[Inference] System architecture tends to mirror organizational communication structure, with tight coupling reflecting insufficient team boundaries or excessive cross-team coordination requirements. Organizations designing tightly coupled systems require high-bandwidth communication channels creating organizational scaling constraints. Decoupled architectures enable team independence but require investment in interface contracts and coordination mechanisms.

### Cost Considerations

**Operational Efficiency**

Tight coupling affects operational cost through reduced flexibility and increased coordination overhead. Synchronized deployments require coordinated maintenance windows reducing deployment velocity. Shared infrastructure prevents independent scaling increasing overprovisioning costs. Cascade failures amplify incident impact increasing downtime costs.

**Development Velocity**

Coupling impacts development cost through increased change coordination and testing requirements. Changes requiring multi-team coordination slow feature delivery. Extensive integration testing increases development cycle time. Breaking changes requiring synchronized updates increase migration costs.

**Infrastructure Utilization**

Coupling constraints affect resource utilization efficiency. Co-located components prevent independent scaling to match workload characteristics. Synchronous communication prevents batching and buffering optimizations. Shared resources prevent workload isolation increasing interference effects.

### Related Topics

- Loose Coupling Patterns
- Service Mesh Architecture
- Event-Driven Architecture
- API Versioning Strategies
- Interface Segregation
- Dependency Injection
- Circuit Breaker Pattern
- Bulkhead Pattern
- Strangler Fig Pattern
- Anti-Corruption Layer
- Feature Flags
- Configuration Management
- Message Queue Architecture
- Contract Testing
- Microservices Decomposition

---

## Modular Monolith

### Architectural Definition and Scope

Modular monolith architecture structures AI systems as single deployable units with strong internal modularization through bounded contexts, explicit interfaces, and enforced dependency constraints. Modules communicate through well-defined APIs, message passing, or event mechanisms within the same process space, eliminating network calls while maintaining logical separation comparable to microservices.

**Process Boundary Consolidation:** All components—model serving, feature computation, data preprocessing, result aggregation, and observability—execute within a single operating system process or tightly coupled process group. Shared memory enables zero-copy data transfer between modules, reducing serialization overhead and network latency.

**Module Isolation Mechanisms:** Enforce boundaries through programming language features (packages, namespaces, modules), dependency injection frameworks, interface-based contracts, and architectural decision records. Static analysis tools verify that modules only import allowed dependencies, preventing circular references and maintaining layered architecture.

**Deployment Atomicity:** Single artifact deployment (Docker container, binary executable, VM image) ensures consistent versioning across all modules. Eliminates version skew problems inherent in distributed systems where independent service deployments create combinatorial compatibility matrices.

### Module Decomposition Patterns

**Core Domain Modules:** Isolate business logic and domain-specific functionality—model inference logic, custom loss functions, domain-specific feature engineering, business rule engines, and task-specific postprocessing. These modules contain the primary value proposition and change most frequently.

**Infrastructure Modules:** Abstract infrastructure concerns—model loading and caching, GPU memory management, batch processing, request queuing, connection pooling, and distributed tracing. Infrastructure modules provide stable interfaces that domain modules depend upon.

**Data Access Modules:** Encapsulate interactions with external systems—feature store clients, model registry APIs, object storage interfaces, database connections, and cache layers. Centralize data access patterns, retry logic, circuit breakers, and connection management.

**Observability Modules:** Consolidate logging, metrics collection, tracing, profiling, and health checking. Provide consistent observability primitives across all modules while hiding implementation details of metrics backends, log aggregators, and tracing systems.

**Adapter Modules:** Translate between external protocols and internal domain models—HTTP/gRPC request handlers, message queue consumers, batch job schedulers, and webhook processors. Adapter modules prevent external protocol details from leaking into core domain logic.

### Dependency Management and Layering

**Acyclic Dependency Principle:** Enforce directed acyclic graph (DAG) structure in module dependencies. Domain modules depend on infrastructure modules but never vice versa. Data access modules depend on infrastructure primitives but not domain logic. Use dependency inversion to break problematic dependencies.

**Stable Dependencies Principle:** Modules should depend on modules more stable than themselves. Infrastructure modules with infrequent changes support domain modules that evolve rapidly. Measure stability through change frequency metrics and coupling analysis.

**Interface Segregation:** Define minimal, focused interfaces between modules. Avoid large, monolithic interfaces that couple modules unnecessarily. Prefer multiple small interfaces over single large ones to enable independent module evolution.

**Dependency Injection:** Wire module dependencies at application startup through dependency injection frameworks (Spring, Guice, inject in Python). Enable module testing with mock dependencies and configuration-based behavior changes without code modifications.

**Package Structure:** Organize code to reflect module boundaries—separate directories per module, explicit `__init__.py` or module manifests declaring public interfaces, internal subdirectories for implementation details. Enforce visibility rules (public, private, protected) rigorously.

### Inter-Module Communication Patterns

**Direct Method Invocation:** Modules communicate through synchronous function calls for request-response patterns. Benefits include type safety, IDE support, zero serialization cost, and straightforward debugging. Appropriate when caller and callee lifetimes are coupled and failures should propagate immediately.

**Event-Driven Communication:** Modules publish events to in-process event bus for asynchronous, decoupled communication. Multiple modules subscribe to events without publishers knowing subscribers. Implemented through observer pattern, publish-subscribe frameworks, or reactive streams. Enables temporal decoupling and supports multiple consumers per event.

**Shared Memory Structures:** High-throughput scenarios use shared memory—NumPy arrays, PyTorch tensors, or memory-mapped files—to pass large data structures between modules without copying. Requires careful lifetime management, coordinate access through locks or lock-free data structures, and validate data consistency.

**Command Query Separation:** Separate command operations (modify state) from query operations (read state). Commands may trigger events, queries return data without side effects. Simplifies reasoning about state changes and enables optimization of read paths independently from write paths.

**Message Queues:** Implement internal message queues (Python Queue, Go channels, Java BlockingQueue) for asynchronous work distribution. Producer modules enqueue tasks, consumer modules process from queue with configurable concurrency. Provides backpressure, work buffering, and decouples producer/consumer rates.

### State Management and Consistency

**Centralized State Stores:** Consolidate mutable state in dedicated modules accessed through controlled interfaces. Examples: model cache storing loaded models, feature cache maintaining computed features, request context tracking in-flight requests. Prevents scattered state mutations across codebase.

**Transactional Boundaries:** Define transaction scopes for operations requiring atomicity. Use database transactions for persistence, optimistic locking for in-memory state, or compensation logic for multi-step operations. Ensure rollback mechanisms exist for partial failures.

**Immutability by Default:** Prefer immutable data structures for inter-module communication. Pass read-only references, frozen dataclasses, or value objects. Prevents unintended mutations and enables safe concurrent access without locks.

**Cache Coherency:** When multiple modules cache related data, implement invalidation protocols. Options include: time-based expiration, event-driven invalidation, version-based validation, or single source of truth with shared cache.

**Session State Management:** For multi-turn interactions (conversational AI, iterative refinement), store session state in-process memory structures. Key by session identifiers, implement TTL-based eviction, and persist to external storage for durability across restarts.

### Module Testing Strategies

**Unit Testing Per Module:** Test modules in isolation with mocked dependencies. Validate module logic independently of infrastructure and external systems. Achieve high code coverage within module boundaries.

**Integration Testing at Module Boundaries:** Test interactions between adjacent modules with real implementations. Validate interface contracts, error propagation, and data transformations. Use test doubles for transitive dependencies.

**Architectural Fitness Functions:** Implement automated tests that verify architectural constraints—dependency rules, layering violations, circular dependencies, forbidden API usage. Integrate into CI pipelines to prevent architectural erosion.

**Contract Testing:** Define explicit contracts between modules using schema definitions (JSON Schema, Protobuf, TypeScript interfaces). Generate test cases from contracts to verify both providers and consumers honor specifications.

**In-Process Integration Tests:** Test multiple modules together within single process for faster feedback than full end-to-end tests. Validate complete workflows—data ingestion through feature computation to model inference—without network or external dependencies.

### Performance Characteristics

**Latency Advantages:** Eliminate network round-trips, serialization/deserialization overhead, and connection management. Function calls complete in nanoseconds versus milliseconds for network requests. Particularly beneficial for high-frequency inference paths requiring low single-digit millisecond latencies.

**Memory Efficiency:** Share memory between modules through references rather than copying. Pass large tensors, feature vectors, or embedding matrices by reference. Reduces memory footprint and garbage collection pressure compared to serialization-based inter-service communication.

**Throughput Optimization:** Batch processing within single process enables efficient GPU utilization. Combine requests from different modules into batches for GPU kernel execution. Avoids fragmented GPU utilization from multiple independent service instances.

**CPU Cache Locality:** Related data structures and code paths residing in same process improve CPU cache hit rates. Reduces memory access latency compared to distributed systems where data crosses process boundaries frequently.

**Contention Bottlenecks:** Shared resources (GPU, CPU cores, memory) create contention between modules. Requires careful resource allocation, thread pool sizing, and priority queuing to prevent resource starvation or priority inversion.

### Scalability Patterns

**Vertical Scaling:** Scale by increasing resources (CPU cores, memory, GPU count) on single machine. Modular monoliths naturally leverage additional cores through thread pools and async execution. Limited by maximum single-machine capacity (typically 2-8 GPUs, 1TB RAM, 128 cores).

**Horizontal Scaling via Load Balancing:** Deploy multiple identical instances behind load balancer. Stateless modules enable trivial horizontal scaling. Stateful modules require session affinity, distributed caching, or state externalization.

**Read Replicas:** Separate read-heavy inference serving from write-heavy model updates by deploying read replicas. Point read traffic to replicas while master instance handles model deployments and configuration updates.

**Modular Scaling:** Extract specific high-load modules into separate services when bottlenecks emerge. Transition from monolith to microservices incrementally by identifying modules that benefit from independent scaling. Maintain monolith for remaining modules.

**Resource Partitioning:** Assign dedicated thread pools, GPU devices, or memory allocations per module. Prevents resource exhaustion in one module from affecting others. Configure limits through resource management frameworks or container resource constraints.

### Development Workflow and Team Organization

**Collective Code Ownership:** All developers can modify any module within monolith. Reduces coordination overhead compared to service-per-team microservices. Requires strong code review practices and architectural guidelines to prevent degradation.

**Feature Teams:** Organize teams around features or business capabilities rather than technical layers. Teams modify multiple modules to implement features end-to-end. Monolithic structure simplifies cross-module refactoring and reduces inter-team dependencies.

**Module Ownership:** Assign stewards to each module responsible for API design, documentation, and architectural integrity. Stewards review changes affecting their modules but don't have exclusive modification rights. Balances autonomy with collective ownership.

**Local Development Simplicity:** Developers run entire application stack on development machines. Eliminates complex local Kubernetes clusters, service meshes, or container orchestration required for microservices development. Single IDE project contains all code.

**Atomic Refactoring:** Large-scale refactoring spanning multiple modules completes in single commits with atomicity guarantees. Type-safe refactoring tools operate across entire codebase. Contrast with microservices where coordinated refactoring requires sequential deployments with backward compatibility.

### Migration and Evolution Strategies

**Strangler Fig Pattern:** Gradually extract modules into separate services by routing specific requests through new services while monolith handles remaining traffic. Implement routing logic in API gateway or within monolith. Incrementally shift traffic until module fully extracted.

**Module to Service Extraction:** Identify modules suitable for extraction based on scalability bottlenecks, team boundaries, or deployment cadence requirements. Convert inter-module interfaces to network protocols (gRPC, HTTP). Extract module into independent deployable with minimal changes due to pre-existing isolation.

**Shared Kernel Modules:** Maintain shared libraries containing common utilities, domain models, and infrastructure abstractions. Both monolith and extracted services depend on shared kernel. Version shared kernel carefully to prevent breaking changes affecting multiple components simultaneously.

**Backward Compatibility Layers:** When extracting modules, maintain adapter layers in monolith that proxy to new services. Allows gradual migration of callers from local to remote invocation. Remove adapters after migration completes.

**Feature Flags for Hybrid Operation:** Use feature flags to toggle between local module execution and remote service calls. Enables testing service extraction with production traffic before committing to migration. Provides rollback mechanism if service extraction causes issues.

### Model Lifecycle Management

**Model Loading and Caching:** Centralized model cache module loads models from registry into memory, manages GPU placement, and handles versioning. Multiple modules reference cached models without redundant loading. Implement LRU eviction when memory constrained.

**Multi-Model Coordination:** Support multiple models simultaneously—ensemble inference, cascade architectures, specialized models per domain. Coordinate resource allocation (GPU memory, compute) across models. Schedule inference requests to maximize GPU utilization while meeting latency targets.

**Model Update Orchestration:** Coordinate model updates across dependent modules within monolith. Lock-free updates through atomic pointer swaps or versioned references. Drain in-flight requests using old model before releasing resources.

**A/B Testing Infrastructure:** Route requests to different model versions within same process. Assign requests to treatment groups based on hashing, user attributes, or sampling policies. Collect metrics per model version for statistical comparison.

**Model Warm-up:** Pre-load models and execute warm-up inferences during application startup to populate caches and JIT compile execution paths. Prevents cold start latency for initial production requests.

### Data Pipeline Integration

**Embedded Feature Computation:** Compute features within serving process rather than querying remote feature stores. Co-locate feature engineering logic with model inference. Trade-off: increased coupling and resource contention versus reduced latency and simplified architecture.

**Streaming Data Processing:** Integrate streaming frameworks (Apache Flink, Kafka Streams) as modules within monolith. Process real-time event streams, maintain aggregations, and serve low-latency queries from in-process state stores.

**Batch Processing:** Implement batch job execution within monolith for periodic tasks—model training, feature precomputation, data validation, report generation. Schedule through internal job scheduler or external orchestrators (Airflow, Prefect) triggering batch endpoints.

**Data Validation Pipelines:** Embed data quality checks within request processing path. Validate input schemas, check feature distributions, and detect anomalies before inference. Fail fast on invalid data to prevent model errors.

### Observability Implementation

**Structured Logging:** Emit structured logs with consistent schemas including request IDs, module names, timestamps, and contextual attributes. Use thread-local storage to propagate request context across module boundaries. Aggregate logs centrally for querying and alerting.

**Metrics Collection:** Export metrics via Prometheus client libraries, StatsD, or OpenTelemetry. Tag metrics with module names, model versions, and request attributes for dimensional analysis. Aggregate counters, histograms, and gauges in-process before export to reduce cardinality.

**Distributed Tracing:** Implement tracing within monolith to measure time spent in each module per request. Create spans for module boundaries, feature computation, model inference, and postprocessing. Export traces to Jaeger, Zipkin, or OpenTelemetry collectors.

**Profiling and Performance Analysis:** Integrate continuous profiling (pprof, py-spy, async-profiler) to identify CPU hotspots, memory allocations, and blocking operations. Profile production traffic safely with sampling to minimize overhead.

**Health Check Aggregation:** Module-level health checks report status to central health check module. Application health check endpoint returns healthy only when all critical modules are healthy. Enables load balancer health-based routing.

### Configuration Management

**Hierarchical Configuration:** Layer configurations—base defaults, environment-specific overrides, runtime dynamic configuration. Load from files (YAML, TOML, JSON), environment variables, and configuration services (Consul, etcd).

**Module-Specific Configuration:** Each module defines configuration schema with validation. Validate configuration at startup to fail fast on misconfigurations. Document configuration options with types, defaults, and constraints.

**Dynamic Reconfiguration:** Support runtime configuration updates for specific parameters—feature flags, model versions, rate limits, circuit breaker thresholds. Implement configuration watchers that reload settings without process restart.

**Configuration Validation:** Type-check configurations using schema validation libraries (Pydantic, Joi, JSON Schema). Validate referential integrity—model IDs exist in registry, file paths are accessible, URLs are reachable. Prevent deployment of invalid configurations.

### Deployment and Operations

**Single Artifact Deployment:** Build single container image, executable binary, or VM image containing all modules. Simplifies deployment automation, version tracking, and rollback procedures. Tag artifacts with semantic versions and Git commit SHAs.

**Blue-Green Deployments:** Maintain two identical production environments. Route traffic to blue environment while deploying to green. Validate green environment, switch traffic, and retain blue for rollback. Requires load balancer supporting instant traffic switching.

**Canary Deployments:** Deploy new version to small subset of instances (5-10%). Monitor error rates, latency, and business metrics. Gradually increase traffic to canary if metrics remain healthy. Automated rollback if metrics degrade.

**Rolling Deployments:** Replace instances incrementally with new version while maintaining minimum available capacity. Requires instances to be stateless or implement graceful connection draining for stateful components.

**Zero-Downtime Updates:** Implement graceful shutdown—stop accepting new requests, drain in-flight requests with timeout, release resources cleanly. Load balancers detect instance shutdown and stop routing traffic before process termination.

### Security and Isolation

**Process-Level Isolation:** Deploy monolith in containerized environments with security hardening—read-only root filesystem, dropped Linux capabilities, seccomp profiles, AppArmor/SELinux policies. Limits blast radius of security vulnerabilities.

**Module Authentication:** Internal authentication when modules process requests from different trust domains. Verify request source, validate permissions, and enforce authorization policies. Relevant when monolith exposes multiple APIs with different security requirements.

**Secrets Management:** Externalize secrets to dedicated services (HashiCorp Vault, AWS Secrets Manager, Azure Key Vault). Inject secrets at runtime via environment variables or mounted volumes. Rotate secrets without code changes.

**Input Validation:** Validate inputs at module boundaries to prevent injection attacks, buffer overflows, and malformed data propagation. Sanitize user inputs, validate against schemas, and enforce size limits.

**Audit Logging:** Log security-relevant events—authentication attempts, authorization failures, configuration changes, model updates. Include actor identities, timestamps, and affected resources. Store audit logs immutably with integrity verification.

### Limitations and Trade-offs

**Scaling Ceiling:** Vertical scaling limits imposed by maximum single-machine capacity. Applications requiring unbounded horizontal scaling eventually outgrow modular monolith architecture. Typical ceiling: 10,000-100,000 requests per second depending on model complexity.

**Deployment Coupling:** All modules deploy together requiring coordination across teams. High-frequency deploying teams blocked by low-frequency teams. Mitigation: feature flags, modular extraction, or organizational alignment.

**Technology Heterogeneity:** Difficult to use different technology stacks per module. Entire monolith typically implemented in single language runtime. Limits ability to leverage specialized frameworks or languages optimal for specific modules.

**Failure Blast Radius:** Single module failure can crash entire process affecting all modules. Requires extensive fault isolation—circuit breakers, timeouts, resource limits—to prevent cascading failures. Contrast with microservices where service boundaries provide natural fault isolation.

**Resource Contention:** Modules compete for shared resources creating performance unpredictability. Noisy neighbor problems where resource-intensive modules starve others. Requires resource quotas, priority queuing, and careful capacity planning.

**Talent Acquisition:** Engineers expect experience with distributed systems, Kubernetes, and microservices for career growth. Monolithic architectures may be perceived as outdated despite technical advantages. Impacts recruiting and retention.

### Comparison with Alternative Architectures

**[Inference] Versus Microservices:** Modular monolith provides simpler operations, lower latency, and reduced infrastructure costs compared to microservices. Trade-offs include limited independent scaling, deployment coupling, and single technology stack. Microservices offer better fault isolation, team autonomy, and technology diversity at cost of operational complexity.

**[Inference] Versus Serverless:** Serverless functions provide elastic scaling and pay-per-use pricing but introduce cold start latency and limited execution time. Modular monolith better suited for steady-state workloads requiring low latency and long-running processes. Serverless appropriate for bursty workloads and event-driven architectures.

**[Inference] Versus Distributed Monolith:** Distributed monolith combines microservices complexity with monolithic coupling—worst of both approaches. Modular monolith maintains advantages of monolithic architecture (simplicity, performance) while preserving modularity for future extraction.

### Related Topics

- Microservices Architecture for AI Systems
- Service Mesh Integration
- API Gateway Patterns
- Model Serving Architecture
- Multi-Model Serving Patterns
- Event-Driven Architecture
- CQRS and Event Sourcing
- Strangler Fig Migration Pattern
- Deployment Strategies for ML Models
- Container Orchestration for ML Workloads

---

## Vertical Slicing

Vertical slicing in AI system architecture refers to decomposing model training and inference workloads by partitioning the computational graph, data pipeline, and model topology across distinct execution boundaries—typically separate processes, containers, or physical nodes—such that each slice owns a complete subset of the end-to-end path from input to output. Unlike horizontal data parallelism (replicating the full model across workers) or pipeline parallelism (partitioning sequential layers temporally), vertical slicing partitions the model and its associated computational dependencies orthogonally, often by feature spaces, modalities, task heads, or semantic domains.

### Architectural Characteristics

**Partitioning Dimensions:**

- **Feature-space partitioning:** Input feature vectors split across slices based on feature subsets (e.g., embeddings for user behavior vs. content attributes in recommendation systems)
- **Modality-based slicing:** Separate slices handle distinct input modalities (vision, language, audio) with late fusion or no fusion
- **Task-specific slicing:** Multi-task models decomposed by prediction target or business domain (fraud detection, churn prediction, content moderation as independent slices)
- **Ensemble disaggregation:** Ensemble components (boosted trees, neural networks, rule engines) deployed as independent slices with aggregation layer

**Control and Data Plane Separation:**

- Control plane: Orchestrates slice selection, routing logic, feature provisioning, and result aggregation
- Data plane: Each slice executes inference or training independently; slices may share no state or share only specific embedding layers
- Routing logic determines which slices activate for a given request (conditional execution based on feature presence, user segment, or A/B test assignment)

**Data Flow Topology:**

- **Scatter-gather pattern:** Request dispatcher fans out to multiple slices, aggregates responses
- **Conditional routing:** Router directs requests to subset of slices based on input metadata, feature flags, or learned routing policies
- **Hierarchical slicing:** Coarse-grained slices subdivide into finer-grained sub-slices (e.g., language → dialect → domain-specific models)

### Training Lifecycle Implications

**Independent Training Workflows:**

- Each slice trains on filtered or domain-specific data subsets
- Training schedules decoupled: slices update at different cadences based on data drift in their partition
- Hyperparameter optimization, model selection, and evaluation occur per-slice

**Data Ownership and Lineage:**

- Feature engineering pipelines may be slice-specific or shared
- Data versioning must track which slices consumed which datasets at training time
- Schema evolution managed per slice; backward compatibility enforced at aggregation boundaries

**Cross-Slice Dependencies:**

- Shared embedding layers or feature extractors introduce coupling; version skew between slices and shared components creates training-serving skew
- Transfer learning across slices: fine-tuning slice-specific heads atop shared backbone requires coordinated deployment
- Slice interdependencies require dependency graphs in orchestration (e.g., slice B consumes outputs of slice A)

### Inference Serving Architecture

**Request Routing:**

- API gateway or ingress controller applies routing policies (content-based, header-based, latency-based)
- Feature store provides slice-specific features; cold start or missing features trigger fallback behavior
- Dynamic slice activation: enable/disable slices via feature flags without redeploying aggregation logic

**Latency and Throughput Trade-offs:**

- Parallel slice execution: p99 latency determined by slowest slice unless timeouts and partial results supported
- Sequential slice execution with early exit: faster slices gate subsequent expensive slices (e.g., lightweight classifier filters to heavy transformer)
- Resource contention: slices compete for GPU/CPU/memory; isolation via separate pods/nodes increases cost but reduces interference

**Aggregation Strategies:**

- Weighted voting or averaging across slice outputs
- Learned aggregation: meta-model trained on slice outputs (stacking, blending)
- Business logic aggregation: rule-based combination respecting domain constraints (e.g., legal requirements override ML predictions)

**Failure Modes and Degradation:**

- Slice failure: serve partial results, use cached predictions, or fall back to simpler model
- Cascading failures: slice A failure propagates if slice B depends on A's output; circuit breakers isolate failures
- Timeout handling: return best-effort results from responsive slices, log timeout events for retraining routing policies

### Scalability and Resource Management

**Independent Scaling:**

- Each slice scales based on its own traffic, latency SLOs, and resource utilization
- Auto-scaling policies per slice: CPU-based, GPU-based, or custom metrics (e.g., queue depth, cache hit rate)
- Cost optimization: expensive slices (large transformers) provision fewer replicas; cheap slices (linear models) over-provision

**Resource Heterogeneity:**

- GPU-bound slices colocate on accelerator nodes; CPU-bound slices on cheaper instances
- Memory-intensive slices (large embedding tables) use high-memory SKUs
- Mixed-precision inference per slice: FP32 for slices requiring precision, INT8/FP16 for others

**Data Locality:**

- Feature store sharding aligns with slice boundaries to minimize cross-slice data fetching
- Cache warming strategies differ per slice based on access patterns
- Slice-specific feature precomputation and materialization

### Model Lifecycle Orchestration

**Versioning and Deployment:**

- Independent versioning per slice; semantic versioning captures API contract changes at aggregation boundary
- Blue-green or canary deployments per slice without coordinated release of all slices
- Rollback isolated to failing slice; aggregation layer handles version skew gracefully

**A/B Testing and Experimentation:**

- Per-slice experiments: test new model architecture in slice C while slices A/B remain stable
- Cross-slice experiments: test different aggregation strategies or routing policies
- Slice-level traffic splitting: route 10% to experimental slice variant, 90% to production

**Monitoring and Observability:**

- Per-slice metrics: latency, throughput, error rate, prediction distribution, feature drift
- Aggregation-layer metrics: overall system latency, slice contribution to final prediction, routing decision distribution
- Distributed tracing spans each slice invocation; trace IDs propagate for end-to-end visibility
- Slice-specific alerts: model performance degradation, data quality issues, resource exhaustion

### Security and Compliance

**Slice Isolation:**

- Network policies enforce slice-to-slice communication restrictions
- Sensitive slices (PII-handling models) isolate in separate trust boundaries with stricter access controls
- Data residency requirements met by deploying slices in specific regions or availability zones

**Access Control:**

- Slice-level RBAC: different teams own different slices
- API keys or JWT tokens scoped to specific slices
- Audit logs per slice for compliance (GDPR, CCPA, SOC2)

**Model Governance:**

- Slice-specific fairness and bias metrics; high-risk slices undergo additional validation
- Explainability requirements vary by slice: credit-scoring slice requires SHAP values; ad-ranking slice does not
- Model cards or documentation per slice; lineage tracking from training data to deployed slice

### Operational Realities

**Cold Start and Warm-Up:**

- Model loading time per slice on pod startup; stagger slice deployments to avoid simultaneous cold starts
- Cache priming strategies per slice; pre-warm frequently accessed features

**Cost Attribution:**

- Per-slice cost tracking for compute, storage, network egress
- Chargeback models for multi-tenant systems where different business units own slices

**Technical Debt and Complexity:**

- Aggregation logic becomes complex as slices proliferate; risk of spaghetti routing code
- Dependency hell: upgrading shared libraries or frameworks requires coordinated testing across all slices
- Slice proliferation anti-pattern: over-decomposition increases operational burden without proportional benefit

### [Inference] Related Architectural Patterns

- Model Pipeline Parallelism
- Multi-Task Learning Architectures
- Mixture of Experts (MoE)
- Ensemble Serving Topologies
- Federated Model Serving
- Model Chaining and Composition
- Hierarchical Model Architectures

---

## Horizontal Slicing (Monolithic)

Architectural pattern where AI system components are organized into distinct horizontal layers—typically data ingestion, feature engineering, model training, model serving, and application logic—but deployed and operated as a single, tightly coupled unit sharing a common runtime, process space, or deployment artifact.

### Architectural Characteristics

**Unified Deployment Boundary**: All ML pipeline stages (preprocessing, training orchestration, inference serving, feedback collection) exist within a single deployable unit. Model artifacts, feature transformations, and business logic reside in shared memory or local filesystem within the same process or container.

**Shared Resource Pool**: Compute, memory, and storage resources are allocated uniformly across the monolith. No isolation between training workloads and inference serving. GPU/TPU access, if present, is managed through a single scheduler without workload-specific optimization.

**Synchronous Layer Invocation**: Feature computation triggers directly invoke model inference code through in-process function calls or shared libraries. No network serialization overhead between layers. Backpressure propagates immediately across the stack.

**Coupled Data Dependencies**: Feature schemas, model input contracts, and output formats are implicitly coupled through shared codebases. Schema evolution requires coordinated changes across all layers simultaneously.

### Data Flow Architecture

**Vertical Call Stack Execution**: Request flows top-down through application → feature layer → model layer → postprocessing within a single thread of execution or tightly coupled async context. No distributed transaction boundaries.

**In-Memory Feature Materialization**: Feature engineering outputs are passed as in-memory objects (arrays, tensors, dataframes) directly to model inference without serialization. Feature stores, if present, are embedded libraries rather than separate services.

**Model Loading Strategy**: Models loaded into process memory at startup or via lazy initialization. Version updates require process restart or hot-reload mechanisms that risk memory leaks or inconsistent state.

**Feedback Loop Locality**: Online learning or model retraining triggered within the same deployment unit. Training data generated from inference requests is written to local storage or database connections managed by the monolith.

### Model Lifecycle Management

**Atomic Deployment Constraint**: Model updates, feature logic changes, and application code modifications must be deployed together. Canary deployments or A/B tests require duplicate instances of the entire monolith.

**Version Coupling**: Model version is implicitly tied to application version. Rollback of a model defect requires rolling back the entire service, including unrelated business logic or infrastructure changes.

**Training-Serving Skew Risk**: [Inference] Feature computation code duplicated between offline training pipelines and online serving layer. Divergence between training and serving preprocessing logic is difficult to detect until production degradation occurs.

**Experimentation Overhead**: Testing new model architectures or hyperparameters requires cloning the monolith or implementing feature flags that increase code complexity and test surface area.

### Scalability and Performance Envelopes

**Uniform Scaling Constraints**: Horizontal scaling adds replicas of the entire stack. Cannot independently scale computationally expensive inference from lightweight feature retrieval or postprocessing.

**Resource Contention**: CPU-intensive feature engineering competes with GPU inference and I/O-bound data fetching within the same resource pool. [Inference] Memory pressure from model loading can starve feature computation or connection pooling.

**Batch Processing Limitations**: Difficult to implement dynamic batching or request coalescing across different layers without complex internal queuing mechanisms. Batch size optimization is constrained by application-layer timeout requirements.

**Cold Start Penalty**: Startup time includes loading all models, initializing feature computation libraries, and establishing database connections. Autoscaling responsiveness is limited by this initialization overhead.

### Operational and Reliability Concerns

**Blast Radius**: Failure in any layer (OOM in model inference, deadlock in feature computation, application crash) brings down the entire service. No fault isolation between AI and non-AI components.

**Observability Granularity**: Metrics and logs are aggregated at the monolith level. Isolating performance bottlenecks or error rates specific to model inference vs feature computation requires instrumentation discipline.

**Dependency Conflict Resolution**: ML framework versions (TensorFlow, PyTorch), feature engineering libraries (scikit-learn, Spark), and application dependencies must be compatible within a single Python/Java/etc. environment. Dependency hell risk.

**Resource Utilization Inefficiency**: [Inference] Over-provisioning compute for peak inference load leaves feature computation or application logic over-resourced during off-peak. Under-provisioning causes inference latency spikes to degrade application responsiveness.

### Deployment and Testing Strategies

**Integration Testing Scope**: End-to-end tests must validate entire request path from application entry point through feature computation to model inference. Test duration and flakiness increase with monolith complexity.

**Shadow Deployment Complexity**: Running shadow models for validation requires duplicating the entire monolith or implementing complex request mirroring logic that increases latency and resource consumption.

**Model Validation Gates**: Pre-deployment model validation is limited to offline evaluation. Online performance can only be assessed after deploying the full monolith to production or staging environments.

**Configuration Management**: Model hyperparameters, feature flags, and application settings managed through a unified configuration system. Changes to model serving parameters risk unintended impact on application behavior.

### Security and Governance Boundaries

**Unified Access Control**: Model artifacts, training data, and application secrets share the same authentication and authorization context. Principle of least privilege is difficult to enforce across AI and non-AI components.

**Audit Trail Coarseness**: Model predictions, feature values, and application events logged through a common system. Separating ML-specific audit requirements (bias monitoring, explainability) from application logs requires filtering or secondary processing.

**Data Residency Constraints**: Sensitive data used for feature computation or model input cannot be isolated to specific geographic regions or security zones without partitioning the entire monolith.

**Model Governance Enforcement**: [Inference] Policy enforcement for model usage (rate limiting per model, access restrictions, compliance checks) requires application-level logic that is tightly coupled to business code.

### Training Pipeline Integration

**Embedded Training Orchestration**: Training jobs triggered via API endpoints or cron jobs within the monolith. Long-running training workloads block or consume resources needed for inference serving unless careful process isolation is implemented.

**Data Access Patterns**: Training pipeline reads from the same databases or data lakes as the inference path. No separation of OLTP (online serving) and OLAP (offline training) data access patterns.

**Experiment Tracking Locality**: Experiment metadata (hyperparameters, metrics, artifacts) stored in the same data stores as application state. Querying ML experiments can impact serving database performance.

**Model Registry Absence**: [Inference] Model versions may be tracked through application versioning systems (Git tags, artifact repositories) rather than ML-specific registries. Model lineage and metadata are embedded in code comments or external documentation.

### Advantages in Specific Contexts

**Development Velocity for Small Teams**: Single codebase simplifies onboarding, debugging, and refactoring when team size is small and domain complexity is limited.

**Latency Minimization**: Eliminates network hops between feature computation and model inference. In-memory data passing achieves sub-millisecond overhead.

**Simplified Operational Model**: Single deployment unit reduces operational complexity for teams without dedicated ML infrastructure or SRE capacity.

**Rapid Prototyping**: Tight integration enables fast iteration on feature-model co-design without managing service contracts or infrastructure provisioning.

### Degradation and Failure Modes

**Cascading Failures**: Memory leak in feature computation eventually causes OOM in model serving. CPU saturation from inference degrades application responsiveness.

**Poison Pill Requests**: Single adversarial input that triggers expensive feature computation or model inference can degrade throughput for all concurrent requests.

**Model Staleness**: Inability to update models independently means production serves stale models until the next full deployment window.

**Resource Exhaustion**: [Inference] Spike in inference requests can exhaust database connection pools used by application logic, causing unrelated features to fail.

### Migration and Evolution Patterns

**Vertical Slicing Extraction**: Extract specific AI components (e.g., model serving) into separate services while maintaining feature computation in the monolith. Requires introducing network serialization and managing service contracts.

**Horizontal Service Decomposition**: Split monolith by functional domain (e.g., recommendation service, fraud detection service) rather than by AI pipeline stage. Each service retains its own horizontal AI layers.

**Model Serving Separation**: Replace in-process inference with calls to dedicated model serving infrastructure (TensorFlow Serving, Triton, SageMaker) while keeping feature engineering in the monolith.

**Feature Store Introduction**: Extract feature computation into a feature store service, converting the monolith to a feature consumer and model serving host.

### Related Architectural Patterns

- Vertical slicing (microservices for ML)
- Model-as-a-service architecture
- Feature store architecture
- Lambda architecture for ML
- Kappa architecture for ML
- Multi-model serving patterns
- Training-serving separation architectures

---

## Internal Modularity (Monolithic)

Internal modularity in monolithic AI systems refers to the structural decomposition of a single-process or single-deployment-unit architecture into cohesive, loosely-coupled subsystems while maintaining unified runtime boundaries. This pattern addresses complexity management, testability, and evolution velocity without incurring distributed system overhead.

### Architectural Boundaries Within Process Space

Establish clear module boundaries using language-native mechanisms (packages, namespaces, modules) with explicit dependency graphs enforced at build time. Define interface contracts between subsystems—data pipeline modules, feature engineering, model inference, post-processing, logging—through abstract base classes or protocol definitions. Dependency injection patterns enable runtime composition while preserving compile-time type safety.

Module ownership manifests through dedicated code namespaces with isolated test suites and independent versioning semantics. Shared kernel components (configuration management, observability instrumentation, resource pooling) exist as foundation layers with stabilized APIs.

### Data Flow Isolation

Implement immutable data structures passed between module boundaries to prevent unintended state mutation. Use builder patterns or data transfer objects (DTOs) for cross-module communication. Distinguish between internal module state (private caches, model artifacts, connection pools) and shared state (request context, feature stores, configuration).

For streaming workloads, employ in-process queues or reactive streams with backpressure mechanisms to decouple producer-consumer rates between pipeline stages. Batch processing paths use memory-mapped structures or shared memory segments for zero-copy transfer of large tensors or embeddings.

### Model Lifecycle Compartmentalization

Separate model loading, initialization, and lifecycle management into dedicated subsystems. Model registry clients, artifact downloaders, warmup routines, and version managers operate as distinct modules with clean interfaces. Hot-swapping logic resides in a controller module that orchestrates model A/B transitions without blocking inference threads.

Inference execution itself partitions into pre-processing (tokenization, normalization, feature extraction), core model invocation (forward pass, beam search, sampling), and post-processing (detokenization, formatting, safety filtering). Each stage exposes metrics and tracing spans independently.

### Resource Management and Pooling

Centralize resource acquisition (GPU memory, thread pools, network connections) in resource manager modules. Inference workers request resources through allocation interfaces rather than direct creation. Connection pools for downstream services (vector databases, feature stores, validation APIs) maintain their own lifecycle separate from request handling.

Memory allocators for tensor operations use custom arenas or pooling strategies managed by a dedicated memory subsystem. This enables fine-grained telemetry on allocation patterns and facilitates debugging of memory leaks or fragmentation.

### Observability Instrumentation Layers

Structure logging, metrics, and tracing as cross-cutting concerns implemented through aspect-oriented patterns or middleware chains. Each module emits structured events to a centralized telemetry sink without direct coupling to observability backends.

Metric namespaces mirror module hierarchy (e.g., `inference.preprocessor.latency`, `model_loader.cache_hit_rate`). Distributed tracing context propagates through explicit context objects passed across module boundaries, enabling end-to-end visibility within the monolith.

### Configuration and Feature Flag Management

Isolate configuration parsing, validation, and hot-reloading into a configuration module with typed schemas. Feature flags for A/B tests, gradual rollouts, or circuit breakers live in a separate flag evaluation module with caching and staleness policies.

Module-specific configuration sections prevent namespace collisions and enable independent evolution of subsystem parameters. Dynamic reconfiguration triggers module-level reload hooks without full process restart.

### Testing and Development Boundaries

Unit tests target individual modules with mocked dependencies injected through constructor parameters or dependency injection containers. Integration tests exercise module compositions using test doubles for external dependencies (model artifacts, remote services).

Contract tests validate interface stability between modules. Mutation testing and fuzzing apply at module boundaries to verify error handling and input validation. Performance benchmarks isolate individual subsystems to identify optimization targets.

### Failure Isolation and Error Propagation

Implement explicit error types or result monads at module boundaries rather than exception-based control flow across subsystems. Circuit breaker patterns apply to modules interacting with stateful resources (disk I/O for model loading, cache access).

Bulkhead patterns partition thread pools or execution contexts per subsystem to prevent cascading failures. Timeouts and cancellation tokens propagate through module call chains to abort long-running operations.

### Scalability Constraints

Vertical scaling remains the primary scaling axis—adding CPU cores, GPU devices, or memory to the host. Multi-threading or multi-processing within the monolith requires careful synchronization around shared model state. Read-only model artifacts enable safe concurrent inference across threads.

GPU parallelism through model sharding, pipeline parallelism, or tensor parallelism occurs within process boundaries using framework-native distribution primitives (DeepSpeed, Megatron, Ray). [Inference] Inter-module latency overhead remains negligible compared to microservices RPC, enabling tighter optimization feedback loops.

### Evolution and Refactoring Paths

Modular monoliths facilitate incremental extraction to microservices. Well-defined module interfaces become service APIs. Shared libraries evolve into client SDKs. Gradual migration strategies involve dual-writing to both internal modules and external services during transition periods.

Code ownership models assign teams to module namespaces with autonomous deployment cycles for internal changes that respect interface contracts. Shared modules require cross-team approval for breaking changes.

### Security and Access Control

Internal authorization boundaries enforce principle of least privilege through capability-based access patterns. Modules declare required capabilities (model access, PII handling, external network calls) validated at initialization.

Sensitive operations (key management, credential access, audit logging) concentrate in security-focused modules with minimal surface area. Input validation and sanitization occur at system ingress before data propagates to internal modules.

### Cost and Performance Envelopes

Single-process deployment minimizes infrastructure overhead—no service mesh, no inter-service encryption, no serialization boundaries. Latency budgets allocate time across pipeline stages with instrumentation identifying bottlenecks.

Memory footprint optimization focuses on shared model artifacts, efficient tensor storage, and cache eviction policies. Startup time benefits from lazy module initialization and incremental model loading.

### Operational Characteristics

Deployment atomicity ensures all modules update simultaneously, avoiding version skew. Rollback procedures revert the entire application, simplifying release management. Blue-green deployment patterns or canary releases operate at the monolith level.

Log aggregation, metrics collection, and trace correlation remain simpler than distributed systems. Debugging tools (profilers, debuggers, heap analyzers) operate within single process boundaries.

### Related Topics

- Microservices for AI systems
- Model serving architectures
- Modular monolith to microservices migration
- In-process model parallelism
- Shared memory inference optimization
- Monorepo strategies for ML systems
- Plugin architectures for model extensibility

---

## Layered Monolith

A deployment architecture where ML/AI components, application logic, data access, and infrastructure concerns are organized into distinct logical layers within a single deployable unit. All layers execute within the same process boundary and share memory space, with model inference, feature computation, and business logic collocated.

### Architectural Topology

**Presentation Layer**: API gateway, request validation, authentication/authorization, rate limiting, request/response transformation. Handles protocol translation (REST/gRPC/WebSocket) and client-facing contracts.

**Application/Orchestration Layer**: Business logic, workflow orchestration, prompt engineering, multi-step reasoning chains, agent control loops. Coordinates between model invocations, feature retrieval, and downstream services. Contains retry logic, fallback strategies, and request routing decisions.

**ML/Inference Layer**: Model loading, inference execution, tokenization, post-processing, response formatting. Manages model lifecycle (load/unload), batching strategies, and inference optimization (quantization, compilation). May include multiple model types (embedding, reranking, generation) within the same layer.

**Feature/Data Layer**: Feature computation, vector similarity search, context retrieval, prompt assembly, cache access. Interfaces with external feature stores, vector databases, or embedding APIs. Handles data transformation and feature engineering for real-time inference.

**Infrastructure/Persistence Layer**: Database connections, external API clients, logging, metrics emission, configuration management. Abstracts persistence mechanisms and third-party integrations.

### Data Flow Patterns

**Request Path**: Inbound request → presentation validation → orchestration logic → feature retrieval → model inference → response assembly → outbound response. All stages execute sequentially within the same call stack, enabling direct function calls and shared memory access.

**Model Loading**: Models loaded at application startup or lazily on first request. Model weights reside in process memory (heap or memory-mapped files). Multiple models share the same address space, enabling zero-copy weight sharing for architectures with common components (e.g., shared encoder in multi-task models).

**Context Propagation**: Request context (trace IDs, user identity, feature flags) passed through function arguments or thread-local storage. No inter-process communication overhead for context sharing.

### Model Lifecycle Management

**Deployment**: Model artifacts (weights, tokenizers, configs) bundled with application code or mounted as read-only volumes. Version coupling between application code and model weights—code changes and model updates deployed atomically.

**Hot Reload**: [Inference] Not typically supported without process restart. Model updates require full application redeployment or custom hot-reload mechanisms that manage memory allocation and inference engine state transitions.

**Rollback**: Application-level rollback includes model artifacts. Canary or blue-green deployments at the instance level, not model level.

**Multi-Model Serving**: Multiple models loaded in the same process. Resource contention for memory and CPU/GPU between models. Memory fragmentation risk with large language models (LLMs) due to contiguous memory requirements.

### Scalability Characteristics

**Vertical Scaling**: Primary scaling dimension. Add CPU cores, memory, or GPU devices to single instance. GPU utilization depends on batch size and concurrency—low request rates result in GPU underutilization.

**Horizontal Scaling**: Deploy multiple identical instances behind load balancer. Each instance loads complete model copy, multiplying memory footprint. Stateless instances enable trivial horizontal scaling for request throughput but not memory efficiency.

**Resource Utilization**: Shared memory space enables efficient resource allocation for small models. For LLMs (>7B parameters), memory overhead becomes prohibitive—each instance requires 14GB+ RAM for bf16 weights, limiting deployment density.

**Batching Constraints**: Dynamic batching within inference layer to amortize model overhead. Batch size limited by single-process memory and latency requirements. No cross-instance batching—each instance batches independently, reducing batch efficiency under uneven load distribution.

### Latency and Performance Envelope

**Cold Start**: High latency on first request after deployment. Model loading (disk I/O, weight initialization, compilation) occurs synchronously. For 7B parameter models, cold start typically 10-60 seconds depending on storage backend and compilation.

**Warm Path**: Sub-millisecond overhead between layers due to direct function calls. No serialization, network, or IPC latency. P99 latency dominated by model inference time, not architectural overhead.

**Caching**: In-process caching for embeddings, KV-cache for autoregressive generation, prompt prefix caching. Cache hit rate directly impacts P50/P99 latency. Cache eviction policies (LRU, LFU) compete with model weights for memory.

**Throughput Bottlenecks**: Single-threaded inference engines (e.g., PyTorch without threading) limit concurrency. Multi-threaded serving (e.g., vLLM, TensorRT) improves throughput but increases memory usage due to KV-cache replication per request.

### Failure Modes and Reliability

**Blast Radius**: Single process failure terminates all layers. Memory leak, OOM, segmentation fault, or unhandled exception in any layer crashes entire application. Model inference errors (CUDA OOM, numerical instability) propagate across all requests.

**Fault Isolation**: No isolation between layers. Feature computation bug, database connection exhaustion, or model inference hang affects all concurrent requests. Timeouts at orchestration layer provide coarse-grained isolation.

**Degradation Strategies**: Fallback to smaller models or cached responses within application logic. Circuit breakers around external dependencies (feature stores, embedding APIs) prevent cascading failures. Graceful degradation requires application-level logic—no infrastructure-level isolation.

**Recovery Time**: Process restart required for most failures. Health checks at load balancer detect unresponsive instances. Rolling restart across instance pool limits impact. Recovery time = instance startup + model loading (10s-60s for LLMs).

### Observability and Debugging

**Tracing**: Single-process tracing captures all layer transitions in unified trace. Detailed call stacks and intra-layer timing without distributed tracing overhead. OpenTelemetry spans track model inference latency, feature retrieval time, and orchestration overhead.

**Metrics**: Process-level metrics (CPU, memory, GPU utilization) directly correlate with request load. Model-specific metrics (token throughput, batch size, KV-cache hit rate) emitted from inference layer. Metric aggregation simpler than distributed systems—no clock synchronization issues.

**Logging**: Centralized logging within process. Request-scoped logging with trace ID propagation. Model inference logs (input tokens, output tokens, generation parameters) colocated with application logs. Log volume proportional to request rate—high throughput saturates I/O.

**Profiling**: CPU/GPU profiling tools (py-spy, NVIDIA Nsight) capture end-to-end execution. Memory profiling identifies layer-specific allocation patterns. Inference engine profiling (TensorRT profiler, PyTorch profiler) reveals model-level bottlenecks.

### Security and Compliance

**Attack Surface**: Single API endpoint exposes all functionality. Authentication/authorization at presentation layer controls access. No internal network segmentation—compromised process accesses all data and models.

**Data Isolation**: No multi-tenancy isolation within process. All requests share memory space. Sensitive data (PII, proprietary prompts) resides in heap memory accessible to any layer. Memory scrubbing after request completion depends on runtime garbage collection.

**Model Protection**: Model weights loaded in process memory are extractable via memory dump. No cryptographic protection at rest in memory. Model extraction risk via side-channel attacks (timing, cache) or memory access vulnerabilities.

**Secrets Management**: API keys, database credentials, model access tokens loaded at startup. Stored in environment variables or mounted secrets. No runtime secret rotation without process restart.

### Cost Structure

**Compute Costs**: Instance cost proportional to peak resource requirements. LLM serving requires GPU instances (A100, H100) with 40GB-80GB VRAM. Underutilization during low-traffic periods—paying for idle capacity.

**Memory Overhead**: Each instance duplicates model weights and application code. For N instances of 7B model, total memory = N × (14GB model + application overhead). No weight sharing across instances.

**Storage Costs**: Model artifacts stored per instance (container image or mounted volume). For large models, container images reach 10GB-50GB, increasing registry storage and transfer costs.

**Operational Costs**: Simplified deployment reduces operational overhead. No service mesh, distributed tracing infrastructure, or inter-service governance. Fewer network hops reduce data transfer costs.

### Development and Operational Characteristics

**Development Velocity**: Simplified debugging with single-process execution. Local development mirrors production topology. No distributed system testing complexity. Tight coupling between layers enables rapid iteration but increases merge conflict risk.

**Deployment Atomicity**: Single deployment unit ensures consistent versioning across layers. No version skew between model and application logic. Schema migrations coupled with code deployment—requires coordination between data layer and infrastructure.

**Testing**: Integration tests execute full stack in single process. Model inference testing requires GPU access or mock inference engines. Load testing requires provisioning production-equivalent instances—cannot test horizontal scaling without full instance pool.

**Operational Complexity**: Single artifact to deploy. No service discovery, inter-service authentication, or distributed configuration management. Simplified CI/CD pipelines. Rollback strategy simpler—revert single deployment.

### Technology Stack Examples

**Python-based**: FastAPI/Flask + PyTorch/TensorFlow + SQLAlchemy + Redis client. Model loaded via `torch.load()` at startup. Inference executed synchronously in request handler or async with executor pools.

**JVM-based**: Spring Boot + DJL/ONNX Runtime + JDBC + Jedis. Model loaded via `Predictor` abstraction. Inference executed in controller methods with thread pool isolation.

**Node.js-based**: Express + ONNX Runtime Node.js + Sequelize + ioredis. Model loaded via `InferenceSession.create()`. Inference executed with async/await patterns.

**Rust-based**: Axum + Candle/Burn + Diesel + redis-rs. Model loaded at startup with memory-mapped weights. Inference executed with async runtime (Tokio).

### Applicable Scenarios

**Low-to-Medium Request Volume**: Request rates where single instance handles traffic (10-1000 RPS depending on model size). Horizontal scaling for availability, not throughput.

**Small-to-Medium Models**: Models fitting in single-instance memory (up to ~13B parameters on 80GB GPU instances with quantization). Embedding models, small LLMs, fine-tuned domain-specific models.

**Latency-Sensitive Applications**: P99 latency requirements where inter-service network hops are unacceptable. Real-time inference for chat, autocomplete, or interactive agents.

**Rapid Prototyping**: Early-stage products where system boundaries are unclear. Enables experimentation without distributed system overhead.

**Regulatory Constraints**: Environments requiring single-deployment-unit compliance certification. Simplifies audit scope—all logic resides in one artifact.

### Constraints and Limitations

**Memory Ceiling**: Single-instance memory limits model size. LLMs >70B parameters infeasible without model parallelism (not supported in monolith). GPU memory limits batch size and KV-cache capacity.

**Blast Radius**: Process failure affects all requests. No incremental degradation—binary availability state (all requests succeed or all fail).

**Resource Contention**: CPU/GPU/memory contention between layers. Feature computation competes with model inference for resources. Difficult to prioritize critical path without explicit resource allocation.

**Deployment Granularity**: Cannot deploy model updates independently from application logic. Model experimentation (A/B testing, canary rollouts) requires full application deployment.

**Scalability Limits**: Vertical scaling ceiling reached at largest instance types. Horizontal scaling multiplies memory footprint linearly with instance count.

### Related Architectural Patterns

- Microservices for ML (separate model serving services)
- Model-as-a-Service (external inference APIs)
- Sidecar Pattern (model server as sidecar container)
- Modular Monolith (stronger layer boundaries, potential extraction path)
- Service-Oriented Architecture (coarse-grained service decomposition)
- Serverless ML Inference (function-based model serving)
- Model Mesh (shared model serving infrastructure)

---

