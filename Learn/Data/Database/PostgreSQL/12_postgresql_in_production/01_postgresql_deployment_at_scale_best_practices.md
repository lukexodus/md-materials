## PostgreSQL Deployment at Scale: Best Practices


### Architecture Planning

#### Hardware Considerations

Properly sizing PostgreSQL deployments requires careful hardware planning:

- **CPU**: PostgreSQL benefits from fast single-thread performance and multiple cores
  - High clock speeds (3.5+ GHz) for OLTP workloads
  - 16+ cores for mixed workloads with parallel query capabilities
  - Consider AMD EPYC or Intel Xeon processors with high single-thread performance

- **Memory**: Crucial for performance, especially buffer cache
  - Minimum: 8GB for small databases
  - Recommended: Enough RAM to hold frequently accessed data (typically 25-40% of database size)
  - Enterprise deployments: 128GB-1TB depending on workload
  - Consider NUMA architecture effects for servers with large memory configurations

- **Storage**: I/O performance critically impacts database performance
  - Use enterprise-grade NVMe SSDs for best performance
  - RAID 10 for both performance and redundancy
  - Separate volumes for:
    - Data directory
    - WAL (write-ahead log)
    - Indexes
    - pg_wal directory (transaction logs)
    - Backup location

- **Network**: Often overlooked but significant for high-traffic databases
  - 10GbE minimum for production environments
  - 25/40/100GbE for large-scale deployments
  - Consider dedicated network for replication traffic

#### Capacity Planning

- **Growth Projection**: Plan for 18-24 months of expected growth
  - Include headroom for unexpected spikes (2-3x normal load)
  - Account for both data volume and query complexity increases

- **Performance Testing**: Conduct load testing that mimics production
  - Use pgbench for basic benchmarking
  - Create custom benchmarks that reflect actual workload patterns
  - Test for peak load scenarios, not just average

- **Scalability Limits**: Understand PostgreSQL's inherent limitations
  - Single primary node for writes
  - Shared_buffers typically limited to 25-40% of system RAM
  - Consider table partitioning early if expecting >1TB tables

### High Availability Setup

#### Replication Strategies

PostgreSQL offers multiple replication options:

- **Physical Replication**:
  - **Streaming Replication**: Real-time WAL streaming to replicas
    ```
    # In postgresql.conf on primary
    wal_level = replica
    max_wal_senders = 10
    wal_keep_size = 2GB
    
    # In pg_hba.conf on primary
    host replication replicator 10.0.0.0/24 md5
    
    # In recovery.conf on standby
    primary_conninfo = 'host=primary port=5432 user=replicator password=secret'
    ```
  
  - **Synchronous Replication**: Ensures transactions commit on multiple servers
    ```
    # In postgresql.conf on primary
    synchronous_standby_names = 'FIRST 1 (standby1, standby2)'
    ```
  
  - **Cascading Replication**: Replicas can stream to other replicas
    ```
    # In recovery.conf on downstream standby
    primary_conninfo = 'host=upstream-standby port=5432 user=replicator password=secret'
    ```

- **Logical Replication** (PostgreSQL 10+):
  - Publication/subscription model
  - Supports selective replication (specific tables)
  - Enables zero-downtime major version upgrades
    ```sql
    -- On publisher
    CREATE PUBLICATION sales_pub FOR TABLE sales, customers;
    
    -- On subscriber
    CREATE SUBSCRIPTION sales_sub 
    CONNECTION 'host=publisher dbname=sales user=replicator password=secret' 
    PUBLICATION sales_pub;
    ```

#### Automated Failover Solutions

- **Patroni**: Industry-standard high-availability solution
  - Uses etcd, Consul, or ZooKeeper for consensus
  - Handles automatic failover and leader election
  - Manages configuration dynamically
  - Example configuration:
    ```yaml
    scope: postgres-cluster
    namespace: /service/
    name: postgresql0
    
    restapi:
      listen: 0.0.0.0:8008
    
    etcd:
      host: 127.0.0.1:2379
    
    bootstrap:
      dcs:
        ttl: 30
        loop_wait: 10
        postgresql:
          use_pg_rewind: true
          parameters:
            max_connections: 1000
            shared_buffers: 8GB
    ```

