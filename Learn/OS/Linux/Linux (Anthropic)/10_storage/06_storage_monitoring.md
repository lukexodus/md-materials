## Storage Monitoring


### Disk Usage (`df`, `du`)

Disk space monitoring involves tracking both filesystem usage and directory-level consumption using complementary tools that provide different perspectives on storage utilization.

#### df Command Usage

The df (disk free) command displays filesystem-level disk space usage, showing mounted filesystems and their available space.

**Basic df syntax:**
```bash
df [options] [filesystem...]
```

**Essential df options:**
- `-h` - Human-readable format (KB, MB, GB)
- `-H` - Human-readable using 1000-byte units instead of 1024
- `-T` - Display filesystem type
- `-i` - Show inode information instead of block usage
- `-x` - Exclude specific filesystem types
- `-t` - Include only specific filesystem types

**Example outputs:**
```bash
df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        20G   12G  7.2G  63% /
/dev/sda2       100G   45G   50G  48% /home
tmpfs           2.0G     0  2.0G   0% /dev/shm
```

**Key Points:**
- df reports space from filesystem perspective
- "Available" space may differ from "Total - Used" due to reserved blocks
- Most filesystems reserve 5% for root user by default
- tmpfs filesystems show maximum possible usage, not actual memory consumption

#### du Command Usage

The du (disk usage) command calculates actual disk space consumed by directories and files, providing granular usage information.

**Basic du syntax:**
```bash
du [options] [directory...]
```

**Essential du options:**
- `-h` - Human-readable format
- `-s` - Summarize (show total only)
- `-c` - Display grand total
- `-a` - Include files in output
- `-d N` - Maximum depth level
- `--max-depth=N` - Alternative depth specification
- `-x` - Stay on single filesystem
- `--exclude=PATTERN` - Exclude files matching pattern

**Common usage patterns:**
```bash
# Directory summary
du -sh /var/log
du -sh /home/*

# Top-level directory usage
du -h --max-depth=1 /

# Find largest directories
du -h /home | sort -hr | head -10
```

#### Differences Between df and du

**Key Points:**
- df shows filesystem-level space; du shows actual file consumption
- Deleted files held open by processes appear in df but not du
- Hard links counted once by du but may appear multiple times in df calculations
- Sparse files show different values between df and du
- Reserved filesystem space affects df but not du calculations

### Inode Usage Monitoring

Inodes store filesystem metadata for files and directories. Inode exhaustion can prevent file creation even when disk space remains available.

#### Understanding Inode Limitations

Each filesystem has a fixed number of inodes determined at creation time. The ratio of inodes to blocks affects how many small files can be stored.

**Checking inode usage:**
```bash
df -i
Filesystem      Inodes   IUsed   IFree IUse% Mounted on
/dev/sda1      1310720   89543 1221177    7% /
/dev/sda2      6553600  245891 6307709    4% /home
```

#### Inode Monitoring Commands

**Detailed inode information:**
```bash
# Show inode usage for all filesystems
df -i

# Show inode usage for specific filesystem
df -i /home

# Find directories consuming many inodes
find /var -type f | cut -d'/' -f2 | sort | uniq -c | sort -nr
```

**Identifying inode-heavy directories:**
```bash
# Count files per directory
for dir in /*; do
    echo -n "$dir: "
    find "$dir" -type f 2>/dev/null | wc -l
done
```

#### Inode Exhaustion Prevention

**Key Points:**
- Monitor inode usage alongside disk space
- Many small files consume inodes faster than large files
- Log rotation and temporary file cleanup prevent inode exhaustion
- Consider inode-to-block ratio when creating filesystems
- Some filesystems (XFS, Btrfs) can allocate inodes dynamically

### Storage Performance Tools

Storage performance monitoring identifies bottlenecks and optimization opportunities through various specialized utilities.

#### iostat Command

The iostat utility reports CPU and I/O statistics for devices and partitions.

