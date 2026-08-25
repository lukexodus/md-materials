## System Tuning


### Kernel Parameter Tuning (`sysctl`)

The `sysctl` interface provides runtime kernel parameter modification without requiring system reboots. These parameters control various aspects of kernel behavior, from networking to memory management.

#### Core sysctl Commands

The `sysctl` command manages kernel parameters through the `/proc/sys` filesystem. Parameters can be viewed with `sysctl parameter_name`, modified temporarily with `sysctl -w parameter=value`, and made persistent by adding entries to `/etc/sysctl.conf` or files in `/etc/sysctl.d/`.

#### Network Tuning Parameters

Critical network parameters include `net.core.rmem_max` and `net.core.wmem_max` for socket buffer sizes, `net.ipv4.tcp_congestion_control` for TCP congestion algorithms, and `net.core.netdev_max_backlog` for network device queue length. The `net.ipv4.tcp_window_scaling` enables TCP window scaling for high-bandwidth connections.

#### Memory Management Parameters

Key memory parameters include `vm.swappiness` (0-100, controls swap usage tendency), `vm.dirty_ratio` (percentage of memory for dirty pages before writeback), and `vm.vfs_cache_pressure` (controls reclaiming of directory and inode caches). The `vm.overcommit_memory` parameter controls memory overcommitment behavior.

#### Security Parameters

Security-related parameters include `kernel.randomize_va_space` for address space layout randomization, `net.ipv4.conf.all.rp_filter` for reverse path filtering, and various `net.ipv4.icmp_*` parameters for ICMP behavior control.

**Key points:**

- Changes via `sysctl -w` are temporary and lost on reboot
- `/etc/sysctl.conf` provides persistent configuration
- Use `sysctl -a` to list all available parameters
- Test parameter changes before making them permanent

### Resource Limits (`ulimit`)

Resource limits control the amount of system resources available to processes and users, preventing resource exhaustion and system instability.

#### Types of Limits

The `ulimit` command manages both soft and hard limits. Soft limits can be increased up to the hard limit by unprivileged users, while hard limits require root privileges to modify. Common limit types include file descriptors (`-n`), memory (`-m`), CPU time (`-t`), and process count (`-u`).

#### Per-User Limits Configuration

The `/etc/security/limits.conf` file and `/etc/security/limits.d/` directory contain persistent user and group limit configurations. Format follows: `<domain> <type> <item> <value>`, where domain can be username, group, or wildcard, type is soft/hard, and item specifies the resource.

#### Common Limit Adjustments

File descriptor limits often require increases for database servers and web applications. Memory limits help prevent runaway processes from consuming all system memory. Process limits control fork bombs and excessive process creation. Core dump size limits manage disk space usage from crashed applications.

#### SystemD Service Limits

Modern systems using systemd can set resource limits within service unit files using directives like `LimitNOFILE`, `LimitNPROC`, and `LimitMEMORY`. These limits apply specifically to the service and its child processes.

**Key points:**

- Limits apply to login sessions and their spawned processes
- SystemD services require limits set in unit files
- Monitor current limits with `ulimit -a`
- Root can always override limits but should use caution

### Scheduler Tuning

Linux scheduler tuning optimizes CPU allocation and process prioritization for specific workload requirements.

#### Scheduler Classes

Linux implements multiple scheduler classes: CFS (Completely Fair Scheduler) for normal processes, RT (Real-Time) for time-critical tasks, and IDLE for background processes. Each class has different algorithms and priority mechanisms.

#### Process Priorities and Nice Values

Nice values range from -20 (highest priority) to +19 (lowest priority), affecting CFS scheduling decisions. The `nice` command starts processes with specific priorities, while `renice` modifies running process priorities. Real-time priorities (1-99) take precedence over all nice values.

#### CPU Affinity Management

