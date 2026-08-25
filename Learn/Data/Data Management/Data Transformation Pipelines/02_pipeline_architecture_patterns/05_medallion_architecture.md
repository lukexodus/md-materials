## Medallion Architecture


This architectural pattern organizes data within a lakehouse or data lake environment into logically separated layers—Bronze (Raw), Silver (Refined), and Gold (Curated). It functions as a progressive data quality pipeline, transforming unverified, high-volume raw data into reliable, optimized business-level entities. The architecture prioritizes atomicity, consistency, isolation, and durability (ACID) compliance in distributed object stores, leveraging modern table formats (Delta Lake, Apache Iceberg, Apache Hudi) to bridge the gap between traditional warehouses and scalable data lakes.

### Architecture Principles and Data Flow Topology

The data flow topology is strictly unidirectional from Bronze to Gold during standard operation, enforcing a lineage of transformation where data quality increases at each stage. This design decouples data ingestion (write-heavy, high throughput) from data consumption (read-heavy, low latency).

- **Multi-Hop Processing:** Data traverses distinct zones. Each hop represents a checkpoint where specific data quality constraints and transformations are applied. This checkpointing enables fault isolation; a corruption in the Gold layer can be rebuilt deterministically from the persistent Silver state without re-ingesting from source systems.
    
- **Unified Batch and Streaming:** The architecture supports a unified interface for both bounded (batch) and unbounded (stream) datasets. Ingestion into Bronze often utilizes streaming listeners (e.g., Kafka connect, Auto Loader), while propagation to Silver and Gold can be triggered via micro-batches or scheduled batch jobs.
    
- **Immutable Source of Truth:** The Bronze layer serves as the immutable record of all received data. Downstream transformations (Silver/Gold) are materialized views or derived tables of this raw history, allowing for complete reprocessing (backfilling) in response to logic changes or bug fixes.
    

### Bronze Layer: Raw Ingestion and Immutable Persistence

The Bronze layer functions as an append-only sink for high-throughput data ingestion. Its primary objective is low-latency write performance and zero data loss. It stores data in its "native" format or a raw, structure-agnostic container format.

- **Schema-on-Read Semantics:** Ingestion pipelines generally employ schema-on-read or loose schema validation to prevent pipeline breakage due to upstream schema drift. All columns are often ingested as strictly typed fields or a single variant/JSON column to preserve fidelity.
    
- **Partitioning Strategy:** Data is typically partitioned by wall-clock ingestion time (`YYYY-MM-DD` or `YYYY-MM-DD-HH`) rather than event time. This optimizes write throughput by avoiding expensive shuffling or re-partitioning operations during ingestion and simplifies incremental ETL based on file arrival time.
    
- **CDC Raw Logs:** For Change Data Capture (CDC) sources, the Bronze layer acts as a log store, capturing `INSERT`, `UPDATE`, and `DELETE` operations as distinct row entries. No reconciliation or merging occurs here; the history of changes is preserved linearly.
    
- **Metadata Columns:** Ingestion pipelines augment records with technical metadata, including `ingest_timestamp`, `source_system_id`, and `input_filename`, to support lineage tracing and auditability.
    

### Silver Layer: Refinement, Deduplication, and State Reconstruction

The Silver layer represents the "Enterprise Data Warehouse" view within the lake. It creates a cleansed, conformed, and enriched version of the data. This layer often transitions from the raw, append-only model of Bronze to a mutable, stateful model representing the current state of entities.

- **Schema Enforcement and Validation:** Explicit schemas are applied. Data violating strict type constraints or business rules (e.g., referential integrity checks) is quarantined into "Dead Letter Queues" (DLQ) or error tables, preventing pollution of the analytical dataset.
    
- **Deduplication and Ordering:** Handling at-least-once delivery guarantees from upstream message queues (like Kafka) requires deduplication logic. Transformations must effectively identify unique records using primary keys and handle out-of-order events using event-time watermarking to ensure the correct version of a record is persisted.
    
