## Performance Optimization


### Efficient Scripting Techniques

Efficient bash scripting requires understanding the performance characteristics of different operations and choosing the most appropriate tools and techniques for each task.

Use built-in shell features instead of external commands whenever possible. Built-ins execute faster because they don't require process creation:

```bash
# Slow - uses external command
if [ $(echo "$string" | wc -c) -gt 10 ]; then
    echo "String too long"
fi

# Fast - uses parameter expansion
if [ ${#string} -gt 10 ]; then
    echo "String too long"
fi
```

Minimize subprocess creation by combining operations and using shell pattern matching:

```bash
# Inefficient - multiple subprocesses
for file in $(ls *.txt); do
    if [ $(basename "$file" .txt | wc -c) -gt 5 ]; then
        echo "Processing $file"
    fi
done

# Efficient - shell globbing and parameter expansion
for file in *.txt; do
    [[ -f "$file" ]] || continue
    basename="${file%.txt}"
    if [ ${#basename} -gt 5 ]; then
        echo "Processing $file"
    fi
done
```

Use arrays for storing and processing multiple values efficiently:

```bash
# Collect data in arrays
declare -a files
declare -a sizes

# Process multiple files efficiently
for file in *.log; do
    [[ -f "$file" ]] || continue
    files+=("$file")
    sizes+=($(stat -c%s "$file"))
done

# Process arrays in batch
for ((i=0; i<${#files[@]}; i++)); do
    if [ "${sizes[i]}" -gt 1000000 ]; then
        compress_file "${files[i]}"
    fi
done
```

Optimize string operations using parameter expansion instead of external tools:

```bash
# Slow
filename=$(basename "$path")
extension=$(echo "$filename" | cut -d. -f2)
name_without_ext=$(echo "$filename" | cut -d. -f1)

# Fast
filename="${path##*/}"
extension="${filename##*.}"
name_without_ext="${filename%.*}"
```

Use here-strings and here-documents to avoid temporary files:

```bash
# Instead of creating temporary files
echo "$data" > temp_file
process_data < temp_file
rm temp_file

# Use here-strings
process_data <<< "$data"

# Or here-documents for multi-line data
process_data << EOF
$line1
$line2
$line3
EOF
```

### Memory and Resource Management

Proper memory and resource management prevents memory leaks, reduces system load, and ensures scripts can handle large datasets efficiently.

Monitor and limit memory usage for large operations:

```bash
# Set memory limits
ulimit -v 1000000  # Virtual memory limit in KB

# Monitor memory usage
check_memory() {
    local current_usage=$(ps -o pid,vsz,rss,comm -p $$)
    echo "Current memory usage: $current_usage" >&2
}
```

Use streaming processing for large files instead of loading everything into memory:

```bash
# Memory-efficient file processing
process_large_file() {
    local file="$1"
    local line_count=0
    
    while IFS= read -r line; do
        # Process line immediately
        process_line "$line"
        
        # Periodic progress updates
        ((line_count++))
        if ((line_count % 10000 == 0)); then
            echo "Processed $line_count lines" >&2
        fi
    done < "$file"
}
```

Implement proper cleanup routines to release resources:

```bash
# Resource cleanup
cleanup() {
    # Close file descriptors
    exec 3<&-
    exec 4>&-
    
    # Remove temporary files
    [[ -n "$temp_dir" ]] && rm -rf "$temp_dir"
    
    # Kill background processes
    [[ -n "$bg_pid" ]] && kill "$bg_pid" 2>/dev/null
    
    # Release locks
    [[ -n "$lock_file" ]] && rm -f "$lock_file"
}

trap cleanup EXIT INT TERM
```

Use efficient data structures and avoid unnecessary variable assignments:

```bash
# Inefficient - creates many variables
for i in {1..1000}; do
    temp_var="processing_$i"
    result="$temp_var done"
    echo "$result"
done

# Efficient - direct processing
for i in {1..1000}; do
    echo "processing_$i done"
done
```

Implement lazy evaluation and caching for expensive operations:

```bash
# Caching expensive operations
declare -A cache

expensive_operation() {
    local key="$1"
    
    # Check cache first
    if [[ -n "${cache[$key]:-}" ]]; then
        echo "${cache[$key]}"
        return 0
    fi
    
    # Perform expensive calculation
    local result=$(complex_calculation "$key")
    
    # Cache result
    cache["$key"]="$result"
    echo "$result"
}
```

### Parallel Processing Basics

Parallel processing can significantly improve performance for CPU-intensive tasks and I/O operations by utilizing multiple cores and reducing waiting time.

Use background processes for independent tasks:

```bash
# Process files in parallel
process_files_parallel() {
    local max_jobs=4
    local job_count=0
    
    for file in *.txt; do
        [[ -f "$file" ]] || continue
        
        # Start background job
        process_single_file "$file" &
        ((job_count++))
        
        # Limit concurrent jobs
        if ((job_count >= max_jobs)); then
            wait  # Wait for all background jobs to complete
            job_count=0
        fi
    done
    
    # Wait for remaining jobs
    wait
}
```

