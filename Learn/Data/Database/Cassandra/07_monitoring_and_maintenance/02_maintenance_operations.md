## Maintenance Operations


### Node Replacement Procedures

Node replacement is one of the most critical maintenance operations in Cassandra, requiring careful coordination to maintain data availability and consistency during the transition.

#### Planned Node Replacement

Planned replacements allow for controlled migration of data with minimal service disruption when nodes require hardware upgrades or maintenance.

**Key Points:**

- Maintains cluster topology and token assignments during replacement
- Requires coordination with existing nodes for data streaming
- Preserves replication factor throughout the replacement process
- Enables zero-downtime replacement when properly executed

The replacement process begins with preparing the new node with identical configuration, excluding any node-specific identifiers. The `replace_address` parameter in cassandra.yaml specifies which existing node to replace, triggering automatic token inheritance and data streaming.

**Example replacement procedure:**

```bash
# On new node - configure cassandra.yaml
replace_address: 192.168.1.100
auto_bootstrap: true

# Start replacement node
sudo systemctl start cassandra

# Monitor streaming progress
nodetool netstats
```

[Inference] Replacement duration depends on data volume and network capacity, typically requiring several hours for nodes containing hundreds of gigabytes of data.

#### Emergency Node Replacement

Emergency replacements handle scenarios where nodes fail catastrophically and cannot be recovered, requiring immediate action to restore replication levels.

**Key Points:**

- Responds to permanent node failures requiring immediate replacement
- May involve data loss if consistency levels were not properly maintained
- Requires careful token management to avoid data inconsistencies
- Should trigger immediate repair operations after completion

Emergency replacement follows similar procedures but may require additional steps like `removenode` operations if the failed node cannot be cleanly shut down. [Inference] Emergency replacements carry higher risk of data inconsistencies, particularly if the failed node contained unique data replicas.

#### Token Assignment Strategies

Proper token management ensures balanced data distribution and optimal performance across the cluster.

**Key Points:**

- Vnodes (virtual nodes) automatically distribute tokens across the ring
- Manual token assignment provides precise control over data distribution
- Token allocation affects load balancing and repair efficiency
- Improper token assignment can create hotspots and performance issues

Modern Cassandra deployments typically use vnodes with `num_tokens: 256` providing automatic load balancing. [Inference] Manual token assignment may still be beneficial for clusters with predictable access patterns or specific performance requirements.

### Adding and Removing Nodes

Cluster scaling operations require careful orchestration to maintain data consistency and availability while redistributing cluster load.

#### Adding Nodes (Scale Out)

Adding nodes increases cluster capacity and potentially improves performance by distributing load across more hardware.

**Key Points:**

- Bootstrap process streams data from existing nodes to new additions
- Automatic token assignment distributes data across new topology
- Requires careful coordination with existing repair and maintenance schedules
- May temporarily increase resource usage during data streaming

The bootstrap process automatically identifies data ranges the new node should own and initiates streaming from appropriate replicas. Configuration requires setting `auto_bootstrap: true` and ensuring proper seed node configuration.

**Example node addition:**

```bash
# Configure new node with same cluster settings
cluster_name: 'production_cluster'
seeds: "192.168.1.1,192.168.1.2,192.168.1.3"
auto_bootstrap: true

# Start new node
sudo systemctl start cassandra

# Verify bootstrap completion
nodetool status
nodetool netstats
```

[Inference] Bootstrap duration scales with data volume per node, potentially taking hours or days for large datasets with limited network bandwidth.

#### Removing Nodes (Scale Down)

Node removal redistributes data to remaining cluster members while maintaining replication requirements.

**Key Points:**

- Decommission process streams data to appropriate remaining nodes
- Maintains replication factor by redistributing departed node's ranges
- Requires sufficient remaining capacity to handle redistributed data
- Should be coordinated with maintenance windows to minimize impact

Decommissioning gracefully removes nodes by streaming their data to appropriate replicas before departure. The `nodetool decommission` command initiates this process, which completes when all data has been successfully transferred.

**Example decommission procedure:**

```bash
# On node to be removed
nodetool decommission

# Monitor streaming progress
nodetool netstats

# Verify node removal from other nodes
nodetool status
```

#### Capacity Planning Considerations

Scaling operations require careful analysis of current and projected resource utilization to ensure cluster stability.

**Key Points:**

- Monitor disk utilization, CPU load, and memory usage before scaling
- Consider network bandwidth limitations during data streaming operations
- Account for temporary resource spikes during bootstrap/decommission
- Plan for future growth to avoid frequent scaling operations

[Inference] Scaling operations typically perform better when existing nodes operate below 70% capacity, providing sufficient headroom for data redistribution without performance degradation.

### Repair Operations and Scheduling

Repair operations maintain data consistency across replicas by identifying and correcting inconsistencies that may develop over time.

#### Full Repairs

Full repairs examine all data within specified ranges, ensuring complete consistency across all replicas.

**Key Points:**

- Compares data across all replicas for specified token ranges
- Identifies and corrects inconsistencies through streaming operations
- Resource-intensive operation requiring careful scheduling
- Essential for maintaining long-term data consistency

Full repairs use merkle trees to efficiently compare large datasets across replicas. The process can be limited to specific keyspaces, tables, or token ranges to manage resource impact.

**Example full repair:**

```bash
# Full keyspace repair
nodetool repair keyspace_name

# Table-specific repair
nodetool repair keyspace_name table_name

# Primary range only repair (more efficient)
nodetool repair -pr keyspace_name
```

[Inference] Primary range repairs (`-pr` flag) typically provide equivalent consistency guarantees while reducing resource usage by limiting each node to repairing only its primary token ranges.

#### Incremental Repairs

Incremental repairs optimize repair operations by tracking which SSTables have been previously repaired, reducing unnecessary work.

**Key Points:**

- Maintains metadata about repaired versus unrepaired SSTables
- Reduces repair time by focusing only on unrepaired data
- Requires careful management of repair state across the cluster
- May complicate compaction strategies and SSTable management

Incremental repair introduces marked and unmarked SSTables, requiring compatible compaction strategies to maintain effectiveness. [Inference] Incremental repairs typically provide significant performance benefits for large datasets but may introduce operational complexity.

#### Repair Scheduling Strategies

Systematic repair scheduling ensures data consistency while minimizing operational impact on production workloads.

**Key Points:**

- Regular repair schedules prevent accumulation of inconsistencies
- Distributed repair timing avoids resource contention
- Integration with monitoring systems enables automated scheduling
- Coordination with other maintenance operations reduces cumulative impact

[Inference] Weekly repair schedules typically provide adequate consistency maintenance for most workloads, while high-write environments may benefit from more frequent repair operations.

**Example repair scheduling with cron:**

```bash
# Weekly repair scheduled during low-usage periods
0 2 * * 0 /usr/bin/nodetool repair -pr production_keyspace
```

### Backup and Restore Procedures

Comprehensive backup strategies protect against data loss while enabling point-in-time recovery and disaster recovery scenarios.

#### Snapshot-Based Backups

Snapshots create consistent point-in-time copies of data files, providing the foundation for backup and recovery operations.

**Key Points:**

- Creates hard links to existing SSTable files without copying data
- Provides consistent snapshot across all tables simultaneously
- Requires additional steps to copy snapshot data to external storage
- Enables incremental backup strategies by tracking file changes

Snapshot operations complete quickly since they create hard links rather than copying data. However, actual backup requires copying snapshot files to external storage systems.

**Example snapshot operations:**

```bash
# Create cluster-wide snapshot
nodetool snapshot production_keyspace

# Create named snapshot
nodetool snapshot -t backup_20250724 production_keyspace

# List existing snapshots
nodetool listsnapshots

# Clear old snapshots
nodetool clearsnapshot production_keyspace
```

#### Incremental Backup Strategies

Incremental backups capture only changes since the last backup, reducing storage requirements and backup windows.

**Key Points:**

- Automatically copies new SSTable files to backup directory
- Requires enabled incremental backup feature in configuration
- Combines with periodic snapshots for complete recovery capability
- Reduces network and storage overhead compared to full backups