- **CDC Reconciliation (SCD Handling):** Raw CDC logs from Bronze are merged to reconstruct the latest state of an entity.
    
    - **SCD Type 1 (Overwrite):** `MERGE INTO` operations update existing records with new values based on primary keys.
        
    - **SCD Type 2 (History):** Historical versions are maintained with `valid_from` and `valid_to` timestamps. This requires complex stateful processing to close out previous validity windows and insert new active rows.
        
- **Data Enrichment:** Reference data (e.g., lookup tables) is joined with transaction streams. Broadcast joins are preferred here if the dimension tables are small enough to fit in executor memory, minimizing shuffle overhead across the cluster.
    

### Gold Layer: Aggregation and Business-Aligned Views

The Gold layer is highly optimized for read performance and consumption by downstream analytics, ML models, and reporting dashboards. Data is organized into project-specific databases or domain-oriented data marts.

- **Read-Optimized Layouts:** Storage layout is tuned for query performance. Techniques such as Z-Ordering (multi-dimensional clustering) or Hilbert curves are applied to co-locate data based on frequent query predicates, maximizing data skipping efficiency during table scans.
    
- **Pre-Aggregation:** Granular transaction data from Silver is aggregated into summary tables (e.g., `daily_sales_revenue`, `monthly_active_users`). This reduces compute costs for repetitive dashboard queries by materializing the results of expensive `GROUP BY` operations.
    
- **Star/Snowflake Schemas:** Data is often denormalized into wide tables or structured into Kimball-style Star Schemas (Fact and Dimension tables) to align with BI tool requirements (PowerBI, Tableau).
    
- **Business Logic Application:** Complex KPIs, window functions, and cross-domain joins are executed here. This layer represents the "truth" for business reporting, incorporating logic that filters out non-relevant data (e.g., test accounts, internal traffic).
    

### Transactional Guarantees and State Management

Implementing Medallion architecture on distributed object stores relies heavily on the transactional capabilities of the underlying table format.

- **ACID Transactions:** Atomicity is critical. Multi-file writes must either succeed completely or fail completely. This is achieved via commit protocols (e.g., Optimistic Concurrency Control in Delta Lake) that verify no conflicting writes have occurred before finalizing a snapshot.
    
- **Snapshot Isolation:** Readers of Gold tables must see a consistent snapshot of the data, even while Silver-to-Gold pipelines are actively writing updates. This eliminates "dirty reads" and ensures report consistency.
    
- **Time Travel:** The transaction log (e.g., `_delta_log`) enables querying previous versions of a table (`AS OF VERSION` or `AS OF TIMESTAMP`). This facilitates debugging, auditing, and instant rollback of accidental data deletions or corrupt transformations.
    

### Operational Characteristics and Performance Optimization

- **Compaction (Bin-packing):** Streaming ingestion into Bronze creates "small file problems" (many KB-sized files) that degrade read performance. Background auto-compaction jobs coalesce these small files into larger, optimal sizes (e.g., 128MB - 1GB) without blocking concurrent reads.
    
- **Vacuuming:** Old data files no longer referenced by a valid snapshot (beyond the retention period) are physically deleted to reclaim storage costs and enforce GDPR/CCPA "right to be forgotten" compliance.
    
- **Incremental Processing:** Pipelines utilize checkpointing mechanisms to track stream progress (offsets). This ensures exactly-once processing semantics during normal operation and allows pipelines to resume from the point of failure without reprocessing the entire dataset.
    
- **Partition Pruning:** Efficient partition schemes in Silver and Gold (e.g., partitioning by `Country` or `Year`) allow the query engine to skip scanning irrelevant directories, significantly reducing I/O.
    

### Related Topics

- Lambda Architecture
    
- Kappa Architecture
    
- Data Mesh (Domain-oriented ownership)
    
- Slowly Changing Dimensions (SCD)
    
- Change Data Capture (CDC)
    
- Data Lakehouse
    
- ACID Compliance in Distributed Systems

---

