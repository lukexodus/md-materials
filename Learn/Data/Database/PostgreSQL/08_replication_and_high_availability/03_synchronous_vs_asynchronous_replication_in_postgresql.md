## Synchronous vs. Asynchronous Replication in PostgreSQL


### Core Differences

Synchronous and asynchronous replication represent two fundamental approaches to data replication in PostgreSQL, differing primarily in when the primary server considers a transaction complete.

**Key Points**:
- Asynchronous replication: Transaction commits without waiting for standby confirmation
- Synchronous replication: Transaction waits for standby acknowledgment before completing
- This fundamental difference creates a tradeoff between performance and data safety
- Both modes utilize the same underlying WAL-based replication mechanism
- The choice impacts disaster recovery, high availability, and performance profiles

### Asynchronous Replication

Asynchronous replication is PostgreSQL's default replication mode, where the primary server commits transactions without waiting for standby servers to confirm receipt or application of the WAL records.

#### How It Works

1. Primary server writes transaction changes to WAL
2. Primary acknowledges transaction completion to client immediately
3. WAL records are sent to standby server(s) independently
4. Standby applies changes at its own pace

#### Configuration

Asynchronous replication requires no special configuration beyond basic streaming replication setup:

```
# On primary postgresql.conf
wal_level = replica
max_wal_senders = 10
```

No `synchronous_standby_names` parameter is specified, making this the default behavior.

#### Advantages

- **Higher Performance**: No waiting for network round-trips or standby processing
- **Primary Availability**: Primary continues operating even if standbys fail or disconnect
- **Reduced Transaction Latency**: Client applications experience faster transaction completions
- **Simpler Setup**: Fewer parameters to configure

#### Disadvantages

- **Potential Data Loss**: Recent transactions may be lost if the primary fails before WAL records reach standbys
- **Inconsistent Replication Lag**: No guaranteed upper bound on how far behind standbys might be
- **Less Predictable Recovery**: Point-in-time recovery might miss the most recent transactions

#### Measuring Replication Lag

```sql
-- Check lag in bytes
SELECT client_addr, 
       pg_wal_lsn_diff(pg_current_wal_lsn(), sent_lsn) AS send_lag_bytes,
       pg_wal_lsn_diff(pg_current_wal_lsn(), write_lsn) AS write_lag_bytes,
       pg_wal_lsn_diff(pg_current_wal_lsn(), flush_lsn) AS flush_lag_bytes,
       pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn) AS replay_lag_bytes
FROM pg_stat_replication;

-- Check lag in time
SELECT now() - pg_last_xact_replay_timestamp() AS replication_lag_time;
```

### Synchronous Replication

Synchronous replication guarantees that transaction data has been received and optionally written/flushed to disk by at least one standby server before the transaction is considered complete.

#### How It Works

1. Primary server writes transaction changes to WAL
2. Primary sends WAL records to standby server(s)
3. Primary waits for acknowledgment from standby(s) according to configured synchronous mode
4. Only after receiving required acknowledgment, primary confirms transaction completion to client

#### Configuration

Synchronous replication requires specifying which standby servers are synchronous:

```
# On primary postgresql.conf
synchronous_standby_names = 'FIRST 1 (standby1, standby2, standby3)'
```

The above configuration means "wait for the first 1 standby from the listed standbys to confirm receipt."

#### Synchronous Modes

PostgreSQL offers different levels of synchronous guarantees:

1. **Remote Write** (`synchronous_commit = remote_write`): Wait until standbys have received and written WAL to their OS cache
2. **Remote Flush** (`synchronous_commit = on` or `remote_apply`): Wait until standbys have flushed WAL to durable storage
3. **Remote Apply** (`synchronous_commit = remote_apply`): Wait until standbys have applied changes to their database

```
# On primary postgresql.conf
synchronous_commit = remote_apply  # Strongest guarantee
```

#### Advantages

- **Data Safety**: Minimizes or eliminates data loss in case of primary failure
- **Consistency Guarantees**: Ensures standby servers have consistent data up to a known point
- **Predictable Recovery**: More reliable failover with guaranteed transaction durability
- **Compliance Support**: Helps meet regulatory requirements for data integrity

#### Disadvantages

- **Performance Impact**: Higher transaction latency due to waiting for standby confirmation
- **Availability Concerns**: Primary operations might stall if synchronous standbys become unavailable
- **Network Sensitivity**: Performance depends on network latency between servers
- **Complex Monitoring**: Requires monitoring synchronization status

#### Example Monitoring Queries

```sql
-- Check synchronization state
SELECT application_name, sync_state, sync_priority 
FROM pg_stat_replication;

-- Check if primary is waiting for synchronous replication
SELECT pid, query, wait_event_type, wait_event 
FROM pg_stat_activity 
WHERE wait_event = 'SyncRep';
```

### Hybrid Approaches

PostgreSQL allows for flexible configurations that blend aspects of both synchronous and asynchronous replication.

#### Priority-Based Synchronous Replication

```
# On primary postgresql.conf
synchronous_standby_names = 'standby1, standby2'
```

This configuration means both standbys are synchronous, but if one becomes unavailable, the primary will continue operating with just one.

#### Limited Synchronous Replication

```
# On primary postgresql.conf
synchronous_standby_names = 'FIRST 1 (standby1, standby2, standby3)'
```

This waits for confirmation from any one of the listed standbys, providing redundancy while limiting performance impact.

