## Process Monitoring in Linux


### Real-time Monitoring Tools

#### top Command

The `top` command provides real-time system and process information, displaying running processes sorted by CPU usage by default.

```bash
# Basic top usage
top

# Key interactive commands within top:
# q - quit
# k - kill process (prompts for PID)
# r - renice process (change priority)
# f - select display fields
# o - change sort order
# 1 - toggle individual CPU cores display
# m - toggle memory display format
# t - toggle task/CPU information display
```

**top display interpretation:**

```
top - 14:23:45 up 2 days, 3:15, 2 users, load average: 1.25, 1.10, 0.95
Tasks: 245 total, 2 running, 243 sleeping, 0 stopped, 0 zombie
%Cpu(s): 12.5 us, 3.2 sy, 0.0 ni, 84.1 id, 0.2 wa, 0.0 hi, 0.0 si, 0.0 st
MiB Mem: 8192.0 total, 2048.5 free, 4096.2 used, 2047.3 buff/cache
MiB Swap: 2048.0 total, 1024.0 free, 1024.0 used. 3584.1 avail Mem

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
 1234 user      20   0  1234567  98765  12345 R  25.0   1.2   2:34.56 process_name
```

**top command options:**

```bash
# Update interval (seconds)
top -d 5

# Show specific user processes
top -u username

# Batch mode (non-interactive)
top -b -n 1

# Show process tree
top -c

# Limit number of processes displayed
top -n 10

# Sort by memory usage
top -o %MEM
```

#### htop Command

[Unverified] `htop` is an enhanced version of `top` with improved user interface and additional features:

```bash
# Install htop (varies by distribution)
sudo apt install htop    # Debian/Ubuntu
sudo yum install htop    # RHEL/CentOS
sudo dnf install htop    # Fedora

# Run htop
htop

# htop interactive keys:
# F1 - Help
# F2 - Setup (configuration)
# F3 - Search processes
# F4 - Filter processes
# F5 - Tree view
# F6 - Sort by column
# F9 - Kill process
# F10 - Quit
```

**htop advantages over top:**

- Color-coded display
- Mouse support
- Horizontal and vertical scrolling
- Tree view of processes
- Built-in process filtering and searching

#### Other Real-time Monitoring Tools

```bash
# atop - Advanced system monitor
atop -a    # Show all processes
atop 5     # 5-second intervals

# iotop - I/O monitoring (requires root)
sudo iotop

# nethogs - Network usage by process
sudo nethogs

# glances - Cross-platform monitoring
glances
```

### Process Searching and Identification

#### pgrep Command

`pgrep` searches for processes by name and returns process IDs:

```bash
# Find processes by name
pgrep firefox
pgrep -f "python script.py"    # Search full command line

# Find processes by user
pgrep -u username
pgrep -u root

# Find processes by parent PID
pgrep -P 1234

# Show process names with PIDs
pgrep -l firefox
pgrep -a firefox    # Show full command line

# Count matching processes
pgrep -c firefox

# Find newest/oldest process
pgrep -n firefox    # Newest
pgrep -o firefox    # Oldest
```

#### pidof Command

`pidof` finds process IDs by program name:

```bash
# Find PID of running program
pidof firefox
pidof httpd

# Find all instances
pidof -x script_name

# Single PID only (if multiple instances)
pidof -s firefox

# Omit processes with specific PID
pidof -o 1234 firefox
```

#### ps Command for Process Searching

```bash
# Find processes by name
ps aux | grep firefox
ps -ef | grep python

# Show process tree
ps auxf
ps -ejH

# Custom format output
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu

# Show threads
ps -eLf

# Show processes for specific user
ps -u username
```

#### pkill and killall

```bash
# Kill processes by name
pkill firefox
pkill -f "python script.py"

# Kill processes by user
pkill -u username

# Send specific signal
pkill -TERM firefox
pkill -9 firefox    # Force kill

# killall (kill by process name)
killall firefox
killall -9 firefox
```

### Resource Usage Analysis

#### CPU Usage Monitoring

```bash
# Real-time CPU usage
top -p PID
htop -p PID

# CPU usage over time
sar -u 1 10    # 10 samples, 1-second intervals

# Per-CPU statistics
mpstat 1 5     # 5 samples, 1-second intervals
mpstat -P ALL  # All CPU cores

# Process CPU usage history
pidstat -p PID 1 5
```

#### Memory Usage Analysis

```bash
# System memory overview
free -h
free -m -s 5    # Update every 5 seconds

# Detailed memory information
cat /proc/meminfo

# Process memory usage
ps aux --sort=-%mem | head -10
pmap PID        # Memory map of process
smem -p         # Memory usage by process (if available)

# Memory usage over time
sar -r 1 10     # 10 samples of memory statistics
vmstat 1 5      # Virtual memory statistics
```

#### Disk I/O Monitoring

```bash
# System I/O statistics
iostat -x 1 5   # Extended I/O stats, 5 samples

# Process I/O usage
iotop -p PID
pidstat -d 1 5  # Disk I/O statistics

# Disk usage by process
lsof +D /path/to/directory

# I/O wait analysis
sar -d 1 10     # Disk activity
```

#### Network Usage Monitoring

```bash
# Network interface statistics
sar -n DEV 1 5
ifstat 1 5

# Network connections by process
ss -tulpn
netstat -tulpn

# Network usage by process
nethogs eth0
iftop -i eth0
```

### Load Average Interpretation

#### Understanding Load Average

Load average represents the average system load over 1, 5, and 15-minute periods. It indicates how many processes are either running or waiting for resources.

