## Storage Performance


### Disk I/O Monitoring with iostat

The `iostat` command provides detailed insights into disk input/output statistics and CPU utilization patterns. This tool reports both device-level and partition-level statistics, enabling administrators to identify storage bottlenecks and performance issues.

**Basic iostat usage:**

```bash
iostat -x 1 5    # Extended statistics every 1 second, 5 times
iostat -d 2      # Device statistics every 2 seconds
iostat -c        # CPU statistics only
iostat -p sda    # Specific device statistics
```

**Key metrics to monitor:**

- **%util**: Device utilization percentage - values consistently above 80% indicate potential bottlenecks
- **await**: Average time for I/O requests including queue time
- **svctm**: Average service time for I/O requests [Unverified - this metric may not be reliable in modern kernels]
- **r/s and w/s**: Read and write requests per second
- **rkB/s and wkB/s**: Kilobytes read and written per second
- **avgrq-sz**: Average request size in sectors
- **avgqu-sz**: Average queue length of requests

Advanced monitoring combines iostat with other tools like `iotop` for process-level I/O analysis and `blktrace` for detailed block layer tracing.

### File System Performance

File system selection and configuration significantly impact storage performance across different workload patterns.

#### File System Types and Performance Characteristics

**ext4**: The default file system for many Linux distributions offers balanced performance with mature stability. Features delayed allocation and multi-block allocation for improved sequential write performance.

**XFS**: Designed for high-performance scenarios, particularly excelling with large files and parallel I/O operations. Supports online defragmentation and dynamic inode allocation.

**Btrfs**: Copy-on-write file system providing advanced features like snapshots and built-in RAID. Performance varies significantly based on configuration and workload patterns [Inference based on copy-on-write overhead].

**ZFS**: Offers comprehensive data integrity features with built-in compression and deduplication, though memory requirements can be substantial.

#### File System Tuning Parameters

Mount options significantly affect performance:

```bash
# Performance-oriented ext4 mount
mount -o noatime,data=writeback,barrier=0 /dev/sda1 /mnt

# XFS performance tuning
mount -o noatime,largeio,swalloc /dev/sda1 /mnt
```

**Critical tuning considerations:**

- **noatime**: Disables access time updates, reducing write operations
- **data=writeback**: Reduces journaling overhead but increases risk during crashes
- **barrier=0**: Disables write barriers for better performance on systems with proper power protection
- **swalloc**: Enables stripe-aware allocation for XFS on RAID systems

#### Block Size and Allocation Strategies

Block size selection affects both performance and space utilization. Larger block sizes improve sequential access performance but may waste space with small files [Inference based on block allocation mechanics].

```bash
# Create ext4 with 4K blocks (default)
mkfs.ext4 -b 4096 /dev/sda1

# Create XFS with specific allocation group size
mkfs.xfs -d agcount=8 /dev/sda1
```

### Storage Optimization

#### I/O Scheduler Selection

Linux provides multiple I/O schedulers optimized for different storage technologies and workload patterns.

**Available schedulers:**

- **mq-deadline**: Default for most systems, balances fairness and performance
- **kyber**: Designed for modern NVMe devices with multiple queues
- **bfq**: Budget Fair Queueing scheduler optimized for interactive workloads
- **none**: No scheduling, suitable for high-performance NVMe devices

```bash
# Check current scheduler
cat /sys/block/sda/queue/scheduler

# Change scheduler temporarily
echo mq-deadline > /sys/block/sda/queue/scheduler

# Set scheduler permanently via kernel parameters
# Add elevator=mq-deadline to GRUB_CMDLINE_LINUX
```

#### Queue Depth and Request Size Optimization

Modern storage devices benefit from appropriate queue depth configuration:

```bash
# Check current queue depth
cat /sys/block/sda/queue/nr_requests

# Adjust request queue size
echo 256 > /sys/block/sda/queue/nr_requests

# Set read-ahead for sequential workloads
blockdev --setra 4096 /dev/sda
```

#### RAID Configuration Impact

RAID levels significantly affect performance characteristics:

- **RAID 0**: Maximum performance through striping, no redundancy
- **RAID 1**: Read performance scaling, write performance penalty
- **RAID 5**: Good read performance, write penalty due to parity calculations
- **RAID 10**: Combines striping and mirroring for balanced performance and redundancy

**Example RAID 0 optimization:**

```bash
# Create RAID 0 with optimal chunk size
mdadm --create /dev/md0 --level=0 --raid-devices=2 --chunk=256 /dev/sda /dev/sdb
```

### Cache Management

#### Page Cache Behavior

The Linux page cache automatically manages memory allocation between applications and cached file data. Understanding cache behavior helps optimize system performance.

**Monitoring cache usage:**

```bash
# View cache statistics
cat /proc/meminfo | grep -E "Cached|Buffers|Dirty"

# Monitor cache hit ratios
sar -r 1 10

# View per-process cache usage
vmtouch -v /path/to/file
```

#### Cache Tuning Parameters

Critical sysctl parameters affect cache behavior:

```bash
# View current cache settings
sysctl vm.dirty_ratio
sysctl vm.dirty_background_ratio
sysctl vm.vfs_cache_pressure

# Optimize for write-heavy workloads
sysctl vm.dirty_ratio=40
sysctl vm.dirty_background_ratio=10
sysctl vm.dirty_expire_centisecs=3000

# Adjust cache pressure for metadata-heavy workloads
sysctl vm.vfs_cache_pressure=50
```

**Key parameters:**

- **vm.dirty_ratio**: Maximum percentage of memory for dirty pages before blocking writes
- **vm.dirty_background_ratio**: Background writeback threshold
- **vm.vfs_cache_pressure**: Controls tendency to reclaim cache memory
- **vm.swappiness**: Balances swapping versus cache reclaim

#### Direct I/O and Synchronous Operations

Applications can bypass page cache using direct I/O for predictable performance:

```bash
# Test direct I/O performance
dd if=/dev/zero of=testfile bs=1M count=1000 oflag=direct

# Test synchronized writes
dd if=/dev/zero of=testfile bs=1M count=1000 oflag=sync
```

#### Memory-Mapped Files and Cache Interaction

Memory-mapped files integrate with the page cache system, allowing efficient file access:

```bash
# Monitor memory-mapped regions
cat /proc/[pid]/maps

# View system-wide mapping statistics
cat /proc/vmstat | grep -E "nr_mapped|nr_file_pages"
```

**Key points:**

- Page cache acts as a unified buffer for file I/O operations
- Cache hit ratios directly impact application performance
- Proper cache sizing balances memory usage between applications and cached data
- Write-back caching improves performance but requires consideration of data consistency requirements

**Example** comprehensive storage monitoring script:

```bash
#!/bin/bash
# Storage performance monitoring
iostat -x 1 1
echo "=== Cache Statistics ==="
cat /proc/meminfo | grep -E "Cached|Buffers|Dirty"
echo "=== I/O Scheduler ==="
cat /sys/block/*/queue/scheduler
```

**Output** interpretation requires understanding baseline performance characteristics for your specific storage hardware and workload patterns.

**Conclusion:** Storage performance optimization requires systematic monitoring, appropriate file system selection, scheduler tuning, and cache management. Performance improvements depend heavily on workload characteristics and hardware capabilities [Inference based on system optimization principles].

---

