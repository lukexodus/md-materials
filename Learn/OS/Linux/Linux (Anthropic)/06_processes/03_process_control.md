## Process Control


### Job Control

Job control in Linux allows users to manage multiple processes from a single terminal session, switching between foreground and background execution modes.

#### Understanding Jobs vs Processes

**Key points:**

- Jobs are shell-managed groupings of processes
- Each job has a job ID (displayed in brackets) and process ID(s)
- Jobs can be in foreground, background, stopped, or running states
- Only one job can be in foreground at a time per terminal

**Example** of job and process relationship:

```bash
# Start a long-running command
sleep 300 &
[1] 12345

# Check jobs and their process IDs
jobs -l
# [1]+ 12345 Running    sleep 300 &

# Compare with process listing
ps aux | grep sleep
# user 12345 ... sleep 300
```

#### Foreground and Background Execution

**Starting Jobs in Background:**

```bash
# Append & to run in background
find / -name "*.log" 2>/dev/null > search_results.txt &
[1] 12346

# Multiple background jobs
grep -r "error" /var/log/ > errors.txt &
[2] 12347
sort large_file.txt > sorted_file.txt &
[3] 12348

# Check all background jobs
jobs
# [1]   Running    find / -name "*.log" 2>/dev/null > search_results.txt &
# [2]-  Running    grep -r "error" /var/log/ > errors.txt &
# [3]+  Running    sort large_file.txt > sorted_file.txt &
```

**Moving Jobs Between Foreground and Background:**

```bash
# Start a job in foreground
top

# Suspend with Ctrl+Z
# [1]+ Stopped    top

# Resume in background
bg %1

# Bring specific job to foreground
fg %1

# Move current job to background (if running)
# Ctrl+Z to suspend, then bg to resume in background
```

#### Job Control Commands

**Jobs Command Options:**

```bash
# List all jobs
jobs

# List jobs with process IDs
jobs -l

# List only running jobs
jobs -r

# List only stopped jobs
jobs -s

# Show job command lines
jobs -p    # Process IDs only
```

**Job Reference Methods:**

```bash
# Reference by job number
fg %1      # Bring job 1 to foreground
bg %2      # Run job 2 in background

# Reference by command name
fg %top    # Bring job starting with "top"
fg %?log   # Bring job containing "log"

# Special references
fg %%      # Current job (same as fg)
fg %+      # Current job
fg %-      # Previous job
```

#### Advanced Job Control

**Job Control in Scripts:**

```bash
#!/bin/bash

# Function to monitor background jobs
monitor_jobs() {
    while [[ $(jobs -r | wc -l) -gt 0 ]]; do
        echo "Active jobs: $(jobs -r | wc -l)"
        sleep 2
    done
    echo "All background jobs completed"
}

# Start multiple background tasks
{
    echo "Task 1 starting"
    sleep 10
    echo "Task 1 completed"
} &

{
    echo "Task 2 starting"  
    sleep 15
    echo "Task 2 completed"
} &

{
    echo "Task 3 starting"
    sleep 8
    echo "Task 3 completed"
} &

# Monitor until completion
monitor_jobs

# Wait for all background jobs
wait
echo "All tasks finished"
```

**Disowning Jobs:**

```bash
# Start a job
long_running_process &
[1] 12349

# Disown the job (continues after logout)
disown %1

# Or disown all jobs
disown -a

# Check jobs (disowned job won't appear)
jobs
```

### Process Signals

Signals are software interrupts that provide a mechanism for process communication and control in Linux systems.

#### Common Signal Types

**Key points:**

- Signals are identified by numbers and names
- Some signals can be caught and handled by processes
- Others cannot be blocked or ignored (SIGKILL, SIGSTOP)
- Default actions vary by signal type

**Standard Signals:**

