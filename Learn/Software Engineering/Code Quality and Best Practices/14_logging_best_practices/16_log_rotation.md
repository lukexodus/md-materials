## Log rotation


Log rotation is a critical system administration and application stability practice designed to prevent filesystem exhaustion and maintain manageable log file sizes.1 Without rotation, continuously appending to a single log file inevitably leads to 100% disk usage, resulting in denial of service (DoS), application crashes, and OS-level instability.2

### Rotation Mechanisms

Rotation typically operates on two primary triggers:

1. **Size-Based:** A log file is rotated once it reaches a predefined byte size (e.g., 100MB). This guarantees deterministic disk usage per file but makes the time span of a log file variable based on traffic.
    
2. **Time-Based:** A log file is rotated at specific intervals (e.g., daily at 00:00 UTC).3 This facilitates easier querying by date but poses risks of disk exhaustion during unpredictable traffic spikes.
    

**Best Practice:** Use a hybrid approach. Rotate on a time basis (daily) but force an early rotation if the size exceeds a safety threshold (e.g., 1GB) to prevent runaway logging from filling the disk before the day ends.

### Architectural Strategies

#### 1. Move-Create (Rename and Reopen)

This is the standard and preferred mechanism on POSIX systems.

1. **Rename:** The active log file (`app.log`) is renamed to an archive name (`app.log.1`).4 The application continues writing to this file because the file descriptor (FD) points to the inode, not the filename.5
    
2. **Signal:** The rotation daemon sends a signal (typically `SIGHUP`) to the application process.6
    
3. **Reopen:** Upon receiving the signal, the application closes its current FD and opens a new FD for `app.log`. The OS creates a new file at this path.
    

- **Pros:** Atomic, zero data loss if handled correctly.
    
- **Cons:** Requires application support for signal handling and reloading; not natively supported on Windows filesystems in the same way.
    

#### 2. Copy-Truncate

Used when the application cannot be signaled or reconfigured to close its log handle.

1. **Copy:** The contents of `app.log` are copied to `app.log.1`.
    
2. **Truncate:** The original `app.log` is truncated to zero bytes.
    

- **Pros:** Works with any application, regardless of its signal handling capabilities.
    
- **Cons:** **Race Condition.** Any log entries written by the application between the completion of the copy and the execution of the truncate operation are permanently lost. Additionally, the copy operation causes double disk I/O pressure.
    

### The "StdOut" Paradigm (Containerization)

In modern cloud-native architectures (Docker, Kubernetes), applications should **not** manage their own log files or rotation.

- **Anti-Pattern:** Configuring Log4j, Winston, or Logback to write to a file on the container filesystem and manage rotation internally. This couples the application to the filesystem and complicates log aggregation.
    
- **Best Practice:** Applications must write purely to `stdout` and `stderr`.
    
    - **Responsibility Shift:** The container runtime (e.g., Docker Engine, Containerd) or the orchestration node handles the capture, rotation, and file management of these streams on the host node.
        
    - **Configuration:** Configure the Docker logging driver (e.g., `json-file`) with `max-size` and `max-file` options to ensure the host disk is not consumed by container logs.7
        

### Compression and Retention Policies

- **Compression:** Rotated logs should be immediately compressed (e.g., `gzip`, `zstd`) to minimize storage footprint.8 CPU overhead for compression is negligible compared to the storage savings (often 10:1 or better for text logs).
    
- **Retention (Hot vs. Cold):**
    
    - **Hot Storage:** Keep a small number of rotated files (e.g., 7 days) on the local disk for immediate debugging.
        
    - **Cold Storage:** Offload older logs to object storage (e.g., S3, Azure Blob) or a centralized logging backend (e.g., Elasticsearch, Splunk) for long-term compliance and audit retention.
        
    - **Purge:** Automatically delete local files exceeding the retention count to free up inodes and space.
        

### Security Implications

- **Permissions:** Rotated log files often contain sensitive historical data.9 They must strictly inherit the file permissions of the parent process or be forcibly restricted (e.g., `600` or `640`) to prevent unauthorized read access by other users on the system.
    
- **Suid Binaries:** Extreme caution is required when rotating logs for binaries running with elevated privileges to avoid race conditions that could allow privilege escalation (e.g., symlink attacks on the log file path).
    

Related topics: `logrotate` utility, Inode management, POSIX Signals, Docker Logging Drivers.

---