- **pg_auto_failover**: Lightweight automated failover solution
  - Built-in monitor node for state coordination
  - Simpler setup than Patroni but less flexible

- **repmgr**: Replication manager for PostgreSQL clusters
  - Monitors replication
  - Performs standby promotion
  - Requires additional tooling for complete automation

#### Disaster Recovery Planning

- **Recovery Point Objective (RPO)**:
  - Synchronous replication: Near-zero RPO
  - Asynchronous replication: Typically seconds, but potentially more during network issues
  - PITR with archived WAL: Determined by archive_timeout setting

- **Recovery Time Objective (RTO)**:
  - Automated failover: Typically 10-30 seconds
  - Manual promotion: Minutes to hours depending on procedures
  - Full restore from backup: Hours to days depending on size

- **Geo-distributed Disaster Recovery**:
  - Maintain standby clusters in different geographic regions
  - Consider async replication for distant locations
  - Test recovery procedures regularly (at least quarterly)

### Performance Optimization

#### Configuration Tuning

Key PostgreSQL configuration parameters to tune:

- **Memory-related**:
  ```
  # Typically 25% of RAM, up to 8GB on Windows, higher on Linux/Unix
  shared_buffers = 8GB
  
  # 50-75% of available RAM / max_connections
  work_mem = 64MB
  
  # 5-10% of RAM for maintenance operations
  maintenance_work_mem = 1GB
  
  # Should be at least 2x maintenance_work_mem
  effective_cache_size = 24GB
  ```

- **Write Performance**:
  ```
  # Distance in WAL segments between automatic WAL checkpoints
  max_wal_size = 16GB
  
  # Target checkpoint completion percentage per interval
  checkpoint_completion_target = 0.9
  
  # Controls WAL write behavior, consider 'on' for better reliability
  synchronous_commit = on
  ```

- **Query Execution**:
  ```
  # Number of background writer processes
  max_worker_processes = 8
  
  # Maximum workers for parallel query execution
  max_parallel_workers = 8
  
  # Maximum workers per query
  max_parallel_workers_per_gather = 4
  
  # Cost threshold for using parallelism
  parallel_tuple_cost = 0.1
  ```

- **Connection Management**:
  ```
  # Maximum allowed connections
  max_connections = 200
  ```

#### Indexing Strategies

- **Index Types**:
  - B-tree: Default, good for equality and range queries
    ```sql
    CREATE INDEX idx_customer_last_name ON customers(last_name);
    ```
  
  - GIN: Optimized for composite values and full-text search
    ```sql
    CREATE INDEX idx_document_text ON documents USING GIN(to_tsvector('english', body));
    ```
  
  - BRIN: Block Range INdexes for very large tables with natural ordering
    ```sql
    CREATE INDEX idx_logs_timestamp ON system_logs USING BRIN(created_at);
    ```
  
  - Partial: Index subset of table for better performance and smaller size
    ```sql
    CREATE INDEX idx_active_users ON users(last_login) WHERE active = true;
    ```
  
  - Expression: Index on expressions for optimizing complex WHERE conditions
    ```sql
    CREATE INDEX idx_email_domain ON users(LOWER(email));
    ```

- **Index Maintenance**:
  - Regular VACUUM and ANALYZE to update statistics
  - Monitor index usage with pg_stat_user_indexes
  - Remove unused indexes that add write overhead
  - Consider covering indexes for read-heavy workloads
    ```sql
    CREATE INDEX idx_order_cover ON orders(order_date) INCLUDE (customer_id, status);
    ```

#### Query Optimization

- **Explain Analyze**: Essential for understanding query execution
  ```sql
  EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) 
  SELECT * FROM orders 
  WHERE order_date > '2023-01-01' AND customer_id = 12345;
  ```