```bash
# View all available signals
kill -l
# Output shows signal numbers and names

# Most commonly used signals:
# SIGTERM (15) - Termination request (default kill)
# SIGKILL (9)  - Force kill (cannot be caught)
# SIGINT (2)   - Interrupt (Ctrl+C)
# SIGSTOP (19) - Stop process (cannot be caught)
# SIGCONT (18) - Continue stopped process
# SIGHUP (1)   - Hangup (often used for config reload)
# SIGUSR1 (10) - User-defined signal 1
# SIGUSR2 (12) - User-defined signal 2
```

#### Kill Command Usage

**Basic Kill Operations:**

```bash
# Send SIGTERM (graceful termination)
kill 12345
kill -15 12345    # Explicit signal number
kill -TERM 12345  # Signal name

# Force kill with SIGKILL
kill -9 12345
kill -KILL 12345

# Send signal to multiple processes
kill -TERM 12345 12346 12347

# Kill by job number
kill %1
kill -9 %2
```

**Advanced Kill Usage:**

```bash
# Send custom signals
kill -USR1 12345    # Send SIGUSR1
kill -HUP 12345     # Send SIGHUP (common for config reload)

# Kill process and all children
kill -TERM -12345   # Negative PID kills process group

# Conditional killing
if pgrep -x "problematic_process" > /dev/null; then
    echo "Killing problematic process"
    pkill -TERM problematic_process
    sleep 5
    pkill -KILL problematic_process 2>/dev/null || true
fi
```

#### Killall and Related Commands

**Killall Command:**

```bash
# Kill all processes by name
killall firefox
killall -9 chrome

# Kill with specific signal
killall -USR1 nginx    # Reload nginx configuration
killall -HUP rsyslog   # Reload rsyslog

# Interactive killing
killall -i firefox    # Ask before killing each process

# Kill processes older than specified time
killall -o 1h firefox  # Kill firefox processes older than 1 hour

# Quiet mode (no error if process not found)
killall -q nonexistent_process
```

**Pkill and Pgrep:**

```bash
# More flexible process matching
pkill -f "python.*script.py"    # Kill by command line pattern
pkill -u username firefox       # Kill user's firefox processes
pkill -g processgroup          # Kill by process group

# Find processes before killing
pgrep -l firefox               # List firefox processes
pgrep -u root                  # Find root's processes
pgrep -f "java.*tomcat"        # Find by command line pattern

# Combined operations
if pgrep -x "apache2" > /dev/null; then
    echo "Apache running, reloading configuration"
    pkill -HUP apache2
else
    echo "Apache not running, starting service"
    systemctl start apache2
fi
```

### Signal Types and Handling

Understanding how different signals behave and how processes can handle them is crucial for effective process control.

#### Signal Categories

**Catchable Signals (can be handled by process):**

```bash
# Demonstration of signal handling
cat > signal_demo.sh << 'EOF'
#!/bin/bash

# Signal handler function
cleanup() {
    echo "Received signal, cleaning up..."
    rm -f /tmp/demo_*
    exit 0
}

# Set signal handlers
trap cleanup SIGTERM SIGINT SIGHUP

echo "Process started (PID: $$)"
echo "Send signals: kill -TERM $$, kill -INT $$, kill -HUP $$"

# Create temporary files
touch /tmp/demo_file1 /tmp/demo_file2

# Main loop
while true; do
    echo "Working... $(date)"
    sleep 2
done
EOF

chmod +x signal_demo.sh
./signal_demo.sh &
```

**Uncatchable Signals:**

```bash
# SIGKILL (9) - Cannot be caught, blocked, or ignored
# SIGSTOP (19) - Cannot be caught, blocked, or ignored

# Example: Process that cannot be killed gracefully
cat > unkillable_demo.sh << 'EOF'
#!/bin/bash

# Ignore most signals (except SIGKILL and SIGSTOP)
trap '' SIGTERM SIGINT SIGHUP SIGQUIT

echo "Process started (PID: $$)"
echo "Try: kill -TERM $$  (will be ignored)"
echo "Try: kill -KILL $$  (will work)"

while true; do
    echo "Still running... $(date)"
    sleep 3
done
EOF
```

