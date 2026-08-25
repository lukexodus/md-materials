## Process Control


Process control in bash scripting encompasses managing the execution, interaction, and lifecycle of processes. This includes running processes in the background, controlling job execution, facilitating inter-process communication, and handling system signals. Mastering these concepts enables creation of robust, efficient scripts that can handle complex workflows and respond appropriately to system events.

### Background Processes and Job Control

Background processes allow scripts to execute multiple tasks concurrently without blocking the main execution thread. Appending an ampersand (&) to a command runs it in the background, immediately returning control to the shell while the process continues execution.

The `jobs` command displays all active jobs in the current shell session, showing job numbers, status, and command names. Each background job receives a unique job ID that can be referenced using `%n` notation, where n is the job number.

Job control commands provide comprehensive process management:

- `bg` moves stopped jobs to background execution
- `fg` brings background jobs to the foreground
- `kill` terminates jobs using job IDs or process IDs
- `disown` removes jobs from the shell's job table
- `nohup` runs commands immune to hangup signals

The `wait` command pauses script execution until specified background processes complete. Using `wait` without arguments waits for all background jobs to finish. Specific processes can be waited for using their process IDs: `wait $PID`.

Process substitution enables capturing output from background processes into variables or files. The `$!` variable contains the process ID of the most recently executed background process, useful for monitoring or controlling specific jobs.

Subshells created with parentheses run commands in isolated environments, inheriting variables but not affecting the parent shell's environment. This proves valuable for temporary directory changes or environment modifications.

### Process Substitution

Process substitution provides a mechanism to use command output as if it were a file, enabling complex data flow between processes without creating temporary files. The `<(command)` syntax creates a named pipe that other commands can read from, while `>(command)` creates a pipe that commands can write to.

Input process substitution `<(command)` allows commands expecting file input to read directly from another command's output. This technique proves particularly useful with commands like `diff`, `sort`, and `join` that typically require file arguments.

Output process substitution `>(command)` enables sending output to a command as if writing to a file. This allows sophisticated output processing without intermediate files, improving performance and reducing disk I/O.

Process substitution works by creating temporary named pipes (FIFOs) in `/dev/fd/` or `/proc/self/fd/`. The shell automatically manages these temporary files, cleaning them up when the process substitution completes.

Multiple process substitutions can be combined in a single command, enabling complex data processing pipelines. This technique allows for sophisticated data transformation and analysis workflows that would otherwise require multiple temporary files or complex pipe arrangements.

Process substitution differs from command substitution (`$(command)`) in that it doesn't capture output into a variable but instead provides a file-like interface for streaming data between processes.

### Named Pipes (FIFOs)

Named pipes, also called FIFOs (First In, First Out), provide persistent inter-process communication channels that exist as special files in the filesystem. Unlike anonymous pipes created with the `|` operator, named pipes persist until explicitly removed and can be accessed by unrelated processes.

Creating named pipes uses the `mkfifo` command, which creates a special file that acts as a communication channel. Multiple processes can open the same FIFO for reading or writing, enabling sophisticated inter-process communication patterns.

Named pipes exhibit blocking behavior: attempts to read from an empty FIFO block until data becomes available, while writes to a FIFO with no readers also block. This synchronization mechanism enables coordination between processes without complex locking mechanisms.

FIFOs support both synchronous and asynchronous communication patterns. Synchronous usage involves processes explicitly coordinating through the FIFO, while asynchronous usage treats the FIFO as a buffer for decoupled communication.

Named pipes prove particularly valuable for:

- Producer-consumer scenarios where one process generates data and another consumes it
- Log aggregation where multiple processes write to a central logging process
- Service communication where long-running processes need to exchange data
- Streaming data processing where continuous data flow is required

Permission management for named pipes follows standard Unix file permissions, allowing fine-grained control over which processes can read from or write to specific FIFOs.

### Signal Handling and Traps

Signals provide a mechanism for processes to communicate events, errors, or requests for specific actions. The `trap` command allows bash scripts to define custom handlers for various signals, enabling graceful error handling and cleanup operations.

Common signals include:

- `SIGTERM` (15): Polite termination request
- `SIGKILL` (9): Immediate termination (cannot be trapped)
- `SIGINT` (2): Interrupt signal (Ctrl+C)
- `SIGHUP` (1): Hangup signal
- `SIGUSR1` (10) and `SIGUSR2` (12): User-defined signals

The `trap` command syntax associates signal handlers with specific signals: `trap 'command' SIGNAL`. Multiple signals can be handled by the same command, and the special `EXIT` signal triggers when the script terminates normally.

Trap handlers enable cleanup operations such as removing temporary files, closing open file descriptors, terminating background processes, or saving state information. This ensures scripts leave the system in a consistent state regardless of how they terminate.

Signal propagation affects child processes differently depending on how they're created. Signals sent to a process group affect all processes in the group, while signals sent to individual processes affect only that process.

The `kill` command sends signals to processes using process IDs or job specifications. Different signals serve different purposes: `SIGTERM` allows graceful shutdown, `SIGKILL` forces immediate termination, and `SIGUSR1`/`SIGUSR2` enable custom application-specific communication.

Trap handlers can be reset using `trap - SIGNAL` or replaced by defining new handlers. The `trap -l` command lists all available signals on the system.

**Key points:**

- Background processes continue execution even after the parent shell exits unless explicitly managed
- Process substitution eliminates the need for temporary files in many scenarios
- Named pipes provide powerful inter-process communication but require careful management of readers and writers
- Signal handling ensures scripts can respond appropriately to system events and user interruptions
- Proper cleanup in trap handlers prevents resource leaks and maintains system stability

**Example:**

```bash
#!/bin/bash

# Named pipe for inter-process communication
mkfifo /tmp/data_pipe

# Background process writing to pipe
{
    for i in {1..100}; do
        echo "Data item $i"
        sleep 0.1
    done
} > /tmp/data_pipe &

producer_pid=$!

# Process substitution for data transformation
process_data() {
    while read -r line; do
        echo "Processed: $line" | tr '[:lower:]' '[:upper:]'
    done
}

# Signal handling and cleanup
cleanup() {
    echo "Cleaning up..."
    kill $producer_pid 2>/dev/null
    rm -f /tmp/data_pipe
    exit 0
}

trap cleanup EXIT SIGINT SIGTERM

# Using process substitution with named pipe
process_data < /tmp/data_pipe > >(tee processed_output.txt)

# Job control example
{
    long_running_task() {
        sleep 30
        echo "Task completed"
    }
    
    long_running_task &
    task_pid=$!
    
    # Wait with timeout
    timeout 10 wait $task_pid || {
        echo "Task timed out, terminating..."
        kill $task_pid
    }
}

# Process substitution for comparing outputs
diff <(command1) <(command2) > differences.txt

wait  # Wait for all background jobs
```

**Conclusion:** Process control mechanisms provide the foundation for creating sophisticated bash scripts that can handle complex workflows, manage system resources efficiently, and respond appropriately to various system conditions. Understanding these concepts enables development of robust automation tools and system management scripts.

For advanced applications, consider exploring process monitoring techniques, systemd integration for service management, and cgroups for resource control in containerized environments.

---

