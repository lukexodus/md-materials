## JVM and System Tuning


### JVM Heap Sizing and Garbage Collection

Cassandra's JVM heap sizing requires balancing memory allocation between heap and off-heap usage. The general recommendation targets 8GB heap size as optimal for most workloads, with larger heaps potentially causing garbage collection problems that impact performance and availability.

Heap sizing follows specific guidelines based on system memory: for systems with 32GB or less RAM, allocate 25% to heap with a maximum of 8GB. For larger systems, maintain the 8GB heap limit while allocating remaining memory to off-heap structures and operating system caches.

**Key points:**

- Target 8GB heap size for optimal garbage collection performance
- Allocate 25% of system RAM to heap, capped at 8GB maximum
- Reserve remaining memory for off-heap storage and OS caches
- Monitor GC pause times and frequency for performance impact

**Example:**

```bash
# For a 32GB system
-Xms8G -Xmx8G
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
-XX:G1HeapRegionSize=16m
```

Garbage collection tuning focuses on minimizing pause times that can cause node unavailability. G1GC is the recommended collector for Cassandra workloads, providing better pause time predictability than other collectors. The collector configuration should target pause times under 200ms to prevent cluster instability.

**Key points:**

- Use G1GC for predictable pause times
- Target GC pause times under 200ms
- Monitor GC logs for pause time trends and frequency
- [Unverified] Concurrent mark sweep (CMS) may still be viable for specific workloads

GC logging and monitoring provide essential insights into JVM performance. Enabling detailed GC logging helps identify pause time patterns and memory allocation issues that could impact cluster health.

**Example:**

```bash
-XX:+PrintGC
-XX:+PrintGCDetails
-XX:+PrintGCTimeStamps
-XX:+PrintGCApplicationStoppedTime
-Xloggc:/var/log/cassandra/gc.log
```

### Off-Heap Memory Usage

Cassandra extensively uses off-heap memory for bloom filters, partition summaries, compression metadata, and key caches. This off-heap usage reduces garbage collection pressure while providing efficient access to frequently used data structures.

Off-heap memory allocation should comprise the majority of available system memory after reserving space for heap and operating system. Typical configurations allocate 50-70% of total system memory to off-heap usage, depending on workload characteristics and data size.

**Key points:**

- Off-heap memory reduces GC pressure and improves performance
- Allocate 50-70% of system memory to off-heap usage
- Monitor off-heap allocation and usage patterns
- Balance off-heap allocation with OS cache requirements

**Example:** For a 64GB system:

- JVM heap: 8GB
- Off-heap (Cassandra): 40GB
- OS and buffers: 16GB

Key cache sizing impacts read performance by keeping frequently accessed partition keys in memory. The key cache should be sized based on working set requirements, typically 5-10% of total key space for most workloads.

**Key points:**

- Size key cache based on working set size, not total key count
- Monitor key cache hit rates and adjust sizing accordingly
- [Inference] Higher cache hit rates generally improve read performance
- Consider workload patterns when sizing caches

Row cache provides partition-level caching but requires careful consideration due to its memory overhead and potential for cache invalidation issues. Most workloads benefit more from increasing key cache size than enabling row cache.

**Key points:**

- Row cache has high memory overhead per cached partition
- Cache invalidation can impact write performance
- Most workloads benefit more from larger key caches
- [Speculation] Row cache may be beneficial for read-heavy workloads with small partitions

### Operating System Tuning

Operating system configuration significantly impacts Cassandra performance through memory management, I/O scheduling, and process limits. Virtual memory settings require adjustment to prevent swapping, which can cause severe performance degradation and node timeouts.

Swapping should be completely disabled or minimized through swappiness settings. Cassandra's memory usage patterns make swapping particularly harmful, as it can cause unpredictable latency spikes and garbage collection issues.

**Key points:**

- Disable swap or set vm.swappiness to 1
- Configure appropriate file descriptor limits
- Tune kernel I/O scheduler for storage type
- Set proper process and memory limits

**Example:**

```bash
# /etc/sysctl.conf
vm.swappiness=1
vm.max_map_count=1048575
net.core.rmem_max=134217728
net.core.wmem_max=134217728
```

File descriptor limits must accommodate Cassandra's file usage patterns, including SSTable files, network connections, and log files. Insufficient limits cause startup failures or runtime errors when the node cannot open required files.

**Key points:**

- Set file descriptor limits to 100,000 or higher
- Configure both soft and hard limits appropriately
- Include limits for both the Cassandra user and system-wide
- Monitor actual file descriptor usage under load