Use `xargs` with parallel processing for efficient batch operations:

```bash
# Parallel processing with xargs
find . -name "*.jpg" -print0 | \
xargs -0 -n 1 -P 4 -I {} sh -c 'convert "{}" -resize 800x600 "thumb_{}"'

# -P 4: Run up to 4 processes in parallel
# -n 1: Use one argument per command
# -I {}: Replace {} with the argument
```

Implement job control for managing parallel processes:

```bash
# Advanced parallel processing with job control
declare -a job_pids
max_concurrent=4

spawn_job() {
    local task="$1"
    
    # Remove completed jobs from tracking
    for i in "${!job_pids[@]}"; do
        if ! kill -0 "${job_pids[i]}" 2>/dev/null; then
            unset 'job_pids[i]'
        fi
    done
    
    # Wait if at max capacity
    while ((${#job_pids[@]} >= max_concurrent)); do
        sleep 0.1
        # Check for completed jobs
        for i in "${!job_pids[@]}"; do
            if ! kill -0 "${job_pids[i]}" 2>/dev/null; then
                unset 'job_pids[i]'
            fi
        done
    done
    
    # Start new job
    "$task" &
    job_pids+=($!)
}

# Usage
for data_file in data_*.csv; do
    spawn_job "process_csv_file '$data_file'"
done

# Wait for all jobs to complete
for pid in "${job_pids[@]}"; do
    wait "$pid"
done
```

Use named pipes (FIFOs) for producer-consumer patterns:

```bash
# Producer-consumer with named pipes
setup_pipeline() {
    local pipe_name="/tmp/processing_pipe"
    
    # Create named pipe
    mkfifo "$pipe_name"
    
    # Producer process
    {
        for i in {1..1000}; do
            echo "data_$i"
        done
    } > "$pipe_name" &
    
    # Consumer processes
    for worker in {1..4}; do
        {
            while read -r data; do
                process_data "$data"
            done
        } < "$pipe_name" &
    done
    
    # Cleanup
    trap "rm -f '$pipe_name'" EXIT
}
```

### Profiling and Optimization

Profiling helps identify performance bottlenecks and measure the effectiveness of optimizations.

Use `time` command variants for basic profiling:

```bash
# Basic timing
time my_script.sh

# Detailed timing information
/usr/bin/time -v my_script.sh

# Custom timing function
profile_function() {
    local func_name="$1"
    local start_time=$(date +%s.%N)
    
    "$func_name"
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    
    echo "Function $func_name took $duration seconds" >&2
}
```

Add debugging and profiling instrumentation to scripts:

```bash
# Profiling with built-in timing
TIMEFORMAT='%R seconds elapsed'

profile_section() {
    local section_name="$1"
    echo "Starting $section_name..." >&2
    
    time {
        case "$section_name" in
            "data_processing")
                process_all_data
                ;;
            "file_operations")
                perform_file_operations
                ;;
            *)
                echo "Unknown section: $section_name" >&2
                return 1
                ;;
        esac
    }
}
```

Use `strace` and `ltrace` for system-level profiling:

```bash
# System call tracing
strace -c -f ./my_script.sh

# Library call tracing
ltrace -c -f ./my_script.sh

# Automated profiling script
profile_script() {
    local script="$1"
    local output_dir="profile_results"
    
    mkdir -p "$output_dir"
    
    # Time profiling
    /usr/bin/time -v "$script" 2> "$output_dir/time_profile.txt"
    
    # System call profiling
    strace -c -f "$script" 2> "$output_dir/strace_profile.txt"
    
    # Memory profiling (if valgrind is available)
    if command -v valgrind >/dev/null 2>&1; then
        valgrind --tool=massif "$script" 2> "$output_dir/memory_profile.txt"
    fi
}
```

Implement performance monitoring within scripts:

```bash
# Performance monitoring
declare -A perf_counters
declare -A perf_timers

start_timer() {
    local timer_name="$1"
    perf_timers["$timer_name"]=$(date +%s.%N)
}

stop_timer() {
    local timer_name="$1"
    local start_time="${perf_timers[$timer_name]}"
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    
    perf_counters["${timer_name}_total"]=$(echo "${perf_counters[${timer_name}_total]:-0} + $duration" | bc)
    perf_counters["${timer_name}_count"]=$((${perf_counters[${timer_name}_count]:-0} + 1))
}

report_performance() {
    echo "Performance Report:" >&2
    for counter in "${!perf_counters[@]}"; do
        if [[ "$counter" == *"_total" ]]; then
            local base_name="${counter%_total}"
            local total="${perf_counters[$counter]}"
            local count="${perf_counters[${base_name}_count]}"
            local average=$(echo "scale=4; $total / $count" | bc)
            
            echo "  $base_name: $total seconds total, $count calls, $average seconds average" >&2
        fi
    done
}

# Usage
start_timer "database_query"
perform_database_query
stop_timer "database_query"
```

**Key points** for performance optimization include understanding the cost of external commands versus built-ins, implementing proper resource management, utilizing parallel processing appropriately, and measuring performance to identify actual bottlenecks rather than premature optimization.

---

