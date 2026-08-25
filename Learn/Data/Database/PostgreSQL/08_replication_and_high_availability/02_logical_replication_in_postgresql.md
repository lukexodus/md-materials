## Logical Replication in PostgreSQL


### What is Logical Replication?

Logical replication is a method of replicating data objects and their changes between PostgreSQL databases based on their replication identity (usually a primary key). Unlike physical replication which copies the entire data file byte-by-byte, logical replication works at the SQL level, replicating individual database objects and operations. This allows for more flexible replication scenarios including selective table replication, cross-version compatibility, and multi-master configurations.

**Key Points**:

- Officially introduced in PostgreSQL 10 (2017)
- Operates at the logical (SQL/row) level rather than physical storage level
- Allows replication of specific tables or databases
- Supports replication between different PostgreSQL versions
- Enables more flexible replication topologies

### How Logical Replication Works

Logical replication uses a publish and subscribe model with the following components:

1. **Publishers**: Database instances that define publication objects containing tables to be replicated
2. **Publications**: Named sets of tables whose changes are to be replicated. It can include filters (e.g., WHERE clauses in PostgreSQL 15+).
3. **Subscribers**: Database instances that define subscription objects which receive data
4. **Subscriptions**: A subscription is a configuration on the subscriber that links to a publication and specifies how to apply changes, including connection details and conflict handling.

The process works as follows:

1. Changes on the publisher are captured through a logical decoding plugin
2. These changes are decoded into a logical format (from WAL)
3. Changes are streamed to subscribers
4. Subscribers apply the changes to matching tables

### Prerequisites and Requirements

#### Publisher Requirements

- `wal_level` must be set to `logical`
- Tables must have a primary key or a unique constraint with non-null columns
- Tables must have the same column structure on both publisher and subscriber
- Table owners must exist on the subscriber

#### System Impact Considerations

- Uses more CPU resources than physical replication
- Generates more WAL data due to additional information needed
- May require more careful monitoring and tuning

### Setting Up Logical Replication

#### Publisher Configuration

In `postgresql.conf`:

```
wal_level = logical
max_replication_slots = 10
max_wal_senders = 10
```

Create a publication:

```sql
-- Create a publication for all tables
CREATE PUBLICATION pub_all FOR ALL TABLES;

-- Or create a publication for specific tables
CREATE PUBLICATION pub_sales FOR TABLE orders, customers, products;
```

#### Subscriber Configuration

Create a subscription:

```sql
-- Create a subscription connecting to the publisher
CREATE SUBSCRIPTION sub_sales 
  CONNECTION 'host=publisher dbname=sales user=replicator password=secret'
  PUBLICATION pub_sales;
```

### Initial Data Synchronization

When a subscription is created, PostgreSQL handles initial data synchronization by:

1. Taking a consistent snapshot of the data on the publisher
2. Copying the snapshot data to the subscriber
3. Building a replication slot on the publisher
4. Starting the replication process for ongoing changes

**Example**:

```sql
-- To monitor initial synchronization progress
SELECT subname, srsubstate, srsubpublications 
FROM pg_subscription_rel;
```

### Conflict Resolution

Logical replication has limited built-in conflict resolution. If conflicts occur (e.g., duplicate key violations):

1. Replication will stop
2. Error will be reported
3. Administrator must manually resolve the conflict
4. Replication can be restarted using `ALTER SUBSCRIPTION ... REFRESH PUBLICATION`

### Advanced Features and Options

#### Column Filtering

You can select specific columns to replicate:

```sql
CREATE PUBLICATION pub_customers FOR TABLE customers (id, name, email);
```

#### Row Filtering

You can filter which rows to replicate using WHERE conditions (PostgreSQL 15+):

```sql
CREATE PUBLICATION pub_active_users FOR TABLE users 
  WHERE status = 'active';
```

#### Bi-directional Replication

While PostgreSQL doesn't natively support true multi-master replication, you can set up bi-directional replication by:

1. Creating publications on both servers
2. Creating subscriptions on both servers
3. Implementing conflict avoidance strategies

This requires careful design to prevent replication loops:

```sql
-- On server A
CREATE PUBLICATION pub_a FOR TABLE shared_table;

-- On server B
CREATE PUBLICATION pub_b FOR TABLE shared_table;

-- On server A
CREATE SUBSCRIPTION sub_b CONNECTION '...' PUBLICATION pub_b;

-- On server B
CREATE SUBSCRIPTION sub_a CONNECTION '...' PUBLICATION pub_a;
```