```bash
# View load average
uptime
cat /proc/loadavg
w

# Example output interpretation:
# load average: 1.25, 1.10, 0.95
# 1-minute: 1.25 (current load)
# 5-minute: 1.10 (recent trend)  
# 15-minute: 0.95 (long-term trend)
```

#### Load Average Guidelines

**For single-core systems:**

- 0.00-0.70: Excellent performance
- 0.70-1.00: Good performance, no delays
- 1.00-1.70: Fair performance, some delays
- 1.70-5.00: Poor performance, long delays
- 5.00+: Very poor performance, system overloaded

**For multi-core systems:** Multiply the single-core values by the number of CPU cores:

```bash
# Check number of CPU cores
nproc
cat /proc/cpuinfo | grep processor | wc -l

# For 4-core system:
# 0.00-2.80: Excellent (4 × 0.70)
# 2.80-4.00: Good (4 × 1.00)
# 4.00-6.80: Fair (4 × 1.70)
```

#### Load Average Monitoring

```bash
# Continuous load monitoring
watch -n 1 'cat /proc/loadavg'
watch -n 1 'uptime'

# Historical load data
sar -q 1 10     # Load average and run queue
uprecords       # System uptime records (if available)

# Load average with process count
while true; do
    echo "$(date): $(cat /proc/loadavg) - Processes: $(ps aux | wc -l)"
    sleep 60
done
```

### Advanced Process Monitoring

#### Process States and Analysis

```bash
# Process states explanation:
# R - Running or runnable
# S - Interruptible sleep (waiting for event)
# D - Uninterruptible sleep (usually I/O)
# T - Stopped or traced
# Z - Zombie (terminated but not reaped)

# Count processes by state
ps axo state --no-headers | sort | uniq -c

# Find zombie processes
ps aux | awk '$8 ~ /^Z/ { print $2 }'

# Find processes in uninterruptible sleep
ps aux | awk '$8 ~ /^D/ { print $2, $11 }'
```

#### Process Priority and Nice Values

```bash
# View process priorities
ps axo pid,ni,pri,cmd

# Change process priority
nice -n 10 command          # Start with lower priority
renice 5 PID               # Change running process priority
renice -5 -u username      # Change all user processes

# Priority ranges:
# -20 (highest priority) to +19 (lowest priority)
# Default nice value: 0
```

#### Process Resource Limits

```bash
# View process limits
cat /proc/PID/limits
prlimit --pid PID

# Set resource limits
ulimit -a              # View all limits
ulimit -n 4096        # Set file descriptor limit
ulimit -u 1000        # Set process limit
ulimit -v 1048576     # Set virtual memory limit (KB)

# Permanent limits (in /etc/security/limits.conf)
username soft nofile 4096
username hard nofile 8192
```

### Monitoring Scripts and Automation

#### Process Monitoring Script

```bash
#!/bin/bash
monitor_process() {
    local process_name="$1"
    local threshold_cpu=80
    local threshold_mem=80
    
    while true; do
        # Get process information
        pid=$(pgrep -n "$process_name")
        
        if [ -z "$pid" ]; then
            echo "$(date): Process $process_name not found"
            sleep 30
            continue
        fi
        
        # Get CPU and memory usage
        cpu_usage=$(ps -p "$pid" -o %cpu --no-headers | tr -d ' ')
        mem_usage=$(ps -p "$pid" -o %mem --no-headers | tr -d ' ')
        
        # Check thresholds
        if (( $(echo "$cpu_usage > $threshold_cpu" | bc -l) )); then
            echo "$(date): High CPU usage: $cpu_usage% for $process_name (PID: $pid)"
        fi
        
        if (( $(echo "$mem_usage > $threshold_mem" | bc -l) )); then
            echo "$(date): High memory usage: $mem_usage% for $process_name (PID: $pid)"
        fi
        
        sleep 60
    done
}
```

#### System Load Monitoring

```bash
#!/bin/bash
monitor_load() {
    local cpu_cores=$(nproc)
    local load_threshold=$(echo "$cpu_cores * 1.5" | bc)
    
    while read -r load_1min load_5min load_15min running_processes last_pid; do
        current_load=$load_1min
        
        if (( $(echo "$current_load > $load_threshold" | bc -l) )); then
            echo "$(date): High load average: $current_load (threshold: $load_threshold)"
            echo "Top CPU consumers:"
            ps aux --sort=-%cpu | head -6
            echo "---"
        fi
        
        sleep 300  # Check every 5 minutes
    done < <(while true; do cat /proc/loadavav; sleep 300; done)
}
```

**Key Points:**

- Load average interpretation depends on CPU core count
- Consistent high load indicates system resource constraints
- Process states help identify system bottlenecks
- Real-time monitoring tools provide immediate system insights
- Historical monitoring data helps identify trends and patterns

**Example** comprehensive monitoring command:

```bash
# Multi-pane monitoring setup
# Terminal 1: Real-time process monitoring
htop

# Terminal 2: I/O monitoring  
sudo iotop -ao

# Terminal 3: Network monitoring
sudo nethogs

# Terminal 4: System statistics
watch -n 2 'echo "=== Load Average ===" && uptime && echo && echo "=== Memory ===" && free -h && echo && echo "=== Disk I/O ===" && iostat -x 1 1'
```

Process monitoring combines real-time observation tools with historical analysis to maintain system performance, identify bottlenecks, and ensure optimal resource utilization across CPU, memory, disk, and network subsystems.

---