**Basic iostat usage:**
```bash
# Show current I/O statistics
iostat

# Continuous monitoring with 2-second intervals
iostat 2

# Extended device statistics
iostat -x 1 5
```

**Key iostat metrics:**
- `%user` - CPU time in user mode
- `%system` - CPU time in system mode
- `%iowait` - CPU time waiting for I/O
- `tps` - Transfers per second
- `kB_read/s` - Kilobytes read per second
- `kB_wrtn/s` - Kilobytes written per second
- `avgqu-sz` - Average queue size
- `await` - Average wait time (ms)
- `%util` - Device utilization percentage

#### iotop Command

The iotop utility displays real-time I/O usage by processes, similar to top for CPU usage.

**Basic iotop usage:**
```bash
# Real-time I/O monitoring
sudo iotop

# Show only processes doing I/O
sudo iotop -o

# Show accumulated I/O instead of bandwidth
sudo iotop -a
```

#### Additional Performance Tools

**lsof for open files:**
```bash
# Show processes with open files on specific filesystem
lsof +D /var

# Show files opened by specific process
lsof -p PID
```

**fuser for file usage:**
```bash
# Show processes using specific file or directory
fuser -v /var/log/messages
```

**hdparm for drive parameters:**
```bash
# Test read performance
sudo hdparm -t /dev/sda
sudo hdparm -T /dev/sda
```

### Capacity Planning

Effective capacity planning prevents storage-related outages and ensures optimal resource allocation through trend analysis and predictive monitoring.

#### Historical Usage Tracking

**Manual tracking methods:**
```bash
# Create daily usage snapshots
df -h > /var/log/disk-usage-$(date +%Y%m%d).log

# Weekly summary script
#!/bin/bash
echo "Weekly Disk Usage Report - $(date)"
df -h
echo "Largest directories:"
du -sh /var/* | sort -hr | head -5
```

#### Growth Rate Analysis

**Calculating growth trends:**
```bash
# Compare usage over time
diff <(df -h | head -1) <(cat /var/log/disk-usage-20240101.log | head -1)

# Simple growth calculation
# [Inference] This approach provides basic trend analysis but requires manual interpretation
current_usage=$(df --output=used /home | tail -1)
previous_usage=$(cat /var/log/usage-30days-ago.txt)
growth_rate=$(echo "scale=2; ($current_usage - $previous_usage) * 100 / $previous_usage" | bc)
```

#### Automated Monitoring Setup

**Cron-based monitoring:**
```bash
# Daily capacity check
0 6 * * * /usr/local/bin/check-disk-usage.sh

# Weekly growth analysis
0 7 * * 1 /usr/local/bin/weekly-storage-report.sh
```

**Threshold-based alerting:**
```bash
#!/bin/bash
THRESHOLD=85
df -h | awk 'NR>1 {
    usage = substr($5, 1, length($5)-1)
    if (usage > THRESHOLD) {
        print "WARNING: " $6 " is " usage "% full"
    }
}'
```

#### Predictive Planning Considerations

**Key Points:**
- [Inference] Growth rates vary seasonally and may not follow linear patterns
- Monitor both space and inode consumption trends
- Consider application lifecycle impacts on storage growth
- Plan for data retention policy changes
- Account for filesystem overhead and reserved space
- [Unverified] Typical enterprise environments see 15-25% annual storage growth

#### Capacity Planning Tools

**System-level monitoring:**
```bash
# Filesystem aging analysis
find / -type f -mtime +365 -exec ls -lh {} \; | awk '{sum+=$5} END {print "Old files: " sum/1024/1024 " MB"}'

# Large file identification
find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null
```

**Log analysis for trends:**
```bash
# Analyze log growth patterns
ls -la /var/log/*.log | awk '{print $5, $9}' | sort -nr
```

**Key Points:**
- Regular capacity assessments prevent emergency situations
- Automated alerting enables proactive response
- Historical data improves prediction accuracy
- Consider backup storage requirements in planning
- Plan for peak usage scenarios and data retention requirements

---

