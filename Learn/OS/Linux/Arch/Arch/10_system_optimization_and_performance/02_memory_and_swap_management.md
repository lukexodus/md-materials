## Memory and Swap Management


### Memory Overview

**RAM Usage**: Processes and kernel use system memory.[1]

**Types**:[1]
- **Physical RAM**: Installed memory[1]
- **Swap**: Disk-based virtual memory[1]
- **Cache**: Kernel filesystem cache[1]
- **Buffers**: Data in transit[1]

**Monitoring**: Track usage to optimize performance.[1]

### Memory Usage Monitoring

#### free Command

**Display Memory**:[1]

```bash
free -h
```

**Output Example**:[1]

```
              total        used        free      shared  buff/cache
Mem:           15Gi       8.5Gi       2.3Gi      512Mi       4.2Gi
Swap:           8Gi       1.2Gi       6.8Gi
```

**Interpretation**:[1]
- `total`: Total RAM[1]
- `used`: Currently used[1]
- `free`: Unallocated[1]
- `buff/cache`: Kernel cache (freeable)[1]

#### top and htop

**Real-time Monitoring**:[1]

```bash
top
```

**Interactive Commands**:[1]
- `M`: Sort by memory[1]
- `P`: Sort by CPU[1]
- `q`: Quit[1]

**Enhanced Version**:[1]

```bash
htop
```

#### ps Memory Usage

**Per-Process Memory**:[1]

```bash
ps aux --sort=-%mem | head -10
```

**Shows**: Top memory-consuming processes.[1]

**Detailed Information**:[1]

```bash
ps -eo pid,user,%mem,comm --sort=-%mem
```

#### systemd-cgtop

**Service Memory** :

```bash
systemd-cgtop
```

**Shows**: Memory usage by service/cgroup .

#### Detailed /proc Analysis

**Memory Info**:[1]

```bash
cat /proc/meminfo
```

**Output**:[1]

```
MemTotal:        16384 kB
MemFree:         2048 kB
MemAvailable:    6144 kB
Buffers:         512 kB
Cached:          3072 kB
SwapTotal:       8192 kB
SwapFree:        6144 kB
```

### Swap Fundamentals

#### Purpose

**Virtual Memory**: Disk storage for memory overflow.[1]

**When Used**:[1]
- Physical RAM exhausted[1]
- Less frequently accessed data[1]
- Emergency overflow[1]

**Performance**: Swap is much slower than RAM.[1]

#### Swap Space

**Current Usage**:[1]

```bash
swapon --show
```

**Output Example**:[1]

```
NAME      TYPE  SIZE USED PRIO
/swapfile file  8G  1.2G   -2
```

#### Swap Pressure

**Monitor Pressure**:[1]

```bash
cat /proc/pressure/memory
```

**Output**:[1]

```
some avg10=5.00 avg60=3.20 avg300=1.50 total=12345
full avg10=2.00 avg60=1.20 avg300=0.50 total=6789
```

### Creating Swap

#### Swap File

**Create File**:[1]

```bash
sudo fallocate -l 4G /swapfile
```

or

```bash
sudo dd if=/dev/zero of=/swapfile bs=1M count=4096
```

**Set Permissions**:[1]

```bash
sudo chmod 600 /swapfile
```

**Format as Swap**:[1]

```bash
sudo mkswap /swapfile
```

**Enable Swap**:[1]

```bash
sudo swapon /swapfile
```

#### Persistent Swap

**Add to fstab**:[1]

```bash
echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
```

**Verify**:[1]

```bash
swapon --show
```

#### Swap Partition

**Create Partition** :

```bash
# Use fdisk or gdisk to create partition
sudo fdisk /dev/sda
# Type t, select partition, type 82 (swap)
# Type w to write
```

**Format as Swap** :

```bash
sudo mkswap /dev/sdX#
```

**Enable** :

```bash
sudo swapon /dev/sdX#
```

**Persist in fstab** :

```bash
echo "/dev/sdX# none swap sw 0 0" | sudo tee -a /etc/fstab
```

#### Remove Swap

**Disable**:[1]

```bash
sudo swapoff /swapfile
```

**Remove File**:[1]

```bash
sudo rm /swapfile
```

**Remove from fstab**:[1]

```bash
sudo nano /etc/fstab
# Delete swap line
```

### Swap Optimization

#### Swappiness

**Parameter**: Controls how aggressively kernel uses swap.[1]

**Range**: 0-100.[1]

**Values**:[1]
- `0`: Avoid swap, use only RAM[1]
- `60` (default): Moderate[1]
- `100`: Aggressive swap usage[1]

**Current Setting**:[1]