- **Common Query Patterns to Optimize**:
  - Use `EXISTS()` instead of `COUNT()` for existence checks
  - Prefer JOINs over correlated subqueries
  - Use LIMIT clauses for ranking/top-N queries
  - Consider WITH queries (CTEs) for readability, but beware materialization overhead
  - Use window functions instead of self-joins for aggregate calculations

- **Server-side Statement Caching**:
  ```
  # In postgresql.conf
  prepared_statements_cache_size = 256MB
  ```

### Database Organization

#### Partitioning

- **Table Partitioning** (PostgreSQL 10+):
  - Range Partitioning for time-series data
    ```sql
    CREATE TABLE measurements (
        logdate date not null,
        device_id int not null,
        temperature float not null
    ) PARTITION BY RANGE (logdate);
    
    CREATE TABLE measurements_y2023m01 PARTITION OF measurements
        FOR VALUES FROM ('2023-01-01') TO ('2023-02-01');
    CREATE TABLE measurements_y2023m02 PARTITION OF measurements
        FOR VALUES FROM ('2023-02-01') TO ('2023-03-01');
    ```
  
  - List Partitioning for categorical data
    ```sql
    CREATE TABLE sales (
        sale_date date not null,
        region text not null,
        amount decimal not null
    ) PARTITION BY LIST (region);
    
    CREATE TABLE sales_america PARTITION OF sales
        FOR VALUES IN ('North America', 'South America');
    CREATE TABLE sales_europe PARTITION OF sales
        FOR VALUES IN ('Europe');
    CREATE TABLE sales_asia PARTITION OF sales
        FOR VALUES IN ('Asia', 'Middle East');
    ```
  
  - Hash Partitioning for distributing load evenly
    ```sql
    CREATE TABLE orders (
        order_id bigint not null,
        customer_id bigint not null,
        order_date date not null
    ) PARTITION BY HASH (customer_id);
    
    CREATE TABLE orders_p0 PARTITION OF orders
        FOR VALUES WITH (MODULUS 4, REMAINDER 0);
    CREATE TABLE orders_p1 PARTITION OF orders
        FOR VALUES WITH (MODULUS 4, REMAINDER 1);
    CREATE TABLE orders_p2 PARTITION OF orders
        FOR VALUES WITH (MODULUS 4, REMAINDER 2);
    CREATE TABLE orders_p3 PARTITION OF orders
        FOR VALUES WITH (MODULUS 4, REMAINDER 3);
    ```

- **Partition Maintenance**:
  - Automatic partition creation tools (pg_partman extension)
  - Automated detachment and archiving of old partitions
  - Indexes on individual partitions vs. global indexes

#### Schema Design for Scale

- **Normalization vs. Denormalization**:
  - Normalize for data integrity, correctness, and storage efficiency
  - Denormalize for read performance when necessary
  - Consider materialized views for performance-critical reporting queries
    ```sql
    CREATE MATERIALIZED VIEW monthly_sales AS
    SELECT date_trunc('month', sale_date) AS month,
           product_id,
           sum(quantity) AS units_sold,
           sum(quantity * price) AS revenue
    FROM sales
    GROUP BY date_trunc('month', sale_date), product_id;
    
    -- Refresh strategy
    REFRESH MATERIALIZED VIEW CONCURRENTLY monthly_sales;
    ```

- **Table Inheritance** vs. Partitioning:
  - Table inheritance for logical organization
  - Partitioning for performance and data lifecycle management

- **JSON/JSONB for Flexibility**:
  - Use JSONB for semi-structured data
  - Index specific JSON paths for frequently-queried attributes
    ```sql
    CREATE INDEX idx_user_preferences_theme ON users((preferences->>'theme'));
    ```
  - Balance between normalized columns and JSON fields

### Monitoring and Maintenance

#### Comprehensive Monitoring Setup