Incremental backups require `incremental_backups: true` in cassandra.yaml and external processes to move backup files to permanent storage.

[Inference] Combination strategies using weekly snapshots with daily incremental backups typically provide optimal balance between recovery capability and resource utilization.

#### Point-in-Time Recovery

Recovery procedures restore cluster state to specific points in time using combinations of snapshots and incremental backups.

**Key Points:**

- Requires coordinated restore across all cluster nodes
- May involve replaying commit logs for precise time recovery
- Necessitates careful ordering of restore operations
- Should be tested regularly to verify recovery procedures

Recovery procedures vary based on backup strategy and desired recovery point. [Inference] Recovery time scales with data volume and may require several hours for large clusters with terabytes of data.

#### Cross-Datacenter Backup Strategies

Multi-datacenter deployments require coordinated backup strategies ensuring recoverability across geographic regions.

**Key Points:**

- Coordinates backup timing across multiple datacenters
- Accounts for network latency and bandwidth limitations
- Provides disaster recovery capabilities for datacenter failures
- May leverage replication for backup redundancy

[Inference] Cross-datacenter backup strategies often utilize existing replication streams to minimize additional network overhead while ensuring geographic backup distribution.

### Cleanup Operations

Regular cleanup operations maintain cluster health by removing unnecessary data and optimizing storage utilization.

#### SSTable Cleanup

SSTable cleanup removes data that no longer belongs to a node after topology changes, reclaiming disk space and improving performance.

**Key Points:**

- Removes data outside node's current token ranges
- Essential after cluster scaling operations
- Reclaims disk space occupied by redistributed data
- Improves read performance by reducing SSTable count

Cleanup operations should follow any topology changes like node additions or removals. The process rewrites SSTables containing only data within the node's current token ranges.

**Example cleanup operations:**

```bash
# Cleanup specific keyspace
nodetool cleanup production_keyspace

# Cleanup all keyspaces
nodetool cleanup

# Monitor cleanup progress
nodetool compactionstats
```

[Inference] Cleanup operations may temporarily increase disk usage during SSTable rewriting before reclaiming space occupied by out-of-range data.

#### Tombstone Removal

Tombstone cleanup removes deletion markers after their grace period expires, reclaiming storage space and improving read performance.

**Key Points:**

- Removes tombstones after gc_grace_seconds period expires
- Triggered automatically during compaction operations
- Can be forced through major compaction when necessary
- Improves read performance by reducing filtering overhead

Tombstone removal happens automatically during normal compaction, but may require manual intervention for tables with infrequent compaction activity.

#### Log File Management

Log file cleanup prevents disk space exhaustion from accumulated system and application logs.

**Key Points:**

- System logs accumulate debugging and operational information
- Commit logs consume space until segments are cleaned
- Application logs may contain performance and error information
- Automated rotation prevents disk space issues

Log management typically involves configuring log rotation policies and cleanup schedripts. [Inference] Weekly log cleanup with appropriate retention periods typically balances debugging capabilities with disk space management.

**Example log cleanup configuration:**

```bash
# Logrotate configuration for Cassandra logs
/var/log/cassandra/*.log {
    weekly
    rotate 4
    compress
    delaycompress
    missingok
    notifempty
}
```

#### Monitoring and Alerting Integration

Integrated monitoring ensures maintenance operations complete successfully and identify potential issues before they impact operations.

**Key Points:**

- Automated monitoring of maintenance operation completion
- Alerting for failed or long-running operations
- Integration with existing monitoring infrastructure
- Performance impact tracking during maintenance windows

[Inference] Comprehensive monitoring typically includes metrics for repair progress, backup completion status, cleanup effectiveness, and resource utilization during maintenance operations.

**Conclusion:** Maintenance operations require careful planning, coordination, and monitoring to ensure cluster health while minimizing service disruption. [Inference] Most production environments benefit from automated scheduling and monitoring of routine maintenance tasks, with manual intervention reserved for complex operations like node replacement.

**Next Steps:** Establish regular maintenance schedules, implement comprehensive monitoring for all maintenance operations, create detailed runbooks for complex procedures, and conduct regular disaster recovery testing to validate backup and restore procedures.

---

