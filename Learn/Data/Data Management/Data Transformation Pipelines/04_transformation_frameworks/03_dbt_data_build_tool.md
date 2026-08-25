## dbt (Data Build Tool)


### Compilation and DAG Topology

dbt operates as a stateless compilation and orchestration layer that abstracts transformation logic into a Directed Acyclic Graph (DAG) of Select statements. Unlike traditional ETL tools that process data in-memory on a dedicated server, dbt enforces a pure ELT (Extract, Load, Transform) model. It does not extract data to an intermediate processing layer; instead, it compiles Jinja-enriched SQL files into raw, platform-specific SQL commands (DDL/DML) and pushes their execution down to the underlying compute engine (e.g., Snowflake, BigQuery, Databricks, Redshift).

- **Graph Construction:** At runtime, dbt parses the project directory, resolving `ref()` and `source()` calls to construct a lineage graph. This graph dictates the execution order, ensuring upstream dependencies (parents) materialize successfully before downstream nodes (children) initiate.
    
- **Manifest Artifact:** The compilation phase produces a `manifest.json` artifact, a comprehensive state file describing the project's full logical topology, configuration, and resource attributes. This artifact is critical for state-based selection and CI/CD operations.
    
- **Parallelization:** Execution is parallelized at the thread level. The `threads` configuration determines the maximum number of concurrent connections to the warehouse. Independent branches of the DAG execute simultaneously, constrained only by the warehouse's queue depth and the client-side thread limit.
    

### Materialization Strategies

Materializations define the persistence mechanism for a model's output. They are configurable at the project, directory, or model level and govern the DDL wrapped around the compiled Select statement.

- **View:** The default strategy. Creates a logical view (`CREATE VIEW AS...`). Guarantees zero data latency but incurs compute costs on every read. Best for lightweight transformations or staging layers.
    
- **Table:** materializes the query result as a physical table (`CREATE TABLE AS...`). Provides high read performance for downstream consumers but requires a full rebuild (drop and create) on every run, making it unsuitable for massive datasets requiring high frequency updates.
    
- **Ephemeral:** A compilation-time abstraction. The model is not materialized in the database; instead, its logic is interpolated as a Common Table Expression (CTE) into dependent models. Used to break up complex logic without polluting the database schema, but excessive chaining can degrade query optimizer performance.
    
- **Materialized View:** Leveraging platform-native materialized views (e.g., Snowflake Materialized Views, Databricks Materialized Views) to offload incremental maintenance to the data warehouse's internal engine rather than dbt's orchestration.
    

### Incremental Processing and State Management

For large-scale datasets, full table rebuilds are cost-prohibitive. Incremental models maintain state by transforming only new or modified data.

- **Execution Logic:** The `is_incremental()` macro acts as a conditional gate. During the initial run, it returns `false`, triggering a full table build. In subsequent runs, it returns `true`, injecting `WHERE` clauses (e.g., `event_time > (select max(event_time) from {{ this }})`) to limit the scan to the delta.
    
- **Merge Strategy:** The standard approach for upserts. Requires a `unique_key`. dbt generates a `MERGE` statement (or `UPDATE` + `INSERT` on generic Postgres) to atomically update existing records and insert new ones.
    
- **Delete+Insert Strategy:** An alternative for warehouses that do not support efficient merges or when handling late-arriving data in partitions. It deletes records in the target table that overlap with the new batch's keys/partitions before inserting the new data.
    
- **Insert Overwrite:** Highly efficient for partitioned datasets (e.g., in Spark/Databricks or BigQuery). It replaces entire partitions of data atomically rather than row-by-row merging. This operation is often idempotent and avoids expensive shuffle operations associated with merges.
    

### Snapshotting and SCD Type 2

dbt provides a native mechanism for Slowly Changing Dimensions (SCD) Type 2, enabling historical tracking of mutable source data.

- **Timestamp Strategy:** Relies on a reliable `updated_at` column in the source. dbt compares the source timestamp with the target's `dbt_updated_at`. If the source is newer, the current record is "expired" (updating `dbt_valid_to`), and a new active record is inserted.
    
- **Check Strategy:** Used when no reliable timestamp exists. A list of columns is hashed or compared by value. Any change in the hash triggers a version rotation. This is more compute-intensive as it requires full value comparison.
    

### Schema Evolution and Contracts

Handling upstream schema changes (drift) is critical for pipeline stability.

- **On Schema Change:** Configurable behavior for incremental models when the new batch's schema differs from the target table. Options include `ignore` (silent failure risk), `fail` (enforce strict schema), `append_new_columns` (schema evolution), or `sync_all_columns` (drops removed columns, adds new ones).
    
- **Model Contracts:** Enforces a strict interface for a model. Constraints (data types, nullability, primary keys) are defined in YAML and validated during compilation. If the transformation logic produces a result that violates the contract, the run fails before materialization, preventing data quality erosion.
    

### Testing and Data Integrity

Testing is a first-class citizen, asserted via YAML configurations or specific SQL files.

- **Generic Tests:** Parametrized assertions (unique, not_null, accepted_values, relationships) applied to columns. These compile into `SELECT count(*) ... HAVING count(*) > 0` queries. If rows are returned, the test fails.
    
- **Singular Tests:** Custom SQL queries written to capture specific business logic failures (e.g., ensuring total debit equals total credit).
    
- **Blocking vs. Warning:** Tests can be configured to `warn` (alert but proceed) or `error` (halt pipeline execution), enabling "circuit breaker" patterns in DAG execution.
    

### CI/CD and Slim CI

Advanced deployment workflows utilize dbt's state awareness to optimize build times.

- **State Comparison:** Using `dbt build --select state:modified --state path/to/base_manifest`, dbt compares the current code against the manifest from the production branch.
    
- **Slim CI:** Only models that have been modified (and their downstream dependencies) are executed. This drastically reduces compute costs and feedback loops in Pull Request validation pipelines.
    
- **Deferral:** In development environments, dbt can "defer" references to unbuilt upstream models to a production namespace. This allows developers to build a leaf node without needing to materialize the entire lineage chain locally.
    

### Related Topics

- Modern Data Stack
    
- ELT Architecture
    
- Jinja Templating
    
- Slowly Changing Dimensions (SCD)
    
- Data Observability
    
- Data Lakehouse Architecture

---