```bash
cat /proc/sys/vm/swappiness
```

**Adjust Swappiness**:[1]

```bash
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.d/99-swappiness.conf
sudo sysctl -p
```

#### For Desktop Systems

**Recommended**: 10-20.[1]

**Config**:[1]

```
vm.swappiness=10
```

**Benefit**: Prefers RAM, swap only when necessary.[1]

#### For Server Systems

**Recommended**: 60-100.[1]

**Rationale**: Allows overcommitment for resource utilization.[1]

#### Memory Pressure

**High RAM Systems**:[1]

```
vm.swappiness=1
```

Almost never swap.[1]

**Limited RAM**:[1]

```
vm.swappiness=50
```

Balanced approach.[1]

### Memory Caching

#### Page Cache

**Purpose**: Kernel caches filesystem data in RAM.[1]

**Automatic**: Kernel manages transparently.[1]

**Monitor**:[1]

```bash
cat /proc/meminfo | grep -i cache
```

**Reclaim Cache** (Emergency):[1]

```bash
sync  # Flush buffers
echo 3 | sudo tee /proc/sys/vm/drop_caches
```

**Caution**: Only in emergencies.[1]

#### Buffer Tuning

**Dirty Ratio**: Percentage of RAM with dirty [1]

```bash
cat /proc/sys/vm/dirty_ratio
```

**Adjust**:[1]

```bash
echo "vm.dirty_ratio = 10" | sudo tee -a /etc/sysctl.d/99-memory.conf
```

**Writeback**:[1]

```bash
echo "vm.dirty_writeback_centisecs = 500" | sudo tee -a /etc/sysctl.d/99-memory.conf
```

### Out of Memory (OOM) Handling

#### OOM Killer

**Purpose**: Selects processes to kill when memory exhausted.[1]

**Kernel Decision**: Based on memory usage and priority.[1]

**Avoid**: Proper resource allocation.[1]

#### OOM Configuration

**Check OOM Behavior**:[1]

```bash
cat /proc/sys/vm/panic_on_oom
```

**Panic on OOM**:[1]

```
vm.panic_on_oom = 0  # Kill process (default)
vm.panic_on_oom = 1  # Panic system
```

**OOM Score**: Process-level adjustment:[1]

```bash
ps aux | grep process
cat /proc/PID/oom_score
```

**Adjust Score**:[1]

```bash
echo -999 | sudo tee /proc/PID/oom_score_adj
```

Negative values make process less likely to be killed.[1]

### Memory Leak Detection

#### Identify Leaks

**Growing Memory**:[1]

```bash
watch -n 1 'ps aux | grep process_name'
```

Monitor process memory over time.[1]

#### valgrind Tool

**Installation**: `sudo pacman -S valgrind`.[1]

**Check Application**:[1]

```bash
valgrind --leak-check=full ./application
```

**Output**: Detailed memory leak report.[1]

### NUMA (Non-Uniform Memory Access)

#### Check NUMA Configuration

**NUMA Nodes**:[1]

```bash
lscpu | grep -i numa
numactl --hardware
```

#### Optimize for NUMA

**Bind Process to Node**:[1]

```bash
numactl --cpunodebind=0 --membind=0 command
```

**Verify**: Application uses local memory.[1]

### Memory Limits

#### Per-User Limits

**Check Limits**:[1]

```bash
ulimit -a
```

**Set Limit**:[1]

```bash
ulimit -v 2000000  # 2GB virtual memory
```

#### systemd Service Limits

**Memory Limit**: `/etc/systemd/system/service.conf` :

```ini
[Service]
MemoryMax=1G
MemoryLimit=512M
```

**Reload**: `sudo systemctl daemon-reload` .

### Transparent Huge Pages

#### Purpose

**Performance**: Larger memory pages reduce TLB misses.[1]

**Check Status**:[1]

```bash
cat /sys/kernel/mm/transparent_hugepage/enabled
```

#### Disable if Causing Issues

**Temporary**:[1]

```bash
echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
```

**Persistent**: `/etc/sysctl.d/99-hugepages.conf`:[1]

```
vm.transparent_hugepage = never
```

### Memory Best Practices

**Monitor Regularly**: Check memory usage patterns.[1]

**Optimize Swappiness**: Match system profile.[1]

**Avoid OOM**: Size swap appropriately.[1]

**Profile Applications**: Identify memory hogs.[1]

**Use Appropriate Tools**: systemd-cgtop for services, top for processes .

**Increase Swap**: If frequent swapping.[1]

**Check for Leaks**: Investigate growing memory usage.[1]

**Document Tuning**: Record changes and impacts.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman

