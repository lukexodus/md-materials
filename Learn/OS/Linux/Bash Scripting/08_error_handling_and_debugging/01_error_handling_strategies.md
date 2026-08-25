## Error Handling Strategies


### Exit Codes and Error Propagation

Exit codes are fundamental to bash error handling, providing a standardized way to communicate success or failure between commands and scripts. Every command in bash returns an exit code: 0 for success, and 1-255 for various error conditions.

The `$?` variable captures the exit code of the last executed command. You can check this immediately after command execution to determine success or failure. For custom functions and scripts, use `exit n` to return specific exit codes, where different numbers can represent different error conditions.

Error propagation becomes crucial in complex scripts where multiple commands depend on each other. The `set -e` option makes your script exit immediately when any command returns a non-zero exit code, preventing cascading failures. However, this can be too aggressive for scripts that need to handle errors gracefully.

More sophisticated error propagation uses the `||` and `&&` operators. The `||` operator executes the right side only if the left side fails, while `&&` executes the right side only if the left side succeeds. This allows for conditional execution based on success or failure.

**Example:**

```bash
#!/bin/bash

# Function with custom exit codes
backup_database() {
    if ! mysqldump database > backup.sql; then
        echo "Database backup failed" >&2
        return 1
    fi
    
    if ! gzip backup.sql; then
        echo "Compression failed" >&2
        return 2
    fi
    
    return 0
}

# Usage with error checking
if backup_database; then
    echo "Backup completed successfully"
else
    case $? in
        1) echo "Database dump failed" >&2 ;;
        2) echo "Compression failed" >&2 ;;
        *) echo "Unknown error occurred" >&2 ;;
    esac
    exit 1
fi
```

### Try/Catch Simulation in Bash

Bash doesn't have native try/catch blocks, but you can simulate this behavior using functions, traps, and conditional statements. This approach provides structured error handling similar to other programming languages.

The most common simulation uses a combination of functions and return codes. Create a "try" function that executes potentially failing commands and returns appropriate exit codes, then use conditional statements to handle different outcomes.

Another approach uses the `trap` command to catch signals and errors. The `ERR` trap executes when a command returns a non-zero exit code, allowing you to define cleanup actions or error handling procedures.

For more sophisticated try/catch simulation, you can create wrapper functions that capture both the exit code and any error output, then provide different handling paths based on the type of error encountered.

**Example:**

```bash
#!/bin/bash

# Try/catch simulation using functions
try() {
    [[ $- = *e* ]] && SAVED_OPT_E=1
    set +e
}

catch() {
    export exception_code=$?
    (( SAVED_OPT_E )) && set -e
    return $exception_code
}

throw() {
    exit $1
}

# Usage example
try
    # Commands that might fail
    cp /nonexistent/file /tmp/
    rm /protected/file
    false  # This will always fail
catch || {
    case $exception_code in
        1)
            echo "File operation failed"
            ;;
        2)
            echo "Permission denied"
            ;;
        *)
            echo "Unknown error: $exception_code"
            ;;
    esac
}

# Alternative using trap
error_handler() {
    local exit_code=$?
    local line_no=$1
    echo "Error on line $line_no: Command exited with status $exit_code" >&2
    # Cleanup actions
    cleanup_temp_files
    exit $exit_code
}

trap 'error_handler $LINENO' ERR
```

### Logging and Error Reporting

Effective logging and error reporting provide visibility into script execution and help diagnose issues. Implement structured logging that captures different severity levels: debug, info, warning, error, and critical.

Use file descriptors to separate different types of output. Standard output (stdout) should contain the main program output, while standard error (stderr) should contain error messages and diagnostic information. This separation allows users to redirect these streams independently.

Create logging functions that automatically timestamp entries and format them consistently. Include contextual information such as function names, line numbers, and relevant variable values to make debugging easier.

For production scripts, implement log rotation to prevent log files from growing too large. Use tools like `logrotate` or implement simple rotation logic within your scripts.

**Example:**

```bash
#!/bin/bash

# Logging configuration
LOG_FILE="/var/log/myscript.log"
LOG_LEVEL="INFO"  # DEBUG, INFO, WARN, ERROR, CRITICAL

# Logging function
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Log level hierarchy
    case $LOG_LEVEL in
        DEBUG) levels="DEBUG INFO WARN ERROR CRITICAL" ;;
        INFO)  levels="INFO WARN ERROR CRITICAL" ;;
        WARN)  levels="WARN ERROR CRITICAL" ;;
        ERROR) levels="ERROR CRITICAL" ;;
        CRITICAL) levels="CRITICAL" ;;
    esac
    
    if [[ " $levels " =~ " $level " ]]; then
        echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
        if [[ $level == "ERROR" || $level == "CRITICAL" ]]; then
            echo "[$timestamp] [$level] $message" >&2
        fi
    fi
}

# Error reporting function
report_error() {
    local function_name=$1
    local line_number=$2
    local exit_code=$3
    local description="$4"
    
    log ERROR "Function: $function_name, Line: $line_number, Exit Code: $exit_code"
    log ERROR "Description: $description"
    
    # Send alert if critical
    if [[ $exit_code -gt 10 ]]; then
        log CRITICAL "Critical error encountered, sending alert"
        # Send email, slack notification, etc.
    fi
}

# Usage with error context
risky_operation() {
    log INFO "Starting risky operation"
    
    if ! some_command; then
        report_error "${FUNCNAME[0]}" "$LINENO" "$?" "some_command failed"
        return 1
    fi
    
    log INFO "Risky operation completed successfully"
    return 0
}
```

