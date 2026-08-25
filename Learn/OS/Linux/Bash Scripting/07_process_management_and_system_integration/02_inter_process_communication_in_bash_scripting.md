## Inter-Process Communication in Bash Scripting


### Pipes and Command Substitution

Pipes and command substitution are fundamental mechanisms for enabling communication between processes in bash. These tools allow processes to share data, coordinate operations, and build complex data processing pipelines.

#### Named and Anonymous Pipes

Anonymous pipes (|) create temporary communication channels between processes, where the output of one process becomes the input of another. Named pipes (FIFOs) provide persistent communication channels that exist in the filesystem and can be accessed by multiple processes independently.

**Key points:**

- Anonymous pipes are created automatically and destroyed when processes terminate
- Named pipes must be explicitly created with mkfifo command
- Pipes provide unidirectional communication channels
- Data flows through pipes in first-in-first-out order
- Processes can block when reading from empty pipes or writing to full pipes

**Example:**

```bash
# Anonymous pipe for data processing
ps aux | grep nginx | awk '{print $2}' | xargs kill -HUP

# Named pipe for inter-process communication
mkfifo /tmp/data_pipe
# Producer process
echo "Processing data..." > /tmp/data_pipe &
# Consumer process
while read line; do
    echo "Received: $line"
done < /tmp/data_pipe
```

#### Bidirectional Communication

Bidirectional communication requires two pipes or more sophisticated mechanisms. Named pipes can be used to establish bidirectional channels, while process substitution enables complex data flow patterns.

**Example:**

```bash
# Bidirectional named pipe communication
mkfifo /tmp/request_pipe /tmp/response_pipe

# Server process
{
    while true; do
        read request < /tmp/request_pipe
        echo "Processing: $request"
        echo "Response to: $request" > /tmp/response_pipe
    done
} &

# Client process
echo "Hello Server" > /tmp/request_pipe
read response < /tmp/response_pipe
echo "Server responded: $response"
```

#### Process Substitution

Process substitution (<() and >()) creates temporary named pipes that can be used as filenames in commands. This enables complex data flow patterns and allows processes to communicate through multiple channels simultaneously.

**Example:**

```bash
# Compare output of two processes
diff <(sort file1.txt) <(sort file2.txt)

# Multiple input streams
paste <(cut -d',' -f1 data.csv) <(cut -d',' -f3 data.csv) > combined.txt

# Tee with process substitution
echo "data" | tee >(grep pattern > matches.txt) >(wc -l > count.txt)
```

#### Command Substitution Techniques

Command substitution captures the output of commands and uses it as input for other operations. Both backticks and $() syntax are supported, with $() being preferred for its better nesting capabilities and readability.

**Example:**

```bash
# Basic command substitution
current_date=$(date +%Y-%m-%d)
log_file="/var/log/app_${current_date}.log"

# Nested command substitution
total_size=$(du -sh $(find /var/log -name "*.log" -mtime -7) | awk '{sum += $1} END {print sum}')

# Complex data processing with substitution
user_count=$(ps aux | grep -v grep | grep $(whoami) | wc -l)
echo "User $(whoami) has $user_count processes running"
```

### Temporary Files for Data Exchange

Temporary files provide a mechanism for processes to exchange data through the filesystem. This approach is particularly useful for large datasets, persistent communication, or when processes need to access shared data multiple times.

#### Secure Temporary File Creation

Creating secure temporary files prevents race conditions and unauthorized access. The mktemp command generates unique filenames and sets appropriate permissions to ensure file security.

**Key points:**

- Use mktemp to create secure temporary files and directories
- Set appropriate permissions and ownership
- Clean up temporary files when processes terminate
- Consider using traps to ensure cleanup on script exit
- Use unique naming conventions to prevent conflicts

**Example:**

```bash
# Secure temporary file creation
temp_file=$(mktemp /tmp/script_data.XXXXXX)
trap "rm -f $temp_file" EXIT

# Write data to temporary file
echo "Process data" > "$temp_file"

# Another process reads the data
while IFS= read -r line; do
    echo "Processing: $line"
done < "$temp_file"

# Temporary directory for multiple files
temp_dir=$(mktemp -d /tmp/batch_process.XXXXXX)
trap "rm -rf $temp_dir" EXIT

# Create multiple temporary files
for i in {1..5}; do
    echo "Data set $i" > "$temp_dir/dataset_$i.txt"
done
```

#### Inter-Process Data Exchange

Temporary files can facilitate complex data exchange patterns between multiple processes. This approach is particularly effective for batch processing, data transformation pipelines, and scenarios where processes need to access shared data at different times.

