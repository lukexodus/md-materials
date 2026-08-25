## Advanced Scripting


### Script Optimization

Script optimization focuses on improving execution speed, resource utilization, and code efficiency through various techniques and best practices.

#### Performance Analysis and Profiling

Script profiling identifies bottlenecks and resource-intensive operations. The `time` command provides basic execution timing, while `strace` traces system calls to identify I/O patterns. For bash scripts, `set -x` enables detailed execution tracing, and custom timing functions can measure specific code sections.

#### Command Substitution Optimization

Modern command substitution using `$()` performs better than backticks due to better nesting support and reduced subshell overhead. Avoiding unnecessary command substitutions in loops significantly improves performance. Caching command results in variables prevents repeated expensive operations.

#### Loop and Iteration Optimization

Array processing often outperforms repeated string operations. Using `while read` loops for file processing handles large files more efficiently than loading entire files into memory. The `mapfile` or `readarray` built-ins provide faster array population from input streams.

#### Built-in Command Utilization

Shell built-ins execute faster than external commands by avoiding process creation overhead. Using parameter expansion (`${var#pattern}`, `${var%pattern}`) instead of `sed` or `cut` for simple string operations improves performance. Built-in arithmetic expansion `$((expression))` outperforms external calculators.

#### Memory Management Strategies

Avoiding large string concatenations in loops prevents memory fragmentation. Using arrays for collecting output and joining once reduces memory reallocation. Unsetting large variables and arrays when no longer needed frees memory immediately.

#### Parallel Processing Techniques

Background processes with `&` enable parallel execution of independent tasks. The `wait` command synchronizes parallel operations. GNU Parallel provides sophisticated parallel processing capabilities for batch operations. Process substitution `<()` enables parallel data flow without temporary files.

#### I/O Optimization

Minimizing file operations by batching reads and writes improves performance. Using process substitution instead of temporary files reduces disk I/O. Redirecting output once rather than repeatedly in loops prevents file descriptor overhead.

**Key points:**

- Profile scripts before optimizing to identify actual bottlenecks
- Built-in commands and features typically outperform external utilities
- Memory-efficient data structures prevent performance degradation
- Parallel processing can significantly improve throughput for independent operations

### Error Handling Strategies

Comprehensive error handling ensures script reliability and provides meaningful feedback when failures occur.

#### Exit Status Management

Every command returns an exit status (0 for success, non-zero for failure). The `$?` variable captures the last command's exit status. Setting meaningful exit codes in scripts allows calling programs to understand failure types. The `exit` command with specific codes provides standardized error reporting.

#### Error Detection Mechanisms

The `set -e` option terminates scripts on any command failure, preventing cascading errors. However, this can be too aggressive for complex scripts. The `set -u` option treats undefined variables as errors. The `set -o pipefail` ensures pipeline failures are detected even if the final command succeeds.

#### Conditional Error Handling

Using `if` statements with command execution allows specific error handling per operation. The `||` and `&&` operators provide concise success/failure branching. The `trap` command enables cleanup operations on script exit or signal reception.

#### Error Recovery Patterns

Retry mechanisms with exponential backoff handle transient failures gracefully. Graceful degradation allows scripts to continue with reduced functionality when non-critical operations fail. Resource cleanup ensures proper system state even after errors.

#### Validation and Sanity Checks

Input validation prevents errors by checking parameters, file existence, and permissions before processing. Dependency checking verifies required commands and resources are available. Range and format validation ensures data integrity.

#### Signal Handling

The `trap` command catches signals (SIGINT, SIGTERM, SIGUSR1) and executes cleanup code. Signal handlers should be kept simple and fast to avoid race conditions [Inference]. Proper signal handling enables graceful shutdown and resource cleanup.

**Example error handling pattern:**

```bash
#!/bin/bash
set -euo pipefail

# Error handling function
error_exit() {
    echo "Error: $1" >&2
    cleanup
    exit "${2:-1}"
}

# Cleanup function
cleanup() {
    [[ -n "${temp_dir:-}" ]] && rm -rf "$temp_dir"
    [[ -n "${lock_file:-}" ]] && rm -f "$lock_file"
}

# Set trap for cleanup
trap cleanup EXIT
trap 'error_exit "Script interrupted" 130' INT
```

### Script Logging

Effective logging provides visibility into script execution, debugging information, and audit trails for compliance and troubleshooting.

#### Logging Levels and Categories

Standard logging levels include DEBUG, INFO, WARN, ERROR, and FATAL, with increasing severity. Each level serves specific purposes: DEBUG for development details, INFO for normal operation, WARN for potential issues, ERROR for failures, and FATAL for critical failures requiring immediate attention.

#### Log Output Destinations

Scripts can log to multiple destinations simultaneously: standard output for user feedback, standard error for warnings and errors, files for persistent records, and syslog for centralized logging. The `logger` command integrates with system logging infrastructure.

#### Structured Logging Formats