### Graceful Failure Handling

Graceful failure handling ensures your scripts fail safely without leaving systems in inconsistent states. This involves implementing cleanup procedures, providing meaningful error messages, and offering recovery options when possible.

Use signal handlers to catch interruption signals (SIGINT, SIGTERM) and perform cleanup before exiting. Create cleanup functions that remove temporary files, release locks, and restore system states.

Implement validation checks before performing destructive operations. Check for required dependencies, sufficient disk space, proper permissions, and valid input parameters before proceeding with the main script logic.

Design your scripts to be idempotent when possible, meaning they can be run multiple times safely. This allows for easy recovery from partial failures by simply re-running the script.

Provide informative error messages that include not just what went wrong, but also suggested remediation steps. Include relevant context such as current working directory, user permissions, and system state.

**Example:**

```bash
#!/bin/bash

# Global variables for cleanup
TEMP_DIR=""
LOCK_FILE="/tmp/myscript.lock"
BACKUP_CREATED=false

# Cleanup function
cleanup() {
    local exit_code=$?
    
    log INFO "Performing cleanup (exit code: $exit_code)"
    
    # Remove temporary files
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
        log INFO "Removed temporary directory: $TEMP_DIR"
    fi
    
    # Release lock
    if [[ -f "$LOCK_FILE" ]]; then
        rm -f "$LOCK_FILE"
        log INFO "Released lock file: $LOCK_FILE"
    fi
    
    # Restore from backup if operation failed
    if [[ $exit_code -ne 0 && $BACKUP_CREATED == true ]]; then
        log WARN "Operation failed, restoring from backup"
        restore_from_backup
    fi
    
    exit $exit_code
}

# Set up signal handlers
trap cleanup EXIT
trap 'log WARN "Received SIGINT, cleaning up..."; exit 130' INT
trap 'log WARN "Received SIGTERM, cleaning up..."; exit 143' TERM

# Pre-flight checks
preflight_checks() {
    log INFO "Running preflight checks"
    
    # Check if already running
    if [[ -f "$LOCK_FILE" ]]; then
        log ERROR "Script is already running (lock file exists: $LOCK_FILE)"
        log ERROR "If you're sure it's not running, remove the lock file manually"
        exit 1
    fi
    
    # Check dependencies
    for cmd in rsync mysqldump gzip; do
        if ! command -v "$cmd" &> /dev/null; then
            log ERROR "Required command not found: $cmd"
            log ERROR "Please install $cmd and try again"
            exit 2
        fi
    done
    
    # Check disk space (need at least 1GB)
    local available=$(df /tmp | tail -1 | awk '{print $4}')
    if [[ $available -lt 1048576 ]]; then
        log ERROR "Insufficient disk space in /tmp (need 1GB, have ${available}KB)"
        log ERROR "Please free up space and try again"
        exit 3
    fi
    
    log INFO "All preflight checks passed"
}

# Safe operation with rollback capability
safe_operation() {
    log INFO "Starting safe operation"
    
    # Create lock file
    echo $$ > "$LOCK_FILE"
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    log INFO "Created temporary directory: $TEMP_DIR"
    
    # Create backup before making changes
    if create_backup; then
        BACKUP_CREATED=true
        log INFO "Backup created successfully"
    else
        log ERROR "Failed to create backup, aborting operation"
        exit 4
    fi
    
    # Perform main operation with error checking
    if ! perform_main_operation; then
        log ERROR "Main operation failed, will restore from backup"
        exit 5
    fi
    
    # Verify operation success
    if ! verify_operation; then
        log ERROR "Operation verification failed, will restore from backup"
        exit 6
    fi
    
    log INFO "Safe operation completed successfully"
    BACKUP_CREATED=false  # Don't restore on successful completion
}

# Main execution
main() {
    log INFO "Script starting"
    
    preflight_checks
    safe_operation
    
    log INFO "Script completed successfully"
}

# Run main function
main "$@"
```

**Key points** for implementing robust error handling strategies include establishing clear exit code conventions throughout your scripts, implementing comprehensive logging that captures both successful operations and failures, creating cleanup procedures that execute regardless of how the script terminates, and providing meaningful error messages that help users understand what went wrong and how to fix it. Always test your error handling paths as thoroughly as your success paths, and consider implementing monitoring and alerting for production scripts to ensure failures are noticed and addressed promptly.

---