**Example:**

```bash
# Producer-consumer pattern with temporary files
shared_data=$(mktemp /tmp/shared_data.XXXXXX)
status_file=$(mktemp /tmp/status.XXXXXX)

# Producer process
{
    for i in {1..100}; do
        echo "Data item $i" >> "$shared_data"
        echo "produced $i" > "$status_file"
        sleep 0.1
    done
    echo "complete" > "$status_file"
} &

# Consumer process
{
    last_processed=0
    while true; do
        status=$(cat "$status_file" 2>/dev/null)
        if [[ "$status" == "complete" ]]; then
            break
        elif [[ "$status" =~ ^produced\ ([0-9]+)$ ]]; then
            current_item=${BASH_REMATCH[1]}
            if (( current_item > last_processed )); then
                tail -n +$((last_processed + 1)) "$shared_data" | head -n $((current_item - last_processed))
                last_processed=$current_item
            fi
        fi
        sleep 0.1
    done
} &

wait
```

#### Memory-Mapped Files and Shared Memory

Advanced inter-process communication can utilize memory-mapped files or shared memory segments for high-performance data exchange. While bash doesn't directly support these mechanisms, it can interact with external tools and utilities that provide shared memory capabilities.

**Example:**

```bash
# Using shared memory with external tools
shm_file="/dev/shm/process_data"

# Writer process
{
    echo "Shared data $(date)" > "$shm_file"
    echo "Writer finished"
} &

# Reader process
{
    while [[ ! -f "$shm_file" ]]; do
        sleep 0.1
    done
    echo "Reader got: $(cat "$shm_file")"
} &

wait
```

### Lock Files and Synchronization

Lock files provide a mechanism for process synchronization and mutual exclusion. They prevent multiple processes from accessing shared resources simultaneously and ensure data consistency in concurrent operations.

#### Basic Lock File Implementation

Lock files are typically created atomically and removed when processes complete their critical sections. The existence of a lock file indicates that a resource is in use, and other processes must wait for the lock to be released.

**Key points:**

- Use atomic operations for lock file creation
- Implement timeout mechanisms to prevent deadlocks
- Handle process termination and cleanup lock files
- Consider using process IDs in lock files for debugging
- Implement retry logic with exponential backoff

**Example:**

```bash
# Basic lock file implementation
lock_file="/tmp/process.lock"

acquire_lock() {
    local timeout=${1:-30}
    local wait_time=0
    
    while ! (set -C; echo $$ > "$lock_file") 2>/dev/null; do
        if (( wait_time >= timeout )); then
            echo "Failed to acquire lock after $timeout seconds"
            return 1
        fi
        sleep 1
        ((wait_time++))
    done
    
    trap "rm -f $lock_file" EXIT
    return 0
}

release_lock() {
    rm -f "$lock_file"
    trap - EXIT
}

# Usage
if acquire_lock 60; then
    echo "Lock acquired, performing critical operation..."
    # Critical section
    sleep 5
    echo "Critical operation completed"
    release_lock
else
    echo "Failed to acquire lock"
    exit 1
fi
```

#### Advanced Synchronization Patterns

Complex synchronization scenarios require more sophisticated locking mechanisms. These include reader-writer locks, semaphores, and condition variables implemented using file system primitives.

**Example:**

```bash
# Reader-writer lock implementation
rw_lock_dir="/tmp/rw_lock"
readers_file="$rw_lock_dir/readers"
writer_file="$rw_lock_dir/writer"

initialize_rw_lock() {
    mkdir -p "$rw_lock_dir"
    echo "0" > "$readers_file"
}

acquire_read_lock() {
    local timeout=${1:-30}
    local wait_time=0
    
    while [[ -f "$writer_file" ]]; do
        if (( wait_time >= timeout )); then
            return 1
        fi
        sleep 0.1
        ((wait_time++))
    done
    
    # Atomically increment reader count
    (
        flock -x 200
        local readers=$(cat "$readers_file")
        echo $((readers + 1)) > "$readers_file"
    ) 200>"$readers_file.lock"
    
    trap "release_read_lock" EXIT
}

release_read_lock() {
    (
        flock -x 200
        local readers=$(cat "$readers_file")
        echo $((readers - 1)) > "$readers_file"
    ) 200>"$readers_file.lock"
    trap - EXIT
}

acquire_write_lock() {
    local timeout=${1:-30}
    local wait_time=0
    
    # Wait for no writers
    while ! (set -C; echo $$ > "$writer_file") 2>/dev/null; do
        if (( wait_time >= timeout )); then
            return 1
        fi
        sleep 0.1
        ((wait_time++))
    done
    
    # Wait for no readers
    while [[ "$(cat "$readers_file")" != "0" ]]; do
        if (( wait_time >= timeout )); then
            rm -f "$writer_file"
            return 1
        fi
        sleep 0.1
        ((wait_time++))
    done
    
    trap "rm -f $writer_file" EXIT
}
```