#### Selective Synchronous Replication

```
# On primary postgresql.conf
synchronous_commit = on  # Global default

# At application level for critical transactions only
SET LOCAL synchronous_commit TO remote_apply;
```

This allows applications to determine which transactions require synchronous guarantees.

### Performance Considerations

#### Latency Impact

| Replication Mode | Typical Latency Impact | Use Case |
|------------------|------------------------|----------|
| Asynchronous | Minimal (microseconds) | High throughput applications |
| Synchronous (remote_write) | Low to moderate (milliseconds) | Balance of safety and performance |
| Synchronous (remote_flush) | Moderate (milliseconds) | Enhanced durability |
| Synchronous (remote_apply) | Highest (10s of milliseconds) | Critical financial/transactional data |

#### Benchmarking Results

**Example**: A typical performance comparison might show:
- Asynchronous: 10,000 TPS (transactions per second)
- Synchronous (remote_write): 8,000 TPS
- Synchronous (remote_apply): 5,000 TPS

Actual numbers vary significantly based on hardware, network, and workload characteristics.

### Failure Scenarios Analysis

#### Primary Server Failure

| Replication Mode | Data Loss Potential | Recovery Complexity |
|------------------|---------------------|---------------------|
| Asynchronous | Seconds of transactions | Simple promotion |
| Synchronous | Minimal to none | Simple promotion |

#### Network Partition

| Replication Mode | Primary Behavior | Standby Behavior |
|------------------|------------------|------------------|
| Asynchronous | Continues operating | Falls behind, reconnects later |
| Synchronous | May block or fail over | Continues receiving when reconnected |

#### Standby Failure

| Replication Mode | Primary Behavior | Recovery Process |
|------------------|------------------|------------------|
| Asynchronous | Unaffected | Rebuild standby from backup or primary |
| Synchronous | May block until timeout | May require manual intervention |

### Implementation Strategies

#### High Availability with Data Safety

```
# On primary postgresql.conf
synchronous_standby_names = 'FIRST 1 (standby1, standby2)'
synchronous_commit = remote_apply
```

Combined with transaction criticality-based settings:

```sql
-- For critical transactions in application code
SET LOCAL synchronous_commit TO remote_apply;

-- For less critical operations
SET LOCAL synchronous_commit TO off;
```

#### Geographic Distribution

For geographically distributed clusters:

```
# Local datacenter standby is synchronous
# Remote datacenter standbys are asynchronous
synchronous_standby_names = 'standby_local'
```

#### Configuration with Quorum Commit

```
# Requires majority confirmation (for 3 standbys)
synchronous_standby_names = 'FIRST 2 (standby1, standby2, standby3)'
```

This provides quorum-based durability guarantees while maintaining availability if a minority of standbys fail.

### Best Practices

1. **Match Replication Strategy to Business Needs**:
   - Financial data: Consider synchronous
   - Analytics/reporting: Consider asynchronous
   - Mixed workloads: Consider selective synchronous

2. **Plan for Network Quality**:
   - High-latency networks: Consider asynchronous or remote_write
   - Low-latency networks: Can use remote_apply with minimal impact

3. **Monitor Replication Health**:
   - Set up alerts for replication lag
   - Monitor synchronization state changes
   - Track transaction latency

4. **Test Failure Scenarios**:
   - Regularly simulate standby failures
   - Practice failover procedures
   - Measure recovery time objectives (RTO)

5. **Consider Application-Level Controls**:
   - Use `synchronous_commit` at session or transaction level
   - Batch non-critical writes

### Common Issues and Troubleshooting

#### Replication Timeouts

**Symptom**: Primary appears to hang during commits  
**Cause**: Synchronous standby unreachable or too slow  
**Solution**:
```
# On primary postgresql.conf
synchronous_standby_timeout = 30s  # Adjust as needed
```

#### Performance Degradation

**Symptom**: Slow transaction throughput  
**Cause**: Synchronous replication adding latency  
**Solution**: Consider using `synchronous_commit = remote_write` instead of `remote_apply`

#### Data Loss Assessment

After a failure event:
```sql
-- On promoted standby, check last received transaction
SELECT pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn();

-- Compare with last known primary position (if available)
```

### Advanced Configurations

#### Cascaded Replication with Synchronous Guarantees

```
primary → synchronous standby1 → asynchronous standby2
```

Configuration:
```
# On primary
synchronous_standby_names = 'standby1'

# On standby1
hot_standby = on
```

#### Mixed Synchronous Modes

```
# On primary postgresql.conf
# Default to slightly faster mode
synchronous_commit = remote_write

# For specific databases
ALTER DATABASE financial_db SET synchronous_commit TO remote_apply;
```

### Comparison with Other Database Systems

| System | Asynchronous Support | Synchronous Support | Special Features |
|--------|---------------------|---------------------|-----------------|
| PostgreSQL | Yes (default) | Yes (configurable) | Multiple sync levels |
| MySQL | Yes | Yes (semi-sync) | Group replication |
| Oracle | Yes | Yes (Data Guard) | Maximum Availability |
| SQL Server | Yes | Yes (sync AG) | Readable secondaries |

### Related Topics

- PostgreSQL Write-Ahead Log (WAL) architecture
- Commit Sequence Number (CSN) tracking
- Multi-master replication alternatives
- Network design for database replication
- Distributed transaction processing

---