- **Critical Metrics to Monitor**:
  - Connection usage (vs. max_connections)
  - Transaction rates (commits, rollbacks)
  - Cache hit ratios (shared_buffers, OS cache)
  - Disk I/O utilization
  - Replication lag
  - Lock contention
  - Long-running queries

- **Useful Extensions**:
  - pg_stat_statements: Query performance analysis
    ```sql
    -- Enable extension
    CREATE EXTENSION pg_stat_statements;
    
    -- Find most time-consuming queries
    SELECT query, 
           calls, 
           total_exec_time, 
           rows, 
           100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0) AS hit_percent
    FROM pg_stat_statements
    ORDER BY total_exec_time DESC
    LIMIT 10;
    ```
  
  - pgstattuple: Detailed table and index bloat analysis
  - pg_wait_sampling: Collect statistics on wait events
  - pg_qualstats: Gather statistics on predicates

- **Monitoring Tools Integration**:
  - Prometheus + Grafana dashboards
  - pg_exporter metrics collector
  - pgwatch2
  - AWS CloudWatch (for RDS)
  - Azure Monitor (for Azure Database for PostgreSQL)

#### Regular Maintenance Tasks

- **VACUUM Operations**:
  - Configure autovacuum properly
    ```
    # In postgresql.conf
    autovacuum = on
    autovacuum_max_workers = 5
    autovacuum_naptime = 1min
    autovacuum_vacuum_threshold = 50
    autovacuum_analyze_threshold = 50
    autovacuum_vacuum_scale_factor = 0.1  # 10% of table changed
    autovacuum_analyze_scale_factor = 0.05  # 5% of table changed
    ```
  
  - Schedule manual VACUUM FULL operations during maintenance windows
  - Monitor for table bloat with pgstattuple extension

- **Database Statistics**:
  - Regular ANALYZE to update statistics for query planner
  - More frequent ANALYZE on rapidly changing tables
  - Set default statistics target appropriately
    ```
    # In postgresql.conf
    default_statistics_target = 100  # Default
    ```
    
    ```sql
    -- Table-specific statistics target
    ALTER TABLE large_complex_table ALTER COLUMN variable_column SET STATISTICS 1000;
    ```

- **Index Maintenance**:
  - Monitor index usage and bloat
  - Rebuild bloated indexes during low-traffic periods
  - Remove unused indexes

### Scaling Strategies

#### Vertical Scaling Limits

- **Resources that Scale Well**:
  - RAM: Larger shared_buffers and work_mem improve performance
  - CPU: More cores help with parallel query execution
  - Storage: Faster disks improve I/O performance

- **Diminishing Returns**:
  - PostgreSQL architecture limits (shared_buffers size constraints)
  - Single-instance write capacity ceiling
  - Maximum practical connection count

#### Horizontal Scaling Approaches

- **Read Scaling**:
  - Multiple read replicas
  - Connection pooling with pgBouncer to distribute read traffic
    ```
    # pgbouncer.ini
    [databases]
    postgres = host=127.0.0.1 port=5432 dbname=postgres
    
    [pgbouncer]
    listen_port = 6432
    listen_addr = *
    auth_type = md5
    auth_file = /etc/pgbouncer/userlist.txt
    pool_mode = transaction
    max_client_conn = 10000
    default_pool_size = 100
    ```
  
  - Load balancer configuration for read traffic distribution

- **Write Scaling Approaches**:
  - Functional partitioning (separate databases by function)
  - Sharding with application-level routing
  - Foreign Data Wrappers for cross-database querying
    ```sql
    -- Create foreign server
    CREATE SERVER foreign_server
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host 'remote-server', port '5432', dbname 'remote_db');
    
    -- Create user mapping
    CREATE USER MAPPING FOR local_user
    SERVER foreign_server
    OPTIONS (user 'remote_user', password 'secret');
    
    -- Create foreign table
    CREATE FOREIGN TABLE remote_sales (
        id integer NOT NULL,
        sale_date date,
        amount numeric
    )
    SERVER foreign_server
    OPTIONS (schema_name 'public', table_name 'sales');
    ```
  
  - Citus extension for distributed PostgreSQL (sharding)
    ```sql
    -- With Citus extension
    CREATE EXTENSION citus;
    
    -- Distribute table
    SELECT create_distributed_table('sales', 'customer_id');
    ```