#### Deadlock Prevention and Detection

Deadlock prevention requires careful ordering of lock acquisition and implementing timeout mechanisms. Detection involves monitoring lock states and identifying circular dependencies.

**Example:**

```bash
# Ordered lock acquisition to prevent deadlocks
acquire_multiple_locks() {
    local -a locks=("$@")
    local -a acquired_locks=()
    
    # Sort locks to ensure consistent ordering
    IFS=$'\n' sorted_locks=($(sort <<<"${locks[*]}"))
    
    for lock in "${sorted_locks[@]}"; do
        if ! acquire_lock "$lock" 10; then
            # Release all acquired locks in reverse order
            for ((i=${#acquired_locks[@]}-1; i>=0; i--)); do
                release_lock "${acquired_locks[i]}"
            done
            return 1
        fi
        acquired_locks+=("$lock")
    done
    
    return 0
}

# Deadlock detection
detect_deadlock() {
    local lock_dir="/tmp/locks"
    local -A lock_holders=()
    local -A waiting_for=()
    
    # Scan lock files to build dependency graph
    for lock_file in "$lock_dir"/*.lock; do
        if [[ -f "$lock_file" ]]; then
            local holder=$(cat "$lock_file")
            local lock_name=$(basename "$lock_file" .lock)
            lock_holders["$lock_name"]="$holder"
        fi
    done
    
    # Check for circular dependencies
    for lock in "${!lock_holders[@]}"; do
        local current_process="${lock_holders[$lock]}"
        local visited=()
        
        while [[ -n "$current_process" ]]; do
            if [[ " ${visited[*]} " =~ " $current_process " ]]; then
                echo "Deadlock detected involving process $current_process"
                return 0
            fi
            visited+=("$current_process")
            current_process="${waiting_for[$current_process]}"
        done
    done
    
    return 1
}
```

### Process Monitoring and Management

Process monitoring and management involve tracking process states, resource usage, and coordinating process lifecycles. This includes process creation, monitoring, termination, and cleanup operations.

#### Process State Monitoring

Monitoring process states requires tracking process IDs, exit codes, and resource consumption. Bash provides several mechanisms for process monitoring, including job control, process substitution, and signal handling.

**Key points:**

- Use process IDs for tracking and signaling
- Monitor exit codes to detect failures
- Implement heartbeat mechanisms for health checking
- Track resource usage and performance metrics
- Handle process termination gracefully

**Example:**

```bash
# Process monitoring framework
declare -A process_pids=()
declare -A process_states=()
declare -A process_start_times=()

start_monitored_process() {
    local name="$1"
    local command="$2"
    
    $command &
    local pid=$!
    
    process_pids["$name"]=$pid
    process_states["$name"]="running"
    process_start_times["$name"]=$(date +%s)
    
    echo "Started process $name with PID $pid"
}

monitor_processes() {
    for name in "${!process_pids[@]}"; do
        local pid="${process_pids[$name]}"
        
        if kill -0 "$pid" 2>/dev/null; then
            # Process is running
            local runtime=$(($(date +%s) - process_start_times["$name"]))
            echo "Process $name (PID $pid) running for ${runtime}s"
        else
            # Process has terminated
            wait "$pid"
            local exit_code=$?
            process_states["$name"]="terminated"
            echo "Process $name (PID $pid) terminated with exit code $exit_code"
            unset process_pids["$name"]
        fi
    done
}

# Usage
start_monitored_process "worker1" "sleep 10"
start_monitored_process "worker2" "sleep 5"

while [[ ${#process_pids[@]} -gt 0 ]]; do
    monitor_processes
    sleep 1
done
```

#### Resource Management

Resource management involves controlling process resource consumption, implementing resource limits, and monitoring system resources. This includes CPU usage, memory consumption, and file descriptor limits.

**Example:**

