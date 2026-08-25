## Popular PostgreSQL Extensions: pg_partman (Table Partitioning)


### Introduction to pg_partman

pg_partman ("Partition Manager") is a powerful PostgreSQL extension designed to simplify and automate the creation and management of time-series or serial-based table partitions. Created by Keith Fiske and maintained by Crunchy Data, pg_partman extends PostgreSQL's native partitioning capabilities with robust automation features and management tools.

### Native PostgreSQL Partitioning vs. pg_partman

PostgreSQL introduced declarative partitioning in version 10, but managing partitions manually still requires considerable effort. pg_partman addresses this gap by providing:

- Automated partition creation and maintenance
- Configurable retention policies for old partitions
- Background workers for continuous partition management
- Simplified partition creation interfaces
- Migration tools from older inheritance-based partitioning

### Key Features of pg_partman

#### Partition Types Supported

- **Time-based partitioning**: Intervals including yearly, quarterly, monthly, weekly, daily, hourly, and down to minutes
- **Serial-based partitioning**: Integer-based partitions for ID or sequential values
- **Sub-partitioning**: Creating partitions within partitions for complex hierarchies

#### Automation Capabilities

- **Partition creation**: Automatically creates future partitions based on configured intervals
- **Partition maintenance**: Manages old partitions through various retention policies
- **Background processing**: Uses PostgreSQL background worker for continuous management

#### Management Functions

- **create_parent()**: Initializes a partition set
- **run_maintenance()**: Manages partition sets including creating new partitions and applying retention policies
- **apply_constraints()**: Applies constraints to child tables to improve query performance
- **undo_partition()**: Reverses the partitioning process

### Installation Process

Installation of pg_partman requires:

```sql
-- Install the extension
CREATE EXTENSION pg_partman;

-- Optional but recommended - configure the schema
CREATE SCHEMA partman;
ALTER EXTENSION pg_partman SET SCHEMA partman;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA partman TO role_name;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA partman TO role_name;
```

### Configuration Examples

#### Time-Based Partitioning

```sql
-- Create a table with PostgreSQL native partitioning
CREATE TABLE measurements (
    measurement_id bigint NOT NULL,
    measurement_time TIMESTAMP NOT NULL,
    value numeric,
    sensor_id int
) PARTITION BY RANGE (measurement_time);

-- Use pg_partman to manage the partitions
SELECT partman.create_parent(
    p_parent_table := 'public.measurements',
    p_control := 'measurement_time',
    p_type := 'native',
    p_interval := 'daily',
    p_premake := 30
);
```

#### ID-Based Partitioning

```sql
-- Create a table partitioned by ID ranges
CREATE TABLE orders (
    order_id bigint NOT NULL,
    customer_id int,
    order_date timestamp,
    total_amount numeric
) PARTITION BY RANGE (order_id);

-- Configure pg_partman for ID-based partitioning
SELECT partman.create_parent(
    p_parent_table := 'public.orders',
    p_control := 'order_id',
    p_type := 'native',
    p_interval := '10000',
    p_premake := 5
);
```

### Setting Up Partition Maintenance

#### Manual Maintenance

```sql
-- Run maintenance manually when needed
SELECT partman.run_maintenance(
    p_parent_table := 'public.measurements',
    p_analyze := true,
    p_jobmon := true
);
```

#### Background Worker Setup

For automatic maintenance, configure the background worker in postgresql.conf:

```
# Add to postgresql.conf
shared_preload_libraries = 'pg_partman_bgw'
pg_partman_bgw.interval = 3600
pg_partman_bgw.role = 'postgres'
pg_partman_bgw.dbname = 'database_name'
```

Then configure partitions to use the background worker:

```sql
-- Update the part_config table
UPDATE partman.part_config
SET automatic_maintenance = 'on'
WHERE parent_table = 'public.measurements';
```

### Partition Retention Strategies

pg_partman provides several methods for handling old partitions:

#### Retention Options

- **retention**: Number of partitions to keep before applying the retention policy
- **retention_keep_table**: Whether to drop or retain the actual table
- **retention_keep_index**: Whether to drop or retain indexes
- **retention_schema**: Schema to move old partitions to (if not dropping)

```sql
-- Example: Configure retention to keep 3 months of daily partitions
SELECT partman.create_parent(
    p_parent_table := 'public.measurements',
    p_control := 'measurement_time',
    p_type := 'native',
    p_interval := 'daily',
    p_premake := 30,
    p_retention := '90',
    p_retention_keep_table := true,
    p_retention_schema := 'archive'
);
```