Structured logging uses consistent formats with timestamps, severity levels, component names, and message content. JSON format enables automated log parsing and analysis. Key-value pairs provide searchable metadata within log entries.

#### Log Rotation and Management

Log files require rotation to prevent disk space exhaustion. The `logrotate` utility manages automated rotation, compression, and cleanup. Scripts should handle log file rotation gracefully, potentially reopening log files when needed.

#### Contextual Logging

Adding contextual information like process ID, user, hostname, and operation identifiers helps correlate log entries. Function names and line numbers aid debugging. Request or transaction IDs enable tracing operations across multiple components.

#### Performance Considerations

Excessive logging can impact performance, especially with synchronous writes. Asynchronous logging or buffering improves performance but may lose recent log entries on crashes [Inference]. Log level filtering reduces overhead by skipping detailed logging in production.

**Example logging implementation:**

```bash
#!/bin/bash

# Logging configuration
LOG_FILE="/var/log/myscript.log"
LOG_LEVEL="INFO"

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] [$$] $message" >> "$LOG_FILE"
    
    # Also output to stderr for errors
    if [[ "$level" =~ ^(ERROR|FATAL)$ ]]; then
        echo "[$timestamp] [$level] $message" >&2
    fi
}

# Convenience functions
log_debug() { [[ "$LOG_LEVEL" == "DEBUG" ]] && log "DEBUG" "$@"; }
log_info() { log "INFO" "$@"; }
log_warn() { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }
```

### Configuration Management

Configuration management separates configuration data from script logic, enabling flexibility and maintainability across different environments.

#### Configuration File Formats

Common formats include key-value pairs, INI files, YAML, JSON, and shell variable files. Key-value format provides simplicity: `KEY=value`. INI format supports sections: `[section]` followed by key-value pairs. Shell variable files can be sourced directly but require careful validation.

#### Configuration Loading Strategies

Scripts can load configuration from multiple sources with precedence order: default values, system-wide configuration files, user-specific files, environment variables, and command-line arguments. This hierarchy allows flexible overrides while maintaining sensible defaults.

#### Environment-Specific Configuration

Different environments (development, staging, production) often require different configuration values. Using environment-specific configuration files or environment variable prefixes enables the same script to operate across environments. Configuration validation ensures required values are present and valid.

#### Dynamic Configuration Updates

Some applications benefit from runtime configuration updates without restart. File monitoring with `inotify` can trigger configuration reloading. However, atomic configuration updates prevent partial reads during file modifications [Inference].

#### Configuration Validation

Input validation ensures configuration values meet expected formats, ranges, and dependencies. Required parameter checking prevents runtime failures. Configuration schema validation catches errors early in the deployment process.

#### Secret Management

Sensitive configuration data like passwords and API keys require special handling. Environment variables provide better security than files for secrets. External secret management systems offer additional security through access controls and audit logging.

#### Configuration Templating

Template systems enable configuration generation from base templates with environment-specific values. Simple variable substitution using `envsubst` handles basic templating needs. More complex templating may require dedicated tools like Jinja2 or Go templates.

**Example configuration management:**

```bash
#!/bin/bash

# Default configuration
DEFAULT_CONFIG="/etc/myapp/config.conf"
USER_CONFIG="$HOME/.myapp/config.conf"

# Configuration variables with defaults
DB_HOST="localhost"
DB_PORT="5432"
LOG_LEVEL="INFO"
MAX_CONNECTIONS="100"

# Load configuration function
load_config() {
    local config_file="$1"
    
    if [[ -r "$config_file" ]]; then
        log_info "Loading configuration from $config_file"
        source "$config_file"
    fi
}

# Validate configuration
validate_config() {
    [[ -n "$DB_HOST" ]] || error_exit "DB_HOST not configured"
    [[ "$DB_PORT" =~ ^[0-9]+$ ]] || error_exit "DB_PORT must be numeric"
    [[ "$LOG_LEVEL" =~ ^(DEBUG|INFO|WARN|ERROR)$ ]] || error_exit "Invalid LOG_LEVEL"
}

# Load configurations in precedence order
load_config "$DEFAULT_CONFIG"
load_config "$USER_CONFIG"

# Override with environment variables
DB_HOST="${MYAPP_DB_HOST:-$DB_HOST}"
DB_PORT="${MYAPP_DB_PORT:-$DB_PORT}"
LOG_LEVEL="${MYAPP_LOG_LEVEL:-$LOG_LEVEL}"

# Validate final configuration
validate_config
```

**Key points:**

- Configuration should be externalized from script logic for flexibility
- Multiple configuration sources enable environment-specific customization
- Validation prevents runtime failures from invalid configuration
- Secrets require special handling separate from regular configuration data

**Conclusion:** Advanced scripting techniques improve reliability, maintainability, and performance of shell scripts. Error handling strategies prevent cascading failures and provide meaningful feedback. Comprehensive logging enables debugging and audit trails. Configuration management separates concerns and enables flexible deployment across environments. These practices transform simple scripts into robust, production-ready automation tools.

---