#### Signal Handling in Scripts

**Robust Signal Handling:**

```bash
#!/bin/bash

# Global variables for cleanup
TEMP_DIR=""
CHILD_PIDS=()

# Comprehensive cleanup function
cleanup_and_exit() {
    local signal_received=$1
    echo "Received signal: $signal_received"
    
    # Kill child processes
    for pid in "${CHILD_PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            echo "Killing child process: $pid"
            kill -TERM "$pid" 2>/dev/null
        fi
    done
    
    # Wait for children to exit
    sleep 2
    for pid in "${CHILD_PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            echo "Force killing child process: $pid"
            kill -KILL "$pid" 2>/dev/null
        fi
    done
    
    # Clean temporary files
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        echo "Cleaning temporary directory: $TEMP_DIR"
        rm -rf "$TEMP_DIR"
    fi
    
    echo "Cleanup completed, exiting"
    exit 0
}

# Set up signal handlers
trap 'cleanup_and_exit SIGTERM' SIGTERM
trap 'cleanup_and_exit SIGINT' SIGINT
trap 'cleanup_and_exit SIGHUP' SIGHUP

# Create temporary workspace
TEMP_DIR=$(mktemp -d /tmp/script_XXXXXX)
echo "Using temporary directory: $TEMP_DIR"

# Start background tasks
{
    while true; do
        echo "Background task 1: $(date)" >> "$TEMP_DIR/task1.log"
        sleep 5
    done
} &
CHILD_PIDS+=($!)

{
    while true; do
        echo "Background task 2: $(date)" >> "$TEMP_DIR/task2.log"
        sleep 3
    done
} &
CHILD_PIDS+=($!)

echo "Main script running (PID: $$)"
echo "Child processes: ${CHILD_PIDS[*]}"
echo "Send SIGTERM, SIGINT, or SIGHUP to test cleanup"

# Main work loop
while true; do
    echo "Main process working: $(date)"
    sleep 2
done
```

#### Signal-based Inter-Process Communication

**Example** of signal-based coordination:

```bash
#!/bin/bash

# Parent process that coordinates children via signals
coordinate_processes() {
    local worker_pids=()
    
    # Worker function
    worker() {
        local worker_id=$1
        local status_file="/tmp/worker_${worker_id}_status"
        
        # Signal handlers for worker
        handle_pause() {
            echo "Worker $worker_id paused" > "$status_file"
            while kill -0 $$ 2>/dev/null; do
                sleep 1
            done
        }
        
        handle_resume() {
            echo "Worker $worker_id resumed" > "$status_file"
        }
        
        trap handle_pause SIGUSR1
        trap handle_resume SIGUSR2
        
        # Worker main loop
        while true; do
            echo "Worker $worker_id working: $(date)" >> "/tmp/worker_${worker_id}.log"
            sleep 2
        done
    }
    
    # Start worker processes
    for i in {1..3}; do
        worker $i &
        worker_pids+=($!)
        echo "Started worker $i (PID: ${worker_pids[-1]})"
    done
    
    # Control workers
    echo "Pausing all workers in 5 seconds..."
    sleep 5
    for pid in "${worker_pids[@]}"; do
        kill -USR1 "$pid"
    done
    
    echo "Resuming all workers in 10 seconds..."
    sleep 10
    for pid in "${worker_pids[@]}"; do
        kill -USR2 "$pid"
    done
    
    # Let workers run for a bit
    sleep 15
    
    # Cleanup
    for pid in "${worker_pids[@]}"; do
        kill -TERM "$pid"
    done
    
    wait
    rm -f /tmp/worker_*
}

coordinate_processes
```

### Orphan and Zombie Processes