### Performance Optimization Techniques

#### Constraint Exclusion

pg_partman can apply constraints to improve partition exclusion:

```sql
-- Apply constraints to existing partitions
SELECT partman.apply_constraints(
    p_parent_table := 'public.measurements',
    p_analyze := true
);
```

#### Index Management

Creating the right indexes on partitioned tables:

```sql
-- Create an index on all partitions
CREATE INDEX ON measurements(sensor_id);

-- For time-series data, include the partition key in multi-column indexes
CREATE INDEX ON measurements(sensor_id, measurement_time);
```

**Key Points:**

- Indexes are inherited by new partitions automatically
- Include the partition key in multi-column indexes for better performance
- Consider different indexing strategies for hot vs. cold partitions

### Common Usage Patterns

#### Time-Series Data

Ideal for IoT data, logs, or any time-stamped information:

```sql
-- Example: Creating a logging table with hourly partitions
CREATE TABLE system_logs (
    log_id bigserial,
    log_time timestamp NOT NULL,
    level text,
    message text,
    source text
) PARTITION BY RANGE (log_time);

SELECT partman.create_parent(
    p_parent_table := 'public.system_logs',
    p_control := 'log_time',
    p_type := 'native',
    p_interval := 'hourly',
    p_premake := 24
);
```

#### High-Volume Transaction Systems

For order processing or event systems with ID-based sequencing:

```sql
-- Example: Order processing system
CREATE TABLE transactions (
    transaction_id bigint NOT NULL,
    transaction_time timestamp,
    amount numeric,
    customer_id int
) PARTITION BY RANGE (transaction_id);

SELECT partman.create_parent(
    p_parent_table := 'public.transactions',
    p_control := 'transaction_id',
    p_type := 'native',
    p_interval := '1000000',
    p_premake := 2
);
```

### Monitoring and Maintenance

#### Important Views and Tables

- **partman.part_config**: Contains configuration for all partition sets
- **partman.part_config_sub**: Contains sub-partition configuration
- **partman.show_partitions()**: Shows all partitions in a set

```sql
-- Check configuration
SELECT * FROM partman.part_config WHERE parent_table = 'public.measurements';

-- View all partitions
SELECT * FROM partman.show_partitions('public.measurements');

-- Check for partition maintenance issues
SELECT * FROM partman.check_parent('public.measurements');
```

#### Handling Problems

- **Undo partitioning**: `SELECT partman.undo_partition('public.measurements', p_target_table := 'public.measurements_restore');`
- **Reapply partitioning**: For fixing incorrect configurations
- **Manual partition creation**: `SELECT partman.create_partition_time('public.measurements');`

### Advanced Features

#### Sub-partitioning

Creating multi-level partition hierarchies:

```sql
-- Example: Create a table partitioned first by year, then by month
SELECT partman.create_parent(
    p_parent_table := 'public.sales',
    p_control := 'sale_date',
    p_type := 'native',
    p_interval := 'yearly',
    p_premake := 2,
    p_default_partition := 'sales_default',
    p_subpartition_type := 'native',
    p_subpartition_control := 'sale_date',
    p_subpartition_interval := 'monthly',
    p_subpartition_premake := 12
);
```

#### Custom Partition Naming

Custom naming patterns for partitions:

```sql
-- Custom naming template
SELECT partman.create_parent(
    p_parent_table := 'public.metrics',
    p_control := 'created_at',
    p_type := 'native',
    p_interval := 'daily',
    p_pattern := 'metrics_y%Ym%md%d'
);
```

#### Partition Template Tables

Using template tables to define column properties:

```sql
-- Create a template table
CREATE TABLE measurement_template (LIKE measurements);
ALTER TABLE measurement_template ADD CONSTRAINT positive_value CHECK (value > 0);

-- Use the template
SELECT partman.create_parent(
    p_parent_table := 'public.measurements',
    p_control := 'measurement_time',
    p_type := 'native',
    p_interval := 'daily',
    p_template_table := 'public.measurement_template'
);
```

### Migration Strategies

#### From Inheritance to Native Partitioning

