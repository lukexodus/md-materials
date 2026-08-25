## Streaming Replication in PostgreSQL


### What is Streaming Replication?

Streaming replication is PostgreSQL's built-in physical replication mechanism that allows a standby server to stay up-to-date with a primary server by continuously receiving and applying transaction log (WAL) records as they're generated on the primary. This creates a near real-time replica of the database that can be used for high availability, disaster recovery, and read scaling.

**Key Points**:

- Introduced in PostgreSQL 9.0 (2010)
- Operates at the physical storage level
- Provides a full, exact copy of the database
- Supports both synchronous and asynchronous modes
- Typically achieves low replication lag (milliseconds to seconds)

### How Streaming Replication Works

Streaming replication operates on PostgreSQL's Write-Ahead Log (WAL) mechanism. When transactions are committed on the primary server, the corresponding WAL records are sent to standby servers over a TCP/IP connection. The standby servers apply these WAL records to maintain an identical copy of the database.

The process follows these steps:

1. Primary server writes transaction changes to WAL
2. WAL sender process on primary streams WAL records to standby
3. WAL receiver process on standby receives the WAL records
4. Standby server applies the WAL records to its data files

### Configuration Requirements

#### Primary Server Configuration

In the `postgresql.conf` file:

```
# Required settings
wal_level = replica                 # Minimum WAL information for replication
max_wal_senders = 10                # Maximum number of concurrent connections
wal_keep_size = 1024                # Size of WAL segments to retain (in MB)

# Optional but recommended
archive_mode = on                   # Enable WAL archiving
archive_command = 'cp %p /path/to/archive/%f'  # Command to archive WAL segments
```

In the `pg_hba.conf` file:

```
# Allow replication connections
host    replication     replicator      192.168.1.0/24        md5
```

#### Standby Server Configuration

Create a `recovery.conf` file (PostgreSQL 11 and earlier) or use `postgresql.conf` (PostgreSQL 12+):

For PostgreSQL 12 and later:

```
# In postgresql.conf
primary_conninfo = 'host=primary_host port=5432 user=replicator password=secret'
promote_trigger_file = '/tmp/promote_to_primary'
```

Create a `standby.signal` file in the data directory to indicate standby mode.

For PostgreSQL 11 and earlier:

```
# In recovery.conf
standby_mode = 'on'
primary_conninfo = 'host=primary_host port=5432 user=replicator password=secret'
trigger_file = '/tmp/promote_to_primary'
```

### Setting Up Streaming Replication

1. Create a base backup of the primary server:

```
pg_basebackup -h primary_host -D /path/to/standby/data -U replicator -P -v -X stream -R
```

2. Start the standby server:

```
pg_ctl -D /path/to/standby/data start
```

### Synchronous vs. Asynchronous Replication

#### Asynchronous Replication

In asynchronous mode, the primary server doesn't wait for the standby to confirm receipt of WAL data before acknowledging transactions to clients. This offers better performance but could lead to data loss if the primary fails before WAL records reach the standby.

#### Synchronous Replication

In synchronous mode, the primary waits for the standby to confirm receipt and/or application of WAL records before acknowledging the transaction to the client. This ensures greater data safety but can impact performance.

Configuration in `postgresql.conf`:

```
# For synchronous replication
synchronous_standby_names = 'standby1'
```

### Monitoring Replication

PostgreSQL provides several views to monitor replication:

```sql
-- Check replication connections
SELECT * FROM pg_stat_replication;

-- Check replication lag
SELECT now() - pg_last_xact_replay_timestamp() AS replication_lag;

-- On primary, check if synchronous replication is working
SELECT sync_state FROM pg_stat_replication;
```

### Failover and Switchover

#### Manual Failover

To promote a standby to primary:

```
# PostgreSQL 12+
pg_ctl promote -D /path/to/standby/data

# PostgreSQL 11 and earlier
touch /tmp/promote_to_primary  # Using the trigger_file path
```

#### Automated Failover

PostgreSQL doesn't provide built-in automated failover. Third-party tools are typically used:

- Patroni
- repmgr
- PAF (PostgreSQL Automatic Failover)
- pgpool-II

### Cascading Replication

PostgreSQL supports cascading replication, where a standby can itself act as a primary for other standbys. This reduces load on the original primary and is useful for geographically distributed setups.

```
primary → standby1 → standby2
```

### Limitations and Considerations

1. All databases in the cluster are replicated; selective replication is not possible
2. Standby servers are read-only during normal operation
3. DDL changes and administrative commands replicate normally
4. Replication slots can prevent primary from removing WAL files needed by standby

### Best Practices

1. Configure enough `wal_senders` for all your standbys plus some buffer
2. Use replication slots to prevent WAL file removal
3. Set up WAL archiving as a fallback mechanism
4. Monitor replication lag regularly
5. Test failover procedures periodically
6. Consider using synchronous replication for critical data
7. Configure appropriate `max_standby_streaming_delay` to manage conflicts

### Replication Slots

Replication slots provide a mechanism to ensure WAL segments aren't removed until all standbys have received them, preventing replication failures due to WAL recycling.

```sql
-- On primary, create a replication slot
SELECT pg_create_physical_replication_slot('standby1_slot');

-- On standby, use the slot (in postgresql.conf)
primary_conninfo = 'host=primary port=5432 user=replicator password=secret application_name=standby1'
primary_slot_name = 'standby1_slot'
```

### Advanced Features

#### Hot Standby

The standby server can accept read-only queries while replication is active, allowing read workloads to be offloaded from the primary.

```
# In postgresql.conf on standby
hot_standby = on  # Default is 'on' in recent PostgreSQL versions
```

#### Delayed Standby

A standby can be configured to apply WAL records with a delay, providing protection against data corruption or operator errors.

```
# In postgresql.conf on standby (PostgreSQL 12+)
recovery_min_apply_delay = '4h'  # Delay by 4 hours
```

### Troubleshooting Common Issues

1. **Replication Not Starting**
    
    - Check network connectivity
    - Verify `pg_hba.conf` permissions
    - Check replication user credentials
2. **High Replication Lag**
    
    - Insufficient I/O capacity on standby
    - Network bandwidth limitations
    - High write load on primary
3. **Standby Cannot Connect After Primary Restart**
    
    - Ensure `max_wal_senders` is sufficient
    - Check if primary IP or hostname resolution works

### Comparison with Other Replication Methods

#### Logical Replication

- Allows selective replication (tables/databases)
- Supports cross-version replication
- Higher overhead compared to streaming replication
- Added in PostgreSQL 10

#### Third-party Solutions

- BDR (Bi-Directional Replication)
- Slony
- Bucardo
- pglogical

### Related Topics

- Write-Ahead Logging (WAL) in PostgreSQL
- Point-in-Time Recovery (PITR)
- Logical Replication
- High Availability architectures for PostgreSQL
- PostgreSQL Backup strategies

---