#### Large Object Replication

Large objects (BLOBs) are not automatically replicated. Handle them through:

- Application logic
- Using external storage for BLOBs
- Converting to bytea type (which is replicated)

### Monitoring Logical Replication

#### Key Monitoring Views

```sql
-- Check the status of publications
SELECT * FROM pg_publication;

-- Check the status of subscriptions
SELECT * FROM pg_subscription;

-- Monitor subscription table status
SELECT * FROM pg_subscription_rel;

-- Check replication slot status
SELECT * FROM pg_replication_slots;

-- Monitor replication activity
SELECT * FROM pg_stat_replication;
```

#### Key Metrics to Monitor

1. Replication lag
2. Subscription state
3. Replication slot size
4. Failed transactions

**Example**:

```sql
-- Check replication lag
SELECT slot_name, 
       pg_current_wal_lsn() - confirmed_flush_lsn AS lag_bytes
FROM pg_replication_slots
WHERE slot_type = 'logical';
```

### Common Scenarios and Use Cases

#### Schema Changes and DDL

DDL operations are not automatically replicated. Options for handling schema changes:

1. Apply schema changes manually on both publisher and subscriber
2. Use tools like pg_dump to refresh schema
3. Use extensions like pglogical which can handle some DDL

#### Version Upgrades with Minimal Downtime

1. Set up logical replication from old to new version
2. Allow replication to catch up
3. Switch application to new version
4. Decommission old version

#### Subset Replication for Data Distribution

```sql
-- On central server
CREATE PUBLICATION pub_regional_sales 
  FOR TABLE sales 
  WHERE region = 'europe';

-- On regional server
CREATE SUBSCRIPTION sub_europe_sales
  CONNECTION '...'
  PUBLICATION pub_regional_sales;
```

### Common Issues and Troubleshooting

#### Replication Not Starting

Possible causes:

- Tables missing primary keys or replication identities
- Network connectivity issues
- Authentication problems

Resolution:

```sql
-- Check for tables without primary keys
SELECT relname 
FROM pg_class c 
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE relkind = 'r' 
  AND n.nspname NOT IN ('pg_catalog', 'information_schema')
  AND NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conrelid = c.oid AND contype = 'p'
  );

-- Add a primary key if missing
ALTER TABLE problematic_table ADD PRIMARY KEY (id);
```

#### High CPU Usage

Logical decoding and applying changes can be CPU-intensive. Solutions:

- Limit the number of tables being replicated
- Optimize indexes on subscriber
- Consider upgrading hardware

#### Subscription Falls Behind

Causes and solutions:

- High transaction volume: Increase subscriber resources
- Network issues: Improve network reliability
- Long-running transactions: Avoid these on publisher
- Track using:

```sql
SELECT now() - pg_last_committed_xact() AS xact_age;
```

### Best Practices

1. **Always use primary keys** on replicated tables
2. **Create separate users** specifically for replication
3. **Monitor replication lag** constantly
4. **Plan for schema changes** across publisher and subscriber
5. **Document replication topology** to avoid circular replication
6. **Regularly check replication slots** to prevent WAL buildup
7. **Consider table partitioning** for large tables
8. **Test failover procedures** regularly

### Limitations

1. **Schema changes** aren't automatically replicated
2. **Sequence values** aren't synchronized
3. **Large objects** (LOBs) aren't replicated
4. **DDL commands** aren't replicated
5. **System tables** can't be replicated
6. **Temporary tables** can't be published
7. **No built-in conflict resolution** for bi-directional setups

### Comparison with Other Replication Methods

#### Streaming Replication

- Replicates entire cluster vs. selected objects
- Lower overhead but less flexibility
- Doesn't allow cross-version replication

#### Third-party Tools

- pglogical: Enhanced logical replication with more features
- BDR: True bi-directional replication
- Bucardo: Trigger-based replication solution

### Extensions and Enhancements

#### pglogical Extension

The pglogical extension predates built-in logical replication and offers additional features:

- DDL replication
- Conflict resolution options
- More flexible replication topologies

Installation:

```sql
CREATE EXTENSION pglogical;
```

#### pg_partman for Partitioned Tables

When replicating partitioned tables:

```sql
CREATE EXTENSION pg_partman;
-- Set up partitioning before creating publications
```

### Related Topics

- Physical (Streaming) Replication in PostgreSQL
- PostgreSQL Write-Ahead Log (WAL)
- Data partitioning strategies
- High Availability architectures
- Change Data Capture (CDC) patterns

---