#### Connection Pooling Options

- **PgBouncer**: Lightweight connection pooler
  - Transaction pooling mode for most applications
  - Session pooling for applications that need persistent connections
  - Statement pooling for highest connection efficiency

- **Odyssey**: High-performance connection pooler with advanced features
  - Routing capabilities
  - Connection pooling
  - Transaction management

- **Pgpool-II**: Connection pooling, replication, load balancing
  - More features but higher complexity
  - Built-in query caching
  - Load balancing functionality

### Security Best Practices

#### Network Security

- **Network Layout**:
  - Place databases in private subnets
  - Use VPCs/VPNs for client access
  - Implement jump hosts for administrative access

- **Connection Encryption**:
  ```
  # In postgresql.conf
  ssl = on
  ssl_cert_file = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
  ssl_key_file = '/etc/ssl/private/ssl-cert-snakeoil.key'
  ssl_ca_file = '/path/to/ca.crt'
  ```

- **Host-based Authentication**:
  ```
  # In pg_hba.conf
  # TYPE  DATABASE        USER            ADDRESS                 METHOD
  hostssl production      app_user        10.0.0.0/24             scram-sha-256
  host    production      app_user        10.0.0.0/24             reject
  hostssl replication     replicator      standby-server-ip/32    scram-sha-256
  ```

#### Access Control

- **Role-Based Access Control**:
  ```sql
  -- Create roles for different functions
  CREATE ROLE readonly;
  GRANT CONNECT ON DATABASE production TO readonly;
  GRANT USAGE ON SCHEMA public TO readonly;
  GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;
  ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readonly;
  
  -- Application-specific roles
  CREATE ROLE billing_app WITH LOGIN PASSWORD 'secure_password';
  GRANT CONNECT ON DATABASE production TO billing_app;
  GRANT USAGE ON SCHEMA billing TO billing_app;
  GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA billing TO billing_app;
  ```

- **Row-Level Security**:
  ```sql
  -- Enable RLS on table
  ALTER TABLE customer_data ENABLE ROW LEVEL SECURITY;
  
  -- Create policy
  CREATE POLICY tenant_isolation ON customer_data
      FOR ALL
      USING (tenant_id = current_setting('app.current_tenant_id')::integer);
  ```

- **Column-Level Security**:
  ```sql
  -- Restrict access to sensitive columns
  GRANT SELECT (id, name, email) ON users TO app_role;
  REVOKE SELECT (password_hash, security_question) ON users FROM app_role;
  ```

#### Compliance and Auditing

- **Audit Logging**:
  ```
  # In postgresql.conf
  log_statement = 'ddl'          # Log all DDL
  log_min_duration_statement = 0 # Log all statements and their durations
  
  # For detailed audit logging, use pgaudit extension
  shared_preload_libraries = 'pgaudit'
  pgaudit.log = 'write, ddl'
  pgaudit.log_relation = on
  pgaudit.log_statement_once = off
  pgaudit.log_parameter = on
  ```

- **Data Protection**:
  - Encryption at rest (filesystem or tablespace encryption)
  - Transparent Data Encryption (TDE) with third-party tools
  - Built-in encryption functions
    ```sql
    -- Example of column encryption
    CREATE EXTENSION pgcrypto;
    
    -- Store encrypted data
    UPDATE users 
    SET credit_card = pgp_sym_encrypt('4111-1111-1111-1111', 'encryption_key');
    
    -- Retrieve decrypted data
    SELECT pgp_sym_decrypt(credit_card, 'encryption_key') 
    FROM users;
    ```