```sql
-- Create new natively partitioned table
CREATE TABLE measurements_native (LIKE measurements INCLUDING ALL) 
PARTITION BY RANGE (measurement_time);

-- Set up pg_partman
SELECT partman.create_parent(
    p_parent_table := 'public.measurements_native',
    p_control := 'measurement_time',
    p_type := 'native',
    p_interval := 'daily'
);

-- Migrate data
INSERT INTO measurements_native SELECT * FROM measurements;
```

#### Upgrading pg_partman

```sql
-- Update the extension
ALTER EXTENSION pg_partman UPDATE;

-- If needed, run maintenance after update
SELECT partman.run_maintenance();
```

### Integration with Other PostgreSQL Features

#### Foreign Tables

Using pg_partman with foreign data wrappers:

```sql
-- Create a foreign table template
CREATE FOREIGN TABLE measurement_foreign_template (LIKE measurements)
SERVER foreign_server
OPTIONS (schema_name 'remote_schema', table_name 'measurements');

-- Use in partitioning (with care and limitations)
ALTER TABLE measurements ATTACH PARTITION measurement_foreign_template 
FOR VALUES FROM ('2020-01-01') TO ('2020-02-01');
```

#### Event Triggers

Automating actions when partitions are created:

```sql
-- Create a function to be triggered
CREATE OR REPLACE FUNCTION handle_new_partition()
RETURNS event_trigger AS $$
BEGIN
    -- Custom logic when partitions are created
END;
$$ LANGUAGE plpgsql;

-- Create the event trigger
CREATE EVENT TRIGGER partition_created ON ddl_command_end
WHEN TAG IN ('CREATE TABLE')
EXECUTE PROCEDURE handle_new_partition();
```

### Common Challenges and Solutions

#### Handling Default Partitions

```sql
-- Create parent with default partition
SELECT partman.create_parent(
    p_parent_table := 'public.measurements',
    p_control := 'measurement_time',
    p_type := 'native',
    p_interval := 'daily',
    p_default_partition := 'measurements_default'
);

-- Periodically check for data in default partition
SELECT count(*) FROM measurements_default;

-- Repartition data from default partition
-- (Requires custom SQL based on the data found)
```

#### Dealing with Very Old Data

```sql
-- Archive old partitions to compressed tables
CREATE TABLE archive.measurements_2020 (LIKE public.measurements);
ALTER TABLE archive.measurements_2020 SET (
    autovacuum_enabled = false,
    toast.autovacuum_enabled = false
);

-- Move data and compress
INSERT INTO archive.measurements_2020 
SELECT * FROM public.measurements_p2020;
ALTER TABLE archive.measurements_2020 SET (parallel_workers = 4);
CLUSTER archive.measurements_2020 USING measurements_2020_time_idx;
ALTER TABLE archive.measurements_2020 SET (parallel_workers = 0);

-- Drop old partition
DROP TABLE public.measurements_p2020;
```

### Performance Benchmarks and Considerations

#### Insertion Performance

- **Bulk loading**: 2-3x faster than non-partitioned tables for large datasets
- **Single row inserts**: Minimal overhead with properly configured partitions
- **Batch processing**: Most efficient with batch sizes aligned to partition boundaries

#### Query Performance

- **Partition pruning**: Up to 100x faster for queries that can exclude partitions
- **Multi-partition queries**: May be slower than non-partitioned tables if many partitions are scanned
- **Index usage**: Partition-level indexes improve targeted queries dramatically

**Key Points:**

- Consider partition size carefully (too many small partitions can degrade performance)
- Monitor catalog bloat with many partitions
- Use appropriate statistics targets for partitioned tables

### pg_partman Administration Best Practices

- Regularly monitor the partman.part_config table for configuration issues
- Set up appropriate alerts for partition creation failures
- Ensure background worker has sufficient permissions
- Test retention policies thoroughly before implementing in production
- Keep pg_partman updated to benefit from performance improvements and bug fixes

### Conclusion

pg_partman transforms PostgreSQL's native partitioning into a production-ready solution for high-volume, time-series, or sequence-based data. By automating partition creation and maintenance, it eliminates the operational burden of manual partition management while providing the performance benefits of properly partitioned tables. For organizations dealing with large volumes of temporal data or rapid growth in sequential IDs, pg_partman offers a mature, battle-tested solution that balances automation with fine-grained control.

When implementing pg_partman, focus on proper sizing of partitions, thoughtful retention policies, and regular monitoring to ensure optimal performance as your data grows. The extension's flexibility allows it to adapt to various partitioning needs while maintaining PostgreSQL's reliability and feature set.

---