```bash
# Resource monitoring and limits
monitor_resource_usage() {
    local pid="$1"
    local max_memory_mb="$2"
    local max_cpu_percent="$3"
    
    while kill -0 "$pid" 2>/dev/null; do
        # Get process statistics
        local stats=$(ps -p "$pid" -o pid,ppid,pcpu,pmem,vsz,rss,time --no-headers)
        
        if [[ -n "$stats" ]]; then
            local cpu_percent=$(echo "$stats" | awk '{print $3}')
            local mem_percent=$(echo "$stats" | awk '{print $4}')
            local mem_mb=$(echo "$stats" | awk '{print $6/1024}')
            
            echo "Process $pid: CPU=${cpu_percent}%, Memory=${mem_mb}MB"
            
            # Check resource limits
            if (( $(echo "$cpu_percent > $max_cpu_percent" | bc -l) )); then
                echo "Process $pid exceeding CPU limit (${cpu_percent}% > ${max_cpu_percent}%)"
                kill -TERM "$pid"
            fi
            
            if (( $(echo "$mem_mb > $max_memory_mb" | bc -l) )); then
                echo "Process $pid exceeding memory limit (${mem_mb}MB > ${max_memory_mb}MB)"
                kill -TERM "$pid"
            fi
        fi
        
        sleep 2
    done
}

# Process pool management
manage_process_pool() {
    local max_processes="$1"
    local -a active_processes=()
    local -a pending_tasks=()
    
    while IFS= read -r task; do
        pending_tasks+=("$task")
    done
    
    for task in "${pending_tasks[@]}"; do
        # Wait for available slot
        while [[ ${#active_processes[@]} -ge $max_processes ]]; do
            local -a new_active=()
            for pid in "${active_processes[@]}"; do
                if kill -0 "$pid" 2>/dev/null; then
                    new_active+=("$pid")
                else
                    wait "$pid"
                    echo "Process $pid completed"
                fi
            done
            active_processes=("${new_active[@]}")
            sleep 0.1
        done
        
        # Start new task
        $task &
        active_processes+=($!)
        echo "Started task: $task (PID $!)"
    done
    
    # Wait for all remaining processes
    for pid in "${active_processes[@]}"; do
        wait "$pid"
        echo "Process $pid completed"
    done
}
```

#### Signal Handling and Graceful Shutdown

Proper signal handling ensures graceful process termination and cleanup. This includes handling SIGTERM, SIGINT, and custom signals for inter-process communication.

**Example:**

```bash
# Signal handling framework
declare -A signal_handlers=()

setup_signal_handlers() {
    # Handle common termination signals
    trap 'handle_signal SIGTERM' TERM
    trap 'handle_signal SIGINT' INT
    trap 'handle_signal SIGHUP' HUP
    trap 'cleanup_and_exit' EXIT
}

handle_signal() {
    local signal="$1"
    echo "Received $signal, initiating graceful shutdown..."
    
    # Stop accepting new work
    touch /tmp/shutdown_requested
    
    # Signal child processes
    for pid in "${!process_pids[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            echo "Sending $signal to process $pid"
            kill -"$signal" "$pid"
        fi
    done
    
    # Wait for processes to terminate
    local timeout=30
    local waited=0
    
    while [[ ${#process_pids[@]} -gt 0 ]] && (( waited < timeout )); do
        for name in "${!process_pids[@]}"; do
            local pid="${process_pids[$name]}"
            if ! kill -0 "$pid" 2>/dev/null; then
                echo "Process $name ($pid) terminated gracefully"
                unset process_pids["$name"]
            fi
        done
        sleep 1
        ((waited++))
    done
    
    # Force kill remaining processes
    for name in "${!process_pids[@]}"; do
        local pid="${process_pids[$name]}"
        echo "Force killing process $name ($pid)"
        kill -KILL "$pid" 2>/dev/null
    done
    
    exit 0
}

cleanup_and_exit() {
    echo "Performing cleanup..."
    rm -f /tmp/shutdown_requested
    rm -f /tmp/*.lock
    echo "Cleanup completed"
}

# Process supervision
supervise_process() {
    local command="$1"
    local restart_count=0
    local max_restarts=5
    
    while (( restart_count < max_restarts )); do
        if [[ -f /tmp/shutdown_requested ]]; then
            echo "Shutdown requested, stopping supervision"
            break
        fi
        
        echo "Starting supervised process (attempt $((restart_count + 1)))"
        $command &
        local pid=$!
        
        wait "$pid"
        local exit_code=$?
        
        if (( exit_code == 0 )); then
            echo "Process completed successfully"
            break
        else
            echo "Process failed with exit code $exit_code"
            ((restart_count++))
            sleep 5
        fi
    done
    
    if (( restart_count >= max_restarts )); then
        echo "Process failed after $max_restarts attempts"
        return 1
    fi
}
```

**Next steps:** Explore advanced topics like distributed process coordination, message queuing systems integration, and performance optimization techniques for high-throughput inter-process communication scenarios.

---