### Backup and Recovery

#### Backup Strategies

- **Physical Backups**:
  - pg_basebackup for complete cluster backup
    ```bash
    pg_basebackup -h localhost -D /backup/base/$(date +%Y%m%d) -Ft -z -Xs -P
    ```
  
  - WAL archiving for point-in-time recovery
    ```
    # In postgresql.conf
    archive_mode = on
    archive_command = 'test ! -f /archive/%f && cp %p /archive/%f'
    wal_level = replica
    ```

- **Logical Backups**:
  - pg_dump for database exports
    ```bash
    pg_dump -Fc -v -f /backup/logical/database_$(date +%Y%m%d).dump dbname
    ```
  
  - pg_dumpall for entire cluster dumps
    ```bash
    pg_dumpall -f /backup/logical/cluster_$(date +%Y%m%d).sql
    ```

- **Third-party Backup Solutions**:
  - Barman: Backup and recovery manager
  - pgBackRest: Reliable backup and restore
  - WAL-G: Archival and restoration for PostgreSQL

#### Recovery Testing

- **Regular Recovery Drills**:
  - Quarterly full recovery testing
  - Automated recovery testing in staging environments
  - Documented recovery runbooks with step-by-step procedures

- **Point-in-Time Recovery Testing**:
  ```bash
  # Restore base backup
  pg_basebackup -h localhost -D /var/lib/postgresql/data -Xs -P
  
  # Create recovery.conf (PostgreSQL < 12) or standby.signal (PostgreSQL ≥ 12)
  echo "restore_command = 'cp /archive/%f %p'" > /var/lib/postgresql/data/recovery.conf
  echo "recovery_target_time = '2023-05-01 15:30:00'" >> /var/lib/postgresql/data/recovery.conf
  ```

### Cloud Deployment Considerations

#### Cloud Provider Options

- **Managed PostgreSQL Services**:
  - Amazon RDS/Aurora PostgreSQL
  - Azure Database for PostgreSQL
  - Google Cloud SQL for PostgreSQL

- **Advantages vs. Self-Managed**:
  - Automated backups and point-in-time recovery
  - Simplified high availability configuration
  - Automated patching and version upgrades
  - Built-in monitoring and alerting
  - Scaling with minimal downtime

- **Limitations to Consider**:
  - Restricted access to postgresql.conf parameters
  - Limited extension support
  - Vendor lock-in concerns
  - Cost at scale versus self-managed

#### Container Deployment

- **PostgreSQL in Kubernetes**:
  - StatefulSets for stable identity
  - Persistent volumes for data durability
  - Operators for managing PostgreSQL clusters
    - Zalando Postgres Operator
    - Crunchy Data PostgreSQL Operator
    - CloudNativePG
    - Example operator configuration:
      ```yaml
      apiVersion: "acid.zalan.do/v1"
      kind: postgresql
      metadata:
        name: postgres-cluster
      spec:
        teamId: "data"
        postgresql:
          version: "15"
        numberOfInstances: 3
        volume:
          size: 100Gi
        users:
          app_user: []
        databases:
          app_db: app_user
        resources:
          requests:
            cpu: 100m
            memory: 4Gi
          limits:
            cpu: 500m
            memory: 4Gi
      ```

- **Docker Deployment Considerations**:
  - Volume management for data persistence
  - Configuration customization
  - Backup and recovery procedures
  - Resource constraints and performance

### Upgrade Planning

#### Version Upgrade Methods

- **Major Version Upgrades**:
  - pg_upgrade for in-place upgrades
    ```bash
    pg_upgrade --old-datadir=/var/lib/postgresql/13/data \
               --new-datadir=/var/lib/postgresql/14/data \
               --old-bindir=/usr/lib/postgresql/13/bin \
               --new-bindir=/usr/lib/postgresql/14/bin
    ```
  
  - Logical replication for zero/minimal-downtime upgrades
    ```sql
    -- On old server (provider)
    CREATE PUBLICATION upgrade_pub FOR ALL TABLES;
    
    -- On new server (subscriber)
    CREATE SUBSCRIPTION upgrade_sub 
    CONNECTION 'host=old-server dbname=olddb user=repl password=secret' 
    PUBLICATION upgrade_pub;
    ```

