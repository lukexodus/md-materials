## Apache Cassandra Troubleshooting


### Common Failure Scenarios

#### Node Failures

**Key points**: Node failures are among the most frequent issues in Cassandra clusters, manifesting through various symptoms and requiring systematic diagnosis.

Cassandra nodes can fail due to hardware issues, memory exhaustion, disk space problems, or network connectivity loss. When a node becomes unresponsive, other nodes detect this through gossip protocol timeouts and mark it as down. The cluster continues operating with reduced capacity, but read and write operations may experience increased latency or temporary unavailability depending on consistency levels and replication factor.

**Example**: A node running out of disk space will stop accepting writes and may crash. The logs typically show "No space left on device" errors, and monitoring tools will indicate 100% disk utilization.

#### Split-Brain Scenarios

Network partitions can create split-brain situations where different parts of the cluster cannot communicate but continue operating independently. This violates Cassandra's eventual consistency model and can lead to data divergence.

**Key points**: Split-brain detection relies on monitoring gossip state and node connectivity patterns across data centers.

#### Compaction Failures

Compaction processes can fail due to insufficient disk space, corrupted SSTables, or memory pressure. Failed compactions leave behind temporary files and can significantly impact read performance as queries must scan multiple SSTables.

#### Schema Disagreements

Schema mismatches between nodes occur when DDL changes don't propagate properly across the cluster. This can cause application errors and inconsistent query results.

### Debugging Performance Issues

#### Read Performance Degradation

**Key points**: Read performance issues typically stem from inefficient data modeling, inadequate caching, or suboptimal query patterns.

Slow reads often indicate wide partitions, lack of appropriate indexes, or queries that don't align with the data model. The partition size and read patterns significantly impact performance, as Cassandra is optimized for sequential reads within partitions.

Diagnostic approaches include analyzing query traces, examining partition sizes, and reviewing cache hit ratios. The `nodetool tablehistograms` command provides insights into read latency distributions and partition sizes.

**Example**: A query scanning multiple partitions with `ALLOW FILTERING` will show high latency in traces, with most time spent in data retrieval rather than network communication.

#### Write Performance Issues

Write performance problems usually relate to memtable flushing, compaction backlog, or commit log issues. Cassandra's write path involves memtable storage, commit log writing, and eventual SSTable creation through flushing.

Monitoring memtable flush frequency, pending compactions, and commit log segment utilization helps identify bottlenecks. High write latency often correlates with pending flushes or compaction backlog.

#### Memory Management Problems

Java heap issues, including garbage collection pauses and out-of-memory errors, significantly impact Cassandra performance. G1GC tuning and proper heap sizing are critical for stable operation.

**Key points**: Memory pressure manifests through increased GC frequency, longer pause times, and eventual node instability.

### Network Partition Handling

#### Detection Mechanisms

Cassandra detects network partitions through gossip protocol failures and endpoint state changes. Nodes that cannot communicate with sufficient peers enter a partitioned state and may reduce their operational capacity.

The phi accrual failure detector calculates suspicion levels based on heartbeat intervals and network latency patterns. Higher phi values indicate increased likelihood of node failure or network issues.

#### Consistency Level Impact

Different consistency levels respond differently to network partitions. `QUORUM` reads and writes require majority agreement, making them more resilient to single-node failures but potentially unavailable during larger partitions.

**Key points**: `LOCAL_QUORUM` provides partition tolerance within a data center while maintaining consistency guarantees.

#### Hinted Handoff Behavior

During network partitions, nodes store hints for unreachable replicas. When connectivity restores, hints are replayed to achieve eventual consistency. However, hints have storage limits and time-to-live constraints.

### Data Consistency Debugging

#### Repair Operations

`nodetool repair` identifies and fixes data inconsistencies between replicas. Full repairs compare merkle trees across replicas and stream differences to achieve consistency. Incremental repairs track repaired data separately and only process unrepaired SSTables.

**Key points**: Repair operations are resource-intensive and should be scheduled during low-traffic periods.

#### Read Repair Mechanisms

Read repair occurs automatically when Cassandra detects inconsistencies during read operations. The coordinator node compares responses from multiple replicas and initiates repair for any mismatches.

**Example**: A `QUORUM` read touching three replicas might detect that one replica has stale data and trigger background repair to update it.

#### Consistency Level Testing

Testing different consistency levels helps identify data consistency issues. Comparing results between `ONE` and `ALL` reads can reveal replica inconsistencies that require attention.

### Recovery Procedures

#### Node Recovery

**Key points**: Node recovery procedures vary depending on the failure type and data integrity status.

For nodes with intact data directories, recovery typically involves restarting the service and allowing gossip to re-establish cluster membership. The node will receive hints for missed writes and gradually return to full operational status.

For nodes with corrupted or lost data, recovery requires either restoring from backups or rebuilding from other replicas using `nodetool rebuild`.

#### Cluster-Wide Recovery

Major cluster failures require systematic recovery procedures starting with seed nodes and gradually adding other nodes. Proper seed node selection ensures gossip state propagates correctly during recovery.

**Key points**: Recovery order matters - bring up seed nodes first, then systematic addition of other nodes while monitoring gossip state.

#### Data Recovery from Backups

Snapshot-based recovery involves stopping the node, clearing data directories, restoring snapshot files, and restarting. Incremental backups provide point-in-time recovery capabilities when combined with commit log replay.

**Example**: Restoring a table from snapshot requires copying SSTable files to the appropriate data directory and running `nodetool refresh` to make them visible to the node.

#### Point-in-Time Recovery

[Inference] Point-in-time recovery combines snapshot restoration with commit log replay to achieve precise recovery timestamps, though this requires careful coordination across cluster nodes.

**Conclusion**: Effective Cassandra troubleshooting requires understanding the distributed nature of failures and their cascading effects. Systematic approaches to diagnosis, combined with proper monitoring and alerting, enable rapid identification and resolution of issues before they impact application availability.

Important related subtopics include monitoring strategies, alerting configuration, capacity planning, and disaster recovery planning.

---