CPU affinity binds processes to specific CPU cores using `taskset`. This optimization reduces cache misses and improves performance for CPU-intensive applications. NUMA (Non-Uniform Memory Access) systems benefit from matching process placement with memory locality.

#### Scheduler Policy Configuration

Real-time scheduling policies include SCHED_FIFO (first-in-first-out) and SCHED_RR (round-robin). SCHED_BATCH optimizes for throughput over interactivity, while SCHED_IDLE runs only when no other processes need CPU time.

#### Kernel Scheduler Parameters

Scheduler behavior can be tuned through `/proc/sys/kernel/sched_*` parameters. Key parameters include `sched_min_granularity_ns` for minimum slice time, `sched_wakeup_granularity_ns` for preemption decisions, and various load balancing controls.

**Key points:**

- CFS provides fair CPU distribution among competing processes
- Real-time scheduling requires careful configuration to avoid system lockup
- CPU affinity should align with application architecture and NUMA topology
- Scheduler tuning often requires workload-specific testing

### Memory Management

Memory management tuning optimizes RAM usage, swap behavior, and virtual memory subsystem performance.

#### Virtual Memory Subsystem

The Linux virtual memory subsystem manages physical RAM, swap space, and memory mapping. Key components include the page cache for file I/O, anonymous memory for process data, and shared memory for inter-process communication.

#### Swap Configuration and Tuning

Swap space provides virtual memory extension but with significant performance penalties. The `vm.swappiness` parameter (0-100) controls swap usage aggressiveness. Values near 0 minimize swapping, while higher values increase swap usage to free RAM for file caches.

#### Memory Overcommitment

Linux allows memory overcommitment, allocating more virtual memory than physically available. The `vm.overcommit_memory` parameter controls this behavior: 0 (heuristic), 1 (always allow), or 2 (strict accounting). The `vm.overcommit_ratio` sets the percentage of RAM that can be overcommitted.

#### Page Cache and Buffer Management

The page cache stores recently accessed file data in RAM for faster subsequent access. Parameters like `vm.dirty_ratio` and `vm.dirty_background_ratio` control when dirty pages are written to storage. The `vm.vfs_cache_pressure` parameter influences cache reclaim behavior.

#### Memory Compaction and Fragmentation

Memory compaction reduces fragmentation by moving pages to create larger contiguous blocks. The `vm.compact_memory` trigger initiates manual compaction, while `vm.compaction_proactiveness` controls automatic compaction frequency.

#### Transparent Huge Pages (THP)

THP automatically uses larger page sizes to reduce TLB pressure and improve performance for memory-intensive applications. Configuration options include always enabled, madvise-only, or disabled, typically controlled through `/sys/kernel/mm/transparent_hugepage/enabled`.

#### NUMA Memory Management

NUMA systems require memory locality awareness for optimal performance. The `vm.zone_reclaim_mode` parameter controls local versus remote memory reclaim behavior. NUMA balancing automatically migrates pages closer to accessing processes.

**Key points:**

- Memory overcommitment can lead to OOM (Out of Memory) killer activation
- Swap should be sized based on workload requirements, not arbitrary ratios [Inference]
- Page cache provides significant I/O performance benefits
- NUMA topology awareness is crucial for multi-socket systems
- Memory tuning requires understanding of application memory access patterns

**Example configuration:**

```bash
# Network tuning
echo 'net.core.rmem_max = 134217728' >> /etc/sysctl.conf
echo 'net.core.wmem_max = 134217728' >> /etc/sysctl.conf

# Memory management
echo 'vm.swappiness = 10' >> /etc/sysctl.conf
echo 'vm.dirty_ratio = 15' >> /etc/sysctl.conf

# Apply changes
sysctl -p
```

**Conclusion:** System tuning requires careful analysis of workload characteristics and systematic testing of parameter changes. Monitoring tools should track the impact of tuning modifications to ensure performance improvements without system instability. [Inference] Different workloads may require contradictory optimizations, necessitating workload-specific tuning approaches.

---