- **Downtime Minimization**:
  - Read-replica upgrade first, then failover
  - Use logical replication to minimize lock requirements
  - Consider AWS RDS "blue/green deployments" for managed instances

#### Testing Upgrade Process

- **Validation Steps**:
  - Full testing in staging environment
  - Performance comparison before/after
  - Application compatibility testing
  - Replication verification

- **Common Issues to Watch For**:
  - Query plan changes
  - Extension compatibility
  - Function/procedure syntax changes
  - Index rebuild requirements

### Advanced Topics

#### Multi-Master Approaches

- **BDR (Bi-Directional Replication)**:
  - Commercial multi-master solution
  - Allows writes to any node
  - Conflict resolution mechanisms

- **Citus for Distributed PostgreSQL**:
  - Sharding approach with coordinator and worker nodes
  - Horizontally scales both storage and compute
  - Maintains full SQL compatibility for single-tenant queries
  - Example setup:
    ```sql
    -- Create distributed table
    SELECT create_distributed_table('large_table', 'distribution_column');
    
    -- Add nodes to the cluster
    SELECT master_add_node('worker-node-1', 5432);
    SELECT master_add_node('worker-node-2', 5432);
    ```

#### TimescaleDB for Time-Series

- **Hypertable Architecture**:
  - Automatic time-based partitioning
  - Query optimization for time-series data
  - Compression for older data
    ```sql
    -- Create hypertable
    CREATE TABLE sensor_data (
        time TIMESTAMPTZ NOT NULL,
        sensor_id INTEGER,
        temperature DOUBLE PRECISION
    );
    
    SELECT create_hypertable('sensor_data', 'time', 
                             chunk_time_interval => INTERVAL '1 day');
    
    -- Enable compression
    ALTER TABLE sensor_data SET (
        timescaledb.compress,
        timescaledb.compress_segmentby = 'sensor_id'
    );
    
    -- Add compression policy
    SELECT add_compression_policy('sensor_data', INTERVAL '7 days');
    ```

#### Foreign Data Wrappers for Polyglot Persistence

- **Communication with External Data Sources**:
  - postgres_fdw for PostgreSQL federation
  - mysql_fdw for MySQL/MariaDB integration
  - mongodb_fdw for MongoDB access
  - file_fdw for flat file integration
  - Example setup for multi-database queries:
    ```sql
    -- Create extension
    CREATE EXTENSION postgres_fdw;
    
    -- Create server
    CREATE SERVER foreign_server
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host 'remote-db', port '5432', dbname 'remote_data');
    
    -- Create user mapping
    CREATE USER MAPPING FOR local_user
    SERVER foreign_server
    OPTIONS (user 'remote_user', password 'secret');
    
    -- Create foreign table
    CREATE FOREIGN TABLE remote_sales (
        id integer,
        product_id integer,
        sale_date date,
        amount numeric
    )
    SERVER foreign_server
    OPTIONS (schema_name 'public', table_name 'sales');
    
    -- Query joining local and remote data
    SELECT l.customer_name, r.amount
    FROM local_customers l
    JOIN remote_sales r ON l.id = r.customer_id;
    ```

**Key Points**:
- PostgreSQL scaling requires careful hardware planning, configuration tuning, and ongoing monitoring
- High availability is achieved through replication with automated failover solutions
- Performance optimization involves proper indexing, query tuning, and regular maintenance
- Security best practices include network isolation, encryption, and role-based access control
- Consider cloud-managed options for simplified administration but be aware of their limitations
- Horizontal scaling strategies can overcome single-instance limitations for large deployments
- Regular testing of backup and recovery procedures is essential for business continuity

---