Understanding and managing orphan and zombie processes is essential for maintaining system health and preventing resource leaks.

#### Orphan Processes

Orphan processes occur when a parent process terminates before its child processes, leaving the children without a parent.

**Key points:**

- Orphan processes are adopted by init (PID 1) or systemd
- They continue running normally under their new parent
- Not inherently problematic but may indicate design issues
- Can be intentional (daemon processes)

**Example** creating orphan processes:

```bash
#!/bin/bash

# Script that creates orphan processes
create_orphan() {
    echo "Parent process PID: $$"
    
    # Start child process
    {
        echo "Child started, PID: $$, Parent: $PPID"
        sleep 5
        echo "Child after parent exit, PID: $$, Parent: $PPID"
        sleep 10
        echo "Child finishing, PID: $$, Parent: $PPID"
    } &
    
    local child_pid=$!
    echo "Child PID: $child_pid"
    
    # Parent exits quickly, leaving child orphaned
    echo "Parent exiting, child will be orphaned"
    exit 0
}

create_orphan
```

**Monitoring Orphan Processes:**

```bash
# Find processes with PPID 1 (adopted by init)
ps -eo pid,ppid,cmd | awk '$2 == 1 && $1 != 1 {print}'

# More detailed orphan process information
ps -eo pid,ppid,uid,cmd --no-headers | while read pid ppid uid cmd; do
    if [[ $ppid -eq 1 && $pid -ne 1 ]]; then
        echo "Orphan: PID=$pid, UID=$uid, CMD=$cmd"
    fi
done
```

#### Zombie Processes

Zombie processes are dead processes that have completed execution but still have entries in the process table because their parent hasn't read their exit status.

**Key points:**

- Also called "defunct" processes
- Consume minimal resources (just process table entry)
- Indicated by 'Z' or '\<defunct>' in process listings
- Resolved when parent reads exit status via wait()
- Accumulation can exhaust process table

**Example** creating zombie processes:

```bash
#!/bin/bash

# Script that creates zombie processes (poor practice demonstration)
create_zombies() {
    echo "Creating zombie processes (PID: $$)"
    
    for i in {1..5}; do
        {
            echo "Child $i (PID: $$) starting"
            sleep 2
            echo "Child $i (PID: $$) exiting"
            exit $i
        } &
        echo "Started child $i"
    done
    
    echo "Parent will NOT wait for children (creates zombies)"
    echo "Check with: ps aux | grep defunct"
    
    # Parent continues without waiting
    sleep 20
    echo "Parent exiting without waiting for children"
}

# Better version that properly waits for children
create_no_zombies() {
    echo "Creating processes with proper cleanup (PID: $$)"
    local child_pids=()
    
    for i in {1..5}; do
        {
            echo "Child $i (PID: $$) starting"
            sleep 2
            echo "Child $i (PID: $$) exiting"
            exit $i
        } &
        child_pids+=($!)
        echo "Started child $i (PID: ${child_pids[-1]})"
    done
    
    echo "Parent waiting for all children"
    for pid in "${child_pids[@]}"; do
        wait "$pid"
        echo "Child $pid completed with exit code $?"
    done
    
    echo "All children completed, no zombies created"
}

# Uncomment to test:
# create_zombies    # Creates zombies
# create_no_zombies # Proper cleanup
```

#### Zombie Process Detection and Cleanup

**Detection Methods:**

```bash
# Find zombie processes
ps aux | grep -E '\s+Z\s+|\sdefunct'

# Count zombie processes
ps aux | awk '$8 ~ /^Z/ { count++ } END { print "Zombie processes:", count+0 }'

# Detailed zombie information
ps -eo pid,ppid,state,comm | awk '$3 == "Z" {
    print "Zombie PID:", $1, "Parent PID:", $2, "Command:", $4
}'

# Check if specific process has zombie children
check_zombie_children() {
    local parent_pid=$1
    local zombie_count
    
    zombie_count=$(ps --ppid "$parent_pid" -o state --no-headers | grep -c Z)
    
    if [[ $zombie_count -gt 0 ]]; then
        echo "Process $parent_pid has $zombie_count zombie children"
        ps --ppid "$parent_pid" -o pid,state,comm
    else
        echo "Process $parent_pid has no zombie children"
    fi
}
```