**Example:**

```bash
# /etc/security/limits.conf
cassandra soft nofile 100000
cassandra hard nofile 100000
cassandra soft nproc 32768
cassandra hard nproc 32768
```

Process scheduling and CPU affinity can impact performance on multi-core systems. While Cassandra generally handles CPU scheduling well automatically, specific workloads may benefit from CPU affinity settings or process priority adjustments.

**Key points:**

- Generally avoid CPU affinity unless specific performance issues identified
- Monitor CPU utilization patterns across cores
- [Unverified] Process priority adjustments may help in mixed workload environments
- Consider NUMA topology for large multi-socket systems

### Disk I/O Optimization

Storage configuration represents one of the most critical performance factors for Cassandra. SSD storage provides significant advantages over traditional spinning disks, particularly for read-heavy workloads and compaction operations.

I/O scheduler selection depends on storage type: deadline scheduler works well for SSDs, while CFQ may be appropriate for spinning disks. The scheduler choice impacts how the kernel manages I/O requests and can significantly affect latency characteristics.

**Key points:**

- Use SSD storage for optimal performance
- Configure I/O scheduler appropriate for storage type (deadline for SSD)
- Separate commit log and data directories when possible
- Monitor I/O utilization and queue depths

**Example:**

```bash
# Set I/O scheduler for SSD
echo deadline > /sys/block/sda/queue/scheduler

# Verify scheduler setting
cat /sys/block/sda/queue/scheduler
```

File system selection and mounting options impact both performance and data safety. XFS generally provides better performance than ext4 for Cassandra workloads, while mounting options should balance performance with data integrity requirements.

**Key points:**

- XFS typically outperforms ext4 for Cassandra workloads
- Use appropriate mount options for performance and safety
- Consider separate file systems for commit log and data
- [Inference] noatime mount option reduces unnecessary write operations

**Example:**

```bash
# /etc/fstab entry for data directory
/dev/sdb1 /var/lib/cassandra/data xfs defaults,noatime,norelatime 0 0
```

RAID configuration should prioritize performance and availability over storage efficiency. RAID 10 provides the best balance of performance and fault tolerance, while RAID 5/6 should be avoided due to write performance penalties.

**Key points:**

- RAID 10 provides optimal performance and fault tolerance
- Avoid RAID 5/6 due to write performance impact
- Consider JBOD with replication for maximum performance
- [Speculation] Cloud storage options may have different optimal configurations

### Network Configuration

Network tuning affects both client communication and inter-node cluster traffic. TCP buffer sizes, connection limits, and timeout settings require adjustment for high-throughput Cassandra deployments.

TCP buffer sizing impacts throughput for large data transfers during operations like bootstrap, repair, and streaming. Increasing buffer sizes can improve performance for these operations, particularly in high-bandwidth environments.

**Key points:**

- Increase TCP receive and send buffer sizes for high throughput
- Configure appropriate connection timeout values
- Monitor network utilization during cluster operations
- Consider network topology impact on consistency levels

**Example:**

```bash
# Network buffer tuning
net.core.rmem_default=262144
net.core.rmem_max=134217728
net.core.wmem_default=262144
net.core.wmem_max=134217728
net.ipv4.tcp_rmem=4096 87380 134217728
net.ipv4.tcp_wmem=4096 65536 134217728
```

Connection pooling and timeout configurations in both Cassandra and client applications affect reliability under load. Proper timeout settings prevent resource exhaustion while maintaining responsiveness during network issues.

**Key points:**

- Configure reasonable connection timeouts
- Size connection pools appropriately for workload
- Monitor connection usage and timeout rates
- [Unverified] Connection pool sizing may need adjustment based on client libraries

Firewall and security configurations must balance access control with performance requirements. Overly restrictive rules can impact cluster communication, while insufficient security creates operational risks.

**Key points:**

- Configure firewalls to allow required Cassandra ports
- Consider security group rules in cloud environments
- Balance security requirements with operational needs
- Monitor for connection failures due to security restrictions

**Output considerations:** JVM and system tuning requires iterative testing and monitoring to achieve optimal performance. Changes should be implemented gradually with careful observation of performance metrics and cluster health indicators.

**Related topics to consider:**

- Monitoring and alerting for system performance metrics
- Capacity planning based on performance characteristics
- Troubleshooting performance issues through system analysis
- Cloud-specific tuning considerations and limitations

---