**Zombie Prevention Strategies:**

```bash
#!/bin/bash

# Strategy 1: Explicit wait for all children
wait_for_all_children() {
    local child_pids=()
    
    # Start background jobs
    for task in task1 task2 task3; do
        {
            echo "Executing $task"
            sleep $((RANDOM % 10 + 1))
            echo "$task completed"
        } &
        child_pids+=($!)
    done
    
    # Wait for all children
    for pid in "${child_pids[@]}"; do
        wait "$pid"
    done
}

# Strategy 2: Signal handler for child reaping
setup_child_reaper() {
    # Signal handler to reap dead children
    reap_children() {
        local pid
        local status
        
        while true; do
            pid=$(wait -n 2>/dev/null)
            status=$?
            
            if [[ $status -eq 127 ]]; then
                # No more children
                break
            fi
            
            echo "Reaped child process $pid with exit status $status"
        done
    }
    
    # Set up SIGCHLD handler (when children die)
    trap reap_children SIGCHLD
}

# Strategy 3: Non-blocking wait in loop
monitor_and_reap() {
    while [[ $(jobs -r | wc -l) -gt 0 ]]; do
        # Check for completed jobs without blocking
        wait -n
        local exit_code=$?
        
        if [[ $exit_code -ne 127 ]]; then
            echo "A child process completed with exit code $exit_code"
        fi
        
        sleep 1
    done
}
```

#### System-wide Zombie Management

**System Monitoring Script:**

```bash
#!/bin/bash

# Comprehensive zombie monitoring and alerting
zombie_monitor() {
    local threshold=${1:-10}  # Alert if more than 10 zombies
    local log_file="/var/log/zombie_monitor.log"
    
    while true; do
        local zombie_count
        local timestamp
        
        zombie_count=$(ps aux | awk '$8 ~ /^Z/ { count++ } END { print count+0 }')
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        
        echo "[$timestamp] Zombie count: $zombie_count" >> "$log_file"
        
        if [[ $zombie_count -gt $threshold ]]; then
            echo "[$timestamp] WARNING: High zombie count ($zombie_count)" >> "$log_file"
            
            # Log details of zombie processes
            echo "[$timestamp] Zombie details:" >> "$log_file"
            ps -eo pid,ppid,state,comm | awk '$3 == "Z"' >> "$log_file"
            
            # Optional: Send alert (uncomment as needed)
            # echo "High zombie count: $zombie_count" | mail -s "Zombie Alert" admin@example.com
        fi
        
        sleep 60  # Check every minute
    done
}

# System cleanup function
cleanup_zombies() {
    echo "Scanning for zombie processes..."
    
    # Find zombie processes and their parents
    ps -eo pid,ppid,state,comm | awk '$3 == "Z" {
        print "Zombie PID:", $1, "Parent PID:", $2, "Command:", $4
        system("ps -p " $2 " -o pid,comm --no-headers")
    }'
    
    echo
    echo "Note: Zombies are cleaned up when parent processes exit"
    echo "or when parents properly wait() for their children."
    echo "Consider restarting problematic parent processes."
}

# Usage examples:
# zombie_monitor 5      # Monitor with threshold of 5
# cleanup_zombies       # Show current zombie status
```

**Conclusion:** Effective process control requires understanding job management, signal handling, and proper process lifecycle management. Preventing zombie processes and handling orphaned processes correctly ensures system stability and resource efficiency.

**Next steps:** Explore advanced process management with cgroups, systemd service management, process monitoring tools like htop/atop, and container process isolation mechanisms.

---

